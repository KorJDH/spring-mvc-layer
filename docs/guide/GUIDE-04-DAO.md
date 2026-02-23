# GUIDE-04. DAO — DB와 대화하는 창구

> DAO는 데이터베이스와 직접 소통하는 유일한 계층입니다.
> "DB에서 데이터를 꺼내오고 싶다면, 반드시 DAO를 통해야 한다"는 규칙이 있습니다.

---

## 읽을 파일

**IntelliJ에서 열기:**
- `src/main/java/com/example/egov/board/dao/BoardDAO.java` — 인터페이스
- `src/main/java/com/example/egov/board/dao/BoardDAOImpl.java` — 구현체

> 파일 검색 단축키: `Ctrl+Shift+N` (Windows) / `Cmd+Shift+O` (Mac)
> → `BoardDAO` 입력하면 두 파일이 모두 나옵니다.

---

## 1. DAO란?

**DAO = Data Access Object = 데이터 접근 객체 = DB 창구**

```
Service (주방장)        DAO (창고지기)          DB (창고)
     │                      │                     │
     │  "게시글 5번 가져와!" │                     │
     │ ─────────────────────▶│                     │
     │                      │  SELECT * FROM ...  │
     │                      │ ────────────────────▶│
     │                      │  결과 반환           │
     │                      │ ◀────────────────────│
     │  BoardVO 반환         │                     │
     │ ◀─────────────────────│                     │
```

**규칙:** Service는 DB를 직접 건드리지 않습니다. 반드시 DAO를 통해서만 접근합니다.
왜? 나중에 DB가 바뀌어도 DAO만 수정하면 Service는 안 바꿔도 되기 때문입니다.

**비유:**
> 주방장(Service)은 재료가 필요할 때 창고에 직접 들어가지 않습니다.
> 반드시 창고지기(DAO)에게 요청합니다.
> 나중에 냉장고를 바꿔도(Oracle DB로 교체), 창고지기(DAO)만 바꾸면
> 주방장(Service)은 그대로 쓸 수 있습니다.

---

## 2. 인터페이스 + 구현체 패턴 이해하기

전자정부프레임워크에서는 DAO를 **2개의 파일**로 만듭니다.

```
BoardDAO.java      ← "무엇을 할 수 있는지" 목록만 정의 (인터페이스)
BoardDAOImpl.java  ← "어떻게 할 것인지" 실제 코드 (구현체)
```

**왜 파일을 2개 만들까요?** → 이 질문에 대한 답은 섹션 6에서 자세히 설명합니다.

### 인터페이스(BoardDAO.java) — 목차

```java
public interface BoardDAO {
    List<BoardVO> selectBoardList(BoardVO boardVO);   // 목록 조회
    int selectBoardTotalCount(BoardVO boardVO);       // 총 건수
    BoardVO selectBoard(int boardNo);                 // 상세 조회
    void insertBoard(BoardVO boardVO);                // 등록
    void updateBoard(BoardVO boardVO);                // 수정
    void deleteBoard(int boardNo);                    // 삭제
    void updateBoardHit(int boardNo);                 // 조회수 증가
}
```

- 메서드의 이름과 파라미터, 반환값만 적혀있습니다
- 실제 코드(SQL 실행)는 없습니다
- **비유**: 식당 메뉴판 — "무슨 음식을 팔 수 있는지"만 나열

**반환 타입 읽는 법:**
| 반환 타입 | 의미 |
|---------|------|
| `List<BoardVO>` | BoardVO 여러 개를 담은 목록 |
| `BoardVO` | BoardVO 하나 |
| `int` | 정수 하나 (예: 총 건수) |
| `void` | 반환값 없음 (등록, 수정, 삭제) |

---

### 구현체(BoardDAOImpl.java) — 실제 조리

