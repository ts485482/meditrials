<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>메인 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="mt-main">
  <section class="mt-container hero">
    <div>
      <h1>희귀질환, 희망을 찾는 여정</h1>
      <h2>MediTrials가 임상시험 참여의 기회를 연결합니다.</h2>
      <p>신뢰할 수 있는 정보를 기반으로 더 나은 치료의 가능성을 함께 만들어갑니다.</p>
      <button class="btn btn-primary">서비스 소개 보기</button>
    </div>
    <div class="hero-graphic"><span class="hero-dot d1"></span><span class="hero-dot d2"></span><span class="hero-dot d3"></span><span class="hero-dot d4"></span></div>
  </section>
  <section class="mt-container feature-row">
    <div class="feature"><span class="feature-icon"></span><div><strong>신뢰할 수 있는 정보</strong><span>검증된 임상시험</span></div></div>
    <div class="feature"><span class="feature-icon"></span><div><strong>맞춤형 탐색</strong><span>나에게 맞는 시험</span></div></div>
    <div class="feature"><span class="feature-icon"></span><div><strong>안전한 참여 지원</strong><span>참여 전 과정 안내</span></div></div>
    <div class="feature"><span class="feature-icon"></span><div><strong>지속적인 업데이트</strong><span>최신 연구정보</span></div></div>
  </section>
  <section class="mt-container grid-3">
    <div class="card">
      <h2>주요 질환</h2>
      <div class="category-grid">
        <a class="category" href="${pageContext.request.contextPath}/diseases"><div class="circle"></div>희귀질환</a>
        <a class="category" href="#"><div class="circle"></div>난치성 질환</a>
        <a class="category" href="#"><div class="circle"></div>유전성 질환</a>
        <a class="category" href="#"><div class="circle"></div>신경계 질환</a>
        <a class="category" href="#"><div class="circle"></div>종양질환</a>
        <a class="category" href="#"><div class="circle"></div>호흡기 질환</a>
        <a class="category" href="#"><div class="circle"></div>면역질환</a>
        <a class="category" href="#"><div class="circle"></div>기타 질환</a>
      </div>
    </div>
    <div class="card">
      <h2>오늘의 임상시험</h2>
      <ul class="list-clean">
        <li class="row-between"><span>파브리병 유전자 치료제 임상 2상</span><span class="badge badge-green">모집중</span></li>
        <li class="row-between"><span>낭포성 섬유증 표적 치료제 2상</span><span class="badge badge-green">모집중</span></li>
        <li class="row-between"><span>ALS 줄기세포 치료제 임상 1/2상</span><span class="badge badge-green">모집중</span></li>
        <li class="row-between"><span>뒤센형 근이영양증 임상 2상</span><span class="badge badge-green">모집중</span></li>
        <li class="row-between"><span>샤르코마리투스병 유전자 치료제 1상</span><span class="badge badge-green">모집중</span></li>
      </ul>
    </div>
    <div class="card premium-card">
      <h3>★ 프리미엄 추천 임상시험</h3>
      <h2 style="font-size:27px;line-height:1.4">차세대 유전자 치료제<br>임상 2/3상 연구</h2>
      <p style="color:#dce9ff">희귀 유전 질환 대상<br>전국 주요 병원 모집 중</p>
      <a class="btn w-100" style="background:#fff;color:#173f79;margin-top:20px" href="${pageContext.request.contextPath}/trials/1">자세히 보기 →</a>
    </div>
  </section>
</main>
<%@ include file="/WEB-INF/views/common/footer.jsp" %></body></html>