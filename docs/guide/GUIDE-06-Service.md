# GUIDE-06. Service — 비즈니스 로직과 트랜잭션

> Service는 "실제 업무 처리"를 담당하는 계층입니다.
> Controller는 요청/응답만, DAO는 DB만 담당합니다.
> 업무 규칙(비즈니스 로직)은 반드시 Service에 있어야 합니다.

---

## 읽을 파일

**IntelliJ에서 열기:**
- `src/main/java/com/example/egov/board/service/BoardService.java`
- `src/main/java/com/example/egov/board/service/BoardServiceImpl.java`

> 파일 검색: `Ctrl+Shift+N` (Windows) / `Cmd+Shift+O` (Mac) → `BoardService` 입력

---

## 1. 비즈니스 로직이란?

**비즈니스 로직 = 실제 업무 규칙**

예를 들어 게시글 상세보기 기능은:

```
단순히 생각하면: "그냥 DB에서 게시글 꺼내면 되는 거 아닌가?"

실제 업무 규칙:
  1. 조회수를 먼저 1 증가시킨다
  2. 그 다음 게시글 내용을 조회한다
  3. 이 두 작업은 반드시 하나로 묶여야 한다 (둘 다 성공하거나, 둘 다 실패하거나)
```

이런 업무 규칙을 코드로 표현한 것이 비즈니스 로직입니다.

```java
// BoardServiceImpl.java
@Override
@Transactional          // 아래 두 줄이 하나의 단위로 처리됨
public BoardVO selectBoard(int boardNo) {
    boardDAO.updateBoardHit(boardNo);  // 1. 조회수 +1
    return boardDAO.selectBoard(boardNo);  // 2. 게시글 조회
}
```

이 로직은 Controller에 있어도 되고 DAO에 있어도 됩니다.
그런데 왜 꼭 Service에 있어야 할까요?

---

## 2. 왜 Service 계층이 필요한가?

**Controller에 로직을 넣으면:**

```java
// Controller에 다 넣으면 — 나쁜 예시
@GetMapping("/view")
public String selectBoard(int boardNo, ModelMap model) {
    boardDAO.updateBoardHit(boardNo);  // 여기서 직접 DAO 호출
    BoardVO board = boardDAO.selectBoard(boardNo);

    // 만약 나중에 "모바일 앱 API"도 만들어야 한다면?
    // 같은 로직을 API Controller에도 복사해야 함 → 중복!
}
```

**Service에 로직을 넣으면:**

```java
// Controller는 Service만 호출 — 좋은 예시
@GetMapping("/view")
public String selectBoard(int boardNo, ModelMap model) {
    BoardVO board = boardService.selectBoard(boardNo);  // 한 줄!
    model.addAttribute("board", board);
    return "board/view";
}

// 나중에 모바일 API가 생겨도
@GetMapping("/api/board/{boardNo}")
public BoardVO selectBoardApi(int boardNo) {
    return boardService.selectBoard(boardNo);  // 같은 Service 재사용!
}
```

**Service의 장점:**
- **재사용성**: 웹, 앱, API 등 어디서든 같은 Service 호출
- **단일 책임**: Controller는 요청/응답만, Service는 업무 로직만
- **테스트 편의**: Service만 따로 테스트 가능

---

## 3. @Transactional — 트랜잭션이란?

**트랜잭션 = "모두 성공하거나, 모두 실패하거나"**

은행 이체를 예로 들면:
```
1. 내 계좌에서 10만원 빼기  ← 이것이 성공하고
2. 상대방 계좌에 10만원 넣기 ← 이것이 실패하면?
→ 내 돈만 사라지는 대참사!
```

트랜잭션은 이 두 작업을 묶어서:
```
성공: 1번, 2번 모두 반영 (commit)
실패: 1번, 2번 모두 취소 (rollback)
```

**commit = 변경사항을 DB에 확정 반영**
**rollback = 변경사항을 모두 취소하고 원상복구**

### 코드에서 사용하기

```java
@Service("boardService")
public class BoardServiceImpl implements BoardService {

    @Override
    @Transactional          // ← 이 어노테이션이 트랜잭션을 보장
    public BoardVO selectBoard(int boardNo) {
        boardDAO.updateBoardHit(boardNo);    // 조회수 증가
        return boardDAO.selectBoard(boardNo); // 게시글 조회
        // 만약 여기서 에러 발생 → 조회수 증가도 자동으로 취소(rollback)
    }
}
```

`@Transactional`을 붙이기만 하면 Spring이 자동으로:
1. 메서드 시작 전: 트랜잭션 시작
2. 메서드 정상 종료: commit (DB에 반영)
3. 에러 발생: rollback (모든 변경 취소)

