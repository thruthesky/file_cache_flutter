# 필고 광고 API 문서

> **📌 플랫폼 안내**: 필고 백엔드는 PHP로 구현되어 있으며, 클라이언트는 주로 JavaScript/Vue.js 또는 Flutter를 사용합니다. 본 문서의 예제는 JavaScript/Vue.js 위주로 작성되었으며, Flutter 개발 시에도 동일한 API를 활용할 수 있습니다.

이 문서는 필고 API 스킬의 광고 관련 API 함수에 대한 상세 설명서입니다.

---

## 📚 목차

1. [광고 시스템 개요](#광고-시스템-개요)
2. [데이터베이스 구조](#데이터베이스-구조)
3. [배너 타입](#배너-타입)
4. [카테고리 기반 배너 표시](#카테고리-기반-배너-표시)
5. [배너 정렬 순서](#배너-정렬-순서)
6. [BannerModel 클래스](#bannermodel-클래스)
7. [API 함수 목록](#api-함수-목록)
   - [get_all_active_advertisements](#1-get_all_active_advertisements)
   - [get_top_banners](#2-get_top_banners)
   - [get_wing_banners](#3-get_wing_banners)
   - [get_square_banners](#4-get_square_banners)
   - [get_small_banners](#5-get_small_banners)
8. [사용 예제](#사용-예제)
9. [API 테스트 방법](#api-테스트-방법)
10. [관련 PHP 파일](#관련-php-파일)

---

## 광고 시스템 개요

필고 광고 시스템은 **업소(company) → 광고(advertisement) → 배너(banner)** 의 계층 구조로 이루어져 있습니다.

```
┌─────────────────────────────────────────────────────────────┐
│                        업소 (Company)                        │
│                    idx_company = 12345                       │
├─────────────────────────────────────────────────────────────┤
│                       광고 (Advertisement)                    │
│   - advertisement = 'y' (광고 활성화)                         │
│   - advertisement_begin_at (시작일)                           │
│   - advertisement_end_at (종료일)                             │
├─────────────────────────────────────────────────────────────┤
│                        배너들 (Banners)                       │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│   │   top   │  │  wing   │  │ square  │  │  small  │       │
│   │ 상단배너 │  │ 윙배너  │  │사각배너 │  │작은배너 │       │
│   └─────────┘  └─────────┘  └─────────┘  └─────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### 핵심 특징

- **1:1:N 관계**: 하나의 업소는 하나의 광고 설정을 가지며, 여러 개의 배너를 등록할 수 있음
- **기간 기반 표시**: `advertisement_begin_at` ~ `advertisement_end_at` 기간 내에만 광고 표시
- **카테고리 기반 타겟팅**: 특정 게시판/카테고리에만 표시하거나 전체 페이지에 표시 가능
- **자동 좌/우 배치**: `top`, `wing` 배너는 자동으로 50:50 비율로 좌/우에 배치됨
- **30분 캐싱**: `get_all_active_advertisements()` 함수는 성능을 위해 30분간 캐싱

---

## 데이터베이스 구조

### company 테이블 (광고 설정)

| 컬럼명 | 타입 | 설명 |
|--------|------|------|
| `idx` | int | 업소(광고) 고유 번호 |
| `advertisement` | enum('y','n') | 광고 활성화 여부 |
| `advertisement_begin_at` | datetime | 광고 시작일시 |
| `advertisement_end_at` | datetime | 광고 종료일시 |

### company_meta 테이블 (배너 정보)

| 컬럼명 | 타입 | 설명 |
|--------|------|------|
| `idx_company` | int | 업소 고유 번호 (FK) |
| `code` | varchar | 배너 타입 (`top`, `wing`, `square`, `small`) |
| `value` | text | 배너 이미지 URL 또는 JSON 데이터 |
| `all_page` | enum('y','n') | 전체 페이지 표시 여부 |

---

## 배너 타입

필고는 4가지 타입의 배너를 지원합니다.

### 1. Top Banner (상단 배너)
- **위치**: 페이지 상단
- **특징**: 좌/우로 자동 분배 (50:50)
- **용도**: 메인 광고 영역, 이벤트 배너

### 2. Wing Banner (윙 배너)
- **위치**: 화면 양쪽 사이드
- **특징**: 좌/우로 자동 분배 (50:50)
- **용도**: 플로팅 광고, 사이드 배너

### 3. Square Banner (사각 배너)
- **위치**: 게시판 목록 상단
- **크기**: 300x300 권장
- **용도**: 게시판별 광고, 사이드바 광고

### 4. Small Banner (작은 배너)
- **위치**: 사각 배너 아래
- **특징**: 텍스트 포함 가능
- **용도**: 텍스트 광고, 미니 배너

---

## 카테고리 기반 배너 표시

배너는 두 가지 방식으로 표시됩니다:

### 1. 전체 페이지 표시 (`all_page = 'y'`)
모든 게시판/카테고리에서 표시되는 배너입니다.

### 2. 특정 카테고리 표시
특정 게시판 ID(예: `wanted`, `qna`, `freetalk`)에서만 표시되는 배너입니다.

### API의 자동 병합 동작

모든 배너 조회 API는 **특정 카테고리 배너 + 전체 페이지 배너**를 자동으로 병합하여 반환합니다.

```javascript
// 'wanted' 게시판의 배너 조회 시
const banners = await func('get_top_banners', { category: 'wanted' });

// 결과: 'wanted' 전용 배너 + all_page='y' 배너 모두 포함
```

---

## 배너 정렬 순서

### 기본 정렬 원칙

모든 배너는 **`ad_end_date DESC`** 순서로 정렬됩니다:

| 순서 | 의미 |
|------|------|
| **먼저 표시** | 광고 만료일이 가장 늦은 (오래 남은) 광고 |
| **나중에 표시** | 광고 만료일이 임박한 광고 |

```
예시 (오늘 날짜: 2025-12-06):
├─ [0] 에르넬 피부과 - 만료일: 2026-10-19 (317일 남음) ← 먼저 표시
├─ [1] 야타이 사우나 - 만료일: 2026-07-04 (210일 남음)
├─ [2] OK 금융 환전 - 만료일: 2026-01-23 (48일 남음)
└─ [3] 하이금융 환전 - 만료일: 2025-12-12 (6일 남음) ← 나중에 표시
```

### filter_banners() 함수 동작 원리

`filter_banners()` 함수는 DB에서 가져온 배너를 카테고리별로 재정렬합니다:

```php
// lib/advertisement/get_banner.functions.php
function filter_banners(array $rows, ?string $category = null)
{
    // 카테고리가 비어있거나 null인 경우:
    // SQL의 ad_end_date DESC 정렬 순서 그대로 유지
    if (empty($category)) {
        return $rows;
    }

    // 카테고리가 지정된 경우:
    // 해당 카테고리 배너를 앞에, all_page 배너를 뒤에 배치
    $all_page_banners = array_filter($rows, fn($row) =>
        $row[ALL_PAGE] == 'y' && $row[CATEGORY] != $category);
    $category_banners = array_filter($rows, fn($row) =>
        $row[CATEGORY] == $category);

    return [...$category_banners, ...$all_page_banners];
}
```

### 카테고리별 정렬 동작

| 상황 | 동작 | 결과 |
|------|------|------|
| **카테고리 없음** (`category = ""` 또는 `null`) | SQL 정렬 순서 유지 | `ad_end_date DESC` 순서 |
| **카테고리 있음** (예: `wanted`) | 카테고리 매칭 배너 우선 | 1. `wanted` 카테고리 배너 (ad_end_date DESC)<br>2. `all_page='y'` 배너 (ad_end_date DESC) |

### 좌/우 배너 분배 알고리즘

`top`, `wing` 배너는 50:50 비율로 좌/우에 자동 분배됩니다:

```php
// 배열 인덱스 기준 분배
for ($i = 0; $i < count($all_banners); $i++) {
    if ($i % 2 == 0) {
        $banners['left'][] = $all_banners[$i];   // 짝수 인덱스 → 왼쪽
    } else {
        $banners['right'][] = $all_banners[$i];  // 홀수 인덱스 → 오른쪽
    }
}
```

```
예시 (8개 배너):
원본 순서: [0]317일, [1]210일, [2]172일, [3]48일, [4]15일, [5]13일, [6]12일, [7]6일

왼쪽: [0]317일 → [2]172일 → [4]15일 → [6]12일
오른쪽: [1]210일 → [3]48일 → [5]13일 → [7]6일
```

---

## BannerModel 클래스

### 클래스 정의

```php
// lib/models/banner.model.php
class BannerModel
{
    public $idx_company;    // 업소(광고주) 고유 번호
    public $idx_banner;     // 배너 고유 번호 (company_meta.idx)
    public $clickUrl;       // 클릭 시 이동 URL
    public $imageUrl;       // 배너 이미지 URL
    public $target;         // 링크 타겟 (_blank, _self 등)
    public $type;           // 배너 타입 (top, wing, square, small)
    public $category;       // 표시 카테고리 (게시판 ID)
    public $primary;        // 주요 텍스트
    public $secondary;      // 부가 텍스트
    public $ad_end_date;    // 광고 만료일 (YYYYMMDD 형식)
}
```

### 속성 상세 설명

| 속성 | 타입 | 설명 | 예시 |
|------|------|------|------|
| `idx_company` | int | 광고주 고유 번호 | `1664` |
| `idx_banner` | int | 배너 메타 고유 번호 | `2345` |
| `clickUrl` | string | 클릭 시 이동 URL | `https://example.com` |
| `imageUrl` | string | 배너 이미지 URL | `https://philgo.com/data/banner.jpg` |
| `target` | string | 링크 타겟 속성 | `_blank` |
| `type` | string | 배너 타입 | `wing`, `top`, `square`, `small` |
| `category` | string | 표시 대상 카테고리 | `wanted`, `travel`, `""` |
| `primary` | string | 주요 텍스트 (작은 배너용) | `환전 최저가` |
| `secondary` | string | 부가 텍스트 | `24시간 운영` |
| `ad_end_date` | string | 광고 만료일 | `20261019` |

### JavaScript에서 사용 예시

```javascript
const banners = await func('get_wing_banners', {});

banners.left.forEach(banner => {
    console.log('업소:', banner.idx_company);
    console.log('이미지:', banner.imageUrl);
    console.log('만료일:', banner.ad_end_date);

    // 남은 일수 계산
    const today = new Date();
    const endDate = new Date(
        banner.ad_end_date.slice(0,4) + '-' +
        banner.ad_end_date.slice(4,6) + '-' +
        banner.ad_end_date.slice(6,8)
    );
    const daysLeft = Math.ceil((endDate - today) / (1000 * 60 * 60 * 24));
    console.log('남은 일수:', daysLeft, '일');
});
```

---

## API 함수 목록

### 1. get_all_active_advertisements

**목적**: 모든 활성 광고를 한 번에 조회합니다.

**사용 시점**:
- Flutter 앱 시작 시 전체 광고 데이터 캐싱
- 웹 페이지 초기 로딩 시 광고 프리로드

**PHP 파일 위치**: `lib/api/function.class.php` (라인 766-770)

**입력 파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| `cache` | boolean | 선택 | `true` | 캐시 사용 여부 (30분 TTL) |

**리턴 값**:

```javascript
{
  "all": [                    // 모든 배너 데이터 (BannerModel 배열)
    {
      "idx": 123,
      "idx_company": 456,
      "type": "top",
      "url": "https://example.com/banner.jpg",
      "link": "https://target.com",
      "all_page": "y",
      "categories": ["wanted", "qna"]
    },
    // ...
  ],
  "top_all_page": [1, 2, 3],      // 전체 페이지 상단 배너 idx 목록
  "wing_all_page": [4, 5],        // 전체 페이지 윙 배너 idx 목록
  "square_all_page": [6, 7, 8],   // 전체 페이지 사각 배너 idx 목록
  "small_all_page": [9, 10]       // 전체 페이지 작은 배너 idx 목록
}
```

**JavaScript 사용 예제**:

```javascript
// Flutter 앱 시작 시 모든 광고 캐싱
async function cacheAllAdvertisements() {
  try {
    const ads = await func('get_all_active_advertisements', { cache: true });

    // 로컬 스토리지에 캐싱
    localStorage.setItem('cached_ads', JSON.stringify(ads));

    console.log('총 배너 수:', ads.all.length);
    console.log('전체 페이지 상단 배너:', ads.top_all_page);

    return ads;
  } catch (error) {
    console.error('광고 로딩 실패:', error);
    return null;
  }
}

// 앱 시작 시 호출
await cacheAllAdvertisements();
```

**Vue.js 사용 예제**:

```javascript
// Vue.js Options API
const AdCacheComponent = {
  data() {
    return {
      allAds: null,
      loading: true,
      error: null
    };
  },
  async mounted() {
    try {
      this.allAds = await func('get_all_active_advertisements', { cache: true });
      console.log('광고 캐싱 완료:', this.allAds.all.length, '개');
    } catch (error) {
      this.error = error.message;
    } finally {
      this.loading = false;
    }
  },
  template: `
    <div v-if="loading">광고 로딩 중...</div>
    <div v-else-if="error">에러: {{ error }}</div>
    <div v-else>{{ allAds.all.length }}개의 광고가 캐싱되었습니다.</div>
  `
};
```

---

### 2. get_top_banners

**목적**: 상단 배너를 조회합니다.

**사용 시점**:
- 페이지 상단 배너 영역에 광고 표시
- 메인 페이지 또는 게시판 상단 광고

**PHP 파일 위치**: `lib/api/function.class.php` (라인 780-783)

**입력 파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| `category` | string | 선택 | `null` | 게시판/카테고리 ID |

**리턴 값**:

```javascript
{
  "left": [           // 왼쪽 배너 배열
    {
      "idx": 123,
      "idx_company": 456,
      "url": "https://example.com/left-banner.jpg",
      "link": "https://target.com",
      "ad_end_date": "20260101",    // 광고 만료일 (항상 리턴됨)
      // ...BannerModel 속성
    }
  ],
  "right": [          // 오른쪽 배너 배열
    {
      "idx": 124,
      "idx_company": 457,
      "url": "https://example.com/right-banner.jpg",
      "link": "https://target2.com",
      "ad_end_date": "20251231"     // 광고 만료일 (항상 리턴됨)
    }
  ]
}
```

> **📌 정렬 순서**: 배너는 `ad_end_date DESC` 순서로 정렬됩니다. 즉, 광고 만료일이 가장 늦은(오래 남은) 광고가 먼저 표시되고, 만료일이 임박한 광고가 나중에 표시됩니다.

**JavaScript 사용 예제**:

```javascript
// 특정 게시판의 상단 배너 조회
async function loadTopBanners(postId) {
  const banners = await func('get_top_banners', { category: postId });

  console.log('왼쪽 배너:', banners.left.length, '개');
  console.log('오른쪽 배너:', banners.right.length, '개');

  return banners;
}

// 구인구직 게시판 상단 배너
const wantedBanners = await loadTopBanners('wanted');

// 전체 페이지 배너만 조회 (카테고리 없이)
const allPageBanners = await func('get_top_banners', {});
```

**Vue.js 사용 예제**:

```javascript
// Vue.js 상단 배너 컴포넌트
function TopBannerComponent() {
  return {
    props: {
      category: {
        type: String,
        default: null
      }
    },
    data() {
      return {
        leftBanners: [],
        rightBanners: [],
        loading: true
      };
    },
    async mounted() {
      await this.loadBanners();
    },
    methods: {
      async loadBanners() {
        try {
          const result = await func('get_top_banners', {
            category: this.category
          });
          this.leftBanners = result.left || [];
          this.rightBanners = result.right || [];
        } catch (error) {
          console.error('상단 배너 로딩 실패:', error);
        } finally {
          this.loading = false;
        }
      }
    },
    template: `
      <div class="top-banners d-flex justify-content-between">
        <div class="left-banners">
          <a v-for="banner in leftBanners" :key="banner.idx"
             :href="banner.link" target="_blank">
            <img :src="banner.url" alt="광고" class="img-fluid">
          </a>
        </div>
        <div class="right-banners">
          <a v-for="banner in rightBanners" :key="banner.idx"
             :href="banner.link" target="_blank">
            <img :src="banner.url" alt="광고" class="img-fluid">
          </a>
        </div>
      </div>
    `
  };
}
```

---

### 3. get_wing_banners

**목적**: 윙 배너(사이드 플로팅 배너)를 조회합니다.

**사용 시점**:
- 화면 양쪽 사이드에 플로팅 광고 표시
- 스크롤에 따라 따라다니는 사이드 배너

**PHP 파일 위치**: `lib/api/function.class.php` (라인 794-797)

**입력 파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| `category` | string | 선택 | `null` | 게시판/카테고리 ID |

**리턴 값**:

```javascript
{
  "left": [           // 왼쪽 윙 배너 배열
    {
      "idx": 123,
      "idx_company": 456,
      "url": "https://example.com/left-wing.jpg",
      "link": "https://target.com",
      "ad_end_date": "20260101"    // 광고 만료일 (항상 리턴됨)
    }
  ],
  "right": [          // 오른쪽 윙 배너 배열
    {
      "idx": 124,
      "idx_company": 457,
      "url": "https://example.com/right-wing.jpg",
      "link": "https://target2.com",
      "ad_end_date": "20251231"    // 광고 만료일 (항상 리턴됨)
    }
  ]
}
```

> **📌 정렬 순서**: 배너는 `ad_end_date DESC` 순서로 정렬됩니다. 즉, 광고 만료일이 가장 늦은(오래 남은) 광고가 먼저 표시되고, 만료일이 임박한 광고가 나중에 표시됩니다.

**JavaScript 사용 예제**:

```javascript
// 윙 배너 로드 및 표시
async function displayWingBanners(category = null) {
  const wings = await func('get_wing_banners', { category });

  // 왼쪽 윙 배너 렌더링
  if (wings.left.length > 0) {
    renderWingBanner('left', wings.left[0]);
  }

  // 오른쪽 윙 배너 렌더링
  if (wings.right.length > 0) {
    renderWingBanner('right', wings.right[0]);
  }
}

function renderWingBanner(position, banner) {
  const container = document.querySelector(`.wing-banner-${position}`);
  if (container) {
    container.innerHTML = `
      <a href="${banner.link}" target="_blank">
        <img src="${banner.url}" alt="광고">
      </a>
    `;
  }
}

// 사용
await displayWingBanners('job');
```

---

### 4. get_square_banners

**목적**: 사각 배너(300x300)를 조회합니다.

**사용 시점**:
- 게시판 목록 상단에 사각형 광고 표시
- 사이드바 광고 영역

**PHP 파일 위치**: `lib/api/function.class.php` (라인 806-809)

**입력 파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| `category` | string | 선택 | `null` | 게시판/카테고리 ID |

**리턴 값**:

```javascript
[                     // BannerModel 배열
  {
    "idx": 123,
    "idx_company": 456,
    "url": "https://example.com/square-banner.jpg",
    "link": "https://target.com",
    "all_page": "n",
    "categories": ["qna"],
    "ad_end_date": "20260101"    // 광고 만료일 (항상 리턴됨)
  },
  // ...
]
```

> **📌 정렬 순서**: 배너는 `ad_end_date DESC` 순서로 정렬됩니다. 즉, 광고 만료일이 가장 늦은(오래 남은) 광고가 먼저 표시되고, 만료일이 임박한 광고가 나중에 표시됩니다.

**JavaScript 사용 예제**:

```javascript
// 사각 배너 로드
async function loadSquareBanners(postId) {
  const banners = await func('get_square_banners', { category: postId });

  console.log('사각 배너 수:', banners.length);

  // 배너 슬라이더로 표시
  return banners;
}

// QnA 게시판 사각 배너
const qnaBanners = await loadSquareBanners('qna');
```

**Vue.js 사용 예제**:

```javascript
// 사각 배너 캐러셀 컴포넌트
function SquareBannerCarousel() {
  return {
    props: ['category'],
    data() {
      return {
        banners: [],
        currentIndex: 0
      };
    },
    async mounted() {
      this.banners = await func('get_square_banners', {
        category: this.category
      });

      // 자동 슬라이드 (5초마다)
      if (this.banners.length > 1) {
        setInterval(() => {
          this.currentIndex = (this.currentIndex + 1) % this.banners.length;
        }, 5000);
      }
    },
    computed: {
      currentBanner() {
        return this.banners[this.currentIndex] || null;
      }
    },
    template: `
      <div v-if="currentBanner" class="square-banner-carousel">
        <a :href="currentBanner.link" target="_blank">
          <img :src="currentBanner.url" alt="광고"
               style="width: 300px; height: 300px; object-fit: cover;">
        </a>
        <div v-if="banners.length > 1" class="banner-dots">
          <span v-for="(_, i) in banners" :key="i"
                :class="{ active: i === currentIndex }"
                @click="currentIndex = i">●</span>
        </div>
      </div>
    `
  };
}
```

---

### 5. get_small_banners

**목적**: 작은 배너(텍스트 포함)를 조회합니다.

**사용 시점**:
- 사각 배너 아래에 추가 광고 표시
- 텍스트 기반 미니 광고

**PHP 파일 위치**: `lib/api/function.class.php` (라인 818-821)

**입력 파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| `category` | string | 선택 | `null` | 게시판/카테고리 ID |

**리턴 값**:

```javascript
[                     // BannerModel 배열
  {
    "idx": 123,
    "idx_company": 456,
    "url": "https://example.com/small-banner.jpg",
    "link": "https://target.com",
    "text": "광고 텍스트",
    "all_page": "y",
    "ad_end_date": "20260101"    // 광고 만료일 (항상 리턴됨)
  },
  // ...
]
```

> **📌 정렬 순서**: 배너는 `ad_end_date DESC` 순서로 정렬됩니다. 즉, 광고 만료일이 가장 늦은(오래 남은) 광고가 먼저 표시되고, 만료일이 임박한 광고가 나중에 표시됩니다.

**JavaScript 사용 예제**:

```javascript
// 작은 배너 로드 및 표시
async function displaySmallBanners(category = null) {
  const banners = await func('get_small_banners', { category });

  const container = document.getElementById('small-banners-area');
  if (!container) return;

  container.innerHTML = banners.map(banner => `
    <a href="${banner.link}" target="_blank" class="small-banner-item">
      ${banner.url ? `<img src="${banner.url}" alt="광고">` : ''}
      ${banner.text ? `<span>${banner.text}</span>` : ''}
    </a>
  `).join('');
}

// 전체 페이지 작은 배너
await displaySmallBanners();

// 특정 게시판 작은 배너
await displaySmallBanners('freetalk');
```

---

## 사용 예제

### 전체 광고 시스템 통합 예제

```javascript
// 페이지 로드 시 모든 광고 초기화
async function initializeAdvertisements(postId = null) {
  try {
    // 1. 상단 배너 로드
    const topBanners = await func('get_top_banners', { category: postId });
    renderTopBanners(topBanners);

    // 2. 윙 배너 로드
    const wingBanners = await func('get_wing_banners', { category: postId });
    renderWingBanners(wingBanners);

    // 3. 사각 배너 로드
    const squareBanners = await func('get_square_banners', { category: postId });
    renderSquareBanners(squareBanners);

    // 4. 작은 배너 로드
    const smallBanners = await func('get_small_banners', { category: postId });
    renderSmallBanners(smallBanners);

    console.log('광고 초기화 완료');
  } catch (error) {
    console.error('광고 초기화 실패:', error);
  }
}

// 게시판 페이지에서 호출
const currentPostId = '<?= $post_id ?? "" ?>';
await initializeAdvertisements(currentPostId);
```

### Flutter 앱용 광고 캐싱 예제

```javascript
// 앱 시작 시 전체 광고 캐싱 (JavaScript 예시, Flutter에서 동일 API 사용)
async function cacheAdsForApp() {
  // 캐시 활성화하여 모든 광고 조회
  const allAds = await func('get_all_active_advertisements', { cache: true });

  // 앱 로컬 스토리지에 저장
  const cacheData = {
    ads: allAds,
    cachedAt: Date.now(),
    expiresAt: Date.now() + (30 * 60 * 1000) // 30분 후 만료
  };

  localStorage.setItem('philgo_ads_cache', JSON.stringify(cacheData));

  return allAds;
}

// 캐시에서 광고 조회
function getAdsFromCache() {
  const cached = localStorage.getItem('philgo_ads_cache');
  if (!cached) return null;

  const data = JSON.parse(cached);
  if (Date.now() > data.expiresAt) {
    localStorage.removeItem('philgo_ads_cache');
    return null;
  }

  return data.ads;
}

// 사용
let ads = getAdsFromCache();
if (!ads) {
  ads = await cacheAdsForApp();
}
```

---

## API 테스트 방법

### 로컬 테스트 (PHP 스크립트)

로컬 개발 환경에서 배너 API를 테스트하려면:

```bash
# 날개 배너 정렬 순서 디버그
php tests/debug-wing-banner-order.php --db-config=etc/db.config.dev.php
```

### 서버 API 테스트 (curl)

> **⚠️ 주의**: philgo.com은 Cloudflare 보안이 적용되어 있어 curl로 직접 테스트가 어려울 수 있습니다.
> 브라우저 콘솔에서 테스트하거나, 로컬 PHP 스크립트를 사용하세요.

#### 테스트 스크립트 위치

```
.claude/skills/philgo-api-skill/scripts/
├── test-get-wing-banners.sh       # 윙 배너 테스트
├── test-get-top-banners.sh        # 상단 배너 테스트
├── test-get-square-banners.sh     # 사각 배너 테스트
├── test-get-small-banners.sh      # 작은 배너 테스트
└── test-all-banners.sh            # 전체 배너 테스트
```

#### 실행 방법

```bash
# 스크립트 디렉토리로 이동
cd .claude/skills/philgo-api-skill/scripts/

# 실행 권한 부여
chmod +x *.sh

# 윙 배너 테스트
./test-get-wing-banners.sh

# 전체 배너 테스트
./test-all-banners.sh
```

### 브라우저 콘솔 테스트

브라우저에서 philgo.com에 접속 후, 개발자 도구(F12) → Console 탭에서:

```javascript
// 윙 배너 테스트
func('get_wing_banners', {}).then(r => {
    console.log('왼쪽 배너:', r.left.length, '개');
    console.log('오른쪽 배너:', r.right.length, '개');
    r.left.forEach((b, i) => {
        console.log(`좌측 ${i+1}: idx=${b.idx_company}, 만료일=${b.ad_end_date}`);
    });
});

// 상단 배너 테스트
func('get_top_banners', { category: 'wanted' }).then(r => {
    console.log('상단 배너:', r);
});

// 사각 배너 테스트
func('get_square_banners', {}).then(r => {
    console.log('사각 배너:', r.length, '개');
});
```

### PHP 유닛 테스트

```bash
# 배너 정렬 순서 테스트
php tests/debug-wing-banner-order.php --db-config=etc/db.config.dev.php

# 출력 예시:
# === 날개 배너 정렬 순서 디버그 ===
# 오늘 날짜: 20251206
#
# 1. DB 쿼리 결과 (ad_end_date DESC 정렬):
# 순서 | idx    | 광고 제목             | 만료일  | 남은일
# 1    | 1664   | 에르넬 피부과         | 20261019 | 317일
# 2    | 1868   | 야타이 사우나         | 20260704 | 210일
# ...
```

---

## 관련 PHP 파일

| 파일 | 설명 |
|------|------|
| `lib/api/function.class.php` | FunctionClass - 광고 API 메서드 정의 |
| `lib/advertisement/advertisement.functions.php` | `get_all_active_advertisements()` 함수 |
| `lib/advertisement/get_banner.functions.php` | 배너 조회 함수들 (`filter_banners`, `get_top_banners`, `get_wing_banners` 등) |
| `lib/models/banner.model.php` | BannerModel 클래스 정의 |
| `tests/debug-wing-banner-order.php` | 배너 정렬 순서 디버그 테스트 |

---

## 주의사항

1. **캐싱**: `get_all_active_advertisements()`는 30분간 캐싱됩니다. 실시간 데이터가 필요하면 `cache: false`를 전달하세요.

2. **카테고리 병합**: 카테고리를 지정하면 해당 카테고리 배너 + 전체 페이지(`all_page='y'`) 배너가 자동으로 병합됩니다.

3. **좌/우 자동 분배**: `top`, `wing` 배너는 자동으로 50:50 비율로 좌/우에 배치됩니다.

4. **기간 체크**: API는 현재 날짜가 광고 기간 내(`advertisement_begin_at` ~ `advertisement_end_at`)인 광고만 반환합니다.

5. **ad_end_date 필드**: 모든 배너 API(`get_top_banners`, `get_wing_banners`, `get_square_banners`, `get_small_banners`)는 항상 `ad_end_date` 필드를 리턴합니다. 이 값은 광고 만료일(YYYYMMDD 형식)을 나타냅니다.

6. **정렬 순서 (ad_end_date DESC)**: 모든 배너는 `ad_end_date DESC` 순서로 정렬되어 반환됩니다. 이는 **광고 만료일이 가장 늦은(오래 남은) 광고가 먼저** 표시되고, **만료일이 임박한 광고가 나중에** 표시됨을 의미합니다. 따라서 광고 기간이 많이 남은 광고가 상단에 위치하고, 곧 만료되는 광고가 하단에 위치합니다.

---

**문서 버전**: 1.0
**최종 업데이트**: 2025-12-05
**작성자**: PhilGo Development Team
