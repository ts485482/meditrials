package meditrials.meditrials.business.subscription.service;

import meditrials.meditrials.business.subscription.vo.BusinessSubscriptionVO;

public interface BusinessSubscriptionService {

    long getPremiumMonthlyFee();

    BusinessSubscriptionVO getLatestPremium(Long memberNo);

    boolean canApplyPremium(Long memberNo);

    boolean isPremiumActive(Long memberNo);

    void applyPremium(Long memberNo);

    void requestPremiumCancellation(Long memberNo);

    void resumePremiumAutoBilling(Long memberNo);

    int processAutoRenewals();

    int closeExpiredPremiums();
}
