package meditrials.meditrials.trial.controller;

import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import meditrials.meditrials.common.constant.SessionConstants;
import meditrials.meditrials.favorite.service.FavoriteService;
import meditrials.meditrials.participation.service.TrialParticipationService;
import meditrials.meditrials.trial.service.TrialService;
import meditrials.meditrials.trial.vo.TrialSearchResultVO;
import meditrials.meditrials.trial.vo.TrialVO;

@Controller
@RequestMapping("/trials")
public class TrialController {

    private static final Logger log = LoggerFactory.getLogger(TrialController.class);
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

    private static final Set<String> ALLOWED_SORTS = Set.of(
            "RECOMMENDED",
            "DEADLINE");

    private final TrialService trialService;
    private final FavoriteService favoriteService;
    private final TrialParticipationService trialParticipationService;

    public TrialController(
            TrialService trialService,
            FavoriteService favoriteService,
            TrialParticipationService trialParticipationService) {
        this.trialService = trialService;
        this.favoriteService = favoriteService;
        this.trialParticipationService = trialParticipationService;
    }

    /**
     * 검색 화면 자체는 외부 API를 기다리지 않고 즉시 반환한다.
     * 실제 임상시험 데이터는 /trials/data 를 JavaScript fetch로 조회한다.
     */
    @GetMapping
    public String trialList(
            @RequestParam(name = "keyword", defaultValue = "") String keyword,
            @RequestParam(name = "status", defaultValue = "ALL") String status,
            @RequestParam(name = "phase", defaultValue = "ALL") String phase,
            @RequestParam(name = "scope", defaultValue = "DOMESTIC") String scope,
            @RequestParam(name = "sort", defaultValue = "RECOMMENDED") String sort,
            @RequestParam(name = "notFound", defaultValue = "false") boolean notFound,
            Model model) {

        String normalizedStatus = normalize(status, ALLOWED_STATUSES, "ALL");
        String normalizedPhase = normalize(phase, ALLOWED_PHASES, "ALL");
        String normalizedScope = normalize(scope, ALLOWED_SCOPES, "DOMESTIC");
        String normalizedSort = normalize(sort, ALLOWED_SORTS, "RECOMMENDED");

        model.addAttribute("keyword", keyword == null ? "" : keyword.trim());
        model.addAttribute("selectedStatus", normalizedStatus);
        model.addAttribute("selectedPhase", normalizedPhase);
        model.addAttribute("selectedScope", normalizedScope);
        model.addAttribute("selectedSort", normalizedSort);
        if (notFound) {
            model.addAttribute("pageNotice", "요청한 임상시험 정보를 찾을 수 없습니다.");
        }

        return "trial/list";
    }

    /**
     * 검색 결과 데이터 전용 엔드포인트.
     * CRIS / ClinicalTrials.gov / 승인된 사업자 임상시험을 기존 서비스 로직 그대로 조회한다.
     */
    @GetMapping("/data")
    @ResponseBody
    public ResponseEntity<?> trialListData(
            @RequestParam(name = "keyword", defaultValue = "") String keyword,
            @RequestParam(name = "status", defaultValue = "ALL") String status,
            @RequestParam(name = "phase", defaultValue = "ALL") String phase,
            @RequestParam(name = "scope", defaultValue = "DOMESTIC") String scope,
            @RequestParam(name = "sort", defaultValue = "RECOMMENDED") String sort) {

        String normalizedStatus = normalize(status, ALLOWED_STATUSES, "ALL");
        String normalizedPhase = normalize(phase, ALLOWED_PHASES, "ALL");
        String normalizedScope = normalize(scope, ALLOWED_SCOPES, "DOMESTIC");
        String normalizedSort = normalize(sort, ALLOWED_SORTS, "RECOMMENDED");

        try {
            TrialSearchResultVO result = trialService.searchTrials(
                    keyword,
                    normalizedStatus,
                    normalizedPhase,
                    normalizedScope,
                    normalizedSort);
            return ResponseEntity.ok(result);
        } catch (RuntimeException exception) {
            log.error("임상시험 비동기 검색 중 오류가 발생했습니다.", exception);
            return ResponseEntity.internalServerError().body(Map.of(
                    "message", "임상시험 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요."));
        }
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
        model.addAttribute(
                "participation",
                trialParticipationService.getMemberTrialParticipation(loginUserMemberNo, trialNo));
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
