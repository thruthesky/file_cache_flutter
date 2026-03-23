# Company Visit Review API - v7 시스템 (PSR-4)

> **✅ 구현 완료** — 업소록 방문 후기 제출/조회/삭제 API, 포인트 적립 로직, 사진 연결 구현 완료

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
- [12. 삼단콤보 포인트 시스템](#12-삼단콤보-포인트-시스템)
- [13. 사진 처리](#13-사진-처리)
- [14. 에러 처리](#14-에러-처리)
- [15. 포인트 적립 상세](#15-포인트-적립-상세)
- [16. 웹 페이지 통합](#16-웹-페이지-통합)
- [17. 전체 데이터 흐름도](#17-전체-데이터-흐름도)

---

## 1. 개요

### 1.1 배경

업소록 방문 후기 시스템은 업소록 QR 이벤트 **삼단콤보**의 마지막 3단계이다.
사용자가 QR 코드를 스캔하고(1단계), 재방문 포인트를 추첨 받은 후(2단계),
사진과 글로 후기를 작성하면(3단계) 추가 포인트를 적립받는다.

삼단콤보 전체 흐름:

```
[1단계] QR 코드 스캔
  → company.scanQrCode API
  → 1,000~2,000P 즉시 적립
  → qr-code-scanned.php 페이지

[2단계] 재방문 포인트 추첨 (재방문자만)
  → CompanyService::reVisitPoint()
  → 추가 2,000~3,000P 적립
  → re-visit-point.php 페이지

[3단계] 방문 후기 작성 ← ★ 본 문서
  → company.submitVisitReview API
  → 추가 2,000~3,000P 적립
  → visit-review-point.php 페이지
  → 사진 1장 이상 + 글 10자 이상
```

**최대 적립 가능: 1회 방문당 최대 8,000P** (1단계 2,000 + 2단계 3,000 + 3단계 3,000)

### 1.2 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **QR 스캔 연동** | `usage_idx`(QR 스캔 기록)를 기반으로 후기 작성 권한을 검증한다 |
| **중복 후기 방지** | 하나의 `usage_idx`에 대해 1개의 후기만 허용 (UNIQUE 수준 검증) |
| **사진 필수** | 최소 1장의 사진 첨부 필수 (uploads 테이블 1:N 연결) |
| **내용 최소 길이** | 후기 내용 최소 10자 이상 (mb_strlen 기반) |
| **랜덤 포인트** | 2,000~3,000P 범위에서 `random_int()` 랜덤 적립 |
| **기존 Upload 연동** | v7 Upload 시스템의 `UploadRepository::updateAttached()` 활용 |
| **공개 조회** | 후기 목록 조회는 인증 불필요 (누구나 볼 수 있음) |
| **페이지네이션** | 후기 목록은 page/limit 기반 페이지네이션 지원 |

### 1.3 관련 테이블

- **company_reviews**: 방문 후기 본문 + 보상 포인트 정보
- **uploads**: 후기 사진 (module='visit_review', code='', attached_to=review.idx)
- **company_qr_code_usages**: QR 스캔 기록 (후기 작성 권한 검증)
- **company**: 업소 정보 (업소명 조회)
- **sf_point_log**: 포인트 로그 (module='company', action='visit_review')

### 1.4 관련 문서

- QR 코드 발행/스캔 API: → [v7-company-qr-code.md](v7-company-qr-code.md)
- 업소 기본 CRUD API: → [v7-company.md](v7-company.md)
- 포인트 로그 API: → [v7-point-log.md](v7-point-log.md)
- 파일 업로드 API: → [v7-upload.md](v7-upload.md)
- 이벤트 시스템 전체 개요: → [../event/v7-event-overview.md](../event/v7-event-overview.md)

---

## 2. CoT 분석: 단계별 설계

### Step 1: 요구사항 분석

- 사용자는 QR 코드 스캔 성공(result='s') 후에만 후기를 작성할 수 있다
- 동일 스캔 기록(usage_idx)에 대해 1회만 후기 작성 가능하다
- 사진 1장 이상, 내용 10자 이상 필수이다
- 후기 작성 시 2,000~3,000P 랜덤 포인트를 추가 적립한다
- 업소별 후기 목록을 공개 조회할 수 있어야 한다

### Step 2: 데이터 모델 설계

- **company_reviews 테이블**: idx, idx_company, idx_member, usage_idx(UNIQUE), content, reward_points, created_at
- **사진 저장 방식**: uploads 테이블의 기존 attached 메커니즘 활용
  - module='visit_review', code='', attached_to=review.idx
  - 1:N 관계 (후기 1개에 여러 사진)
- **포인트 로그**: sf_point_log 테이블에 module='company', action='visit_review'로 기록

### Step 3: API 설계

- `company.submitVisitReview` — 후기 제출 (인증 필수)
  - 입력: usage_idx, content, photo_idxs[]
  - 검증: 로그인, 스캔 기록 유효, 본인 스캔, 중복 방지, 내용/사진 검증
  - 처리: 후기 저장 → 사진 연결 → 포인트 적립
  - 출력: review_idx, reward_points, point_before, point_after

- `company.getVisitReviews` — 후기 목록 조회 (인증 불필요)
  - 입력: idx_company, page, limit
  - 처리: 후기 목록 + 각 후기의 사진 목록 로드
  - 출력: reviews[], total, page, limit

### Step 4: 검증 로직 설계

후기 제출의 8단계 검증 체인:

```
1. 로그인 확인 (idx_member > 0)
2. usage_idx 유효성 (> 0)
3. 스캔 기록 존재 확인 (QrCodeUsageRepository::findByIdx)
4. 본인 스캔 기록 확인 (usage.idx_member === input.idx_member)
5. 성공한 스캔 확인 (usage.result === 's')
6. 중복 후기 방지 (VisitReviewRepository::existsByUsageIdx)
7. 내용 길이 검증 (mb_strlen >= 10)
8. 사진 개수 검증 (count >= 1)
```

### Step 5: 포인트 적립 설계

- `random_int(2000, 3000)` — CSPRNG 기반 랜덤 포인트
- `PointLogService::changePoints()` 호출
  - idx_member_from: 0 (시스템)
  - idx_member_to: 후기 작성자
  - module: 'company'
  - action: 'visit_review'
  - etc: '{업소명} 방문 후기 보상 (usage_idx:{N})'
- 적립 전/후 포인트를 응답에 포함

---

## 3. ToT 분석: 설계 결정 트리

### Branch 1: 후기 데이터 저장 방식

| 방식 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| **별도 테이블 (company_reviews)** | **명확한 스키마, 인덱스 최적화** | **테이블 추가** | **✅ 채택** |
| sf_post_data 기존 테이블 활용 | 기존 인프라 재사용 | 스키마 부적합, 과도한 컬럼 | |
| company_meta에 JSON 저장 | 테이블 추가 불필요 | 검색/페이지네이션 불가 | |

### Branch 2: 사진 저장 방식

| 방식 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| **uploads 테이블 연결** | **v7 Upload 시스템 재활용** | **별도 조회 필요** | **✅ 채택** |
| company_reviews에 URL 컬럼 | 조회 간편 | 다중 사진 불가 | |
| 별도 review_photos 테이블 | 독립적 관리 | 불필요한 테이블 증가 | |

### Branch 3: 중복 방지 전략

| 방식 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| **코드 레벨 검증 + DB UNIQUE** | **이중 방어** | **약간 복잡** | **✅ 채택** |
| DB UNIQUE만 | 간단 | SQL 에러 처리 필요 | |
| 코드 레벨만 | 간단 | 동시 요청 시 경합 가능 | |

### Branch 4: 후기 작성 권한 검증

| 방식 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| **usage_idx 기반 검증** | **스캔 기록과 직접 연결** | **usage_idx 필수** | **✅ 채택** |
| idx_company + idx_member | 간단 | 스캔 없이 작성 가능 (보안 취약) | |
| 토큰 기반 | 보안 강화 | 토큰 관리 복잡 | |

### Branch 5: 포인트 적립 시점

| 방식 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| **후기 저장 + 사진 연결 후 즉시** | **트랜잭션 일관성** | **롤백 시 포인트 처리** | **✅ 채택** |
| 관리자 승인 후 | 품질 보장 | 사용자 대기 불편 | |
| 비동기 배치 처리 | 서버 부하 분산 | 실시간성 저하 | |

---

## 4. DB 스키마

### 4.1 company_reviews 테이블

```sql
CREATE TABLE company_reviews (
    idx INT AUTO_INCREMENT PRIMARY KEY,
    idx_company INT NOT NULL DEFAULT 0,          -- 업소 idx (FK → company.idx)
    idx_member INT NOT NULL DEFAULT 0,           -- 작성자 회원 idx (FK → sf_member.idx)
    usage_idx INT NOT NULL DEFAULT 0,            -- QR 스캔 기록 idx (FK → company_qr_code_usages.idx)
    content LONGTEXT NOT NULL,                   -- 후기 본문 (최소 10자)
    reward_points INT NOT NULL DEFAULT 0,        -- 적립된 보상 포인트 (2,000~3,000)
    created_at INT NOT NULL DEFAULT 0,           -- 작성 시각 (Unix timestamp)
    UNIQUE KEY idx_usage (usage_idx),            -- 동일 스캔 기록에 1회만 후기 작성
    KEY idx_company (idx_company),               -- 업소별 조회 인덱스
    KEY idx_member (idx_member)                  -- 작성자별 조회 인덱스
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**핵심 제약 조건**:
- `usage_idx` UNIQUE: 하나의 QR 스캔 기록에 대해 1개의 후기만 허용
- `content` LONGTEXT: 긴 후기 내용도 저장 가능

### 4.2 관련 테이블 — uploads (사진 연결)

후기 사진은 기존 v7 Upload 시스템의 `uploads` 테이블을 활용한다.

```sql
-- uploads 테이블에서 후기 사진 조회 조건:
SELECT * FROM uploads
WHERE module = 'visit_review'
  AND code = ''
  AND attached_to = {review.idx};
```

| 필드 | 값 | 설명 |
|------|-----|------|
| `module` | `'visit_review'` | 방문 후기 모듈 |
| `code` | `''` | 빈 값 |
| `attached_to` | `review.idx` | 후기 idx에 연결 |

### 4.3 관련 테이블 — sf_point_log (포인트 로그)

```sql
-- 방문 후기 포인트 로그 조회:
SELECT * FROM sf_point_log
WHERE module = 'company'
  AND action = 'visit_review'
  AND idx_member_to = {idx_member};
```

| 필드 | 값 | 설명 |
|------|-----|------|
| `module` | `'company'` | 업소록 모듈 |
| `action` | `'visit_review'` | 방문 후기 액션 |
| `idx_member_from` | `0` | 시스템 (발신자 없음) |
| `idx_member_to` | `{idx_member}` | 후기 작성자 |
| `point` | `2000~3000` | 적립 포인트 |
| `etc` | `'{업소명} 방문 후기 보상 (usage_idx:{N})'` | 설명 |

---

## 5. 아키텍처

```
클라이언트
  ↓
api.php → CompanyController
              ↓
          CompanyService::submitVisitReview()
           ↓          ↓              ↓
  QrCodeUsageRepo   VisitReviewRepo   UploadRepo
     ↓                  ↓                 ↓
  usages 테이블    reviews 테이블    uploads 테이블
                                         ↓
                               PointLogService::changePoints()
                                         ↓
                                  sf_point_log 테이블
```

후기 조회 흐름:

```
클라이언트
  ↓
api.php → CompanyController
              ↓
          CompanyService::getVisitReviews()
           ↓                    ↓
  VisitReviewRepo         UploadRepo::findByAttached()
     ↓                         ↓
  reviews 테이블           uploads 테이블 (사진)
     ↓                         ↓
  VisitReviewEntity[]     → photos[] 런타임 주입
     ↓
  toArray() → JSON 응답
```

---

## 6. 파일 구조

```
lib/company/
├── CompanyController.php        # ★ submitVisitReview(), getVisitReviews() API 엔드포인트
├── CompanyService.php           # ★ submitVisitReview(), getVisitReviews() 비즈니스 로직
├── VisitReviewEntity.php        # ★ company_reviews 테이블 Entity (POPO)
├── VisitReviewRepository.php    # ★ company_reviews 테이블 DB CRUD
├── CompanyRepository.php        # 업소 정보 조회 (업소명 등)
├── QrCodeUsageRepository.php    # QR 스캔 기록 조회 (권한 검증)
└── ... (기타 Company 관련 파일)

lib/upload/
└── UploadRepository.php         # updateAttached(), findByAttached() — 사진 연결/조회

lib/point_log/
└── PointLogService.php          # changePoints() — 포인트 적립

company/
├── visit-review-point.php       # ★ 후기 작성 페이지 (Vue.js + Bootstrap)
├── re-visit-point.php           # 재방문 포인트 → "후기 작성" 버튼 연결
└── view.php                     # 업소 상세 → 하단 후기 목록 표시
```

---

## 7. Entity 클래스

### 7.1 VisitReviewEntity

**파일**: `lib/company/VisitReviewEntity.php`
**네임스페이스**: `Philgo\Company`
**테이블**: `company_reviews`

```php
class VisitReviewEntity
{
    // DB 컬럼 매핑
    public int $idx = 0;                    // 후기 고유 번호 (PK)
    public int $idx_company = 0;            // 업소 idx (FK)
    public int $idx_member = 0;             // 작성자 회원 idx (FK)
    public int $usage_idx = 0;              // QR 스캔 기록 idx (FK, UNIQUE)
    public string $content = '';            // 후기 본문 (최소 10자)
    public int $reward_points = 0;          // 적립된 보상 포인트 (2,000~3,000)
    public int $created_at = 0;             // 작성 시각 (Unix timestamp)

    // 런타임 속성 (DB 컬럼 아님)
    /** @var array uploads 테이블에서 조회한 사진 목록 (UploadEntity[]) */
    public array $photos = [];
}
```

**주요 메서드**:

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `fromArray` | `(array $data): self` | DB 행 → Entity 변환 |
| `toArray` | `(): array` | Entity → 배열 변환 (**photos 포함**) |

**toArray() 응답 구조**:

```json
{
    "idx": 15,
    "idx_company": 1337,
    "idx_member": 100,
    "usage_idx": 42,
    "content": "음식이 맛있고 분위기도 좋았습니다. 재방문 의사 100%!",
    "reward_points": 2500,
    "created_at": 1709337600,
    "photos": [
        {
            "idx": 101,
            "url": "https://...",
            "module": "visit_review",
            "code": "",
            "attached_to": 15
        },
        {
            "idx": 102,
            "url": "https://...",
            "module": "visit_review",
            "code": "",
            "attached_to": 15
        }
    ]
}
```

**핵심 구현** — `toArray()`에서 photos 배열 변환:

```php
public function toArray(): array
{
    return [
        'idx' => $this->idx,
        'idx_company' => $this->idx_company,
        // ... 기본 필드 ...
        'photos' => array_map(fn($photo) => $photo->toArray(), $this->photos),
    ];
}
```

---

## 8. Repository 클래스

### 8.1 VisitReviewRepository

**파일**: `lib/company/VisitReviewRepository.php`
**네임스페이스**: `Philgo\Company`
**테이블**: `company_reviews`

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `insert` | `(array $data): int` | 후기 INSERT, 생성된 idx 반환 |
| `findByIdx` | `(int $idx): ?VisitReviewEntity` | idx로 후기 1건 조회 |
| `findByUsageIdx` | `(int $usageIdx): ?VisitReviewEntity` | QR 스캔 기록 idx로 후기 조회 |
| `existsByUsageIdx` | `(int $usageIdx): bool` | 동일 usage_idx 후기 존재 여부 (중복 방지) |
| `findByCompany` | `(int $idxCompany, int $page, int $limit): VisitReviewEntity[]` | 업소별 후기 목록 (페이지네이션, 최신순) |
| `countByCompany` | `(int $idxCompany): int` | 업소별 후기 총 개수 |

**핵심 구현 — insert()**: created_at 자동 설정

```php
public static function insert(array $data): int
{
    if (!isset($data['created_at'])) {
        $data['created_at'] = time();
    }
    // 동적 컬럼/플레이스홀더 생성
    $columns = array_keys($data);
    $placeholders = array_map(fn($col) => ":$col", $columns);
    $sql = "INSERT INTO company_reviews (...) VALUES (...)";
    $stmt = Db::pdo()->prepare($sql);
    $stmt->execute($data);
    return (int)Db::pdo()->lastInsertId();
}
```

**핵심 구현 — findByCompany()**: 페이지네이션 + 최신순 정렬

```php
public static function findByCompany(int $idxCompany, int $page = 1, int $limit = 10): array
{
    $offset = ($page - 1) * $limit;
    $stmt = Db::pdo()->prepare(
        "SELECT * FROM company_reviews WHERE idx_company = :idx_company ORDER BY idx DESC LIMIT :lmt OFFSET :ofs"
    );
    $stmt->bindValue('idx_company', $idxCompany, PDO::PARAM_INT);
    $stmt->bindValue('lmt', $limit, PDO::PARAM_INT);
    $stmt->bindValue('ofs', $offset, PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    return array_map(fn($row) => VisitReviewEntity::fromArray($row), $rows);
}
```

**핵심 구현 — existsByUsageIdx()**: 중복 후기 확인

```php
public static function existsByUsageIdx(int $usageIdx): bool
{
    $stmt = Db::pdo()->prepare("SELECT COUNT(*) FROM company_reviews WHERE usage_idx = :usage_idx");
    $stmt->execute(['usage_idx' => $usageIdx]);
    return (int)$stmt->fetchColumn() > 0;
}
```

---

## 9. Service 비즈니스 로직

### 9.1 submitVisitReview — 후기 제출

**파일**: `lib/company/CompanyService.php` (937~1056줄)
**시그니처**: `CompanyService::submitVisitReview(array $input): array`

**입력 파라미터**:

| 키 | 타입 | 필수 | 설명 |
|----|------|------|------|
| `usage_idx` | int | ✅ | QR 스캔 기록 idx |
| `idx_member` | int | ✅ | 로그인 회원 idx (Controller에서 주입) |
| `content` | string | ✅ | 후기 본문 (최소 10자) |
| `photo_idxs` | int[] | ✅ | 업로드된 사진 idx 배열 (1장 이상) |

**8단계 검증 체인** (CompanyService.php:951~990):

| 단계 | 검증 | 라인 | 에러 메시지 |
|------|------|------|------------|
| 1 | 로그인 확인 | 952 | `로그인이 필요합니다.` |
| 2 | usage_idx > 0 | 957 | `유효하지 않은 요청입니다.` |
| 3 | 스캔 기록 존재 | 962-964 | `스캔 기록을 찾을 수 없습니다.` |
| 4 | 본인 스캔 기록 | 968 | `본인의 스캔 기록이 아닙니다.` |
| 5 | 성공한 스캔 (result='s') | 973 | `유효한 스캔 기록이 아닙니다.` |
| 6 | 중복 후기 방지 | 978 | `이미 후기를 작성하셨습니다.` |
| 7 | 내용 >= 10자 | 983 | `후기 내용을 10자 이상 작성해 주세요.` |
| 8 | 사진 >= 1장 | 988 | `사진을 1장 이상 첨부해 주세요.` |

**처리 흐름** (CompanyService.php:992~1055):

```
검증 통과 후:
  ↓
9.  업소 정보 조회 (CompanyRepository::findByIdx)     — 995줄
10. 랜덤 포인트 결정 (random_int(2000, 3000))         — 999줄
11. 후기 저장 (VisitReviewRepository::insert)          — 1008줄
12. 사진 연결 (UploadRepository::updateAttached)       — 1018줄
13. 포인트 적립 (PointLogService::changePoints)         — 1026줄
  ↓
결과 반환
```

**응답 구조**:

```json
{
    "success": true,
    "review_idx": 15,
    "reward_points": 2500,
    "point_before": 10000,
    "point_after": 12500,
    "company_name": "스시오마카세",
    "idx_company": 1337
}
```

**핵심 코드** — 후기 저장 + 사진 연결 + 포인트 적립:

```php
// 11. 후기 저장
$reviewIdx = VisitReviewRepository::insert([
    'idx_company' => $idxCompany,
    'idx_member' => $idxMember,
    'usage_idx' => $usageIdx,
    'content' => $content,
    'reward_points' => $rewardPoints,
    'created_at' => time(),
]);

// 12. 사진 연결: 각 upload의 attached_to를 후기 idx로 업데이트
foreach ($photoIdxs as $photoIdx) {
    $photoIdx = (int)$photoIdx;
    if ($photoIdx > 0) {
        \Philgo\Upload\UploadRepository::updateAttached($photoIdx, $reviewIdx);
    }
}

// 13. 포인트 적립
$pointLog = PointLogService::changePoints(
    $rewardPoints,
    0,                    // idx_member_from (시스템)
    $idxMember,           // idx_member_to
    'company',            // module
    'visit_review',       // action
    0,                    // idx_post
    $companyName . ' 방문 후기 보상 (usage_idx:' . $usageIdx . ')'
);
```

### 9.2 getVisitReviews — 후기 목록 조회

**파일**: `lib/company/CompanyService.php` (1069~1093줄)
**시그니처**: `CompanyService::getVisitReviews(array $input): array`

**입력 파라미터**:

| 키 | 타입 | 필수 | 기본값 | 설명 |
|----|------|------|--------|------|
| `idx_company` | int | ✅ | - | 업소 idx |
| `page` | int | | 1 | 페이지 번호 (1부터) |
| `limit` | int | | 10 | 페이지당 개수 (최대 50) |

**처리 흐름** (CompanyService.php:1071~1092):

```
1. idx_company 검증 (> 0)                                — 1072줄
2. page/limit 정규화 (max/min)                            — 1076줄
3. 후기 목록 조회 (VisitReviewRepository::findByCompany)  — 1079줄
4. 총 개수 조회 (VisitReviewRepository::countByCompany)   — 1080줄
5. 각 후기의 사진 로드 (UploadRepository::findByAttached) — 1083줄
6. Entity → 배열 변환 (toArray)                           — 1088줄
```

**응답 구조**:

```json
{
    "reviews": [
        {
            "idx": 15,
            "idx_company": 1337,
            "idx_member": 100,
            "usage_idx": 42,
            "content": "음식이 맛있고...",
            "reward_points": 2500,
            "created_at": 1709337600,
            "photos": [
                { "idx": 101, "url": "...", "module": "visit_review", "code": "" }
            ]
        }
    ],
    "total": 25,
    "page": 1,
    "limit": 10
}
```

**핵심 코드** — 사진 런타임 주입:

```php
$reviews = VisitReviewRepository::findByCompany($idxCompany, $page, $limit);
$total = VisitReviewRepository::countByCompany($idxCompany);

// 각 후기에 연결된 사진 목록을 uploads 테이블에서 조회
foreach ($reviews as $review) {
    $review->photos = \Philgo\Upload\UploadRepository::findByAttached(
        'visit_review',   // module
        '',               // code (빈 값)
        $review->idx      // attached_to (후기 idx)
    );
}

return [
    'reviews' => array_map(fn($r) => $r->toArray(), $reviews),
    'total' => $total,
    'page' => $page,
    'limit' => $limit,
];
```

### 9.3 deleteVisitReview — 후기 삭제 (관리자 전용)

**파일**: `lib/company/CompanyService.php` (1116~1141줄)
**시그니처**: `CompanyService::deleteVisitReview(array $input): array`

**입력 파라미터**:

| 키 | 타입 | 필수 | 설명 |
|----|------|------|------|
| `idx` | int | ✅ | 삭제할 후기 idx |
| `is_admin` | bool | ✅ | 관리자 여부 (Controller에서 주입) |

**3단계 검증 체인** (CompanyService.php:1118~1132):

| 단계 | 검증 | 라인 | 에러 메시지 |
|------|------|------|------------|
| 1 | 관리자 확인 | 1119 | `관리자만 삭제할 수 있습니다.` |
| 2 | idx > 0 | 1124 | `후기 idx가 필요합니다.` |
| 3 | 후기 존재 확인 | 1130 | `후기를 찾을 수 없습니다.` |

**처리 흐름** (CompanyService.php:1134~1140):

```
검증 통과 후:
  ↓
4. 연결된 사진 삭제 (UploadRepository::deleteByAttached)  — 1135줄
5. 후기 레코드 삭제 (VisitReviewRepository::deleteByIdx)  — 1138줄
  ↓
결과 반환
```

**응답 구조**:

```json
{
    "success": true
}
```

**핵심 코드** — 사진 삭제 + 후기 삭제:

```php
// 3. 연결된 사진 삭제 (module='visit_review', code='')
\Philgo\Upload\UploadRepository::deleteByAttached('visit_review', '', $idx);

// 4. 후기 레코드 삭제
VisitReviewRepository::deleteByIdx($idx);

return ['success' => true];
```

---

## 10. Controller API 엔드포인트

### 10.1 company.submitVisitReview — 후기 제출

**파일**: `lib/company/CompanyController.php` (402~406줄)

```
GET/POST https://local.philgo.com/api.php?method=company.submitVisitReview
    &usage_idx=42
    &content=맛있었습니다...
    &photo_idxs[]=101
    &photo_idxs[]=102
    &session_id=xxx
```

**인증**: 필수 (로그인 사용자)

**Controller 코드**:

```php
public function submitVisitReview(array $input): array
{
    $input['idx_member'] = $this->getAuthenticatedMemberIdx();
    return CompanyService::submitVisitReview($input);
}
```

### 10.2 company.getVisitReviews — 후기 목록 조회

**파일**: `lib/company/CompanyController.php` (421~424줄)

```
GET https://local.philgo.com/api.php?method=company.getVisitReviews
    &idx_company=1337
    &page=1
    &limit=10
```

**인증**: 불필요 (공개 조회)

**Controller 코드**:

```php
public function getVisitReviews(array $input): array
{
    return CompanyService::getVisitReviews($input);
}
```

### 10.3 company.deleteVisitReview — 후기 삭제 (관리자 전용)

**파일**: `lib/company/CompanyController.php` (457~462줄)

```
POST https://local.philgo.com/api.php
    method=company.deleteVisitReview
    idx=15
```

**인증**: 필수 (관리자만 가능, session_id는 쿠키로 자동 전송)

**Controller 코드**:

```php
public function deleteVisitReview(array $input): array
{
    $this->getAuthenticatedMemberIdx();
    $input['is_admin'] = $this->isAdmin();
    return CompanyService::deleteVisitReview($input);
}
```

**권한 검사 흐름**:

```
1. getAuthenticatedMemberIdx() → 로그인 확인 (미인증 시 RuntimeException)
2. isAdmin() → ADMINS 상수(firebase_uid 배열)에 포함 여부 확인
3. is_admin 플래그를 input에 추가 → Service에서 최종 검증
```

---

## 11. API 호출 예시

### 11.1 curl 예시

```bash
# 후기 제출
curl "https://local.philgo.com/api.php?method=company.submitVisitReview&usage_idx=42&content=맛있었습니다+정말+좋은+가게&photo_idxs[]=101&photo_idxs[]=102&session_id=xxx"

# 후기 목록 조회
curl "https://local.philgo.com/api.php?method=company.getVisitReviews&idx_company=1337&page=1&limit=10"

# 후기 삭제 (관리자만)
curl -X POST "https://local.philgo.com/api.php" \
  -d "method=company.deleteVisitReview" \
  -d "idx=15" \
  --cookie "session_id=xxx"
```

### 11.2 JavaScript (func) 호출 예시

```javascript
// 후기 제출
const result = await func('v7', {
    method: 'company.submitVisitReview',
    usage_idx: 42,
    content: '음식이 맛있고 분위기도 좋았습니다. 재방문 의사 100%!',
    photo_idxs: [101, 102, 103]
});
console.log(result.review_idx);      // 생성된 후기 idx
console.log(result.reward_points);   // 적립된 포인트 (2000~3000)
console.log(result.point_after);     // 적립 후 총 포인트

// 후기 목록 조회
const reviews = await func('v7', {
    method: 'company.getVisitReviews',
    idx_company: 1337,
    page: 1,
    limit: 10
});
console.log(reviews.total);         // 전체 후기 수
reviews.reviews.forEach(r => {
    console.log(r.content, r.photos.length + '장');
});

// 후기 삭제 (관리자만, v7api 사용)
// session_id는 쿠키로 자동 전송되므로 별도 전달 불필요
try {
    await v7api('company.deleteVisitReview', { idx: 15 });
    console.log('삭제 성공');
} catch (e) {
    // v7api()가 alertOnError 기본 옵션으로 에러 메시지 자동 표시
}
```

### 11.3 Flutter (v7api) 호출 예시

```dart
// 후기 제출
final result = await v7api('company.submitVisitReview', {
    'usage_idx': usageIdx,
    'content': reviewContent,
    'photo_idxs': uploadedPhotoIdxs,
});
print('적립 포인트: ${result['reward_points']}P');
print('현재 포인트: ${result['point_after']}P');

// 후기 목록 조회
final reviews = await v7api('company.getVisitReviews', {
    'idx_company': companyIdx,
    'page': 1,
    'limit': 10,
});
for (final r in reviews['reviews']) {
    print('${r['content']} (사진 ${r['photos'].length}장)');
}

// 후기 삭제 (관리자만)
final deleteResult = await v7api('company.deleteVisitReview', {
    'idx': reviewIdx,
});
print('삭제 성공: ${deleteResult['success']}');
```

---

## 12. 삼단콤보 포인트 시스템

### 12.1 전체 흐름

```
[1단계] QR 스캔 → scanQrCode()
  ├─ 포인트: 1,000~2,000P (random_int)
  ├─ 모듈/액션: company / qr_scan
  ├─ 조건: 로그인 사용자, 24시간 중복 불가
  └─ 페이지: qr-code-scanned.php

[2단계] 재방문 추첨 → reVisitPoint()
  ├─ 포인트: 2,000~3,000P (random_int)
  ├─ 모듈/액션: company / qr_revisit
  ├─ 조건: 24시간 이전 방문 이력 보유, 중복 적립 방지
  └─ 페이지: re-visit-point.php

[3단계] 후기 작성 → submitVisitReview()
  ├─ 포인트: 2,000~3,000P (random_int)
  ├─ 모듈/액션: company / visit_review
  ├─ 조건: 성공 스캔 기록, 사진 1+장, 내용 10+자, 중복 불가
  └─ 페이지: visit-review-point.php
```

### 12.2 포인트 적립 매트릭스

| 단계 | API | module | action | 포인트 범위 | 조건 |
|------|-----|--------|--------|-------------|------|
| 1단계 | scanQrCode | `company` | `qr_scan` | 1,000~2,000 | 로그인 + 24시간 중복 X |
| 2단계 | reVisitPoint | `company` | `qr_revisit` | 2,000~3,000 | 재방문자 + 1회 제한 |
| 3단계 | submitVisitReview | `company` | `visit_review` | 2,000~3,000 | 사진+글 + 1회 제한 |

### 12.3 최대/최소 적립

| 시나리오 | 1단계 | 2단계 | 3단계 | 합계 |
|----------|-------|-------|-------|------|
| **최대** | 2,000 | 3,000 | 3,000 | **8,000P** |
| **최소** | 1,000 | 2,000 | 2,000 | **5,000P** |
| **평균** | 1,500 | 2,500 | 2,500 | **6,500P** |
| 신규 방문 (1단계만) | 2,000 | - | - | **2,000P** |
| 신규 방문 + 후기 | 2,000 | - | 3,000 | **5,000P** |

---

## 13. 사진 처리

### 13.1 업로드 흐름

```
클라이언트에서 사진 업로드 (v7 Upload API)
  ↓
uploads 테이블에 저장 (module='visit_review', code='')
  ↓
클라이언트에서 photo_idxs[] 배열로 전달
  ↓
submitVisitReview() 내에서 UploadRepository::updateAttached() 호출
  ↓
uploads.attached_to = review.idx 로 업데이트
```

### 13.2 사진 연결 코드 (CompanyService.php:1017~1023)

```php
// 각 업로드된 사진의 attached_to를 후기 idx로 업데이트
foreach ($photoIdxs as $photoIdx) {
    $photoIdx = (int)$photoIdx;
    if ($photoIdx > 0) {
        \Philgo\Upload\UploadRepository::updateAttached($photoIdx, $reviewIdx);
    }
}
```

### 13.3 사진 조회 코드 (CompanyService.php:1082~1085)

```php
// 각 후기에 연결된 사진 목록을 uploads 테이블에서 조회
foreach ($reviews as $review) {
    $review->photos = \Philgo\Upload\UploadRepository::findByAttached(
        'visit_review',   // module
        '',               // code (빈 값)
        $review->idx      // attached_to 값
    );
}
```

### 13.4 사진 업로드 파라미터

후기 사진을 업로드할 때 v7 Upload API에 다음 파라미터를 전달한다:

| 파라미터 | 값 | 설명 |
|---------|-----|------|
| `module` | `visit_review` | 방문 후기 모듈 |
| `code` | `` (빈 값) | 코드 없음 |
| `attached_to` | `0` (임시) → 이후 `review.idx`로 업데이트 | 후기 생성 후 연결 |

---

## 14. 에러 처리

### 14.1 검증 에러 목록

| 단계 | 조건 | 에러 메시지 | HTTP 상태 |
|------|------|------------|-----------|
| 1 | `idx_member <= 0` | `로그인이 필요합니다.` | 401 |
| 2 | `usage_idx <= 0` | `유효하지 않은 요청입니다.` | 400 |
| 3 | 스캔 기록 null | `스캔 기록을 찾을 수 없습니다.` | 404 |
| 4 | 본인 아님 | `본인의 스캔 기록이 아닙니다.` | 403 |
| 5 | result !== 's' | `유효한 스캔 기록이 아닙니다.` | 400 |
| 6 | 후기 이미 존재 | `이미 후기를 작성하셨습니다.` | 409 |
| 7 | 내용 < 10자 | `후기 내용을 10자 이상 작성해 주세요.` | 400 |
| 8 | 사진 < 1장 | `사진을 1장 이상 첨부해 주세요.` | 400 |

### 14.2 삭제 에러

| 단계 | 조건 | 에러 메시지 | HTTP 상태 |
|------|------|------------|-----------|
| 1 | 비관리자 | `관리자만 삭제할 수 있습니다.` | 403 |
| 2 | `idx <= 0` | `후기 idx가 필요합니다.` | 400 |
| 3 | 후기 미존재 | `후기를 찾을 수 없습니다.` | 404 |

### 14.3 조회 에러

| 조건 | 에러 메시지 |
|------|------------|
| `idx_company <= 0` | `업소 idx가 필요합니다.` |

### 14.4 에러 응답 형식

모든 에러는 `RuntimeException`으로 throw되며, `api.php`에서 catch하여 JSON 응답:

```json
{
    "success": false,
    "message": "에러 메시지"
}
```

---

## 15. 포인트 적립 상세

### 15.1 적립 코드 (CompanyService.php:1026~1034)

```php
$pointLog = PointLogService::changePoints(
    $rewardPoints,                  // 적립 포인트 (2,000~3,000)
    0,                              // idx_member_from (시스템=0)
    $idxMember,                     // idx_member_to (수령자)
    'company',                      // module
    'visit_review',                 // action
    0,                              // idx_post (미사용)
    $companyName . ' 방문 후기 보상 (usage_idx:' . $usageIdx . ')'  // etc 설명
);
```

### 15.2 적립 후 반환값

`PointLogService::changePoints()`는 PointLogEntity를 반환한다:

| 필드 | 설명 |
|------|------|
| `$pointLog->idx` | 포인트 로그 idx |
| `$pointLog->point_before` | 적립 전 포인트 |
| `$pointLog->point_after` | 적립 후 포인트 |

### 15.3 Debug 로그

`submitVisitReview()` 내에서 3단계 Debug::log() 기록:

| 시점 | 로그 태그 | 기록 항목 |
|------|-----------|-----------|
| 시작 | `[VISIT-REVIEW] 후기 제출 시작` | usage_idx, idx_member, content_length, photo_count |
| 포인트 결정 | `[VISIT-REVIEW] 포인트 결정` | reward_points, idx_company, company_name |
| 완료 | `[VISIT-REVIEW] 후기 저장 + 포인트 적립 완료` | review_idx, reward_points, point_before, point_after, photo_count |

로그 파일 위치: `var/debug.log`

---

## 16. 웹 페이지 통합

### 16.1 company/visit-review-point.php — 후기 작성 페이지

사용자가 "후기 작성" 버튼 클릭 시 이동하는 페이지.
Vue.js + Bootstrap 기반으로 구현되어 있으며, v7 Upload API로 사진 업로드 후
`company.submitVisitReview` API로 후기를 제출한다.

**접속 URL**: `https://local.philgo.com/company/visit-review-point.php?usage_idx=42`

**파라미터**: `usage_idx` — QR 스캔 기록 idx

**UI 구성**:
- 사진 업로드 영역 (v7 Upload API 연동)
- 후기 내용 입력 textarea (최소 10자 안내)
- 제출 버튼
- 적립 결과 표시 (성공 시)

### 16.2 company/re-visit-point.php — 후기 작성 버튼 연결

재방문 포인트 적립 성공 후 페이지에 "후기 작성하기" 버튼이 표시된다.
이 버튼을 클릭하면 `visit-review-point.php?usage_idx={N}`으로 이동한다.

### 16.3 company/view.php — 업소 상세 페이지 하단 후기 표시

업소 상세 페이지 하단에 `company.getVisitReviews` API를 호출하여
해당 업소의 방문 후기 목록을 표시한다.

관리자인 경우 각 후기 카드에 "삭제" 버튼이 표시되며,
`v7api('company.deleteVisitReview', { idx })` 호출로 후기를 삭제한다.
`session_id`는 쿠키로 자동 전송되므로 별도 전달이 불필요하다.

**삭제 JavaScript 코드** (company/view.php):

```javascript
async function deleteVisitReview(idx, btn) {
    if (!confirm('정말 삭제하시겠습니까?')) return;
    try {
        await v7api('company.deleteVisitReview', { idx: idx });
        var card = btn.closest('.card');
        if (card) card.remove();
    } catch (e) {
        // v7api()가 alertOnError 기본 옵션으로 에러 메시지 자동 표시
    }
}
```

---

## 17. 전체 데이터 흐름도

### 17.1 후기 제출 전체 흐름

```
[사용자] 업소 방문 → QR 코드 스캔
  ↓
[qr-code-scanned.php]
  ├─ company.scanQrCode API 호출
  ├─ 1단계 포인트 적립 (1,000~2,000P)
  ├─ 재방문자? → "재방문 포인트 추첨" 버튼 표시
  └─ "후기 작성" 버튼 표시
  ↓
[re-visit-point.php] (재방문자만)
  ├─ reVisitPoint() 호출
  ├─ 2단계 포인트 적립 (2,000~3,000P)
  └─ "후기 작성하기" 버튼 표시
  ↓
[visit-review-point.php]
  ├─ 사진 업로드 (v7 Upload API)
  │   └─ uploads 테이블에 임시 저장 (module='visit_review', code='', attached_to=0)
  ├─ 후기 내용 작성 (10자 이상)
  ├─ "제출" 클릭
  │   └─ company.submitVisitReview API 호출
  │       ├─ 8단계 검증
  │       ├─ company_reviews 테이블에 INSERT
  │       ├─ uploads.attached_to → review.idx 업데이트
  │       └─ sf_point_log에 포인트 적립
  └─ 3단계 포인트 적립 결과 표시 (2,000~3,000P)
```

### 17.2 후기 삭제 전체 흐름 (관리자)

```
[관리자] 업소 상세 페이지 (company/view.php)
  ├─ 후기 카드의 "삭제" 버튼 클릭
  ├─ confirm() 확인 대화상자
  └─ v7api('company.deleteVisitReview', { idx: N }) 호출
  ↓
[api.php]
  ↓
[CompanyController::deleteVisitReview()]
  ├─ getAuthenticatedMemberIdx() → 로그인 확인
  ├─ isAdmin() → ADMINS 상수로 관리자 확인
  └─ is_admin 플래그를 input에 추가
  ↓
[CompanyService::deleteVisitReview()]
  ├─ 관리자 확인 (is_admin 플래그)
  ├─ idx 유효성 검증
  ├─ 후기 존재 확인 (VisitReviewRepository::findByIdx)
  ├─ 연결된 사진 삭제 (UploadRepository::deleteByAttached)
  │   └─ uploads 테이블에서 module='visit_review', attached_to=idx 레코드 삭제
  └─ 후기 레코드 삭제 (VisitReviewRepository::deleteByIdx)
      └─ company_reviews 테이블에서 DELETE
  ↓
JSON 응답 { "success": true }
  ↓
[프론트엔드] 해당 카드 DOM 제거 (card.remove())
```

### 17.3 후기 조회 흐름

```
[사용자] 업소 상세 페이지 방문 (company/view.php)
  ↓
company.getVisitReviews API 호출
  ↓
CompanyService::getVisitReviews()
  ├─ VisitReviewRepository::findByCompany() → 후기 목록
  ├─ VisitReviewRepository::countByCompany() → 전체 개수
  └─ UploadRepository::findByAttached() → 각 후기의 사진 로드
  ↓
JSON 응답 → 프론트엔드 렌더링
  ├─ 후기 내용 표시
  ├─ 사진 썸네일 표시
  ├─ 적립 포인트 표시
  └─ 페이지네이션
```

### 17.4 DB 테이블 관계도

```
company (업소 정보)
  │
  ├─ company_qr_codes (QR 코드 발행)
  │     │
  │     └─ company_qr_code_usages (QR 스캔 기록)
  │           │
  │           └─ company_reviews (방문 후기)  ← usage_idx FK
  │                 │
  │                 └─ uploads (사진)  ← attached_to = review.idx
  │                       module='visit_review', code=''
  │
  └─ sf_point_log (포인트 로그)
        module='company'
        action IN ('qr_scan', 'qr_revisit', 'visit_review')
```
