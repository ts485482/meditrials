<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="mt-header">
  <div class="mt-container mt-header-inner">
    <a class="mt-logo" href="${pageContext.request.contextPath}/main" aria-label="MediTrials 메인으로 이동">
      <span class="mt-logo-mark" aria-hidden="true"><i></i><i></i><i></i></span>
      <span>MediTrials</span>
    </a>

    <nav class="mt-nav" aria-label="주요 메뉴">
      <a href="${pageContext.request.contextPath}/diseases">질환정보</a>
      <a href="${pageContext.request.contextPath}/trials">임상시험 검색</a>
      <a href="${pageContext.request.contextPath}/mypage/inquiries">참여문의</a>
      <a href="${pageContext.request.contextPath}/support">고객센터</a>
    </nav>

    <form class="mt-search" action="${pageContext.request.contextPath}/search" method="get" role="search">
      <input type="search" name="keyword" placeholder="질환명 또는 임상시험 키워드" aria-label="통합 검색어">
    </form>

    <%-- 로그인 기능 연결 전 비로그인 상태 UI --%>
    <div class="mt-auth">
      <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/login">로그인</a>
      <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/member/signup">회원가입</a>
    </div>
  </div>
</header>
