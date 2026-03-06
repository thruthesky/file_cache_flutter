# v7 Interface 시스템 — EntityInterface + RepositoryInterface + ServiceInterface + ControllerInterface

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
- [9. Interface 호환성 테스트 (PEST)](#9-interface-호환성-테스트-pest)
  - [9.1 테스트 파일 및 실행 방법](#91-테스트-파일-및-실행-방법)
  - [9.2 EntityInterface 테스트 패턴](#92-entityinterface-테스트-패턴)
  - [9.3 RepositoryInterface Reflection 검증 패턴](#93-repositoryinterface-reflection-검증-패턴)
  - [9.4 findByIdx() 반환 타입 검증 (Fatal Error 방지)](#94-findbyidx-반환-타입-검증-fatal-error-방지)
  - [9.5 CRUD 전체 사이클 테스트](#95-crud-전체-사이클-테스트)
  - [9.6 Service 계층 연동 테스트](#96-service-계층-연동-테스트)
  - [9.7 Settings API 종단 간 테스트](#97-settings-api-종단-간-테스트)
- [10. 리네이밍 마이그레이션 전수 조사 결과](#10-리네이밍-마이그레이션-전수-조사-결과)
  - [10.1 메서드 리네이밍 전후 대조표](#101-메서드-리네이밍-전후-대조표)
  - [10.2 호출부 변경 영향 분석](#102-호출부-변경-영향-분석)
  - [10.3 CompanyMetaRepository Interface 적용/제거 사례](#103-companymetarepository-interface-적용제거-사례)
- [11. ControllerInterface](#11-controllerinterface)
  - [11.1 도입 배경](#111-도입-배경)
  - [11.2 인터페이스 소스코드](#112-인터페이스-소스코드)
  - [11.3 적용된 Controller (10개)](#113-적용된-controller-10개)
  - [11.4 적용된 Controller (10개)](#114-적용된-controller-10개)
  - [11.5 list 페이지네이션 표준](#115-list-페이지네이션-표준)
  - [11.6 delete 반환 타입 통일](#116-delete-반환-타입-통일)
  - [11.7 래퍼 메서드 패턴](#117-래퍼-메서드-패턴)
  - [11.8 ControllerInterface 테스트 (PEST)](#118-controllerinterface-테스트-pest)
- [12. ServiceInterface](#12-serviceinterface)
  - [12.1 도입 배경](#121-도입-배경)
  - [12.2 인터페이스 소스코드](#122-인터페이스-소스코드)
  - [12.3 미지원 CRUD 처리 방식](#123-미지원-crud-처리-방식)
  - [12.4 적용된 Service (10개)](#124-적용된-service-10개)
  - [12.5 Controller ↔ Service 역할 분리](#125-controller--service-역할-분리)
  - [12.6 list 페이지네이션 표준](#126-list-페이지네이션-표준)
  - [12.7 Service CRUD 반환 타입 통일](#127-service-crud-반환-타입-통일)
  - [12.8 ServiceInterface 테스트 (PEST)](#128-serviceinterface-테스트-pest)

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
| **Service** | `ServiceInterface` | 10개 전체 | 모든 Service가 5개 CRUD를 직접 구현 |

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

## 4. Service 명명 규칙 (ServiceInterface 기반)

모든 도메인 Service는 `ServiceInterface`를 구현하여 표준 CRUD 메서드를 강제한다.
상세 구현 정보는 [12. ServiceInterface](#12-serviceinterface) 참조.

### 4.1 표준 메서드명

| 작업 | 표준 메서드명 | 입력 | 리턴 |
|------|-------------|------|------|
| 단건 조회 | `get(array $input)` | `array $input` | `array\|Entity` |
| 목록 조회 | `list(array $input)` | `array $input` | `array` (`['items' => [], 'total' => int, 'page' => int, 'limit' => int]`) |
| 생성 | `create(array $input)` | `array $input` | `array\|Entity` |
| 수정 | `update(array $input)` | `array $input` | `array\|Entity` |
| 삭제 | `delete(array $input)` | `array $input` | `array` (`['deleted' => bool]`) |

**규칙**:
- 모든 메서드는 `public static`으로 선언한다 (ServiceInterface 강제)
- 반환 타입은 `array|EntityInterface`이다. **단건 결과(create, get, update)는 가능한 한 Entity 객체를 직접 반환**하고, 목록(list)과 삭제(delete)는 array를 반환한다
- **Entity를 반환하면 api.php가 자동으로 `toArray()`를 호출**하여 JSON으로 변환하므로, Service/Controller에서 별도의 `->toArray()` 변환이 불필요하다
- 입력 파라미터는 `array $input`으로 통일한다 (JavaScript `func()` 호출과 호환)
- 에러는 `RuntimeException`으로 던진다
- 모든 Service는 5개 CRUD를 직접 구현한다. 미지원 메서드는 도메인에 맞는 구체적인 에러 메시지로 `RuntimeException`을 throw한다
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
Controller (api.php → dispatch)              ← ★ ControllerInterface
    ↓ array $input (인증/검증 후)
Service (비즈니스 로직, 검증, 데이터 처리)       ← ★ ServiceInterface
    ↓ array $data
Repository (PDO Prepared Statement)          ← ★ RepositoryInterface
    ↓ SQL
DB (MariaDB)
    ↓ array $row (PDO::FETCH_ASSOC)
Repository → Entity::fromArray($row)         ← ★ EntityInterface
    ↓ Entity 객체
Service → Entity 직접 반환 (또는 array)       ← ★ ServiceInterface (array|EntityInterface)
    ↓ Entity 또는 array
Controller → Entity 직접 반환 (또는 array)    ← ★ ControllerInterface (array|EntityInterface)
    ↓
api.php → toArray() 자동 호출 (Entity인 경우)
    ↓ array
api.php → json_encode()
    ↓
API 응답 (JSON)
```

**핵심 포인트**:
- Repository의 `findByIdx()`는 DB 행을 `Entity::fromArray($row)`로 변환하여 Entity를 리턴
- Service에서 Entity의 도메인 메서드(`isComment()`, `isSuccess()` 등)를 직접 호출 가능
- **단건 결과(create, get, update)는 Entity 객체를 직접 반환**하여 타입 안전성을 확보
- **api.php가 Entity 객체를 받으면 자동으로 `toArray()`를 호출**하여 배열로 변환 (api.php:96-106)
- 목록(list)과 삭제(delete) 등 복합 결과는 array를 반환
- Controller는 Service 결과를 그대로 반환 (얇은 계층)

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

---

## 9. Interface 호환성 테스트 (PEST)

### 9.1 테스트 파일 및 실행 방법

**파일**: `tests/Unit/InterfaceCompatibilityTest.php`

```bash
# 전체 Interface 호환성 테스트 실행
./vendor/bin/pest tests/Unit/InterfaceCompatibilityTest.php

# 특정 describe 블록만 실행
./vendor/bin/pest tests/Unit/InterfaceCompatibilityTest.php --filter "EntityInterface 구현 검증"
./vendor/bin/pest tests/Unit/InterfaceCompatibilityTest.php --filter "RepositoryInterface"
./vendor/bin/pest tests/Unit/InterfaceCompatibilityTest.php --filter "findByIdx"
```

**테스트 구성** (68개 테스트, 193 assertions):

| describe 블록 | 테스트 수 | 검증 내용 |
|---------------|----------|----------|
| EntityInterface 구현 검증 | 14 | 14개 Entity의 instanceof 체크 |
| EntityInterface 왕복 변환 | 8 | fromArray() → toArray() 데이터 일관성 |
| RepositoryInterface 구현 검증 | 6 | 6개 Repository의 Reflection 체크 |
| findByIdx() 반환 타입 검증 | 6 | Entity 인스턴스 반환 확인 (Fatal Error 방지) |
| Service 계층 연동 검증 | 5 | Service가 배열을 반환하는지 확인 |
| Settings API 호환성 | 4 | Controller/Service 종단 간 검증 |
| Reflection 시그니처 검증 | 24 | 6 Repository × 4 메서드 시그니처 |
| CRUD 전체 사이클 | 1 | create → find → update → delete 전 과정 |

### 9.2 EntityInterface 테스트 패턴

**14개 Entity의 instanceof 검증**:

```php
use Philgo\Utils\EntityInterface;
use Philgo\Event\EventCouponEntity;

it('EventCouponEntity는 EntityInterface를 구현한다', function () {
    $entity = EventCouponEntity::fromArray(['idx' => 1, 'coupon_type' => 'starbucks']);
    expect($entity)->toBeInstanceOf(EntityInterface::class);
    expect($entity->toArray())->toBeArray();
});
```

**fromArray() → toArray() 왕복 변환 검증**:

```php
it('EventCouponEntity: nullable 필드가 누락되면 null이 된다', function () {
    $entity = EventCouponEntity::fromArray([]);

    expect($entity->memo)->toBeNull();
    expect($entity->image_url)->toBeNull();
    expect($entity->idx_upload)->toBeNull();
    expect($entity->idx_winner)->toBeNull();
    expect($entity->won_at)->toBeNull();
    expect($entity->sent_at)->toBeNull();
});

it('EventCouponEntity: nullable 필드에 값이 있으면 올바르게 변환된다', function () {
    $data = [
        'memo' => '메모 있음',
        'idx_upload' => 55,
        'idx_winner' => 1001,
        'won_at' => 1700000000,
    ];
    $entity = EventCouponEntity::fromArray($data);

    expect($entity->memo)->toBe('메모 있음');
    expect($entity->idx_upload)->toBe(55);
    expect($entity->idx_winner)->toBe(1001);
    expect($entity->won_at)->toBe(1700000000);
});
```

### 9.3 RepositoryInterface Reflection 검증 패턴

PHP Reflection API를 사용하여 런타임에 메서드 시그니처를 검증한다.
이 패턴은 `implements RepositoryInterface` 선언만으로는 잡을 수 없는 세부 타입 문제를 잡는다.

```php
use Philgo\Utils\EntityInterface;
use Philgo\Event\EventCouponRepository;

$repositoryClasses = [
    PostRepository::class,
    CompanyRepository::class,
    QrCodeRepository::class,
    UploadRepository::class,
    EventCouponRepository::class,
    PointLogRepository::class,
];

foreach ($repositoryClasses as $repoClass) {
    $shortName = (new ReflectionClass($repoClass))->getShortName();

    it("{$shortName}::create()가 int를 반환한다", function () use ($repoClass) {
        $method = new ReflectionMethod($repoClass, 'create');
        expect($method->isStatic())->toBeTrue();
        expect($method->getReturnType()?->getName())->toBe('int');
    });

    it("{$shortName}::findByIdx()가 nullable EntityInterface를 반환한다", function () use ($repoClass) {
        $method = new ReflectionMethod($repoClass, 'findByIdx');
        $returnType = $method->getReturnType();
        expect($returnType->allowsNull())->toBeTrue();

        $typeName = $returnType->getName();
        if ($typeName !== EntityInterface::class) {
            $entityRef = new ReflectionClass($typeName);
            expect($entityRef->implementsInterface(EntityInterface::class))->toBeTrue();
        }
    });
}
```

**검증 항목** (6 Repository × 4 메서드 = 24 테스트):
- `create()`: static, 리턴 int
- `findByIdx()`: static, 리턴 nullable, EntityInterface 구현체
- `update()`: static, 리턴 bool
- `deleteByIdx()`: static, 리턴 bool

### 9.4 findByIdx() 반환 타입 검증 (Fatal Error 방지)

이 테스트는 **이전 Fatal Error의 재발을 방지**하는 핵심 테스트이다.
`findByIdx()`가 배열이 아닌 Entity 인스턴스를 반환하는지 실제 DB 호출로 확인한다.

```php
it('EventCouponRepository::findByIdx()는 EventCouponEntity를 반환한다', function () {
    $idx = EventCouponRepository::create([
        'coupon_type' => 'test_iface_findby',
        'title' => '인터페이스 findByIdx 테스트',
        'status' => 'available',
        'created_at' => time(),
        'updated_at' => time(),
    ]);

    $entity = EventCouponRepository::findByIdx($idx);

    // ★ 핵심 검증: EntityInterface 인스턴스인지 확인
    expect($entity)->toBeInstanceOf(EntityInterface::class);
    expect($entity)->toBeInstanceOf(EventCouponEntity::class);

    // 프로퍼티 접근 가능한지 확인 (배열이면 Fatal Error)
    expect($entity->idx)->toBe($idx);
    expect($entity->coupon_type)->toBe('test_iface_findby');

    // toArray()가 배열을 반환하는지 확인
    $arr = $entity->toArray();
    expect($arr)->toBeArray();
    expect($arr['idx'])->toBe($idx);

    EventCouponRepository::deleteByIdx($idx);
});
```

### 9.5 CRUD 전체 사이클 테스트

`create → findByIdx → update → findByIdx → deleteByIdx` 전체 사이클을 하나의 테스트에서 검증한다.
각 단계에서 반환 타입과 Entity 프로퍼티 접근을 확인한다.

```php
it('create → findByIdx → update → findByIdx → deleteByIdx 전체 사이클', function () {
    // 1. create: int 반환
    $idx = EventCouponRepository::create([...]);
    expect($idx)->toBeInt()->toBeGreaterThan(0);

    // 2. findByIdx: EntityInterface 반환
    $entity = EventCouponRepository::findByIdx($idx);
    expect($entity)->toBeInstanceOf(EventCouponEntity::class);
    expect($entity->coupon_type)->toBe('test_iface_lifecycle');

    // 3. update: bool 반환
    $success = EventCouponRepository::update($idx, ['title' => '수정된 제목']);
    expect($success)->toBeTrue();

    // 4. findByIdx 재조회: 수정 반영 확인
    $updated = EventCouponRepository::findByIdx($idx);
    expect($updated->title)->toBe('수정된 제목');

    // 5. toArray(): 배열 변환 확인
    $arr = $updated->toArray();
    expect($arr)->toBeArray();

    // 6. deleteByIdx: bool 반환
    $deleted = EventCouponRepository::deleteByIdx($idx);
    expect($deleted)->toBeTrue();

    // 7. 삭제 확인
    expect(EventCouponRepository::findByIdx($idx))->toBeNull();
});
```

### 9.6 Service 계층 연동 테스트

Service가 Repository의 Entity를 올바르게 사용하여 배열을 반환하는지 확인한다.

```php
it('EventCouponService::createCoupon()이 배열을 반환한다', function () {
    $result = EventCouponService::createCoupon([
        'coupon_type' => 'test_iface_svc_create',
        'title' => '서비스 생성 인터페이스 테스트',
    ]);

    // Service는 내부에서 Entity->toArray() 결과를 반환
    expect($result)->toBeArray();
    expect($result)->toHaveKeys(['idx', 'coupon_type', 'title', 'status']);
});
```

### 9.7 Settings API 종단 간 테스트

Flutter 앱에서 호출하는 Settings API의 호환성을 직접 검증한다.

```php
it('SettingsController::get()이 배열을 반환한다', function () {
    $ctrl = new SettingsController();
    $result = $ctrl->get([]);

    expect($result)->toBeArray();
    expect($result)->toHaveKey('admins');
    expect($result)->toHaveKey('available_starbucks_coupons');
});

it('SettingsController::appVersion()이 배열을 반환한다', function () {
    $ctrl = new SettingsController();
    $result = $ctrl->appVersion([]);
    expect($result)->toBeArray();
});

it('SettingsService::getAll()이 배열을 반환한다', function () {
    $result = SettingsService::getAll();
    expect($result)->toBeArray();
});
```

---

## 10. 리네이밍 마이그레이션 전수 조사 결과

### 10.1 메서드 리네이밍 전후 대조표

Interface 도입 시 기존 메서드명을 표준화하기 위해 리네이밍한 전체 내역이다.

| Repository | 구 메서드 | 신 메서드 | 리턴 타입 변경 |
|-----------|----------|----------|-------------|
| PointLogRepository | `insert(array $data): int` | `create(array $data): int` | 없음 |
| PointLogRepository | `getByIdx(int $idx): ?array` | `findByIdx(int $idx): ?PointLogEntity` | **`?array` → `?PointLogEntity`** |
| PointLogRepository | `delete(int $idx): bool` | `deleteByIdx(int $idx): bool` | 없음 |
| QrCodeRepository | `insert(array $data): int` | `create(array $data): int` | 없음 |
| QrCodeRepository | (신규 추가) | `update(int $idx, array $data): bool` | 신규 |
| EventCouponRepository | `findByIdx(int $idx): ?array` | `findByIdx(int $idx): ?EventCouponEntity` | **`?array` → `?EventCouponEntity`** |
| EventCouponRepository | `delete(int $idx): bool` | `deleteByIdx(int $idx): bool` | 없음 |
| UploadRepository | (신규 추가) | `update(int $idx, array $data): bool` | 신규 |

### 10.2 호출부 변경 영향 분석

`findByIdx()` 리턴 타입이 `?array` → `?Entity`로 변경된 경우, 호출부에서 접근 방식이 바뀌어야 한다.

**PointLogRepository 호출부**:
- `PointLogService::changePoints()`: `$existingLog['point']` → `$existingLog->point` (이미 Entity 접근 사용 중이었으므로 변경 불필요)

**EventCouponRepository 호출부**:
- `EventCouponService::deleteCoupon()`: `$coupon['status']` → `$coupon->status`
- `EventCouponService::toggleSentStatus()`: 내부에서 `findByIdx()` 호출 후 `$entity->toArray()` 리턴
- `EventCouponService::assignCouponToWinner()`: `findByIdx()` 호출 후 `$entity->toArray()` 리턴
- `EventCouponService::updateCoupon()`: `$coupon` 유효성 검증 → `$coupon->status` 등 프로퍼티 접근

**⚠️ lockAndPickAvailable()는 배열 리턴 유지**: RepositoryInterface에 포함되지 않는 확장 쿼리이므로 기존 `?array` 리턴을 유지한다. 트랜잭션 내에서 `SELECT ... FOR UPDATE`로 사용되며, Entity 변환 없이 바로 `$coupon['idx']`로 접근한다.

### 10.3 CompanyMetaRepository Interface 적용/제거 사례

**경위**: 처음에는 CompanyMetaRepository에도 `implements RepositoryInterface`를 적용했으나, 시그니처 불일치로 **즉시 제거**했다.

**문제**: CompanyMetaRepository의 `update()` 메서드가 3개 파라미터를 받는다:

```php
// CompanyMetaRepository — 실제 시그니처
public static function update(int $idxCompany, string $key, array $data): bool

// RepositoryInterface — 요구 시그니처
public static function update(int $idx, array $data): bool
```

파라미터 수가 2개 vs 3개로 호환 불가. PHP에서 `implements` 선언 시 **Fatal Error** 발생:

```
Declaration of CompanyMetaRepository::update(int $idxCompany, string $key, array $data): bool
must be compatible with RepositoryInterface::update(int $idx, array $data): bool
```

**근본 원인**: CompanyMetaRepository는 `idx` 기반 단일 키가 아니라 `(idx_company, key)` 복합 키로 데이터를 관리하는 key-value 패턴이다. 표준 CRUD의 `update(int $idx, array $data)` 시그니처와 구조적으로 맞지 않는다.

**교훈**: RepositoryInterface 적용 전 반드시 다음을 확인한다:
1. 해당 Repository가 `idx` 기반 단일 키를 사용하는가?
2. `create()`, `findByIdx()`, `update()`, `deleteByIdx()` 4개 메서드의 시그니처가 인터페이스와 호환되는가?
3. 도메인 특성상 삭제/수정이 불가능한 경우는 아닌가?

---

## 11. ControllerInterface

### 11.1 도입 배경

v7 시스템의 10개 Controller가 각각 독립적인 메서드명과 반환 형식을 사용하여 일관성이 부족했다.
ControllerInterface를 도입하여 모든 Controller에 CRUD(create, update, delete, get, list)
메서드를 강제하고, 특히 list의 페이지네이션 반환 형식을 통일했다.

**설계 결정: 모든 Controller가 5개 CRUD 메서드를 직접 구현**

- Interface: 5개 메서드 시그니처 강제 (컴파일 타임 검증)
- 모든 Controller 클래스가 create, update, delete, get, list를 직접 구현
- 아직 구현되지 않은 메서드는 RuntimeException을 직접 던지도록 작성
- Trait(ControllerDefaultsTrait)은 사용하지 않음 (삭제됨)

### 11.2 인터페이스 소스코드

파일: `lib/utils/ControllerInterface.php`

```php
namespace Philgo\Utils;

interface ControllerInterface
{
    public function create(array $input): array|EntityInterface;
    public function update(array $input): array|EntityInterface;
    public function delete(array $input): array|EntityInterface;
    public function get(array $input): array|EntityInterface;
    public function list(array $input): array|EntityInterface;
}
```

> **Entity 직접 반환 원칙**: 단건 결과(create, get, update)는 가능한 한 Entity 객체를 직접 반환한다.
> api.php가 Entity 객체를 받으면 자동으로 `toArray()`를 호출하여 JSON 배열로 변환한다.
> 이를 통해 **타입 안전성**을 확보하고, Controller/Service에서 불필요한 `->toArray()` 변환을 제거한다.

**각 모듈의 Controller Entity 반환 현황**:

| Controller | create | update | get | delete | list |
|-----------|--------|--------|-----|--------|------|
| PostController | `PostEntity` | `PostEntity` | `PostEntity` | `array` | `array` |
| CompanyController | `CompanyEntity` | `CompanyEntity` | `CompanyEntity` | `array` | `array` |
| CompanyMetaController | `CompanyMetaEntity` | `CompanyMetaEntity` | `array` | `array` | `array` |
| UploadController | `UploadEntity` | `UploadEntity` | `UploadEntity` | `array` | `array` |
| PointLogController | `PointLogEntity` | `PointLogEntity` | `PointLogEntity` | `array` | `array` |
| UserController | `UserEntity` | `UserEntity` | `UserEntity` | `array` | `array` |
| SettingsController | `array` | `array` | `array` | `array` | `array` |
| AiController | `array` | `array` | `array` | `array` | `array` |
| TravelController | `array` | `array` | `array` | `array` | `array` |
| EventController | `array` | `array` | `array` | `array` | `array` |

```text
```

### 11.3 적용된 Controller (10개)

모든 Controller가 5개 CRUD 메서드를 직접 구현한다.
아직 비즈니스 로직이 없는 메서드는 RuntimeException을 던진다.

| Controller | create | update | delete | get | list |
|-----------|--------|--------|--------|-----|------|
| PostController | Service 호출 | Service 호출 | Service 호출 | Service 호출 | Service 호출 |
| CompanyController | Service 호출 | Service 호출 | Service 호출 | Service 호출 | Service 호출 |
| CompanyMetaController | update 래퍼 | Service 호출 | Service 호출 | Service 호출 | get 래퍼 |
| UploadController | upload 래퍼 | 미구현 | Service 호출 | Service 호출 | Service 호출 |
| PointLogController | changePoints 래퍼 | Service 호출 | Service 호출 | Service 호출 | history 래퍼 |
| SettingsController | update 래퍼 | Service 호출 | 미구현 | Service 호출 | get 래퍼 |
| UserController | 미구현 | 미구현 | 미구현 | Service 호출 | 미구현 |
| AiController | generate 래퍼 | 미구현 | 미구현 | 미구현 | 미구현 |
| TravelController | 미구현 | 미구현 | 미구현 | Service 호출 | Service 호출 |
| EventController | spin 래퍼 | 미구현 | 미구현 | 미구현 | history 래퍼 |

### 11.5 list 페이지네이션 표준

**입력**: `page` (int, 기본 1), `limit` (int, 기본 20, 최대 100)

**반환 형식**:
```php
['items' => array, 'total' => int, 'page' => int, 'limit' => int]
```

| Controller | 변환 내용 |
|-----------|----------|
| PostController | `posts` 키 유지 + `items` 키 추가 (하위 호환) |
| TravelController | `pagination` 중첩 → 플랫 구조로 변환 |
| CompanyController | 기존 `items` 키 유지 |

### 11.6 delete 반환 타입 통일

기존에 `bool`을 반환하던 3개 Controller → `array` 반환으로 변경:

```php
// 변경 전: return Service::delete($input);  // bool
// 변경 후: return ['deleted' => Service::delete($input)];  // array
```

변경된 Controller: CompanyController, UploadController, CompanyMetaController

### 11.7 래퍼 메서드 패턴

CRUD 메서드명과 기존 메서드명이 다른 Controller에서 래퍼 패턴 사용:

```php
// PointLogController — Entity 직접 반환
public function create(array $input): PointLogEntity { return $this->changePoints($input); }
public function list(array $input): array { return $this->history($input); }

// UploadController — Entity 직접 반환
public function create(array $input): UploadEntity { return $this->upload($input); }
```

### 11.8 ControllerInterface 테스트 (PEST)

파일: `tests/Unit/ControllerInterfaceTest.php`
실행: `./vendor/bin/pest tests/Unit/ControllerInterfaceTest.php`
결과: **128개 테스트, 390개 assertions 통과**

테스트 항목:
1. 10개 Controller instanceof ControllerInterface 검증
2. 50개 CRUD 메서드 시그니처 검증 (10 Controller × 5 메서드)
3. Trait 사용 Controller의 미지원 메서드 RuntimeException 검증
4. 직접 구현 메서드의 declaring class 검증
5. 래퍼 메서드(create→changePoints, create→upload 등) 존재 검증
6. Interface/Trait 정의 자체의 무결성 검증

---

## 12. ServiceInterface

### 12.1 도입 배경

v7 시스템에서 Controller는 클라이언트 요청을 받아 입력값을 검증하고, Service를 호출한 후 결과를 응답하는 **얇은 계층(thin layer)**이다. 실제 비즈니스 로직/데이터 처리는 모두 **Service 클래스가 담당(thick layer)**한다.

기존에는 Service 클래스에 강제하는 인터페이스가 없어 다음 문제가 있었다:

| 문제 | 예시 |
|------|------|
| CRUD 메서드명 불일치 | `store()` vs `create()`, `remove()` vs `delete()`, `upsert()` vs `update()` |
| 반환 타입 불일치 | Entity 객체 vs 배열 vs bool 혼재 |
| list 페이지네이션 형식 불일치 | `posts` 키 vs `items` 키, `pagination` 중첩 vs 플랫 구조 |
| Controller에서 `->toArray()` 변환 부담 | Service가 Entity를 반환하면 Controller가 배열로 변환 |

**목표**: ServiceInterface를 도입하여 모든 Service에 **표준 CRUD 메서드(create, update, delete, get, list)**를 강제하고, **반환 타입을 `array|EntityInterface`로 통일**하여 Entity 직접 반환을 지원한다. api.php가 Entity 객체를 자동으로 `toArray()` 변환하므로, Service/Controller에서 불필요한 변환 코드가 제거된다.

**설계 결정: Interface 기반 직접 구현**

모든 Service는 ServiceInterface의 5개 CRUD 메서드를 직접 구현한다:

- **ServiceInterface**: 5개 static CRUD 메서드 시그니처 강제
- 모든 Service가 5개 CRUD를 직접 구현한다
- 미지원 메서드는 도메인에 맞는 구체적인 에러 메시지로 `RuntimeException`을 throw한다

### 12.2 인터페이스 소스코드

파일: `lib/utils/ServiceInterface.php`

```php
namespace Philgo\Utils;

interface ServiceInterface
{
    public static function create(array $input): array|EntityInterface;
    public static function update(array $input): array|EntityInterface;
    public static function delete(array $input): array|EntityInterface;
    public static function get(array $input): array|EntityInterface;
    public static function list(array $input): array;
}
```

**ControllerInterface와의 핵심 차이점**: Service 메서드는 모두 `public static`이다. Controller는 인스턴스 메서드(`public function`)를 사용한다.

### 12.3 미지원 CRUD 처리 방식

모든 Service는 5개 CRUD를 직접 구현한다. 미지원 메서드는 도메인에 맞는 구체적인 에러 메시지로 `RuntimeException`을 throw한다.

```php
// 예시: TravelService — JSON 읽기 전용이므로 create/update/delete는 미지원
public static function create(array $input): array
{
    throw new RuntimeException('여행 데이터는 읽기 전용입니다. 생성할 수 없습니다.');
}

public static function update(array $input): array
{
    throw new RuntimeException('여행 데이터는 읽기 전용입니다. 수정할 수 없습니다.');
}

public static function delete(array $input): array
{
    throw new RuntimeException('여행 데이터는 읽기 전용입니다. 삭제할 수 없습니다.');
}
```

**핵심 원칙**: 기존의 `ServiceDefaultsTrait`는 삭제되었다. 모든 Service 클래스가 5개 CRUD 메서드를 직접 구현하며, 미지원 기능은 도메인 맥락에 맞는 구체적인 에러 메시지를 포함한 `RuntimeException`을 throw한다.

### 12.4 적용된 Service (10개)

| Service | create | update | delete | get | list | 비고 |
|---------|--------|--------|--------|-----|------|------|
| PostService | 직접 | 직접 | 직접 | 직접 | 직접 | 5개 CRUD 모두 `array` 반환 |
| CompanyService | 직접 | 직접 | 직접 | 직접 | 직접 | delete가 `['deleted' => bool]` 반환 |
| PointLogService | 직접 | 직접 | 직접 | 직접 | 직접 | 기존 메서드를 CRUD 래퍼로 제공 |
| CompanyMetaService | 직접 | 직접 | 직접 | 직접 | 직접 | create→upsert 래퍼, list→findByCompany 래퍼 |
| UploadService | 직접 | 직접 | 직접 | 직접 | 직접 | create→store 래퍼, update→updateAttached 래퍼 |
| SettingsService | 직접 | 직접 | 직접 | 직접 | 직접 | create→update 래퍼(UPSERT), list→getAll 래퍼 |
| TravelService | 직접 | 직접 | 직접 | 직접 | 직접 | JSON 읽기 전용: create/update/delete는 RuntimeException |
| UserService | 직접 | 직접 | 직접 | 직접 | 직접 | sf_member 직접 쿼리, password 제외 |
| AiService | 직접 | 직접 | 직접 | 직접 | 직접 | create→generate 래퍼, get→moderate 래퍼, update/delete/list는 RuntimeException |
| EventService | 직접 | 직접 | 직접 | 직접 | 직접 | create→spin 래퍼, list→getHistory 래퍼, update/delete는 RuntimeException |

### 12.5 Controller <-> Service 역할 분리

ServiceInterface 도입으로 Controller와 Service의 역할이 명확히 분리되었다:

```
Controller (얇은 계층)          Service (두꺼운 계층)
─────────────────────           ─────────────────────
1. 클라이언트 입력 수신          1. 비즈니스 로직 처리
2. 인증/권한 확인               2. DB 조회/저장 (Repository 호출)
3. Service 호출                 3. Entity → array 변환
4. 결과를 클라이언트에 응답       4. 표준 형식으로 결과 반환
```

**변경 전** (Controller가 변환 담당):
```php
// PostController — 변경 전
public function get(array $input): array
{
    $entity = PostService::get($input);
    return $entity->toArray();  // Controller에서 변환
}
```

**변경 후** (Service가 array 반환):
```php
// PostController — 변경 후
public function get(array $input): array
{
    return PostService::get($input);  // Service가 이미 array 반환
}
```

### 12.6 list 페이지네이션 표준

모든 Service의 `list()` 메서드는 다음 표준을 따른다:

**입력 표준**:
- `page` (int): 페이지 번호 (기본 1)
- `limit` (int): 페이지당 항목 수 (기본 20, 최대 100)

**반환 형식 표준**:
```php
['items' => array, 'total' => int, 'page' => int, 'limit' => int]
```

| Service | 변환 내용 |
|---------|----------|
| PostService | `posts` 키 → `items` 키 추가 (하위 호환) |
| TravelService | `pagination` 중첩 → 플랫 구조 |
| UploadService | 신규 list() 추가 (표준 형식) |
| CompanyService | 기존 `items` 키 유지 |
| PointLogService | 기존 getHistory() 래퍼 |

### 12.7 Service/Controller CRUD 반환 타입 — Entity 직접 반환 원칙

ServiceInterface와 ControllerInterface의 CRUD 메서드는 `array|EntityInterface`를 반환한다.
**단건 결과(create, get, update)는 가능한 한 Entity 객체를 직접 반환**하여 타입 안전성을 확보한다.
api.php가 Entity 객체를 받으면 자동으로 `toArray()`를 호출하므로, 불필요한 변환 코드가 제거된다.

**Entity 직접 반환 패턴 (권장)**:
```php
// Service: Entity 직접 반환
public static function get(array $input): PostEntity
{
    $entity = PostRepository::findByIdx($idx);
    if ($entity === null) {
        throw new RuntimeException('해당 게시글을 찾을 수 없습니다.');
    }
    return $entity;  // Entity 직접 반환 → api.php에서 toArray() 자동 호출
}

// Controller: Service 결과를 그대로 전달
public function get(array $input): PostEntity
{
    return PostService::get($input);
}
```

**각 모듈의 Service Entity 반환 현황**:

| Service | create | update | get | delete | list |
|---------|--------|--------|-----|--------|------|
| UserService | `UserEntity` | `UserEntity` | `UserEntity` | `array` | `array` |
| PostService | `PostEntity` | `PostEntity` | `PostEntity` | `array` | `array` |
| CompanyService | `CompanyEntity` | `CompanyEntity` | `CompanyEntity` | `array` | `array` |
| CompanyMetaService | `CompanyMetaEntity` | `CompanyMetaEntity` | `array` | `array` | `array` |
| UploadService | `UploadEntity` | `UploadEntity` | `UploadEntity` | `array` | `array` |
| PointLogService | `PointLogEntity` | `PointLogEntity` | `PointLogEntity` | `array` | `array` |

**delete bool → array 래핑**:
```php
// delete는 항상 array 반환 (삭제 결과)
public static function delete(array $input): array
{
    return ['deleted' => CompanyRepository::deleteByIdx($idx)];
}
```

### 12.8 ServiceInterface 테스트 (PEST)

파일: `tests/Unit/ServiceInterfaceTest.php`
실행: `./vendor/bin/pest tests/Unit/ServiceInterfaceTest.php`
결과: **87개 테스트, 329개 assertions 통과**

테스트 항목:
1. 10개 Service `instanceof ServiceInterface` 검증
2. 50개 CRUD 메서드 시그니처 검증 (10 Service x 5 메서드, static/파라미터/반환 타입)
3. Trait 사용 Service의 미지원 메서드 `RuntimeException` 검증
4. TravelService CRUD 실제 동작 테스트 (list 페이지네이션, get 단건 조회)
5. SettingsService get/getValue 구분 테스트
6. PointLogService 시그니처 검증
