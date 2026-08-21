package meditrials.meditrials.disease.api;

import java.io.StringReader;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.util.HtmlUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

@Component
public class MedlinePlusClient {

    private final RestClient restClient;

    public MedlinePlusClient(
            @Value("${meditrials.medlineplus.base-url:https://wsearch.nlm.nih.gov}")
            String baseUrl) {
        this.restClient = RestClient.builder()
                .baseUrl(baseUrl)
                .build();
    }

    public MedlinePlusTopic searchTopic(String englishDiseaseName) {
        if (englishDiseaseName == null || englishDiseaseName.isBlank()) {
            return null;
        }

        try {
            String xml = restClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/ws/query")
                            .queryParam("db", "healthTopics")
                            .queryParam("term", englishDiseaseName.trim())
                            .queryParam("retmax", 1)
                            .queryParam("rettype", "brief")
                            .queryParam("tool", "meditrials")
                            .build())
                    .retrieve()
                    .body(String.class);
            return parseTopic(xml);
        } catch (RestClientException exception) {
            return null;
        }
    }

    private MedlinePlusTopic parseTopic(String xml) {
        if (xml == null || xml.isBlank()) {
            return null;
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
            Document document = builder.parse(new InputSource(new StringReader(xml)));
            NodeList documents = document.getElementsByTagName("document");
            if (documents.getLength() == 0 || !(documents.item(0) instanceof Element element)) {
                return null;
            }

            String title = null;
            String summary = null;
            NodeList contents = element.getElementsByTagName("content");
            for (int index = 0; index < contents.getLength(); index++) {
                Node node = contents.item(index);
                if (!(node instanceof Element content)) {
                    continue;
                }
                String name = content.getAttribute("name");
                if ("title".equalsIgnoreCase(name)) {
                    title = cleanHtml(content.getTextContent());
                } else if ("fullSummary".equalsIgnoreCase(name)) {
                    summary = cleanHtml(content.getTextContent());
                }
            }

            String sourceUrl = element.getAttribute("url");
            if (summary == null || summary.isBlank()) {
                return null;
            }
            return new MedlinePlusTopic(
                    blankToNull(title),
                    summary,
                    blankToNull(sourceUrl));
        } catch (Exception exception) {
            return null;
        }
    }

    private String cleanHtml(String value) {
        if (value == null) {
            return null;
        }
        String withoutTags = value.replaceAll("<[^>]+>", " ");
        String unescaped = HtmlUtils.htmlUnescape(withoutTags);
        return unescaped.replaceAll("\\s+", " ").trim();
    }

    private String blankToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
