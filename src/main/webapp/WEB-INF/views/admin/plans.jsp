<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%@ page import="meditrials.meditrials.plan.vo.PlanPolicyVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String money(Number value) {
        long amount = value == null ? 0L : value.longValue();
        return NumberFormat.getNumberInstance(Locale.KOREA).format(amount);
    }

    private String formatDateTime(LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm"));
    }

    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }
%>
<%
    PlanPolicyVO freePolicy = request.getAttribute("freePolicy") instanceof PlanPolicyVO value
            ? value : null;
    PlanPolicyVO premiumPolicy = request.getAttribute("premiumPolicy") instanceof PlanPolicyVO value
            ? value : null;
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
    String pageError = request.getAttribute("pageError") instanceof String value ? value : null;
    long freeFee = freePolicy == null || freePolicy.getMonthlyFee() == null ? 0L : freePolicy.getMonthlyFee();
    long premiumFee = premiumPolicy == null || premiumPolicy.getMonthlyFee() == null ? 0L : premiumPolicy.getMonthlyFee();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>요금제 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>요금제 관리</h1>
        <p class="text-muted" style="margin:8px 0 0;">현재 적용 중인 FREE/PREMIUM 정책을 확인하고 PREMIUM 신규 신청 금액을 관리합니다.</p>
      </div>
    </div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#e9fbf3;color:#18825e;border-color:#bfead8;"><%= h(pageNotice) %></div>
    <% } %>
    <% if (pageError != null && !pageError.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#fff1f2;color:#b93640;border-color:#f5cbd0;"><%= h(pageError) %></div>
    <% } %>

    <div class="plan-grid">
      <div class="plan-card">
        <h2>FREE</h2>
        <div class="price">₩<%= money(freeFee) %></div>
        <ul>
          <li>임상시험 등록/수정</li>
          <li>참여문의 확인/답변</li>
          <li>기본 모집상태 관리</li>
        </ul>
        <div class="notice" style="margin-top:18px;">FREE 요금제는 기본 제공 정책으로 월 이용료가 발생하지 않습니다.</div>
      </div>

      <div class="plan-card premium">
        <span class="badge badge-blue" style="position:absolute;right:22px;top:22px;">운영 중</span>
        <h2>PREMIUM</h2>
        <div class="price">₩<%= money(premiumFee) %> <small style="font-size:14px">/월 · 자동결제</small></div>
        <ul>
          <li>메인/검색 우선 노출</li>
          <li>조회/관심/문의/참여 통계</li>
          <li>프리미엄 임상시험 홍보</li>
          <li>기간별 모집성과 분석</li>
        </ul>
        <div class="notice" style="margin-top:18px;background:#eef5ff;color:#245a9b;border-color:#cddff5;">
          현재 사업자 신규 신청 화면에도 동일한 월 이용료가 표시됩니다.
        </div>
      </div>
    </div>

    <section class="card mt-20">
      <h3 style="margin-bottom:6px;">PREMIUM 요금제 정책 설정</h3>
      <p class="text-muted" style="margin-top:0;line-height:1.65;">
        월 이용료 변경은 저장 이후 <strong>새로 PREMIUM을 신청하는 사업자부터</strong> 적용됩니다.
        기존 활성 구독은 신청 당시 BUSINESS_SUBSCRIPTION.MONTHLY_FEE를 유지하므로 다음 자동결제 금액도 변경되지 않습니다.
      </p>

      <form action="${pageContext.request.contextPath}/admin/plans/premium" method="post" style="margin-top:22px;max-width:560px;">
        <label for="monthlyFee" style="display:block;font-weight:700;margin-bottom:8px;">PREMIUM 월 이용료</label>
        <div class="form-inline">
          <input id="monthlyFee"
                 class="form-control"
                 type="number"
                 name="monthlyFee"
                 value="<%= premiumFee %>"
                 min="0"
                 max="10000000"
                 step="1000"
                 required>
          <span style="padding:12px;white-space:nowrap;">원 / 월</span>
          <button class="btn btn-primary" type="submit"
                  onclick="return confirm('PREMIUM 월 이용료 정책을 저장하시겠습니까? 변경 금액은 신규 신청부터 적용됩니다.');">정책 저장</button>
        </div>
      </form>

      <div class="divider"></div>
      <div class="content-grid-2">
        <p><strong>현재 PREMIUM 월 이용료</strong><br>₩<%= money(premiumFee) %></p>
        <p><strong>최근 변경일</strong><br><%= premiumPolicy == null ? "-" : formatDateTime(premiumPolicy.getUpdatedAt()) %></p>
        <p><strong>최근 변경 관리자</strong><br><%= premiumPolicy == null || premiumPolicy.getUpdatedByName() == null ? "초기 정책" : h(premiumPolicy.getUpdatedByName()) %></p>
        <p><strong>정책 상태</strong><br><span class="badge badge-green"><%= premiumPolicy != null && "Y".equals(premiumPolicy.getActiveYn()) ? "사용 중" : "비활성" %></span></p>
      </div>
    </section>

    <div class="notice" style="margin-top:18px;">
      요금제 기능 구성은 현재 MediTrials 서비스 정책으로 고정되어 있으며, 이 화면에서는 실제 과금에 사용되는 PREMIUM 월 이용료를 관리합니다.
    </div>
  </main>
</div>
<script src="${pageContext.request.contextPath}/js/meditrials.js"></script>
</body>
</html>
