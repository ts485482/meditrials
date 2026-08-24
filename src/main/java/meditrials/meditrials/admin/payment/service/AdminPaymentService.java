package meditrials.meditrials.admin.payment.service;

import java.util.List;

import meditrials.meditrials.admin.payment.vo.AdminPaymentVO;

public interface AdminPaymentService {

    List<AdminPaymentVO> getPayments();

    AdminPaymentVO getPayment(Long paymentNo);

    void completePayment(Long adminMemberNo, Long paymentNo);

    void cancelPayment(Long adminMemberNo, Long paymentNo);

    void refundPayment(Long adminMemberNo, Long paymentNo);
}
