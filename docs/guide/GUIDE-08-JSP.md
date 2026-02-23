# GUIDE-08. JSP — 화면 만들기

> JSP는 HTML에 Java 코드를 섞어 쓸 수 있는 화면 파일입니다.
> 전자정부프레임워크는 JSP를 기본 View(화면)로 사용합니다.

---

## 읽을 파일

**IntelliJ에서 열기:**
- `src/main/webapp/WEB-INF/views/board/list.jsp`
- `src/main/webapp/WEB-INF/views/board/view.jsp`
- `src/main/webapp/WEB-INF/views/board/writeForm.jsp`
- `src/main/webapp/WEB-INF/views/board/updateForm.jsp`

> IntelliJ 왼쪽 패널에서 `src/main/webapp/WEB-INF/views/board/` 폴더 찾기
> 또는 파일 검색: `Ctrl+Shift+N` / `Cmd+Shift+O` → `list.jsp` 입력

---

## 1. JSP란?

**JSP = JavaServer Pages**

HTML만으로는 DB 데이터를 화면에 뿌릴 수 없습니다.
JSP는 HTML 안에서 서버의 데이터를 출력할 수 있게 해줍니다.

```jsp
<!-- 순수 HTML (정적) -->
<td>게시글 제목이 여기에 고정되어 있음</td>

<!-- JSP (동적) -->
<td>${board.boardTitle}</td>
<!-- ↑ Controller가 model에 담아서 보내준 실제 데이터가 출력됨 -->
```

**비유:**
> 인쇄된 메뉴판(HTML) vs 매일 바뀌는 화이트보드 메뉴(JSP)
> - HTML: 고정된 내용만 표시
> - JSP: 서버의 최신 데이터를 가져와서 화면에 표시

---

## 2. JSP 파일의 상단 선언부

모든 JSP 파일 맨 위에 이 두 줄이 있습니다:

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
```

**첫 번째 줄 — 페이지 설정:**
- `contentType="text/html;charset=UTF-8"`: 한글 깨짐 방지
- `language="java"`: Java를 사용하는 JSP 파일

**두 번째 줄 — JSTL 라이브러리 불러오기:**
- `prefix="c"`: JSTL 태그를 `<c:태그명>` 형태로 사용
- 이게 없으면 `<c:forEach>`, `<c:if>` 를 쓸 수 없음

> 💡 JSP 파일을 새로 만들 때는 이 두 줄을 반드시 맨 위에 붙여넣으세요.

---

## 3. EL (Expression Language) — `${}` 문법

Controller에서 `model.addAttribute("board", boardVO)` 로 보낸 데이터를
JSP에서 `${}` 로 꺼내 씁니다.

```jsp
<!-- Controller에서 -->
model.addAttribute("board", boardVO);
model.addAttribute("totalCount", 50);

<!-- JSP에서 -->
${board.boardTitle}    <!-- boardVO.getBoardTitle() 자동 호출 -->
${board.boardNo}       <!-- boardVO.getBoardNo() 자동 호출 -->
${totalCount}          <!-- 50 출력 -->
```

**EL을 쓰지 않으면 (구식 방법):**
```jsp
<%
    BoardVO board = (BoardVO) request.getAttribute("board");
    out.print(board.getBoardTitle());
%>
```

EL 덕분에 JSP 안에 Java 코드가 최소화됩니다.

**`${board.boardTitle}` 을 읽는 방법:**
```
${ board . boardTitle }
    ↑       ↑
  model에   boardVO의
  넣은 키   필드명(또는 getter의 메서드명에서 get을 뺀 것)
```

---

## 4. JSTL — HTML처럼 생긴 Java 문법

### `<c:forEach>` — 반복문

```jsp
<!-- Java의 for문과 같음 -->
<c:forEach var="board" items="${boardList}" varStatus="status">
    <tr>
        <td>${board.boardNo}</td>
        <td>${board.boardTitle}</td>
        <td>${board.boardWriter}</td>
    </tr>
