package meditrials.meditrials.disease.api;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Component
public class ClinicalTrialsClient {

    private static final Duration CACHE_DURATION = Duration.ofHours(12);
    private static final Duration FAILURE_CACHE_DURATION = Duration.ofMinutes(5);

    private final RestClient restClient;
    private final Map<String, TrialCountCache> cache = new ConcurrentHashMap<>();

    public ClinicalTrialsClient(
            @Value("${meditrials.clinicaltrials.base-url:https://clinicaltrials.gov}")
            String baseUrl) {
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .build();
    }

    public Integer countStudies(String diseaseName) {
        if (diseaseName == null || diseaseName.isBlank()) {
            return null;
        }

        String key = diseaseName.trim().toLowerCase(java.util.Locale.ROOT);
        TrialCountCache cached = cache.get(key);
        if (isCacheValid(cached)) {
            return cached.count();
        }

        try {
            Map<?, ?> response = restClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/api/v2/studies")
                            .queryParam("query.cond", diseaseName.trim())
                            .queryParam("pageSize", 1)
                            .queryParam("countTotal", true)
                            .queryParam("format", "json")
                            .build())
                    .retrieve()
                    .body(Map.class);

            Integer count = readInteger(response == null ? null : response.get("totalCount"));
            cache.put(key, new TrialCountCache(count, Instant.now()));
            return count;
        } catch (RestClientException exception) {
            cache.put(key, new TrialCountCache(null, Instant.now()));
            return null;
        }
    }

    private boolean isCacheValid(TrialCountCache cached) {
        if (cached == null) {
            return false;
        }

        Duration duration = cached.count() == null
                ? FAILURE_CACHE_DURATION
                : CACHE_DURATION;
        return cached.cachedAt().plus(duration).isAfter(Instant.now());
    }

    private Integer readInteger(Object value) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        if (value instanceof String text) {
            try {
                return Integer.valueOf(text);
            } catch (NumberFormatException exception) {
                return null;
            }
        }
        return null;
    }

    private record TrialCountCache(Integer count, Instant cachedAt) {
    }
}
