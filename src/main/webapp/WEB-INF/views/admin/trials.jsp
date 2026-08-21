<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>임상시험 검수 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>임상시험 검수 관리</h1></div>
<div class="table-card"><table class="table"><thead><tr><th>번호</th><th>임상시험 제목</th><th>기관</th><th>단계</th><th>검수상태</th><th>관리</th></tr></thead><tbody><tr><td>27</td><td>차세대 유전자 치료제 임상 2/3상</td><td>서울대학교병원</td><td>2/3상</td><td><span class="badge badge-gray">대기</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>26</td><td>헌팅턴병 치료제 효과 평가</td><td>세브란스병원</td><td>2상</td><td><span class="badge badge-green">승인</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>25</td><td>파브리병 효소대체요법</td><td>삼성서울병원</td><td>3상</td><td><span class="badge badge-red">반려</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr></tbody></table></div>
<div class="card"><h3>임상시험 검수 상세</h3><p><strong>시험명</strong><br>차세대 유전자 치료제 임상 2/3상 연구</p><p><strong>연구 목적</strong><br>희귀 유전 질환 환자를 대상으로 안전성과 유효성을 평가합니다.</p><p><strong>모집 상태</strong> 모집중 &nbsp;&nbsp; <strong>임상 단계</strong> 2/3상</p><div style="text-align:right"><button class="btn btn-danger">반려</button> <button class="btn btn-primary">승인/공개</button></div></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>