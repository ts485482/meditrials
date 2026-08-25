package meditrials.meditrials.disease.controller;

import java.util.ArrayList;
import java.util.List;
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
import meditrials.meditrials.disease.service.DiseaseService;
import meditrials.meditrials.disease.vo.DiseaseSearchResultVO;
import meditrials.meditrials.disease.vo.DiseaseVO;
import meditrials.meditrials.favorite.service.FavoriteService;
import meditrials.meditrials.trial.service.TrialService;
import meditrials.meditrials.trial.vo.TrialSearchResultVO;
import meditrials.meditrials.trial.vo.TrialVO;

@Controller
@RequestMapping("/diseases")
public class DiseaseController {

    private static final Logger log = LoggerFactory.getLogger(DiseaseController.class);
    private static final int RELATED_TRIAL_PREVIEW_LIMIT = 4;
    private static final String ROLE_USER = "USER";

    private static final Set<String> ALLOWED_CATEGORIES = Set.of(
            "ALL",
            "NEURO",
            "AUTOIMMUNE",
            "CANCER",
            "GENETIC",
            "CHRONIC");

    private final DiseaseService diseaseService;
    private final TrialService trialService;
    private final FavoriteService favoriteService;

    public DiseaseController(
            DiseaseService diseaseService,
            TrialService trialService,
            FavoriteService favoriteService) {
        this.diseaseService = diseaseService;
        this.trialService = trialService;
        this.favoriteService = favoriteService;
    }

    /**
     * 질환 목록 화면은 외부 API 호출 없이 즉시 반환한다.
     * 실제 HIRA/DB 검색 결과와 관련 임상시험 건수는 /diseases/data 에서 비동기로 조회한다.
     */
    @GetMapping
    public String diseaseList(
            @RequestParam(name = "keyword", defaultValue = "") String keyword,
            @RequestParam(name = "category", defaultValue = "ALL") String category,
            @RequestParam(name = "notFound", defaultValue = "false") boolean notFound,
            Model model) {

        String normalizedCategory = normalizeCategory(category);
        model.addAttribute("keyword", keyword == null ? "" : keyword.trim());
        model.addAttribute("selectedCategory", normalizedCategory);
        if (notFound) {
            model.addAttribute("pageNotice", "요청한 질환정보를 찾을 수 없습니다.");
        }

        return "disease/list";
    }

    /**
     * 질환 검색 결과 데이터 전용 엔드포인트.
     */
    @GetMapping("/data")
    @ResponseBody
    public ResponseEntity<?> diseaseListData(
            @RequestParam(name = "keyword", defaultValue = "") String keyword,
            @RequestParam(name = "category", defaultValue = "ALL") String category) {

        String normalizedCategory = normalizeCategory(category);
        try {
            DiseaseSearchResultVO result = diseaseService.searchDiseases(keyword, normalizedCategory);
            return ResponseEntity.ok(result);
        } catch (RuntimeException exception) {
            log.error("질환정보 비동기 검색 중 오류가 발생했습니다.", exception);
            return ResponseEntity.internalServerError().body(Map.of(
                    "message", "질환정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요."));
        }
    }

    @GetMapping("/{id}")
    public String diseaseDetail(
            @PathVariable("id") Long diseaseNo,
            HttpServletRequest request,
            Model model) {

        DiseaseVO disease = diseaseService.getDiseaseDetail(diseaseNo);
        if (disease == null) {
            return "redirect:/diseases?notFound=true";
        }

        TrialSearchResultVO relatedResult = trialService.searchTrials(
                disease.getDiseaseName(),
                "ALL",
                "ALL",
                "DOMESTIC");

        List<TrialVO> relatedTrials = previewTrials(relatedResult.getTrials());
        Long loginUserMemberNo = getLoginUserMemberNo(request);

        model.addAttribute("disease", disease);
        model.addAttribute("relatedTrials", relatedTrials);
        model.addAttribute("relatedCrisCount", relatedResult.getCrisTotalCount());
        model.addAttribute("relatedClinicalTrialsCount", relatedResult.getClinicalTrialsTotalCount());
        model.addAttribute("relatedTrialApiAvailable", relatedResult.isApiAvailable());
        model.addAttribute(
                "favoriteDisease",
                favoriteService.isDiseaseFavorite(loginUserMemberNo, diseaseNo));
        return "disease/detail";
    }

    private List<TrialVO> previewTrials(List<TrialVO> trials) {
        if (trials == null || trials.isEmpty()) {
            return List.of();
        }
        int endIndex = Math.min(RELATED_TRIAL_PREVIEW_LIMIT, trials.size());
        return new ArrayList<>(trials.subList(0, endIndex));
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

    private String normalizeCategory(String category) {
        if (category == null) {
            return "ALL";
        }
        String normalized = category.trim().toUpperCase(Locale.ROOT);
        return ALLOWED_CATEGORIES.contains(normalized) ? normalized : "ALL";
    }
}
