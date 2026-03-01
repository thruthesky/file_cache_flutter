# httpYac 가이드 — 변수 시스템 & 환경 설정

> 메인 문서: [yac.md](yac.md)

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
