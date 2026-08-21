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

    private static final Duration CACHE_DURATION = Duration.ofHours(6);

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
        if (cached != null && cached.cachedAt().plus(CACHE_DURATION).isAfter(Instant.now())) {
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
            if (count != null) {
                cache.put(key, new TrialCountCache(count, Instant.now()));
            }
            return count;
        } catch (RestClientException exception) {
            return null;
        }
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

    private record TrialCountCache(int count, Instant cachedAt) {
    }
}
