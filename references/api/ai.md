# AI 모듈 API 문서

## 개요

Gemini API를 활용한 콘텐츠 검열, 텍스트 생성, 영수증 분석 모듈이다.
기존 레거시 검열 코드(`lib/moderate/gemini-moderate-api.php`)를 v7 Controller+Service 아키텍처로 재구현한 것이다.

## 목차

- [파일 구조](#파일-구조)
- [API 엔드포인트](#api-엔드포인트)
  - [ai.moderate - 텍스트 검열](#aimoderate---텍스트-검열)
  - [ai.generate - 텍스트 생성](#aigenerate---텍스트-생성)
  - [ai.analyzeReceipt - 영수증 분석](#aianalyzereceipt---영수증-분석)
- [Entity 구조](#entity-구조)
  - [ModerationEntity](#moderationentity)
  - [GenerateEntity](#generateentity)
  - [ReceiptEntity](#receiptentity)
- [GeminiClient](#geminiclient)
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

Gemini API를 사용하여 텍스트 콘텐츠를 검열한다.

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

**응답 (에러):**

```json
{
    "success": false,
    "message": "text 파라미터가 필요합니다."
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

Gemini API를 사용하여 텍스트를 생성한다.

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
# GET 방식
curl -k "https://local.philgo.com/api.php?method=ai.generate&prompt=1%2B1%EC%9D%80?"

# POST 방식
curl -k -X POST https://local.philgo.com/api.php \
  -H "Content-Type: application/json" \
  -d '{"method":"ai.generate","prompt":"필리핀 마닐라의 날씨를 알려주세요","system_instruction":"필리핀 전문 여행 가이드"}'
```

---

### ai.analyzeReceipt - 영수증 분석

영수증 이미지를 업로드하면 Gemini AI가 영수증 진위 여부를 판별하고 정보를 추출한다.

**처리 흐름:**
1. `UploadService::store()`로 이미지 업로드 (자동으로 1000px 썸네일 생성)
2. `1000-{baseName}.webp` 썸네일 파일을 base64 인코딩
3. `GeminiClient::generateJsonWithImage()`로 Gemini API 호출 (모델: `gemini-2.5-flash-lite-preview-09-2025`)
4. 영수증이 아니면 에러 반환, 영수증이면 분석 결과 반환

**요청:**

```
POST /api.php (multipart/form-data)
- method: ai.analyzeReceipt
- idx_member: 회원 idx (필수)
- file: 영수증 이미지 파일 (필수)
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `idx_member` | int | ✅ | 회원 idx |
| `file` | file | ✅ | 영수증 이미지 파일 (multipart/form-data) |

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
    "upload_idx": 12345
}
```

**응답 (성공 - 가짜 영수증):**

```json
{
    "is_receipt": true,
    "is_authentic": false,
    "store_name": "Unknown Store",
    "date": "2025-01-15",
    "total_amount": "₱1,500.00",
    "currency": "PHP",
    "items": [],
    "payment_method": "",
    "receipt_type": "카드 매출전표",
    "summary": "조작이 의심되는 영수증",
    "suspicious_reasons": ["폰트 불일치 감지", "금액 합계 오류"],
    "confidence_score": 25,
    "upload_idx": 12346
}
```

**응답 (에러 - 영수증이 아닌 이미지):**

```json
{
    "success": false,
    "message": "이미지가 영수증이 아닙니다."
}
```

**응답 (에러 - 파라미터 누락):**

```json
{
    "success": false,
    "message": "idx_member가 필요합니다."
}
```

**curl 예시:**

```bash
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "idx_member=190076" \
  -F "file=@/path/to/receipt.jpg"
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

#### 메서드

| 메서드 | 반환 | 설명 |
|--------|------|------|
| `fromArray(array $data)` | `self` | API 결과 배열 → Entity |
| `toArray()` | `array` | Entity → 배열 |
| `getReason()` | `string` | 판단 근거 문자열 |

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

#### 메서드

| 메서드 | 반환 | 설명 |
|--------|------|------|
| `fromArray(array $data)` | `self` | API 결과 배열 → Entity |
| `toArray()` | `array` | Entity → 배열 |

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
| `getModel()` | `string` | 기본 모델명 조회 |

### API 설정

- **엔드포인트**: `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`
- **API 키**: `GEMINI_API_KEY` 상수 (`etc/app.config.php`)
- **기본 모델**: `gemini-3-flash-preview`
- **영수증 분석 모델**: `gemini-2.5-flash-lite-preview-09-2025`

### 모델 변경 예시

```php
// 기본 모델 사용 (gemini-3-flash-preview)
GeminiClient::generateContent($prompt, $text);

// 특정 모델 지정
GeminiClient::generateContent($prompt, $text, null, 'gemini-2.5-flash-lite-preview-09-2025');

// 이미지 분석 + 특정 모델
GeminiClient::generateJsonWithImage($prompt, $base64, $mime, $text, $schema, 'gemini-2.5-flash-lite-preview-09-2025');
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

### 테스트 항목

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
| AiController | analyzeReceipt() 입력 검증 | idx_member 누락 시 예외 |
| GeminiClient | getModel() | 모델명 반환 |
| AiService | moderate() 통합 | 실제 API 호출 |
| AiService | generate() 통합 | 실제 API 호출 |

---

## 레거시 코드와의 관계

| v7 (새 시스템) | v6 (레거시) | 비고 |
|----------------|-------------|------|
| `AiService::moderate()` | `gemini_moderate_api()` | 동일한 검열 정책 |
| `ModerationEntity` | `ModerationResult` | 동일한 필드 구조 |
| `GeminiClient` | cURL 직접 호출 | 클래스로 추출 |
| `Philgo\Ai\` 네임스페이스 | 전역 함수 | PSR-4 |

두 시스템은 완전히 독립적이며 공존한다. 기존 레거시 코드를 수정/삭제하지 않는다.
