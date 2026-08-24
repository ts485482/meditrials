<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="meditrials.meditrials.business.vo.BusinessVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String orgTypeLabel(String value) {
        if ("HOSPITAL".equals(value)) return "병원";
        if ("PHARMA".equals(value)) return "제약사";
        if ("RESEARCH".equals(value)) return "연구기관";
        if ("CRO".equals(value)) return "CRO";
        if ("OTHER".equals(value)) return "기타";
        return value == null ? "-" : value;
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

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm"));
    }
%>
<%
    BusinessVO business = request.getAttribute("business") instanceof BusinessVO value ? value : null;
    String successMessage = request.getAttribute("successMessage") instanceof String value ? value : null;
    String errorMessage = request.getAttribute("errorMessage") instanceof String value ? value : null;
    String flashError = request.getAttribute("profileError") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>기관정보 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/business-profile.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>

  <main class="dashboard-main">
    <div class="dashboard-head business-profile-head">
      <div>
        <h1>기관정보 관리</h1>
        <p class="text-muted">관리자 승인에 사용된 기관 기본정보와 사용자에게 표시할 연락처를 관리합니다.</p>
      </div>
      <% if (business != null) { %>
        <span class="badge <%= approvalClass(business.getApprovalStatus()) %>"><%= h(approvalLabel(business.getApprovalStatus())) %></span>
      <% } %>
    </div>

    <% if (successMessage != null) { %>
      <div class="profile-message profile-message-success"><%= h(successMessage) %></div>
    <% } %>
    <% if (errorMessage != null || flashError != null) { %>
      <div class="profile-message profile-message-error"><%= h(errorMessage != null ? errorMessage : flashError) %></div>
    <% } %>

    <% if (business == null) { %>
      <div class="notice">로그인 계정에 연결된 기관 정보를 찾을 수 없습니다.</div>
    <% } else { %>
      <% if ("REJECTED".equals(business.getApprovalStatus())) { %>
        <div class="notice profile-reject-notice">
          <strong>사업자 승인 신청이 반려된 상태입니다.</strong><br>
          반려 사유: <%= business.getRejectReason() == null ? "관리자에게 문의해주세요." : h(business.getRejectReason()) %>
        </div>
      <% } %>

      <section class="profile-card">
        <div class="profile-card-title">
          <div>
            <h2>기관 기본정보</h2>
            <p>기관 식별 및 관리자 승인에 사용되는 정보입니다.</p>
          </div>
        </div>

        <div class="profile-readonly-grid">
          <div class="profile-readonly-item">
            <span>기관명</span>
            <strong><%= h(business.getOrgName()) %></strong>
          </div>
          <div class="profile-readonly-item">
            <span>기관 유형</span>
            <strong><%= h(orgTypeLabel(business.getOrgType())) %></strong>
          </div>
          <div class="profile-readonly-item">
            <span>사업자등록번호</span>
            <strong><%= h(business.getBusinessRegNo()) %></strong>
          </div>
          <div class="profile-readonly-item">
            <span>가입 상태</span>
            <strong><%= h(approvalLabel(business.getApprovalStatus())) %></strong>
          </div>
          <div class="profile-readonly-item profile-readonly-wide">
            <span>승인 일시</span>
            <strong><%= h(formatDate(business.getApprovedAt())) %></strong>
          </div>
        </div>

        <div class="notice profile-core-guide">
          기관명, 기관 유형, 사업자등록번호는 승인 기준이 되는 정보이므로 이 화면에서 변경하지 않습니다.
          변경이 필요한 경우 관리자에게 문의해주세요.
        </div>
      </section>

      <section class="profile-card">
        <div class="profile-card-title">
          <div>
            <h2>기관 연락정보</h2>
            <p>임상시험 상세와 관리자 확인에 사용할 기관 연락정보를 입력해주세요.</p>
          </div>
        </div>

        <form action="${pageContext.request.contextPath}/business/profile" method="post" class="profile-form">
          <div class="profile-form-grid">
            <div class="form-group">
              <label class="form-label" for="orgPhone">기관 연락처 <span class="profile-required">*</span></label>
              <input class="form-control" id="orgPhone" name="orgPhone" type="text"
                     maxlength="30" value="<%= h(business.getPhone()) %>" required>
              <small>예: 02-1234-5678</small>
            </div>

            <div class="form-group">
              <label class="form-label" for="orgEmail">기관 이메일 <span class="profile-required">*</span></label>
              <input class="form-control" id="orgEmail" name="orgEmail" type="email"
                     maxlength="200" value="<%= h(business.getEmail()) %>" required>
              <small>로그인 이메일과 별도로 기관 연락용 이메일로 사용할 수 있습니다.</small>
            </div>

            <div class="form-group profile-form-wide">
              <label class="form-label" for="address">기관 주소</label>
              <input class="form-control" id="address" name="address" type="text"
                     maxlength="500" value="<%= h(business.getAddress()) %>"
                     placeholder="기관 주소를 입력해주세요.">
            </div>

            <div class="form-group profile-form-wide">
              <label class="form-label" for="description">기관 소개</label>
              <textarea class="form-control" id="description" name="description" maxlength="1000"
                        placeholder="기관의 연구 분야, 주요 진료/연구 영역 등을 입력해주세요."><%= h(business.getDescription()) %></textarea>
              <div class="profile-help">최대 1000자</div>
            </div>
          </div>

          <div class="profile-actions">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/business">대시보드로</a>
            <button class="btn btn-primary" type="submit">기관정보 저장</button>
          </div>
        </form>
      </section>
    <% } %>
  </main>
</div>
</body>
</html>
