<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.inquiry.vo.TrialInquiryVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String statusLabel(TrialInquiryVO inquiry) {
        if (inquiry == null) return "상태 미확인";
        if ("ANSWERED".equals(inquiry.getStatus())) return "답변완료";
        if ("CLOSED".equals(inquiry.getStatus())) return "종료";
        if (inquiry.getBusinessNo() == null) return "외부시험 문의 기록";
        return "답변대기";
    }

    private String statusClass(TrialInquiryVO inquiry) {
        if (inquiry == null) return "badge-gray";
        if ("ANSWERED".equals(inquiry.getStatus())) return "badge-green";
        if ("CLOSED".equals(inquiry.getStatus())) return "badge-gray";
        if (inquiry.getBusinessNo() == null) return "badge-amber";
        return "badge-gray";
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm"));
    }
%>
<%
    List<TrialInquiryVO> inquiries = request.getAttribute("inquiries") instanceof List<?> list
            ? (List<TrialInquiryVO>) list : List.of();
    TrialInquiryVO selectedInquiry = request.getAttribute("selectedInquiry") instanceof TrialInquiryVO value
            ? value : null;
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>참여 문의 내역 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/inquiry.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head inquiry-page-head">
      <div>
        <h1>참여 문의 내역</h1>
        <p class="text-muted">내가 등록한 임상시험 참여 문의와 답변 상태를 확인할 수 있습니다.</p>
      </div>
      <a class="btn btn-primary" href="${pageContext.request.contextPath}/trials">임상시험 검색</a>
    </div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="inquiry-success"><%= h(pageNotice) %></div>
    <% } %>

    <% if (inquiries.isEmpty()) { %>
      <div class="empty-state inquiry-empty-state">
        <h3>등록한 참여 문의가 없습니다.</h3>
        <p class="text-muted">임상시험 상세 화면에서 참여 문의를 등록하면 이곳에서 확인할 수 있습니다.</p>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/trials">임상시험 찾아보기</a>
      </div>
    <% } else { %>
      <div class="inquiry-history-layout">
        <section class="inquiry-history-list" aria-label="참여 문의 목록">
          <% for (TrialInquiryVO inquiry : inquiries) { %>
            <a
                class="inquiry-history-item <%= selectedInquiry != null && inquiry.getInquiryNo().equals(selectedInquiry.getInquiryNo()) ? "active" : "" %>"
                href="${pageContext.request.contextPath}/mypage/inquiries?inquiryNo=<%= inquiry.getInquiryNo() %>">
              <div class="inquiry-history-topline">
                <span class="inquiry-history-date"><%= formatDate(inquiry.getCreatedAt()) %></span>
                <span class="badge <%= statusClass(inquiry) %>"><%= h(statusLabel(inquiry)) %></span>
              </div>
              <h3><%= h(inquiry.getTrialTitle()) %></h3>
              <p><%= h(inquiry.getSubject()) %></p>
            </a>
          <% } %>
        </section>

        <section class="inquiry-history-detail">
          <% if (selectedInquiry != null) { %>
            <div class="inquiry-detail-header">
              <div>
                <span class="inquiry-kicker">문의 #<%= selectedInquiry.getInquiryNo() %></span>
                <h2><%= h(selectedInquiry.getSubject()) %></h2>
              </div>
              <span class="badge <%= statusClass(selectedInquiry) %>"><%= h(statusLabel(selectedInquiry)) %></span>
            </div>

            <div class="inquiry-detail-meta">
              <div>
                <span>임상시험</span>
                <a href="${pageContext.request.contextPath}/trials/<%= selectedInquiry.getTrialNo() %>">
                  <strong><%= h(selectedInquiry.getTrialTitle()) %></strong>
                </a>
              </div>
              <div>
                <span>문의일</span>
                <strong><%= formatDate(selectedInquiry.getCreatedAt()) %></strong>
              </div>
              <% if (selectedInquiry.getInstitutionName() != null && !selectedInquiry.getInstitutionName().isBlank()) { %>
                <div>
                  <span>기관</span>
                  <strong><%= h(selectedInquiry.getInstitutionName()) %></strong>
                </div>
              <% } %>
            </div>

            <div class="inquiry-message-block">
              <h3>문의 내용</h3>
              <p><%= h(selectedInquiry.getQuestion()) %></p>
            </div>

            <div class="inquiry-answer-block <%= "ANSWERED".equals(selectedInquiry.getStatus()) ? "answered" : "waiting" %>">
              <h3>답변</h3>
              <% if ("ANSWERED".equals(selectedInquiry.getStatus())
                      && selectedInquiry.getAnswer() != null
                      && !selectedInquiry.getAnswer().isBlank()) { %>
                <p><%= h(selectedInquiry.getAnswer()) %></p>
                <% if (selectedInquiry.getAnsweredAt() != null) { %>
                  <div class="field-help">답변일 <%= formatDate(selectedInquiry.getAnsweredAt()) %></div>
                <% } %>
              <% } else if (selectedInquiry.getBusinessNo() == null) { %>
                <p>
                  이 임상시험은 외부 등록(CRIS/ClinicalTrials.gov) 데이터이므로 MediTrials 사업자 직접 답변 대상이 아닐 수 있습니다.
                  상세화면의 연구기관 및 공식 출처 연락정보를 함께 확인해주세요.
                </p>
              <% } else { %>
                <p>아직 사업자 답변이 등록되지 않았습니다.</p>
              <% } %>
            </div>
          <% } %>
        </section>
      </div>
    <% } %>
  </main>
</div>
</body>
</html>
