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
        if ("APPLIED".equals(status)) return "검토대기";
        if ("APPROVED".equals(status)) return "참여승인";
        if ("PARTICIPATING".equals(status)) return "참여중";
        if ("COMPLETED".equals(status)) return "참여완료";
        if ("REJECTED".equals(status)) return "참여거절";
        if ("WITHDRAWN".equals(status)) return "요청취소";
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
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>참여 요청 내역 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/participation.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head participation-page-head">
      <div>
        <h1>참여 요청 내역</h1>
        <p class="text-muted">실제 임상시험 참여를 요청한 내역과 사업자 처리 상태를 확인할 수 있습니다.</p>
      </div>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/trials">임상시험 검색</a>
    </div>

    <% if (participationNotice != null && !participationNotice.isBlank()) { %>
      <div class="participation-success"><%= h(participationNotice) %></div>
    <% } %>
    <% if (participationError != null && !participationError.isBlank()) { %>
      <div class="participation-error"><%= h(participationError) %></div>
    <% } %>

    <% if (participations.isEmpty()) { %>
      <div class="empty-state participation-empty-state">
        <h3>참여 요청 내역이 없습니다.</h3>
        <p class="text-muted">MediTrials 사업자 임상시험 상세에서 ‘참여 요청’을 누르면 이곳에서 처리 상태를 확인할 수 있습니다.</p>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/trials">임상시험 찾아보기</a>
      </div>
    <% } else { %>
      <div class="participation-layout">
        <section class="participation-list" aria-label="참여 요청 목록">
          <% for (TrialParticipationVO participation : participations) { %>
            <a
                class="participation-item <%= selectedParticipation != null && participation.getParticipationNo().equals(selectedParticipation.getParticipationNo()) ? "active" : "" %>"
                href="${pageContext.request.contextPath}/mypage/participations?participationNo=<%= participation.getParticipationNo() %>">
              <div class="participation-item-topline">
                <span><%= formatDate(participation.getAppliedAt()) %></span>
                <span class="badge <%= statusClass(participation.getStatus()) %>"><%= statusLabel(participation.getStatus()) %></span>
              </div>
              <h3><%= h(participation.getTrialTitle()) %></h3>
              <p><%= h(participation.getBusinessOrgName() != null ? participation.getBusinessOrgName() : participation.getInstitutionName()) %></p>
            </a>
          <% } %>
        </section>

        <section class="participation-detail">
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
                <span>임상시험</span>
                <a href="${pageContext.request.contextPath}/trials/<%= selectedParticipation.getTrialNo() %>"><strong><%= h(selectedParticipation.getTrialTitle()) %></strong></a>
              </div>
              <div>
                <span>기관</span>
                <strong><%= h(selectedParticipation.getBusinessOrgName() != null ? selectedParticipation.getBusinessOrgName() : selectedParticipation.getInstitutionName()) %></strong>
              </div>
              <div>
                <span>요청일</span>
                <strong><%= formatDate(selectedParticipation.getAppliedAt()) %></strong>
              </div>
              <div>
                <span>승인일</span>
                <strong><%= formatDate(selectedParticipation.getApprovedAt()) %></strong>
              </div>
              <div>
                <span>참여 시작일</span>
                <strong><%= formatDate(selectedParticipation.getStartedAt()) %></strong>
              </div>
              <div>
                <span>참여 완료일</span>
                <strong><%= formatDate(selectedParticipation.getCompletedAt()) %></strong>
              </div>
            </div>

            <div class="participation-state-box <%= statusClass(selectedParticipation.getStatus()) %>">
              <% if ("APPLIED".equals(selectedParticipation.getStatus())) { %>
                <h3>사업자 검토 대기 중입니다.</h3>
                <p>사업자가 참여 가능 여부를 확인한 뒤 승인 또는 거절합니다. 문의가 필요한 경우 별도의 ‘문의하기’ 기능을 이용해주세요.</p>
              <% } else if ("APPROVED".equals(selectedParticipation.getStatus())) { %>
                <h3>참여 요청이 승인되었습니다.</h3>
                <p>실제 방문 일정과 세부 절차는 해당 기관의 안내를 확인해주세요.</p>
              <% } else if ("PARTICIPATING".equals(selectedParticipation.getStatus())) { %>
                <h3>현재 임상시험에 참여 중입니다.</h3>
                <p>기관 안내에 따라 참여 일정을 진행해주세요.</p>
              <% } else if ("COMPLETED".equals(selectedParticipation.getStatus())) { %>
                <h3>참여가 완료되었습니다.</h3>
                <p>해당 임상시험의 참여 상태가 완료로 처리되었습니다.</p>
              <% } else if ("REJECTED".equals(selectedParticipation.getStatus())) { %>
                <h3>참여 요청이 승인되지 않았습니다.</h3>
                <p>현재 모집 중인 시험이라면 상세 화면에서 다시 참여 요청할 수 있습니다.</p>
              <% } else { %>
                <h3>참여 요청이 취소되었습니다.</h3>
                <p>현재 모집 중인 시험이라면 상세 화면에서 다시 참여 요청할 수 있습니다.</p>
              <% } %>
            </div>

            <% if ("APPLIED".equals(selectedParticipation.getStatus())) { %>
              <form
                  class="participation-actions"
                  method="post"
                  action="${pageContext.request.contextPath}/mypage/participations/<%= selectedParticipation.getParticipationNo() %>/withdraw"
                  onsubmit="return confirm('참여 요청을 취소하시겠습니까?');">
                <button class="btn btn-outline" type="submit">참여 요청 취소</button>
              </form>
            <% } %>
          <% } %>
        </section>
      </div>
    <% } %>
  </main>
</div>
</body>
</html>
