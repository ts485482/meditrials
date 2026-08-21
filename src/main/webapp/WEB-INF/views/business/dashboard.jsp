<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>사업자 대시보드 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>사업자 대시보드</h1><span class="badge badge-green">승인 사업자</span></div>
<div class="stat-grid">
  <div class="stat-card"><span>전체 임상시험</span><strong>8</strong></div>
  <div class="stat-card"><span>검수 대기</span><strong>2</strong></div>
  <div class="stat-card"><span>승인 완료</span><strong>5</strong></div>
  <div class="stat-card"><span>반려</span><strong>1</strong></div>
</div>
<div class="content-grid-2">
  <div class="table-card"><h3>최근 임상시험</h3><table class="table"><thead><tr><th>제목</th><th>단계</th><th>검수상태</th><th>모집상태</th></tr></thead><tbody><tr><td>차세대 유전자 치료제 임상</td><td>2/3상</td><td><span class="badge badge-gray">검수대기</span></td><td><span class="badge badge-green">모집중</span></td></tr><tr><td>헌팅턴병 치료제 효과 평가</td><td>2상</td><td><span class="badge badge-green">승인</span></td><td><span class="badge badge-green">모집중</span></td></tr><tr><td>파브리병 효소대체요법</td><td>3상</td><td><span class="badge badge-red">반려</span></td><td><span class="badge badge-amber">모집예정</span></td></tr></tbody></table></div>
  <div class="table-card"><h3>참여 문의</h3><table class="table"><thead><tr><th>문의일</th><th>임상시험</th><th>문의자</th><th>상태</th></tr></thead><tbody><tr><td>08.21</td><td>차세대 유전자 치료제</td><td>홍길동</td><td><span class="badge badge-green">답변완료</span></td></tr><tr><td>08.20</td><td>헌팅턴병 치료제</td><td>김민수</td><td><span class="badge badge-gray">답변대기</span></td></tr><tr><td>08.19</td><td>낭포성 섬유증 치료제</td><td>이영희</td><td><span class="badge badge-green">답변완료</span></td></tr></tbody></table></div>
</div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>