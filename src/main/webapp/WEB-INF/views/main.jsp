<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>메인 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="mt-main main-page">
  <section class="mt-container main-hero" aria-labelledby="mainHeroTitle">
    <div class="main-hero-copy">
      <h1 id="mainHeroTitle">희귀질환, 희망을 찾는 여정</h1>
      <h2>MediTrials가 임상시험 참여의 기회를 연결합니다.</h2>
      <p>신뢰할 수 있는 정보를 기반으로 더 나은 치료의 가능성을 함께 만들어갑니다.</p>
      <a class="btn btn-primary main-hero-button" href="${pageContext.request.contextPath}/support">서비스 소개 보기</a>
    </div>

    <div class="main-hero-visual" aria-hidden="true">
      <span class="dna-line line-1"></span>
      <span class="dna-line line-2"></span>
      <span class="dna-line line-3"></span>
      <span class="dna-line line-4"></span>
      <span class="dna-line line-5"></span>
      <span class="dna-dot dot-1"></span>
      <span class="dna-dot dot-2"></span>
      <span class="dna-dot dot-3"></span>
      <span class="dna-dot dot-4"></span>
    </div>
  </section>

  <section class="mt-container main-benefits" aria-label="MediTrials 주요 특징">
    <article class="main-benefit">
      <span class="main-benefit-icon"></span>
      <div><strong>신뢰할 수 있는 정보</strong><span>검증된 임상시험</span></div>
    </article>
    <article class="main-benefit">
      <span class="main-benefit-icon"></span>
      <div><strong>맞춤형 탐색</strong><span>나에게 맞는 시험</span></div>
    </article>
    <article class="main-benefit">
      <span class="main-benefit-icon"></span>
      <div><strong>안전한 참여 지원</strong><span>참여 전 과정 안내</span></div>
    </article>
    <article class="main-benefit">
      <span class="main-benefit-icon"></span>
      <div><strong>지속적인 업데이트</strong><span>최신 연구정보</span></div>
    </article>
  </section>

  <section class="mt-container main-content-grid">
    <article class="main-panel disease-panel">
      <h2>주요 질환</h2>
      <div class="main-disease-grid">
        <a href="${pageContext.request.contextPath}/diseases?category=rare"><span class="disease-symbol"></span><strong>희귀질환</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=intractable"><span class="disease-symbol"></span><strong>난치성 질환</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=genetic"><span class="disease-symbol"></span><strong>유전성 질환</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=neurology"><span class="disease-symbol"></span><strong>신경계 질환</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=oncology"><span class="disease-symbol"></span><strong>종양질환</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=respiratory"><span class="disease-symbol"></span><strong>호흡기 질환</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=immune"><span class="disease-symbol"></span><strong>면역질환</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=etc"><span class="disease-symbol"></span><strong>기타 질환</strong></a>
      </div>
    </article>

    <article class="main-panel today-trial-panel">
      <div class="main-panel-head">
        <h2>오늘의 임상시험</h2>
        <a href="${pageContext.request.contextPath}/trials">전체보기</a>
      </div>
      <ul class="today-trial-list">
        <li><a href="${pageContext.request.contextPath}/trials/1">파브리병 유전자 치료제 임상 2상</a><span class="status-pill recruiting">모집중</span></li>
        <li><a href="${pageContext.request.contextPath}/trials/2">낭포성 섬유증 표적 치료제 2상</a><span class="status-pill recruiting">모집중</span></li>
        <li><a href="${pageContext.request.contextPath}/trials/3">ALS 줄기세포 치료제 임상 1/2상</a><span class="status-pill recruiting">모집중</span></li>
        <li><a href="${pageContext.request.contextPath}/trials/4">뒤센형 근이영양증 임상 2상</a><span class="status-pill recruiting">모집중</span></li>
        <li><a href="${pageContext.request.contextPath}/trials/5">샤르코마리투스병 유전자 치료제 1상</a><span class="status-pill recruiting">모집중</span></li>
      </ul>
    </article>

    <article class="premium-trial-panel">
      <span class="premium-label">★ 프리미엄 추천 임상시험</span>
      <h2>차세대 유전자 치료제<br>임상 2/3상 연구</h2>
      <p>희귀 유전 질환 대상<br>전국 주요 병원 모집 중</p>
      <a class="premium-detail-button" href="${pageContext.request.contextPath}/trials/1">자세히 보기 →</a>
    </article>
  </section>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
