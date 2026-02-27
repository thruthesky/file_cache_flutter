# Company API - v7 시스템 (PSR-4)

> **✅ 구현 완료** — 모든 API 엔드포인트, PEST Unit Test 검증 완료

## 목차

- [1. 개요](#1-개요)
- [2. CoT 분석: 단계별 설계](#2-cot-분석-단계별-설계)
- [3. ToT 분석: 설계 결정 트리](#3-tot-분석-설계-결정-트리)
- [4. DB 스키마](#4-db-스키마)
- [5. 아키텍처](#5-아키텍처)
- [6. 파일 구조](#6-파일-구조)
- [7. Entity 클래스](#7-entity-클래스)
- [8. Repository 클래스](#8-repository-클래스)
- [9. Service 클래스](#9-service-클래스)
- [10. Controller 클래스](#10-controller-클래스)
- [11. API 엔드포인트](#11-api-엔드포인트)
- [12. Company Meta API](#12-company-meta-api)
- [13. Status 흐름](#13-status-흐름)
- [14. 권한 모델](#14-권한-모델)
- [15. PSR-4 Autoload 설정](#15-psr-4-autoload-설정)
- [16. PEST Unit Test](#16-pest-unit-test)
- [17. 레거시(v6)와의 관계](#17-레거시v6와의-관계)

---

## 1. 개요

### 1.1 배경

업소록(Company)은 필고의 핵심 기능으로, 사업체 정보를 등록/관리/검색하는 시스템이다.
v6 레거시 코드(`lib/company.functions.php`, `lib/company_meta.functions.php`)를 참고하여
v7 형식의 PSR-4 기반 API를 `lib/company/` 하위 폴더에 구현한다.

### 1.2 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **Entity + Repository + Service + Controller** | Upload API와 동일한 4계층 아키텍처 |
| **company + company_meta 이중 구조** | company 테이블(기본 정보) + company_meta 테이블(확장 메타) |
| **상태 기반 승인 시스템** | `'' → 'p' → 'a'` 상태 전이, 관리자만 승인/거절 가능 |
| **소유자/관리자 권한 모델** | idx_member로 소유자 판별, 관리자는 모든 업소 관리 가능 |
| **자동 업소 생성** | `mine()` 호출 시 업소가 없으면 자동으로 빈 레코드 생성 |
| **QR 코드 조건부 활성화** | `show_qr_code=1` AND `status='a'` 조건 충족 시에만 활성화 |
| **메타 Upsert** | key 존재 시 UPDATE, 미존재 시 INSERT |
| **기존 코드 공존** | 동일 DB 테이블을 공유하며 v6 코드와 완벽 공존 |

### 1.3 관련 테이블

- **company**: 업소 기본 정보 (33개 컬럼)
- **company_meta**: 업소 확장 메타 정보 (11개 컬럼)
- **sf_member**: 회원 정보 (소유자 참조)

---

## 2. CoT 분석: 단계별 설계

### Step 1: 테이블 구조 파악

- **company 테이블**: idx, idx_member, name, title, description, category, location, address, created_at, updated_at, phone_number, mobile_number 등 33개 컬럼
  - UNIQUE 제약: `idx_member`, `family_site_domain`(idx_domain 인덱스)
- **company_meta 테이블**: idx, idx_company, group, category, type, key, value, url, primary, secondary, all_page 11개 컬럼
  - 예약어 주의: `group`, `key`, `primary`는 MySQL 예약어 → backtick 필수

### Step 2: v6 비즈니스 로직 분석

- **status 흐름**: `''` (empty/신규) → `'p'` (pending/심사중) → `'a'` (approved/승인)
- **소유권**: `idx_member`로 소유자 판별, 관리자(`is_admin()`)는 모든 업소 수정 가능
- **업데이트 시 status 변경**: description, title_image_url, photo_url 수정 시 자동으로 `'p'`(pending)로 변경
- **QR 코드**: `show_qr_code=1` AND `status='a'` 일 때만 활성화
- **meta Upsert**: key 존재 시 UPDATE, 미존재 시 INSERT
- **mine()**: 회원의 업소를 조회하되, 없으면 빈 레코드를 자동 생성

### Step 3: v7 아키텍처 적용 방침

- **PSR-4**: `Philgo\Company\` → `lib/company/`
- **DB 접근**: `Db::pdo()->prepare()` + `execute()` (v6의 `db_select`, `db_update` 등 사용 금지)
- **인증**: `AuthService::getLoginUser()` (v6의 `login()` 사용 금지)
- **에러**: `RuntimeException` throw (api.php가 catch하여 JSON 응답)
- **Entity**: POPO 패턴, `fromArray()` + `toArray()` 정적/인스턴스 메서드

---

## 3. ToT 분석: 설계 결정 트리

### Branch 1: Company 엔드포인트 설계

```
company.get         → 업소 조회 (인증 불필요)
company.list        → 업소 목록 (인증 불필요, 필터: category, status, location)
company.mine        → 내 업소 조회 (인증 필수, 없으면 자동 생성)
company.create      → 업소 생성 (인증 필수)
company.update      → 업소 수정 (인증 필수, 소유자/관리자)
company.delete      → 업소 삭제 (인증 필수, 소유자/관리자)
company.approve     → 업소 승인 (관리자 전용)
company.reject      → 업소 거절 (관리자 전용)
company.toggleQrCode → QR 코드 토글 (관리자 전용)
company.locations   → 지역 목록 (인증 불필요)
company.info        → 업소 상세 (업소+소유자, 인증 불필요)
```

### Branch 2: CompanyMeta 엔드포인트 설계

```
company_meta.get            → 메타 조회 (인증 불필요)
company_meta.update         → 메타 Upsert (인증 필수, 소유자/관리자)
company_meta.updateMultiple → 메타 일괄 Upsert (인증 필수, 소유자/관리자)
company_meta.delete         → 메타 삭제 (인증 필수, 소유자/관리자)
```

### Branch 3: 레거시 호환성

- v6 함수(`get_company()`, `update_company()` 등)는 그대로 유지
- v7 API는 독립적으로 동작하며 동일 DB 테이블 공유
- 상수(`COMPANY_TABLE`, `STATUS_APPROVE` 등)는 v7에서 직접 문자열 사용

---

## 4. DB 스키마

### 4.1 company 테이블

```sql
CREATE TABLE `company` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_member` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `updated_at` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `name` varchar(128) NOT NULL DEFAULT '',
  `title` varchar(256) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL DEFAULT '',
  `location` varchar(64) NOT NULL DEFAULT '',
  `address` varchar(256) NOT NULL DEFAULT '',
  `phone_number` varchar(64) NOT NULL DEFAULT '',
  `mobile_number` varchar(64) NOT NULL DEFAULT '',
  `mobile_number_call_type` varchar(16) NOT NULL DEFAULT '',
  `kakaotalk_id` varchar(64) NOT NULL DEFAULT '',
  `kakaotalk_qr_code` varchar(256) NOT NULL DEFAULT '',
  `kakaotalk_qr_code_url` varchar(512) NOT NULL DEFAULT '',
  `telegram_id` varchar(64) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT '',
  `logo_url` varchar(512) NOT NULL DEFAULT '',
  `business_license_url` varchar(512) NOT NULL DEFAULT '',
  `photo_url` varchar(512) NOT NULL DEFAULT '',
  `title_image_url` varchar(512) NOT NULL DEFAULT '',
  `family_site_domain` varchar(64) DEFAULT NULL,
  `family_site_custom_domain` varchar(128) DEFAULT NULL,
  `family_site_name` varchar(128) NOT NULL DEFAULT '',
  `family_site_description` text,
  `family_site_logo_url` varchar(512) NOT NULL DEFAULT '',
  `ad_title` varchar(256) NOT NULL DEFAULT '',
  `ad_description` text,
  `ad_begin_date` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ad_end_date` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ad_click_url` varchar(512) NOT NULL DEFAULT '',
  `show_qr_code` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `idx_member` (`idx_member`),
  UNIQUE KEY `idx_domain` (`family_site_domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**주요 제약 조건**:
- `idx_member` UNIQUE: 한 회원이 하나의 업소만 가질 수 있다
- `family_site_domain` UNIQUE (idx_domain): 패밀리사이트 도메인은 중복 불가
  - 빈 값은 `NULL`로 저장해야 한다 (빈 문자열 `''`은 UNIQUE 위반)

### 4.2 company_meta 테이블

```sql
CREATE TABLE `company_meta` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_company` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `group` varchar(64) NOT NULL DEFAULT '',
  `category` varchar(64) NOT NULL DEFAULT '',
  `type` varchar(32) NOT NULL DEFAULT '',
  `key` varchar(128) NOT NULL DEFAULT '',
  `value` text NOT NULL,
  `url` varchar(512) NOT NULL DEFAULT '',
  `primary` varchar(128) NOT NULL DEFAULT '',
  `secondary` varchar(128) NOT NULL DEFAULT '',
  `all_page` char(1) NOT NULL DEFAULT '',
  PRIMARY KEY (`idx`),
  KEY `idx_company` (`idx_company`),
  KEY `idx_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**예약어 주의**: `group`, `key`, `primary`는 MySQL 예약어이므로 쿼리에서 반드시 backtick(`` ` ``)으로 감싸야 한다.

---

## 5. 아키텍처

```
클라이언트 → api.php → CompanyController → CompanyService → CompanyRepository → Db::pdo()
                  │
                  ├─ company.get, company.list, company.mine ...
                  │
                  └→ CompanyMetaController → CompanyMetaService → CompanyMetaRepository → Db::pdo()
                        │
                        ├─ company_meta.get, company_meta.update ...
```

### 계층별 역할

| 계층 | 파일 | 역할 |
|------|------|------|
| **Entity** | CompanyEntity.php, CompanyMetaEntity.php | DB 행 ↔ 객체 변환 (POPO) |
| **Repository** | CompanyRepository.php, CompanyMetaRepository.php | DB CRUD (Prepared Statement) |
| **Service** | CompanyService.php, CompanyMetaService.php | 비즈니스 로직, 권한 검사 |
| **Controller** | CompanyController.php, CompanyMetaController.php | API 엔드포인트, 인증 처리 |

---

## 6. 파일 구조

```
lib/company/
├── CompanyEntity.php          # company 테이블 Entity (POPO)
├── CompanyMetaEntity.php      # company_meta 테이블 Entity (POPO)
├── CompanyRepository.php      # company 테이블 DB CRUD
├── CompanyMetaRepository.php  # company_meta 테이블 DB CRUD
├── CompanyService.php         # company 비즈니스 로직
├── CompanyMetaService.php     # company_meta 비즈니스 로직
├── CompanyController.php      # company API 엔드포인트
└── CompanyMetaController.php  # company_meta API 엔드포인트

tests/Unit/
├── CompanyTest.php            # Company PEST 테스트 (28개)
└── CompanyMetaTest.php        # CompanyMeta PEST 테스트 (19개)
```

---

## 7. Entity 클래스

### 7.1 CompanyEntity

**파일**: `lib/company/CompanyEntity.php`
**네임스페이스**: `Philgo\Company`

```php
class CompanyEntity
{
    public int $idx = 0;
    public int $idx_member = 0;
    public string $name = '';
    public string $title = '';
    public string $description = '';
    public string $category = '';
    public string $location = '';
    public string $address = '';
    public int $created_at = 0;
    public int $updated_at = 0;
    public string $phone_number = '';
    public string $mobile_number = '';
    public string $mobile_number_call_type = '';
    public string $kakaotalk_id = '';
    public string $kakaotalk_qr_code = '';
    public string $kakaotalk_qr_code_url = '';
    public string $telegram_id = '';
    public string $status = '';              // '' | 'p' | 'a'
    public string $logo_url = '';
    public string $business_license_url = '';
    public string $photo_url = '';
    public string $title_image_url = '';
    public string $family_site_domain = '';
    public string $family_site_custom_domain = '';
    public string $family_site_name = '';
    public string $family_site_description = '';
    public string $family_site_logo_url = '';
    public string $ad_title = '';
    public string $ad_description = '';
    public int $ad_begin_date = 0;
    public int $ad_end_date = 0;
    public string $ad_click_url = '';
    public int $show_qr_code = 0;

    // 정적 팩토리
    public static function fromArray(array $data): self;

    // 배열 변환 (qr_code_enabled 계산 필드 포함)
    public function toArray(): array;

    // 상태 확인 메서드
    public function isApproved(): bool;     // status === 'a'
    public function isPending(): bool;      // status === 'p'
    public function exists(): bool;         // idx > 0
    public function qrCodeEnabled(): bool;  // show_qr_code === 1 && status === 'a'
}
```

**`toArray()` 반환값에 포함되는 계산 필드**:
- `qr_code_enabled`: `bool` — QR 코드가 실제로 활성화되었는지 (show_qr_code=1 AND status='a')

### 7.2 CompanyMetaEntity

**파일**: `lib/company/CompanyMetaEntity.php`
**네임스페이스**: `Philgo\Company`

```php
class CompanyMetaEntity
{
    public int $idx = 0;
    public int $idx_company = 0;
    public string $group = '';
    public string $category = '';
    public string $type = '';
    public string $key = '';
    public string $value = '';
    public string $url = '';
    public string $primary = '';
    public string $secondary = '';
    public string $all_page = '';

    public static function fromArray(array $data): self;
    public function toArray(): array;
}
```

---

## 8. Repository 클래스

### 8.1 CompanyRepository

**파일**: `lib/company/CompanyRepository.php`
**네임스페이스**: `Philgo\Company`

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `create` | `(array $data): int` | 업소 생성, lastInsertId 반환 |
| `findByIdx` | `(int $idx): ?CompanyEntity` | idx로 조회 |
| `findByIdxMember` | `(int $idxMember): ?CompanyEntity` | 회원번호로 조회 |
| `findByDomain` | `(string $domain): ?CompanyEntity` | 도메인으로 조회 (www, http, 포트, .philgo.com 자동 제거) |
| `findAll` | `(?string $category, ?string $status, ?string $location, string $orderby, int $limit, int $offset): CompanyEntity[]` | 필터링된 목록 조회 |
| `update` | `(int $idx, array $data): bool` | idx로 업데이트 |
| `updateByIdxMember` | `(int $idxMember, array $data): bool` | 회원번호로 업데이트 |
| `deleteByIdx` | `(int $idx): bool` | idx로 삭제 |
| `getLocations` | `(): string[]` | 승인된 업소의 고유 지역 목록 |

**중요 구현 세부사항**:

1. **`create()` — `family_site_domain` NULL 처리**:
   ```php
   'family_site_domain' => $data['family_site_domain'] ?? null,
   'family_site_custom_domain' => $data['family_site_custom_domain'] ?? null,
   ```
   → UNIQUE 인덱스(`idx_domain`) 때문에 빈 값은 반드시 `NULL`로 저장 (빈 문자열 `''` 사용 금지)

2. **`findAll()` — SQL 인젝션 방지**:
   ```php
   $allowedOrderby = ['updated_at DESC', 'updated_at ASC', 'created_at DESC', ...];
   if (!in_array($orderby, $allowedOrderby)) {
       $orderby = 'updated_at DESC';
   }
   ```
   → orderby 허용 목록 검증

3. **`findByDomain()` — 도메인 정규화**:
   ```php
   $domain = str_replace('www.', '', $domain);
   $domain = preg_replace('/^https?:\/\//', '', $domain);
   // 포트 번호 제거, .philgo.com 제거
   ```

### 8.2 CompanyMetaRepository

**파일**: `lib/company/CompanyMetaRepository.php`
**네임스페이스**: `Philgo\Company`

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `create` | `(array $data): int` | 메타 생성 |
| `findByIdx` | `(int $idx): ?CompanyMetaEntity` | idx로 조회 |
| `findByCompany` | `(int $idxCompany): array` | 전체 메타 조회 `[group => [key => Entity]]` |
| `findByCompanyAndGroup` | `(int $idxCompany, string $group): array` | 그룹별 조회 `[key => Entity]` |
| `findByCompanyAndKey` | `(int $idxCompany, string $key): ?CompanyMetaEntity` | 키로 조회 |
| `update` | `(int $idxCompany, string $key, array $data): bool` | 키로 업데이트 |
| `deleteByCompanyAndKey` | `(int $idxCompany, string $key): bool` | 키로 삭제 |
| `exists` | `(int $idxCompany, string $key): bool` | 존재 여부 확인 |

**중요 구현 세부사항**:

1. **예약어 backtick 처리**: SQL에서 `group`, `key`, `primary` 필드는 반드시 backtick으로 감싼다
   ```sql
   INSERT INTO company_meta (idx_company, `group`, `key`, value, `primary`, ...)
   ```

2. **파라미터 이름 충돌 방지**: `:group` → `:grp`, `:primary` → `:pri` 사용
   ```php
   $stmt->execute([
       'grp' => $data['group'] ?? '',
       'pri' => $data['primary'] ?? '',
   ]);
   ```

3. **update() 동적 필드 파라미터**: 필드명과 파라미터명 충돌 방지
   ```php
   $paramName = 'v_' . $field;
   $sets[] = "`$field` = :$paramName";
   $params[$paramName] = $value;
   ```

---

## 9. Service 클래스

### 9.1 CompanyService

**파일**: `lib/company/CompanyService.php`
**네임스페이스**: `Philgo\Company`

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `get` | `(array $input): CompanyEntity` | idx 또는 idx_member로 업소 조회 |
| `list` | `(array $input): array` | 업소 목록 조회 |
| `mine` | `(int $idxMember): CompanyEntity` | 내 업소 조회 (없으면 자동 생성) |
| `create` | `(array $input): CompanyEntity` | 업소 생성 |
| `update` | `(array $input): CompanyEntity` | 업소 수정 (소유자/관리자, auto pending) |
| `delete` | `(array $input): bool` | 업소 삭제 (소유자/관리자) |
| `approve` | `(array $input): CompanyEntity` | 업소 승인 (관리자 전용) |
| `reject` | `(array $input): CompanyEntity` | 업소 거절 (관리자 전용) |
| `toggleQrCode` | `(array $input): array` | QR 코드 토글 (관리자 전용) |
| `locations` | `(): array` | 승인된 업소 지역 목록 |
| `info` | `(array $input): array` | 업소 상세 (업소+소유자 정보) |

**핵심 비즈니스 로직**:

1. **`update()` — 자동 pending 처리**:
   ```php
   // description, title_image_url, photo_url 변경 시 status를 pending으로 변경
   if (isset($input['description']) || isset($input['title_image_url']) || isset($input['photo_url'])) {
       $data['status'] = 'p';
   }
   ```

2. **`update()` — 관리자 타인 업소 수정**:
   ```php
   if ($isAdmin && $idx > 0) {
       $entity = CompanyRepository::findByIdx($idx);           // 관리자가 idx로 직접 지정
   } elseif ($isAdmin && isset($input['target_idx_member'])) {
       $entity = CompanyRepository::findByIdxMember(...);      // 관리자가 다른 회원의 업소 수정
   } else {
       $entity = CompanyRepository::findByIdxMember($idxMember); // 본인 업소
   }
   ```

3. **`mine()` — 자동 생성**:
   ```php
   $entity = CompanyRepository::findByIdxMember($idxMember);
   if ($entity !== null) return $entity;
   // 없으면 빈 레코드 자동 생성
   $idx = CompanyRepository::create(['idx_member' => $idxMember, 'status' => '']);
   ```

4. **`toggleQrCode()` — 승인 상태 체크**:
   ```php
   if (!$entity->isApproved()) {
       throw new RuntimeException('승인된 업소만 QR 코드를 설정할 수 있습니다.');
   }
   ```

5. **`extractCompanyFields()` — 필드 화이트리스트**:
   ```php
   $allowedFields = [
       'name', 'title', 'description', 'category', 'location', 'address',
       'phone_number', 'mobile_number', 'mobile_number_call_type',
       'kakaotalk_id', 'kakaotalk_qr_code', 'kakaotalk_qr_code_url', 'telegram_id',
       'status', 'logo_url', 'business_license_url', 'photo_url', 'title_image_url',
       'family_site_domain', 'family_site_custom_domain', 'family_site_name',
       'family_site_description', 'family_site_logo_url',
       'ad_title', 'ad_description', 'ad_begin_date', 'ad_end_date', 'ad_click_url',
       'show_qr_code',
   ];
   ```

### 9.2 CompanyMetaService

**파일**: `lib/company/CompanyMetaService.php`
**네임스페이스**: `Philgo\Company`

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `get` | `(array $input): array` | 3가지 모드: key별, group별, 전체 |
| `upsert` | `(array $input): CompanyMetaEntity` | Upsert (존재 시 UPDATE, 미존재 시 INSERT) |
| `upsertMultiple` | `(array $input): void` | key-value 배열 일괄 Upsert |
| `delete` | `(array $input): bool` | 메타 삭제 |

**`get()` 3가지 조회 모드**:

```
1. key 지정        → 단일 레코드 반환 (toArray())
2. group 지정      → [key => Entity.toArray()] 형태 반환
3. idx_company만   → [group => [key => Entity.toArray()]] 형태 반환
```

**`upsert()` 로직**:

```php
if (CompanyMetaRepository::exists($idxCompany, $key)) {
    CompanyMetaRepository::update($idxCompany, $key, $fields);  // UPDATE
} else {
    CompanyMetaRepository::create([...]);                        // INSERT
}
```

---

## 10. Controller 클래스

### 10.1 CompanyController

**파일**: `lib/company/CompanyController.php`
**네임스페이스**: `Philgo\Company`
**API 접두사**: `company.*`

| API Method | 메서드 | 인증 | 설명 |
|------------|--------|------|------|
| `company.get` | `get(array $input): array` | 불필요 | 업소 조회 |
| `company.list` | `list(array $input): array` | 불필요 | 업소 목록 |
| `company.mine` | `mine(array $input): array` | 필수 | 내 업소 (자동 생성) |
| `company.create` | `create(array $input): array` | 필수 | 업소 생성 |
| `company.update` | `update(array $input): array` | 필수 | 업소 수정 |
| `company.delete` | `delete(array $input): bool` | 필수 | 업소 삭제 |
| `company.approve` | `approve(array $input): array` | 필수(관리자) | 업소 승인 |
| `company.reject` | `reject(array $input): array` | 필수(관리자) | 업소 거절 |
| `company.toggleQrCode` | `toggleQrCode(array $input): array` | 필수(관리자) | QR 토글 |
| `company.locations` | `locations(array $input): array` | 불필요 | 지역 목록 |
| `company.info` | `info(array $input): array` | 불필요 | 업소 상세 |

**내부 헬퍼 메서드**:
- `getAuthenticatedMemberIdx(): int` — 미인증 시 RuntimeException throw
- `isAdmin(): bool` — `($user['admin'] ?? '') === 'Y'` 확인

### 10.2 CompanyMetaController

**파일**: `lib/company/CompanyMetaController.php`
**네임스페이스**: `Philgo\Company`
**API 접두사**: `company_meta.*`

| API Method | 메서드 | 인증 | 설명 |
|------------|--------|------|------|
| `company_meta.get` | `get(array $input): array` | 불필요 | 메타 조회 |
| `company_meta.update` | `update(array $input): array` | 필수 | 메타 Upsert |
| `company_meta.updateMultiple` | `updateMultiple(array $input): array` | 필수 | 일괄 Upsert |
| `company_meta.delete` | `delete(array $input): bool` | 필수 | 메타 삭제 |

**내부 헬퍼 메서드**:
- `getAuthenticatedMemberIdx(): int`
- `assertOwnerOrAdmin(int $idxCompany): void` — 소유자 또는 관리자 검증

---

## 11. API 엔드포인트

### 11.1 company.get — 업소 조회

```
GET https://local.philgo.com/api.php?method=company.get&idx=1025
GET https://local.philgo.com/api.php?method=company.get&idx_member=100
```

**입력**: `idx` 또는 `idx_member` 중 하나 필수
**출력**: CompanyEntity.toArray()

```json
{
  "success": true,
  "data": {
    "idx": 1025,
    "idx_member": 100,
    "name": "테스트 업소",
    "status": "a",
    "qr_code_enabled": true,
    ...
  }
}
```

### 11.2 company.list — 업소 목록

```
GET https://local.philgo.com/api.php?method=company.list&status=a&category=restaurant&limit=20
```

**입력** (모두 선택):
- `category`: 카테고리 필터
- `status`: 상태 필터
- `location`: 지역 필터
- `orderby`: 정렬 (기본: `updated_at DESC`)
- `limit`: 최대 조회 수 (기본: 100)
- `offset`: 오프셋 (기본: 0)

**출력**: `{ items: [CompanyEntity.toArray(), ...] }`

### 11.3 company.mine — 내 업소 조회

```
GET https://local.philgo.com/api.php?method=company.mine&session_id=xxx
```

**인증 필수**. 업소가 없으면 자동 생성.
**출력**: CompanyEntity.toArray()

### 11.4 company.create — 업소 생성

```
GET https://local.philgo.com/api.php?method=company.create&session_id=xxx&name=테스트업소&category=restaurant
```

**인증 필수**. 이미 업소가 있으면 예외.
**출력**: CompanyEntity.toArray()

### 11.5 company.update — 업소 수정

```
GET https://local.philgo.com/api.php?method=company.update&session_id=xxx&name=새이름
```

**인증 필수**. 소유자 또는 관리자만 가능.
description, title_image_url, photo_url 변경 시 자동으로 status='p' 설정.
**출력**: CompanyEntity.toArray()

### 11.6 company.delete — 업소 삭제

```
GET https://local.philgo.com/api.php?method=company.delete&idx=1025&session_id=xxx
```

**인증 필수**. 소유자 또는 관리자만 가능.
**출력**: `true`

### 11.7 company.approve — 업소 승인 (관리자)

```
GET https://local.philgo.com/api.php?method=company.approve&idx=1025&session_id=xxx
```

**관리자 인증 필수**. status → 'a'
**출력**: CompanyEntity.toArray()

### 11.8 company.reject — 업소 거절 (관리자)

```
GET https://local.philgo.com/api.php?method=company.reject&idx=1025&session_id=xxx
```

**관리자 인증 필수**. status → 'p'
**출력**: CompanyEntity.toArray()

### 11.9 company.toggleQrCode — QR 코드 토글 (관리자)

```
GET https://local.philgo.com/api.php?method=company.toggleQrCode&idx=1025&session_id=xxx
```

**관리자 인증 필수**. 승인된 업소만 가능.
**출력**: `{ show_qr_code: 0|1 }`

### 11.10 company.locations — 지역 목록

```
GET https://local.philgo.com/api.php?method=company.locations
```

**인증 불필요**.
**출력**: `["서울", "부산", "인천", ...]`

### 11.11 company.info — 업소 상세

```
GET https://local.philgo.com/api.php?method=company.info&idx=1025
```

**인증 불필요**.
**출력**: `{ company: {...}, owner: {idx, nickname, name, photo_url, created_at} }`

---

## 12. Company Meta API

### 12.1 company_meta.get — 메타 조회

```
# 모드 1: 특정 key 조회
GET https://local.philgo.com/api.php?method=company_meta.get&idx_company=1025&key=receipt_name

# 모드 2: 그룹별 조회
GET https://local.philgo.com/api.php?method=company_meta.get&idx_company=1025&group=company_info

# 모드 3: 전체 조회
GET https://local.philgo.com/api.php?method=company_meta.get&idx_company=1025
```

### 12.2 company_meta.update — 메타 Upsert

```
GET https://local.philgo.com/api.php?method=company_meta.update&idx_company=1025&key=receipt_name&value=ABC&group=company_info&session_id=xxx
```

**인증 필수**. 소유자 또는 관리자만 가능.
key 존재 시 UPDATE, 미존재 시 INSERT.
**출력**: CompanyMetaEntity.toArray()

### 12.3 company_meta.updateMultiple — 일괄 Upsert

```
POST https://local.philgo.com/api.php?method=company_meta.updateMultiple&session_id=xxx
Content-Type: application/json

{
  "idx_company": 1025,
  "group": "company_info",
  "meta": {
    "receipt_name": "ABC Restaurant",
    "receipt_phone": "02-1234-5678"
  }
}
```

**인증 필수**. 소유자 또는 관리자만 가능.
**출력**: `{ success: true }`

### 12.4 company_meta.delete — 메타 삭제

```
GET https://local.philgo.com/api.php?method=company_meta.delete&idx_company=1025&key=receipt_name&session_id=xxx
```

**인증 필수**. 소유자 또는 관리자만 가능.
**출력**: `true`

---

## 13. Status 흐름

```
     ┌─────────┐     create()      ┌─────────┐      approve()     ┌──────────┐
     │  (없음)  │ ───────────────→ │  '' 신규  │ ─────────────────→ │ 'a' 승인  │
     └─────────┘                   └─────────┘                     └──────────┘
                                        │                                │
                                        │ update (desc/photo 변경)       │ reject()
                                        ▼                                ▼
                                   ┌─────────┐                     ┌──────────┐
                                   │ 'p' 심사 │ ←────────────────── │ 'p' 심사  │
                                   └─────────┘    update (desc/     └──────────┘
                                        │         photo 변경)
                                        │
                                        │ approve()
                                        ▼
                                   ┌──────────┐
                                   │ 'a' 승인  │
                                   └──────────┘
```

| 상태 | 코드 | 설명 |
|------|------|------|
| 신규 | `''` (빈 문자열) | 처음 생성된 상태 |
| 심사중 | `'p'` (pending) | 관리자 검토 대기 |
| 승인됨 | `'a'` (approved) | 관리자 승인 완료, QR 코드 활성화 가능 |

**자동 pending 전환 조건**:
- `description` 변경 시
- `title_image_url` 변경 시
- `photo_url` 변경 시

---

## 14. 권한 모델

| 접근 수준 | 대상 | API |
|-----------|------|-----|
| **공개** | 모든 사용자 | `get`, `list`, `locations`, `info`, `company_meta.get` |
| **인증 필수** | 로그인 사용자 | `mine`, `create` |
| **소유자/관리자** | 업소 소유자 또는 관리자 | `update`, `delete`, `company_meta.update/delete` |
| **관리자 전용** | 관리자만 | `approve`, `reject`, `toggleQrCode` |

**소유자 판별**: `company.idx_member === AuthService::getLoginUser()['idx']`
**관리자 판별**: `AuthService::getLoginUser()['admin'] === 'Y'`

---

## 15. PSR-4 Autoload 설정

`composer.json`에 다음 매핑이 필요하다:

```json
{
    "autoload": {
        "psr-4": {
            "Philgo\\Company\\": "lib/company/"
        }
    }
}
```

추가 후 반드시 실행:

```bash
composer dump-autoload
```

---

## 16. PEST Unit Test

### 16.1 CompanyTest.php (28개 테스트)

**실행**: `./vendor/bin/pest tests/Unit/CompanyTest.php`

| describe | 테스트 수 | 설명 |
|----------|-----------|------|
| CompanyEntity | 5 | fromArray, toArray, 기본값, 상태확인, exists |
| CompanyRepository | 7 | create, findByIdx, findByIdxMember, update, findAll, getLocations, deleteByIdx |
| CompanyService | 10 | get(성공/실패/예외), create, update(비소유자), delete(비소유자), approve, reject, mine, locations |
| CompanyController | 6 | get, list, mine(미인증/인증), delete(미인증), locations |

### 16.2 CompanyMetaTest.php (19개 테스트)

**실행**: `./vendor/bin/pest tests/Unit/CompanyMetaTest.php`

| describe | 테스트 수 | 설명 |
|----------|-----------|------|
| CompanyMetaEntity | 3 | fromArray, toArray, 기본값 |
| CompanyMetaRepository | 6 | create, findByCompanyAndGroup, findByCompany, update, exists, delete |
| CompanyMetaService | 6 | upsert(INSERT), upsert(UPDATE), get, get(예외), upsertMultiple, delete |
| CompanyMetaController | 4 | get(공개), update(미인증), update(소유자), delete(미인증) |

### 16.3 테스트 격리 패턴

각 테스트는 **독립적으로 고유한 idx_member를 사용**하여 UNIQUE 제약 조건 충돌을 방지한다:

- CompanyTest: `88001 ~ 88020` 범위 사용
- CompanyMetaTest: `87001 ~ 87020` 범위 사용

```php
// 테스트 시작 시 기존 데이터 정리 후 생성
cleanupTestCompany(88001);
$idx = CompanyRepository::create(['idx_member' => 88001, ...]);
// ... 테스트 ...
CompanyRepository::deleteByIdx($idx);
```

`beforeAll`과 `afterAll`에서 전체 범위를 cleanup하여 잔여 데이터를 방지한다.

---

## 17. 레거시(v6)와의 관계

### 17.1 공존 방식

| 항목 | v6 레거시 | v7 시스템 |
|------|-----------|-----------|
| **DB 테이블** | `company`, `company_meta` | 동일 테이블 공유 |
| **DB 접근** | `db_select()`, `db_update()` 등 | `Db::pdo()->prepare()` |
| **인증** | `login()`, `is_admin()` | `AuthService::getLoginUser()` |
| **파일 위치** | `lib/company.functions.php` | `lib/company/CompanyService.php` |
| **호출 방식** | `get_company($idx)` | `CompanyService::get(['idx' => $idx])` |
| **에러 처리** | 배열 반환 `['error' => '...']` | `throw new RuntimeException(...)` |

### 17.2 v6 레거시 함수 (참고)

v6 함수는 그대로 유지되며 기존 페이지에서 계속 사용된다:

```php
// v6 — 기존 코드 (lib/company.functions.php)
$company = get_company($idx);
$companies = get_companies(['status' => 'a']);
update_company(['idx' => $idx, 'name' => '새이름']);

// v7 — 새 코드 (lib/company/CompanyService.php)
$entity = CompanyService::get(['idx' => $idx]);
$list = CompanyService::list(['status' => 'a']);
$updated = CompanyService::update(['idx' => $idx, 'name' => '새이름', 'idx_member' => $idxMember]);
```

### 17.3 통합 사용 예시

하나의 PHP 페이지에서 v6과 v7 코드를 함께 사용할 수 있다:

```php
<?php
include_once '../page.header.php';
require_once ROOT_DIR . '/vendor/autoload.php';

use Philgo\Company\CompanyService;

// v7 시스템으로 업소 조회
$entity = CompanyService::get(['idx' => 1025]);

// v6 레거시 함수도 함께 사용 가능
$posts = get_latest_posts_by_company($entity->idx, 5);
?>
```
