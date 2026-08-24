package meditrials.meditrials.business.promotion.service;

import java.util.List;

import meditrials.meditrials.business.promotion.vo.BusinessPromotionVO;

public interface BusinessPromotionService {

    List<BusinessPromotionVO> getPromotionTrials(Long memberNo);

    void applyPromotion(Long memberNo, Long trialNo);
}
