<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.disease.vo.DiseaseVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%
    Object diseasesAttribute = request.getAttribute("diseases");
    List<?> diseaseList = diseasesAttribute instanceof List<?> list ? list : List.of();
    String keyword = request.getAttribute("keyword") instanceof String value ? value : "";
    String selectedCategory = request.getAttribute("selectedCategory") instanceof String value
            ? value : "ALL";
    String apiNotice = request.getAttribute("apiNotice") instanceof String value ? value : "";
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : "";
    boolean apiAvailable = Boolean.TRUE.equals(request.getAttribute("apiAvailable"));
    int totalCount = request.getAttribute("totalCount") instanceof Number number
            ? number.intValue() : 0;
    String escapedKeyword = HtmlUtils.htmlEscape(keyword);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>질환 검색 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/disease.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section">
  <div class="mt-container">
    <div class="disease-page-head">
      <div>
        <h1 class="section-title mb-10">질환 정보</h1>
        <p class="text-muted mb-0">
          치료 연구가 활발한 난치성·치료 미충족 질환을 중심으로 질환정보와 임상시험을 연결합니다.
        </p>
      </div>
      <span class="badge <%= apiAvailable ? "badge-green" : "badge-amber" %>">
        <%= apiAvailable ? "HIRA 연동" : "HIRA 인증키 필요" %>
      </span>
    </div>

    <div class="search-panel disease-search-panel">
      <form action="${pageContext.request.contextPath}/diseases" method="get" class="disease-search-form">
        <input type="hidden" name="category" value="<%= HtmlUtils.htmlEscape(selectedCategory) %>">
        <input
            class="form-control"
            type="search"
            name="keyword"
            value="<%= escapedKeyword %>"
            placeholder="질환명, 영문 질환명 또는 KCD 코드"
            aria-label="질환 검색어">
        <button class="btn btn-primary" type="submit">검색</button>
      </form>

      <form action="${pageContext.request.contextPath}/diseases" method="get" class="disease-filter-tabs">
        <input type="hidden" name="keyword" value="<%= escapedKeyword %>">
        <button class="tab disease-filter-tab <%= "ALL".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="ALL">전체</button>
        <button class="tab disease-filter-tab <%= "NEURO".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="NEURO">신경퇴행성</button>
        <button class="tab disease-filter-tab <%= "AUTOIMMUNE".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="AUTOIMMUNE">자가면역·면역</button>
        <button class="tab disease-filter-tab <%= "CANCER".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="CANCER">암·종양</button>
        <button class="tab disease-filter-tab <%= "GENETIC".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="GENETIC">유전성</button>
        <button class="tab disease-filter-tab <%= "CHRONIC".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="CHRONIC">만성·난치성</button>
      </form>
      <p class="disease-filter-note">
        분류는 MediTrials의 치료 연구 탐색용 분류이며, 희귀질환 여부는 추후 공식 희귀질환 데이터로 별도 보강합니다.
      </p>
    </div>

    <% if (!pageNotice.isBlank()) { %>
      <div class="disease-api-notice is-warning"><%= HtmlUtils.htmlEscape(pageNotice) %></div>
    <% } %>

    <% if (!apiNotice.isBlank()) { %>
      <div class="disease-api-notice <%= apiAvailable ? "is-success" : "is-warning" %>">
        <%= HtmlUtils.htmlEscape(apiNotice) %>
      </div>
    <% } %>

    <div class="disease-data-guide">
      <div><strong>질환명·KCD</strong><span>건강보험심사평가원</span></div>
      <div><strong>질환 설명</strong><span>MedlinePlus</span></div>
      <div><strong>관련 임상시험</strong><span>ClinicalTrials.gov</span></div>
    </div>

    <div class="disease-result-head">
      <h3>질환 검색 결과</h3>
      <span class="text-muted">총 <strong><%= totalCount %></strong>건 · 최대 20건 표시</span>
    </div>

    <% if (diseaseList.isEmpty()) { %>
      <div class="disease-empty">
        <strong>표시할 질환정보가 없습니다.</strong>
        <p>
          HIRA 인증키를 설정했는지 확인하거나 질환명·KCD 코드로 검색해주세요.
        </p>
        <a class="btn btn-outline" href="${pageContext.request.contextPath}/diseases">검색 초기화</a>
      </div>
    <% } else { %>
      <div class="content-grid-2 disease-result-grid">
        <% for (Object item : diseaseList) {
             if (!(item instanceof DiseaseVO disease)) {
                 continue;
             }
             String diseaseName = disease.getDiseaseName() == null
                     ? "질환정보" : HtmlUtils.htmlEscape(disease.getDiseaseName());
             String englishName = disease.getEnglishName() == null
                     ? "" : HtmlUtils.htmlEscape(disease.getEnglishName());
             String rawSourceCode = disease.getSourceCode();
             String displayCode = rawSourceCode == null ? "-" : rawSourceCode;
             if (displayCode.startsWith("HIRA:")) {
                 displayCode = displayCode.substring("HIRA:".length());
             }
             displayCode = HtmlUtils.htmlEscape(displayCode);
             String category = disease.getCategory() == null
                     ? "치료 연구 질환" : HtmlUtils.htmlEscape(disease.getCategory());
             Integer relatedTrialCount = disease.getRelatedTrialCount();
        %>
          <a class="result-card disease-result-card"
             href="${pageContext.request.contextPath}/diseases/<%= disease.getDiseaseNo() %>">
            <div class="row-between disease-card-title-row">
              <div class="disease-card-title-group">
                <h3><%= diseaseName %></h3>
                <% if (!englishName.isBlank() && !englishName.equals(diseaseName)) { %>
                  <p><%= englishName %></p>
                <% } %>
              </div>
              <span class="badge badge-blue"><%= category %></span>
            </div>
            <div class="result-meta disease-card-meta">
              <span>KCD <strong><%= displayCode %></strong></span>
              <span>
                관련 임상시험
                <% if (relatedTrialCount == null) { %>
                  <strong>확인 불가</strong>
                <% } else { %>
                  <strong><%= relatedTrialCount %></strong>건
                <% } %>
              </span>
            </div>
            <span class="disease-card-link">상세정보 보기 →</span>
          </a>
        <% } %>
      </div>
    <% } %>

    <div class="disease-source-credit">
      질환명·KCD 출처: 건강보험심사평가원 질병정보서비스
    </div>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
