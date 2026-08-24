<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>사업자 회원가입 | MediTrials</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/business-signup.css">
</head>
<body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section">
  <div class="mt-container">
    <div class="card business-signup-card">
      <div class="business-signup-head">
        <div>
          <h1 class="section-title">사업자 회원가입</h1>
          <p class="text-muted">기관 가입 신청 후 관리자 승인 완료 시 임상시험 등록·수정 기능을 사용할 수 있습니다.</p>
        </div>
        <span class="badge badge-amber">가입 시 승인대기</span>
      </div>

      <div id="signupError" class="business-signup-message business-signup-message-error" aria-live="polite"></div>
      <input type="hidden" id="serverErrorCode" value="${errorCode}">

      <form id="businessSignupForm"
            action="${pageContext.request.contextPath}/business/signup"
            method="post"
            data-context-path="${pageContext.request.contextPath}"
            novalidate>

        <div class="business-signup-grid">
          <section class="business-signup-section">
            <h2>계정 정보</h2>

            <div class="form-group">
              <label class="form-label" for="email">이메일</label>
              <div class="form-inline">
                <input class="form-control" id="email" name="email" type="email"
                       autocomplete="email" placeholder="example@meditrials.kr" value="${email}" required>
                <button class="btn btn-light" id="emailCheckButton" type="button">중복 확인</button>
              </div>
              <div id="emailCheckMessage" class="business-signup-field-message" aria-live="polite"></div>
            </div>

            <div class="form-group">
              <label class="form-label" for="password">비밀번호</label>
              <input class="form-control" id="password" name="password" type="password"
                     autocomplete="new-password" minlength="8" required>
              <p class="business-signup-guide">8자 이상, 영문자와 특수문자를 각각 1자 이상 포함해주세요.</p>
            </div>

            <div class="form-group">
              <label class="form-label" for="passwordConfirm">비밀번호 확인</label>
              <input class="form-control" id="passwordConfirm" name="passwordConfirm" type="password"
                     autocomplete="new-password" minlength="8" required>
            </div>

            <div class="form-group">
              <label class="form-label" for="memberName">이름</label>
              <input class="form-control" id="memberName" name="memberName" type="text"
                     autocomplete="name" value="${memberName}" required>
            </div>

            <div class="form-group">
              <label class="form-label" for="memberPhone">연락처</label>
              <input class="form-control" id="memberPhone" name="memberPhone" type="tel"
                     autocomplete="tel" placeholder="010-1234-5678" value="${memberPhone}" required>
            </div>
          </section>

          <section class="business-signup-section">
            <h2>기관 정보</h2>

            <div class="form-group">
              <label class="form-label" for="orgName">기관명</label>
              <input class="form-control" id="orgName" name="orgName" type="text"
                     value="${orgName}" required>
            </div>

            <div class="form-group">
              <label class="form-label" for="orgType">기관 유형</label>
              <select class="form-control" id="orgType" name="orgType" required>
                <option value="">선택</option>
                <option value="HOSPITAL" ${orgType == 'HOSPITAL' ? 'selected' : ''}>병원</option>
                <option value="PHARMA" ${orgType == 'PHARMA' ? 'selected' : ''}>제약사</option>
                <option value="RESEARCH" ${orgType == 'RESEARCH' ? 'selected' : ''}>연구기관</option>
                <option value="CRO" ${orgType == 'CRO' ? 'selected' : ''}>CRO</option>
                <option value="OTHER" ${orgType == 'OTHER' ? 'selected' : ''}>기타</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label" for="businessRegNo">사업자등록번호</label>
              <div class="form-inline">
                <input class="form-control" id="businessRegNo" name="businessRegNo" type="text"
                       placeholder="123-45-67890" value="${businessRegNo}" required>
                <button class="btn btn-light" id="businessRegCheckButton" type="button">중복 확인</button>
              </div>
              <div id="businessRegCheckMessage" class="business-signup-field-message" aria-live="polite"></div>
            </div>

            <div class="form-group">
              <label class="form-label" for="orgPhone">기관 연락처</label>
              <input class="form-control" id="orgPhone" name="orgPhone" type="tel"
                     placeholder="02-1234-5678" value="${orgPhone}" required>
            </div>

            <div class="notice business-approval-guide">
              <strong>승인 전 이용 안내</strong><br>
              가입 직후 BUSINESS 계정으로 로그인할 수 있지만 기관 상태는 <b>PENDING(승인대기)</b>입니다.
              관리자 승인 완료 후 임상시험 등록·수정·검수 요청 기능이 활성화됩니다.
            </div>
          </section>
        </div>

        <div class="business-signup-actions">
          <a class="btn btn-outline" href="${pageContext.request.contextPath}/login">로그인으로</a>
          <button class="btn btn-primary" type="submit">가입 신청</button>
        </div>
      </form>
    </div>
  </div>
</main>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/business-signup.js"></script>
</body>
</html>
