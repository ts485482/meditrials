package meditrials.meditrials.disease.api;

import java.io.ByteArrayInputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

@Component
public class HiraDiseaseClient {

    private static final int DEFAULT_RESULT_LIMIT = 20;
    private static final int MAX_RESULT_LIMIT = 100;
    private static final int SICK_TYPE = 1;
    private static final int MEDICAL_TYPE = 1;
    private static final String DISEASE_TYPE_NAME = "SICK_NM";
    private static final String DISEASE_TYPE_CODE = "SICK_CD";

    private final RestClient restClient;
    private final String serviceKey;

    public HiraDiseaseClient(
            @Value("${meditrials.hira.base-url:https://apis.data.go.kr/B551182/diseaseInfoService1}")
            String baseUrl,
            @Value("${meditrials.hira.service-key:}") String serviceKey) {
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .build();
        this.serviceKey = normalizeServiceKey(serviceKey);
    }

    public boolean isConfigured() {
        return serviceKey != null && !serviceKey.isBlank();
    }

    public List<HiraDiseaseItem> searchDiseases(String keyword) {
        return searchDiseases(keyword, DEFAULT_RESULT_LIMIT);
    }

    public List<HiraDiseaseItem> searchDiseases(String keyword, int resultLimit) {
        String normalizedKeyword = keyword == null ? "" : keyword.trim();
        if (normalizedKeyword.isBlank()) {
            return List.of();
        }
        if (!isConfigured()) {
            throw new HiraDiseaseApiException(
                    "HIRA 질병정보서비스 인증키가 설정되지 않았습니다. HIRA_SERVICE_KEY 환경변수를 설정해주세요.");
        }

        int safeLimit = Math.max(1, Math.min(resultLimit, MAX_RESULT_LIMIT));
        String diseaseType = looksLikeDiseaseCode(normalizedKeyword)
                ? DISEASE_TYPE_CODE
                : DISEASE_TYPE_NAME;

        return requestDiseaseSearch(normalizedKeyword, diseaseType, safeLimit);
    }

