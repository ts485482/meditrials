<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.business.trial.vo.BusinessTrialVO" %>
<%@ page import="meditrials.meditrials.business.vo.BusinessVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String phaseLabel(String value) {
        if (value == null || value.isBlank()) return "미지정";
        return switch (value) {
            case "PHASE1" -> "1상";
            case "PHASE1|PHASE2" -> "1/2상";
            case "PHASE2" -> "2상";
            case "PHASE2|PHASE3" -> "2/3상";
            case "PHASE3" -> "3상";
            case "PHASE4" -> "4상";
            default -> value;
        };
    }

    private String reviewLabel(String value) {
        if ("DRAFT".equals(value)) return "임시저장";
        if ("PENDING".equals(value)) return "검수대기";
        if ("APPROVED".equals(value)) return "승인";
        if ("REJECTED".equals(value)) return "반려";
        return value == null ? "미지정" : value;
    }

    private String reviewClass(String value) {
        if ("APPROVED".equals(value)) return "badge-green";
        if ("REJECTED".equals(value)) return "badge-red";
        if ("PENDING".equals(value)) return "badge-amber";
        return "badge-gray";
    }

    private String recruitmentLabel(String value) {
        if ("RECRUITING".equals(value)) return "모집중";
        if ("NOT_YET_RECRUITING".equals(value)) return "모집예정";
        if ("COMPLETED".equals(value)) return "모집완료";
        if ("ACTIVE_NOT_RECRUITING".equals(value)) return "진행중·모집종료";
        return value == null || value.isBlank() ? "미지정" : value;
    }

    private String recruitmentClass(String value) {
        if ("RECRUITING".equals(value)) return "badge-green";
        if ("NOT_YET_RECRUITING".equals(value)) return "badge-amber";
        return "badge-gray";
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd"));
    }
%>
<%
    List<BusinessTrialVO> trials = request.getAttribute("trials") instanceof List<?> list
            ? (List<BusinessTrialVO>) list : List.of();
    BusinessVO business = request.getAttribute("business") instanceof BusinessVO value ? value : null;
    boolean canManage = Boolean.TRUE.equals(request.getAttribute("canManage"));
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;

    long draftCount = trials.stream().filter(t -> "DRAFT".equals(t.getReviewStatus())).count();
    long pendingCount = trials.stream().filter(t -> "PENDING".equals(t.getReviewStatus())).count();
    long approvedCount = trials.stream().filter(t -> "APPROVED".equals(t.getReviewStatus())).count();
    long rejectedCount = trials.stream().filter(t -> "REJECTED".equals(t.getReviewStatus())).count();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>임상시험 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/business-trial.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>임상시험 관리</h1>
        <p class="text-muted">내 기관이 등록한 임상시험의 검수 상태와 모집 상태를 관리합니다.</p>
      </div>
      <% if (canManage) { %>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/business/trials/form">+ 임상시험 등록</a>
      <% } %>
    </div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="business-trial-notice"><%= h(pageNotice) %></div>
    <% } %>

    <% if (!canManage) { %>
      <div class="notice business-trial-approval-notice">
        현재 기관 상태: <strong><%= business == null ? "기관정보 없음" : h(business.getApprovalStatus()) %></strong><br>
        관리자 승인 완료(APPROVED) 후 임상시험 등록·수정과 검수 요청 기능을 사용할 수 있습니다.
      </div>
    <% } %>

    <div class="business-trial-summary">
      <div class="stat-card"><span>전체</span><strong><%= trials.size() %></strong></div>
      <div class="stat-card"><span>임시저장</span><strong><%= draftCount %></strong></div>
      <div class="stat-card"><span>검수대기</span><strong><%= pendingCount %></strong></div>
      <div class="stat-card"><span>승인</span><strong><%= approvedCount %></strong></div>
      <div class="stat-card"><span>반려</span><strong><%= rejectedCount %></strong></div>
    </div>

    <% if (trials.isEmpty()) { %>
      <div class="empty-state business-trial-empty">
        <h3>등록한 임상시험이 없습니다.</h3>
        <p class="text-muted">임상시험을 등록하고 검수 요청하면 관리자가 승인 후 사용자 검색에 공개합니다.</p>
        <% if (canManage) { %>
          <a class="btn btn-primary" href="${pageContext.request.contextPath}/business/trials/form">첫 임상시험 등록</a>
        <% } %>
      </div>
    <% } else { %>
      <div class="table-card business-trial-table-card">
        <table class="table business-trial-table">
          <thead>
            <tr>
              <th>번호</th>
              <th>임상시험 제목</th>
              <th>대상 질환</th>
              <th>단계</th>
              <th>검수</th>
              <th>모집</th>
              <th>등록일</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody>
          <% for (BusinessTrialVO trial : trials) { %>
            <tr>
              <td><%= trial.getTrialNo() %></td>
              <td class="business-trial-title-cell">
                <strong><%= h(trial.getTitle()) %></strong>
                <% if ("REJECTED".equals(trial.getReviewStatus()) && trial.getRejectReason() != null) { %>
                  <small class="business-trial-reject-reason">반려 사유: <%= h(trial.getRejectReason()) %></small>
                <% } %>
              </td>
              <td><%= h(trial.getDiseaseName()) %></td>
              <td><%= h(phaseLabel(trial.getPhase())) %></td>
              <td><span class="badge <%= reviewClass(trial.getReviewStatus()) %>"><%= h(reviewLabel(trial.getReviewStatus())) %></span></td>
              <td><span class="badge <%= recruitmentClass(trial.getRecruitmentStatus()) %>"><%= h(recruitmentLabel(trial.getRecruitmentStatus())) %></span></td>
              <td><%= formatDate(trial.getCreatedAt()) %></td>
              <td>
                <% if (canManage) { %>
                  <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/business/trials/<%= trial.getTrialNo() %>/edit">수정</a>
                <% } else { %>
                  <span class="text-muted">제한</span>
                <% } %>
              </td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>
    <% } %>
  </main>
</div>
</body>
</html>
