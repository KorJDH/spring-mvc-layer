# GUIDE-09. 전체 흐름 따라가기 — 글 등록 한 사이클

> 지금까지 배운 모든 내용을 하나로 연결합니다.
> "글 등록하기" 기능이 실행되는 순간부터 목록 화면이 뜰 때까지
> 코드가 어떻게 흘러가는지 파일별로 따라가 봅시다.

---

## 시나리오

> 사용자가 "글쓰기" 버튼을 누르고, 제목/내용/작성자를 입력한 뒤
> "등록" 버튼을 클릭합니다.

---

## 먼저 모든 파일을 열어두세요

이 가이드를 따라가면서 각 파일을 번갈아 확인합니다.
IntelliJ에서 미리 열어두면 편합니다.

**열어야 할 파일들 (파일명 검색: Ctrl+Shift+N / Cmd+Shift+O):**

1. `list.jsp` — 목록 화면 (글쓰기 버튼 있는 곳)
2. `writeForm.jsp` — 글쓰기 폼
3. `BoardController.java` — 요청 받는 곳
4. `BoardServiceImpl.java` — 비즈니스 로직
5. `BoardDAOImpl.java` — DB 창구
6. `BoardMapper.xml` — SQL

---

## Step 1. 글쓰기 폼 열기

**사용자 행동:** `/board/list` 에서 "글쓰기" 버튼 클릭

**`list.jsp`에서 찾아보세요:**
```html
<button onclick="location.href='/board/writeForm'">글쓰기</button>
```

**브라우저가 보내는 요청:**
```
GET /board/writeForm
```

---

**`BoardController.java`에서 찾아보세요:**

```java
@GetMapping("/writeForm")
public String writeForm() {
    return "board/writeForm";   // JSP 이름만 반환 (데이터 없음)
}
```

이 메서드는 아주 단순합니다. Service를 부를 필요도 없이
그냥 빈 폼 화면만 보여주면 됩니다.

---

**결과:** 브라우저에 빈 입력 폼이 표시됩니다.

```
/WEB-INF/views/board/writeForm.jsp → 빈 입력 폼 화면
```

---

## Step 2. 폼 작성 후 등록 버튼 클릭

**사용자가 입력:**
- 제목: "MyBatis 학습 정리"
- 작성자: "홍길동"
- 내용: "오늘 배운 내용..."

**`writeForm.jsp`에서 찾아보세요:**

```html
<form method="post" action="/board/write">
    <input type="text" name="boardTitle" value="MyBatis 학습 정리">
    <input type="text" name="boardWriter" value="홍길동">
    <textarea name="boardContent">오늘 배운 내용...</textarea>
    <button type="submit">등록</button>
</form>
```

등록 버튼(`<button type="submit">`) 클릭 시 폼 전송.

**브라우저가 보내는 요청:**
```
POST /board/write
Body: boardTitle=MyBatis 학습 정리&boardWriter=홍길동&boardContent=오늘 배운 내용...
```

> 💡 개발자 도구(F12) → Network 탭에서 실제로 확인할 수 있습니다.
> `POST /board/write` 요청을 클릭하고 `Payload` 탭을 보면 전송 데이터가 보입니다.

---

## Step 3. Controller가 요청을 받음

**`BoardController.java`에서 찾아보세요:**

```java
@PostMapping("/write")
public String insertBoard(BoardVO boardVO) {
    //                     └────────────┘
    //         Spring이 자동으로 폼 데이터를 BoardVO에 채워줌
    //         boardVO.boardTitle   = "MyBatis 학습 정리"
    //         boardVO.boardWriter  = "홍길동"
    //         boardVO.boardContent = "오늘 배운 내용..."

    boardService.insertBoard(boardVO);    // Service 호출

    return "redirect:/board/list";        // 등록 후 목록으로 이동 (PRG 패턴)
}
```

**Controller가 하는 일:**
1. 폼 데이터를 VO에 자동으로 채우기 (Spring이 해줌)
2. Service에 넘기기
3. 어디로 갈지 결정 (`redirect`)

**Controller가 하지 않는 일:**
- DB에 직접 저장하지 않음 → Service에게 시킴

---

## Step 4. Service가 비즈니스 로직 처리

**`BoardServiceImpl.java`에서 찾아보세요:**

```java
@Override
@Transactional           // 트랜잭션 시작
public void insertBoard(BoardVO boardVO) {
    boardDAO.insertBoard(boardVO);   // DAO에게 DB 작업 위임
}
// 정상 종료 → 트랜잭션 commit
// 에러 발생 → 트랜잭션 rollback (데이터 원상복구)
```

**Service가 하는 일:**
1. 트랜잭션 관리 (`@Transactional`)
2. DAO에게 실제 DB 작업 위임

> 💡 `insertBoard` 하나만 있어서 트랜잭션이 필요 없어 보이지만,
> 나중에 "글 등록 시 알림 이력도 함께 저장"처럼 여러 DB 작업이 생기면
> `@Transactional` 덕분에 자동으로 묶입니다.

