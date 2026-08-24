package meditrials.meditrials.business.promotion.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.business.promotion.service.BusinessPromotionService;
import meditrials.meditrials.business.promotion.vo.BusinessPromotionVO;
import meditrials.meditrials.business.subscription.service.BusinessSubscriptionService;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/business/promotions")
public class BusinessPromotionController {

    private final BusinessPromotionService businessPromotionService;
    private final BusinessSubscriptionService businessSubscriptionService;

    public BusinessPromotionController(
            BusinessPromotionService businessPromotionService,
            BusinessSubscriptionService businessSubscriptionService) {
        this.businessPromotionService = businessPromotionService;
        this.businessSubscriptionService = businessSubscriptionService;
    }

    @GetMapping
    public String promotions(
            @RequestParam(name = "result", required = false) String result,
            HttpSession session,
            Model model) {

        Long memberNo = loginMemberNo(session);
        if (!businessSubscriptionService.isPremiumActive(memberNo)) {
            return "redirect:/business/plans";
        }

        List<BusinessPromotionVO> trials = businessPromotionService.getPromotionTrials(memberNo);
        model.addAttribute("promotionTrials", trials);
        model.addAttribute("pageNotice", resolveNotice(result));
        model.addAttribute("pageError", resolveError(result));
        return "business/promotions";
    }

    @PostMapping("/{trialNo}/apply")
    public String apply(
            @PathVariable Long trialNo,
            HttpSession session) {
        try {
            businessPromotionService.applyPromotion(loginMemberNo(session), trialNo);
            return redirectResult("applied");
        } catch (IllegalArgumentException exception) {
            return redirectResult("invalid");
        } catch (IllegalStateException exception) {
            return redirectResult(resolveResultCode(exception.getMessage()));
        }
    }

    private Long loginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }

    private String redirectResult(String result) {
        return "redirect:/business/promotions?result=" + result;
    }

    private String resolveResultCode(String code) {
        if ("PREMIUM_REQUIRED".equals(code)) {
            return "premiumRequired";
        }
        if ("PROMOTION_ALREADY_OPEN".equals(code)) {
            return "alreadyOpen";
        }
        return "failed";
    }

    private String resolveNotice(String result) {
        if ("applied".equals(result)) {
            return "프리미엄 노출 신청이 완료되었습니다. 관리자 승인 후 메인 추천 영역과 임상시험 검색 상단에 우선 노출됩니다.";
        }
        return null;
    }

    private String resolveError(String result) {
        if (result == null) {
            return null;
        }
        return switch (result) {
            case "premiumRequired" -> "활성화된 PREMIUM 요금제가 있어야 프리미엄 노출을 신청할 수 있습니다.";
            case "alreadyOpen" -> "이미 승인 대기 또는 활성 상태의 프리미엄 노출 신청이 있습니다.";
            case "invalid" -> "본인의 승인 완료 임상시험만 프리미엄 노출을 신청할 수 있습니다.";
            case "failed" -> "프리미엄 노출 신청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.";
            default -> null;
        };
    }
}
