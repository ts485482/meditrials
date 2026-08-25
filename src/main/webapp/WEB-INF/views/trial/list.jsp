<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%
    String keyword = request.getAttribute("keyword") instanceof String value ? value : "";
    String selectedStatus = request.getAttribute("selectedStatus") instanceof String value ? value : "ALL";
    String selectedPhase = request.getAttribute("selectedPhase") instanceof String value ? value : "ALL";
    String selectedScope = request.getAttribute("selectedScope") instanceof String value ? value : "DOMESTIC";
    String selectedSort = request.getAttribute("selectedSort") instanceof String value ? value : "RECOMMENDED";
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : "";
    boolean domesticScope = "DOMESTIC".equals(selectedScope);

    String escapedKeyword = HtmlUtils.htmlEscape(keyword);
    String escapedStatus = HtmlUtils.htmlEscape(selectedStatus);
    String escapedPhase = HtmlUtils.htmlEscape(selectedPhase);
    String escapedScope = HtmlUtils.htmlEscape(selectedScope);
    String escapedSort = HtmlUtils.htmlEscape(selectedSort);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>임상시험 검색 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/trial.css?v=20260825-async1">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section trial-page">
  <div class="mt-container">
    <div class="row-between trial-title-row">
      <div>
        <h1 class="section-title mb-10">임상시험 검색</h1>
        <p class="trial-subtitle">
          <%= domesticScope
                  ? "국내에서 수행되는 임상연구를 우선 조회하고 한글 등록정보를 중심으로 표시합니다."
                  : "난치성·치료 미충족 질환을 중심으로 ClinicalTrials.gov의 전 세계 임상시험을 검색합니다." %>
        </p>
      </div>
      <div id="trialSourceBadges" class="trial-source-badges" aria-live="polite">
        <% if (domesticScope) { %>
          <span class="badge badge-blue">CRIS 확인 중</span>
          <span class="badge badge-blue">ClinicalTrials.gov 확인 중</span>
        <% } else { %>
          <span class="badge badge-blue">ClinicalTrials.gov 확인 중</span>
        <% } %>
      </div>
    </div>

    <% if (!pageNotice.isBlank()) { %>
      <div class="notice trial-notice"><%= HtmlUtils.htmlEscape(pageNotice) %></div>
    <% } %>

    <form class="search-panel trial-search-panel" method="get" action="${pageContext.request.contextPath}/trials">
      <input type="hidden" name="sort" value="<%= escapedSort %>">
      <div class="filter-row">
        <div class="filter-item trial-keyword-item">
          <label for="trialKeyword">질환명 또는 임상시험명</label>
          <input id="trialKeyword" name="keyword" class="form-control" value="<%= escapedKeyword %>" placeholder="예: 파킨슨병, 알츠하이머병">
        </div>
        <div class="filter-item">
          <label for="trialScope">조회 범위</label>
          <select id="trialScope" name="scope" class="form-control">
            <option value="DOMESTIC" <%= "DOMESTIC".equals(selectedScope) ? "selected" : "" %>>국내 임상시험</option>
            <option value="GLOBAL" <%= "GLOBAL".equals(selectedScope) ? "selected" : "" %>>해외 포함 전체</option>
          </select>
        </div>
        <div class="filter-item">
          <label for="trialStatus">모집 상태</label>
          <select id="trialStatus" name="status" class="form-control">
            <option value="ALL" <%= "ALL".equals(selectedStatus) ? "selected" : "" %>>전체</option>
            <option value="RECRUITING" <%= "RECRUITING".equals(selectedStatus) ? "selected" : "" %>>모집중</option>
            <option value="NOT_YET_RECRUITING" <%= "NOT_YET_RECRUITING".equals(selectedStatus) ? "selected" : "" %>>모집예정</option>
            <option value="COMPLETED" <%= "COMPLETED".equals(selectedStatus) ? "selected" : "" %>>완료</option>
          </select>
        </div>
        <div class="filter-item">
          <label for="trialPhase">임상 단계</label>
          <select id="trialPhase" name="phase" class="form-control">
            <option value="ALL" <%= "ALL".equals(selectedPhase) ? "selected" : "" %>>전체</option>
            <option value="PHASE1" <%= "PHASE1".equals(selectedPhase) ? "selected" : "" %>>1상</option>
            <option value="PHASE1_2" <%= "PHASE1_2".equals(selectedPhase) ? "selected" : "" %>>1/2상</option>
            <option value="PHASE2" <%= "PHASE2".equals(selectedPhase) ? "selected" : "" %>>2상</option>
            <option value="PHASE2_3" <%= "PHASE2_3".equals(selectedPhase) ? "selected" : "" %>>2/3상</option>
            <option value="PHASE3" <%= "PHASE3".equals(selectedPhase) ? "selected" : "" %>>3상</option>
          </select>
        </div>
        <button class="btn btn-primary" type="submit">검색하기</button>
      </div>
    </form>

    <div id="trialApiNotice" class="trial-api-notice" hidden aria-live="polite"></div>

    <div class="row-between trial-result-head">
      <h2>임상시험 검색 결과</h2>
      <div class="trial-result-tools">
        <div id="trialResultCount" class="trial-result-count" aria-live="polite">
          임상시험 정보를 불러오는 중입니다.
        </div>
        <form class="trial-sort-form" method="get" action="${pageContext.request.contextPath}/trials">
          <input type="hidden" name="keyword" value="<%= escapedKeyword %>">
          <input type="hidden" name="scope" value="<%= escapedScope %>">
          <input type="hidden" name="status" value="<%= escapedStatus %>">
          <input type="hidden" name="phase" value="<%= escapedPhase %>">
          <label for="trialSort">정렬</label>
          <select id="trialSort" name="sort" class="form-control">
            <option value="RECOMMENDED" <%= "RECOMMENDED".equals(selectedSort) ? "selected" : "" %>>추천순</option>
            <option value="DEADLINE" <%= "DEADLINE".equals(selectedSort) ? "selected" : "" %>>모집 종료 임박순</option>
          </select>
          <button class="btn btn-outline trial-sort-button" type="submit">적용</button>
        </form>
      </div>
    </div>

    <div id="trialLoading" class="trial-async-loading" aria-live="polite">
      <div class="async-loading-heading">
        <span class="async-spinner" aria-hidden="true"></span>
        <div>
          <strong>임상시험 정보를 불러오고 있습니다.</strong>
          <span>CRIS, ClinicalTrials.gov와 MediTrials 등록 정보를 확인하고 있어요.</span>
        </div>
      </div>
      <div class="trial-skeleton-list" aria-hidden="true">
        <% for (int i = 0; i < 4; i++) { %>
          <div class="trial-skeleton-card">
            <span class="async-skeleton-line is-short"></span>
            <span class="async-skeleton-line is-title"></span>
            <span class="async-skeleton-line"></span>
          </div>
        <% } %>
      </div>
    </div>

    <div id="trialLoadError" class="trial-async-error" hidden>
      <strong>임상시험 정보를 불러오지 못했습니다.</strong>
      <span id="trialLoadErrorMessage">잠시 후 다시 시도해주세요.</span>
      <button id="trialRetryButton" class="btn btn-outline" type="button">다시 시도</button>
    </div>

    <div id="trialEmpty" class="trial-empty" hidden>
      <strong>표시할 임상시험이 없습니다.</strong>
      <span>검색어 또는 필터 조건을 변경해보세요.</span>
    </div>

    <div id="trialResultList" class="trial-result-list" hidden></div>

    <noscript>
      <div class="trial-async-error">
        <strong>검색 결과를 표시하려면 JavaScript가 필요합니다.</strong>
      </div>
    </noscript>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
