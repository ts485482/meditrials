package meditrials.meditrials.disease.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

import org.springframework.stereotype.Service;

import meditrials.meditrials.disease.api.ClinicalTrialsClient;
import meditrials.meditrials.disease.api.HiraDiseaseApiException;
import meditrials.meditrials.disease.api.HiraDiseaseClient;
import meditrials.meditrials.disease.api.HiraDiseaseItem;
import meditrials.meditrials.disease.api.MedlinePlusClient;
import meditrials.meditrials.disease.api.MedlinePlusTopic;
import meditrials.meditrials.disease.config.DiseaseFocusCatalog;
import meditrials.meditrials.disease.config.DiseaseFocusCatalog.FocusDisease;
import meditrials.meditrials.disease.dao.DiseaseDAO;
import meditrials.meditrials.disease.vo.DiseaseSearchResultVO;
import meditrials.meditrials.disease.vo.DiseaseVO;

@Service
public class DiseaseServiceImpl implements DiseaseService {

    private static final int DISPLAY_LIMIT = 20;
    private static final int FOCUS_SEARCH_LIMIT = 20;
    private static final String SOURCE_HIRA = "HIRA";
    private static final String SOURCE_CODE_PREFIX = "HIRA:";
    private static final String CATEGORY_OTHER = "기타 치료 연구 질환";

    private final DiseaseDAO diseaseDAO;
    private final HiraDiseaseClient hiraDiseaseClient;
    private final MedlinePlusClient medlinePlusClient;
    private final ClinicalTrialsClient clinicalTrialsClient;

    public DiseaseServiceImpl(
            DiseaseDAO diseaseDAO,
            HiraDiseaseClient hiraDiseaseClient,
            MedlinePlusClient medlinePlusClient,
            ClinicalTrialsClient clinicalTrialsClient) {
        this.diseaseDAO = diseaseDAO;
        this.hiraDiseaseClient = hiraDiseaseClient;
        this.medlinePlusClient = medlinePlusClient;
        this.clinicalTrialsClient = clinicalTrialsClient;
    }

    @Override
    public DiseaseSearchResultVO searchDiseases(String keyword, String category) {
        String normalizedKeyword = normalizeKeyword(keyword);
        String databaseCategory = normalizeCategory(category);

        DiseaseSearchResultVO searchResult = new DiseaseSearchResultVO();
        boolean apiAvailable = hiraDiseaseClient.isConfigured();
        String notice;

        try {
            if (normalizedKeyword.isEmpty()) {
                ensureFocusDiseasesSynced();
            } else if (!hasCachedSearchResult(normalizedKeyword)) {
                syncSearchResults(normalizedKeyword);
            }
            notice = "건강보험심사평가원 질병명칭/코드 정보를 기준으로 조회하고, "
                    + "MediTrials가 난치성·치료 미충족 질환을 중심으로 분류합니다.";
        } catch (HiraDiseaseApiException exception) {
            apiAvailable = false;
            notice = exception.getMessage();
        }

        List<DiseaseVO> diseases = diseaseDAO.selectDiseaseList(
                normalizedKeyword,
                databaseCategory,
                DISPLAY_LIMIT);
        enrichTrialCounts(diseases);

        searchResult.setDiseases(diseases);
        searchResult.setTotalCount(
                diseaseDAO.countDiseaseList(normalizedKeyword, databaseCategory));
        searchResult.setApiAvailable(apiAvailable);
        searchResult.setNotice(notice);
        return searchResult;
    }

    @Override
    public DiseaseVO getDiseaseDetail(Long diseaseNo) {
        if (diseaseNo == null) {
            return null;
        }

        DiseaseVO disease = diseaseDAO.selectDiseaseByNo(diseaseNo);
        if (disease == null) {
            return null;
        }

        enrichDetailFromMedlinePlus(disease);
        disease.setRelatedTrialCount(countRelatedTrials(disease));
        return disease;
    }

