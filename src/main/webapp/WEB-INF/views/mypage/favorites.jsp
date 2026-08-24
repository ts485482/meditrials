<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.disease.vo.DiseaseVO" %>
<%@ page import="meditrials.meditrials.trial.vo.TrialVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
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
%>
<%
    List<DiseaseVO> favoriteDiseases = request.getAttribute("favoriteDiseases") instanceof List<?> list
            ? (List<DiseaseVO>) list : List.of();
    List<TrialVO> favoriteTrials = request.getAttribute("favoriteTrials") instanceof List<?> list
            ? (List<TrialVO>) list : List.of();
    String selectedTab = request.getAttribute("selectedTab") instanceof String value ? value : "diseases";
    boolean trialTab = "trials".equals(selectedTab);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>관심 목록 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <h1>관심 목록</h1>
    </div>

    <div class="tabs">
      <a class="tab <%= trialTab ? "" : "active" %>" href="${pageContext.request.contextPath}/mypage/favorites?tab=diseases">
        관심 질환 <%= favoriteDiseases.size() %>
      </a>
      <a class="tab <%= trialTab ? "active" : "" %>" href="${pageContext.request.contextPath}/mypage/favorites?tab=trials">
        관심 임상시험 <%= favoriteTrials.size() %>
      </a>
    </div>

    <% if (!trialTab) { %>
      <% if (favoriteDiseases.isEmpty()) { %>
        <div class="empty-state">
          <h3>등록한 관심 질환이 없습니다.</h3>
          <p class="text-muted">질환 상세 화면에서 관심 질환을 등록하면 이곳에서 확인할 수 있습니다.</p>
          <a class="btn btn-primary" href="${pageContext.request.contextPath}/diseases">질환정보 보기</a>
        </div>
      <% } else { %>
        <div class="favorite-card-grid">
          <% for (DiseaseVO disease : favoriteDiseases) { %>
            <div class="favorite-card">
              <div>
                <a href="${pageContext.request.contextPath}/diseases/<%= disease.getDiseaseNo() %>">
                  <h3><%= h(disease.getDiseaseName()) %></h3>
                </a>
                <% if (disease.getEnglishName() != null && !disease.getEnglishName().isBlank()) { %>
                  <p class="text-muted"><%= h(disease.getEnglishName()) %></p>
                <% } %>
                <p class="text-muted"><%= h(disease.getCategory()) %></p>
              </div>
              <form method="post" action="${pageContext.request.contextPath}/mypage/favorites/diseases/<%= disease.getDiseaseNo() %>">
                <input type="hidden" name="returnTo" value="list">
                <button class="btn btn-outline" type="submit" title="관심 질환 해제">♥ 해제</button>
              </form>
            </div>
          <% } %>
        </div>
      <% } %>
    <% } else { %>
      <% if (favoriteTrials.isEmpty()) { %>
        <div class="empty-state">
          <h3>등록한 관심 임상시험이 없습니다.</h3>
          <p class="text-muted">임상시험 상세 화면에서 관심 등록하면 이곳에서 확인할 수 있습니다.</p>
          <a class="btn btn-primary" href="${pageContext.request.contextPath}/trials">임상시험 검색</a>
        </div>
      <% } else { %>
        <div class="favorite-card-grid">
          <% for (TrialVO trial : favoriteTrials) { %>
            <div class="favorite-card">
              <div>
                <a href="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>">
                  <h3><%= h(trial.getTitle()) %></h3>
                </a>
                <p class="text-muted">
                  <%= h(phaseLabel(trial.getPhase())) %> · <%= h(statusLabel(trial.getRecruitmentStatus())) %>
                  <% if (trial.getInstitutionName() != null && !trial.getInstitutionName().isBlank()) { %>
                    <br><%= h(trial.getInstitutionName()) %>
                  <% } %>
                </p>
              </div>
              <form method="post" action="${pageContext.request.contextPath}/mypage/favorites/trials/<%= trial.getTrialNo() %>">
                <input type="hidden" name="returnTo" value="list">
                <button class="btn btn-outline" type="submit" title="관심 임상시험 해제">♥ 해제</button>
              </form>
            </div>
          <% } %>
        </div>
      <% } %>
    <% } %>
  </main>
</div>
</body>
</html>
