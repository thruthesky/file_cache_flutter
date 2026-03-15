# AI 모듈 API 문서

## 개요

Gemini API를 활용한 콘텐츠 검열, 텍스트 생성, 영수증 분석 모듈이다.
기존 레거시 검열 코드(`lib/moderate/gemini-moderate-api.php`)를 v7 Controller+Service 아키텍처로 재구현한 것이다.

### 영수증 진위 판별 API 상세 → [v7-ai-receipt.md](v7-ai-receipt.md)

클라이언트(웹/앱)가 영수증 이미지를 업로드하면 Gemini AI가 진짜/가짜를 판별하는
`ai.analyzeReceipt` API의 상세 사용법을 다룬다. **필리핀에서 발행된 영수증만
`is_authentic=true`로 인정하며**, 한국·미국·일본 등 타국 영수증은 무조건
`is_authentic=false`로 거부하고 `suspicious_reasons`에 "필리핀 국가에서 발행한
영수증이 아닙니다"를 추가한다. `POST multipart/form-data`로 `session_id` 또는
`id_token` 인증과 함께 영수증 이미지(`file`)를 전달하면, 내부적으로 WebP 변환 및
1000px 썸네일을 생성하고 base64 인코딩 후 `gemini-2.5-flash-lite` 모델에 필리핀
발행 검증 + 6가지 검증 카테고리(물리적 특성, 폰트/레이아웃, 금액/수치, 이미지 조작,
형식/일관성, 디지털 생성 패턴)로 진위를 판별한다. CoT/ToT 분석 기반 판별 로직,
클라이언트 통합 코드(JavaScript/Flutter), 에러 처리, CURL/PEST 테스트 가이드,
핵심 소스코드를 포함한다.

## 목차

