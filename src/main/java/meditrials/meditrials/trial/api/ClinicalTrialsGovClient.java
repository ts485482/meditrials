package meditrials.meditrials.trial.api;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import meditrials.meditrials.trial.vo.TrialVO;

@Component
public class ClinicalTrialsGovClient {

    private static final int SEARCH_FETCH_SIZE = 50;
    private static final Duration SEARCH_CACHE_DURATION = Duration.ofMinutes(30);
    private static final Duration DETAIL_CACHE_DURATION = Duration.ofHours(6);

    private static final String SEARCH_FIELDS = String.join(",",
            "NCTId",
            "BriefTitle",
            "OfficialTitle",
            "OverallStatus",
            "StartDate",
            "CompletionDate",
            "StudyType",
            "Phase",
            "EnrollmentCount",
            "Condition",
            "LeadSponsorName",
            "LocationFacility",
            "LocationCity",
            "LocationState",
            "LocationCountry");

    private final RestClient restClient;
    private final Map<String, SearchCacheEntry> searchCache = new ConcurrentHashMap<>();
    private final Map<String, DetailCacheEntry> detailCache = new ConcurrentHashMap<>();

    public ClinicalTrialsGovClient(
            @Value("${meditrials.clinicaltrials.base-url:https://clinicaltrials.gov}")
            String baseUrl) {
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .build();
    }

    public ApiSearchResult searchStudies(String queryTerm, String recruitmentStatus) {
        return searchStudies(queryTerm, recruitmentStatus, "");
    }

    public ApiSearchResult searchStudies(
            String queryTerm,
            String recruitmentStatus,
            String locationTerm) {
        String normalized = queryTerm == null ? "" : queryTerm.trim();
        String normalizedStatus = recruitmentStatus == null ? "" : recruitmentStatus.trim();
        String normalizedLocation = locationTerm == null ? "" : locationTerm.trim();
        String cacheKey = (normalized + "|" + normalizedStatus + "|" + normalizedLocation)
                .toLowerCase(Locale.ROOT);
        SearchCacheEntry cached = searchCache.get(cacheKey);
        if (cached != null && cached.cachedAt().plus(SEARCH_CACHE_DURATION).isAfter(Instant.now())) {
            return cached.result();
        }

        try {
            Map<?, ?> response = restClient.get()
                    .uri(uriBuilder -> {
                        var builder = uriBuilder
                                .path("/api/v2/studies")
                                .queryParam("format", "json")
                                .queryParam("pageSize", SEARCH_FETCH_SIZE)
                                .queryParam("countTotal", true)
                                .queryParam("sort", "LastUpdatePostDate:desc")
                                .queryParam("fields", SEARCH_FIELDS);
                        if (!normalized.isBlank()) {
                            builder.queryParam("query.term", normalized);
                        }
                        if (!normalizedStatus.isBlank() && !"ALL".equalsIgnoreCase(normalizedStatus)) {
                            builder.queryParam("filter.overallStatus", normalizedStatus);
                        }
                        if (!normalizedLocation.isBlank()) {
                            builder.queryParam("query.locn", normalizedLocation);
                        }
                        return builder.build();
                    })
                    .retrieve()
                    .body(Map.class);

            List<TrialVO> studies = parseStudies(response);
            Integer totalCount = readInteger(response == null ? null : response.get("totalCount"));
            ApiSearchResult result = new ApiSearchResult(studies, totalCount);
            searchCache.put(cacheKey, new SearchCacheEntry(result, Instant.now()));
            return result;
        } catch (RestClientException exception) {
            throw new ClinicalTrialsGovException(
                    "ClinicalTrials.gov 임상시험 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.",
                    exception);
        }
    }

    public TrialVO getStudy(String nctId) {
        if (nctId == null || nctId.isBlank()) {
            return null;
        }

        String normalized = nctId.trim().toUpperCase(Locale.ROOT);
        DetailCacheEntry cached = detailCache.get(normalized);
        if (cached != null && cached.cachedAt().plus(DETAIL_CACHE_DURATION).isAfter(Instant.now())) {
            return cached.trial();
        }

        try {
            Map<?, ?> response = restClient.get()
                    .uri("/api/v2/studies/{nctId}", normalized)
                    .retrieve()
                    .body(Map.class);

            TrialVO trial = parseStudy(response);
            if (trial != null) {
                detailCache.put(normalized, new DetailCacheEntry(trial, Instant.now()));
            }
            return trial;
        } catch (RestClientException exception) {
            throw new ClinicalTrialsGovException(
                    "ClinicalTrials.gov 임상시험 상세정보를 불러오지 못했습니다.",
                    exception);
        }
    }

    private List<TrialVO> parseStudies(Map<?, ?> response) {
        List<TrialVO> studies = new ArrayList<>();
        for (Object item : asList(response == null ? null : response.get("studies"))) {
            TrialVO trial = parseStudy(asMap(item));
            if (trial != null && trial.getNctId() != null && trial.getTitle() != null) {
                studies.add(trial);
            }
        }
        return studies;
    }

