# GUIDE-07. Controller — 요청을 받아 응답 돌려주기

> Controller는 브라우저와 서버 사이의 "안내 데스크"입니다.
> 요청을 받아서 Service에 넘기고, 결과를 화면(JSP)에 전달하는 것이 전부입니다.

---

## 읽을 파일

**IntelliJ에서 열기:**
`src/main/java/com/example/egov/board/controller/BoardController.java`

> 파일 검색: `Ctrl+Shift+N` (Windows) / `Cmd+Shift+O` (Mac) → `BoardController` 입력

---

## 1. Controller의 역할 3가지

```java
@Controller                  // 1. "이건 Controller야" 라고 Spring에게 알림
@RequestMapping("/board")    // 2. 이 Controller는 "/board"로 시작하는 URL 담당
public class BoardController {

    @Autowired
    private BoardService boardService;

    @GetMapping("/list")     // 3. GET /board/list 요청이 오면 이 메서드 실행
    public String selectBoardList(BoardVO boardVO, ModelMap model) {
        // ① 요청 파라미터를 받아서 (boardVO에 자동으로 담김)
        List<BoardVO> boardList = boardService.selectBoardList(boardVO);  // ② Service 호출
        model.addAttribute("boardList", boardList);  // ③ 결과를 JSP에 전달
        return "board/list";  // ④ 어느 JSP를 보여줄지 반환
    }
}
```

**Controller가 하는 일:**
1. HTTP 요청 받기
2. 파라미터 추출 (자동 바인딩)
3. Service 호출
4. 결과를 Model에 담기
5. View 이름(JSP 경로) 반환

**Controller가 하면 안 되는 일:**
- SQL 직접 실행 (DAO의 역할)
- 복잡한 업무 로직 (Service의 역할)

> 💡 Controller는 "교통 정리"만 합니다. 실제 일은 Service에게 시킵니다.

---

## 2. URL 매핑 어노테이션

### @RequestMapping — 클래스 단위 공통 경로

```java
@RequestMapping("/board")   // 이 Controller의 모든 URL은 "/board"로 시작
```

### @GetMapping — GET 요청 처리

```java
@GetMapping("/list")          // GET /board/list
@GetMapping("/view")          // GET /board/view
@GetMapping("/writeForm")     // GET /board/writeForm
@GetMapping("/updateForm")    // GET /board/updateForm
```

### @PostMapping — POST 요청 처리

```java
@PostMapping("/write")    // POST /board/write (등록 처리)
@PostMapping("/update")   // POST /board/update (수정 처리)
@PostMapping("/delete")   // POST /board/delete (삭제 처리)
```

**URL이 만들어지는 방식:**
```
@RequestMapping("/board")  +  @GetMapping("/list")
        ↓                           ↓
    "/board"              +      "/list"
                    =  "/board/list"
```

**GET vs POST 다시 확인:**
- GET → 화면을 보여달라 (목록, 상세, 폼)
- POST → 데이터를 처리해달라 (등록, 수정, 삭제)

---

## 3. 파라미터 자동 바인딩

브라우저가 보내는 파라미터를 Java 객체에 자동으로 채워줍니다.
이것이 Spring의 강력한 기능 중 하나입니다.

### VO로 받기

```java
@GetMapping("/list")
public String selectBoardList(BoardVO boardVO, ModelMap model) {
    // URL: /board/list?searchCondition=title&searchKeyword=Spring&pageIndex=2
    //
    // Spring이 자동으로:
    // boardVO.searchCondition = "title"
    // boardVO.searchKeyword   = "Spring"
    // boardVO.pageIndex       = 2
    // ↑ URL 파라미터 이름과 VO 필드 이름이 일치하면 자동으로 매핑
}
```

**자동 바인딩이 일어나려면:**
URL 파라미터 이름(`searchCondition`) = VO 필드명(`searchCondition`) 이어야 합니다.
이름이 다르면 값이 null이 됩니다.

### @RequestParam으로 받기

```java
@GetMapping("/view")
public String selectBoard(@RequestParam int boardNo, ModelMap model) {
    // URL: /board/view?boardNo=5
    // boardNo = 5 로 자동 바인딩
}
```

파라미터가 1~2개로 적을 때는 `@RequestParam`으로 직접 받는 것이 더 명확합니다.

### 폼 데이터 받기 (POST)

```java
@PostMapping("/write")
public String insertBoard(BoardVO boardVO) {
    // 폼에서 name="boardTitle", name="boardContent", name="boardWriter"
    // → boardVO.boardTitle, boardVO.boardContent, boardVO.boardWriter 에 자동 매핑
}
```

폼의 `name` 속성값 = VO 필드명이어야 자동 매핑됩니다.

---

## 4. ModelMap — View에 데이터 전달하기

```java
@GetMapping("/view")
public String selectBoard(@RequestParam int boardNo, ModelMap model) {
    BoardVO board = boardService.selectBoard(boardNo);

    model.addAttribute("board", board);
    //                  └────┘  └────┘
    //                  키 이름  값
    // JSP에서 ${board.boardTitle} 로 접근 가능

    return "board/view";
}
```

ModelMap은 데이터를 JSP로 보내는 "택배 상자"입니다:

```
Controller                   JSP
model.addAttribute("board", boardVO)  →  ${board.boardTitle}
model.addAttribute("totalCount", 50)  →  ${totalCount}
model.addAttribute("boardList", list) →  <c:forEach var="b" items="${boardList}">
```

