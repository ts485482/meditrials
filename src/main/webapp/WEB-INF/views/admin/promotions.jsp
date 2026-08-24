<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="meditrials.meditrials.admin.promotion.vo.AdminPromotionVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) { return value == null ? "" : HtmlUtils.htmlEscape(value); }
    private String date(LocalDateTime value) { return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd")); }
    private String statusLabel(String value) {
        if (value == null) return "-";
        return switch (value) {
            case "PENDING" -> "승인대기";
            case "ACTIVE" -> "활성";
            case "REJECTED" -> "반려";
            case "ENDED" -> "종료";
            default -> value;
        };
    }
    private String statusClass(String value) {
        if ("ACTIVE".equals(value)) return "badge-green";
        if ("PENDING".equals(value)) return "badge-amber";
        if ("REJECTED".equals(value)) return "badge-red";
        return "badge-gray";
    }
%>
<%
    List<AdminPromotionVO> promotions = request.getAttribute("promotions") instanceof List<?> list
            ? (List<AdminPromotionVO>) list : List.of();
    AdminPromotionVO selected = request.getAttribute("selectedPromotion") instanceof AdminPromotionVO value ? value : null;
    String selectedStatus = request.getAttribute("selectedStatus") instanceof String value ? value : "ALL";
    long pendingCount = request.getAttribute("pendingCount") instanceof Number value ? value.longValue() : 0;
    long activeCount = request.getAttribute("activeCount") instanceof Number value ? value.longValue() : 0;
    long closedCount = request.getAttribute("closedCount") instanceof Number value ? value.longValue() : 0;
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
    String pageError = request.getAttribute("pageError") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>프리미엄 노출 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head"><h1>프리미엄 노출 관리</h1></div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="notice" style="margin-bottom:16px;"><%= h(pageNotice) %></div>
    <% } %>
    <% if (pageError != null && !pageError.isBlank()) { %>
      <div class="notice" style="margin-bottom:16px;background:#fff1f1;color:#a23131;border-color:#f0caca;"><%= h(pageError) %></div>
    <% } %>

    <div class="stat-grid" style="grid-template-columns:repeat(3,minmax(0,1fr));margin-bottom:18px;">
      <div class="stat-card"><span>승인 대기</span><strong><%= pendingCount %>건</strong></div>
      <div class="stat-card"><span>현재 노출</span><strong><%= activeCount %>건</strong></div>
      <div class="stat-card"><span>반려/종료</span><strong><%= closedCount %>건</strong></div>
    </div>

    <form method="get" action="${pageContext.request.contextPath}/admin/promotions" style="margin-bottom:14px;display:flex;gap:8px;align-items:center;">
      <select class="form-control" name="status" style="max-width:190px;">
        <option value="ALL" <%= "ALL".equals(selectedStatus) ? "selected" : "" %>>전체</option>
        <option value="PENDING" <%= "PENDING".equals(selectedStatus) ? "selected" : "" %>>승인대기</option>
        <option value="ACTIVE" <%= "ACTIVE".equals(selectedStatus) ? "selected" : "" %>>활성</option>
        <option value="REJECTED" <%= "REJECTED".equals(selectedStatus) ? "selected" : "" %>>반려</option>
        <option value="ENDED" <%= "ENDED".equals(selectedStatus) ? "selected" : "" %>>종료</option>
      </select>
      <button class="btn btn-outline" type="submit">조회</button>
    </form>

    <div class="table-card">
      <table class="table">
        <thead><tr><th>번호</th><th>임상시험</th><th>기관</th><th>신청일</th><th>노출기간</th><th>상태</th><th>관리</th></tr></thead>
        <tbody>
        <% if (promotions.isEmpty()) { %>
          <tr><td colspan="7" style="text-align:center;padding:30px;">조회할 프리미엄 노출 신청이 없습니다.</td></tr>
        <% } else { %>
          <% for (AdminPromotionVO promotion : promotions) {
               LocalDateTime expectedEnd = promotion.getSubscriptionEndDate() != null
                       ? promotion.getSubscriptionEndDate() : promotion.getEndDate();
          %>
            <tr>
              <td><%= promotion.getPromotionNo() %></td>
              <td><strong><%= h(promotion.getTitle()) %></strong></td>
              <td><%= h(promotion.getOrgName()) %></td>
              <td><%= date(promotion.getCreatedAt()) %></td>
              <td>
                <% if ("ACTIVE".equals(promotion.getPromotionStatus())) { %>
                  <%= date(promotion.getStartDate()) %> ~ <%= expectedEnd == null ? "PREMIUM 이용 중" : date(expectedEnd) %>
                <% } else { %>-<% } %>
              </td>
              <td><span class="badge <%= statusClass(promotion.getPromotionStatus()) %>"><%= h(statusLabel(promotion.getPromotionStatus())) %></span></td>
              <td><a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/promotions?promotionNo=<%= promotion.getPromotionNo() %>&status=<%= selectedStatus %>">상세</a></td>
            </tr>
          <% } %>
        <% } %>
        </tbody>
      </table>
    </div>

    <section class="card" style="margin-top:18px;">
      <h3>노출 상세</h3>
      <% if (selected == null) { %>
        <p class="text-muted">확인할 프리미엄 노출 신청을 선택해주세요.</p>
      <% } else { %>
        <div class="content-grid-2">
          <p><strong>기관</strong><br><%= h(selected.getOrgName()) %></p>
          <p><strong>신청번호</strong><br>PROMO-<%= selected.getPromotionNo() %></p>
          <p><strong>임상시험</strong><br><%= h(selected.getTitle()) %></p>
          <p><strong>임상시험 번호</strong><br>MT-<%= selected.getTrialNo() %></p>
          <p><strong>노출 위치</strong><br>메인 추천 영역 / 임상시험 검색 상단</p>
          <p><strong>PREMIUM 상태</strong><br><%= h(selected.getSubscriptionStatus()) %></p>
          <p><strong>신청일</strong><br><%= date(selected.getCreatedAt()) %></p>
          <p><strong>노출 기간</strong><br>
            <% if ("ACTIVE".equals(selected.getPromotionStatus())) { %>
              <%= date(selected.getStartDate()) %> ~ <%= selected.getSubscriptionEndDate() == null ? "PREMIUM 이용 중" : date(selected.getSubscriptionEndDate()) %>
            <% } else { %>-<% } %>
          </p>
        </div>

        <% if (selected.getRejectReason() != null && !selected.getRejectReason().isBlank()) { %>
          <div class="notice" style="margin-top:12px;background:#fff8f8;color:#8c3838;border-color:#f0d1d1;">
            <strong>반려 사유</strong><br><%= h(selected.getRejectReason()) %>
          </div>
        <% } %>

        <% if ("PENDING".equals(selected.getPromotionStatus())) { %>
          <div class="divider"></div>
          <form method="post" action="${pageContext.request.contextPath}/admin/promotions/<%= selected.getPromotionNo() %>/reject" style="margin-bottom:10px;">
            <label for="rejectReason"><strong>반려 사유</strong></label>
            <textarea id="rejectReason" name="rejectReason" class="form-control" rows="3" maxlength="1000" placeholder="반려 시 사유를 입력해주세요."></textarea>
            <div style="text-align:right;margin-top:10px;"><button class="btn btn-danger" type="submit">반려</button></div>
          </form>
          <form method="post" action="${pageContext.request.contextPath}/admin/promotions/<%= selected.getPromotionNo() %>/approve" style="text-align:right;">
            <button class="btn btn-primary" type="submit">노출 승인</button>
          </form>
        <% } %>
      <% } %>
    </section>
  </main>
</div>
</body>
</html>
