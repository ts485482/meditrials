package meditrials.meditrials.admin.promotion.controller;

import java.util.List;
import java.util.Locale;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.admin.promotion.service.AdminPromotionService;
import meditrials.meditrials.admin.promotion.vo.AdminPromotionVO;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/admin/promotions")
public class AdminPromotionController {

    private final AdminPromotionService adminPromotionService;

    public AdminPromotionController(AdminPromotionService adminPromotionService) {
        this.adminPromotionService = adminPromotionService;
    }

    @GetMapping
    public String list(
            @RequestParam(name = "status", defaultValue = "ALL") String status,
            @RequestParam(name = "promotionNo", required = false) Long promotionNo,
            @RequestParam(name = "result", required = false) String result,
            Model model) {

        String selectedStatus = normalizeStatus(status);
        List<AdminPromotionVO> allPromotions = adminPromotionService.getPromotions();
        List<AdminPromotionVO> filtered = filterByStatus(allPromotions, selectedStatus);
        AdminPromotionVO selected = resolveSelectedPromotion(promotionNo, filtered, allPromotions);

        model.addAttribute("promotions", filtered);
        model.addAttribute("selectedPromotion", selected);
        model.addAttribute("selectedStatus", selectedStatus);
        model.addAttribute("pendingCount", countStatus(allPromotions, "PENDING"));
        model.addAttribute("activeCount", countStatus(allPromotions, "ACTIVE"));
        model.addAttribute("closedCount", countStatus(allPromotions, "REJECTED") + countStatus(allPromotions, "ENDED"));
        model.addAttribute("pageNotice", resolveNotice(result));
        model.addAttribute("pageError", resolveError(result));
        return "admin/promotions";
    }

    @PostMapping("/{promotionNo}/approve")
    public String approve(
            @PathVariable Long promotionNo,
            HttpSession session) {
        try {
            adminPromotionService.approvePromotion(loginMemberNo(session), promotionNo);
            return redirectResult(promotionNo, "approved");
        } catch (IllegalArgumentException exception) {
            return redirectResult(promotionNo, "invalid");
        } catch (IllegalStateException exception) {
            return redirectResult(promotionNo, resolveFailureCode(exception.getMessage()));
        }
    }

    @PostMapping("/{promotionNo}/reject")
    public String reject(
            @PathVariable Long promotionNo,
            @RequestParam(name = "rejectReason", required = false) String rejectReason,
            HttpSession session) {
        try {
            adminPromotionService.rejectPromotion(loginMemberNo(session), promotionNo, rejectReason);
            return redirectResult(promotionNo, "rejected");
        } catch (IllegalArgumentException exception) {
            return redirectResult(promotionNo, "reasonRequired");
        } catch (IllegalStateException exception) {
            return redirectResult(promotionNo, resolveFailureCode(exception.getMessage()));
        }
    }

    private AdminPromotionVO resolveSelectedPromotion(
            Long promotionNo,
            List<AdminPromotionVO> filtered,
            List<AdminPromotionVO> allPromotions) {
        if (promotionNo != null) {
            AdminPromotionVO selected = adminPromotionService.getPromotion(promotionNo);
            if (selected != null) {
                return selected;
            }
        }
        if (!filtered.isEmpty()) {
            return filtered.get(0);
        }
        return allPromotions.isEmpty() ? null : allPromotions.get(0);
    }

    private List<AdminPromotionVO> filterByStatus(List<AdminPromotionVO> promotions, String status) {
        if ("ALL".equals(status)) {
            return promotions;
        }
        return promotions.stream()
                .filter(promotion -> status.equals(promotion.getPromotionStatus()))
                .toList();
    }

    private long countStatus(List<AdminPromotionVO> promotions, String status) {
        return promotions.stream()
                .filter(promotion -> status.equals(promotion.getPromotionStatus()))
                .count();
    }

    private String normalizeStatus(String value) {
        if (value == null) {
            return "ALL";
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        return switch (normalized) {
            case "PENDING", "ACTIVE", "REJECTED", "ENDED" -> normalized;
            default -> "ALL";
        };
    }

    private Long loginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }

    private String redirectResult(Long promotionNo, String result) {
        return "redirect:/admin/promotions?promotionNo=" + promotionNo + "&result=" + result;
    }

    private String resolveFailureCode(String code) {
        if ("PROMOTION_ALREADY_PROCESSED".equals(code)) {
            return "alreadyProcessed";
        }
        return "failed";
    }

    private String resolveNotice(String result) {
        if ("approved".equals(result)) {
            return "프리미엄 노출을 승인했습니다. 해당 임상시험이 메인 추천 영역과 임상시험 검색 상단에 우선 노출됩니다.";
        }
        if ("rejected".equals(result)) {
            return "프리미엄 노출 신청을 반려했습니다.";
        }
        return null;
    }

    private String resolveError(String result) {
        if (result == null) {
            return null;
        }
        return switch (result) {
            case "reasonRequired" -> "반려 사유를 입력해주세요.";
            case "alreadyProcessed" -> "이미 처리된 프리미엄 노출 신청입니다. 화면을 새로고침해주세요.";
            case "invalid" -> "프리미엄 노출 신청 정보를 찾을 수 없습니다.";
            case "failed" -> "프리미엄 노출 상태를 변경하지 못했습니다. PREMIUM 이용 상태와 임상시험 승인 상태를 확인해주세요.";
            default -> null;
        };
    }
}