(() => {
  const contextPath = '${pageContext.request.contextPath}';
  const selectedScope = '<%= escapedScope %>';

  const loading = document.getElementById('trialLoading');
  const errorBox = document.getElementById('trialLoadError');
  const errorMessage = document.getElementById('trialLoadErrorMessage');
  const retryButton = document.getElementById('trialRetryButton');
  const emptyBox = document.getElementById('trialEmpty');
  const resultList = document.getElementById('trialResultList');
  const resultCount = document.getElementById('trialResultCount');
  const apiNotice = document.getElementById('trialApiNotice');
  const sourceBadges = document.getElementById('trialSourceBadges');

  function currentParams() {
    const params = new URLSearchParams();
    params.set('keyword', document.getElementById('trialKeyword').value || '');
    params.set('scope', document.getElementById('trialScope').value || 'DOMESTIC');
    params.set('status', document.getElementById('trialStatus').value || 'ALL');
    params.set('phase', document.getElementById('trialPhase').value || 'ALL');
    params.set('sort', document.getElementById('trialSort').value || 'RECOMMENDED');
    return params;
  }

  function statusLabel(value) {
    const labels = {
      CRIS_REGISTERED: 'CRIS 등록',
      RECRUITING: '모집중',
      NOT_YET_RECRUITING: '모집예정',
      ACTIVE_NOT_RECRUITING: '진행중·모집종료',
      ENROLLING_BY_INVITATION: '초대 모집',
      COMPLETED: '완료',
      SUSPENDED: '일시중단',
      TERMINATED: '조기종료',
      WITHDRAWN: '철회'
    };
    return labels[value] || value || '상태 미확인';
  }

  function statusClass(value) {
    if (value === 'RECRUITING') return 'badge-green';
    if (value === 'NOT_YET_RECRUITING') return 'badge-blue';
    if (value === 'CRIS_REGISTERED') return 'badge-cris';
    if (value === 'COMPLETED') return 'badge-gray';
    return 'badge-amber';
  }

  function phaseLabel(value) {
    if (!value) return '단계 미지정';
    const normalized = String(value).toUpperCase();
    if (normalized.includes('PHASE1') && normalized.includes('PHASE2')) return '1/2상';
    if (normalized.includes('PHASE2') && normalized.includes('PHASE3')) return '2/3상';
    if (normalized.includes('EARLY_PHASE1')) return '초기 1상';
    if (normalized.includes('PHASE1')) return '1상';
    if (normalized.includes('PHASE2')) return '2상';
    if (normalized.includes('PHASE3')) return '3상';
    if (normalized.includes('PHASE4')) return '4상';
    if (normalized.includes('NA')) return '해당없음';
    return value;
  }

  function isCris(trial) {
    return trial && trial.nctId && String(trial.nctId).toUpperCase().startsWith('KCT');
  }

  function isBusinessTrial(trial) {
    return trial && String(trial.sourceType || '').toUpperCase() === 'BUSINESS';
  }

  function sourceLabel(trial) {
    if (isBusinessTrial(trial)) return 'MediTrials 사업자 등록';
    return isCris(trial) ? 'CRIS' : 'ClinicalTrials.gov';
  }

  function sourceId(trial) {
    if (isBusinessTrial(trial)) return trial.trialNo ? 'MT-' + trial.trialNo : 'MediTrials';
    return trial && trial.nctId ? trial.nctId : '';
  }

  function textElement(tagName, className, text) {
    const element = document.createElement(tagName);
    if (className) element.className = className;
    element.textContent = text == null ? '' : String(text);
    return element;
  }

  function badge(text, className) {
    return textElement('span', 'badge ' + className, text);
  }

  function appendMeta(container, text) {
    if (!text) return;
    container.appendChild(textElement('span', '', text));
  }

  function createTrialCard(trial) {
    const card = document.createElement('a');
    card.className = 'result-card trial-result-card';
    if (isCris(trial)) card.classList.add('trial-result-card-cris');
    if (isBusinessTrial(trial)) card.classList.add('trial-result-card-business');
    card.href = contextPath + '/trials/' + trial.trialNo;

    const head = document.createElement('div');
    head.className = 'row-between trial-card-head';

    const titleWrap = document.createElement('div');
    titleWrap.appendChild(textElement('div', 'trial-nct', sourceId(trial) + ' · ' + sourceLabel(trial)));
    titleWrap.appendChild(textElement('h3', '', trial.title || '임상시험'));
    if (isCris(trial) && trial.officialTitle) {
      titleWrap.appendChild(textElement('div', 'trial-card-english-title', trial.officialTitle));
    }

    const badges = document.createElement('div');
    badges.className = 'trial-card-badges';
    if (trial.premiumPromoted) badges.appendChild(badge('★ PREMIUM', 'badge-amber'));
    badges.appendChild(badge(statusLabel(trial.recruitmentStatus), statusClass(trial.recruitmentStatus)));

    head.appendChild(titleWrap);
    head.appendChild(badges);
    card.appendChild(head);

    const meta = document.createElement('div');
    meta.className = 'result-meta trial-card-meta';
    meta.appendChild(badge(phaseLabel(trial.phase), 'badge-blue'));
    appendMeta(meta, trial.conditionsText);

    if (trial.startDateText || trial.completionDateText) {
      appendMeta(meta, (trial.startDateText || '') + ' ~ ' + (trial.completionDateText || ''));
    }

    if (trial.institutionName) {
      let institution = trial.institutionName;
      if (Number(trial.locationCount) > 1) {
        institution += ' 외 ' + (Number(trial.locationCount) - 1) + '개 기관';
      }
      appendMeta(meta, institution);
    }

    card.appendChild(meta);
    return card;
  }

  function updateSourceBadges(result) {
    sourceBadges.replaceChildren();
    if (selectedScope === 'DOMESTIC') {
      sourceBadges.appendChild(badge('CRIS 국내', result.crisAvailable ? 'badge-cris' : 'badge-amber'));
      sourceBadges.appendChild(badge('ClinicalTrials.gov 한국', result.apiAvailable ? 'badge-green' : 'badge-amber'));
    } else {
      sourceBadges.appendChild(badge('ClinicalTrials.gov 전체', result.apiAvailable ? 'badge-green' : 'badge-amber'));
    }
  }

  function updateResultCount(result, trials) {
    const count = Number.isFinite(Number(result.displayedCount))
      ? Number(result.displayedCount)
      : trials.length;
    resultCount.replaceChildren();
    resultCount.append('현재 ');
    const strong = document.createElement('strong');
    strong.textContent = count;
    resultCount.appendChild(strong);
    resultCount.append('건 표시');

    if (selectedScope === 'DOMESTIC') {
      if (result.crisTotalCount != null) resultCount.append(' · CRIS ' + result.crisTotalCount + '건');
      if (result.clinicalTrialsTotalCount != null) {
        resultCount.append(' · ClinicalTrials.gov 한국 ' + result.clinicalTrialsTotalCount + '건');
      }
    } else if (result.apiTotalCount != null) {
      resultCount.append(' · ClinicalTrials.gov 전체 ' + result.apiTotalCount + '건');
    }
  }

  function showLoading() {
    loading.hidden = false;
    errorBox.hidden = true;
    emptyBox.hidden = true;
    resultList.hidden = true;
    resultList.replaceChildren();
    apiNotice.hidden = true;
    resultCount.textContent = '임상시험 정보를 불러오는 중입니다.';
  }

  function showError(message) {
    loading.hidden = true;
    errorBox.hidden = false;
    emptyBox.hidden = true;
    resultList.hidden = true;
    errorMessage.textContent = message || '잠시 후 다시 시도해주세요.';
    resultCount.textContent = '불러오기 실패';
  }

  function renderResult(result) {
    const trials = Array.isArray(result.trials) ? result.trials : [];
    loading.hidden = true;
    errorBox.hidden = true;
    updateSourceBadges(result);
    updateResultCount(result, trials);

    if (result.notice) {
      apiNotice.textContent = result.notice;
      apiNotice.className = 'trial-api-notice ' + (result.apiAvailable ? 'ok' : 'warn');
      apiNotice.hidden = false;
    } else {
      apiNotice.hidden = true;
    }

    resultList.replaceChildren();
    if (trials.length === 0) {
      emptyBox.hidden = false;
      resultList.hidden = true;
      return;
    }

    emptyBox.hidden = true;
    for (const trial of trials) {
      if (trial && trial.trialNo != null) resultList.appendChild(createTrialCard(trial));
    }
    resultList.hidden = false;
  }

  async function loadTrialData() {
    showLoading();
    const controller = new AbortController();
    const timeoutId = window.setTimeout(() => controller.abort(), 60000);

    try {
      const response = await fetch(contextPath + '/trials/data?' + currentParams().toString(), {
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
          : '임상시험 정보를 불러오지 못했습니다.');
      }

      renderResult(payload || {});
    } catch (error) {
      if (error && error.name === 'AbortError') {
        showError('조회 시간이 길어지고 있습니다. 다시 시도해주세요.');
      } else {
        showError(error && error.message ? error.message : '임상시험 정보를 불러오지 못했습니다.');
      }
    } finally {
      window.clearTimeout(timeoutId);
    }
  }

  retryButton.addEventListener('click', loadTrialData);
  loadTrialData();
})();
</script>
</body>
</html>
