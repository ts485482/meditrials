<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>사업자 회원가입 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<%@ include file="/WEB-INF/views/common/header.jsp" %>

<main class="section"><div class="mt-container"><div class="card" style="max-width:900px;margin:0 auto">
  <h1 class="section-title">사업자 회원가입</h1>
  <div class="content-grid-2">
    <div>
      <h3>계정 정보</h3>
      <div class="form-group"><label class="form-label">이메일</label><div class="form-inline"><input class="form-control"><button class="btn btn-light">중복 확인</button></div></div>
      <div class="form-group"><label class="form-label">비밀번호</label><input class="form-control" type="password"></div>
      <div class="form-group"><label class="form-label">비밀번호 확인</label><input class="form-control" type="password"></div>
      <div class="form-group"><label class="form-label">이름</label><input class="form-control"></div>
      <div class="form-group"><label class="form-label">연락처</label><input class="form-control"></div>
    </div>
    <div>
      <h3>기관 정보</h3>
      <div class="form-group"><label class="form-label">기관명</label><input class="form-control"></div>
      <div class="form-group"><label class="form-label">기관 유형</label><select class="form-control"><option>병원</option><option>제약사</option><option>연구기관</option><option>CRO</option></select></div>
      <div class="form-group"><label class="form-label">사업자등록번호</label><div class="form-inline"><input class="form-control"><button class="btn btn-light">중복 확인</button></div></div>
      <div class="form-group"><label class="form-label">기관 연락처</label><input class="form-control"></div>
    </div>
  </div>
  <div class="notice">※ 기관 가입 후 관리자 승인 완료 시 임상시험 등록 기능을 사용할 수 있습니다.</div>
  <div style="text-align:right;margin-top:24px"><button class="btn btn-primary" data-demo-alert="가입 신청 기능은 BUSINESS 연동 단계에서 적용합니다.">가입 신청</button></div>
</div></div></main>
<%@ include file="/WEB-INF/views/common/footer.jsp" %></body></html>