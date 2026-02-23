# GUIDE-02. 프로젝트 구조 이해하기

> 집을 짓기 전에 설계도를 먼저 봐야 하듯,
> 코드를 읽기 전에 어느 폴더에 무슨 파일이 있는지 파악해야 합니다.

---

## 0. 파일을 열기 전에 — IDE에서 탐색하는 방법

이 가이드에서는 계속 특정 파일을 "열어보세요"라고 합니다.
IntelliJ IDEA에서 파일을 찾는 방법을 먼저 알아봅시다.

**IntelliJ 왼쪽 패널 활용:**

```
IntelliJ 화면 왼쪽에 "Project" 패널이 있습니다.
없다면: View → Tool Windows → Project (단축키: Alt+1 또는 Cmd+1)

spring-mvc-layer                          ← 최상위 프로젝트 폴더
└── src
    └── main
        ├── java
        │   └── com.example.egov
        │       └── board
        │           ├── controller   ← 이 폴더를 클릭하면 하위 파일 보임
        │           ├── service
        │           ├── dao
        │           └── vo
        ├── resources
        └── webapp
```

폴더 옆 화살표(▶)를 클릭하면 펼쳐집니다.
파일 이름을 더블클릭하면 오른쪽 편집 창에서 열립니다.

**파일을 이름으로 검색 (더 빠른 방법):**
- Windows: `Ctrl + Shift + N`
- Mac: `Cmd + Shift + O`
- 검색창에 파일 이름 입력 (예: `BoardVO`, `BoardController`)

---

## 1. 전체 폴더 구조

```
spring-mvc-layer/                               ← 프로젝트 최상위 폴더
│
├── pom.xml                         ← "장바구니 목록". 필요한 라이브러리 명세
│
├── docs/guide/                     ← 지금 읽고 있는 가이드 파일들
│
└── src/
    └── main/
        ├── java/                   ← Java 소스코드가 있는 곳
        │   └── com/example/egov/
        │       ├── EgovApplication.java         ← 앱 시작 버튼
        │       └── board/
        │           ├── controller/              ← 요청 받는 곳
        │           │   └── BoardController.java
        │           ├── service/                 ← 일 처리하는 곳
        │           │   ├── BoardService.java
        │           │   └── BoardServiceImpl.java
        │           ├── dao/                     ← DB 창구
        │           │   ├── BoardDAO.java
        │           │   └── BoardDAOImpl.java
        │           └── vo/                      ← 데이터 상자
        │               └── BoardVO.java
        │
        ├── resources/              ← Java 코드가 아닌 설정/리소스 파일
        │   ├── application.properties           ← 앱 설정 파일
        │   ├── mapper/
        │   │   └── BoardMapper.xml              ← SQL 쿼리 모음
        │   └── sql/
        │       ├── schema.sql                   ← 테이블 생성 SQL
        │       └── data.sql                     ← 초기 샘플 데이터
        │
        └── webapp/
            └── WEB-INF/views/board/            ← 화면 파일 (JSP)
                ├── list.jsp                    ← 목록 화면
                ├── view.jsp                    ← 상세 화면
                ├── writeForm.jsp               ← 등록 폼
                └── updateForm.jsp              ← 수정 폼
```

> 💡 **지금 바로 해보세요:** IntelliJ 왼쪽 패널에서 위 구조와 똑같이 폴더가 구성되어 있는지 확인해보세요.

---

## 2. 각 파일의 역할 — 식당에 비유하면

전자정부프레임워크 구조를 **식당**에 비유해볼게요.

```
손님 (브라우저)
    │
    │ 주문서 작성
    ▼
┌──────────────────────────────┐
│  Controller (홀 서버)        │  손님의 주문을 받아서
│  BoardController.java        │  주방으로 넘겨주는 직원
└──────────────────────────────┘
    │
    │ 주문 전달
    ▼
┌──────────────────────────────┐
│  Service (주방장)            │  실제 요리를 지휘하는 곳
│  BoardServiceImpl.java       │  재료를 어떻게 조리할지 결정
└──────────────────────────────┘
    │
    │ 재료 요청
    ▼
┌──────────────────────────────┐
│  DAO (식재료 창고지기)       │  냉장고(DB)에서 재료를 꺼내주는 곳
│  BoardDAOImpl.java           │  재료를 저장하기도 함
└──────────────────────────────┘
    │
    │ 재료 꺼내기/넣기
    ▼
┌──────────────────────────────┐
│  DB (냉장고/창고)            │  데이터가 실제로 저장되는 곳
│  H2 Database                 │
└──────────────────────────────┘

📦 VO (반찬통/용기) = 각 계층 사이에서 데이터를 담아 전달하는 그릇
📋 Mapper XML = 레시피 북 (어떤 SQL로 데이터를 꺼낼지)
🖥️ JSP = 완성된 요리를 담는 그릇(접시) = 화면
```

