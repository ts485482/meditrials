package meditrials.meditrials.business.promotion.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.business.promotion.dao.BusinessPromotionDAO;
import meditrials.meditrials.business.promotion.vo.BusinessPromotionVO;
import meditrials.meditrials.business.subscription.service.BusinessSubscriptionService;

@Service
public class BusinessPromotionServiceImpl implements BusinessPromotionService {

    private final BusinessPromotionDAO businessPromotionDAO;
    private final BusinessSubscriptionService businessSubscriptionService;

    public BusinessPromotionServiceImpl(
            BusinessPromotionDAO businessPromotionDAO,
            BusinessSubscriptionService businessSubscriptionService) {
        this.businessPromotionDAO = businessPromotionDAO;
        this.businessSubscriptionService = businessSubscriptionService;
    }

    @Override
    @Transactional
    public List<BusinessPromotionVO> getPromotionTrials(Long memberNo) {
        if (memberNo == null) {
            return List.of();
        }
        businessPromotionDAO.endInactivePromotionsByMemberNo(memberNo);
        return businessPromotionDAO.selectPromotionTrialList(memberNo);
    }

    @Override
    @Transactional
    public void applyPromotion(Long memberNo, Long trialNo) {
        if (memberNo == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }
        if (trialNo == null) {
            throw new IllegalArgumentException("임상시험 번호를 확인해주세요.");
        }
        if (!businessSubscriptionService.isPremiumActive(memberNo)) {
            throw new IllegalStateException("PREMIUM_REQUIRED");
        }

        businessPromotionDAO.endInactivePromotionsByMemberNo(memberNo);
        BusinessPromotionVO trial = businessPromotionDAO.selectPromotionTrialByNo(memberNo, trialNo);
        if (trial == null) {
            throw new IllegalArgumentException("프리미엄 노출을 신청할 수 있는 승인 완료 임상시험을 찾을 수 없습니다.");
        }
        if (businessPromotionDAO.countOpenPromotionForTrial(memberNo, trialNo) > 0) {
            throw new IllegalStateException("PROMOTION_ALREADY_OPEN");
        }

        Long subscriptionNo = businessPromotionDAO.selectActiveSubscriptionNo(memberNo);
        if (subscriptionNo == null) {
            throw new IllegalStateException("PREMIUM_REQUIRED");
        }

        BusinessPromotionVO promotion = new BusinessPromotionVO();
        promotion.setTrialNo(trialNo);
        promotion.setBusinessNo(trial.getBusinessNo());
        promotion.setSubscriptionNo(subscriptionNo);

        int inserted = businessPromotionDAO.insertPromotion(promotion);
        if (inserted != 1) {
            throw new IllegalStateException("PROMOTION_INSERT_FAILED");
        }
    }
}
