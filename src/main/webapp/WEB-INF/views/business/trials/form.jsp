<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>임상시험 등록/수정 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>임상시험 등록</h1></div>
<div class="card">
  <div class="content-grid-2">
    <div><div class="form-group"><label class="form-label">임상시험 제목</label><input class="form-control"></div><div class="form-group"><label class="form-label">대상 질환</label><input class="form-control"></div><div class="form-group"><label class="form-label">임상 단계</label><select class="form-control"><option>선택</option><option>1상</option><option>1/2상</option><option>2상</option><option>2/3상</option><option>3상</option></select></div><div class="form-group"><label class="form-label">모집 상태</label><select class="form-control"><option>선택</option><option>모집예정</option><option>모집중</option><option>모집완료</option></select></div></div>
    <div><div class="form-group"><label class="form-label">모집 인원</label><input class="form-control" type="number"></div><div class="form-group"><label class="form-label">연구 기관</label><input class="form-control"></div><div class="form-group"><label class="form-label">연구 기간</label><div class="form-inline"><input class="form-control" type="date"><input class="form-control" type="date"></div></div><div class="form-group"><label class="form-label">연락처</label><input class="form-control"></div></div>
  </div>
  <div class="form-group"><label class="form-label">연구 목적</label><textarea class="form-control"></textarea></div>
  <div class="form-group"><label class="form-label">참여 조건</label><textarea class="form-control"></textarea></div>
  <div style="text-align:right"><button class="btn btn-outline" data-demo-alert="DRAFT 상태로 저장됩니다.">임시 저장</button> <button class="btn btn-primary" data-demo-alert="PENDING 상태로 검수 요청됩니다.">검수 요청</button></div>
</div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>