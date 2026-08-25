<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%
    String keyword = request.getAttribute("keyword") instanceof String value ? value : "";
    String selectedCategory = request.getAttribute("selectedCategory") instanceof String value
            ? value : "ALL";
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : "";
    String escapedKeyword = HtmlUtils.htmlEscape(keyword);
    String escapedCategory = HtmlUtils.htmlEscape(selectedCategory);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>질환 검색 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/disease.css?v=20260825-async1">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section">
  <div class="mt-container">
    <div class="disease-page-head">
      <div>
        <h1 class="section-title mb-10">질환 정보</h1>
        <p class="text-muted mb-0">
          치료 연구가 활발한 난치성·치료 미충족 질환을 중심으로 질환정보와 임상시험을 연결합니다.
        </p>
      </div>
      <span id="diseaseApiBadge" class="badge badge-blue" aria-live="polite">HIRA 연동 확인 중</span>
    </div>

    <div class="search-panel disease-search-panel">
      <form action="${pageContext.request.contextPath}/diseases" method="get" class="disease-search-form">
        <input type="hidden" name="category" value="<%= escapedCategory %>">
        <input
            id="diseaseKeyword"
            class="form-control"
            type="search"
            name="keyword"
            value="<%= escapedKeyword %>"
            placeholder="질환명, 영문 질환명 또는 KCD 코드"
            aria-label="질환 검색어">
        <button class="btn btn-primary" type="submit">검색</button>
      </form>

      <form action="${pageContext.request.contextPath}/diseases" method="get" class="disease-filter-tabs">
        <input type="hidden" name="keyword" value="<%= escapedKeyword %>">
        <button class="tab disease-filter-tab <%= "ALL".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="ALL">전체</button>
        <button class="tab disease-filter-tab <%= "NEURO".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="NEURO">신경퇴행성</button>
        <button class="tab disease-filter-tab <%= "AUTOIMMUNE".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="AUTOIMMUNE">자가면역·면역</button>
        <button class="tab disease-filter-tab <%= "CANCER".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="CANCER">암·종양</button>
        <button class="tab disease-filter-tab <%= "GENETIC".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="GENETIC">유전성</button>
        <button class="tab disease-filter-tab <%= "CHRONIC".equals(selectedCategory) ? "active" : "" %>"
                type="submit" name="category" value="CHRONIC">만성·난치성</button>
      </form>
      <p class="disease-filter-note">
        분류는 MediTrials의 치료 연구 탐색용 분류이며, 희귀질환 여부는 추후 공식 희귀질환 데이터로 별도 보강합니다.
      </p>
    </div>

    <% if (!pageNotice.isBlank()) { %>
      <div class="disease-api-notice is-warning"><%= HtmlUtils.htmlEscape(pageNotice) %></div>
    <% } %>

    <div id="diseaseApiNotice" class="disease-api-notice" hidden aria-live="polite"></div>

    <div class="disease-data-guide">
      <div><strong>질환명·KCD</strong><span>건강보험심사평가원</span></div>
      <div><strong>질환 설명</strong><span>MedlinePlus</span></div>
      <div><strong>관련 임상시험</strong><span>ClinicalTrials.gov</span></div>
    </div>

    <div class="disease-result-head">
      <h3>질환 검색 결과</h3>
      <span id="diseaseResultCount" class="text-muted" aria-live="polite">질환정보를 불러오는 중입니다.</span>
    </div>

    <div id="diseaseLoading" class="disease-async-loading" aria-live="polite">
      <div class="async-loading-heading">
        <span class="async-spinner" aria-hidden="true"></span>
        <div>
          <strong>질환정보를 불러오고 있습니다.</strong>
          <span>HIRA 질환정보와 관련 임상시험 건수를 확인하고 있어요.</span>
        </div>
      </div>
      <div class="disease-skeleton-grid" aria-hidden="true">
        <% for (int i = 0; i < 6; i++) { %>
          <div class="disease-skeleton-card">
            <span class="async-skeleton-line is-title"></span>
            <span class="async-skeleton-line is-short"></span>
            <span class="async-skeleton-line"></span>
          </div>
        <% } %>
      </div>
    </div>

    <div id="diseaseLoadError" class="disease-async-error" hidden>
      <strong>질환정보를 불러오지 못했습니다.</strong>
      <span id="diseaseLoadErrorMessage">잠시 후 다시 시도해주세요.</span>
      <button id="diseaseRetryButton" class="btn btn-outline" type="button">다시 시도</button>
    </div>

    <div id="diseaseEmpty" class="disease-empty" hidden>
      <strong>표시할 질환정보가 없습니다.</strong>
      <p>HIRA 인증키를 설정했는지 확인하거나 질환명·KCD 코드로 검색해주세요.</p>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/diseases">검색 초기화</a>
    </div>

    <div id="diseaseResultGrid" class="content-grid-2 disease-result-grid" hidden></div>

    <div class="disease-source-credit">
      질환명·KCD 출처: 건강보험심사평가원 질병정보서비스
    </div>

    <noscript>
      <div class="disease-async-error">
        <strong>검색 결과를 표시하려면 JavaScript가 필요합니다.</strong>
      </div>
    </noscript>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