---

## Step 5. DAO가 SQL 실행 준비

**`BoardDAOImpl.java`에서 찾아보세요:**

```java
@Override
public void insertBoard(BoardVO boardVO) {
    sqlSession.insert(
        "com.example.egov.board.mapper.BoardMapper.insertBoard",
        boardVO
    );
    // ↑ "BoardMapper.xml 파일에서 id가 'insertBoard'인 SQL을 실행해줘"
    //   "파라미터는 boardVO야"
}
```

**DAO가 하는 일:**
- SqlSession을 통해 Mapper XML의 SQL을 찾아서 실행 요청

---

## Step 6. Mapper XML의 SQL이 실행됨

**`BoardMapper.xml`에서 찾아보세요:**

```xml
<insert id="insertBoard" parameterType="boardVO">
    INSERT INTO tb_board (
        board_title,
        board_content,
        board_writer,
        board_hit,
        board_regdate
    ) VALUES (
        #{boardTitle},    <!-- "MyBatis 학습 정리" -->
        #{boardContent},  <!-- "오늘 배운 내용..." -->
        #{boardWriter},   <!-- "홍길동" -->
        0,
        NOW()
    )
</insert>
```

**실제 실행되는 SQL:**
```sql
INSERT INTO tb_board (board_title, board_content, board_writer, board_hit, board_regdate)
VALUES ('MyBatis 학습 정리', '오늘 배운 내용...', '홍길동', 0, '2024-01-15 10:30:00')
```

`#{boardTitle}` → boardVO의 `getBoardTitle()` 값이 들어감
`NOW()` → 현재 시각이 자동으로 들어감

---

## Step 7. DB에 저장됨

```
tb_board 테이블
┌──────────┬──────────────────────┬───────────────────┬──────────────┬──────────┬─────────────────────┐
│ board_no │ board_title          │ board_content     │ board_writer │ board_hit│ board_regdate       │
├──────────┼──────────────────────┼───────────────────┼──────────────┼──────────┼─────────────────────┤
│ 1        │ 전자정부프레임워크... │ 전자정부프레임워크│ 관리자       │ 5        │ 2024-01-15 09:00:00 │
│ 2        │ Spring MVC 패턴...   │ Controller-Servi..│ 강사         │ 3        │ 2024-01-15 09:30:00 │
│ 6        │ MyBatis 학습 정리    │ 오늘 배운 내용... │ 홍길동       │ 0        │ 2024-01-15 10:30:00 │
└──────────┴──────────────────────┴───────────────────┴──────────────┴──────────┴─────────────────────┘
                                                                              ↑ 방금 추가된 행!
```

> 💡 **H2 콘솔에서 직접 확인하기:**
> 1. `http://localhost:8080/h2-console` 접속
> 2. JDBC URL: `jdbc:h2:mem:egovdb`, User Name: `sa`
> 3. SQL 입력: `SELECT * FROM TB_BOARD ORDER BY BOARD_NO DESC;`
> 4. 방금 등록한 게시글이 맨 위에 보이는지 확인!

---

## Step 8. 거슬러 올라가며 반환

```
Mapper XML → SQL 실행 완료
    ↓
DAOImpl → 반환
    ↓
ServiceImpl → 트랜잭션 commit → 반환
    ↓
Controller → return "redirect:/board/list"
    ↓
브라우저 → GET /board/list 요청
    ↓
Controller → selectBoardList() 실행
    ↓
Service → DAO → DB 조회
    ↓
list.jsp → 목록 화면 (새 게시글 포함)
```

---

## 한눈에 보는 전체 흐름

```
[브라우저]
    │  POST /board/write
    │  Body: boardTitle=MyBatis 학습 정리&...
    ▼
[BoardController.insertBoard()]
    │  boardVO.boardTitle = "MyBatis 학습 정리" (자동 바인딩)
    │  boardService.insertBoard(boardVO)
    ▼
[BoardServiceImpl.insertBoard()]
    │  @Transactional 시작
    │  boardDAO.insertBoard(boardVO)
    ▼
[BoardDAOImpl.insertBoard()]
    │  sqlSession.insert("...insertBoard", boardVO)
    ▼
[BoardMapper.xml - <insert id="insertBoard">]
    │  INSERT INTO tb_board VALUES (...)
    ▼
[H2 Database]
    │  데이터 저장 완료
    ▼
[거슬러 올라가며 반환]
    ▼
[BoardServiceImpl] → @Transactional commit
    ▼
[BoardController] → return "redirect:/board/list"
    ▼
[브라우저] → GET /board/list 재요청
    ▼
[목록 화면에 새 게시글 표시]
```

---

## 나머지 기능도 같은 원리

이제 나머지 기능도 스스로 따라가 보세요:

**목록 조회:**
```
GET /board/list
→ Controller.selectBoardList()
→ Service.selectBoardList()
→ DAO.selectBoardList()
→ Mapper XML selectBoardList SQL
→ DB 조회
→ List<BoardVO> 반환
→ model.addAttribute("boardList", ...)
→ list.jsp 에서 <c:forEach> 로 출력
```

