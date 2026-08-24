<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>
<%@ page import="meditrials.meditrials.business.subscription.vo.BusinessSubscriptionVO" %>
<%@ page import="meditrials.meditrials.business.vo.BusinessVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String money(Number value) {
        long amount = value == null ? 0L : value.longValue();
        return NumberFormat.getNumberInstance(Locale.KOREA).format(amount);
    }

    private String formatDate(LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd"));
    }

    private String subscriptionLabel(String value, boolean cancelScheduled) {
        if ("PENDING".equals(value)) return "최초 결제 대기";
        if ("ACTIVE".equals(value) && cancelScheduled) return "이용 중 · 자동결제 취소 예정";
        if ("ACTIVE".equals(value)) return "이용 중 · 자동결제";
        if ("EXPIRED".equals(value)) return "이용 만료";
        if ("CANCELED".equals(value)) return "이용 종료";
        return value == null ? "미신청" : value;
    }

    private String paymentLabel(String value) {
        if ("PENDING".equals(value)) return "결제대기";
        if ("PAID".equals(value)) return "결제완료";
        if ("CANCELED".equals(value)) return "결제취소";
        if ("REFUNDED".equals(value)) return "환불완료";
        return value == null ? "-" : value;
    }

    private String statusClass(String value) {
        if ("ACTIVE".equals(value) || "PAID".equals(value)) return "badge-green";
        if ("PENDING".equals(value)) return "badge-amber";
        if ("CANCELED".equals(value) || "REFUNDED".equals(value)) return "badge-red";
        return "badge-gray";
    }
