<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>요금제 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>요금제 관리</h1></div>
<div class="plan-grid"><div class="plan-card"><h2>FREE</h2><div class="price">₩0</div><ul><li>임상시험 등록/수정</li><li>문의 확인/답변</li></ul></div><div class="plan-card premium"><h2>PREMIUM</h2><div class="price">₩99,000</div><ul><li>우선 노출</li><li>조회/관심/문의 통계</li><li>모집성과 분석</li></ul></div></div>
<div class="card mt-20"><h3>요금제 정책 설정</h3><div class="form-inline" style="max-width:420px"><input class="form-control" value="99000"><span style="padding:12px">원</span><button class="btn btn-primary" data-demo-alert="변경된 정책은 신규 신청부터 적용됩니다.">정책 저장</button></div></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>