# v7 Interface 시스템 — EntityInterface + RepositoryInterface

## 목차

- [1. 개요](#1-개요)
  - [1.1 도입 배경](#11-도입-배경)
  - [1.2 설계 결정: Interface vs Abstract Class](#12-설계-결정-interface-vs-abstract-class)
  - [1.3 적용 범위](#13-적용-범위)
- [2. EntityInterface](#2-entityinterface)
  - [2.1 인터페이스 소스코드](#21-인터페이스-소스코드)
  - [2.2 메서드 설명](#22-메서드-설명)
  - [2.3 Entity 표준 패턴 (필수)](#23-entity-표준-패턴-필수)
  - [2.4 계산 필드 패턴](#24-계산-필드-패턴)
  - [2.5 런타임 속성 패턴](#25-런타임-속성-패턴)
  - [2.6 PointLogEntity 특수 패턴 (생성자 + fromArray 공존)](#26-pointlogentity-특수-패턴-생성자--fromarray-공존)
  - [2.7 전체 Entity 목록 (14개)](#27-전체-entity-목록-14개)
- [3. RepositoryInterface](#3-repositoryinterface)
  - [3.1 인터페이스 소스코드](#31-인터페이스-소스코드)
  - [3.2 메서드 설명](#32-메서드-설명)
  - [3.3 Repository 표준 패턴 (필수)](#33-repository-표준-패턴-필수)
  - [3.4 적용된 Repository (6개)](#34-적용된-repository-6개)
  - [3.5 예외 Repository (5개) — 인터페이스 미적용](#35-예외-repository-5개--인터페이스-미적용)
  - [3.6 전체 Repository 목록 (11개)](#36-전체-repository-목록-11개)
- [4. Service 명명 규칙 (문서 기반)](#4-service-명명-규칙-문서-기반)
  - [4.1 표준 메서드명](#41-표준-메서드명)
  - [4.2 전체 Service 목록 (13개)](#42-전체-service-목록-13개)
- [5. 데이터 흐름](#5-데이터-흐름)
- [6. 실제 구현 예시](#6-실제-구현-예시)
  - [6.1 PostEntity — 대형 Entity 구현](#61-postentity--대형-entity-구현)
  - [6.2 UploadEntity — 동적 썸네일 URL 생성](#62-uploadentity--동적-썸네일-url-생성)
  - [6.3 PostRepository — 표준 CRUD + 확장 쿼리](#63-postrepository--표준-crud--확장-쿼리)
  - [6.4 PointLogRepository — 리네이밍된 Repository](#64-pointlogrepository--리네이밍된-repository)
  - [6.5 EventCouponEntity — 생성자 + fromArray 공존 + nullable 필드](#65-eventcouponentity--생성자--fromarray-공존--nullable-필드)
  - [6.6 EventCouponRepository — 리네이밍 + Entity 리턴 타입 수정](#66-eventcouponrepository--리네이밍--entity-리턴-타입-수정)
- [7. 새 Entity/Repository 추가 워크플로우](#7-새-entityrepository-추가-워크플로우)
- [8. 주의 사항 및 규칙](#8-주의-사항-및-규칙)

---

## 1. 개요

### 1.1 도입 배경

v7 시스템의 Entity 14개, Service 13개, Repository 11개 클래스 사이에 다음 문제가 있었다:

| 문제 | 예시 |
|------|------|
| 생성자 방식 불일치 | Entity에 따라 `fromArray()` 또는 `__construct()` 사용 |
| 메서드명 불일치 | `create()` vs `insert()`, `findByIdx()` vs `getByIdx()`, `deleteByIdx()` vs `delete()` |
| 필수 메서드 미보장 | 일부 Entity에 `fromArray()` 없음, 일부 Repository에 표준 CRUD 메서드 없음 |
| 구조 강제 메커니즘 없음 | 동일 역할의 클래스가 서로 다른 인터페이스를 가짐 |

**목표**: Interface를 도입하여 **필수 메서드를 컴파일 타임에 강제**하고, **일관된 메서드명과 시그니처**를 유지한다.

### 1.2 설계 결정: Interface vs Abstract Class

4가지 접근 방식을 분석 후 **Interface**를 선택했다:

| 항목 | Interface | Abstract Class | 선택 이유 |
|------|-----------|---------------|----------|
| 공통 구현 | 없음 | 있음 | Entity마다 프로퍼티/로직이 달라 공유할 구현이 없음 |
| 다중 상속 | O (implements 여러 개) | X (extends 하나만) | PHP 단일 상속 제약 회피 |
| 기존 코드 변경량 | 최소 (implements 추가만) | 중간 (extends 변경 + 구현 이동) | 기존 코드 최소 변경 |
| 유연성 | 높음 | 낮음 | PointLogEntity처럼 생성자 + fromArray 공존 허용 |

### 1.3 적용 범위

| 계층 | 인터페이스 | 적용 | 미적용 이유 |
|------|-----------|------|-----------|
| **Entity** | `EntityInterface` | 14개 전체 | — |
| **Repository** | `RepositoryInterface` | 6개 | 5개 예외: CRUD 패턴과 안 맞는 도메인 |
| **Service** | 없음 (문서 기반 관례) | — | 도메인별 메서드가 천차만별이라 Interface 강제가 부적절 |

---

## 2. EntityInterface

### 2.1 인터페이스 소스코드

**파일**: `lib/utils/EntityInterface.php`
**네임스페이스**: `Philgo\Utils\EntityInterface`

```php
<?php
namespace Philgo\Utils;

interface EntityInterface
{
    /**
     * 배열(DB 행 또는 API 응답)로부터 Entity를 생성한다.
     *
     * @param array $data DB 조회 결과 (연관 배열) 또는 API 입력 데이터
     * @return static 생성된 Entity 인스턴스
     */
    public static function fromArray(array $data): static;

    /**
     * Entity를 배열로 변환한다.
     *
     * API 응답에 사용할 수 있는 연관 배열을 반환한다.
     * 계산 필드(예: level, is_comment 등)도 포함하여 반환한다.
     *
     * @return array Entity 데이터 배열
     */
    public function toArray(): array;
}
```

### 2.2 메서드 설명

| 메서드 | 시그니처 | 역할 | 리턴 |
|--------|---------|------|------|
| `fromArray()` | `public static fromArray(array $data): static` | 배열(DB 행)로부터 Entity 생성 (정적 팩토리) | Entity 인스턴스 |
| `toArray()` | `public function toArray(): array` | Entity를 배열로 변환 (API 응답용) | 연관 배열 |

**`static` 리턴 타입 규칙**:
- `fromArray()`의 리턴 타입은 반드시 `static`이어야 한다 (PHP 8.0+)
- `self`를 사용하면 인터페이스와 호환되지 않아 Fatal Error 발생

```php
// ✅ 올바른 방식
public static function fromArray(array $data): static { ... }

// ❌ 금지 (인터페이스 호환 불가)
public static function fromArray(array $data): self { ... }
```

### 2.3 Entity 표준 패턴 (필수)

새 Entity를 작성할 때 **반드시** 따라야 하는 패턴이다.

```php
<?php
/**
 * @file lib/<module>/<Xxx>Entity.php
 * @brief <테이블명> 테이블 데이터 구조체 (POPO)
 *
 * PSR-4: Philgo\<Module>\<Xxx>Entity
 */

namespace Philgo\<Module>;

use Philgo\Utils\EntityInterface;

class XxxEntity implements EntityInterface
{
    // 프로퍼티: public, typed, 기본값 필수
    public int $idx = 0;
    public string $name = '';
    public int $created_at = 0;

    // ★ 정적 팩토리 메서드 (필수) — 리턴 타입 반드시 static
    public static function fromArray(array $data): static
    {
        $entity = new self();
        $entity->idx = (int)($data['idx'] ?? 0);
        $entity->name = (string)($data['name'] ?? '');
        $entity->created_at = (int)($data['created_at'] ?? 0);
        return $entity;
    }

    // ★ 배열 변환 (필수)
    public function toArray(): array
    {
        return [
            'idx' => $this->idx,
            'name' => $this->name,
            'created_at' => $this->created_at,
        ];
    }

    // ★ 도메인 메서드 (선택)
    public function exists(): bool
    {
        return $this->idx > 0;
    }
}
```

**규칙 요약**:

| 규칙 | 내용 |
|------|------|
| 생성 방식 | `static fromArray()` 팩토리 패턴 표준 사용 |
| 프로퍼티 | `public` 접근, PHP 8.1+ 타입 선언, 기본값 필수 |
| 리턴 타입 | `fromArray()`는 반드시 `static` (self 금지) |
| 타입 캐스팅 | `fromArray()` 내에서 반드시 `(int)`, `(string)` 등으로 명시적 캐스팅 |
| null-safe | `$data['key'] ?? 기본값` 패턴 필수 |
| 계산 필드 | `toArray()`에 포함하여 API 응답에 자동 반영 |
| 파일 위치 | `lib/<module>/<Xxx>Entity.php` (PSR-4) |
| 파일 상단 주석 | `@file`, `@brief`, PSR-4 네임스페이스, `@see` 필수 |

### 2.4 계산 필드 패턴

`toArray()`에 DB에 없는 계산 필드를 추가하여 API 응답에 자동 포함시킨다.

```php
// PostEntity — is_comment 계산 필드
public function toArray(): array
{
    return [
        'idx' => $this->idx,
        'depth' => $this->depth,
        // ★ 계산 필드: DB에 없지만 API 응답에 포함
        'is_comment' => $this->isComment(),    // depth > 0 이면 true
        'earned_point' => $this->int_10,       // 커스텀 필드 매핑
    ];
}

// QrCodeUsageEntity — is_success 계산 필드
public function toArray(): array
{
    return [
        'idx' => $this->idx,
        'result' => $this->result,
        // ★ 계산 필드
        'is_success' => $this->isSuccess(),   // result === 's'
    ];
}

// UploadEntity — 동적 썸네일 URL 계산 필드
public function toArray(): array
{
    return [
        'idx' => $this->idx,
        'url' => $this->url,
        // ★ DB 저장값 (기존 호환)
        'thumbnail_400x400_url' => $this->thumbnail_400x400_url,
        // ★ 동적 생성 썸네일 URL (URL 규칙 기반)
        'thumbnail_url_400' => $this->thumbnailUrl400(),
        'thumbnail_url_800' => $this->thumbnailUrl800(),
        'thumbnail_url_1000' => $this->thumbnailUrl1000(),
    ];
}
```

### 2.5 런타임 속성 패턴

DB에 없는 런타임 전용 속성은 `fromArray()`에서 설정하지 않고, Service/Repository에서 별도 할당한다.

```php
// VisitReviewEntity — 런타임 속성
class VisitReviewEntity implements EntityInterface
{
    // DB 컬럼 속성
    public int $idx = 0;
    public string $content = '';

    // ★ 런타임 속성: fromArray()에서 설정하지 않음
    /** @var string 작성자 닉네임 (sf_member.nickname) */
    public string $author_name = '';

    /** @var array uploads 테이블에서 조회한 사진 목록 (UploadEntity[]) */
    public array $photos = [];

    public function toArray(): array
    {
        return [
            'idx' => $this->idx,
            'content' => $this->content,
            // ★ 런타임 속성도 toArray()에 포함
            'author_name' => $this->author_name,
            'photos' => array_map(fn($photo) => $photo->toArray(), $this->photos),
        ];
    }
}
```

### 2.6 PointLogEntity 특수 패턴 (생성자 + fromArray 공존)

PointLogEntity는 기존 `__construct(array $row)` 패턴과 새 `fromArray()` 패턴이 공존한다.
`fromArray()`는 내부적으로 생성자를 호출한다.

```php
class PointLogEntity implements EntityInterface
{
    public int $idx = 0;
    public int $point = 0;
    // ...

    // 기존 생성자 (레거시 호환 유지)
    public function __construct(array $row)
    {
        $this->idx = (int)($row['idx'] ?? 0);
        $this->point = (int)($row['point'] ?? 0);
        // ...
    }

    // ★ EntityInterface 필수 메서드: 생성자 위임
    public static function fromArray(array $data): static
    {
        return new static($data);
    }
}
```

### 2.7 전체 Entity 목록 (14개)

모든 Entity는 `EntityInterface`를 구현한다.

| Entity | 네임스페이스 | 파일 위치 | 테이블 | 특이사항 |
|--------|-------------|----------|--------|---------|
| UserEntity | `Philgo\User` | `lib/user/UserEntity.php` | sf_member | level() 계산 필드 |
| PostEntity | `Philgo\Post` | `lib/post/PostEntity.php` | sf_post_data | 800+ LOC, 확장 필드(int_1~10, varchar_1~20 등) |
| CompanyEntity | `Philgo\Company` | `lib/company/CompanyEntity.php` | company | 패밀리사이트 관련 필드 |
| CompanyMetaEntity | `Philgo\Company` | `lib/company/CompanyMetaEntity.php` | company_meta | key-value 메타 |
| QrCodeEntity | `Philgo\Company` | `lib/company/QrCodeEntity.php` | company_qr_codes | QR 발행 기록 |
| QrCodeUsageEntity | `Philgo\Company` | `lib/company/QrCodeUsageEntity.php` | company_qr_code_usages | isSuccess() 계산 필드 |
| VisitReviewEntity | `Philgo\Company` | `lib/company/VisitReviewEntity.php` | company_reviews | photos[] 런타임 속성 |
| UploadEntity | `Philgo\Upload` | `lib/upload/UploadEntity.php` | uploads | 동적 썸네일 URL 생성 |
| PointLogEntity | `Philgo\PointLog` | `lib/point_log/PointLogEntity.php` | sf_point_log | 생성자 + fromArray 공존 |
| EventCouponEntity | `Philgo\Event` | `lib/event/EventCouponEntity.php` | event_coupons | 생성자 + fromArray 공존, nullable 필드 다수 |
| GenerateEntity | `Philgo\Ai` | `lib/ai/GenerateEntity.php` | — (API 응답) | Gemini 텍스트 생성 결과 |
| ModerationEntity | `Philgo\Ai` | `lib/ai/ModerationEntity.php` | — (API 응답) | Gemini 검열 결과 |
| ReceiptEntity | `Philgo\Ai` | `lib/ai/ReceiptEntity.php` | — (API 응답) | Gemini 영수증 인식 결과 |
| SettingsEntity | `Philgo\Settings` | `lib/settings/SettingsEntity.php` | sf_config | key-value 설정 |

---

## 3. RepositoryInterface

### 3.1 인터페이스 소스코드

**파일**: `lib/utils/RepositoryInterface.php`
**네임스페이스**: `Philgo\Utils\RepositoryInterface`

```php
<?php
namespace Philgo\Utils;

interface RepositoryInterface
{
    /**
     * 새 레코드를 생성한다.
     *
     * @param array $data 생성할 데이터 (연관 배열)
     * @return int 생성된 레코드의 idx (AUTO_INCREMENT)
     */
    public static function create(array $data): int;

    /**
     * idx로 단건 조회한다.
     *
     * @param int $idx 조회할 레코드의 고유 ID
     * @return ?EntityInterface Entity 또는 null (존재하지 않을 때)
     */
    public static function findByIdx(int $idx): ?EntityInterface;

    /**
     * 레코드를 수정한다.
     *
     * @param int $idx 수정할 레코드의 고유 ID
     * @param array $data 수정할 데이터 (연관 배열)
     * @return bool 성공 여부
     */
    public static function update(int $idx, array $data): bool;

    /**
     * 레코드를 삭제한다.
     *
     * @param int $idx 삭제할 레코드의 고유 ID
     * @return bool 성공 여부
     */
    public static function deleteByIdx(int $idx): bool;
}
```

### 3.2 메서드 설명

| 메서드 | 시그니처 | 역할 | 리턴 |
|--------|---------|------|------|
| `create()` | `public static create(array $data): int` | 새 레코드 INSERT | `int` (생성된 idx) |
| `findByIdx()` | `public static findByIdx(int $idx): ?EntityInterface` | idx로 단건 SELECT | `?Entity` (없으면 null) |
| `update()` | `public static update(int $idx, array $data): bool` | 레코드 UPDATE | `bool` |
| `deleteByIdx()` | `public static deleteByIdx(int $idx): bool` | 레코드 DELETE | `bool` |

**핵심 규칙**:
- 모든 메서드는 `public static`
- `findByIdx()`는 반드시 **Entity 객체**를 리턴한다 (배열 리턴 금지)
- `findByIdx()` 리턴 타입: 실제 구현에서는 `?XxxEntity`로 구체적 타입 사용 가능 (공변 리턴 타입)
- `create()`는 동적 SQL 생성 패턴 사용 (`array_keys` → 컬럼, `array_map` → 플레이스홀더)

### 3.3 Repository 표준 패턴 (필수)

새 Repository를 작성할 때 **반드시** 따라야 하는 패턴이다.

```php
<?php
/**
 * @file lib/<module>/<Xxx>Repository.php
 * @brief <테이블명> 테이블 DB CRUD Repository
 *
 * PSR-4: Philgo\<Module>\<Xxx>Repository
 */

namespace Philgo\<Module>;

use Philgo\Utils\Db;
use Philgo\Utils\EntityInterface;
use Philgo\Utils\RepositoryInterface;
use PDO;

class XxxRepository implements RepositoryInterface
{
    /** @var string 테이블명 */
    private const TABLE = 'xxx_table';

    /**
     * 새 레코드를 생성한다.
     */
    public static function create(array $data): int
    {
        $columns = array_keys($data);
        $placeholders = array_map(fn($col) => ":$col", $columns);
        $sql = "INSERT INTO " . self::TABLE
            . " (" . implode(', ', $columns) . ")"
            . " VALUES (" . implode(', ', $placeholders) . ")";
        $stmt = Db::pdo()->prepare($sql);
        $stmt->execute($data);
        return (int)Db::pdo()->lastInsertId();
    }

    /**
     * idx로 단건 조회한다.
     */
    public static function findByIdx(int $idx): ?XxxEntity
    {
        $stmt = Db::pdo()->prepare(
            "SELECT * FROM " . self::TABLE . " WHERE idx = :idx"
        );
        $stmt->execute(['idx' => $idx]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row === false) {
            return null;
        }
        return XxxEntity::fromArray($row);
    }

    /**
     * 레코드를 수정한다.
     */
    public static function update(int $idx, array $data): bool
    {
        if (empty($data)) return false;
        $sets = [];
        $values = [];
        foreach ($data as $col => $val) {
            $sets[] = "`{$col}` = :{$col}";
            $values[$col] = $val;
        }
        $values['idx'] = $idx;
        $sql = "UPDATE " . self::TABLE
            . " SET " . implode(', ', $sets)
            . " WHERE idx = :idx";
        $stmt = Db::pdo()->prepare($sql);
        return $stmt->execute($values);
    }

    /**
     * 레코드를 삭제한다.
     */
    public static function deleteByIdx(int $idx): bool
    {
        $stmt = Db::pdo()->prepare(
            "DELETE FROM " . self::TABLE . " WHERE idx = :idx"
        );
        return $stmt->execute(['idx' => $idx]);
    }
}
```

### 3.4 적용된 Repository (6개)

표준 CRUD 패턴을 따르며 `RepositoryInterface`를 구현하는 Repository 목록이다.

| Repository | 파일 위치 | 테이블 | 리네이밍/변경 |
|-----------|----------|--------|-------------|
| CompanyRepository | `lib/company/CompanyRepository.php` | company | 없음 |
| PostRepository | `lib/post/PostRepository.php` | sf_post_data | 없음 |
| UploadRepository | `lib/upload/UploadRepository.php` | uploads | `update()` 메서드 추가 |
| PointLogRepository | `lib/point_log/PointLogRepository.php` | sf_point_log | `insert()` → `create()`, `getByIdx()` → `findByIdx()`, `delete()` → `deleteByIdx()` |
| QrCodeRepository | `lib/company/QrCodeRepository.php` | company_qr_codes | `insert()` → `create()`, `update()` 추가 |
| EventCouponRepository | `lib/event/EventCouponRepository.php` | event_coupons | `findByIdx()` 리턴 `?array` → `?EventCouponEntity`, `delete()` → `deleteByIdx()` |

**리네이밍 상세**:

PointLogRepository:
```
insert(array $data): int           → create(array $data): int
getByIdx(int $idx): ?array         → findByIdx(int $idx): ?PointLogEntity  (★ 리턴 타입 변경!)
delete(int $idx): bool             → deleteByIdx(int $idx): bool
```

QrCodeRepository:
```
insert(array $data): int           → create(array $data): int
(신규 추가)                        → update(int $idx, array $data): bool
```

EventCouponRepository:
```
findByIdx(int $idx): ?array        → findByIdx(int $idx): ?EventCouponEntity  (★ 리턴 타입 변경! Entity 신규 생성)
delete(int $idx): bool             → deleteByIdx(int $idx): bool
(EventCouponEntity 신규 생성)      → lib/event/EventCouponEntity.php
```

UploadRepository:
```
(신규 추가)                        → update(int $idx, array $data): bool
```

> **⚠️ 주의**: `findByIdx()`의 리턴 타입이 `?array`에서 `?Entity`로 변경되었다. 호출부에서 `$row['field']` → `$row->field`로 접근 방식이 바뀐다.
>
> **⚠️ EventCouponService 호출부 변경 필수**: EventCouponRepository의 `findByIdx()`가 Entity를 리턴하므로, Service에서 `$coupon['status']` → `$coupon->status`로 속성 접근 방식을 변경하고, API 응답 시 `$entity->toArray()`로 배열 변환해야 한다.

### 3.5 예외 Repository (5개) — 인터페이스 미적용

도메인 특성상 CRUD 패턴과 맞지 않아 `RepositoryInterface`를 구현하지 않는다.

| Repository | 파일 위치 | 예외 사유 |
|-----------|----------|----------|
| CompanyMetaRepository | `lib/company/CompanyMetaRepository.php` | key-value 패턴: `update(int $idxCompany, string $key, array $data)` 시그니처가 3개 파라미터로 RepositoryInterface의 `update(int $idx, array $data)` 2개 파라미터와 호환 불가. `deleteByIdx()` 없이 `deleteByCompanyAndKey()`만 사용. idx가 아닌 `(idx_company, key)` 복합 키로 조회/수정/삭제 |
| SettingsRepository | `lib/settings/SettingsRepository.php` | key-value 패턴 (idx 기반 아님, `getByKey()`/`setByKey()` 사용) |
| EventRepository | `lib/event/EventRepository.php` | 스핀 히스토리 전용 (표준 CRUD 없음) |
| QrCodeUsageRepository | `lib/company/QrCodeUsageRepository.php` | 삭제 메서드 없음 (사용 기록은 삭제 불가) |
| VisitReviewRepository | `lib/company/VisitReviewRepository.php` | 수정/삭제 없음 (후기는 생성/조회만) |

### 3.6 전체 Repository 목록 (11개)

| Repository | 인터페이스 | 테이블 |
|-----------|-----------|--------|
| CompanyRepository | ✅ RepositoryInterface | company |
| PostRepository | ✅ RepositoryInterface | sf_post_data |
| UploadRepository | ✅ RepositoryInterface | uploads |
| PointLogRepository | ✅ RepositoryInterface | sf_point_log |
| QrCodeRepository | ✅ RepositoryInterface | company_qr_codes |
| EventCouponRepository | ✅ RepositoryInterface | event_coupons |
| CompanyMetaRepository | ❌ (예외) | company_meta |
| SettingsRepository | ❌ (예외) | sf_config |
| EventRepository | ❌ (예외) | event_spin_history |
| QrCodeUsageRepository | ❌ (예외) | company_qr_code_usages |
| VisitReviewRepository | ❌ (예외) | company_reviews |

---

## 4. Service 명명 규칙 (문서 기반)

Service는 인터페이스를 적용하지 않되, 아래 명명 규칙을 따른다.

### 4.1 표준 메서드명

| 작업 | 표준 메서드명 | 입력 | 리턴 |
|------|-------------|------|------|
| 단건 조회 | `get(array $input)` | `array $input` | Entity |
| 목록 조회 | `list(array $input)` | `array $input` | `array` (`['items' => [], 'total' => int]`) |
| 생성 | `create(array $input)` | `array $input` | Entity |
| 수정 | `update(array $input)` | `array $input` | Entity |
| 삭제 | `delete(array $input)` | `array $input` | `bool` |

**규칙**:
- 모든 메서드는 `public static`으로 선언한다
- 입력 파라미터는 `array $input`으로 통일한다 (JavaScript `func()` 호출과 호환)
- 에러는 `RuntimeException`으로 던진다
- 조회/생성/수정 시 Entity를 리턴한다
- 유틸리티 Service (AuthService, FirebaseService, ImageService)는 도메인별 메서드를 자유롭게 정의한다

### 4.2 전체 Service 목록 (13개)

| Service | 네임스페이스 | 주요 역할 |
|---------|-------------|----------|
| UserService | `Philgo\User` | 사용자 정보, 레벨 계산 |
| PostService | `Philgo\Post` | 게시글 CRUD + 포인트 |
| CompanyService | `Philgo\Company` | 업소록 CRUD + QR |
| CompanyMetaService | `Philgo\Company` | 업소 메타데이터 |
| UploadService | `Philgo\Upload` | 파일 업로드 + 썸네일 |
| PointLogService | `Philgo\PointLog` | 포인트 변경 + 로그 |
| EventService | `Philgo\Event` | 스핀 휠 이벤트 |
| EventCouponService | `Philgo\Event` | 이벤트 쿠폰 관리 |
| AiService | `Philgo\Ai` | Gemini API 연동 |
| SettingsService | `Philgo\Settings` | 시스템 설정 |
| AuthService | `Philgo\Utils` | 인증 (세션 + Firebase) |
| FirebaseService | `Philgo\Utils` | Firebase ID Token 검증 |
| ImageService | `Philgo\Upload` | 이미지 변환/리사이즈 |

---

## 5. 데이터 흐름

```
API 요청 (JSON)
    ↓
Controller (api.php → dispatch)
    ↓ array $input
Service (비즈니스 로직, 검증, 권한 확인)
    ↓ array $data
Repository (PDO Prepared Statement)
    ↓ SQL
DB (MariaDB)
    ↓ array $row (PDO::FETCH_ASSOC)
Repository → Entity::fromArray($row)        ← ★ EntityInterface
    ↓ Entity 객체
Service → Entity->toArray()                 ← ★ EntityInterface
    ↓ array
api.php → json_encode()
    ↓
API 응답 (JSON)
```

**핵심 포인트**:
- Repository의 `findByIdx()`는 DB 행을 `Entity::fromArray($row)`로 변환하여 Entity를 리턴
- Service에서 Entity의 도메인 메서드(`isComment()`, `isSuccess()` 등)를 직접 호출 가능
- api.php에서 Entity의 `toArray()`를 호출하여 JSON 응답 변환

---

## 6. 실제 구현 예시

### 6.1 PostEntity — 대형 Entity 구현

PostEntity는 800+ LOC의 대형 Entity로, 커스텀 확장 필드(int_1~10, char_1~10, varchar_1~20, text_1~10)와 다수의 도메인 메서드를 포함한다.

**파일**: `lib/post/PostEntity.php`

```php
namespace Philgo\Post;

use Philgo\Utils\EntityInterface;

class PostEntity implements EntityInterface
{
    public int $idx = 0;
    public string $subject = '';
    public string $content = '';
    public int $depth = 0;
    // ... (80+ 프로퍼티)

    public static function fromArray(array $data): static
    {
        $entity = new self();
        $entity->idx = (int)($data['idx'] ?? 0);
        $entity->subject = (string)($data['subject'] ?? '');
        // ... 커스텀 필드는 루프로 처리
        for ($i = 1; $i <= 10; $i++) {
            $field = "int_{$i}";
            $entity->$field = (int)($data[$field] ?? 0);
        }
        return $entity;
    }

    public function toArray(): array
    {
        $arr = [
            'idx' => $this->idx,
            'subject' => $this->subject,
            // ★ 계산 필드
            'is_comment' => $this->isComment(),
            'earned_point' => $this->int_10,
        ];
        // 커스텀 필드도 루프로 추가
        for ($i = 1; $i <= 10; $i++) {
            $field = "int_{$i}";
            $arr[$field] = $this->$field;
        }
        return $arr;
    }

    // ★ 도메인 메서드
    public function isComment(): bool { return $this->depth > 0; }
    public function isPost(): bool { return $this->depth === 0; }
    public function isBlocked(): bool { return $this->checked === 'R'; }
    public function isBlinded(): bool { return $this->blind === 'Y'; }
    public function isSecret(): bool { return $this->secret === 'Y'; }
    public function exists(): bool { return $this->idx > 0; }
}
```

### 6.2 UploadEntity — 동적 썸네일 URL 생성

UploadEntity는 URL 규칙 기반으로 동적 썸네일 URL을 생성하는 private 헬퍼 메서드를 가진다.

**파일**: `lib/upload/UploadEntity.php`

```php
namespace Philgo\Upload;

use Philgo\Utils\EntityInterface;

class UploadEntity implements EntityInterface
{
    public string $url = '';
    public string $type = '';
    // ...

    // 400x400 정사각형 썸네일
    public function thumbnailUrl400(): ?string
    {
        return $this->getThumbnailUrl(400);
    }

    // 1000px 비율 유지 리사이즈
    public function thumbnailUrl1000(): ?string
    {
        return $this->getResizedThumbnailUrl(1000);
    }

    // ★ 정사각형 썸네일 URL: /uploads/{idx_member}/{size}x{size}-{filename}
    private function getThumbnailUrl(int $size): ?string
    {
        if (empty($this->url)) return null;
        if (!str_starts_with($this->type, 'image/') || $this->type === 'image/gif') return null;
        $dir = dirname($this->url);
        $baseName = basename($this->url);
        return $dir . '/' . $size . 'x' . $size . '-' . $baseName;
    }

    // ★ 비율 유지 썸네일 URL: /uploads/{idx_member}/{width}-{filename}
    private function getResizedThumbnailUrl(int $width): ?string
    {
        if (empty($this->url)) return null;
        if (!str_starts_with($this->type, 'image/') || $this->type === 'image/gif') return null;
        $dir = dirname($this->url);
        $baseName = basename($this->url);
        return $dir . '/' . $width . '-' . $baseName;
    }
}
```

### 6.3 PostRepository — 표준 CRUD + 확장 쿼리

PostRepository는 RepositoryInterface의 4개 CRUD 메서드 외에 `findAll()`, `count()`, `getPostConfig()` 등 확장 쿼리를 가진다.

**파일**: `lib/post/PostRepository.php`

```php
namespace Philgo\Post;

use Philgo\Utils\Db;
use Philgo\Utils\EntityInterface;
use Philgo\Utils\RepositoryInterface;
use PDO;

class PostRepository implements RepositoryInterface
{
    private const TABLE = 'sf_post_data';

    // ★ RepositoryInterface 필수 메서드 4개
    public static function create(array $data): int { ... }
    public static function findByIdx(int $idx): ?PostEntity { ... }
    public static function update(int $idx, array $data): bool { ... }
    public static function deleteByIdx(int $idx): bool { ... }

    // ★ 확장 쿼리 (인터페이스 외)
    public static function findAll(string $postId, ...): array
    {
        // ...
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return array_map(fn($row) => PostEntity::fromArray($row), $rows);
    }

    public static function count(string $postId, ?string $category = null): int { ... }
    public static function getPostConfig(string $postId): ?array { ... }
}
```

### 6.4 PointLogRepository — 리네이밍된 Repository

PointLogRepository는 인터페이스 도입 시 메서드명이 리네이밍된 Repository이다.
`findByIdx()`의 리턴 타입이 `?array`에서 `?PointLogEntity`로 변경되었다.

**파일**: `lib/point_log/PointLogRepository.php`

```php
namespace Philgo\PointLog;

use Philgo\Utils\Db;
use Philgo\Utils\EntityInterface;
use Philgo\Utils\RepositoryInterface;
use PDO;

class PointLogRepository implements RepositoryInterface
{
    private const TABLE = 'sf_point_log';

    // ★ create() (구: insert())
    public static function create(array $data): int
    {
        $columns = array_keys($data);
        $placeholders = array_map(fn($col) => ":$col", $columns);
        $sql = "INSERT INTO " . self::TABLE
            . " (" . implode(', ', $columns) . ")"
            . " VALUES (" . implode(', ', $placeholders) . ")";
        $stmt = Db::pdo()->prepare($sql);
        $stmt->execute($data);
        return (int)Db::pdo()->lastInsertId();
    }

    // ★ findByIdx() (구: getByIdx()) — 리턴 타입 ?array → ?PointLogEntity
    public static function findByIdx(int $idx): ?PointLogEntity
    {
        $stmt = Db::pdo()->prepare(
            "SELECT * FROM " . self::TABLE . " WHERE idx = :idx"
        );
        $stmt->execute(['idx' => $idx]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row === false) {
            return null;
        }
        return PointLogEntity::fromArray($row);
    }

    // ★ update() (변경 없음)
    public static function update(int $idx, array $data): bool { ... }

    // ★ deleteByIdx() (구: delete())
    public static function deleteByIdx(int $idx): bool
    {
        $stmt = Db::pdo()->prepare(
            "DELETE FROM " . self::TABLE . " WHERE idx = :idx"
        );
        return $stmt->execute(['idx' => $idx]);
    }

    // 확장 쿼리
    public static function getHistoryByMember(int $idxMember, ...): array { ... }
    public static function countRecentActions(int $idxMember, int $minutes, string $action): int { ... }
    public static function countWeekly(int $idxMember, ...): int { ... }
    public static function sumPointByPost(int $idxPost, ?string $module = null): int { ... }
    public static function getMember(int $idxMember): ?array { ... }
    public static function updateMemberPoint(int $idxMember, int $newPoints): bool { ... }
}
```

### 6.5 EventCouponEntity — 생성자 + fromArray 공존 + nullable 필드

EventCouponEntity는 PointLogEntity와 유사하게 `__construct(array $row)` 패턴과 `fromArray()` 패턴이 공존한다.
nullable 필드(`?string`, `?int`)를 다수 포함하며, null 처리에 `isset()` 체크를 사용한다.

**파일**: `lib/event/EventCouponEntity.php`

```php
namespace Philgo\Event;

use Philgo\Utils\EntityInterface;

class EventCouponEntity implements EntityInterface
{
    public int $idx = 0;
    public string $coupon_type = '';
    public string $title = '';
    public ?string $memo = null;
    public ?string $image_url = null;
    public ?int $idx_upload = null;
    public string $status = 'available';   // available|won|sent|expired|cancelled
    public ?int $idx_winner = null;
    public ?int $idx_spin_history = null;
    public ?int $won_at = null;
    public ?int $sent_at = null;
    public int $created_at = 0;
    public int $updated_at = 0;

    // 기존 생성자 (레거시 호환 유지)
    public function __construct(array $row = [])
    {
        $this->idx = (int) ($row['idx'] ?? 0);
        $this->coupon_type = (string) ($row['coupon_type'] ?? '');
        $this->title = (string) ($row['title'] ?? '');
        // ★ nullable 필드: isset() 체크로 null 보존
        $this->memo = isset($row['memo']) ? (string) $row['memo'] : null;
        $this->image_url = isset($row['image_url']) ? (string) $row['image_url'] : null;
        $this->idx_upload = isset($row['idx_upload']) ? (int) $row['idx_upload'] : null;
        $this->status = (string) ($row['status'] ?? 'available');
        $this->idx_winner = isset($row['idx_winner']) ? (int) $row['idx_winner'] : null;
        $this->idx_spin_history = isset($row['idx_spin_history']) ? (int) $row['idx_spin_history'] : null;
        $this->won_at = isset($row['won_at']) ? (int) $row['won_at'] : null;
        $this->sent_at = isset($row['sent_at']) ? (int) $row['sent_at'] : null;
        $this->created_at = (int) ($row['created_at'] ?? 0);
        $this->updated_at = (int) ($row['updated_at'] ?? 0);
    }

    // ★ EntityInterface 필수 메서드: 생성자 위임
    public static function fromArray(array $data): static
    {
        return new static($data);
    }

    public function toArray(): array
    {
        return [
            'idx' => $this->idx,
            'coupon_type' => $this->coupon_type,
            'title' => $this->title,
            'memo' => $this->memo,
            'image_url' => $this->image_url,
            'idx_upload' => $this->idx_upload,
            'status' => $this->status,
            'idx_winner' => $this->idx_winner,
            'idx_spin_history' => $this->idx_spin_history,
            'won_at' => $this->won_at,
            'sent_at' => $this->sent_at,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
```

**nullable 필드 패턴 (⚠️ 중요)**:

일반 필드와 nullable 필드의 처리 방식이 다르다:

```php
// ★ 일반 필드: ?? 연산자로 기본값 할당
$this->title = (string) ($row['title'] ?? '');
$this->created_at = (int) ($row['created_at'] ?? 0);

// ★ nullable 필드: isset() 체크로 null 보존
$this->memo = isset($row['memo']) ? (string) $row['memo'] : null;
$this->idx_winner = isset($row['idx_winner']) ? (int) $row['idx_winner'] : null;
```

> `$row['memo'] ?? null`은 빈 문자열('')도 null이 아니므로 `isset()`과 동일하지 않다.
> DB의 NULL과 빈 문자열을 구분해야 할 때 반드시 `isset()` 패턴을 사용한다.

### 6.6 EventCouponRepository — 리네이밍 + Entity 리턴 타입 수정

EventCouponRepository는 인터페이스 도입 시 `findByIdx()`의 리턴 타입이 `?array`에서 `?EventCouponEntity`로 변경되었고,
`delete()`가 `deleteByIdx()`로 리네이밍되었다.

**파일**: `lib/event/EventCouponRepository.php`

```php
namespace Philgo\Event;

use Philgo\Utils\Db;
use Philgo\Utils\EntityInterface;
use Philgo\Utils\RepositoryInterface;
use PDO;

class EventCouponRepository implements RepositoryInterface
{
    private const TABLE = 'event_coupons';

    public static function create(array $data): int { ... }

    // ★ 리턴 타입 변경: ?array → ?EventCouponEntity
    public static function findByIdx(int $idx): ?EventCouponEntity
    {
        $stmt = Db::pdo()->prepare(
            "SELECT * FROM " . self::TABLE . " WHERE idx = :idx"
        );
        $stmt->execute(['idx' => $idx]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row === false) {
            return null;
        }
        return EventCouponEntity::fromArray($row);
    }

    public static function update(int $idx, array $data): bool { ... }

    // ★ 리네이밍: delete() → deleteByIdx()
    public static function deleteByIdx(int $idx): bool
    {
        $stmt = Db::pdo()->prepare(
            "DELETE FROM " . self::TABLE . " WHERE idx = :idx AND status = 'available'"
        );
        $stmt->execute(['idx' => $idx]);
        return $stmt->rowCount() > 0;
    }

    // ★ 확장 쿼리 (인터페이스 외) — 배열 리턴 유지
    // lockAndPickAvailable(), assignToWinner(), markAsSent() 등은
    // 트랜잭션 내에서 사용되므로 배열 리턴을 유지한다.
    public static function lockAndPickAvailable(?string $couponType = null): ?array { ... }
}
```

**⚠️ Service 호출부 변경 패턴**:

Repository의 `findByIdx()`가 Entity를 리턴하므로 Service에서 접근 방식이 변경된다:

```php
// ★ BEFORE (배열 접근)
$coupon = EventCouponRepository::findByIdx($idx);
if (!$coupon || $coupon['status'] !== 'available') { ... }
return $coupon;

// ★ AFTER (Entity 속성 접근 + toArray() 변환)
$coupon = EventCouponRepository::findByIdx($idx);
if (!$coupon || $coupon->status !== 'available') { ... }
return $coupon->toArray();
```

---

## 7. 새 Entity/Repository 추가 워크플로우

새로운 모듈을 추가할 때 다음 단계를 따른다:

### 7.1 Entity 추가

1. `lib/<module>/<Xxx>Entity.php` 파일 생성
2. `namespace Philgo\<Module>;` 선언
3. `use Philgo\Utils\EntityInterface;` 추가
4. `class XxxEntity implements EntityInterface` 선언
5. 프로퍼티: `public`, typed, 기본값 필수
6. `fromArray(array $data): static` 구현 (타입 캐스팅 + null-safe)
7. `toArray(): array` 구현 (계산 필드 포함)
8. `composer dump-autoload` 실행
9. `php -l lib/<module>/<Xxx>Entity.php` 문법 검증

### 7.2 Repository 추가

1. `lib/<module>/<Xxx>Repository.php` 파일 생성
2. `namespace Philgo\<Module>;` 선언
3. `use Philgo\Utils\{Db, EntityInterface, RepositoryInterface};` 추가
4. `class XxxRepository implements RepositoryInterface` 선언
5. `private const TABLE = 'xxx_table';` 테이블명 선언
6. 4개 필수 메서드 구현: `create()`, `findByIdx()`, `update()`, `deleteByIdx()`
7. `findByIdx()`에서 반드시 `XxxEntity::fromArray($row)` 호출
8. 확장 쿼리 메서드 추가 (필요 시)
9. `composer dump-autoload` 실행
10. `php -l lib/<module>/<Xxx>Repository.php` 문법 검증

### 7.3 검증

```bash
# PSR-4 오토로딩 갱신
composer dump-autoload

# PHP 문법 검증
php -l lib/<module>/<Xxx>Entity.php
php -l lib/<module>/<Xxx>Repository.php

# PEST 테스트 실행
php vendor/bin/pest tests/Unit/<Xxx>Test.php
```

---

## 8. 주의 사항 및 규칙

### 8.1 절대 금지 사항

| 금지 | 이유 |
|------|------|
| `fromArray()`에 `self` 리턴 타입 | `EntityInterface`의 `static`과 호환 불가 → Fatal Error |
| `findByIdx()`에서 배열 리턴 | `RepositoryInterface`는 `?EntityInterface` 리턴 요구 → Fatal Error |
| Entity에 `EntityInterface` 미구현 | 모든 Entity는 반드시 구현해야 함 |
| 기존 메서드명 사용 | `insert()`, `getByIdx()`, `delete()` 등 구 메서드명 사용 금지 |
| Entity 없이 RepositoryInterface 적용 | findByIdx()가 Entity를 리턴해야 하므로 해당 Entity 클래스가 반드시 먼저 존재해야 함 |
| 시그니처 불일치 Repository에 Interface 적용 | `update()` 파라미터 수가 다르면 Fatal Error (CompanyMetaRepository 사례) |

**🚨 실제 발생한 Fatal Error 사례**:

```
Fatal Error: Declaration of Philgo\Event\EventCouponRepository::findByIdx(int $idx): ?array
must be compatible with Philgo\Utils\RepositoryInterface::findByIdx(int $idx): ?Philgo\Utils\EntityInterface
```

이 에러는 `EventCouponRepository`에 `implements RepositoryInterface`를 적용한 후,
`findByIdx()`의 리턴 타입을 `?array`에서 `?EventCouponEntity`로 변경하지 않아 발생했다.
**해결**: EventCouponEntity를 새로 생성하고, findByIdx()가 이 Entity를 리턴하도록 수정했다.

### 8.2 Entity 프로퍼티 규칙

- `public` 접근 제한자 필수
- PHP 8.1+ 타입 선언 필수 (`int`, `string`, `array` 등)
- 기본값 필수 (int → `0`, string → `''`, array → `[]`)
- `fromArray()` 내에서 반드시 명시적 타입 캐스팅 (`(int)`, `(string)`)
- null-safe 접근: `$data['key'] ?? 기본값`

### 8.3 Repository CRUD 메서드 시그니처

```php
// ★ 반드시 이 시그니처를 준수
public static function create(array $data): int;
public static function findByIdx(int $idx): ?XxxEntity;  // 구체적 Entity 타입 사용 가능
public static function update(int $idx, array $data): bool;
public static function deleteByIdx(int $idx): bool;
```

### 8.4 Repository에서 목록 조회 시 Entity 변환

목록 조회 메서드(`findAll()`, `findByCompany()` 등)에서도 반드시 `Entity::fromArray($row)`로 변환한다.

```php
// ✅ 올바른 방식
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
return array_map(fn($row) => XxxEntity::fromArray($row), $rows);

// ❌ 금지 (배열 리턴)
return $stmt->fetchAll(PDO::FETCH_ASSOC);
```
