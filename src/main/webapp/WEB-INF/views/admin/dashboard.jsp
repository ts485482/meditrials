<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="meditrials.meditrials.admin.dashboard.vo.AdminDashboardVO" %>
<%@ page import="meditrials.meditrials.admin.dashboard.vo.AdminRecentReviewVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String number(long value) {
        return NumberFormat.getNumberInstance(Locale.KOREA).format(value);
    }

    private String targetTypeLabel(String value) {
        if ("BUSINESS".equals(value)) return "사업자";
        if ("TRIAL".equals(value)) return "임상시험";
        if ("PROMOTION".equals(value)) return "프리미엄 노출";
        if ("SUBSCRIPTION".equals(value)) return "프리미엄";
        return value == null ? "-" : value;
    }

    private String actionLabel(String value) {
        if ("APPROVE".equals(value)) return "승인";
        if ("REJECT".equals(value)) return "반려";
        if ("ACTIVATE".equals(value)) return "활성화";
        if ("END".equals(value)) return "종료";
        return value == null ? "-" : value;
    }
%>
<%
    AdminDashboardVO dashboard = request.getAttribute("dashboard") instanceof AdminDashboardVO value
            ? value : new AdminDashboardVO();
    List<AdminRecentReviewVO> recentReviews = request.getAttribute("recentReviews") instanceof List<?> list
            ? (List<AdminRecentReviewVO>) list : List.of();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>관리자 대시보드 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>관리자 대시보드</h1>
        <p class="text-muted" style="margin:8px 0 0;">현재 MediTrials 운영 현황을 실제 DB 기준으로 확인합니다.</p>
      </div>
    </div>

    <div class="stat-grid six">
      <div class="stat-card">
        <span>회원 수</span>
        <strong><%= number(dashboard.getUserCount()) %>명</strong>
      </div>
      <div class="stat-card">
        <span>승인 사업자</span>
        <strong><%= number(dashboard.getBusinessCount()) %>개</strong>
      </div>
      <div class="stat-card">
        <span>공개 임상시험</span>
        <strong><%= number(dashboard.getTrialCount()) %>건</strong>
      </div>
      <div class="stat-card">
        <span>참여 문의</span>
        <strong><%= number(dashboard.getInquiryCount()) %>건</strong>
      </div>
      <div class="stat-card">
        <span>PREMIUM 이용</span>
        <strong><%= number(dashboard.getPremiumBusinessCount()) %>건</strong>
      </div>
      <div class="stat-card">
        <span>이번 달 매출</span>
        <strong style="font-size:20px;">₩<%= number(dashboard.getMonthRevenue()) %></strong>
      </div>
    </div>

    <div class="content-grid-3">
      <div class="card">
        <h3>사업자 승인 관리</h3>
        <p>신규 승인 대기 <strong><%= number(dashboard.getPendingBusinessCount()) %>건</strong></p>
        <p>승인 완료(이번 달) <strong><%= number(dashboard.getApprovedBusinessMonthCount()) %>건</strong></p>
        <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/businesses">사업자 관리</a>
      </div>

      <div class="card">
        <h3>임상시험 검수</h3>
        <p>검수 대기 <strong><%= number(dashboard.getPendingTrialCount()) %>건</strong></p>
        <p>반려(이번 달) <strong><%= number(dashboard.getRejectedTrialMonthCount()) %>건</strong></p>
        <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/trials">임상시험 검수</a>
      </div>

      <div class="card">
        <h3>프리미엄 / 매출</h3>
        <p>PREMIUM 이용 <strong><%= number(dashboard.getPremiumBusinessCount()) %>건</strong></p>
        <p>이번 달 매출 <strong>₩<%= number(dashboard.getMonthRevenue()) %></strong></p>
        <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/payments">결제 관리</a>
      </div>
    </div>

    <div class="table-card mt-20">
      <h3>최근 처리 내역</h3>
      <table class="table">
        <thead>
          <tr>
            <th>일시</th>
            <th>구분</th>
            <th>대상</th>
            <th>처리</th>
            <th>관리자</th>
          </tr>
        </thead>
        <tbody>
        <% if (recentReviews.isEmpty()) { %>
          <tr>
            <td colspan="5" class="text-center text-muted">아직 관리자 처리 이력이 없습니다.</td>
          </tr>
        <% } else { %>
          <% for (AdminRecentReviewVO review : recentReviews) { %>
            <tr>
              <td><%= h(review.getCreatedAtText()) %></td>
              <td><%= h(targetTypeLabel(review.getTargetType())) %></td>
              <td><%= h(review.getTargetName() == null || review.getTargetName().isBlank()
                      ? "#" + review.getTargetNo() : review.getTargetName()) %></td>
              <td><%= h(actionLabel(review.getActionType())) %></td>
              <td><%= h(review.getAdminName()) %></td>
            </tr>
          <% } %>
        <% } %>
        </tbody>
      </table>
    </div>
  </main>
</div>
<script src="${pageContext.request.contextPath}/js/meditrials.js"></script>
</body>
</html>
