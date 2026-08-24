package meditrials.meditrials.trial.api;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import meditrials.meditrials.trial.vo.TrialVO;

@Component
public class CrisClinicalTrialClient {

    private static final int SEARCH_FETCH_SIZE = 50;
    private static final Duration CACHE_DURATION = Duration.ofMinutes(30);

    private final RestClient restClient;
    private final String serviceKey;
    private final Map<String, CacheEntry> cache = new ConcurrentHashMap<>();

    public CrisClinicalTrialClient(
            @Value("${meditrials.cris.base-url:https://apis.data.go.kr/1352159/crisinfodataview}")
            String baseUrl,
            @Value("${CRIS_SERVICE_KEY:}") String serviceKey) {
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .build();
        this.serviceKey = normalizeServiceKey(serviceKey);
    }

    public boolean isConfigured() {
        return serviceKey != null && !serviceKey.isBlank();
    }

    public CrisSearchResult searchStudies(String keyword) {
        if (!isConfigured()) {
            throw new CrisClinicalTrialException(
                    "CRIS 임상연구 DB 인증키가 설정되지 않았습니다. CRIS_SERVICE_KEY 환경변수를 설정해주세요.");
        }

        String normalizedKeyword = keyword == null ? "" : keyword.trim();
        String cacheKey = normalizedKeyword.toLowerCase(Locale.ROOT);
        CacheEntry cached = cache.get(cacheKey);
        if (cached != null && cached.cachedAt().plus(CACHE_DURATION).isAfter(Instant.now())) {
            return cached.result();
        }

        try {
            Map<?, ?> raw = restClient.get()
                    .uri(uriBuilder -> {
                        var builder = uriBuilder
                                .path("/list")
                                .queryParam("serviceKey", serviceKey)
                                .queryParam("resultType", "JSON")
                                .queryParam("numOfRows", SEARCH_FETCH_SIZE)
                                .queryParam("pageNo", 1);
                        if (!normalizedKeyword.isBlank()) {
                            builder.queryParam("srchWord", normalizedKeyword);
                        }
                        return builder.build();
                    })
                    .retrieve()
                    .body(Map.class);

            validateResponse(raw);
            Object body = findValue(raw, "body");
            Integer totalCount = readInteger(findValue(body, "totalCount"));
            List<TrialVO> trials = parseItems(findValue(body, "items"));

            CrisSearchResult result = new CrisSearchResult(trials, totalCount);
            cache.put(cacheKey, new CacheEntry(result, Instant.now()));
            return result;
        } catch (CrisClinicalTrialException exception) {
            throw exception;
        } catch (RestClientException exception) {
            throw new CrisClinicalTrialException(
                    "질병관리청 CRIS 임상연구 정보를 불러오지 못했습니다.",
                    exception);
        } catch (RuntimeException exception) {
            throw new CrisClinicalTrialException(
                    "CRIS 임상연구 응답을 해석하지 못했습니다.",
                    exception);
        }
    }

    private void validateResponse(Map<?, ?> raw) {
        String resultCode = readString(findValue(raw, "resultCode"));
        if (resultCode == null || resultCode.isBlank() || "00".equals(resultCode) || "0".equals(resultCode)) {
            return;
        }

        String message = readString(findValue(raw, "resultMsg"));
        if (message == null || message.isBlank()) {
            message = "인증키와 활용신청 상태를 확인해주세요.";
        }
        throw new CrisClinicalTrialException("CRIS API 오류 " + resultCode + ": " + message);
    }

    private List<TrialVO> parseItems(Object itemsObject) {
        Object candidate = itemsObject;
        if (candidate instanceof Map<?, ?> map) {
            Object item = valueIgnoreCase(map, "item");
            if (item != null) {
                candidate = item;
            }
        }

        List<?> items;
        if (candidate instanceof List<?> list) {
            items = list;
        } else if (candidate instanceof Map<?, ?> map) {
            items = List.of(map);
        } else {
            items = List.of();
        }

        List<TrialVO> trials = new ArrayList<>();
        for (Object itemObject : items) {
            Map<?, ?> item = asMap(itemObject);
            TrialVO trial = parseTrial(item);
            if (trial != null) {
                trials.add(trial);
            }
        }
        return trials;
    }

    private TrialVO parseTrial(Map<?, ?> item) {
        String trialId = read(item, "trial_id", "trialId");
        String titleKr = read(item, "scientific_title_kr", "scientificTitleKr");
        String titleEn = read(item, "scientific_title_en", "scientificTitleEn");
        if (trialId == null || trialId.isBlank() || titleKr == null || titleKr.isBlank()) {
            return null;
        }

        String studyTypeKr = read(item, "study_type_kr", "studyTypeKr");
        String phaseKr = read(item, "phase_kr", "phaseKr");
        String interventionKr = read(item, "i_freetext_kr", "iFreetextKr");
        String sponsorKr = read(item, "primary_sponsor_kr", "primarySponsorKr");
        String fundingKr = read(item, "source_name_kr", "sourceNameKr");
        String primaryOutcomeKr = read(item, "primary_outcome_1_kr", "primaryOutcome1Kr");
        String completionStateKr = read(
                item,
                "results_type_date_completed_kr",
                "resultsTypeDateCompletedKr");

        TrialVO trial = new TrialVO();
        trial.setNctId(trialId.trim().toUpperCase(Locale.ROOT));
        trial.setSourceType("API");
        trial.setReviewStatus("APPROVED");
        trial.setTitle(titleKr.trim());
        trial.setOfficialTitle(trimToNull(titleEn));
        trial.setStudyType(toStudyType(studyTypeKr));
        trial.setPhase(toPhase(phaseKr));
        trial.setRecruitmentStatus(toRecruitmentStatus(completionStateKr));
        trial.setLeadSponsor(firstNonBlank(fundingKr, sponsorKr));
        trial.setInstitutionName(firstNonBlank(sponsorKr, fundingKr));
        trial.setStartDateText(read(item, "date_enrolment", "dateEnrolment"));
        trial.setCompletionDateText(read(item, "results_date_completed", "resultsDateCompleted"));
        trial.setConditionsText(buildListDescription(studyTypeKr, interventionKr));
        trial.setLocationText(buildLocationText(trial.getInstitutionName()));
        trial.setBriefSummary(buildSummary(primaryOutcomeKr));
        trial.setEnrollmentCurrent(0);
        trial.setViewCount(0);
        return trial;
    }

