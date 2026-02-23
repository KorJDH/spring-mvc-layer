# GUIDE-05. MyBatis Mapper XML — SQL 작성하기

> MyBatis는 Java 코드와 SQL을 분리해주는 도구입니다.
> SQL을 XML 파일에 따로 관리해서, 코드와 쿼리를 독립적으로 수정할 수 있습니다.

---

## 읽을 파일

**IntelliJ에서 열기:**
`src/main/resources/mapper/BoardMapper.xml`

> IntelliJ 왼쪽 패널에서 `resources` → `mapper` → `BoardMapper.xml` 더블클릭

---

## 1. MyBatis가 왜 필요한가요?

MyBatis 없이 Java에서 SQL을 실행하면 이렇게 됩니다:

```java
// MyBatis 없이 (JDBC 직접 사용) — 복잡하고 힘듦
Connection conn = DriverManager.getConnection("jdbc:h2:...", "sa", "");
PreparedStatement pstmt = conn.prepareStatement(
    "SELECT board_no, board_title FROM tb_board WHERE board_title LIKE ?"
);
pstmt.setString(1, "%" + keyword + "%");
ResultSet rs = pstmt.executeQuery();
while (rs.next()) {
    BoardVO vo = new BoardVO();
    vo.setBoardNo(rs.getInt("board_no"));
    vo.setBoardTitle(rs.getString("board_title"));
    // ...반복...
}
```

이 코드의 문제점:
- DB 연결, SQL 실행, 결과 처리를 모두 직접 해야 함
- 코드가 길고 실수할 부분이 많음
- SQL을 바꾸려면 Java 코드를 직접 수정해야 함

**MyBatis 사용 후 — 훨씬 단순해짐:**

```java
// DAOImpl
return sqlSession.selectList("...selectBoardList", boardVO);
```

```xml
<!-- Mapper XML -->
<select id="selectBoardList" resultType="boardVO">
    SELECT * FROM tb_board
</select>
```

MyBatis가 연결, 파라미터 바인딩, 결과 매핑을 자동으로 해줍니다.

---

## 2. Mapper XML 기본 구조

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.example.egov.board.mapper.BoardMapper">
<!--           └──────────────────────────────────────────────┘
               DAOImpl의 NAMESPACE 상수와 반드시 일치해야 함!         -->

    <select id="selectBoard" parameterType="int" resultType="boardVO">
    <!--       └──────────┘  └────────────────┘  └────────────────┘
               SQL의 ID       입력 파라미터 타입   결과 반환 타입      -->
        SELECT * FROM tb_board WHERE board_no = #{boardNo}
    </select>

</mapper>
```

**각 속성 설명:**

| 속성 | 의미 | 예시 |
|------|------|------|
| `id` | 이 SQL의 이름 (DAO에서 참조) | `"selectBoard"` |
| `parameterType` | 입력으로 받는 데이터 타입 | `"int"`, `"boardVO"` |
| `resultType` | 결과를 담을 타입 | `"boardVO"`, `"int"` |

> 💡 `parameterType`이 `"boardVO"`이면 BoardVO 객체를 파라미터로 받는다는 뜻입니다.

---

## 3. 4가지 SQL 태그

| 태그 | 용도 | Java의 대응 |
|------|------|------------|
| `<select>` | 데이터 조회 | return 값 있음 |
| `<insert>` | 데이터 추가 | INSERT INTO |
| `<update>` | 데이터 수정 | UPDATE |
| `<delete>` | 데이터 삭제 | DELETE FROM |

---

## 4. 파라미터 바인딩 — `#{}` vs `${}`

### `#{값}` — 안전한 방법 (항상 이것을 쓰세요!)

```xml
<select id="selectBoard" parameterType="int" resultType="boardVO">
    SELECT * FROM tb_board WHERE board_no = #{boardNo}
    <!--                                    └────────┘
                          PreparedStatement의 ?로 바뀜 → SQL Injection 방지  -->
</select>
```

실제 실행될 때:
```sql
SELECT * FROM tb_board WHERE board_no = ?   -- ? 에 값을 안전하게 넣음
```

`#{}`은 값을 `?`로 바꾸고 별도로 안전하게 처리합니다.
사용자가 어떤 값을 입력해도 SQL 구조가 변하지 않습니다.

### `${값}` — 위험한 방법 (컬럼명 동적 변경 때만 예외적으로 사용)

```xml
<!-- 이렇게 하면 SQL Injection 공격에 취약! -->
SELECT * FROM tb_board WHERE board_title = '${keyword}'
```

