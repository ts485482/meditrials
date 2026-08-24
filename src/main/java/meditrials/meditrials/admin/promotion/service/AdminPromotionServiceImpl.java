package meditrials.meditrials.admin.promotion.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.admin.promotion.dao.AdminPromotionDAO;
import meditrials.meditrials.admin.promotion.vo.AdminPromotionVO;

@Service
public class AdminPromotionServiceImpl implements AdminPromotionService {

    private static final String PENDING = "PENDING";

    private final AdminPromotionDAO adminPromotionDAO;

    public AdminPromotionServiceImpl(AdminPromotionDAO adminPromotionDAO) {
        this.adminPromotionDAO = adminPromotionDAO;
    }

    @Override
    @Transactional
    public List<AdminPromotionVO> getPromotions() {
        adminPromotionDAO.endInactivePromotions();
        return adminPromotionDAO.selectPromotionList();
    }

    @Override
    @Transactional
    public AdminPromotionVO getPromotion(Long promotionNo) {
        if (promotionNo == null) {
            return null;
        }
        adminPromotionDAO.endInactivePromotions();
        return adminPromotionDAO.selectPromotionByNo(promotionNo);
    }

    @Override
    @Transactional
    public void approvePromotion(Long adminMemberNo, Long promotionNo) {
        validateAdminAndPromotion(adminMemberNo, promotionNo);
        requirePendingPromotion(promotionNo);

        int updated = adminPromotionDAO.approvePromotion(promotionNo);
        if (updated != 1) {
            throw new IllegalStateException("PROMOTION_APPROVE_FAILED");
        }
        insertReviewLog(adminMemberNo, promotionNo, "APPROVE", null);
    }

    @Override
    @Transactional
    public void rejectPromotion(Long adminMemberNo, Long promotionNo, String rejectReason) {
        validateAdminAndPromotion(adminMemberNo, promotionNo);
        String normalizedReason = trimToNull(rejectReason);
        if (normalizedReason == null) {
            throw new IllegalArgumentException("반려 사유를 입력해주세요.");
        }
        if (normalizedReason.length() > 1000) {
            throw new IllegalArgumentException("반려 사유는 1000자 이내로 입력해주세요.");
        }

        requirePendingPromotion(promotionNo);
        int updated = adminPromotionDAO.rejectPromotion(promotionNo, normalizedReason);
        if (updated != 1) {
            throw new IllegalStateException("PROMOTION_REJECT_FAILED");
        }
        insertReviewLog(adminMemberNo, promotionNo, "REJECT", normalizedReason);
    }

    private AdminPromotionVO requirePendingPromotion(Long promotionNo) {
        AdminPromotionVO promotion = adminPromotionDAO.selectPromotionByNo(promotionNo);
        if (promotion == null) {
            throw new IllegalArgumentException("프리미엄 노출 신청을 찾을 수 없습니다.");
        }
        if (!PENDING.equals(promotion.getPromotionStatus())) {
            throw new IllegalStateException("PROMOTION_ALREADY_PROCESSED");
        }
        return promotion;
    }

    private void validateAdminAndPromotion(Long adminMemberNo, Long promotionNo) {
        if (adminMemberNo == null) {
            throw new IllegalStateException("ADMIN_SESSION_REQUIRED");
        }
        if (promotionNo == null) {
            throw new IllegalArgumentException("프리미엄 노출 신청 번호를 확인해주세요.");
        }
    }

    private void insertReviewLog(
            Long adminMemberNo,
            Long promotionNo,
            String actionType,
            String reason) {
        int inserted = adminPromotionDAO.insertReviewLog(
                adminMemberNo,
                promotionNo,
                actionType,
                reason);
        if (inserted != 1) {
            throw new IllegalStateException("ADMIN_REVIEW_LOG_INSERT_FAILED");
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
