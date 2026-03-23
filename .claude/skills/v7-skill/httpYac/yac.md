# httpYac 완벽 스터디 가이드

> **공식 문서**: https://httpyac.github.io
> **VS Code 확장**: [httpYac - Yet Another Client](https://marketplace.visualstudio.com/items?itemName=anweber.vscode-httpyac)
> **CLI**: `npm install -g httpyac`

---

## 목차

- [1. 개요 및 설치](#1-개요-및-설치)
- [2. 기본 요청 (Request)](#2-기본-요청-request)
  - [2.1. Request-Line 문법](#21-request-line-문법)
  - [2.2. Query String](#22-query-string)
  - [2.3. Headers](#23-headers)
  - [2.4. Cookie](#24-cookie)
  - [2.5. Request Body](#25-request-body)
  - [2.6. 파일 임포트 Body](#26-파일-임포트-body)
  - [2.7. Multipart/Form-Data](#27-multipartform-data)
- [3. 요청 분리와 주석](#3-요청-분리와-주석)
  - [3.1. 요청 분리자 (###)](#31-요청-분리자-)
  - [3.2. Global Region](#32-global-region)
  - [3.3. 주석](#33-주석)
- [서브 문서 참조](#서브-문서-참조) (4~17장은 별도 문서로 분리)
  - [변수 시스템 & 환경 설정 (4~5장)](#변수-시스템--환경-설정--yac-variablesmd)
  - [메타데이터 & 스크립팅 (6~7장)](#메타데이터--스크립팅--yac-metadata-scriptingmd)
  - [Assert & 응답 처리 (8~9장)](#assert--응답-처리--yac-assertmd)
  - [인증, 고급 요청, Hooks & Injected Languages (10~13장)](#인증-고급-요청-hooks--injected-languages--yac-advancedmd)
  - [실전 예제, 비교 & 베스트 프랙티스 (14~17장)](#실전-예제-비교--베스트-프랙티스--yac-practicemd)
- [18. 중요한 암기 목록](#18-중요한-암기-목록)

---

## 1. 개요 및 설치

httpYac은 VS Code에서 `.http` / `.rest` 파일을 통해 HTTP 요청을 보내고, 응답을 검증하고, 환경 변수를 관리할 수 있는 강력한 REST 클라이언트이다.

### 주요 특징

| 특징 | 설명 |
|------|------|
| HTTP/REST | GET, POST, PUT, DELETE 등 모든 HTTP 메서드 |
| GraphQL | 쿼리, 변수, Fragment 지원 |
| gRPC | Proto 로드, Unary/Streaming RPC |
| WebSocket | 양방향 실시간 통신 |
| SSE | Server-Sent Events 수신 |
| MQTT | Pub/Sub 메시징 |
| AMQP | RabbitMQ 연동 |
| 스크립팅 | NodeJS JavaScript 실행 |
| Assert | 응답 자동 검증 |
| 환경 변수 | dev/staging/prod 환경 전환 |
| CLI | 터미널에서 실행, CI/CD 연동 |

### 설치

**VS Code 확장:**
1. VS Code 확장 마켓에서 "httpYac" 검색
2. "anweber.vscode-httpyac" 설치

**CLI (터미널):**
```bash
npm install -g httpyac
```

---

## 2. 기본 요청 (Request)

### 2.1. Request-Line 문법

요청의 기본 형식은 `메서드 URL HTTP버전`이다. 메서드를 생략하면 GET이 기본값이다.

```http
### 전체 형식
GET https://httpbin.org/get HTTP/1.1

### 버전 생략 (기본 HTTP/1.1)
GET https://httpbin.org/get

### 메서드도 생략 (기본 GET)
https://httpbin.org/get

### HTTP/2 명시
GET https://httpbin.org/get HTTP/2.0
```

**URL을 여러 줄로 분리** (들여쓰기로 연속 표시):
```http
GET https://httpbin.org
  /get
```

**지원 HTTP 메서드:**
GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD, CONNECT, TRACE, PROPFIND, PROPPATCH, COPY, MOVE, LOCK, UNLOCK 등

---

### 2.2. Query String

쿼리 파라미터를 URL에 직접 붙이거나 줄바꿈으로 분리할 수 있다.

```http
### 한 줄로 작성
GET https://httpbin.org/anything?q=httpyac&lang=ko

### 여러 줄로 분리 (가독성 향상)
GET https://httpbin.org/anything
  ?q=httpyac
  &lang=ko
  &page=1
```

---

### 2.3. Headers

헤더는 URL 바로 아래에 `헤더명: 값` 형식으로 작성한다.

```http
GET https://httpbin.org/anything
Content-Type: application/json
Authorization: Bearer my-secret-token
Accept-Language: ko-KR
```

**헤더 재사용 (defaultHeaders 패턴):**

```http
### 글로벌 영역에서 공통 헤더 정의
{{+
  const token = "my-secret-token";
  exports.defaultHeaders = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  };
}}

###
GET https://httpbin.org/anything
...defaultHeaders
```

`...변수명` 문법으로 객체를 헤더로 펼칠 수 있다.

---

### 2.4. Cookie

쿠키 전송은 `Cookie` 헤더로 직접 설정한다. CookieJar가 기본 활성화되어 있어 서버의 `Set-Cookie` 응답이 자동으로 후속 요청에 포함된다.

```http
GET https://httpbin.org/cookies
Cookie: session=abc123; theme=dark
```

**쿠키 자동 저장 비활성화:**
```http
# @no-cookie-jar
GET https://www.google.de
```

> **참고**: CookieJar는 메모리 기반이므로 VS Code 재시작 시 초기화된다. 수동 초기화는 `httpyac.reset` 명령 사용.

---

### 2.5. Request Body

헤더 이후 빈 줄 다음에 오는 내용이 요청 본문이 된다.

```http
### JSON 바디
POST https://httpbin.org/anything
Content-Type: application/json

{
  "name": "홍길동",
  "age": 30,
  "email": "hong@example.com"
}

### Form URL Encoded
POST https://httpbin.org/anything
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&client_id=myapp&client_secret=secret123
```

**여러 바디 분리 (`===`):**

MQTT나 WebSocket에서 여러 메시지를 순차 전송할 때 사용한다.

```http
MQTT tcp://broker.hivemq.com
topic: httpyac

첫 번째 메시지
===
두 번째 메시지
=== wait-for-server
세 번째 메시지
```

---

### 2.6. 파일 임포트 Body

외부 파일의 내용을 요청 바디로 사용할 수 있다.

```http
### 파일 내용을 그대로 바디로 사용
POST https://httpbin.org/anything
Content-Type: application/json

< ./data/request-body.json
```

**변수 치환이 포함된 임포트 (`<@`):**
```http
@username=홍길동

POST https://httpbin.org/anything
Content-Type: application/json

<@ ./data/template.json
```

`template.json` 파일 내의 `{{username}}`이 "홍길동"으로 치환된다.

**인코딩 지정:**
```http
POST https://httpbin.org/anything
Content-Type: application/json

<@latin1 ./data/legacy-data.json
```

**변수로 경로 지정:**
```http
@assetsDir=./data/

POST https://httpbin.org/anything
Content-Type: application/json

< {{assetsDir}}request-body.json
```

---

### 2.7. Multipart/Form-Data

파일 업로드를 포함한 멀티파트 요청을 작성할 수 있다.

```http
POST https://httpbin.org/post
Content-Type: multipart/form-data; boundary=----FormBoundary

------FormBoundary
Content-Disposition: form-data; name="title"

게시글 제목
------FormBoundary
Content-Disposition: form-data; name="content"

게시글 내용입니다.
------FormBoundary
Content-Disposition: form-data; name="image"; filename="photo.jpg"
Content-Type: image/jpeg

< ./uploads/photo.jpg
------FormBoundary--
```

---

## 3. 요청 분리와 주석

### 3.1. 요청 분리자 (###)

한 파일에 여러 요청을 작성할 때 `###`로 구분한다.

```http
### 첫 번째 요청
GET https://httpbin.org/get

### 두 번째 요청
POST https://httpbin.org/post
Content-Type: application/json

{"key": "value"}

### 세 번째 요청
DELETE https://httpbin.org/delete
```

각 `###` 블록은 독립적인 요청으로 실행된다. VS Code에서는 각 요청 위에 "Send Request" 버튼이 표시된다.

---

### 3.2. Global Region

파일 첫 `###` 이전의 영역은 Global Region으로, 여기에 정의한 변수와 스크립트는 파일 내 모든 요청에 적용된다.

```http
# === Global Region (모든 요청에 적용) ===
@host=https://httpbin.org
@token=my-secret-token

###
# 첫 번째 요청 — host와 token 변수 사용 가능
GET {{host}}/anything
Authorization: Bearer {{token}}

###
# 두 번째 요청 — 동일 변수 사용 가능
POST {{host}}/anything
Authorization: Bearer {{token}}
Content-Type: application/json

{"message": "hello"}
```

---

### 3.3. 주석

```http
# 한 줄 주석 (# 스타일)
// 한 줄 주석 (// 스타일)

/*
  여러 줄 주석
  이 블록은 모두 무시된다.
*/

GET https://httpbin.org/get
```

> **참고**: 요청의 첫 번째 주석은 자동으로 해당 요청의 **설명(description)**으로 등록된다. httpBook에서 마크다운 렌더링에 활용된다.

---

## 서브 문서 참조

> 4~17장의 상세 내용은 아래 서브 문서에 분리되어 있다. 각 요약을 읽고 필요한 서브 문서를 참조한다.

---

### 변수 시스템 & 환경 설정 → [yac-variables.md](../references/http-yac/yac-variables.md)

httpYac에서 `.http` 파일 작성 시 변수를 정의하고 활용하는 전체 방법을 다룬다. `@변수명=값` 형태의 인라인 변수 정의, 고정 변수(`=`)와 지연 변수(`:=`)의 차이, `host` 변수를 통한 URL 자동 구성, `\{\{...\}\}` 이스케이프 방법을 설명한다. NodeJS 표현식으로 `{{Date.now()}}` 같은 동적 값을 생성하고, `$uuid`, `$timestamp`, `$randomInt` 등 IntelliJ/REST Client 호환 내장 동적 변수를 사용할 수 있다. `$input`, `$password`, `$pick` 으로 사용자 입력을 받고, `$global` 객체로 파일 간 글로벌 변수를 공유한다. 환경 설정에서는 `.env` 파일, `.httpyac.js` JSON 설정, IntelliJ 호환 `http-client.env.json` 파일을 통한 dev/staging/prod 환경 분리와 VS Code에서의 환경 전환 방법을 포함한다.

---

### 메타데이터 & 스크립팅 → [yac-metadata-scripting.md](../references/http-yac/yac-metadata-scripting.md)

요청의 동작을 제어하는 `# @태그` 메타데이터와 `{{ }}` JavaScript 스크립팅을 다룬다. `@name`으로 응답을 변수화하여 다른 요청에서 `{{name.field}}` 형태로 참조하고, `@ref`/`@forceRef`로 요청 간 의존성을 설정한다. `@import`로 외부 `.http` 파일을 참조하고, `@loop`로 배열 순회 및 횟수/조건 반복 실행을 구성한다. `@sleep`, `@disabled`, `@ratelimit`으로 실행 흐름을 제어하며, `@no-redirect`, `@no-reject-unauthorized`, `@proxy` 등 네트워크 관련 태그와 `@debug`, `@save` 등 출력/로깅 태그를 제공한다. 스크립팅에서는 `{{ }}` 블록의 요청 전/후 실행 시점 구분, `{{@request}}`, `{{@response}}` 등 이벤트 기반 스크립트, `exports`/`$global` 변수 저장, `require()`를 통한 외부 모듈(uuid, dayjs, crypto 등) 사용, `$cancel`로 실행 중단하는 방법을 설명한다.

---

### Assert & 응답 처리 → [yac-assert.md](../references/http-yac/yac-assert.md)

API 테스트 자동화의 핵심인 `??` Assert 문법과 응답 처리 방법을 다룬다. `?? [대상] [조건] [예상값]` 형식으로 status, header, body, duration 네 가지 대상에 대해 `==`, `!=`, `>`, `<`, `includes`, `exists`, `isNumber`, `isArray`, `matches` 등 조건 연산자를 사용한다. JSON 응답은 `body data.user.name` 형태의 경로 접근으로 중첩 필드를 검증하고, `?? js` 접두사로 JavaScript 표현식 기반 복합 검증을 수행한다. XPath Assert로 XML 응답도 검증 가능하다. `test()` 함수와 Node.js `assert` 모듈 또는 Chai 라이브러리로 구조화된 테스트를 작성하며, `test.status()`, `test.headerContains()` 등 보조 테스트 메서드를 제공한다. 응답 문서화(`HTTP/1.1 200 OK`)와 `>>`/`>>!` 연산자로 응답을 파일에 저장하는 방법도 포함한다.

---

### 인증, 고급 요청, Hooks & Injected Languages → [yac-advanced.md](../references/http-yac/yac-advanced.md)

httpYac의 인증 기능과 HTTP 이외의 프로토콜 지원, 플러그인 시스템을 다룬다. Basic/Digest Authentication, OAuth2/OpenID Connect(Client Credentials, Authorization Code, PKCE, Implicit, Password, Device Code 6개 플로우), AWS Signature v4, SSL 클라이언트 인증서 등 인증 방식을 설명한다. 고급 요청 타입에서는 GraphQL(쿼리, Fragment, 외부 `.gql` 파일 임포트), gRPC(Proto 로드, Unary/Server/Client/Bidirectional Streaming, Reflection), WebSocket(양방향 통신, `@keepStreaming`), SSE(Server-Sent Events), MQTT(Pub/Sub, QoS, 인증 옵션), AMQP/RabbitMQ(Exchange/Queue 선언, 바인딩, 메시지 발행/소비)를 포함한다. Hooks 시스템에서는 `httpyac.config.js`를 통한 `responseLogging`, `onRequest` 등 플러그인 Hook 설정을 다루고, Injected Languages로 Markdown이나 Asciidoctor 파일 내에서 HTTP 요청 블록을 인식하는 방법을 설명한다.

---

### 실전 예제, 비교 & 베스트 프랙티스 → [yac-practice.md](../references/http-yac/yac-practice.md)

httpYac을 실무에서 활용하는 구체적인 워크플로우와 도구 비교를 다룬다. 필고 API 테스트를 예시로 로그인-스핀실행-히스토리조회의 멀티스텝 API 테스트 워크플로우를 완전한 `.http` 파일로 구성하는 방법을 보여준다. REST Client와 httpYac의 기능 비교표(스크립팅, Assert, gRPC, WebSocket, CLI, CI/CD 등)를 제공한다. 베스트 프랙티스에서는 요청당 파일 분리, `@import`/`@ref` 활용, 환경별 host 전환, CI/CD 자동화(`httpyac --all -e dev`), 응답값 체이닝 패턴(생성-조회-삭제), `.env.local`과 `.gitignore`를 통한 민감 정보 관리를 제안한다. 자주 사용하는 패턴 Quick Reference도 포함한다. Bruno vs httpYac 실전 비교에서는 HTTP 파일 포맷의 역사, 인기도 차이(Bruno 27,000+ vs httpYac 500 Stars), 대상 사용자별 추천, Postman 마이그레이션 팁, GitHub Actions CI/CD 설정 예시를 다룬다.

---

## 18. 중요한 암기 목록

> 이 섹션은 httpYac에서 가장 자주 사용하고, 반드시 기억해야 하는 핵심 문법을 정리한 것이다.

---

### 18.1. `??` — 응답 단언(Assert) 문법

**한 줄 요약**: 요청 후 응답을 자동 검증하는 테스트 구문. 실패 시 FAIL 처리.

**기본 형식**: `?? [대상] [조건] [예상값]`

#### 검증 대상 4가지

| 대상 | 의미 | 예시 |
|------|------|------|
| `status` | HTTP 상태 코드 | `?? status == 200` |
| `header` | 응답 헤더 값 | `?? header content-type includes json` |
| `body` | 응답 본문 (JSON 경로 접근) | `?? body data.name == 홍길동` |
| `duration` | 응답 소요 시간 (ms) | `?? duration < 2000` |

#### 자주 쓰는 조건 연산자

| 연산자 | 의미 | 예시 |
|--------|------|------|
| `==` | 같음 | `?? status == 200` |
| `!=` | 다름 | `?? status != 500` |
| `>`, `>=`, `<`, `<=` | 크기 비교 | `?? body count >= 1` |
| `exists` | 존재 여부 | `?? body data.prize exists` |
| `includes` / `contains` | 포함 여부 | `?? body message includes 성공` |
| `isNumber` | 숫자 타입 | `?? body id isNumber` |
| `isArray` | 배열 타입 | `?? body items isArray` |
| `isFalse` | 거짓/미존재 | `?? body error isFalse` |
| `matches` | 정규표현식 | `?? status matches ^2\\d{2}` |

#### 실전 패턴 모음

```http
# 기본 성공 검증
?? status == 200
?? body success == true
?? body data exists

# JSON 중첩 경로 접근
?? body data.user.name == 홍길동
?? body data.items[0].id isNumber

# 성능 검증
?? duration < 3000

# 헤더 검증
?? header content-type includes application/json

# JavaScript 기반 복합 검증
?? js response.parsedBody.items.length > 0
?? js response.statusCode >= 200 && response.statusCode < 300
```

---

### 18.2. `{{ }}` — 스크립팅 문법

**한 줄 요약**: NodeJS JavaScript를 실행하는 블록. 변수 저장, 응답 처리, 조건 분기에 사용.

#### 변수 치환 vs 스크립트 블록 구분법 (핵심!)

| 형태 | 용도 | 구분 기준 |
|------|------|-----------|
| `{{변수명}}` | 변수 값 치환 | 한 줄, 중괄호 안에 공백/줄바꿈 없음 |
| `{{\n코드\n}}` | 스크립트 실행 | 여러 줄, **첫 줄이 공백** |

```http
# 변수 치환 (한 줄)
GET {{host}}/api?id={{userId}}

# 스크립트 블록 (여러 줄, 첫 줄 공백)
{{
  exports.myVar = "값";
}}
```

#### 실행 시점 (위치가 결정)

| 위치 | 실행 시점 |
|------|-----------|
| 요청 URL **이전** | 요청 전송 **전** 실행 |
| 요청 URL **이후** | 응답 수신 **후** 실행 |

```http
# ① 요청 전 실행 (URL 위에 위치)
{{
  exports.timestamp = Date.now();
}}
GET https://api.example.com/data?ts={{timestamp}}

# ② 응답 후 실행 (URL 아래에 위치)
{{
  console.info("상태: " + response.statusCode);
  const body = response.parsedBody;
  exports.token = body.token;
}}
```

#### 스크립트 내 핵심 전역 객체

| 객체 | 용도 | 사용 예시 |
|------|------|-----------|
| `response.statusCode` | HTTP 상태 코드 | `response.statusCode === 200` |
| `response.parsedBody` | JSON 파싱된 응답 본문 | `response.parsedBody.data.name` |
| `response.headers` | 응답 헤더 | `response.headers['content-type']` |
| `request` | 요청 객체 (수정 가능) | `request.headers['X-Custom'] = 'val'` |
| `exports` | 변수 저장 | `exports.myVar = "값"` |
| `$global` | 글로벌 변수 (파일 간 공유) | `$global.token = body.token` |
| `test(name, fn)` | 테스트 함수 | `test('이름', () => { ... })` |
| `console.info()` | 로그 출력 | `console.info("결과: " + data)` |

#### 실전 패턴 모음

```http
# 패턴 1: 응답 값 추출 후 변수 저장
{{
  const body = response.parsedBody;
  $global.authToken = body.token;
  $global.userId = body.user.id;
}}

# 패턴 2: 조건 분기 + 로깅
{{
  const body = response.parsedBody;
  if (body.success) {
    console.info("성공: " + JSON.stringify(body.data));
  } else {
    console.warn("실패: " + body.message);
  }
}}

# 패턴 3: test() 함수로 구조화된 검증
{{
  const { equal, ok } = require('assert');

  test('상태 코드 200', () => {
    equal(response.statusCode, 200);
  });

  test('데이터가 존재해야 한다', () => {
    ok(response.parsedBody.data);
  });
}}

# 패턴 4: 보조 테스트 메서드 (간결한 검증)
{{
  test.status(200);
  test.headerContains("content-type", "json");
  test.hasResponseBody();
  test.totalTime(3000);
}}
```

---

### 18.3. `??` vs `{{ }}` 언제 어떤 것을 사용하는가?

| 상황 | 사용 구문 | 이유 |
|------|-----------|------|
| 상태 코드 확인 | `??` | `?? status == 200` 한 줄로 충분 |
| JSON 필드 존재 확인 | `??` | `?? body data exists` 한 줄로 충분 |
| 단순 값 비교 | `??` | `?? body name == 홍길동` 한 줄로 충분 |
| 응답 값을 변수로 저장 | `{{ }}` | `exports`, `$global`에 저장 필요 |
| 조건 분기 (if/else) | `{{ }}` | JavaScript 로직 필요 |
| 복합 검증 + 로깅 | `{{ }}` | 여러 단계 검증 + console 출력 |
| 외부 모듈 사용 (assert, chai) | `{{ }}` | `require()` 호출 필요 |

> **원칙**: 단순 검증은 `??`, 복잡한 로직은 `{{ }}`

---

### 18.4. 그 외 필수 암기 항목

#### 변수 정의

```http
@host=https://api.example.com          # 고정 변수 (즉시 평가)
@currentTime:={{Date.now()}}            # 지연 변수 (요청 시 평가)
```

#### 요청 분리자

```http
### 첫 번째 요청
GET https://api.example.com/users

### 두 번째 요청 (독립 실행)
POST https://api.example.com/users
```

#### 핵심 메타데이터 (@태그)

| 태그 | 용도 | 예시 |
|------|------|------|
| `# @name` | 응답을 변수로 저장 | `# @name loginResult` |
| `# @ref` | 다른 요청 먼저 실행 (캐시 사용) | `# @ref loginResult` |
| `# @forceRef` | 다른 요청 강제 재실행 | `# @forceRef loginResult` |
| `# @import` | 외부 .http 파일 참조 | `# @import ./auth.http` |
| `# @loop` | 반복 실행 | `# @loop for 5` |
| `# @disabled` | 요청 비활성화 | `# @disabled` |

#### 응답값 체이닝 패턴 (가장 많이 쓰는 패턴)

```http
### Step 1: 로그인 → 토큰 획득
# @name auth
POST {{host}}/login
Content-Type: application/json

{"email": "test@test.com", "password": "1234"}

?? status == 200

{{
  $global.token = response.parsedBody.token;
}}

###
### Step 2: 인증된 요청 (auth 참조)
# @forceRef auth
GET {{host}}/profile
Authorization: Bearer {{auth.token}}

?? status == 200
?? body name exists
```
