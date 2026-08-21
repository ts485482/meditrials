<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html><html lang="ko"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>프리미엄 노출 관리 | MediTrials</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/meditrials.css">
</head><body>
<div class="page-shell"><%@ include file="/WEB-INF/views/common/sidebar-admin.jsp" %><main class="dashboard-main">
<div class="dashboard-head"><h1>프리미엄 노출 관리</h1></div>
<div class="table-card"><table class="table"><thead><tr><th>번호</th><th>임상시험</th><th>기관</th><th>신청일</th><th>노출기간</th><th>상태</th><th>관리</th></tr></thead><tbody><tr><td>18</td><td>차세대 유전자 치료제 임상</td><td>서울대학교병원</td><td>08.21</td><td>08.22~09.21</td><td><span class="badge badge-gray">대기</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>17</td><td>헌팅턴병 치료제 평가</td><td>세브란스병원</td><td>08.20</td><td>08.20~09.20</td><td><span class="badge badge-green">활성</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr><tr><td>16</td><td>낭포성 섬유증 치료제</td><td>삼성서울병원</td><td>08.19</td><td>08.19~09.19</td><td><span class="badge badge-green">활성</span></td><td><button class="btn btn-sm btn-outline">상세</button></td></tr></tbody></table></div>
<div class="card"><h3>노출 상세</h3><p><strong>노출 위치</strong><br>메인 추천 영역 / 검색 상단</p><p><strong>기간</strong><br>2026.08.22 ~ 2026.09.21</p><div style="text-align:right"><button class="btn btn-danger">반려</button> <button class="btn btn-primary">노출 승인</button></div></div>
</main></div><script src="${pageContext.request.contextPath}/js/meditrials.js"></script></body></html>