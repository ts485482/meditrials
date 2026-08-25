<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.business.trial.vo.BusinessTrialVO" %>
<%@ page import="meditrials.meditrials.business.vo.BusinessVO" %>
<%@ page import="meditrials.meditrials.participation.vo.TrialParticipationVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String approvalLabel(String value) {
        if ("APPROVED".equals(value)) return "승인 완료";
        if ("REJECTED".equals(value)) return "반려";
        return "승인 대기";
    }

    private String approvalClass(String value) {
        if ("APPROVED".equals(value)) return "badge-green";
        if ("REJECTED".equals(value)) return "badge-red";
        return "badge-amber";
    }

    private String reviewLabel(String value) {
        if ("DRAFT".equals(value)) return "임시저장";
        if ("PENDING".equals(value)) return "검수대기";
        if ("APPROVED".equals(value)) return "승인";
        if ("REJECTED".equals(value)) return "반려";
        return value == null ? "-" : value;
    }

    private String participationStatusLabel(String value) {
        if ("APPLIED".equals(value)) return "승인대기";
        if ("APPROVED".equals(value)) return "참여승인";
        if ("PARTICIPATING".equals(value)) return "참여중";
        if ("COMPLETED".equals(value)) return "참여완료";
        if ("REJECTED".equals(value)) return "거절";
        if ("WITHDRAWN".equals(value)) return "요청취소";
        return value == null ? "-" : value;
    }

    private String participationStatusClass(String value) {
        if ("APPROVED".equals(value) || "PARTICIPATING".equals(value) || "COMPLETED".equals(value)) return "badge-green";
        if ("REJECTED".equals(value)) return "badge-red";
        if ("APPLIED".equals(value)) return "badge-amber";
        return "badge-gray";
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("MM.dd"));
    }
