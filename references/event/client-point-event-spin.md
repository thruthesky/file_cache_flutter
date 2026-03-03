# 필고 포인트 이벤트 기능 개발 계획

## 1. 개요

필고 포인트 이벤트 기능은 사용자들이 **업소 방문 → QR 코드 스캔 → 포인트 획득 → 이벤트 응모**의 흐름으로 참여하는 시스템이다.
"삼단콤보"라는 이름으로, 한 번의 업소 방문에서 최대 3가지 방법으로 포인트를 획득할 수 있다.

### 1.1 삼단콤보 포인트 획득 구조

| 단계 | 행동 | 포인트 | 조건 |
|------|------|--------|------|
| 1단계 | QR 코드 스캔 | 랜덤 1,000 ~ 2,000P | 유효한 QR 코드 스캔 시 즉시 지급 |
| 2단계 | 재방문 보너스 (동일 업소 재방문 시) | 랜덤 2,000 ~ 3,000P | 동일 업소 이전 방문 기록이 있을 때 |
| 3단계 | 후기 작성 | 랜덤 2,000 ~ 3,000P | 텍스트 후기 작성 시 지급 |

### 1.2 핵심 원칙

- QR 코드는 **1회용**: 한 번 사용된 QR 코드는 재사용 불가
- QR 코드에는 **verification_id** 포함: 업소 회원이 생성할 때 랜덤 고유 ID 발급, DB에 저장
- QR 코드 내용 형식: `https://philgo.com/company/qr-code-scanned.php?code={verification_id}`
- 하루 최대 **10개** QR 코드 생성 제한 (업소 당, 24시간 기준)
- 모든 포인트는 **서버에서 랜덤 생성**: `random_int()` 사용, 클라이언트 조작 방지
- 모든 API 호출은 **v7 API 아키텍처** 사용 (Controller → Service → Repository → DB)

### 1.3 기존 시스템 참고 (philgo-skill)

본 시스템은 필고의 기존 시스템을 참고하되, **v7 API로 구현**한다.

#### 기존 포인트 시스템 참고

- **sf_member.point**: 회원 포인트 잔액 필드 (직접 UPDATE)
- **sf_point_log**: 포인트 변동 내역 기록 테이블
  - `idx_member_from`, `idx_member_to`: 포인트 이동 주체
  - `module`: 모듈명 (예: 'adv', 'post', 'comment')
  - `action`: 액션명 (예: 'point-post-advertisement')
  - `point`: 포인트 (양수=지급, 음수=차감)
  - `stamp`: 거래 시간 (Unix timestamp)
- **기존 이벤트 포인트**: `PointConfig::$point_event_dates`에 기간 설정, `randomize_event_point()`로 배율 계산
- **포인트 변경 함수**: `change_user_points()` — sf_member.point 업데이트 + sf_point_log 기록

#### 기존 업소록 시스템 참고

- **company 테이블**: `idx`, `idx_member`(1회원 1업소), `status`('a'=승인), `name`, `category`, `receipt_name`
- **1회원 1업소 원칙**: idx_member UNIQUE 제약
- **관리자 승인 필요**: status='a'인 업소만 활성

#### 기존 QR 코드 스캔 화면 참고

- **company.qr_code_scanned.screen.dart**: 기존 먹방 이벤트 QR 스캔 결과 화면
  - `code`(verification_id)를 파라미터로 수신
  - verification_id로 QR 코드 조회하여 업소 정보 로드
  - `UserApi.me()`로 사용자 정보 로드
  - `V7FileUpload` 위젯으로 영수증 업로드
  - `ai.analyzeReceipt` API로 AI 영수증 분석
  - 라우트: `/company/qr-code-scanned.php?code={verificationId}`
  - **이 화면의 패턴을 참고하여** 포인트 이벤트 QR 스캔 결과 화면 구현

---

## 2. COT (Chain-of-Thought) 분석

### 2.1 문제 분석

**핵심 문제**: 업소 방문 인증을 위한 1회용 QR 코드 기반 포인트 시스템 구현

**기존 시스템과의 차이점**:
- 기존 먹방 이벤트: 영수증 촬영 → AI 분석 → 포인트 지급 (복잡, 시간 소요)
- 신규 포인트 이벤트: QR 코드 스캔 → 즉시 포인트 지급 (간단, 즉각적)

**기존 시스템 활용 가능 요소**:
- v7 API 4계층 구조 (Controller → Service → Repository → DB)
- PSR-4 Autoloading (`Philgo\PointEvent\*`)
- AuthService 2경로 인증 (Firebase ID Token / session_id)
- 기존 Company 모델/테이블 (업소 정보)
- 기존 sf_member.point 포인트 잔액 관리
- 기존 sf_point_log 포인트 변동 기록
- 기존 Upload 시스템 (후기 이미지 첨부 시 활용)
- 기존 라우터 패턴 (go_router, routeName + push)
- 기존 company.qr_code_scanned.screen.dart 화면 패턴

### 2.2 QR 코드 verification_id 메커니즘 상세

#### QR 코드 생성 흐름 (업소 회원)

```
업소 회원이 "QR 코드 생성" 버튼 클릭
    ↓
서버: AuthService::getLoginUser() → 로그인 확인
    ↓
서버: company 테이블에서 idx_member로 업소 조회
    → 업소가 없거나 status != 'a' → 에러
    ↓
서버: 24시간 이내 생성된 QR 코드 카운트 확인
    → 10개 이상 → 에러 ('하루 최대 10개까지 QR 코드를 생성할 수 있습니다.')
    ↓
서버: verification_id 생성
    $verification_id = bin2hex(random_bytes(16));  // 32자 hex
    → 128비트 랜덤 → 사실상 충돌/추측 불가
    ↓
서버: company_qr_codes 테이블에 INSERT
    - idx_company: 업소 idx
    - idx_member_created: 로그인 회원 idx
    - verification_id: 생성된 64자 hex
    - created_at: time()
    - expired_at: time() + 180 (180초 후)
    ↓
서버: QR 코드 URL 반환
    qr_url = "https://philgo.com/company/qr-code-scanned.php?code={verification_id}"
    ↓
Flutter: qr_flutter 패키지로 QR 이미지 렌더링
    사용자에게 QR 코드 이미지 표시
```

#### verification_id 보안 특성

| 항목 | 상세 |
|------|------|
| 생성 방식 | `bin2hex(random_bytes(32))` — PHP CSPRNG 사용 |
| 길이 | 64자 hex (256비트) |
| 충돌 확률 | 약 2^-256 (사실상 0) |
| 유효 기간 | 생성 후 180초(3분) |
| 사용 횟수 | 1회만 가능 (사용 후 used_at 업데이트) |
| DB 인덱스 | UNIQUE KEY로 중복 방지 |

### 2.3 QR 코드 스캔 흐름 상세 (사용자)

