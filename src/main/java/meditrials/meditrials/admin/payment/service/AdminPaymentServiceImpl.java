package meditrials.meditrials.admin.payment.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.admin.payment.dao.AdminPaymentDAO;
import meditrials.meditrials.admin.payment.vo.AdminPaymentVO;

@Service
public class AdminPaymentServiceImpl implements AdminPaymentService {

    private static final String PAYMENT_PENDING = "PENDING";
    private static final String PAYMENT_PAID = "PAID";
    private static final String SUBSCRIPTION_PENDING = "PENDING";
    private static final String SUBSCRIPTION_ACTIVE = "ACTIVE";
    private static final String ACTION_ACTIVATE = "ACTIVATE";
    private static final String ACTION_REJECT = "REJECT";
    private static final String ACTION_END = "END";

    private final AdminPaymentDAO adminPaymentDAO;

    public AdminPaymentServiceImpl(AdminPaymentDAO adminPaymentDAO) {
        this.adminPaymentDAO = adminPaymentDAO;
    }

    @Override
    public List<AdminPaymentVO> getPayments() {
        return adminPaymentDAO.selectPaymentList();
    }

    @Override
    public AdminPaymentVO getPayment(Long paymentNo) {
        if (paymentNo == null) {
            return null;
        }
        return adminPaymentDAO.selectPaymentByNo(paymentNo);
    }

    @Override
    @Transactional
    public void completePayment(Long adminMemberNo, Long paymentNo) {
        AdminPaymentVO payment = requirePayment(paymentNo);
        requirePaymentStatus(payment, PAYMENT_PENDING);
        requireSubscriptionStatus(payment, SUBSCRIPTION_PENDING);
        requireAdmin(adminMemberNo);

        if (adminPaymentDAO.countOtherActiveSubscriptions(
                payment.getBusinessNo(), payment.getSubscriptionNo()) > 0) {
            throw new IllegalStateException("ACTIVE_SUBSCRIPTION_EXISTS");
        }

        int paymentRows = adminPaymentDAO.markPaymentPaid(paymentNo);
        if (paymentRows != 1) {
            throw new IllegalStateException("PAYMENT_ALREADY_PROCESSED");
        }

        int subscriptionRows = adminPaymentDAO.activateSubscription(payment.getSubscriptionNo());
        if (subscriptionRows != 1) {
            throw new IllegalStateException("SUBSCRIPTION_ALREADY_PROCESSED");
        }

        insertReviewLog(
                adminMemberNo,
                payment.getSubscriptionNo(),
                ACTION_ACTIVATE,
                "TEST/MANUAL 결제 완료 처리로 PREMIUM 활성화");
    }

    @Override
    @Transactional
    public void cancelPayment(Long adminMemberNo, Long paymentNo) {
        AdminPaymentVO payment = requirePayment(paymentNo);
        requirePaymentStatus(payment, PAYMENT_PENDING);
        requireSubscriptionStatus(payment, SUBSCRIPTION_PENDING);
        requireAdmin(adminMemberNo);

        int paymentRows = adminPaymentDAO.cancelPendingPayment(paymentNo);
        if (paymentRows != 1) {
            throw new IllegalStateException("PAYMENT_ALREADY_PROCESSED");
        }

        int subscriptionRows = adminPaymentDAO.cancelPendingSubscription(payment.getSubscriptionNo());
        if (subscriptionRows != 1) {
            throw new IllegalStateException("SUBSCRIPTION_ALREADY_PROCESSED");
        }

        insertReviewLog(
                adminMemberNo,
                payment.getSubscriptionNo(),
                ACTION_REJECT,
                "프리미엄 신청 결제 취소");
    }

    @Override
    @Transactional
    public void refundPayment(Long adminMemberNo, Long paymentNo) {
        AdminPaymentVO payment = requirePayment(paymentNo);
        requirePaymentStatus(payment, PAYMENT_PAID);
        requireSubscriptionStatus(payment, SUBSCRIPTION_ACTIVE);
        requireAdmin(adminMemberNo);

        int paymentRows = adminPaymentDAO.refundPaidPayment(paymentNo);
        if (paymentRows != 1) {
            throw new IllegalStateException("PAYMENT_ALREADY_PROCESSED");
        }

        int subscriptionRows = adminPaymentDAO.cancelActiveSubscription(payment.getSubscriptionNo());
        if (subscriptionRows != 1) {
            throw new IllegalStateException("SUBSCRIPTION_ALREADY_PROCESSED");
        }

        insertReviewLog(
                adminMemberNo,
                payment.getSubscriptionNo(),
                ACTION_END,
                "PREMIUM 결제 환불 및 이용 종료");
    }

    private AdminPaymentVO requirePayment(Long paymentNo) {
        if (paymentNo == null) {
            throw new IllegalArgumentException("결제 정보를 확인해주세요.");
        }

        AdminPaymentVO payment = adminPaymentDAO.selectPaymentByNo(paymentNo);
        if (payment == null) {
            throw new IllegalArgumentException("결제 정보를 찾을 수 없습니다.");
        }
        return payment;
    }

    private void requirePaymentStatus(AdminPaymentVO payment, String requiredStatus) {
        if (!requiredStatus.equals(payment.getPaymentStatus())) {
            throw new IllegalStateException("PAYMENT_ALREADY_PROCESSED");
        }
    }

    private void requireSubscriptionStatus(AdminPaymentVO payment, String requiredStatus) {
        if (!requiredStatus.equals(payment.getSubscriptionStatus())) {
            throw new IllegalStateException("SUBSCRIPTION_ALREADY_PROCESSED");
        }
    }

    private void requireAdmin(Long adminMemberNo) {
        if (adminMemberNo == null) {
            throw new IllegalStateException("ADMIN_SESSION_REQUIRED");
        }
    }

    private void insertReviewLog(
            Long adminMemberNo,
            Long subscriptionNo,
            String actionType,
            String reason) {

        int insertedRows = adminPaymentDAO.insertSubscriptionReviewLog(
                adminMemberNo,
                subscriptionNo,
                actionType,
                reason);
        if (insertedRows != 1) {
            throw new IllegalStateException("ADMIN_REVIEW_LOG_INSERT_FAILED");
        }
    }
}
