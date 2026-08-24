<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.member.vo.MemberVO" %>
<%@ page import="meditrials.meditrials.mypage.vo.MypageSummaryVO" %>
<%@ page import="meditrials.meditrials.mypage.vo.MypageRecentItemVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd"));
    }

    private String trialStatusLabel(String value) {
        if (value == null || value.isBlank()) return "상태 미확인";
        return switch (value) {
            case "RECRUITING" -> "모집중";
            case "NOT_YET_RECRUITING" -> "모집예정";
            case "ACTIVE_NOT_RECRUITING" -> "진행중·모집종료";
            case "COMPLETED" -> "완료";
            case "SUSPENDED" -> "일시중단";
            case "TERMINATED" -> "조기종료";
            case "WITHDRAWN" -> "철회";
            default -> value;
        };
    }

    private String inquiryStatusLabel(String value) {
        if ("ANSWERED".equals(value)) return "답변완료";
        if ("CLOSED".equals(value)) return "종료";
        return "답변대기";
    }

    private String inquiryStatusClass(String value) {
        return "ANSWERED".equals(value) ? "badge-green" : "badge-gray";
    }
%>
<%
    MemberVO member = request.getAttribute("member") instanceof MemberVO value ? value : null;
    MypageSummaryVO summary = request.getAttribute("summary") instanceof MypageSummaryVO value
            ? value : new MypageSummaryVO();
    List<MypageRecentItemVO> recentFavoriteDiseases = request.getAttribute("recentFavoriteDiseases") instanceof List<?> list
            ? (List<MypageRecentItemVO>) list : List.of();
    List<MypageRecentItemVO> recentFavoriteTrials = request.getAttribute("recentFavoriteTrials") instanceof List<?> list
            ? (List<MypageRecentItemVO>) list : List.of();
    List<MypageRecentItemVO> recentInquiries = request.getAttribute("recentInquiries") instanceof List<?> list
            ? (List<MypageRecentItemVO>) list : List.of();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>마이페이지 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-user.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head mypage-head">
      <div>
        <h1>마이페이지</h1>
        <p class="text-muted">
          <%= member == null ? "내 관심정보와 참여 문의를 확인합니다." : h(member.getMemberName()) + "님의 관심정보와 참여 문의를 확인합니다." %>
        </p>
      </div>
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/mypage/profile">회원정보 수정</a>
    </div>

    <div class="stat-grid mypage-stat-grid">
      <a class="stat-card mypage-stat-card" href="${pageContext.request.contextPath}/mypage/favorites?tab=diseases">
        <span>관심 질환</span><strong><%= summary.getFavoriteDiseaseCount() %></strong>
      </a>
      <a class="stat-card mypage-stat-card" href="${pageContext.request.contextPath}/mypage/favorites?tab=trials">
        <span>관심 임상시험</span><strong><%= summary.getFavoriteTrialCount() %></strong>
      </a>
      <a class="stat-card mypage-stat-card" href="${pageContext.request.contextPath}/mypage/inquiries">
        <span>참여 문의</span><strong><%= summary.getInquiryCount() %></strong>
      </a>
      <a class="stat-card mypage-stat-card" href="${pageContext.request.contextPath}/mypage/inquiries">
        <span>답변 완료</span><strong><%= summary.getAnsweredInquiryCount() %></strong>
      </a>
    </div>

    <div class="content-grid-3 mypage-content-grid">
      <section class="table-card mypage-preview-card">
        <div class="mypage-card-head">
          <h3>최근 관심 질환</h3>
          <a href="${pageContext.request.contextPath}/mypage/favorites?tab=diseases">전체 보기</a>
        </div>
        <% if (recentFavoriteDiseases.isEmpty()) { %>
          <div class="mypage-empty">등록한 관심 질환이 없습니다.</div>
        <% } else { %>
          <ul class="list-clean mypage-preview-list">
            <% for (MypageRecentItemVO item : recentFavoriteDiseases) { %>
              <li>
                <a href="${pageContext.request.contextPath}/diseases/<%= item.getTargetNo() %>">
                  <strong><%= h(item.getTitle()) %></strong>
                  <span><%= h(item.getSubtitle()) %></span>
                  <small><%= formatDate(item.getCreatedAt()) %></small>
                </a>
              </li>
            <% } %>
          </ul>
        <% } %>
      </section>

      <section class="table-card mypage-preview-card">
        <div class="mypage-card-head">
          <h3>최근 관심 임상시험</h3>
          <a href="${pageContext.request.contextPath}/mypage/favorites?tab=trials">전체 보기</a>
        </div>
        <% if (recentFavoriteTrials.isEmpty()) { %>
          <div class="mypage-empty">등록한 관심 임상시험이 없습니다.</div>
        <% } else { %>
          <ul class="list-clean mypage-preview-list">
            <% for (MypageRecentItemVO item : recentFavoriteTrials) { %>
              <li>
                <a href="${pageContext.request.contextPath}/trials/<%= item.getTargetNo() %>">
                  <strong><%= h(item.getTitle()) %></strong>
                  <span><%= h(item.getSubtitle()) %></span>
                  <div class="mypage-preview-meta">
                    <span class="badge badge-blue"><%= h(trialStatusLabel(item.getStatus())) %></span>
                    <small><%= formatDate(item.getCreatedAt()) %></small>
                  </div>
                </a>
              </li>
            <% } %>
          </ul>
        <% } %>
      </section>

      <section class="table-card mypage-preview-card">
        <div class="mypage-card-head">
          <h3>최근 참여 문의</h3>
          <a href="${pageContext.request.contextPath}/mypage/inquiries">전체 보기</a>
        </div>
        <% if (recentInquiries.isEmpty()) { %>
          <div class="mypage-empty">등록한 참여 문의가 없습니다.</div>
        <% } else { %>
          <ul class="list-clean mypage-preview-list">
            <% for (MypageRecentItemVO item : recentInquiries) { %>
              <li>
                <a href="${pageContext.request.contextPath}/mypage/inquiries?inquiryNo=<%= item.getTargetNo() %>">
                  <strong><%= h(item.getTitle()) %></strong>
                  <span><%= h(item.getSubtitle()) %></span>
                  <div class="mypage-preview-meta">
                    <span class="badge <%= inquiryStatusClass(item.getStatus()) %>"><%= h(inquiryStatusLabel(item.getStatus())) %></span>
                    <small><%= formatDate(item.getCreatedAt()) %></small>
                  </div>
                </a>
              </li>
            <% } %>
          </ul>
        <% } %>
      </section>
    </div>
  </main>
</div>
</body>
</html>
