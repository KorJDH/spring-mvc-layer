# GUIDE-01. 웹이 동작하는 원리

> 코드를 보기 전에, 브라우저와 서버가 어떻게 대화하는지 이해해야 합니다.
> 이것이 모든 웹 개발의 기초입니다.

---

## 1. 브라우저와 서버의 대화 — HTTP

여러분이 브라우저 주소창에 `http://localhost:8080/board/list` 를 입력하면
무슨 일이 일어날까요?

```
여러분 (브라우저)             서버 (우리가 만든 Spring 앱)
      │                              │
      │  "야, /board/list 줘!"       │
      │ ─────────── 요청(Request) ──▶│
      │                              │  (DB에서 게시글 목록 꺼내서...)
      │  "여기 게시판 목록 HTML이야"  │
      │ ◀────────── 응답(Response) ──│
      │                              │
   화면에 표시
```

이 대화 방식을 **HTTP(HyperText Transfer Protocol)** 라고 합니다.
쉽게 말해 브라우저와 서버 사이의 **약속된 대화 규칙**입니다.

**비유:**
> 카페에서 음료를 주문하는 것과 같습니다.
> - 손님(브라우저)이 "아메리카노 주세요"(요청)
> - 바리스타(서버)가 커피를 만들어서 건네줌(응답)
> - 손님이 커피를 받아 마심(화면에 표시)

---

## 2. GET vs POST — 두 가지 요청 방식

HTTP 요청에는 여러 종류가 있지만, 지금은 두 가지만 알면 됩니다.

### GET — 데이터를 "조회"할 때

```
브라우저 주소창에 직접 입력: http://localhost:8080/board/list
→ 이게 바로 GET 요청입니다
```

- **언제?** 페이지를 보여달라고 할 때 (목록, 상세, 폼 화면)
- **특징?** URL에 파라미터가 보입니다: `/board/view?boardNo=1`
- **비유?** 도서관에서 "책 좀 보여주세요" 라고 하는 것

### POST — 데이터를 "전송"할 때

```html
<!-- 폼에서 등록 버튼을 누르면 POST 요청 -->
<form method="post" action="/board/write">
    ...
</form>
```

- **언제?** 데이터를 저장/수정/삭제할 때
- **특징?** URL에 데이터가 노출되지 않음. 요청 본문(body)에 숨겨서 전송
- **비유?** 도서관에 "이 책 반납합니다" 라고 하면서 책을 건네는 것

### 정리

| | GET | POST |
|--|-----|------|
| 목적 | 조회 | 생성/수정/삭제 |
| 데이터 위치 | URL에 노출 | 숨겨서 전송 |
| 예시 | 목록보기, 상세보기 | 글쓰기, 수정, 삭제 |

---

## 3. URL의 구조

```
http://localhost:8080/board/list?searchCondition=title&searchKeyword=Spring
│      │         │    │          └─────────────────────────────────────────┘
│      │         │    │                         파라미터 (쿼리스트링)
│      │         │    └─── 경로(Path): Controller에서 @RequestMapping으로 받음
│      │         └──────── 포트번호: 8080번으로 실행 중인 서버
│      └────────────────── 호스트: localhost = 내 컴퓨터
└──────────────────────── 프로토콜: http
```

**파라미터 읽는 법:**
- `?` 다음부터 파라미터 시작
- `키=값` 형태
- `&` 로 여러 파라미터 구분
- 위 예시: `searchCondition`의 값은 `title`, `searchKeyword`의 값은 `Spring`

**실제로 해보기:**
`http://localhost:8080/board/list` 주소창에서 `?`를 붙여 파라미터를 추가해보세요:
```
http://localhost:8080/board/list?searchCondition=title&searchKeyword=Spring
```
검색 결과가 달라지는 것을 확인해보세요.

---

## 4. Spring MVC의 요청 처리 흐름

Spring은 요청이 들어오면 이렇게 처리합니다:

