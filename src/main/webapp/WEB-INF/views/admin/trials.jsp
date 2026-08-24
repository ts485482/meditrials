<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.admin.trial.vo.AdminTrialReviewVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String reviewLabel(String value) {
        if (value == null) return "상태 없음";
        return switch (value) {
            case "PENDING" -> "검수대기";
            case "APPROVED" -> "승인";
            case "REJECTED" -> "반려";
            default -> value;
        };
    }

    private String reviewClass(String value) {
        if ("APPROVED".equals(value)) return "badge-green";
        if ("REJECTED".equals(value)) return "badge-red";
        return "badge-amber";
    }

    private String recruitmentLabel(String value) {
        if (value == null) return "미지정";
        return switch (value) {
            case "RECRUITING" -> "모집중";
            case "NOT_YET_RECRUITING" -> "모집예정";
            case "ACTIVE_NOT_RECRUITING" -> "진행중·모집종료";
            case "COMPLETED" -> "모집완료";
            default -> value;
        };
    }

    private String phaseLabel(String value) {
        if (value == null || value.isBlank()) return "미지정";
        String normalized = value.toUpperCase();
        if (normalized.contains("PHASE1") && normalized.contains("PHASE2")) return "1/2상";
        if (normalized.contains("PHASE2") && normalized.contains("PHASE3")) return "2/3상";
        if (normalized.contains("PHASE1")) return "1상";
        if (normalized.contains("PHASE2")) return "2상";
        if (normalized.contains("PHASE3")) return "3상";
        if (normalized.contains("PHASE4")) return "4상";
        return value;
    }
