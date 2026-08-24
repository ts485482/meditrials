<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
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

    private boolean isBusinessTrial(TrialVO trial) {
        return trial != null && "BUSINESS".equalsIgnoreCase(trial.getSourceType());
    }

    private String sourceLabel(TrialVO trial) {
        if (isBusinessTrial(trial)) return "MediTrials 사업자 등록";
        return isCris(trial) ? "CRIS" : "ClinicalTrials.gov";
    }

    private String sourceId(TrialVO trial) {
        if (isBusinessTrial(trial)) return trial.getTrialNo() == null ? "MediTrials" : "MT-" + trial.getTrialNo();
        return trial == null || trial.getNctId() == null ? "" : trial.getNctId();
    }

    private String statusLabel(String value) {
        if (value == null) return "상태 미확인";
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
    List<TrialVO> trials = request.getAttribute("trials") instanceof List<?> list
            ? (List<TrialVO>) list : List.of();
    String keyword = request.getAttribute("keyword") instanceof String value ? value : "";
    String selectedStatus = request.getAttribute("selectedStatus") instanceof String value ? value : "ALL";
    String selectedPhase = request.getAttribute("selectedPhase") instanceof String value ? value : "ALL";
    String selectedScope = request.getAttribute("selectedScope") instanceof String value ? value : "DOMESTIC";
    Integer apiTotalCount = request.getAttribute("apiTotalCount") instanceof Integer value ? value : null;
    Integer crisTotalCount = request.getAttribute("crisTotalCount") instanceof Integer value ? value : null;
    Integer clinicalTrialsTotalCount = request.getAttribute("clinicalTrialsTotalCount") instanceof Integer value ? value : null;
    boolean apiAvailable = !(request.getAttribute("apiAvailable") instanceof Boolean value) || value;
    boolean crisAvailable = !(request.getAttribute("crisAvailable") instanceof Boolean value) || value;
    String apiNotice = request.getAttribute("apiNotice") instanceof String value ? value : "";
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : "";
    boolean domesticScope = "DOMESTIC".equals(selectedScope);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>임상시험 검색 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/trial.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section trial-page">
  <div class="mt-container">
    <div class="row-between trial-title-row">
      <div>
        <h1 class="section-title mb-10">임상시험 검색</h1>
        <p class="trial-subtitle">
          <%= domesticScope
                  ? "국내에서 수행되는 임상연구를 우선 조회하고 한글 등록정보를 중심으로 표시합니다."
                  : "난치성·치료 미충족 질환을 중심으로 ClinicalTrials.gov의 전 세계 임상시험을 검색합니다." %>
        </p>
      </div>
      <div class="trial-source-badges">
        <% if (domesticScope) { %>
          <span class="badge <%= crisAvailable ? "badge-cris" : "badge-amber" %>">CRIS 국내</span>
          <span class="badge badge-green">ClinicalTrials.gov 한국</span>
        <% } else { %>
          <span class="badge <%= apiAvailable ? "badge-green" : "badge-amber" %>">ClinicalTrials.gov 전체</span>
        <% } %>
      </div>
    </div>

    <% if (!pageNotice.isBlank()) { %>
      <div class="notice trial-notice"><%= h(pageNotice) %></div>
    <% } %>

    <form class="search-panel trial-search-panel" method="get" action="${pageContext.request.contextPath}/trials">
      <div class="filter-row">
        <div class="filter-item trial-keyword-item">
          <label for="trialKeyword">질환명 또는 임상시험명</label>
          <input id="trialKeyword" name="keyword" class="form-control" value="<%= h(keyword) %>" placeholder="예: 파킨슨병, 알츠하이머병">
        </div>
        <div class="filter-item">
          <label for="trialScope">조회 범위</label>
          <select id="trialScope" name="scope" class="form-control">
            <option value="DOMESTIC" <%= "DOMESTIC".equals(selectedScope) ? "selected" : "" %>>국내 임상시험</option>
            <option value="GLOBAL" <%= "GLOBAL".equals(selectedScope) ? "selected" : "" %>>해외 포함 전체</option>
          </select>
        </div>
        <div class="filter-item">
          <label for="trialStatus">모집 상태</label>
          <select id="trialStatus" name="status" class="form-control">
            <option value="ALL" <%= "ALL".equals(selectedStatus) ? "selected" : "" %>>전체</option>
            <option value="RECRUITING" <%= "RECRUITING".equals(selectedStatus) ? "selected" : "" %>>모집중</option>
            <option value="NOT_YET_RECRUITING" <%= "NOT_YET_RECRUITING".equals(selectedStatus) ? "selected" : "" %>>모집예정</option>
            <option value="COMPLETED" <%= "COMPLETED".equals(selectedStatus) ? "selected" : "" %>>완료</option>
          </select>
        </div>
        <div class="filter-item">
          <label for="trialPhase">임상 단계</label>
          <select id="trialPhase" name="phase" class="form-control">
            <option value="ALL" <%= "ALL".equals(selectedPhase) ? "selected" : "" %>>전체</option>
            <option value="PHASE1" <%= "PHASE1".equals(selectedPhase) ? "selected" : "" %>>1상</option>
            <option value="PHASE1_2" <%= "PHASE1_2".equals(selectedPhase) ? "selected" : "" %>>1/2상</option>
            <option value="PHASE2" <%= "PHASE2".equals(selectedPhase) ? "selected" : "" %>>2상</option>
            <option value="PHASE2_3" <%= "PHASE2_3".equals(selectedPhase) ? "selected" : "" %>>2/3상</option>
            <option value="PHASE3" <%= "PHASE3".equals(selectedPhase) ? "selected" : "" %>>3상</option>
          </select>
        </div>
        <button class="btn btn-primary" type="submit">검색하기</button>
      </div>
    </form>

    <% if (!apiNotice.isBlank()) { %>
      <div class="trial-api-notice <%= apiAvailable ? "ok" : "warn" %>"><%= h(apiNotice) %></div>
    <% } %>

    <div class="row-between trial-result-head">
      <h2>임상시험 검색 결과</h2>
      <div class="trial-result-count">
        현재 <strong><%= trials.size() %></strong>건 표시
        <% if (domesticScope) { %>
          <% if (crisTotalCount != null) { %><span>· CRIS <%= crisTotalCount %>건</span><% } %>
          <% if (clinicalTrialsTotalCount != null) { %><span>· ClinicalTrials.gov 한국 <%= clinicalTrialsTotalCount %>건</span><% } %>
        <% } else if (apiTotalCount != null) { %>
          <span>· ClinicalTrials.gov 전체 <%= apiTotalCount %>건</span>
        <% } %>
      </div>
    </div>

    <% if (trials.isEmpty()) { %>
      <div class="trial-empty">
        <strong>표시할 임상시험이 없습니다.</strong>
        <span>검색어 또는 필터 조건을 변경해보세요.</span>
      </div>
    <% } else { %>
      <div class="trial-result-list">
        <% for (TrialVO trial : trials) { %>
          <a class="result-card trial-result-card <%= isCris(trial) ? "trial-result-card-cris" : (isBusinessTrial(trial) ? "trial-result-card-business" : "") %>" href="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>">
            <div class="row-between trial-card-head">
              <div>
                <div class="trial-nct"><%= h(sourceId(trial)) %> · <%= h(sourceLabel(trial)) %></div>
                <h3><%= h(trial.getTitle()) %></h3>
                <% if (isCris(trial) && trial.getOfficialTitle() != null && !trial.getOfficialTitle().isBlank()) { %>
                  <div class="trial-card-english-title"><%= h(trial.getOfficialTitle()) %></div>
                <% } %>
              </div>
              <span class="badge <%= statusClass(trial.getRecruitmentStatus()) %>"><%= h(statusLabel(trial.getRecruitmentStatus())) %></span>
            </div>
            <div class="result-meta trial-card-meta">
              <span class="badge badge-blue"><%= h(phaseLabel(trial.getPhase())) %></span>
              <% if (trial.getConditionsText() != null && !trial.getConditionsText().isBlank()) { %>
                <span><%= h(trial.getConditionsText()) %></span>
              <% } %>
              <% if (trial.getStartDateText() != null || trial.getCompletionDateText() != null) { %>
                <span><%= h(trial.getStartDateText()) %> ~ <%= h(trial.getCompletionDateText()) %></span>
              <% } %>
              <% if (trial.getInstitutionName() != null && !trial.getInstitutionName().isBlank()) { %>
                <span><%= h(trial.getInstitutionName()) %><%= trial.getLocationCount() != null && trial.getLocationCount() > 1 ? " 외 " + (trial.getLocationCount() - 1) + "개 기관" : "" %></span>
              <% } %>
            </div>
          </a>
        <% } %>
      </div>
    <% } %>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
