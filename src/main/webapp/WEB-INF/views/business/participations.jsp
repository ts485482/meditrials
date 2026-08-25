<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.participation.vo.TrialParticipationVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm"));
    }

    private String statusLabel(String status) {
        if ("APPLIED".equals(status)) return "승인대기";
        if ("APPROVED".equals(status)) return "참여승인";
        if ("PARTICIPATING".equals(status)) return "참여중";
        if ("COMPLETED".equals(status)) return "참여완료";
        if ("REJECTED".equals(status)) return "거절";
        if ("WITHDRAWN".equals(status)) return "사용자취소";
        return "상태 미확인";
    }

    private String statusClass(String status) {
        if ("APPROVED".equals(status) || "PARTICIPATING".equals(status) || "COMPLETED".equals(status)) return "badge-green";
        if ("APPLIED".equals(status)) return "badge-amber";
        if ("REJECTED".equals(status)) return "badge-red";
        return "badge-gray";
    }
%>
<%
    List<TrialParticipationVO> participations = request.getAttribute("participations") instanceof List<?> list
            ? (List<TrialParticipationVO>) list : List.of();
    TrialParticipationVO selectedParticipation = request.getAttribute("selectedParticipation") instanceof TrialParticipationVO value
            ? value : null;
    String participationNotice = request.getAttribute("participationNotice") instanceof String value ? value : null;
    String participationError = request.getAttribute("participationError") instanceof String value ? value : null;
    String businessError = request.getAttribute("businessError") instanceof String value ? value : null;
    long appliedCount = request.getAttribute("appliedCount") instanceof Number value ? value.longValue() : 0L;
    long approvedCount = request.getAttribute("approvedCount") instanceof Number value ? value.longValue() : 0L;
    long rejectedCount = request.getAttribute("rejectedCount") instanceof Number value ? value.longValue() : 0L;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>참여 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/participation.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head participation-page-head">
      <div>
        <h1>참여 관리</h1>
        <p class="text-muted">내 기관의 임상시험에 접수된 실제 참여 요청을 확인하고 승인 또는 거절합니다.</p>
      </div>
    </div>

    <% if (participationNotice != null && !participationNotice.isBlank()) { %>
      <div class="participation-success"><%= h(participationNotice) %></div>
    <% } %>
    <% if (participationError != null && !participationError.isBlank()) { %>
      <div class="participation-error"><%= h(participationError) %></div>
    <% } %>
    <% if (businessError != null && !businessError.isBlank()) { %>
      <div class="participation-error"><%= h(businessError) %></div>
    <% } %>

    <div class="participation-summary">
      <div class="participation-stat"><span>전체 요청</span><strong><%= participations.size() %></strong></div>
      <div class="participation-stat"><span>승인 대기</span><strong><%= appliedCount %></strong></div>
      <div class="participation-stat"><span>참여 승인</span><strong><%= approvedCount %></strong></div>
      <div class="participation-stat"><span>거절</span><strong><%= rejectedCount %></strong></div>
    </div>

    <% if (participations.isEmpty()) { %>
      <div class="empty-state participation-empty-state">
        <h3>접수된 참여 요청이 없습니다.</h3>
        <p class="text-muted">사용자가 사업자 임상시험 상세 화면에서 ‘참여 요청’을 누르면 이곳에 표시됩니다.</p>
      </div>
    <% } else { %>
      <div class="participation-layout business-participation-layout">
        <section class="participation-list" aria-label="사업자 참여 요청 목록">
          <% for (TrialParticipationVO participation : participations) { %>
            <a
                class="participation-item <%= selectedParticipation != null && participation.getParticipationNo().equals(selectedParticipation.getParticipationNo()) ? "active" : "" %>"
                href="${pageContext.request.contextPath}/business/participations?participationNo=<%= participation.getParticipationNo() %>">
              <div class="participation-item-topline">
                <span><%= formatDate(participation.getAppliedAt()) %></span>
                <span class="badge <%= statusClass(participation.getStatus()) %>"><%= statusLabel(participation.getStatus()) %></span>
              </div>
              <h3><%= h(participation.getTrialTitle()) %></h3>
              <p><%= h(participation.getMemberName()) %> · <%= h(participation.getMemberEmail()) %></p>
            </a>
          <% } %>
        </section>

        <section class="participation-detail business-participation-detail">
          <% if (selectedParticipation != null) { %>
            <div class="participation-detail-header">
              <div>
                <span class="participation-kicker">참여 요청 #<%= selectedParticipation.getParticipationNo() %></span>
                <h2><%= h(selectedParticipation.getTrialTitle()) %></h2>
              </div>
              <span class="badge <%= statusClass(selectedParticipation.getStatus()) %>"><%= statusLabel(selectedParticipation.getStatus()) %></span>
            </div>

            <div class="participation-meta-grid">
              <div>
                <span>신청자</span>
                <strong><%= h(selectedParticipation.getMemberName()) %></strong>
                <small><%= h(selectedParticipation.getMemberEmail()) %></small>
              </div>
              <div>
                <span>요청일</span>
                <strong><%= formatDate(selectedParticipation.getAppliedAt()) %></strong>
              </div>
              <div>
                <span>임상시험</span>
                <a href="${pageContext.request.contextPath}/trials/<%= selectedParticipation.getTrialNo() %>"><strong><%= h(selectedParticipation.getTrialTitle()) %></strong></a>
              </div>
              <div>
                <span>모집 상태</span>
                <strong><%= h(selectedParticipation.getRecruitmentStatus()) %></strong>
              </div>
              <div>
                <span>승인일</span>
                <strong><%= formatDate(selectedParticipation.getApprovedAt()) %></strong>
              </div>
            </div>

            <div class="participation-guide-box">
              <% if ("APPLIED".equals(selectedParticipation.getStatus())) { %>
                <h3>참여 가능 여부를 검토해주세요.</h3>
                <p>문의 답변과는 별개입니다. 실제 참여 요청을 승인하면 사업자 통계의 ‘참여확정’ 건수에 반영됩니다.</p>
              <% } else if ("APPROVED".equals(selectedParticipation.getStatus())) { %>
                <h3>참여 승인된 요청입니다.</h3>
                <p>사용자 참여 요청 내역에도 ‘참여승인’ 상태로 표시됩니다.</p>
              <% } else if ("REJECTED".equals(selectedParticipation.getStatus())) { %>
                <h3>거절 처리된 요청입니다.</h3>
                <p>현재 모집 중인 시험이라면 사용자가 다시 참여 요청할 수 있습니다.</p>
              <% } else { %>
                <h3>현재 상태: <%= statusLabel(selectedParticipation.getStatus()) %></h3>
                <p>이 요청은 현재 승인/거절 처리 대상이 아닙니다.</p>
              <% } %>
            </div>

            <% if ("APPLIED".equals(selectedParticipation.getStatus())) { %>
              <div class="business-participation-actions">
                <form method="post" action="${pageContext.request.contextPath}/business/participations/<%= selectedParticipation.getParticipationNo() %>/reject" onsubmit="return confirm('이 참여 요청을 거절하시겠습니까?');">
                  <button class="btn btn-outline" type="submit">거절</button>
                </form>
                <form method="post" action="${pageContext.request.contextPath}/business/participations/<%= selectedParticipation.getParticipationNo() %>/approve" onsubmit="return confirm('이 사용자의 참여 요청을 승인하시겠습니까?');">
                  <button class="btn btn-primary" type="submit">참여 승인</button>
                </form>
              </div>
            <% } %>
          <% } %>
        </section>
      </div>
    <% } %>
  </main>
</div>
</body>
</html>