%>
<%
    List<AdminTrialReviewVO> trials = request.getAttribute("trials") instanceof List<?> list
            ? (List<AdminTrialReviewVO>) list : List.of();
    AdminTrialReviewVO selectedTrial = request.getAttribute("selectedTrial") instanceof AdminTrialReviewVO value
            ? value : null;
    String selectedStatus = request.getAttribute("selectedStatus") instanceof String value ? value : "ALL";
    Long pendingCount = request.getAttribute("pendingCount") instanceof Number value ? value.longValue() : 0L;
    Long approvedCount = request.getAttribute("approvedCount") instanceof Number value ? value.longValue() : 0L;
    Long rejectedCount = request.getAttribute("rejectedCount") instanceof Number value ? value.longValue() : 0L;
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>임상시험 검수 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-trial.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %>

  <main class="dashboard-main admin-trial-page">
    <div class="dashboard-head admin-trial-head">
      <div>
        <h1>임상시험 검수 관리</h1>
        <p>사업자가 검수 요청한 임상시험을 확인하고 승인 또는 반려합니다.</p>
      </div>
    </div>

    <% if (!pageNotice.isBlank()) { %>
      <div class="admin-trial-notice"><%= h(pageNotice) %></div>
    <% } %>

    <div class="admin-trial-summary">
      <a class="summary-card <%= "PENDING".equals(selectedStatus) ? "active" : "" %>" href="${pageContext.request.contextPath}/admin/trials?status=PENDING">
        <span>검수 대기</span><strong><%= pendingCount %></strong>
      </a>
      <a class="summary-card <%= "APPROVED".equals(selectedStatus) ? "active" : "" %>" href="${pageContext.request.contextPath}/admin/trials?status=APPROVED">
        <span>승인 완료</span><strong><%= approvedCount %></strong>
      </a>
      <a class="summary-card <%= "REJECTED".equals(selectedStatus) ? "active" : "" %>" href="${pageContext.request.contextPath}/admin/trials?status=REJECTED">
        <span>반려</span><strong><%= rejectedCount %></strong>
      </a>
      <a class="summary-card <%= "ALL".equals(selectedStatus) ? "active" : "" %>" href="${pageContext.request.contextPath}/admin/trials?status=ALL">
        <span>전체 검수 대상</span><strong><%= pendingCount + approvedCount + rejectedCount %></strong>
      </a>
    </div>

    <section class="table-card admin-trial-list-card">
      <div class="admin-card-title-row">
        <h2>사업자 임상시험 목록</h2>
        <span><%= trials.size() %>건</span>
      </div>

      <% if (trials.isEmpty()) { %>
        <div class="admin-trial-empty">해당 상태의 사업자 임상시험이 없습니다.</div>
      <% } else { %>
        <div class="table-scroll">
          <table class="table admin-trial-table">
            <thead>
              <tr>
                <th>번호</th>
                <th>임상시험 제목</th>
                <th>기관</th>
                <th>질환</th>
                <th>단계</th>
                <th>검수상태</th>
                <th>관리</th>
              </tr>
            </thead>
            <tbody>
              <% for (AdminTrialReviewVO trial : trials) { %>
                <tr class="<%= selectedTrial != null && trial.getTrialNo().equals(selectedTrial.getTrialNo()) ? "selected-row" : "" %>">
                  <td><%= trial.getTrialNo() %></td>
                  <td class="trial-title-cell"><%= h(trial.getTitle()) %></td>
                  <td><%= h(trial.getOrgName()) %></td>
                  <td><%= trial.getDiseaseName() == null ? "-" : h(trial.getDiseaseName()) %></td>
                  <td><%= h(phaseLabel(trial.getPhase())) %></td>
                  <td><span class="badge <%= reviewClass(trial.getReviewStatus()) %>"><%= h(reviewLabel(trial.getReviewStatus())) %></span></td>
                  <td>
                    <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/trials?status=<%= h(selectedStatus) %>&trialNo=<%= trial.getTrialNo() %>">상세</a>
                  </td>
                </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      <% } %>
    </section>

    <section class="card admin-trial-detail-card">
      <h2>임상시험 검수 상세</h2>

      <% if (selectedTrial == null) { %>
        <div class="admin-trial-empty">검수할 임상시험을 선택해주세요.</div>
      <% } else { %>
        <div class="admin-trial-detail-head">
          <div>
            <div class="detail-kicker">MT-<%= selectedTrial.getTrialNo() %> · <%= h(selectedTrial.getOrgName()) %></div>
            <h3><%= h(selectedTrial.getTitle()) %></h3>
          </div>
          <span class="badge <%= reviewClass(selectedTrial.getReviewStatus()) %>"><%= h(reviewLabel(selectedTrial.getReviewStatus())) %></span>
        </div>

        <div class="admin-trial-meta-grid">
          <div><span>대상 질환</span><strong><%= selectedTrial.getDiseaseName() == null ? "정보 없음" : h(selectedTrial.getDiseaseName()) %></strong></div>
          <div><span>임상 단계</span><strong><%= h(phaseLabel(selectedTrial.getPhase())) %></strong></div>
          <div><span>모집 상태</span><strong><%= h(recruitmentLabel(selectedTrial.getRecruitmentStatus())) %></strong></div>
          <div><span>모집 인원</span><strong><%= selectedTrial.getEnrollmentTarget() == null ? "정보 없음" : selectedTrial.getEnrollmentTarget() + "명" %></strong></div>
          <div><span>연구 기관</span><strong><%= selectedTrial.getInstitutionName() == null ? h(selectedTrial.getOrgName()) : h(selectedTrial.getInstitutionName()) %></strong></div>
          <div><span>연구 기간</span><strong><%= h(selectedTrial.getStartDateText()) %> ~ <%= h(selectedTrial.getCompletionDateText()) %></strong></div>
        </div>

        <div class="admin-trial-text-block">
          <h4>연구 목적</h4>
          <p><%= selectedTrial.getBriefSummary() == null ? "등록된 연구 목적이 없습니다." : h(selectedTrial.getBriefSummary()) %></p>
        </div>

        <div class="admin-trial-text-block">
          <h4>참여 조건</h4>
          <p><%= selectedTrial.getEligibilityText() == null ? "등록된 참여 조건이 없습니다." : h(selectedTrial.getEligibilityText()) %></p>
        </div>

        <div class="admin-trial-contact-grid">
          <div><span>기관 위치</span><strong><%= selectedTrial.getLocationText() == null ? "정보 없음" : h(selectedTrial.getLocationText()) %></strong></div>
          <div><span>담당자</span><strong><%= selectedTrial.getContactName() == null ? "정보 없음" : h(selectedTrial.getContactName()) %></strong></div>
          <div><span>연락처</span><strong><%= selectedTrial.getContactPhone() == null ? "정보 없음" : h(selectedTrial.getContactPhone()) %></strong></div>
          <div><span>이메일</span><strong><%= selectedTrial.getContactEmail() == null ? "정보 없음" : h(selectedTrial.getContactEmail()) %></strong></div>
        </div>

        <% if ("REJECTED".equals(selectedTrial.getReviewStatus()) && selectedTrial.getRejectReason() != null) { %>
          <div class="reject-history">
            <strong>반려 사유</strong>
            <p><%= h(selectedTrial.getRejectReason()) %></p>
          </div>
        <% } %>

        <% if ("PENDING".equals(selectedTrial.getReviewStatus())) { %>
          <div class="admin-review-actions">
            <form class="reject-form" method="post" action="${pageContext.request.contextPath}/admin/trials/<%= selectedTrial.getTrialNo() %>/reject">
              <label for="rejectReason">반려 사유</label>
              <textarea id="rejectReason" name="rejectReason" maxlength="1000" placeholder="반려 시 사업자가 확인할 사유를 입력해주세요."></textarea>
              <button class="btn btn-danger" type="submit" onclick="return confirm('이 임상시험을 반려하시겠습니까?');">반려</button>
            </form>

            <form class="approve-form" method="post" action="${pageContext.request.contextPath}/admin/trials/<%= selectedTrial.getTrialNo() %>/approve">
              <p>승인하면 사용자 임상시험 검색에 즉시 공개됩니다.</p>
              <button class="btn btn-primary" type="submit" onclick="return confirm('이 임상시험을 승인하고 사용자에게 공개하시겠습니까?');">승인 / 공개</button>
            </form>
          </div>
        <% } else { %>
          <div class="review-completed-message">이미 검수가 완료된 임상시험입니다.</div>
        <% } %>
      <% } %>
    </section>
  </main>
</div>
</body>
</html>
