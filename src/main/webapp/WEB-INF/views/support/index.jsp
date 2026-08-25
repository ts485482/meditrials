<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
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
%>
<%
    List<SupportNoticeVO> notices = request.getAttribute("notices") instanceof List<?> list
            ? (List<SupportNoticeVO>) list : List.of();
    int noticeCount = request.getAttribute("noticeCount") instanceof Number value ? value.intValue() : notices.size();
    String keyword = request.getAttribute("keyword") instanceof String value ? value : "";
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : "";
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy.MM.dd");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>고객센터 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/support.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section support-page">
  <div class="mt-container">
    <div class="support-hero">
      <div>
        <span class="support-eyebrow">MediTrials Support</span>
        <h1>고객센터</h1>
        <p>서비스 이용 방법과 자주 묻는 질문, 공지사항을 확인할 수 있습니다.</p>
      </div>
      <div class="support-hero-actions">
        <a class="btn btn-light" href="${pageContext.request.contextPath}/diseases">질환정보 찾기</a>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/trials">임상시험 검색</a>
      </div>
    </div>

    <% if (!pageNotice.isBlank()) { %>
      <div class="notice support-page-notice"><%= h(pageNotice) %></div>
    <% } %>

    <section class="support-section">
      <div class="support-section-head">
        <div>
          <h2>자주 묻는 질문</h2>
          <p>주요 이용 흐름을 빠르게 확인해보세요.</p>
        </div>
      </div>
      <div class="faq-list">
        <details>
          <summary>임상시험 문의와 참여 요청은 어떻게 다른가요?</summary>
          <p>관리자가 승인한 MediTrials 자체 등록 임상시험에서는 <strong>문의하기</strong>로 조건·일정 등을 질문하고, <strong>참여 요청</strong>으로 실제 참여 의사를 전달할 수 있습니다. 외부 API 임상시험은 공식 상세 페이지에서 기관 연락처와 참여 정보를 확인해주세요.</p>
        </details>
        <details>
          <summary>관심 질환과 관심 임상시험은 어디에서 확인하나요?</summary>
          <p>로그인 후 <strong>내 정보 → 관심 질환 / 관심 임상시험</strong>에서 저장한 항목을 확인하고 해제할 수 있습니다.</p>
        </details>
        <details>
          <summary>사업자 회원가입 후 바로 임상시험을 등록할 수 있나요?</summary>
          <p>사업자 회원가입 후 관리자 승인이 완료되어야 임상시험 등록·수정·검수 요청 기능을 사용할 수 있습니다.</p>
        </details>
        <details>
          <summary>PREMIUM 자동결제를 취소하면 바로 기능이 종료되나요?</summary>
          <p>취소 신청 시 현재 이용기간의 종료예정일까지 PREMIUM 기능이 유지됩니다. 종료 전에 자동결제 이어하기를 선택하면 취소 신청을 철회할 수 있습니다.</p>
        </details>
      </div>
    </section>

    <section class="support-section">
      <div class="support-section-head support-notice-head">
        <div>
          <h2>공지사항</h2>
          <p>서비스 운영 및 주요 변경사항을 안내합니다. 총 <strong><%= noticeCount %></strong>건</p>
        </div>
        <form class="support-notice-search" action="${pageContext.request.contextPath}/support" method="get">
          <input class="form-control" type="search" name="keyword" maxlength="100" value="<%= h(keyword) %>" placeholder="공지 제목 검색">
          <button type="submit" class="btn btn-outline">검색</button>
        </form>
      </div>

      <div class="support-notice-list">
        <% if (notices.isEmpty()) { %>
          <div class="support-notice-empty">
            <strong><%= keyword.isBlank() ? "등록된 공지사항이 없습니다." : "검색된 공지사항이 없습니다." %></strong>
            <span><%= keyword.isBlank() ? "관리자가 공지사항을 등록하면 이곳에 표시됩니다." : "다른 검색어를 입력해보세요." %></span>
          </div>
        <% } else { %>
          <% for (SupportNoticeVO notice : notices) { %>
            <a class="support-notice-row" href="${pageContext.request.contextPath}/support/notices/<%= notice.getNoticeNo() %>">
              <div class="support-notice-title">
                <% if (notice.isPinnedNotice()) { %><span class="badge badge-blue">공지</span><% } %>
                <strong><%= h(notice.getTitle()) %></strong>
              </div>
              <div class="support-notice-meta">
                <span><%= h(notice.getAdminName() == null ? "MediTrials" : notice.getAdminName()) %></span>
                <span><%= notice.getCreatedAt() == null ? "" : notice.getCreatedAt().format(dateFormatter) %></span>
              </div>
            </a>
          <% } %>
        <% } %>
      </div>
    </section>

    <section class="support-guide-grid">
      <div class="support-guide-card">
        <span>사용자</span>
        <h3>임상시험 참여 관련 문의</h3>
        <p>승인된 자체 임상시험의 상세 화면에서 문의를 작성하면 해당 기관 사업자가 답변합니다.</p>
        <a class="link-blue" href="${pageContext.request.contextPath}/trials">임상시험 찾기 →</a>
      </div>
      <div class="support-guide-card">
        <span>사업자</span>
        <h3>기관 승인 및 등록 상태 확인</h3>
        <p>사업자 센터에서 기관 승인 상태, 임상시험 검수 상태, 반려 사유를 확인할 수 있습니다.</p>
        <a class="link-blue" href="${pageContext.request.contextPath}/business">사업자 센터 →</a>
      </div>
    </section>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
