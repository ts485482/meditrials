package meditrials.meditrials.business.subscription.scheduler;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import meditrials.meditrials.business.subscription.service.BusinessSubscriptionService;

/**
 * PREMIUM 자동결제/예약취소 종료 처리.
 * MVP에서는 실제 PG 대신 PAYMENT_METHOD='TEST' 결제 내역을 매월 자동 생성한다.
 */
@Component
public class PremiumAutoBillingScheduler {

    private final BusinessSubscriptionService businessSubscriptionService;

    public PremiumAutoBillingScheduler(BusinessSubscriptionService businessSubscriptionService) {
        this.businessSubscriptionService = businessSubscriptionService;
    }

    @Scheduled(cron = "0 5 * * * *", zone = "Asia/Seoul")
    public void processPremiumBilling() {
        businessSubscriptionService.closeExpiredPremiums();
        businessSubscriptionService.processAutoRenewals();
    }
}
