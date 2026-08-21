<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>일반 회원가입 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-signup.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section">
  <div class="mt-container">
    <div class="card member-signup-card">
      <h1 class="section-title">일반 회원가입</h1>
      <p class="text-muted" style="margin-top:-10px;margin-bottom:24px;font-size:13px;">모든 항목은 필수 입력입니다.</p>

      <div id="signupError" class="signup-message signup-message-error" aria-live="polite"></div>
      <input type="hidden" id="serverErrorCode" value="${errorCode}">

      <form id="memberSignupForm"
            action="${pageContext.request.contextPath}/member/signup"
            method="post"
            data-context-path="${pageContext.request.contextPath}"
            novalidate>

        <div class="form-group">
          <label class="form-label" for="email">이메일</label>
          <div class="form-inline">
            <input class="form-control" id="email" name="email" type="email"
                   autocomplete="email" placeholder="example@meditrials.kr" value="${email}" required aria-required="true">
            <button class="btn btn-light" id="emailCheckButton" type="button">중복 확인</button>
          </div>
          <div id="emailCheckMessage" class="signup-field-message" aria-live="polite"></div>
        </div>

        <div class="form-group">
          <label class="form-label" for="password">비밀번호</label>
          <input class="form-control" id="password" name="password" type="password"
                 autocomplete="new-password" minlength="8" aria-describedby="passwordGuide" required aria-required="true">
          <div id="passwordGuide" class="text-muted" style="margin-top:8px;font-size:13px;">
            8자 이상, 영문자와 특수문자를 각각 1자 이상 포함해주세요.
          </div>
        </div>

        <div class="form-group">
          <label class="form-label" for="passwordConfirm">비밀번호 확인</label>
          <input class="form-control" id="passwordConfirm" name="passwordConfirm" type="password"
                 autocomplete="new-password" minlength="8" required aria-required="true">
        </div>

        <div class="form-group">
          <label class="form-label" for="memberName">이름</label>
          <input class="form-control" id="memberName" name="memberName" type="text"
                 autocomplete="name" value="${memberName}" required aria-required="true">
        </div>

        <div class="form-group">
          <label class="form-label" for="phone">연락처</label>
          <input class="form-control" id="phone" name="phone" type="tel"
                 autocomplete="tel" placeholder="010-1234-5678" value="${phone}" required aria-required="true">
        </div>

        <div class="member-signup-actions">
          <button class="btn btn-primary" type="submit">회원가입</button>
        </div>
      </form>
    </div>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/member-signup.js"></script>
</body>
</html>