```java
@Repository("boardDAO")                    // "이건 DAO야" 라고 Spring에게 알림
public class BoardDAOImpl implements BoardDAO {  // BoardDAO를 구현한다

    @Autowired
    private SqlSession sqlSession;         // MyBatis의 핵심 도구

    @Override
    public List<BoardVO> selectBoardList(BoardVO boardVO) {
        // sqlSession으로 Mapper XML의 SQL을 실행
        return sqlSession.selectList(
            "com.example.egov.board.mapper.BoardMapper.selectBoardList",
            boardVO
        );
    }
}
```

- `@Repository`: "이 클래스는 DAO입니다" 라는 라벨 스티커
- `implements BoardDAO`: 인터페이스에 선언된 메서드를 실제로 구현한다는 선언
- `@Override`: 인터페이스에서 선언한 메서드를 여기서 구현한다는 표시

---

## 3. SqlSession — MyBatis의 핵심 도구

```java
@Autowired
private SqlSession sqlSession;
```

`SqlSession`은 MyBatis가 제공하는 객체로, SQL을 실행하는 도구입니다.

```java
// 조회 - 여러 건
sqlSession.selectList("namespace.sqlId", 파라미터);

// 조회 - 한 건
sqlSession.selectOne("namespace.sqlId", 파라미터);

// 등록
sqlSession.insert("namespace.sqlId", 파라미터);

// 수정
sqlSession.update("namespace.sqlId", 파라미터);

// 삭제
sqlSession.delete("namespace.sqlId", 파라미터);
```

각 메서드의 첫 번째 파라미터 `"namespace.sqlId"` 는
Mapper XML 파일에서 실행할 SQL의 주소입니다.

**왜 selectList와 selectOne이 따로 있을까요?**
- `selectList`: 결과가 여러 행(row)일 때 → `List<BoardVO>` 반환
- `selectOne`: 결과가 정확히 1행일 때 → `BoardVO` 하나 반환
- 목록 조회는 `selectList`, 단건 조회는 `selectOne`

---

## 4. namespace와 sqlId — SQL의 주소

```java
// DAOImpl에서
return sqlSession.selectList(
    "com.example.egov.board.mapper.BoardMapper.selectBoardList",
//   └─────────────────────────────────────┘  └────────────────┘
//         namespace (Mapper XML의 namespace)     sqlId (SQL의 id)
    boardVO
);
```

```xml
<!-- BoardMapper.xml에서 -->
<mapper namespace="com.example.egov.board.mapper.BoardMapper">
<!--              └───────────────────────────────────────────┘
                  이 부분이 namespace — DAO의 NAMESPACE와 일치해야 함!  -->

    <select id="selectBoardList" ...>
    <!--       └────────────────┘
               이 부분이 sqlId — DAO에서 .selectBoardList 로 참조  -->
        SELECT * FROM tb_board ...
    </select>
</mapper>
```

**연결 구조:**
```
DAOImpl                                    Mapper XML
"...BoardMapper.selectBoardList"    →    namespace="...BoardMapper"
                                          id="selectBoardList"
```

**이 둘이 일치하지 않으면?**
```
에러: org.apache.ibatis.binding.BindingException:
      Invalid bound statement (not found): ...selectBoardList
```
→ namespace 또는 id가 틀렸다는 에러입니다. 이 에러가 나면 이 두 곳을 먼저 확인하세요.

---

## 5. 메서드 이름 규칙

전자정부프레임워크에서는 CRUD에 따라 메서드 이름을 정해서 씁니다:

| 동작 | 메서드 이름 예시 | SQL 종류 |
|------|----------------|---------|
| 목록 조회 | `selectBoardList()` | SELECT (복수) |
| 단건 조회 | `selectBoard()` | SELECT (단수) |
| 총 건수 | `selectBoardTotalCount()` | SELECT COUNT(*) |
| 등록 | `insertBoard()` | INSERT |
| 수정 | `updateBoard()` | UPDATE |
| 삭제 | `deleteBoard()` | DELETE |

