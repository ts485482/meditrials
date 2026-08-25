<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="meditrials.meditrials.trial.vo.TrialVO" %>
<%@ page import="meditrials.meditrials.participation.vo.TrialParticipationVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private boolean isCris(TrialVO trial) {
        return trial != null
                && trial.getNctId() != null
                && trial.getNctId().toUpperCase().startsWith("KCT");
    }

    private String statusLabel(String value) {
        if (value == null) return "상태 미확인";
        return switch (value) {
            case "CRIS_REGISTERED" -> "CRIS 등록";
            case "RECRUITING" -> "모집중";
            case "NOT_YET_RECRUITING" -> "모집예정";
            case "ACTIVE_NOT_RECRUITING" -> "진행중·모집종료";
            case "ENROLLING_BY_INVITATION" -> "초대 모집";
            case "COMPLETED" -> "완료";
            case "SUSPENDED" -> "일시중단";
            case "TERMINATED" -> "조기종료";
            case "WITHDRAWN" -> "철회";
            default -> value;
        };
    }

    private String statusClass(String value) {
        if ("RECRUITING".equals(value)) return "badge-green";
        if ("NOT_YET_RECRUITING".equals(value)) return "badge-blue";
        if ("CRIS_REGISTERED".equals(value)) return "badge-cris";
        if ("COMPLETED".equals(value)) return "badge-gray";
        return "badge-amber";
    }

    private String phaseLabel(String value) {
        if (value == null || value.isBlank()) return "단계 미지정";
        String normalized = value.toUpperCase();
        if (normalized.contains("PHASE1") && normalized.contains("PHASE2")) return "1/2상";
        if (normalized.contains("PHASE2") && normalized.contains("PHASE3")) return "2/3상";
        if (normalized.contains("EARLY_PHASE1")) return "초기 1상";
        if (normalized.contains("PHASE1")) return "1상";
        if (normalized.contains("PHASE2")) return "2상";
        if (normalized.contains("PHASE3")) return "3상";
        if (normalized.contains("PHASE4")) return "4상";
        if (normalized.contains("NA")) return "해당없음";
        return value;
    }

    private boolean isBusinessTrial(TrialVO trial) {
        return trial != null && "BUSINESS".equalsIgnoreCase(trial.getSourceType());
    }


    private String participationStatusLabel(String status) {
        if ("APPLIED".equals(status)) return "참여 요청 검토중";
        if ("APPROVED".equals(status)) return "참여 승인됨";
        if ("PARTICIPATING".equals(status)) return "참여중";
        if ("COMPLETED".equals(status)) return "참여완료";
        if ("REJECTED".equals(status)) return "참여 요청 거절";
        if ("WITHDRAWN".equals(status)) return "참여 요청 취소";
        return "참여 상태 확인";
    }

    private String sexLabel(String value) {
        if ("ALL".equals(value)) return "모든 성별";
        if ("MALE".equals(value)) return "남성";
        if ("FEMALE".equals(value)) return "여성";
        return value == null || value.isBlank() ? "정보 없음" : value;
    }
