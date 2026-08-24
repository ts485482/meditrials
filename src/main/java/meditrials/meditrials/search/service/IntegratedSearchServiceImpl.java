package meditrials.meditrials.search.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import meditrials.meditrials.disease.service.DiseaseService;
import meditrials.meditrials.disease.vo.DiseaseSearchResultVO;
import meditrials.meditrials.search.vo.IntegratedSearchVO;
import meditrials.meditrials.trial.service.TrialService;
import meditrials.meditrials.trial.vo.TrialSearchResultVO;

@Service
public class IntegratedSearchServiceImpl implements IntegratedSearchService {

    private static final int DISEASE_PREVIEW_LIMIT = 8;
    private static final int TRIAL_PREVIEW_LIMIT = 8;

    private final DiseaseService diseaseService;
    private final TrialService trialService;

    public IntegratedSearchServiceImpl(
            DiseaseService diseaseService,
            TrialService trialService) {
        this.diseaseService = diseaseService;
        this.trialService = trialService;
    }

    @Override
    public IntegratedSearchVO search(String keyword) {
        String normalizedKeyword = normalizeKeyword(keyword);
        IntegratedSearchVO integrated = new IntegratedSearchVO();
        integrated.setKeyword(normalizedKeyword);

        if (normalizedKeyword.isEmpty()) {
            return integrated;
        }

        DiseaseSearchResultVO diseaseResult = diseaseService.searchDiseases(normalizedKeyword, "ALL");
        integrated.setDiseases(preview(diseaseResult.getDiseases(), DISEASE_PREVIEW_LIMIT));
        integrated.setDiseaseTotalCount(diseaseResult.getTotalCount());
        integrated.setDiseaseApiAvailable(diseaseResult.isApiAvailable());
        integrated.setDiseaseNotice(diseaseResult.getNotice());

        TrialSearchResultVO trialResult = trialService.searchTrials(
                normalizedKeyword,
                "ALL",
                "ALL",
                "DOMESTIC");
        integrated.setTrials(preview(trialResult.getTrials(), TRIAL_PREVIEW_LIMIT));
        integrated.setTrialDisplayedCount(trialResult.getDisplayedCount());
        integrated.setTrialApiAvailable(trialResult.isApiAvailable());
        integrated.setTrialNotice(trialResult.getNotice());
        return integrated;
    }

    private String normalizeKeyword(String keyword) {
        if (keyword == null) {
            return "";
        }
        String normalized = keyword.trim();
        return normalized.length() <= 100 ? normalized : normalized.substring(0, 100);
    }

    private <T> List<T> preview(List<T> source, int limit) {
        if (source == null || source.isEmpty()) {
            return List.of();
        }
        int endIndex = Math.min(limit, source.size());
        return new ArrayList<>(source.subList(0, endIndex));
    }
}