---

## 3. 파일 하나씩 살펴보기

### pom.xml — 장바구니 목록

**IntelliJ에서 열기:** 프로젝트 최상위 `spring-mvc-layer` 폴더 바로 아래에 있습니다.

```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.3.1</version>
</dependency>
```

- Maven이 이 파일을 읽고 인터넷에서 필요한 라이브러리를 자동으로 다운받습니다
- 직접 jar 파일을 다운받아 넣을 필요가 없습니다
- **비유**: 마트 장바구니 목록 → 마트(인터넷)에서 알아서 담아줌

> 💡 **확인해보기:** pom.xml을 열어서 `<dependencies>` 태그 안에 어떤 라이브러리들이 있는지 훑어보세요. `spring`, `mybatis`, `h2`, `lombok` 같은 이름들이 보일 것입니다.

---

### EgovApplication.java — 앱 시작 버튼

**IntelliJ에서 열기:** `src/main/java/com/example/egov/EgovApplication.java` (패키지명은 그대로 유지됩니다)

```java
@SpringBootApplication          // "이 클래스에서 Spring Boot를 시작해"
public class EgovApplication {
    public static void main(String[] args) {
        SpringApplication.run(EgovApplication.class, args);  // 서버 ON
    }
}
```

- 이 파일을 실행하면 서버가 켜집니다
- `@SpringBootApplication` = Spring이 모든 설정을 자동으로 해줘
- `main` 메서드 = Java 프로그램의 시작점 (항상 이 이름, 이 형태)

> 💡 **확인해보기:** IntelliJ에서 이 파일을 열면 `main` 메서드 왼쪽에 초록색 ▶ 버튼이 있습니다. 이걸 클릭해도 서버가 실행됩니다.

---

### application.properties — 앱 설정 파일

**IntelliJ에서 열기:** `src/main/resources/application.properties`

```properties
# 포트 번호 (8080번 사용)
server.port=8080

# JSP 파일 위치 설정
spring.mvc.view.prefix=/WEB-INF/views/
spring.mvc.view.suffix=.jsp

# DB 연결 정보 (MODE=MySQL: MySQL 문법 호환, DB_CLOSE_DELAY=-1: 서버 종료 전까지 DB 유지)
spring.datasource.url=jdbc:h2:mem:egovdb;MODE=MySQL;DB_CLOSE_DELAY=-1;NON_KEYWORDS=VALUE
```

- 코드를 바꾸지 않고 설정값만 바꿀 수 있게 분리해놓은 파일
- **비유**: 에어컨 리모컨 — 에어컨 내부 회로를 뜯지 않고 온도만 조절

> 💡 **직접 바꿔보기:** `server.port=8080`을 `server.port=9090`으로 바꾸고 서버를 재시작해보세요. 그러면 `http://localhost:9090/board/list` 로 접속해야 합니다. 확인 후 다시 8080으로 되돌리세요.

---

### schema.sql + data.sql — DB 초기화

**IntelliJ에서 열기:** `src/main/resources/sql/` 폴더 안

```sql
-- schema.sql: 테이블 만들기 (서랍장 칸 구성)
CREATE TABLE tb_board (
    board_no    INT AUTO_INCREMENT PRIMARY KEY,
    board_title VARCHAR(200) NOT NULL,
    ...
);

-- data.sql: 샘플 데이터 넣기 (서랍장에 미리 내용물 채우기)
INSERT INTO tb_board (board_title, ...) VALUES ('전자정부프레임워크 소개', ...);
```

- 앱이 시작될 때 자동으로 실행됩니다
- H2 인메모리 DB는 서버를 껐다 켜면 데이터가 사라지기 때문에
  매번 자동으로 테이블을 만들고 샘플 데이터를 넣어줍니다

> 💡 **확인해보기:**
> 1. 서버 실행 중에 `http://localhost:8080/h2-console` 접속
> 2. JDBC URL: `jdbc:h2:mem:egovdb`, User Name: `sa`, Password: 비워두기
> 3. `Connect` 클릭
> 4. 왼쪽에 `TB_BOARD` 테이블이 보이면 성공
> 5. SQL 입력창에 `SELECT * FROM TB_BOARD;` 입력 후 `Run` 클릭

---

## 4. 어노테이션(Annotation) — `@` 기호 이해하기

코드에 `@`로 시작하는 것들이 많이 보입니다. 이것이 **어노테이션**입니다.

