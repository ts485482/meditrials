<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 | MediTrials</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
</head>
<body class="login-page">
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="login-screen">
    <section class="login-panel" aria-labelledby="loginTitle">
        <h1 id="loginTitle" class="login-title">로그인</h1>

        <form
            id="loginForm"
            class="login-form"
            action="${pageContext.request.contextPath}/login"
            method="post"
            data-error-code="${loginErrorCode}"
            novalidate
        >
            <div class="login-field">
                <label for="email" class="login-label">이메일</label>
                <input
                    id="email"
                    name="email"
                    class="login-input"
                    type="email"
                    placeholder="example@meditrials.kr"
                    autocomplete="username"
                    maxlength="100"
                    required
                >
                <p id="emailError" class="login-error" aria-live="polite"></p>
            </div>

            <div class="login-field">
                <label for="password" class="login-label">비밀번호</label>
                <input
                    id="password"
                    name="password"
                    class="login-input"
                    type="password"
                    placeholder="••••••••"
                    autocomplete="current-password"
                    maxlength="100"
                    required
                >
                <p id="passwordError" class="login-error" aria-live="polite"></p>
            </div>

            <button type="submit" class="login-submit">로그인</button>
            <p id="loginMessage" class="login-message" aria-live="polite"></p>
        </form>

        <p class="login-signup-guide">
            <span>계정이 없으신가요?</span>
            <a href="${pageContext.request.contextPath}/member/signup">회원가입</a>
        </p>

        <div class="login-divider" aria-hidden="true"></div>

        <a class="business-signup-link" href="${pageContext.request.contextPath}/business/signup">
            사업자이신가요? <strong>기관 회원가입</strong>
        </a>
    </section>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/login.js"></script>
</body>
</html>
