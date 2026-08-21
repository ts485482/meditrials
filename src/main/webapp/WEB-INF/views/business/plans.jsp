<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>요금제/프리미엄 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>요금제 / 프리미엄</h1></div>
<div class="plan-grid">
  <div class="plan-card"><h2>FREE</h2><div class="price">₩0</div><ul><li>임상시험 등록/수정</li><li>참여문의 확인/답변</li><li>기본 모집상태 관리</li></ul></div>
  <div class="plan-card premium"><span class="badge badge-blue">추천</span><h2>PREMIUM</h2><div class="price">₩99,000 <small style="font-size:14px">/월</small></div><ul><li>메인/검색 우선 노출</li><li>조회수·관심등록·문의 통계</li><li>프리미엄 임상시험 홍보</li><li>기간별 모집성과 확인</li></ul><button class="btn btn-primary w-100" data-demo-alert="프리미엄 신청이 생성됩니다.">프리미엄 이용 신청</button></div>
</div>
<div class="card mt-20"><h3>현재 이용 상태</h3><p>현재 요금제 <strong>FREE</strong></p><p>프리미엄 신청 상태 <span class="badge badge-gray">미신청</span></p></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>