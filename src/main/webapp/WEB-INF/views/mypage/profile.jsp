<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="meditrials.meditrials.member.vo.MemberVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd"));
    }
%>
<%
    MemberVO member = request.getAttribute("member") instanceof MemberVO value ? value : null;
    String profileSuccess = request.getAttribute("profileSuccess") instanceof String value ? value : null;
    String profileError = request.getAttribute("profileError") instanceof String value ? value : null;
    String formMemberName = request.getAttribute("formMemberName") instanceof String value ? value : null;
    String formPhone = request.getAttribute("formPhone") instanceof String value ? value : null;

    String memberNameValue = formMemberName != null ? formMemberName : (member == null ? "" : member.getMemberName());
    String phoneValue = formPhone != null ? formPhone : (member == null ? "" : member.getPhone());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>회원정보 수정 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head mypage-head">
      <div>
        <h1>회원정보 수정</h1>
        <p class="text-muted">로그인 이메일은 유지하고 이름과 연락처를 수정할 수 있습니다.</p>
      </div>
    </div>

    <% if (profileSuccess != null) { %>
      <div class="mypage-message mypage-message-success"><%= h(profileSuccess) %></div>
    <% } %>
    <% if (profileError != null) { %>
      <div class="mypage-message mypage-message-error"><%= h(profileError) %></div>
    <% } %>

    <% if (member == null) { %>
      <div class="notice">회원 정보를 찾을 수 없습니다.</div>
    <% } else { %>
      <section class="mypage-form-card">
        <div class="mypage-account-summary">
          <div><span>로그인 이메일</span><strong><%= h(member.getEmail()) %></strong></div>
          <div><span>가입일</span><strong><%= h(formatDate(member.getCreatedAt())) %></strong></div>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/mypage/profile">
          <div class="form-group">
            <label class="form-label" for="memberName">이름</label>
            <input class="form-control" id="memberName" name="memberName" type="text" maxlength="100"
                   value="<%= h(memberNameValue) %>" required>
          </div>
          <div class="form-group">
            <label class="form-label" for="phone">연락처</label>
            <input class="form-control" id="phone" name="phone" type="text" maxlength="30"
                   value="<%= h(phoneValue) %>" required placeholder="010-1234-5678">
          </div>
          <div class="mypage-form-actions">
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/mypage">취소</a>
            <button class="btn btn-primary" type="submit">회원정보 저장</button>
          </div>
        </form>
      </section>
    <% } %>
  </main>
</div>
</body>
</html>