%>
<%
    BusinessVO business = request.getAttribute("business") instanceof BusinessVO value ? value : null;
    BusinessSubscriptionVO premium = request.getAttribute("premium") instanceof BusinessSubscriptionVO value ? value : null;
    Number premiumMonthlyFee = request.getAttribute("premiumMonthlyFee") instanceof Number value ? value : 99_000L;
    boolean canApplyPremium = Boolean.TRUE.equals(request.getAttribute("canApplyPremium"));
    boolean premiumRequired = Boolean.TRUE.equals(request.getAttribute("premiumRequired"));
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
    String pageError = request.getAttribute("pageError") instanceof String value ? value : null;
    boolean businessApproved = business != null && "APPROVED".equals(business.getApprovalStatus());
    boolean premiumActive = premium != null
            && "ACTIVE".equals(premium.getSubscriptionStatus())
            && (premium.getEndDate() == null || premium.getEndDate().isAfter(LocalDateTime.now()));
    boolean premiumPending = premium != null && "PENDING".equals(premium.getSubscriptionStatus());
    boolean cancelScheduled = premiumActive && premium.getEndDate() != null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>요금제/프리미엄 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>요금제 / 프리미엄</h1>
        <p class="text-muted" style="margin:8px 0 0;">PREMIUM 최초 결제 승인 후에는 매월 자동결제되며, 취소 신청 시 현재 결제 주기 종료일까지 이용할 수 있습니다.</p>
      </div>
    </div>

    <% if (premiumRequired) { %>
      <div class="notice" style="margin-bottom:18px;">통계 메뉴는 PREMIUM이 활성화된 사업자에게만 표시됩니다.</div>
    <% } %>
    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#e9fbf3;color:#18825e;border-color:#bfead8;"><%= h(pageNotice) %></div>
    <% } %>
    <% if (pageError != null && !pageError.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#fff1f2;color:#b93640;border-color:#f5cbd0;"><%= h(pageError) %></div>
    <% } %>

    <div class="plan-grid">
      <div class="plan-card">
        <h2>FREE</h2>
        <div class="price">₩0</div>
        <ul>
          <li>임상시험 등록/수정</li>
          <li>참여문의 확인/답변</li>
          <li>기본 모집상태 관리</li>
        </ul>
      </div>

      <div class="plan-card premium">
        <span class="badge badge-blue" style="position:absolute;right:22px;top:22px;">추천</span>
        <h2>PREMIUM</h2>
        <div class="price">₩<%= money(premiumMonthlyFee) %> <small style="font-size:14px">/월 · 자동결제</small></div>
        <ul>
          <li>메인/검색 우선 노출</li>
          <li>조회수·관심등록·문의 통계</li>
          <li>프리미엄 임상시험 홍보</li>
          <li>기간별 모집성과 확인</li>
        </ul>

        <% if (canApplyPremium) { %>
          <form action="${pageContext.request.contextPath}/business/plans/apply" method="post">
            <button class="btn btn-primary w-100" type="submit"
                    onclick="return confirm('PREMIUM을 신청하시겠습니까? 최초 결제 승인 후 매월 자동결제됩니다.');">프리미엄 이용 신청</button>
          </form>
        <% } else if (!businessApproved) { %>
          <button class="btn btn-outline w-100" type="button" disabled>사업자 승인 후 신청 가능</button>
        <% } else if (premiumPending) { %>
          <button class="btn btn-outline w-100" type="button" disabled>최초 결제 처리 대기 중</button>
        <% } else if (premiumActive && !cancelScheduled) { %>
          <form action="${pageContext.request.contextPath}/business/plans/cancel" method="post">
            <button class="btn btn-danger w-100" type="submit"
                    onclick="return confirm('PREMIUM 자동결제를 취소하시겠습니까? 현재 결제 주기 종료일까지 PREMIUM 기능은 유지됩니다.');">자동결제 취소 신청</button>
          </form>
        <% } else if (cancelScheduled) { %>
          <div class="notice" style="margin-bottom:10px;background:#fff8e7;color:#806018;border-color:#f1dda8;text-align:center;">
            자동결제 취소 신청 완료 · <%= formatDate(premium.getEndDate()) %> 종료 예정
          </div>
          <form action="${pageContext.request.contextPath}/business/plans/resume" method="post">
            <button class="btn btn-primary w-100" type="submit"
                    onclick="return confirm('자동결제 취소 신청을 철회하고 PREMIUM 자동결제를 계속하시겠습니까?');">자동결제 이어하기</button>
          </form>
        <% } else { %>
          <button class="btn btn-outline w-100" type="button" disabled>신청 상태 확인 중</button>
        <% } %>
      </div>
    </div>

    <% if (premiumActive) { %>
      <section class="card mt-20" style="display:flex;align-items:center;justify-content:space-between;gap:20px;">
        <div>
          <h3 style="margin:0 0 6px;">프리미엄 임상시험 노출</h3>
          <p class="text-muted" style="margin:0;">승인 완료된 자체 임상시험을 메인 추천 영역과 검색 상단에 노출 신청할 수 있습니다.</p>
        </div>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/business/promotions">노출 신청/관리</a>
      </section>
    <% } %>

    <section class="card mt-20">
      <div class="row-between" style="align-items:flex-start;">
        <div>
          <h3 style="margin-bottom:6px;">현재 이용 상태</h3>
          <p class="text-muted" style="margin-top:0;">기관: <%= business == null ? "-" : h(business.getOrgName()) %></p>
        </div>
        <% if (premiumActive) { %>
          <span class="badge badge-green">PREMIUM</span>
        <% } else { %>
          <span class="badge badge-gray">FREE</span>
        <% } %>
      </div>

      <div class="content-grid-2" style="margin-top:18px;">
        <div>
          <p><strong>현재 요금제</strong><br><%= premiumActive ? "PREMIUM" : "FREE" %></p>
          <p><strong>사업자 승인 상태</strong><br>
            <% if (businessApproved) { %>
              <span class="badge badge-green">승인완료</span>
            <% } else { %>
              <span class="badge badge-amber">승인 전</span>
            <% } %>
          </p>
        </div>
        <div>
          <p><strong>프리미엄 이용 상태</strong><br>
            <span class="badge <%= statusClass(premium == null ? null : premium.getSubscriptionStatus()) %>"><%= subscriptionLabel(premium == null ? null : premium.getSubscriptionStatus(), cancelScheduled) %></span>
          </p>
          <p><strong>최근 결제 상태</strong><br>
            <span class="badge <%= statusClass(premium == null ? null : premium.getPaymentStatus()) %>"><%= paymentLabel(premium == null ? null : premium.getPaymentStatus()) %></span>
          </p>
        </div>
      </div>

      <% if (premium != null) { %>
        <div class="divider"></div>
        <div class="content-grid-2">
          <p><strong>최초 신청일</strong><br><%= formatDate(premium.getCreatedAt()) %></p>
          <p><strong>내 구독 월 결제금액</strong><br>₩<%= money(premium.getMonthlyFee()) %></p>
          <p><strong>최근 결제번호</strong><br><%= premium.getPaymentNo() == null ? "-" : "P-" + premium.getPaymentNo() %></p>
          <p><strong>이용 시작일</strong><br><%= formatDate(premium.getStartDate()) %></p>
          <% if (premiumActive && !cancelScheduled) { %>
            <p><strong>다음 자동결제 예정일</strong><br><%= formatDate(premium.getNextBillingDate()) %></p>
          <% } else if (cancelScheduled) { %>
            <p><strong>취소 신청일</strong><br><%= formatDate(premium.getUpdatedAt()) %></p>
            <p><strong>이용 종료 예정일</strong><br><%= formatDate(premium.getEndDate()) %></p>
          <% } else if (premium.getEndDate() != null) { %>
            <p><strong>이용 종료일</strong><br><%= formatDate(premium.getEndDate()) %></p>
          <% } %>
        </div>
      <% } %>
    </section>

    <% if (!businessApproved) { %>
      <div class="notice" style="margin-top:18px;">관리자 사업자 승인이 완료되어야 프리미엄 이용 신청을 할 수 있습니다.</div>
    <% } else if (premiumPending) { %>
      <div class="notice" style="margin-top:18px;">MVP에서는 최초 결제를 TEST 방식으로 관리자가 승인합니다. 활성화 이후 월 결제는 같은 TEST 방식으로 자동 생성됩니다.</div>
    <% } else if (premiumActive && !cancelScheduled) { %>
      <div class="notice" style="margin-top:18px;">PREMIUM은 매월 자동결제됩니다. 자동결제를 취소하면 즉시 종료되지 않고 현재 결제 주기 종료일까지 PREMIUM 기능을 계속 이용할 수 있습니다.</div>
    <% } else if (cancelScheduled) { %>
      <div class="notice" style="margin-top:18px;background:#fff8e7;color:#806018;border-color:#f1dda8;">
        자동결제 취소 신청이 완료되었습니다. <strong><%= formatDate(premium.getEndDate()) %></strong>까지 PREMIUM 기능이 유지되며 이후 FREE로 전환됩니다.
        종료 예정일 전에는 위의 <strong>자동결제 이어하기</strong> 버튼으로 취소 신청을 철회할 수 있습니다.
      </div>
    <% } %>
  </main>
</div>
</body>
</html>
