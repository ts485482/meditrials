<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="meditrials.meditrials.support.vo.SupportNoticeVO" %>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String nl2br(String value) {
        return h(value).replace("\r\n", "<br>").replace("\n", "<br>").replace("\r", "<br>");
    }
%>
<%
    SupportNoticeVO notice = request.getAttribute("notice") instanceof SupportNoticeVO value
            ? value : new SupportNoticeVO();
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><%= h(notice.getTitle()) %> | MediTrials 고객센터</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/support.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section support-page">
  <div class="mt-container support-detail-wrap">
    <div class="support-detail-head">
      <a class="support-back-link" href="${pageContext.request.contextPath}/support">← 공지사항 목록</a>
      <div class="support-detail-title-row">
        <% if (notice.isPinnedNotice()) { %><span class="badge badge-blue">공지</span><% } %>
        <h1><%= h(notice.getTitle()) %></h1>
      </div>
      <div class="support-detail-meta">
        <span>작성자 <strong><%= h(notice.getAdminName() == null ? "MediTrials" : notice.getAdminName()) %></strong></span>
        <span>등록일 <%= notice.getCreatedAt() == null ? "" : notice.getCreatedAt().format(dateFormatter) %></span>
      </div>
    </div>

    <article class="support-detail-content"><%= nl2br(notice.getContent()) %></article>

    <div class="support-detail-actions">
      <a class="btn btn-outline" href="${pageContext.request.contextPath}/support">목록으로</a>
    </div>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
