<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>회원 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>회원 관리</h1></div>
<div class="search-panel"><div class="form-inline"><input class="form-control" placeholder="이메일 또는 이름 검색"><button class="btn btn-primary">검색</button></div></div>
<div class="table-card"><table class="table"><thead><tr><th>번호</th><th>이메일</th><th>이름</th><th>가입일</th><th>역할</th><th>상태</th><th>관리</th></tr></thead><tbody><tr><td>12458</td><td>hong@sample.kr</td><td>홍길동</td><td>08.21</td><td>USER</td><td><span class="badge badge-green">정상</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>12457</td><td>kim@sample.kr</td><td>김민수</td><td>08.21</td><td>USER</td><td><span class="badge badge-green">정상</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>12456</td><td>lee@sample.kr</td><td>이영희</td><td>08.20</td><td>USER</td><td><span class="badge badge-red">정지</span></td><td><button class="btn btn-sm btn-success">정지 해제</button></td></tr></tbody></table></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>