(() => {
  const contextPath = '${pageContext.request.contextPath}';
  const selectedCategory = '<%= escapedCategory %>';

  const apiBadge = document.getElementById('diseaseApiBadge');
  const apiNotice = document.getElementById('diseaseApiNotice');
  const resultCount = document.getElementById('diseaseResultCount');
  const loading = document.getElementById('diseaseLoading');
  const errorBox = document.getElementById('diseaseLoadError');
  const errorMessage = document.getElementById('diseaseLoadErrorMessage');
  const retryButton = document.getElementById('diseaseRetryButton');
  const emptyBox = document.getElementById('diseaseEmpty');
  const resultGrid = document.getElementById('diseaseResultGrid');

  function currentParams() {
    const params = new URLSearchParams();
    params.set('keyword', document.getElementById('diseaseKeyword').value || '');
    params.set('category', selectedCategory || 'ALL');
    return params;
  }

  function textElement(tagName, className, text) {
    const element = document.createElement(tagName);
    if (className) element.className = className;
    element.textContent = text == null ? '' : String(text);
    return element;
  }

  function displayCode(sourceCode) {
    if (!sourceCode) return '-';
    return String(sourceCode).startsWith('HIRA:')
      ? String(sourceCode).substring('HIRA:'.length)
      : String(sourceCode);
  }

  function createDiseaseCard(disease) {
    const card = document.createElement('a');
    card.className = 'result-card disease-result-card';
    card.href = contextPath + '/diseases/' + disease.diseaseNo;

    const titleRow = document.createElement('div');
    titleRow.className = 'row-between disease-card-title-row';

    const titleGroup = document.createElement('div');
    titleGroup.className = 'disease-card-title-group';
    const diseaseName = disease.diseaseName || '질환정보';
    titleGroup.appendChild(textElement('h3', '', diseaseName));
    if (disease.englishName && disease.englishName !== diseaseName) {
      titleGroup.appendChild(textElement('p', '', disease.englishName));
    }

    titleRow.appendChild(titleGroup);
    titleRow.appendChild(textElement('span', 'badge badge-blue', disease.category || '치료 연구 질환'));
    card.appendChild(titleRow);

    const meta = document.createElement('div');
    meta.className = 'result-meta disease-card-meta';

    const codeSpan = document.createElement('span');
    codeSpan.append('KCD ');
    codeSpan.appendChild(textElement('strong', '', displayCode(disease.sourceCode)));
    meta.appendChild(codeSpan);

    const trialSpan = document.createElement('span');
    trialSpan.append('관련 임상시험 ');
    const trialCount = disease.relatedTrialCount == null ? '확인 불가' : disease.relatedTrialCount + '건';
    trialSpan.appendChild(textElement('strong', '', trialCount));
    meta.appendChild(trialSpan);

    card.appendChild(meta);
    card.appendChild(textElement('span', 'disease-card-link', '상세정보 보기 →'));
    return card;
  }

  function showLoading() {
    loading.hidden = false;
    errorBox.hidden = true;
    emptyBox.hidden = true;
    resultGrid.hidden = true;
    resultGrid.replaceChildren();
    apiNotice.hidden = true;
    apiBadge.className = 'badge badge-blue';
    apiBadge.textContent = 'HIRA 연동 확인 중';
    resultCount.textContent = '질환정보를 불러오는 중입니다.';
  }

  function showError(message) {
    loading.hidden = true;
    errorBox.hidden = false;
    emptyBox.hidden = true;
    resultGrid.hidden = true;
    errorMessage.textContent = message || '잠시 후 다시 시도해주세요.';
    apiBadge.className = 'badge badge-amber';
    apiBadge.textContent = 'HIRA 확인 실패';
    resultCount.textContent = '불러오기 실패';
  }

  function renderResult(result) {
    const diseases = Array.isArray(result.diseases) ? result.diseases : [];
    loading.hidden = true;
    errorBox.hidden = true;

    apiBadge.className = 'badge ' + (result.apiAvailable ? 'badge-green' : 'badge-amber');
    apiBadge.textContent = result.apiAvailable ? 'HIRA 연동' : 'HIRA 인증키 필요';

    if (result.notice) {
      apiNotice.textContent = result.notice;
      apiNotice.className = 'disease-api-notice ' + (result.apiAvailable ? 'is-success' : 'is-warning');
      apiNotice.hidden = false;
    } else {
      apiNotice.hidden = true;
    }

    const totalCount = result.totalCount == null ? diseases.length : result.totalCount;
    resultCount.replaceChildren();
    resultCount.append('총 ');
    resultCount.appendChild(textElement('strong', '', totalCount));
    resultCount.append('건 · 최대 20건 표시');

    resultGrid.replaceChildren();
    if (diseases.length === 0) {
      emptyBox.hidden = false;
      resultGrid.hidden = true;
      return;
    }

    emptyBox.hidden = true;
    for (const disease of diseases) {
      if (disease && disease.diseaseNo != null) resultGrid.appendChild(createDiseaseCard(disease));
    }
    resultGrid.hidden = false;
  }

  async function loadDiseaseData() {
    showLoading();
    const controller = new AbortController();
    const timeoutId = window.setTimeout(() => controller.abort(), 60000);

    try {
      const response = await fetch(contextPath + '/diseases/data?' + currentParams().toString(), {
        method: 'GET',
        headers: { Accept: 'application/json' },
        signal: controller.signal,
        credentials: 'same-origin'
      });

      let payload = null;
      try {
        payload = await response.json();
      } catch (ignore) {
        payload = null;
      }

      if (!response.ok) {
        throw new Error(payload && payload.message
          ? payload.message
          : '질환정보를 불러오지 못했습니다.');
      }

      renderResult(payload || {});
    } catch (error) {
      if (error && error.name === 'AbortError') {
        showError('조회 시간이 길어지고 있습니다. 다시 시도해주세요.');
      } else {
        showError(error && error.message ? error.message : '질환정보를 불러오지 못했습니다.');
      }
    } finally {
      window.clearTimeout(timeoutId);
    }
  }

  retryButton.addEventListener('click', loadDiseaseData);
  loadDiseaseData();
})();
</script>
</body>
</html>