악의적인 사용자가 `keyword`에 `' OR '1'='1` 을 넣으면:
```sql
SELECT * FROM tb_board WHERE board_title = '' OR '1'='1'
-- 모든 데이터가 조회됨! 해킹 성공
```

**SQL Injection이란?**
> 사용자 입력값에 SQL 코드를 몰래 넣어서 DB를 공격하는 방법입니다.
> `#{}` 를 쓰면 이런 공격을 자동으로 막아줍니다.

**결론: 사용자 입력값은 반드시 `#{}` 사용**

---

## 5. resultType — 결과를 어디에 담을까?

```xml
<select id="selectBoardList" resultType="boardVO">
<!--                                     └──────┘
          조회 결과를 BoardVO에 자동으로 담아줌
          (application.properties의 typeAlias 설정 덕분에 "boardVO" 로 짧게 씀)  -->
```

**application.properties 설정:**
```properties
mybatis.type-aliases-package=com.example.egov.board.vo
# 이 패키지 내의 클래스는 클래스명을 소문자로 바꾼 이름으로 참조 가능
# BoardVO → boardVO
```

MyBatis가 자동으로:
- DB 컬럼 `board_no` → VO 필드 `boardNo` 에 값을 넣어줌
- DB 컬럼 `board_title` → VO 필드 `boardTitle` 에 값을 넣어줌

**이 자동 변환이 가능한 이유:**
```properties
# application.properties
mybatis.configuration.map-underscore-to-camel-case=true
# board_no(DB) → boardNo(Java) 자동 변환
```

---

## 6. 동적 SQL — 조건에 따라 SQL이 달라지는 마법

게시판 검색 기능을 예로 들겠습니다.
검색어가 없을 수도 있고, 있으면 조건에 따라 SQL이 달라져야 합니다.

### `<if>` — Java의 if문과 같음

```xml
<select id="selectBoardList" parameterType="boardVO" resultType="boardVO">
    SELECT * FROM tb_board
    WHERE 1=1
    <if test="searchCondition == 'title'">
        AND board_title LIKE '%' || #{searchKeyword} || '%'
    </if>
    <if test="searchCondition == 'writer'">
        AND board_writer LIKE '%' || #{searchKeyword} || '%'
    </if>
</select>
```

- `test` 속성 안에 조건을 씁니다 (Java 조건식과 유사)
- 조건이 참이면 내부 SQL이 추가됩니다

> **`WHERE 1=1`이 뭔가요?**
> 항상 참인 조건입니다. 이렇게 해두면 뒤에 오는 `AND ...` 조건들을
> 모두 동일한 형식으로 추가할 수 있어 편합니다.

> **참고:** 실제 `BoardMapper.xml`에서는 아래에서 설명하는 `<where>` 태그 방식을 사용합니다.
> `WHERE 1=1` 패턴은 여러 현장 코드에서 자주 볼 수 있는 방식이라 이해를 돕기 위해 먼저 설명했습니다.

### `<where>` — WHERE절 자동 처리

```xml
<select id="selectBoardList" parameterType="boardVO" resultType="boardVO">
    SELECT * FROM tb_board
    <where>
        <!--
        <where>는 똑똑합니다:
        - 안에 아무 조건도 없으면 WHERE 자체를 안 씀
        - 첫 번째 AND/OR는 자동으로 제거해줌
        -->
        <if test="searchCondition == 'title'">
            AND board_title LIKE '%' || #{searchKeyword} || '%'
        </if>
        <if test="searchCondition == 'writer'">
            AND board_writer LIKE '%' || #{searchKeyword} || '%'
        </if>
    </where>
    ORDER BY board_no DESC
</select>
```

**`<where>` 없이 하면 생기는 문제:**
```sql
-- searchCondition 없을 때
SELECT * FROM tb_board WHERE    -- WHERE 다음에 아무것도 없어서 에러!

-- searchCondition='title' 일 때
SELECT * FROM tb_board WHERE AND board_title LIKE ...  -- AND가 앞에 붙어서 에러!
```

**`<where>` 사용하면 자동으로 해결됩니다.**

---

## 7. 페이징 — LIMIT과 OFFSET

```xml
<select id="selectBoardList" parameterType="boardVO" resultType="boardVO">
    SELECT * FROM tb_board
    ORDER BY board_no DESC
    LIMIT #{pageUnit} OFFSET #{firstIndex}
    <!--   └────────┘        └──────────┘
           한 페이지 건수       시작 위치
           10                  0 (1페이지), 10 (2페이지), 20 (3페이지)  -->
</select>
```

