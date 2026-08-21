<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>임상시험 검색 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section"><div class="mt-container">
  <h1 class="section-title">임상시험 검색</h1>
  <div class="search-panel">
    <h3>상세 검색</h3>
    <div class="filter-row">
      <div class="filter-item"><label>키워드</label><input class="form-control" placeholder="질환명 또는 임상시험명"></div>
      <div class="filter-item"><label>모집 상태</label><select class="form-control"><option>전체</option><option>모집중</option><option>모집예정</option><option>모집완료</option></select></div>
      <div class="filter-item"><label>임상 단계</label><select class="form-control"><option>전체</option><option>1상</option><option>1/2상</option><option>2상</option><option>2/3상</option><option>3상</option></select></div>
      <button class="btn btn-primary">검색하기</button>
    </div>
  </div>
  <div class="row-between"><h3>임상시험 검색 결과</h3><select class="form-control" style="width:180px"><option>모집 종료 임박순</option><option>최신순</option></select></div>
  <a class="result-card" href="${pageContext.request.contextPath}/trials/1"><div class="row-between"><h3>차세대 유전자 치료제 임상 2/3상 연구</h3><span class="badge badge-green">모집중</span></div><div class="result-meta"><span>2/3상</span><span>유전성 질환</span><span>2024.05.01 ~ 2026.12.31</span><span>전국 15개 기관</span></div></a>
  <div class="result-card"><div class="row-between"><h3>헌팅턴병 세포치료 표적 치료제 연구</h3><span class="badge badge-green">모집중</span></div><div class="result-meta"><span>1/2상</span><span>신경계 질환</span><span>서울대학교병원 외 8개 기관</span></div></div>
  <div class="result-card"><div class="row-between"><h3>낭포성 섬유증 신약 치료제 2상 임상</h3><span class="badge badge-green">모집중</span></div><div class="result-meta"><span>2상</span><span>호흡기 질환</span><span>전국 9개 기관</span></div></div>
  <div class="result-card"><div class="row-between"><h3>파브리병 유전자 치료제 임상 1/2상</h3><span class="badge badge-green">모집중</span></div><div class="result-meta"><span>1/2상</span><span>유전성 질환</span><span>세브란스병원 외 4개 기관</span></div></div>
</div></main>
<%@ include file="/WEB-INF/views/common/footer.jsp" %></body></html>