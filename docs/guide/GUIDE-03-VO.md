# GUIDE-03. VO (Value Object) — 데이터를 담는 상자

> 코드를 읽기 전에 먼저 **어떤 데이터가 오가는지** 파악하는 것이 중요합니다.
> VO는 가장 단순하면서도 가장 자주 보이는 클래스입니다.

---

## 읽을 파일

**IntelliJ에서 열기:**
`src/main/java/com/example/egov/board/vo/BoardVO.java`

> IntelliJ에서 파일을 못 찾겠으면:
> `Ctrl + Shift + N` (Windows) 또는 `Cmd + Shift + O` (Mac) → `BoardVO` 입력 → Enter

---

## 1. VO란 무엇인가요?

**VO = Value Object = 값을 담는 객체 = 데이터 상자**

게시글 하나를 예로 들면:

```
게시글 번호:  3
제목:        MyBatis 사용법
내용:        MyBatis는 SQL을 XML로 관리하는...
작성자:      강사
조회수:      12
등록일:      2024-01-15 09:30:00
```

이 6가지 데이터를 함께 묶어서 들고 다닐 수 있는 "상자"가 VO입니다.

**왜 상자(VO)로 묶을까요?**

상자 없이 데이터를 전달하려면:
```java
// 이렇게 해야 함 (매우 불편)
void insertBoard(String title, String content, String writer, int hit, String regdate)
```

상자(VO)로 전달하면:
```java
// 이렇게 하면 됨 (간편)
void insertBoard(BoardVO boardVO)
```

메서드 파라미터가 1개로 줄어들고, 나중에 필드가 추가돼도 메서드 수정 불필요.

---

## 2. 코드로 보기

```java
// BoardVO.java
public class BoardVO {
    private int    boardNo;       // 게시글 번호
    private String boardTitle;    // 제목
    private String boardContent;  // 내용
    private String boardWriter;   // 작성자
    private int    boardHit;      // 조회수
    private String boardRegdate;  // 등록일
}
```

이 클래스에 있는 각 변수를 **필드(field)** 라고 합니다.

**Java 자료형 기초 (처음 보는 분을 위해):**

| 자료형 | 저장할 수 있는 것 | 예시 |
|-------|----------------|------|
| `int` | 정수(소수점 없는 숫자) | 3, 12, 0 |
| `String` | 문자열(글자) | "제목", "홍길동" |

---

## 3. getter / setter — 상자의 뚜껑

VO의 필드는 `private`(외부에서 직접 접근 불가)입니다.
그래서 데이터를 꺼내거나 넣으려면 **getter/setter** 메서드를 사용합니다.

```java
// 데이터 꺼내기 (get) — 상자 열어서 꺼내기
boardVO.getBoardTitle()   // "MyBatis 사용법" 반환

// 데이터 넣기 (set) — 상자에 넣기
boardVO.setBoardTitle("새로운 제목")
```

**왜 private + getter/setter를 쓸까요?**

직접 접근을 막는 이유:
```java
// 나쁜 예: 직접 접근하면
boardVO.boardTitle = "";        // 빈 제목으로 저장될 수 있음
boardVO.boardHit = -999;        // 말이 안 되는 음수 조회수 저장 가능

// 좋은 예: setter를 통하면 검증 로직 추가 가능
public void setBoardTitle(String boardTitle) {
    if (boardTitle == null || boardTitle.isEmpty()) {
        throw new Exception("제목은 비워둘 수 없습니다");
    }
    this.boardTitle = boardTitle;
}
```

**비유:**
```
boardVO = 반찬통
boardTitle = 반찬통 안의 칸 중 "제목" 칸

getBoardTitle() = 반찬통 열어서 "제목" 칸 꺼내기
setBoardTitle() = "제목" 칸에 내용 넣기
```

---

## 4. Lombok — getter/setter 자동 생성

VO에는 필드마다 getter/setter를 써야 합니다.
필드가 10개면 메서드도 20개... 코드가 너무 길어집니다.

**Lombok**은 이걸 어노테이션 3줄로 해결해줍니다:

```java
@Getter   // 모든 필드에 대한 getXxx() 메서드 자동 생성
@Setter   // 모든 필드에 대한 setXxx() 메서드 자동 생성
@ToString // toString() 자동 생성 (로그 출력 시 유용)
public class BoardVO {
    private int    boardNo;
    private String boardTitle;
    // ...
}
```

어노테이션 3개 덕분에 수십 줄의 코드가 사라집니다.
(실제로 컴파일할 때 Lombok이 자동으로 코드를 추가해줌)

**`@ToString`이 있으면:**
```java
// 로그에 이렇게 출력됨 (BoardVO 내용을 한 번에 볼 수 있음)
log.info("게시글 정보: {}", boardVO);
// 출력: 게시글 정보: BoardVO(boardNo=3, boardTitle=MyBatis 사용법, ...)
```

---

## 5. DB 테이블과 VO 비교

VO의 필드는 DB 테이블의 컬럼과 1:1로 매핑됩니다.

