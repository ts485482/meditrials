<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="meditrials.meditrials.admin.payment.vo.AdminPaymentVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String money(Number value) {
        long amount = value == null ? 0L : value.longValue();
        return NumberFormat.getNumberInstance(Locale.KOREA).format(amount);
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm"));
    }

    private String paymentLabel(String value) {
        if ("PENDING".equals(value)) return "결제대기";
        if ("PAID".equals(value)) return "결제완료";
        if ("CANCELED".equals(value)) return "결제취소";
        if ("REFUNDED".equals(value)) return "환불완료";
        return value == null ? "-" : value;
    }

    private String subscriptionLabel(String value) {
        if ("PENDING".equals(value)) return "활성화대기";
        if ("ACTIVE".equals(value)) return "PREMIUM 활성";
        if ("EXPIRED".equals(value)) return "만료";
        if ("CANCELED".equals(value)) return "종료";
        return value == null ? "-" : value;
    }

    private String statusClass(String value) {
        if ("PAID".equals(value) || "ACTIVE".equals(value)) return "badge-green";
        if ("PENDING".equals(value)) return "badge-amber";
        if ("CANCELED".equals(value) || "REFUNDED".equals(value)) return "badge-red";
        return "badge-gray";
    }
%>
<%
    List<AdminPaymentVO> payments = request.getAttribute("payments") instanceof List<?> list
            ? (List<AdminPaymentVO>) list : List.of();
    AdminPaymentVO selectedPayment = request.getAttribute("selectedPayment") instanceof AdminPaymentVO value
            ? value : null;
    Number pendingCount = request.getAttribute("pendingCount") instanceof Number value ? value : 0;
    Number paidCount = request.getAttribute("paidCount") instanceof Number value ? value : 0;
    Number closedCount = request.getAttribute("closedCount") instanceof Number value ? value : 0;
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
    String pageError = request.getAttribute("pageError") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>결제 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>결제 관리</h1>
        <p class="text-muted" style="margin:8px 0 0;">PREMIUM 최초 신청 결제를 승인하고, 활성화 이후 생성되는 월 자동결제 내역을 확인합니다.</p>
      </div>
    </div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#e9fbf3;color:#18825e;border-color:#bfead8;"><%= h(pageNotice) %></div>
    <% } %>
    <% if (pageError != null && !pageError.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#fff1f2;color:#b93640;border-color:#f5cbd0;"><%= h(pageError) %></div>
    <% } %>

    <div class="stat-grid">
      <div class="stat-card"><span>전체 결제</span><strong><%= payments.size() %>건</strong></div>
      <div class="stat-card"><span>결제 대기</span><strong><%= pendingCount.longValue() %>건</strong></div>
      <div class="stat-card"><span>결제 완료</span><strong><%= paidCount.longValue() %>건</strong></div>
      <div class="stat-card"><span>취소/환불</span><strong><%= closedCount.longValue() %>건</strong></div>
    </div>

    <div class="table-card">
      <table class="table">
        <thead>
          <tr>
            <th>결제번호</th>
            <th>기관명</th>
            <th>요금제</th>
            <th>금액</th>
            <th>신청/결제일</th>
            <th>상태</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
        <% if (payments.isEmpty()) { %>
          <tr><td colspan="7" class="text-center text-muted">프리미엄 결제 신청 내역이 없습니다.</td></tr>
        <% } else { %>
          <% for (AdminPaymentVO payment : payments) { %>
            <tr>
              <td><strong>P-<%= payment.getPaymentNo() %></strong></td>
              <td><%= h(payment.getOrgName()) %></td>
              <td><%= h(payment.getPlanType()) %></td>
              <td>₩<%= money(payment.getAmount()) %></td>
              <td><%= formatDate(payment.getPaidAt() != null ? payment.getPaidAt() : payment.getCreatedAt()) %></td>
              <td><span class="badge <%= statusClass(payment.getPaymentStatus()) %>"><%= paymentLabel(payment.getPaymentStatus()) %></span></td>
              <td><a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/payments?paymentNo=<%= payment.getPaymentNo() %>">상세</a></td>
            </tr>
          <% } %>
        <% } %>
        </tbody>
      </table>
    </div>

    <% if (selectedPayment != null) { %>
      <section class="card">
        <div class="row-between" style="align-items:flex-start;margin-bottom:18px;">
          <div>
            <h3 style="margin-bottom:6px;">결제 상세</h3>
            <span class="badge <%= statusClass(selectedPayment.getPaymentStatus()) %>"><%= paymentLabel(selectedPayment.getPaymentStatus()) %></span>
            <span class="badge <%= statusClass(selectedPayment.getSubscriptionStatus()) %>" style="margin-left:6px;"><%= subscriptionLabel(selectedPayment.getSubscriptionStatus()) %></span>
          </div>
          <strong style="color:#173f79;font-size:20px;">P-<%= selectedPayment.getPaymentNo() %></strong>
        </div>

        <div class="content-grid-2">
          <p><strong>기관명</strong><br><%= h(selectedPayment.getOrgName()) %></p>
          <p><strong>요금제</strong><br><%= h(selectedPayment.getPlanType()) %></p>
          <p><strong>결제 금액</strong><br>₩<%= money(selectedPayment.getAmount()) %></p>
          <p><strong>결제 방식</strong><br><%= h(selectedPayment.getPaymentMethod()) %></p>
          <p><strong>신청일</strong><br><%= formatDate(selectedPayment.getCreatedAt()) %></p>
          <p><strong>결제 완료일</strong><br><%= formatDate(selectedPayment.getPaidAt()) %></p>
          <p><strong>PREMIUM 시작일</strong><br><%= formatDate(selectedPayment.getSubscriptionStartDate()) %></p>
          <p><strong>자동결제 종료 예정일</strong><br><%= formatDate(selectedPayment.getSubscriptionEndDate()) %></p>
        </div>

        <% if (selectedPayment.getTransactionId() != null && !selectedPayment.getTransactionId().isBlank()) { %>
          <div class="notice" style="margin-top:12px;background:#f6f8fb;color:#5f6e80;border-color:#e2e7ed;">
            테스트 거래번호: <strong><%= h(selectedPayment.getTransactionId()) %></strong>
          </div>
        <% } %>

        <% if ("PENDING".equals(selectedPayment.getPaymentStatus()) && "PENDING".equals(selectedPayment.getSubscriptionStatus())) { %>
          <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:22px;">
            <form action="${pageContext.request.contextPath}/admin/payments/<%= selectedPayment.getPaymentNo() %>/cancel" method="post">
              <button class="btn btn-danger" type="submit" onclick="return confirm('이 PREMIUM 신청 결제를 취소하시겠습니까?');">결제 취소</button>
            </form>
            <form action="${pageContext.request.contextPath}/admin/payments/<%= selectedPayment.getPaymentNo() %>/complete" method="post">
              <button class="btn btn-primary" type="submit" onclick="return confirm('결제 완료 처리 후 PREMIUM을 활성화하시겠습니까?');">결제 완료 / PREMIUM 활성화</button>
            </form>
          </div>
        <% } else if ("PAID".equals(selectedPayment.getPaymentStatus()) && "ACTIVE".equals(selectedPayment.getSubscriptionStatus())) { %>
          <div style="display:flex;justify-content:flex-end;margin-top:22px;">
            <form action="${pageContext.request.contextPath}/admin/payments/<%= selectedPayment.getPaymentNo() %>/refund" method="post">
              <button class="btn btn-danger" type="submit" onclick="return confirm('환불 처리하면 PREMIUM 이용도 즉시 종료됩니다. 계속하시겠습니까?');">환불 / PREMIUM 종료</button>
            </form>
          </div>
        <% } %>
      </section>
    <% } %>

    <div class="notice" style="margin-top:18px;">MVP 단계에서는 최초 결제와 월 자동결제를 PAYMENT_METHOD='TEST'로 기록합니다. 관리자는 최초 결제만 승인하며 이후 결제는 매월 자동 생성됩니다.</div>
  </main>
</div>
</body>
</html>
