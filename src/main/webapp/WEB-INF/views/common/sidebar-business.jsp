<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<aside class="sidebar">
  <a class="mt-logo" href="${pageContext.request.contextPath}/main"><span>MediTrials</span></a>
  <div class="sidebar-role">사업자 센터</div>
  <nav class="side-nav">
    <a href="${pageContext.request.contextPath}/business">대시보드</a>
    <a href="${pageContext.request.contextPath}/business/trials">임상시험 관리</a>
    <a href="${pageContext.request.contextPath}/business/inquiries">문의 관리</a>
    <a href="${pageContext.request.contextPath}/business/plans">요금제/프리미엄</a>
    <a href="${pageContext.request.contextPath}/business/stats">통계</a>
    <a href="${pageContext.request.contextPath}/business/profile">기관정보 관리</a>
  </nav>
  <form action="${pageContext.request.contextPath}/logout" method="post" style="margin:0;">
    <button class="side-logout" type="submit" style="border:0;background:none;padding:0;">로그아웃</button>
  </form>
</aside>
