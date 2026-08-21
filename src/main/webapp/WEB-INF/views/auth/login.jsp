<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>로그인 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="auth-wrap"><div class="auth-card">
  <h1>로그인</h1>
  <form>
    <div class="form-group"><label class="form-label">이메일</label><input class="form-control" type="email" placeholder="example@meditrials.kr"></div>
    <div class="form-group"><label class="form-label">비밀번호</label><input class="form-control" type="password" placeholder="••••••••"></div>
    <button type="button" class="btn btn-primary w-100" data-demo-alert="로그인 기능은 백엔드 연결 단계에서 적용합니다.">로그인</button>
  </form>
  <p class="text-center text-muted">계정이 없으신가요? <a class="link-blue" href="${pageContext.request.contextPath}/member/signup">회원가입</a></p>
  <div class="divider"></div>
  <p class="text-center"><a class="link-blue" href="${pageContext.request.contextPath}/business/signup">사업자이신가요? 기관 회원가입</a></p>
</div></main>
<%@ include file="/WEB-INF/views/common/footer.jsp" %></body></html>