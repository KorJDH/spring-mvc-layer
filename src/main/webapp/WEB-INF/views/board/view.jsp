<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 상세</title>
    <style>
        body { font-family: 맑은 고딕, Arial, sans-serif; margin: 20px; }
        h1 { color: #003876; border-bottom: 2px solid #003876; padding-bottom: 8px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #f5f5f5; padding: 10px; text-align: left; width: 120px;
             border: 1px solid #ddd; color: #333; }
        td { padding: 10px; border: 1px solid #ddd; }
        .content-area { min-height: 150px; white-space: pre-wrap; }
        .btn { padding: 6px 14px; color: white; border: none; cursor: pointer; border-radius: 3px; }
        .btn-primary { background: #003876; }
        .btn-warning { background: #e67e00; }
        .btn-danger  { background: #c0392b; }
        .btn-group { margin-top: 15px; display: flex; gap: 8px; }

        .study-box { background: #fffbea; border: 1px solid #f0c040; padding: 12px 16px;
                     margin-bottom: 20px; border-radius: 4px; font-size: 0.88em; }
        .study-box h3 { margin: 0 0 8px; color: #7a5500; }
    </style>
</head>
<body>

<div class="study-box">
    <h3>📚 [학습 포인트] 게시글 상세 (view.jsp)</h3>
    <ul>
        <li><b>EL</b>: <code>${board.boardTitle}</code> → Controller에서 model.addAttribute("board", board) 로 담은 BoardVO 객체의 getBoardTitle() 자동 호출</li>
        <li><b>삭제 확인</b>: JavaScript confirm()으로 실수 방지. form submit으로 POST 요청</li>
        <li><b>조회수</b>: ServiceImpl에서 updateBoardHit() → selectBoard() 순서로 트랜잭션 처리</li>
    </ul>
</div>

<h1>게시글 상세</h1>

<table>
    <tr>
        <th>제목</th>
        <td>${board.boardTitle}</td>
    </tr>
    <tr>
        <th>작성자</th>
        <td>${board.boardWriter}</td>
    </tr>
    <tr>
        <th>조회수</th>
        <td>${board.boardHit}</td>
    </tr>
    <tr>
        <th>등록일</th>
        <td>${board.boardRegdate}</td>
    </tr>
    <tr>
        <th>내용</th>
        <td class="content-area">${board.boardContent}</td>
    </tr>
</table>

<div class="btn-group">
    <button class="btn btn-primary" onclick="location.href='/board/list'">목록</button>
    <button class="btn btn-warning" onclick="location.href='/board/updateForm?boardNo=${board.boardNo}'">수정</button>

    <%-- 삭제: GET이 아닌 POST로 처리해야 합니다 (데이터 변경은 항상 POST) --%>
    <form id="deleteForm" method="post" action="/board/delete" style="display:inline;">
        <input type="hidden" name="boardNo" value="${board.boardNo}">
        <button type="button" class="btn btn-danger"
                onclick="if(confirm('정말 삭제하시겠습니까?')) document.getElementById('deleteForm').submit()">
            삭제
        </button>
    </form>
</div>

</body>
</html>
