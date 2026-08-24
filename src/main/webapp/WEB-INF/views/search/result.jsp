<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.search.vo.IntegratedSearchVO" %>
<%@ page import="meditrials.meditrials.disease.vo.DiseaseVO" %>
<%@ page import="meditrials.meditrials.trial.vo.TrialVO" %>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
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

    private String trialSourceLabel(TrialVO trial) {
        if (trial == null) return "임상시험";
        if ("BUSINESS".equals(trial.getSourceType())) return "MediTrials 승인 시험";
        String id = trial.getNctId();
        if (id != null && id.toUpperCase().startsWith("KCT")) return "CRIS";
        return "ClinicalTrials.gov";
    }
%>
<%
    IntegratedSearchVO searchResult = request.getAttribute("searchResult") instanceof IntegratedSearchVO value
            ? value : new IntegratedSearchVO();
    String keyword = searchResult.getKeyword() == null ? "" : searchResult.getKeyword();
    String encodedKeyword = URLEncoder.encode(keyword, StandardCharsets.UTF_8);
    List<DiseaseVO> diseases = searchResult.getDiseases();
    List<TrialVO> trials = searchResult.getTrials();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>통합검색 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/search.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section integrated-search-page">
  <div class="mt-container">
    <div class="integrated-search-head">
      <h1 class="section-title">통합검색</h1>
      <p>질환정보와 국내 임상시험을 한 번에 검색합니다.</p>
    </div>

    <form class="integrated-search-form" action="${pageContext.request.contextPath}/search" method="get" role="search">
      <input type="search" name="keyword" maxlength="100" value="<%= h(keyword) %>" placeholder="질환명 또는 임상시험 키워드" aria-label="통합 검색어">
      <button type="submit" class="btn btn-primary">검색</button>
    </form>

    <% if (keyword.isBlank()) { %>
      <div class="search-empty-state">
        <strong>검색어를 입력해주세요.</strong>
        <span>질환명, 치료제, 임상시험명 등의 키워드로 검색할 수 있습니다.</span>
      </div>
    <% } else { %>
      <div class="search-summary-grid">
        <a class="search-summary-card" href="${pageContext.request.contextPath}/diseases?keyword=<%= encodedKeyword %>">
          <span>질환정보</span>
          <strong><%= searchResult.getDiseaseTotalCount() %>건</strong>
          <small>전체 질환 결과 보기 →</small>
        </a>
        <a class="search-summary-card" href="${pageContext.request.contextPath}/trials?keyword=<%= encodedKeyword %>&scope=DOMESTIC">
          <span>임상시험</span>
          <strong><%= searchResult.getTrialDisplayedCount() %>건</strong>
          <small>국내 임상시험 결과 보기 →</small>
        </a>
      </div>

      <section class="integrated-result-section">
        <div class="integrated-result-head row-between">
          <div>
            <h2>질환정보</h2>
            <p>“<%= h(keyword) %>”와 관련된 질환정보입니다.</p>
          </div>
          <a class="link-blue" href="${pageContext.request.contextPath}/diseases?keyword=<%= encodedKeyword %>">전체보기</a>
        </div>

        <% if (diseases == null || diseases.isEmpty()) { %>
          <div class="search-section-empty">검색된 질환정보가 없습니다.</div>
        <% } else { %>
          <div class="integrated-disease-grid">
            <% for (DiseaseVO disease : diseases) { %>
              <a class="integrated-disease-card" href="${pageContext.request.contextPath}/diseases/<%= disease.getDiseaseNo() %>">
                <div class="row-between">
                  <span class="badge badge-blue"><%= h(disease.getCategory() == null ? "질환정보" : disease.getCategory()) %></span>
                  <% if (disease.getRelatedTrialCount() != null) { %>
                    <small>관련 임상시험 <%= disease.getRelatedTrialCount() %>건</small>
                  <% } %>
                </div>
                <h3><%= h(disease.getDiseaseName()) %></h3>
                <% if (disease.getEnglishName() != null && !disease.getEnglishName().isBlank()) { %>
                  <p><%= h(disease.getEnglishName()) %></p>
                <% } %>
              </a>
            <% } %>
          </div>
        <% } %>
      </section>

      <section class="integrated-result-section">
        <div class="integrated-result-head row-between">
          <div>
            <h2>임상시험</h2>
            <p>관리자 승인 자체 임상시험과 국내 등록 연구를 함께 표시합니다.</p>
          </div>
          <a class="link-blue" href="${pageContext.request.contextPath}/trials?keyword=<%= encodedKeyword %>&scope=DOMESTIC">전체보기</a>
        </div>

        <% if (trials == null || trials.isEmpty()) { %>
          <div class="search-section-empty">검색된 임상시험이 없습니다.</div>
        <% } else { %>
          <div class="integrated-trial-list">
            <% for (TrialVO trial : trials) { %>
              <a class="integrated-trial-card" href="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>">
                <div class="integrated-trial-main">
                  <div class="integrated-trial-source"><%= h(trialSourceLabel(trial)) %><%= trial.getNctId() == null || trial.getNctId().isBlank() ? "" : " · " + h(trial.getNctId()) %></div>
                  <h3><%= h(trial.getTitle()) %></h3>
                  <div class="result-meta">
                    <span class="badge badge-blue"><%= h(phaseLabel(trial.getPhase())) %></span>
                    <% if (trial.getInstitutionName() != null && !trial.getInstitutionName().isBlank()) { %>
                      <span><%= h(trial.getInstitutionName()) %></span>
                    <% } %>
                    <% if (trial.getStartDateText() != null || trial.getCompletionDateText() != null) { %>
                      <span><%= h(trial.getStartDateText()) %> ~ <%= h(trial.getCompletionDateText()) %></span>
                    <% } %>
                  </div>
                </div>
                <div class="integrated-trial-badges">
                  <% if (trial.isPremiumPromoted()) { %>
                    <span class="badge badge-amber">★ PREMIUM</span>
                  <% } %>
                  <span class="badge <%= statusClass(trial.getRecruitmentStatus()) %>"><%= h(statusLabel(trial.getRecruitmentStatus())) %></span>
                </div>
              </a>
            <% } %>
          </div>
        <% } %>
      </section>
    <% } %>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
