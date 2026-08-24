package meditrials.meditrials.business.subscription.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.subscription.dao.BusinessSubscriptionDAO;
import meditrials.meditrials.business.subscription.vo.BusinessSubscriptionVO;
import meditrials.meditrials.business.vo.BusinessVO;

@Service
public class BusinessSubscriptionServiceImpl implements BusinessSubscriptionService {

    private static final long PREMIUM_MONTHLY_FEE = 99_000L;
    private static final String BUSINESS_APPROVED = "APPROVED";
    private static final String PLAN_PREMIUM = "PREMIUM";
    private static final String SUBSCRIPTION_PENDING = "PENDING";
    private static final String PAYMENT_PENDING = "PENDING";
    private static final String PAYMENT_METHOD_TEST = "TEST";

    private final BusinessSubscriptionDAO businessSubscriptionDAO;
    private final BusinessService businessService;

    public BusinessSubscriptionServiceImpl(
            BusinessSubscriptionDAO businessSubscriptionDAO,
            BusinessService businessService) {
        this.businessSubscriptionDAO = businessSubscriptionDAO;
        this.businessService = businessService;
    }

    @Override
    public long getPremiumMonthlyFee() {
        return PREMIUM_MONTHLY_FEE;
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
        return premium != null && "ACTIVE".equals(premium.getSubscriptionStatus());
    }

    @Override
    @Transactional
    public void applyPremium(Long memberNo) {
        BusinessVO business = requireApprovedBusiness(memberNo);
        if (businessSubscriptionDAO.countOpenPremiumByMemberNo(memberNo) > 0) {
            throw new IllegalStateException("PREMIUM_ALREADY_OPEN");
        }

        BusinessSubscriptionVO subscription = new BusinessSubscriptionVO();
        subscription.setBusinessNo(business.getBusinessNo());
        subscription.setPlanType(PLAN_PREMIUM);
        subscription.setSubscriptionStatus(SUBSCRIPTION_PENDING);
        subscription.setMonthlyFee(PREMIUM_MONTHLY_FEE);
        subscription.setAmount(PREMIUM_MONTHLY_FEE);
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
