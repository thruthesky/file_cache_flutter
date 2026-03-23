# v7 광고(Advertisement) API 문서

## 목차

1. [개요](#1-개요)
2. [DB 스키마](#2-db-스키마)
3. [Entity — BannerEntity](#3-entity--bannerentity)
4. [Repository — AdvertisementRepository](#4-repository--advertisementrepository)
5. [Service — AdvertisementService](#5-service--advertisementservice)
6. [Controller — AdvertisementController](#6-controller--advertisementcontroller)
7. [API 엔드포인트 목록](#7-api-엔드포인트-목록)
8. [배너 타입 및 위치 규칙](#8-배너-타입-및-위치-규칙)

9. [배너 조회 로직 (홈페이지 표시용)](#9-배너-조회-로직-홈페이지-표시용)
10. [캐시 시스템](#10-캐시-시스템)
11. [에러 처리](#11-에러-처리)
12. [PEST 테스트](#12-pest-테스트)

---

## 1. 개요

v7 광고 시스템은 **기존 v6 광고 시스템과 동일한 DB 테이블**(`company`, `company_meta`)을 사용하며,
v7 PSR-4 아키텍처(Controller → Service → Repository → Db)로 재구현한다.

### 핵심 구조

```
광고주(회원) 1:1 업소(company) 1:N 배너(company_meta, group='advertisement')
```

- 1명의 회원은 1개의 업소(company)만 등록할 수 있다.
- 1개의 업소에 `ad_*` 필드로 광고 정보를 설정하면 광고가 된다.
- 1개의 광고에 여러 개의 배너(company_meta)를 등록할 수 있다.
- 배너는 4가지 타입: `top`, `wing`, `square`, `small`

### 파일 구조

```
lib/advertisement/
├── AdvertisementController.php   # API 엔드포인트 (ControllerInterface 구현)
├── AdvertisementService.php      # 비즈니스 로직 (요청 단위 캐시 포함)
├── AdvertisementRepository.php   # DB 접근 (14개 static 메서드)
└── BannerEntity.php              # 배너 데이터 구조체 (EntityInterface 구현)

v7/adv/
├── banner.php                       # 배너 광고 안내 페이지 (Vue.js + v7api)
├── banner.css                       # 배너 광고 안내 페이지 스타일
├── point.php                        # 포인트 광고 안내 페이지 (PHP 서버 렌더링)
├── point.css                        # 포인트 광고 안내 페이지 스타일
├── massage.php                      # 마사지 배너 광고 안내 페이지 (Vue.js + v7api)
└── massage.css                      # 마사지 배너 광고 안내 페이지 스타일

v7/widgets/advertisement/
├── point-purchase-info.php          # 포인트 구매 안내 위젯 (최소금액, 페소결제, 환불정책)
├── payment-info.php                 # 공용 입금 정보 위젯 (배너/포인트/마사지 공통, 복사 버튼 포함)
├── marketing-message.php            # 광고 마케팅 메시지 위젯
├── point-advertisements.php         # 포인트 광고 목록 위젯 (게시판)
├── square-banners.php               # 사각 배너 위젯
└── small-banners.php                # 작은 배너 위젯

tests/Unit/
├── AdvertisementTest.php            # 광고 API PEST 테스트 (57개 테스트)
├── AdvPointPageTest.php             # 포인트 광고 페이지 PEST 테스트 (23개 테스트)
└── AdvPaymentWidgetTest.php         # 공용 입금 정보 위젯 PEST 테스트 (13개 테스트)
```

### PSR-4 매핑 (composer.json)

```json
"Philgo\\Advertisement\\": "lib/advertisement/"
```

---

## 2. DB 스키마

### 2.1 company 테이블 (광고 기본 정보)

광고 정보는 `company` 테이블의 `ad_*` 컬럼에 저장된다.

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx` | int(10) UNSIGNED | 업소(광고) 고유 번호 (PK, AUTO_INCREMENT) |
| `idx_member` | int(10) UNSIGNED | 광고주 회원 번호 (FK → sf_member.idx) |
| `name` | varchar(64) | 업소명 |
| `location` | varchar(64) | 위치 (INSERT 시 필수) |
| `ad_title` | varchar(255) | 광고 제목 |
| `ad_description` | longtext | 광고 설명 |
| `ad_begin_date` | int(8) UNSIGNED | 광고 시작일 (YYYYMMDD 형식, 예: 20260101) |
| `ad_end_date` | int(8) UNSIGNED | 광고 종료일 (YYYYMMDD 형식, 예: 20261231) |
| `ad_click_url` | varchar(255) | 광고 클릭 시 이동 URL |
| `created_at` | int(10) UNSIGNED | 생성 시각 (UNIX timestamp) |
| `updated_at` | int(10) UNSIGNED | 수정 시각 (UNIX timestamp) |

**광고 식별 조건**: `ad_begin_date > 1` 이면 광고가 설정된 업소로 판단한다.

**활성 광고 조건**: `ad_begin_date <= 오늘(YYYYMMDD)` AND `ad_end_date >= 오늘(YYYYMMDD)`

### 2.2 company_meta 테이블 (배너 정보)

배너는 `company_meta` 테이블에 `group='advertisement'`로 저장된다.

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx` | int(10) UNSIGNED | 배너 고유 번호 (PK, AUTO_INCREMENT) |
| `idx_company` | int(10) UNSIGNED | 업소 번호 (FK → company.idx) |
| `group` | varchar(32) | 그룹 = `'advertisement'` (고정) |
| `category` | varchar(32) | 게시판/카테고리 코드 (예: `qna`, `freetalk`) |
| `type` | varchar(32) | 배너 타입: `top`, `wing`, `square`, `small` |
| `key` | varchar(64) | 배너 키: `{idx_company}:{category}:{type}` |
| `value` | longtext | 기타 값 (미사용, INSERT 시 빈 문자열) |
| `url` | varchar(255) | 배너 이미지 URL |
| `primary` | varchar(255) | 작은 배너 주 텍스트 (small 배너 전용) |
| `secondary` | varchar(255) | 작은 배너 부 텍스트 (small 배너 전용) |
| `all_page` | char(1) | 모든 페이지 표시 여부: `'y'` 또는 `''` |

> **주의**: `primary`, `secondary`, `key`, `group`은 SQL 예약어이므로 쿼리에서 반드시 **백틱**으로 감싸야 한다.

---

## 3. Entity — BannerEntity

**파일**: `lib/advertisement/BannerEntity.php`
**네임스페이스**: `Philgo\Advertisement\BannerEntity`
**구현 인터페이스**: `Philgo\Utils\EntityInterface`

### 3.1 프로퍼티

| 프로퍼티 | 타입 | 설명 | DB 컬럼 매핑 |
|----------|------|------|-------------|
| `idx` | `int` | 배너 고유 번호 | `company_meta.idx` (LEFT JOIN 시 `idx_meta` alias) |
| `idx_company` | `int` | 업소/광고 번호 | `company.idx` |
| `type` | `string` | 배너 타입 | `company_meta.type` |
| `category` | `string` | 게시판/카테고리 | `company_meta.category` |
| `imageUrl` | `string` | 배너 이미지 URL | `company_meta.url` |
| `clickUrl` | `string` | 클릭 시 이동 URL (변환값) | `company.ad_click_url` → `resolveClickUrl()` |
| `target` | `?string` | 링크 타겟 | `company.ad_click_url` → `resolveTarget()` |
| `primary` | `string` | 작은 배너 주 텍스트 | `company_meta.primary` |
| `secondary` | `string` | 작은 배너 부 텍스트 | `company_meta.secondary` |
| `allPage` | `string` | 모든 페이지 표시 여부 | `company_meta.all_page` |
| `adEndDate` | `string` | 광고 종료일 (YYYYMMDD) | `company.ad_end_date` |
| `key` | `string` | 배너 키 | `company_meta.key` |

### 3.2 fromArray() — DB 행 → Entity 변환

```php
public static function fromArray(array $data): static
```

LEFT JOIN 결과에서 company 컬럼(`ad_click_url`, `ad_end_date`)과
company_meta 컬럼(`type`, `category`, `url` 등)을 모두 매핑한다.

**idx 매핑 우선순위**: `$data['idx_meta']` → `$data['idx']` (LEFT JOIN alias 우선)

### 3.3 toArray() — Entity → API 응답 배열 변환

```php
public function toArray(): array
```

반환 키: `idx`, `idx_company`, `type`, `category`, `image_url`, `click_url`, `target`, `primary`, `secondary`, `all_page`, `ad_end_date`, `key`

> **주의**: PHP 프로퍼티명(`imageUrl`)과 배열 키명(`image_url`)이 다르다 (스네이크 케이스 변환).

### 3.4 resolveClickUrl() — 클릭 URL 변환 (v6 get_advertisement_url()과 동일)

```php
public static function resolveClickUrl(string $url): string
```

| 입력 | 출력 | 설명 |
|------|------|------|
| `''` | `''` | 빈 문자열 |
| `'https://example.com'` | `'https://example.com'` | http로 시작 → 그대로 |
| `'12345'` | `'/post/adv.php?idx=12345'` | 숫자만 → 내부 글 URL |
| `'idx=67890'` | `'/post/adv.php?idx=67890'` | idx= 패턴 → 내부 글 URL |
| `'/custom/path'` | `'/custom/path'` | 기타 → 그대로 |

### 3.5 resolveTarget() — 링크 타겟 결정 (v6 get_advertisement_target()과 동일)

```php
public static function resolveTarget(string $url): ?string
```

| 입력 | 출력 | 설명 |
|------|------|------|
| `'https://...'` / `'http://...'` | `'_blank'` | http 포함 → 새 창 |
| `'12345'` / `''` | `null` | http 미포함 → 현재 창 |

---

## 4. Repository — AdvertisementRepository

**파일**: `lib/advertisement/AdvertisementRepository.php`
**네임스페이스**: `Philgo\Advertisement\AdvertisementRepository`

14개 정적 메서드로 구성된 DB 접근 계층이다.

### 4.1 광고(company) 조회

| 메서드 | 반환 타입 | 설명 |
|--------|-----------|------|
| `findByIdx(int $idx)` | `array\|false` | company.idx로 조회 |
| `findByIdxMember(int $idxMember)` | `array\|false` | idx_member로 조회 (`ad_begin_date > 1` 조건) |
| `findActiveAdvertisements()` | `array` | 오늘 날짜 기준 활성 광고 목록 (LIMIT 1000) |

### 4.2 광고 목록 (관리자용, LEFT JOIN 배너)

```php
public static function findAdvertisements(
    ?string $status = null,
    ?string $searchTerm = null,
    int $limit = 1000
): array
```

**status 필터**:

| 값 | 조건 | 설명 |
|----|------|------|
| `null` | `ad_begin_date > 1` | 전체 (광고 설정된 업소) |
| `'active'` | `begin <= 오늘 AND end >= 오늘` | 현재 진행 중 |
| `'expired'` | `end < 오늘` | 만료됨 |
| `'expiring'` | `end BETWEEN (오늘-3일) AND (오늘+15일)` | 만료 임박 |

**searchTerm**: `ad_title` 또는 `ad_description`에 대한 LIKE 검색

**SQL 구조**: `company c LEFT JOIN company_meta m ON c.idx = m.idx_company AND m.group = 'advertisement'`

**SELECT 컬럼**:
```sql
c.idx AS idx_company, c.idx_member, c.name,
c.ad_title, c.ad_description, c.ad_begin_date, c.ad_end_date, c.ad_click_url,
m.idx AS idx_meta, m.type, m.category, m.url,
m.`primary`, m.secondary, m.all_page, m.`key`
```

### 4.3 광고 필드 업데이트

```php
public static function updateAdFields(int $idx, array $data): bool
```

**허용 필드**: `ad_title`, `ad_description`, `ad_begin_date`, `ad_end_date`, `ad_click_url`

`updated_at = UNIX_TIMESTAMP()`도 함께 업데이트된다.

### 4.4 배너(company_meta) CRUD

| 메서드 | 반환 타입 | 설명 |
|--------|-----------|------|
| `findBanners(int $idxCompany)` | `array` | 업소의 모든 배너 조회 (`ORDER BY idx ASC`) |
| `findBanner(int $idxCompany, string $key)` | `array\|false` | 키 기반 단건 조회 |
| `findBannerByIdx(int $idx)` | `array\|false` | idx 기반 단건 조회 |
| `addBanner(array $data)` | `int` | 배너 추가 (AUTO_INCREMENT idx 반환) |
| `updateBanner(int $idx, array $data)` | `bool` | 배너 수정 (허용 필드: category, type, key, url, primary, secondary, all_page) |
| `deleteBanner(int $idxCompany, string $key)` | `bool` | 키 기반 배너 삭제 |

### 4.5 활성 배너 조회 (홈페이지 표시용)

| 메서드 | 반환 타입 | 설명 |
|--------|-----------|------|
| `findActiveBannersByType(string $type)` | `array` | 타입별 활성 배너 조회 (INNER JOIN, 날짜 필터) |
| `findAllActiveBanners()` | `array` | 모든 활성 배너 조회 (타입 무관) |
| `countActiveBannersAtLocation(string $type, string $category)` | `int` | 동일 위치 활성 배너 개수 (top/wing 최대 2개 제한용) |

**활성 배너 SQL 패턴**:
```sql
SELECT c.idx AS idx_company, c.ad_click_url, c.ad_end_date,
       m.idx AS idx_meta, m.type, m.category, m.url,
       m.`primary`, m.secondary, m.all_page, m.`key`
FROM company c
INNER JOIN company_meta m ON c.idx = m.idx_company AND m.`group` = 'advertisement'
WHERE c.ad_begin_date <= ? AND c.ad_end_date >= ?
  AND m.type = ?
ORDER BY c.ad_end_date DESC
```

---

## 5. Service — AdvertisementService

**파일**: `lib/advertisement/AdvertisementService.php`
**네임스페이스**: `Philgo\Advertisement\AdvertisementService`

### 5.1 광고 CRUD

#### get(array $input): array

광고 기본 정보 + 배너 목록을 함께 반환한다.

**입력**: `['idx' => 123]` 또는 `['idx_member' => 456]`

**로직**:
1. `idx` 또는 `idx_member`로 company 조회
2. `AdvertisementRepository::findBanners()`로 해당 업소의 배너 조회
3. 각 배너에 company의 `ad_click_url`, `ad_end_date`를 병합하여 `BannerEntity::fromArray()` 생성
4. `toArray()`로 변환하여 `$ad['banners']` 배열에 추가

**반환 구조**:
```php
[
    'idx' => 123,
    'idx_member' => 456,
    'name' => '업소명',
    'ad_title' => '광고 제목',
    'ad_description' => '광고 설명',
    'ad_begin_date' => 20260101,
    'ad_end_date' => 20261231,
    'ad_click_url' => 'https://...',
    'banners' => [
        ['idx' => 10, 'type' => 'top', 'category' => 'qna', ...],
        ['idx' => 11, 'type' => 'wing', 'category' => 'freetalk', ...],
    ],
]
```

#### list(array $input): array

관리자용 광고 목록을 업소별로 그룹화하여 반환한다.

**입력**: `['status' => 'active', 'search_term' => '맛집']`

**내부 로직**: `findAdvertisements()` → `groupAdvertisementsWithMeta()` (LEFT JOIN 결과를 업소별 그룹화)

#### update(array $input): array

광고 `ad_*` 필드를 업데이트하고 최신 정보를 반환한다.

**입력**: `['idx' => 123, 'ad_title' => '새제목', 'ad_begin_date' => 20260101]`

### 5.2 배너 CRUD

#### addBanner(array $input): array

**입력**: `['idx_company' => 123, 'type' => 'top', 'category' => 'qna', 'url' => 'https://...', 'all_page' => '']`

**검증 로직**:
1. `idx_company` 필수
2. `type` ∈ `['top', 'wing', 'square', 'small']` 검증
3. `top`/`wing`은 `category` 필수 (단, `all_page='y'`이면 예외)
4. 배너 키 `{idx_company}:{category}:{type}` 생성
5. 동일 키 중복 검사 (`findBanner()`)
6. `top`/`wing` 위치 제한: 카테고리당 최대 2개 (`countActiveBannersAtLocation()`)

**성공 시**: 캐시 초기화 → `get(['idx' => $idxCompany])` 반환

#### updateBanner(array $input): array

**입력**: `['idx' => 456, 'idx_company' => 123, 'type' => 'wing', 'url' => 'https://...']`

**타입/카테고리 변경 시**: 새 키 `{idx_company}:{category}:{type}` 재생성 → 중복 검사

#### deleteBanner(array $input): array

**입력**: `['idx_company' => 123, 'key' => '123:qna:top']`

### 5.3 홈페이지 표시용 배너 조회

#### getTopBanners(?string $category = null): array

**반환**: `['left' => BannerEntity[], 'right' => BannerEntity[], 'left_fixed' => bool, 'right_fixed' => bool]`

**상세 배치 로직** (v6 `get_top_banners()`와 100% 동일):

1. `findActiveBannersByType('top')`으로 모든 활성 top 배너 조회
2. 카테고리 배너와 `all_page` 배너로 분리
3. **all_page 배너 시간 기반 순환**: `(현재분 % 10) % 배너수`로 시작 오프셋 결정 (1분 단위 서버 사이드 로테이션)
4. 배치 규칙:

| 카테고리 배너 수 | 왼쪽 | 오른쪽 | left_fixed | right_fixed |
|-----------------|------|--------|-----------|-------------|
| 2개 이상 | 첫 번째 고정 | 두 번째 고정 | `true` | `true` |
| 1개 | 카테고리 배너 고정 | all_page 배너들 (JS 로테이션) | `true` | `false` |
| 0개 | all_page 짝수 인덱스 | all_page 홀수 인덱스 | `false` | `false` |

#### getWingBanners(?string $category = null): array

**반환**: `['left' => BannerEntity[], 'right' => BannerEntity[]]`

**로직**: `filterBanners()`로 카테고리 + all_page 필터링 → 좌/우 번갈아 분배 (짝수=왼쪽, 홀수=오른쪽)

#### getSquareBanners(?string $category = null): BannerEntity[]

**로직**:
1. square 배너 중 `all_page='y'` 또는 현재 카테고리 매칭 필터
2. wing 배너 중 현재 카테고리 매칭 배너를 **앞에** 추가 (v6과 동일)
3. `array_merge(matchingWings, filteredSquare)` 반환

#### getSmallBanners(?string $category = null): BannerEntity[]

**로직**: `all_page='y'` 또는 현재 카테고리 배너만 필터링

### 5.4 헬퍼 함수

#### filterBanners(array $banners, ?string $category): array (private)

카테고리 매칭 배너를 앞에, all_page 배너를 뒤에 배치한다.
매칭되지 않고 all_page도 아닌 배너는 제외된다.

#### groupAdvertisementsWithMeta(array $rows): array (private)

LEFT JOIN 결과를 `idx_company` 기준으로 그룹화하여 각 업소에 `banners[]` 배열을 포함시킨다.
`idx_meta`가 비어있는 행(배너 없는 업소)은 banners 배열이 비어있다.

#### getRemainingDays(string $adEndDate): int (public static)

YYYYMMDD 형식의 종료일과 오늘의 차이 일수를 반환한다.
- 양수: 남은 일수
- 0: 오늘 만료
- 음수: 만료된 일수
- 빈 문자열 또는 8자리 미만: 0 반환

#### resetCache(): void (public static)

테스트용 캐시 초기화 메서드.

---

## 6. Controller — AdvertisementController

**파일**: `lib/advertisement/AdvertisementController.php`
**네임스페이스**: `Philgo\Advertisement\AdvertisementController`
**구현 인터페이스**: `Philgo\Utils\ControllerInterface`

### 6.1 관리자 권한 확인

```php
private function requireAdmin(): void
{
    if (!AuthService::isAdmin()) {
        throw new RuntimeException('관리자 권한이 필요합니다.');
    }
}
```

### 6.2 표준 CRUD (ControllerInterface)

| 메서드 | 권한 | 동작 |
|--------|------|------|
| `get($input)` | 누구나 | `AdvertisementService::get($input)` |
| `list($input)` | 관리자 | `AdvertisementService::list($input)` |
| `create($input)` | — | RuntimeException throw (미사용) |
| `update($input)` | 관리자 | `AdvertisementService::update($input)` |
| `delete($input)` | — | RuntimeException throw (미사용) |

> `create()`와 `delete()`는 ControllerInterface 구현을 위해 존재하지만 항상 예외를 발생시킨다.
> 광고 생성은 업소 등록 후 `update`로 설정, 삭제는 배너 개별 삭제 + `ad_begin_date=0` 설정.

### 6.3 배너 CRUD API

| 메서드 | 권한 | API 엔드포인트 |
|--------|------|----------------|
| `addBanner($input)` | 관리자 | `POST /api.php?method=advertisement.addBanner` |
| `updateBanner($input)` | 관리자 | `POST /api.php?method=advertisement.updateBanner` |
| `deleteBanner($input)` | 관리자 | `POST /api.php?method=advertisement.deleteBanner` |

### 6.4 홈페이지 표시용 배너 조회 API

| 메서드 | 권한 | API 엔드포인트 |
|--------|------|----------------|
| `topBanners($input)` | 누구나 | `GET /api.php?method=advertisement.topBanners&category=qna` |
| `wingBanners($input)` | 누구나 | `GET /api.php?method=advertisement.wingBanners&category=qna` |
| `squareBanners($input)` | 누구나 | `GET /api.php?method=advertisement.squareBanners&category=qna` |
| `smallBanners($input)` | 누구나 | `GET /api.php?method=advertisement.smallBanners&category=qna` |

**BannerEntity → 배열 변환**: 각 메서드에서 `BannerEntity::toArray()`를 통해 배열로 변환하여 반환한다.

```php
public function topBanners(array $input): array
{
    $category = !empty($input['category']) ? (string)$input['category'] : null;
    $result = AdvertisementService::getTopBanners($category);
    return [
        'left' => array_map(fn(BannerEntity $b) => $b->toArray(), $result['left']),
        'right' => array_map(fn(BannerEntity $b) => $b->toArray(), $result['right']),
        'left_fixed' => $result['left_fixed'],
        'right_fixed' => $result['right_fixed'],
    ];
}
```

---

## 7. API 엔드포인트 목록

### 7.1 광고 관리 (관리자 전용)

| 메서드 | 엔드포인트 | 설명 | 권한 |
|--------|-----------|------|------|
| `advertisement.get` | `GET /api.php?method=advertisement.get&idx=123` | 광고 조회 (배너 포함) | 누구나 |
| `advertisement.get` | `GET /api.php?method=advertisement.get&idx_member=456` | 회원 번호로 광고 조회 | 누구나 |
| `advertisement.list` | `GET /api.php?method=advertisement.list&status=active` | 광고 목록 | 관리자 |
| `advertisement.list` | `GET /api.php?method=advertisement.list&status=expired&search_term=맛집` | 광고 목록 (검색) | 관리자 |
| `advertisement.update` | `POST /api.php?method=advertisement.update&idx=123&ad_title=새제목` | 광고 정보 수정 | 관리자 |

### 7.2 배너 CRUD (관리자 전용)

| 메서드 | 엔드포인트 | 설명 | 권한 |
|--------|-----------|------|------|
| `advertisement.addBanner` | `POST /api.php?method=advertisement.addBanner&idx_company=123&type=top&category=qna&url=https://...` | 배너 추가 | 관리자 |
| `advertisement.updateBanner` | `POST /api.php?method=advertisement.updateBanner&idx=456&idx_company=123&url=https://...` | 배너 수정 | 관리자 |
| `advertisement.deleteBanner` | `POST /api.php?method=advertisement.deleteBanner&idx_company=123&key=123:qna:top` | 배너 삭제 | 관리자 |

### 7.3 배너 광고 안내 정보

| 메서드 | 엔드포인트 | 설명 | 권한 |
|--------|-----------|------|------|
| `advertisement.bannerInfo` | `GET /api.php?method=advertisement.bannerInfo` | 배너 종류별 가격/기간/카테고리/환불정책/등록프로세스 조회 | 누구나 |

**응답 구조:**

```json
{
  "banner_types": {
    "top": {
      "name": "탑 배너",
      "name_en": "Top Banner",
      "size": "600 x 200",
      "unit": "px",
      "gif": true,
      "position": "홈페이지 맨 위에 표시",
      "packages": [
        {
          "code": "T1",
          "name": "서브 게시판 1개",
          "price": 21000,
          "currency": "PHP",
          "duration_months": 3,
          "category_type": "minor",
          "included_banners": [
            {"type": "top", "size": "600 x 200", "gif": true},
            {"type": "small", "size": "200 x 100", "gif": false}
          ]
        }
      ]
    }
  },
  "major_categories": {"질문답변": "qna", ...},
  "minor_categories": {"마사지": "massage", ...},
  "refund_policy": [
    {"period": "결제 후 15일 이내", "rate": 65, "description": "65% 환불"},
    {"period": "결제 후 30일 이내", "rate": 50, "description": "50% 환불"},
    {"period": "30일 이후", "rate": 0, "description": "환불 불가"}
  ],
  "pause_policy": {"min_remaining_days": 7, "description": "..."},
  "registration_process": [
    {"step": 1, "title": "광고비 입금", "description": "..."},
    {"step": 2, "title": "자료 제출", "description": "..."},
    {"step": 3, "title": "배너 제작", "description": "..."},
    {"step": 4, "title": "배너 등록", "description": "..."}
  ]
}
```

**JavaScript 호출 예시:**

```javascript
v7api('advertisement.bannerInfo').then(res => {
    console.log(res.banner_types);        // 배너 종류별 상세 정보
    console.log(res.major_categories);    // 메인 카테고리
    console.log(res.minor_categories);    // 소 카테고리
    console.log(res.refund_policy);       // 환불 정책
    console.log(res.registration_process); // 등록 프로세스
});
```

**v7 페이지:** `/adv/banner` (v7/adv/banner.php)

**배너 위치 이미지:** 각 배너 타입별 위치 다이어그램 이미지가 `/res/img/banner/places/` 폴더에 존재한다:
- `top-banner.png` — 탑 배너 위치 (헤더 좌/우)
- `wing-banner.png` — 날개 배너 위치 (페이지 좌/우)
- `square-banner.png` — 사각 배너 위치 (게시판 상단)
- `small-banner.png` — 작은 배너 위치 (사각배너 아래)

배너 안내 페이지에서 각 타입 카드 내에 해당 이미지를 표시하여 배너가 실제로 어디에 노출되는지 시각적으로 안내한다.

### 7.3.1 마사지 배너 광고 안내 정보

| 메서드 | 엔드포인트 | 설명 | 권한 |
|--------|-----------|------|------|
| `advertisement.massageBannerInfo` | `GET /api.php?method=advertisement.massageBannerInfo` | 마사지 업종 전용 배너 종류/비용/기간/규정/환불/입금정보 조회 | 누구나 |

마사지 업종은 사각 배너(45,000 PHP/3개월)와 작은 배너(30,000 PHP/3개월)만 가능하다.
대규모 스파 시설(100명 이상 수용)은 탑배너/날개배너도 가능 — `bannerInfo` API 참조.

**응답 구조:**

```json
{
  "banner_types": {
    "square": {"name": "사각 배너", "price": 45000, "currency": "PHP", "duration_months": 3, "size": "400 x 400", ...},
    "small": {"name": "작은 배너", "price": 30000, "currency": "PHP", "duration_months": 3, "size": "200 x 100", ...}
  },
  "spa_notice": "동시에 100명 이상 수용 가능한 스파 시설의 경우...",
  "rules": [
    {"title": "일반적인 마사지 내용만 포함", "items": [...]},
    {"title": "일반적인 마사지 사진만 포함", "items": [...]},
    {"title": "필수 포함 항목", "items": [...]}
  ],
  "refund_policy": [...],
  "pause_policy": {...},
  "payment_info": {"notice": "...", "accounts": [{...KRW...}, {...PHP...}]},
  "marketing": {"title": "...", "description": "..."},
  "kakaotalk_guide_url": "/page/help/kakaotalk-1-1-open-chat.php"
}
```

**JavaScript 호출 예시:**

```javascript
v7api('advertisement.massageBannerInfo').then(res => {
    console.log(res.banner_types);     // 사각/작은 배너 정보 (가격/기간 포함)
    console.log(res.rules);            // 마사지 배너 규정 3개
    console.log(res.payment_info);     // 입금 계좌 정보
});
```

**v7 페이지:** `/adv/massage` (v7/adv/massage.php + massage.css)

### 7.4 포인트 광고 안내 페이지

**v7 페이지:** `/adv/point` (v7/adv/point.php + point.css)

포인트 구매 안내, 결제 정보(계좌), 마케팅 메시지를 표시하는 서버 렌더링 페이지이다.
API 호출 없이 PHP로 직접 렌더링한다.

**페이지 구성:**

| 섹션 | 위젯 파일 | 설명 |
|------|-----------|------|
| 공통 헤더/네비게이션 | `adv/adv-nav.php` | 아이콘 + 제목 + 설명 + 탭 네비게이션 |
| 구매 안내 | `widgets/advertisement/point-purchase-info.php` | 최소 구매 금액, 페소 결제, 환불 정책 (3열 그리드) |
| 입금 정보 | `widgets/advertisement/payment-info.php` | 공용 입금 정보 위젯 (배너/포인트/마사지 공통) |
| 마케팅 메시지 | `widgets/advertisement/marketing-message.php` | 필고 광고 플랫폼 홍보 + 운영자 문의 버튼 |

**모바일 앱 분기:** `RequestUtils::get('device') === 'mobile'`이면 입금 정보 섹션과 운영자 문의 버튼 숨김.

### 7.5 공용 입금 정보 위젯 및 API

#### API: `advertisement.paymentInfo`

| 메서드 | 엔드포인트 | 설명 | 권한 |
|--------|-----------|------|------|
| `advertisement.paymentInfo` | `GET /api.php?method=advertisement.paymentInfo` | KB국민은행/BDO 계좌 정보 조회 | 누구나 |

**응답 구조:**

```json
{
  "notice": "입금 후 반드시 입금증을 보내주세요.",
  "accounts": [
    {
      "bank": "국민은행",
      "bank_en": "KB Kookmin Bank",
      "currency": "KRW",
      "account_name": "송재호",
      "account_no": "655-601-04-1644-08"
    },
    {
      "bank": "BDO",
      "bank_en": "BDO Unibank",
      "currency": "PHP",
      "account_name": "JAEHO SONG",
      "account_no": "008-018-022-138"
    }
  ]
}
```

**서비스 메서드:** `AdvertisementService::getPaymentInfo()` (public static)

**사용 상수 (etc/app.config.php):**
- `KB_NAME`, `KB_ACCOUNT_NAME`, `KB_ACCOUNT_NO` — 국민은행 계좌
- `BDO_NAME`, `BDO_ACCOUNT_NAME`, `BDO_ACCOUNT_NO` — BDO 계좌

#### 공용 위젯: `widgets/advertisement/payment-info.php`

배너, 포인트, 마사지 광고 페이지에서 동일한 디자인으로 사용되는 공용 위젯이다.

**특징:**
- PHP 서버사이드 렌더링 (API 호출 없이 상수 직접 사용)
- `adv-payment-*` CSS 클래스 사용 (banner.css에 정의)
- 복사 버튼 클릭 시 **은행명 + 예금주 + 계좌번호** 전체를 클립보드에 복사
- 모바일 앱(`?device=mobile`) 시 위젯 전체 숨김 (위젯 내부에서 자동 처리)
- `advCopyPaymentInfo(bank, name, accountNo)` JavaScript 함수 사용

**사용법 (PHP include):**
```php
<?php include __DIR__ . '/../widgets/advertisement/payment-info.php'; ?>
```

세 광고 페이지에서의 사용 위치:
- `banner.php`: Vue 앱 바깥(하단)에 PHP include
- `point.php`: `<div class="v7-content-pad">` 내부에 PHP include
- `massage.php`: Vue 앱 바깥(하단)에 `<div class="v7-content-pad">` 래퍼와 함께 PHP include

### 7.6 배너 조회 (홈페이지 표시용)

| 메서드 | 엔드포인트 | 설명 | 권한 |
|--------|-----------|------|------|
| `advertisement.topBanners` | `GET /api.php?method=advertisement.topBanners&category=qna` | 상단 배너 (좌/우) | 누구나 |
| `advertisement.wingBanners` | `GET /api.php?method=advertisement.wingBanners&category=qna` | 날개 배너 (좌/우) | 누구나 |
| `advertisement.squareBanners` | `GET /api.php?method=advertisement.squareBanners&category=qna` | 사각 배너 | 누구나 |
| `advertisement.smallBanners` | `GET /api.php?method=advertisement.smallBanners&category=qna` | 작은 배너 | 누구나 |

---

## 8. 배너 타입 및 위치 규칙

### 8.1 배너 4가지 타입

| 타입 | 설명 | 크기 | 위치 | 제한 |
|------|------|------|------|------|
| `top` | 상단 배너 | 252×84px (3:1) | 헤더 양측 좌/우 | 카테고리당 최대 2개 |
| `wing` | 날개 배너 | 정사각형 (1:1) | 페이지 좌/우 날개 | 카테고리당 최대 2개 |
| `square` | 사각 배너 | 정사각형 (1:1) | 게시판 상단 | 제한 없음 |
| `small` | 작은 배너 | 92×46px + 텍스트 | 사각 배너 아래 | 제한 없음 |

### 8.2 배너 키 형식

```
{idx_company}:{category}:{type}
```

예시:
- `123:qna:top` — 업소 123, 질문답변 게시판, 상단 배너
- `123::wing` — 업소 123, 카테고리 없음(all_page), 날개 배너
- `456:freetalk:square` — 업소 456, 자유게시판, 사각 배너

### 8.3 all_page 배너

- `all_page = 'y'`로 설정하면 모든 페이지/게시판에 표시
- `category`와 무관하게 전체 노출
- top 배너의 경우 서버 사이드 시간 기반(1분 단위) 순환 로테이션 + 클라이언트 9초 JavaScript 로테이션

### 8.4 카테고리 필수 조건

- `top`/`wing` 배너는 `category`가 필수 (단, `all_page='y'`이면 비어있어도 허용)
- `square`/`small` 배너는 `category` 선택 사항

---

## 9. 배너 조회 로직 (홈페이지 표시용)

### 9.1 Top 배너 배치 규칙

```
카테고리 배너 2개 이상:
  → 왼쪽: 첫 번째 카테고리 배너 (고정, left_fixed=true)
  → 오른쪽: 두 번째 카테고리 배너 (고정, right_fixed=true)

카테고리 배너 1개:
  → 왼쪽: 카테고리 배너 (고정, left_fixed=true)
  → 오른쪽: all_page 배너들 (9초 JS 로테이션, right_fixed=false)

카테고리 배너 없음:
  → all_page 배너를 좌/우 번갈아 분배 (left_fixed=false, right_fixed=false)
```

### 9.2 Wing 배너 배치 규칙

```
현재 카테고리 배너를 앞에 배치 + all_page 배너를 뒤에 배치
→ 좌/우 번갈아 분배 (짝수 인덱스=왼쪽, 홀수 인덱스=오른쪽)
```

### 9.3 Square 배너 배치 규칙

```
1. wing 배너 중 현재 카테고리 매칭 배너를 앞에 배치
2. square 배너 중 all_page='y' 또는 현재 카테고리 배너를 뒤에 배치
3. 게시판 1페이지에서만 표시
```

### 9.4 Small 배너 배치 규칙

```
all_page='y' 또는 현재 카테고리 배너만 필터링
게시판 1페이지에서만 표시
```

---

## 10. 캐시 시스템

v7에서는 PHP 정적 변수 캐시를 사용한다 (요청 단위 캐시).

```php
private static array $cache = [];

public static function getTopBanners(?string $category = null): array
{
    $cacheKey = "top_" . ($category ?? '__null__');
    if (isset(self::$cache[$cacheKey])) {
        return self::$cache[$cacheKey];
    }
    // ... 조회 로직 ...
    self::$cache[$cacheKey] = $result;
    return $result;
}
```

### 캐시 키 패턴

| 메서드 | 캐시 키 | 예시 |
|--------|---------|------|
| `getTopBanners('qna')` | `top_qna` | `top_qna` |
| `getTopBanners(null)` | `top___null__` | `top___null__` |
| `getWingBanners('freetalk')` | `wing_freetalk` | `wing_freetalk` |
| `getSquareBanners('qna')` | `square_qna` | `square_qna` |
| `getSmallBanners(null)` | `small___null__` | `small___null__` |

### 캐시 초기화 시점

- `addBanner()` 호출 후
- `updateBanner()` 호출 후
- `deleteBanner()` 호출 후
- `resetCache()` 직접 호출 (테스트용)

> **v6과의 차이**: v6은 파일 기반 캐시(30분 TTL)를 사용했지만,
> v7은 요청 단위 정적 변수 캐시를 사용한다.
> SSR 렌더링 시 동일 요청 내에서 중복 쿼리를 방지한다.

---

## 11. 에러 처리

모든 에러는 `RuntimeException`을 throw하며, `api.php`에서 자동으로 JSON 에러 응답을 생성한다.

```json
{
    "success": false,
    "message": "유효하지 않은 배너 타입: invalid (top, wing, square, small 중 하나)"
}
```

### 주요 에러 메시지

| 상황 | 메시지 |
|------|--------|
| 필수 파라미터 누락 | `idx 또는 idx_member가 필요합니다.` |
| 광고 없음 | `광고를 찾을 수 없습니다.` |
| idx 누락 | `idx가 필요합니다.` |
| idx_company 누락 | `idx_company가 필요합니다.` |
| 배너 idx 누락 | `배너 idx가 필요합니다.` |
| 배너 key 누락 | `배너 key가 필요합니다.` |
| 유효하지 않은 타입 | `유효하지 않은 배너 타입: {type} (top, wing, square, small 중 하나)` |
| 카테고리 필수 | `{type} 배너는 category가 필수입니다 (또는 all_page='y').` |
| 중복 배너 | `동일한 위치에 이미 배너가 존재합니다: {key}` |
| 위치 제한 초과 | `{type} 배너는 '{category}' 카테고리에 최대 2개까지 등록 가능합니다.` |
| 배너 없음 | `배너를 찾을 수 없습니다.` |
| 키 변경 중복 | `변경하려는 위치에 이미 배너가 존재합니다: {newKey}` |
| 삭제 실패 | `배너를 찾을 수 없거나 삭제에 실패했습니다.` |
| 권한 없음 | `관리자 권한이 필요합니다.` |
| 생성 미사용 | `광고 생성은 업소 등록(company.create) 후 advertisement.update로 설정합니다.` |
| 삭제 미사용 | `광고 삭제는 배너를 모두 삭제하고 ad_begin_date를 0으로 설정합니다.` |

---

## 12. PEST 테스트

**파일**: `tests/Unit/AdvertisementTest.php`
**실행**: `./vendor/bin/pest tests/Unit/AdvertisementTest.php`
**결과**: 33개 테스트, 91개 assertion

### 12.1 테스트 헬퍼

```php
function createTestAdvertisement(int $idxMember, array $overrides = []): int
```

- 테스트용 company 레코드 생성 (idx_member=99901~99910 범위 사용)
- `location` 필드를 `'test'`로 설정 (INSERT 시 필수 컬럼)
- 기존 동일 idx_member 레코드 자동 정리 후 생성

```php
function cleanupTestAdvertisement(int $idxMember): void
```

- 해당 idx_member의 company + company_meta(배너) 일괄 삭제

### 12.2 테스트 그룹

| 그룹 | 테스트 수 | 주요 테스트 내용 |
|------|-----------|-----------------|
| **BannerEntity** | 8개 | fromArray/toArray 변환, resolveClickUrl 4가지 패턴, resolveTarget 2가지 패턴 |
| **AdvertisementRepository** | 7개 | findByIdx, findByIdxMember, updateAdFields, addBanner, updateBanner, deleteBanner, countActiveBannersAtLocation |
| **AdvertisementService** | 10개 | get (성공/에러), update, addBanner 타입 검증, getRemainingDays (미래/과거/오늘/빈값), getTopBanners/getWingBanners/getSquareBanners/getSmallBanners 반환 구조 |
| **AdvertisementController** | 8개 | topBanners/wingBanners/squareBanners/smallBanners 반환 구조, create/delete 예외, list 권한 검증 |

### 12.3 테스트 라이프사이클

```php
beforeAll(function () {
    // ROOT_DIR 정의, autoload, 99901~99910 잔여 데이터 정리
});

afterAll(function () {
    // 99901~99910 데이터 정리, AuthService::reset(), AdvertisementService::resetCache()
});

// AdvertisementService describe 내부
beforeEach(function () {
    AdvertisementService::resetCache(); // 각 테스트 전 캐시 초기화
});
```
