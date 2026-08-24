package meditrials.meditrials.business.service;

import java.util.Locale;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.business.dao.BusinessDAO;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.member.dao.MemberDAO;
import meditrials.meditrials.member.vo.MemberVO;

@Service
public class BusinessServiceImpl implements BusinessService {

    private static final String ROLE_BUSINESS = "BUSINESS";
    private static final String STATUS_ACTIVE = "ACTIVE";
    private static final String APPROVAL_PENDING = "PENDING";

    private final BusinessDAO businessDAO;
    private final MemberDAO memberDAO;
    private final PasswordEncoder passwordEncoder;

    public BusinessServiceImpl(
            BusinessDAO businessDAO,
            MemberDAO memberDAO,
            PasswordEncoder passwordEncoder) {
        this.businessDAO = businessDAO;
        this.memberDAO = memberDAO;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public int getBusinessCount() {
        return businessDAO.countBusinesses();
    }

    @Override
    public boolean isBusinessRegNoDuplicated(String businessRegNo) {
        if (businessRegNo == null || businessRegNo.isBlank()) {
            return false;
        }
        return businessDAO.countByBusinessRegNo(businessRegNo.trim()) > 0;
    }

    @Override
    public BusinessVO getBusinessByNo(Long businessNo) {
        return businessDAO.selectBusinessByNo(businessNo);
    }

    @Override
    public BusinessVO getBusinessByMemberNo(Long memberNo) {
        return businessDAO.selectBusinessByMemberNo(memberNo);
    }

    @Override
    @Transactional
    public BusinessVO registerBusiness(
            String email,
            String rawPassword,
            String memberName,
            String memberPhone,
            BusinessVO business) {

        if (business == null) {
            throw new IllegalArgumentException("BUSINESS_REQUIRED");
        }

        String normalizedEmail = normalizeEmail(email);
        String normalizedBusinessRegNo = trim(business.getBusinessRegNo());

        if (memberDAO.countByEmail(normalizedEmail) > 0) {
            throw new IllegalStateException("EMAIL_DUPLICATED");
        }
        if (businessDAO.countByBusinessRegNo(normalizedBusinessRegNo) > 0) {
            throw new IllegalStateException("BUSINESS_REG_NO_DUPLICATED");
        }

        MemberVO member = new MemberVO();
        member.setEmail(normalizedEmail);
        member.setPasswordHash(passwordEncoder.encode(rawPassword));
        member.setMemberName(trim(memberName));
        member.setPhone(trim(memberPhone));
        member.setRoleCode(ROLE_BUSINESS);
        member.setStatus(STATUS_ACTIVE);

        int memberRows = memberDAO.insertMember(member);
        if (memberRows != 1 || member.getMemberNo() == null) {
            throw new IllegalStateException("MEMBER_INSERT_FAILED");
        }

        business.setMemberNo(member.getMemberNo());
        business.setOrgName(trim(business.getOrgName()));
        business.setOrgType(trim(business.getOrgType()).toUpperCase(Locale.ROOT));
        business.setBusinessRegNo(normalizedBusinessRegNo);
        business.setPhone(trim(business.getPhone()));
        business.setEmail(normalizedEmail);
        business.setAddress(trimToNull(business.getAddress()));
        business.setDescription(trimToNull(business.getDescription()));
        business.setApprovalStatus(APPROVAL_PENDING);

        int businessRows = businessDAO.insertBusiness(business);
        if (businessRows != 1 || business.getBusinessNo() == null) {
            throw new IllegalStateException("BUSINESS_INSERT_FAILED");
        }

        return business;
    }

    @Override
    @Transactional
    public BusinessVO updateBusinessProfile(
            Long memberNo,
            String phone,
            String email,
            String address,
            String description) {

        if (memberNo == null) {
            throw new IllegalArgumentException("MEMBER_NO_REQUIRED");
        }

        BusinessVO business = businessDAO.selectBusinessByMemberNo(memberNo);
        if (business == null) {
            throw new IllegalStateException("BUSINESS_NOT_FOUND");
        }

        String normalizedPhone = trim(phone);
        String normalizedEmail = normalizeEmail(email);
        if (normalizedPhone.isEmpty() || normalizedEmail.isEmpty()) {
            throw new IllegalArgumentException("CONTACT_REQUIRED");
        }

        int updatedRows = businessDAO.updateBusinessProfile(
                memberNo,
                normalizedPhone,
                normalizedEmail,
                trimToNull(address),
                trimToNull(description));

        if (updatedRows != 1) {
            throw new IllegalStateException("BUSINESS_UPDATE_FAILED");
        }

        return businessDAO.selectBusinessByMemberNo(memberNo);
    }

    private String normalizeEmail(String email) {
        return trim(email).toLowerCase(Locale.ROOT);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String trimToNull(String value) {
        String trimmed = trim(value);
        return trimmed.isEmpty() ? null : trimmed;
    }
}
