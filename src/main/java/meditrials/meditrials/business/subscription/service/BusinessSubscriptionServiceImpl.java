package meditrials.meditrials.business.subscription.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.subscription.dao.BusinessSubscriptionDAO;
import meditrials.meditrials.business.subscription.vo.BusinessSubscriptionVO;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.plan.service.PlanPolicyService;

@Service
public class BusinessSubscriptionServiceImpl implements BusinessSubscriptionService {

    private static final String BUSINESS_APPROVED = "APPROVED";
    private static final String PLAN_PREMIUM = "PREMIUM";
    private static final String SUBSCRIPTION_PENDING = "PENDING";
    private static final String SUBSCRIPTION_ACTIVE = "ACTIVE";
    private static final String PAYMENT_PENDING = "PENDING";
    private static final String PAYMENT_METHOD_TEST = "TEST";

    private final BusinessSubscriptionDAO businessSubscriptionDAO;
    private final BusinessService businessService;
    private final PlanPolicyService planPolicyService;

    public BusinessSubscriptionServiceImpl(
            BusinessSubscriptionDAO businessSubscriptionDAO,
            BusinessService businessService,
            PlanPolicyService planPolicyService) {
        this.businessSubscriptionDAO = businessSubscriptionDAO;
        this.businessService = businessService;
        this.planPolicyService = planPolicyService;
    }

    @Override
    public long getPremiumMonthlyFee() {
        return planPolicyService.getPremiumMonthlyFee();
    }

    @Override
    public BusinessSubscriptionVO getLatestPremium(Long memberNo) {
        if (memberNo == null) {
            return null;
        }
        return businessSubscriptionDAO.selectLatestPremiumByMemberNo(memberNo);
    }

    @Override
    public boolean canApplyPremium(Long memberNo) {
        if (memberNo == null) {
            return false;
        }

        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        if (business == null || !BUSINESS_APPROVED.equals(business.getApprovalStatus())) {
            return false;
        }

        return businessSubscriptionDAO.countOpenPremiumByMemberNo(memberNo) == 0;
    }

    @Override
    public boolean isPremiumActive(Long memberNo) {
        BusinessSubscriptionVO premium = getLatestPremium(memberNo);
        if (premium == null || !SUBSCRIPTION_ACTIVE.equals(premium.getSubscriptionStatus())) {
            return false;
        }

        LocalDateTime endDate = premium.getEndDate();
        return endDate == null || endDate.isAfter(LocalDateTime.now());
    }

    @Override
    @Transactional
    public void applyPremium(Long memberNo) {
        BusinessVO business = requireApprovedBusiness(memberNo);
        businessSubscriptionDAO.closeExpiredPremiumSubscriptions();
        if (businessSubscriptionDAO.countOpenPremiumByMemberNo(memberNo) > 0) {
            throw new IllegalStateException("PREMIUM_ALREADY_OPEN");
        }

        long premiumMonthlyFee = planPolicyService.getPremiumMonthlyFee();

        BusinessSubscriptionVO subscription = new BusinessSubscriptionVO();
        subscription.setBusinessNo(business.getBusinessNo());
        subscription.setPlanType(PLAN_PREMIUM);
        subscription.setSubscriptionStatus(SUBSCRIPTION_PENDING);
        subscription.setMonthlyFee(premiumMonthlyFee);
        subscription.setAmount(premiumMonthlyFee);
        subscription.setPaymentMethod(PAYMENT_METHOD_TEST);
        subscription.setPaymentStatus(PAYMENT_PENDING);

        int insertedSubscription = businessSubscriptionDAO.insertPremiumSubscription(subscription);
        if (insertedSubscription != 1 || subscription.getSubscriptionNo() == null) {
            throw new IllegalStateException("PREMIUM_SUBSCRIPTION_INSERT_FAILED");
        }

        int insertedPayment = businessSubscriptionDAO.insertPendingPayment(subscription);
        if (insertedPayment != 1) {
            throw new IllegalStateException("PREMIUM_PAYMENT_INSERT_FAILED");
        }
    }