%>
<%
    TrialVO trial = request.getAttribute("trial") instanceof TrialVO value ? value : null;
    String title = trial == null ? "임상시험 상세" : h(trial.getTitle());
    boolean businessTrial = isBusinessTrial(trial);
    String externalId = businessTrial
            ? (trial == null || trial.getTrialNo() == null ? "MediTrials" : "MT-" + trial.getTrialNo())
            : (trial == null ? "" : h(trial.getNctId()));
    boolean cris = isCris(trial);
    String sourceName = businessTrial
            ? "MediTrials 사업자 등록"
            : (cris ? "질병관리청 CRIS" : "ClinicalTrials.gov");
    boolean favoriteTrial = Boolean.TRUE.equals(request.getAttribute("favoriteTrial"));
    TrialParticipationVO participation = request.getAttribute("participation") instanceof TrialParticipationVO value
            ? value : null;
    boolean inquiryAvailable = businessTrial
            && trial != null
            && "APPROVED".equalsIgnoreCase(trial.getReviewStatus())
            && trial.getBusinessNo() != null;
    boolean inquiryUnavailable = "true".equalsIgnoreCase(request.getParameter("inquiryUnavailable"));
    boolean participationAvailable = inquiryAvailable
            && trial != null
            && "RECRUITING".equalsIgnoreCase(trial.getRecruitmentStatus());
    String participationNotice = request.getAttribute("participationNotice") instanceof String value ? value : null;
    String participationError = request.getAttribute("participationError") instanceof String value ? value : null;
    String inquiryNotice = request.getAttribute("inquiryNotice") instanceof String value ? value : null;
    String inquiryError = request.getAttribute("inquiryError") instanceof String value ? value : null;
    String inquirySubject = request.getAttribute("inquirySubject") instanceof String value ? value : "";
    String inquiryQuestion = request.getAttribute("inquiryQuestion") instanceof String value ? value : "";
    boolean inquiryPrivacyAgreed = Boolean.TRUE.equals(request.getAttribute("inquiryPrivacyAgreed"));
    boolean openInquiryModal = "true".equalsIgnoreCase(request.getParameter("openInquiry"))
            || Boolean.TRUE.equals(request.getAttribute("openInquiryModal"));
    Object loginRoleValue = session.getAttribute("LOGIN_MEMBER_ROLE");
    boolean loginUser = "USER".equals(loginRoleValue);
    boolean loggedIn = loginRoleValue != null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= title %> | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/trial.css?v=20260825-1431">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section trial-page">
  <div class="mt-container">
    <a class="trial-back-link" href="${pageContext.request.contextPath}/trials">← 임상시험 목록</a>

    <div class="trial-detail-head">
      <div class="trial-detail-source"><%= externalId %> · <%= sourceName %></div>
      <h1 class="section-title trial-detail-title"><%= title %></h1>
      <% if (trial != null && trial.getOfficialTitle() != null && !trial.getOfficialTitle().isBlank() && !trial.getOfficialTitle().equals(trial.getTitle())) { %>
        <p class="trial-official-title"><%= h(trial.getOfficialTitle()) %></p>
      <% } %>
      <div class="trial-detail-tags">
        <span class="badge <%= statusClass(trial == null ? null : trial.getRecruitmentStatus()) %>"><%= h(statusLabel(trial == null ? null : trial.getRecruitmentStatus())) %></span>
        <span class="badge badge-blue"><%= h(phaseLabel(trial == null ? null : trial.getPhase())) %></span>
        <% if (businessTrial) { %>
          <span class="badge badge-green">관리자 승인</span>
        <% } else if (cris) { %>
          <span class="badge badge-cris">국내 연구</span>
        <% } else if (trial != null && trial.getStudyType() != null) { %>
          <span class="badge badge-gray"><%= h(trial.getStudyType()) %></span>
        <% } %>
      </div>
    </div>

    <div class="detail-layout trial-detail-layout">
      <div>
        <section class="detail-section">
          <h2>연구 개요</h2>
          <% if (trial != null && trial.getBriefSummary() != null && !trial.getBriefSummary().isBlank()) { %>
            <p class="trial-preline"><%= h(trial.getBriefSummary()) %></p>
          <% } else { %>
            <p class="text-muted"><%= cris ? "CRIS 목록 API에서 제공되는 연구 개요가 없습니다." : "등록된 연구 개요가 없습니다." %></p>
          <% } %>
        </section>

        <section class="detail-section">
          <h2>대상 기준</h2>
          <div class="trial-eligibility-summary">
            <span><strong>성별</strong><%= h(sexLabel(trial == null ? null : trial.getSex())) %></span>
            <span><strong>최소 연령</strong><%= trial == null || trial.getMinAge() == null ? "정보 없음" : h(trial.getMinAge()) %></span>
            <span><strong>최대 연령</strong><%= trial == null || trial.getMaxAge() == null ? "정보 없음" : h(trial.getMaxAge()) %></span>
            <span><strong>목표 인원</strong><%= trial == null || trial.getEnrollmentTarget() == null ? "정보 없음" : trial.getEnrollmentTarget() + "명" %></span>
          </div>
          <% if (trial != null && trial.getEligibilityText() != null && !trial.getEligibilityText().isBlank()) { %>
            <div class="trial-preline trial-eligibility-text"><%= h(trial.getEligibilityText()) %></div>
          <% } else { %>
            <p class="text-muted"><%= cris ? "대상자 선정기준은 CRIS 상세 등록정보에서 추가 확인이 필요합니다." : "세부 선정·제외 기준 정보가 없습니다." %></p>
          <% } %>
        </section>

        <section class="detail-section">
          <h2>기관 및 일정</h2>
          <div class="trial-info-grid">
            <div><span>대표 기관</span><strong><%= trial == null || trial.getInstitutionName() == null ? "정보 없음" : h(trial.getInstitutionName()) %></strong></div>
            <div><span><%= businessTrial ? "등록 기관" : (cris ? "연구비지원/책임 기관" : "연구 책임 기관/스폰서") %></span><strong><%= trial == null || trial.getLeadSponsor() == null ? "정보 없음" : h(trial.getLeadSponsor()) %></strong></div>
            <div><span><%= cris ? "첫 연구대상자 등록일" : "연구 시작" %></span><strong><%= trial == null || trial.getStartDateText() == null ? "정보 없음" : h(trial.getStartDateText()) %></strong></div>
            <div><span>연구 종료일</span><strong><%= trial == null || trial.getCompletionDateText() == null ? "정보 없음" : h(trial.getCompletionDateText()) %></strong></div>
          </div>
          <% if (trial != null && trial.getLocationText() != null && !trial.getLocationText().isBlank()) { %>
            <div class="trial-location-text"><%= h(trial.getLocationText()) %></div>
          <% } %>
        </section>
      </div>

      <aside class="side-box trial-contact-box">
        <h3>정보 출처 / 참여 확인</h3>

        <% if (businessTrial) { %>
          <p><strong>등록 구분</strong><br>MediTrials 사업자 직접 등록 · 관리자 검수 승인</p>
          <p><strong>연락 담당자</strong><br><%= trial == null || trial.getContactName() == null ? "공개 연락처 없음" : h(trial.getContactName()) %></p>
          <p><strong>연락처</strong><br><%= trial == null || trial.getContactPhone() == null ? "정보 없음" : h(trial.getContactPhone()) %></p>
          <p><strong>이메일</strong><br><%= trial == null || trial.getContactEmail() == null ? "정보 없음" : h(trial.getContactEmail()) %></p>
        <% } else if (cris) { %>
          <p><strong>등록기관</strong><br>질병관리청 임상연구정보서비스(CRIS)</p>
          <p><strong>CRIS 등록번호</strong><br><%= externalId %></p>
        <% } else { %>
          <p><strong>연락 담당자</strong><br><%= trial == null || trial.getContactName() == null ? "공개 연락처 없음" : h(trial.getContactName()) %></p>
          <p><strong>연락처</strong><br><%= trial == null || trial.getContactPhone() == null ? "정보 없음" : h(trial.getContactPhone()) %></p>
          <p><strong>이메일</strong><br><%= trial == null || trial.getContactEmail() == null ? "정보 없음" : h(trial.getContactEmail()) %></p>
        <% } %>

        <% if (inquiryUnavailable) { %>
          <div class="trial-action-notice">외부 등록 임상시험은 MediTrials 직접 문의 대상이 아닙니다. 공식 등록 페이지에서 상세정보와 참여 방법을 확인해주세요.</div>
        <% } %>
        <% if (inquiryNotice != null && !inquiryNotice.isBlank()) { %>
          <div class="trial-action-notice trial-action-success"><%= h(inquiryNotice) %></div>
        <% } %>
        <% if (participationNotice != null && !participationNotice.isBlank()) { %>
          <div class="trial-action-notice trial-action-success"><%= h(participationNotice) %></div>
        <% } %>
        <% if (participationError != null && !participationError.isBlank()) { %>
          <div class="trial-action-notice trial-action-error"><%= h(participationError) %></div>
        <% } %>

        <div class="trial-contact-actions">
          <% if (loginUser) { %>
            <form method="post" action="${pageContext.request.contextPath}/mypage/favorites/trials/<%= trial.getTrialNo() %>">
              <button class="btn <%= favoriteTrial ? "btn-light" : "btn-outline" %> w-100" type="submit">
                <%= favoriteTrial ? "♥ 관심 해제" : "♡ 관심 등록" %>
              </button>
            </form>
          <% } else if (!loggedIn) { %>
            <a class="btn btn-outline w-100" href="${pageContext.request.contextPath}/login?required=true">♡ 관심 등록</a>
          <% } else { %>
            <button class="btn btn-outline w-100" type="button" disabled title="일반 사용자 계정에서 이용할 수 있습니다.">♡ 관심 등록</button>
          <% } %>

          <% if (inquiryAvailable) { %>
            <% if (loginUser) { %>
              <button class="btn btn-outline w-100" id="openInquiryDialog" type="button">문의하기</button>
            <% } else if (!loggedIn) { %>
              <a class="btn btn-outline w-100" href="${pageContext.request.contextPath}/login?required=true">문의하기</a>
            <% } else { %>
              <button class="btn btn-outline w-100" type="button" disabled title="일반 사용자 계정에서 이용할 수 있습니다.">문의하기</button>
            <% } %>

            <% if (loginUser) { %>
              <% if (participation == null && participationAvailable) { %>
                <form method="post" action="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>/participations/request" onsubmit="return confirm('이 임상시험에 실제 참여 요청을 등록하시겠습니까?');">
                  <button class="btn btn-primary w-100" type="submit">참여 요청</button>
                </form>
              <% } else if (participation != null && ("REJECTED".equals(participation.getStatus()) || "WITHDRAWN".equals(participation.getStatus())) && participationAvailable) { %>
                <form method="post" action="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>/participations/request" onsubmit="return confirm('이 임상시험에 다시 참여 요청을 등록하시겠습니까?');">
                  <button class="btn btn-primary w-100" type="submit">다시 참여 요청</button>
                </form>
              <% } else if (participation != null) { %>
                <a class="btn btn-light w-100" href="${pageContext.request.contextPath}/mypage/participations?participationNo=<%= participation.getParticipationNo() %>"><%= h(participationStatusLabel(participation.getStatus())) %></a>
              <% } else { %>
                <button class="btn btn-light w-100" type="button" disabled>현재 참여 요청 불가</button>
              <% } %>
            <% } else if (!loggedIn) { %>
              <a class="btn btn-primary w-100" href="${pageContext.request.contextPath}/login?required=true">참여 요청</a>
            <% } else { %>
              <button class="btn btn-light w-100" type="button" disabled title="일반 사용자 계정에서 이용할 수 있습니다.">참여 요청</button>
            <% } %>

            <div class="trial-action-guide">
              <strong>문의하기</strong>는 조건·일정 등에 대한 질문이며, <strong>참여 요청</strong>은 실제 참여 의사를 사업자에게 전달하는 기능입니다.
            </div>
          <% } else if (cris) { %>
            <a class="btn btn-primary w-100" href="https://cris.nih.go.kr" target="_blank" rel="noopener noreferrer">CRIS 공식 상세정보 확인 ↗</a>
          <% } else if (!businessTrial && trial != null && trial.getNctId() != null && !trial.getNctId().isBlank()) { %>
            <a class="btn btn-primary w-100" href="https://clinicaltrials.gov/study/<%= h(trial.getNctId()) %>" target="_blank" rel="noopener noreferrer">ClinicalTrials.gov 상세보기 ↗</a>
          <% } %>
        </div>

        <p class="trial-source-note">
          <%= businessTrial
                  ? "MediTrials 사업자가 직접 등록하고 관리자가 검수 승인한 임상시험입니다. 실제 참여 가능 여부와 최신 일정은 등록 기관에 확인해주세요."
                  : (cris
                      ? "CRIS에 공개된 국내 임상연구 등록정보를 기반으로 표시합니다. 모집 가능 여부와 세부 참여조건은 CRIS 및 실제 연구기관에서 다시 확인해야 합니다."
                      : "ClinicalTrials.gov 등록 정보를 기반으로 표시합니다. 실제 참여 가능 여부와 최신 일정은 연구기관 및 원문에서 다시 확인해야 합니다.") %>
        </p>
      </aside>
    </div>
  </div>
