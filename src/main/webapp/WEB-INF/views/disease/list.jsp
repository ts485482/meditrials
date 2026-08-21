<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>질환 검색 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section"><div class="mt-container">
  <h1 class="section-title">질환 검색</h1>
  <div class="search-panel">
    <div class="form-inline"><input class="form-control" placeholder="질환명 또는 키워드"><button class="btn btn-primary">검색</button></div>
    <div class="tabs mt-20"><a class="tab active">전체</a><a class="tab">희귀질환</a><a class="tab">신경계</a><a class="tab">유전성</a><a class="tab">호흡기</a><a class="tab">면역질환</a></div>
  </div>
  <h3>질환 검색 결과 <span class="text-muted">총 32건</span></h3>
  <div class="content-grid-2">
    <a class="result-card" href="${pageContext.request.contextPath}/diseases/1"><h3>헌팅턴병</h3><div class="result-meta"><span>유전성 · 신경계 질환</span><span>관련 임상시험 8건</span></div></a>
    <a class="result-card" href="#"><h3>파브리병</h3><div class="result-meta"><span>유전성 · 대사 질환</span><span>관련 임상시험 5건</span></div></a>
    <a class="result-card" href="#"><h3>근위축성 측삭경화증 (ALS)</h3><div class="result-meta"><span>신경계 질환</span><span>관련 임상시험 12건</span></div></a>
    <a class="result-card" href="#"><h3>낭포성 섬유증</h3><div class="result-meta"><span>유전성 · 호흡기 질환</span><span>관련 임상시험 6건</span></div></a>
    <a class="result-card" href="#"><h3>샤르코마리투스병 (CMT)</h3><div class="result-meta"><span>유전성 · 신경계 질환</span><span>관련 임상시험 2건</span></div></a>
  </div>
</div></main>
<%@ include file="/WEB-INF/views/common/footer.jsp" %></body></html>