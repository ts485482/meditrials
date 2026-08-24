<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.trial.vo.TrialVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String statusLabel(String value) {
        if (value == null) return "상태 미확인";
        return switch (value) {
            case "RECRUITING" -> "모집중";
            case "NOT_YET_RECRUITING" -> "모집예정";
            case "COMPLETED" -> "모집완료";
            default -> value;
        };
    }
%>
<%
    List<TrialVO> premiumTrials = request.getAttribute("premiumTrials") instanceof List<?> list
            ? (List<TrialVO>) list : List.of();
    TrialVO premiumTrial = premiumTrials.isEmpty() ? null : premiumTrials.get(0);
%>
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
      <h1 id="mainHeroTitle">치료의 가능성을 찾는 여정</h1>
      <h2>MediTrials가 임상시험 참여의 기회를 연결합니다.</h2>
      <p>난치성·치료 미충족 질환 정보와 임상시험을 한곳에서 연결합니다.</p>
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
        <a href="${pageContext.request.contextPath}/diseases?category=NEURO"><span class="disease-symbol"></span><strong>신경퇴행성</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=AUTOIMMUNE"><span class="disease-symbol"></span><strong>자가면역·면역</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=CANCER"><span class="disease-symbol"></span><strong>암·종양성</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=GENETIC"><span class="disease-symbol"></span><strong>유전성</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?category=CHRONIC"><span class="disease-symbol"></span><strong>만성·난치성</strong></a>
        <a href="${pageContext.request.contextPath}/diseases"><span class="disease-symbol"></span><strong>치료 미충족 질환</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?keyword=알츠하이머"><span class="disease-symbol"></span><strong>알츠하이머병</strong></a>
        <a href="${pageContext.request.contextPath}/diseases?keyword=파킨슨"><span class="disease-symbol"></span><strong>파킨슨병</strong></a>
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
      <% if (premiumTrial != null) { %>
        <h2><%= h(premiumTrial.getTitle()) %></h2>
        <p>
          <%= premiumTrial.getConditionsText() == null || premiumTrial.getConditionsText().isBlank()
                  ? "MediTrials 승인 임상시험" : h(premiumTrial.getConditionsText()) %><br>
          <%= premiumTrial.getInstitutionName() == null || premiumTrial.getInstitutionName().isBlank()
                  ? "참여 기관 정보 확인" : h(premiumTrial.getInstitutionName()) %>
          · <%= h(statusLabel(premiumTrial.getRecruitmentStatus())) %>
        </p>
        <a class="premium-detail-button" href="${pageContext.request.contextPath}/trials/<%= premiumTrial.getTrialNo() %>">자세히 보기 →</a>
      <% } else { %>
        <h2>프리미엄 추천 임상시험</h2>
        <p>관리자 승인된 프리미엄 노출 임상시험이 이 영역에 표시됩니다.</p>
        <a class="premium-detail-button" href="${pageContext.request.contextPath}/trials">임상시험 검색 →</a>
      <% } %>
    </article>
  </section>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
