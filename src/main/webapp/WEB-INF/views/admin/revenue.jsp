<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>매출 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>매출 관리</h1></div>
<div class="stat-grid"><div class="stat-card"><span>이번 달 매출</span><strong>₩24,580,000</strong></div><div class="stat-card"><span>프리미엄 이용</span><strong>156건</strong></div><div class="stat-card"><span>전월 대비</span><strong>+8.5%</strong></div></div>
<div class="content-grid-2"><div class="card"><h3>월별 매출 추이</h3><div class="chart-placeholder"></div></div><div class="card"><h3>수익 구성</h3><ul class="list-clean"><li class="row-between"><span>프리미엄 구독</span><strong>₩18,900,000</strong></li><li class="row-between"><span>프로모션</span><strong>₩5,680,000</strong></li></ul></div></div>
<div class="table-card mt-20"><table class="table"><thead><tr><th>월</th><th>결제건수</th><th>프리미엄 매출</th><th>프로모션 매출</th><th>총매출</th></tr></thead><tbody><tr><td>8월</td><td>156</td><td>18,900,000</td><td>5,680,000</td><td>24,580,000</td></tr><tr><td>7월</td><td>142</td><td>17,300,000</td><td>5,350,000</td><td>22,650,000</td></tr><tr><td>6월</td><td>131</td><td>15,900,000</td><td>4,700,000</td><td>20,600,000</td></tr></tbody></table></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>