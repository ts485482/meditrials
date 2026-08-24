<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="meditrials.meditrials.business.promotion.vo.BusinessPromotionVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String date(LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd"));
    }

    private String phase(String value) {
        if (value == null || value.isBlank()) return "단계 미지정";
        String v = value.toUpperCase();
        if (v.contains("PHASE1") && v.contains("PHASE2")) return "1/2상";
        if (v.contains("PHASE2") && v.contains("PHASE3")) return "2/3상";
        if (v.contains("PHASE1")) return "1상";
        if (v.contains("PHASE2")) return "2상";
        if (v.contains("PHASE3")) return "3상";
        return value;
    }

    private String statusLabel(String value) {
        if (value == null) return "신청 가능";
        return switch (value) {
            case "PENDING" -> "승인대기";
            case "ACTIVE" -> "노출중";
            case "REJECTED" -> "반려";
            case "ENDED" -> "종료";
            default -> value;
        };
    }

    private String statusClass(String value) {
        if ("ACTIVE".equals(value)) return "badge-green";
        if ("PENDING".equals(value)) return "badge-amber";
        if ("REJECTED".equals(value)) return "badge-red";
        return "badge-gray";
    }
%>
<%
    List<BusinessPromotionVO> promotionTrials = request.getAttribute("promotionTrials") instanceof List<?> list
            ? (List<BusinessPromotionVO>) list : List.of();
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
    String pageError = request.getAttribute("pageError") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>프리미엄 노출 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-business.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>프리미엄 임상시험 노출</h1>
        <p class="text-muted">관리자 승인 완료 임상시험을 메인 추천 영역과 검색 상단에 우선 노출할 수 있습니다.</p>
      </div>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/business/plans">요금제/프리미엄으로</a>
    </div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="notice" style="margin-bottom:16px;"><%= h(pageNotice) %></div>
    <% } %>
    <% if (pageError != null && !pageError.isBlank()) { %>
      <div class="notice" style="margin-bottom:16px;background:#fff1f1;color:#a23131;border-color:#f0caca;"><%= h(pageError) %></div>
    <% } %>

    <section class="card" style="margin-bottom:18px;">
      <h3 style="margin-top:0;">노출 정책</h3>
      <p class="text-muted" style="margin-bottom:0;line-height:1.7;">
        PREMIUM 이용 중인 사업자만 신청할 수 있습니다. 신청 후 관리자가 승인하면 노출이 시작되며,
        PREMIUM 자동결제를 취소하더라도 이용 종료 예정일까지는 노출이 유지됩니다.
      </p>
    </section>

    <div class="table-card">
      <table class="table">
        <thead>
          <tr>
            <th>임상시험</th>
            <th>단계</th>
            <th>모집상태</th>
            <th>노출상태</th>
            <th>노출기간</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
        <% if (promotionTrials.isEmpty()) { %>
          <tr><td colspan="6" style="text-align:center;padding:34px;">관리자 승인 완료된 자체 임상시험이 없습니다.</td></tr>
        <% } else { %>
          <% for (BusinessPromotionVO trial : promotionTrials) {
               String promotionStatus = trial.getPromotionStatus();
               LocalDateTime expectedEnd = trial.getSubscriptionEndDate() != null
                       ? trial.getSubscriptionEndDate() : trial.getEndDate();
          %>
            <tr>
              <td>
                <strong><%= h(trial.getTitle()) %></strong><br>
                <span class="text-muted"><%= h(trial.getInstitutionName()) %></span>
              </td>
              <td><%= h(phase(trial.getPhase())) %></td>
              <td><%= h(trial.getRecruitmentStatus()) %></td>
              <td><span class="badge <%= statusClass(promotionStatus) %>"><%= h(statusLabel(promotionStatus)) %></span></td>
              <td>
                <% if ("ACTIVE".equals(promotionStatus)) { %>
                  <%= date(trial.getStartDate()) %> ~ <%= expectedEnd == null ? "PREMIUM 이용 중" : date(expectedEnd) %>
                <% } else if ("ENDED".equals(promotionStatus)) { %>
                  <%= date(trial.getStartDate()) %> ~ <%= date(trial.getEndDate()) %>
                <% } else { %>
                  -
                <% } %>
              </td>
              <td>
                <% if (promotionStatus == null || "REJECTED".equals(promotionStatus) || "ENDED".equals(promotionStatus)) { %>
                  <form method="post" action="${pageContext.request.contextPath}/business/promotions/<%= trial.getTrialNo() %>/apply" style="margin:0;">
                    <button class="btn btn-sm btn-primary" type="submit"><%= "REJECTED".equals(promotionStatus) ? "재신청" : "노출 신청" %></button>
                  </form>
                <% } else if ("PENDING".equals(promotionStatus)) { %>
                  <span class="text-muted">관리자 검토 중</span>
                <% } else { %>
                  <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/trials/<%= trial.getTrialNo() %>">노출 확인</a>
                <% } %>
              </td>
            </tr>
            <% if ("REJECTED".equals(promotionStatus) && trial.getRejectReason() != null && !trial.getRejectReason().isBlank()) { %>
              <tr>
                <td colspan="6" style="background:#fff8f8;color:#8c3838;">
                  <strong>반려 사유:</strong> <%= h(trial.getRejectReason()) %>
                </td>
              </tr>
            <% } %>
          <% } %>
        <% } %>
        </tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