</c:forEach>
```

- `items="${boardList}"`: Controller에서 보낸 List 데이터
- `var="board"`: 반복할 때 한 개씩 꺼낸 변수명 (내가 원하는 이름 써도 됨)
- `varStatus="status"`: 반복 상태 정보 (index, count 등)

**Java로 쓰면 이것과 같습니다:**
```java
for (BoardVO board : boardList) {
    // board.getBoardNo(), board.getBoardTitle(), ...
}
```

**`<c:forEach>` 안에서 `${board.xxx}`를 쓸 때:**
- `var="board"` 로 선언했기 때문에 `${board.boardTitle}` 로 사용
- `var="item"` 으로 바꾸면 `${item.boardTitle}` 로 사용해야 함

---

### `<c:if>` — 조건문

```jsp
<!-- boardList가 비어있으면 메시지 표시 -->
<c:if test="${empty boardList}">
    <tr>
        <td colspan="5">등록된 게시글이 없습니다.</td>
    </tr>
</c:if>

<!-- searchCondition 값에 따라 selected 처리 -->
<option value="title"
        <c:if test="${boardVO.searchCondition == 'title'}">selected</c:if>>
    제목
</option>
```

**Java의 if문과 같습니다:**
```java
if (boardList.isEmpty()) {
    // ...
}
if ("title".equals(boardVO.getSearchCondition())) {
    // selected
}
```

**`${empty boardList}` 란?**
> `empty`는 null이거나 빈 목록인지 확인하는 EL 연산자입니다.
> - 게시글이 없으면 `true` → `<c:if>` 블록 실행
> - 게시글이 있으면 `false` → `<c:if>` 블록 실행 안 함

---

## 5. 폼(Form) — 데이터를 서버로 보내기

```jsp
<!-- 등록 폼 (writeForm.jsp) -->
<form method="post" action="/board/write">
<!--         └────┘         └───────────┘
             POST 방식        Controller의 @PostMapping("/write") 로 전달  -->

    <input type="text" name="boardTitle" placeholder="제목">
    <!--                    └──────────┘
                    Controller의 BoardVO.boardTitle 필드에 자동 매핑  -->

    <input type="text" name="boardWriter">
    <textarea name="boardContent"></textarea>

    <button type="submit">등록</button>
    <!--         └──────┘
                 클릭하면 폼 데이터를 action URL로 POST 전송  -->
</form>
```

**`name` 속성과 VO 필드명이 일치해야 자동 매핑이 됩니다:**

```
HTML form                    BoardVO
name="boardTitle"    →      private String boardTitle
name="boardWriter"   →      private String boardWriter
name="boardContent"  →      private String boardContent
```

**`name`이 다르면 어떻게 될까요?**
> `name="title"` 로 하면 BoardVO의 `boardTitle` 필드에 값이 안 들어갑니다.
> (BoardVO에는 `title`이라는 필드가 없기 때문)
> `boardTitle` 필드는 `null`이 됩니다.

---

## 6. hidden 필드 — 숨겨서 보내기

수정 폼에서는 게시글 번호(boardNo)를 화면에 표시하지 않지만
서버로는 반드시 보내야 합니다.

```jsp
<!-- updateForm.jsp -->
<form method="post" action="/board/update">

    <!-- 화면에는 안 보이지만 서버로 전달됨 -->
    <input type="hidden" name="boardNo" value="${board.boardNo}">
    <!--         └─────┘
                 사용자 눈에 안 보이는 필드  -->

    <input type="text" name="boardTitle" value="${board.boardTitle}">
    <!-- ↑ 기존 제목이 미리 채워져 있음 -->
</form>
```

**왜 hidden 필드가 필요할까요?**
> 수정 처리 시 "몇 번 게시글을 수정하라"는 정보가 필요합니다.
> 이 번호를 화면에 보여줄 필요는 없지만(사용자가 변경하면 안 되므로),
> 서버에는 반드시 전달해야 합니다.
> → `type="hidden"` 으로 숨겨서 전송

---

## 7. 삭제 버튼 — POST로 처리하는 이유

```jsp
<!-- view.jsp -->
<form id="deleteForm" method="post" action="/board/delete">
    <input type="hidden" name="boardNo" value="${board.boardNo}">
    <button type="button"
            onclick="if(confirm('정말 삭제하시겠습니까?')) document.getElementById('deleteForm').submit()">
        삭제
    </button>
</form>
```

**코드 해설:**
- `confirm('정말 삭제하시겠습니까?')`: 확인/취소 창을 띄움
- 확인 클릭 → `document.getElementById('deleteForm').submit()`: 폼 전송
- 취소 클릭 → 아무 일도 안 일어남

**왜 삭제를 GET이 아닌 POST로 처리하나요?**

```
GET으로 삭제하면:
/board/delete?boardNo=5