    private String buildListDescription(String studyTypeKr, String interventionKr) {
        List<String> values = new ArrayList<>();
        addIfPresent(values, studyTypeKr);
        addIfPresent(values, interventionKr);
        return values.isEmpty() ? "국내 CRIS 등록 연구" : String.join(" · ", values);
    }

    private String buildSummary(String primaryOutcomeKr) {
        String outcome = trimToNull(primaryOutcomeKr);
        if (outcome == null) {
            return "질병관리청 임상연구정보서비스(CRIS)에 등록된 국내 임상연구입니다.";
        }
        return "질병관리청 임상연구정보서비스(CRIS)에 등록된 국내 임상연구입니다.\n"
                + "주요 결과변수: " + outcome;
    }

    private String buildLocationText(String institutionName) {
        String institution = trimToNull(institutionName);
        if (institution == null) {
            return "대한민국";
        }
        return "대한민국 / " + institution;
    }

    private String toStudyType(String value) {
        String normalized = trimToNull(value);
        if (normalized == null) {
            return null;
        }
        if (normalized.contains("중재")) {
            return "INTERVENTIONAL";
        }
        if (normalized.contains("관찰")) {
            return "OBSERVATIONAL";
        }
        return normalized;
    }

    private String toPhase(String value) {
        String normalized = trimToNull(value);
        if (normalized == null) {
            return null;
        }

        String compact = normalized
                .replace(" ", "")
                .replace("임상시험", "")
                .replace("임상", "")
                .toUpperCase(Locale.ROOT);
        if (compact.contains("1/2") || compact.contains("1·2") || compact.contains("1,2")) {
            return "PHASE1,PHASE2";
        }
        if (compact.contains("2/3") || compact.contains("2·3") || compact.contains("2,3")) {
            return "PHASE2,PHASE3";
        }
        if (compact.contains("1상") || compact.equals("1") || compact.contains("PHASE1")) {
            return "PHASE1";
        }
        if (compact.contains("2상") || compact.equals("2") || compact.contains("PHASE2")) {
            return "PHASE2";
        }
        if (compact.contains("3상") || compact.equals("3") || compact.contains("PHASE3")) {
            return "PHASE3";
        }
        if (compact.contains("4상") || compact.equals("4") || compact.contains("PHASE4")) {
            return "PHASE4";
        }
        if (compact.contains("해당사항없음") || compact.contains("해당없음")) {
            return "NA";
        }
        return normalized;
    }

    private String toRecruitmentStatus(String completionStateKr) {
        String normalized = trimToNull(completionStateKr);
        if (normalized != null && (normalized.contains("완료") || normalized.contains("종료"))) {
            return "COMPLETED";
        }
        return "CRIS_REGISTERED";
    }

    private Object findValue(Object value, String key) {
        if (value instanceof Map<?, ?> map) {
            Object direct = valueIgnoreCase(map, key);
            if (direct != null) {
                return direct;
            }
            for (Object nested : map.values()) {
                Object found = findValue(nested, key);
                if (found != null) {
                    return found;
                }
            }
        } else if (value instanceof List<?> list) {
            for (Object nested : list) {
                Object found = findValue(nested, key);
                if (found != null) {
                    return found;
                }
            }
        }
        return null;
    }

    private Object valueIgnoreCase(Map<?, ?> map, String key) {
        for (Map.Entry<?, ?> entry : map.entrySet()) {
            if (entry.getKey() != null && key.equalsIgnoreCase(String.valueOf(entry.getKey()))) {
                return entry.getValue();
            }
        }
        return null;
    }

    private String read(Map<?, ?> map, String... keys) {
        for (String key : keys) {
            String value = readString(valueIgnoreCase(map, key));
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }

    private Map<?, ?> asMap(Object value) {
        return value instanceof Map<?, ?> map ? map : Map.of();
    }

    private String readString(Object value) {
        return value == null ? null : String.valueOf(value).trim();
    }

    private Integer readInteger(Object value) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        if (value != null) {
            try {
                return Integer.valueOf(String.valueOf(value).trim());
            } catch (NumberFormatException exception) {
                return null;
            }
        }
        return null;
    }

    private void addIfPresent(List<String> target, String value) {
        String normalized = trimToNull(value);
        if (normalized != null) {
            target.add(normalized);
        }
    }

    private String firstNonBlank(String first, String second) {
        String normalizedFirst = trimToNull(first);
        return normalizedFirst == null ? trimToNull(second) : normalizedFirst;
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeServiceKey(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }
        String spaceFixed = value.trim().replace(" ", "+");
        try {
            return URLDecoder.decode(spaceFixed, StandardCharsets.UTF_8);
        } catch (IllegalArgumentException exception) {
            return spaceFixed;
        }
    }

    public record CrisSearchResult(List<TrialVO> studies, Integer totalCount) {
    }

    private record CacheEntry(CrisSearchResult result, Instant cachedAt) {
    }
}
