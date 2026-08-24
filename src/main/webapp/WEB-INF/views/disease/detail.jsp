<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.disease.vo.DiseaseVO" %>
<%@ page import="meditrials.meditrials.trial.vo.TrialVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private boolean isCris(TrialVO trial) {
        return trial != null
                && trial.getNctId() != null
                && trial.getNctId().toUpperCase().startsWith("KCT");
    }

    private String sourceLabel(TrialVO trial) {
        return isCris(trial) ? "CRIS" : "ClinicalTrials.gov";
    }

    private String statusLabel(String value) {
        if (value == null || value.isBlank()) return "상태 미확인";
        return switch (value) {
            case "CRIS_REGISTERED" -> "CRIS 등록";
            case "RECRUITING" -> "모집중";
            case "NOT_YET_RECRUITING" -> "모집예정";
            case "ACTIVE_NOT_RECRUITING" -> "진행중·모집종료";
            case "ENROLLING_BY_INVITATION" -> "초대 모집";
            case "COMPLETED" -> "완료";
            case "SUSPENDED" -> "일시중단";
            case "TERMINATED" -> "조기종료";
            case "WITHDRAWN" -> "철회";
            default -> value;
        };
    }

    private String statusClass(String value) {
        if ("RECRUITING".equals(value)) return "badge-green";
        if ("NOT_YET_RECRUITING".equals(value)) return "badge-blue";
        if ("CRIS_REGISTERED".equals(value)) return "badge-cris";
        if ("COMPLETED".equals(value)) return "badge-gray";
        return "badge-amber";
    }

    private String phaseLabel(String value) {
        if (value == null || value.isBlank()) return "단계 미지정";
        String normalized = value.toUpperCase();
        if (normalized.contains("PHASE1") && normalized.contains("PHASE2")) return "1/2상";
        if (normalized.contains("PHASE2") && normalized.contains("PHASE3")) return "2/3상";
        if (normalized.contains("EARLY_PHASE1")) return "초기 1상";
        if (normalized.contains("PHASE1")) return "1상";
        if (normalized.contains("PHASE2")) return "2상";
        if (normalized.contains("PHASE3")) return "3상";
        if (normalized.contains("PHASE4")) return "4상";
        if (normalized.contains("NA")) return "해당없음";
        return value;
    }
