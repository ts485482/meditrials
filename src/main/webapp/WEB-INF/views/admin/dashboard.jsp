<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>관리자 대시보드 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>관리자 대시보드</h1></div>
<div class="stat-grid six"><div class="stat-card"><span>회원 수</span><strong>12,458</strong></div><div class="stat-card"><span>사업자 수</span><strong>1,236</strong></div><div class="stat-card"><span>임상시험 수</span><strong>892</strong></div><div class="stat-card"><span>문의 수</span><strong>521</strong></div><div class="stat-card"><span>프리미엄</span><strong>156</strong></div><div class="stat-card"><span>이번 달 매출</span><strong style="font-size:20px">₩24.58M</strong></div></div>
<div class="content-grid-3"><div class="card"><h3>사업자 승인 관리</h3><p>신규 승인 대기 <strong>18건</strong></p><p>승인 완료(이번 달) <strong>46건</strong></p></div><div class="card"><h3>임상시험 검수</h3><p>검수 대기 <strong>27건</strong></p><p>반려(이번 달) <strong>8건</strong></p></div><div class="card"><h3>프리미엄/매출</h3><p>프리미엄 사용 <strong>156건</strong></p><p>이번 달 매출 <strong>₩24,580,000</strong></p></div></div>
<div class="table-card mt-20"><h3>최근 처리 내역</h3><table class="table"><thead><tr><th>일시</th><th>구분</th><th>대상</th><th>처리</th><th>관리자</th></tr></thead><tbody><tr><td>08.21 09:30</td><td>사업자</td><td>바이오메드 연구소</td><td>승인</td><td>admin</td></tr><tr><td>08.21 09:10</td><td>임상시험</td><td>차세대 유전자 치료제</td><td>검수승인</td><td>admin</td></tr><tr><td>08.20 16:40</td><td>프리미엄</td><td>세브란스병원</td><td>활성</td><td>admin</td></tr></tbody></table></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>