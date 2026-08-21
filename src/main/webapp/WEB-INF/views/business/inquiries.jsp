<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>사업자 문의 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>참여 문의 관리</h1></div>
<div class="content-grid-2">
  <div class="table-card"><h3>문의 목록</h3><ul class="list-clean" style="padding:0 20px 20px"><li><strong>차세대 유전자 치료제</strong><div class="row-between text-muted"><span>08.21 · 홍길동</span><span class="badge badge-gray">답변대기</span></div></li><li><strong>헌팅턴병 치료제</strong><div class="row-between text-muted"><span>08.20 · 김민수</span><span class="badge badge-green">답변완료</span></div></li><li><strong>낭포성 섬유증 치료제</strong><div class="row-between text-muted"><span>08.18 · 이영희</span><span class="badge badge-green">답변완료</span></div></li></ul></div>
  <div class="card"><h3>문의 상세/답변</h3><p><strong>문의 제목</strong><br>임상시험 참여 조건 문의드립니다.</p><p class="text-muted">유전자 검사 결과가 있는 경우 참여가 가능한지, 방문 일정은 어떻게 되는지 궁금합니다.</p><div class="form-group"><label class="form-label">답변 작성</label><textarea class="form-control"></textarea></div><button class="btn btn-primary" data-demo-alert="답변 등록 후 ANSWERED 상태로 변경합니다.">답변 등록</button></div>
</div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>