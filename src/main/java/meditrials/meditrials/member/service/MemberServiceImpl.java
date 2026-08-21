package meditrials.meditrials.member.service;

import java.util.Locale;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.member.dao.MemberDAO;
import meditrials.meditrials.member.vo.MemberVO;

@Service
public class MemberServiceImpl implements MemberService {

    private static final String ROLE_USER = "USER";
    private static final String STATUS_ACTIVE = "ACTIVE";

    private final MemberDAO memberDAO;
    private final PasswordEncoder passwordEncoder;

    public MemberServiceImpl(MemberDAO memberDAO, PasswordEncoder passwordEncoder) {
        this.memberDAO = memberDAO;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public int getMemberCount() {
        return memberDAO.countMembers();
    }

    @Override
    public boolean isEmailDuplicated(String email) {
        if (email == null || email.isBlank()) {
            return false;
        }
        return memberDAO.countByEmail(normalizeEmail(email)) > 0;
    }

    @Override
    public MemberVO getMemberByNo(Long memberNo) {
        return memberDAO.selectMemberByNo(memberNo);
    }

    @Override
    public MemberVO getMemberByEmail(String email) {
        if (email == null || email.isBlank()) {
            return null;
        }
        return memberDAO.selectMemberByEmail(normalizeEmail(email));
    }

    @Override
    public MemberVO authenticate(String email, String rawPassword) {
        if (email == null || email.isBlank() || rawPassword == null || rawPassword.isBlank()) {
            return null;
        }

        MemberVO member = memberDAO.selectMemberByEmail(normalizeEmail(email));
        if (member == null || member.getPasswordHash() == null || member.getPasswordHash().isBlank()) {
            return null;
        }

        if (!passwordEncoder.matches(rawPassword, member.getPasswordHash())) {
            return null;
        }

        return member;
    }

    @Override
    @Transactional
    public MemberVO registerUser(String email, String rawPassword, String memberName, String phone) {
        String normalizedEmail = normalizeEmail(email);

        if (memberDAO.countByEmail(normalizedEmail) > 0) {
            throw new IllegalStateException("EMAIL_DUPLICATED");
        }

        MemberVO member = new MemberVO();
        member.setEmail(normalizedEmail);
        member.setPasswordHash(passwordEncoder.encode(rawPassword));
        member.setMemberName(memberName.trim());
        member.setPhone(phone.trim());
        member.setRoleCode(ROLE_USER);
        member.setStatus(STATUS_ACTIVE);

        int insertedRows = memberDAO.insertMember(member);
        if (insertedRows != 1) {
            throw new IllegalStateException("MEMBER_INSERT_FAILED");
        }

        return member;
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
