package meditrials.meditrials.admin.promotion.service;

import java.util.List;

import meditrials.meditrials.admin.promotion.vo.AdminPromotionVO;

public interface AdminPromotionService {

    List<AdminPromotionVO> getPromotions();

    AdminPromotionVO getPromotion(Long promotionNo);

    void approvePromotion(Long adminMemberNo, Long promotionNo);

    void rejectPromotion(Long adminMemberNo, Long promotionNo, String rejectReason);
}