> 💡 이름 규칙을 지키는 이유: 다른 개발자가 코드를 봤을 때 메서드 이름만으로 무슨 역할인지 바로 알 수 있기 때문입니다.

---

## 6. 왜 인터페이스 + Impl 구조인가요?

처음엔 "왜 파일을 2개씩 만들어?" 라는 의문이 생깁니다.

**이유 1: 교체 가능성**
```java
// Service가 사용하는 것은 "인터페이스"
@Autowired
private BoardDAO boardDAO;  // ← 인터페이스 타입으로 선언

// 실제 들어오는 것은 구현체
// BoardDAOImpl → 나중에 BoardDAOOracleImpl 로 교체해도
// Service 코드는 전혀 바꿀 필요 없음
```

현실 예:
> - 지금 H2 DB 사용 → 나중에 Oracle DB로 교체
> - `BoardDAOImpl.java` → `BoardDAOOracleImpl.java` 새로 만들고
> - `BoardServiceImpl.java`는 한 줄도 바꾸지 않아도 됨

**이유 2: 테스트 편의**
```java
// 실제 DB 없이 가짜(Mock) DAO로 테스트 가능
BoardDAO mockDAO = new MockBoardDAO();  // 가짜 구현체
```

**이유 3: 전자정부프레임워크 규칙**
- 공공 프로젝트에서 일관성을 위해 이 패턴을 표준으로 사용

---

## 7. 실습 — BoardDAOImpl.java 직접 확인하기

**1단계:** `BoardDAOImpl.java` 파일을 IntelliJ에서 열기

**2단계:** 아래 내용을 순서대로 확인하세요:

- [ ] **`@Repository("boardDAO")`** 어노테이션 확인
  - 클래스 바로 위에 있어야 합니다
  - 이 이름(`boardDAO`)으로 Spring이 이 DAO 객체를 관리합니다

- [ ] **`implements BoardDAO`** 선언 확인
  - `public class BoardDAOImpl implements BoardDAO {`
  - BoardDAO 인터페이스를 구현함을 선언한 부분입니다

- [ ] **`NAMESPACE` 상수** 찾기
  ```java
  private static final String NAMESPACE = "com.example.egov.board.mapper.BoardMapper";
  ```
  - `BoardMapper.xml` 파일을 열어서 `namespace=` 값과 같은지 비교해보세요

- [ ] **`selectList`** 사용하는 메서드 찾기 (복수 조회)
  ```java
  sqlSession.selectList(NAMESPACE + ".selectBoardList", boardVO)
  ```

- [ ] **`selectOne`** 사용하는 메서드 찾기 (단건 조회)
  ```java
  sqlSession.selectOne(NAMESPACE + ".selectBoard", boardNo)
  ```

- [ ] **`insert`, `update`, `delete`** 메서드도 각각 찾아보세요

**3단계:** 두 파일 비교하기
- `BoardDAO.java` (인터페이스)를 열어서 메서드 선언만 있는 것 확인
- `BoardDAOImpl.java` (구현체)를 열어서 실제 코드가 있는 것 확인
- 두 파일의 메서드 이름이 완전히 일치하는지 확인

---

## 핵심 요약

```
✅ DAO = DB와 직접 통신하는 유일한 계층
✅ 인터페이스(BoardDAO) = 메서드 목록만
✅ 구현체(BoardDAOImpl) = 실제 SQL 실행
✅ SqlSession = MyBatis를 통해 SQL 실행하는 도구
✅ "namespace.sqlId" = Mapper XML에서 실행할 SQL의 주소
✅ selectList(복수) vs selectOne(단건) 구분해서 사용
✅ namespace 또는 sqlId 오타 → BindingException 에러 발생
```

---

이전: [GUIDE-03-VO.md](GUIDE-03-VO.md)
다음: [GUIDE-05-MyBatis.md](GUIDE-05-MyBatis.md)
