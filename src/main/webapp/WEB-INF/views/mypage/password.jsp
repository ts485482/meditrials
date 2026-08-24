<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }
%>
<%
    String passwordSuccess = request.getAttribute("passwordSuccess") instanceof String value ? value : null;
    String passwordError = request.getAttribute("passwordError") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>비밀번호 변경 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head mypage-head">
      <div>
        <h1>비밀번호 변경</h1>
        <p class="text-muted">현재 비밀번호 확인 후 새 비밀번호로 변경합니다.</p>
      </div>
    </div>

    <% if (passwordSuccess != null) { %>
      <div class="mypage-message mypage-message-success"><%= h(passwordSuccess) %></div>
    <% } %>
    <% if (passwordError != null) { %>
      <div class="mypage-message mypage-message-error"><%= h(passwordError) %></div>
    <% } %>

    <section class="mypage-form-card">
      <div class="notice mypage-password-guide">
        비밀번호는 8자 이상이며 영문자와 특수문자를 각각 1개 이상 포함해야 합니다.
      </div>
      <form method="post" action="${pageContext.request.contextPath}/mypage/password" autocomplete="off">
        <div class="form-group">
          <label class="form-label" for="currentPassword">현재 비밀번호</label>
          <input class="form-control" id="currentPassword" name="currentPassword" type="password" required autocomplete="current-password">
        </div>
        <div class="form-group">
          <label class="form-label" for="newPassword">새 비밀번호</label>
          <input class="form-control" id="newPassword" name="newPassword" type="password" minlength="8" required autocomplete="new-password">
        </div>
        <div class="form-group">
          <label class="form-label" for="passwordConfirm">새 비밀번호 확인</label>
          <input class="form-control" id="passwordConfirm" name="passwordConfirm" type="password" minlength="8" required autocomplete="new-password">
        </div>
        <div class="mypage-form-actions">
          <a class="btn btn-outline" href="${pageContext.request.contextPath}/mypage">취소</a>
          <button class="btn btn-primary" type="submit">비밀번호 변경</button>
        </div>
      </form>
    </section>
  </main>
</div>
</body>
</html>