```
[업소 이벤트 화면 (CompanyEventScreen)]
    │ "QR 코드 스캔하기" 버튼 클릭
    ↓
[mobile_scanner ^7.2.0 카메라 오픈]
    │ MobileScannerController 설정:
    │   - detectionSpeed: DetectionSpeed.noDuplicates
    │   - formats: [BarcodeFormat.qr]
    │   - autoStart: true
    │
    │ MobileScanner 위젯의 onDetect 콜백:
    │   (BarcodeCapture capture) {
    │     final barcode = capture.barcodes.first;
    │     final rawValue = barcode.rawValue;
    │     // "https://philgo.com/company/qr-code-scanned.php?code={verification_id}"
    │     // URL에서 code 쿼리 파라미터 파싱
    │   }
    ↓
[QR 코드 파싱]
    │ rawValue = "https://philgo.com/company/qr-code-scanned.php?code=a1b2c3d4e5f6..."
    │ → Uri.parse(rawValue)
    │ → verification_id = uri.queryParameters['code'] → "a1b2c3d4e5f6..."
    │
    │ 형식 검증:
    │ - "https://philgo.com/company/qr-code-scanned.php" URL 확인
    │ - code 쿼리 파라미터가 64자 hex인지 확인
    │ → 형식 불일치 시: 에러 표시 ("유효하지 않은 QR 코드 형식입니다.")
    ↓
[company.qr_code_scanned.screen.dart 화면 오픈]
    │ CompanyQrCodeScannedScreen.push(context, verification_id)
    │ → 라우트: /company/qr-code-scanned.php?code={verification_id}
    │
    │ 화면 로드 시:
    │ 1. CompanyApi.get(idx) → 업소 정보 로드
    │ 2. UserApi.me() → 사용자 정보 로드
    │ 3. v7api('pointEvent.scanQr') → QR 검증 + 포인트 지급
    ↓
[서버: pointEvent.scanQr 처리]
    │ 1. AuthService::getLoginUser() → 로그인 확인
    │ 2. verification_id로 company_qr_codes 테이블 조회
    │    → 없으면: RuntimeException('유효하지 않은 QR 코드입니다.')
    │ 3. 만료 확인: expired_at < time()
    │    → 만료: RuntimeException('만료된 QR 코드입니다.')
    │ 4. 사용 여부: used_at IS NOT NULL
    │    → 이미 사용: RuntimeException('이미 사용된 QR 코드입니다.')
    │ 5. 자기 업소 QR 확인: idx_member_created == 현재 로그인 회원
    │    → 자기 QR: RuntimeException('자신의 업소 QR 코드는 스캔할 수 없습니다.')
    │ 6. QR 코드 사용 처리:
    │    company_qr_code_usages에 사용 기록 INSERT (result='s')
    │ 7. 재방문 여부 확인:
    │    SELECT COUNT(*) FROM company_qr_code_usages
    │    WHERE idx_member = ? AND idx_company = ? AND type = 'qr_scan'
    │    → 이전 기록 존재 = 재방문
    │ 8. 랜덤 포인트 생성: random_int(1000, 2000)
    │ 9. company_qr_code_usages INSERT (result='s')
    │ 10. sf_member.point 업데이트: point = point + {포인트}
    │ 11. sf_point_log INSERT (포인트 변동 기록)
    │ 12. 결과 반환:
    │     { points, is_revisit, revisit_bonus_available, idx_qr, company_name }
    ↓
[Flutter: QR 스캔 결과 표시]
    │ ① 획득 포인트 애니메이션 표시 (+1,500P!)
    │
    │ ② 재방문인 경우:
    │    "추가 보너스 받기" 버튼 활성화
    │    클릭 → v7api('pointEvent.claimRevisitBonus')
    │    → 서버: random_int(2000, 3000) 포인트 지급
    │    → 추가 포인트 표시 (+2,500P 보너스!)
    │
    │ ③ 후기 작성 영역:
    │    텍스트 입력 필드 + 사진 첨부 (V7FileUpload)
    │    "후기 등록" 버튼 클릭
    │    → v7api('pointEvent.submitReview')
    │    → 서버: random_int(2000, 3000) 포인트 지급
    │    → 추가 포인트 표시 (+2,800P 후기 보너스!)
    │
    │ ④ 총 획득 포인트 요약 표시
    ↓
[이동 선택 다이얼로그]
    ├─ "이벤트 응모" → EventEntryScreen
    └─ "홈으로" → HomeScreen
```

### 2.4 기술적 결정 사항

| 항목 | 결정 | 이유 |
|------|------|------|
| QR 코드 포맷 | `https://philgo.com/company/qr-code-scanned.php?code={verification_id}` | 딥링크 URL 형태, 웹/앱 모두 대응 |
| verification_id 생성 | PHP `bin2hex(random_bytes(32))` | 64자 hex, 256비트 CSPRNG, 충돌 불가 |
| QR 스캔 패키지 | `mobile_scanner: ^7.2.0` | Flutter 공식 추천, 높은 인식률 |
| QR 스캔 결과 화면 | `company.qr_code_scanned.screen.dart` 활용 | 기존 화면 패턴 참고, code(verification_id) 파라미터 전달 |
| 포인트 랜덤 생성 | PHP `random_int(min, max)` | 보안 강화된 CSPRNG 랜덤 함수 |
| 재방문 판단 | `company_qr_code_usages` 테이블에서 동일 업소 이력 확인 | 간단하고 정확 |
| 후기 저장 | `company_reviews` 테이블에 저장 | 결정 완료 - 별도 테이블 사용 |
| QR 만료 | 생성 후 180초(3분) | 보안 + 현장 인증 강화 |
| 하루 제한 | 업소 당 10개/24시간 | DB created_at 기준 카운트, 남용 방지 |
| 포인트 기록 | sf_point_log + company_qr_code_usages 이중 기록 | 기존 포인트 시스템과 호환 + 이벤트 전용 기록 |

---

## 3. DOD (Definition of Done) 정의

### 3.1 (1) QR 코드 생성 - DOD

| # | 완료 조건 | 검증 방법 |
|---|----------|----------|
| 1 | 업소록 등록 회원(status='a')만 QR 코드를 생성할 수 있다 | 비업소 회원 호출 시 에러, 미승인(status!='a') 업소 회원 호출 시 에러 |
| 2 | 매 호출마다 새로운 고유 verification_id가 생성된다 | 동일 업소에서 연속 호출 시 다른 verification_id 반환 |
| 3 | verification_id는 64자 hex(256비트 CSPRNG)이다 | 생성된 ID 형식 검증 (정규표현식 `/^[0-9a-f]{64}$/`) |
| 4 | 하루 최대 10개 제한이 적용된다 (24시간 기준) | 11번째 생성 시 에러 반환, 24시간 경과 후 카운트 리셋 |
| 5 | QR 코드가 DB company_qr_codes 테이블에 저장된다 | INSERT 레코드 존재 확인 |
| 6 | QR URL 형식이 `https://philgo.com/company/qr-code-scanned.php?code={verification_id}`이다 | 반환된 qr_url URL 파싱 검증 |
| 7 | expired_at이 created_at + 180 (180초)으로 설정된다 | DB 값 확인 |
| 8 | QR 코드가 Flutter 화면에 이미지로 표시된다 | qr_flutter 위젯 렌더링 확인 |
| 9 | 오늘 생성 횟수와 남은 횟수가 표시된다 | today_count, today_remaining 값 확인 |
| 10 | PEST Unit Test 통과 | 생성/제한/에러/형식 모든 케이스 테스트 |

### 3.2 (2) QR 코드 스캔 - DOD

| # | 완료 조건 | 검증 방법 |
|---|----------|----------|
| 1 | 로그인한 회원만 QR 코드를 스캔할 수 있다 | 미로그인 시 에러 반환 |
| 2 | mobile_scanner 카메라가 정상 오픈된다 | MobileScanner 위젯 렌더링, BarcodeFormat.qr 설정 |
| 3 | QR 코드 인식 후 올바르게 파싱된다 | URL 쿼리 파라미터에서 code(verification_id) 추출 |
| 4 | 잘못된 QR 코드 형식 시 에러 표시된다 | philgo:// prefix 없는 코드, 파라미터 불일치 시 에러 |
| 5 | company.qr_code_scanned.screen.dart 화면이 오픈된다 | 라우팅 확인 (code 파라미터 전달) |
| 6 | 서버에서 verification_id로 QR 코드를 검증한다 | DB 조회 결과 확인 |
| 7 | 유효한 QR 스캔 시 랜덤 1,000~2,000P 지급된다 | 포인트 기록 DB에 저장, 사용자 알림 |
| 8 | 이미 사용된 QR 코드 스캔 시 에러 반환된다 | used_at NOT NULL인 코드 거부 |
| 9 | 만료된 QR 코드(180초 경과) 스캔 시 에러 반환된다 | expired_at < time() 코드 거부 |
| 10 | 자기 업소의 QR 코드는 스캔할 수 없다 | idx_member_created == 로그인 회원 시 에러 |
| 11 | 스캔 성공 시 QR 코드가 사용됨 상태로 변경된다 | used_at, idx_member_used 업데이트 |
| 12 | sf_member.point가 업데이트된다 | point = point + 획득포인트 |
| 13 | sf_point_log에 기록된다 | module='point_event', action='qr_scan' |
| 14 | company_qr_code_usages에 기록된다 | type='qr_scan', points=획득포인트 |
| 15 | 재방문 여부가 응답에 포함된다 | is_revisit, revisit_bonus_available 필드 |
| 16 | 포인트 획득 알림 애니메이션이 표시된다 | Flutter 위젯 확인 |
| 17 | PEST Unit Test 통과 | 유효/무효/만료/자가스캔/재방문판단 모든 케이스 |