    private List<HiraDiseaseItem> requestDiseaseSearch(
            String searchText,
            String diseaseType,
            int resultLimit) {
        try {
            byte[] xml = restClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/getDissNameCodeList1")
                            // 공공데이터포털 공식 파라미터명은 ServiceKey이다.
                            .queryParam("ServiceKey", serviceKey)
                            .queryParam("pageNo", 1)
                            .queryParam("numOfRows", resultLimit)
                            .queryParam("sickType", SICK_TYPE)
                            // MediTrials는 의과(양방) 질환정보를 사용한다.
                            .queryParam("medTp", MEDICAL_TYPE)
                            // 질병명/코드조회 API는 diseaseType + searchText로 서버 검색한다.
                            .queryParam("diseaseType", diseaseType)
                            .queryParam("searchText", searchText)
                            .queryParam("_type", "xml")
                            .build())
                    .retrieve()
                    .body(byte[].class);

            return parseDiseaseItems(xml);
        } catch (HiraDiseaseApiException exception) {
            throw exception;
        } catch (RestClientException exception) {
            throw new HiraDiseaseApiException(
                    "건강보험심사평가원 질병정보서비스를 호출하지 못했습니다.",
                    exception);
        }
    }

    private List<HiraDiseaseItem> parseDiseaseItems(byte[] xml) {
        if (xml == null || xml.length == 0) {
            return List.of();
        }

        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
            factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            factory.setFeature("http://xml.org/sax/features/external-general-entities", false);
            factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
            factory.setExpandEntityReferences(false);
            factory.setXIncludeAware(false);

            DocumentBuilder builder = factory.newDocumentBuilder();
            // HIRA XML 원본 바이트를 그대로 파싱하여 XML 선언의 문자셋을 존중한다.
            // String.class로 먼저 변환하면 응답 Content-Type에 charset이 없을 때
            // UTF-8 한글이 ISO-8859-1 계열로 잘못 해석되어 깨질 수 있다.
            Document document = builder.parse(new ByteArrayInputStream(xml));

            validateResponse(document);

            NodeList itemNodes = document.getElementsByTagName("item");
            List<HiraDiseaseItem> items = new ArrayList<>();
            for (int index = 0; index < itemNodes.getLength(); index++) {
                Node node = itemNodes.item(index);
                if (!(node instanceof Element itemElement)) {
                    continue;
                }

                String sickCode = firstText(itemElement, "sickCd", "sickCode");
                String koreanName = firstText(itemElement, "sickNm", "diseaseName");
                String englishName = firstText(
                        itemElement,
                        "sickEngNm",
                        "sickNmEng",
                        "engSickNm",
                        "engNm",
                        "englishName");
                if (englishName == null || englishName.isBlank()) {
                    englishName = findEnglishNameField(itemElement);
                }

                if (koreanName == null || koreanName.isBlank()) {
                    continue;
                }

                items.add(new HiraDiseaseItem(
                        trimToNull(sickCode),
                        koreanName.trim(),
                        trimToNull(englishName)));
            }
            return items;
        } catch (HiraDiseaseApiException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new HiraDiseaseApiException(
                    "HIRA 질병정보 XML 응답을 해석하지 못했습니다.",
                    exception);
        }
    }

    private void validateResponse(Document document) {
        String returnReasonCode = firstDocumentText(document, "returnReasonCode");
        if (returnReasonCode != null && !returnReasonCode.isBlank()
                && !"0".equals(returnReasonCode.trim())
                && !"00".equals(returnReasonCode.trim())) {
            String message = firstDocumentText(document, "returnAuthMsg", "errMsg");
            throw new HiraDiseaseApiException(
                    "HIRA API 인증 오류 " + returnReasonCode + ": "
                            + (message == null
                                    ? "인증키 또는 활용신청 상태를 확인해주세요."
                                    : message));
        }

        String resultCode = firstDocumentText(document, "resultCode");
        if (resultCode != null && !resultCode.isBlank()
                && !"0".equals(resultCode.trim())
                && !"00".equals(resultCode.trim())) {
            String message = firstDocumentText(
                    document,
                    "resultMsg",
                    "resultMessage",
                    "errMsg");
            throw new HiraDiseaseApiException(
                    "HIRA API 오류 " + resultCode + ": "
                            + (message == null ? "요청값을 확인해주세요." : message));
        }
    }

    private String firstDocumentText(Document document, String... tagNames) {
        for (String tagName : tagNames) {
            NodeList nodes = document.getElementsByTagName(tagName);
            if (nodes.getLength() > 0) {
                String value = trimToNull(nodes.item(0).getTextContent());
                if (value != null) {
                    return value;
                }
            }
        }
        return null;
    }

    private String firstText(Element element, String... tagNames) {
        for (String tagName : tagNames) {
            NodeList nodes = element.getElementsByTagName(tagName);
            if (nodes.getLength() > 0) {
                String value = trimToNull(nodes.item(0).getTextContent());
                if (value != null) {
                    return value;
                }
            }
        }
        return null;
    }

    private String findEnglishNameField(Element element) {
        NodeList childNodes = element.getChildNodes();
        for (int index = 0; index < childNodes.getLength(); index++) {
            Node child = childNodes.item(index);
            String nodeName = child.getNodeName();
            if (nodeName == null) {
                continue;
            }
            String normalized = nodeName.toLowerCase(Locale.ROOT);
            if (normalized.contains("eng") && normalized.contains("nm")) {
                String value = trimToNull(child.getTextContent());
                if (value != null) {
                    return value;
                }
            }
        }
        return null;
    }

    private boolean looksLikeDiseaseCode(String value) {
        String compact = value.replace(".", "")
                .replace("-", "")
                .replace(" ", "")
                .toUpperCase(Locale.ROOT);
        return compact.matches("[A-Z][0-9A-Z]{1,6}");
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

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
