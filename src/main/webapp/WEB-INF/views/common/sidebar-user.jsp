<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<aside class="sidebar">
  <a class="mt-logo" href="${pageContext.request.contextPath}/main"><span>MediTrials</span></a>
  <div class="sidebar-role">사용자</div>
  <nav class="side-nav">
    <a href="${pageContext.request.contextPath}/mypage">마이페이지</a>
    <a href="${pageContext.request.contextPath}/mypage/favorites?tab=diseases">관심 질환</a>
    <a href="${pageContext.request.contextPath}/mypage/favorites?tab=trials">관심 임상시험</a>
    <a href="${pageContext.request.contextPath}/mypage/inquiries">문의 내역</a>
    <a href="${pageContext.request.contextPath}/mypage/participations">참여 요청 내역</a>
    <a href="${pageContext.request.contextPath}/mypage/profile">회원정보 수정</a>
    <a href="${pageContext.request.contextPath}/mypage/password">비밀번호 변경</a>
  </nav>
  <form action="${pageContext.request.contextPath}/logout" method="post" style="margin:0;">
    <button class="side-logout" type="submit" style="border:0;background:none;padding:0;">로그아웃</button>
  </form>
</aside>