**`addAttribute("키", 값)` 에서:**
- 키: JSP에서 사용할 변수 이름 (본인이 정하면 됨)
- 값: 실제 데이터 (BoardVO, List, int 등)

---

## 5. 반환값 — 어느 JSP를 보여줄까?

### 뷰 이름 반환

```java
return "board/list";
// → /WEB-INF/views/ + board/list + .jsp
// → /WEB-INF/views/board/list.jsp 가 화면에 표시됨
```

이 변환은 `application.properties`의 ViewResolver 설정 덕분입니다:
```properties
spring.mvc.view.prefix=/WEB-INF/views/
spring.mvc.view.suffix=.jsp
```

### redirect: — 다른 URL로 이동

```java
return "redirect:/board/list";
// JSP를 보여주지 않고 브라우저를 /board/list 로 이동시킴
// (브라우저가 새로 GET 요청을 보냄)
```

**일반 반환 vs redirect 차이:**
```
return "board/list"          → 현재 요청에서 바로 list.jsp 표시
return "redirect:/board/list" → 브라우저에게 "/board/list"로 다시 요청하라고 지시
```

---

## 6. PRG 패턴 — Post-Redirect-Get

등록/수정/삭제 처리 후에는 반드시 redirect를 해야 합니다.

**왜?** → 새로고침 방지

```
사용자 → [등록 버튼 클릭]
    POST /board/write (등록 처리)
    ↓
    만약 여기서 그냥 list.jsp를 반환하면:
    사용자가 새로고침(F5) 클릭 시
    → "폼 데이터 재전송하시겠습니까?" 창 뜸
    → 확인 클릭 시 글이 또 등록됨! (중복 등록)

PRG 패턴 사용:
    POST /board/write (등록 처리)
        → redirect:/board/list   ← "브라우저야, /board/list로 다시 요청해"
    GET /board/list (목록 조회)   ← 브라우저가 새로 GET 요청
    사용자가 새로고침 → GET /board/list 재요청 → 목록만 다시 로딩, 등록 X
```

```java
@PostMapping("/write")
public String insertBoard(BoardVO boardVO) {
    boardService.insertBoard(boardVO);
    return "redirect:/board/list";  // PRG 패턴!
}
```

**직접 확인해보기:**
1. 글을 등록한 후 F5(새로고침)를 눌러보세요
2. 글이 또 등록되지 않고 목록만 다시 로딩됩니다 → PRG 패턴 덕분

---

## 7. 전체 URL 설계 정리

| HTTP Method | URL | Controller 메서드 | 설명 |
|-------------|-----|------------------|------|
| GET | /board/list | selectBoardList() | 목록 화면 |
| GET | /board/view?boardNo=5 | selectBoard() | 상세 화면 |
| GET | /board/writeForm | writeForm() | 등록 폼 |
| POST | /board/write | insertBoard() | 등록 처리 |
| GET | /board/updateForm?boardNo=5 | updateForm() | 수정 폼 |
| POST | /board/update | updateBoard() | 수정 처리 |
| POST | /board/delete | deleteBoard() | 삭제 처리 |

---

## 8. 실습 — BoardController.java 직접 확인하기

**1단계:** `BoardController.java` 파일을 IntelliJ에서 열기

**2단계:** 아래 내용을 순서대로 확인하세요:

- [ ] 파일 맨 위에 `@Controller`와 `@RequestMapping("/board")` 가 있나요?

- [ ] `@GetMapping`과 `@PostMapping`의 차이를 파악해보세요.
  - 어떤 메서드들이 `@GetMapping`을 쓰고 있나요?
  - 어떤 메서드들이 `@PostMapping`을 쓰고 있나요?

- [ ] `selectBoardList()` 메서드에서 `model.addAttribute`를 찾으세요.
  - JSP로 어떤 이름(`key`)으로 어떤 데이터를 보내고 있나요?
  - 이 이름들은 나중에 `list.jsp`에서 `${...}` 로 사용됩니다.

- [ ] `insertBoard()` 메서드 마지막 줄을 확인하세요.
  ```java
  return "redirect:/board/list";
  ```
  이 줄이 있는 이유: 새로고침 시 중복 등록 방지(PRG 패턴)

- [ ] `updateBoard()` 메서드는 수정 후 어디로 redirect 하나요?
  - 목록 페이지 vs 상세 페이지
  - 왜 상세 페이지로 가는지 생각해보세요 (수정 결과를 바로 확인하기 위해)

---

## 핵심 요약

```
✅ @Controller = Spring MVC 컨트롤러 선언
✅ @RequestMapping("/board") = 이 Controller의 URL 접두사
✅ @GetMapping = GET 요청 처리 (조회/폼 표시)
✅ @PostMapping = POST 요청 처리 (등록/수정/삭제)
✅ 파라미터 자동 바인딩 = URL 파라미터 이름과 VO 필드명이 같으면 자동 매핑
✅ ModelMap = Controller → JSP 데이터 전달 상자
✅ return "board/list" = JSP 뷰 이름 반환
✅ return "redirect:..." = 브라우저를 다른 URL로 이동 (PRG 패턴)
```

---

이전: [GUIDE-06-Service.md](GUIDE-06-Service.md)
다음: [GUIDE-08-JSP.md](GUIDE-08-JSP.md)
