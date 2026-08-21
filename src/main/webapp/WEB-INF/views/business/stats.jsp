<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>사업자 통계 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>임상시험 모집 성과 <span class="badge badge-blue">PREMIUM</span></h1></div>
<div class="stat-grid"><div class="stat-card"><span>조회수</span><strong>1,320</strong></div><div class="stat-card"><span>관심등록</span><strong>152</strong></div><div class="stat-card"><span>참여문의</span><strong>37</strong></div><div class="stat-card"><span>참여확정</span><strong>18</strong></div></div>
<div class="content-grid-2"><div class="card"><h3>기간별 성과</h3><div class="chart-placeholder"></div></div><div class="card"><h3>전환 현황</h3><ul class="list-clean"><li class="row-between"><span>조회 → 관심</span><strong>11.5%</strong></li><li class="row-between"><span>관심 → 문의</span><strong>24.3%</strong></li><li class="row-between"><span>문의 → 참여</span><strong>48.6%</strong></li></ul></div></div>
<div class="table-card mt-20"><table class="table"><thead><tr><th>임상시험</th><th>조회</th><th>관심</th><th>문의</th><th>참여</th></tr></thead><tbody><tr><td>차세대 유전자 치료제</td><td>520</td><td>64</td><td>18</td><td>9</td></tr><tr><td>헌팅턴병 치료제</td><td>410</td><td>51</td><td>12</td><td>6</td></tr><tr><td>낭포성 섬유증 치료제</td><td>390</td><td>37</td><td>7</td><td>3</td></tr></tbody></table></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>