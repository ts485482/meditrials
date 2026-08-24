package meditrials.meditrials.trial.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import meditrials.meditrials.disease.config.DiseaseFocusCatalog;
import meditrials.meditrials.disease.config.DiseaseFocusCatalog.FocusDisease;
import meditrials.meditrials.disease.dao.DiseaseDAO;
import meditrials.meditrials.disease.vo.DiseaseVO;
import meditrials.meditrials.trial.api.ClinicalTrialsGovClient;
import meditrials.meditrials.trial.api.ClinicalTrialsGovClient.ApiSearchResult;
import meditrials.meditrials.trial.api.ClinicalTrialsGovException;
import meditrials.meditrials.trial.api.CrisClinicalTrialClient;
import meditrials.meditrials.trial.api.CrisClinicalTrialClient.CrisSearchResult;
import meditrials.meditrials.trial.api.CrisClinicalTrialException;
import meditrials.meditrials.trial.dao.TrialDAO;
import meditrials.meditrials.trial.vo.TrialSearchResultVO;
import meditrials.meditrials.trial.vo.TrialVO;

@Service
public class TrialServiceImpl implements TrialService {

    private static final int DISPLAY_LIMIT = 20;
    private static final String SOURCE_API = "API";
    private static final String REVIEW_APPROVED = "APPROVED";
    private static final String SCOPE_DOMESTIC = "DOMESTIC";
    private static final String KOREA_LOCATION_QUERY = "South Korea";

    private final TrialDAO trialDAO;
    private final DiseaseDAO diseaseDAO;
    private final ClinicalTrialsGovClient clinicalTrialsGovClient;
    private final CrisClinicalTrialClient crisClinicalTrialClient;

    public TrialServiceImpl(
            TrialDAO trialDAO,
            DiseaseDAO diseaseDAO,
            ClinicalTrialsGovClient clinicalTrialsGovClient,
            CrisClinicalTrialClient crisClinicalTrialClient) {
        this.trialDAO = trialDAO;
        this.diseaseDAO = diseaseDAO;
        this.clinicalTrialsGovClient = clinicalTrialsGovClient;
        this.crisClinicalTrialClient = crisClinicalTrialClient;
    }

    @Override
    public TrialSearchResultVO searchTrials(
            String keyword,
            String recruitmentStatus,
            String phase,
            String scope) {

        String normalizedKeyword = keyword == null ? "" : keyword.trim();
        String normalizedStatus = normalizeStatus(recruitmentStatus);
        String normalizedPhase = normalizePhase(phase);
        String normalizedScope = normalizeScope(scope);

        if (SCOPE_DOMESTIC.equals(normalizedScope)) {
            return searchDomesticTrials(normalizedKeyword, normalizedStatus, normalizedPhase);
        }
        return searchGlobalTrials(normalizedKeyword, normalizedStatus, normalizedPhase);
    }

    @Override
    public TrialVO getTrialDetail(Long trialNo) {
        if (trialNo == null) {
            return null;
        }

        TrialVO cached = trialDAO.selectTrialByNo(trialNo);
        if (cached == null) {
            return null;
        }

        if (!SOURCE_API.equals(cached.getSourceType())
                || cached.getNctId() == null
                || cached.getNctId().isBlank()) {
            return cached;
        }

        if (isCrisId(cached.getNctId())) {
            return cached;
        }

        try {
            TrialVO latest = clinicalTrialsGovClient.getStudy(cached.getNctId());
            if (latest != null) {
                prepareApiTrial(latest);
                trialDAO.mergeTrial(latest);
                TrialVO refreshed = trialDAO.selectTrialByNctId(cached.getNctId());
                return refreshed == null ? cached : refreshed;
            }
        } catch (ClinicalTrialsGovException exception) {
            return cached;
        }
        return cached;
    }

    @Override
    public List<TrialVO> getActivePremiumTrials(int limit) {
        int safeLimit = Math.max(1, Math.min(limit, 10));
        return trialDAO.selectActivePremiumTrialList(safeLimit);
    }

    @Override
    @Transactional
    public void recordTrialView(Long trialNo, Long memberNo) {
        if (trialNo == null) {
            return;
        }

        int inserted = trialDAO.insertTrialViewHistory(trialNo, memberNo);
        if (inserted == 1) {
            trialDAO.incrementTrialViewCount(trialNo);
        }
    }

