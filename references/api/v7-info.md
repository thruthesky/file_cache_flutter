# v7 Info 시스템 — sf_post_data 기반

> **✅ 구현 완료** — sf_post_data 단일 테이블 기반 info 시스템

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [핵심 아키텍처](#3-핵심-아키텍처)
4. [필드 매핑](#4-필드-매핑)
5. [Entity 클래스](#5-entity-클래스)
6. [InfoService 유틸리티](#6-infoservice-유틸리티)
7. [API 엔드포인트 — info.* 전용 API](#7-api-엔드포인트--info-전용-api)
8. [카테고리/서브카테고리 규약](#8-카테고리서브카테고리-규약)
9. [info 게시글 식별 — group_id = 'info'](#9-info-게시글-식별--group_id--info)
10. [v7 위젯 시스템](#10-v7-위젯-시스템)
11. [Flutter/웹 호출 예시](#11-flutter웹-호출-예시)

---

## 1. 개요

Info 시스템은 여행지, 병원, 경찰, 긴급연락처, 비자, 축제 등 **다양한 카테고리의 정보를 sf_post_data 테이블의 커스텀 필드**를 활용하여 저장·관리하는 시스템임.

**info 게시글의 생성/수정/삭제는 반드시 `info.*` 전용 API를 사용해야 함.** `post.create` API에서는 `group_id=info` 설정이 차단됨.

| 항목 | 설명 |
|------|------|
| **네임스페이스** | `Philgo\Info` |
| **DB 테이블** | `sf_post_data` (기존 게시판과 동일 테이블) |
| **식별** | `group_id = 'info'` |
| **API** | `info.*` 전용 API (InfoController) — **post.create에서 group_id=info 차단됨** |
| **확장** | `text_1`(texts JSON), `text_2`(extra_data JSON) 커스텀 필드 |
| **게시판 기능** | 댓글, 좋아요, 포인트, 검색, 알림, 블라인드, 신고 100% 자동 지원 |

### 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **테이블 1개** | sf_post_data 테이블의 커스텀 필드 활용 |
| **게시판 기능 100%** | 댓글, 좋아요, 포인트, 검색, 알림, 블라인드, 신고 자동 |
| **Entity 래핑** | varchar_1 → english_name 등 의미 있는 이름으로 접근 |
| **info.* 전용 API** | info.create, info.update, info.delete, info.list, info.get, info.categories, info.meta |
| **group_id=info 보호** | post.create API에서 group_id=info 직접 설정 불가 (info.create만 허용) |

---

## 2. 파일 구조

```
lib/info/
├── InfoController.php   # info.* API 엔드포인트 (list, get, categories, meta, create, update, delete)
├── InfoPostEntity.php   # PostEntity 래핑 — sf_post_data 커스텀 필드를 의미 있는 이름으로 매핑
└── InfoService.php      # 비즈니스 로직 — create, update, delete, list, get, 카테고리 메타

v7/widgets/info/
├── info-view.php        # 통합 info 글 읽기 위젯 (카테고리별 디자인 분기)
├── info-meta-card.php   # 공통 메타 카드 (위치/연락처/운영시간/지도)
└── info-view.css        # info 위젯 CSS

data/info/
└── info-meta.json       # 카테고리 체계, post_link 매핑, 필드 규칙
```

---

## 3. 핵심 아키텍처

```
sf_post_data ────── 유일한 데이터 저장소
PostEntity ──────── DB 행의 원본 표현
InfoPostEntity ──── PostEntity 래핑 (공통 info 필드 매핑)
InfoController ──── info.* API 엔드포인트 (관리자 CRUD + 공개 조회)
InfoService ─────── 비즈니스 로직
```

### info 게시글의 데이터 흐름

```
[생성] info.create API → InfoController → InfoService::create() → PostRepository → sf_post_data
       (group_id='info' 자동 설정, post_id/category는 카테고리 메타에서 자동 매핑)
       ⚠️ post.create API에서는 group_id=info 차단됨 → RuntimeException 발생

[수정] info.update API → InfoController → InfoService::update() → PostRepository → sf_post_data
       (관리자 인증 필수)

[삭제] info.delete API → InfoController → InfoService::delete() → 논리 삭제 (deleted=1)
       (관리자 인증 필수)

[조회] info.get API → InfoController → InfoService::get() → InfoPostEntity
       (인증 불필요)

[목록] info.list API → InfoController → InfoService::list() → InfoPostEntity[]
       (인증 불필요, 카테고리/지역/도시/월 필터 지원)

[통계] info.categories API → InfoController → InfoService::getDistinctPostCategories()
       (인증 불필요, DB 실시간 집계)

[메타] info.meta API → InfoController → InfoService::getAllCategories()
       (인증 불필요, 하드코딩된 카테고리 메타 정보)
```

---

## 4. 필드 매핑

### 기존 컬럼 활용

| sf_post_data 컬럼 | info 의미 | 설명 |
|-------------------|----------|------|
| `subject` | name | 이름 (한글) |
| `content` | content | 본문 (마크다운) |
| `group_id` | `'info'` (고정) | info 게시글 식별자 |
| `post_id` | 게시판 ID | info-meta.json의 post_link.post_id |
| `category` | 게시판 카테고리 | info-meta.json의 post_link.category |
| `sub_category` | info 서브카테고리 | beach, hospital, embassy 등 |
| `region` | 지역 | 비사야, 루손 등 |
| `link` | website_url | 웹사이트 URL |

### varchar 커스텀 필드

| 필드 | info 의미 | 비고 |
|------|----------|------|
| `varchar_1` | english_name | 영문 이름 |
| `varchar_2` | title | 한 줄 소개 |
| `varchar_3` | icon | 개별 이모지 아이콘 |
| `varchar_4` | category_icon | 카테고리 이모지 |
| `varchar_5` | subcategory_icon | 서브카테고리 이모지 |
| `varchar_6` | city | 도시 |
| `varchar_7` | province | 주/도 |
| `varchar_8` | address | 상세 주소 |
| `varchar_9` | phone | 전화번호 |
| `varchar_13` | phone2 | 보조 전화번호 |
| `varchar_14` | email | 이메일 |
| `varchar_16` | hours | 운영시간 |
| `varchar_17` | image_url | 대표 이미지 URL |
| `varchar_18` | fee | 이용료/입장료 |
| `varchar_19` | event_date | 이벤트 날짜 |
| `varchar_20` | tags | 태그 (쉼표 구분) |

> **varchar_10~12**: 썸네일 (모든 게시글 공통 — 수정 금지)

### int 커스텀 필드

| 필드 | info 의미 | 비고 |
|------|----------|------|
| `int_1` | sort_order | 정렬 순서 (작을수록 먼저) |
| `int_2` | month | 축제 월 (1~12) |
| `int_3` | latitude x 10^7 | 위도 (예: 10.3157 → 103157000) |
| `int_4` | longitude x 10^7 | 경도 (예: 123.8854 → 1238854000) |

> **int_5~10**: 광고/포인트/차단 시스템 (모든 게시글 공통 — 수정 금지)

### text 커스텀 필드

| 필드 | info 의미 | 비고 |
|------|----------|------|
| `text_1` | texts | JSON 마크다운 섹션 배열 |
| `text_2` | extra_data | JSON 카테고리별 추가 데이터 |
| `text_3` | description | 요약 설명 (2~3문장) |

### char 커스텀 필드

| 필드 | info 의미 | 값 | 비고 |
|------|----------|---|------|
| `char_1` | info_status | Y/N/D | 정보 상태 |
| `char_2` | has_map | Y/'' | 지도 정보 보유 |
| `char_3` | has_texts | Y/'' | texts 섹션 보유 |
| `char_4` | verified | Y/'' | 정보 검증 완료 |

---

## 5. Entity 클래스

### InfoPostEntity (`lib/info/InfoPostEntity.php`)

PostEntity를 래핑하여 커스텀 필드를 의미 있는 이름으로 매핑함.

```php
use Philgo\Info\InfoPostEntity;

// PostEntity → InfoPostEntity 변환
$infoPost = InfoPostEntity::fromPost($post);
echo $infoPost->name;          // = $post->subject
echo $infoPost->english_name;  // = $post->varchar_1
echo $infoPost->city;          // = $post->varchar_6
echo $infoPost->latitude;      // = $post->int_3 / 10^7

// InfoPostEntity → PostRepository::create()용 배열
$postData = $infoPost->toPostData();

// InfoPostEntity → API 응답용 배열
$apiData = $infoPost->toArray();
```

### PostEntity::isInfoPost()

```php
// info 게시글 여부 확인
if ($post->isInfoPost()) {
    $infoPost = InfoPostEntity::fromPost($post);
    // info 전용 렌더링
}
```

---

## 6. InfoService 유틸리티

InfoService는 InfoController를 통해 API로 노출됨.

```php
use Philgo\Info\InfoService;

// 생성 (카테고리 메타에서 post_id/category 자동 매핑, group_id='info' 자동 설정)
$info = InfoService::create([
    'category' => 'travel',
    'name' => '보라카이 화이트 비치',
    'english_name' => 'White Beach',
    'city' => '말레이',
    'province' => '아클란',
    'region' => '비사야',
    'latitude' => 11.9612,
    'longitude' => 121.956,
    'texts' => ['## 소개\n...', '## 방문 정보\n...'],
    'idx_member' => 186619,
]);

// 수정
$info = InfoService::update(['idx' => 123, 'title' => '업데이트']);

// 삭제 (논리 삭제)
InfoService::delete(['idx' => 123]);

// 조회
$info = InfoService::get(123);

// 목록 (필터 지원)
$result = InfoService::list(['category' => 'travel', 'city' => '세부']);
```

---

## 7. API 엔드포인트 — info.* 전용 API

### 🔴 핵심 규칙: post.create API에서 group_id=info 차단

> **⛔ `post.create` API에서 `group_id=info`를 직접 설정하면 RuntimeException이 발생한다.**
> **info 게시글을 생성하려면 반드시 `info.create` API를 사용해야 한다.**
> **일반 사용자/앱에서 group_id=info를 직접 설정하는 것은 불가능하다.**

```php
// PostService에서의 차단 로직 (lib/post/PostService.php)
if ($key === 'group_id' && $input[$key] === 'info') {
    throw new \RuntimeException('group_id=info는 post.create API로 설정할 수 없습니다. info.create API를 사용하세요.');
}
```

### API 엔드포인트 목록

| API | 메서드 | 인증 | 설명 |
|-----|--------|------|------|
| `info.list` | GET/POST | 불필요 | info 게시글 목록 (카테고리/지역/도시/월 필터) |
| `info.get` | GET/POST | 불필요 | info 게시글 단건 조회 |
| `info.categories` | GET/POST | 불필요 | DB 실시간 post_id+category+sub_category 분포 통계 |
| `info.meta` | GET/POST | 불필요 | 하드코딩된 카테고리 메타 정보 (전체 또는 특정) |
| `info.create` | POST | **관리자 전용** | info 게시글 생성 (group_id=info 자동 설정) |
| `info.update` | POST | **관리자 전용** | info 게시글 수정 |
| `info.delete` | POST | **관리자 전용** | info 게시글 삭제 (논리 삭제) |

### info.create — info 게시글 생성 (관리자 전용)

`group_id=info`가 자동으로 설정되며, `category` 파라미터에서 `post_id`와 `category`(게시판 카테고리)가 자동 매핑됨.

```bash
curl -sk -X POST 'https://v7-local.philgo.com/api.php' \
  --data-urlencode 'method=info.create' \
  --data-urlencode 'session_id_v7=관리자세션ID' \
  --data-urlencode 'category=travel' \
  --data-urlencode 'subcategory=beach' \
  --data-urlencode 'name=보라카이 화이트 비치' \
  --data-urlencode 'english_name=White Beach, Boracay' \
  --data-urlencode 'title=세계에서 가장 아름다운 해변' \
  --data-urlencode 'content=## 소개...' \
  --data-urlencode 'city=말레이' \
  --data-urlencode 'province=아클란' \
  --data-urlencode 'region=비사야' \
  --data-urlencode 'latitude=11.9612' \
  --data-urlencode 'longitude=121.956' \
  --data-urlencode 'description=요약 설명...' \
  --data-urlencode 'info_status=Y'
```

**주요 파라미터:**

| 파라미터 | 필수 | 설명 |
|---------|------|------|
| `category` | ✅ | info 카테고리 코드 (travel, hospital, emergency 등) |
| `name` | ✅ | 이름 (한글) — subject 컬럼에 저장 |
| `english_name` | | 영문 이름 — varchar_1에 저장 |
| `title` | | 한 줄 소개 — varchar_2에 저장 |
| `content` | | 본문 (마크다운) |
| `subcategory` | | 서브카테고리 코드 (beach, hospital 등) |
| `city` | | 도시 |
| `province` | | 주/도 |
| `region` | | 지역 |
| `latitude` | | 위도 (소수점) |
| `longitude` | | 경도 (소수점) |
| `phone` | | 전화번호 |
| `email` | | 이메일 |
| `website_url` | | 웹사이트 URL |
| `hours` | | 운영시간 |
| `fee` | | 이용료/입장료 |
| `tags` | | 태그 (쉼표 구분) |
| `image_url` | | 대표 이미지 URL |
| `texts` | | JSON 마크다운 섹션 배열 |
| `description` | | 요약 설명 |
| `info_status` | | Y/N/D |
| `sort_order` | | 정렬 순서 (작을수록 먼저) |

### info.update — info 게시글 수정 (관리자 전용)

```bash
curl -sk -X POST 'https://v7-local.philgo.com/api.php' \
  --data-urlencode 'method=info.update' \
  --data-urlencode 'session_id_v7=관리자세션ID' \
  --data-urlencode 'idx=12345' \
  --data-urlencode 'title=업데이트된 소개'
```

### info.delete — info 게시글 삭제 (관리자 전용)

```bash
curl -sk -X POST 'https://v7-local.philgo.com/api.php' \
  --data-urlencode 'method=info.delete' \
  --data-urlencode 'session_id_v7=관리자세션ID' \
  --data-urlencode 'idx=12345'
```

### info.list — info 게시글 목록 (인증 불필요)

```bash
# 전체 info 목록
curl -sk 'https://v7-local.philgo.com/api.php?method=info.list'

# 카테고리 필터
curl -sk 'https://v7-local.philgo.com/api.php?method=info.list&category=travel'

# 카테고리 + 도시 필터
curl -sk 'https://v7-local.philgo.com/api.php?method=info.list&category=hospital&city=세부'

# post_id 필터
curl -sk 'https://v7-local.philgo.com/api.php?method=info.list&post_id=travel&limit=10'

# 월 필터 (축제)
curl -sk 'https://v7-local.philgo.com/api.php?method=info.list&month=1'
```

**응답 형식:**

```json
{
  "success": true,
  "items": [...],
  "total": 42
}
```

### info.get — info 게시글 단건 조회 (인증 불필요)

```bash
curl -sk 'https://v7-local.philgo.com/api.php?method=info.get&idx=12345'
```

### info.categories — DB 실시간 통계 (인증 불필요)

```bash
curl -sk 'https://v7-local.philgo.com/api.php?method=info.categories'
```

**응답 형식:**

```json
{
  "success": true,
  "categories": [
    {
      "post_id": "travel",
      "category": "여행",
      "sub_category": "travel",
      "count": 15,
      "info_category": "travel",
      "info_icon": "🧳",
      "info_name": "여행지"
    }
  ],
  "total": 42
}
```

### info.meta — 카테고리 메타 정보 (인증 불필요)

```bash
# 전체 카테고리 메타 정보
curl -sk 'https://v7-local.philgo.com/api.php?method=info.meta'

# 특정 카테고리 메타 정보
curl -sk 'https://v7-local.philgo.com/api.php?method=info.meta&category=travel'
```

---

## 8. 카테고리/서브카테고리 규약

| info 카테고리 | post_id | category | 비고 |
|--------------|---------|----------|------|
| travel | `travel` | `여행` | 여행지 |
| festival | `travel` | `여행` | 축제 |
| hospital | `freetalk` | `info` | 병원 |
| police | `freetalk` | `info` | 경찰 |
| emergency | `freetalk` | `info` | 긴급연락처 |
| visa | `freetalk` | `info` | 비자 |
| living | `freetalk` | `생활의팁` | 생활정보 |
| food | `freetalk` | `먹방` | 맛집/식당 |
| accommodation | — | — | 숙소 |

> info.create API 호출 시, `category` 파라미터만 지정하면 `post_id`와 게시판 `category`가 InfoService에서 자동 매핑됨.
> 매핑 정보는 InfoService::CATEGORIES 상수에 하드코딩되어 있음.

---

## 9. info 게시글 식별 — group_id = 'info'

```php
// PHP — info 게시글 여부 확인
$post->isInfoPost();  // group_id === 'info'

// JavaScript
const isInfoPost = (post) => post.group_id === 'info';
```

### group_id=info 설정 규칙

| 방법 | 허용 여부 | 설명 |
|------|----------|------|
| `info.create` API | ✅ 허용 | group_id=info 자동 설정 (관리자 전용) |
| `post.create` API + `group_id=info` | ❌ **차단됨** | RuntimeException 발생 |
| 직접 SQL | ❌ 금지 | API를 통해서만 생성 |

### 동작 방식

1. **게시글 목록**: PostService::list()는 변경 없이 info 글도 자동 포함
2. **게시글 상세**: view.php에서 isInfoPost() → info 위젯 렌더링
3. **댓글/좋아요**: info/일반 게시글 동일하게 적용

---

## 10. v7 위젯 시스템

### view.php에서 info 분기

```php
if ($post->isInfoPost()) {
    $infoPost = InfoPostEntity::fromPost($post);
    include __DIR__ . '/../widgets/info/info-view.php';
}
```

### 카테고리별 특수 UI

| 카테고리 | 특수 UI | 파일 |
|---------|---------|------|
| emergency, police | 긴급연락처 카드 (빨간 배경) | info-view.php 내부 |
| hospital | 병원 카드 (진료과목, 한국어, 24시간) | info-view.php 내부 |
| festival | 축제 카드 (월, 기간, 하이라이트) | info-view.php 내부 |
| 공통 | 메타 카드 (위치, 연락처, 지도) | info-meta-card.php |

### post-list-tile.php에서 info 표시

```php
$_isInfoPost = ($post['group_id'] ?? '') === 'info';
$_infoCategoryIcon = $_isInfoPost ? ($post['varchar_4'] ?? '') : '';
// title(varchar_2) 우선, 없으면 name(subject) 표시
```

---

## 11. Flutter/웹 호출 예시

### Flutter 앱

```dart
// info 게시글 생성 (관리자 전용 — info.create API 필수 사용)
final result = await v7api('info.create', {
  'category': 'travel',
  'subcategory': 'beach',
  'name': '보라카이 화이트 비치',
  'english_name': 'White Beach, Boracay',
  'city': '말레이',
  'region': '비사야',
  'latitude': 11.9612,
  'longitude': 121.956,
  'description': '요약 설명...',
  'info_status': 'Y',
});

// info 목록 조회 (인증 불필요)
final list = await v7api('info.list', {
  'category': 'travel',
  'limit': 20,
});

// info 단건 조회 (인증 불필요)
final info = await v7api('info.get', {'idx': 12345});

// info 카테고리 통계 (인증 불필요)
final stats = await v7api('info.categories', {});

// info 메타 정보 (인증 불필요)
final meta = await v7api('info.meta', {});
```

### JavaScript (v7 웹)

```javascript
// info 게시글 생성 (관리자 전용 — info.create API 필수 사용)
const result = await v7api('info.create', {
  category: 'travel',
  subcategory: 'beach',
  name: '보라카이 화이트 비치',
  english_name: 'White Beach, Boracay',
  city: '말레이',
  region: '비사야',
  latitude: 11.9612,
  longitude: 121.956,
  description: '요약 설명...',
  info_status: 'Y',
});

// info 목록 조회 (인증 불필요)
const list = await v7api('info.list', {
  category: 'travel',
  limit: 20,
});

// info 단건 조회 (인증 불필요)
const info = await v7api('info.get', { idx: 12345 });

// info 수정 (관리자 전용)
const updated = await v7api('info.update', {
  idx: 12345,
  title: '업데이트된 소개',
});

// info 삭제 (관리자 전용)
const deleted = await v7api('info.delete', { idx: 12345 });
```

### 잘못된 사용법 (절대 금지)

```dart
// ❌ 절대 금지: post.create API로 group_id=info 설정 시도
final result = await v7api('post.create', {
  'post_id': 'travel',
  'category': '여행',
  'group_id': 'info',    // ❌ RuntimeException 발생!
  'subject': '보라카이',
});
```

```javascript
// ❌ 절대 금지: post.create API로 group_id=info 설정 시도
const result = await v7api('post.create', {
  post_id: 'travel',
  category: '여행',
  group_id: 'info',      // ❌ RuntimeException 발생!
  subject: '보라카이',
});
```