```
DB 테이블 (tb_board)        BoardVO.java
─────────────────────       ──────────────────────────
board_no    INT          ↔  private int    boardNo
board_title VARCHAR(200) ↔  private String boardTitle
board_content TEXT       ↔  private String boardContent
board_writer VARCHAR(50) ↔  private String boardWriter
board_hit   INT          ↔  private int    boardHit
board_regdate DATETIME   ↔  private String boardRegdate
```

**주의:** DB 컬럼명은 `board_no` (언더스코어) 이지만
VO 필드명은 `boardNo` (카멜케이스) 입니다.

이 변환은 `application.properties`에서 자동으로 해줍니다:
```properties
mybatis.configuration.map-underscore-to-camel-case=true
# board_no  →  boardNo 자동 변환
# board_title → boardTitle 자동 변환
```

**카멜케이스란?**
```
board_no    ← 언더스코어 방식 (DB 표준)
boardNo     ← 카멜케이스 (낙타 등처럼 대문자로 시작하는 단어가 붙어있음) (Java 표준)
boardTitle  ← 'b'는 소문자로 시작, 'T'처럼 중간 단어는 대문자
```

---

## 6. 검색 조건도 VO에 함께

전자정부프레임워크에서는 검색 조건이나 페이징 정보도
같은 VO에 함께 담는 경우가 많습니다:

```java
public class BoardVO {
    // DB 컬럼과 매핑되는 필드들
    private int    boardNo;
    private String boardTitle;
    // ...

    // 검색/페이징 용도 (DB 컬럼은 아님)
    private String searchCondition;  // 검색 조건 (title/content/writer)
    private String searchKeyword;    // 검색어
    private int    pageIndex = 1;    // 현재 페이지
    private int    pageUnit  = 10;   // 한 페이지에 보여줄 개수
}
```

**장점:** 하나의 VO만 Controller → Service → DAO로 전달하면 됨

**단점:** VO 하나에 역할이 너무 많아짐 (현대 방식은 별도 SearchVO로 분리)

---

## 7. VO를 실제로 사용하는 모습

```java
// Controller에서
BoardVO boardVO = new BoardVO();      // 상자 만들기
boardVO.setBoardTitle("공지사항");   // 제목 넣기
boardVO.setBoardWriter("관리자");    // 작성자 넣기

// Service로 전달
boardService.insertBoard(boardVO);   // 상자 째로 넘기기

// JSP에서 (EL 표현식)
// model.addAttribute("board", boardVO) 로 넘어온 경우
${board.boardTitle}   // = boardVO.getBoardTitle() 자동 호출
${board.boardWriter}  // = boardVO.getBoardWriter() 자동 호출
```

> 💡 JSP에서 `${board.boardTitle}`처럼 쓰면 자동으로 `boardVO.getBoardTitle()`을 호출해줍니다.
> Lombok이 getter를 만들어뒀기 때문에 이게 가능합니다.

---

## 8. 실습 — BoardVO.java 직접 확인하기

**1단계:** `BoardVO.java` 파일을 IntelliJ에서 엽니다.
(`Ctrl+Shift+N` 또는 `Cmd+Shift+O` → `BoardVO` 검색)

**2단계:** 아래 내용을 찾아보세요:

- [ ] 파일 맨 위에 `@Getter`, `@Setter`, `@ToString` 어노테이션이 있나요?
  ```java
  @Getter
  @Setter
  @ToString
  public class BoardVO {
  ```

- [ ] 필드(변수) 목록을 확인하세요. DB 컬럼명(`board_no`)과 Java 필드명(`boardNo`)을 비교해보세요.

- [ ] `searchCondition`, `searchKeyword` 필드가 있나요? 이 필드들은 DB 테이블에는 없고 검색용으로만 사용합니다.

- [ ] `getFirstIndex()` 메서드를 찾아보세요:
  ```java
  public int getFirstIndex() {
      return (pageIndex - 1) * pageUnit;
  }
  ```
  이 메서드는 페이지 번호를 데이터베이스 조회 시작 위치(offset)로 변환합니다.
  - 1페이지 → (1-1) × 10 = 0 (처음부터 10개)
  - 2페이지 → (2-1) × 10 = 10 (11번째부터 10개)
  - 3페이지 → (3-1) × 10 = 20 (21번째부터 10개)

---

## 핵심 요약

```
✅ VO = DB 테이블 한 행(row)의 데이터를 담는 Java 클래스
✅ 각 필드 = DB 컬럼 1개에 대응
✅ private + getter/setter 조합으로 데이터 보호
✅ Lombok(@Getter, @Setter)으로 반복 코드 제거
✅ board_no(DB) ↔ boardNo(Java): underscore → camelCase 자동 변환
✅ 검색조건, 페이징 정보도 같이 담는 것이 전자정부 관행
```

---

이전: [GUIDE-02-프로젝트구조.md](GUIDE-02-프로젝트구조.md)
다음: [GUIDE-04-DAO.md](GUIDE-04-DAO.md)