    private TrialSearchResultVO searchDomesticTrials(
            String keyword,
            String recruitmentStatus,
            String phase) {

        TrialSearchResultVO result = new TrialSearchResultVO();
        List<TrialVO> crisTrials = new ArrayList<>();
        List<TrialVO> clinicalTrials = new ArrayList<>();
        String crisError = null;
        String clinicalError = null;

        try {
            CrisSearchResult crisResult = crisClinicalTrialClient.searchStudies(keyword);
            result.setCrisTotalCount(crisResult.totalCount());
            result.setCrisAvailable(true);
            crisTrials.addAll(filterTrials(crisResult.studies(), recruitmentStatus, phase));
        } catch (CrisClinicalTrialException exception) {
            result.setCrisAvailable(false);
            crisError = exception.getMessage();
        }

        try {
            String clinicalQuery = resolveApiQuery(keyword);
            ApiSearchResult clinicalResult = clinicalTrialsGovClient.searchStudies(
                    clinicalQuery,
                    recruitmentStatus,
                    KOREA_LOCATION_QUERY);
            result.setClinicalTrialsTotalCount(clinicalResult.totalCount());
            clinicalTrials.addAll(filterTrials(clinicalResult.studies(), recruitmentStatus, phase));
        } catch (ClinicalTrialsGovException exception) {
            clinicalError = exception.getMessage();
        }

        List<TrialVO> prioritized = prioritizeDomesticTrials(crisTrials, clinicalTrials);
        List<TrialVO> deduplicated = deduplicate(prioritized);
        List<TrialVO> displayed = persistAndLimit(deduplicated);

        if (displayed.isEmpty() && crisError != null && clinicalError != null) {
            displayed = cachedFallback(keyword, recruitmentStatus, phase, true);
        }

        displayed = includeApprovedBusinessTrials(
                keyword,
                recruitmentStatus,
                phase,
                displayed);

        result.setTrials(displayed);
        result.setDisplayedCount(displayed.size());
        result.setApiAvailable(crisError == null || clinicalError == null);
        result.setNotice(buildDomesticNotice(crisError, clinicalError));
        return result;
    }

    private TrialSearchResultVO searchGlobalTrials(
            String keyword,
            String recruitmentStatus,
            String phase) {

        String apiQuery = resolveApiQuery(keyword);
        TrialSearchResultVO result = new TrialSearchResultVO();

        try {
            ApiSearchResult apiResult = clinicalTrialsGovClient.searchStudies(apiQuery, recruitmentStatus);
            List<TrialVO> filtered = filterTrials(
                    apiResult.studies(),
                    recruitmentStatus,
                    phase);
            List<TrialVO> displayed = persistAndLimit(filtered);
            displayed = includeApprovedBusinessTrials(
                    keyword,
                    recruitmentStatus,
                    phase,
                    displayed);

            result.setTrials(displayed);
            result.setDisplayedCount(displayed.size());
            result.setApiTotalCount(apiResult.totalCount());
            result.setClinicalTrialsTotalCount(apiResult.totalCount());
            result.setApiAvailable(true);
            result.setNotice(
                    "관리자 승인된 MediTrials 사업자 임상시험과 ClinicalTrials.gov API v2의 전 세계 등록 연구를 함께 조회합니다. "
                    + "최대 20건을 표시합니다.");
            return result;
        } catch (ClinicalTrialsGovException exception) {
            List<TrialVO> cached = cachedFallback(keyword, recruitmentStatus, phase, false);
            cached = includeApprovedBusinessTrials(
                    keyword,
                    recruitmentStatus,
                    phase,
                    cached);
            result.setTrials(cached);
            result.setDisplayedCount(cached.size());
            result.setApiAvailable(false);
            result.setNotice(
                    exception.getMessage()
                    + " 현재 화면에는 이전에 저장된 ClinicalTrials.gov 데이터가 있으면 대신 표시합니다.");
            return result;
        }
    }

