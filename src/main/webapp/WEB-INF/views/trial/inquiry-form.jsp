<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>참여 문의 작성 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>임상시험 참여 문의</h1></div>
<div class="card" style="max-width:800px">
  <div class="row-between"><h2>차세대 유전자 치료제 임상 2/3상 연구</h2><span class="badge badge-green">모집중</span></div>
  <div class="form-group"><label class="form-label">문의 제목</label><input class="form-control"></div>
  <div class="form-group"><label class="form-label">문의 내용</label><textarea class="form-control" placeholder="참여 조건, 일정, 방문 기관 등에 대해 문의할 내용을 작성해주세요."></textarea></div>
  <label style="display:flex;gap:8px;align-items:center"><input type="checkbox"> 개인정보 수집 및 문의 전달에 동의합니다.</label>
  <div style="text-align:right;margin-top:24px"><a class="btn btn-outline" href="${pageContext.request.contextPath}/trials/1">취소</a> <button class="btn btn-primary" data-demo-alert="문의가 등록되었습니다.">문의 등록</button></div>
</div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>