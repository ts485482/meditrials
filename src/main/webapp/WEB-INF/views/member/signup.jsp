<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>일반 회원가입 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section"><div class="mt-container"><div class="card" style="max-width:850px;margin:0 auto">
  <h1 class="section-title">일반 회원가입</h1>
  <div class="form-group"><label class="form-label">이메일</label><div class="form-inline"><input class="form-control"><button class="btn btn-light" data-demo-alert="사용 가능한 이메일입니다.">중복 확인</button></div></div>
  <div class="form-group"><label class="form-label">비밀번호</label><input class="form-control" type="password"></div>
  <div class="form-group"><label class="form-label">비밀번호 확인</label><input class="form-control" type="password"></div>
  <div class="form-group"><label class="form-label">이름</label><input class="form-control"></div>
  <div class="form-group"><label class="form-label">연락처</label><input class="form-control"></div>
  <div style="text-align:right;margin-top:28px"><button class="btn btn-primary" data-demo-alert="회원가입 기능은 MEMBER 연동 단계에서 적용합니다.">회원가입</button></div>
</div></div></main>
<%@ include file="/WEB-INF/views/common/footer.jsp" %></body></html>