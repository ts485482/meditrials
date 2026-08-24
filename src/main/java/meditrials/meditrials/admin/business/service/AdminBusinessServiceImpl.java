package meditrials.meditrials.admin.business.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.admin.business.dao.AdminBusinessDAO;
import meditrials.meditrials.business.vo.BusinessVO;

@Service
public class AdminBusinessServiceImpl implements AdminBusinessService {

    private static final String STATUS_PENDING = "PENDING";
    private static final String ACTION_APPROVE = "APPROVE";
    private static final String ACTION_REJECT = "REJECT";

    private final AdminBusinessDAO adminBusinessDAO;

    public AdminBusinessServiceImpl(AdminBusinessDAO adminBusinessDAO) {
        this.adminBusinessDAO = adminBusinessDAO;
    }

    @Override
    public List<BusinessVO> getBusinesses() {
        return adminBusinessDAO.selectBusinessList();
    }

    @Override
    public BusinessVO getBusiness(Long businessNo) {
        if (businessNo == null) {
            return null;
        }
        return adminBusinessDAO.selectBusinessByNo(businessNo);
    }

    @Override
    @Transactional
    public void approveBusiness(Long adminMemberNo, Long businessNo) {
        BusinessVO business = requirePendingBusiness(businessNo);
        int updatedRows = adminBusinessDAO.approveBusiness(business.getBusinessNo());
        if (updatedRows != 1) {
            throw new IllegalStateException("BUSINESS_ALREADY_PROCESSED");
        }

        insertReviewLog(adminMemberNo, businessNo, ACTION_APPROVE, null);
    }

    @Override
    @Transactional
    public void rejectBusiness(Long adminMemberNo, Long businessNo, String rejectReason) {
        String normalizedReason = rejectReason == null ? "" : rejectReason.trim();
        if (normalizedReason.isEmpty()) {
            throw new IllegalArgumentException("반려 사유를 입력해주세요.");
        }

        BusinessVO business = requirePendingBusiness(businessNo);
        int updatedRows = adminBusinessDAO.rejectBusiness(
                business.getBusinessNo(), normalizedReason);
        if (updatedRows != 1) {
            throw new IllegalStateException("BUSINESS_ALREADY_PROCESSED");
        }

        insertReviewLog(adminMemberNo, businessNo, ACTION_REJECT, normalizedReason);
    }

    private BusinessVO requirePendingBusiness(Long businessNo) {
        if (businessNo == null) {
            throw new IllegalArgumentException("사업자 정보를 확인해주세요.");
        }

        BusinessVO business = adminBusinessDAO.selectBusinessByNo(businessNo);
        if (business == null) {
            throw new IllegalArgumentException("사업자 정보를 찾을 수 없습니다.");
        }
        if (!STATUS_PENDING.equals(business.getApprovalStatus())) {
            throw new IllegalStateException("BUSINESS_ALREADY_PROCESSED");
        }
        return business;
    }

    private void insertReviewLog(
            Long adminMemberNo,
            Long businessNo,
            String actionType,
            String reason) {

        if (adminMemberNo == null) {
            throw new IllegalStateException("ADMIN_SESSION_REQUIRED");
        }

        int insertedRows = adminBusinessDAO.insertReviewLog(
                adminMemberNo,
                businessNo,
                actionType,
                reason);
        if (insertedRows != 1) {
            throw new IllegalStateException("ADMIN_REVIEW_LOG_INSERT_FAILED");
        }
    }
}
