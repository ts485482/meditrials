package meditrials.meditrials.admin.plan.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.common.constant.SessionConstants;
import meditrials.meditrials.plan.service.PlanPolicyService;

@Controller
@RequestMapping("/admin/plans")
public class AdminPlanController {

    private final PlanPolicyService planPolicyService;

    public AdminPlanController(PlanPolicyService planPolicyService) {
        this.planPolicyService = planPolicyService;
    }

    @GetMapping
    public String plans(Model model) {
        model.addAttribute("freePolicy", planPolicyService.getFreePolicy());
        model.addAttribute("premiumPolicy", planPolicyService.getPremiumPolicy());
        return "admin/plans";
    }

    @PostMapping("/premium")
    public String updatePremiumPolicy(
            @RequestParam("monthlyFee") String monthlyFeeText,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            Long monthlyFee = parseMonthlyFee(monthlyFeeText);
            planPolicyService.updatePremiumMonthlyFee(monthlyFee, getLoginMemberNo(session));
            redirectAttributes.addFlashAttribute(
                    "pageNotice",
                    "PREMIUM 월 이용료가 저장되었습니다. 변경 금액은 이후 새로 신청하는 PREMIUM 구독부터 적용됩니다.");
        } catch (IllegalArgumentException exception) {
            redirectAttributes.addFlashAttribute("pageError", exception.getMessage());
        } catch (IllegalStateException exception) {
            redirectAttributes.addFlashAttribute(
                    "pageError",
                    "요금제 정책을 저장하지 못했습니다. 잠시 후 다시 시도해주세요.");
        }

        return "redirect:/admin/plans";
    }

    private Long parseMonthlyFee(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("PREMIUM 월 이용료를 입력해주세요.");
        }

        String normalized = value.replace(",", "").trim();
        try {
            return Long.valueOf(normalized);
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException("월 이용료는 숫자로 입력해주세요.");
        }
    }

    private Long getLoginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }
}
