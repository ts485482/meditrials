package meditrials.meditrials.business.subscription.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.business.service.BusinessService;
import meditrials.meditrials.business.subscription.service.BusinessSubscriptionService;
import meditrials.meditrials.business.subscription.vo.BusinessSubscriptionVO;
import meditrials.meditrials.business.vo.BusinessVO;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/business")
public class BusinessSubscriptionController {

    private final BusinessSubscriptionService businessSubscriptionService;
    private final BusinessService businessService;

    public BusinessSubscriptionController(
            BusinessSubscriptionService businessSubscriptionService,
            BusinessService businessService) {
        this.businessSubscriptionService = businessSubscriptionService;
        this.businessService = businessService;
    }

    @GetMapping("/plans")
    public String plans(
            @RequestParam(name = "premiumRequired", defaultValue = "false") boolean premiumRequired,
            HttpSession session,
            Model model) {
        Long memberNo = getLoginMemberNo(session);
        BusinessVO business = businessService.getBusinessByMemberNo(memberNo);
        BusinessSubscriptionVO premium = businessSubscriptionService.getLatestPremium(memberNo);

        model.addAttribute("business", business);
        model.addAttribute("premium", premium);
        model.addAttribute("premiumMonthlyFee", businessSubscriptionService.getPremiumMonthlyFee());
        model.addAttribute("canApplyPremium", businessSubscriptionService.canApplyPremium(memberNo));
        model.addAttribute("premiumRequired", premiumRequired);
        return "business/plans";
    }

    @PostMapping("/plans/apply")
    public String applyPremium(
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            businessSubscriptionService.applyPremium(getLoginMemberNo(session));
            redirectAttributes.addFlashAttribute(
                    "pageNotice",
                    "프리미엄 이용 신청이 완료되었습니다. 관리자가 결제 완료 처리하면 PREMIUM이 활성화됩니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute(
                    "pageError",
                    resolveApplyError(exception.getMessage()));
        }

        return "redirect:/business/plans";
    }


    @PostMapping("/plans/cancel")
    public String cancelPremium(
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            businessSubscriptionService.requestPremiumCancellation(getLoginMemberNo(session));
            redirectAttributes.addFlashAttribute(
                    "pageNotice",
                    "PREMIUM 자동결제 취소 신청이 완료되었습니다. 현재 결제 주기 종료일까지 PREMIUM 기능을 이용할 수 있습니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute(
                    "pageError",
                    resolveCancelError(exception.getMessage()));
        }

        return "redirect:/business/plans";
    }


    @PostMapping("/plans/resume")
    public String resumePremiumAutoBilling(
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            businessSubscriptionService.resumePremiumAutoBilling(getLoginMemberNo(session));
            redirectAttributes.addFlashAttribute(
                    "pageNotice",
                    "자동결제 취소 신청이 철회되었습니다. PREMIUM 자동결제가 계속됩니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute(
                    "pageError",
                    resolveResumeError(exception.getMessage()));
        }

        return "redirect:/business/plans";
    }

    private String resolveApplyError(String errorCode) {
        if ("BUSINESS_NOT_APPROVED".equals(errorCode)) {
            return "관리자 승인이 완료된 사업자만 프리미엄을 신청할 수 있습니다.";
        }
        if ("PREMIUM_ALREADY_OPEN".equals(errorCode)) {
            return "이미 처리 중인 프리미엄 신청 또는 활성화된 PREMIUM 이용 내역이 있습니다.";
        }
        return "프리미엄 신청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.";
    }

    private String resolveCancelError(String errorCode) {
        if ("PREMIUM_NOT_ACTIVE".equals(errorCode)) {
            return "현재 활성화된 PREMIUM 이용 내역이 없습니다.";
        }
        if ("PREMIUM_CANCEL_ALREADY_REQUESTED".equals(errorCode)) {
            return "이미 자동결제 취소 신청이 완료되었습니다.";
        }
        if ("BUSINESS_NOT_APPROVED".equals(errorCode)) {
            return "승인된 사업자만 PREMIUM 이용 상태를 변경할 수 있습니다.";
        }
        return "PREMIUM 자동결제 취소 신청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.";
    }

    private String resolveResumeError(String errorCode) {
        if ("PREMIUM_NOT_ACTIVE".equals(errorCode)) {
            return "현재 활성화된 PREMIUM 이용 내역이 없습니다.";
        }
        if ("PREMIUM_CANCEL_NOT_REQUESTED".equals(errorCode)) {
            return "현재 자동결제 취소 신청 상태가 아닙니다.";
        }
        if ("PREMIUM_CANCEL_PERIOD_ENDED".equals(errorCode)) {
            return "이미 PREMIUM 이용 종료 예정일이 지나 자동결제를 이어할 수 없습니다. 새로 PREMIUM을 신청해주세요.";
        }
        if ("BUSINESS_NOT_APPROVED".equals(errorCode)) {
            return "승인된 사업자만 PREMIUM 이용 상태를 변경할 수 있습니다.";
        }
        return "PREMIUM 자동결제 이어하기를 처리하지 못했습니다. 잠시 후 다시 시도해주세요.";
    }

    private Long getLoginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }
}
