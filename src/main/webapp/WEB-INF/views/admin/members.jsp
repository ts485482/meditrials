<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="meditrials.meditrials.admin.member.vo.AdminMemberVO" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%!
    private String h(String value) {
        return value == null ? "" : HtmlUtils.htmlEscape(value);
    }

    private String formatDate(java.time.LocalDateTime value) {
        return value == null ? "-" : value.format(DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm"));
    }

    private String statusLabel(String value) {
        if ("ACTIVE".equals(value)) return "정상";
        if ("SUSPENDED".equals(value)) return "정지";
        if ("WITHDRAWN".equals(value)) return "탈퇴";
        return value == null ? "-" : value;
    }

    private String statusClass(String value) {
        if ("ACTIVE".equals(value)) return "badge-green";
        if ("SUSPENDED".equals(value)) return "badge-red";
        return "badge-gray";
    }

    private String roleLabel(String value) {
        if ("USER".equals(value)) return "일반회원";
        if ("BUSINESS".equals(value)) return "사업자";
        if ("ADMIN".equals(value)) return "관리자";
        return value == null ? "-" : value;
    }

    private String orgTypeLabel(String value) {
        if ("HOSPITAL".equals(value)) return "병원";
        if ("PHARMA".equals(value)) return "제약사";
        if ("RESEARCH".equals(value)) return "연구기관";
        if ("CRO".equals(value)) return "CRO";
        if ("OTHER".equals(value)) return "기타";
        return value == null ? "-" : value;
    }

    private String approvalLabel(String value) {
        if ("PENDING".equals(value)) return "승인대기";
        if ("APPROVED".equals(value)) return "승인";
        if ("REJECTED".equals(value)) return "반려";
        return value == null ? "-" : value;
    }
%>
<%
    List<AdminMemberVO> members = request.getAttribute("members") instanceof List<?> list
            ? (List<AdminMemberVO>) list : List.of();
    AdminMemberVO selectedMember = request.getAttribute("selectedMember") instanceof AdminMemberVO value
            ? value : null;
    String keyword = request.getAttribute("keyword") instanceof String value ? value : "";
    Number activeCount = request.getAttribute("activeCount") instanceof Number value ? value : 0;
    Number suspendedCount = request.getAttribute("suspendedCount") instanceof Number value ? value : 0;
    Number withdrawnCount = request.getAttribute("withdrawnCount") instanceof Number value ? value : 0;
    String pageNotice = request.getAttribute("pageNotice") instanceof String value ? value : null;
    String pageError = request.getAttribute("pageError") instanceof String value ? value : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>회원 관리 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head>
<body>
<div class="page-shell">
  <%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %>
  <main class="dashboard-main">
    <div class="dashboard-head">
      <div>
        <h1>회원 관리</h1>
        <p class="text-muted" style="margin:8px 0 0;">실제 MEMBER 정보를 조회하고 회원 이용 상태를 관리합니다.</p>
      </div>
    </div>

    <% if (pageNotice != null && !pageNotice.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#e9fbf3;color:#18825e;border-color:#bfead8;"><%= h(pageNotice) %></div>
    <% } %>
    <% if (pageError != null && !pageError.isBlank()) { %>
      <div class="notice" style="margin-bottom:18px;background:#fff1f2;color:#b93640;border-color:#f5cbd0;"><%= h(pageError) %></div>
    <% } %>

    <div class="stat-grid">
      <div class="stat-card"><span>검색 결과</span><strong><%= members.size() %>명</strong></div>
      <div class="stat-card"><span>정상 회원</span><strong><%= activeCount.longValue() %>명</strong></div>
      <div class="stat-card"><span>정지 회원</span><strong><%= suspendedCount.longValue() %>명</strong></div>
      <div class="stat-card"><span>탈퇴 회원</span><strong><%= withdrawnCount.longValue() %>명</strong></div>
    </div>

    <div class="search-panel">
      <form class="form-inline" action="${pageContext.request.contextPath}/admin/members" method="get">
        <input class="form-control" name="keyword" value="<%= h(keyword) %>" placeholder="이메일 또는 이름 검색">
        <button class="btn btn-primary" type="submit">검색</button>
        <% if (!keyword.isBlank()) { %>
          <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/members">초기화</a>
        <% } %>
      </form>
    </div>

    <div class="table-card">
      <table class="table">
        <thead>
          <tr>
            <th>번호</th>
            <th>이메일</th>
            <th>이름</th>
            <th>가입일</th>
            <th>역할</th>
            <th>상태</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
        <% if (members.isEmpty()) { %>
          <tr><td colspan="7" class="text-center text-muted">검색 결과가 없습니다.</td></tr>
        <% } else { %>
          <% for (AdminMemberVO member : members) { %>
            <tr>
              <td><%= member.getMemberNo() %></td>
              <td><%= h(member.getEmail()) %></td>
              <td><%= h(member.getMemberName()) %></td>
              <td><%= formatDate(member.getCreatedAt()) %></td>
              <td><%= roleLabel(member.getRoleCode()) %></td>
              <td><span class="badge <%= statusClass(member.getStatus()) %>"><%= statusLabel(member.getStatus()) %></span></td>
              <td><a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/members?memberNo=<%= member.getMemberNo() %><%= keyword.isBlank() ? "" : "&keyword=" + java.net.URLEncoder.encode(keyword, java.nio.charset.StandardCharsets.UTF_8) %>">상세</a></td>
            </tr>
          <% } %>
        <% } %>
        </tbody>
      </table>
    </div>

    <% if (selectedMember != null) { %>
      <section class="card mt-20">
        <div class="row-between" style="align-items:flex-start;margin-bottom:18px;">
          <div>
            <h3 style="margin-bottom:8px;">회원 상세</h3>
            <span class="badge <%= statusClass(selectedMember.getStatus()) %>"><%= statusLabel(selectedMember.getStatus()) %></span>
            <span class="badge badge-gray" style="margin-left:6px;"><%= roleLabel(selectedMember.getRoleCode()) %></span>
          </div>
          <strong style="color:#173f79;font-size:20px;">#<%= selectedMember.getMemberNo() %></strong>
        </div>

        <div class="content-grid-2">
          <p><strong>이메일</strong><br><%= h(selectedMember.getEmail()) %></p>
          <p><strong>이름</strong><br><%= h(selectedMember.getMemberName()) %></p>
          <p><strong>연락처</strong><br><%= h(selectedMember.getPhone()) %></p>
          <p><strong>가입일</strong><br><%= formatDate(selectedMember.getCreatedAt()) %></p>
          <p><strong>회원 상태</strong><br><%= statusLabel(selectedMember.getStatus()) %></p>
          <p><strong>최근 상태 변경</strong><br><%= formatDate(selectedMember.getUpdatedAt()) %></p>
        </div>

        <% if ("BUSINESS".equals(selectedMember.getRoleCode())) { %>
          <div class="notice" style="margin-top:12px;background:#f6f8fb;color:#5f6e80;border-color:#e2e7ed;">
            연결 기관: <strong><%= h(selectedMember.getOrgName()) %></strong>
            · <%= orgTypeLabel(selectedMember.getOrgType()) %>
            · 사업자 승인상태 <strong><%= approvalLabel(selectedMember.getApprovalStatus()) %></strong>
          </div>
        <% } %>

        <% if (!"ADMIN".equals(selectedMember.getRoleCode()) && !"WITHDRAWN".equals(selectedMember.getStatus())) { %>
          <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:22px;">
            <% if ("ACTIVE".equals(selectedMember.getStatus())) { %>
              <form action="${pageContext.request.contextPath}/admin/members/<%= selectedMember.getMemberNo() %>/suspend" method="post">
                <button class="btn btn-danger" type="submit" onclick="return confirm('이 회원의 이용을 정지하시겠습니까? 다음 로그인부터 서비스 이용이 제한됩니다.');">이용 정지</button>
              </form>
            <% } else if ("SUSPENDED".equals(selectedMember.getStatus())) { %>
              <form action="${pageContext.request.contextPath}/admin/members/<%= selectedMember.getMemberNo() %>/activate" method="post">
                <button class="btn btn-success" type="submit" onclick="return confirm('이 회원의 이용 정지를 해제하시겠습니까?');">정지 해제</button>
              </form>
            <% } %>
          </div>
        <% } else if ("ADMIN".equals(selectedMember.getRoleCode())) { %>
          <div class="notice" style="margin-top:18px;">관리자 계정은 이 화면에서 이용 정지 상태로 변경할 수 없습니다.</div>
        <% } %>
      </section>
    <% } %>
  </main>
</div>
<script src="${pageContext.request.contextPath}/js/meditrials.js"></script>
</body>
</html>
