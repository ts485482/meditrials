package meditrials.meditrials.admin.trial.controller;

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
import meditrials.meditrials.admin.trial.service.AdminTrialReviewService;
import meditrials.meditrials.admin.trial.vo.AdminTrialReviewVO;
import meditrials.meditrials.common.constant.SessionConstants;

@Controller
@RequestMapping("/admin/trials")
public class AdminTrialReviewController {

    private final AdminTrialReviewService adminTrialReviewService;

    public AdminTrialReviewController(AdminTrialReviewService adminTrialReviewService) {
        this.adminTrialReviewService = adminTrialReviewService;
    }

    @GetMapping
    public String list(
            @RequestParam(name = "status", defaultValue = "ALL") String status,
            @RequestParam(name = "trialNo", required = false) Long trialNo,
            @RequestParam(name = "result", required = false) String result,
            Model model) {

        String selectedStatus = normalizeStatus(status);
        List<AdminTrialReviewVO> allTrials = adminTrialReviewService.getReviewTrials();
        List<AdminTrialReviewVO> filteredTrials = filterByStatus(allTrials, selectedStatus);

        AdminTrialReviewVO selectedTrial = trialNo == null
                ? selectDefaultTrial(filteredTrials, allTrials)
                : adminTrialReviewService.getReviewTrial(trialNo);

        model.addAttribute("trials", filteredTrials);
        model.addAttribute("selectedTrial", selectedTrial);
        model.addAttribute("selectedStatus", selectedStatus);
        model.addAttribute("pendingCount", countStatus(allTrials, "PENDING"));
        model.addAttribute("approvedCount", countStatus(allTrials, "APPROVED"));
        model.addAttribute("rejectedCount", countStatus(allTrials, "REJECTED"));
        model.addAttribute("pageNotice", resolveNotice(result));
        return "admin/trials";
    }

    @PostMapping("/{trialNo}/approve")
    public String approve(
            @PathVariable Long trialNo,
            HttpSession session) {
        try {
            adminTrialReviewService.approveTrial(loginMemberNo(session), trialNo);
            return redirectResult(trialNo, "approved");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return redirectResult(trialNo, "failed");
        }
    }

    @PostMapping("/{trialNo}/reject")
    public String reject(
            @PathVariable Long trialNo,
            @RequestParam(name = "rejectReason", required = false) String rejectReason,
            HttpSession session) {
        try {
            adminTrialReviewService.rejectTrial(loginMemberNo(session), trialNo, rejectReason);
            return redirectResult(trialNo, "rejected");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return redirectResult(trialNo, "failed");
        }
    }

    private List<AdminTrialReviewVO> filterByStatus(
            List<AdminTrialReviewVO> trials,
            String status) {
        if ("ALL".equals(status)) {
            return trials;
        }
        return trials.stream()
                .filter(trial -> status.equals(trial.getReviewStatus()))
                .toList();
    }

    private AdminTrialReviewVO selectDefaultTrial(
            List<AdminTrialReviewVO> filteredTrials,
            List<AdminTrialReviewVO> allTrials) {
        if (!filteredTrials.isEmpty()) {
            return filteredTrials.get(0);
        }
        return allTrials.stream()
                .filter(trial -> "PENDING".equals(trial.getReviewStatus()))
                .findFirst()
                .orElse(null);
    }

    private long countStatus(List<AdminTrialReviewVO> trials, String status) {
        return trials.stream()
                .filter(trial -> status.equals(trial.getReviewStatus()))
                .count();
    }

    private String normalizeStatus(String value) {
        if (value == null) {
            return "ALL";
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        return switch (normalized) {
            case "PENDING", "APPROVED", "REJECTED" -> normalized;
            default -> "ALL";
        };
    }

    private Long loginMemberNo(HttpSession session) {
        Object value = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        return value instanceof Number number ? number.longValue() : null;
    }

    private String redirectResult(Long trialNo, String result) {
        return "redirect:/admin/trials?trialNo=" + trialNo + "&result=" + result;
    }

    private String resolveNotice(String result) {
        if (result == null) {
            return null;
        }
        return switch (result) {
            case "approved" -> "임상시험을 승인했습니다. 사용자 임상시험 검색에 공개됩니다.";
            case "rejected" -> "임상시험을 반려했습니다. 사업자가 반려 사유를 확인한 뒤 수정하여 다시 검수 요청할 수 있습니다.";
            case "failed" -> "검수 처리에 실패했습니다. 현재 상태를 확인한 뒤 다시 시도해주세요.";
            default -> null;
        };
    }
}
