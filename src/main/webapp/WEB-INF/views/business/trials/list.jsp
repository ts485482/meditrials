<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>임상시험 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>임상시험 관리</h1><a class="btn btn-primary" href="${pageContext.request.contextPath}/business/trials/form">임상시험 등록</a></div>
<div class="table-card"><table class="table"><thead><tr><th>번호</th><th>임상시험 제목</th><th>단계</th><th>검수상태</th><th>모집상태</th><th>관리</th></tr></thead><tbody>
<tr><td>8</td><td>차세대 유전자 치료제 임상 2/3상</td><td>2/3상</td><td><span class="badge badge-gray">검수대기</span></td><td><span class="badge badge-green">모집중</span></td><td><a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/business/trials/form">수정</a></td></tr>
<tr><td>7</td><td>헌팅턴병 치료제 효과 평가</td><td>2상</td><td><span class="badge badge-green">승인</span></td><td><span class="badge badge-green">모집중</span></td><td><a class="btn btn-sm btn-outline" href="#">수정</a></td></tr>
<tr><td>6</td><td>파브리병 효소대체요법</td><td>3상</td><td><span class="badge badge-red">반려</span></td><td><span class="badge badge-amber">모집예정</span></td><td><a class="btn btn-sm btn-outline" href="#">수정</a></td></tr>
</tbody></table></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>