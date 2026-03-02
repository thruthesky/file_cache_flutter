# Company QR Code API - v7 시스템 (PSR-4)

> **✅ 구현 완료** — 모든 API 엔드포인트, PEST Unit Test, 관리자 페이지 구현 완료

## 목차

- [1. 개요](#1-개요)
- [2. CoT 분석: 단계별 설계](#2-cot-분석-단계별-설계)
- [3. ToT 분석: 설계 결정 트리](#3-tot-분석-설계-결정-트리)
- [4. DB 스키마](#4-db-스키마)
- [5. 아키텍처](#5-아키텍처)
- [6. 파일 구조](#6-파일-구조)
- [7. Entity 클래스](#7-entity-클래스)
- [8. Repository 클래스](#8-repository-클래스)
- [9. Service 비즈니스 로직](#9-service-비즈니스-로직)
- [10. Controller API 엔드포인트](#10-controller-api-엔드포인트)
- [11. API 호출 예시](#11-api-호출-예시)
- [12. 권한 모델](#12-권한-모델)
- [13. 비즈니스 규칙](#13-비즈니스-규칙)
- [14. 관리자 페이지](#14-관리자-페이지)
- [15. PEST Unit Test](#15-pest-unit-test)
- [16. 레거시(v6)와의 관계](#16-레거시v6와의-관계)
- [17. 웹 페이지 통합](#17-웹-페이지-통합-v6-파일에서-v7-api-호출)

---

## 1. 개요

### 1.1 배경

업소록 QR 코드 시스템은 승인된 업소가 랜덤한 고유 QR 코드를 발행하고, 사용자가 이를 스캔하여
방문 기록을 남기는 시스템이다. 기존 v6의 고정 QR 코드(`md5(idx+idx_member)`)를 대체하여
보안성과 추적성을 크게 강화한 v7 시스템이다.

### 1.2 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **랜덤 QR 코드 생성** | `bin2hex(random_bytes(32))` → 64자 hex 고유 검증 ID |
| **일일 발행 제한** | 업소당 하루 최대 10개 QR 코드 발행 가능 |
| **180초 만료** | QR 코드 발행 후 180초(3분) 이내에 스캔해야 유효 (`expired_at = time() + 180`) |
| **24시간 중복 사용 제한** | 동일 사용자가 동일 업소에서 24시간 내 중복 사용 불가 |
| **비회원 스캔 허용** | 로그인하지 않은 사용자도 QR 코드 스캔 가능 (제한 없음) |
| **모든 스캔 기록** | 성공/실패/거부 모든 결과를 기록하여 통계/감사 활용 |
| **show_qr_code 무관** | `status='a'`(승인) 업소면 show_qr_code 값과 무관하게 발행 가능 |
| **디바이스 추적** | User-Agent 분석으로 mobile/tablet/desktop 기기 유형 기록 |
| **환경 자동 대응 URL** | QR 코드 URL에 `$_SERVER['HTTP_HOST']`를 사용하여 로컬/프로덕션 환경을 자동 구분 |

### 1.3 관련 테이블

- **company_qr_codes**: QR 코드 발행 기록
- **company_qr_code_usages**: QR 코드 사용(스캔) 기록
- **company**: 업소 정보 (소유자 확인, 승인 상태 확인)
- **sf_member**: 회원 정보 (발행자/사용자 참조)

---

## 2. CoT 분석: 단계별 설계

### Step 1: 기존 QR 코드 시스템 분석

- **v6 방식**: `md5(company.idx + company.idx_member)` → 고정 값, 변경 불가
- **v6 문제점**: DB 기록 없음, 통계 불가, 보안 취약 (hash 추측 가능)
- **v6 파일**: `company/qr-code.php` (표시), `company/qr-code-scanned.php` (검증)

### Step 2: v7 새 시스템 설계

- **verification_id**: `bin2hex(random_bytes(32))` → 64자 hex (충돌 확률 무시 가능)
- **DB 기록**: 발행/사용 모든 이벤트를 DB에 기록
- **발행 제한**: 업소당 하루 10개 (00:00~23:59 기준)
- **사용 제한**: 로그인 사용자는 동일 업소에서 24시간 내 1회만 성공 가능

### Step 3: v7 아키텍처 적용

- **PSR-4**: `Philgo\Company\` → `lib/company/` (기존 Company 모듈에 통합)
- **Entity**: `QrCodeEntity`, `QrCodeUsageEntity` (POPO 패턴)
- **Repository**: `QrCodeRepository`, `QrCodeUsageRepository` (DB CRUD)
- **Service**: `CompanyService`에 QR 코드 메서드 추가 (별도 클래스 불필요)
- **Controller**: `CompanyController`에 QR 코드 API 엔드포인트 추가

---

## 3. ToT 분석: 설계 결정 트리

### Branch 1: QR 코드 생성 방식

| 방식 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| UUID v4 | 표준 형식 | 하이픈 포함, 36자 | |
| **random_bytes hex** | **순수 hex, 64자** | **비표준** | **✅ 채택** |
| JWT 토큰 | 자체 검증 | 길이 과다, 만료 복잡 | |

### Branch 2: 서비스 분리 전략

| 방식 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| **CompanyService 통합** | **일관성, 간결** | **파일 비대화** | **✅ 채택** |
| 별도 QrCodeService | 분리, 독립 | 파일 증가, 의존성 | |

### Branch 3: 비회원 스캔 정책

| 방식 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| **비회원 허용 (제한 없음)** | **접근성 극대화** | **남용 가능** | **✅ 채택** |
| 로그인 필수 | 추적 정확 | 접근성 저하 | |
| IP 기반 제한 | 중간 보안 | VPN/공유IP 문제 | |

---

## 4. DB 스키마

### 4.1 company_qr_codes 테이블

```sql
CREATE TABLE company_qr_codes (
    idx INT AUTO_INCREMENT PRIMARY KEY,
    idx_company INT NOT NULL DEFAULT 0,           -- 업소 idx
    idx_member INT NOT NULL DEFAULT 0,            -- 발행자 회원 idx
    verification_id VARCHAR(128) NOT NULL DEFAULT '',  -- 고유 검증 ID (64자 hex)
    status CHAR(1) NOT NULL DEFAULT 'a',          -- 상태: 'a'=활성, 'd'=비활성
    created_at INT NOT NULL DEFAULT 0,            -- 발행 시각 (Unix timestamp)
    expired_at INT NOT NULL DEFAULT 0,            -- 만료 시각 (time()+180, 180초 후 만료)
    used_count INT NOT NULL DEFAULT 0,            -- 총 사용 횟수
    memo VARCHAR(255) NOT NULL DEFAULT '',        -- 메모
    UNIQUE KEY idx_verification_id (verification_id),
    KEY idx_company (idx_company),
    KEY idx_member (idx_member),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 4.2 company_qr_code_usages 테이블

```sql
CREATE TABLE company_qr_code_usages (
    idx INT AUTO_INCREMENT PRIMARY KEY,
    idx_qr_code INT NOT NULL DEFAULT 0,           -- QR 코드 idx
    idx_company INT NOT NULL DEFAULT 0,            -- 업소 idx
    idx_member INT NOT NULL DEFAULT 0,             -- 사용자 회원 idx (0=비회원)
    verification_id VARCHAR(128) NOT NULL DEFAULT '',  -- QR 코드 검증 ID
    scanned_at INT NOT NULL DEFAULT 0,             -- 스캔 시각 (Unix timestamp)
    ip_address VARCHAR(45) NOT NULL DEFAULT '',    -- 스캐너 IP
    user_agent VARCHAR(512) NOT NULL DEFAULT '',   -- User-Agent
    referer VARCHAR(512) NOT NULL DEFAULT '',      -- Referer URL
    device_type VARCHAR(20) NOT NULL DEFAULT '',   -- 기기 유형 (mobile/tablet/desktop)
    result CHAR(1) NOT NULL DEFAULT 's',           -- 결과: 's'=성공, 'f'=실패, 'r'=거부(24h)
    KEY idx_qr_code (idx_qr_code),
    KEY idx_company (idx_company),
    KEY idx_member (idx_member),
    KEY idx_scanned_at (scanned_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 5. 아키텍처

```
클라이언트
  ↓
api.php → CompanyController
              ↓
          CompanyService
           ↓          ↓
  QrCodeRepository    QrCodeUsageRepository
     ↓                     ↓
  QrCodeEntity         QrCodeUsageEntity
     ↓                     ↓
  company_qr_codes    company_qr_code_usages (DB)
```

---

## 6. 파일 구조

```
lib/company/
├── CompanyController.php    # QR 코드 API 엔드포인트 추가
├── CompanyService.php       # QR 코드 비즈니스 로직 추가
├── QrCodeEntity.php         # ✅ QR 코드 Entity (POPO)
├── QrCodeUsageEntity.php    # ✅ QR 코드 사용 기록 Entity (POPO)
├── QrCodeRepository.php     # ✅ QR 코드 DB CRUD
└── QrCodeUsageRepository.php  # ✅ 사용 기록 DB CRUD

page/admin/
├── company-qr-code-list.php    # ✅ 관리자 QR 코드 발행 목록
└── company-qr-code-usages.php  # ✅ 관리자 QR 코드 스캔 현황

widgets/admin/company/
├── qr-code-list.php          # ✅ QR 코드 목록 위젯
└── qr-code-usages.php        # ✅ 스캔 현황 위젯

tests/Unit/
└── CompanyQrCodeTest.php     # ✅ PEST Unit Test
```

---

## 7. Entity 클래스

### 7.1 QrCodeEntity

| 프로퍼티 | 타입 | 설명 |
|----------|------|------|
| idx | int | PK |
| idx_company | int | 업소 idx |
| idx_member | int | 발행자 회원 idx |
| verification_id | string | 고유 검증 ID (64자 hex) |
| status | string | 'a'=활성, 'd'=비활성 |
| created_at | int | 발행 시각 (Unix timestamp) |
| expired_at | int | 만료 시각 (0=무제한) |
| used_count | int | 총 사용 횟수 |
| memo | string | 메모 |

**주요 메서드:**

```php
QrCodeEntity::fromArray(array $data): self     // DB 행 → Entity
$entity->toArray(): array                       // Entity → 배열 (is_active, is_expired, qr_url 포함)
$entity->isActive(): bool                       // status === 'a'
$entity->isExpired(): bool                      // expired_at > 0 && expired_at < time()
$entity->exists(): bool                         // idx > 0
$entity->getQrUrl(): string                     // QR 스캔 URL 생성
```

**toArray() 응답 구조:**

```json
{
    "idx": 1,
    "idx_company": 100,
    "idx_member": 200,
    "verification_id": "a1b2c3d4...64자hex",
    "status": "a",
    "created_at": 1709280000,
    "expired_at": 0,
    "used_count": 5,
    "memo": "테스트 발행",
    "is_active": true,
    "is_expired": false,
    "qr_url": "https://www.philgo.com/company/qr-code-scanned.php?code=a1b2c3d4..."
}
```

### 7.2 QrCodeUsageEntity

| 프로퍼티 | 타입 | 설명 |
|----------|------|------|
| idx | int | PK |
| idx_qr_code | int | QR 코드 idx |
| idx_company | int | 업소 idx |
| idx_member | int | 사용자 회원 idx (0=비회원) |
| verification_id | string | QR 코드 검증 ID |
| scanned_at | int | 스캔 시각 (Unix timestamp) |
| ip_address | string | 스캐너 IP |
| user_agent | string | User-Agent |
| referer | string | Referer URL |
| device_type | string | mobile/tablet/desktop |
| result | string | 's'=성공, 'f'=실패, 'r'=거부(24h) |

---

## 8. Repository 클래스

### 8.1 QrCodeRepository

| 메서드 | 설명 |
|--------|------|
| `insert(array $data): int` | QR 코드 발행 (INSERT) |
| `findByIdx(int $idx): ?QrCodeEntity` | idx로 조회 |
| `findByVerificationId(string $id): ?QrCodeEntity` | verification_id로 조회 |
| `countTodayIssued(int $idxCompany): int` | 오늘 발행 수 조회 |
| `incrementUsedCount(int $idx): bool` | used_count + 1 |
| `updateStatus(int $idx, string $status): bool` | 상태 업데이트 |
| `findByCompany(?int $idxCompany, int $page, int $limit): array` | 페이지네이션 조회 |
| `getStats(int $idxCompany, string $period): array` | 통계 조회 |
| `deleteByIdx(int $idx): bool` | 삭제 (단건) |
| `deleteByCompany(int $idxCompany): bool` | 업소 전체 삭제 (테스트용) |

**상수:**

```php
QrCodeRepository::DAILY_ISSUE_LIMIT = 10  // 업소당 하루 최대 발행 수
```

### 8.2 QrCodeUsageRepository

| 메서드 | 설명 |
|--------|------|
| `insert(array $data): int` | 사용 기록 INSERT |
| `hasRecentUsage(int $idxCompany, int $idxMember): bool` | 24시간 내 사용 여부 |
| `findByCompany(?int $idxCompany, ?int $idxQrCode, int $page, int $limit): array` | 페이지네이션 조회 |
| `getStats(int $idxCompany, string $period): array` | 사용 통계 (일별 breakdown) |
| `deleteByCompany(int $idxCompany): bool` | 업소 전체 삭제 (테스트용) |

---

## 9. Service 비즈니스 로직

### 9.1 issueQrCode (QR 코드 발행)

```
CompanyService::issueQrCode(array $input): array
```

**입력 파라미터:**

| 키 | 타입 | 필수 | 설명 |
|----|------|------|------|
| idx | int | ✅ | 업소 idx |
| idx_member | int | ✅ | 로그인 사용자 idx (Controller에서 주입) |
| is_admin | bool | ✅ | 관리자 여부 (Controller에서 주입) |
| memo | string | | 메모 (선택) |

**처리 흐름:**

1. 업소 존재 확인 (CompanyRepository::findByIdx)
2. 승인 상태 확인 (`status === 'a'`)
3. 소유자 또는 관리자 권한 확인
4. 일일 발행 한도 확인 (10개)
5. `bin2hex(random_bytes(32))` → verification_id 생성
6. DB INSERT
7. 발행된 QR 코드 정보 + today_issued_count + today_remaining 반환

**응답 예시:**

```json
{
    "idx": 15,
    "idx_company": 100,
    "verification_id": "a1b2c3...",
    "status": "a",
    "qr_url": "https://www.philgo.com/company/qr-code-scanned.php?code=a1b2c3...",
    "today_issued_count": 3,
    "today_remaining": 7
}
```

### 9.2 scanQrCode (QR 코드 스캔)

```
CompanyService::scanQrCode(array $input): array
```

**입력 파라미터:**

| 키 | 타입 | 필수 | 설명 |
|----|------|------|------|
| code | string | ✅ | QR 코드 verification_id |
| idx_member | int | | 사용자 idx (0=비회원, Controller에서 주입) |
| ip | string | | IP 주소 (Controller에서 주입) |
| user_agent | string | | User-Agent (Controller에서 주입) |
| referer | string | | Referer URL (Controller에서 주입) |
| device_type | string | | 기기 유형 (Controller에서 주입) |

**처리 흐름:**

1. verification_id로 QR 코드 조회
2. 유효성 검증:
   - 존재 여부 → 실패 기록 (result='f')
   - 활성 상태 (`status='a'`) → 실패 기록
   - 만료 확인 (expired_at) → 실패 기록
   - 업소 승인 상태 → 실패 기록
3. 로그인 사용자: 24시간 중복 사용 확인 → 거부 기록 (result='r')
4. 성공 기록 (result='s') + used_count 증가
5. **포인트 적립** (로그인 사용자만): 1,000~2,000P 랜덤 적립 (`PointLogService::changePoints()`)
6. 결과 반환 (포인트 정보 포함)

**응답 예시 (성공 — 로그인 사용자, 포인트 적립 포함):**

```json
{
    "success": true,
    "usage_idx": 42,
    "idx_company": 1108,
    "company_name": "Durian",
    "company": { ... },
    "reward_points": 1523,
    "point_before": 5000,
    "point_after": 6523
}
```

**응답 예시 (성공 — 비로그인 사용자, 포인트 미적립):**

```json
{
    "success": true,
    "usage_idx": 43,
    "idx_company": 1108,
    "company_name": "Durian",
    "company": { ... },
    "reward_points": 0,
    "point_before": 0,
    "point_after": 0
}
```

**응답 예시 (24시간 중복 거부):**

```json
{
    "result": "r",
    "message": "24시간 이내에 이미 이 업소의 QR 코드를 사용했습니다."
}
```

### 9.3 listQrCodes (QR 코드 목록)

```
CompanyService::listQrCodes(array $input): array
```

**입력:** idx (업소 idx), page, limit
**응답:** `{ total, page, limit, items: QrCodeEntity[] }`

### 9.4 listQrCodeUsages (사용 기록 목록)

```
CompanyService::listQrCodeUsages(array $input): array
```

**입력:** idx (업소 idx), idx_qr_code (선택), page, limit
**응답:** `{ total, page, limit, items: QrCodeUsageEntity[] }`

### 9.5 qrCodeStats (통계)

```
CompanyService::qrCodeStats(array $input): array
```

**입력:** idx (업소 idx), period (today/week/month/all)
**응답:**

```json
{
    "issue": {
        "total_issued": 50,
        "total_scanned": 200,
        "today_issued": 3,
        "today_remaining": 7
    },
    "usage": {
        "total_scanned": 200,
        "total_success": 180,
        "total_unique_users": 45,
        "today_scanned": 10,
        "period_stats": [
            { "date": "2026-03-01", "scanned": 10, "success": 9, "unique_users": 5 }
        ]
    }
}
```

---

## 10. Controller API 엔드포인트

### 10.1 issueQrCode

```
GET/POST https://local.philgo.com/api.php?method=company.issueQrCode&idx=1025&session_id=xxx
GET/POST https://local.philgo.com/api.php?method=company.issueQrCode&idx=1025&session_id=xxx&memo=테스트
```

**인증:** 필수 (업소 소유자 또는 관리자)

### 10.2 scanQrCode

```
GET/POST https://local.philgo.com/api.php?method=company.scanQrCode&code=a1b2c3d4...
GET/POST https://local.philgo.com/api.php?method=company.scanQrCode&code=a1b2c3d4...&session_id=xxx
```

**인증:** 선택 (비회원도 스캔 가능)

### 10.3 listQrCodes

```
GET https://local.philgo.com/api.php?method=company.listQrCodes&idx=1025&session_id=xxx
GET https://local.philgo.com/api.php?method=company.listQrCodes&idx=1025&session_id=xxx&page=2&limit=10
```

**인증:** 필수

### 10.4 listQrCodeUsages

```
GET https://local.philgo.com/api.php?method=company.listQrCodeUsages&idx=1025&session_id=xxx
GET https://local.philgo.com/api.php?method=company.listQrCodeUsages&idx=1025&idx_qr_code=5&session_id=xxx
```

**인증:** 필수

### 10.5 qrCodeStats

```
GET https://local.philgo.com/api.php?method=company.qrCodeStats&idx=1025&session_id=xxx
GET https://local.philgo.com/api.php?method=company.qrCodeStats&idx=1025&session_id=xxx&period=week
```

**인증:** 필수

---

## 11. API 호출 예시

### curl 예시

```bash
# QR 코드 발행
curl "https://local.philgo.com/api.php?method=company.issueQrCode&idx=1025&session_id=xxx"

# QR 코드 스캔 (비회원)
curl "https://local.philgo.com/api.php?method=company.scanQrCode&code=a1b2c3d4..."

# QR 코드 목록
curl "https://local.philgo.com/api.php?method=company.listQrCodes&idx=1025&session_id=xxx"

# 통계 조회
curl "https://local.philgo.com/api.php?method=company.qrCodeStats&idx=1025&session_id=xxx&period=month"
```

### JavaScript (func) 호출 예시

```javascript
// QR 코드 발행
const result = await func('v7', { method: 'company.issueQrCode', idx: 1025 });

// QR 코드 스캔
const scan = await func('v7', { method: 'company.scanQrCode', code: 'a1b2c3...' });
```

### Flutter (v7api) 호출 예시

```dart
// QR 코드 발행
final result = await v7api('company.issueQrCode', {'idx': 1025});

// QR 코드 스캔
final scan = await v7api('company.scanQrCode', {'code': 'a1b2c3...'});

// 통계 조회
final stats = await v7api('company.qrCodeStats', {'idx': 1025, 'period': 'month'});
```

---

## 12. 권한 모델

| API | 비회원 | 일반회원 | 업소 소유자 | 관리자 |
|-----|--------|----------|-------------|--------|
| issueQrCode | ❌ | ❌ | ✅ | ✅ |
| scanQrCode | ✅ (무제한) | ✅ (24h 제한) | ✅ (24h 제한) | ✅ (24h 제한) |
| listQrCodes | ❌ | ❌ | ✅ (자기 업소) | ✅ |
| listQrCodeUsages | ❌ | ❌ | ✅ (자기 업소) | ✅ |
| qrCodeStats | ❌ | ❌ | ✅ (자기 업소) | ✅ |

---

## 13. 비즈니스 규칙

### 13.1 QR 코드 발행 규칙

| 규칙 | 조건 | 설명 |
|------|------|------|
| 승인 업소만 | `company.status === 'a'` | show_qr_code 값과 무관 |
| 소유자/관리자만 | `idx_member === company.idx_member \|\| is_admin` | |
| 하루 10개 제한 | `countTodayIssued() < 10` | 00:00~23:59 기준 |
| 고유 검증 ID | `bin2hex(random_bytes(32))` | 64자 hex, UNIQUE 제약 |

### 13.2 QR 코드 스캔 규칙

| 규칙 | 조건 | 결과 |
|------|------|------|
| 코드 존재 | verification_id 일치 | 미일치 시 result='f' |
| 활성 상태 | `qr_code.status === 'a'` | 비활성 시 result='f' |
| 미만료 | `expired_at === 0 \|\| expired_at > time()` | 만료 시 result='f' |
| 업소 승인 | `company.status === 'a'` | 미승인 시 result='f' |
| 24시간 제한 | 로그인 사용자만 적용 | 중복 시 result='r' |
| 비회원 | idx_member=0 | 제한 없이 성공 가능 |

### 13.3 result 코드

| 코드 | 의미 | 설명 |
|------|------|------|
| `s` | success | 정상 스캔 성공 |
| `f` | fail | 유효하지 않은 QR 코드 (존재하지 않음, 비활성, 만료, 업소 미승인) |
| `r` | rejected | 24시간 이내 중복 사용 거부 |

### 13.4 QR 코드 스캔 포인트 적립 규칙

QR 코드 스캔 성공(result='s') 시 로그인 사용자에게 보상 포인트를 즉시 적립한다.

| 규칙 | 설명 |
|------|------|
| 적립 대상 | 로그인 사용자만 (`idx_member > 0`) |
| 적립 범위 | 1,000P ~ 2,000P 랜덤 (`random_int(1000, 2000)`) |
| 적립 시점 | QR 코드 스캔 성공 즉시 (서버 측, `scanQrCode()` 내부) |
| 포인트 로그 | `sf_point_log` 테이블에 기록 (module='company', action='qr_scan') |
| 적립 함수 | `PointLogService::changePoints()` (lib/point_log/PointLogService.php) |
| etc 필드 | `"{업소명} QR 스캔 보상"` 형식 |
| 비로그인 | 스캔은 성공하지만 포인트 미적립 (reward_points=0) |
| 상세 로깅 | `Debug::log()` (var/debug.log)에 `[QR-POINT]` 태그로 상세 기록 |

**로그 태그 및 기록 항목:**

| 시점 | 로그 태그 | 기록 항목 |
|------|-----------|-----------|
| 적립 시작 | `[QR-POINT] 포인트 적립 시작` | idx_member, verification_id, idx_company, company_name, usage_idx, ip, user_agent |
| 포인트 결정 | `[QR-POINT] 랜덤 포인트 결정` | reward_points, range |
| 적립 완료 | `[QR-POINT] 포인트 적립 완료` | idx_member, reward_points, point_before, point_after, point_log_idx, module, action |
| 비로그인 | `[QR-POINT] 비로그인 사용자` | verification_id, idx_company, company_name |

### 13.5 재방문 포인트 추첨 규칙

QR 코드 스캔 성공 시 재방문자에게 추가 포인트 추첨 기회를 제공한다.

| 규칙 | 설명 |
|------|------|
| 재방문 판별 | 해당 업소에서 24시간 이전 성공(result='s') 기록 보유 |
| 적립 대상 | 로그인 사용자 중 재방문자만 |
| 적립 범위 | 2,000P ~ 3,000P 랜덤 (`random_int(2000, 3000)`) |
| 적립 시점 | `company/re-visit-point.php` 페이지에서 사용자 클릭 시 |
| 중복 적립 방지 | 동일 usage_idx에 대해 1회만 적립 (sf_point_log etc 필드 검색) |
| 포인트 로그 | module='company', action='qr_revisit' |
| etc 필드 | `"{업소명} 재방문 보상 (usage_idx:{N})"` 형식 |
| 상세 로깅 | `[QR-REVISIT]` 태그로 Debug::log() 기록 |

**`CompanyService::reVisitPoint()` API:**

```php
CompanyService::reVisitPoint(['usage_idx' => int, 'idx_member' => int]): array
```

반환값:
```json
{
    "success": true,
    "reward_points": 2521,
    "point_before": 12019,
    "point_after": 14540,
    "company_name": "Durian",
    "idx_company": 1108
}
```

**24시간 중복 에러 메시지 (qr-code-scanned.php):**

스캔 시 24시간 내 중복 방문이면 "포인트 충전 실패" 페이지를 표시한다:
- 제목: "포인트 충전 실패"
- 안내: "한 업소에서 24시간 이내 재방문한 경우 포인트를 충전하지 않습니다."
- 이전 방문 시간: "이전 방문 시간: 2026년 03월 01일 15:30"

---

## 14. 관리자 페이지

### 14.1 QR 코드 발행 목록

- **URL**: `https://local.philgo.com/page/admin/company-qr-code-list.php`
- **파일**: `page/admin/company-qr-code-list.php` → `widgets/admin/company/qr-code-list.php`
- **기능**:
  - 업소별 필터링
  - 상태별 필터링 (활성/비활성)
  - 업소명/검증ID 검색
  - 발행 통계 요약 (전체/활성/비활성/사용횟수)
  - 페이지네이션 (20개/페이지)

### 14.2 QR 코드 스캔 현황

- **URL**: `https://local.philgo.com/page/admin/company-qr-code-usages.php`
- **파일**: `page/admin/company-qr-code-usages.php` → `widgets/admin/company/qr-code-usages.php`
- **기능**:
  - 업소별 필터링
  - QR 코드별 필터링
  - 결과별 필터링 (성공/실패/거부)
  - 디바이스별 필터링 (모바일/태블릿/데스크톱)
  - 사용 통계 요약 (전체/성공/실패/거부/고유사용자/오늘)
  - 페이지네이션 (30개/페이지)

### 14.3 관리자 메뉴

- **admin-menu.php**에 "QR코드" 메뉴 항목 추가
- `href()->admin->company_qr_code_list` → QR 코드 발행 목록
- `href()->admin->company_qr_code_usages` → QR 코드 스캔 현황

---

## 15. PEST Unit Test

### 테스트 파일

`tests/Unit/CompanyQrCodeTest.php`

### 테스트 구성 (10개 describe 블록)

| describe | 테스트 항목 | it 개수 |
|----------|-------------|---------|
| QrCodeEntity | fromArray, toArray, isActive, isExpired, getQrUrl, exists | 6 |
| QrCodeUsageEntity | fromArray, toArray, isRejected | 3 |
| QrCodeRepository | insert, find, count, increment, pagination, delete | 6 |
| QrCodeUsageRepository | insert, hasRecentUsage, pagination | 4 |
| issueQrCode | 소유자, 관리자, 비소유자, 미승인, 일일제한, 고유ID | 6 |
| scanQrCode | 성공, 미존재, 비활성, 24h중복, 비회원, used_count | 6 |
| listQrCodes | 페이지네이션, 건수 확인 | 2 |
| listQrCodeUsages | 페이지네이션, 필터 | 2 |
| qrCodeStats | 통계 정확도, idx 누락 | 2 |
| Controller 인증 | 미인증 거부, 인증 발행, 비회원 스캔 | 3 |

### 실행 방법

```bash
cd /Users/thruthesky/apps/withcenter/philgo/www
./vendor/bin/pest tests/Unit/CompanyQrCodeTest.php
```

---

## 16. 레거시(v6)와의 관계

### 공존 구조

| 항목 | v6 (레거시) | v7 (신규) |
|------|-------------|-----------|
| QR 코드 생성 | `md5(idx + idx_member)` 고정 | `random_bytes(32)` 랜덤 |
| QR 코드 표시 | `company/qr-code.php` (v7 API 호출) | v7 API `company.issueQrCode` |
| QR 코드 검증 | `company/qr-code-scanned.php` (v7 API + v6 호환) | v7 API `company.scanQrCode` |
| DB 기록 | 없음 | `company_qr_codes` + `company_qr_code_usages` |
| 통계 | 없음 | `company.qrCodeStats` API |
| 관리 | 없음 | 관리자 페이지 (목록/스캔현황) |

### 마이그레이션 완료 사항

- **`qr-code.php`**: v6 고정 QR 코드(`md5()`) → v7 API `CompanyService::issueQrCode()` 호출로 전환 완료
- **`qr-code-scanned.php`**: v7 `code` 파라미터 처리 추가 + v6 `idx`+`verification_id` 레거시 호환 유지
- v7 QR 코드는 별도 테이블(`company_qr_codes`, `company_qr_code_usages`)을 사용
- `show_qr_code` 컬럼은 `qr-code.php` 페이지 접근 제어에만 영향 (v7 API와 무관)

---

## 17. 웹 페이지 통합 (v6 파일에서 v7 API 호출)

### 17.1 company/qr-code.php — QR 코드 발행 페이지

v6 레거시 파일이 v7 `CompanyService::issueQrCode()`를 직접 호출하여 매 접속마다 새 QR 코드를 발행한다.

#### 동작 흐름

```
사용자 접속 → qr-code.php
  ↓
1. 업소 존재 여부 확인 (get_company)
2. QR 코드 활성화 여부 확인 (qr_code_enabled)
3. 로그인 확인 (login())
4. v7 API 호출: CompanyService::issueQrCode()
   → verification_id 랜덤 생성
   → expired_at = time() + 180 (180초 후 만료)
   → DB 기록 저장
5. QR 코드 이미지 생성 (qrcodejs CDN)
6. 오늘 발행 현황 표시 (UTC+8 기준)
```

#### 주요 UI 요소

| 요소 | 설명 |
|------|------|
| **업소 정보 카드** | 로고, 업소명, 카테고리, 위치, 연락처 |
| **이벤트 배너** | "필고 + {업소명} 이벤트 참여" 그래디언트 배너 |
| **QR 코드 이미지** | qrcodejs로 생성, 256x256, 높은 오류 복구 수준(H) |
| **발행 현황 뱃지** | 오늘 날짜(UTC+8), 발행 수/일일 제한, 남은 횟수 |
| **안내 문구** | QR 코드 스캔 안내 + 180초 만료 안내 |
| **액션 버튼** | 프린트, 다운로드(PNG), 업소 보기 |
| **에러 상태** | 발행 실패 시 에러 메시지 표시 (로그인 필요, 일일 제한 초과 등) |

#### QR 코드 URL 생성 규칙

```php
// QrCodeEntity::getQrUrl()
// 웹 환경: $_SERVER['HTTP_HOST'] 사용 (환경별 자동 대응)
// CLI 환경: PHILGO_DOMAIN 상수 사용 (기본값: philgo.com)
$host = $_SERVER['HTTP_HOST'] ?? '';
if (empty($host)) {
    $domain = defined('PHILGO_DOMAIN') ? PHILGO_DOMAIN : 'philgo.com';
    $host = "www.{$domain}";
}
return "https://{$host}/company/qr-code-scanned.php?code={$this->verification_id}";
```

| 환경 | 생성되는 QR 코드 URL |
|------|----------------------|
| 로컬 (`local.philgo.com`) | `https://local.philgo.com/company/qr-code-scanned.php?code=...` |
| 프로덕션 (`www.philgo.com`) | `https://www.philgo.com/company/qr-code-scanned.php?code=...` |
| CLI | `https://www.philgo.com/company/qr-code-scanned.php?code=...` |

### 17.2 company/qr-code-scanned.php — QR 코드 스캔 감사 페이지

v7 `code` 파라미터와 v6 `idx`+`verification_id` 레거시 형식을 모두 지원한다.

#### 이중 경로 처리

```
스캔 URL 접속
  ↓
파라미터 확인
  ├─ code 파라미터 존재 → v7 처리
  │   └─ CompanyService::scanQrCode() 호출
  │       ├─ 성공 → 포인트 적립 (로그인 시 1,000~2,000P) → 감사 페이지 + 포인트 표시
  │       └─ 실패 → 에러 메시지 (만료/비활성/중복 등)
  │
  ├─ idx + verification_id 존재 → v6 레거시 처리
  │   └─ md5(idx + idx_member) 검증
  │       ├─ 일치 → 감사 페이지 표시
  │       └─ 불일치 → 에러 페이지
  │
  └─ 파라미터 없음 → 에러 페이지
```

#### v7 스캔 에러 메시지

| 에러 | 메시지 |
|------|--------|
| QR 코드 없음 | "유효하지 않은 QR 코드입니다." |
| 비활성화 | "비활성화된 QR 코드입니다." |
| 만료 | "만료된 QR 코드입니다." |
| 업소 무효 | "해당 업소가 유효하지 않습니다." |
| 24시간 중복 | "24시간 이내에 이미 사용하셨습니다. 내일 다시 시도해 주세요." |

#### 포인트 적립 UI

스캔 성공 시 감사 메시지 하단에 포인트 적립 정보를 표시한다.

| 상태 | UI 표시 |
|------|---------|
| 로그인 + 포인트 적립 | 노란색 카드: `{reward_points}P 적립!` + `현재 포인트: {point_after}P` |
| 비로그인 | 파란색 안내: `로그인하면 포인트를 받을 수 있습니다.` |

다국어 지원 키: `적립`, `현재_포인트`, `로그인_포인트_안내`

#### 재방문 포인트 추첨 버튼

재방문자(`is_revisit=true`)이고 로그인한 사용자에게 강조 버튼을 표시한다.

| 요소 | 설명 |
|------|------|
| 조건 | `$result['is_revisit'] === true && login()` |
| 버튼 스타일 | `btn-lg btn-warning rounded-pill w-100 fw-bold` + 글로우 애니메이션 |
| 클릭 대상 | `/company/re-visit-point.php?usage_idx={usage_idx}` |
| 표시 내용 | "재방문 포인트 추첨" + "2,000P ~ 3,000P" 서브텍스트 |

### 17.2.1 company/re-visit-point.php — 재방문 포인트 적립 페이지

재방문 사용자가 "재방문 포인트 추첨" 버튼 클릭 시 이동하는 페이지.
`CompanyService::reVisitPoint()`를 호출하여 2,000~3,000P 랜덤 포인트를 적립한다.

```
사용자 클릭 → re-visit-point.php
  ↓
로그인 확인
  ↓
CompanyService::reVisitPoint() 호출
  ├─ 성공 → 축하 카드 + 적립 포인트 표시 (그래디언트 강조)
  └─ 실패 → 에러 카드 (이미 적립됨, 재방문 아님 등)
```

다국어 지원 키: `재방문_축하`, `재방문_보상_안내`, `재방문_적립_포인트`, `변경_전`, `변경_후`, `재방문_포인트_실패`

### 17.3 page/help/guideline.php — 이용안내 페이지

"업소록 관리 안내" 아코디언 항목에 QR 코드 규칙을 표시한다.

| 안내 항목 | 내용 |
|-----------|------|
| QR 코드 발행 제한 | 각 업소별로 하루 최대 10개 발행 가능 |
| QR 코드 만료 | 발행 후 180초(3분) 이내에 스캔해야 유효 |

### 17.4 다국어 지원

모든 페이지에서 `inject_*_language()` 함수를 사용하여 4개 언어(ko, en, ja, zh) 지원:

- `qr-code.php`: `inject_company_qr_code_language()`
- `qr-code-scanned.php`: `inject_company_qr_code_scanned_language()`
- `re-visit-point.php`: `inject_company_re_visit_point_language()`
- `guideline.php`: `inject_help_guideline_language()`