### 3.3 (3) 재방문 보너스 - DOD

| # | 완료 조건 | 검증 방법 |
|---|----------|----------|
| 1 | 동일 업소 재방문 여부가 정확히 판단된다 | company_qr_code_usages에서 이전 방문(result='s') 이력 확인 |
| 2 | 재방문 시에만 보너스 버튼이 활성화된다 | 처음 방문 시 보너스 버튼 비활성화/숨김 |
| 3 | 보너스 버튼 클릭 시 랜덤 2,000~3,000P 추가 지급된다 | random_int(2000, 3000) 범위 확인 |
| 4 | sf_point_log에 action='qr_revisit'로 기록된다 | DB 레코드 확인 |
| 5 | sf_member.point가 업데이트된다 | point = point + 재방문보너스 |
| 6 | sf_point_log에 기록된다 | module='point_event', action='revisit' |
| 7 | 같은 QR 스캔 건에서 보너스는 1회만 가능하다 | 중복 클릭 시 에러 (HTTP 208 soft error) |
| 8 | PEST Unit Test 통과 | 첫방문/재방문/중복클릭 모든 케이스 |

### 3.4 (4) 후기 작성 - DOD

| # | 완료 조건 | 검증 방법 |
|---|----------|----------|
| 1 | 후기 입력 UI가 표시된다 | 텍스트 입력 필드 + 사진 첨부 버튼 (V7FileUpload) |
| 2 | 후기 등록 시 서버에 저장된다 | company_reviews 테이블에 content 저장 |
| 3 | 후기 등록 성공 시 랜덤 2,000~3,000P 추가 지급된다 | random_int(2000, 3000) 범위 확인 |
| 4 | company_reviews에 후기가 저장되고 sf_point_log에 기록된다 | DB 레코드 확인 |
| 5 | sf_member.point가 업데이트된다 | point = point + 후기포인트 |
| 6 | sf_point_log에 기록된다 | module='point_event', action='review' |
| 7 | 같은 QR 스캔 건에서 후기 포인트는 1회만 가능하다 | 중복 등록 시 에러 (HTTP 208 soft error) |
| 8 | 포인트 획득 알림 애니메이션이 표시된다 | Flutter 위젯 확인 |
| 9 | PEST Unit Test 통과 | 후기등록/포인트지급/중복방지 모든 케이스 |

### 3.5 (5) 이동 선택 - DOD

| # | 완료 조건 | 검증 방법 |
|---|----------|----------|
| 1 | 모든 포인트 획득 과정 완료 후 선택 다이얼로그가 표시된다 | 2개 버튼: "이벤트 응모" / "홈으로" |
| 2 | "이벤트 응모" 선택 시 EventEntryScreen으로 이동한다 | 라우팅 확인 |
| 3 | "홈으로" 선택 시 홈 화면으로 이동한다 | 라우팅 확인 |

---

## 4. 데이터베이스 설계

### 4.1 추가 DB 테이블 필요성 분석

#### 기존 테이블 활용 분석

| 기존 테이블 | 활용 방안 | 추가 필요 여부 |
|------------|----------|--------------|
| `sf_member` | point 필드 업데이트 (포인트 잔액) | ❌ 추가 불필요 — 기존 그대로 사용 |
| `sf_point_log` | 포인트 변동 기록 (module/action/point) | ❌ 추가 불필요 — 기존 그대로 사용 |
| `company` | 업소 정보 조회 (idx, idx_member, status, name) | ❌ 추가 불필요 — 기존 그대로 사용 |
| `company_reviews` | 방문 후기 저장 (content, reward_points 등) | ✅ **필수** — 후기 전용 테이블 |

#### 실제 구현 테이블

> **⚠️ 참고**: 본 문서는 초기 설계 문서이다. 실제 구현에서는 아래 3개 테이블을 사용한다.
> 테이블 DDL 및 관계도 상세는 [v7-event-overview.md](v7-event-overview.md) 7장 "DB 스키마 요약"을 참조한다.

