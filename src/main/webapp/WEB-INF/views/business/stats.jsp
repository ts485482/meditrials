<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="meditrials.meditrials.business.stats.vo.BusinessStatsDetailVO" %>
<%@ page import="meditrials.meditrials.business.stats.vo.BusinessStatsVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String number(long value) {
        return NumberFormat.getNumberInstance(Locale.KOREA).format(value);
    }

    private String percent(double value) {
        return String.format(Locale.KOREA, "%.1f%%", value);
    }

    private int barWidth(long value, long max) {
        if (value <= 0L || max <= 0L) return 0;
        return Math.max(4, (int) Math.round((value * 100.0d) / max));
    }
%>
<%
    BusinessStatsVO stats = request.getAttribute("stats") instanceof BusinessStatsVO value
            ? value : new BusinessStatsVO();
    List<BusinessStatsDetailVO> trialStats = stats.getTrialStats();
    List<BusinessStatsDetailVO> dailyStats = stats.getDailyStats();

    long maxDailyValue = 0L;
    for (BusinessStatsDetailVO daily : dailyStats) {
        maxDailyValue = Math.max(maxDailyValue, daily.getViewCount());
        maxDailyValue = Math.max(maxDailyValue, daily.getFavoriteCount());
        maxDailyValue = Math.max(maxDailyValue, daily.getInquiryCount());
        maxDailyValue = Math.max(maxDailyValue, daily.getParticipantCount());
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>사업자 통계 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/business-stats.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>임상시험 모집 성과 <span class="badge badge-blue">PREMIUM</span></h1>
        <p class="text-muted">관리자 승인 후 공개된 우리 기관 임상시험의 실제 DB 데이터를 집계합니다.</p>
      </div>
    </div>

    <div class="stat-grid">
      <div class="stat-card"><span>조회수</span><strong><%= number(stats.getViewCount()) %></strong></div>
      <div class="stat-card"><span>관심등록</span><strong><%= number(stats.getFavoriteCount()) %></strong></div>
      <div class="stat-card"><span>문의</span><strong><%= number(stats.getInquiryCount()) %></strong></div>
      <div class="stat-card"><span>참여확정</span><strong><%= number(stats.getParticipantCount()) %></strong></div>
    </div>

    <div class="content-grid-2">
      <section class="card stats-period-card">
        <div class="row-between stats-card-head">
          <h3>최근 7일 성과</h3>
          <span class="text-muted">일자별 발생 건수</span>
        </div>

        <% if (dailyStats.isEmpty()) { %>
          <div class="stats-empty">집계할 기간별 데이터가 없습니다.</div>
        <% } else { %>
          <div class="stats-legend">
            <span><i class="legend-dot views"></i>조회</span>
            <span><i class="legend-dot favorites"></i>관심</span>
            <span><i class="legend-dot inquiries"></i>문의</span>
            <span><i class="legend-dot participants"></i>참여</span>
          </div>
          <div class="stats-daily-list">
          <% for (BusinessStatsDetailVO daily : dailyStats) { %>
            <div class="stats-daily-row">
              <strong class="stats-day"><%= h(daily.getPeriodLabel()) %></strong>
              <div class="stats-bars">
                <div class="stats-bar-line" title="조회 <%= daily.getViewCount() %>건">
                  <span class="stats-bar views" style="width:<%= barWidth(daily.getViewCount(), maxDailyValue) %>%"></span>
                  <em><%= daily.getViewCount() %></em>
                </div>
                <div class="stats-bar-line" title="관심 <%= daily.getFavoriteCount() %>건">
                  <span class="stats-bar favorites" style="width:<%= barWidth(daily.getFavoriteCount(), maxDailyValue) %>%"></span>
                  <em><%= daily.getFavoriteCount() %></em>
                </div>
                <div class="stats-bar-line" title="문의 <%= daily.getInquiryCount() %>건">
                  <span class="stats-bar inquiries" style="width:<%= barWidth(daily.getInquiryCount(), maxDailyValue) %>%"></span>
                  <em><%= daily.getInquiryCount() %></em>
                </div>
                <div class="stats-bar-line" title="참여 <%= daily.getParticipantCount() %>건">
                  <span class="stats-bar participants" style="width:<%= barWidth(daily.getParticipantCount(), maxDailyValue) %>%"></span>
                  <em><%= daily.getParticipantCount() %></em>
                </div>
              </div>
            </div>
          <% } %>
          </div>
        <% } %>
      </section>

      <section class="card">
        <h3>전환 현황</h3>
        <ul class="list-clean stats-conversion-list">
          <li class="row-between"><span>조회 → 관심</span><strong><%= percent(stats.getViewToFavoriteRate()) %></strong></li>
          <li class="row-between"><span>관심 → 문의</span><strong><%= percent(stats.getFavoriteToInquiryRate()) %></strong></li>
          <li class="row-between"><span>문의 → 참여</span><strong><%= percent(stats.getInquiryToParticipantRate()) %></strong></li>
        </ul>
        <div class="notice stats-note">
          참여확정은 TRIAL_PARTICIPATION의 APPROVED / PARTICIPATING / COMPLETED 상태를 기준으로 집계합니다.
        </div>
      </section>
    </div>

    <div class="table-card mt-20">
      <div class="row-between stats-table-head">
        <h3>임상시험별 모집 성과</h3>
        <span class="text-muted">승인·공개된 자체 등록 임상시험</span>
      </div>
      <table class="table">
        <thead>
          <tr><th>임상시험</th><th>조회</th><th>관심</th><th>문의</th><th>참여</th></tr>
        </thead>
        <tbody>
        <% if (trialStats.isEmpty()) { %>
          <tr><td colspan="5" class="text-center text-muted">승인되어 공개 중인 자체 등록 임상시험이 없습니다.</td></tr>
        <% } else { %>
          <% for (BusinessStatsDetailVO trial : trialStats) { %>
            <tr>
              <td><a class="link-blue" href="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>"><%= h(trial.getTitle()) %></a></td>
              <td><%= number(trial.getViewCount()) %></td>
              <td><%= number(trial.getFavoriteCount()) %></td>
              <td><%= number(trial.getInquiryCount()) %></td>
              <td><%= number(trial.getParticipantCount()) %></td>
            </tr>
          <% } %>
        <% } %>
        </tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