    private void ensureFocusDiseasesSynced() {
        // 초기 대표 질환 적재는 HIRA 데이터가 하나도 없을 때만 수행한다.
        // 일부 대표 질환이 HIRA 명칭 차이로 매칭되지 않더라도 매 화면 진입마다
        // 외부 API를 다시 호출하지 않고, 이후에는 Oracle DB를 우선 사용한다.
        if (diseaseDAO.countDiseaseBySourceType(SOURCE_HIRA) > 0) {
            return;
        }

        for (FocusDisease focusDisease : DiseaseFocusCatalog.diseases()) {
            HiraDiseaseItem selected = findFocusDisease(focusDisease);
            if (selected != null) {
                mergeDisease(selected, focusDisease);
            }
        }
    }

    private HiraDiseaseItem findFocusDisease(FocusDisease focusDisease) {
        List<HiraDiseaseItem> fallbackCandidates = new ArrayList<>();

        for (String searchTerm : focusDisease.hiraSearchTerms()) {
            List<HiraDiseaseItem> candidates = hiraDiseaseClient.searchDiseases(
                    searchTerm,
                    FOCUS_SEARCH_LIMIT);
            if (candidates == null || candidates.isEmpty()) {
                continue;
            }

            HiraDiseaseItem codeMatched = selectBestCandidate(
                    candidates,
                    focusDisease,
                    true);
            if (codeMatched != null) {
                return codeMatched;
            }

            fallbackCandidates.addAll(candidates);
        }

        return selectBestCandidate(fallbackCandidates, focusDisease, false);
    }

    private boolean hasCachedSearchResult(String keyword) {
        return diseaseDAO.countDiseaseList(keyword, "") > 0;
    }

    private void syncSearchResults(String keyword) {
        List<HiraDiseaseItem> apiResults = hiraDiseaseClient.searchDiseases(keyword, DISPLAY_LIMIT);
        for (HiraDiseaseItem apiDisease : apiResults) {
            FocusDisease focus = DiseaseFocusCatalog.findBestMatch(
                    apiDisease.koreanName(),
                    apiDisease.englishName());
            mergeDisease(apiDisease, focus);
        }
    }

    private HiraDiseaseItem selectBestCandidate(
            List<HiraDiseaseItem> candidates,
            FocusDisease focusDisease,
            boolean requireExpectedCode) {
        if (candidates == null || candidates.isEmpty()) {
            return null;
        }

        return candidates.stream()
                .filter(item -> !requireExpectedCode || matchesExpectedKcd(item, focusDisease))
                .min(Comparator.comparingInt(item -> matchScore(item, focusDisease)))
                .orElse(null);
    }

    private boolean matchesExpectedKcd(
            HiraDiseaseItem candidate,
            FocusDisease focusDisease) {
        if (candidate == null || candidate.sickCode() == null) {
            return false;
        }

        String code = candidate.sickCode().trim().toUpperCase(Locale.ROOT);
        for (String prefix : focusDisease.expectedKcdPrefixes()) {
            if (code.startsWith(prefix.toUpperCase(Locale.ROOT))) {
                return true;
            }
        }
        return false;
    }

    private int matchScore(HiraDiseaseItem candidate, FocusDisease focusDisease) {
        String candidateKorean = normalizeName(candidate.koreanName());
        String candidateEnglish = normalizeName(candidate.englishName());

        int bestScore = 100;
        bestScore = Math.min(
                bestScore,
                compareName(candidateKorean, normalizeName(focusDisease.koreanName())));
        bestScore = Math.min(
                bestScore,
                compareName(candidateEnglish, normalizeName(focusDisease.englishName())));

        for (String searchTerm : focusDisease.hiraSearchTerms()) {
            bestScore = Math.min(
                    bestScore,
                    compareName(candidateKorean, normalizeName(searchTerm)));
        }

        if (matchesExpectedKcd(candidate, focusDisease)) {
            bestScore -= 10;
        }
        return bestScore;
    }

    private int compareName(String candidate, String requested) {
        if (candidate.isEmpty() || requested.isEmpty()) {
            return 50;
        }
        if (candidate.equals(requested)) {
            return 0;
        }
        if (candidate.contains(requested) || requested.contains(candidate)) {
            return 5;
        }
        return 20;
    }