%>
<%
    BusinessVO business = request.getAttribute("business") instanceof BusinessVO value ? value : null;
    List<BusinessTrialVO> trials = request.getAttribute("trials") instanceof List<?> list
            ? (List<BusinessTrialVO>) list : List.of();
    List<TrialParticipationVO> recentParticipations = request.getAttribute("recentParticipations") instanceof List<?> list
            ? (List<TrialParticipationVO>) list : List.of();
    Number pendingCount = request.getAttribute("pendingCount") instanceof Number value ? value : 0;
    Number approvedCount = request.getAttribute("approvedCount") instanceof Number value ? value : 0;
    Number rejectedCount = request.getAttribute("rejectedCount") instanceof Number value ? value : 0;
    Number pendingParticipationCount = request.getAttribute("pendingParticipationCount") instanceof Number value ? value : 0;
    Number activeParticipationCount = request.getAttribute("activeParticipationCount") instanceof Number value ? value : 0;
    boolean canManageTrials = Boolean.TRUE.equals(request.getAttribute("canManageTrials"));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>사업자 대시보드 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>사업자 대시보드</h1>
        <% if (business != null) { %>
          <p class="text-muted" style="margin:8px 0 0;"><%= h(business.getOrgName()) %></p>
        <% } %>
      </div>
      <% if (business != null) { %>
        <span class="badge <%= approvalClass(business.getApprovalStatus()) %>"><%= h(approvalLabel(business.getApprovalStatus())) %></span>
      <% } %>
    </div>

    <% if (business == null) { %>
      <div class="notice" style="margin-bottom:20px;">로그인 계정에 연결된 기관 정보를 찾을 수 없습니다.</div>
    <% } else if (!canManageTrials) { %>
      <div class="notice" style="margin-bottom:20px;">
        <% if ("REJECTED".equals(business.getApprovalStatus())) { %>
          <strong>사업자 가입 신청이 반려되었습니다.</strong><br>
          반려 사유: <%= business.getRejectReason() == null ? "관리자에게 문의해주세요." : h(business.getRejectReason()) %><br>
          현재는 임상시험 등록·수정·검수 요청 기능을 사용할 수 없습니다.
        <% } else { %>
          <strong>현재 관리자 승인 대기 중입니다.</strong><br>
          로그인과 사업자 센터 확인은 가능하지만 임상시험 등록·수정·검수 요청은 승인 완료 후 활성화됩니다.
        <% } %>
      </div>
    <% } %>

    <div class="stat-grid six">
      <div class="stat-card"><span>전체 임상시험</span><strong><%= trials.size() %></strong></div>
      <div class="stat-card"><span>검수 대기</span><strong><%= pendingCount.longValue() %></strong></div>
      <div class="stat-card"><span>승인 완료</span><strong><%= approvedCount.longValue() %></strong></div>
      <div class="stat-card"><span>반려</span><strong><%= rejectedCount.longValue() %></strong></div>
      <a class="stat-card" style="text-decoration:none;color:inherit;" href="${pageContext.request.contextPath}/business/participations">
        <span>참여 승인대기</span><strong><%= pendingParticipationCount.longValue() %></strong>
      </a>
      <a class="stat-card" style="text-decoration:none;color:inherit;" href="${pageContext.request.contextPath}/business/participations">
        <span>진행 중 참여</span><strong><%= activeParticipationCount.longValue() %></strong>
      </a>
    </div>

    <div class="content-grid-2">
      <div class="table-card">
        <div class="row-between" style="padding:20px 22px 0;">
          <h3 style="padding:0;">최근 임상시험</h3>
          <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/business/trials">전체 보기</a>
        </div>
        <table class="table">
          <thead>
            <tr><th>제목</th><th>검수상태</th><th>등록일</th><th>관리</th></tr>
          </thead>
          <tbody>
          <% if (trials.isEmpty()) { %>
            <tr><td colspan="4" class="text-center text-muted">등록한 임상시험이 없습니다.</td></tr>
          <% } else { %>
            <% for (int i = 0; i < Math.min(5, trials.size()); i++) { BusinessTrialVO trial = trials.get(i); %>
              <tr>
                <td><%= h(trial.getTitle()) %></td>
                <td><%= h(reviewLabel(trial.getReviewStatus())) %></td>
                <td><%= formatDate(trial.getCreatedAt()) %></td>
                <td>
                  <% if (canManageTrials) { %>
                    <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/business/trials/<%= trial.getTrialNo() %>/edit">수정</a>
                  <% } else { %>
                    <span class="text-muted">승인 후 이용</span>
                  <% } %>
                </td>
              </tr>
            <% } %>
          <% } %>
          </tbody>
        </table>
      </div>

      <div class="table-card">
        <div class="row-between" style="padding:20px 22px 0;">
          <h3 style="padding:0;">최근 참여 요청</h3>
          <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/business/participations">전체 보기</a>
        </div>
        <table class="table">
          <thead>
            <tr><th>임상시험</th><th>신청자</th><th>상태</th><th>요청일</th></tr>
          </thead>
          <tbody>
          <% if (recentParticipations.isEmpty()) { %>
            <tr><td colspan="4" class="text-center text-muted">접수된 참여 요청이 없습니다.</td></tr>
          <% } else { %>
            <% for (TrialParticipationVO participation : recentParticipations) { %>
              <tr>
                <td>
                  <a href="${pageContext.request.contextPath}/business/participations?participationNo=<%= participation.getParticipationNo() %>">
                    <%= h(participation.getTrialTitle()) %>
                  </a>
                </td>
                <td><%= h(participation.getMemberName()) %></td>
                <td><span class="badge <%= participationStatusClass(participation.getStatus()) %>"><%= h(participationStatusLabel(participation.getStatus())) %></span></td>
                <td><%= formatDate(participation.getAppliedAt()) %></td>
              </tr>
            <% } %>
          <% } %>
          </tbody>
        </table>
      </div>
    </div>
  </main>
</div>
</body>
</html>
