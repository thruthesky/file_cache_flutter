# v7 검색 기능 (Google CSE)

## 목차

- [개요](#개요)
- [아키텍처](#아키텍처)
- [파일 구조](#파일-구조)
- [검색 페이지 (v7/post/search.php)](#검색-페이지-v7postsearchphp)
  - [검색 흐름](#검색-흐름)
  - [URL 파라미터](#url-파라미터)
  - [SEO 처리](#seo-처리)
  - [Google CSE 위젯](#google-cse-위젯)
  - [인기 검색어](#인기-검색어)
- [검색 CSS (v7/post/search.css)](#검색-css-v7postsearchcss)
  - [주요 CSS 클래스](#주요-css-클래스)
  - [다크모드 대응](#다크모드-대응)
  - [반응형 처리](#반응형-처리)
- [검색 JS (v7/js/search.js)](#검색-js-v7jssearchjs)
  - [debounce 자동 제출](#debounce-자동-제출)
- [데스크톱 헤더 검색 폼](#데스크톱-헤더-검색-폼)
  - [HTML 구조](#html-구조)
  - [CSS 클래스](#css-클래스)
- [모바일 헤더 검색 링크](#모바일-헤더-검색-링크)
- [URL 헬퍼](#url-헬퍼)
  - [Route::postSearch()](#routepostsearch)
  - [url()->search](#url-search)
- [SearchService (FULLTEXT 검색 — 향후 활용)](#searchservice-fulltext-검색--향후-활용)
  - [클래스 구조](#클래스-구조)
  - [search() 메서드](#search-메서드)
  - [generateSearchWords() 메서드](#generatesearchwords-메서드)
  - [DB 테이블: post_search](#db-테이블-post_search)
- [PEST 브라우저 테스트](#pest-브라우저-테스트)
- [향후 확장 계획](#향후-확장-계획)

---

## 개요

v7 검색 기능은 **Google Custom Search Engine(CSE)**을 사용하여 필고 사이트 내 콘텐츠를 검색한다.
v6의 `/page/search/cse.php`와 동일한 Google CSE cx ID(`d37786943cf92484d`)를 사용하며,
v7 레이아웃과 URL 구조에 맞게 재구현되었다.

| 항목 | 설명 |
|------|------|
| **검색 엔진** | Google Custom Search Engine (CSE) |
| **CSE cx ID** | `d37786943cf92484d` |
| **검색 페이지 URL** | `/post/search` 또는 `/post/search?search_term=키워드` |
| **데스크톱 헤더** | 로고 하단에 검색 입력 폼 (`.v7-search-form`) |
| **모바일 헤더** | 돋보기 아이콘 → 검색 페이지로 이동 |
| **FULLTEXT 검색** | `SearchService` (현재 미사용, 향후 활용 가능) |

---

## 아키텍처

```
[사용자 검색 흐름]

데스크톱:
  헤더 검색 폼 (.v7-search-form)
  → input 입력 → 0.9초 debounce 자동 제출 (search.js)
  → GET /post/search?search_term=키워드
  → v7/post/search.php 렌더링
  → Google CSE 위젯이 검색 결과 표시

모바일:
  헤더 돋보기 아이콘 클릭
  → GET /post/search (검색 페이지 이동)
  → 인라인 검색 폼에 키워드 입력 → 제출
  → Google CSE 위젯이 검색 결과 표시
```

---

## 파일 구조

```
v7/
├── post/
│   ├── search.php              ← 검색 결과 페이지 (Google CSE)
│   └── search.css              ← 검색 페이지 전용 CSS
├── js/
│   └── search.js               ← 데스크톱 헤더 검색 debounce 자동 제출
├── widgets/layout/
│   ├── layout.header-desktop.php  ← 데스크톱 헤더 (.v7-search-form 포함)
│   └── layout.header-mobile.php   ← 모바일 헤더 (검색 아이콘 링크)
├── utils/
│   ├── Route.php               ← Route::postSearch() 헬퍼
│   └── Url.php                 ← url()->search, url()->post->search()
lib/
└── search/
    └── SearchService.php       ← FULLTEXT 검색 Service (향후 활용)
tests/
└── Browser/
    └── SearchTest.php          ← PEST 브라우저 테스트 (7개)
```

---

## 검색 페이지 (v7/post/search.php)

### 검색 흐름

1. 쿼리 파라미터에서 `search_term` (또는 `q`) 추출
2. 검색어가 없으면 → 안내 메시지 + 인기 검색어 표시
3. 검색어가 있으면 → Google CSE 위젯 렌더링
4. hash fragment로 검색어 자동 전달 → CSE가 자동 검색 수행

### URL 파라미터

| 파라미터 | 필수 | 설명 |
|----------|------|------|
| `search_term` | N | 검색어 (기본 파라미터) |
| `q` | N | 검색어 대체 파라미터 (`search_term`이 없을 때 사용) |

**URL 예시:**

```
/post/search                          → 검색 안내 페이지
/post/search?search_term=마닐라       → "마닐라" 검색 결과
/post/search?q=환전                   → "환전" 검색 결과
```

### SEO 처리

```php
// 검색어가 있을 때
Seo::title("'{$searchTerm}' 검색 결과 - 필고");
Seo::description("필고에서 '{$searchTerm}' 관련 글을 검색한 결과입니다.");

// 검색어가 없을 때
Seo::title("검색 - 필고");
Seo::description("필고 전체 게시판을 검색합니다.");
```

### Google CSE 위젯

Google CSE는 `data-queryParameterName="search_term"` 속성으로 URL 파라미터를 자동 인식한다.
추가로 hash fragment를 사용하여 검색어를 전달한다.

```php
<!-- Google CSE 위젯 -->
<div class="gcse-search" data-queryParameterName="search_term"></div>

<script>
// hash fragment로 검색어 자동 전달
(function() {
    var searchTerm = <?= json_encode($searchTerm, JSON_UNESCAPED_UNICODE) ?>;
    if (searchTerm && !location.hash) {
        location.hash = '#gsc.tab=0&gsc.q=' + encodeURIComponent(searchTerm);
    }
})();
</script>
<script async src="https://cse.google.com/cse.js?cx=d37786943cf92484d"></script>
```

### 인기 검색어

검색어가 없을 때 인기 검색어 링크를 표시한다. `Route::postSearch()` 헬퍼를 사용하여 URL을 생성한다.

```php
<div class="v7-search-suggestions">
    <span>인기 검색어:</span>
    <a href="<?= Route::postSearch('마닐라') ?>">마닐라</a>
    <a href="<?= Route::postSearch('환전') ?>">환전</a>
    <a href="<?= Route::postSearch('비자') ?>">비자</a>
    <a href="<?= Route::postSearch('맛집') ?>">맛집</a>
    <a href="<?= Route::postSearch('골프') ?>">골프</a>
</div>
```

---

## 검색 CSS (v7/post/search.css)

### 주요 CSS 클래스

| CSS 클래스 | 설명 |
|-----------|------|
| `.v7-search-page` | 검색 페이지 전체 컨테이너 |
| `.v7-search-inline-form` | 검색 페이지 내 인라인 검색 폼 |
| `.v7-search-input-wrap` | 입력 필드 + 아이콘 + 버튼 래퍼 (flex) |
| `.v7-search-empty-guide` | 검색어 없을 때 안내 영역 |
| `.v7-search-suggestions` | 인기 검색어 링크 영역 |
| `.v7-search-cse-section` | Google CSE 결과 섹션 |
| `.v7-search-cse-header` | CSE 섹션 헤더 ("구글 검색 결과") |
| `.v7-search-result-header` | 검색 결과 헤더 (결과 수, 소요 시간) |
| `.v7-search-results` | 검색 결과 카드 컨테이너 |
| `.v7-search-result-card` | 개별 검색 결과 카드 |
| `.v7-search-no-result` | 결과 없음 안내 |
| `.v7-search-pagination` | 페이지네이션 |
| `.v7-search-error` | 에러 표시 |

### 다크모드 대응

`@media (prefers-color-scheme: dark)` 미디어 쿼리로 다크모드를 지원한다.

```css
@media (prefers-color-scheme: dark) {
    .v7-search-card-content b {
        background-color: rgba(255, 243, 205, 0.2);
        color: #ffc107;
    }
    .v7-search-suggestions > a,
    .v7-search-alt-links > a {
        background: var(--wa-color-neutral-800);
        color: var(--wa-color-neutral-300);
    }
}
```

### 반응형 처리

모바일(768px 이하)에서 간격과 패딩을 축소한다.

```css
@media (max-width: 768px) {
    .v7-search-stats { gap: 0.5rem; }
    .v7-search-result-card { padding: 0.75rem 0.25rem; }
}
```

---

## 검색 JS (v7/js/search.js)

### debounce 자동 제출

데스크톱 헤더의 검색 입력창(`.v7-search-form input[name="search_term"]`)에서 타이핑 시 **0.9초(900ms)** 대기 후 자동으로 폼을 제출한다.

| 동작 | 설명 |
|------|------|
| **입력 감지** | `input` 이벤트 리스너 |
| **최소 글자** | 2글자 이상 입력 시 debounce 시작 |
| **대기 시간** | 900ms |
| **엔터키** | 즉시 제출 (debounce 타이머 취소) |
| **빈 입력** | 전송하지 않음 |

```javascript
document.addEventListener('DOMContentLoaded', function () {
    var searchForm = document.querySelector('.v7-search-form');
    if (!searchForm) return;

    var searchInput = searchForm.querySelector('input[name="search_term"]');
    if (!searchInput) return;

    var DEBOUNCE_DELAY = 900;
    var debounceTimer = null;

    searchInput.addEventListener('input', function (e) {
        clearTimeout(debounceTimer);
        var value = (e.target.value || '').trim();
        if (value.length >= 2) {
            debounceTimer = setTimeout(function () {
                searchForm.submit();
            }, DEBOUNCE_DELAY);
        }
    });

    searchInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            clearTimeout(debounceTimer);
            // 기본 form submit 동작이 처리됨
        }
    });
});
```

---

## 데스크톱 헤더 검색 폼

### HTML 구조

`v7/widgets/layout/layout.header-desktop.php`의 `.v7-logo-center` 영역에 검색 폼이 위치한다.

```php
<div class="v7-logo-center">
    <a href="<?= url()->home ?>">
        <img src="/res/img/philgo/philgo.wide.logo.png" alt="PhilGo Logo">
    </a>
    <form class="v7-search-form" action="/post/search" method="get">
        <span class="search-addon"><i class="fa-solid fa-magnifying-glass"></i></span>
        <input name="search_term" type="text" placeholder="필리핀의 모든 것을 알려줍니다">
        <span class="search-addon search-suffix">
            <a href="<?= url()->post->list->encyclopedia ?>">백과</a>
            <a href="<?= url()->post->list->life_tips ?>">생활의팁</a>
        </span>
    </form>
</div>
```

### CSS 클래스

| 클래스 | 설명 |
|--------|------|
| `.v7-search-form` | 데스크톱 헤더 검색 폼 (로고 하단) |
| `.search-addon` | 검색 아이콘 / 접미사 링크 영역 |
| `.search-suffix` | 검색 폼 오른쪽의 바로가기 링크 (백과, 생활의팁) |

> `.v7-search-form`의 CSS 스타일은 `v7/css/layout.css`에 정의되어 있다. `max-width: 500px` 제한.

---

## 모바일 헤더 검색 링크

`v7/widgets/layout/layout.header-mobile.php`의 `.v7-mobile-actions` 영역에 돋보기 아이콘 링크가 위치한다.

```php
<div class="v7-mobile-actions">
    <a href="/post/search" style="color:inherit;" title="검색">
        <i class="fa-solid fa-magnifying-glass"></i>
    </a>
    <!-- ... 로그인/프로필/메뉴 아이콘 ... -->
</div>
```

클릭 시 `/post/search` 검색 페이지로 이동한다.

---

## URL 헬퍼

### Route::postSearch()

`v7/utils/Route.php`에 정의된 정적 메서드이다.

```php
/**
 * @param string|null $searchTerm 검색어 (null이면 검색 페이지만)
 * @param int $page 페이지 번호 (1이면 page 파라미터 생략)
 */
public static function postSearch(?string $searchTerm = null, int $page = 1): string
```

| 호출 예시 | 결과 URL |
|----------|----------|
| `Route::postSearch()` | `/post/search` |
| `Route::postSearch('김치')` | `/post/search?search_term=김치` |
| `Route::postSearch('김치', 2)` | `/post/search?search_term=김치&page=2` |

### url()->search

`v7/utils/Url.php`에 정의된 프로퍼티 접근 방식이다.

```php
url()->search                      // '/post/search'
url()->post->search('마닐라')      // '/post/search?query=마닐라'
```

---

## SearchService (FULLTEXT 검색 — 향후 활용)

`lib/search/SearchService.php`에 구현된 FULLTEXT BOOLEAN MODE 검색 서비스이다.
현재는 Google CSE를 사용하고 있어 **미사용** 상태이나, 향후 자체 검색으로 전환 시 활용할 수 있다.

### 클래스 구조

```
Philgo\Search\SearchService
├── search(array $input): array        ← FULLTEXT BOOLEAN 검색 수행
├── generateSearchWords(string $q): string  ← 검색어 → BOOLEAN 쿼리 변환
└── wrapSearchWords(string $q, string $content): string  ← 검색어 <b> 하이라이트
```

### search() 메서드

```php
/**
 * @param array $input
 *   - 'q' 또는 'search_term': 검색어 (필수, 2~32자)
 *   - 'page': 페이지 번호 (기본: 1)
 *   - 'per_page': 페이지당 결과 수 (기본: 40, 최대: 100)
 * @return array
 *   - 'search_words': 실제 검색에 사용된 단어
 *   - 'page': 현재 페이지 번호
 *   - 'per_page': 페이지당 결과 수
 *   - 'total': 전체 결과 수
 *   - 'duration': 검색 소요 시간 (초)
 *   - 'results': [idx_post, post_id, category, stamp, content]
 */
SearchService::search(['q' => '마닐라', 'page' => 1]);
```

### generateSearchWords() 메서드

입력된 검색어에서 특수문자/숫자를 제거하고, 각 단어에 `+`, `*`를 추가하여 BOOLEAN MODE 쿼리를 생성한다.

```
"김치"           → "+김치*"
"김치 마닐라"    → "+김치* +마닐라*"
"김치 마닐라 판매" → "+김치* +마닐라* +판매*"
```

### DB 테이블: post_search

`post_search` 테이블은 게시글의 제목/내용을 FULLTEXT 인덱스로 저장하는 테이블이다.

```sql
CREATE TABLE `post_search` (
    `idx` int(11) NOT NULL AUTO_INCREMENT,
    `idx_post` int(11) NOT NULL DEFAULT 0,
    `post_id` varchar(64) NOT NULL DEFAULT '',
    `category` varchar(64) NOT NULL DEFAULT '',
    `stamp` int(11) NOT NULL DEFAULT 0,
    `content` text NOT NULL,
    PRIMARY KEY (`idx`),
    KEY `idx_post` (`idx_post`),
    KEY `post_id` (`post_id`),
    FULLTEXT KEY `ft_content` (`content`)
) ENGINE=InnoDB;
```

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx` | int | PK (AUTO_INCREMENT) |
| `idx_post` | int | 게시글 번호 (sf_post_data.idx) |
| `post_id` | varchar(64) | 게시판 ID |
| `category` | varchar(64) | 카테고리 |
| `stamp` | int | 작성 시간 (UNIX timestamp) |
| `content` | text | 검색 대상 텍스트 (FULLTEXT 인덱스) |

---

## PEST 브라우저 테스트

`tests/Browser/SearchTest.php`에 7개의 PEST 브라우저 테스트가 작성되어 있다.

**실행 방법:**

```bash
./vendor/bin/pest tests/Browser/SearchTest.php
./vendor/bin/pest tests/Browser/SearchTest.php --headed
```

**테스트 URL:** `https://v7-local.philgo.com/post/search`

| # | 테스트명 | 그룹 | 설명 |
|---|---------|------|------|
| 1 | v7 검색 페이지에 접근할 수 있다 | smoke | 검색 페이지 접근 + footer 확인 |
| 2 | v7 검색 페이지 레이아웃이 올바르다 | layout | v7 레이아웃 구조 + 검색 고유 요소 확인 |
| 3 | 검색어가 없으면 안내 메시지가 표시된다 | empty | `.v7-search-empty-guide`, `.v7-search-suggestions` 확인 |
| 4 | 검색어를 입력하면 Google CSE 검색 결과가 표시된다 | cse | `?search_term=마닐라` → CSE 섹션 확인 |
| 5 | v7 검색 페이지 타이틀이 올바르다 | seo | 타이틀에 검색어 + "검색" 포함 확인 |
| 6 | 검색 인라인 폼에서 검색어를 입력하고 제출할 수 있다 | form | 인라인 폼 입력 → 제출 → CSE 섹션 표시 확인 |
| 7 | 데스크톱 헤더의 검색 폼이 v7 검색 페이지로 연결된다 | header | `.v7-search-form[action="/post/search"]` 확인 |

---

## 향후 확장 계획

| 항목 | 설명 | 비고 |
|------|------|------|
| **FULLTEXT 자체 검색** | `SearchService`를 활용한 자체 검색 결과 표시 | Google CSE와 병행 또는 대체 가능 |
| **검색 자동완성** | 입력 시 실시간 자동완성 제안 | Vue.js 컴포넌트로 구현 가능 |
| **검색 로그** | 검색어 로그 저장 → 인기 검색어 자동 갱신 | DB 테이블 추가 필요 |
| **카테고리 필터** | 특정 게시판/카테고리만 검색 | `post_id` 파라미터 추가 |