```
브라우저
    │  GET /board/list
    ↓
┌─────────────────────────────────────┐
│         DispatcherServlet           │  ← Spring의 "교통 경찰"
│  (모든 요청을 가장 먼저 받는 곳)    │    어느 Controller로 보낼지 결정
└─────────────────────────────────────┘
    │
    │  "/board/list" 는 BoardController의 selectBoardList() 가 담당!
    ↓
┌─────────────────────────────────────┐
│         BoardController             │
│  @GetMapping("/list")               │
│  public String selectBoardList(...) │
└─────────────────────────────────────┘
    │
    │  Service 호출 → DB 조회 → 결과를 Model에 담기
    ↓
┌─────────────────────────────────────┐
│         ViewResolver                │  ← "board/list" 라는 이름을
│  "board/list" → JSP 경로로 변환     │    실제 JSP 파일 경로로 바꿔줌
└─────────────────────────────────────┘
    │
    │  /WEB-INF/views/board/list.jsp 에 데이터 전달
    ↓
┌─────────────────────────────────────┐
│         list.jsp                    │  ← HTML로 렌더링
└─────────────────────────────────────┘
    │  완성된 HTML
    ↓
브라우저 (화면 표시)
```

**application.properties 에서 ViewResolver 설정:**
```properties
spring.mvc.view.prefix=/WEB-INF/views/    # 앞에 붙이는 경로
spring.mvc.view.suffix=.jsp               # 뒤에 붙이는 확장자

# Controller가 "board/list" 반환
# → /WEB-INF/views/ + board/list + .jsp
# → /WEB-INF/views/board/list.jsp  ✓
```

---

## 5. 실제로 확인해보기 — 개발자 도구 사용법

브라우저에는 "개발자 도구"라는 기능이 내장되어 있습니다.
HTTP 요청/응답을 눈으로 직접 볼 수 있는 강력한 도구입니다.

**개발자 도구 열기:**

| 브라우저 | 단축키 |
|---------|--------|
| Chrome | `F12` 또는 `Ctrl + Shift + I` (Windows) / `Cmd + Option + I` (Mac) |
| Edge | `F12` |
| Safari | `Cmd + Option + I` (먼저 개발자 메뉴 활성화 필요) |
| Firefox | `F12` |

**따라해보기:**

**1단계:** 서버가 실행된 상태에서 Chrome 브라우저 열기

**2단계:** `F12` 키를 누르면 오른쪽 또는 아래쪽에 개발자 도구 창이 열림

**3단계:** 상단 탭에서 **`Network`** 클릭

```
[Elements] [Console] [Sources] [Network] [Performance] ...
                                  ↑ 이걸 클릭!
```

**4단계:** `http://localhost:8080/board/list` 주소로 이동

**5단계:** Network 탭에 여러 줄이 나타납니다. 맨 위 `list` 항목 클릭

**6단계:** 오른쪽에 정보가 표시됩니다:

```
Headers 탭:

Request URL: http://localhost:8080/board/list
Request Method: GET          ← 요청 방식 (GET 또는 POST)
Status Code: 200 OK          ← 응답 코드
                               200 = 성공
                               404 = 페이지 없음
                               500 = 서버 에러
```

**상태 코드(Status Code) 의미:**
| 코드 | 의미 | 언제 보이나요? |
|------|------|--------------|
| 200 | 성공 | 정상적으로 페이지가 로딩될 때 |
| 302 | 이동 | 등록/수정/삭제 후 redirect 될 때 |
| 404 | 없음 | 주소가 틀렸을 때 |
| 500 | 서버 에러 | 코드에 에러가 있을 때 |

**이렇게 활용하세요:**
- 페이지가 안 뜰 때 → Network 탭에서 빨간 줄 찾기
- POST 요청으로 보내는 데이터 확인 → Network → 해당 요청 → `Payload` 탭

---

## 핵심 요약

```
✅ 브라우저 → 서버 = 요청(Request)
✅ 서버 → 브라우저 = 응답(Response)
✅ GET = 보여달라 (조회)
✅ POST = 처리해달라 (등록/수정/삭제)
✅ Spring의 DispatcherServlet이 요청을 Controller로 연결해줌
✅ Controller 반환값(문자열) → ViewResolver → JSP 파일 경로로 변환
✅ F12 개발자 도구 → Network 탭으로 요청/응답 직접 확인 가능
```

---

이전: [GUIDE-00-시작하기전에.md](GUIDE-00-시작하기전에.md)
다음: [GUIDE-02-프로젝트구조.md](GUIDE-02-프로젝트구조.md)
