package meditrials.meditrials.trial.controller;

import java.util.Locale;
import java.util.Set;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.common.constant.SessionConstants;
import meditrials.meditrials.favorite.service.FavoriteService;
import meditrials.meditrials.trial.service.TrialService;
import meditrials.meditrials.trial.vo.TrialSearchResultVO;
import meditrials.meditrials.trial.vo.TrialVO;

@Controller
@RequestMapping("/trials")
public class TrialController {

    private static final String ROLE_USER = "USER";

    private static final Set<String> ALLOWED_STATUSES = Set.of(
            "ALL",
            "RECRUITING",
            "NOT_YET_RECRUITING",
            "COMPLETED");

    private static final Set<String> ALLOWED_PHASES = Set.of(
            "ALL",
            "PHASE1",
            "PHASE1_2",
            "PHASE2",
            "PHASE2_3",
            "PHASE3");

    private static final Set<String> ALLOWED_SCOPES = Set.of(
            "DOMESTIC",
            "GLOBAL");

    private final TrialService trialService;
    private final FavoriteService favoriteService;

    public TrialController(TrialService trialService, FavoriteService favoriteService) {
        this.trialService = trialService;
        this.favoriteService = favoriteService;
    }

    @GetMapping
    public String trialList(
            @RequestParam(name = "keyword", defaultValue = "") String keyword,
            @RequestParam(name = "status", defaultValue = "ALL") String status,
            @RequestParam(name = "phase", defaultValue = "ALL") String phase,
            @RequestParam(name = "scope", defaultValue = "DOMESTIC") String scope,
            @RequestParam(name = "notFound", defaultValue = "false") boolean notFound,
            Model model) {

        String normalizedStatus = normalize(status, ALLOWED_STATUSES, "ALL");
        String normalizedPhase = normalize(phase, ALLOWED_PHASES, "ALL");
        String normalizedScope = normalize(scope, ALLOWED_SCOPES, "DOMESTIC");
        TrialSearchResultVO result = trialService.searchTrials(
                keyword,
                normalizedStatus,
                normalizedPhase,
                normalizedScope);

        model.addAttribute("trials", result.getTrials());
        model.addAttribute("displayedCount", result.getDisplayedCount());
        model.addAttribute("apiTotalCount", result.getApiTotalCount());
        model.addAttribute("crisTotalCount", result.getCrisTotalCount());
        model.addAttribute("clinicalTrialsTotalCount", result.getClinicalTrialsTotalCount());
        model.addAttribute("apiAvailable", result.isApiAvailable());
        model.addAttribute("crisAvailable", result.isCrisAvailable());
        model.addAttribute("apiNotice", result.getNotice());
        model.addAttribute("keyword", keyword == null ? "" : keyword.trim());
        model.addAttribute("selectedStatus", normalizedStatus);
        model.addAttribute("selectedPhase", normalizedPhase);
        model.addAttribute("selectedScope", normalizedScope);
        if (notFound) {
            model.addAttribute("pageNotice", "요청한 임상시험 정보를 찾을 수 없습니다.");
        }

        return "trial/list";
    }

    @GetMapping("/{id}")
    public String trialDetail(
            @PathVariable("id") Long trialNo,
            HttpServletRequest request,
            Model model) {

        TrialVO trial = trialService.getTrialDetail(trialNo);
        if (trial == null) {
            return "redirect:/trials?notFound=true";
        }

        Long loginUserMemberNo = getLoginUserMemberNo(request);
        trialService.recordTrialView(trialNo, loginUserMemberNo);
        model.addAttribute("trial", trial);
        model.addAttribute(
                "favoriteTrial",
                favoriteService.isTrialFavorite(loginUserMemberNo, trialNo));
        return "trial/detail";
    }

    private Long getLoginUserMemberNo(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object roleCode = session.getAttribute(SessionConstants.LOGIN_MEMBER_ROLE);
        if (!ROLE_USER.equals(roleCode)) {
            return null;
        }

        Object memberNo = session.getAttribute(SessionConstants.LOGIN_MEMBER_NO);
        if (memberNo instanceof Number number) {
            return number.longValue();
        }
        return null;
    }

    private String normalize(String value, Set<String> allowed, String defaultValue) {
        if (value == null) {
            return defaultValue;
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        return allowed.contains(normalized) ? normalized : defaultValue;
    }
}
