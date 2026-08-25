<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Object loginMemberNo = session.getAttribute("LOGIN_MEMBER_NO");
    String loginMemberRole = (String) session.getAttribute("LOGIN_MEMBER_ROLE");
    String memberInfoPath = "/mypage";

    if ("BUSINESS".equals(loginMemberRole)) {
        memberInfoPath = "/business";
    } else if ("ADMIN".equals(loginMemberRole)) {
        memberInfoPath = "/admin";
    }
%>
<header class="mt-header">
  <div class="mt-container mt-header-inner">
    <a class="mt-logo" href="${pageContext.request.contextPath}/main" aria-label="MediTrials 메인으로 이동">
      <span class="mt-logo-mark" aria-hidden="true"><i></i><i></i><i></i></span>
      <span>MediTrials</span>
    </a>

    <nav class="mt-nav" aria-label="주요 메뉴">
      <a href="${pageContext.request.contextPath}/diseases">질환정보</a>
      <a href="${pageContext.request.contextPath}/trials">임상시험 검색</a>
      <a href="${pageContext.request.contextPath}/mypage/inquiries">문의내역</a>
      <a href="${pageContext.request.contextPath}/support">고객센터</a>
    </nav>

    <form class="mt-search" action="${pageContext.request.contextPath}/search" method="get" role="search">
      <input type="search" name="keyword" maxlength="100" placeholder="질환명 또는 임상시험 키워드" aria-label="통합 검색어">
      <button type="submit" aria-label="통합검색 실행">검색</button>
    </form>

    <div class="mt-auth">
      <% if (loginMemberNo == null) { %>
        <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/login">로그인</a>
        <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/member/signup">회원가입</a>
      <% } else { %>
        <a class="btn btn-primary btn-sm" href="<%= request.getContextPath() %><%= memberInfoPath %>">내 정보</a>
        <form action="${pageContext.request.contextPath}/logout" method="post" style="margin:0">
          <button type="submit" class="btn btn-outline btn-sm">로그아웃</button>
        </form>
      <% } %>
    </div>
  </div>
</header>
