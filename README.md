# 전자정부프레임워크 학습 프로젝트 — 게시판

> 비개발자 출신 주니어를 위한 전자정부프레임워크 입문 프로젝트입니다.
> **Controller → Service → DAO → VO** 패턴을 처음부터 하나씩 따라가며 배울 수 있습니다.

---

## 시작하기 전에

### 1. 이 프로젝트에서 배우는 것

한국 공공기관 프로젝트의 95%는 전자정부프레임워크 기반입니다.
이 프로젝트는 그 핵심 구조를 가장 단순한 "게시판" 예제로 학습합니다.

```
브라우저 요청
    ↓
Controller  ← 요청을 받아 Service에 넘김
    ↓
Service     ← 실제 업무 로직 처리
    ↓
DAO         ← DB와 직접 통신
    ↓
H2 DB       ← 데이터 저장
    ↑
VO          ← 계층 사이에서 데이터를 담아 전달하는 상자
```

### 2. 필요한 것

| 도구 | 버전 | 확인 방법 |
|------|------|---------|
| Java | 11 이상 | `java -version` |
| Maven | 3.x 이상 | `mvn -version` |

> Java나 Maven이 없다면 → **[docs/guide/GUIDE-00-시작하기전에.md](docs/guide/GUIDE-00-시작하기전에.md)** 에 설치 방법이 있습니다.

---

## 빠른 시작

### 1. 프로젝트 받기

```bash
git clone https://github.com/[계정명]/egov.git
cd egov
```

### 2. 실행

```bash
mvn spring-boot:run
```

처음 실행 시 필요한 라이브러리를 자동으로 다운받습니다 (인터넷 필요, 약 5분 소요).

**성공하면 이런 메시지가 나옵니다:**
```
Started EgovApplication in 3.xxx seconds
```

### 3. 브라우저에서 확인

| 주소 | 설명 |
|------|------|
| http://localhost:8080/board/list | 게시판 목록 |
| http://localhost:8080/h2-console | DB 콘솔 (JDBC URL: `jdbc:h2:mem:egovdb`, 계정: `sa`) |

---

## 학습 가이드

`docs/guide/` 폴더에 10개의 가이드 파일이 있습니다.
**이 순서대로** 읽으면서 실제 코드를 함께 확인하세요.

| 순서 | 파일 | 내용 |
|------|------|------|
| 0 | [GUIDE-00-시작하기전에.md](docs/guide/GUIDE-00-시작하기전에.md) | 환경 설정, Java/Maven/IntelliJ 설치 |
| 1 | [GUIDE-01-웹동작원리.md](docs/guide/GUIDE-01-웹동작원리.md) | HTTP, GET/POST, DispatcherServlet |
| 2 | [GUIDE-02-프로젝트구조.md](docs/guide/GUIDE-02-프로젝트구조.md) | 폴더 구조, 어노테이션, @Autowired |
| 3 | [GUIDE-03-VO.md](docs/guide/GUIDE-03-VO.md) | 데이터 상자, Lombok, getter/setter |
| 4 | [GUIDE-04-DAO.md](docs/guide/GUIDE-04-DAO.md) | DB 창구, SqlSession, 인터페이스+Impl |
| 5 | [GUIDE-05-MyBatis.md](docs/guide/GUIDE-05-MyBatis.md) | SQL 작성, #{} vs ${}, 동적 SQL |
| 6 | [GUIDE-06-Service.md](docs/guide/GUIDE-06-Service.md) | 비즈니스 로직, @Transactional |
| 7 | [GUIDE-07-Controller.md](docs/guide/GUIDE-07-Controller.md) | @GetMapping/@PostMapping, PRG 패턴 |
| 8 | [GUIDE-08-JSP.md](docs/guide/GUIDE-08-JSP.md) | EL, JSTL, form 태그 |
| 9 | [GUIDE-09-전체흐름.md](docs/guide/GUIDE-09-전체흐름.md) | 글 등록 전체 흐름 따라가기 |

> 💡 **처음이라면 GUIDE-00부터 시작하세요.** Java 설치부터 IntelliJ 설정까지 모두 안내합니다.

---

## 프로젝트 구조

```
egov/
├── pom.xml                              ← Maven 의존성 (라이브러리 목록)
├── docs/guide/                          ← 학습 가이드 (여기부터 읽으세요!)
└── src/main/
    ├── java/com/example/egov/board/
    │   ├── controller/
    │   │   └── BoardController.java     ← HTTP 요청/응답
    │   ├── service/
    │   │   ├── BoardService.java        ← 비즈니스 로직 인터페이스
    │   │   └── BoardServiceImpl.java    ← 비즈니스 로직 구현
    │   ├── dao/
    │   │   ├── BoardDAO.java            ← DB 접근 인터페이스
    │   │   └── BoardDAOImpl.java        ← SqlSession으로 MyBatis 호출
    │   └── vo/
    │       └── BoardVO.java             ← 데이터 전달 객체
    ├── resources/
    │   ├── application.properties       ← 포트, DB, JSP 설정
    │   ├── mapper/BoardMapper.xml       ← SQL 쿼리 모음
    │   └── sql/
    │       ├── schema.sql               ← 테이블 생성
    │       └── data.sql                 ← 샘플 데이터
    └── webapp/WEB-INF/views/board/
        ├── list.jsp                     ← 목록 화면
        ├── view.jsp                     ← 상세 화면
        ├── writeForm.jsp                ← 등록 폼
        └── updateForm.jsp               ← 수정 폼
```

---

## 게시판 기능

| 기능 | URL | 방식 |
|------|-----|------|
| 목록 조회 | `/board/list` | GET |
| 상세 조회 | `/board/view?boardNo=1` | GET |
| 등록 폼 | `/board/writeForm` | GET |
| 등록 처리 | `/board/write` | POST |
| 수정 폼 | `/board/updateForm?boardNo=1` | GET |
| 수정 처리 | `/board/update` | POST |
| 삭제 처리 | `/board/delete` | POST |

---

## 기술 스택

| 분류 | 기술 |
|------|------|
| 언어 | Java 11 |
| 프레임워크 | Spring Boot 2.7 (전자정부프레임워크 1.0 스타일) |
| ORM | MyBatis 2.3 |
| DB | H2 인메모리 (별도 설치 불필요) |
| View | JSP + JSTL |
| 빌드 | Maven |
| 코드 단축 | Lombok |

> **H2 인메모리 DB란?** 서버를 실행하는 동안만 존재하는 학습용 DB입니다.
> 서버를 껐다 켜면 데이터가 초기화되고 샘플 데이터가 다시 들어옵니다.
> 별도 DB 설치가 필요 없어 학습에 최적화되어 있습니다.

---

## 자주 묻는 질문

**Q. `java -version`이 안 됩니다.**
→ Java가 설치되지 않은 것입니다. [GUIDE-00](docs/guide/GUIDE-00-시작하기전에.md)의 STEP 1을 따라 설치하세요.

**Q. `mvn spring-boot:run` 실행 중 에러가 납니다.**
→ 터미널에서 `ERROR` 글자가 있는 줄을 찾아 구글에 검색하세요. 대부분 해결책이 나옵니다.

**Q. 실행은 됐는데 페이지가 안 열립니다.**
→ 서버가 실행 중인 터미널 창을 닫지 않았는지 확인하고, 주소(`http://localhost:8080/board/list`)를 다시 확인하세요.

**Q. 수정했는데 코드를 원래대로 되돌리고 싶습니다.**
→ `git checkout .` 명령어로 마지막 커밋 상태로 되돌릴 수 있습니다.