이 URL을 이메일로 보내거나, 검색엔진이 크롤링하면
→ 모르는 사람이 클릭만 해도 게시글이 삭제됨! (보안 위험)

POST로 삭제하면:
폼을 직접 제출해야만 삭제 요청이 만들어짐
→ 실수나 악의적인 삭제 방지
```

---

## 8. 4개 JSP 파일 역할 정리

### list.jsp — 목록 화면

```
Controller에서 받는 것:
- ${boardList}    : 게시글 목록 (List<BoardVO>)
- ${totalCount}   : 총 게시글 수
- ${boardVO}      : 검색 조건 (다시 폼에 표시하기 위해)

화면에 보여주는 것:
- 검색 폼 (검색 조건, 검색어)
- 게시글 목록 테이블
- 글쓰기 버튼
```

### view.jsp — 상세 화면

```
Controller에서 받는 것:
- ${board}  : 게시글 1개 (BoardVO)

화면에 보여주는 것:
- 게시글 제목, 작성자, 조회수, 등록일, 내용
- 목록/수정/삭제 버튼
```

### writeForm.jsp — 등록 폼

```
Controller에서 받는 것:
- (없음, 빈 폼)

화면에 보여주는 것:
- 제목, 작성자, 내용 입력 폼
- 등록/취소 버튼
```

### updateForm.jsp — 수정 폼

```
Controller에서 받는 것:
- ${board}  : 기존 게시글 (폼에 미리 채워넣기 위해)

화면에 보여주는 것:
- 기존 내용이 채워진 폼
- 수정/취소 버튼
- hidden으로 boardNo 전달
```

---

## 9. 실습 — JSP 파일 직접 확인하기

**`list.jsp` 확인:**

- [ ] 파일 맨 위 두 줄(`<%@ page ...%>`, `<%@ taglib ...%>`) 확인

- [ ] `<c:forEach>` 시작 태그와 끝 태그(`</c:forEach>`) 찾기
  ```jsp
  <c:forEach var="board" items="${boardList}">
      ...
  </c:forEach>
  ```
  - 이 사이에 있는 `<tr>` 태그가 게시글 수만큼 반복 출력됩니다

- [ ] `${board.boardTitle}` 이 링크(`<a href=...>`)로 감싸진 부분 찾기
  - 클릭하면 상세 페이지(`/board/view?boardNo=...`)로 이동합니다

- [ ] `<c:if test="${empty boardList}">` 찾기
  - 이 블록은 게시글이 없을 때만 표시됩니다

- [ ] 검색 폼의 `<select name="searchCondition">` 찾기
  - `name`이 `searchCondition`인 이유: BoardVO의 `searchCondition` 필드에 매핑되기 때문

**`writeForm.jsp` 확인:**

- [ ] `<form method="post" action="/board/write">` 찾기
  - 이 폼이 제출되면 `BoardController`의 `@PostMapping("/write")` 메서드로 전달

- [ ] `name="boardTitle"`, `name="boardWriter"`, `name="boardContent"` 찾기
  - BoardVO의 어느 필드에 매핑되는지 확인

**`updateForm.jsp` 확인:**

- [ ] `<input type="hidden" name="boardNo" value="${board.boardNo}">` 찾기
  - 왜 hidden 타입으로 boardNo를 보내는지 이해했나요?

- [ ] `value="${board.boardTitle}"` — 기존 값이 입력 폼에 미리 채워져 있나요?

---

## 핵심 요약

```
✅ JSP = HTML + 서버 데이터를 출력할 수 있는 동적 화면
✅ ${변수명} = EL, Controller에서 model에 담아 보낸 데이터 출력
✅ <c:forEach> = 리스트 반복 출력 (for문)
✅ <c:if test="..."> = 조건부 출력 (if문)
✅ <form method="post"> = POST 방식으로 데이터 전송
✅ name="필드명" = VO의 필드명과 일치해야 자동 바인딩
✅ <input type="hidden"> = 화면엔 안 보이지만 서버로 전달
✅ 삭제는 항상 POST로 (GET 삭제는 보안 위험)
```

---

이전: [GUIDE-07-Controller.md](GUIDE-07-Controller.md)
다음: [GUIDE-09-전체흐름.md](GUIDE-09-전체흐름.md)