    private TrialVO parseStudy(Map<?, ?> study) {
        if (study == null || study.isEmpty()) {
            return null;
        }

        Map<?, ?> protocol = asMap(study.get("protocolSection"));
        if (protocol.isEmpty()) {
            return null;
        }

        Map<?, ?> identification = asMap(protocol.get("identificationModule"));
        Map<?, ?> status = asMap(protocol.get("statusModule"));
        Map<?, ?> description = asMap(protocol.get("descriptionModule"));
        Map<?, ?> design = asMap(protocol.get("designModule"));
        Map<?, ?> eligibility = asMap(protocol.get("eligibilityModule"));
        Map<?, ?> sponsor = asMap(protocol.get("sponsorCollaboratorsModule"));
        Map<?, ?> conditions = asMap(protocol.get("conditionsModule"));
        Map<?, ?> contactsLocations = asMap(protocol.get("contactsLocationsModule"));

        TrialVO trial = new TrialVO();
        trial.setSourceType("API");
        trial.setReviewStatus("APPROVED");
        trial.setEnrollmentCurrent(0);
        trial.setViewCount(0);

        trial.setNctId(readString(identification.get("nctId")));
        trial.setTitle(firstNonBlank(
                readString(identification.get("briefTitle")),
                readString(identification.get("officialTitle"))));
        trial.setOfficialTitle(readString(identification.get("officialTitle")));
        trial.setBriefSummary(readString(description.get("briefSummary")));

        trial.setRecruitmentStatus(readString(status.get("overallStatus")));
        trial.setStartDateText(readString(asMap(status.get("startDateStruct")).get("date")));
        trial.setCompletionDateText(readString(asMap(status.get("completionDateStruct")).get("date")));

        trial.setStudyType(readString(design.get("studyType")));
        trial.setPhase(toPhaseValue(asList(design.get("phases"))));
        trial.setEnrollmentTarget(readInteger(asMap(design.get("enrollmentInfo")).get("count")));

        trial.setEligibilityText(readString(eligibility.get("eligibilityCriteria")));
        trial.setSex(readString(eligibility.get("sex")));
        trial.setMinAge(readString(eligibility.get("minimumAge")));
        trial.setMaxAge(readString(eligibility.get("maximumAge")));

        trial.setLeadSponsor(readString(asMap(sponsor.get("leadSponsor")).get("name")));
        trial.setConditionsText(joinValues(asList(conditions.get("conditions")), 5));

        List<?> locations = asList(contactsLocations.get("locations"));
        trial.setLocationCount(locations.size());
        trial.setInstitutionName(firstLocationFacility(locations));
        trial.setLocationText(buildLocationText(locations));
        fillContact(trial, contactsLocations, locations);

        return trial;
    }

    private void fillContact(TrialVO trial, Map<?, ?> contactsLocations, List<?> locations) {
        Map<?, ?> contact = firstMap(asList(contactsLocations.get("centralContacts")));
        if (contact.isEmpty() && !locations.isEmpty()) {
            Map<?, ?> firstLocation = asMap(locations.get(0));
            contact = firstMap(asList(firstLocation.get("contacts")));
        }

        trial.setContactName(readString(contact.get("name")));
        trial.setContactPhone(readString(contact.get("phone")));
        trial.setContactEmail(readString(contact.get("email")));
    }

    private String firstLocationFacility(List<?> locations) {
        for (Object item : locations) {
            String facility = readString(asMap(item).get("facility"));
            if (facility != null && !facility.isBlank()) {
                return facility;
            }
        }
        return null;
    }

    private String buildLocationText(List<?> locations) {
        if (locations.isEmpty()) {
            return null;
        }

        List<String> lines = new ArrayList<>();
        int max = Math.min(locations.size(), 10);
        for (int i = 0; i < max; i++) {
            Map<?, ?> location = asMap(locations.get(i));
            List<String> parts = new ArrayList<>();
            addIfPresent(parts, readString(location.get("facility")));
            addIfPresent(parts, readString(location.get("city")));
            addIfPresent(parts, readString(location.get("state")));
            addIfPresent(parts, readString(location.get("country")));
            if (!parts.isEmpty()) {
                lines.add(String.join(" / ", parts));
            }
        }
        if (locations.size() > max) {
            lines.add("외 " + (locations.size() - max) + "개 기관");
        }
        return lines.isEmpty() ? null : String.join("\n", lines);
    }

    private String toPhaseValue(List<?> phases) {
        if (phases.isEmpty()) {
            return null;
        }
        Set<String> values = new LinkedHashSet<>();
        for (Object phase : phases) {
            String value = readString(phase);
            if (value != null && !value.isBlank()) {
                values.add(value);
            }
        }
        return values.isEmpty() ? null : String.join(",", values);
    }

    private String joinValues(List<?> values, int maxCount) {
        List<String> texts = new ArrayList<>();
        for (Object value : values) {
            String text = readString(value);
            if (text != null && !text.isBlank()) {
                texts.add(text);
                if (texts.size() >= maxCount) {
                    break;
                }
            }
        }
        return texts.isEmpty() ? null : String.join(", ", texts);
    }

    private Map<?, ?> firstMap(List<?> values) {
        return values.isEmpty() ? Map.of() : asMap(values.get(0));
    }

    private void addIfPresent(List<String> target, String value) {
        if (value != null && !value.isBlank()) {
            target.add(value.trim());
        }
    }

    private String firstNonBlank(String first, String second) {
        if (first != null && !first.isBlank()) {
            return first;
        }
        return second;
    }

    private Map<?, ?> asMap(Object value) {
        return value instanceof Map<?, ?> map ? map : Map.of();
    }

    private List<?> asList(Object value) {
        return value instanceof List<?> list ? list : List.of();
    }

    private String readString(Object value) {
        return value == null ? null : String.valueOf(value).trim();
    }

    private Integer readInteger(Object value) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        if (value instanceof String text) {
            try {
                return Integer.valueOf(text.trim());
            } catch (NumberFormatException exception) {
                return null;
            }
        }
        return null;
    }

    public record ApiSearchResult(List<TrialVO> studies, Integer totalCount) {
    }

    private record SearchCacheEntry(ApiSearchResult result, Instant cachedAt) {
    }

    private record DetailCacheEntry(TrialVO trial, Instant cachedAt) {
    }
}
