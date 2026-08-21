<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>사업자 승인 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>사업자 승인 관리</h1></div>
<div class="table-card"><table class="table"><thead><tr><th>번호</th><th>기관명</th><th>기관유형</th><th>신청일</th><th>상태</th><th>관리</th></tr></thead><tbody><tr><td>18</td><td>바이오메드 연구소</td><td>연구기관</td><td>08.21</td><td><span class="badge badge-gray">승인대기</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>17</td><td>헬스케어 제약</td><td>제약사</td><td>08.20</td><td><span class="badge badge-gray">승인대기</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>16</td><td>서울 임상센터</td><td>병원</td><td>08.20</td><td><span class="badge badge-green">승인</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr></tbody></table></div>
<div class="card"><h3>사업자 상세</h3><div class="content-grid-2"><p><strong>기관명</strong><br>바이오메드 연구소</p><p><strong>기관 유형</strong><br>연구기관</p><p><strong>사업자등록번호</strong><br>123-45-67890</p><p><strong>연락처</strong><br>02-1234-5678</p></div><p><strong>주소</strong><br>서울특별시 종로구...</p><div style="text-align:right"><button class="btn btn-danger">반려</button> <button class="btn btn-primary">승인</button></div></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>