<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.business.trial.vo.BusinessTrialVO" %>
<%@ page import="meditrials.meditrials.business.vo.BusinessVO" %>
<%@ page import="meditrials.meditrials.disease.vo.DiseaseVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String selected(String actual, String expected) {
        return expected.equals(actual) ? "selected" : "";
    }
%>
<%
    BusinessTrialVO trial = request.getAttribute("trialForm") instanceof BusinessTrialVO value
            ? value : new BusinessTrialVO();
    BusinessVO business = request.getAttribute("business") instanceof BusinessVO value ? value : null;
    List<DiseaseVO> diseaseOptions = request.getAttribute("diseaseOptions") instanceof List<?> list
            ? (List<DiseaseVO>) list : List.of();
    boolean isEdit = Boolean.TRUE.equals(request.getAttribute("isEdit"));
    String formError = request.getAttribute("formError") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= isEdit ? "임상시험 수정" : "임상시험 등록" %> | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/business-trial.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1><%= isEdit ? "임상시험 수정" : "임상시험 등록" %></h1>
        <p class="text-muted">임시 저장은 제목만 입력해도 가능하며, 검수 요청 시 필수 항목을 모두 확인합니다.</p>
      </div>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/business/trials">목록으로</a>
    </div>

    <% if (formError != null && !formError.isBlank()) { %>
      <div class="business-trial-error"><%= h(formError) %></div>
    <% } %>

    <% if ("REJECTED".equals(trial.getReviewStatus()) && trial.getRejectReason() != null) { %>
      <div class="business-trial-rejected-box">
        <strong>관리자 반려 사유</strong>
        <p><%= h(trial.getRejectReason()) %></p>
        <span>내용을 수정한 뒤 다시 검수 요청할 수 있습니다.</span>
      </div>
    <% } %>

    <form class="business-trial-form" method="post" action="${pageContext.request.contextPath}/business/trials/save">
      <% if (trial.getTrialNo() != null) { %>
        <input type="hidden" name="trialNo" value="<%= trial.getTrialNo() %>">
      <% } %>

      <section class="business-trial-form-card">
        <div class="business-trial-section-head">
          <h2>기본 정보</h2>
          <% if (trial.getReviewStatus() != null) { %>
            <span class="business-trial-current-status">현재 검수상태: <%= h(trial.getReviewStatus()) %></span>
          <% } %>
        </div>

        <div class="business-trial-form-grid">
          <div class="form-group business-trial-span-2">
            <label class="form-label" for="title">임상시험 제목 <span class="required-mark">*</span></label>
            <input class="form-control" id="title" name="title" maxlength="500" value="<%= h(trial.getTitle()) %>" placeholder="예: 파킨슨병 신약 치료제 2상 임상">
          </div>

          <div class="form-group">
            <label class="form-label" for="diseaseNo">대상 질환</label>
            <select class="form-control" id="diseaseNo" name="diseaseNo">
              <option value="">선택</option>
              <% for (DiseaseVO disease : diseaseOptions) { %>
                <option value="<%= disease.getDiseaseNo() %>" <%= trial.getDiseaseNo() != null && trial.getDiseaseNo().equals(disease.getDiseaseNo()) ? "selected" : "" %>>
                  <%= h(disease.getDiseaseName()) %><%= disease.getSourceCode() == null ? "" : " (" + h(disease.getSourceCode().replace("HIRA:", "KCD ")) + ")" %>
                </option>
              <% } %>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label" for="phase">임상 단계</label>
            <select class="form-control" id="phase" name="phase">
              <option value="">선택</option>
              <option value="PHASE1" <%= selected(trial.getPhase(), "PHASE1") %>>1상</option>
              <option value="PHASE1|PHASE2" <%= selected(trial.getPhase(), "PHASE1|PHASE2") %>>1/2상</option>
              <option value="PHASE2" <%= selected(trial.getPhase(), "PHASE2") %>>2상</option>
              <option value="PHASE2|PHASE3" <%= selected(trial.getPhase(), "PHASE2|PHASE3") %>>2/3상</option>
              <option value="PHASE3" <%= selected(trial.getPhase(), "PHASE3") %>>3상</option>
              <option value="PHASE4" <%= selected(trial.getPhase(), "PHASE4") %>>4상</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label" for="recruitmentStatus">모집 상태</label>
            <select class="form-control" id="recruitmentStatus" name="recruitmentStatus">
              <option value="">선택</option>
              <option value="NOT_YET_RECRUITING" <%= selected(trial.getRecruitmentStatus(), "NOT_YET_RECRUITING") %>>모집예정</option>
              <option value="RECRUITING" <%= selected(trial.getRecruitmentStatus(), "RECRUITING") %>>모집중</option>
              <option value="ACTIVE_NOT_RECRUITING" <%= selected(trial.getRecruitmentStatus(), "ACTIVE_NOT_RECRUITING") %>>진행중·모집종료</option>
              <option value="COMPLETED" <%= selected(trial.getRecruitmentStatus(), "COMPLETED") %>>모집완료</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label" for="enrollmentTarget">모집 인원</label>
            <input class="form-control" id="enrollmentTarget" name="enrollmentTarget" type="number" min="1" value="<%= trial.getEnrollmentTarget() == null ? "" : trial.getEnrollmentTarget() %>" placeholder="예: 100">
          </div>
        </div>
      </section>

      <section class="business-trial-form-card">
        <h2>연구 정보</h2>
        <div class="form-group">
          <label class="form-label" for="briefSummary">연구 목적</label>
          <textarea class="form-control business-trial-textarea" id="briefSummary" name="briefSummary" placeholder="연구 목적과 평가 내용을 입력해주세요."><%= h(trial.getBriefSummary()) %></textarea>
        </div>
        <div class="form-group">
          <label class="form-label" for="eligibilityText">참여 조건</label>
          <textarea class="form-control business-trial-textarea" id="eligibilityText" name="eligibilityText" placeholder="대상 연령, 질환 상태, 주요 선정/제외 기준 등을 입력해주세요."><%= h(trial.getEligibilityText()) %></textarea>
        </div>
      </section>

      <section class="business-trial-form-card">
        <h2>기관 및 일정</h2>
        <div class="business-trial-form-grid">
          <div class="form-group business-trial-span-2">
            <label class="form-label" for="institutionName">연구 기관</label>
            <input class="form-control" id="institutionName" name="institutionName" maxlength="300" value="<%= h(trial.getInstitutionName()) %>" placeholder="연구 기관명">
            <% if (business != null) { %>
              <div class="field-help">기본 기관: <%= h(business.getOrgName()) %></div>
            <% } %>
          </div>

          <div class="form-group">
            <label class="form-label" for="startDateText">연구 시작일</label>
            <input class="form-control" id="startDateText" name="startDateText" type="date" value="<%= h(trial.getStartDateText()) %>">
          </div>
          <div class="form-group">
            <label class="form-label" for="completionDateText">연구 종료일</label>
            <input class="form-control" id="completionDateText" name="completionDateText" type="date" value="<%= h(trial.getCompletionDateText()) %>">
          </div>

          <div class="form-group business-trial-span-2">
            <label class="form-label" for="contactPhone">연락처</label>
            <input class="form-control" id="contactPhone" name="contactPhone" maxlength="50" value="<%= h(trial.getContactPhone()) %>" placeholder="02-1234-5678">
          </div>
        </div>
      </section>

      <div class="business-trial-form-actions">
        <button class="btn btn-outline" type="submit" name="action" value="draft">임시 저장</button>
        <button class="btn btn-primary" type="submit" name="action" value="review"><%= isEdit ? "수정 후 검수 요청" : "검수 요청" %></button>
      </div>
      <p class="business-trial-form-help">검수 요청 시 상태가 PENDING으로 변경되며, 관리자 승인(APPROVED) 후 사용자 임상시험 검색에 공개됩니다.</p>
    </form>
  </main>
</div>
</body>
</html>
