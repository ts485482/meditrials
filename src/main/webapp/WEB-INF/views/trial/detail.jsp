<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="meditrials.meditrials.trial.vo.TrialVO" %>
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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/trial.css">
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
          <a class="btn btn-light w-100" href="https://cris.nih.go.kr" target="_blank" rel="noopener noreferrer">CRIS에서 등록번호 검색</a>
        <% } else { %>
          <p><strong>연락 담당자</strong><br><%= trial == null || trial.getContactName() == null ? "공개 연락처 없음" : h(trial.getContactName()) %></p>
          <p><strong>연락처</strong><br><%= trial == null || trial.getContactPhone() == null ? "정보 없음" : h(trial.getContactPhone()) %></p>
          <p><strong>이메일</strong><br><%= trial == null || trial.getContactEmail() == null ? "정보 없음" : h(trial.getContactEmail()) %></p>
          <% if (trial != null && trial.getNctId() != null && !trial.getNctId().isBlank()) { %>
            <a class="btn btn-light w-100" href="https://clinicaltrials.gov/study/<%= h(trial.getNctId()) %>" target="_blank" rel="noopener noreferrer">ClinicalTrials.gov 원문 보기</a>
          <% } %>
        <% } %>

        <% if (loginUser) { %>
          <form method="post" action="${pageContext.request.contextPath}/mypage/favorites/trials/<%= trial.getTrialNo() %>">
            <button class="btn <%= favoriteTrial ? "btn-light" : "btn-outline" %> w-100 mt-20" type="submit">
              <%= favoriteTrial ? "♥ 관심 해제" : "♡ 관심 등록" %>
            </button>
          </form>
        <% } else if (!loggedIn) { %>
          <a class="btn btn-outline w-100 mt-20" href="${pageContext.request.contextPath}/login?required=true">♡ 관심 등록</a>
        <% } else { %>
          <button class="btn btn-outline w-100 mt-20" type="button" disabled title="일반 사용자 계정에서 이용할 수 있습니다.">♡ 관심 등록</button>
        <% } %>
        <a class="btn btn-primary w-100 mt-20" href="${pageContext.request.contextPath}/trials/<%= trial == null ? "" : trial.getTrialNo() %>/inquiries/new">참여 문의</a>

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

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