| 실제 테이블 | 용도 | 상세 참조 |
|---|---|---|
| `company_qr_codes` | QR 코드 발행/검증/만료 관리 | [v7-event-overview.md §4.8](v7-event-overview.md#48-데이터-관계도) |
| `company_qr_code_usages` | QR 스캔 기록 (성공/실패/거부) | [v7-event-overview.md §7](v7-event-overview.md#7-db-스키마-요약) |
| `company_reviews` | 방문 후기 + 포인트 적립 | [v7-event-overview.md §7](v7-event-overview.md#7-db-스키마-요약) |

### 4.5 sf_point_log 기록 규칙

포인트 이벤트에서 sf_point_log에 기록할 때 다음 규칙을 따른다:

```php
// QR 코드 스캔 포인트 기록
INSERT INTO sf_point_log SET
  idx_member_from = 0,              // 시스템에서 지급
  idx_member_to = {회원_idx},       // 포인트 수령 회원
  module = 'point_event',           // 모듈명
  action = 'qr_scan',              // 액션명
  etc = 'company:{idx_company}',    // 업소 정보
  idx_post = 0,                     // 게시글 관련 없음
  point = {1000~2000},             // 지급 포인트 (양수)
  stamp = UNIX_TIMESTAMP()

// 재방문 보너스 기록
INSERT INTO sf_point_log SET
  module = 'point_event',
  action = 'revisit',
  point = {2000~3000}

// 후기 포인트 기록
INSERT INTO sf_point_log SET
  module = 'point_event',
  action = 'review',
  point = {2000~3000}
```

---

## 5. v7 API 설계

### 5.1 모듈 구조 (PSR-4)

```
lib/point_event/
├── PointEventController.php    # API 엔드포인트 (6개 메서드)
├── PointEventService.php       # 비즈니스 로직 (포인트 계산, 검증)
├── PointEventRepository.php    # DB CRUD (Prepared Statement)
├── PointEventQrEntity.php      # QR 코드 Entity
└── PointEventHistoryEntity.php # 참여 기록 Entity
```

**composer.json PSR-4 등록** (기존에 이미 등록되어 있을 수 있음):
```json
{
  "autoload": {
    "psr-4": {
      "Philgo\\PointEvent\\": "lib/point_event/"
    }
  }
}
```

**api.php 라우팅 자동 매핑**:
```
method: "pointEvent.generateQr"
  → PascalCase: "PointEvent"
  → FQCN: "Philgo\PointEvent\PointEventController"
  → 메서드: $ctrl->generateQr($input)
```

### 5.2 API 엔드포인트 목록

| API 메서드 | 용도 | 인증 | 포인트 범위 |
|-----------|------|------|-----------|
| `pointEvent.generateQr` | QR 코드 생성 | 필수 (업소 회원) | - |
| `pointEvent.scanQr` | QR 코드 스캔 + 포인트 지급 | 필수 (일반 회원) | 1,000 ~ 2,000P |
| `pointEvent.claimRevisitBonus` | 재방문 보너스 | 필수 | 2,000 ~ 3,000P |
| `pointEvent.submitReview` | 후기 등록 + 포인트 지급 | 필수 | 2,000 ~ 3,000P |
| `pointEvent.history` | 참여 기록 조회 | 필수 | - |
| `pointEvent.qrList` | QR 목록 조회 | 필수 (업소 회원) | - |

### 5.3 API 상세 명세

#### (1) `pointEvent.generateQr` - QR 코드 생성

```
POST api.php
Body: { "method": "pointEvent.generateQr" }
```

**요청 파라미터**: 없음 (인증 토큰으로 업소 회원 확인)

**Controller 코드 흐름**:
```php
public function generateQr(array $input): array
{
    // 1. 인증
    $user = AuthService::getLoginUser();
    if (!$user) throw new RuntimeException('로그인이 필요합니다.');

    // 2. 업소 확인
    $company = $this->repo->findCompanyByMember($user['idx']);
    if (!$company || $company['status'] !== 'a') {
        throw new RuntimeException('업소록에 등록된 회원만 QR 코드를 생성할 수 있습니다.');
    }

    // 3. 일일 제한 확인 (24시간 기준)
    $todayCount = $this->repo->countQrCreatedSince(
        $company['idx'],
        time() - 86400
    );
    if ($todayCount >= 10) {
        throw new RuntimeException('하루 최대 10개까지 QR 코드를 생성할 수 있습니다.');
    }

    // 4. verification_id 생성 (64자 hex)
    $verificationId = bin2hex(random_bytes(32));

    // 5. DB 저장
    $now = time();
    $idx = $this->repo->insertQr([
        'idx_company' => $company['idx'],
        'idx_member_created' => $user['idx'],
        'verification_id' => $verificationId,
        'created_at' => $now,
        'expired_at' => $now + 180,
    ]);

    // 6. 반환
    return [
        'idx' => $idx,
        'idx_company' => $company['idx'],
        'verification_id' => $verificationId,
        'qr_url' => "https://philgo.com/company/qr-code-scanned.php?code={$verificationId}",
        'created_at' => $now,
        'expired_at' => $now + 180,
        'today_count' => $todayCount + 1,
        'today_remaining' => 10 - $todayCount - 1,
    ];
}
```

**성공 응답**:
```json
{
  "idx": 1,
  "idx_company": 1025,
  "verification_id": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6",
  "qr_url": "https://philgo.com/company/qr-code-scanned.php?code=a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6",
  "created_at": 1740700000,
  "expired_at": 1740700180,
  "today_count": 3,
  "today_remaining": 7
}
```

#### (2) `pointEvent.scanQr` - QR 코드 스캔

```
POST api.php
Body: { "method": "pointEvent.scanQr", "verification_id": "a1b2..." }
```

**요청 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `verification_id` | string | Y | 스캔한 QR 코드의 verification_id (32자 hex) |

**Service 로직 상세**:
```php
public function scanQr(array $user, string $verificationId): array
{
    // 1. QR 코드 조회
    $qr = $this->repo->findQrByVerificationId($verificationId);
    if (!$qr) throw new RuntimeException('유효하지 않은 QR 코드입니다.');

    // 2. 만료 확인
    if ($qr['expired_at'] < time()) {
        throw new RuntimeException('만료된 QR 코드입니다.');
    }

    // 3. 사용 여부 확인
    if ($qr['used_at'] !== null) {
        throw new RuntimeException('이미 사용된 QR 코드입니다.');
    }

    // 4. 자기 업소 확인
    if ($qr['idx_member_created'] == $user['idx']) {
        throw new RuntimeException('자신의 업소 QR 코드는 스캔할 수 없습니다.');
    }

    // 5. QR 사용 처리
    $this->repo->markQrUsed($qr['idx'], $user['idx'], time());

    // 6. 재방문 여부 확인
    $isRevisit = $this->repo->hasVisitHistory(
        $user['idx'],
        $qr['idx_company']
    );

    // 7. 랜덤 포인트 생성 (1,000 ~ 2,000)
    $points = random_int(1000, 2000);

    // 8. 포인트 지급 (PointLogService::changePoints())
    $this->grantPoints($user['idx'], $qr['idx_company'], $qr['idx'], 'qr_scan', $points);

    // 9. 업소 정보 조회
    $company = $this->repo->findCompany($qr['idx_company']);

    return [
        'idx_qr' => $qr['idx'],
        'idx_company' => $qr['idx_company'],
        'company_name' => $company['name'] ?? '',
        'type' => 'qr_scan',
        'points' => $points,
        'is_revisit' => $isRevisit,
        'revisit_bonus_available' => $isRevisit,
    ];
}

/**
 * 포인트 지급: PointLogService::changePoints() (sf_member.point 업데이트 + sf_point_log 기록)
 */
private function grantPoints(int $idxMember, int $idxCompany, int $idxQr, string $type, int $points): void
{
    $pdo = Db::pdo();

    // sf_member.point 업데이트
    $stmt = $pdo->prepare('UPDATE sf_member SET point = point + ? WHERE idx = ?');
    $stmt->execute([$points, $idxMember]);

    // sf_point_log 기록
    $stmt = $pdo->prepare('INSERT INTO sf_point_log SET
        idx_member_from = 0, idx_member_to = ?, module = ?, action = ?,
        etc = ?, point = ?, stamp = ?');
    $stmt->execute([
        $idxMember,
        'point_event',
        $type,
        "company:{$idxCompany}",
        $points,
        time(),
    ]);

    // company_qr_code_usages 기록은 scanQrCode()에서 처리됨
    // PointLogService::changePoints()로 sf_point_log INSERT
        idx_member = ?, idx_company = ?, idx_qr = ?, type = ?, points = ?, created_at = ?');
    $stmt->execute([$idxMember, $idxCompany, $idxQr, $type, $points, time()]);
}
```

**성공 응답**:
```json
{
  "idx_qr": 1,
  "idx_company": 1025,
  "company_name": "한인마트 마닐라",
  "type": "qr_scan",
  "points": 1500,
  "is_revisit": true,
  "revisit_bonus_available": true
}
```

#### (3) `pointEvent.claimRevisitBonus` - 재방문 보너스

```
POST api.php
Body: { "method": "pointEvent.claimRevisitBonus", "idx_qr": 1 }
```

**요청 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `idx_qr` | int | Y | QR 코드 idx |

**처리 로직**:
```
1. AuthService::getLoginUser() → 로그인 확인
2. idx_qr로 QR 코드 조회 → idx_member_used == 현재 회원인지 확인
   → 불일치: RuntimeException('권한이 없습니다.')
3. 재방문 여부 확인: company_qr_code_usages에서 이전 방문(result='s') 이력 존재?
   → 이전 이력 없으면: RuntimeException('재방문 보너스 대상이 아닙니다.')
4. 이미 보너스 수령 확인: 같은 idx_qr + type='revisit' 이력 존재?
   → 이미 수령: soft_error('이미 재방문 보너스를 받았습니다.') (HTTP 208)
5. 랜덤 포인트 생성: random_int(2000, 3000)
6. grantPoints() 호출 (sf_member + sf_point_log)
7. 결과 반환
```

**성공 응답**:
```json
{
  "idx_qr": 1,
  "idx_company": 1025,
  "type": "revisit",
  "points": 2500
}
```

#### (4) `pointEvent.submitReview` - 후기 등록

```
POST api.php
Body: { "method": "pointEvent.submitReview", "idx_qr": 1, "content": "정말 맛있었습니다!", "file_idxs": "101,102" }
```

**요청 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `idx_qr` | int | Y | QR 코드 idx |
| `content` | string | Y | 후기 내용 |
| `file_idxs` | string | N | 첨부 파일 idx 목록 (콤마 구분) |

**처리 로직**:
```
1. AuthService::getLoginUser() → 로그인 확인
2. idx_qr로 QR 코드 조회 → idx_member_used == 현재 회원인지 확인
3. content 유효성 검증 (빈 문자열 불가)
4. 이미 후기 포인트 수령 확인: 같은 idx_qr + type='review' 이력 존재?
   → 이미 수령: soft_error('이미 후기 포인트를 받았습니다.') (HTTP 208)
5. 후기 내용 저장:
   - company_reviews에 content 필드에 저장
   - (선택) 별도 Post 레코드 생성 가능
6. 랜덤 포인트 생성: random_int(2000, 3000)
7. grantPoints() 호출 (sf_member + sf_point_log)
8. 결과 반환
```

**성공 응답**:
```json
{
  "idx_qr": 1,
  "idx_company": 1025,
  "type": "review",
  "points": 2800,
  "content": "정말 맛있었습니다!"
}
```

#### (5) `pointEvent.history` - 참여 기록 조회

```
POST api.php
Body: { "method": "pointEvent.history", "limit": 20, "offset": 0 }
```

**요청 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `limit` | int | N | 조회 개수 (기본 20, 최대 100) |
| `offset` | int | N | 오프셋 (기본 0) |

**SQL 쿼리**:
```sql
SELECT h.*, c.name as company_name
FROM company_qr_code_usages h
LEFT JOIN company c ON h.idx_company = c.idx
WHERE h.idx_member = ?
ORDER BY h.created_at DESC
LIMIT ? OFFSET ?
```

**성공 응답**:
```json
{
  "total": 15,
  "items": [
    {
      "idx": 3,
      "idx_company": 1025,
      "company_name": "한인마트 마닐라",
      "idx_qr": 1,
      "type": "review",
      "points": 2800,
      "created_at": 1740700300
    },
    {
      "idx": 2,
      "idx_company": 1025,
      "company_name": "한인마트 마닐라",
      "idx_qr": 1,
      "type": "revisit",
      "points": 2500,
      "created_at": 1740700200
    },
    {
      "idx": 1,
      "idx_company": 1025,
      "company_name": "한인마트 마닐라",
      "idx_qr": 1,
      "type": "qr_scan",
      "points": 1500,
      "created_at": 1740700100
    }
  ]
}
```

#### (6) `pointEvent.qrList` - QR 코드 목록 (업소 회원용)

```
POST api.php
Body: { "method": "pointEvent.qrList", "limit": 20, "offset": 0 }
```

**성공 응답**:
```json
{
  "total": 5,
  "today_count": 3,
  "today_remaining": 7,
  "items": [
    {
      "idx": 5,
      "verification_id": "a1b2c3...",
      "qr_url": "https://philgo.com/company/qr-code-scanned.php?code=a1b2c3...",
      "created_at": 1740700000,
      "expired_at": 1740700180,
      "used_at": null,
      "idx_member_used": null,
      "is_expired": false,
      "is_used": false
    }
  ]
}
```

---

## 6. Flutter 앱 설계

### 6.1 mobile_scanner 통합 상세

#### 패키지 설정

```yaml
# pubspec.yaml
dependencies:
  mobile_scanner: ^7.2.0
```

#### iOS 권한 설정 (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>QR 코드 스캔을 위해 카메라 접근이 필요합니다.</string>
```

#### QR 코드 스캔 구현 패턴

```dart
/// company_event.screen.dart의 "QR 코드 스캔하기" 버튼 onPressed:
void _onScanButtonPressed(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _QrScannerPage(),
    ),
  );
}

/// QR 스캐너 페이지 (전체 화면 카메라)
class _QrScannerPage extends StatefulWidget { ... }

class _QrScannerPageState extends State<_QrScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,  // 중복 감지 방지
    formats: [BarcodeFormat.qr],                   // QR 코드만
    autoStart: true,
  );
  bool _isProcessing = false;  // 중복 처리 방지

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.qrScanTitle)),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture capture) {
          if (_isProcessing) return;
          final barcode = capture.barcodes.firstOrNull;
          if (barcode == null || barcode.rawValue == null) return;

          final rawValue = barcode.rawValue!;
          // "https://philgo.com/company/qr-code-scanned.php?code={verification_id}" 파싱
          final uri = Uri.tryParse(rawValue);
          if (uri == null ||
              uri.host != 'philgo.com' ||
              uri.path != '/company/qr-code-scanned.php') {
            _showError('유효하지 않은 QR 코드 형식입니다.');
            return;
          }

          _isProcessing = true;
          controller.stop();  // 카메라 중지

          final verificationId = uri.queryParameters['code'];

          if (verificationId == null || verificationId.length != 64) {
            _showError('QR 코드 데이터가 올바르지 않습니다.');
            return;
          }

          // 기존 화면으로 이동
          Navigator.of(context).pop();  // 스캐너 닫기
          CompanyQrCodeScannedScreen.push(context, verificationId);
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

### 6.2 화면 흐름도

```
[홈 화면]
  │ 퀵메뉴: "업소이벤트" 클릭
  ▼
[CompanyEventScreen] ← 현재 구현 완료
  │ "QR 코드 스캔하기" 버튼 클릭
  ▼
[_QrScannerPage] ← mobile_scanner 카메라
  │ QR 코드 인식
  │ URL 파싱: "https://philgo.com/company/qr-code-scanned.php?code={verification_id}"
  │ 유효성 검증 (host, path, code 64자 hex)
  ▼
[CompanyQrCodeScannedScreen] ← 기존 화면 활용/수정
  │ 파라미터: verificationId (64자 hex, URL의 code 파라미터)
  │
  │ 화면 초기화 시:
  │ 1. CompanyApi.get(idx) → 업소 정보 로드
  │ 2. UserApi.me() → 사용자 정보 로드
  │ 3. v7api('pointEvent.scanQr', data: {'verification_id': vid})
  │    → QR 검증 + 포인트 지급
  │
  ├─ 에러 시: 에러 메시지 표시 + "돌아가기" 버튼
  │
  ├─ 성공 시:
  │   │ ① 획득 포인트 표시 (flutter_animate 애니메이션)
  │   │    "+1,500P 포인트 획득!" 텍스트 애니메이션
  │   │
  │   ├─ is_revisit == true인 경우:
  │   │   │ ② "추가 보너스 받기" 버튼 활성화
  │   │   │   클릭 → v7api('pointEvent.claimRevisitBonus')
  │   │   │   → 서버: random_int(2000, 3000) 포인트 지급
  │   │   │   → "+2,500P 재방문 보너스!" 애니메이션
  │   │   ▼
  │   │
  │   │ ③ 후기 작성 영역 표시
  │   │   │ - 텍스트 입력 필드 (TextField)
  │   │   │ - 사진 첨부 (V7FileUpload 위젯 활용)
  │   │   │ - "후기 등록하고 포인트 받기" 버튼
  │   │   │   클릭 → v7api('pointEvent.submitReview')
  │   │   │   → 서버: random_int(2000, 3000) 포인트 지급
  │   │   │   → "+2,800P 후기 포인트!" 애니메이션
  │   │   ▼
  │   │
  │   │ ④ 총 획득 포인트 요약
  │   │    "총 6,800P 획득!" (QR 1,500 + 재방문 2,500 + 후기 2,800)
  │   ▼
  │
  │ ⑤ 이동 선택 다이얼로그
  │   ├─ "이벤트 응모" → EventEntryScreen
  │   └─ "홈으로" → HomeScreen (pop to root)
  ▼
```

### 6.3 기존 CompanyQrCodeScannedScreen 수정 방안

기존 `company.qr_code_scanned.screen.dart`는 **먹방 이벤트** (영수증 기반)용 화면이다.
**포인트 이벤트** (QR 기반)와는 다른 흐름이므로, 두 가지 접근 방안이 있다:

#### 방안 A: 기존 화면 확장 (권장)

기존 CompanyQrCodeScannedScreen에 QR 코드 유형 판별 로직을 추가하여,
QR 코드 종류에 따라 다른 UI를 표시한다.

```dart
/// 화면 초기화 시 QR 코드 유형에 따라 분기
void initState() {
  super.initState();
  _loadCompany();
  _loadUserInfo();

  // verification_id로 포인트 이벤트 QR인지 확인
  _processPointEventQr();
}

Future<void> _processPointEventQr() async {
  try {
    final result = await v7api('pointEvent.scanQr', data: {
      'verification_id': widget.verificationId,
    });
    // 포인트 이벤트 QR 성공 → 포인트 획득 UI 표시
    setState(() { pointEventResult = result; });
  } catch (e) {
    // 포인트 이벤트 QR이 아니면 기존 먹방 이벤트 흐름
    setState(() { isLegacyFlow = true; });
  }
}
```

#### 방안 B: 별도 화면 생성

새로운 `point_event_scan_result.screen.dart`를 만들어 완전히 분리한다.
- 장점: 기존 화면 수정 없이 독립적 구현
- 단점: 중복 코드 발생 가능

**결정**: 구현 시 기존 화면의 복잡도와 결합도를 보고 결정한다.
기존 화면이 이미 1052줄로 큰 편이므로, **방안 B (별도 화면)**가 유지보수에 유리할 수 있다.

### 6.4 신규/수정 파일 목록

#### Flutter 파일

| 파일 | 상태 | 설명 |
|------|------|------|
| `lib/screens/event/company_event.screen.dart` | 수정 | QR 스캔 버튼에 mobile_scanner 연결 |
| `lib/screens/event/qr_scanner.screen.dart` | 신규 | mobile_scanner 카메라 전체화면 |
| `lib/screens/event/point_event_result.screen.dart` | 신규 | 포인트 이벤트 QR 스캔 결과 + 삼단콤보 UI |
| `lib/screens/event/event_entry.screen.dart` | 수정 | 더미 데이터 → API 연동 (pointEvent.history) |
| `lib/v7_api/point_event_api.dart` | 신규 | v7 API 래퍼 클래스 (6개 메서드) |
| `lib/router.dart` | 수정 | 신규 화면 라우트 추가 |
| `lib/l10n/app_*.arb` (4개) | 수정 | 신규 i18n 키 추가 |

#### PHP 서버 파일

| 파일 | 상태 | 설명 |
|------|------|------|
| `lib/point_event/PointEventController.php` | 수정/확장 | 6개 API 메서드 추가 |
| `lib/point_event/PointEventService.php` | 수정/확장 | 비즈니스 로직 추가 |
| `lib/point_event/PointEventRepository.php` | 수정/확장 | DB CRUD 추가 |
| `lib/point_event/PointEventQrEntity.php` | 신규 | QR 코드 Entity |
| `lib/point_event/PointEventHistoryEntity.php` | 신규 | 참여 기록 Entity |
| `tests/Unit/PointEventQrTest.php` | 신규 | QR 기능 PEST Unit Test |
| `composer.json` | 확인 | PSR-4 네임스페이스 확인 |

### 6.5 Flutter v7 API 래퍼 클래스

```dart
/// lib/v7_api/point_event_api.dart

import 'package:philgo/v7_api/v7_api.dart';

/// 포인트 이벤트 v7 API 래퍼 클래스
///
/// QR 코드 기반 삼단콤보 포인트 이벤트 API를 제공한다.
/// 모든 메서드는 v7api() 함수를 통해 서버와 통신한다.
class PointEventApi {
  PointEventApi._();

  /// QR 코드 생성 (업소 회원용)
  /// API: pointEvent.generateQr (인증 필수, 업소 회원만)
  /// 반환: idx, verification_id, qr_url, today_count, today_remaining
  static Future<Map<String, dynamic>> generateQr() async {
    return await v7api('pointEvent.generateQr');
  }

  /// QR 코드 스캔 (일반 회원용)
  /// API: pointEvent.scanQr (인증 필수)
  /// 반환: points, is_revisit, revisit_bonus_available, idx_qr, company_name
  static Future<Map<String, dynamic>> scanQr(String verificationId) async {
    return await v7api('pointEvent.scanQr', data: {
      'verification_id': verificationId,
    });
  }

  /// 재방문 보너스 요청
  /// API: pointEvent.claimRevisitBonus (인증 필수)
  /// 반환: points, type='revisit'
  static Future<Map<String, dynamic>> claimRevisitBonus(int idxQr) async {
    return await v7api('pointEvent.claimRevisitBonus', data: {
      'idx_qr': idxQr,
    });
  }

  /// 후기 등록 + 포인트 요청
  /// API: pointEvent.submitReview (인증 필수)
  /// 반환: points, type='review'
  static Future<Map<String, dynamic>> submitReview({
    required int idxQr,
    required String content,
    String? fileIdxs,
  }) async {
    return await v7api('pointEvent.submitReview', data: {
      'idx_qr': idxQr,
      'content': content,
      if (fileIdxs != null) 'file_idxs': fileIdxs,
    });
  }

  /// 내 이벤트 참여 기록 조회
  /// API: pointEvent.history (인증 필수)
  /// 반환: total, items[]
  static Future<Map<String, dynamic>> history({
    int limit = 20,
    int offset = 0,
  }) async {
    return await v7api('pointEvent.history', data: {
      'limit': limit,
      'offset': offset,
    });
  }

  /// QR 코드 목록 조회 (업소 회원용)
  /// API: pointEvent.qrList (인증 필수, 업소 회원만)
  /// 반환: total, today_count, today_remaining, items[]
  static Future<Map<String, dynamic>> qrList({
    int limit = 20,
    int offset = 0,
  }) async {
    return await v7api('pointEvent.qrList', data: {
      'limit': limit,
      'offset': offset,
    });
  }
}
```

---

## 7. 에러 처리 설계

### 7.1 에러 코드 목록

| 에러 메시지 | 발생 상황 | HTTP | 처리 방식 |
|------------|----------|------|---------|
| `'로그인이 필요합니다.'` | 미인증 상태 | 200 | RuntimeException |
| `'업소록에 등록된 회원만 QR 코드를 생성할 수 있습니다.'` | 비업소 회원이 QR 생성 시도 | 200 | RuntimeException |
| `'하루 최대 10개까지 QR 코드를 생성할 수 있습니다.'` | 업소 일일 제한 초과 | 200 | RuntimeException |
| `'유효하지 않은 QR 코드입니다.'` | DB에 없는 verification_id | 200 | RuntimeException |
| `'만료된 QR 코드입니다.'` | 180초 경과 (expired_at < time()) | 200 | RuntimeException |
| `'이미 사용된 QR 코드입니다.'` | used_at NOT NULL | 200 | RuntimeException |
| `'자신의 업소 QR 코드는 스캔할 수 없습니다.'` | idx_member_created == 로그인 회원 | 200 | RuntimeException |
| `'이미 재방문 보너스를 받았습니다.'` | 중복 보너스 요청 | 208 | soft_error |
| `'재방문 보너스 대상이 아닙니다.'` | 첫 방문인데 보너스 요청 | 200 | RuntimeException |
| `'이미 후기 포인트를 받았습니다.'` | 중복 후기 포인트 | 208 | soft_error |
| `'후기 내용을 입력해주세요.'` | content 빈 문자열 | 200 | RuntimeException |
| `'권한이 없습니다.'` | QR 사용자와 요청자 불일치 | 200 | RuntimeException |

### 7.2 Flutter 에러 처리 패턴

```dart
/// v7api()는 success:false 응답 시 자동으로 Exception throw
/// Flutter에서는 try-catch로 처리

// QR 스캔 에러 처리
try {
  final result = await PointEventApi.scanQr(verificationId);
  // 성공: 포인트 표시, 재방문 여부 확인
  setState(() {
    scanResult = result;
    isSuccess = true;
  });
} catch (e) {
  // 에러 메시지를 사용자에게 표시
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

// 재방문 보너스 에러 처리 (HTTP 208 soft error 포함)
try {
  final result = await PointEventApi.claimRevisitBonus(idxQr);
  // 성공: 보너스 포인트 표시
} catch (e) {
  // "이미 재방문 보너스를 받았습니다." 등
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
```

---

## 8. 보안 고려사항

| 항목 | 위협 | 대응 | 상세 |
|------|------|------|------|
| QR 코드 위조 | 악의적 QR 코드 생성 | 64자 hex (256bit) CSPRNG 랜덤 | bin2hex(random_bytes(32)), 추측 불가 |
| QR 코드 재사용 | 동일 QR 코드 다수 사용 | used_at NOT NULL 체크 | 1회 사용 후 폐기 |
| QR 코드 스크린샷 공유 | QR 이미지 공유로 타인 사용 | 180초 만료 + 1회용 | 피해 최소화 |
| 자가 포인트 부여 | 업소 회원이 자기 QR 스캔 | idx_member_created 비교 | 자기 업소 QR 스캔 차단 |
| 포인트 조작 | 클라이언트에서 포인트 값 조작 | 서버에서만 random_int() 생성 | 클라이언트 불신 원칙 |
| 중복 보너스/후기 | 동일 QR로 반복 보너스/후기 | idx_qr + type 조합 중복 검사 | DB 제약 |
| SQL Injection | 파라미터 조작 | Prepared Statement 필수 | v7 원칙, pdo()->prepare() |
| 무작위 대입 공격 | verification_id 무작위 시도 | 256비트 엔트로피 | 사실상 추측 불가 (2^256 경우의 수) |
| 일일 제한 우회 | 시간대 조작으로 제한 우회 | 서버 시간 기준 24시간 | 클라이언트 시간 무시 |
| 권한 탈취 | 타인의 QR 결과에 보너스/후기 요청 | idx_member_used 검증 | QR 사용자와 요청자 일치 확인 |

---

## 9. PEST Unit Test 설계

### 9.1 테스트 파일 구조

```
tests/Unit/PointEventQrTest.php    # QR 코드 생성/스캔/보너스/후기 테스트
```

### 9.2 테스트 케이스 목록

```php
describe('PointEventController - QR 기반 삼단콤보', function () {

    // === QR 코드 생성 ===
    it('generateQr() - 미인증 시 에러');
    it('generateQr() - 비업소 회원 시 에러');
    it('generateQr() - 미승인(status!=a) 업소 회원 시 에러');
    it('generateQr() - 정상 생성 성공');
    it('generateQr() - verification_id가 64자 hex인지 확인');
    it('generateQr() - qr_url 형식 확인 (https://philgo.com/company/qr-code-scanned.php?code={verification_id})');
    it('generateQr() - expired_at = created_at + 180 확인');
    it('generateQr() - 연속 생성 시 서로 다른 verification_id');
    it('generateQr() - 11번째 생성 시 일일 제한 에러');
    it('generateQr() - 24시간 경과 후 카운트 리셋');

    // === QR 코드 스캔 ===
    it('scanQr() - 미인증 시 에러');
    it('scanQr() - 존재하지 않는 verification_id 시 에러');
    it('scanQr() - 만료된 QR 코드 시 에러');
    it('scanQr() - 이미 사용된 QR 코드 시 에러');
    it('scanQr() - 자기 업소 QR 스캔 시 에러');
    it('scanQr() - 정상 스캔 성공');
    it('scanQr() - 포인트가 1000~2000 범위인지 확인');
    it('scanQr() - used_at 업데이트 확인');
    it('scanQr() - sf_member.point 증가 확인');
    it('scanQr() - sf_point_log 기록 확인');
    it('scanQr() - company_qr_code_usages 기록 확인 (result=s)');
    it('scanQr() - 첫 방문 시 is_revisit=false');
    it('scanQr() - 재방문 시 is_revisit=true');

    // === 재방문 보너스 ===
    it('claimRevisitBonus() - 미인증 시 에러');
    it('claimRevisitBonus() - QR 사용자 불일치 시 에러');
    it('claimRevisitBonus() - 첫 방문인데 보너스 요청 시 에러');
    it('claimRevisitBonus() - 재방문 보너스 정상 지급');
    it('claimRevisitBonus() - 포인트가 2000~3000 범위인지 확인');
    it('claimRevisitBonus() - 중복 요청 시 HTTP 208 soft error');
    it('claimRevisitBonus() - sf_member.point 증가 확인');

    // === 후기 등록 ===
    it('submitReview() - 미인증 시 에러');
    it('submitReview() - QR 사용자 불일치 시 에러');
    it('submitReview() - content 빈 문자열 시 에러');
    it('submitReview() - 후기 등록 + 포인트 정상 지급');
    it('submitReview() - 포인트가 2000~3000 범위인지 확인');
    it('submitReview() - 중복 요청 시 HTTP 208 soft error');
    it('submitReview() - sf_member.point 증가 확인');
    it('submitReview() - company_reviews에 content 저장 확인');

    // === 기록 조회 ===
    it('history() - 미인증 시 에러');
    it('history() - 정상 조회 (최신순 정렬)');
    it('history() - limit/offset 페이지네이션');

    // === QR 목록 ===
    it('qrList() - 미인증 시 에러');
    it('qrList() - 비업소 회원 시 에러');
    it('qrList() - 정상 조회');
    it('qrList() - today_count, today_remaining 정확성');
});
```

### 9.3 테스트 실행

```bash
# 전체 포인트 이벤트 QR 테스트
./vendor/bin/pest tests/Unit/PointEventQrTest.php

# 특정 테스트만
./vendor/bin/pest tests/Unit/PointEventQrTest.php --filter="scanQr"
```

---

## 10. 구현 순서 (작업 단계)

### Phase 1: 서버 (PHP v7) — DB + API

1. DB 테이블 확인 (`company_qr_codes`, `company_qr_code_usages`, `company_reviews`)
2. Entity 클래스 작성 (`PointEventQrEntity`, `PointEventHistoryEntity`)
3. Repository 클래스 확장 (`PointEventRepository` — QR 관련 CRUD 메서드 추가)
4. Service 클래스 확장 (`PointEventService` — 비즈니스 로직 추가)
5. Controller 클래스 확장 (`PointEventController` — 6개 API 메서드 추가)
6. composer.json PSR-4 확인 + `composer dump-autoload`
7. PEST Unit Test 작성 및 통과 (`PointEventQrTest.php`)

### Phase 2: Flutter API 래퍼

1. `lib/v7_api/point_event_api.dart` 작성 (6개 메서드)
2. 각 메서드 API 연동 테스트

### Phase 3: Flutter UI — QR 스캔

1. `lib/screens/event/qr_scanner.screen.dart` 구현 (mobile_scanner 카메라)
2. `lib/screens/event/company_event.screen.dart` 수정 (QR 스캔 버튼 연결)
3. QR 코드 URL 파싱 로직 구현 (`Uri.parse()` → `queryParameters['code']`로 verification_id 추출)

### Phase 4: Flutter UI — 포인트 획득

1. `lib/screens/event/point_event_result.screen.dart` 구현 (스캔 결과 화면)
   - 업소 정보 표시
   - QR 스캔 포인트 (1,000~2,000P) 표시 + 애니메이션
   - 재방문 보너스 버튼 (2,000~3,000P)
   - 후기 작성 영역 + V7FileUpload
   - 후기 포인트 (2,000~3,000P) 표시
   - 총 획득 포인트 요약
   - 이동 선택 다이얼로그
2. i18n 키 추가 (4개 언어)
3. 라우터 수정 (`lib/router.dart`)
4. `flutter analyze` 통과

### Phase 5: Flutter UI — 이벤트 응모

1. `lib/screens/event/event_entry.screen.dart` 수정 (더미 → API 연동)
2. `pointEvent.history` API로 실제 참여 기록 표시

### Phase 6: 업소 회원 QR 생성 화면

1. 업소 회원용 QR 코드 생성 버튼/화면 구현
2. 일일 생성 제한 UI 표시 (today_count / 10)
3. QR 코드 목록 조회 기능 (`pointEvent.qrList`)
4. qr_flutter 패키지로 QR 이미지 렌더링

---

## 11. 참고 파일 위치

### Flutter 앱 파일

| 카테고리 | 파일 경로 |
|---------|---------|
| 업소 이벤트 화면 | `lib/screens/event/company_event.screen.dart` |
| 이벤트 응모 화면 | `lib/screens/event/event_entry.screen.dart` |
| 기존 QR 스캔 결과 화면 | `lib/screens/company/company.qr_code_scanned.screen.dart` |
| 기존 QR 코드 표시 화면 | `lib/screens/company/company.qr_code.screen.dart` |
| v7 API 기본 함수 | `lib/v7_api/v7_api.dart` |
| Company API (v7) | `lib/v7_api/company_api.dart` |
| Upload API (v7) | `lib/v7_api/upload_api.dart` |
| User API (v7) | `lib/v7_api/user_api.dart` |
| 파일 업로드 위젯 | `lib/v7_api/widgets/upload/v7_file_upload.dart` |
| 라우터 | `lib/router.dart` |
| i18n 파일 | `lib/l10n/app_*.arb` |

### v7-skill 문서

| 카테고리 | 파일 경로 |
|---------|---------|
| v7 아키텍처 | `.claude/skills/v7-skill/references/v7-architecture.md` |
| v7 Flutter API | `.claude/skills/v7-skill/references/app/v7-flutter-api.md` |
| v7 Company API | `.claude/skills/v7-skill/references/api/v7-company.md` |
| v7 User API | `.claude/skills/v7-skill/references/api/v7-user.md` |
| v7 Upload API | `.claude/skills/v7-skill/references/api/v7-upload.md` |
| v7 AI 영수증 | `.claude/skills/v7-skill/references/api/v7-ai-receipt.md` |
| v7 Docker | `.claude/skills/v7-skill/references/v7-docker.md` |

### philgo-skill 문서

| 카테고리 | 파일 경로 |
|---------|---------|
| 포인트 광고 | `.claude/skills/philgo-skill/references/point-advertisement.md` |
| 포인트 API | `.claude/skills/philgo-skill/references/api/point-api.md` |
| 업소록 | `.claude/skills/philgo-skill/references/company.md` |
| 사용자 API | `.claude/skills/philgo-skill/references/api/api-spec-user.md` |
| API 기본 스펙 | `.claude/skills/philgo-skill/references/api/api-spec.md` |
| 업소 API | `.claude/skills/philgo-skill/references/api/api-spec-company.md` |
| DB 관리 | `.claude/skills/philgo-skill/references/db/database-management.md` |

### Flutter-skill 문서

| 카테고리 | 파일 경로 |
|---------|---------|
| mobile_scanner | `.claude/skills/flutter-skill/references/mobile-scanner.md` |

### PHP 서버 파일 (v7)

| 카테고리 | 파일 경로 (서버) |
|---------|---------|
| PointEventController | `lib/point_event/PointEventController.php` |
| PointEventService | `lib/point_event/PointEventService.php` |
| PointEventRepository | `lib/point_event/PointEventRepository.php` |
| 포인트 설정 | `etc/app.config.php` (PointConfig 클래스) |
| 포인트 함수 | `lib/point.functions.php` |
| 상수 정의 | `lib/constants.php` |

---

## 12. 이벤트 응모 스피닝 휠 Prize Type 설계

### 12.1 개요

이벤트 응모 화면(`EventEntryScreen`)에서 사용자가 원판을 돌려 포인트를 획득하는 스피닝 휠 시스템.
총 10개 섹션, 가중치(weight) 합계 1000 (0.1% 단위 확률 제어).

### 12.2 Prize Type 목록

| # | 섹션 | 포인트 | Weight | 확률 | 원판 각도 | 색상 | 아이콘 |
|---|------|--------|--------|------|----------|------|--------|
| 1 | 50P | 50 | 379 | 37.9% | 136.44° | `#E88B8B` (분홍) | - |
| 2 | 100P | 100 | 80 | 8.0% | 28.8° | `#E8A87C` (살구) | - |
| 3 | 200P | 200 | 70 | 7.0% | 25.2° | `#F5B971` (주황) | - |
| 4 | 300P | 300 | 60 | 6.0% | 21.6° | `#D4A76A` (황토) | - |
| 5 | 400P | 400 | 50 | 5.0% | 18.0° | `#D4B896` (베이지) | - |
| 6 | 500P | 500 | 40 | 4.0% | 14.4° | `#E8C170` (금색) | - |
| 7 | 꽝 | 0 | 300 | 30.0% | 108.0° | `#B0B0B0` (회색) | - |
| 8 | 1,000P | 1,000 | 15 | 1.5% | 5.4° | `#C9A9C9` (보라) | ★ (solidStar × 1) |
| 9 | 2,000P | 2,000 | 4 | 0.4% | 1.44° | `#9CC2D8` (하늘) | ★★ (solidStar × 2) |
| 10 | 스타벅스 쿠폰 | -1 (특별) | 2 | 0.2% | 0.72° | `#8BC78B` (초록) | ☕ (lightMugHot) |
| | **합계** | | **1,000** | **100%** | **360°** | | |

### 12.3 확률 분포 설계 의도

**기본 원칙**: 고포인트일수록 극히 낮은 확률, 저포인트는 높은 확률

| 등급 | 섹션 | 확률 합계 | 설계 의도 |
|------|------|----------|----------|
| **일반** | 50P + 꽝 | 67.9% | 대부분의 결과 (약 2/3) |
| **중간** | 100P ~ 500P | 30% | 적당한 보상감 제공 |
| **희귀** | 1,000P | 1.5% | 드문 행운 |
| **초희귀** | 2,000P | 0.4% | 매우 드문 대박 |
| **전설** | 스타벅스 쿠폰 | 0.2% | 500회에 1번 (최고 보상) |

### 12.4 기대값 분석

```
기대값 = Σ(포인트 × 확률)
       = 50×0.379 + 100×0.08 + 200×0.07 + 300×0.06 + 400×0.05
         + 500×0.04 + 1000×0.015 + 2000×0.004 + 0×0.30
       = 18.95 + 8 + 14 + 18 + 20 + 20 + 15 + 8 + 0
       = 121.95P (1회 회전 당 기대값, 약 122P)

※ 스타벅스 쿠폰(0.2%)은 포인트가 아닌 실물 보상이므로 기대값 계산에서 제외
```

### 12.5 WheelSection 코드 정의

```dart
/// lib/screens/event/event_entry.screen.dart
/// 원판 섹션 정의 (10개 섹션, 총 weight = 1000 → 확률 0.1% 단위)
_sections = [
  WheelSection(label: '50',    color: Color(0xFFE88B8B), points: 50,   weight: 379),
  WheelSection(label: '100',   color: Color(0xFFE8A87C), points: 100,  weight: 80),
  WheelSection(label: '200',   color: Color(0xFFF5B971), points: 200,  weight: 70),
  WheelSection(label: '300',   color: Color(0xFFD4A76A), points: 300,  weight: 60),
  WheelSection(label: '400',   color: Color(0xFFD4B896), points: 400,  weight: 50),
  WheelSection(label: '500',   color: Color(0xFFE8C170), points: 500,  weight: 40),
  WheelSection(label: l10n.spinWheelMiss, color: Color(0xFFB0B0B0), points: 0, weight: 300),
  WheelSection(label: '1,000', color: Color(0xFFC9A9C9), points: 1000, weight: 15,
    icon: FontAwesomeIcons.solidStar),
  WheelSection(label: '2,000', color: Color(0xFF9CC2D8), points: 2000, weight: 4,
    icon: FontAwesomeIcons.solidStar, iconCount: 2),
  WheelSection(label: l10n.spinWheelCoupon, color: Color(0xFF8BC78B), points: -1, weight: 2,
    icon: FontAwesomeIcons.lightMugHot),
];
```

### 12.6 points 필드 규칙

| points 값 | 의미 | 결과 처리 |
|-----------|------|----------|
| `> 0` | 포인트 당첨 | 해당 포인트 지급 |
| `== 0` | 꽝 | 포인트 미지급 |
| `== -1` | 스타벅스 쿠폰 (특별 상품) | 실물 쿠폰 지급, Auto Spin 중지 조건 |

### 12.7 Auto Spin 중지 조건

```dart
/// 스타벅스 쿠폰(points == -1) 당첨 시 연속 돌리기 자동 중지
autoSpinStopCondition: (section) => section.points == -1,
```

### 12.8 결과 메시지 분기

```dart
if (section.points == 0) {
  message = l10n.spinWheelResultMiss;        // "아쉽지만 다음 기회에!"
} else if (section.points == -1) {
  message = l10n.spinWheelResultCoupon;      // "스타벅스 쿠폰 당첨!"
} else {
  message = l10n.spinWheelResultPoints(section.points);  // "{point}P 당첨!"
}
```

### 12.9 서버 연동 시 고려사항

서버에서 결과를 미리 결정할 때, 동일한 가중치 기반 확률을 서버 측에서도 적용해야 한다.

```php
/// PHP 서버 측 가중치 기반 랜덤 선택 (예시)
$sections = [
    ['points' => 50,   'weight' => 380],
    ['points' => 100,  'weight' => 80],
    ['points' => 200,  'weight' => 70],
    ['points' => 300,  'weight' => 60],
    ['points' => 400,  'weight' => 50],
    ['points' => 500,  'weight' => 40],
    ['points' => 0,    'weight' => 300],  // 꽝
    ['points' => 1000, 'weight' => 15],
    ['points' => 2000, 'weight' => 4],
    ['points' => -1,   'weight' => 1],   // 스타벅스 쿠폰
];

$totalWeight = array_sum(array_column($sections, 'weight'));  // 1000
$rand = random_int(1, $totalWeight);
$cumulative = 0;
foreach ($sections as $index => $section) {
    $cumulative += $section['weight'];
    if ($rand <= $cumulative) {
        return $index;  // 당첨 섹션 인덱스
    }
}
```
