# v7 Info access_code 기반 콘텐츠 관리 시스템

> **구현 완료** — access_code(UNIQUE KEY)를 활용한 info 콘텐츠 식별, 동기화, 웹/앱 공유 시스템
>
> **정보 콘텐츠의 마크다운 작성/품질/그룹별 구조는 `philgo-content` 스킬(`.custom-skills/philgo-content/SKILL.md`)을 참조한다.**

## 목차

1. [개요 및 설계 의도](#1-개요-및-설계-의도)
2. [access_code 스키마](#2-access_code-스키마)
3. [access_code 명명 규칙](#3-access_code-명명-규칙)
4. [데이터 저장 전략 — content 마크다운 중심](#4-데이터-저장-전략--content-마크다운-중심)
5. [PostEntity / InfoPostEntity access_code 매핑](#5-postentity--infopostentity-access_code-매핑)
6. [InfoService — access_code 기반 메서드](#6-infoservice--access_code-기반-메서드)
7. [InfoController — API 엔드포인트](#7-infocontroller--api-엔드포인트)
8. [웹/앱 access_code 공유 (레지스트리)](#8-웹앱-access_code-공유-레지스트리)
9. [동기화 스크립트 (export/import)](#9-동기화-스크립트-exportimport)
10. [PEST 유닛 테스트](#10-pest-유닛-테스트)
11. [curl 테스트 예시](#11-curl-테스트-예시)

---

## 1. 개요 및 설계 의도

### 문제

로컬 개발 환경에서 info 콘텐츠(대사관, 한인회, 경찰서, 병원 등)를 생성하면
`sf_post_data.idx`가 로컬 DB의 AUTO_INCREMENT 값으로 결정된다.
이 idx는 프로덕션 DB와 다르므로, 로컬에서 만든 데이터를 프로덕션으로 옮길 때
"어떤 글이 어떤 정보인지" 식별할 수 없다.

### 해결

`sf_post_data.access_code`(UNIQUE KEY, varchar(255), DEFAULT NULL)를
info 콘텐츠의 **고유 식별자**로 활용한다.
idx가 달라도 access_code가 동일하면 같은 콘텐츠로 인식하여 UPSERT가 가능하다.

```
로컬 DB: idx=50123, access_code='info:contact:cebu:police'
프로덕션 DB: idx=89001, access_code='info:contact:cebu:police'
→ access_code가 같으므로 동일 콘텐츠 → UPSERT 가능
```

### 전체 아키텍처

```
[AI/관리자 — 로컬 개발]
    │
    ├── info.create / info.upsertByAccessCode API 호출
    │   (access_code 포함, content에 마크다운)
    │
    ├── scripts/info-sync-export.php → JSON 내보내기
    │
    ├── scp → 프로덕션 전송
    │
    └── scripts/info-sync-import.php → 프로덕션 UPSERT
            (access_code 기준 INSERT 또는 UPDATE)

[웹 (PHP)]
    └── info.getByAccessCode / info.registry API
        → access_code로 콘텐츠 조회, 메뉴 자동 생성

[앱 (Flutter)]
    └── v7api('info.getByAccessCode', { access_code: '...' })
        → 동일한 access_code로 동일한 데이터 조회
```

---

## 2. access_code 스키마

### 현재 DB 스키마 (변경 불필요)

```sql
-- sf_post_data 테이블
`access_code` varchar(255) DEFAULT NULL

-- 인덱스
ADD UNIQUE KEY `access_code` (`access_code`)
```

| 항목 | 값 |
|------|-----|
| **타입** | `varchar(255)` |
| **기본값** | `NULL` |
| **인덱스** | `UNIQUE KEY` — 동일 access_code 중복 삽입 자동 방지 |
| **NULL 허용** | MySQL/MariaDB에서 NULL은 UNIQUE 제약에서 중복 제외됨 |

> 일반 게시글(access_code=NULL)은 UNIQUE 제약에 영향받지 않음.
> info 콘텐츠에만 고유한 access_code를 부여하여 식별함.

---

## 3. access_code 명명 규칙

### 형식

콜론(`:`)으로 세그먼트를 구분. 세그먼트 수는 자유 확장 가능.

```
info:<모듈>:<세부코드>              ← 3단 (전국/전체)
info:<모듈>:<지역>:<세부코드>        ← 4단 (지역별)
info:<모듈>:<지역>:<하위분류>:<세부코드> ← 5단 (세분화)
```

| 세그먼트 | 필수 | 설명 | 예시 |
|---------|------|------|------|
| `info` | 필수 | 접두사 | 고정값 |
| `<모듈>` | 필수 | 기능 영역 | `contact`, `visa`, `living`, `travel` |
| `<지역>` | 선택 | 도시/지역 | `cebu`, `manila`, `palawan` |
| `<하위분류>` | 선택 | 세부 분류 | `hospital`, `beach` |
| `<세부코드>` | 필수 | 개별 식별자 | `police`, `embassy`, `ocean-park` |

### 예시

| 패턴 | access_code | 설명 |
|------|-------------|------|
| 3단 | `info:contact:embassy` | 필리핀 전체 대사관 목록 |
| 3단 | `info:visa:overview` | 비자 종류 총정리 |
| 4단 | `info:contact:cebu:police` | 세부 경찰서 목록 |
| 4단 | `info:contact:manila:hospital` | 마닐라 병원 목록 |
| 4단 | `info:travel:cebu:ocean-park` | 세부 오션 파크 |
| 5단 | `info:contact:cebu:hospital:korean` | 세부 한국인 병원 |
| 5단 | `info:travel:cebu:beach:moalboal` | 세부 모알보알 해변 |

### LIKE 쿼리 계층 조회

```sql
-- 세부 지역의 모든 연락처
WHERE access_code LIKE 'info:contact:cebu:%'

-- 모든 여행지
WHERE access_code LIKE 'info:travel:%'

-- 세부 해변 전체
WHERE access_code LIKE 'info:travel:cebu:beach:%'
```

### 명명 규칙

| 규칙 | 설명 |
|------|------|
| 소문자 영문만 | 한글/특수문자 금지 |
| 세그먼트 구분 | 콜론(`:`) |
| 단어 구분 | 하이픈(`-`) (예: `ocean-park`) |
| 고유성 | UNIQUE KEY — 시스템 전체에서 1개만 존재 |
| 변경 금지 | 한 번 부여한 access_code는 절대 변경하지 않음 |

---

## 4. 데이터 저장 전략 — content 마크다운 중심

### content가 유일한 메인 콘텐츠

| 필드 | 역할 | 저장 내용 |
|------|------|----------|
| **content** | **메인 콘텐츠** — 웹/앱 모두에서 렌더링 | 마크다운 본문 |
| **여유 필드** (varchar_8~20 등) | 메타데이터 | 전화, 주소, 운영시간, 좌표 (상단 메타 카드로 표시) |
| **text_2** | 메타데이터 JSON | 카테고리별 추가 속성 |
| **text_3** | 요약 설명 | 2~3문장 description |

> **text_1은 더 이상 사용하지 않는다.** 모든 콘텐츠는 content 마크다운에 작성한다.

---

## 5. PostEntity / InfoPostEntity access_code 매핑

### PostEntity (소스: `lib/post/PostEntity.php`)

```php
// 프로퍼티 선언
public string $access_code = '';   // 107행 근처

// fromArray() 매핑
$entity->access_code = (string)($data['access_code'] ?? '');  // 241행 근처

// toArray() 포함
'access_code' => $this->access_code,  // 355행 근처
```

### InfoPostEntity (소스: `lib/info/InfoPostEntity.php`)

```php
// 프로퍼티 선언
public string $access_code = '';   // post->access_code (동기화용) — 77행

// fromPost() 매핑
$entity->access_code = $post->access_code;  // 147행

// toPostData() — 빈 값이면 제외 (NULL 유지)
if (!empty($this->access_code)) {
    $data['access_code'] = $this->access_code;
}
// 199행 근처

// toArray() 포함
'access_code' => $this->access_code,  // 256행 근처
```

### PostRepository (소스: `lib/post/PostRepository.php`)

```php
// create() $defaults에 access_code 포함
$defaults = [
    // ...기존 필드...
    'access_code' => null,   // 95행 근처 — NULL 기본값
    'ip' => '',
];
```

### fillFromInput() — 입력 필드 매핑

> **text_1/texts 관련 코드는 하위 호환용으로 소스에 남아있으나, 새 데이터 생성 시에는 사용하지 않는다.**
> **모든 콘텐츠는 `content` 필드에 마크다운으로 전달한다.**

// access_code
if (isset($input['access_code'])) $entity->access_code = (string)$input['access_code'];
```

---

## 6. InfoService — access_code 기반 메서드

### 소스 파일: `lib/info/InfoService.php`

### 6.1 getByAccessCode()

```php
/**
 * access_code로 info 게시글을 조회한다.
 */
public static function getByAccessCode(string $accessCode): ?InfoPostEntity
{
    $row = Db::fetch(
        "SELECT p.*, m.photo_url as user_photo_url, m.nickname as user_nickname,
                m.firebase_uid as user_firebase_uid
         FROM sf_post_data p
         LEFT JOIN sf_member m ON p.idx_member = m.idx
         WHERE p.access_code = ? AND p.group_id = 'info' AND p.deleted = 0
         LIMIT 1",
        [$accessCode]
    );
    if ($row === false) {
        return null;
    }
    return InfoPostEntity::fromPost(PostEntity::fromArray($row));
}
```

### 6.2 upsertByAccessCode()

```php
/**
 * access_code 기준 UPSERT (생성 또는 수정).
 * access_code가 존재하면 UPDATE, 없으면 INSERT.
 * 동기화 전용 — 관리자만 사용.
 */
public static function upsertByAccessCode(array $input): InfoPostEntity
{
    $accessCode = (string)($input['access_code'] ?? '');
    if (empty($accessCode)) {
        throw new RuntimeException('access_code는 필수입니다');
    }

    $existing = self::getByAccessCode($accessCode);
    if ($existing !== null) {
        $input['idx'] = $existing->idx;  // 기존 글 idx로 수정
        return self::update($input);
    } else {
        return self::create($input);     // 새 글 생성
    }
}
```

### 6.3 listByAccessCodePrefix()

```php
/**
 * access_code 접두사로 info 게시글 목록 조회.
 * LIKE 쿼리로 계층적 조회 가능.
 *
 * 예: 'info:contact:cebu' → info:contact:cebu:police, info:contact:cebu:hospital 등
 */
public static function listByAccessCodePrefix(string $prefix): array
{
    $rows = Db::fetchAll(
        "SELECT p.*, m.photo_url as user_photo_url, m.nickname as user_nickname,
                m.firebase_uid as user_firebase_uid
         FROM sf_post_data p
         LEFT JOIN sf_member m ON p.idx_member = m.idx
         WHERE p.access_code LIKE ? AND p.group_id = 'info' AND p.deleted = 0
         ORDER BY p.int_1 ASC, p.stamp DESC",
        [$prefix . ':%']
    );

    $items = [];
    foreach ($rows as $row) {
        $post = PostEntity::fromArray($row);
        $items[] = InfoPostEntity::fromPost($post);
    }
    return $items;
}
```

### 6.4 getRegistry()

```php
/**
 * DB에서 access_code가 설정된 모든 info 게시글의 레지스트리 반환.
 * 웹/앱에서 동일한 access_code 목록을 공유하기 위한 Single Source of Truth.
 *
 * module 필터: access_code 접두사 LIKE 쿼리.
 * region 필터: sf_post_data.region 컬럼으로 SQL WHERE 조건.
 */
public static function getRegistry(string $module = '', string $region = ''): array
{
    $where = ["p.group_id = 'info'", "p.deleted = 0", "p.depth = 0",
              "p.access_code IS NOT NULL", "p.access_code != ''"];
    $params = [];

    // 모듈 필터 (access_code 접두사)
    if (!empty($module)) {
        $where[] = "p.access_code LIKE ?";
        $params[] = "info:{$module}:%";
    }

    // 지역 필터 (sf_post_data.region 컬럼 사용)
    if (!empty($region)) {
        $where[] = "p.region = ?";
        $params[] = $region;
    }

    $whereClause = implode(' AND ', $where);
    $rows = Db::fetchAll(
        "SELECT p.access_code, p.subject, p.varchar_3 as icon, p.text_3 as description,
                p.sub_category, p.varchar_6 as city, p.region, p.post_id, p.category
         FROM sf_post_data p
         WHERE {$whereClause}
         ORDER BY p.access_code",
        $params
    );

    $registry = [];
    foreach ($rows as $row) {
        $code = (string)$row['access_code'];

        // access_code에서 모듈 추출 (info:<모듈>:...)
        $segments = explode(':', $code);
        $rowModule = $segments[1] ?? '';

        $registry[$code] = [
            'name' => (string)$row['subject'],
            'icon' => (string)$row['icon'],
            'description' => (string)$row['description'],
            'module' => $rowModule,
            'region' => (string)$row['region'],
            'city' => (string)$row['city'],
            'post_id' => (string)$row['post_id'],
            'category' => (string)$row['category'],
        ];
    }
    return $registry;
}
```

---

## 7. InfoController — API 엔드포인트

### 소스 파일: `lib/info/InfoController.php`

### 7.1 info.getByAccessCode (인증 불필요)

```php
/**
 * GET: /api.php?method=info.getByAccessCode&access_code=info:contact:cebu:police
 */
public function getByAccessCode(array $input): array
{
    $accessCode = (string)($input['access_code'] ?? '');
    if (empty($accessCode)) {
        throw new RuntimeException('access_code는 필수입니다');
    }
    $info = InfoService::getByAccessCode($accessCode);
    if ($info === null) {
        throw new RuntimeException("access_code에 해당하는 info 게시글을 찾을 수 없습니다");
    }
    return $info->toArray();
}
```

### 7.2 info.upsertByAccessCode (관리자 전용)

```php
/**
 * POST: /api.php  method=info.upsertByAccessCode
 * access_code 기준 INSERT/UPDATE. 동기화용.
 */
public function upsertByAccessCode(array $input): array
{
    $this->requireAdmin();
    $input['idx_member'] = $this->getAuthenticatedMemberIdx();
    $info = InfoService::upsertByAccessCode($input);
    return $info->toArray();
}
```

### 7.3 info.registry (인증 불필요)

```php
/**
 * GET: /api.php?method=info.registry
 * GET: /api.php?method=info.registry&module=contact
 * GET: /api.php?method=info.registry&region=cebu
 */
public function registry(array $input): array
{
    $module = (string)($input['module'] ?? '');
    $region = (string)($input['region'] ?? '');
    return InfoService::getRegistry($module, $region);
}
```

### 7.4 info.listByPrefix (인증 불필요)

```php
/**
 * GET: /api.php?method=info.listByPrefix&prefix=info:contact:cebu
 */
public function listByPrefix(array $input): array
{
    $prefix = (string)($input['prefix'] ?? '');
    if (empty($prefix)) {
        throw new RuntimeException('prefix는 필수입니다');
    }
    $items = InfoService::listByAccessCodePrefix($prefix);
    return [
        'items' => array_map(fn(InfoPostEntity $item) => $item->toArray(), $items),
    ];
}
```

### API 엔드포인트 전체 목록 (기존 + 신규)

| API | 인증 | 설명 |
|-----|------|------|
| `info.list` | 불필요 | info 목록 (카테고리/지역/도시 필터) |
| `info.get` | 불필요 | idx 기준 단건 조회 |
| `info.categories` | 불필요 | DB 실시간 카테고리 분포 |
| `info.meta` | 불필요 | 하드코딩된 카테고리 메타 정보 |
| `info.create` | 관리자 | info 게시글 생성 |
| `info.update` | 관리자 | info 게시글 수정 |
| `info.delete` | 관리자 | info 게시글 삭제 (논리) |
| **`info.getByAccessCode`** | 불필요 | **access_code로 단건 조회** |
| **`info.upsertByAccessCode`** | 관리자 | **access_code 기준 INSERT/UPDATE** |
| **`info.registry`** | 불필요 | **웹/앱 공유 레지스트리** |
| **`info.listByPrefix`** | 불필요 | **접두사로 계층 목록 조회** |

---

## 8. 웹/앱 access_code 공유 (레지스트리)

### 원칙: DB가 Single Source of Truth

access_code 레지스트리를 상수로 하드코딩하지 않고 **DB에서 동적 조회**한다.
access_code가 1만개 이상으로 확장될 수 있으므로 상수 방식은 비현실적.

```
[DB — 유일한 관리 포인트]
    │
    ├── 웹 (PHP 직접 조회)
    │   InfoService::getRegistry() 호출
    │   → 메뉴/링크 자동 생성
    │
    └── 앱 (API 호출)
        v7api('info.registry') 호출
        → 동일한 레지스트리 반환
```

### 웹에서 사용 (PHP)

```php
<?php
use Philgo\Info\InfoService;

// 전체 레지스트리
$registry = InfoService::getRegistry();

// 모듈별 필터
$contacts = InfoService::getRegistry('contact');

// 지역별 필터
$cebuContacts = InfoService::getRegistry('contact', 'cebu');

// access_code로 데이터 로드
$policeInfo = InfoService::getByAccessCode('info:contact:cebu:police');
if ($policeInfo !== null) {
    $content = $policeInfo->content; // 마크다운 본문
}
?>
```

### 앱에서 사용 (Flutter)

```dart
// 레지스트리 조회
final registry = await v7api('info.registry');
final contactRegistry = await v7api('info.registry', {'module': 'contact'});

// access_code로 데이터 조회
final policeData = await v7api('info.getByAccessCode', {
  'access_code': 'info:contact:cebu:police',
});
// policeData['content'] → 마크다운 렌더링

// 특정 지역의 모든 연락처
final allCebuContacts = await v7api('info.listByPrefix', {
  'prefix': 'info:contact:cebu',
});
```

---

## 9. 동기화 스크립트 (export/import)

### 파일 위치

| 파일 | 용도 |
|------|------|
| `scripts/info-sync-export.php` | 로컬 DB → JSON 내보내기 |
| `scripts/info-sync-import.php` | JSON → 프로덕션 DB UPSERT |

### 내보내기

```bash
php scripts/info-sync-export.php --output=tmp/info-sync-export.json
php scripts/info-sync-export.php --output=tmp/info-sync-export.json --prefix=info:contact
```

핵심 로직: `access_code IS NOT NULL AND access_code LIKE 'info:%'`인 글을 추출하여
동기화 대상 필드만 JSON으로 저장.

### 가져오기

```bash
php scripts/info-sync-import.php --input=tmp/info-sync-export.json --dry-run    # 미리보기
php scripts/info-sync-import.php --input=tmp/info-sync-export.json --execute    # 실행
php scripts/info-sync-import.php --input=tmp/info-sync-export.json --verify     # 검증
```

핵심 로직: access_code로 기존 글 조회 → 존재하면 UPDATE(콘텐츠 필드만), 없으면 INSERT.

### 동기화 대상/제외 필드

| 동기화 대상 (덮어쓰기) | 동기화 제외 (프로덕션 값 유지) |
|----------------------|----------------------------|
| subject, content, text_2~3 | idx, idx_member, stamp |
| varchar_1~20, int_1~4 | no_of_comment, no_of_view |
| char_1~4, category, sub_category | good, bad, report, deleted |
| region, link, access_code | |

### 전체 실행 순서

```bash
# 1. 로컬에서 내보내기
php scripts/info-sync-export.php --output=tmp/info-sync-export.json

# 2. 프로덕션 전송
scp tmp/info-sync-export.json root@philgo.net:/var/www/html/tmp/

# 3. 프로덕션에서 가져오기
ssh root@philgo.net
cd /var/www/html
php scripts/info-sync-import.php --input=tmp/info-sync-export.json --dry-run
php scripts/info-sync-import.php --input=tmp/info-sync-export.json --execute
```

---

## 10. PEST 유닛 테스트

### 파일: `tests/Unit/InfoAccessCodeTest.php`

```bash
./vendor/bin/pest tests/Unit/InfoAccessCodeTest.php
```

### 테스트 항목 (8개, 27 assertions)

| 테스트 | 검증 내용 |
|--------|----------|
| info.create로 access_code 포함 게시글 생성 | access_code 저장, 필드 매핑 |
| getByAccessCode로 조회 | access_code 기준 단건 조회 |
| getByAccessCode — 존재하지 않는 코드 | null 반환 |
| upsertByAccessCode — INSERT | 새 access_code → 새 글 생성 |
| upsertByAccessCode — UPDATE | 기존 access_code → 동일 idx 유지, 값 변경 |
| listByAccessCodePrefix | LIKE 쿼리로 접두사 매칭 |
| getRegistry | 레지스트리 조회, 키/값 구조 |
| content 마크다운 저장 및 조회 | 마크다운 본문이 정상적으로 저장/조회되는지 |

---

## 11. curl 테스트 예시

### info.create (access_code + content 마크다운)

```bash
curl -sk -X POST 'https://v7-local.philgo.com/api.php' \
  --data-urlencode 'method=info.create' \
  --data-urlencode 'session_id_v7=090e2895f9280a7d7d6ec11d3f0ce483-186619' \
  --data-urlencode 'category=police' \
  --data-urlencode 'name=세부 경찰서 목록' \
  --data-urlencode 'access_code=info:contact:cebu:police' \
  --data-urlencode 'icon=🚔' \
  --data-urlencode 'description=세부 지역 경찰서 연락처' \
  --data-urlencode 'city=세부' \
  --data-urlencode 'region=비사야' \
  --data-urlencode 'content=## 🚔 세부 경찰서 목록

세부 지역의 경찰서 정보를 안내합니다.

### 🏛️ 세부 시티 경찰서

| 항목 | 정보 |
|------|------|
| 📞 전화 | **032-253-5636** |
| 📍 주소 | Osmena Blvd, Cebu City |
| ⏰ 운영 | 24시간 |'
```

### info.getByAccessCode

```bash
curl -sk 'https://v7-local.philgo.com/api.php?method=info.getByAccessCode&access_code=info:contact:cebu:police'
```

### info.upsertByAccessCode

```bash
curl -sk -X POST 'https://v7-local.philgo.com/api.php' \
  --data-urlencode 'method=info.upsertByAccessCode' \
  --data-urlencode 'session_id_v7=090e2895f9280a7d7d6ec11d3f0ce483-186619' \
  --data-urlencode 'access_code=info:contact:cebu:police' \
  --data-urlencode 'category=police' \
  --data-urlencode 'name=세부 경찰서 목록 (업데이트)' \
  --data-urlencode 'description=UPSERT로 업데이트된 정보'
```

### info.registry

```bash
curl -sk 'https://v7-local.philgo.com/api.php?method=info.registry'
curl -sk 'https://v7-local.philgo.com/api.php?method=info.registry&module=contact'
curl -sk 'https://v7-local.philgo.com/api.php?method=info.registry&region=cebu'
```

### info.listByPrefix

```bash
curl -sk 'https://v7-local.philgo.com/api.php?method=info.listByPrefix&prefix=info:contact:cebu'
```
