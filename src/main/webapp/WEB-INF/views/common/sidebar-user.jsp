<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<aside class="sidebar">
  <a class="mt-logo" href="${pageContext.request.contextPath}/main"><span>MediTrials</span></a>
  <div class="sidebar-role">사용자</div>
  <nav class="side-nav">
    <a href="${pageContext.request.contextPath}/mypage">마이페이지</a>
<a href="${pageContext.request.contextPath}/mypage/favorites">관심 질환</a>
<a href="${pageContext.request.contextPath}/mypage/favorites">관심 임상시험</a>
<a href="${pageContext.request.contextPath}/mypage/inquiries">참여 문의 내역</a>
<a href="${pageContext.request.contextPath}#">회원정보 수정</a>
<a href="${pageContext.request.contextPath}#">비밀번호 변경</a>
  </nav>
  <a class="side-logout" href="${pageContext.request.contextPath}/logout">로그아웃</a>
</aside>
