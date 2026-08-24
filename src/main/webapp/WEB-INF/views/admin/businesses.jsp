<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
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

    private String statusLabel(String value) {
        if ("PENDING".equals(value)) return "승인대기";
        if ("APPROVED".equals(value)) return "승인";
        if ("REJECTED".equals(value)) return "반려";
        return value == null ? "-" : value;
    }

    private String statusClass(String value) {
        if ("APPROVED".equals(value)) return "badge-green";
        if ("REJECTED".equals(value)) return "badge-red";
        return "badge-amber";
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd"));
    }
%>
<%
    List<BusinessVO> businesses = request.getAttribute("businesses") instanceof List<?> list
            ? (List<BusinessVO>) list : List.of();
    BusinessVO selectedBusiness = request.getAttribute("selectedBusiness") instanceof BusinessVO value
            ? value : null;
    Number pendingValue = request.getAttribute("pendingCount") instanceof Number value ? value : 0;
    Number approvedValue = request.getAttribute("approvedCount") instanceof Number value ? value : 0;
    Number rejectedValue = request.getAttribute("rejectedCount") instanceof Number value ? value : 0;
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
    String pageError = request.getAttribute("pageError") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>사업자 승인 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>사업자 승인 관리</h1>
        <p class="text-muted">사업자 가입 신청 정보를 확인하고 승인 또는 반려합니다.</p>
      </div>
    </div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#e9fbf3;color:#18825e;border-color:#bfead8;"><%= h(pageNotice) %></div>
    <% } %>
    <% if (pageError != null && !pageError.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#fff1f2;color:#b93640;border-color:#f5cbd0;"><%= h(pageError) %></div>
    <% } %>

    <div class="stat-grid">
      <div class="stat-card"><span>전체 신청</span><strong><%= businesses.size() %></strong></div>
      <div class="stat-card"><span>승인 대기</span><strong><%= pendingValue.longValue() %></strong></div>
      <div class="stat-card"><span>승인 완료</span><strong><%= approvedValue.longValue() %></strong></div>
      <div class="stat-card"><span>반려</span><strong><%= rejectedValue.longValue() %></strong></div>
    </div>

    <div class="table-card">
      <table class="table">
        <thead>
          <tr>
            <th>번호</th>
            <th>기관명</th>
            <th>기관유형</th>
            <th>신청일</th>
            <th>상태</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
        <% if (businesses.isEmpty()) { %>
          <tr><td colspan="6" class="text-center text-muted">사업자 가입 신청 내역이 없습니다.</td></tr>
        <% } else { %>
          <% for (BusinessVO business : businesses) { %>
            <tr>
              <td><%= business.getBusinessNo() %></td>
              <td><strong><%= h(business.getOrgName()) %></strong></td>
              <td><%= h(orgTypeLabel(business.getOrgType())) %></td>
              <td><%= formatDate(business.getCreatedAt()) %></td>
              <td><span class="badge <%= statusClass(business.getApprovalStatus()) %>"><%= h(statusLabel(business.getApprovalStatus())) %></span></td>
              <td>
                <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/businesses?businessNo=<%= business.getBusinessNo() %>">상세</a>
              </td>
            </tr>
          <% } %>
        <% } %>
        </tbody>
      </table>
    </div>

    <% if (selectedBusiness != null) { %>
      <section class="card">
        <div class="row-between" style="align-items:flex-start;margin-bottom:18px;">
          <div>
            <h3 style="margin-bottom:6px;">사업자 상세</h3>
            <span class="badge <%= statusClass(selectedBusiness.getApprovalStatus()) %>"><%= h(statusLabel(selectedBusiness.getApprovalStatus())) %></span>
          </div>
          <span class="text-muted" style="font-size:13px;">신청일 <%= formatDate(selectedBusiness.getCreatedAt()) %></span>
        </div>

        <div class="content-grid-2">
          <p><strong>기관명</strong><br><%= h(selectedBusiness.getOrgName()) %></p>
          <p><strong>기관 유형</strong><br><%= h(orgTypeLabel(selectedBusiness.getOrgType())) %></p>
          <p><strong>사업자등록번호</strong><br><%= h(selectedBusiness.getBusinessRegNo()) %></p>
          <p><strong>기관 연락처</strong><br><%= h(selectedBusiness.getPhone()) %></p>
          <p><strong>기관 이메일</strong><br><%= h(selectedBusiness.getEmail()) %></p>
          <p><strong>주소</strong><br><%= selectedBusiness.getAddress() == null ? "-" : h(selectedBusiness.getAddress()) %></p>
        </div>

        <% if ("REJECTED".equals(selectedBusiness.getApprovalStatus())) { %>
          <div class="notice" style="margin-top:8px;background:#fff1f2;color:#b93640;border-color:#f5cbd0;">
            <strong>반려 사유</strong><br><%= h(selectedBusiness.getRejectReason()) %>
          </div>
        <% } %>

        <% if ("PENDING".equals(selectedBusiness.getApprovalStatus())) { %>
          <div style="display:grid;grid-template-columns:1fr auto;gap:18px;align-items:end;margin-top:22px;">
            <form action="${pageContext.request.contextPath}/admin/businesses/<%= selectedBusiness.getBusinessNo() %>/reject" method="post">
              <label class="form-label" for="rejectReason">반려 사유</label>
              <div class="form-inline">
                <input class="form-control" id="rejectReason" name="rejectReason" type="text"
                       maxlength="1000" placeholder="반려할 경우 사유를 입력해주세요.">
                <button class="btn btn-danger" type="submit" onclick="return confirm('이 사업자 신청을 반려하시겠습니까?');">반려</button>
              </div>
            </form>

            <form action="${pageContext.request.contextPath}/admin/businesses/<%= selectedBusiness.getBusinessNo() %>/approve" method="post">
              <button class="btn btn-primary" type="submit" onclick="return confirm('이 사업자를 승인하시겠습니까?');">승인</button>
            </form>
          </div>
        <% } %>
      </section>
    <% } %>
  </main>
</div>
</body>
</html>
