<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 등록</title>
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
        .btn-primary { background: #003876; }
        .btn-default { background: #888; }
        .btn-group { margin-top: 15px; display: flex; gap: 8px; }

        .study-box { background: #fffbea; border: 1px solid #f0c040; padding: 12px 16px;
                     margin-bottom: 20px; border-radius: 4px; font-size: 0.88em; }
        .study-box h3 { margin: 0 0 8px; color: #7a5500; }
    </style>
</head>
<body>

<div class="study-box">
    <h3>📚 [학습 포인트] 게시글 등록 폼 (writeForm.jsp)</h3>
    <ul>
        <li><b>method="post"</b>: 데이터를 생성/변경하는 요청은 반드시 POST (GET은 조회에만)</li>
        <li><b>name 속성</b>: <code>name="boardTitle"</code> → BoardVO의 <code>boardTitle</code> 필드에 자동 바인딩</li>
        <li><b>Spring MVC 데이터 바인딩</b>: form 파라미터명과 VO 필드명이 일치하면 자동으로 채워줌</li>
        <li><b>유효성 검사</b>: 실무에서는 Bean Validation(@NotBlank 등)을 함께 사용</li>
    </ul>
</div>

<h1>게시글 등록</h1>

<%-- action="/board/write" → BoardController의 @PostMapping("/write") 로 전달 --%>
<form method="post" action="/board/write">

    <table>
        <tr>
            <th>제목 <span style="color:red">*</span></th>
            <td>
                <%-- name="boardTitle" → BoardVO.boardTitle 에 자동 바인딩 --%>
                <input type="text" name="boardTitle" placeholder="제목을 입력하세요" required maxlength="200">
            </td>
        </tr>
        <tr>
            <th>작성자 <span style="color:red">*</span></th>
            <td>
                <input type="text" name="boardWriter" placeholder="작성자명을 입력하세요" required maxlength="50">
            </td>
        </tr>
        <tr>
            <th>내용 <span style="color:red">*</span></th>
            <td>
                <textarea name="boardContent" placeholder="내용을 입력하세요" required></textarea>
            </td>
        </tr>
    </table>

    <div class="btn-group">
        <button type="submit" class="btn btn-primary">등록</button>
        <button type="button" class="btn btn-default" onclick="location.href='/board/list'">취소</button>
    </div>
</form>

</body>
</html>
