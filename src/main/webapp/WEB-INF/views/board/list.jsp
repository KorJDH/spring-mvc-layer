<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판 목록</title>
    <style>
        body { font-family: 맑은 고딕, Arial, sans-serif; margin: 20px; }
        h1 { color: #003876; border-bottom: 2px solid #003876; padding-bottom: 8px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #003876; color: white; padding: 10px; text-align: center; }
        td { padding: 8px 10px; border-bottom: 1px solid #ddd; text-align: center; }
        td.title { text-align: left; }
        tr:hover td { background: #f0f4ff; }
        a { color: #003876; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .btn { padding: 6px 14px; background: #003876; color: white; border: none; cursor: pointer; border-radius: 3px; }
        .search-box { margin: 10px 0; display: flex; gap: 8px; }
        .total { color: #555; font-size: 0.9em; margin-top: 10px; }
        .paging { margin-top: 15px; text-align: center; }
        .paging a, .paging span { margin: 0 4px; padding: 4px 8px; border: 1px solid #ccc; }
        .paging .current { background: #003876; color: white; border-color: #003876; }

        /* 학습용 주석 박스 */
        .study-box { background: #fffbea; border: 1px solid #f0c040; padding: 12px 16px;
                     margin-bottom: 20px; border-radius: 4px; font-size: 0.88em; }
        .study-box h3 { margin: 0 0 8px; color: #7a5500; }
    </style>
</head>
<body>

<!-- ===== 학습용 설명 박스 ===== -->
<div class="study-box">
    <h3>📚 [학습 포인트] 게시글 목록 (list.jsp)</h3>
    <ul>
        <li><b>EL (Expression Language)</b>: <code>${boardList}</code> → Controller에서 model.addAttribute("boardList", ...) 로 담은 값</li>
        <li><b>JSTL c:forEach</b>: Java의 for문과 동일. JSP에서 반복 처리에 사용</li>
        <li><b>JSTL c:if</b>: 조건부 출력. 검색어 없을 때 빈 상태 메시지 표시</li>
        <li><b>PRG 패턴</b>: 등록/수정 후 redirect하여 새로고침 시 중복 실행 방지</li>
    </ul>
</div>

<h1>게시판</h1>

<!-- ===== 검색 폼 ===== -->
<form method="get" action="/board/list">
    <div class="search-box">
        <select name="searchCondition">
            <option value="title"   <c:if test="${boardVO.searchCondition == 'title'}">selected</c:if>>제목</option>
            <option value="content" <c:if test="${boardVO.searchCondition == 'content'}">selected</c:if>>내용</option>
            <option value="writer"  <c:if test="${boardVO.searchCondition == 'writer'}">selected</c:if>>작성자</option>
        </select>
        <input type="text" name="searchKeyword" value="${boardVO.searchKeyword}" placeholder="검색어를 입력하세요">
        <button type="submit" class="btn">검색</button>
    </div>
</form>

<div class="total">총 <b>${totalCount}</b>건</div>

<!-- ===== 게시글 목록 테이블 ===== -->
<table>
    <thead>
        <tr>
            <th width="80">번호</th>
            <th>제목</th>
            <th width="100">작성자</th>
            <th width="80">조회수</th>
            <th width="130">등록일</th>
        </tr>
    </thead>
    <tbody>
        <%-- JSTL forEach: boardList가 비어있으면 이 블록은 실행되지 않음 --%>
        <c:forEach var="board" items="${boardList}" varStatus="status">
            <tr>
                <td>${board.boardNo}</td>
                <td class="title">
                    <a href="/board/view?boardNo=${board.boardNo}">${board.boardTitle}</a>
                </td>
                <td>${board.boardWriter}</td>
                <td>${board.boardHit}</td>
                <td>${board.boardRegdate}</td>
            </tr>
        </c:forEach>

        <%-- 게시글이 없을 때 표시 --%>
        <c:if test="${empty boardList}">
            <tr>
                <td colspan="5" style="text-align:center; padding: 30px; color: #888;">
                    등록된 게시글이 없습니다.
                </td>
            </tr>
        </c:if>
    </tbody>
</table>

<!-- ===== 등록 버튼 ===== -->
<div style="text-align:right; margin-top: 10px;">
    <button class="btn" onclick="location.href='/board/writeForm'">글쓰기</button>
</div>

</body>
</html>
