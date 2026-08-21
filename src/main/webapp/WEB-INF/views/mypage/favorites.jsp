<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>관심 목록 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>관심 목록</h1></div>
<div class="tabs"><button class="tab active" data-tab>관심 질환</button><button class="tab" data-tab>관심 임상시험</button></div>
<div class="favorite-card-grid">
  <div class="favorite-card"><div><h3>헌팅턴병</h3><p class="text-muted">유전성·신경계 질환<br>관련 임상시험 8건</p></div><span class="heart">♥</span></div>
  <div class="favorite-card"><div><h3>파브리병</h3><p class="text-muted">유전성·대사 질환<br>관련 임상시험 5건</p></div><span class="heart">♥</span></div>
  <div class="favorite-card"><div><h3>낭포성 섬유증</h3><p class="text-muted">유전성·호흡기 질환<br>관련 임상시험 6건</p></div><span class="heart">♥</span></div>
  <div class="favorite-card"><div><h3>근위축성 측삭경화증 (ALS)</h3><p class="text-muted">신경계 질환<br>관련 임상시험 12건</p></div><span class="heart">♥</span></div>
</div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>