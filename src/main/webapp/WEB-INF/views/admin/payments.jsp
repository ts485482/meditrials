<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>결제 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>결제 관리</h1></div>
<div class="stat-grid"><div class="stat-card"><span>결제 대기</span><strong>12건</strong></div><div class="stat-card"><span>결제 완료</span><strong>156건</strong></div><div class="stat-card"><span>취소/환불</span><strong>4건</strong></div></div>
<div class="table-card"><table class="table"><thead><tr><th>결제번호</th><th>기관명</th><th>요금제</th><th>금액</th><th>결제일</th><th>상태</th><th>관리</th></tr></thead><tbody><tr><td>P-1024</td><td>바이오메드 연구소</td><td>PREMIUM</td><td>99,000</td><td>08.21</td><td><span class="badge badge-green">결제완료</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>P-1023</td><td>헬스케어 제약</td><td>PREMIUM</td><td>99,000</td><td>08.21</td><td><span class="badge badge-gray">결제대기</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>P-1022</td><td>서울 임상센터</td><td>PREMIUM</td><td>99,000</td><td>08.20</td><td><span class="badge badge-green">결제완료</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr></tbody></table></div>
<div class="notice">MVP 단계에서는 TEST/MANUAL 결제 상태 관리로 실제 PG 결제를 대체합니다.</div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>