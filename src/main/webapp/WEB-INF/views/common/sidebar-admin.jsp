<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<aside class="sidebar">
  <a class="mt-logo" href="${pageContext.request.contextPath}/main"><span>MediTrials</span></a>
  <div class="sidebar-role">관리자</div>
  <nav class="side-nav">
    <a href="${pageContext.request.contextPath}/admin">대시보드</a>
    <a href="${pageContext.request.contextPath}/admin/businesses">사업자 관리</a>
    <a href="${pageContext.request.contextPath}/admin/trials">임상시험 검수</a>
    <a href="${pageContext.request.contextPath}/admin/members">회원 관리</a>
    <a href="${pageContext.request.contextPath}/admin/plans">요금제 관리</a>
    <a href="${pageContext.request.contextPath}/admin/payments">결제 관리</a>
    <a href="${pageContext.request.contextPath}/admin/promotions">프리미엄 노출</a>
    <a href="${pageContext.request.contextPath}/admin/revenue">매출 관리</a>
  </nav>
  <form action="${pageContext.request.contextPath}/logout" method="post" style="margin:0;">
    <button class="side-logout" type="submit" style="border:0;background:none;padding:0;">로그아웃</button>
  </form>
</aside>