### readOnly = true — 읽기 전용 트랜잭션

```java
@Override
@Transactional(readOnly = true)   // 조회만 하는 메서드에 사용
public List<BoardVO> selectBoardList(BoardVO boardVO) {
    return boardDAO.selectBoardList(boardVO);
}
```

- 데이터를 변경하지 않는 조회 메서드에 사용
- DB 성능 최적화 효과 있음 (쓰기 잠금을 걸지 않아도 됨)

**언제 `readOnly = true`를 쓰나요?**
- 조회(SELECT)만 하는 메서드: `readOnly = true` 붙이기
- 변경(INSERT/UPDATE/DELETE)하는 메서드: `@Transactional`만 (readOnly 없이)

---

## 4. 인터페이스 + Impl 구조 (DAO와 동일)

Service도 DAO와 마찬가지로 2개의 파일로 구성됩니다:

```java
// BoardService.java (인터페이스) — "무엇을 할 수 있는지"
public interface BoardService {
    List<BoardVO> selectBoardList(BoardVO boardVO);
    BoardVO selectBoard(int boardNo);
    void insertBoard(BoardVO boardVO);
    // ...
}

// BoardServiceImpl.java (구현체) — "어떻게 할 것인지"
@Service("boardService")
public class BoardServiceImpl implements BoardService {

    @Autowired
    private BoardDAO boardDAO;   // DAO를 주입받아서 사용

    @Override
    @Transactional
    public void insertBoard(BoardVO boardVO) {
        boardDAO.insertBoard(boardVO);  // DAO에게 DB 작업 위임
    }
}
```

---

## 5. 계층 간 흐름 다시 보기

```
사용자가 "글쓰기" 버튼 클릭

Controller
    boardService.insertBoard(boardVO);   ← Service 호출

        ServiceImpl
            @Transactional 시작
            boardDAO.insertBoard(boardVO);  ← DAO 호출

                DAOImpl
                    sqlSession.insert("...insertBoard", boardVO);

                        Mapper XML
                            INSERT INTO tb_board (...) VALUES (...)

                        H2 DB에 저장

                DAOImpl 반환
            @Transactional 정상 종료 → commit

        ServiceImpl 반환

    Controller → "redirect:/board/list"

브라우저 → 목록 페이지로 이동
```

---

## 6. 실습 — BoardServiceImpl.java 직접 확인하기

**1단계:** `BoardServiceImpl.java` 파일을 IntelliJ에서 열기

**2단계:** 아래 내용을 순서대로 확인하세요:

- [ ] **`@Service("boardService")`** 어노테이션 확인
  - 클래스 바로 위에 있어야 합니다
  - 이름이 `boardService`인 Service 객체를 Spring이 관리합니다

- [ ] **`@Autowired private BoardDAO boardDAO`** 찾기
  - Service가 DAO를 주입받는 부분입니다
  - `boardDAO`를 통해서만 DB 작업을 합니다

- [ ] **`selectBoard()` 메서드** 확인
  ```java
  @Transactional
  public BoardVO selectBoard(int boardNo) {
      boardDAO.updateBoardHit(boardNo);    // ← DAO 메서드 1
      return boardDAO.selectBoard(boardNo); // ← DAO 메서드 2
  }
  ```
  - `@Transactional` 이 붙어있나요?
  - DAO 메서드를 2번 호출하고 있나요?

- [ ] **조회 메서드들** (`selectBoardList`, `selectBoard`, `selectBoardTotalCount`)
  - `@Transactional(readOnly = true)` 가 붙어있나요?

- [ ] **변경 메서드들** (`insertBoard`, `updateBoard`, `deleteBoard`)
  - `@Transactional` (readOnly 없이) 이 붙어있나요?

**생각해볼 질문:**
> `deleteBoard()`에서 만약 삭제 도중 에러가 발생하면 어떻게 될까요?
> → `@Transactional` 덕분에 자동으로 rollback 됩니다.
> 데이터가 "반쯤 지워진" 상태가 되지 않습니다.

---

## 핵심 요약

```
✅ Service = 비즈니스 로직(업무 규칙) 담당 계층
✅ Controller는 요청/응답만, DB 로직은 DAO에만
✅ 업무 규칙은 Service에 — 재사용성 확보
✅ @Transactional = 모두 성공하거나 모두 실패하거나 (commit/rollback 자동)
✅ @Transactional(readOnly = true) = 조회 전용, 성능 최적화
✅ 인터페이스 + Impl 구조 = DAO와 동일한 이유로 사용
```

---

이전: [GUIDE-05-MyBatis.md](GUIDE-05-MyBatis.md)
다음: [GUIDE-07-Controller.md](GUIDE-07-Controller.md)
