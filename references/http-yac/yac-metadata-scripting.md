# httpYac 가이드 — 메타데이터 & 스크립팅

> 메인 문서: [yac.md](../httpYac/yac.md)

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