    private String buildDomesticNotice(String crisError, String clinicalError) {
        if (crisError == null && clinicalError == null) {
            return "관리자 승인된 MediTrials 사업자 임상시험을 함께 표시하고, 질병관리청 CRIS의 한글 치료·중재연구와 "
                    + "ClinicalTrials.gov의 대한민국 수행 연구를 보강합니다.";
        }
        if (crisError != null && clinicalError == null) {
            return crisError + " 대신 ClinicalTrials.gov에서 대한민국 수행 연구를 표시합니다.";
        }
        if (crisError == null) {
            return clinicalError + " CRIS 국내 한글 등록 연구는 정상적으로 표시합니다.";
        }
        return "CRIS와 ClinicalTrials.gov 호출이 모두 원활하지 않아 저장된 임상시험 데이터가 있으면 대신 표시합니다.";
    }

    private List<TrialVO> includeApprovedBusinessTrials(
            String keyword,
            String recruitmentStatus,
            String phase,
            List<TrialVO> externalTrials) {
        List<TrialVO> businessTrials = trialDAO.selectApprovedBusinessTrialList(
                keyword,
                "ALL".equals(recruitmentStatus) ? "" : recruitmentStatus,
                DISPLAY_LIMIT * 4);
        List<TrialVO> filteredBusinessTrials = filterTrials(
                businessTrials,
                recruitmentStatus,
                phase);

        List<TrialVO> combined = new ArrayList<>();
        combined.addAll(filteredBusinessTrials);
        if (externalTrials != null) {
            combined.addAll(externalTrials);
        }

        if (combined.size() > DISPLAY_LIMIT) {
            return new ArrayList<>(combined.subList(0, DISPLAY_LIMIT));
        }
        return combined;
    }

    private List<TrialVO> cachedFallback(
            String keyword,
            String recruitmentStatus,
            String phase,
            boolean domesticOnly) {
        List<TrialVO> cached = trialDAO.selectCachedTrialList(
                keyword,
                "ALL".equals(recruitmentStatus) ? "" : recruitmentStatus,
                DISPLAY_LIMIT * 4);
        List<TrialVO> filtered = filterTrials(cached, recruitmentStatus, phase);
        if (domesticOnly) {
            filtered.removeIf(trial -> !isDomesticCached(trial));
        }
        if (filtered.size() > DISPLAY_LIMIT) {
            return new ArrayList<>(filtered.subList(0, DISPLAY_LIMIT));
        }
        return filtered;
    }

    private boolean isDomesticCached(TrialVO trial) {
        if (trial == null) {
            return false;
        }
        if (isCrisId(trial.getNctId())) {
            return true;
        }
        String location = trial.getLocationText();
        return location != null
                && (location.toLowerCase(Locale.ROOT).contains("south korea")
                        || location.contains("대한민국")
                        || location.contains("한국"));
    }

    private List<TrialVO> prioritizeDomesticTrials(
            List<TrialVO> crisTrials,
            List<TrialVO> clinicalTrials) {
        List<TrialVO> focusedCris = new ArrayList<>();
        List<TrialVO> otherCris = new ArrayList<>();

        for (TrialVO trial : crisTrials) {
            if (treatmentPriorityScore(trial) >= 70) {
                focusedCris.add(trial);
            } else {
                otherCris.add(trial);
            }
        }

        focusedCris.sort((left, right) -> Integer.compare(
                treatmentPriorityScore(right),
                treatmentPriorityScore(left)));
        otherCris.sort((left, right) -> Integer.compare(
                treatmentPriorityScore(right),
                treatmentPriorityScore(left)));

        List<TrialVO> prioritized = new ArrayList<>();

        // 국내 한글 CRIS 연구를 우선하되, ClinicalTrials.gov 한국 수행 연구도
        // 최대 20건 화면 안에 일부 포함될 수 있도록 CRIS 우선 영역을 16건으로 둔다.
        int crisFrontLimit = Math.min(16, focusedCris.size());
        prioritized.addAll(focusedCris.subList(0, crisFrontLimit));
        prioritized.addAll(clinicalTrials);
        if (focusedCris.size() > crisFrontLimit) {
            prioritized.addAll(focusedCris.subList(crisFrontLimit, focusedCris.size()));
        }
        prioritized.addAll(otherCris);
        return prioritized;
    }

