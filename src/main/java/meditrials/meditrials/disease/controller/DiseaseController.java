package meditrials.meditrials.disease.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import meditrials.meditrials.disease.service.DiseaseService;
import meditrials.meditrials.disease.vo.DiseaseSearchResultVO;
import meditrials.meditrials.disease.vo.DiseaseVO;
import meditrials.meditrials.trial.service.TrialService;
import meditrials.meditrials.trial.vo.TrialSearchResultVO;
import meditrials.meditrials.trial.vo.TrialVO;

@Controller
@RequestMapping("/diseases")
public class DiseaseController {

    private static final int RELATED_TRIAL_PREVIEW_LIMIT = 4;

    private static final Set<String> ALLOWED_CATEGORIES = Set.of(
            "ALL",
            "NEURO",
            "AUTOIMMUNE",
            "CANCER",
            "GENETIC",
            "CHRONIC");

    private final DiseaseService diseaseService;
    private final TrialService trialService;

    public DiseaseController(DiseaseService diseaseService, TrialService trialService) {
        this.diseaseService = diseaseService;
        this.trialService = trialService;
    }

    @GetMapping
    public String diseaseList(
            @RequestParam(name = "keyword", defaultValue = "") String keyword,
            @RequestParam(name = "category", defaultValue = "ALL") String category,
            @RequestParam(name = "notFound", defaultValue = "false") boolean notFound,
            Model model) {

        String normalizedCategory = normalizeCategory(category);
        DiseaseSearchResultVO result = diseaseService.searchDiseases(keyword, normalizedCategory);

        model.addAttribute("diseases", result.getDiseases());
        model.addAttribute("totalCount", result.getTotalCount());
        model.addAttribute("apiAvailable", result.isApiAvailable());
        model.addAttribute("apiNotice", result.getNotice());
        model.addAttribute("keyword", keyword.trim());
        model.addAttribute("selectedCategory", normalizedCategory);
        if (notFound) {
            model.addAttribute("pageNotice", "요청한 질환정보를 찾을 수 없습니다.");
        }

        return "disease/list";
    }

    @GetMapping("/{id}")
    public String diseaseDetail(@PathVariable("id") Long diseaseNo, Model model) {
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

        model.addAttribute("disease", disease);
        model.addAttribute("relatedTrials", relatedTrials);
        model.addAttribute("relatedCrisCount", relatedResult.getCrisTotalCount());
        model.addAttribute("relatedClinicalTrialsCount", relatedResult.getClinicalTrialsTotalCount());
        model.addAttribute("relatedTrialApiAvailable", relatedResult.isApiAvailable());
        return "disease/detail";
    }

    private List<TrialVO> previewTrials(List<TrialVO> trials) {
        if (trials == null || trials.isEmpty()) {
            return List.of();
        }
        int endIndex = Math.min(RELATED_TRIAL_PREVIEW_LIMIT, trials.size());
        return new ArrayList<>(trials.subList(0, endIndex));
    }

    private String normalizeCategory(String category) {
        if (category == null) {
            return "ALL";
        }
        String normalized = category.trim().toUpperCase(Locale.ROOT);
        return ALLOWED_CATEGORIES.contains(normalized) ? normalized : "ALL";
    }
}