```java
@Controller           // "이 클래스는 컨트롤러입니다"
@Service              // "이 클래스는 서비스입니다"
@Repository           // "이 클래스는 DAO입니다"
@Autowired            // "이 객체를 Spring이 자동으로 넣어줘"
@GetMapping("/list")  // "GET /list 요청이 오면 이 메서드를 실행해"
@Transactional        // "이 메서드는 트랜잭션으로 처리해"
```

**어노테이션은 Spring에게 보내는 "라벨 스티커"입니다.**

예를 들어 물건에 라벨 스티커를 붙이면:
- `🔴 위험물` → 조심히 다뤄라
- `📦 냉동식품` → 냉동 보관해라

마찬가지로 코드에 `@Controller`를 붙이면:
- Spring이 "아, 이건 컨트롤러구나. HTTP 요청을 처리하는 클래스네" 라고 인식합니다

**처음에 자주 보게 될 어노테이션 정리:**

| 어노테이션 | 붙이는 위치 | 의미 |
|-----------|-----------|------|
| `@Controller` | 클래스 위 | 이 클래스는 요청을 받는 컨트롤러 |
| `@Service` | 클래스 위 | 이 클래스는 비즈니스 로직을 담당 |
| `@Repository` | 클래스 위 | 이 클래스는 DB와 통신하는 DAO |
| `@Autowired` | 변수 위 | Spring이 이 변수에 객체를 자동으로 넣어줘 |
| `@GetMapping` | 메서드 위 | 이 메서드는 GET 요청을 처리 |
| `@PostMapping` | 메서드 위 | 이 메서드는 POST 요청을 처리 |

---

## 5. 의존성 주입(Dependency Injection) — `@Autowired`

```java
@Controller
public class BoardController {

    @Autowired                        // ← 이 부분!
    private BoardService boardService;
    //      └── "BoardService 객체를 Spring이 알아서 만들어서 여기에 넣어줘"
}
```

**비유로 이해하기:**

> 레스토랑의 홀 직원(Controller)이 필요할 때:
> - 기존 방식: 홀 직원이 직접 주방장(Service)을 고용하고 관리
> - `@Autowired` 방식: 레스토랑 사장(Spring)이 알아서 주방장을 배치해줌
>   홀 직원은 그냥 `boardService.xxx()` 라고 부르기만 하면 됨

이렇게 하면 Controller가 Service를 직접 만들 필요 없고,
필요할 때 Spring이 알아서 연결해줍니다.

**`@Autowired` 없이 직접 만드는 방식 (나쁜 예):**
```java
// 이렇게 하면 안 됩니다
BoardService boardService = new BoardServiceImpl();
// → 테스트도 어렵고, DB 교체도 어렵고, 코드가 복잡해짐
```

**`@Autowired` 사용 (좋은 예):**
```java
@Autowired
private BoardService boardService;
// → Spring이 알아서 넣어줌. 우리는 그냥 사용만 하면 됨
```

---

## 6. 처음으로 파일 열어보기 — 실습

지금 바로 아래 파일들을 순서대로 열고 겉모습만 훑어보세요.
내용은 아직 몰라도 됩니다. "이런 파일이 있구나" 정도만 파악하면 됩니다.

**순서:**

1. `src/main/java/.../board/vo/BoardVO.java`
   - 어떤 필드(변수)들이 있나요?

2. `src/main/java/.../board/dao/BoardDAO.java`
   - 어떤 메서드들이 선언되어 있나요?

3. `src/main/java/.../board/service/BoardServiceImpl.java`
   - `@Autowired` 로 무엇을 주입받고 있나요?

4. `src/main/java/.../board/controller/BoardController.java`
   - `@GetMapping`, `@PostMapping` 이 몇 개나 있나요?

5. `src/main/resources/mapper/BoardMapper.xml`
   - `<select>`, `<insert>`, `<update>`, `<delete>` 태그들이 보이나요?

6. `src/main/webapp/WEB-INF/views/board/list.jsp`
   - HTML처럼 생겼지만 `${...}` 와 `<c:...>` 태그들이 섞여 있나요?

---

## 핵심 요약

```
✅ java/     → 실제 로직이 담긴 Java 파일들
✅ resources/ → 설정 파일, SQL 파일, Mapper XML
✅ webapp/   → JSP 화면 파일들
✅ @어노테이션 → Spring에게 보내는 라벨 스티커
✅ @Autowired → Spring이 객체를 알아서 주입해줌 (직접 new 안 해도 됨)
✅ Controller → Service → DAO → DB 순서로 흐름이 내려감
✅ Ctrl+Shift+N (Mac: Cmd+Shift+O) → IntelliJ에서 파일 이름으로 검색
```

---

이전: [GUIDE-01-웹동작원리.md](GUIDE-01-웹동작원리.md)
다음: [GUIDE-03-VO.md](GUIDE-03-VO.md)