    private int treatmentPriorityScore(TrialVO trial) {
        if (trial == null || !isCrisId(trial.getNctId())) {
            return 0;
        }

        int score = 0;
        String meta = normalizeForPriority(trial.getConditionsText());
        String title = normalizeForPriority(trial.getTitle() + " " + trial.getOfficialTitle());
        String phase = normalizeForPriority(trial.getPhase());

        if ("INTERVENTIONAL".equalsIgnoreCase(trial.getStudyType())) {
            score += 15;
        }
        if (!phase.isBlank() && !phase.contains("NA") && phase.contains("PHASE")) {
            score += 70;
        }

        if (containsAny(meta, "의약품", "약물", "생물학적", "백신", "세포치료", "유전자치료")) {
            score += 100;
        } else if (containsAny(meta, "의료기구", "의료기기")) {
            score += 80;
        } else if (containsAny(meta, "수술", "시술", "치료", "재활")) {
            score += 60;
        } else if (containsAny(meta, "행동요법", "운동")) {
            score += 25;
        }

        if (containsAny(
                title,
                "치료", "임상시험", "안전성", "유효성", "투여", "항암", "약물", "약제",
                "제제", "백신", "세포", "유전자", "수술", "시술", "환자", "암", "질환")) {
            score += 35;
        }

        if (containsAny(
                title,
                "교육프로그램", "교육 프로그램", "교육", "지식", "역량", "인식", "만족도",
                "설문", "챗봇", "학생", "간호사")) {
            score -= 70;
        }
        return score;
    }

    private String normalizeForPriority(String value) {
        return value == null ? "" : value.toLowerCase(Locale.ROOT);
    }

    private boolean containsAny(String text, String... keywords) {
        if (text == null || text.isBlank()) {
            return false;
        }
        for (String keyword : keywords) {
            if (keyword != null && !keyword.isBlank() && text.contains(keyword.toLowerCase(Locale.ROOT))) {
                return true;
            }
        }
        return false;
    }

    private List<TrialVO> deduplicate(List<TrialVO> trials) {
        Map<String, TrialVO> unique = new LinkedHashMap<>();
        for (TrialVO trial : trials) {
            if (trial == null || trial.getNctId() == null || trial.getNctId().isBlank()) {
                continue;
            }
            unique.putIfAbsent(trial.getNctId().trim().toUpperCase(Locale.ROOT), trial);
        }
        return new ArrayList<>(unique.values());
    }

    private List<TrialVO> persistAndLimit(List<TrialVO> trials) {
        List<TrialVO> displayed = new ArrayList<>();
        for (TrialVO trial : trials) {
            if (displayed.size() >= DISPLAY_LIMIT) {
                break;
            }

            prepareApiTrial(trial);
            trialDAO.mergeTrial(trial);
            TrialVO persisted = trialDAO.selectTrialByNctId(trial.getNctId());
            if (persisted != null) {
                trial.setTrialNo(persisted.getTrialNo());
            }
            displayed.add(trial);
        }
        return displayed;
    }

    private void prepareApiTrial(TrialVO trial) {
        trial.setSourceType(SOURCE_API);
        trial.setReviewStatus(REVIEW_APPROVED);
        if (trial.getTitle() == null || trial.getTitle().isBlank()) {
            trial.setTitle(trial.getNctId() == null ? "임상연구" : trial.getNctId());
        }
        if (trial.getRecruitmentStatus() == null || trial.getRecruitmentStatus().isBlank()) {
            trial.setRecruitmentStatus("UNKNOWN");
        }
        trial.setNctId(limitText(trial.getNctId(), 30));
        trial.setTitle(limitText(trial.getTitle(), 500));
        trial.setOfficialTitle(limitText(trial.getOfficialTitle(), 1000));
        trial.setPhase(limitText(trial.getPhase(), 100));
        trial.setStudyType(limitText(trial.getStudyType(), 100));
        trial.setRecruitmentStatus(limitText(trial.getRecruitmentStatus(), 50));
        trial.setSex(limitText(trial.getSex(), 20));
        trial.setMinAge(limitText(trial.getMinAge(), 50));
        trial.setMaxAge(limitText(trial.getMaxAge(), 50));
        trial.setLeadSponsor(limitText(trial.getLeadSponsor(), 300));
        trial.setInstitutionName(limitText(trial.getInstitutionName(), 300));
        trial.setContactName(limitText(trial.getContactName(), 100));
        trial.setContactPhone(limitText(trial.getContactPhone(), 50));
        trial.setContactEmail(limitText(trial.getContactEmail(), 200));
        trial.setStartDateText(limitText(trial.getStartDateText(), 20));
        trial.setCompletionDateText(limitText(trial.getCompletionDateText(), 20));
        if (trial.getEnrollmentCurrent() == null) {
            trial.setEnrollmentCurrent(0);
        }
        if (trial.getViewCount() == null) {
            trial.setViewCount(0);
        }
    }

