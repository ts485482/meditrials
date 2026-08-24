package meditrials.meditrials.admin.payment.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.admin.payment.vo.AdminPaymentVO;

@Mapper
public interface AdminPaymentDAO {

    List<AdminPaymentVO> selectPaymentList();

    AdminPaymentVO selectPaymentByNo(@Param("paymentNo") Long paymentNo);

    int countOtherActiveSubscriptions(
            @Param("businessNo") Long businessNo,
            @Param("subscriptionNo") Long subscriptionNo);

    int markPaymentPaid(@Param("paymentNo") Long paymentNo);

    int activateSubscription(@Param("subscriptionNo") Long subscriptionNo);

    int cancelPendingPayment(@Param("paymentNo") Long paymentNo);

    int cancelPendingSubscription(@Param("subscriptionNo") Long subscriptionNo);

    int refundPaidPayment(@Param("paymentNo") Long paymentNo);

    int cancelActiveSubscription(@Param("subscriptionNo") Long subscriptionNo);

    int insertSubscriptionReviewLog(
            @Param("adminMemberNo") Long adminMemberNo,
            @Param("subscriptionNo") Long subscriptionNo,
            @Param("actionType") String actionType,
            @Param("reason") String reason);
}
