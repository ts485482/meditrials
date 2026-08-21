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
    String description = disease == null || disease.getDescription() == null || disease.getDescription().isBlank()
            ? "MedlinePlus에서 연결 가능한 질환 설명을 찾지 못했습니다. 질환명과 KCD 정보는 HIRA 데이터를 기준으로 제공합니다."
            : HtmlUtils.htmlEscape(disease.getDescription());
    String symptomText = disease == null || disease.getSymptomText() == null || disease.getSymptomText().isBlank()
            ? "구조화된 주요 증상 정보는 현재 데이터 출처를 추가 검토 중입니다. 확인되지 않은 증상 정보를 임의로 표시하지 않습니다."
            : HtmlUtils.htmlEscape(disease.getSymptomText());
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
          <h2>질환 설명</h2>
          <p class="disease-detail-text"><%= description %></p>
        </section>

        <section class="detail-section">
          <h2>주요 증상</h2>
          <p class="disease-detail-text"><%= symptomText %></p>
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
          <strong>MedlinePlus</strong>
          <span>연결 가능한 질환의 일반 설명 보강</span>
        </div>
        <div class="disease-source-row">
          <strong>ClinicalTrials.gov</strong>
          <span>질환별 관련 임상시험 건수</span>
        </div>
        <% if (sourceUrl.startsWith("http://") || sourceUrl.startsWith("https://")) { %>
          <a class="btn btn-light w-100" href="<%= sourceUrl %>" target="_blank" rel="noopener noreferrer">
            질환 설명 원문 보기
          </a>
        <% } %>
        <p class="disease-license">
          MediTrials의 질환 분류는 치료 연구 탐색을 위한 서비스 분류이며 공식 진단 분류를 대체하지 않습니다.
        </p>
      </aside>
    </div>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
