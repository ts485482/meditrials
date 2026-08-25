<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.inquiry.vo.TrialInquiryVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm"));
    }

    private String statusLabel(String status) {
        if ("ANSWERED".equals(status)) return "답변완료";
        if ("CLOSED".equals(status)) return "종료";
        return "답변대기";
    }

    private String statusClass(String status) {
        if ("ANSWERED".equals(status)) return "badge-green";
        if ("CLOSED".equals(status)) return "badge-gray";
        return "badge-amber";
    }
%>
<%
    List<TrialInquiryVO> inquiries = request.getAttribute("inquiries") instanceof List<?> list
            ? (List<TrialInquiryVO>) list : List.of();
    TrialInquiryVO selectedInquiry = request.getAttribute("selectedInquiry") instanceof TrialInquiryVO value
            ? value : null;
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
    String formError = request.getAttribute("formError") instanceof String value ? value : null;
    String businessError = request.getAttribute("businessError") instanceof String value ? value : null;
    String answerInput = request.getAttribute("answerInput") instanceof String value ? value : null;
    long waitingCount = request.getAttribute("waitingCount") instanceof Number value ? value.longValue() : 0L;
    long answeredCount = request.getAttribute("answeredCount") instanceof Number value ? value.longValue() : 0L;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>사업자 문의 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/inquiry.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head inquiry-page-head">
      <div>
        <h1>문의 관리</h1>
        <p class="text-muted">내 기관이 등록한 임상시험에 접수된 질문을 확인하고 답변할 수 있습니다. 실제 참여 요청은 ‘참여 관리’에서 별도로 처리합니다.</p>
      </div>
    </div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="inquiry-success"><%= h(pageNotice) %></div>
    <% } %>
    <% if (businessError != null && !businessError.isBlank()) { %>
      <div class="inquiry-error"><%= h(businessError) %></div>
    <% } %>

    <div class="business-inquiry-summary">
      <div class="business-inquiry-stat">
        <span>전체 문의</span>
        <strong><%= inquiries.size() %></strong>
      </div>
      <div class="business-inquiry-stat">
        <span>답변 대기</span>
        <strong><%= waitingCount %></strong>
      </div>
      <div class="business-inquiry-stat">
        <span>답변 완료</span>
        <strong><%= answeredCount %></strong>
      </div>
    </div>

    <% if (inquiries.isEmpty()) { %>
      <div class="empty-state inquiry-empty-state">
        <h3>접수된 문의가 없습니다.</h3>
        <p class="text-muted">사업자가 등록한 임상시험에 사용자가 문의를 남기면 이곳에 표시됩니다.</p>
      </div>
    <% } else { %>
      <div class="inquiry-history-layout business-inquiry-layout">
        <section class="inquiry-history-list" aria-label="사업자 문의 목록">
          <% for (TrialInquiryVO inquiry : inquiries) { %>
            <a
                class="inquiry-history-item <%= selectedInquiry != null && inquiry.getInquiryNo().equals(selectedInquiry.getInquiryNo()) ? "active" : "" %>"
                href="${pageContext.request.contextPath}/business/inquiries?inquiryNo=<%= inquiry.getInquiryNo() %>">
              <div class="inquiry-history-topline">
                <span class="inquiry-history-date"><%= formatDate(inquiry.getCreatedAt()) %></span>
                <span class="badge <%= statusClass(inquiry.getStatus()) %>"><%= statusLabel(inquiry.getStatus()) %></span>
              </div>
              <h3><%= h(inquiry.getTrialTitle()) %></h3>
              <p><%= h(inquiry.getMemberName()) %> · <%= h(inquiry.getSubject()) %></p>
            </a>
          <% } %>
        </section>

        <section class="inquiry-history-detail business-inquiry-detail">
          <% if (selectedInquiry != null) { %>
            <div class="inquiry-detail-header">
              <div>
                <span class="inquiry-kicker">문의 #<%= selectedInquiry.getInquiryNo() %></span>
                <h2><%= h(selectedInquiry.getSubject()) %></h2>
              </div>
              <span class="badge <%= statusClass(selectedInquiry.getStatus()) %>"><%= statusLabel(selectedInquiry.getStatus()) %></span>
            </div>

            <div class="business-inquiry-meta-grid">
              <div>
                <span>임상시험</span>
                <a href="${pageContext.request.contextPath}/trials/<%= selectedInquiry.getTrialNo() %>">
                  <strong><%= h(selectedInquiry.getTrialTitle()) %></strong>
                </a>
              </div>
              <div>
                <span>문의자</span>
                <strong><%= h(selectedInquiry.getMemberName()) %></strong>
                <% if (selectedInquiry.getMemberEmail() != null && !selectedInquiry.getMemberEmail().isBlank()) { %>
                  <small><%= h(selectedInquiry.getMemberEmail()) %></small>
                <% } %>
              </div>
              <div>
                <span>문의일</span>
                <strong><%= formatDate(selectedInquiry.getCreatedAt()) %></strong>
              </div>
              <div>
                <span>모집 상태</span>
                <strong><%= h(selectedInquiry.getRecruitmentStatus()) %></strong>
              </div>
            </div>

            <div class="inquiry-message-block">
              <h3>문의 내용</h3>
              <p><%= h(selectedInquiry.getQuestion()) %></p>
            </div>

            <% if (formError != null && !formError.isBlank()) { %>
              <div class="inquiry-error business-answer-error"><%= h(formError) %></div>
            <% } %>

            <% if (!"CLOSED".equals(selectedInquiry.getStatus())) { %>
              <form
                  class="business-answer-form"
                  method="post"
                  action="${pageContext.request.contextPath}/business/inquiries/<%= selectedInquiry.getInquiryNo() %>/answer">
                <div class="form-group">
                  <label class="form-label" for="answer">답변 작성 <span class="required-mark">*</span></label>
                  <textarea
                      class="form-control business-answer-textarea"
                      id="answer"
                      name="answer"
                      placeholder="참여 조건, 일정, 방문 기관 등에 대한 답변을 작성해주세요."
                      required><%= h(answerInput != null ? answerInput : selectedInquiry.getAnswer()) %></textarea>
                  <div class="field-help">답변을 저장하면 사용자 문의 내역의 상태가 ‘답변완료’로 변경됩니다.</div>
                </div>
                <div class="business-answer-actions">
                  <% if ("ANSWERED".equals(selectedInquiry.getStatus()) && selectedInquiry.getAnsweredAt() != null) { %>
                    <span class="business-answer-date">최근 답변 <%= formatDate(selectedInquiry.getAnsweredAt()) %></span>
                  <% } %>
                  <button class="btn btn-primary" type="submit">
                    <%= "ANSWERED".equals(selectedInquiry.getStatus()) ? "답변 수정" : "답변 등록" %>
                  </button>
                </div>
              </form>
            <% } else { %>
              <div class="inquiry-answer-block waiting">
                <h3>종료된 문의</h3>
                <p>종료 처리된 문의에는 추가 답변을 등록할 수 없습니다.</p>
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