%>
<%
    DiseaseVO disease = request.getAttribute("disease") instanceof DiseaseVO value ? value : null;
    String diseaseName = disease == null || disease.getDiseaseName() == null
            ? "질환정보" : HtmlUtils.htmlEscape(disease.getDiseaseName());
    String rawDiseaseName = disease == null || disease.getDiseaseName() == null
            ? "" : disease.getDiseaseName();
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

    List<TrialVO> relatedTrials = request.getAttribute("relatedTrials") instanceof List<?> list
            ? (List<TrialVO>) list : List.of();
    Integer relatedCrisCount = request.getAttribute("relatedCrisCount") instanceof Integer value ? value : null;
    Integer relatedClinicalTrialsCount = request.getAttribute("relatedClinicalTrialsCount") instanceof Integer value ? value : null;
    boolean relatedTrialApiAvailable = !(request.getAttribute("relatedTrialApiAvailable") instanceof Boolean value) || value;
    String relatedSearchUrl = request.getContextPath()
            + "/trials?scope=DOMESTIC&keyword="
            + URLEncoder.encode(rawDiseaseName, StandardCharsets.UTF_8);

    boolean favoriteDisease = Boolean.TRUE.equals(request.getAttribute("favoriteDisease"));
    Object loginRoleValue = session.getAttribute("LOGIN_MEMBER_ROLE");
    boolean loginUser = "USER".equals(loginRoleValue);
    boolean loggedIn = loginRoleValue != null;
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
      <% if (loginUser) { %>
        <form method="post" action="${pageContext.request.contextPath}/mypage/favorites/diseases/<%= disease.getDiseaseNo() %>">
          <button class="btn <%= favoriteDisease ? "btn-light" : "btn-outline" %>" type="submit">
            <%= favoriteDisease ? "♥ 관심 질환 해제" : "♡ 관심 질환 등록" %>
          </button>
        </form>
      <% } else if (!loggedIn) { %>
        <a class="btn btn-outline" href="${pageContext.request.contextPath}/login?required=true">♡ 관심 질환 등록</a>
      <% } else { %>
        <button class="btn btn-outline" type="button" disabled title="일반 사용자 계정에서 이용할 수 있습니다.">
          ♡ 관심 질환 등록
        </button>
      <% } %>
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

        <section class="detail-section disease-related-section">
          <div class="row-between disease-related-heading">
            <div>
              <h2 class="mb-0">관련 임상시험</h2>
              <p class="disease-related-subtitle">국내 CRIS 한글 연구를 우선하고, ClinicalTrials.gov의 대한민국 수행 연구를 함께 표시합니다.</p>
            </div>
            <div class="disease-related-source-counts">
              <% if (relatedCrisCount != null) { %>
                <span class="badge badge-cris">CRIS <%= relatedCrisCount %>건</span>
              <% } %>
              <% if (relatedClinicalTrialsCount != null) { %>
                <span class="badge badge-green">ClinicalTrials.gov 한국 <%= relatedClinicalTrialsCount %>건</span>
              <% } %>
            </div>
          </div>

          <% if (relatedTrials.isEmpty()) { %>
            <div class="disease-related-empty">
              <strong>현재 표시할 국내 관련 임상시험이 없습니다.</strong>
              <span><%= relatedTrialApiAvailable
                      ? "해외 포함 전체 검색에서 추가 연구를 확인할 수 있습니다."
                      : "외부 임상시험 API 연결 상태를 확인해주세요." %></span>
            </div>
          <% } else { %>
            <div class="disease-related-trial-list">
              <% for (TrialVO trial : relatedTrials) { %>
                <a class="disease-related-trial-card <%= isCris(trial) ? "is-cris" : "" %>"
                   href="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>">
                  <div class="disease-related-trial-top">
                    <div class="disease-related-trial-title-wrap">
                      <div class="disease-related-trial-source"><%= h(trial.getNctId()) %> · <%= h(sourceLabel(trial)) %></div>
                      <h3><%= h(trial.getTitle()) %></h3>
                    </div>
                    <span class="badge <%= statusClass(trial.getRecruitmentStatus()) %>"><%= h(statusLabel(trial.getRecruitmentStatus())) %></span>
                  </div>
                  <div class="disease-related-trial-meta">
                    <span class="badge badge-blue"><%= h(phaseLabel(trial.getPhase())) %></span>
                    <% if (trial.getInstitutionName() != null && !trial.getInstitutionName().isBlank()) { %>
                      <span><%= h(trial.getInstitutionName()) %></span>
                    <% } %>
                    <% if (trial.getStartDateText() != null && !trial.getStartDateText().isBlank()) { %>
                      <span><%= h(trial.getStartDateText()) %><%= trial.getCompletionDateText() == null || trial.getCompletionDateText().isBlank() ? "" : " ~ " + h(trial.getCompletionDateText()) %></span>
                    <% } %>
                  </div>
                </a>
              <% } %>
            </div>
          <% } %>

          <div class="disease-related-actions">
            <a class="btn btn-light" href="<%= relatedSearchUrl %>">국내 관련 임상시험 전체 보기 →</a>
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
          <strong>질병관리청 CRIS</strong>
          <span>국내 한글 임상연구 및 치료·중재 연구 우선 조회</span>
        </div>
        <div class="disease-source-row">
          <strong>ClinicalTrials.gov</strong>
          <span>대한민국에서 수행되는 국제 등록 임상시험 보강</span>
        </div>
        <div class="disease-source-row">
          <strong>MedlinePlus</strong>
          <span>한국어 설명이 없는 질환의 영문 일반 설명 보조 자료</span>
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