    private String limitText(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }

    private List<TrialVO> filterTrials(
            List<TrialVO> trials,
            String recruitmentStatus,
            String phase) {
        List<TrialVO> filtered = new ArrayList<>();
        if (trials == null) {
            return filtered;
        }

        for (TrialVO trial : trials) {
            if (trial == null || !isInterventional(trial)) {
                continue;
            }
            if (!statusMatches(trial.getRecruitmentStatus(), recruitmentStatus)) {
                continue;
            }
            if (!phaseMatches(trial.getPhase(), phase)) {
                continue;
            }
            filtered.add(trial);
        }
        return filtered;
    }

    private boolean isInterventional(TrialVO trial) {
        String studyType = trial.getStudyType();
        if (isCrisId(trial.getNctId())) {
            return "INTERVENTIONAL".equalsIgnoreCase(studyType);
        }
        return studyType == null
                || studyType.isBlank()
                || "INTERVENTIONAL".equalsIgnoreCase(studyType);
    }

    private boolean statusMatches(String actual, String requested) {
        return "ALL".equals(requested)
                || (actual != null && requested.equalsIgnoreCase(actual));
    }

    private boolean phaseMatches(String actual, String requested) {
        if ("ALL".equals(requested)) {
            return true;
        }
        if (actual == null || actual.isBlank()) {
            return false;
        }

        String normalized = actual.toUpperCase(Locale.ROOT);
        return switch (requested) {
            case "PHASE1" -> normalized.contains("PHASE1") && !normalized.contains("PHASE2");
            case "PHASE1_2" -> normalized.contains("PHASE1") && normalized.contains("PHASE2");
            case "PHASE2" -> normalized.contains("PHASE2")
                    && !normalized.contains("PHASE1")
                    && !normalized.contains("PHASE3");
            case "PHASE2_3" -> normalized.contains("PHASE2") && normalized.contains("PHASE3");
            case "PHASE3" -> normalized.contains("PHASE3") && !normalized.contains("PHASE2");
            default -> true;
        };
    }

    private String resolveApiQuery(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return buildDefaultFocusQuery();
        }

        FocusDisease focus = DiseaseFocusCatalog.findBestMatch(keyword, keyword);
        if (focus != null) {
            return focus.clinicalTrialsQuery();
        }

        List<DiseaseVO> diseases = diseaseDAO.selectDiseaseList(keyword, "", 1);
        if (diseases != null && !diseases.isEmpty()) {
            DiseaseVO disease = diseases.get(0);
            if (disease.getEnglishName() != null && !disease.getEnglishName().isBlank()) {
                FocusDisease matched = DiseaseFocusCatalog.findBestMatch(
                        disease.getDiseaseName(),
                        disease.getEnglishName());
                return matched == null
                        ? disease.getEnglishName().trim()
                        : matched.clinicalTrialsQuery();
            }
        }
        return keyword;
    }

    private String buildDefaultFocusQuery() {
        List<String> terms = new ArrayList<>();
        for (FocusDisease disease : DiseaseFocusCatalog.diseases()) {
            String query = disease.clinicalTrialsQuery();
            if (query != null && !query.isBlank()) {
                terms.add('"' + query.replace("\"", "") + '"');
            }
        }
        return String.join(" OR ", terms);
    }

    private boolean isCrisId(String value) {
        return value != null && value.trim().toUpperCase(Locale.ROOT).startsWith("KCT");
    }

    private String normalizeStatus(String value) {
        if (value == null) {
            return "ALL";
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        return switch (normalized) {
            case "RECRUITING", "NOT_YET_RECRUITING", "COMPLETED" -> normalized;
            default -> "ALL";
        };
    }

    private String normalizePhase(String value) {
        if (value == null) {
            return "ALL";
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        return switch (normalized) {
            case "PHASE1", "PHASE1_2", "PHASE2", "PHASE2_3", "PHASE3" -> normalized;
            default -> "ALL";
        };
    }

    private String normalizeScope(String value) {
        if (value == null) {
            return SCOPE_DOMESTIC;
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        return "GLOBAL".equals(normalized) ? "GLOBAL" : SCOPE_DOMESTIC;
    }
}