</main>

<% if (inquiryAvailable && loginUser && trial != null) { %>
<dialog class="trial-inquiry-dialog" id="trialInquiryDialog" aria-labelledby="trialInquiryDialogTitle">
  <div class="trial-inquiry-dialog-panel">
    <div class="trial-inquiry-dialog-head">
      <div>
        <span class="trial-inquiry-kicker">임상시험 문의</span>
        <h2 id="trialInquiryDialogTitle">문의하기</h2>
      </div>
      <button class="trial-inquiry-dialog-close" type="button" data-inquiry-close aria-label="문의 팝업 닫기">×</button>
    </div>

    <div class="trial-inquiry-summary">
      <span>문의 대상 임상시험</span>
      <strong><%= h(trial.getTitle()) %></strong>
      <% if (trial.getInstitutionName() != null && !trial.getInstitutionName().isBlank()) { %>
        <small><%= h(trial.getInstitutionName()) %></small>
      <% } %>
    </div>

    <% if (inquiryError != null && !inquiryError.isBlank()) { %>
      <div class="trial-inquiry-error" role="alert"><%= h(inquiryError) %></div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>/inquiries/new" class="trial-inquiry-form">
      <div class="form-group">
        <label class="form-label" for="inquirySubject">문의 제목 <span class="required-mark">*</span></label>
        <input
            class="form-control"
            id="inquirySubject"
            name="subject"
            type="text"
            maxlength="200"
            required
            value="<%= h(inquirySubject) %>"
            placeholder="예: 참여 조건과 방문 일정이 궁금합니다.">
        <div class="trial-inquiry-help">200자 이내로 입력해주세요.</div>
      </div>

      <div class="form-group">
        <label class="form-label" for="inquiryQuestion">문의 내용 <span class="required-mark">*</span></label>
        <textarea
            class="form-control trial-inquiry-question"
            id="inquiryQuestion"
            name="question"
            required
            placeholder="참여 조건, 일정, 방문 기관 등 궁금한 내용을 작성해주세요."><%= h(inquiryQuestion) %></textarea>
      </div>

      <label class="trial-inquiry-consent" for="inquiryPrivacyAgreed">
        <input
            id="inquiryPrivacyAgreed"
            name="privacyAgreed"
            type="checkbox"
            value="true"
            required
            <%= inquiryPrivacyAgreed ? "checked" : "" %>>
        <span>개인정보 수집 및 문의 전달에 동의합니다. <strong>(필수)</strong></span>
      </label>

      <div class="trial-inquiry-actions">
        <button class="btn btn-outline" type="button" data-inquiry-close>취소</button>
        <button class="btn btn-primary" type="submit">문의 등록</button>
      </div>
    </form>
  </div>
</dialog>

<script>
(function () {
  const dialog = document.getElementById('trialInquiryDialog');
  const openButton = document.getElementById('openInquiryDialog');
  if (!dialog) return;

  const openDialog = function () {
    if (!dialog.open) {
      dialog.showModal();
    }
  };

  if (openButton) {
    openButton.addEventListener('click', openDialog);
  }

  dialog.querySelectorAll('[data-inquiry-close]').forEach(function (button) {
    button.addEventListener('click', function () {
      dialog.close();
    });
  });

  dialog.addEventListener('click', function (event) {
    if (event.target === dialog) {
      dialog.close();
    }
  });

  <% if (openInquiryModal) { %>
    openDialog();
  <% } %>
})();
</script>
<% } %>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
