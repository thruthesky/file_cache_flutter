# v7 웹 업소록 (Company) 홈페이지

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [URL 라우팅](#3-url-라우팅)
4. [업소록 목록 페이지 (SSR)](#4-업소록-목록-페이지-ssr)
5. [업소록 상세 페이지 (SSR)](#5-업소록-상세-페이지-ssr)
6. [업소 등록/수정 페이지 (CSR)](#6-업소-등록수정-페이지-csr)
7. [Config 헬퍼 메서드](#7-config-헬퍼-메서드)
8. [사이드바 위젯](#8-사이드바-위젯)
9. [CSS 구조](#9-css-구조)
10. [SEO 패턴](#10-seo-패턴)
11. [v7api / v7apiUpload 사용](#11-v7api--v7apiupload-사용)

---

## 1. 개요

v7 업소록 홈페이지는 **목록/상세는 SSR(SEO 필수)**, **등록/수정은 CSR(Vue.js CDN)**로 구현한다.
v6 코드를 일절 사용하지 않으며, v7 API(`CompanyService`)와 v7 유틸리티(`Config`, `Route`, `Url`, `Seo`)만 사용한다.

| 페이지 | 렌더링 | URL | 파일 |
|--------|--------|-----|------|
| **목록** | SSR (PHP) | `/company`, `/company?category=food` | `v7/company/index.php` |
| **상세** | SSR (PHP) | `/company/view?idx=1025` | `v7/company/view.php` |
| **등록/수정** | CSR (Vue.js) | `/company/register` | `v7/company/register.php` + `v7/js/company-register.js` |

### 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **SSR 우선** | 목록/상세는 PHP에서 `CompanyService`를 호출하여 서버에서 HTML 생성 (SEO/크롤러 대응) |
| **CSR 분리** | 등록/수정은 로그인 필수이므로 SEO 불필요, Vue.js CDN으로 동적 렌더링 |
| **v6 코드 금지** | `boot.php`, `page.header.php`, `pdo()`, `login()`, `href()` 등 v6 코드 사용 금지 |
| **v7 API 호출** | CSR 페이지에서 API 호출 시 반드시 `v7api()` 함수 사용 (`fetch`/`axios` 직접 호출 금지) |
| **url() 함수** | URL 생성 시 반드시 `url()->company->*` 사용 (하드코딩 금지) |
| **CSS 분리** | 각 페이지별 CSS를 별도 `.css` 파일로 분리 (`<style>` 태그 인라인 금지) |
| **Web Awesome Pro** | UI 컴포넌트는 Web Awesome Pro 사용 (Bootstrap 금지) |

---

## 2. 파일 구조

```
v7/company/
├── index.php              # 업소록 목록 (SSR, SEO)
├── index.css              # 목록 페이지 CSS (~267줄)
├── view.php               # 업소록 상세 (SSR, SEO)
├── view.css               # 상세 페이지 CSS (~249줄)
├── register.php           # 업소 등록/수정 (CSR, Vue.js)
└── register.css           # 등록 페이지 CSS (~276줄)

v7/js/
└── company-register.js    # 등록/수정 Vue.js 앱 (~333줄)

v7/js/
└── v7api.js               # v7 API 호출 래퍼 (v7api, v7apiUpload)

v7/utils/
├── Url.php                # CompanyUrl 클래스 (url()->company->*)
├── Route.php              # companyList(), companyView(), companyRegister() 정적 메서드
└── Config.php             # companyCategories(), companyCategoryName(), companyCategoryIcon()

v7/widgets/shared/
├── shared.company-categories.php   # 업소 카테고리 위젯 (사이드바)
└── shared.latest-companies.php     # 최근 업데이트된 업소 위젯 (사이드바)

lib/company/
├── CompanyService.php     # 비즈니스 로직 (list, info, mine, update 등)
├── CompanyEntity.php      # Entity (33개 필드 + toArray)
└── CompanyRepository.php  # DB CRUD (findAll, findByIdx 등)
```

---

## 3. URL 라우팅

### 3.1 Url 클래스 (`v7/utils/Url.php`)

`url()` 전역 함수를 통해 업소록 URL을 프로퍼티로 접근한다:

```php
class CompanyUrl
{
    public string $home = '/company';
    public string $register = '/company/register';

    public function view(int $idx): string
    {
        return Route::companyView($idx);
    }

    public function category(string $category): string
    {
        return Route::companyList($category);
    }
}
```

**사용 예시**:

```php
url()->company->home                 // '/company'
url()->company->register             // '/company/register'
url()->company->view(1025)           // '/company/view?idx=1025'
url()->company->category('food')     // '/company?category=food'
```

### 3.2 Route 정적 메서드 (`v7/utils/Route.php`)

```php
// 목록 URL
Route::companyList();                    // /company
Route::companyList('food');              // /company?category=food
Route::companyList('food', 2);           // /company?category=food&page=2

// 상세 URL
Route::companyView(1025);                // /company/view?idx=1025

// 등록 URL
Route::companyRegister();                // /company/register
```

### 3.3 디렉토리 인덱스 폴백

`/company` URL은 `v7/company.php`가 아니라 `v7/company/index.php`로 매핑된다.
`Route::resolvePageFile()`에 디렉토리 인덱스 폴백이 구현되어 있다:

```php
private function resolvePageFile(): void
{
    $v7Dir = $this->rootDir . '/v7';
    $realV7Dir = realpath($v7Dir);

    // 1차: path.php 파일 확인 (예: v7/company.php)
    $candidateFile = $v7Dir . '/' . $this->path . '.php';
    $realPageFile = realpath($candidateFile);
    if ($realPageFile && $realV7Dir && str_starts_with($realPageFile, $realV7Dir)) {
        $this->pageFile = $realPageFile;
        $this->validPath = true;
        return;
    }

    // 2차: path/index.php 디렉토리 인덱스 폴백 (예: v7/company/index.php)
    $indexFile = $v7Dir . '/' . $this->path . '/index.php';
    $realIndexFile = realpath($indexFile);
    if ($realIndexFile && $realV7Dir && str_starts_with($realIndexFile, $realV7Dir)) {
        $this->pageFile = $realIndexFile;
        $this->validPath = true;
        return;
    }

    $this->pageFile = null;
    $this->validPath = false;
}
```

**라우팅 흐름**:
1. 브라우저 → `/company` 요청
2. `v7.php` 프론트 컨트롤러 → `Route::getInstance()` → `path = 'company'`
3. `resolvePageFile()` → `v7/company.php` 없음 → `v7/company/index.php` 존재 → 매핑 성공
4. `v7/company/index.php` 렌더링

---

## 4. 업소록 목록 페이지 (SSR)

**파일**: `v7/company/index.php`
**URL**: `/company`, `/company?category=food`, `/company?category=food&page=2`

### 4.1 데이터 조회

```php
use Philgo\Company\CompanyService;
use Philgo\Utils\Seo;
use V7\Utils\Config;
use V7\Utils\Route;

$route = Route::getInstance();
$category = $route->query('category');
$page = max(1, (int)$route->query('page', 1));
$limit = 20;

$result = CompanyService::list([
    'category' => $category,
    'status' => 'a',           // 승인된 업소만 표시
    'page' => $page,
    'limit' => $limit,
]);
$companies = $result['items'] ?? [];
$total = $result['total'] ?? 0;
$totalPages = (int)ceil($total / $limit);
```

**`CompanyService::list()` 반환값**:
```php
[
    'items' => CompanyEntity::toArray()[], // 업소 배열
    'total' => int,                        // 총 개수
    'page'  => int,                        // 현재 페이지
    'limit' => int,                        // 페이지 크기
]
```

### 4.2 페이지 구조

```
┌──────────────────────────────────────────┐
│ wa-breadcrumb (홈 > 업소록 > [카테고리])      │
├──────────────────────────────────────────┤
│ 페이지 헤더 (제목 + 메타 + 등록 버튼)          │
├──────────────────────────────────────────┤
│ 카테고리 필터 (칩 16개 + 전체)                │
├──────────────────────────────────────────┤
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐     │
│ │카드1  │ │카드2  │ │카드3  │ │카드4  │     │  ← CSS Grid
│ └──────┘ └──────┘ └──────┘ └──────┘     │
│ ┌──────┐ ┌──────┐ ┌──────┐ ...          │
├──────────────────────────────────────────┤
│ 페이지네이션 (« ‹ 1 2 3 4 5 › »)           │
└──────────────────────────────────────────┘
```

### 4.3 카테고리 필터 핵심 코드

```php
<div class="company-category-filter">
    <a href="<?= url()->company->home ?>"
       class="category-chip <?= $category === null ? 'category-chip-active' : '' ?>">
        전체
    </a>
    <?php foreach ($categories as $cat): ?>
        <a href="<?= url()->company->category($cat) ?>"
           class="category-chip <?= $category === $cat ? 'category-chip-active' : '' ?>">
            <i class="<?= Config::companyCategoryIcon($cat) ?>"></i>
            <?= htmlspecialchars(Config::companyCategoryName($cat)) ?>
        </a>
    <?php endforeach; ?>
</div>
```

### 4.4 업소 카드 핵심 코드

```php
<a href="<?= url()->company->view((int)$company['idx']) ?>" class="company-card">
    <div class="company-card-image">
        <?php if (!empty($company['title_image_url'])): ?>
            <img src="<?= htmlspecialchars($company['title_image_url']) ?>"
                 alt="<?= htmlspecialchars($company['name']) ?>" loading="lazy">
        <?php elseif (!empty($company['logo_url'])): ?>
            <img src="<?= htmlspecialchars($company['logo_url']) ?>" ... loading="lazy">
        <?php else: ?>
            <div class="company-card-placeholder">
                <i class="<?= Config::companyCategoryIcon($company['category'] ?? '') ?>"></i>
            </div>
        <?php endif; ?>
    </div>
    <div class="company-card-body">
        <div class="company-card-name"><?= htmlspecialchars($company['name'] ?: '(이름 없음)') ?></div>
        <div class="company-card-meta">
            <span class="company-card-category">
                <i class="<?= Config::companyCategoryIcon($company['category']) ?>"></i>
                <?= htmlspecialchars(Config::companyCategoryName($company['category'])) ?>
            </span>
            <span class="company-card-location">
                <i class="fa-solid fa-location-dot"></i>
                <?= htmlspecialchars($company['location']) ?>
            </span>
        </div>
    </div>
</a>
```

**이미지 폴백 우선순위**: `title_image_url` → `logo_url` → 카테고리 아이콘 플레이스홀더

### 4.5 페이지네이션 핵심 코드

```php
<?php if ($totalPages > 1): ?>
    <nav class="company-pagination">
        <?php
        $pageRange = 5;
        $startPage = max(1, $page - $pageRange);
        $endPage = min($totalPages, $page + $pageRange);
        ?>

        <?php if ($page > 1): ?>
            <a href="<?= Route::companyList($category, 1) ?>" class="page-link page-first">
                <i class="fa-solid fa-angles-left"></i>
            </a>
            <a href="<?= Route::companyList($category, $page - 1) ?>" class="page-link page-prev">
                <i class="fa-solid fa-angle-left"></i>
            </a>
        <?php endif; ?>

        <?php for ($i = $startPage; $i <= $endPage; $i++): ?>
            <a href="<?= Route::companyList($category, $i) ?>"
               class="page-link <?= $i === $page ? 'page-current' : '' ?>">
                <?= $i ?>
            </a>
        <?php endfor; ?>

        <?php if ($page < $totalPages): ?>
            <a href="<?= Route::companyList($category, $page + 1) ?>" class="page-link page-next">
                <i class="fa-solid fa-angle-right"></i>
            </a>
            <a href="<?= Route::companyList($category, $totalPages) ?>" class="page-link page-last">
                <i class="fa-solid fa-angles-right"></i>
            </a>
        <?php endif; ?>
    </nav>
<?php endif; ?>
```

---

## 5. 업소록 상세 페이지 (SSR)

**파일**: `v7/company/view.php`
**URL**: `/company/view?idx=1025`

### 5.1 데이터 조회

```php
use Philgo\Company\CompanyService;
use Philgo\Utils\Seo;
use V7\Utils\Config;
use V7\Utils\Route;

$route = Route::getInstance();
$idx = (int)$route->query('idx', 0);

if ($idx <= 0) {
    http_response_code(400);
    echo '<div>잘못된 요청 — 업소 번호가 필요합니다.</div>';
    return;
}

$info = CompanyService::info(['idx' => $idx]);
$company = $info['company'] ?? [];
$owner = $info['owner'] ?? [];
```

**`CompanyService::info()` 반환값**:
```php
[
    'company' => CompanyEntity::toArray(),  // 업소 전체 필드
    'owner' => [                            // 소유자 정보
        'idx' => int,
        'nickname' => string,
        'name' => string,
        'photo_url' => string,
    ],
]
```

> **주의**: `sf_member` 테이블에는 `created_at` 컬럼이 없다 (`stamp` 컬럼 사용).
> `CompanyService::info()`의 owner 쿼리에서 `created_at`을 SELECT하면 에러가 발생한다.

### 5.2 페이지 구조

```
┌──────────────────────────────────────────┐
│ wa-breadcrumb (홈 > 업소록 > 카테고리 > 이름) │
├──────────────────────────────────────────┤
│ 커버 이미지 (title_image_url, max-height: 300px) │
│ ┌──────┐                                 │
│ │ 로고  │ 업소명 + 한줄소개 + 배지들          │
│ └──────┘ (카테고리 | 지역 | QR)            │
├──────────────────────────────────────────┤
│ [소개] description (nl2br)                │
├──────────────────────────────────────────┤
│ [사진] photo_url                          │
├──────────────────────────────────────────┤
│ [연락처] phone / mobile / address / kakao / telegram │
├──────────────────────────────────────────┤
│ [카카오톡 QR] kakaotalk_qr_code_url        │
├──────────────────────────────────────────┤
│ [운영자] owner name                        │
├──────────────────────────────────────────┤
│ [액션] 목록으로 | 카테고리 더보기               │
└──────────────────────────────────────────┘
```

### 5.3 연락처 섹션 핵심 코드

```php
<div class="company-contact-list">
    <?php if (!empty($company['phone_number'])): ?>
        <div class="company-contact-item">
            <i class="fa-solid fa-phone"></i>
            <span>전화:</span>
            <a href="tel:<?= htmlspecialchars($company['phone_number']) ?>">
                <?= htmlspecialchars($company['phone_number']) ?>
            </a>
        </div>
    <?php endif; ?>
    <?php if (!empty($company['mobile_number'])): ?>
        <div class="company-contact-item">
            <i class="fa-solid fa-mobile-screen"></i>
            <span>휴대폰:</span>
            <a href="tel:<?= htmlspecialchars($company['mobile_number']) ?>">
                <?= htmlspecialchars($company['mobile_number']) ?>
            </a>
        </div>
    <?php endif; ?>
    <!-- address, kakaotalk_id, telegram_id 동일 패턴 -->
</div>
```

### 5.4 하단 액션 버튼

```php
<div class="company-view-actions">
    <a href="<?= url()->company->home ?>" class="company-action-btn company-action-list">
        <i class="fa-solid fa-list"></i> 목록으로
    </a>
    <?php if (!empty($company['category'])): ?>
        <a href="<?= url()->company->category($company['category']) ?>" class="company-action-btn">
            <i class="<?= Config::companyCategoryIcon($company['category']) ?>"></i>
            <?= htmlspecialchars($categoryName) ?> 더보기
        </a>
    <?php endif; ?>
</div>
```

---

## 6. 업소 등록/수정 페이지 (CSR)

**PHP 파일**: `v7/company/register.php`
**JS 파일**: `v7/js/company-register.js`
**URL**: `/company/register`

### 6.1 PHP (최소 구조)

```php
use Philgo\Utils\Seo;
use V7\Utils\Config;

Seo::title('업소 등록/수정 - 필고');

$categories = Config::companyCategories();
$categoryNames = Config::companyCategoryNames();
?>

<div id="company-register-app"
     data-categories='<?= htmlspecialchars(json_encode($categories, JSON_UNESCAPED_UNICODE)) ?>'
     data-category-names='<?= htmlspecialchars(json_encode($categoryNames, JSON_UNESCAPED_UNICODE)) ?>'>
    <div class="company-register-loading">
        <i class="fa-solid fa-spinner fa-spin"></i> 로딩 중...
    </div>
</div>

<script defer src="/v7/js/company-register.js?v=<?= CACHE_VERSION ?>"></script>
```

**핵심 패턴**:
- PHP는 Vue 마운트 포인트(`#company-register-app`)와 데이터 전달(`data-*` 속성)만 담당
- 카테고리 목록을 JSON으로 HTML data 속성에 주입
- `CACHE_VERSION`으로 JS 캐시 버스팅

### 6.2 Vue.js 앱 (`company-register.js`)

```javascript
document.addEventListener('DOMContentLoaded', function () {
    var el = document.getElementById('company-register-app');
    if (!el) return;

    // data 속성에서 카테고리 데이터 파싱
    var categories = JSON.parse(el.dataset.categories || '[]');
    var categoryNames = JSON.parse(el.dataset.categoryNames || '{}');

    Vue.createApp({
        data: function () {
            return {
                loading: true,
                saving: false,
                error: '',
                success: '',
                loggedIn: false,
                categories: categories,
                categoryNames: categoryNames,
                company: {
                    idx: 0, name: '', title: '', description: '',
                    category: '', location: '', address: '',
                    phone_number: '', mobile_number: '',
                    kakaotalk_id: '', telegram_id: '',
                    status: '', logo_url: '', title_image_url: '', photo_url: '',
                },
                uploadingLogo: false,
                uploadingTitleImage: false,
                uploadingPhoto: false,
            };
        },
        mounted: function () { this.loadMyCompany(); },
        methods: {
            // 내 업소 정보 로드
            loadMyCompany: async function () { ... },
            // 업소 정보 저장
            saveCompany: async function () { ... },
            // 이미지 업로드
            uploadImage: async function (event, field) { ... },
            // 이미지 제거
            removeImage: function (field) { ... },
        },
        template: '...',
    }).mount('#company-register-app');
});
```

### 6.3 API 호출 패턴

```javascript
// 내 업소 로드 — v7api() 사용 (fetch/axios 직접 호출 금지)
loadMyCompany: async function () {
    try {
        var data = await v7api('company.mine', {}, { alertOnError: false });
        if (data) {
            this.loggedIn = true;
            this.company.idx = data.idx || 0;
            this.company.name = data.name || '';
            // ... 모든 필드 매핑
        }
    } catch (e) {
        if (e.response && e.response.status === 401) {
            this.loggedIn = false;  // 미로그인 상태
        }
    }
},

// 업소 정보 저장
saveCompany: async function () {
    var data = await v7api('company.update', {
        name: this.company.name,
        title: this.company.title,
        description: this.company.description,
        category: this.company.category,
        // ... 모든 필드 전달
    });
    this.company.status = data.status || this.company.status;
},

// 이미지 업로드 — v7apiUpload() 사용
uploadImage: async function (event, field) {
    var file = event.target.files && event.target.files[0];
    if (!file) return;
    var data = await v7apiUpload(file, 'company', field.replace('_url', ''));
    if (data && data.url) {
        this.company[field] = data.url;
    }
},
```

### 6.4 로그인 상태 감지

- `company.mine` API 호출 시 401 에러 → `loggedIn = false` → 로그인 안내 UI 표시
- 정상 응답 → `loggedIn = true` → 폼 표시
- `company.mine`은 업소가 없으면 자동으로 빈 레코드를 생성한다

### 6.5 상태 표시 (status)

```javascript
computed: {
    isNew: function () { return this.company.idx === 0 || this.company.name === ''; },
    statusLabel: function () {
        if (this.company.status === 'a') return '승인됨';
        if (this.company.status === 'p') return '심사중';
        return '미등록';
    },
    statusClass: function () {
        if (this.company.status === 'a') return 'company-status-approved';
        if (this.company.status === 'p') return 'company-status-pending';
        return 'company-status-new';
    },
},
```

---

## 7. Config 헬퍼 메서드

**파일**: `v7/utils/Config.php`

### 7.1 카테고리 목록

```php
Config::companyCategories()  // string[] — COMPANY_CATEGORIES 상수 반환
```

16개 카테고리: `public-office`, `education`, `food`, `transport`, `hospital`, `mart`, `bank`, `gadget`, `travel-agency`, `hotel`, `rentcar`, `beauty`, `real-estate`, `ktv`, `spa`, `etc`

### 7.2 카테고리 한글 이름

```php
Config::companyCategoryNames()       // ['food' => '음식점', 'hotel' => '호텔', ...]
Config::companyCategoryName('food')  // '음식점' (매핑에 없으면 원본 반환)
```

### 7.3 카테고리 아이콘

```php
Config::companyCategoryIcon('food')        // 'fa-solid fa-utensils'
Config::companyCategoryIcon('hotel')       // 'fa-solid fa-hotel'
Config::companyCategoryIcon('unknown')     // 'fa-solid fa-store' (기본값)
```

**전체 아이콘 매핑**:

| 카테고리 | 한글 | Font Awesome 아이콘 |
|---------|------|-------------------|
| `public-office` | 관공서 | `fa-solid fa-building-columns` |
| `education` | 교육 | `fa-solid fa-graduation-cap` |
| `food` | 음식점 | `fa-solid fa-utensils` |
| `transport` | 교통 | `fa-solid fa-bus` |
| `hospital` | 병원 | `fa-solid fa-hospital` |
| `mart` | 마트 | `fa-solid fa-cart-shopping` |
| `bank` | 은행 | `fa-solid fa-landmark` |
| `gadget` | 전자제품 | `fa-solid fa-mobile-screen` |
| `travel-agency` | 여행사 | `fa-solid fa-plane` |
| `hotel` | 호텔 | `fa-solid fa-hotel` |
| `rentcar` | 렌트카 | `fa-solid fa-car` |
| `beauty` | 뷰티 | `fa-solid fa-spa` |
| `real-estate` | 부동산 | `fa-solid fa-house` |
| `ktv` | KTV | `fa-solid fa-microphone` |
| `spa` | 스파 | `fa-solid fa-hot-tub-person` |
| `etc` | 기타 | `fa-solid fa-ellipsis` |

---

## 8. 사이드바 위젯

### 8.1 업소 카테고리 위젯

**파일**: `v7/widgets/shared/shared.company-categories.php`

```php
use V7\Utils\Config;
?>
<div class="v7-widget-box">
    <div class="widget-title">
        <span><i class="fa-solid fa-store"></i> 업소록</span>
        <a href="<?= url()->company->register ?>">등록</a>
    </div>
    <div class="widget-body">
        <div class="v7-category-grid">
            <?php foreach (Config::companyCategories() as $cat): ?>
                <a href="<?= url()->company->category($cat) ?>">
                    <?= htmlspecialchars(Config::companyCategoryName($cat)) ?>
                </a>
            <?php endforeach; ?>
        </div>
    </div>
</div>
```

- `Config::companyCategories()`로 동적 렌더링 (하드코딩 없음)
- `url()->company->category($cat)`로 URL 생성
- 오른쪽 상단에 `url()->company->register` 등록 링크

### 8.2 최근 업데이트된 업소 위젯

**파일**: `v7/widgets/shared/shared.latest-companies.php`

```php
use Philgo\Company\CompanyService;
use V7\Utils\Config;

$latestResult = CompanyService::list([
    'status' => 'a',
    'limit' => 5,
    'orderby' => 'updated_at DESC',
]);
$latestCompanies = $latestResult['items'] ?? [];
```

- 승인된 업소만 5개 조회 (`status => 'a'`)
- 이미지 폴백: `logo_url` → 카테고리 아이콘
- 제목 30자 truncate: `mb_substr($lc['title'], 0, 30)`
- 링크: `url()->company->view((int)$lc['idx'])`
- 더보기: `url()->company->home`

---

## 9. CSS 구조

### 9.1 공통 색상 변수

| 용도 | 색상 | 사용처 |
|------|------|--------|
| 브랜드색 | `#7f1d1d` | 헤더, 버튼, 활성 칩, 페이지네이션 |
| 강조색 | `#dc2626` | 호버 상태 |
| 배경색 | `#f3f4f6` | 플레이스홀더, 배지 |
| 텍스트 | `#1a1a1a` | 이름 |
| 보조 텍스트 | `#666` ~ `#999` | 설명, 메타 |
| 성공 | `#059669` | 승인 상태 배지 |
| 경고 | `#d97706` | 심사중 배지 |

### 9.2 목록 페이지 CSS (`index.css`)

```css
/* 그리드 레이아웃 */
.company-list-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 16px;
}

/* 카드 호버 */
.company-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    border-color: #7f1d1d;
}

/* 카테고리 칩 */
.category-chip {
    padding: 4px 10px;
    border: 1px solid #ddd;
    border-radius: 20px;
    font-size: 0.78em;
}
.category-chip-active {
    background: #7f1d1d;
    color: #fff;
    border-color: #7f1d1d;
}

/* 반응형 */
@media (max-width: 991px) {
    .company-list-grid { grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); }
}
@media (max-width: 480px) {
    .company-list-grid { grid-template-columns: 1fr 1fr; }
}
```

### 9.3 상세 페이지 CSS (`view.css`)

```css
.company-view-cover { max-height: 300px; overflow: hidden; border-radius: 8px; }
.company-view-logo  { width: 80px; height: 80px; border-radius: 12px; }
.company-view-section { padding: 16px; border: 1px solid #e5e7eb; border-radius: 8px; }
.company-section-title { color: #7f1d1d; border-bottom: 1px solid #f3f4f6; }
.company-contact-item i { width: 20px; text-align: center; color: #7f1d1d; }

@media (max-width: 991px) {
    .company-view-cover { max-height: 200px; }
    .company-view-logo  { width: 60px; height: 60px; }
}
```

### 9.4 등록 페이지 CSS (`register.css`)

```css
.company-register-form { max-width: 700px; }
.company-form-input:focus { border-color: #7f1d1d; }
.company-image-preview { width: 120px; height: 120px; }
.company-image-add { width: 120px; height: 120px; border: 2px dashed #d1d5db; }
.company-btn-submit { background: #7f1d1d; }
.company-btn-submit:hover { background: #dc2626; }

.company-status-approved { background: #ecfdf5; color: #059669; }
.company-status-pending  { background: #fffbeb; color: #d97706; }
.company-status-new      { background: #f3f4f6; color: #888; }
```

### 9.5 CSS 로딩

CSS 파일은 `v7/layout.php`에서 로드하지 **않는다**.
각 PHP 페이지에서 `<link>` 태그를 직접 포함하거나, `v7/layout.php`에서 경로 기반으로 조건 로드한다.
현재 구현에서는 `v7/layout.php`에 3개 CSS를 추가하여 전역 로드한다:

```html
<link rel="stylesheet" href="/v7/company/index.css?v=<?= CACHE_VERSION ?>">
<link rel="stylesheet" href="/v7/company/view.css?v=<?= CACHE_VERSION ?>">
<link rel="stylesheet" href="/v7/company/register.css?v=<?= CACHE_VERSION ?>">
```

---

## 10. SEO 패턴

### 10.1 목록 페이지 SEO

```php
$pageTitle = $categoryName !== null
    ? "{$categoryName} - 업소록 - 필고"
    : '업소록 - 필고';

Seo::title($pageTitle);
Seo::description('필고 업소록 - 필리핀 업소 정보 디렉토리');

// canonical URL (카테고리 + 페이지 포함)
$canonicalUrl = 'https://www.philgo.com/company';
if ($category !== null) {
    $canonicalUrl .= '?category=' . urlencode($category);
}
if ($page > 1) {
    $canonicalUrl .= ($category !== null ? '&' : '?') . "page={$page}";
}
Seo::canonical($canonicalUrl);
```

### 10.2 상세 페이지 SEO

```php
Seo::title("{$companyName} - 업소록 - 필고");

$descText = !empty($company['title']) ? $company['title'] : ($company['description'] ?? '');
Seo::description(mb_substr(strip_tags($descText), 0, 150));

Seo::canonical("https://www.philgo.com/company/view?idx={$idx}");

// OG 이미지: title_image_url 우선, 없으면 logo_url
if (!empty($company['title_image_url'])) {
    Seo::ogImage($company['title_image_url']);
} elseif (!empty($company['logo_url'])) {
    Seo::ogImage($company['logo_url']);
}
```

### 10.3 등록 페이지 SEO

```php
Seo::title('업소 등록/수정 - 필고');
// SEO 불필요 (로그인 필수 페이지)
```

---

## 11. v7api / v7apiUpload 사용

### 11.1 v7api() — API 호출

**파일**: `v7/js/v7api.js`

```javascript
// 내 업소 로드
var data = await v7api('company.mine', {}, { alertOnError: false });

// 업소 정보 저장
var data = await v7api('company.update', {
    name: '업소명', title: '소개', category: 'food', ...
});
```

### 11.2 v7apiUpload() — 파일 업로드

```javascript
// 이미지 업로드
var data = await v7apiUpload(file, 'company', 'logo');
// data.url → 업로드된 이미지 URL
```

**파라미터**:
- `file`: File 객체
- `module`: `'company'` (모듈명)
- `code`: `'logo'`, `'title_image'`, `'photo'` (필드명에서 `_url` 제거)

### 11.3 사용 시 주의사항

- `fetch()`, `axios.post()` 직접 사용 **절대 금지**
- `v7api()`는 에러 시 자동 `alert()` 표시 (기본값 `alertOnError: true`)
- `alertOnError: false`로 설정하면 조용히 에러 처리 (로그인 확인 등)