**페이징이 뭔가요?**
> 게시글이 100개 있을 때 한 페이지에 10개씩 나눠서 보여주는 것입니다.
> 1페이지: 1~10번째 게시글, 2페이지: 11~20번째 게시글...

`#{firstIndex}` 는 BoardVO의 `getFirstIndex()` 메서드가 계산합니다:

```java
// BoardVO.java
public int getFirstIndex() {
    return (pageIndex - 1) * pageUnit;
    // 1페이지: (1-1) * 10 = 0
    // 2페이지: (2-1) * 10 = 10
    // 3페이지: (3-1) * 10 = 20
}
```

`LIMIT 10 OFFSET 0` = 0번째부터 10개 = 1~10번째 데이터
`LIMIT 10 OFFSET 10` = 10번째부터 10개 = 11~20번째 데이터

---

## 8. H2 콘솔에서 직접 SQL 실행해보기

실제 SQL이 어떻게 동작하는지 눈으로 확인할 수 있습니다.

**접속 방법:**
1. 서버 실행 중에 브라우저에서 `http://localhost:8080/h2-console` 접속
2. 입력값:
   - JDBC URL: `jdbc:h2:mem:egovdb`
   - User Name: `sa`
   - Password: (빈칸으로 두기)
3. `Connect` 버튼 클릭

**직접 SQL 실행해보기:**

```sql
-- 1. 전체 조회 (모든 게시글 보기)
SELECT * FROM TB_BOARD;

-- 2. 제목으로 검색
SELECT * FROM TB_BOARD WHERE BOARD_TITLE LIKE '%Spring%';

-- 3. 전체 건수 확인
SELECT COUNT(*) FROM TB_BOARD;

-- 4. 페이징 (1페이지, 한 페이지에 3개씩)
SELECT * FROM TB_BOARD ORDER BY BOARD_NO DESC LIMIT 3 OFFSET 0;

-- 5. 페이징 (2페이지, 한 페이지에 3개씩)
SELECT * FROM TB_BOARD ORDER BY BOARD_NO DESC LIMIT 3 OFFSET 3;
```

> 💡 SQL 입력창에 위 코드를 붙여넣고 `Run` 버튼(또는 Ctrl+Enter)을 클릭하면 결과가 나옵니다.

---

## 9. 실습 — BoardMapper.xml 직접 확인하기

**1단계:** `BoardMapper.xml` 파일을 IntelliJ에서 열기

**2단계:** 아래 내용을 확인하세요:

- [ ] **`namespace`** 확인
  ```xml
  <mapper namespace="com.example.egov.board.mapper.BoardMapper">
  ```
  이 값이 `BoardDAOImpl.java`의 `NAMESPACE` 상수와 같은지 확인하세요.

- [ ] **`<select id="selectBoardList">`** 찾기
  - `parameterType`은 무엇인가요?
  - `resultType`은 무엇인가요?
  - `<if>` 또는 `<where>` 태그가 있나요?

- [ ] **`<insert id="insertBoard">`** 찾기
  - `#{boardTitle}`, `#{boardContent}` 처럼 `#{}` 문법을 사용하고 있나요?

- [ ] **`LIMIT #{pageUnit} OFFSET #{firstIndex}`** 찾기
  - `#{firstIndex}`가 BoardVO의 `getFirstIndex()` 메서드와 연결된다는 것을 기억하세요.

**3단계:** H2 콘솔에서 직접 확인 (위의 섹션 8 실습 진행)

---

## 핵심 요약

```
✅ MyBatis = Java 코드에서 SQL을 분리해 XML로 관리하는 도구
✅ namespace = DAOImpl의 NAMESPACE 상수와 반드시 일치
✅ #{} = 안전한 파라미터 바인딩 (PreparedStatement)
✅ ${} = 위험! 사용자 입력에는 절대 사용 금지
✅ <if test="..."> = 조건부 SQL 추가
✅ <where> = WHERE절 자동 처리 (AND/OR 앞에 붙는 문제 해결)
✅ LIMIT/OFFSET = 페이징 처리
✅ H2 콘솔(http://localhost:8080/h2-console)에서 SQL 직접 실행 가능
```

---

이전: [GUIDE-04-DAO.md](GUIDE-04-DAO.md)
다음: [GUIDE-06-Service.md](GUIDE-06-Service.md)