**상세 조회 (조회수 포함):**
```
GET /board/view?boardNo=6
→ Controller.selectBoard(6)
→ Service.selectBoard(6) — @Transactional
    → DAO.updateBoardHit(6)  — board_hit + 1
    → DAO.selectBoard(6)     — 게시글 조회
→ model.addAttribute("board", boardVO)
→ view.jsp 에서 ${board.boardTitle} 등 출력
```

---

## 최종 실습 — 모든 기능 직접 테스트하기

**준비:** 서버가 실행 중인지 확인 (터미널에 `Started EgovApplication` 메시지가 보여야 함)

**실행 중이 아니라면:**
```bash
# 프로젝트 폴더에서
mvn spring-boot:run
```

**테스트 순서:**

**1. 목록 페이지 접속**
- 브라우저에서 `http://localhost:8080/board/list`
- 샘플 게시글 목록이 보이는지 확인

**2. 글쓰기 테스트**
- "글쓰기" 버튼 클릭
- 제목, 작성자, 내용 입력
- "등록" 버튼 클릭
- → 목록에 새 글이 추가되었나요?

**3. 상세보기 테스트**
- 게시글 제목 클릭
- 내용이 제대로 보이나요?
- 상세보기를 할 때마다 조회수가 1씩 늘어나나요?

**4. 수정 테스트**
- 상세 화면에서 "수정" 버튼 클릭
- 내용 변경 후 저장
- 변경된 내용이 반영되었나요?

**5. 삭제 테스트**
- 삭제 버튼 클릭
- 확인 창에서 "확인" 클릭
- 목록에서 사라졌나요?

**6. H2 콘솔에서 직접 확인**
- `http://localhost:8080/h2-console`
- JDBC URL: `jdbc:h2:mem:egovdb`, User Name: `sa`
- SQL:
  ```sql
  SELECT * FROM TB_BOARD ORDER BY BOARD_NO DESC;
  ```

**7. 로그 확인**
- 서버 실행 중인 터미널 창 보기
- SQL 쿼리가 실행되는 로그가 출력되는지 확인

---

## 막혔을 때 — 에러 해결 방법

**빨간 에러 메시지가 터미널에 나올 때:**
1. 터미널에서 `ERROR` 또는 `Exception` 글자가 있는 줄 찾기
2. 그 줄의 내용을 복사해서 구글에 검색
3. 자주 나오는 에러들:

| 에러 메시지 | 원인 | 해결 방법 |
|------------|------|---------|
| `BindingException: Invalid bound statement` | Mapper XML의 namespace 또는 id 오타 | DAOImpl의 NAMESPACE와 Mapper XML의 namespace가 같은지 확인 |
| `NullPointerException` | null인 변수를 사용 | `@Autowired`가 제대로 있는지 확인 |
| `404 Not Found` | URL 오타 또는 @Mapping 없음 | Controller의 @GetMapping/@PostMapping URL 확인 |
| `500 Internal Server Error` | 코드에 에러 | 터미널 로그에서 에러 원인 확인 |

**페이지가 안 열릴 때:**
- [ ] 서버가 실행 중인가? (터미널에 `Started EgovApplication` 메시지 확인)
- [ ] 주소가 맞는가? (`http://localhost:8080/board/list`)
- [ ] 포트가 맞는가? (application.properties의 `server.port` 확인)

---

## 학습을 마치며

이 프로젝트를 통해 배운 것:

```
✅ HTTP 요청(GET/POST)이 어떻게 서버에 전달되는가
✅ Spring MVC의 Controller → Service → DAO → DB 흐름
✅ VO로 계층 간 데이터를 전달하는 방법
✅ MyBatis로 SQL을 XML에서 관리하는 방법
✅ @Transactional로 트랜잭션을 보장하는 방법
✅ JSP + JSTL + EL로 동적 화면을 만드는 방법
✅ PRG 패턴으로 중복 요청을 방지하는 방법
```

**다음 단계로 나아가려면:**

1. **댓글 기능 추가해보기**
   - `tb_comment` 테이블 새로 만들기 (schema.sql 수정)
   - CommentVO, CommentDAO, CommentService, CommentController 새로 만들기
   - 게시글 상세 화면(view.jsp)에 댓글 목록 추가

2. **페이징 UI 직접 구현해보기**
   - list.jsp에 `[1] [2] [3] ... [10]` 형태의 페이지 버튼 추가

3. **검색 기능 개선해보기**
   - BoardMapper.xml에서 동적 SQL(`<if>`) 수정해보기

4. **Oracle DB로 교체해보기**
   - `application.properties`의 datasource 설정만 바꾸면 됨
   - (MyBatis + DAO 덕분에 Java 코드는 거의 안 바꿔도 됨)

---

이전: [GUIDE-08-JSP.md](GUIDE-08-JSP.md)
처음으로: [GUIDE-00-시작하기전에.md](GUIDE-00-시작하기전에.md)
