<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>마이페이지 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>마이페이지</h1></div>
<div class="stat-grid">
  <div class="stat-card"><span>관심 질환</span><strong>5</strong></div>
  <div class="stat-card"><span>관심 임상시험</span><strong>3</strong></div>
  <div class="stat-card"><span>참여 문의</span><strong>2</strong></div>
</div>
<div class="content-grid-3">
  <div class="table-card"><h3>관심 질환</h3><ul class="list-clean" style="padding:0 20px 18px"><li>헌팅턴병</li><li>낭포성 섬유증</li><li>근위축성 측삭경화증 (ALS)</li></ul></div>
  <div class="table-card"><h3>관심 임상시험</h3><ul class="list-clean" style="padding:0 20px 18px"><li>차세대 유전자 치료제 임상 2/3상</li><li>헌팅턴병 치료제 2상</li><li>낭포성 섬유증 치료제 2상</li></ul></div>
  <div class="table-card"><h3>참여 문의 내역</h3><ul class="list-clean" style="padding:0 20px 18px"><li class="row-between"><span>차세대 유전자 치료제 문의</span><span class="badge badge-green">답변완료</span></li><li class="row-between"><span>헌팅턴병 치료제 문의</span><span class="badge badge-gray">답변대기</span></li></ul></div>
</div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>