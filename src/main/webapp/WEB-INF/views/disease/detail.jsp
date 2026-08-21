<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>질환 상세 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section"><div class="mt-container">
  <div class="row-between mb-20"><div><h1 class="section-title mb-10">헌팅턴병 <span style="font-size:20px">(Huntington’s Disease)</span></h1><span class="badge badge-blue">유전성 질환</span> <span class="badge badge-blue">신경계 질환</span> <span class="badge badge-amber">희귀</span></div><button class="btn btn-outline">♡ 관심 등록</button></div>
  <div class="detail-layout">
    <div>
      <section class="detail-section"><h2>질환 개요</h2><p>헌팅턴병은 유전적 원인으로 발생하는 진행성 신경계 질환으로, 운동·인지·행동 변화가 나타날 수 있습니다.</p></section>
      <section class="detail-section"><h2>주요 증상</h2><p>불수의적 움직임, 균형 저하, 인지기능 변화, 정서 및 행동 변화 등이 나타날 수 있습니다.</p></section>
      <section class="detail-section"><h2>관련 임상시험</h2><div class="result-card"><h3>헌팅턴병 세포치료 표적 치료제 연구</h3><div class="result-meta"><span class="badge badge-green">모집중</span><span>1/2상</span><span>서울대학교병원 외 8개 기관</span></div></div></section>
    </div>
    <aside class="side-box"><h3>정보 출처</h3><p class="text-muted">희귀질환 공개 데이터 및 MediTrials 검증 정보</p><a class="link-blue" href="${pageContext.request.contextPath}/trials">관련 임상시험 전체 보기 →</a></aside>
  </div>
</div></main>
<%@ include file="/WEB-INF/views/common/footer.jsp" %></body></html>