# AI 영수증 진위 판별 API 상세 가이드

> 본 문서는 `ai.analyzeReceipt` API의 상세 사용법을 다룬다.
> 메인 문서: [v7-ai.md](v7-ai.md)

## 목차

1. [개요](#개요)
2. [API 호출 방법](#api-호출-방법)
3. [인증 (필수)](#인증-필수)
4. [요청/응답 상세](#요청응답-상세)
5. [진위 판별 로직 상세](#진위-판별-로직-상세)
6. [내부 처리 흐름](#내부-처리-흐름)
7. [시스템 프롬프트 설계](#시스템-프롬프트-설계)
8. [클라이언트 통합 가이드](#클라이언트-통합-가이드)
9. [에러 처리](#에러-처리)
10. [테스트 가이드](#테스트-가이드)
11. [핵심 소스코드](#핵심-소스코드)

---

## 개요

### 무엇을 하는 API인가?

`ai.analyzeReceipt`는 클라이언트(웹/앱)가 영수증 이미지를 업로드하면, Google Gemini AI가 다음 3가지를 판별하여 JSON으로 응답하는 API이다:

1. **영수증 여부** — 이미지가 영수증인지 아닌지 (`is_receipt`)
2. **진위 여부** — 진짜 영수증인지 가짜(조작/위조)인지 (`is_authentic`)
3. **정보 추출** — 상점명, 금액, 날짜, 결제 방식 등 (`store_name`, `total_amount`, ...)

### 핵심 특징

| 항목 | 내용 |
|------|------|
| API 메서드 | `ai.analyzeReceipt` |
| HTTP 방식 | `POST multipart/form-data` |
| 인증 | **필수** — `session_id` 또는 `id_token` |
| AI 모델 | `gemini-2.5-flash-lite-preview-09-2025` (경량 모델) |
| 이미지 처리 | 업로드 → WebP 변환 → 1000px 썸네일 → base64 → Gemini API |
| 진위 판별 원칙 | **"의심 우선"** — 모든 영수증을 가짜로 간주하고 시작 |
| 필리핀 발행 필수 | **필리핀에서 발행된 영수증만 `is_authentic=true` 가능** — 한국, 미국 등 타국 영수증은 무조건 거부 |
| 판정 기준 | confidence_score >= 70 AND 6가지 검증 모두 통과 AND 필리핀 발행 확인 시에만 `is_authentic=true` |

### 왜 만들었는가?

필리핀 커뮤니티에서 환전/거래 시 가짜 영수증으로 사기를 치는 사례가 빈번하다. 이 API를 통해 사용자가 영수증 사진을 올리면 즉시 진위를 판별하여 사기 피해를 예방한다.

---

## API 호출 방법

### 기본 호출

```bash
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "session_id={세션ID}" \
  -F "file=@/path/to/receipt.jpg"
```

### session_id 인증 (CURL/서버 간 호출용)

```bash
# Durian 테스트 계정 사용 (v7-accounts.md 참조)
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "session_id=2278018daa75e0ab879d8791fb0e2b2d-190076" \
  -F "file=@./tmp/sample-files/receipt-1.jpeg"
```

### Firebase ID Token 인증 (앱/웹 클라이언트용)

```bash
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "id_token=eyJhbGciOiJSUzI1NiIs..." \
  -F "file=@./tmp/sample-files/receipt-1.jpeg"
```

### JavaScript (웹 클라이언트)

```javascript
// FormData 구성
const formData = new FormData();
formData.append('method', 'ai.analyzeReceipt');
formData.append('session_id', sessionId);  // 또는 id_token
formData.append('file', fileInput.files[0]);

// API 호출
const response = await fetch('https://philgo.com/api.php', {
    method: 'POST',
    body: formData
});
const result = await response.json();

// 결과 처리
if (result.is_receipt && result.is_authentic) {
    console.log('진짜 영수증:', result.summary);
    console.log('신뢰도:', result.confidence_score);
} else if (result.is_receipt && !result.is_authentic) {
    console.log('가짜 영수증 의심!');
    console.log('의심 사유:', result.suspicious_reasons);
}
```

### Flutter/Dart (앱 클라이언트)

```dart
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> analyzeReceipt(String filePath, String idToken) async {
  var request = http.MultipartRequest('POST', Uri.parse('https://philgo.com/api.php'));
  request.fields['method'] = 'ai.analyzeReceipt';
  request.fields['id_token'] = idToken;
  request.files.add(await http.MultipartFile.fromPath('file', filePath));

  var response = await request.send();
  var body = await response.stream.bytesToString();
  return jsonDecode(body);
}
```

---

## 인증 (필수)

영수증 분석 API는 **인증이 필수**이다. 인증 없이 호출하면 에러가 발생한다.

### 인증 경로 2가지

| 경로 | 파라미터 | 용도 | 우선순위 |
|------|---------|------|---------|
| 세션 인증 | `session_id` | CURL, 서버 간 호출, SSR | 1 (먼저 검사) |
| Firebase 인증 | `id_token` | 앱, 웹 클라이언트 | 2 (세션 실패 시) |

### 인증 처리 흐름

```
요청 도착
  │
  ├─ 1. session_id 확인 (쿠키 또는 파라미터)
  │  ├─ 있으면 → 형식 검증 → DB 조회 → 해시 검증 → 성공
  │  └─ 없거나 실패 → 다음 단계
  │
  ├─ 2. id_token 확인 (파라미터)
  │  ├─ 있으면 → Firebase 토큰 검증 → DB 조회 → 성공
  │  └─ 없거나 실패 → 다음 단계
  │
  └─ 3. 둘 다 실패 → RuntimeException: "로그인이 필요합니다."
```

### session_id 형식

```
{MD5해시}-{사용자idx}

예: 2278018daa75e0ab879d8791fb0e2b2d-190076
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  ^^^^^^
    md5(LOGIN_SALT+idx+firebase_uid   사용자 idx
        +phone_number)
```

### 인증 실패 응답

```json
{
  "success": false,
  "message": "로그인이 필요합니다. id_token 또는 session_id를 전달해주세요."
}
```

---

## 요청/응답 상세

### 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `method` | string | ✅ | `ai.analyzeReceipt` (고정) |
| `session_id` | string | 조건부 | 세션 ID (인증 경로 1) |
| `id_token` | string | 조건부 | Firebase ID Token (인증 경로 2) |
| `file` | file | ✅ | 영수증 이미지 파일 (multipart/form-data) |

> `session_id`와 `id_token` 중 하나는 반드시 전달해야 한다.

### 지원 이미지 형식

| 형식 | 확장자 | 비고 |
|------|-------|------|
| JPEG | .jpg, .jpeg | 가장 일반적 |
| PNG | .png | 투명 배경 포함 |
| WebP | .webp | 이미 변환된 이미지 |
| GIF | .gif | 정적 이미지만 |
| BMP | .bmp | 대용량 주의 |

> 업로드된 이미지는 자동으로 **WebP 형식**으로 변환되고, **1000px 비율 유지 썸네일**이 생성된다. Gemini API에는 이 썸네일이 base64로 전달된다.

### 성공 응답 (필리핀 진짜 영수증)

```json
{
  "is_receipt": true,
  "is_authentic": true,
  "store_name": "globalpayments (SONG JAEHO)",
  "date": "Feb 24, 20 20:25",
  "total_amount": "PHP 816.96",
  "currency": "PHP",
  "items": [],
  "payment_method": "Debit Card / UPI Debit",
  "receipt_type": "Card Slip (Debit)",
  "summary": "필리핀 Taguig에 위치한 가맹점에서 카드(Debit)로 PHP 816.96을 결제한 거래 승인 전표",
  "suspicious_reasons": [
    "구매 항목 목록이 상세히 기록되지 않고 카드 승인 정보만 남아있는 전형적인 카드 매출 전표 형식 (위조 의심 요소 아님)"
  ],
  "confidence_score": 95,
  "upload_idx": 107
}
```

### 성공 응답 (비필리핀 영수증 — 자동 거부)

```json
{
  "is_receipt": true,
  "is_authentic": false,
  "store_name": "한국도로공사 동창원영업소",
  "date": "20XX년 XX월 XX일 01시27분",
  "total_amount": "3,800 원",
  "currency": "KRW",
  "items": [
    {"name": "1종", "price": "3,800"}
  ],
  "payment_method": "카드",
  "receipt_type": "하이패스 영수증 (한국도로공사)",
  "summary": "한국도로공사 동창원영업소에서 3,800원(카드)으로 하이패스 통행료를 지불한 영수증",
  "suspicious_reasons": [
    "필리핀 국가에서 발행한 영수증이 아닙니다",
    "거래 날짜(20XX년 XX월 XX일) 정보가 구체적이지 않고 마스킹되어 있습니다.",
    "이미지가 디지털 생성 또는 편집된 것으로 보이는 매우 깔끔한 폰트와 레이아웃입니다."
  ],
  "confidence_score": 0,
  "upload_idx": 108
}
```

### 응답 필드 상세

| 필드 | 타입 | 설명 |
|------|------|------|
| `is_receipt` | bool | 이미지가 영수증인지 여부 |
| `is_authentic` | bool | **영수증이 진짜인지 여부** (핵심 판별 결과) |
| `store_name` | string | 상점명 |
| `date` | string | 거래 날짜 (원본 형식 그대로) |
| `total_amount` | string | 총 금액 (통화 기호 포함) |
| `currency` | string | ISO 통화 코드 (PHP, KRW, USD 등) |
| `items` | array | 구매 항목 목록 `[{name, price}]` |
| `payment_method` | string | 결제 방식 (카드, 현금, 온라인 등) |
| `receipt_type` | string | 영수증 종류 (POS 영수증, 카드 매출전표 등) |
| `summary` | string | 영수증 내용 한 문장 요약 |
| `suspicious_reasons` | array | **가짜로 의심되는 구체적 이유 목록** |
| `confidence_score` | int | **신뢰도 점수 (0-100)** |
| `upload_idx` | int | 업로드 레코드 idx (DB 참조용) |

---

## 진위 판별 로직 상세

### CoT (Chain of Thought) 분석

영수증 진위 판별은 다음과 같은 단계적 사고 과정을 거친다:

```
[입력] 영수증 이미지
    │
    ▼
[1단계] 이미지가 영수증인가?
    ├─ YES → 1.5단계로 진행
    └─ NO  → is_receipt=false, 나머지 기본값 반환, RuntimeException throw
    │
    ▼
[1.5단계] 필리핀 발행 영수증인가?
    ├─ YES (PHP/₱ 통화, 필리핀 주소/지명, BIR 번호 등) → 2단계로 진행
    └─ NO  → is_authentic=false, confidence_score=0,
             suspicious_reasons에 "필리핀 국가에서 발행한 영수증이 아닙니다" 추가
    │
    ▼
[2단계] 6가지 검증 카테고리 순차 점검
    ├─ A. 물리적 특성 → 실제 프린터 출력인가?
    ├─ B. 폰트/레이아웃 → 일관성 있는가?
    ├─ C. 금액/수치 → 합산이 맞는가?
    ├─ D. 이미지 조작 → 편집 흔적이 있는가?
    ├─ E. 형식/일관성 → 날짜, 번호 형식이 올바른가?
    └─ F. 디지털 생성 → 프로그램으로 만든 것인가?
    │
    ▼
[3단계] confidence_score 계산 (0-100)
    │
    ▼
[4단계] 최종 판정
    ├─ score >= 70 AND 모든 검증 통과 → is_authentic=true
    └─ score < 70 OR 하나라도 실패 → is_authentic=false
    │
    ▼
[5단계] 정보 추출 (상점명, 금액, 날짜 등)
    │
    ▼
[출력] ReceiptEntity (JSON)
```

### ToT (Tree of Thought) 분석 — 6가지 검증 카테고리

```
영수증 진위 검증
├── A. 물리적 특성 검증
│   ├── POS/열전사 프린터 출력 패턴 확인
│   │   ├── 점 패턴, 약간의 번짐 → 진짜 가능성 ↑
│   │   └── 완벽한 선명도 → 디지털 생성 의심
│   ├── 종이 질감 (감열지 여부)
│   │   ├── 감열지 특유의 질감 → 진짜 가능성 ↑
│   │   └── 일반 용지/화면 → 가짜 의심
│   ├── 촬영 사진 자연스러움
│   │   ├── 각도/그림자/배경 자연스러움 → 진짜 가능성 ↑
│   │   └── 정면 완벽 촬영 → 스캔/캡처 의심
│   └── 🔴 즉시 실패: 화면 캡처, 스크린샷, 디지털 생성
│
├── B. 폰트 및 레이아웃 검증
│   ├── 폰트 종류 일관성
│   │   ├── 단일 폰트 사용 → 진짜 가능성 ↑
│   │   └── 2종류 이상 혼재 → 편집 의심
│   ├── 문자/줄 간격 일정성
│   │   ├── 일정함 → 진짜 가능성 ↑
│   │   └── 불균일 → 수작업 편집 의심
│   └── 🔴 즉시 실패: 폰트 크기/종류 갑작스런 변경
│
├── C. 금액 및 수치 검증 (산술)
│   ├── 항목 합계 = 소계 확인
│   ├── 소계 + 세금 = 총액 확인
│   ├── 할인 적용 올바른지 확인
│   ├── 🔴 즉시 실패: 금액 합산 불일치
│   └── 🔴 즉시 실패: 비정상적 소수점
│
├── D. 이미지 조작 흔적 검증
│   ├── 픽셀 불일치, 경계선 부자연스러움
│   ├── 영역별 선명도/밝기/대비 차이
│   ├── JPEG 압축 아티팩트 불균형
│   ├── 텍스트 주변 배경색 차이
│   └── 🔴 즉시 실패: 편집 흔적 발견
│
├── E. 형식 및 내용 일관성 검증
│   ├── 날짜/시간 형식 (해당 국가 표준)
│   ├── 사업자번호/영수증번호 자릿수
│   ├── 상점명/주소 현실성
│   ├── 통화 기호/금액 형식
│   └── 🔴 즉시 실패: 미래 날짜, 비현실적 정보
│
└── F. 디지털 생성/위조 패턴 감지
    ├── Word/Excel/포토샵/그림판 생성 의심
    ├── 레이아웃이 너무 완벽함 (POS 출력은 불완전함이 있음)
    ├── 텍스트가 이미지 위 오버레이 의심
    └── 🔴 즉시 실패: 디지털 생성 의심
```

### confidence_score 구간별 판정 기준

| 점수 범위 | 의미 | is_authentic |
|----------|------|-------------|
| 90-100 | 실제 매장에서 POS 프린터로 출력한 진짜 영수증이 확실함 | `true` |
| 70-89 | 진짜일 가능성이 높지만 경미한 의심 요소 있음 | `true` |
| 50-69 | 진위 불명확 — 판별 불가 | `false` |
| 30-49 | 가짜일 가능성이 높음 | `false` |
| 0-29 | 명백한 위조/조작 | `false` |

### is_authentic 최종 판정 기준

```
is_authentic = true 조건 (모두 충족해야 함):
  ✅ 필리핀에서 발행된 영수증 (PHP/₱ 통화, 필리핀 주소, BIR 번호 등)
  ✅ confidence_score >= 70
  ✅ A~F 6가지 검증 항목 모두 통과
  ✅ 편집/조작 흔적 없음
  ✅ 금액 산술 검증 통과

is_authentic = false 조건 (하나라도 해당):
  ❌ 필리핀이 아닌 국가에서 발행된 영수증 (→ confidence_score=0, suspicious_reasons에 "필리핀 국가에서 발행한 영수증이 아닙니다" 추가)
  ❌ confidence_score < 70
  ❌ A~F 중 하나라도 실패
  ❌ 화면 캡처/스크린샷/디지털 생성
  ❌ 금액 합산 불일치
  ❌ 편집 흔적 발견
  ❌ 조금이라도 의심스러움
```

---

## 내부 처리 흐름

### 전체 아키텍처 흐름

```
클라이언트 (웹/앱)
    │
    │ POST multipart/form-data
    │ - method=ai.analyzeReceipt
    │ - session_id 또는 id_token
    │ - file=영수증이미지.jpg
    │
    ▼
api.php (v7 엔트리포인트)
    │
    │ RequestUtils::parseMethod() → ['ai', 'analyzeReceipt']
    │ FQCN → Philgo\Ai\AiController
    │
    ▼
AiController::analyzeReceipt($input)
    │
    ▼
AiService::analyzeReceipt($input)
    │
    ├─ [1] AuthService::getLoginUser() ─── 인증 확인
    │      └─ session_id 또는 id_token 검증 → 사용자 idx 획득
    │
    ├─ [2] $input['idx_member'] = $user['idx'] ─── 자동 설정
    │
    ├─ [3] UploadService::store($input) ─── 이미지 업로드
    │      ├─ 파일 저장: /uploads/{idx_member}/{uniqueName}
    │      ├─ WebP 변환 (1600px 최대)
    │      ├─ 썸네일 생성: 400x400, 800x800, 1000-{name}
    │      └─ DB 레코드 생성 → UploadEntity 반환
    │
    ├─ [4] 1000-{baseName}.webp 썸네일 경로 계산
    │      └─ 없으면 원본 사용
    │
    ├─ [5] base64_encode(file_get_contents($thumbnailPath))
    │      └─ MIME: image/webp
    │
    ├─ [6] GeminiClient::generateJsonWithImage() ─── AI 분석
    │      ├─ 시스템 프롬프트: 6가지 검증 카테고리
    │      ├─ 응답 스키마: 12개 필드
    │      ├─ 모델: gemini-2.5-flash-lite-preview-09-2025
    │      └─ Gemini REST API 호출 (inline_data 방식)
    │
    ├─ [7] ReceiptEntity::fromArray($result)
    │      └─ upload_idx 설정
    │
    └─ [8] is_receipt=false → RuntimeException throw
           is_receipt=true → ReceiptEntity 반환
    │
    ▼
AiController → $entity->toArray() → JSON 응답
```

### 이미지 처리 파이프라인

```
원본 이미지 (JPEG/PNG 등)
    │
    ├─ [1] move_uploaded_file() → /uploads/{idx}/원본파일
    │
    ├─ [2] ImageService::convertAndResize()
    │      └─ WebP 변환 + 1600px 최대 리사이즈
    │      └─ 원본 삭제 → /uploads/{idx}/{name}.webp
    │
    ├─ [3] ImageService::generateSquareThumbnails()
    │      ├─ /uploads/{idx}/400x400-{name}.webp
    │      └─ /uploads/{idx}/800x800-{name}.webp
    │
    ├─ [4] ImageService::generateResizedThumbnails()
    │      └─ /uploads/{idx}/1000-{name}.webp  ← Gemini에 전달되는 이미지
    │
    └─ [5] Gemini API에는 1000-{name}.webp가 base64로 전달
```

### Gemini API Payload 구조

```json
{
  "system_instruction": {
    "parts": [{"text": "당신은 영수증 위조 탐지 전문 수사관입니다..."}]
  },
  "contents": [{
    "parts": [
      {
        "inline_data": {
          "mime_type": "image/webp",
          "data": "base64로 인코딩된 이미지 데이터..."
        }
      },
      {
        "text": "이 이미지를 분석하여 영수증인지 판별하고, 진위 여부를 확인한 후 정보를 추출해주세요."
      }
    ]
  }],
  "generationConfig": {
    "responseMimeType": "application/json",
    "responseSchema": {
      "type": "OBJECT",
      "properties": {
        "is_receipt": {"type": "BOOLEAN"},
        "is_authentic": {"type": "BOOLEAN"},
        "confidence_score": {"type": "NUMBER"},
        "suspicious_reasons": {"type": "ARRAY", "items": {"type": "STRING"}}
      }
    }
  }
}
```

---

## 시스템 프롬프트 설계

### 설계 원칙

1. **필리핀 발행 필수**: 필리핀에서 발행된 영수증만 `is_authentic=true` 가능. 타국 영수증은 즉시 `is_authentic=false`, `confidence_score=0`, `suspicious_reasons`에 "필리핀 국가에서 발행한 영수증이 아닙니다" 추가.
2. **기본 태도: "의심"** — 모든 영수증을 가짜로 간주하고 시작. 진짜임을 증명하는 근거를 찾는 방식.
3. **6가지 검증 카테고리**: 물리적 특성(A), 폰트/레이아웃(B), 금액/수치(C), 이미지 조작(D), 형식/내용 일관성(E), 디지털 생성 패턴(F)
4. **즉시 실패 조건**: 각 카테고리에 🔴로 표시된 즉시 실패 조건이 있으며, 해당 시 무조건 `is_authentic=false`
5. **confidence_score 기준**: 70점 이상이어야 `is_authentic=true` 가능
6. **suspicious_reasons 필수**: `is_authentic=false`일 때 반드시 1개 이상 구체적 이유 기재

### 프롬프트 핵심 구조

```
[역할 정의]
"당신은 영수증 위조 탐지 전문 수사관입니다. 기본 태도는 의심."

[1단계] 영수증 여부 판별
  → is_receipt (true/false)

[1.5단계] 필리핀 발행 영수증 필수 검증
  → 필리핀 발행 아니면: is_authentic=false, confidence_score=0,
    suspicious_reasons에 "필리핀 국가에서 발행한 영수증이 아닙니다" 추가

[2단계] 진위 여부 판별 — 6가지 검증 카테고리
  A. 물리적 특성 (프린터 출력 여부)
  B. 폰트/레이아웃 (일관성)
  C. 금액/수치 (산술 검증)
  D. 이미지 조작 (편집 흔적)
  E. 형식/내용 (날짜, 번호 형식)
  F. 디지털 생성 (프로그램 제작 여부)

[confidence_score 기준]
  90-100: 확실한 진짜
  70-89: 진짜 가능성 높음
  50-69: 불명확 → false
  30-49: 가짜 가능성 높음
  0-29: 명백한 위조

[is_authentic 판정]
  score >= 70 AND 모두 통과 → true
  score < 70 OR 하나라도 실패 → false

[3단계] 정보 추출
  상점명, 날짜, 금액, 통화, 항목, 결제 방식, 영수증 종류, 요약
```

> 프롬프트 전문은 `lib/ai/AiService.php`의 `getReceiptAnalysisSystemPrompt()` 메서드를 참조한다.

---

## 클라이언트 통합 가이드

### 웹 (HTML + JavaScript)

```html
<input type="file" id="receiptFile" accept="image/*">
<button onclick="analyzeReceipt()">영수증 분석</button>
<div id="result"></div>

<script>
async function analyzeReceipt() {
    const fileInput = document.getElementById('receiptFile');
    if (!fileInput.files[0]) {
        alert('영수증 이미지를 선택해주세요.');
        return;
    }

    const formData = new FormData();
    formData.append('method', 'ai.analyzeReceipt');
    formData.append('session_id', getSessionId());  // 세션 ID 가져오기
    formData.append('file', fileInput.files[0]);

    try {
        const res = await fetch('/api.php', { method: 'POST', body: formData });
        const data = await res.json();

        if (data.success === false) {
            document.getElementById('result').innerHTML =
                `<div class="alert alert-danger">${data.message}</div>`;
            return;
        }

        // 진짜 영수증
        if (data.is_authentic) {
            document.getElementById('result').innerHTML = `
                <div class="alert alert-success">
                    <h5>✅ 진짜 영수증 (신뢰도: ${data.confidence_score}%)</h5>
                    <p>상점: ${data.store_name}</p>
                    <p>금액: ${data.total_amount}</p>
                    <p>날짜: ${data.date}</p>
                    <p>요약: ${data.summary}</p>
                </div>`;
        }
        // 가짜 영수증
        else {
            document.getElementById('result').innerHTML = `
                <div class="alert alert-danger">
                    <h5>⚠️ 가짜 영수증 의심 (신뢰도: ${data.confidence_score}%)</h5>
                    <p>의심 사유:</p>
                    <ul>${data.suspicious_reasons.map(r => `<li>${r}</li>`).join('')}</ul>
                </div>`;
        }
    } catch (err) {
        console.error('API 호출 실패:', err);
    }
}
</script>
```

### 판정 결과에 따른 UI 분기

```javascript
function handleReceiptResult(data) {
    // 1. 영수증이 아닌 경우 (success: false로 올 수 있음)
    if (data.success === false) {
        // "이미지가 영수증이 아닙니다." 또는 인증 실패
        showError(data.message);
        return;
    }

    // 2. 진짜 영수증
    if (data.is_receipt && data.is_authentic) {
        showSuccess({
            title: '진짜 영수증',
            confidence: data.confidence_score,
            store: data.store_name,
            amount: data.total_amount,
            date: data.date,
            summary: data.summary,
            warnings: data.suspicious_reasons  // 경미한 의심 사항
        });
    }

    // 3. 가짜 영수증
    if (data.is_receipt && !data.is_authentic) {
        showWarning({
            title: '가짜 영수증 의심',
            confidence: data.confidence_score,
            reasons: data.suspicious_reasons,
            store: data.store_name,
            amount: data.total_amount
        });
    }
}
```

---

## 에러 처리

### 에러 응답 형식

모든 에러는 `api.php`에서 catch되어 다음 형식으로 반환된다:

```json
{
  "success": false,
  "message": "에러 메시지"
}
```

### 에러 유형별 응답

| 에러 상황 | message | 원인 |
|----------|---------|------|
| 미인증 | `로그인이 필요합니다. id_token 또는 session_id를 전달해주세요.` | 인증 파라미터 누락 |
| 파일 누락 | `파일 업로드에 실패했습니다. (error: -1)` | `file` 파라미터 누락 |
| 영수증 아님 | `이미지가 영수증이 아닙니다.` | `is_receipt=false` |
| 이미지 읽기 실패 | `업로드된 이미지 파일을 찾을 수 없습니다.` | 썸네일/원본 없음 |
| Gemini API 오류 | `Gemini API HTTP 오류: {status_code}` | API 키/모델 문제 |

### 클라이언트 에러 처리 예시

```javascript
try {
    const res = await fetch('/api.php', { method: 'POST', body: formData });
    const data = await res.json();

    if (data.success === false) {
        switch (true) {
            case data.message.includes('로그인'):
                // 로그인 페이지로 이동
                window.location.href = '/user/login.php';
                break;
            case data.message.includes('영수증이 아닙니다'):
                alert('영수증 이미지가 아닙니다. 영수증 사진을 다시 촬영해주세요.');
                break;
            default:
                alert('오류: ' + data.message);
        }
        return;
    }

    // 정상 처리...
} catch (err) {
    alert('서버 연결에 실패했습니다.');
}
```

---

## 테스트 가이드

### 테스트 계정

API 테스트 시 [v7-accounts.md](../v7-accounts.md) 문서의 테스트 계정을 사용한다.

| 계정 | session_id | idx | 용도 |
|------|-----------|-----|------|
| Durian | `2278018daa75e0ab879d8791fb0e2b2d-190076` | 190076 | 개발 테스트 전용 |

### CURL 테스트

#### 필리핀 진짜 영수증 테스트

```bash
# receipt-1.jpeg: 필리핀 카드 결제 영수증 (PHP 816.96)
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "session_id=2278018daa75e0ab879d8791fb0e2b2d-190076" \
  -F "file=@./tmp/sample-files/receipt-1.jpeg"

# 예상: is_receipt=true, is_authentic=true, confidence_score >= 70

# receipt-4.jpeg: 필리핀 SM Cinema 영수증 (PHP 202.00)
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "session_id=2278018daa75e0ab879d8791fb0e2b2d-190076" \
  -F "file=@./tmp/sample-files/receipt-4.jpeg"

# 예상: is_receipt=true, is_authentic=true, confidence_score >= 70
```

#### 비필리핀 영수증 테스트 (자동 거부)

```bash
# receipt-2.jpeg: 한국 하이패스 영수증 (가짜, KRW)
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "session_id=2278018daa75e0ab879d8791fb0e2b2d-190076" \
  -F "file=@./tmp/sample-files/receipt-2.jpeg"

# 예상: is_authentic=false, confidence_score=0, "필리핀 국가에서 발행한 영수증이 아닙니다"

# receipt-3.jpeg: 한국 카드 매출전표 (진짜이지만 비필리핀)
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "session_id=2278018daa75e0ab879d8791fb0e2b2d-190076" \
  -F "file=@./tmp/sample-files/receipt-3.jpeg"

# 예상: is_authentic=false, confidence_score=0~10, "필리핀 국가에서 발행한 영수증이 아닙니다"
```

#### 인증 없이 테스트 (에러 확인)

```bash
curl -k -X POST "https://local.philgo.com/api.php" \
  -F "method=ai.analyzeReceipt" \
  -F "file=@./tmp/sample-files/receipt-1.jpeg"

# 예상: {"success":false,"message":"로그인이 필요합니다. id_token 또는 session_id를 전달해주세요."}
```

### PEST 유닛 테스트

```bash
./vendor/bin/pest tests/Unit/AiTest.php
```

#### 영수증 관련 테스트 항목

| 테스트 | 설명 |
|--------|------|
| `ReceiptEntity fromArray() - 빈 배열` | 모든 필드 기본값 처리 |
| `ReceiptEntity fromArray() - 영수증 데이터` | 정상 데이터 변환 |
| `ReceiptEntity fromArray() - 가짜 영수증` | is_authentic=false 데이터 변환 |
| `ReceiptEntity toArray()` | Entity → 배열 변환 |
| `analyzeReceipt() - 미인증 시 예외` | AuthService 없이 호출 시 RuntimeException |
| `analyzeReceipt() - 인증 후 파일 없음` | 인증은 통과하지만 file 없을 때 예외 |

#### PEST 테스트에서 인증 시뮬레이션

```php
use Philgo\Utils\AuthService;

// 인증된 사용자 설정
AuthService::setTestUser(['idx' => 190076, 'firebase_uid' => 'test_uid']);

// 테스트 실행...

// 테스트 후 반드시 초기화
AuthService::reset();
```

---

## 핵심 소스코드

### AiService::analyzeReceipt() 전체 코드

```php
// lib/ai/AiService.php
use Philgo\Upload\UploadService;
use Philgo\Utils\AuthService;
use RuntimeException;

public static function analyzeReceipt(array $input): ReceiptEntity
{
    // 1. 인증 확인 — Firebase ID Token 또는 session_id 필수
    $user = AuthService::getLoginUser();
    if ($user === null) {
        throw new RuntimeException('로그인이 필요합니다. id_token 또는 session_id를 전달해주세요.');
    }

    // 인증된 사용자의 idx를 idx_member로 설정
    $input['idx_member'] = (int) $user['idx'];

    // 2. 이미지 업로드 (UploadService가 자동으로 1000px 썸네일 생성)
    $uploadEntity = UploadService::store($input);

    // 3. 1000-{baseName}.webp 썸네일 경로 계산
    $rootDir = defined('ROOT_DIR') ? ROOT_DIR : dirname(__DIR__, 2);
    $baseName = basename($uploadEntity->url);
    $dir = dirname($uploadEntity->url);
    $thumbnailUrl = $dir . '/1000-' . $baseName;
    $thumbnailPath = $rootDir . $thumbnailUrl;

    // 썸네일이 없으면 원본 사용
    if (!file_exists($thumbnailPath)) {
        $thumbnailPath = $rootDir . $uploadEntity->url;
    }
    if (!file_exists($thumbnailPath)) {
        throw new RuntimeException('업로드된 이미지 파일을 찾을 수 없습니다.');
    }

    // 4. base64 인코딩
    $imageData = file_get_contents($thumbnailPath);
    if ($imageData === false) {
        throw new RuntimeException('이미지 파일을 읽을 수 없습니다.');
    }
    $imageBase64 = base64_encode($imageData);
    $imageMimeType = 'image/webp';

    // 5. Gemini API 호출 (영수증 분석은 gemini-2.5-flash-lite 모델 사용)
    $systemPrompt = self::getReceiptAnalysisSystemPrompt();
    $responseSchema = self::getReceiptAnalysisResponseSchema();
    $userText = '이 이미지를 분석하여 영수증인지 판별하고, 진위 여부를 확인한 후 정보를 추출해주세요.';
    $receiptModel = 'gemini-2.5-flash-lite-preview-09-2025';

    $result = GeminiClient::generateJsonWithImage(
        $systemPrompt, $imageBase64, $imageMimeType, $userText, $responseSchema, $receiptModel
    );

    // 6. ReceiptEntity 변환 + upload_idx 설정
    $entity = ReceiptEntity::fromArray($result);
    $entity->upload_idx = $uploadEntity->idx;

    // 7. 영수증이 아니면 예외 throw
    if (!$entity->is_receipt) {
        throw new RuntimeException('이미지가 영수증이 아닙니다.');
    }

    return $entity;
}
```

### ReceiptEntity 전체 코드

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
        ];
    }
}
```

### 응답 스키마 (Gemini API)

```php
// AiService::getReceiptAnalysisResponseSchema()
[
    'type' => 'OBJECT',
    'properties' => [
        'is_receipt' => ['type' => 'BOOLEAN'],
        'is_authentic' => ['type' => 'BOOLEAN'],
        'store_name' => ['type' => 'STRING'],
        'date' => ['type' => 'STRING'],
        'total_amount' => ['type' => 'STRING'],
        'currency' => ['type' => 'STRING'],
        'items' => [
            'type' => 'ARRAY',
            'items' => [
                'type' => 'OBJECT',
                'properties' => [
                    'name' => ['type' => 'STRING'],
                    'price' => ['type' => 'STRING'],
                ]
            ]
        ],
        'payment_method' => ['type' => 'STRING'],
        'receipt_type' => ['type' => 'STRING'],
        'summary' => ['type' => 'STRING'],
        'suspicious_reasons' => [
            'type' => 'ARRAY',
            'items' => ['type' => 'STRING']
        ],
        'confidence_score' => ['type' => 'NUMBER'],
    ],
    'required' => [
        'is_receipt', 'is_authentic', 'store_name', 'date',
        'total_amount', 'currency', 'items', 'payment_method',
        'receipt_type', 'summary', 'suspicious_reasons', 'confidence_score'
    ]
]
```

---

## 관련 파일

| 파일 | 역할 |
|------|------|
| `lib/ai/AiController.php` | API 엔드포인트 (analyzeReceipt 메서드) |
| `lib/ai/AiService.php` | 비즈니스 로직 (인증, 업로드, AI 분석, 검증) |
| `lib/ai/GeminiClient.php` | Gemini REST API 클라이언트 |
| `lib/ai/ReceiptEntity.php` | 영수증 분석 결과 Entity (POPO) |
| `lib/upload/UploadService.php` | 이미지 업로드 + WebP 변환 + 썸네일 생성 |
| `lib/utils/AuthService.php` | 사용자 인증 (session_id, Firebase ID Token) |
| `tests/Unit/AiTest.php` | PEST 유닛 테스트 |
