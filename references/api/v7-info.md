# v7 Info 시스템 — sf_post_data 기반

> **구현 완료** — sf_post_data 단일 테이블 기반 info 시스템

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [핵심 아키텍처](#3-핵심-아키텍처)
4. [필드 매핑](#4-필드-매핑)
5. [Entity 클래스 — InfoPostEntity](#5-entity-클래스--infopostentity)
6. [InfoService 상세](#6-infoservice-상세)
7. [InfoController — API 엔드포인트](#7-infocontroller--api-엔드포인트)
8. [카테고리/서브카테고리 규약](#8-카테고리서브카테고리-규약)
9. [info 게시글 식별 — group_id = 'info'](#9-info-게시글-식별--group_id--info)
10. [v7 위젯 시스템 — 렌더링 상세](#10-v7-위젯-시스템--렌더링-상세)
11. [CSS 클래스 목록](#11-css-클래스-목록)
12. [게시판 목록(post-list-tile)에서의 info 표시](#12-게시판-목록post-list-tile에서의-info-표시)
13. [extra_data JSON 구조 (카테고리별)](#13-extra_data-json-구조-카테고리별)
14. [Flutter/웹 호출 예시](#14-flutter웹-호출-예시)
15. [Travel 시스템과의 관계](#15-travel-시스템과의-관계)
16. [테스트](#16-테스트)
17. [access_code 기반 콘텐츠 관리 시스템](#17-access_code-기반-콘텐츠-관리-시스템)

---

## 1. 개요

Info 시스템은 여행지, 병원, 경찰, 긴급연락처, 비자, 축제 등 **다양한 카테고리의 정보를 sf_post_data 테이블의 커스텀 필드**를 활용하여 저장/관리하는 시스템임.

**info 게시글의 생성/수정/삭제는 반드시 `info.*` 전용 API를 사용해야 함.** `post.create` API에서는 `group_id=info` 설정이 차단됨.

> **정보 콘텐츠 생성/가공 시 반드시 `philgo-content` 스킬(`.custom-skills/philgo-content/SKILL.md`)을 참조한다.**
> 마크다운 구조, 그룹별 템플릿, 완성도 규칙, 인터넷 정보 수집 워크플로우 등이 정의되어 있음.

| 항목 | 설명 |
|------|------|
| **네임스페이스** | `Philgo\Info` |
| **DB 테이블** | `sf_post_data` (기존 게시판과 동일 테이블) |
| **식별** | `group_id = 'info'` |
| **API** | `info.*` 전용 API (InfoController) — **post.create에서 group_id=info 차단됨** |
| **확장** | `text_2`(extra_data JSON) 커스텀 필드, `content`(마크다운 본문) |
| **게시판 기능** | 댓글, 좋아요, 포인트, 검색, 알림, 블라인드, 신고 100% 자동 지원 |

### 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **테이블 1개** | sf_post_data 테이블의 커스텀 필드 활용 — 별도 테이블 없음 |
| **게시판 기능 100%** | 댓글, 좋아요, 포인트, 검색, 알림, 블라인드, 신고 자동 |
| **Entity 래핑** | varchar_1 -> english_name 등 의미 있는 이름으로 접근 |
| **info.* 전용 API** | info.create, info.update, info.delete, info.list, info.get, info.categories, info.meta |
| **group_id=info 보호** | post.create API에서 group_id=info 직접 설정 불가 (info.create만 허용) |

### 전체 데이터 흐름 다이어그램

```
[관리자/클라이언트]                              [서버 (PHP)]                              [DB]
   |                                              |                                        |
   | 1. info.create API 호출                       |                                        |
   |    (category=travel, name=..., ...)           |                                        |
   |    ----------------------------------------> |                                        |
   |                                              | 2. api.php -> 라우팅                      |
   |                                              |    InfoController::create()              |
   |                                              |    requireAdmin() 관리자 검증              |
   |                                              |                                        |
   |                                              | 3. InfoService::create()                |
   |                                              |    CATEGORIES 상수에서 post_id 매핑         |
   |                                              |    InfoPostEntity 구성                    |
   |                                              |    toPostData() -> 커스텀 필드 변환         |
   |                                              |                                        |
   |                                              | 4. PostRepository::create($postData)    |
   |                                              |    ----------------------------------------> 5. sf_post_data
   |                                              |                                        |    INSERT (group_id='info')
   |                                              |    <----------------------------------------
   |                                              |                                        |
   |    <---------------------------------------- | 6. InfoPostEntity::toArray() 응답        |
   |                                              |                                        |
   | 7. 웹 조회: view.php                          |                                        |
   |    isInfoPost() -> info-view.php 렌더링       |                                        |
```

---

## 2. 파일 구조

```
lib/info/
  InfoController.php   # info.* API 엔드포인트 (list, get, categories, meta, create, update, delete)
  InfoPostEntity.php   # PostEntity 래핑 — sf_post_data 커스텀 필드를 의미 있는 이름으로 매핑
  InfoService.php      # 비즈니스 로직 — create, update, delete, list, get, 카테고리 메타

v7/widgets/post/view/info/
  info-view.php        # 통합 info 글 읽기 위젯 (카테고리별 디자인 분기)
  info-meta-card.php   # 공통 메타 카드 (위치/연락처/운영시간/지도)
  info-view.css        # info 위젯 CSS (297줄)

v7/post/
  view.php             # 게시글 읽기 — isInfoPost() 분기로 info 위젯 include

v7/widgets/post/list/
  post-list-tile.php   # 게시판 목록 타일 — info 게시글 특수 표시 (카테고리 아이콘, title 우선)
```

---

## 3. 핵심 아키텍처

```
sf_post_data --------- 유일한 데이터 저장소
PostEntity ----------- DB 행의 원본 표현
InfoPostEntity ------- PostEntity 래핑 (공통 info 필드 매핑, 51개 프로퍼티)
InfoService ---------- 비즈니스 로직 (CATEGORIES 상수, CRUD, 필터, 카테고리 메타)
InfoController ------- info.* API 엔드포인트 (관리자 CRUD + 공개 조회)
```

### info 게시글의 데이터 흐름 (CRUD)

```
[생성] info.create API -> InfoController::create() -> InfoService::create()
      1. 필수 필드 검증 (category, name)
      2. CATEGORIES 상수에서 post_id/category 자동 매핑
      3. InfoPostEntity 구성 -> fillFromInput()으로 30개+ 필드 채움
      4. toPostData() -> PostRepository::create() -> sf_post_data INSERT
      5. group_id='info' 자동 설정
      주의: post.create API에서는 group_id=info 차단 -> RuntimeException

[수정] info.update API -> InfoController::update() -> InfoService::update()
      1. PostRepository::findByIdx()로 기존 게시글 조회
      2. group_id !== 'info'이면 RuntimeException
      3. InfoPostEntity::fromPost()로 기존 데이터 로드
      4. fillFromInput()으로 입력 필드만 덮어쓰기 (부분 수정 가능)
      5. toPostData() -> PostRepository::update() -> sf_post_data UPDATE

[삭제] info.delete API -> InfoController::delete() -> InfoService::delete()
      1. PostRepository::findByIdx()로 기존 게시글 조회
      2. group_id !== 'info'이면 RuntimeException
      3. 논리 삭제: UPDATE sf_post_data SET deleted = 1 WHERE idx = ?
      4. 댓글/좋아요 등 게시판 데이터 보존

[조회] info.get API -> InfoController::get() -> InfoService::get()
      1. PostRepository::findByIdx()로 조회
      2. group_id !== 'info'이면 RuntimeException
      3. InfoPostEntity::fromPost()로 래핑 후 toArray()로 반환
      4. 인증 불필요

[목록] info.list API -> InfoController::list() -> InfoService::list()
      1. WHERE group_id='info' AND deleted=0 AND depth=0 기본 조건
      2. 카테고리/지역/도시/월/post_id 필터 적용
      3. ORDER BY int_1 ASC, stamp DESC (sort_order -> 작성일)
      4. PostEntity::fromArray() -> InfoPostEntity::fromPost() 변환
      5. 인증 불필요

[통계] info.categories API -> InfoService::getDistinctPostCategories()
      1. GROUP BY post_id, category, sub_category, COUNT(*)
      2. DB 실시간 집계
      3. 각 row에 CATEGORIES 상수의 아이콘/이름 추가

[메타] info.meta API -> InfoService::getAllCategories()
      1. CATEGORIES 상수 전체 또는 특정 카테고리 반환
      2. 하드코딩된 정보 (DB 조회 없음)
```

---

## 4. 필드 매핑

### 기존 컬럼 활용

| sf_post_data 컬럼 | info 의미 | 설명 |
|-------------------|----------|------|
| `subject` | name | 이름 (한글) |
| `content` | content | 본문 (마크다운) |
| `content_type` | (고정 'markdown') | 콘텐츠 타입 |
| `group_id` | `'info'` (고정) | info 게시글 식별자 |
| `post_id` | 게시판 ID | info-meta.json의 post_link.post_id (자동 매핑) |
| `category` | 게시판 카테고리 | subcategory가 있으면 subcategory, 없으면 CATEGORIES의 category |
| `sub_category` | info 서브카테고리 | beach, hospital, embassy 등 |
| `region` | 지역 | 비사야, 루손 등 |
| `link` | website_url | 웹사이트 URL |
| `stamp` | stamp | 생성 시간 (Unix Timestamp) |
| `stamp_update` | (자동) | 수정 시간 |
| `deleted` | (논리 삭제) | 0=활성, 1=삭제됨 |
| `no_of_comment` | no_of_comment | 댓글 수 |
| `no_of_view` | no_of_view | 조회 수 |
| `good` | good | 좋아요 수 |
| `bad` | bad | 싫어요 수 |

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

### int 커스텀 필드

| 필드 | info 의미 | 비고 |
|------|----------|------|
| `int_1` | sort_order | 정렬 순서 (작을수록 먼저) |
| `int_2` | month | 축제 월 (1~12) |
| `int_3` | latitude x 10^7 | 위도 (예: 10.3157 -> 103157000) |
| `int_4` | longitude x 10^7 | 경도 (예: 123.8854 -> 1238854000) |

> **int_5~10**: 광고/포인트/차단 시스템 (모든 게시글 공통 — 수정 금지)

#### 위도/경도 변환 공식

```
저장 시: int_3 = (int)(latitude  * 10,000,000)   예: 11.9612 -> 119612000
저장 시: int_4 = (int)(longitude * 10,000,000)   예: 121.956 -> 1219560000

복원 시: latitude  = int_3 / 10,000,000.0        예: 119612000 -> 11.9612
복원 시: longitude = int_4 / 10,000,000.0        예: 1219560000 -> 121.956

특수값: int_3 = 0 또는 int_4 = 0 -> latitude/longitude = null (좌표 없음)
```

- 소수점 7자리까지 정밀도 유지 (약 1.1cm 오차)
- DB에서 int 타입이므로 인덱싱/비교 성능 우수

### text 커스텀 필드

| 필드 | info 의미 | 비고 |
|------|----------|------|
| `text_1` | (사용 안 함) | 하위 호환만 유지, 새 데이터에서는 사용하지 않음 |
| `text_2` | extra_data | JSON 카테고리별 추가 데이터 (예: `{"specialties":["내과"]}`) |
| `text_3` | description | 요약 설명 (2~3문장, 평문) |

### char 커스텀 필드

| 필드 | info 의미 | 값 | 비고 |
|------|----------|---|------|
| `char_1` | info_status | Y/N/D | 정보 상태 (활성/비활성/삭제) |
| `char_2` | has_map | Y/'' | 지도 정보 보유 (위도+경도 모두 있으면 자동 Y) |
| `char_3` | has_texts | Y/'' | (하위 호환) 사용하지 않음 |
| `char_4` | verified | Y/'' | 정보 검증 완료 |

> has_map은 toPostData()에서 자동 계산:
> ```php
> 'char_2' => ($this->latitude !== null && $this->longitude !== null) ? 'Y' : '',
> ```

---

## 5. Entity 클래스 — InfoPostEntity

### 파일: `lib/info/InfoPostEntity.php` (PSR-4: `Philgo\Info\InfoPostEntity`)

PostEntity를 래핑하여 커스텀 필드를 의미 있는 이름으로 매핑함. 총 **51개 프로퍼티**.

### 전체 프로퍼티 목록

```php
// === 래핑 대상 ===
public PostEntity $post;              // 원본 PostEntity 객체

// === 기존 컬럼에서 매핑 (5개) ===
public string $name = '';             // post->subject (한글 이름)
public string $content = '';          // post->content (마크다운 본문)
public string $category = '';         // post->category
public string $subcategory = '';      // post->sub_category
public string $region = '';           // post->region

// === varchar 커스텀 필드 (17개) ===
public string $english_name = '';     // post->varchar_1
public string $title = '';            // post->varchar_2 (한 줄 소개)
public string $icon = '';             // post->varchar_3
public string $category_icon = '';    // post->varchar_4
public string $subcategory_icon = ''; // post->varchar_5
public string $city = '';             // post->varchar_6
public string $province = '';         // post->varchar_7
public string $address = '';          // post->varchar_8
public string $phone = '';            // post->varchar_9
public string $phone2 = '';           // post->varchar_13
public string $email = '';            // post->varchar_14
public string $website_url = '';      // post->link
public string $hours = '';            // post->varchar_16
public string $image_url = '';        // post->varchar_17
public string $fee = '';              // post->varchar_18
public string $event_date = '';       // post->varchar_19
public string $tags = '';             // post->varchar_20

// === int 커스텀 필드 (4개) ===
public int $sort_order = 0;           // post->int_1
public int $month = 0;               // post->int_2
public ?float $latitude = null;       // post->int_3 / 10^7
public ?float $longitude = null;      // post->int_4 / 10^7

// === text 커스텀 필드 (2개) ===
public array $extra_data = [];        // post->text_2 (JSON 디코딩)
public string $description = '';      // post->text_3

// === char 커스텀 필드 (3개) ===
public string $info_status = '';      // post->char_1 (Y/N/D)
public string $has_map = '';          // post->char_2 (Y/'')
public string $verified = '';         // post->char_4 (Y/'')

// === 게시판 기능 필드 (8개) ===
public int $idx = 0;                  // post->idx (게시글 PK)
public int $idx_member = 0;           // post->idx_member (작성자 FK)
public int $no_of_comment = 0;        // post->no_of_comment
public int $no_of_view = 0;           // post->no_of_view
public int $good = 0;                 // post->good (좋아요)
public int $bad = 0;                  // post->bad (싫어요)
public int $stamp = 0;               // post->stamp (작성 시간)
public string $post_id = '';          // post->post_id (게시판 ID)
public string $access_code = '';      // post->access_code
```

### 메서드

#### `fromPost(PostEntity $post): self` (정적)

PostEntity를 InfoPostEntity로 변환. 모든 커스텀 필드를 의미 있는 이름으로 매핑함.

```php
$infoPost = InfoPostEntity::fromPost($post);
echo $infoPost->name;          // = $post->subject
echo $infoPost->english_name;  // = $post->varchar_1
echo $infoPost->city;          // = $post->varchar_6
echo $infoPost->latitude;      // = $post->int_3 / 10^7
echo $infoPost->description;   // = $post->text_3
```

주요 변환 로직:
- `int_3/int_4 -> latitude/longitude`: `$post->int_3 !== 0 ? $post->int_3 / 10000000.0 : null`

- `text_2 -> extra_data`: `json_decode($post->text_2, true)` — 실패 시 빈 배열

#### `toPostData(): array`

InfoPostEntity를 PostRepository::create()/update()용 배열로 변환.

```php
$postData = $infoPost->toPostData();
// 결과: ['subject' => $this->name, 'group_id' => 'info', 'varchar_1' => $this->english_name, ...]
```

주요 변환 로직:
- `group_id` = `'info'` (항상 고정)
- `content_type` = `'markdown'` (항상 고정)
- `latitude -> int_3`: `(int)($this->latitude * 10000000)`

- `info_status`: 기본값 `'Y'` (`$this->info_status ?: 'Y'`)
- `has_map`: latitude+longitude 모두 있으면 자동 `'Y'`


#### `toArray(): array`

API 응답용 배열로 변환 (50개 필드). 클라이언트에 반환할 때 사용함.

```php
$apiData = $infoPost->toArray();
// 결과: ['idx' => 123, 'name' => '보라카이', 'latitude' => 11.9612, ...]
```

### PostEntity::isInfoPost()

```php
// lib/post/PostEntity.php:467-470
public function isInfoPost(): bool
{
    return $this->group_id === 'info';
}
```

---

## 6. InfoService 상세

### 파일: `lib/info/InfoService.php` (PSR-4: `Philgo\Info\InfoService`)

### CATEGORIES 상수

9개 카테고리의 메타 정보가 하드코딩됨. 각 카테고리에는 아이콘, 이름, 게시판 매핑, 서브카테고리가 포함됨.

#### travel (여행지) — 10개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| beach | 🏖 | 해변/섬 |
| waterfall | 💧 | 폭포 |
| diving | 🤿 | 다이빙/스노클링 |
| museum | 🏛 | 박물관/미술관 |
| historical | 🏰 | 역사 유적 |
| garden | 🌹 | 꽃 정원 |
| nature | 🌳 | 자연경관 |
| resort | 🏨 | 리조트/호텔 |
| adventure | 🪂 | 어드벤처 |
| etc | ⭐ | 기타 |

#### festival (축제) — 5개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| religious | ⛪ | 종교 |
| cultural | 🎭 | 문화 |
| memorial | 🏛 | 기념일 |
| harvest | 🌾 | 수확/농업 |
| food_festival | 🍽 | 음식 축제 |

#### hospital (병원) — 5개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| general | 🏥 | 종합병원 |
| dental | 🦷 | 치과 |
| dermatology | 🧴 | 피부과 |
| eye | 👁 | 안과 |
| korean_clinic | 🇰🇷 | 한국인 병원 |

#### police (경찰) — 2개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| station | 🚔 | 경찰서 |
| tourist_police | 👮 | 관광경찰 |

#### emergency (긴급연락처) — 3개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| embassy | 🏛 | 대사관/영사관 |
| hotline | 📞 | 긴급전화 |
| rescue | 🚑 | 구조/구급 |

#### visa (비자) — 5개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| tourist | 🧳 | 관광비자 |
| working | 💼 | 워킹비자 |
| student | 🎓 | 학생비자 |
| retirement | 🏖 | 은퇴비자 |
| extension | 📋 | 비자 연장 |

#### living (생활정보) — 6개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| exchange | 💱 | 환전 |
| telecom | 📱 | 통신/SIM |
| transport | 🚌 | 교통 |
| delivery | 📦 | 배달/택배 |
| shopping | 🛒 | 쇼핑 |
| banking | 🏦 | 은행/금융 |

#### food (맛집/식당) — 5개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| korean | 🇰🇷 | 한식당 |
| local | 🍜 | 현지 맛집 |
| cafe | ☕ | 카페 |
| buffet | 🍱 | 뷔페 |
| bar | 🍺 | 바/펍 |

#### accommodation (숙소) — 5개 서브카테고리

| 코드 | 아이콘 | 이름 |
|------|--------|------|
| hotel | 🏨 | 호텔 |
| guesthouse | 🏠 | 게스트하우스 |
| resort | 🌴 | 리조트 |
| hostel | 🛏 | 호스텔 |
| condo | 🏢 | 콘도/아파트 |

> accommodation은 post_id/category가 비어 있음 (게시판 미매핑).

### 메서드 상세

#### `create(array $input): InfoPostEntity` (정적)

info 게시글을 생성함. 관리자 전용.

```php
$info = InfoService::create([
    'category' => 'travel',           // 필수 — CATEGORIES 키
    'name' => '보라카이 화이트 비치',    // 필수 — subject에 저장
    'english_name' => 'White Beach',
    'subcategory' => 'beach',
    'city' => '말레이',
    'province' => '아클란',
    'region' => '비사야',
    'latitude' => 11.9612,
    'longitude' => 121.956,
    'content' => '## 소개\n보라카이...\n\n## 방문 정보\n...',
    'description' => '보라카이 섬의 대표적인 해변...',
    'image_url' => 'https://...',
    'tags' => '해변,비사야,보라카이',
    'info_status' => 'Y',
    'idx_member' => 186619,           // Controller에서 자동 설정
]);
```

내부 처리 흐름:
1. 필수 필드 검증 (category, name)
2. `getPostLink($input['category'])`로 post_id/category 자동 매핑
3. `new InfoPostEntity()` 생성 -> `fillFromInput()` 호출
4. `toPostData()`로 sf_post_data 컬럼 배열 생성
5. `post_id`, `category`, `sub_category`, `idx_member`, `stamp`, `stamp_update` 설정
6. `PostRepository::create($postData)` -> INSERT
7. `PostRepository::findByIdx($idx)` -> `InfoPostEntity::fromPost()` 반환

> subcategory가 있으면 `category = subcategory`로 설정됨 (게시판 목록 필터링 호환).
> subcategory가 없으면 `category = CATEGORIES[category]['category']`로 설정됨.

#### `update(array $input): InfoPostEntity` (정적)

info 게시글을 수정함. 부분 수정 가능 (입력에 있는 필드만 덮어씀).

```php
$info = InfoService::update([
    'idx' => 12345,                   // 필수
    'title' => '업데이트된 소개',       // 이 필드만 수정됨
    'phone' => '+63-36-288-1234',     // 이 필드만 수정됨
]);
```

#### `delete(array $input): array` (정적)

논리 삭제. `UPDATE sf_post_data SET deleted = 1 WHERE idx = ?`.

```php
InfoService::delete(['idx' => 12345]);
// 반환: ['deleted' => true, 'idx' => 12345]
```

#### `get(int $idx): InfoPostEntity` (정적)

단건 조회. group_id !== 'info'이면 RuntimeException.

#### `list(array $input): array` (정적)

목록 조회. 필터/정렬/페이징 지원.

```php
$result = InfoService::list([
    'category' => 'travel',     // sub_category 필터
    'region' => '비사야',        // region 필터
    'city' => '세부',           // varchar_6 필터
    'post_id' => 'travel',     // post_id 필터
    'month' => 1,              // int_2 필터 (축제 월)
    'limit' => 20,             // 기본 20
    'offset' => 0,             // 기본 0
]);
// 반환: ['items' => InfoPostEntity[], 'total' => int]
```

**생성되는 SQL:**

```sql
SELECT p.*, m.photo_url as user_photo_url
FROM sf_post_data p
LEFT JOIN sf_member m ON p.idx_member = m.idx
WHERE p.group_id = 'info'
  AND p.deleted = 0
  AND p.depth = 0
  [AND p.sub_category = ?]    -- category 필터
  [AND p.region = ?]          -- region 필터
  [AND p.varchar_6 = ?]       -- city 필터
  [AND p.post_id = ?]         -- post_id 필터
  [AND p.int_2 = ?]           -- month 필터
ORDER BY p.int_1 ASC, p.stamp DESC
LIMIT 20 OFFSET 0
```

> 정렬: sort_order(int_1) 오름차순 (관리자 지정), stamp 내림차순 (최신순)

#### `getDistinctPostCategories(): array` (정적)

DB에서 group_id='info' 게시글들의 고유 post_id + category + sub_category 조합을 실시간 집계.

```sql
SELECT post_id, category, sub_category, COUNT(*) as count
FROM sf_post_data
WHERE group_id = 'info' AND deleted = 0 AND depth = 0
GROUP BY post_id, category, sub_category
ORDER BY count DESC
```

#### `getPostLink(string $category): array` (정적)

CATEGORIES 상수에서 카테고리별 게시판 매핑(post_id, category)을 반환.

```php
InfoService::getPostLink('travel');
// 반환: ['post_id' => 'travel', 'category' => '여행']
```

#### `getCategoryMeta(string $category): ?array` (정적)

카테고리의 상세 메타 정보 반환. 서브카테고리 목록 포함.

```php
InfoService::getCategoryMeta('travel');
// 반환:
// [
//     'code' => 'travel',
//     'icon' => '🧳',
//     'name' => '여행지',
//     'english_name' => 'Travel',
//     'post_id' => 'travel',
//     'category' => '여행',
//     'subcategories' => [
//         ['code' => 'beach', 'icon' => '🏖️', 'name' => '해변/섬'],
//         ['code' => 'waterfall', 'icon' => '💧', 'name' => '폭포'],
//         ...
//     ],
// ]
```

#### `getAllCategories(): array` (정적)

모든 카테고리 메타 정보를 반환. 키는 카테고리 코드.

#### `getSubcategoryMeta(string $category, string $subcategory): ?array` (정적)

특정 서브카테고리의 이름과 아이콘 반환.

```php
InfoService::getSubcategoryMeta('travel', 'beach');
// 반환: ['code' => 'beach', 'icon' => '🏖️', 'name' => '해변/섬']
```

#### `findCategoryBySubcategory(string $subcategoryCode): ?array` (정적)

서브카테고리 코드로 부모 카테고리를 역검색. info-view.php에서 카테고리 메타 조회 실패 시 사용.

```php
InfoService::findCategoryBySubcategory('beach');
// 반환:
// [
//     'parent_code' => 'travel',
//     'parent_meta' => [...],            // getCategoryMeta('travel') 결과
//     'sub_code' => 'beach',
//     'sub_meta' => ['icon' => '🏖️', 'name' => '해변/섬'],
// ]
```

#### `fillFromInput(InfoPostEntity $entity, array $input): void` (비공개)

입력값으로 InfoPostEntity의 필드를 채움. **입력에 있는 필드만 업데이트** (기존 값 유지).

지원 필드 (32개):
`name`, `english_name`, `title`, `icon`, `description`, `content`, `category`, `subcategory`, `category_icon`, `subcategory_icon`, `city`, `province`, `region`, `address`, `phone`, `phone2`, `email`, `url`, `website_url`, `hours`, `fee`, `event_date`, `tags`, `image_url`, `sort_order`, `month`, `latitude`, `longitude`, `extra_data`, `info_status`, `verified`

---

## 7. InfoController — API 엔드포인트

### 파일: `lib/info/InfoController.php` (PSR-4: `Philgo\Info\InfoController`)

`ControllerInterface`를 구현. API method 접두사: `info.*`

### 핵심 규칙: post.create API에서 group_id=info 차단

> `post.create` API에서 `group_id=info`를 직접 설정하면 RuntimeException이 발생한다.
> info 게시글을 생성하려면 반드시 `info.create` API를 사용해야 한다.

```php
// PostService.php:1694-1696 — 차단 로직
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

### 관리자 인증 메커니즘

```php
// InfoController 내부 메서드
private function requireAdmin(): void
{
    $user = AuthService::getLoginUser();          // session_id_v7로 인증
    if ($user === null) throw RuntimeException;   // 로그인 필수
    if (!AuthService::isAdmin()) throw RuntimeException; // 관리자 필수
}
```

### info.create — info 게시글 생성 (관리자 전용)

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
| `category` | 필수 | info 카테고리 코드 (travel, hospital, emergency 등) |
| `name` | 필수 | 이름 (한글) — subject 컬럼에 저장 |
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
| `content` | | 마크다운 본문 (유일한 메인 콘텐츠) |
| `extra_data` | | JSON 카테고리별 추가 데이터 |
| `description` | | 요약 설명 |
| `info_status` | | Y/N/D (기본 Y) |
| `sort_order` | | 정렬 순서 (작을수록 먼저) |
| `month` | | 축제 월 (1~12) |

### info.update — info 게시글 수정 (관리자 전용)

```bash
curl -sk -X POST 'https://v7-local.philgo.com/api.php' \
  --data-urlencode 'method=info.update' \
  --data-urlencode 'session_id_v7=관리자세션ID' \
  --data-urlencode 'idx=12345' \
  --data-urlencode 'title=업데이트된 소개'
```

> 입력에 포함된 필드만 수정됨 (부분 업데이트).

### info.delete — info 게시글 삭제 (관리자 전용)

```bash
curl -sk -X POST 'https://v7-local.philgo.com/api.php' \
  --data-urlencode 'method=info.delete' \
  --data-urlencode 'session_id_v7=관리자세션ID' \
  --data-urlencode 'idx=12345'
```

> 논리 삭제 (deleted=1). 댓글 등 관련 데이터 보존됨.

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
  "items": [
    {
      "idx": 12345,
      "name": "보라카이 화이트 비치",
      "english_name": "White Beach, Boracay",
      "title": "세계에서 가장 아름다운 해변",
      "city": "말레이",
      "province": "아클란",
      "region": "비사야",
      "category": "beach",
      "subcategory": "beach",
      "latitude": 11.9612,
      "longitude": 121.956,
      "image_url": "https://...",
      "no_of_view": 150,
      "good": 12,
      "stamp": 1711234567
    }
  ],
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

### 카테고리 -> 게시판 자동 매핑

| info 카테고리 | 아이콘 | 이름 | post_id | category | 서브카테고리 수 |
|--------------|--------|------|---------|----------|:---:|
| travel | 🧳 | 여행지 | `travel` | `여행` | 10 |
| festival | 🎉 | 축제 | `travel` | `여행` | 5 |
| hospital | 🏥 | 병원 | `freetalk` | `info` | 5 |
| police | 🚔 | 경찰 | `freetalk` | `info` | 2 |
| emergency | 🆘 | 긴급연락처 | `freetalk` | `info` | 3 |
| visa | 🛂 | 비자 | `freetalk` | `info` | 5 |
| living | 📱 | 생활정보 | `freetalk` | `생활의팁` | 6 |
| food | 🍽 | 맛집/식당 | `freetalk` | `먹방` | 5 |
| accommodation | 🏨 | 숙소 | — | — | 5 |

> info.create API 호출 시, `category` 파라미터만 지정하면 `post_id`와 게시판 `category`가 InfoService에서 자동 매핑됨.
> 매핑 정보는 InfoService::CATEGORIES 상수에 하드코딩되어 있음.

### category/sub_category 저장 로직

```php
// InfoService::create() 내부
$subcategory = $input['subcategory'] ?? '';

// subcategory가 있으면: category=subcategory, sub_category=subcategory
// subcategory가 없으면: category=CATEGORIES[카테고리]['category'], sub_category=카테고리코드
$postData['category'] = !empty($subcategory) ? $subcategory : $postCategory;
$postData['sub_category'] = !empty($subcategory) ? $subcategory : ($input['category'] ?? '');
```

예시:
- `category=travel, subcategory=beach` -> `category='beach', sub_category='beach'`
- `category=travel, subcategory=없음` -> `category='여행', sub_category='travel'`

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
| `info.create` API | 허용 | group_id=info 자동 설정 (관리자 전용) |
| `post.create` API + `group_id=info` | **차단됨** | RuntimeException 발생 |
| 직접 SQL | 금지 | API를 통해서만 생성 |

### 동작 방식

1. **게시글 목록**: PostService::list()는 변경 없이 info 글도 자동 포함
2. **게시글 상세**: view.php에서 isInfoPost() -> info 위젯 렌더링
3. **댓글/좋아요**: info/일반 게시글 동일하게 적용
4. **AI 답변**: info 게시글은 AI 답변 대상에서 제외됨 (`!$post->isInfoPost()` 조건)

---

## 10. v7 위젯 시스템 — 렌더링 상세

### view.php에서 info 분기

파일: `v7/post/view.php:287-299`

```php
<?php // --- 3-1. Info 게시글 (여행/병원/축제 등 정보 게시글) --- ?>
<?php if ($post->isInfoPost()): ?>
    <?php
    $infoPost = \Philgo\Info\InfoPostEntity::fromPost($post);
    include __DIR__ . '/../widgets/post/view/info/info-view.php';
    ?>
<?php endif; ?>

<?php // --- 3-2. 일반 게시글 (브레드크럼, 헤더, 본문, 첨부파일, 액션바, AI 답변) --- ?>
<?php if (!$post->isInfoPost()): ?>
    <?php include __DIR__ . '/../widgets/post/view/post-view-default.php'; ?>
<?php endif; ?>
```

- `isInfoPost() === true` -> info-view.php 위젯
- `isInfoPost() === false` -> post-view-default.php 위젯 (일반 게시글)
- AI 답변 대상에서 info 게시글 제외: `!$post->isInfoPost() && in_array($post->post_id, ['qna', 'freetalk'])`

### info-view.php 렌더링 구조 (10단계)

파일: `v7/widgets/post/view/info/info-view.php`

필수 변수: `$post` (PostEntity), `$infoPost` (InfoPostEntity), `$boardName`, `$effectivePostId`, `$effectiveCategory`

```
info-view.php 렌더링 순서
|
|-- 1. 카테고리 메타 조회 (PHP 전처리)
|      getCategoryMeta() -> 실패 시 findCategoryBySubcategory()로 역검색
|
|-- 2. 브레드크럼 (wa-breadcrumb)
|      홈 > 카테고리명 > 서브카테고리명
|
|-- 3. 대표 이미지 (info-hero-image)
|      $infoPost->image_url (있을 때만)
|
|-- 4. 제목 영역 (info-title-section)
|      ├ 개별 아이콘 ($infoPost->icon)
|      ├ 한글 이름 ($infoPost->name) — h1
|      ├ 영문 이름 ($infoPost->english_name)
|      └ 한 줄 소개 ($infoPost->title)
|
|-- 5. 요약 설명 (info-description)
|      $infoPost->description (있을 때만)
|
|-- 6. 카테고리별 특수 카드
|      ├ emergency/police -> 긴급연락처 카드 (빨간 배경 #fef2f2)
|      |   phone, phone2, hours, extra_data[emergency_phone, after_hours_phone]
|      ├ hospital -> 병원 카드 (초록 배경 #f0fdf4)
|      |   phone, hours, extra_data[specialties], extra_data[korean_staff], extra_data[emergency_24h]
|      └ festival -> 축제 카드 (노란 배경 #fefce8)
|          month, event_date, extra_data[duration_days], extra_data[highlight]
|
|-- 7. 본문 (info-content)
|      $infoPost->content -> v7Markdown() 마크다운 렌더링
|
|-- 9. 메타 카드 (info-meta-card.php include)
|      위치, 연락처, 운영시간, 이용료, 웹사이트, Google Maps 지도
|
|-- 10. 태그 (info-tags)
|       $infoPost->tags (쉼표 구분 -> 개별 태그 표시)
|
|-- 11. 통계 (info-stats)
|       조회수, 좋아요, 댓글 수
```

### 카테고리 메타 조회 로직 (info-view.php 상단)

```php
// 1차: 직접 카테고리 코드로 조회
$_infoCategoryMeta = InfoService::getCategoryMeta($_infoCategory);

// 2차 (실패 시): 서브카테고리 코드로 부모 카테고리 역검색
if (!$_infoCategoryMeta && $infoPost->subcategory) {
    $_parentResult = InfoService::findCategoryBySubcategory($infoPost->subcategory);
    // 부모 카테고리의 메타 정보 사용
}

// 3차 (여전히 실패): 서브카테고리 목록에서 이름/아이콘 검색
if ($_infoCategoryMeta && !$_infoSubHasName) {
    foreach ($_infoCategoryMeta['subcategories'] as $sub) {
        if ($sub['code'] === $infoPost->subcategory) { ... }
    }
}
```

### info-meta-card.php 상세

파일: `v7/widgets/post/view/info/info-meta-card.php`

공통 메타 카드. 모든 info 위젯에서 include하여 사용함.

```
info-meta-card 렌더링 항목 (있는 필드만 표시)
|
|-- 위치: city, province (region)
|-- 주소: address (fa-map-pin)
|-- 전화: phone (tel: 링크)
|-- 보조전화: phone2 (tel: 링크)
|-- 이메일: email (mailto: 링크)
|-- 운영시간: hours (fa-clock)
|-- 이용료: fee (fa-ticket)
|-- 웹사이트: website_url (target=_blank)
|-- 지도 링크: Google Maps 링크 (latitude, longitude)
|-- 지도 임베드: Google Maps iframe (latitude, longitude -> z=14)
```

> 위도/경도가 모두 있을 때만 Google Maps iframe이 렌더링됨.

---

## 11. CSS 클래스 목록

파일: `v7/widgets/post/view/info/info-view.css` (297줄)

### 공통 클래스

| 클래스 | 설명 |
|--------|------|
| `.info-view-page` | 전체 컨테이너 |
| `.info-breadcrumb` | 브레드크럼 |
| `.info-hero-image` | 대표 이미지 래퍼 |
| `.info-hero-image img` | 대표 이미지 (max-height: 400px, object-fit: cover) |
| `.info-title-section` | 제목 영역 |
| `.info-title-icon` | 제목 아이콘 (1.5em) |
| `.info-title-name` | 한글 이름 (h1, 1.5em, font-weight: 700) |
| `.info-title-english` | 영문 이름 (0.9em, #64748b) |
| `.info-title-subtitle` | 한 줄 소개 (italic) |
| `.info-description` | 요약 설명 (좌측 파란 보더) |
| `.info-content` | 본문 (마크다운) |
| `.info-tags` | 태그 컨테이너 (flex-wrap) |
| `.info-tag` | 개별 태그 (#3b82f6, #eff6ff 배경) |
| `.info-stats` | 통계 (조회/좋아요/댓글) |

### 메타 카드 클래스

| 클래스 | 설명 |
|--------|------|
| `.info-meta-card` | 메타 카드 컨테이너 (#f8fafc 배경) |
| `.info-meta-item` | 메타 항목 (flex, gap: 0.5rem) |
| `.info-meta-item i` | 아이콘 (#3b82f6) |
| `.info-map-embed` | 지도 래퍼 |
| `.info-map-embed iframe` | 지도 (height: 300px) |

### 긴급연락처 카드 (emergency, police)

| 클래스 | 설명 |
|--------|------|
| `.info-emergency-card` | 컨테이너 (배경 #fef2f2, 보더 #fecaca) |
| `.info-emergency-item` | 항목 행 |
| `.info-emergency-label` | 라벨 (#991b1b, min-width: 6em) |
| `.info-emergency-number` | 전화번호 (#dc2626, font-weight: 700) |
| `.info-emergency-value` | 일반 값 |

### 병원 카드 (hospital)

| 클래스 | 설명 |
|--------|------|
| `.info-hospital-card` | 컨테이너 (배경 #f0fdf4, 보더 #bbf7d0) |
| `.info-hospital-grid` | 그리드 (auto-fit, minmax: 120px) |
| `.info-hospital-cell` | 셀 (white 배경) |
| `.info-hospital-cell-label` | 셀 라벨 |
| `.info-hospital-cell-value` | 셀 값 |
| `.info-hospital-specialties` | 진료과목 |
| `.info-hospital-emergency` | 24시간 응급실 (#16a34a) |

### 축제 카드 (festival)

| 클래스 | 설명 |
|--------|------|
| `.info-festival-card` | 컨테이너 (배경 #fefce8, 보더 #fde68a, flex) |
| `.info-festival-month` | 월 배지 (#fbbf24 배경, white 텍스트) |
| `.info-festival-month-label` | "개최 월" 라벨 |
| `.info-festival-month-value` | 월 숫자 (1.3em, bold) |
| `.info-festival-date` | 날짜 |
| `.info-festival-duration` | 기간 |
| `.info-festival-highlight` | 하이라이트 |

---

## 12. 게시판 목록(post-list-tile)에서의 info 표시

파일: `v7/widgets/post/list/post-list-tile.php`

```php
// info 게시글 여부 확인
$_isInfoPost = $post->group_id === 'info';

// 카테고리 아이콘 (varchar_4)
$_infoCategoryIcon = $_isInfoPost ? $post->varchar_4 : '';

// 제목: title(varchar_2) 우선, 없으면 name(subject) 표시
$_infoDisplaySubject = $_isInfoPost
    ? ($post->varchar_2 ?: $post->subject)  // title 우선, 없으면 name
    : ($post->subject ?: '(제목 없음)');
```

info 게시글이 게시판 목록에 나타날 때:
- 카테고리 아이콘(varchar_4)이 제목 앞에 표시됨
- title(한 줄 소개)이 있으면 title 표시, 없으면 name(한글 이름) 표시
- 블라인드 된 info 게시글은 '블라인드 된 글입니다.' 표시

---

## 13. extra_data JSON 구조 (카테고리별)

`text_2` 컬럼에 JSON으로 저장되는 카테고리별 추가 데이터. 구조는 카테고리마다 다름.

### hospital (병원)

```json
{
  "specialties": ["내과", "외과", "피부과"],
  "korean_staff": true,
  "emergency_24h": true
}
```

| 키 | 타입 | 설명 |
|---|------|------|
| specialties | string[] | 진료과목 배열 |
| korean_staff | bool | 한국어 스태프 유무 |
| emergency_24h | bool | 24시간 응급실 유무 |

### emergency / police (긴급연락처)

```json
{
  "emergency_phone": "+63-2-8888-1234",
  "after_hours_phone": "+63-912-345-6789"
}
```

| 키 | 타입 | 설명 |
|---|------|------|
| emergency_phone | string | 비상 연락 전화번호 |
| after_hours_phone | string | 업무시간 외 전화번호 |

### festival (축제)

```json
{
  "duration_days": 3,
  "highlight": "전통 의상을 입고 춤을 추는 퍼레이드"
}
```

| 키 | 타입 | 설명 |
|---|------|------|
| duration_days | int | 축제 기간 (일 수) |
| highlight | string | 축제 하이라이트 설명 |

### 기타 카테고리

```json
{
  "key": "value"
}
```

> extra_data는 자유 형식 JSON. 카테고리별 특수 UI에서 필요한 데이터를 저장함.

---

## 14. Flutter/웹 호출 예시

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
// 절대 금지: post.create API로 group_id=info 설정 시도
final result = await v7api('post.create', {
  'post_id': 'travel',
  'category': '여행',
  'group_id': 'info',    // RuntimeException 발생!
  'subject': '보라카이',
});
```

```javascript
// 절대 금지: post.create API로 group_id=info 설정 시도
const result = await v7api('post.create', {
  post_id: 'travel',
  category: '여행',
  group_id: 'info',      // RuntimeException 발생!
  subject: '보라카이',
});
```

---

## 15. Travel 시스템과의 관계

필고에는 **두 개의 여행 정보 시스템**이 존재함. Info 시스템과 Travel 시스템은 별개의 시스템임.

### 비교표

| 항목 | Info 시스템 | Travel 시스템 |
|------|------------|--------------|
| **네임스페이스** | `Philgo\Info` | `Philgo\Travel` |
| **데이터 저장소** | sf_post_data (DB) | JSON 파일 + 마크다운 파일 |
| **파일** | `lib/info/` | `lib/travel/` |
| **데이터 파일** | — | `www/data/travel/travel_index.json` (604KB) + `content/{index}.md` (1,045개) |
| **API 접두사** | `info.*` | `travel.*` |
| **CRUD** | 전부 지원 (관리자) | **읽기 전용** (create/update/delete -> RuntimeException) |
| **게시판 기능** | 댓글, 좋아요, 포인트, 검색, 신고 100% | 없음 |
| **캐싱** | 없음 | 메모리 캐시 (동일 요청 내 재사용) |
| **웹 위젯** | info-view.php, info-meta-card.php | 없음 (API만 존재) |
| **앱 연동** | v7api('info.*') | v7api('travel.*'), TravelApi.dart |
| **용도** | 동적 여행 정보 관리 (주력) | 정적 여행 명소 데이터 조회 (보조) |
| **관리 방법** | API (info.create/update/delete) | JSON/마크다운 파일 직접 편집 |

### Travel API (참고)

| API | 설명 |
|-----|------|
| `travel.list` | 명소 목록 (province/city/category/search 필터, 페이징) |
| `travel.get` | 명소 상세 (texts + content 포함) |
| `travel.filters` | 필터 옵션 (provinces, cities, categories) |

> Travel 시스템 상세: `.claude/skills/v7-skill/references/api/v7-travel.md` 참조

---

## 16. 테스트

### PEST 유닛 테스트

파일: `tests/Unit/InfoPostEntityTest.php`

```bash
# info 관련 테스트 실행
./vendor/bin/pest tests/Unit/InfoPostEntityTest.php

# 전체 테스트
./vendor/bin/pest tests/Unit/
```

테스트 범위:
- InfoPostEntity 래핑 (fromPost, toPostData, toArray)
- 위도/경도 x 10^7 변환 정확도
- extra_data JSON 인코딩/디코딩
- InfoService CRUD (create, read, update, delete, list)
- 카테고리 메타 검색 (getCategoryMeta, findCategoryBySubcategory)
- group_id=info 보호 (post.create에서 차단)
- 필터 조건 (category, city, region, month)
- access_code 기반 CRUD (create, getByAccessCode, upsertByAccessCode, listByPrefix, registry)

---

## 17. access_code 기반 콘텐츠 관리 시스템 → [v7-info-access-code.md](v7-info-access-code.md)

`sf_post_data.access_code`(UNIQUE KEY, varchar(255), DEFAULT NULL)를 info 콘텐츠의
고유 식별자로 활용하여, 로컬 개발 환경에서 생성한 데이터를 프로덕션 DB로 동기화하고
웹과 앱에서 동일한 access_code로 콘텐츠를 조회하는 시스템이다.
`info:<모듈>:<지역>:<세부코드>` 형식의 계층적 명명 규칙을 사용하여 LIKE 쿼리로
지역별/모듈별 일괄 조회가 가능하다. InfoService에 `getByAccessCode()`(단건 조회),
`upsertByAccessCode()`(INSERT/UPDATE 자동 분기), `listByAccessCodePrefix()`(접두사 목록),
`getRegistry()`(웹/앱 공유 레지스트리) 4개 메서드를 추가하고, InfoController에
`info.getByAccessCode`, `info.upsertByAccessCode`, `info.registry`, `info.listByPrefix`
4개 API 엔드포인트를 추가했다. 동기화는 `scripts/info-sync-export.php`(로컬→JSON)와
`scripts/info-sync-import.php`(JSON→프로덕션 UPSERT, dry-run 지원)로 수행한다.
동기화는 `scripts/info-sync-export.php`(로컬→JSON)와
`scripts/info-sync-import.php`(JSON→프로덕션 UPSERT, dry-run 지원)로 수행한다.
PEST 유닛 테스트 8개(27 assertions)로 전체 CRUD 흐름을 검증했다.

## 18. 마크다운 중심 아키텍처 (현재)

### content 마크다운이 유일한 메인 콘텐츠

| 항목 | 설명 |
|------|------|
| **content** | 마크다운 — 웹/앱 모두에서 렌더링되는 **유일한 메인 콘텐츠** |
| **text_1** | 더 이상 콘텐츠 저장에 사용하지 않음 (info-view.php에서 렌더링 코드 삭제됨) |
| **text_2** | 메타데이터 JSON (출처, 최종 확인일 등) |
| **text_3** | 요약 설명 (2~3문장) |

### v7Markdown() 렌더링 함수

`v7/utils/helpers.php`에 정의된 v7 전용 마크다운 변환 함수.
v6 `convertMarkdownToHtml()`의 문제(### 깨짐, 줄바꿈 누락, blockquote 폰트)를 모두 해결.

- 11단계 순차 처리: 코드블록→테이블→**헤딩→인용→리스트**→인라인→문단
- **헤딩을 리스트보다 먼저 처리**하여 `###` 깨짐 방지
- `font-family: Noto Sans KR` 적용 (blockquote 포함)
- H2에 자동 `border-top` + `padding-top`으로 섹션 분리 (`---` 수평선 불필요)

### 카테고리 그룹별 마크다운 구조

info 콘텐츠는 카테고리에 따라 **5개 그룹별 다른 마크다운 구조**를 사용한다.
상세 구조는 `.custom-skills/philgo-content/SKILL.md`의 "카테고리 그룹별 content 마크다운 섹션 구조" 참조.

| 그룹 | 카테고리 | H2 섹션 수 |
|------|---------|-----------|
| A. 여행/관광 | travel, festival, food | 최소 4개 (한눈에 보기/상세/액티비티/방문정보/팁/숙소) |
| B. 의료/안전 | hospital, police | 최소 4개 (기본정보/진료안내/이용절차/참고) |
| C. 긴급/연락처 | emergency | 최소 3개 (총정리/기관연락처/상황별대응/참고) |
| D. 비자/행정 | visa | 최소 4개 (개요/종류/절차/주의/링크) |
| E. 생활정보 | living | 최소 4개 (개요/비교/이용방법/팁/링크) |
