<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>임상시험 상세 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section"><div class="mt-container">
  <div class="row-between mb-20"><div><h1 class="section-title mb-10">차세대 유전자 치료제 임상 2/3상 연구</h1><span class="badge badge-green">모집중</span> <span class="badge badge-blue">2/3상</span> <span class="badge badge-gray">유전성 질환</span></div></div>
  <div class="detail-layout">
    <div>
      <section class="detail-section"><h2>연구 개요</h2><p>새로운 유전자 치료 기술을 활용한 희귀 유전 질환 치료제의 안전성과 유효성을 평가하는 임상시험입니다.</p></section>
      <section class="detail-section"><h2>대상 기준</h2><ul><li>만 18세 이상 유전성 질환 환자</li><li>관련 유전자 변이 보유자</li><li>기타 선정/제외 기준 충족자</li></ul></section>
      <section class="detail-section"><h2>기관 및 일정</h2><p><strong>연구 기관 :</strong> 서울대학교병원 외 14개 기관</p><p><strong>연구 기간 :</strong> 2024.05.01 ~ 2026.12.31</p></section>
    </div>
    <aside class="side-box"><h3>참여 문의</h3><p><strong>대표 기관</strong><br>서울대학교병원</p><p><strong>연락처</strong><br>02-123-4567</p><p><strong>이메일</strong><br>clinicaltrials@meditrials.kr</p><button class="btn btn-outline w-100">♡ 관심 등록</button><a class="btn btn-primary w-100 mt-20" href="${pageContext.request.contextPath}/trials/1/inquiries/new">참여 문의</a></aside>
  </div>
</div></main>
<%@ include file="/WEB-INF/views/common/footer.jsp" %></body></html>