# httpYac 가이드 — 실전 예제, 비교 & 베스트 프랙티스

> 메인 문서: [yac.md](yac.md)

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