    @Override
    @Transactional
    public void requestPremiumCancellation(Long memberNo) {
        requireApprovedBusiness(memberNo);

        BusinessSubscriptionVO premium = getLatestPremium(memberNo);
        if (premium == null || !SUBSCRIPTION_ACTIVE.equals(premium.getSubscriptionStatus())) {
            throw new IllegalStateException("PREMIUM_NOT_ACTIVE");
        }
        if (premium.getEndDate() != null) {
            throw new IllegalStateException("PREMIUM_CANCEL_ALREADY_REQUESTED");
        }

        LocalDateTime endDate = premium.getNextBillingDate();
        if (endDate == null) {
            endDate = calculateNextBillingDate(premium);
        }
        if (endDate == null) {
            throw new IllegalStateException("PREMIUM_END_DATE_CALCULATION_FAILED");
        }

        int updatedRows = businessSubscriptionDAO.schedulePremiumCancellation(
                premium.getSubscriptionNo(), endDate);
        if (updatedRows != 1) {
            throw new IllegalStateException("PREMIUM_CANCEL_UPDATE_FAILED");
        }
    }

    @Override
    @Transactional
    public void resumePremiumAutoBilling(Long memberNo) {
        requireApprovedBusiness(memberNo);

        BusinessSubscriptionVO premium = getLatestPremium(memberNo);
        if (premium == null || !SUBSCRIPTION_ACTIVE.equals(premium.getSubscriptionStatus())) {
            throw new IllegalStateException("PREMIUM_NOT_ACTIVE");
        }
        if (premium.getEndDate() == null) {
            throw new IllegalStateException("PREMIUM_CANCEL_NOT_REQUESTED");
        }
        if (!premium.getEndDate().isAfter(LocalDateTime.now())) {
            throw new IllegalStateException("PREMIUM_CANCEL_PERIOD_ENDED");
        }

        int updatedRows = businessSubscriptionDAO.resumePremiumAutoBilling(
                premium.getSubscriptionNo());
        if (updatedRows != 1) {
            throw new IllegalStateException("PREMIUM_RESUME_UPDATE_FAILED");
        }
    }

    @Override
    @Transactional
    public int processAutoRenewals() {
        LocalDateTime now = LocalDateTime.now();
        List<BusinessSubscriptionVO> subscriptions = businessSubscriptionDAO.selectActivePremiumForAutoBilling();
        int paymentCount = 0;

        for (BusinessSubscriptionVO subscription : subscriptions) {
            if (subscription.getStartDate() == null) {
                continue;
            }

            int paidCount = subscription.getPaidPaymentCount() == null
                    ? 0
                    : subscription.getPaidPaymentCount();
            LocalDateTime dueDate = subscription.getStartDate().plusMonths(paidCount);

            while (!dueDate.toLocalDate().isAfter(now.toLocalDate())) {
                LocalDateTime endDate = subscription.getEndDate();
                if (endDate != null && !dueDate.isBefore(endDate)) {
                    break;
                }

                subscription.setAmount(subscription.getMonthlyFee() == null
                        ? planPolicyService.getPremiumMonthlyFee()
                        : subscription.getMonthlyFee());

                int insertedRows = businessSubscriptionDAO.insertAutoPaidPayment(subscription);
                if (insertedRows != 1) {
                    throw new IllegalStateException("PREMIUM_AUTO_PAYMENT_INSERT_FAILED");
                }

                paymentCount++;
                paidCount++;
                dueDate = subscription.getStartDate().plusMonths(paidCount);
            }
        }

        return paymentCount;
    }

    @Override
    @Transactional
    public int closeExpiredPremiums() {
        return businessSubscriptionDAO.closeExpiredPremiumSubscriptions();
    }

    private LocalDateTime calculateNextBillingDate(BusinessSubscriptionVO premium) {
        if (premium.getStartDate() == null) {
            return null;
        }

        int paidCount = premium.getPaidPaymentCount() == null
                ? 0
                : premium.getPaidPaymentCount();
        LocalDateTime nextBillingDate = premium.getStartDate().plusMonths(paidCount);
        LocalDateTime now = LocalDateTime.now();

        while (!nextBillingDate.isAfter(now)) {
            paidCount++;
            nextBillingDate = premium.getStartDate().plusMonths(paidCount);
        }
        return nextBillingDate;
    }

    private BusinessVO requireApprovedBusiness(Long memberNo) {
        if (memberNo == null) {
            throw new IllegalStateException("LOGIN_REQUIRED");
        }

        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        if (business == null) {
            throw new IllegalArgumentException("사업자 정보를 찾을 수 없습니다.");
        }
        if (!BUSINESS_APPROVED.equals(business.getApprovalStatus())) {
            throw new IllegalStateException("BUSINESS_NOT_APPROVED");
        }
        return business;
    }
}
