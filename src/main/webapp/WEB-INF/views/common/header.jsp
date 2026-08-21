<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="mt-header">
  <div class="mt-container mt-header-inner">
    <a class="mt-logo" href="${pageContext.request.contextPath}/main">
      <span class="mt-logo-mark"><i></i><i></i><i></i></span><span>MediTrials</span>
    </a>
    <nav class="mt-nav">
      <a href="${pageContext.request.contextPath}/diseases">질환정보</a>
      <a href="${pageContext.request.contextPath}/trials">임상시험 검색</a>
      <a href="${pageContext.request.contextPath}/mypage/inquiries">참여문의</a>
      <a href="${pageContext.request.contextPath}/support">고객센터</a>
    </nav>
    <form class="mt-search" action="${pageContext.request.contextPath}/search" method="get">
      <input name="keyword" placeholder="질환명 또는 임상시험 키워드">
    </form>
    <!-- 화면 목업 단계: 실제 로그인 상태 분기는 Spring Security 연동 시 적용 -->
    <div class="mt-auth">
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/login">로그인</a>
      <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/member/signup">회원가입</a>
    </div>
  </div>
</header>
