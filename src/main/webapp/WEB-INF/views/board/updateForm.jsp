<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 수정</title>
    <style>
        body { font-family: 맑은 고딕, Arial, sans-serif; margin: 20px; }
        h1 { color: #003876; border-bottom: 2px solid #003876; padding-bottom: 8px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #f5f5f5; padding: 10px; text-align: left; width: 120px;
             border: 1px solid #ddd; color: #333; }
        td { padding: 10px; border: 1px solid #ddd; }
        input[type=text], textarea { width: 98%; padding: 6px; border: 1px solid #ccc; }
        textarea { height: 200px; resize: vertical; }
        .btn { padding: 6px 14px; color: white; border: none; cursor: pointer; border-radius: 3px; }
        .btn-primary { background: #e67e00; }
        .btn-default { background: #888; }
        .btn-group { margin-top: 15px; display: flex; gap: 8px; }

        .study-box { background: #fffbea; border: 1px solid #f0c040; padding: 12px 16px;
                     margin-bottom: 20px; border-radius: 4px; font-size: 0.88em; }
        .study-box h3 { margin: 0 0 8px; color: #7a5500; }
    </style>
</head>
<body>

<div class="study-box">
    <h3>📚 [학습 포인트] 게시글 수정 폼 (updateForm.jsp)</h3>
    <ul>
        <li><b>hidden 필드</b>: boardNo는 화면에 표시 안 하지만 서버로 전달해야 하므로 hidden type 사용</li>
        <li><b>value="${board.boardTitle}"</b>: 기존 데이터를 폼에 미리 채워줌 (Controller에서 model에 담아 전달)</li>
        <li><b>수정 후 흐름</b>: POST /board/update → redirect → GET /board/view (PRG 패턴)</li>
    </ul>
</div>

<h1>게시글 수정</h1>

<form method="post" action="/board/update">

    <%-- boardNo는 URL에 노출되지 않고 hidden으로 전달 --%>
    <input type="hidden" name="boardNo" value="${board.boardNo}">

    <table>
        <tr>
            <th>번호</th>
            <td>${board.boardNo}</td>
        </tr>
        <tr>
            <th>제목 <span style="color:red">*</span></th>
            <td>
                <%-- 기존 값을 value에 채워서 보여줌 --%>
                <input type="text" name="boardTitle" value="${board.boardTitle}" required maxlength="200">
            </td>
        </tr>
        <tr>
            <th>작성자 <span style="color:red">*</span></th>
            <td>
                <input type="text" name="boardWriter" value="${board.boardWriter}" required maxlength="50">
            </td>
        </tr>
        <tr>
            <th>내용 <span style="color:red">*</span></th>
            <td>
                <textarea name="boardContent" required>${board.boardContent}</textarea>
            </td>
        </tr>
        <tr>
            <th>등록일</th>
            <td>${board.boardRegdate}</td>
        </tr>
    </table>

    <div class="btn-group">
        <button type="submit" class="btn btn-primary">수정</button>
        <button type="button" class="btn btn-default"
                onclick="location.href='/board/view?boardNo=${board.boardNo}'">취소</button>
    </div>
</form>

</body>
</html>
