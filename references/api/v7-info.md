# v7 Info 시스템 — sf_post_data 기반

> **✅ 구현 완료** — info 테이블 폐기, sf_post_data 단일 테이블 통합

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [핵심 아키텍처](#3-핵심-아키텍처)
4. [필드 매핑](#4-필드-매핑)
5. [Entity 클래스](#5-entity-클래스)
6. [InfoService 유틸리티](#6-infoservice-유틸리티)
7. [API 사용법 — 기존 Post API 활용](#7-api-사용법--기존-post-api-활용)
8. [카테고리/서브카테고리 규약](#8-카테고리서브카테고리-규약)
9. [info 게시글 식별 — group_id = 'info'](#9-info-게시글-식별--group_id--info)
10. [v7 위젯 시스템](#10-v7-위젯-시스템)
11. [Flutter/웹 호출 예시](#11-flutter웹-호출-예시)

---

## 1. 개요

Info 시스템은 여행지, 병원, 경찰, 긴급연락처, 비자, 축제 등 **다양한 카테고리의 정보를 sf_post_data 테이블의 커스텀 필드**를 활용하여 저장·관리하는 시스템임.

**별도의 info 테이블과 info API(info.create, info.update 등)는 폐기됨.**
기존 Post API(post.create, post.update 등)를 그대로 사용하며, `group_id='info'`로 info 게시글을 식별함.

| 항목 | 설명 |
|------|------|
| **네임스페이스** | `Philgo\Info` |
| **DB 테이블** | `sf_post_data` (기존 게시판과 동일 테이블) |
| **식별** | `group_id = 'info'` |
| **API** | 기존 `post.*` API 사용 (별도 info API 없음) |
| **확장** | `text_1`(texts JSON), `text_2`(extra_data JSON) 커스텀 필드 |
| **게시판 기능** | 댓글, 좋아요, 포인트, 검색, 알림, 블라인드, 신고 100% 자동 지원 |

### 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **테이블 1개** | info 전용 테이블 없이 sf_post_data만 사용 |
| **동기화 0** | 별도 테이블이 없으므로 동기화 불필요 |
| **게시판 기능 100%** | 댓글, 좋아요, 포인트, 검색, 알림, 블라인드, 신고 자동 |
| **Entity 래핑** | varchar_1 → english_name 등 의미 있는 이름으로 접근 |
| **기존 API 재활용** | post.create, post.update, post.list, post.get 그대로 사용 |

---

## 2. 파일 구조

```
lib/info/
├── InfoPostEntity.php    # PostEntity 래핑 — sf_post_data 커스텀 필드를 의미 있는 이름으로 매핑
└── InfoService.php       # 내부 유틸리티 — create, update, delete, list, get (API 미노출)

v7/widgets/info/
├── info-view.php         # 통합 info 글 읽기 위젯 (카테고리별 디자인 분기)
├── info-meta-card.php    # 공통 메타 카드 (위치/연락처/운영시간/지도)
└── info-view.css         # info 위젯 CSS

data/info/
└── info-meta.json        # 카테고리 체계, post_link 매핑, 필드 규칙
```

---

## 3. 핵심 아키텍처

```
sf_post_data ────── 유일한 데이터 저장소
PostEntity ──────── DB 행의 원본 표현
InfoPostEntity ──── PostEntity 래핑 (공통 info 필드 매핑)
InfoService ─────── 내부 유틸리티 (API 미노출)
```

### info 게시글의 데이터 흐름

```
[생성] post.create API → PostController → PostService → PostRepository → sf_post_data
       (group_id='info', post_id/category 지정, varchar/int/text 커스텀 필드 설정)

[조회] post.get API → PostEntity → InfoPostEntity::fromPost() → 의미 있는 필드명
       (view.php에서 isInfoPost() 확인 → info 위젯 렌더링)

[목록] post.list API → PostService::list() → 일반 게시글과 info 게시글 함께 표시
       (post-list-tile.php에서 group_id='info'이면 아이콘+title 표시)
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
| `int_3` | latitude × 10^7 | 위도 (예: 10.3157° → 103157000) |
| `int_4` | longitude × 10^7 | 경도 (예: 123.8854° → 1238854000) |

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

> **InfoService는 내부 유틸리티로만 사용. API로 노출하지 않음.**

```php
use Philgo\Info\InfoService;

// 생성 (info-meta.json 참조하여 post_id/category 자동 설정)
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

## 7. API 사용법 — 기존 Post API 활용

### info 게시글 생성 (post.create)

```bash
curl -sk -X POST 'https://v7-local.philgo.com/api.php' \
  --data-urlencode 'method=post.create' \
  --data-urlencode 'session_id_v7=...' \
  --data-urlencode 'post_id=travel' \
  --data-urlencode 'category=여행' \
  --data-urlencode 'group_id=info' \
  --data-urlencode 'sub_category=beach' \
  --data-urlencode 'subject=보라카이 화이트 비치' \
  --data-urlencode 'content=## 소개...' \
  --data-urlencode 'varchar_1=White Beach, Boracay' \
  --data-urlencode 'varchar_2=세계에서 가장 아름다운 해변' \
  --data-urlencode 'varchar_6=말레이' \
  --data-urlencode 'varchar_7=아클란' \
  --data-urlencode 'region=비사야' \
  --data-urlencode 'text_1=["## 소개\n...", "## 방문 정보\n..."]' \
  --data-urlencode 'text_3=요약 설명...' \
  --data-urlencode 'char_1=Y'
```

### info 게시글 목록 (post.list)

```bash
# group_id 필터는 post.list에서 지원하지 않으므로, post_id+category로 필터
curl -sk 'https://v7-local.philgo.com/api.php?method=post.list&post_id=travel&category=여행'
```

### info 게시글 조회 (post.get)

```bash
curl -sk 'https://v7-local.philgo.com/api.php?method=post.get&idx=12345'
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

> **info-meta.json**에서 각 카테고리의 post_link, 서브카테고리, 필수 필드, extra_data 스키마를 확인.

---

## 9. info 게시글 식별 — group_id = 'info'

```php
// PHP — info 게시글 여부 확인
$post->isInfoPost();  // group_id === 'info'

// JavaScript
const isInfoPost = (post) => post.group_id === 'info';
```

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
// info 게시글 생성
final result = await v7api('post.create', {
  'post_id': 'travel',
  'category': '여행',
  'group_id': 'info',
  'sub_category': 'beach',
  'subject': '보라카이 화이트 비치',
  'varchar_1': 'White Beach, Boracay',
  'varchar_6': '말레이',
  'text_1': jsonEncode(['## 소개\n...', '## 방문\n...']),
  'char_1': 'Y',
});
```

### JavaScript (v7 웹)

```javascript
const result = await v7api('post.create', {
  post_id: 'travel',
  category: '여행',
  group_id: 'info',
  sub_category: 'beach',
  subject: '보라카이 화이트 비치',
  varchar_1: 'White Beach, Boracay',
  varchar_6: '말레이',
  text_1: JSON.stringify(['## 소개\n...', '## 방문\n...']),
  char_1: 'Y',
});
```