- [파일 구조](#파일-구조)
- [API 엔드포인트](#api-엔드포인트)
  - [ai.moderate - 텍스트 검열](#aimoderate---텍스트-검열)
  - [ai.generate - 텍스트 생성](#aigenerate---텍스트-생성)
  - [ai.analyzeReceipt - 영수증 분석 (인증 필수)](#aianalyzereceipt---영수증-분석-인증-필수)
  - [ai.generateStream - AI 답변 SSE 스트리밍](#aigeneratestream---ai-답변-sse-스트리밍)
  - [ai.saveAnswer - AI 답변 저장](#aisaveanswer---ai-답변-저장)
  - [ai-api.php 전용 엔트리포인트](#ai-apiphp-전용-엔트리포인트)
- [인증 방식](#인증-방식)
- [Entity 구조](#entity-구조)
  - [ModerationEntity](#moderationentity)
  - [GenerateEntity](#generateentity)
  - [ReceiptEntity](#receiptentity)
- [GeminiClient](#geminiclient)
- [핵심 소스코드](#핵심-소스코드)
  - [AiController 핵심 코드](#aicontroller-핵심-코드)
  - [AiService 핵심 코드](#aiservice-핵심-코드)
  - [GeminiClient 핵심 코드](#geminiclient-핵심-코드)
  - [ReceiptEntity 핵심 코드](#receiptentity-핵심-코드)
- [검열 정책](#검열-정책)
- [테스트](#테스트)

---

## 파일 구조

```
lib/ai/
├── AiController.php       # API 엔드포인트 (method=ai.*)
├── AiService.php          # 비즈니스 로직 (Gemini API 호출)
├── GeminiClient.php       # Gemini REST API cURL 클라이언트
├── ModerationEntity.php   # 검열 결과 Entity (POPO)
├── GenerateEntity.php     # 텍스트 생성 결과 Entity (POPO)
└── ReceiptEntity.php      # 영수증 분석 결과 Entity (POPO)

ai-api.php                 # AI 전용 엔트리포인트 (api.php require 래퍼)
```

| 클래스 | 네임스페이스 | 역할 |
|--------|-------------|------|
| `AiController` | `Philgo\Ai` | API 엔드포인트 |
| `AiService` | `Philgo\Ai` | 비즈니스 로직 |
| `GeminiClient` | `Philgo\Ai` | Gemini API cURL 호출 |
| `ModerationEntity` | `Philgo\Ai` | 검열 결과 데이터 구조체 |
| `GenerateEntity` | `Philgo\Ai` | 텍스트 생성 결과 데이터 구조체 |
| `ReceiptEntity` | `Philgo\Ai` | 영수증 분석 결과 데이터 구조체 |

---

## API 엔드포인트

### ai.moderate - 텍스트 검열

Gemini API를 사용하여 텍스트 콘텐츠를 검열한다. 인증 불필요.

**요청:**

```
GET /api.php?method=ai.moderate&text=검열할텍스트

POST /api.php
Content-Type: application/json
{"method": "ai.moderate", "text": "검열할 텍스트"}
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `text` | string | ✅ | 검열할 텍스트 |

**응답 (성공):**

```json
{
    "flagged": false,
    "insult": false,
    "sexually_explicit": false,
    "selling": false,
    "job": false,
    "news": false,
    "seek": false,
    "gambling": false,
    "exchange": false,
    "spam": false,
    "contact": false,
    "info_score": 45,
    "wrong_job_description": false,
    "is_job_pass": true,
    "reasons": {},
    "is_advertisement": false,
    "is_job": false,
    "is_exchange": false,
    "is_gambling": false,
    "is_news": false
}
```

**curl 예시:**

```bash
# GET 방식
curl -k "https://local.philgo.com/api.php?method=ai.moderate&text=안녕하세요"

# POST 방식
curl -k -X POST https://local.philgo.com/api.php \
  -H "Content-Type: application/json" \
  -d '{"method":"ai.moderate","text":"안녕하세요. 오늘 날씨가 좋네요."}'
```

---

### ai.generate - 텍스트 생성

Gemini API를 사용하여 텍스트를 생성한다. 인증 불필요.

**요청:**

```
GET /api.php?method=ai.generate&prompt=질문&system_instruction=역할

POST /api.php
Content-Type: application/json
{"method": "ai.generate", "prompt": "필리핀 날씨", "system_instruction": "필리핀 전문가"}
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `prompt` | string | ✅ | 사용자 프롬프트 |
| `system_instruction` | string | ❌ | 시스템 프롬프트 (기본값: "당신은 유용한 도우미입니다. 한국어로 답변하세요.") |

**응답 (성공):**

```json
{
    "text": "필리핀은 열대성 기후로...",
    "model": "gemini-3-flash-preview",
    "created_at": 1709876543
}
```

**curl 예시:**

```bash
curl -k -X POST https://local.philgo.com/api.php \
  -H "Content-Type: application/json" \
  -d '{"method":"ai.generate","prompt":"필리핀 마닐라의 날씨를 알려주세요","system_instruction":"필리핀 전문 여행 가이드"}'
```

---

### ai.analyzeReceipt - 영수증 분석 (인증 필수)

영수증 이미지를 업로드하면 Gemini AI가 영수증 진위 여부를 판별하고 정보를 추출한다.

**⚠️ 인증 필수**: Firebase ID Token(`id_token`) 또는 세션 ID(`session_id`)로 사용자 인증이 필요하다. `idx_member`를 직접 전달하지 않으며, 인증된 사용자의 idx가 자동으로 사용된다.

**처리 흐름:**
1. `AuthService::getLoginUser()`로 인증 확인 (미인증 시 RuntimeException)
2. 인증된 사용자의 idx를 `idx_member`에 자동 설정
3. `UploadService::store()`로 이미지 업로드 (자동으로 1000px 썸네일 생성)
4. `1000-{baseName}.webp` 썸네일 파일을 base64 인코딩
5. `GeminiClient::generateJsonWithImage()`로 Gemini API 호출 (모델: `gemini-2.5-flash-lite-preview-09-2025`)
6. 영수증이 아니면 에러 반환, 영수증이면 분석 결과 반환

**요청:**

```
POST /api.php (multipart/form-data)
- method: ai.analyzeReceipt
- session_id: 세션 ID (인증 경로 1) — 또는
- id_token: Firebase ID Token (인증 경로 2)
- file: 영수증 이미지 파일 (필수)
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `session_id` | string | ✅* | 세션 ID (인증 경로 1) |
| `id_token` | string | ✅* | Firebase ID Token (인증 경로 2) |
| `file` | file | ✅ | 영수증 이미지 파일 (multipart/form-data) |
| `company_idx` | int | ❌ | 업소 번호. 전달 시 영수증의 store_name과 업소명/영수증 표시 이름(receipt_name) 일치 여부를 검증 |

> \* `session_id` 또는 `id_token` 중 하나가 반드시 필요하다.
> `company_idx`는 선택이며, 전달 시 해당 업소의 이름 또는 영수증 표시 이름과 영수증의 상점명이 일치하는지 추가 검증한다. 불일치 시 `is_authentic=false`, `company_name_matched=false`.

**응답 (성공 - 진짜 영수증):**

```json
{
    "is_receipt": true,
    "is_authentic": true,
    "store_name": "세븐일레븐",
    "date": "2025-01-15",
    "total_amount": "₱350.00",
    "currency": "PHP",
    "items": [
        {"name": "커피", "price": "₱150.00"},
        {"name": "샌드위치", "price": "₱200.00"}
    ],
    "payment_method": "현금",
    "receipt_type": "POS 영수증",
    "summary": "세븐일레븐에서 커피와 샌드위치 구매",
    "suspicious_reasons": [],
    "confidence_score": 95,
    "upload_idx": 12345,
    "company_name_matched": null
}
```

**응답 (에러 - 미인증):**

```json
{
    "success": false,
    "message": "로그인이 필요합니다. id_token 또는 session_id를 전달해주세요."
}
```

**응답 (에러 - 영수증이 아닌 이미지):**

```json
{
    "success": false,
    "message": "이미지가 영수증이 아닙니다."
}
```

**curl 예시 (session_id 인증):**

```bash
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "session_id=abc123hash-190076" \
  -F "file=@/path/to/receipt.jpg"
```

**curl 예시 (Firebase ID Token 인증):**

```bash
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "id_token=eyJhbGciOiJSUzI1NiIs..." \
  -F "file=@/path/to/receipt.jpg"
```

---

### ai.generateStream - AI 답변 SSE 스트리밍

qna/freetalk 게시판의 글에 대해 Gemini AI가 실시간 SSE 스트리밍으로 답변을 생성한다.

**⛔ 반드시 `/ai-api.php`를 통해 호출해야 한다. `/api.php`로 호출하면 에러 발생.**

**요청:**

```
POST /ai-api.php
Content-Type: application/x-www-form-urlencoded
method=ai.generateStream&prompt=질문내용&post_idx=12345&model=gemini-3.1-flash-lite-preview
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `prompt` | string | ✅ | 질문/프롬프트 |
| `model` | string | ❌ | 모델명. 기본: gemini-3.1-flash-lite-preview. 대안: gemini-2.5-flash-lite |
| `post_idx` | int | ❌ | 글 번호. 전달 시 게시판(qna/freetalk만) + 중복 방지 검증 |

**응답:** `Content-Type: text/event-stream` (SSE)

```
data: {"candidates":[{"content":{"parts":[{"text":"안녕"}]}}]}

data: {"candidates":[{"content":{"parts":[{"text":"하세요"}]}}]}
```

**curl 예시:**

```bash
curl -sk "https://v7-local.philgo.com/ai-api.php" \
  -d "method=ai.generateStream&prompt=필리핀날씨&post_idx=12345"
```

**내부 흐름:**

```
AiController::generateStream()
  → enforceAiApiEndpoint() (ai-api.php 경로 체크)
  → SSE 헤더 설정 (text/event-stream, X-Accel-Buffering: no)
  → AiService::generateStream()
    → 모델 화이트리스트 검증
    → 게시판 검증 (qna/freetalk만)
    → 중복 방지 (text_7 이미 있으면 거부)
    → GeminiClient::generateContentStream()
      → cURL WRITEFUNCTION 콜백으로 청크 즉시 전달
      → streamGenerateContent?alt=sse 엔드포인트
  → exit (api.php의 JSON 응답 우회)
```

---

### ai.saveAnswer - AI 답변 저장

AI 답변을 sf_post_data.text_7 필드에 저장한다. v6의 update_other_post()와 동일한 역할.

**⛔ 반드시 `/ai-api.php`를 통해 호출해야 한다.**

**요청:**

```
POST /ai-api.php
Content-Type: application/x-www-form-urlencoded
method=ai.saveAnswer&idx=12345&text_7=AI답변내용
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `idx` | int | ✅ | 글 번호 |
| `text_7` | string | ✅ | AI 답변 내용 (마크다운) |

**응답 (성공):**

```json
{"idx": 12345}
```

**응답 (에러):**

```json
{"success": false, "message": "이미 AI 답변이 존재합니다."}
```

**검증:**

- 글 존재 여부
- 게시판 검증 (qna/freetalk만)
- 코멘트 거부 (idx_parent > 0)
- 중복 방지 (text_7 이미 있으면 거부)

---

### ai-api.php 전용 엔트리포인트

모든 AI API 호출은 `/ai-api.php`를 통해야 한다. 이 파일은 `api.php`를 그대로 require하는 래퍼이며, Nginx에서 AI 전용 PHP-FPM 풀(포트 9001)로 분기된다.

```php
// ai-api.php
require __DIR__ . '/api.php';
```

AiController의 모든 메서드에서 `enforceAiApiEndpoint()`를 호출하여 `$_SERVER['SCRIPT_NAME']`이 `ai-api.php`인지 체크한다. `/api.php`로 직접 호출하면 RuntimeException.

**Nginx 설정:**

```nginx
location = /ai-api.php {
    fastcgi_pass php:9001;       # AI 전용 FPM 풀
    fastcgi_buffering off;        # SSE 스트리밍 필수
    fastcgi_read_timeout 120;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

---

## 인증 방식

영수증 분석 API(`ai.analyzeReceipt`)는 사용자 인증이 필수이다. v7 시스템은 `AuthService::getLoginUser()`를 통해 2가지 경로로 인증한다.

### 인증 경로 1: session_id (SSR/CURL용)

세션 ID는 `{MD5해시}-{사용자idx}` 형식이다.

```
파라미터: session_id=abc123hash-190076
또는 쿠키: Cookie: session_id=abc123hash-190076
```

검증 흐름:
1. session_id에서 idx 추출
2. DB에서 sf_member 조회
3. 해시 검증 (md5(LOGIN_SALT + idx + firebase_uid + phone_number))

### 인증 경로 2: id_token (API/앱용)

Firebase Authentication에서 발급한 ID Token을 전달한다.

```
파라미터: id_token=eyJhbGciOiJSUzI1NiIs...
```

검증 흐름:
1. `FirebaseService::verifyIdToken($idToken)` → Firebase UID 획득
2. DB에서 `firebase_uid`로 sf_member 조회
3. 성공 시 세션 쿠키 자동 생성

### 우선순위

| 순위 | 인증 방식 | 용도 |
|------|----------|------|
| 1 | session_id (쿠키 또는 파라미터) | SSR, CURL 테스트 |
| 2 | id_token (파라미터) | 앱, JavaScript API |

### 핵심 코드 (AuthService)

```php
// lib/utils/AuthService.php
public static function getLoginUser(): ?array
{
    if (self::$checked) return self::$cachedUser;
    self::$checked = true;

    // 경로 1: session_id (쿠키 또는 파라미터)
    $sessionId = $_COOKIE['session_id'] ?? RequestUtils::get('session_id');
    if (!empty($sessionId)) {
        $user = self::getUserBySessionId($sessionId);
        if ($user !== null) { self::$cachedUser = $user; return $user; }
    }

    // 경로 2: Firebase ID Token
    $idToken = RequestUtils::get('id_token');
    if (!empty($idToken)) {
        $user = self::getUserByIdToken($idToken);
        if ($user !== null) {
            self::setSessionCookie($user);
            self::$cachedUser = $user;
            return $user;
        }
    }

    return null;
}

// 테스트용 메서드
public static function setTestUser(?array $user): void  // 인증 우회
public static function reset(): void                     // 캐시 초기화
```

---

## Entity 구조

### ModerationEntity

검열 결과를 나타내는 Entity (POPO). 기존 `ModerationResult` 클래스의 v7 버전이다.

#### 기본 필드 (Gemini API 직접 반환)

| 필드 | 타입 | 설명 |
|------|------|------|
| `insult` | bool | 욕설/모욕 여부 |
| `sexually_explicit` | bool | 성적 표현 여부 |
| `selling` | bool | 판매 여부 |
| `job` | bool | 구인/구직 여부 |
| `news` | bool | 뉴스 여부 |
| `seek` | bool | 사람 찾기 여부 |
| `gambling` | bool | 도박 여부 |
| `exchange` | bool | 환전 여부 |
| `spam` | bool | 스팸 여부 |
| `contact` | bool | 연락처 포함 여부 |
| `info_score` | int | 필리핀 관련 점수 (0-100) |
| `wrong_job_description` | bool | 잘못된 구직 정보 여부 |
| `reasons` | array | 각 항목별 판단 근거 |

#### 파생 필드 (자동 계산)

| 필드 | 타입 | 계산 로직 |
|------|------|-----------|
| `is_flagged` | bool | `insult \|\| sexually_explicit` |
| `is_advertisement` | bool | `selling && contact` |
| `is_job` | bool | `job && contact` |
| `is_job_pass` | bool | `!wrong_job_description` |
| `is_exchange` | bool | `exchange && contact` |
| `is_gambling` | bool | `gambling && contact` |
| `is_news` | bool | `news` |

---

### GenerateEntity

텍스트 생성 결과를 나타내는 Entity (POPO).

| 필드 | 타입 | 설명 |
|------|------|------|
| `text` | string | 생성된 텍스트 |
| `model` | string | 사용된 모델명 |
| `created_at` | int | 생성 시각 (unix timestamp) |

---

### ReceiptEntity

영수증 분석 결과를 나타내는 Entity (POPO).

| 필드 | 타입 | 설명 |
|------|------|------|
| `is_receipt` | bool | 영수증 여부 |
| `is_authentic` | bool | 진짜 영수증 여부 |
| `store_name` | string | 상점명 |
| `date` | string | 거래 날짜 |
| `total_amount` | string | 총 금액 |
| `currency` | string | 통화 (PHP, KRW 등) |
| `items` | array | 구매 항목 목록 [{name, price}] |
| `payment_method` | string | 결제 방식 |
| `receipt_type` | string | 영수증 종류 (카드, 현금 등) |
| `summary` | string | 영수증 요약 텍스트 |
| `suspicious_reasons` | array | 가짜로 의심되는 이유 목록 |
| `confidence_score` | int | 신뢰도 점수 (0-100) |
| `upload_idx` | int | 업로드 레코드 idx |
| `company_name_matched` | bool\|null | 업소명 일치 여부. `company_idx` 전달 시: `true`/`false`. 미전달 시: `null` |

---

## GeminiClient

Gemini REST API에 cURL로 요청을 보내는 클라이언트 클래스이다.
모든 public 메서드의 마지막 파라미터로 `?string $model`을 전달하여 호출 시점에 모델을 변경할 수 있다.

### 메서드

| 메서드 | 반환 | 설명 |
|--------|------|------|
| `generateContent($systemInstruction, $userText, ?$generationConfig, ?$model)` | `array` | 텍스트 생성 요청 |
| `generateJson($systemInstruction, $userText, $responseSchema, ?$model)` | `array` | JSON 구조화 응답 요청 |
| `generateContentWithImage($systemInstruction, $imageBase64, $imageMimeType, $userText, ?$generationConfig, ?$model)` | `array` | 이미지+텍스트 생성 요청 |
| `generateJsonWithImage($systemInstruction, $imageBase64, $imageMimeType, $userText, $responseSchema, ?$model)` | `array` | 이미지+텍스트 JSON 응답 요청 |
| `generateContentStream($systemInstruction, $userText, $onChunk, ?$model)` | `void` | SSE 스트리밍 텍스트 생성 |
| `getModel()` | `string` | 기본 모델명 조회 |

### API 설정

- **엔드포인트**: `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`
- **SSE 엔드포인트**: `https://generativelanguage.googleapis.com/v1beta/models/{model}:streamGenerateContent?alt=sse`
- **API 키**: `GEMINI_API_KEY` 상수 (`etc/app.config.php`)
- **기본 모델**: `gemini-3-flash-preview`
- **영수증 분석 모델**: `gemini-2.5-flash-lite-preview-09-2025`
- **AI 답변 기본 모델**: `gemini-3.1-flash-lite-preview`
- **AI 답변 폴백 모델**: `gemini-2.5-flash-lite`

---

## 핵심 소스코드

### AiController 핵심 코드

```php
// lib/ai/AiController.php
namespace Philgo\Ai;

class AiController
{
    // API: method=ai.moderate (인증 불필요)
    public function moderate(array $input): array
    {
        $entity = AiService::moderate($input);
        return $entity->toArray();
    }

    // API: method=ai.generate (인증 불필요)
    public function generate(array $input): array
    {
        $entity = AiService::generate($input);
        return $entity->toArray();
    }

    // API: method=ai.analyzeReceipt (⚠️ 인증 필수)
    // 인증: id_token 또는 session_id 파라미터 필수
    public function analyzeReceipt(array $input): array
    {
        $entity = AiService::analyzeReceipt($input);
        return $entity->toArray();
    }
}
```

### AiService 핵심 코드

#### moderate() - 텍스트 검열

```php
// lib/ai/AiService.php
public static function moderate(array $input): ModerationEntity
{
    $text = trim((string)($input['text'] ?? ''));
    if ($text === '') {
        throw new RuntimeException('text 파라미터가 필요합니다.');
    }

    $systemPrompt = self::getModerationSystemPrompt();
    $responseSchema = self::getModerationResponseSchema();

    try {
        $result = GeminiClient::generateJson($systemPrompt, $text, $responseSchema);
        return ModerationEntity::fromArray($result);
    } catch (RuntimeException $e) {
        // API 오류 시 기본 Entity 반환 (모든 필드 false — 검열 통과 처리)
        return new ModerationEntity();
    }
}
```

#### generate() - 텍스트 생성

```php
public static function generate(array $input): GenerateEntity
{
    $prompt = trim((string)($input['prompt'] ?? ''));
    if ($prompt === '') {
        throw new RuntimeException('prompt 파라미터가 필요합니다.');
    }

    $systemInstruction = trim((string)($input['system_instruction'] ?? '당신은 유용한 도우미입니다. 한국어로 답변하세요.'));
    $result = GeminiClient::generateContent($systemInstruction, $prompt);

    return GenerateEntity::fromArray([
        'text' => $result['text'],
        'model' => GeminiClient::getModel(),
        'created_at' => time(),
    ]);
}
```

#### analyzeReceipt() - 영수증 분석 (인증 필수)

```php
use Philgo\Utils\AuthService;
use Philgo\Company\CompanyRepository;
use Philgo\Company\CompanyMetaRepository;

public static function analyzeReceipt(array $input): ReceiptEntity
{
    // 1. 인증 확인 — Firebase ID Token 또는 session_id 필수
    $user = AuthService::getLoginUser();
    if ($user === null) {
        throw new RuntimeException('로그인이 필요합니다. id_token 또는 session_id를 전달해주세요.');
    }

    // 인증된 사용자의 idx를 idx_member로 자동 설정
    $input['idx_member'] = (int) $user['idx'];

    // 2. 이미지 업로드 (UploadService가 자동으로 1000px 썸네일 생성)
    $uploadEntity = UploadService::store($input);

    // 3. 1000-{baseName}.webp 썸네일 경로 계산
    // ... (동일)

    // 4. company_idx가 전달되면 업소 정보 조회
    $companyIdx = (int)($input['company_idx'] ?? 0);
    $companyName = null;
    $receiptName = null;

    if ($companyIdx > 0) {
        $company = CompanyRepository::findByIdx($companyIdx);
        if ($company === null) {
            throw new RuntimeException('존재하지 않는 업소 번호입니다. company_idx: ' . $companyIdx);
        }
        $companyName = $company->name;

        // 영수증 표시 이름 조회 (company_meta에서 key='receipt_name')
        $receiptMeta = CompanyMetaRepository::findByCompanyAndKey($companyIdx, 'receipt_name');
        if ($receiptMeta !== null && $receiptMeta->value !== '') {
            $receiptName = $receiptMeta->value;
        }
    }

    // 5. base64 인코딩 + Gemini API 호출 (동적 시스템 프롬프트에 업소명 포함)
    $systemPrompt = self::getReceiptAnalysisSystemPrompt($companyName, $receiptName);
    // ... Gemini API 호출

    // 6. ReceiptEntity 변환 + company_name_matched 후처리
    $entity = ReceiptEntity::fromArray($result);
    $entity->upload_idx = $uploadEntity->idx;
    if ($companyIdx === 0) {
        $entity->company_name_matched = null;
    }

    // 7. 업소명 불일치 시 강제로 is_authentic=false 처리 (AI 판단 보정)
    if ($companyIdx > 0 && $entity->company_name_matched === false) {
        $entity->is_authentic = false;
        $entity->confidence_score = 0;
        $entity->suspicious_reasons[] = '영수증의 상점명이 등록된 업소명과 일치하지 않습니다';
    }

    // 8. 영수증이 아니면 예외 throw
    if (!$entity->is_receipt) {
        throw new RuntimeException('이미지가 영수증이 아닙니다.');
    }

    return $entity;
}
```

### 영수증 진위 판별 시스템 프롬프트 설계 원칙

`getReceiptAnalysisSystemPrompt(?string $companyName, ?string $receiptName)`의 핵심 설계 원칙:

1. **필리핀 발행 필수**: 필리핀에서 발행된 영수증만 `is_authentic=true` 가능. 타국 영수증은 즉시 거부 (`confidence_score=0`, `suspicious_reasons`에 "필리핀 국가에서 발행한 영수증이 아닙니다" 추가).
2. **업소명 일치 검증** (company_idx 전달 시): `$companyName`/`$receiptName`을 시스템 프롬프트에 동적으로 삽입하여 AI가 영수증 store_name과 비교. 불일치 시 PHP 후처리로 `is_authentic=false`, `confidence_score=0` 강제 처리.
3. **기본 태도: "의심"** — 모든 영수증은 가짜로 간주하고 시작. 진짜임을 증명하는 근거를 찾는 방식.
4. **6가지 검증 카테고리**: 물리적 특성(A), 폰트/레이아웃(B), 금액/수치(C), 이미지 조작(D), 형식/내용 일관성(E), 디지털 생성 패턴(F)
5. **confidence_score 기준**: 90-100(확실 진짜), 70-89(진짜 가능성 높음), 50-69(불명확→가짜 판정), 30-49(가짜 가능성 높음), 0-29(명백한 위조)
6. **is_authentic 판정**: 필리핀 발행 확인 AND 업소명 일치(전달 시) AND confidence_score >= 70 AND 6가지 검증 모두 통과 시에만 true
7. **suspicious_reasons 필수**: is_authentic=false일 때 반드시 1개 이상 구체적 이유 기재

> 프롬프트 전문은 `lib/ai/AiService.php`의 `getReceiptAnalysisSystemPrompt()` 메서드를 참조한다.

### GeminiClient 핵심 코드

```php
// lib/ai/GeminiClient.php
namespace Philgo\Ai;

class GeminiClient
{
    // 텍스트 전용 생성 요청
    public static function generateContent(
        string $systemInstruction, string $userText,
        ?array $generationConfig = null, ?string $model = null
    ): array {
        $payload = [
            'system_instruction' => ['parts' => [['text' => $systemInstruction]]],
            'contents' => [['parts' => [['text' => $userText]]]],
        ];
        if ($generationConfig !== null) $payload['generationConfig'] = $generationConfig;
        $response = self::callApi($payload, $model);
        return ['text' => self::extractText($response), 'raw' => $response];
    }

    // JSON 구조화 응답 요청
    public static function generateJson(
        string $systemInstruction, string $userText,
        array $responseSchema, ?string $model = null
    ): array {
        $generationConfig = [
            'responseMimeType' => 'application/json',
            'responseSchema' => $responseSchema,
        ];
        $result = self::generateContent($systemInstruction, $userText, $generationConfig, $model);
        return json_decode($result['text'], true);
    }

    // 이미지+텍스트 생성 요청 (inline_data 방식)
    public static function generateContentWithImage(
        string $systemInstruction, string $imageBase64, string $imageMimeType,
        string $userText, ?array $generationConfig = null, ?string $model = null
    ): array {
        $payload = [
            'system_instruction' => ['parts' => [['text' => $systemInstruction]]],
            'contents' => [[
                'parts' => [
                    ['inline_data' => ['mime_type' => $imageMimeType, 'data' => $imageBase64]],
                    ['text' => $userText]
                ]
            ]],
        ];
        if ($generationConfig !== null) $payload['generationConfig'] = $generationConfig;
        $response = self::callApi($payload, $model);
        return ['text' => self::extractText($response), 'raw' => $response];
    }

    // 이미지+텍스트 JSON 구조화 응답 요청
    public static function generateJsonWithImage(
        string $systemInstruction, string $imageBase64, string $imageMimeType,
        string $userText, array $responseSchema, ?string $model = null
    ): array {
        $generationConfig = [
            'responseMimeType' => 'application/json',
            'responseSchema' => $responseSchema,
        ];
        $result = self::generateContentWithImage(
            $systemInstruction, $imageBase64, $imageMimeType, $userText, $generationConfig, $model
        );
        return json_decode($result['text'], true);
    }

    // 기본 모델명
    public static function getModel(): string { return 'gemini-3-flash-preview'; }

    // cURL API 호출 (모델 파라미터 지원)
    private static function callApi(array $payload, ?string $model = null): array {
        $apiKey = self::getApiKey();
        $useModel = $model ?? self::getModel();
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$useModel}:generateContent?key={$apiKey}";
        // ... cURL 실행 + 에러 처리
    }
}
```

### ReceiptEntity 핵심 코드

```php
// lib/ai/ReceiptEntity.php
namespace Philgo\Ai;

class ReceiptEntity
{
    public bool $is_receipt = false;
    public bool $is_authentic = false;
    public string $store_name = '';
    public string $date = '';
    public string $total_amount = '';
    public string $currency = '';
    public array $items = [];
    public string $payment_method = '';
    public string $receipt_type = '';
    public string $summary = '';
    public array $suspicious_reasons = [];
    public int $confidence_score = 0;
    public int $upload_idx = 0;
    public ?bool $company_name_matched = null;

    public static function fromArray(array $data): self
    {
        $entity = new self();
        $entity->is_receipt = (bool)($data['is_receipt'] ?? false);
        $entity->is_authentic = (bool)($data['is_authentic'] ?? false);
        $entity->store_name = (string)($data['store_name'] ?? '');
        $entity->date = (string)($data['date'] ?? '');
        $entity->total_amount = (string)($data['total_amount'] ?? '');
        $entity->currency = (string)($data['currency'] ?? '');
        $entity->items = (array)($data['items'] ?? []);
        $entity->payment_method = (string)($data['payment_method'] ?? '');
        $entity->receipt_type = (string)($data['receipt_type'] ?? '');
        $entity->summary = (string)($data['summary'] ?? '');
        $entity->suspicious_reasons = (array)($data['suspicious_reasons'] ?? []);
        $entity->confidence_score = (int)($data['confidence_score'] ?? 0);
        $entity->upload_idx = (int)($data['upload_idx'] ?? 0);
        $entity->company_name_matched = isset($data['company_name_matched'])
            ? (bool)$data['company_name_matched'] : null;
        return $entity;
    }

    public function toArray(): array
    {
        return [
            'is_receipt' => $this->is_receipt,
            'is_authentic' => $this->is_authentic,
            'store_name' => $this->store_name,
            'date' => $this->date,
            'total_amount' => $this->total_amount,
            'currency' => $this->currency,
            'items' => $this->items,
            'payment_method' => $this->payment_method,
            'receipt_type' => $this->receipt_type,
            'summary' => $this->summary,
            'suspicious_reasons' => $this->suspicious_reasons,
            'confidence_score' => $this->confidence_score,
            'upload_idx' => $this->upload_idx,
            'company_name_matched' => $this->company_name_matched,
        ];
    }
}
```

---

## 검열 정책

### 차단 기준 (2가지만)

1. **insult**: 특정인 대상 욕설/심한 모욕
2. **sexually_explicit**: 100% 명백한 과도한 성적 표현

### 분류 항목

| 항목 | 조건 | 처리 |
|------|------|------|
| 판매 광고 | `selling && contact` | 회원장터 이동 |
| 구인/구직 | `job && contact` | 6가지 필수 요소 검증 |
| 도박 | `gambling && contact` | 블라인드 (뉴스 제외) |
| 환전 | `exchange && contact` | 환전 카테고리 이동 |
| 스팸 | `spam` | 블라인드 |

### 구인 필수 요소 (6가지)

1. 회사명/소개
2. 완전한 필리핀 주소 (거리명 시 번지수 또는 층 정보 필수)
3. 업무 범위/성격 (구체적)
4. 근무제 (주 5일/6일, 재택/원격/화상 불가)
5. 월급 (5만~30만 페소)
6. 필리핀 전화번호 (+63/09xx만, 카톡/텔레 불가)

---

## 테스트

### 실행 방법

```bash
# 전체 AI 모듈 테스트
./vendor/bin/pest tests/Unit/AiTest.php

# 통합 테스트 포함 (Gemini API 호출)
./vendor/bin/pest tests/Unit/AiTest.php --filter="통합"
```

### 테스트 항목 (30개)

| 구분 | 테스트 | 설명 |
|------|--------|------|
| ModerationEntity | fromArray() 기본값 | 빈 배열 → 모든 필드 false |
| ModerationEntity | fromArray() insult | is_flagged=true 계산 |
| ModerationEntity | 파생 필드 | is_advertisement, is_job, is_exchange 등 |
| ModerationEntity | toArray() | 배열 변환 |
| ModerationEntity | getReason() | 판단 근거 문자열 |
| GenerateEntity | fromArray()/toArray() | 변환 |
| ReceiptEntity | fromArray() 기본값 | 빈 배열 → 모든 필드 기본값 |
| ReceiptEntity | fromArray() 영수증 | 영수증 데이터 변환 |
| ReceiptEntity | fromArray() 가짜 | 가짜 영수증 데이터 변환 |
| ReceiptEntity | toArray() | 배열 변환 |
| AiController | moderate() 입력 검증 | text 누락 시 예외 |
| AiController | generate() 입력 검증 | prompt 누락 시 예외 |
| AiController | analyzeReceipt() 미인증 | 로그인 없이 호출 시 예외 |
| AiController | analyzeReceipt() 인증+파일없음 | 인증 후 파일 누락 시 예외 |
| GeminiClient | getModel() | 모델명 반환 |
| AiService | moderate() 통합 | 실제 API 호출 |
| AiService | generate() 통합 | 실제 API 호출 |

### 인증 기반 테스트 방법

PEST 유닛 테스트에서는 `AuthService::setTestUser()`로 인증을 시뮬레이션한다.

```php
use Philgo\Utils\AuthService;

// 미인증 테스트: AuthService 캐시 초기화
it('analyzeReceipt() - 미인증 시 예외 발생', function () {
    AuthService::reset();  // 캐시 초기화 (미인증 상태)
    $ctrl = new AiController();
    expect(fn() => $ctrl->analyzeReceipt([]))
        ->toThrow(RuntimeException::class, '로그인이 필요합니다.');
});

// 인증 후 테스트: setTestUser()로 테스트 사용자 설정
it('analyzeReceipt() - 인증 후에도 파일 없으면 업로드 예외 발생', function () {
    AuthService::setTestUser(['idx' => 190076, 'firebase_uid' => 'test_uid']);
    $ctrl = new AiController();
    // 인증은 통과하지만 $_FILES['file']이 없으므로 UploadService에서 예외 발생
    expect(fn() => $ctrl->analyzeReceipt([]))->toThrow(RuntimeException::class);
    AuthService::reset();  // 테스트 후 캐시 초기화
});
```

### CURL 테스트 방법 (실제 환경)

영수증 분석 API는 인증이 필수이므로, 반드시 `session_id` 또는 `id_token`을 함께 전달해야 한다.

**테스트 계정 정보**: [v7-accounts.md](../v7-accounts.md) 문서에 테스트용 계정 정보(session_id 포함)가 있다. CURL 테스트나 글 작성 등을 할 때 해당 문서의 session_id를 사용한다.

#### 방법 1: Durian 테스트 계정으로 테스트 (권장)

```bash
# Durian 테스트 계정 (v7-accounts.md 참조)
# session_id: 2278018daa75e0ab879d8791fb0e2b2d-190076
# sf_member.idx: 190076
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "session_id=2278018daa75e0ab879d8791fb0e2b2d-190076" \
  -F "file=@./tmp/sample-files/receipt-1.jpeg"
```

#### 방법 2: Firebase ID Token으로 테스트

```bash
# Firebase ID Token은 클라이언트에서 Firebase Auth로 발급
# JavaScript: firebase.auth().currentUser.getIdToken()
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "id_token=eyJhbGciOiJSUzI1NiIs..." \
  -F "file=@./tmp/sample-files/receipt-1.jpeg"
```

#### 방법 3: 인증 없이 테스트 (에러 확인)

```bash
# 인증 파라미터 없이 호출 → 에러 응답
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "file=@./tmp/sample-files/receipt-1.jpeg"

# 예상 응답:
# {"success":false,"message":"로그인이 필요합니다. id_token 또는 session_id를 전달해주세요."}
```

### 테스트 계정 안내

v7 API 테스트 시 인증이 필요한 경우, [v7-accounts.md](../v7-accounts.md) 문서에 기록된 테스트 계정의 `session_id`를 사용한다.

| 계정 | session_id | idx | 용도 |
|------|-----------|-----|------|
| Durian | `2278018daa75e0ab879d8791fb0e2b2d-190076` | 190076 | 개발 테스트 전용 |

> 브라우저 쿠키에서 session_id를 확인할 수도 있다:
> 1. `https://local.philgo.com`에 로그인
> 2. 개발자 도구 → Application → Cookies → `session_id` 값 복사

---

## 레거시 코드와의 관계

| v7 (새 시스템) | v6 (레거시) | 비고 |
|----------------|-------------|------|
| `AiService::moderate()` | `gemini_moderate_api()` | 동일한 검열 정책 |
| `ModerationEntity` | `ModerationResult` | 동일한 필드 구조 |
| `GeminiClient` | cURL 직접 호출 | 클래스로 추출 |
| `AuthService::getLoginUser()` | `login()` | 동일한 인증 흐름 |
| `Philgo\Ai\` 네임스페이스 | 전역 함수 | PSR-4 |

두 시스템은 완전히 독립적이며 공존한다. 기존 레거시 코드를 수정/삭제하지 않는다.
