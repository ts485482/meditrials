package meditrials.meditrials.admin.payment.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.admin.payment.service.AdminPaymentService;
import meditrials.meditrials.admin.payment.vo.AdminPaymentVO;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/admin/payments")
public class AdminPaymentController {

    private final AdminPaymentService adminPaymentService;

    public AdminPaymentController(AdminPaymentService adminPaymentService) {
        this.adminPaymentService = adminPaymentService;
    }

    @GetMapping
    public String payments(
            @RequestParam(name = "paymentNo", required = false) Long paymentNo,
            Model model) {

        List<AdminPaymentVO> payments = adminPaymentService.getPayments();
        AdminPaymentVO selectedPayment = resolveSelectedPayment(paymentNo, payments);

        model.addAttribute("payments", payments);
        model.addAttribute("selectedPayment", selectedPayment);
        model.addAttribute("pendingCount", countByStatus(payments, "PENDING"));
        model.addAttribute("paidCount", countByStatus(payments, "PAID"));
        model.addAttribute("closedCount", countByStatus(payments, "CANCELED")
                + countByStatus(payments, "REFUNDED"));
        return "admin/payments";
    }

    @PostMapping("/{paymentNo}/complete")
    public String complete(
            @PathVariable Long paymentNo,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            adminPaymentService.completePayment(getLoginMemberNo(session), paymentNo);
            redirectAttributes.addFlashAttribute(
                    "pageNotice",
                    "최초 결제 완료 처리와 PREMIUM 활성화가 완료되었습니다. 이후 월 결제는 자동 처리됩니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("pageError", resolveProcessError(exception.getMessage()));
        }
        return "redirect:/admin/payments?paymentNo=" + paymentNo;
    }

    @PostMapping("/{paymentNo}/cancel")
    public String cancel(
            @PathVariable Long paymentNo,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            adminPaymentService.cancelPayment(getLoginMemberNo(session), paymentNo);
            redirectAttributes.addFlashAttribute("pageNotice", "프리미엄 신청 결제를 취소했습니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("pageError", resolveProcessError(exception.getMessage()));
        }
        return "redirect:/admin/payments?paymentNo=" + paymentNo;
    }

    @PostMapping("/{paymentNo}/refund")
    public String refund(
            @PathVariable Long paymentNo,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            adminPaymentService.refundPayment(getLoginMemberNo(session), paymentNo);
            redirectAttributes.addFlashAttribute(
                    "pageNotice",
                    "환불 처리와 PREMIUM 이용 종료가 완료되었습니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute("pageError", resolveProcessError(exception.getMessage()));
        }
        return "redirect:/admin/payments?paymentNo=" + paymentNo;
    }

    private AdminPaymentVO resolveSelectedPayment(
            Long paymentNo,
            List<AdminPaymentVO> payments) {

        if (paymentNo != null) {
            AdminPaymentVO selected = adminPaymentService.getPayment(paymentNo);
            if (selected != null) {
                return selected;
            }
        }

        return payments.stream()
                .filter(payment -> "PENDING".equals(payment.getPaymentStatus()))
                .findFirst()
                .orElse(payments.isEmpty() ? null : payments.get(0));
    }

    private long countByStatus(List<AdminPaymentVO> payments, String status) {
        return payments.stream()
                .filter(payment -> status.equals(payment.getPaymentStatus()))
                .count();
    }

    private String resolveProcessError(String code) {
        if ("ACTIVE_SUBSCRIPTION_EXISTS".equals(code)) {
            return "이미 활성화된 PREMIUM 구독이 있어 처리할 수 없습니다.";
        }
        if ("PAYMENT_ALREADY_PROCESSED".equals(code)
                || "SUBSCRIPTION_ALREADY_PROCESSED".equals(code)) {
            return "이미 처리된 결제 또는 프리미엄 신청입니다. 화면을 새로고침해주세요.";
        }
        return "결제 상태를 변경하지 못했습니다. 잠시 후 다시 시도해주세요.";
    }

    private Long getLoginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }
}
