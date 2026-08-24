<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="meditrials.meditrials.disease.vo.DiseaseVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%
    DiseaseVO disease = request.getAttribute("disease") instanceof DiseaseVO value ? value : null;
    String diseaseName = disease == null || disease.getDiseaseName() == null
            ? "질환정보" : HtmlUtils.htmlEscape(disease.getDiseaseName());
    String englishName = disease == null || disease.getEnglishName() == null
            ? "" : HtmlUtils.htmlEscape(disease.getEnglishName());
    String category = disease == null || disease.getCategory() == null
            ? "치료 연구 질환" : HtmlUtils.htmlEscape(disease.getCategory());
    String rawSourceCode = disease == null ? null : disease.getSourceCode();
    String displayCode = rawSourceCode == null ? "-" : rawSourceCode;
    if (displayCode.startsWith("HIRA:")) {
        displayCode = displayCode.substring("HIRA:".length());
    }
    displayCode = HtmlUtils.htmlEscape(displayCode);

    boolean hasDescription = disease != null
            && disease.getDescription() != null
            && !disease.getDescription().isBlank();
    String description = hasDescription
            ? HtmlUtils.htmlEscape(disease.getDescription())
            : "등록된 한국어 질환 설명이 없습니다. 연결 가능한 경우 MedlinePlus 영문 설명을 보조 정보로 제공합니다.";

    boolean hasSymptoms = disease != null
            && disease.getSymptomText() != null
            && !disease.getSymptomText().isBlank();
    String[] symptomItems = hasSymptoms
            ? disease.getSymptomText().split("\\s*,\\s*")
            : new String[0];

    String sourceUrl = disease == null || disease.getSourceUrl() == null
            ? "" : HtmlUtils.htmlEscape(disease.getSourceUrl());
    Integer relatedTrialCount = disease == null ? null : disease.getRelatedTrialCount();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= diseaseName %> | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/disease.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section">
  <div class="mt-container">
    <div class="row-between disease-detail-head">
      <div>
        <a class="disease-back-link" href="${pageContext.request.contextPath}/diseases">← 질환 목록</a>
        <h1 class="section-title disease-detail-title"><%= diseaseName %></h1>
        <% if (!englishName.isBlank() && !englishName.equals(diseaseName)) { %>
          <p class="disease-english-name"><%= englishName %></p>
        <% } %>
        <div class="disease-detail-tags">
          <span class="badge badge-blue"><%= category %></span>
          <span class="badge badge-gray">KCD <%= displayCode %></span>
          <span class="badge badge-green">HIRA</span>
        </div>
      </div>
      <button class="btn btn-outline" type="button" disabled title="관심 질환 기능 연결 예정">
        ♡ 관심 질환 등록
      </button>
    </div>

    <div class="detail-layout">
      <div>
        <section class="detail-section">
          <div class="disease-section-title-row">
            <h2>질환 설명</h2>
            <% if (hasDescription) { %>
              <span class="badge badge-green">한국어 정보</span>
            <% } %>
          </div>
          <p class="disease-detail-text"><%= description %></p>
        </section>

        <section class="detail-section">
          <h2>주요 증상</h2>
          <% if (hasSymptoms) { %>
            <div class="disease-symptom-list">
              <% for (String symptom : symptomItems) {
                   String escapedSymptom = HtmlUtils.htmlEscape(symptom == null ? "" : symptom.trim());
                   if (!escapedSymptom.isBlank()) { %>
                <span class="disease-symptom-chip"><%= escapedSymptom %></span>
              <%   }
                 } %>
            </div>
          <% } else { %>
            <p class="disease-detail-text disease-detail-muted">
              등록된 주요 증상 정보가 없습니다. 확인되지 않은 증상 정보를 임의로 표시하지 않습니다.
            </p>
          <% } %>
        </section>

        <section class="detail-section">
          <div class="row-between">
            <h2 class="mb-0">관련 임상시험</h2>
            <span class="badge badge-gray">
              <% if (relatedTrialCount == null) { %>
                확인 불가
              <% } else { %>
                <%= relatedTrialCount %>건
              <% } %>
            </span>
          </div>
          <div class="disease-related-empty">
            현재는 ClinicalTrials.gov에서 해당 질환의 관련 연구 건수를 확인합니다.
            다음 임상시험 연동 단계에서 실제 모집 중 시험 목록과 상세 화면을 연결합니다.
          </div>
        </section>
      </div>

      <aside class="side-box disease-source-box">
        <h3>정보 출처</h3>
        <div class="disease-source-row">
          <strong>건강보험심사평가원</strong>
          <span>국문 질환명 · 영문 질환명 · KCD 코드</span>
        </div>
        <div class="disease-source-row">
          <strong>MediTrials 질환정보</strong>
          <span>DB에 등록한 한국어 질환 설명 · 주요 증상 정보를 우선 표시</span>
        </div>
        <div class="disease-source-row">
          <strong>MedlinePlus</strong>
          <span>한국어 설명이 없는 질환의 영문 일반 설명 보조 자료</span>
        </div>
        <div class="disease-source-row">
          <strong>ClinicalTrials.gov</strong>
          <span>질환별 관련 임상시험 건수</span>
        </div>
        <% if (sourceUrl.startsWith("http://") || sourceUrl.startsWith("https://")) { %>
          <a class="btn btn-light w-100" href="<%= sourceUrl %>" target="_blank" rel="noopener noreferrer">
            MedlinePlus 참고자료 보기
          </a>
        <% } %>
        <p class="disease-license">
          질환 설명과 주요 증상은 의료 상담이나 진단을 대신하지 않으며,
          MediTrials의 질환 분류는 치료 연구 탐색을 위한 서비스 분류입니다.
        </p>
      </aside>
    </div>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
