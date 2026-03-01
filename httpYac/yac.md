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
- [4. 변수 시스템](#4-변수-시스템)
  - [4.1. 인라인 변수](#41-인라인-변수)
  - [4.2. 고정 변수 vs 지연 변수](#42-고정-변수-vs-지연-변수)
  - [4.3. Host 변수](#43-host-변수)
  - [4.4. 변수 치환과 이스케이프](#44-변수-치환과-이스케이프)
  - [4.5. NodeJS 표현식](#45-nodejs-표현식)
  - [4.6. 동적 변수 (Built-in)](#46-동적-변수-built-in)
  - [4.7. 사용자 입력 변수](#47-사용자-입력-변수)
  - [4.8. 글로벌 변수 ($global)](#48-글로벌-변수-global)
  - [4.9. 변수 스코프](#49-변수-스코프)
- [5. 환경 설정 (Environments)](#5-환경-설정-environments)
  - [5.1. .env 파일](#51-env-파일)
  - [5.2. JSON 환경 설정](#52-json-환경-설정)
  - [5.3. IntelliJ 호환 환경 파일](#53-intellij-호환-환경-파일)
  - [5.4. 환경 전환 (VS Code)](#54-환경-전환-vs-code)
  - [5.5. 변수 확장](#55-변수-확장)
- [6. 메타데이터 (@태그)](#6-메타데이터-태그)
  - [6.1. @name — 응답 변수화](#61-name--응답-변수화)
  - [6.2. @ref / @forceRef — 요청 참조](#62-ref--forceref--요청-참조)
  - [6.3. @import — 외부 파일 참조](#63-import--외부-파일-참조)
  - [6.4. @loop — 반복 실행](#64-loop--반복-실행)
  - [6.5. @sleep — 대기](#65-sleep--대기)
  - [6.6. @disabled — 비활성화](#66-disabled--비활성화)
  - [6.7. @ratelimit — 속도 제한](#67-ratelimit--속도-제한)
  - [6.8. 네트워크 관련 태그](#68-네트워크-관련-태그)
  - [6.9. 출력/로깅 태그](#69-출력로깅-태그)
  - [6.10. 기타 태그](#610-기타-태그)
- [7. 스크립팅 (JavaScript)](#7-스크립팅-javascript)
  - [7.1. 기본 스크립트 블록](#71-기본-스크립트-블록)
  - [7.2. 요청 전/후 스크립트](#72-요청-전후-스크립트)
  - [7.3. 이벤트 기반 스크립트](#73-이벤트-기반-스크립트)
  - [7.4. 비동기 처리](#74-비동기-처리)
  - [7.5. 접근 가능한 전역 객체](#75-접근-가능한-전역-객체)
  - [7.6. 외부 모듈 사용](#76-외부-모듈-사용)
  - [7.7. 실행 중단 ($cancel)](#77-실행-중단-cancel)
  - [7.8. 디버깅](#78-디버깅)
- [8. Assert — 응답 검증](#8-assert--응답-검증)
  - [8.1. 기본 문법 (??)](#81-기본-문법-)
  - [8.2. 조건 연산자 전체 목록](#82-조건-연산자-전체-목록)
  - [8.3. Status Assert](#83-status-assert)
  - [8.4. Header Assert](#84-header-assert)
  - [8.5. Body Assert (JSON 경로)](#85-body-assert-json-경로)
  - [8.6. Duration Assert](#86-duration-assert)
  - [8.7. JavaScript Assert](#87-javascript-assert)
  - [8.8. XPath Assert](#88-xpath-assert)
  - [8.9. 스크립트 기반 테스트 (test 함수)](#89-스크립트-기반-테스트-test-함수)
  - [8.10. 보조 테스트 메서드](#810-보조-테스트-메서드)
- [9. 응답 처리 (Response)](#9-응답-처리-response)
  - [9.1. 응답 문서화](#91-응답-문서화)
  - [9.2. 출력 리다이렉트 (파일 저장)](#92-출력-리다이렉트-파일-저장)
- [10. 인증 (Authentication)](#10-인증-authentication)
  - [10.1. Basic Authentication](#101-basic-authentication)
  - [10.2. Digest Authentication](#102-digest-authentication)
  - [10.3. OAuth2 / OpenID Connect](#103-oauth2--openid-connect)
  - [10.4. AWS Signature v4](#104-aws-signature-v4)
  - [10.5. SSL 클라이언트 인증서](#105-ssl-클라이언트-인증서)
- [11. 고급 요청 타입](#11-고급-요청-타입)
  - [11.1. GraphQL](#111-graphql)
  - [11.2. gRPC](#112-grpc)
  - [11.3. WebSocket](#113-websocket)
  - [11.4. Server-Sent Events (SSE)](#114-server-sent-events-sse)
  - [11.5. MQTT](#115-mqtt)
  - [11.6. AMQP / RabbitMQ](#116-amqp--rabbitmq)
- [12. Hooks (플러그인)](#12-hooks-플러그인)
- [13. Injected Languages](#13-injected-languages)
- [14. 실전 예제: API 테스트 워크플로우](#14-실전-예제-api-테스트-워크플로우)
- [15. REST Client vs httpYac 비교](#15-rest-client-vs-httpyac-비교)
- [16. 팁과 베스트 프랙티스](#16-팁과-베스트-프랙티스)
- [17. Bruno vs httpYac — 실전 비교 (테크톡 기반)](#17-bruno-vs-httpyac--실전-비교-테크톡-기반)
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

## 4. 변수 시스템

httpYac의 변수 시스템은 매우 강력하다. `{{변수명}}` 형태로 URL, 헤더, 바디 어디에서나 사용할 수 있다.

### 4.1. 인라인 변수

`@변수명=값` 형태로 정의한다.

```http
@baseUrl=https://httpbin.org
@userId=12345
@apiKey=my-api-key-abc

GET {{baseUrl}}/anything?user={{userId}}
X-API-Key: {{apiKey}}
```

변수 안에서 다른 변수를 참조할 수 있다:
```http
@host=https://httpbin.org
@endpoint={{host}}/anything
```

---

### 4.2. 고정 변수 vs 지연 변수

**고정 변수 (`=`)**: 정의 즉시 평가된다.
```http
@timestamp=초기값
@greeting=Hello {{timestamp}}
# greeting은 "Hello 초기값"으로 즉시 평가됨
```

**지연 변수 (`:=`)**: 요청 실행 직전에 평가된다.
```http
@currentTime:={{new Date().toISOString()}}
# currentTime은 요청 전송 시점의 시간으로 평가됨

GET https://httpbin.org/anything?time={{currentTime}}
```

> **핵심 차이**: `:=`는 매 요청마다 새로운 값을 생성한다. 동적 값(시간, UUID 등)에 유용하다.

---

### 4.3. Host 변수

`host` 변수를 정의하면, URL을 `/`로 시작해도 자동으로 전체 URL이 구성된다.

```http
@host=https://httpbin.org

### host 변수가 자동으로 앞에 붙음
GET /anything?q=test
# 실제 URL: https://httpbin.org/anything?q=test

###
POST /post
Content-Type: application/json

{"key": "value"}
# 실제 URL: https://httpbin.org/post
```

> **팁**: 환경별로 `host` 변수만 바꾸면 dev/staging/prod를 쉽게 전환할 수 있다.

---

### 4.4. 변수 치환과 이스케이프

모든 `{{...}}`는 요청 전송 전에 실제 값으로 대체된다.

**치환 방지 (이스케이프):**
```http
POST https://httpbin.org/anything
Content-Type: application/json

{
  "template": "My \{\{someVariable\}\} template!!"
}
# 결과: "My {{someVariable}} template!!"
```

백슬래시 `\`로 중괄호를 이스케이프하면 변수 치환 없이 그대로 출력된다.

---

### 4.5. NodeJS 표현식

`{{...}}` 안에 JavaScript 코드를 직접 작성할 수 있다.

```http
GET https://httpbin.org/anything
  ?timestamp={{Date.now()}}
  &uuid={{require('uuid').v4()}}
  &random={{Math.floor(Math.random() * 1000)}}
  &date={{new Date().toISOString()}}
```

---

### 4.6. 동적 변수 (Built-in)

httpYac은 IntelliJ와 REST Client 호환 동적 변수를 제공한다.

#### IntelliJ 호환 변수

| 변수 | 설명 | 예시 값 |
|------|------|---------|
| `$uuid` | UUID v4 | `a1b2c3d4-e5f6-...` |
| `$timestamp` | UNIX 타임스탬프 (초) | `1709283600` |
| `$randomInt` | 0~1000 랜덤 정수 | `742` |
| `$isoTimestamp` | ISO 8601 형식 | `2024-03-01T12:00:00Z` |
| `$random.uuid` | UUID v4 | `a1b2c3d4-...` |
| `$random.integer(min, max)` | 범위 내 랜덤 정수 | `5` |
| `$random.float(min, max)` | 범위 내 랜덤 실수 | `3.14` |
| `$random.alphabetic(length)` | 랜덤 알파벳 문자열 | `abcXYz...` |
| `$random.email` | 랜덤 이메일 | `user@random.com` |
| `$random.hexadecimal(length)` | 랜덤 16진수 | `a3f` |

```http
GET https://httpbin.org/anything
  ?id={{$uuid}}
  &timestamp={{$timestamp}}
  &random={{$randomInt}}
  &email={{$random.email}}
```

#### REST Client 호환 변수

| 변수 | 설명 | 예시 |
|------|------|------|
| `$guid` | UUID v4 | `$uuid`와 동일 |
| `$randomInt min max` | 범위 랜덤 정수 | `{{$randomInt 100 200}}` |
| `$timestamp [offset]` | 타임스탬프 + 오프셋 | `{{$timestamp 2 h}}` |
| `$datetime format [offset]` | 날짜 포맷 | `{{$datetime rfc1123}}` |
| `$localDatetime format` | 로컬 날짜 | `{{$localDatetime iso8601}}` |
| `$processEnv KEY` | 환경 변수 | `{{$processEnv HOME}}` |
| `$dotenv KEY` | dotenv 변수 | `{{$dotenv API_KEY}}` |

```http
### 다양한 동적 변수 활용
GET https://httpbin.org/anything
  ?guid={{$guid}}
  &random={{$randomInt 1 100}}
  &timestamp={{$timestamp}}
  &timestamp_plus_2h={{$timestamp 2 h}}
  &date_rfc={{$datetime rfc1123}}
  &date_iso={{$datetime iso8601}}
  &date_custom={{$datetime "YYYY-MM-DD"}}
  &date_offset={{$datetime "DD.MM.YYYY" 7 d}}
  &local_date={{$localDatetime iso8601}}
  &env_user={{$processEnv USER}}
```

---

### 4.7. 사용자 입력 변수

실행 시 사용자에게 입력을 요청하는 변수를 정의할 수 있다.

```http
### 텍스트 입력 (기본값: foo)
@query = {{$input 검색어를 입력하세요 $value: foo}}

### 비밀번호 입력 (마스킹)
@secret = {{$password API 비밀키를 입력하세요}}

### 선택 목록
@env = {{$pick 환경을 선택하세요 $value: dev,staging,prod}}

GET https://httpbin.org/anything?q={{query}}&env={{env}}
Authorization: Bearer {{secret}}
```

**한 번만 묻기 (`-askonce`):**
```http
### 같은 세션 내에서 한 번만 입력받음
@apiKey = {{$input-askonce API Key를 입력하세요}}
```

---

### 4.8. 글로벌 변수 ($global)

스크립트에서 `$global` 객체를 사용하면 모든 요청에서 접근 가능한 글로벌 변수를 설정할 수 있다.

```http
### 로그인 후 토큰 저장
# @name loginRequest
POST https://api.example.com/login
Content-Type: application/json

{"email": "test@test.com", "password": "1234"}

{{
  // 응답에서 토큰을 추출하여 글로벌 변수에 저장
  $global.authToken = response.parsedBody.token;
  $global.userId = response.parsedBody.user.id;
}}

###
### 이후 모든 요청에서 사용 가능
GET https://api.example.com/profile/{{$global.userId}}
Authorization: Bearer {{$global.authToken}}
```

---

### 4.9. 변수 스코프

변수의 가시 범위는 3단계로 구분된다:

| 스코프 | 정의 위치 | 접근 범위 |
|--------|-----------|-----------|
| **환경 변수** | `.env` 파일, JSON 환경 설정 | 모든 파일의 모든 요청 |
| **파일 글로벌** | Global Region (첫 `###` 이전) | 해당 파일의 모든 요청 |
| **요청 변수** | 특정 `###` 블록 내 | 해당 요청 블록에서만 |

```http
# === 파일 글로벌 변수 (이 파일 모든 요청에서 사용 가능) ===
@baseUrl=https://httpbin.org

###
# 요청 변수 (이 블록에서만 사용 가능)
@localVar=only-here
GET {{baseUrl}}/anything?local={{localVar}}

###
# localVar는 여기서 사용 불가!
GET {{baseUrl}}/anything
```

---

## 5. 환경 설정 (Environments)

환경(Environment)은 변수의 집합이다. dev, staging, prod 같은 환경을 정의하고 전환할 수 있다.

### 5.1. .env 파일

가장 간단한 방법. 프로젝트 루트에 `.env` 파일을 생성한다.

```bash
# .env — 모든 환경에서 공유
API_VERSION=v2
TIMEOUT=5000
```

```bash
# .env.dev — dev 환경 전용 (또는 dev.env)
host=https://dev-api.example.com
API_KEY=dev-key-123
DEBUG=true
```

```bash
# .env.prod — prod 환경 전용 (또는 prod.env)
host=https://api.example.com
API_KEY=prod-key-secret
DEBUG=false
```

```bash
# .env.local — 로컬 개발용 (git에서 제외 권장)
host=https://localhost:3000
API_KEY=local-dev-key
```

**검색 위치 (우선순위):**
1. `.http` 파일과 같은 폴더
2. 프로젝트 루트
3. 프로젝트 루트의 `env/` 폴더
4. `HTTPYAC_ENV` 환경 변수가 가리키는 경로

---

### 5.2. JSON 환경 설정

`.httpyac.js` 또는 `.httpyac.json` 파일에서 더 구조화된 환경을 정의할 수 있다.

```javascript
// .httpyac.js
module.exports = {
  environments: {
    // $shared: 모든 환경에서 공유
    "$shared": {
      "apiVersion": "v2",
      "timeout": 5000
    },
    // $default: 환경 미선택 시 사용
    "$default": {
      "host": "https://localhost:3000"
    },
    // dev 환경
    "dev": {
      "host": "https://dev-api.example.com",
      "apiKey": "dev-key-123",
      "debug": true
    },
    // staging 환경
    "staging": {
      "host": "https://staging-api.example.com",
      "apiKey": "staging-key-456",
      "debug": false
    },
    // prod 환경
    "prod": {
      "host": "https://api.example.com",
      "apiKey": "prod-key-secret",
      "debug": false
    }
  }
};
```

---

### 5.3. IntelliJ 호환 환경 파일

IntelliJ의 환경 파일 형식도 지원한다.

```json
// http-client.env.json
{
  "dev": {
    "host": "https://dev-api.example.com",
    "token": "dev-token"
  },
  "prod": {
    "host": "https://api.example.com",
    "token": "prod-token"
  }
}
```

```json
// http-client.private.env.json (git에서 제외!)
{
  "dev": {
    "password": "dev-secret-password"
  },
  "prod": {
    "password": "prod-secret-password"
  }
}
```

---

### 5.4. 환경 전환 (VS Code)

VS Code에서 환경을 전환하는 방법:

1. **Command Palette**: `Ctrl+Shift+P` → "httpYac: Toggle Environment" 선택
2. 원하는 환경(dev, staging, prod) 선택
3. **여러 환경 동시 선택 가능** — 변수가 병합됨

> **참고**: 파일별로 다른 환경을 선택할 수 있으며, 새로 열린 파일은 마지막 활성 환경으로 시작한다.

---

### 5.5. 변수 확장

환경 변수 내에서 다른 변수를 참조할 수 있다.

```bash
# .env
authHost=https://auth.example.com

# .env.dev
host=https://dev-api.example.com
auth_tokenEndpoint={{authHost}}/oauth/token

# 결과: auth_tokenEndpoint = https://auth.example.com/oauth/token
```

---

## 6. 메타데이터 (@태그)

메타데이터는 `# @태그` 형식으로 요청의 동작을 제어한다.

### 6.1. @name — 응답 변수화

**가장 중요한 메타데이터.** 응답을 변수로 저장하여 다른 요청에서 참조할 수 있다.

```http
### 사용자 목록 가져오기 → "users" 변수에 저장
# @name users
GET https://httpbin.org/json

###
### users 응답의 JSON 필드 접근
POST https://httpbin.org/anything
Content-Type: application/json

{
  "author": "{{users.slideshow.author}}",
  "title": "{{users.slideshow.title}}"
}
```

JSON 응답은 자동으로 파싱되므로 `변수명.필드.하위필드` 형태로 바로 접근할 수 있다.

---

### 6.2. @ref / @forceRef — 요청 참조

현재 요청 실행 전에 다른 요청을 먼저 실행한다.

- `@ref`: 캐시된 응답이 있으면 재사용 (빠름)
- `@forceRef`: 항상 재실행 (최신 데이터 필요 시)

```http
### 토큰 발급 API
# @name auth
POST https://api.example.com/login
Content-Type: application/json

{"email": "test@test.com", "password": "1234"}

###
### 매번 auth를 재실행하여 최신 토큰 사용
# @forceRef auth
GET https://api.example.com/profile
Authorization: Bearer {{auth.token}}

###
### 캐시된 auth 응답 재사용
# @ref auth
GET https://api.example.com/settings
Authorization: Bearer {{auth.token}}
```

---

### 6.3. @import — 외부 파일 참조

다른 `.http` 파일의 명명된 요청을 가져온다.

```http
# @import ./auth/login.http

# @ref auth
GET https://api.example.com/protected
Authorization: Bearer {{auth.token}}
```

`login.http` 파일에 `# @name auth`로 정의된 요청이 있어야 한다.

---

### 6.4. @loop — 반복 실행

요청을 여러 번 반복 실행한다.

**for...of 패턴 (배열 순회):**
```http
{{
  exports.userIds = [101, 102, 103, 104, 105];
}}

###
# @loop for id of userIds
GET https://httpbin.org/anything?userId={{id}}
```

**for 패턴 (횟수 반복):**
```http
# @loop for 5
GET https://httpbin.org/anything?index={{$index}}
```

`$index`는 0부터 시작하는 자동 인덱스 변수이다.

**while 패턴 (조건 반복):**
```http
{{
  exports.counter = { value: 0 };
}}

###
# @loop while counter.value < 3
GET https://httpbin.org/anything?count={{counter.value++}}
```

> **참고**: @name과 함께 사용 시 변수명에 인덱스가 자동 붙는다 (예: `result0`, `result1`, `result2`).

---

### 6.5. @sleep — 대기

요청 실행 전 지정된 시간(밀리초) 대기한다.

```http
### 10초 대기 후 실행
# @sleep 10000
GET https://httpbin.org/anything
```

---

### 6.6. @disabled — 비활성화

요청을 비활성화한다.

```http
### 이 요청은 실행되지 않음
# @disabled
GET https://httpbin.org/anything

### 조건부 비활성화 (skipTest 변수가 true일 때 비활성화)
# @disabled skipTest
GET https://httpbin.org/anything

### 부정 조건 (callRequest 변수가 false일 때 비활성화)
# @disabled !callRequest
GET https://httpbin.org/anything
```

---

### 6.7. @ratelimit — 속도 제한

API 호출 빈도를 제한한다.

```http
### 최소 10초 간격으로 실행
# @ratelimit minIdleTime 10000
GET https://httpbin.org/json

### 60초 동안 최대 10회
# @ratelimit max 10 expire: 60000
GET https://httpbin.org/json

### 슬롯별 제한 (같은 슬롯 이름끼리 제한 공유)
# @ratelimit slot myApi minIdleTime 5000
GET https://httpbin.org/json
```

---

### 6.8. 네트워크 관련 태그

| 태그 | 설명 |
|------|------|
| `@no-redirect` | 리다이렉트 자동 따라가기 비활성화 |
| `@no-reject-unauthorized` | SSL 인증서 검증 무시 (자체 서명 인증서용) |
| `@proxy http://...` | 프록시 서버 지정 |
| `@no-proxy` | 프록시 사용 안 함 |
| `@no-cookie-jar` | 쿠키 자동 저장 비활성화 |
| `@no-client-cert` | SSL 클라이언트 인증서 전송 안 함 |

```http
### SSL 검증 무시 (로컬 개발 서버)
# @no-reject-unauthorized
GET https://localhost:8443/api/test

### 리다이렉트 따라가지 않기
# @no-redirect
GET https://httpbin.org/redirect/3

### 프록시 경유
# @proxy http://localhost:8888
GET https://httpbin.org/anything
```

---

### 6.9. 출력/로깅 태그

| 태그 | 설명 |
|------|------|
| `@no-log` | 로그 출력 안 함 |
| `@no-response-view` | 응답 뷰 표시 안 함 |
| `@debug` | 디버그 로그 활성화 |
| `@verbose` | 상세 추적 로그 활성화 |
| `@save` | 응답을 파일로 자동 저장 |
| `@extension ext` | 저장 파일의 확장자 지정 |
| `@openWith editor` | 지정 에디터로 응답 열기 |

```http
### 디버그 모드로 실행
# @debug
GET https://httpbin.org/anything

### 응답을 파일로 저장 (.gson 확장자)
# @save
# @extension gson
GET https://httpbin.org/json

### 이미지를 이미지 뷰어로 열기
# @openWith imagePreview.previewEditor
GET https://example.com/image.png
```

---

### 6.10. 기타 태그

| 태그 | 설명 |
|------|------|
| `@title 제목` | 요청 제목 지정 |
| `@description 설명` | 요청 설명 지정 |
| `@note 메시지` | 실행 전 확인 대화상자 표시 |
| `@jwt 변수` | JWT 토큰 자동 디코딩 |
| `@injectVariables` | 요청 본문에 변수 주입 (IntelliJ 호환) |
| `@keepStreaming` | WebSocket/MQTT/SSE 연결 유지 |
| `@noStreamingLog` | 스트리밍 중간 결과 로그 비활성화 |
| `@grpc-reflection` | gRPC Reflection 활성화 |

```http
### 삭제 전 확인 대화상자
# @note 정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.
DELETE https://api.example.com/users/123

### JWT 토큰 자동 디코딩
# @jwt tokenData
POST https://httpbin.org/anything
Content-Type: text/plain

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U
```

---

## 7. 스크립팅 (JavaScript)

httpYac의 가장 강력한 기능. `{{ }}` 블록 안에 NodeJS JavaScript를 작성할 수 있다.

### 7.1. 기본 스크립트 블록

```http
{{
  // 이 블록은 JavaScript로 실행된다
  // exports에 할당한 값은 변수로 저장된다
  exports.greeting = "Hello, World!";
  exports.today = new Date().toISOString().split('T')[0];
}}

###
GET https://httpbin.org/anything?msg={{greeting}}&date={{today}}
```

> **중요**: `{{ }}` 블록 내 첫 줄은 공백이어야 한다. 이것이 변수 치환 `{{변수명}}`과 스크립트 블록을 구분하는 기준이다.
>
> - `{{변수명}}` → 변수 치환 (한 줄, 공백 없음)
> - `{{ \n코드\n}}` → 스크립트 실행 (여러 줄, 첫 줄 공백)

---

### 7.2. 요청 전/후 스크립트

```http
### 요청 전 스크립트 (요청 라인 이전에 위치)
{{
  // 요청 전에 실행됨
  exports.timestamp = Date.now();
  console.info("요청 시작: " + new Date().toISOString());
}}
GET https://httpbin.org/anything?ts={{timestamp}}

### 요청 후 스크립트 (요청 라인 이후에 위치)
{{
  // 응답 수신 후 실행됨
  const data = response.parsedBody;
  console.info("상태 코드: " + response.statusCode);
  console.info("응답 데이터: " + JSON.stringify(data));

  // 응답에서 값 추출하여 변수로 저장
  exports.extractedValue = data.args.ts;
}}
```

**위치에 따른 실행 시점:**
- 요청 라인(URL) **이전**의 스크립트 → 요청 전 실행
- 요청 라인(URL) **이후**의 스크립트 → 응답 후 실행

---

### 7.3. 이벤트 기반 스크립트

특정 이벤트에 바인딩하여 실행할 수 있다.

| 이벤트 | 시점 | 문법 |
|--------|------|------|
| `request` | 요청 전송 직전 | `{{@request ... }}` |
| `streaming` | 스트리밍 중 | `{{@streaming ... }}` |
| `response` | 응답 수신 시 | `{{@response ... }}` |
| `responseLogging` | 응답 출력 시 | `{{@responseLogging ... }}` |
| `after` | 모든 처리 완료 후 | `{{@after ... }}` |

```http
### request 이벤트: 요청 객체 수정
{{@request
  // 요청 헤더에 타임스탬프 추가
  request.headers['X-Request-Time'] = new Date().toISOString();
}}
GET https://httpbin.org/anything

### response 이벤트: 응답 처리
{{@response
  if (response.statusCode !== 200) {
    console.error("에러 발생: " + response.statusCode);
  }
}}
```

**글로벌 이벤트 (`+` 접두사):**

`{{+이벤트명`으로 작성하면 파일 내 **모든 요청**에 적용된다.

```http
### 글로벌 영역에서 정의 — 모든 요청 완료 후 로그 출력
{{+after
  console.info(`[${response.statusCode}] ${request.url}`);
}}

###
GET https://httpbin.org/get

###
POST https://httpbin.org/post
Content-Type: application/json

{"key": "value"}
```

---

### 7.4. 비동기 처리

Promise를 `exports`에 할당하면 완료될 때까지 대기한다.

```http
{{
  async function fetchData() {
    await sleep(2000);  // 2초 대기
    return { message: "비동기 작업 완료" };
  }
  exports.asyncResult = fetchData();
}}

###
GET https://httpbin.org/anything?result={{asyncResult.message}}
```

---

### 7.5. 접근 가능한 전역 객체

스크립트 내에서 사용할 수 있는 전역 객체:

| 객체 | 설명 | 사용 예시 |
|------|------|-----------|
| `request` | 다음에 전송할 요청 객체 | `request.headers['X-Custom'] = 'val'` |
| `response` | 마지막 응답 객체 | `response.statusCode`, `response.parsedBody` |
| `$global` | 글로벌 변수 저장소 | `$global.token = 'abc'` |
| `$requestClient` | 스트리밍 메시지 전송 | `$requestClient.send({...})` |
| `httpFile` | 현재 .http 파일 정보 | `httpFile.fileName` |
| `httpRegion` | 현재 요청 영역 정보 | `httpRegion.metaData` |
| `sleep(ms)` | 밀리초 대기 함수 | `await sleep(5000)` |
| `test(name, fn)` | 테스트 함수 | `test('확인', () => { ... })` |
| `__dirname` | 현재 파일 디렉토리 경로 | `__dirname + '/data.json'` |
| `__filename` | 현재 파일 전체 경로 | |

---

### 7.6. 외부 모듈 사용

`require()`로 NodeJS 모듈을 로드할 수 있다.

**기본 제공 모듈 (별도 설치 불필요):**
- `uuid`, `dayjs`, `got`
- `mqtt`, `ws`, `eventsource`
- `@grpc/grpc-js`, `@xmldom/xmldom`, `xpath`
- `@cloudamqp/amqp-client`
- NodeJS 내장 API (fs, path, crypto 등)

```http
{{
  const { v4: uuidv4 } = require('uuid');
  const dayjs = require('dayjs');
  const crypto = require('crypto');

  exports.requestId = uuidv4();
  exports.formattedDate = dayjs().format('YYYY-MM-DD HH:mm:ss');
  exports.hash = crypto.createHash('sha256').update('hello').digest('hex');
}}

###
GET https://httpbin.org/anything
X-Request-Id: {{requestId}}
X-Date: {{formattedDate}}
X-Hash: {{hash}}
```

**npm 패키지 추가 사용:**
```bash
# 프로젝트에 패키지 설치 후 사용 가능
npm install chai
```

---

### 7.7. 실행 중단 ($cancel)

스크립트에서 조건에 따라 실행을 중단할 수 있다.

```http
{{
  // 조건이 맞지 않으면 요청 실행을 중단
  if (!process.env.API_KEY) {
    console.error("API_KEY 환경 변수가 설정되지 않았습니다!");
    exports.$cancel = true;
  }
}}

GET https://api.example.com/data
Authorization: Bearer {{$processEnv API_KEY}}
```

---

### 7.8. 디버깅

스크립트를 디버깅하는 방법:

1. httpyac CLI 전역 설치:
```bash
npm install -g httpyac
```

2. 스크립트에 `debugger;` 삽입:
```http
{{
  debugger;  // 여기서 브레이크포인트
  const data = response.parsedBody;
  exports.result = data.key;
}}
```

3. VS Code의 JavaScript Debug Terminal에서 실행:
```bash
httpyac my-request.http -l 5
```

---

## 8. Assert — 응답 검증

httpYac의 Assert 기능은 API 테스트 자동화의 핵심이다. `??` 기호로 시작한다.

### 8.1. 기본 문법 (??)

```
?? [대상] [조건] [예상값]
```

```http
GET https://httpbin.org/json

### 응답 검증
?? status == 200
?? header content-type includes json
?? body includes slideshow
?? duration < 5000
```

---

### 8.2. 조건 연산자 전체 목록

| 조건 | 별칭 | 설명 | 예시 |
|------|------|------|------|
| `==` | `equals` | 값이 동일 | `?? status == 200` |
| `!=` | | 값이 다름 | `?? status != 404` |
| `>` | | 초과 | `?? status > 199` |
| `>=` | | 이상 | `?? status >= 200` |
| `<` | | 미만 | `?? status < 300` |
| `<=` | | 이하 | `?? status <= 299` |
| `startsWith` | | ~로 시작 | `?? status startsWith 20` |
| `endsWith` | | ~로 끝남 | `?? status endsWith 00` |
| `includes` | `contains` | 포함 | `?? body includes "hello"` |
| `exists` | `isTrue` | 존재/참 | `?? header content-type exists` |
| `isFalse` | | 거짓 | `?? body error isFalse` |
| `isNumber` | | 숫자 타입 | `?? body count isNumber` |
| `isBoolean` | | 불린 타입 | `?? body active isBoolean` |
| `isString` | | 문자열 타입 | `?? header content-type isString` |
| `isArray` | | 배열 타입 | `?? body items isArray` |
| `matches` | | 정규표현식 | `?? status matches ^2\\d{2}` |
| `sha256` | | SHA256 해시 | `?? body sha256 abc123...` |
| `sha512` | | SHA512 해시 | `?? body sha512 def456...` |
| `md5` | | MD5 해시 | `?? body md5 789abc...` |

---

### 8.3. Status Assert

```http
GET https://httpbin.org/status/200

?? status == 200
?? status >= 200
?? status < 300
?? status matches ^2\\d{2}
?? status isNumber
```

---

### 8.4. Header Assert

```http
GET https://httpbin.org/json

?? header content-type == application/json
?? header content-type includes json
?? header content-type isString
?? header content-type exists
?? header x-custom-header isFalse
```

---

### 8.5. Body Assert (JSON 경로)

JSON 응답의 특정 필드를 검증할 수 있다.

```http
GET https://httpbin.org/json

# 전체 바디 검증
?? body includes slideshow

# JSON 필드 경로로 접근
?? body slideshow.author == Yours Truly
?? body slideshow.slides isArray
?? body slideshow.slides[0].title exists
?? body slideshow.date == date of publication
```

---

### 8.6. Duration Assert

응답 시간을 검증한다 (밀리초 단위).

```http
GET https://httpbin.org/json

?? duration < 2000
?? duration < 500
```

---

### 8.7. JavaScript Assert

복잡한 검증 로직을 JavaScript로 작성한다.

```http
GET https://httpbin.org/json

?? js response.parsedBody.slideshow.slides.length == 2
?? js response.parsedBody.slideshow.slides[0].title == Wake up to WonderWidgets!
?? js response.statusCode >= 200 && response.statusCode < 300
```

---

### 8.8. XPath Assert

XML 응답을 XPath로 검증한다.

```http
GET https://httpbin.org/xml

?? xpath /slideshow/@title == Sample Slide Show
?? xpath /slideshow/@author == Yours Truly
?? xpath //item/@id exists
```

---

### 8.9. 스크립트 기반 테스트 (test 함수)

더 복잡한 테스트를 `test()` 함수로 작성한다.

```http
GET https://httpbin.org/json

{{
  const { equal, ok } = require('assert');

  test('상태 코드가 200이어야 한다', () => {
    equal(response.statusCode, 200);
  });

  test('응답 바디에 slideshow가 있어야 한다', () => {
    ok(response.parsedBody.slideshow);
  });

  test('슬라이드가 2개여야 한다', () => {
    equal(response.parsedBody.slideshow.slides.length, 2);
  });
}}
```

**Chai 라이브러리 사용:**
```http
GET https://httpbin.org/json

{{
  const { expect } = require('chai');

  test('상태 코드 200', () => {
    expect(response.statusCode).to.equal(200);
  });

  test('JSON 응답 구조 검증', () => {
    expect(response.parsedBody).to.have.property('slideshow');
    expect(response.parsedBody.slideshow.slides).to.be.an('array');
    expect(response.parsedBody.slideshow.slides).to.have.lengthOf(2);
  });
}}
```

> **참고**: Chai를 사용하려면 `npm install chai` 필요.

---

### 8.10. 보조 테스트 메서드

빠른 검증을 위한 내장 헬퍼 메서드:

```http
GET https://httpbin.org/json

{{
  test.status(200);                                    // 상태 코드 검증
  test.totalTime(3000);                                // 응답 시간 상한
  test.header("content-type", "application/json");     // 헤더 정확히 일치
  test.headerContains("content-type", "json");         // 헤더 포함
  test.hasResponseBody();                              // 응답 바디 존재
  // test.hasNoResponseBody();                         // 응답 바디 없음
  // test.responseBody('{"exact": "match"}');           // 바디 정확히 일치
}}
```

---

## 9. 응답 처리 (Response)

### 9.1. 응답 문서화

HTTP 파일 내에서 예상 응답을 문서화할 수 있다. `HTTP/버전`으로 시작하면 응답으로 해석된다.

```http
GET https://httpbin.org/json

HTTP/1.1 200 OK
date: Mon, 21 Jun 2021 19:38:05 GMT
content-type: application/json

{
  "slideshow": {
    "author": "Yours Truly",
    "title": "Sample Slide Show"
  }
}
```

> **참고**: 이 응답 문서는 httpBook 표시 용도로만 사용되며, 실제 실행에는 영향 없다.

---

### 9.2. 출력 리다이렉트 (파일 저장)

응답 본문을 파일로 저장할 수 있다.

```http
### 새 파일로 저장 (파일 존재 시 -1, -2 등 접미사 추가)
GET https://httpbin.org/json

>> ./responses/output.json

### 기존 파일 덮어쓰기
GET https://httpbin.org/json

>>! ./responses/output.json
```

| 연산자 | 동작 |
|--------|------|
| `>>` | 새 파일 생성, 기존 파일 있으면 `-n` 접미사 추가 |
| `>>!` | 기존 파일 덮어쓰기 |

---

## 10. 인증 (Authentication)

### 10.1. Basic Authentication

사용자명과 비밀번호를 자동 Base64 인코딩한다.

```http
@user=myuser
@password=mypassword123

GET https://httpbin.org/basic-auth/{{user}}/{{password}}
Authorization: Basic {{user}} {{password}}
```

**사용자명에 공백이 있는 경우 (콜론 구분):**
```http
@user=john doe
@password=mypassword

GET https://httpbin.org/basic-auth/john/{{password}}
Authorization: Basic {{user}}:{{password}}
```

---

### 10.2. Digest Authentication

```http
@user=myuser
@password=mypassword

GET https://httpbin.org/digest-auth/auth/{{user}}/{{password}}
Authorization: Digest {{user}} {{password}}
```

---

### 10.3. OAuth2 / OpenID Connect

httpYac의 가장 강력한 인증 기능. 다양한 OAuth2 플로우를 지원한다.

#### 지원 플로우

| 플로우 | grant_type | 문법 |
|--------|-----------|------|
| Client Credentials | `client_credentials` | `Authorization: openid` |
| Authorization Code | `authorization_code` | `Authorization: oauth2 code` |
| Auth Code + PKCE | `authorization_code` + PKCE | `Authorization: oauth2 code pkce` |
| Implicit | `implicit` | `Authorization: oauth2 implicit` |
| Password | `password` | `Authorization: oauth2 password` |
| Device Code | `device_code` | `Authorization: oauth2 device_code` |

#### 환경 변수 설정 (.env)

```bash
# .env.dev
oauth2_tokenEndpoint=http://localhost:8080/realms/master/protocol/openid-connect/token
oauth2_authorizationEndpoint=http://localhost:8080/realms/master/protocol/openid-connect/auth
oauth2_clientId=my-app
oauth2_clientSecret=my-secret-key
oauth2_scope=openid profile email
oauth2_username=testuser
oauth2_password=testpass
```

#### 사용 예시

```http
### Client Credentials Flow (기본)
GET https://api.example.com/protected
Authorization: openid

### Authorization Code Flow
GET https://api.example.com/protected
Authorization: oauth2 code

### PKCE Flow
GET https://api.example.com/protected
Authorization: oauth2 code pkce

### Password Flow
GET https://api.example.com/protected
Authorization: oauth2 password

### Custom Prefix (여러 OAuth2 서버 사용 시)
GET https://api.example.com/protected
Authorization: openid client_credentials keycloak
```

**Custom Prefix 사용 시 환경 변수:**
```bash
# keycloak 접두사를 사용하면 keycloak_* 변수를 찾음
keycloak_tokenEndpoint=http://localhost:8080/auth/realms/test/protocol/openid-connect/token
keycloak_clientId=my-app
keycloak_clientSecret=my-secret
keycloak_scope=openid profile
```

---

### 10.4. AWS Signature v4

```http
@accessId=AKIAIOSFODNN7EXAMPLE
@accessKey=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
@region=ap-northeast-2
@service=execute-api

GET https://api.example.com/data
Authorization: AWS {{accessId}} {{accessKey}} region:{{region}} service:{{service}}
```

**임시 토큰 포함:**
```http
GET https://api.example.com/data
Authorization: AWS {{accessId}} {{accessKey}} token:{{sessionToken}} region:{{region}} service:{{service}}
```

---

### 10.5. SSL 클라이언트 인증서

**설정 파일로 지정:**

```json
// .httpyac.json 또는 settings.json
{
  "clientCertificates": {
    "api.example.com": {
      "cert": "./certs/client.crt",
      "key": "./certs/client.key"
    },
    "secure.example.com": {
      "pfx": "./certs/client.p12",
      "passphrase": "my-password"
    }
  }
}
```

**헤더로 직접 지정:**
```http
GET https://api.example.com/secure
ClientCert: pfx: ./certs/client.p12 passphrase: my-password
```

---

## 11. 고급 요청 타입

### 11.1. GraphQL

```http
### 기본 GraphQL 쿼리
POST https://countries.trevorblades.com/graphql
Content-Type: application/json

query Continents($code: String!) {
  continents(filter: { code: { eq: $code } }) {
    code
    name
  }
}

{
  "code": "EU"
}
```

**Fragment 사용:**
```http
fragment ContinentParts on Continent {
  code
  name
}

POST https://countries.trevorblades.com/graphql
Content-Type: application/json

query Continents {
  continents {
    ...ContinentParts
  }
}
```

**외부 .gql 파일 임포트:**
```http
POST https://countries.trevorblades.com/graphql
Content-Type: application/json

gql Continents < ./queries/continents.gql

{
  "code": "EU"
}
```

---

### 11.2. gRPC

Proto 파일을 로드하고 `GRPC` 메서드로 호출한다.

```http
### Proto 파일 로드
proto < ./protos/hello.proto

### Unary RPC
GRPC grpc.example.com/HelloService/SayHello

{
  "greeting": "world"
}
```

**형식**: `GRPC 서버주소/서비스명/메서드명`

**TLS 보안 연결:**
```http
proto < ./hello.proto

{{@request
  const grpc = require('@grpc/grpc-js');
  request.channelCredentials = grpc.ChannelCredentials.createSsl();
}}
GRPC grpc.example.com/HelloService/SayHello

{
  "greeting": "world"
}
```

**Server Streaming:**
```http
proto < ./hello.proto

GRPC grpc.example.com/HelloService/LotsOfReplies

{
  "greeting": "world"
}
```

**Client Streaming:**
```http
proto < ./hello.proto

GRPC grpc.example.com/HelloService/LotsOfGreetings

{
  "greeting": "첫 번째"
}

{{@streaming
  async function writeStream() {
    await sleep(1000);
    await $requestClient.send({ greeting: '두 번째' });
    await sleep(1000);
    await $requestClient.send({ greeting: '세 번째' });
  }
  exports.waitPromise = writeStream();
}}
```

**Bidirectional Streaming:**
```http
proto < ./hello.proto

GRPC grpc.example.com/HelloService/BidiHello

{
  "greeting": "시작"
}
===
{
  "greeting": "두 번째"
}
=== wait-for-server
=== wait-for-server
{
  "greeting": "마지막"
}
```

**gRPC Reflection (proto 파일 없이):**
```http
# @grpc-reflection
GRPC grpc.example.com/HelloService/SayHello

{
  "greeting": "world"
}
```

---

### 11.3. WebSocket

`WS` 메서드로 WebSocket 연결을 열고 메시지를 주고받는다.

```http
WS wss://echo.websocket.org/

{
  "type": "hello",
  "message": "httpYac에서 보냅니다"
}

{{@streaming
  async function communicate() {
    // 서버 응답 대기
    await sleep(2000);

    // 추가 메시지 전송
    $requestClient.send({
      type: "ping",
      timestamp: Date.now()
    });

    await sleep(3000);

    $requestClient.send({
      type: "goodbye",
      message: "종료합니다"
    });

    await sleep(1000);
  }
  exports.waitPromise = communicate();
}}
```

**연결 유지:**
```http
# @keepStreaming
WS wss://echo.websocket.org/

{
  "type": "subscribe",
  "channel": "updates"
}
```

---

### 11.4. Server-Sent Events (SSE)

서버에서 이벤트를 지속적으로 수신한다.

```http
SSE https://example.com/events
Event: message

{{@streaming
  async function listenEvents() {
    await sleep(30000);  // 30초 동안 이벤트 수신
  }
  exports.waitPromise = listenEvents();
}}
```

**지속 연결:**
```http
# @keepStreaming
SSE https://example.com/events
```

---

### 11.5. MQTT

**메시지 발행 (Publish):**
```http
MQTT tcp://broker.hivemq.com
Topic: my-app/notifications

{
  "type": "alert",
  "message": "새 알림이 있습니다"
}
```

**토픽 구독 (Subscribe):**
```http
# @keepStreaming
MQTT tcp://broker.hivemq.com
subscribe: my-app/notifications
```

**인증 옵션:**
```http
MQTT tcp://broker.example.com
Topic: secure-topic
Qos: 1
username: mqttuser
password: mqttpass
retain: true
keepAlive: 60

{
  "data": "secure message"
}
```

---

### 11.6. AMQP / RabbitMQ

**메시지 발행:**
```http
AMQP amqp://guest:guest@localhost
amqp_exchange: my_exchange
amqp_routing_key: my.route

{
  "order_id": "{{$uuid}}",
  "status": "created"
}
```

**큐 직접 발행:**
```http
AMQP amqp://guest:guest@localhost
amqp_queue: my_queue

{
  "task": "process_order"
}
```

**메시지 소비 (구독):**
```http
# @keepStreaming
AMQP amqp://guest:guest@localhost
amqp_method: consume
amqp_queue: my_queue
```

**Exchange/Queue 선언:**
```http
### Exchange 선언
AMQP amqp://guest:guest@localhost
amqp_method: declare
amqp_exchange: my_exchange

### Queue 선언 및 바인딩
AMQP amqp://guest:guest@localhost
amqp_method: declare
amqp_queue: my_queue

###
AMQP amqp://guest:guest@localhost
amqp_method: bind
amqp_exchange: my_exchange
amqp_queue: my_queue
amqp_routing_key: my.route
```

---

## 12. Hooks (플러그인)

httpYac은 플러그인 기반 아키텍처를 사용한다. `httpyac.config.js` 파일에서 Hook을 설정할 수 있다.

```javascript
// httpyac.config.js (프로젝트 루트)
module.exports = {
  configureHooks: function(api) {
    // 응답 로깅 시 민감한 헤더 제거
    api.hooks.responseLogging.addHook('removeSensitiveData', function(response) {
      if (response.request) {
        delete response.request.headers['authorization'];
        delete response.request.headers['cookie'];
      }
    });

    // 모든 요청에 커스텀 헤더 추가
    api.hooks.onRequest.addHook('addTraceId', function(request) {
      const { v4: uuidv4 } = require('uuid');
      request.headers['X-Trace-Id'] = uuidv4();
    });
  }
};
```

---

## 13. Injected Languages

httpYac는 `.http` 파일 외에도 다른 파일 형식에서 HTTP 요청 블록을 인식할 수 있다.

### Markdown

````markdown
# API 문서

아래 요청으로 사용자 목록을 가져올 수 있습니다:

```http
GET https://api.example.com/users
Authorization: Bearer {{token}}
```
````

### Asciidoctor

```asciidoc
[source,http]
----
GET https://api.example.com/users
Authorization: Bearer {{token}}
----
```

---

## 14. 실전 예제: API 테스트 워크플로우

전체 API 테스트 워크플로우를 하나의 파일로 구성하는 예제:

```http
# =============================================
# 필고 API 테스트 워크플로우
# =============================================

@host=https://local.philgo.com

# === 글로벌: 공통 헤더 ===
{{+
  exports.defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };
}}

###
# -----------------------------------------
# Step 1: 로그인하여 세션 획득
# -----------------------------------------
# @name loginResult
POST {{host}}/api.php
...defaultHeaders

{
  "method": "user.login",
  "email": "banana@test.com",
  "password": "12345a,*"
}

?? status == 200
?? body error isFalse

{{
  // 로그인 성공 시 세션 정보를 글로벌 변수에 저장
  if (response.parsedBody && !response.parsedBody.error) {
    $global.sessionId = response.parsedBody.session_id;
    console.info("로그인 성공! 세션: " + $global.sessionId);
  }
}}

###
# -----------------------------------------
# Step 2: 이벤트 스핀 실행
# -----------------------------------------
# @forceRef loginResult
# @name spinResult
POST {{host}}/api.php
...defaultHeaders

{
  "method": "event.spin",
  "session_id": "{{$global.sessionId}}"
}

?? status == 200

{{
  const data = response.parsedBody;
  test('스핀 결과가 존재해야 한다', () => {
    const { ok } = require('assert');
    ok(data.section_index !== undefined);
  });

  test('포인트가 0 이상이어야 한다', () => {
    const { ok } = require('assert');
    ok(data.reward_point >= 0);
  });

  console.info("스핀 결과: " + JSON.stringify(data));
}}

###
# -----------------------------------------
# Step 3: 스핀 히스토리 조회
# -----------------------------------------
# @ref loginResult
POST {{host}}/api.php
...defaultHeaders

{
  "method": "event.history",
  "session_id": "{{$global.sessionId}}",
  "page": 1,
  "limit": 10
}

?? status == 200
?? body isArray

{{
  test('히스토리가 배열이어야 한다', () => {
    const { ok } = require('assert');
    ok(Array.isArray(response.parsedBody));
  });

  console.info("히스토리 개수: " + response.parsedBody.length);
}}
```

---

## 15. REST Client vs httpYac 비교

| 기능 | REST Client | httpYac |
|------|-------------|---------|
| `.http` 파일 지원 | O | O (완벽 호환) |
| 환경 변수 | settings.json | .env, JSON, IntelliJ |
| JavaScript 스크립팅 | X | O (NodeJS) |
| 응답 검증 (Assert) | X | O (`??` 문법) |
| 변수 체이닝 | 제한적 | O (`@name`, `@ref`) |
| CLI 실행 | X | O (`httpyac` CLI) |
| CI/CD 연동 | X | O |
| GraphQL | O | O |
| gRPC | X | O |
| WebSocket | X | O |
| MQTT | X | O |
| SSE | X | O |
| AMQP | X | O |
| OAuth2 자동 | X | O (6개 플로우) |
| 반복 실행 (@loop) | X | O |
| 요청 참조 (@ref) | X | O |
| CookieJar | X | O |
| 속도 제한 | X | O |
| 플러그인/Hook | X | O |
| 파일 저장 (>>) | O | O |
| IntelliJ 호환 | 부분 | 거의 완벽 |
| 학습 곡선 | 낮음 | 중간 |
| VS Code 사용자 수 | 매우 많음 | 적음 |

---

## 16. 팁과 베스트 프랙티스

### 파일 구조 권장

```
project/
├── .env                          # 공통 환경 변수
├── .env.dev                      # 개발 환경
├── .env.staging                  # 스테이징 환경
├── .env.prod                     # 프로덕션 환경
├── .httpyac.js                   # httpYac 설정 (Hook 등)
├── http/                         # HTTP 요청 파일 폴더
│   ├── _shared/
│   │   └── auth.http             # 인증 관련 (@name login 등)
│   ├── users/
│   │   ├── create-user.http
│   │   ├── get-user.http
│   │   ├── update-user.http
│   │   └── delete-user.http
│   ├── posts/
│   │   ├── create-post.http
│   │   ├── list-posts.http
│   │   └── get-post.http
│   └── events/
│       ├── spin.http
│       └── history.http
```

### 팁 1: 요청당 하나의 파일

```http
# http/users/create-user.http
# 사용자 생성 API

@host=https://local.philgo.com

# @import ../_shared/auth.http
# @ref login

POST {{host}}/api.php
Content-Type: application/json

{
  "method": "user.create",
  "session_id": "{{login.session_id}}",
  "name": "새 사용자",
  "email": "new@example.com"
}

?? status == 200
```

### 팁 2: 환경별 Host 전환

```bash
# .env.dev
host=https://local.philgo.com

# .env.staging
host=https://staging.philgo.com

# .env.prod
host=https://www.philgo.com
```

```http
# host 변수가 환경에 따라 자동 전환됨
GET /api.php?method=user.profile
```

### 팁 3: CI/CD에서 자동 테스트

```bash
# CLI로 모든 요청 실행 및 Assert 검증
httpyac http/**/*.http --all -e dev

# 특정 파일만 실행
httpyac http/users/create-user.http -e dev

# 특정 요청만 실행 (라인 번호)
httpyac http/users/create-user.http -l 5 -e dev
```

### 팁 4: 응답값 체이닝 패턴

```http
### Step 1: 글 생성 → 글 번호 획득
# @name createPost
POST https://api.example.com/posts
Content-Type: application/json

{"title": "테스트 글", "content": "내용"}

###
### Step 2: 생성된 글 조회 (자동 체이닝)
# @ref createPost
GET https://api.example.com/posts/{{createPost.id}}

?? status == 200
?? body title == 테스트 글

###
### Step 3: 글 삭제
# @ref createPost
DELETE https://api.example.com/posts/{{createPost.id}}

?? status == 200
```

### 팁 5: 민감 정보 관리

```bash
# .gitignore에 추가
.env.local
.env.*.local
http-client.private.env.json
```

```bash
# .env.local (git에서 제외)
API_KEY=실제_비밀_키
DB_PASSWORD=실제_비밀번호
```

---

## 부록: 자주 사용하는 패턴 Quick Reference

```http
# ── 변수 정의 ──
@host=https://api.example.com
@token=my-secret-token
@dynamicTime:={{new Date().toISOString()}}

# ── 기본 GET ──
GET {{host}}/users?page=1
Authorization: Bearer {{token}}

?? status == 200

# ── POST JSON ──
###
POST {{host}}/users
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "name": "홍길동",
  "email": "hong@example.com"
}

?? status == 201
?? body id isNumber

# ── 파일 업로드 ──
###
POST {{host}}/upload
Content-Type: multipart/form-data; boundary=----Boundary

------Boundary
Content-Disposition: form-data; name="file"; filename="photo.jpg"
Content-Type: image/jpeg

< ./photo.jpg
------Boundary--

# ── 응답 저장 ──
###
GET {{host}}/export/data

>>! ./responses/export.json

# ── 반복 실행 ──
###
# @loop for 3
GET {{host}}/health?check={{$index}}

?? status == 200

# ── 응답값 체이닝 ──
###
# @name auth
POST {{host}}/login
Content-Type: application/json

{"email": "test@test.com", "password": "1234"}

###
# @forceRef auth
GET {{host}}/profile
Authorization: Bearer {{auth.token}}
```

---

## 17. Bruno vs httpYac — 실전 비교 (테크톡 기반)

> 아래 내용은 실무 QA 엔지니어의 기술 세미나에서 추출한 실전 경험이다.

### 탄생 배경

2023년 5월 Postman이 무료 Scratch Pad 모드(로컬 컬렉션)를 폐지하면서, 많은 팀이 대안을 찾기 시작했다. 주요 대안으로 Bruno와 httpYac이 부상했다.

### HTTP 파일 포맷의 역사

| 연도 | 사건 |
|------|------|
| 2017 | **REST Client** (VS Code 확장) 등장 — `.http` 파일 포맷 제안 |
| 2019 | **JetBrains HTTP Client** — `.http` 포맷 채택 + 스크립팅/테스팅 추가 |
| 2020 | **httpYac** 등장 — REST Client + JetBrains 클라이언트의 상위 집합 |
| 2022 | **Microsoft Visual Studio 2022** — `.http` 파일 네이티브 지원 |

> httpYac 제작자 Andreas Weber: "REST Client와 JetBrains HTTP Client 양쪽의 상위 집합(superset)을 만들어, IDE 없이도 확장 가능하게 하려고 httpYac을 2020년에 만들었다."

### 인기도 (GitHub Stars)

| 도구 | Stars | 비고 |
|------|-------|------|
| Bruno | ~27,000+ | Postman 가격 정책 변경 후 폭발적 성장 (500 → 27,000) |
| httpYac | ~500 | 인지도는 낮지만 기능은 가장 풍부 |

> Bruno가 50배 더 인기 있지만, httpYac이 기능적으로는 더 강력하다.

### 대상 사용자 차이

| 상황 | Bruno 추천 | httpYac 추천 |
|------|-----------|-------------|
| Postman 경험자, 코딩 비전문가 | O | |
| 깔끔한 GUI 선호 | O | |
| VS Code 중심 개발자 | | O |
| 코드와 테스트를 한 IDE에서 관리 | | O |
| Data-driven 테스트 (무료) | | O (Bruno는 유료 기능) |
| CI/CD 자동화 | O | O |
| gRPC, WebSocket, MQTT 지원 | | O |

### Postman → httpYac 마이그레이션 팁

세미나 발표자의 실전 경험:

1. **Postman의 JSON 구조를 httpYac `.http` 파일로 변환**해야 한다
2. **AI(LLM) 활용 추천**: 발표자는 AI에 httpYac 문서를 프롬프트에 포함시키고, Postman JSON을 붙여넣어 `.http` 파일로 변환했다
3. **httpYac 문서가 잘 되어 있어** AI가 자동으로 정확한 httpYac 테스트를 생성한다고 한다
4. Bruno는 문서가 상대적으로 부족해 프롬프트에 문서 내용을 직접 포함시켜야 했다

### CI/CD 실전 설정

**package.json 설정:**
```json
{
  "devDependencies": {
    "httpyac": "latest"
  },
  "scripts": {
    "test": "httpyac http/**/*.http --all -e dev",
    "test:ci": "httpyac http/**/*.http --all -e ci --output-format junit"
  }
}
```

**GitHub Actions 워크플로우:**
```yaml
name: API Tests
on: [push, pull_request]

jobs:
  api-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm install
      - run: npm run test:ci
      - uses: dorny/test-reporter@v1
        if: always()
        with:
          name: httpYac Test Results
          path: 'test-results/*.xml'
          reporter: java-junit
```

> **핵심**: httpYac CLI는 JUnit 5 XML 형식으로 결과를 출력할 수 있어, Allure Report, Report Portal 등 모든 표준 보고 도구와 호환된다.

### 결론: 어떤 도구를 선택할 것인가?

| 시나리오 | 추천 도구 |
|----------|-----------|
| 팀에 비개발자 QA가 포함 | **Bruno** (직관적 GUI) |
| 개발자 중심 팀, VS Code 사용 | **httpYac** (코드 통합) |
| 무료 Data-driven 테스트 필요 | **httpYac** |
| gRPC, WebSocket, MQTT API 테스트 | **httpYac** |
| Postman에서 빠른 마이그레이션 | **Bruno** (Postman Import 기능 내장) |
| CI/CD 자동화 | 둘 다 가능 (CLI 제공) |
| 로컬 파일 기반, Git 연동 | 둘 다 가능 |

> 두 도구 모두 뛰어난 엔지니어들이 만든 훌륭한 도구이다. 자신의 팀 구성과 워크플로우에 맞는 것을 선택하면 된다.

---

> **참고 문서:**
> - 공식 사이트: https://httpyac.github.io
> - GitHub: https://github.com/AnWeber/httpyac
> - VS Code 확장: https://github.com/AnWeber/vscode-httpyac

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
