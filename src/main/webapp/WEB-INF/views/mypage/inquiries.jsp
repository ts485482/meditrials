<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>참여 문의 내역 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>참여 문의 내역</h1></div>
<div class="table-card">
<table class="table"><thead><tr><th>임상시험</th><th>문의 제목</th><th>문의일</th><th>상태</th></tr></thead><tbody>
<tr><td>차세대 유전자 치료제 임상 2/3상 연구</td><td>참여 조건 문의</td><td>2026.08.21</td><td><span class="badge badge-green">답변완료</span></td></tr>
<tr><td>헌팅턴병 치료제 효과 및 안전성 평가</td><td>방문 일정 문의</td><td>2026.08.20</td><td><span class="badge badge-gray">답변대기</span></td></tr>
<tr><td>낭포성 섬유증 신규 치료제 2상 임상</td><td>선정 기준 문의</td><td>2026.08.18</td><td><span class="badge badge-green">답변완료</span></td></tr>
</tbody></table></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>