    private void mergeDisease(HiraDiseaseItem apiDisease, FocusDisease focusDisease) {
        if (apiDisease.sickCode() == null || apiDisease.sickCode().isBlank()) {
            return;
        }

        DiseaseVO disease = new DiseaseVO();
        disease.setSourceType(SOURCE_HIRA);
        disease.setSourceCode(SOURCE_CODE_PREFIX + apiDisease.sickCode().trim());
        disease.setDiseaseName(resolveKoreanName(apiDisease, focusDisease));
        disease.setEnglishName(resolveEnglishName(apiDisease, focusDisease));
        disease.setCategory(focusDisease == null ? CATEGORY_OTHER : focusDisease.category());
        diseaseDAO.mergeDisease(disease);
    }

    private String resolveKoreanName(HiraDiseaseItem apiDisease, FocusDisease focusDisease) {
        if (focusDisease != null) {
            return focusDisease.koreanName();
        }
        return apiDisease.koreanName();
    }

    private String resolveEnglishName(HiraDiseaseItem apiDisease, FocusDisease focusDisease) {
        if (focusDisease != null) {
            return focusDisease.englishName();
        }
        return apiDisease.englishName();
    }

    private void enrichDetailFromMedlinePlus(DiseaseVO disease) {
        if (disease.getDescription() != null && !disease.getDescription().isBlank()) {
            return;
        }

        String queryName = resolveExternalQueryName(disease);
        if (queryName == null || queryName.isBlank()) {
            return;
        }

        MedlinePlusTopic topic = medlinePlusClient.searchTopic(queryName);
        if (topic == null) {
            return;
        }

        disease.setDescription(topic.summary());
        disease.setSourceUrl(topic.sourceUrl());
        diseaseDAO.updateDiseaseDetail(disease);
    }

    private void enrichTrialCounts(List<DiseaseVO> diseases) {
        for (DiseaseVO disease : diseases) {
            disease.setRelatedTrialCount(countRelatedTrials(disease));
        }
    }

    private Integer countRelatedTrials(DiseaseVO disease) {
        String queryName = resolveExternalQueryName(disease);
        return clinicalTrialsClient.countStudies(queryName);
    }

    private String resolveExternalQueryName(DiseaseVO disease) {
        FocusDisease focusDisease = DiseaseFocusCatalog.findBestMatch(
                disease.getDiseaseName(),
                disease.getEnglishName());
        if (focusDisease != null) {
            return focusDisease.clinicalTrialsQuery();
        }

        String englishName = normalizeExternalDiseaseName(disease.getEnglishName());
        if (!englishName.isBlank()) {
            return englishName;
        }
        return normalizeExternalDiseaseName(disease.getDiseaseName());
    }

    private String normalizeExternalDiseaseName(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }

        return value
                .replace('’', '\'')
                .replace('‘', '\'')
                .replace('–', '-')
                .replace('—', '-')
                .replaceAll("\\[[^\\]]*\\]", " ")
                .replaceAll("\\([^)]*[A-Z][0-9][^)]*\\)", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }

    private String normalizeKeyword(String keyword) {
        return keyword == null ? "" : keyword.trim();
    }

    private String normalizeCategory(String category) {
        if (category == null) {
            return "";
        }
        return switch (category.toUpperCase(Locale.ROOT)) {
            case "NEURO" -> "신경퇴행성";
            case "AUTOIMMUNE" -> "자가면역";
            case "CANCER" -> "암·종양";
            case "GENETIC" -> "유전성";
            case "CHRONIC" -> "만성·난치성";
            default -> "";
        };
    }

    private String normalizeName(String value) {
        if (value == null) {
            return "";
        }
        return value.replace(" ", "")
                .replace("-", "")
                .replace("'", "")
                .replace("’", "")
                .replace("(", "")
                .replace(")", "")
                .toLowerCase(Locale.ROOT)
                .trim();
    }
}
