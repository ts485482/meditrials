<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="meditrials.meditrials.admin.revenue.vo.AdminMonthlyRevenueVO" %>
<%@ page import="meditrials.meditrials.admin.revenue.vo.AdminRevenueSummaryVO" %>
<%!
    private String number(long value) {
        return NumberFormat.getNumberInstance(Locale.KOREA).format(value);
    }

    private String growthLabel(long current, long previous) {
        if (previous == 0L) {
            return current == 0L ? "0.0%" : "신규";
        }
        double rate = ((double) current - previous) * 100.0 / previous;
        return String.format(Locale.KOREA, "%+.1f%%", rate);
    }

    private String growthClass(long current, long previous) {
        if (current > previous) return "revenue-up";
        if (current < previous) return "revenue-down";
        return "revenue-flat";
    }
%>
<%
    AdminRevenueSummaryVO summary = request.getAttribute("summary") instanceof AdminRevenueSummaryVO value
            ? value : new AdminRevenueSummaryVO();
    List<AdminMonthlyRevenueVO> monthlyRevenue = request.getAttribute("monthlyRevenue") instanceof List<?> list
            ? (List<AdminMonthlyRevenueVO>) list : List.of();

    long maxMonthlyRevenue = 0L;
    for (AdminMonthlyRevenueVO item : monthlyRevenue) {
        maxMonthlyRevenue = Math.max(maxMonthlyRevenue, item.getPremiumRevenue());
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>매출 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <style>
    .revenue-chart{height:250px;display:flex;align-items:flex-end;gap:16px;padding:24px 14px 10px;border-bottom:1px solid #dfe6ef}
    .revenue-bar-item{flex:1;min-width:0;text-align:center}
    .revenue-bar-wrap{height:180px;display:flex;align-items:flex-end;justify-content:center}
    .revenue-bar{width:min(54px,72%);min-height:4px;border-radius:7px 7px 2px 2px;background:#1769d2}
    .revenue-bar-value{font-size:12px;color:#5f6e80;margin-bottom:7px;white-space:nowrap}
    .revenue-bar-label{font-size:13px;color:#516174;margin-top:9px}
    .revenue-up{color:#17845f}.revenue-down{color:#c3444d}.revenue-flat{color:#5f6e80}
    .revenue-note{font-size:13px;color:#6e7d90;line-height:1.65;margin-top:14px}
  </style>
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>매출 관리</h1>
        <p class="text-muted" style="margin:8px 0 0;">PAYMENT의 실제 결제 완료(PAID) 내역을 기준으로 매출을 집계합니다.</p>
      </div>
    </div>

    <div class="stat-grid">
      <div class="stat-card">
        <span>이번 달 매출</span>
        <strong>₩<%= number(summary.getCurrentMonthRevenue()) %></strong>
      </div>
      <div class="stat-card">
        <span>활성 PREMIUM</span>
        <strong><%= number(summary.getActivePremiumCount()) %>건</strong>
      </div>
      <div class="stat-card">
        <span>이번 달 결제</span>
        <strong><%= number(summary.getCurrentMonthPaymentCount()) %>건</strong>
      </div>
      <div class="stat-card">
        <span>전월 대비</span>
        <strong class="<%= growthClass(summary.getCurrentMonthRevenue(), summary.getPreviousMonthRevenue()) %>">
          <%= growthLabel(summary.getCurrentMonthRevenue(), summary.getPreviousMonthRevenue()) %>
        </strong>
      </div>
    </div>

    <div class="content-grid-2">
      <div class="card">
        <h3>최근 6개월 매출 추이</h3>
        <% if (monthlyRevenue.isEmpty()) { %>
          <div class="text-center text-muted" style="padding:80px 0;">표시할 매출 데이터가 없습니다.</div>
        <% } else { %>
          <div class="revenue-chart">
            <% for (AdminMonthlyRevenueVO item : monthlyRevenue) {
                 double ratio = maxMonthlyRevenue == 0L ? 0.0 : ((double) item.getPremiumRevenue() / maxMonthlyRevenue);
                 int height = item.getPremiumRevenue() == 0L ? 4 : Math.max(12, (int) Math.round(ratio * 170.0));
            %>
              <div class="revenue-bar-item">
                <div class="revenue-bar-value">₩<%= number(item.getPremiumRevenue()) %></div>
                <div class="revenue-bar-wrap">
                  <div class="revenue-bar" style="height:<%= height %>px;"></div>
                </div>
                <div class="revenue-bar-label"><%= item.getMonthLabel() %></div>
              </div>
            <% } %>
          </div>
        <% } %>
      </div>

      <div class="card">
        <h3>수익 구성</h3>
        <ul class="list-clean">
          <li class="row-between">
            <span>PREMIUM 구독 결제</span>
            <strong>₩<%= number(summary.getCurrentMonthRevenue()) %></strong>
          </li>
          <li class="row-between">
            <span>프리미엄 노출 별도 과금</span>
            <strong>₩0</strong>
          </li>
          <li class="row-between" style="border-top:1px solid #e6ebf2;margin-top:8px;padding-top:14px;">
            <span>누적 결제 매출</span>
            <strong>₩<%= number(summary.getTotalPaidRevenue()) %></strong>
          </li>
        </ul>
        <p class="revenue-note">
          현재 MediTrials의 프리미엄 임상시험 노출은 PREMIUM 요금제 기능에 포함되어 있어 별도 프로모션 결제 금액은 발생하지 않습니다.
        </p>
      </div>
    </div>

    <div class="table-card mt-20">
      <h3>월별 매출 상세</h3>
      <table class="table">
        <thead>
          <tr>
            <th>월</th>
            <th>결제건수</th>
            <th>PREMIUM 구독 매출</th>
            <th>총매출</th>
          </tr>
        </thead>
        <tbody>
        <% if (monthlyRevenue.isEmpty()) { %>
          <tr><td colspan="4" class="text-center text-muted">월별 매출 데이터가 없습니다.</td></tr>
        <% } else { %>
          <% for (AdminMonthlyRevenueVO item : monthlyRevenue) { %>
            <tr>
              <td><strong><%= item.getMonthLabel() %></strong></td>
              <td><%= number(item.getPaymentCount()) %>건</td>
              <td>₩<%= number(item.getPremiumRevenue()) %></td>
              <td><strong>₩<%= number(item.getPremiumRevenue()) %></strong></td>
            </tr>
          <% } %>
        <% } %>
        </tbody>
      </table>
    </div>

    <div class="notice" style="margin-top:18px;">
      환불된 결제는 PAYMENT.STATUS='REFUNDED'로 변경되므로 매출 집계에서 자동 제외됩니다. 자동결제는 TEST 결제라도 PAID 상태이면 실제 프로젝트 매출 통계에 포함됩니다.
    </div>
  </main>
</div>
<script src="${pageContext.request.contextPath}/js/meditrials.js"></script>
</body>
</html>
