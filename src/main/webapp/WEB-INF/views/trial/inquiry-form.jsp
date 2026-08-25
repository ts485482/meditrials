<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="meditrials.meditrials.trial.vo.TrialVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
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
%>
<%
    TrialVO trial = request.getAttribute("trial") instanceof TrialVO value ? value : null;
    String subject = request.getAttribute("subject") instanceof String value ? value : "";
    String question = request.getAttribute("question") instanceof String value ? value : "";
    String formError = request.getAttribute("formError") instanceof String value ? value : null;
    boolean externalTrial = trial != null && trial.getBusinessNo() == null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>임상시험 문의 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/inquiry.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <h1>임상시험 문의</h1>
    </div>

    <div class="inquiry-form-card">
      <div class="inquiry-trial-summary">
        <div>
          <span class="inquiry-kicker">문의 대상 임상시험</span>
          <h2><%= trial == null ? "임상시험 정보 없음" : h(trial.getTitle()) %></h2>
          <% if (trial != null && trial.getInstitutionName() != null && !trial.getInstitutionName().isBlank()) { %>
            <p><%= h(trial.getInstitutionName()) %></p>
          <% } %>
        </div>
        <% if (trial != null) { %>
          <span class="badge <%= statusClass(trial.getRecruitmentStatus()) %>"><%= h(statusLabel(trial.getRecruitmentStatus())) %></span>
        <% } %>
      </div>

      <% if (externalTrial) { %>
        <div class="inquiry-info-notice">
          외부 등록 임상시험(CRIS/ClinicalTrials.gov)은 MediTrials 사업자에게 직접 전달되는 시험이 아닐 수 있습니다.
          문의 내역은 저장되며, 실제 참여 가능 여부와 연락은 상세화면의 연구기관·공식 출처 정보도 함께 확인해주세요.
        </div>
      <% } %>

      <% if (formError != null && !formError.isBlank()) { %>
        <div class="inquiry-error" role="alert"><%= h(formError) %></div>
      <% } %>

      <% if (trial != null) { %>
        <form method="post" action="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>/inquiries/new" class="inquiry-form">
          <div class="form-group">
            <label class="form-label" for="subject">문의 제목 <span class="required-mark">*</span></label>
            <input
                class="form-control"
                id="subject"
                name="subject"
                type="text"
                maxlength="200"
                required
                value="<%= h(subject) %>"
                placeholder="예: 참여 조건과 방문 일정이 궁금합니다.">
            <div class="field-help">200자 이내로 입력해주세요.</div>
          </div>

          <div class="form-group">
            <label class="form-label" for="question">문의 내용 <span class="required-mark">*</span></label>
            <textarea
                class="form-control inquiry-question"
                id="question"
                name="question"
                required
                placeholder="참여 조건, 일정, 방문 기관 등 궁금한 내용을 작성해주세요."><%= h(question) %></textarea>
          </div>

          <label class="inquiry-consent" for="privacyAgreed">
            <input id="privacyAgreed" name="privacyAgreed" type="checkbox" value="true" required>
            <span>개인정보 수집 및 문의 전달에 동의합니다. <strong>(필수)</strong></span>
          </label>

          <div class="inquiry-actions">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>">취소</a>
            <button class="btn btn-primary" type="submit">문의 등록</button>
          </div>
        </form>
      <% } %>
    </div>
  </main>
</div>
</body>
</html>
