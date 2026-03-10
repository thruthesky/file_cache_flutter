# v7 관리자 대시보드 시스템

## 목차

1. [핵심 개념](#1-핵심-개념)
2. [파일 구조](#2-파일-구조)
3. [라우팅 및 레이아웃 분기](#3-라우팅-및-레이아웃-분기)
4. [인증 시스템](#4-인증-시스템)
5. [관리자 레이아웃](#5-관리자-레이아웃-admin-layoutphp)
6. [대시보드 페이지](#6-대시보드-페이지-indexphp)
7. [회원 관리 페이지](#7-회원-관리-페이지-usersphp)
8. [게시판 관리 페이지](#8-게시판-관리-페이지-boardsphp)
9. [글 목록 관리 페이지](#9-글-목록-관리-페이지-postsphp)
10. [코멘트 관리 페이지](#10-코멘트-관리-페이지-commentsphp)
11. [업소록 관리 페이지](#11-업소록-관리-페이지-companiesphp)
12. [설정 관리 페이지](#12-설정-관리-페이지-settingsphp)
13. [CSS 스타일 시스템](#13-css-스타일-시스템-admincss)
14. [JavaScript 유틸리티](#14-javascript-유틸리티-adminjs)
15. [DB 테이블 참조](#15-db-테이블-참조)
16. [공통 코딩 패턴](#16-공통-코딩-패턴)
17. [새 관리자 페이지 추가 방법](#17-새-관리자-페이지-추가-방법)

---

## 1. 핵심 개념

### 설계 의도

v7 관리자 대시보드는 v6 관리자 페이지의 기능을 v7 구조에 맞게 **완전히 새로 구현**한 시스템이다.
v6 코드(boot.php, page.header.php, Bootstrap 등)를 일절 사용하지 않고,
v7 전용 부팅(`v7/boot.php`), `Db::pdo()`, `AuthService`, Web Awesome Pro + Font Awesome Pro + 커스텀 CSS로 구현한다.

### 아키텍처 특징

| 항목 | 설명 |
|------|------|
| **렌더링 방식** | PHP SSR (서버 사이드 렌더링) — `Db::pdo()` 직접 쿼리 |
| **레이아웃** | 관리자 전용 레이아웃 (`admin-layout.php`) — 사이드바/날개 없이 탑바 + 네비게이션 탭 + 전폭 콘텐츠 |
| **인증** | `AuthService::getLoginUser()` → `firebase_uid`가 `Config::admins()`에 포함되는지 확인 |
| **UI 라이브러리** | Web Awesome Pro v3.3.1 + Font Awesome Pro v7.2.0 + 커스텀 CSS (`admin.css`) |
| **JavaScript** | Vue.js CDN + Axios + `v7api()` + 관리자 유틸 (`admin.js`) |
| **v6 코드 사용** | 없음 (boot.php, Bootstrap, jQuery, func() 등 일절 미사용) |

### 경로 규칙

모든 관리자 페이지는 `/admin/**` 경로에서 서비스된다.

| URL | 파일 | 설명 |
|-----|------|------|
| `/admin` | `v7/admin/index.php` | 대시보드 |
| `/admin/users` | `v7/admin/users.php` | 회원 관리 |
| `/admin/boards` | `v7/admin/boards.php` | 게시판 관리 |
| `/admin/posts` | `v7/admin/posts.php` | 글 목록 관리 |
| `/admin/comments` | `v7/admin/comments.php` | 코멘트 관리 |
| `/admin/companies` | `v7/admin/companies.php` | 업소록 관리 |
| `/admin/settings` | `v7/admin/settings.php` | 설정 관리 |

---

## 2. 파일 구조

```
v7/admin/
├── admin-layout.php    ← 관리자 전용 HTML 레이아웃 (탑바 + 네비 + 콘텐츠)
├── admin.css           ← 관리자 전용 CSS (Bootstrap 없이 독립)
├── admin.js            ← 관리자 공통 JavaScript 유틸리티
├── index.php           ← 대시보드 (통계 카드 + 최근 글/회원)
├── users.php           ← 회원 관리 (검색 + 페이지네이션)
├── boards.php          ← 게시판 관리 (sf_post_config 목록)
├── posts.php           ← 글 목록 관리 (필터 + 검색 + 페이지네이션)
├── comments.php        ← 코멘트 관리 (검색 + 페이지네이션)
├── companies.php       ← 업소록 관리 (카테고리 필터 + 검색 + 페이지네이션)
└── settings.php        ← 설정 관리 (Config 값 읽기 전용 표시)
```

---

## 3. 라우팅 및 레이아웃 분기

### 라우팅 원리

v7 프론트 컨트롤러(`v7.php`)는 `v7/boot.php`를 로드한 후 `v7/layout.php`를 include한다.
`layout.php`에서 `Route::getInstance()->getPageFile()`로 페이지 파일을 찾아 `ob_start()`로 콘텐츠를 캡처한 뒤,
경로가 `/admin`으로 시작하면 관리자 전용 레이아웃으로 분기한다.

### Route 클래스 페이지 파일 해석

`Route::resolvePageFile()`는 다음 순서로 파일을 찾는다:

1. `v7/{path}.php` — 예: `/admin/users` → `v7/admin/users.php`
2. `v7/{path}/index.php` — 예: `/admin` → `v7/admin/index.php`

### 핵심 분기 소스코드 (`v7/layout.php` 52~56행)

```php
// 관리자 페이지: /admin/ 경로일 때 관리자 전용 레이아웃 사용
if (str_starts_with($route->getUri(), '/admin')) {
    include __DIR__ . '/admin/admin-layout.php';
    return;
}
```

이 분기 로직으로 `/admin/**` 경로는 5-column 레이아웃 대신 관리자 전용 레이아웃(`admin-layout.php`)을 사용한다.

---

## 4. 인증 시스템

### 인증 흐름

1. `AuthService::getLoginUser()` — 세션 쿠키(`session_id`)에서 사용자 정보 추출
2. 로그인 사용자의 `firebase_uid`를 `Config::admins()` 배열과 대조
3. 포함되면 `$isAdmin = true` → 관리자 콘텐츠 표시
4. 미포함이면 "접근 권한이 없습니다" 화면 표시

### 세션 인증 구조

| 항목 | 값 |
|------|-----|
| 쿠키명 | `session_id` |
| 형식 | `{MD5(LOGIN_SALT + idx + firebase_uid + phone_number)}-{idx}` |
| 검증 | `AuthService`가 쿠키 파싱 → `sf_member` 조회 → MD5 해시 비교 |

### 핵심 인증 소스코드 (`admin-layout.php` 20~26행)

```php
$loginUser = AuthService::getLoginUser();
$isAdmin = false;
if ($loginUser) {
    $firebaseUid = $loginUser['firebase_uid'] ?? '';
    $isAdmin = in_array($firebaseUid, Config::admins(), true);
}
```

### Config::admins() 구조

`v7/utils/Config.php`에서 `ADMINS` 상수(Firebase UID 배열)를 반환한다:

```php
public static function admins(): array
{
    return ADMINS; // v7/boot.php에서 정의된 상수
}
```

### 권한 없음 화면 (`admin-layout.php` 90~101행)

```php
<?php if (!$isAdmin): ?>
    <div class="admin-access-denied">
        <i class="fa-solid fa-lock" style="font-size: 3rem; color: #dc2626;"></i>
        <h2>접근 권한이 없습니다</h2>
        <?php if (!$loginUser): ?>
            <p>관리자 계정으로 로그인해 주세요.</p>
            <a href="/user/login" class="admin-btn admin-btn-primary">로그인</a>
        <?php else: ?>
            <p>관리자 권한이 있는 계정으로 로그인해 주세요.</p>
        <?php endif; ?>
    </div>
<?php endif; ?>
```

---

## 5. 관리자 레이아웃 (`admin-layout.php`)

### 파일 경로

`v7/admin/admin-layout.php`

### 구조

관리자 레이아웃은 v7 일반 레이아웃(5-column)과 **완전히 독립**된 HTML 문서를 생성한다.

```
┌─────────────────────────────────────────┐
│  탑바 (admin-topbar)                     │  ← sticky, #1e293b 배경
├─────────────────────────────────────────┤
│  네비게이션 탭 (admin-nav)               │  ← sticky, 흰색 배경, 수평 스크롤
├─────────────────────────────────────────┤
│                                         │
│  메인 콘텐츠 (admin-content)             │  ← max-width: 1200px, 중앙 정렬
│  <?= $content ?>                        │
│                                         │
└─────────────────────────────────────────┘
```

### 탑바

- 좌측: 필고 관리자 브랜드 로고 + 텍스트 (모바일에서 텍스트 숨김)
- 우측: 로그인 사용자 이름 + "홈으로" 링크

### 네비게이션 탭

7개 메뉴 항목으로 구성되며, 현재 경로에 따라 `active` 클래스를 적용한다.

```php
$navItems = [
    '/admin'           => ['label' => '대시보드', 'icon' => 'fa-solid fa-gauge'],
    '/admin/users'     => ['label' => '회원',     'icon' => 'fa-solid fa-users'],
    '/admin/boards'    => ['label' => '게시판',   'icon' => 'fa-solid fa-table-columns'],
    '/admin/posts'     => ['label' => '글 목록',  'icon' => 'fa-solid fa-file-lines'],
    '/admin/comments'  => ['label' => '코멘트',   'icon' => 'fa-solid fa-comments'],
    '/admin/companies' => ['label' => '업소록',   'icon' => 'fa-solid fa-store'],
    '/admin/settings'  => ['label' => '설정',     'icon' => 'fa-solid fa-gear'],
];
```

### 활성 탭 감지 로직 (`admin-layout.php` 107~111행)

```php
$isActive = ($currentPath === $path) ||
    ($path !== '/admin' && str_starts_with($currentPath, $path));
if ($path === '/admin' && $currentPath !== '/admin') $isActive = false;
```

- `/admin` 경로는 **정확 일치**만 활성화 (하위 경로에서 대시보드 탭 비활성)
- 다른 경로는 **접두사 일치**로 활성화 (`/admin/posts?page=2`에서 글 목록 탭 활성)

### `<head>` 리소스 로딩

```html
<!-- Web Awesome Pro (CSS + 컴포넌트) -->
<link rel="stylesheet" href="/v7/etc/dist-cdn/styles/webawesome.css">
<script type="module" src="/v7/etc/dist-cdn/webawesome.loader.js" data-webawesome="/v7/etc/dist-cdn"></script>

<!-- Font Awesome 7.2.0 -->
<link rel="stylesheet" href="/v7/etc/font-awesome/css/all.min.css">

<!-- 관리자 전용 CSS -->
<link rel="stylesheet" href="/v7/admin/admin.css?v=<?= CACHE_VERSION ?>">

<!-- Vue.js CDN -->
<script defer src="/v7/etc/vue/vue.global.prod.js"></script>

<!-- Axios + v7 API 호출 함수 -->
<script defer src="https://cdn.jsdelivr.net/npm/axios@1/dist/axios.min.js"></script>
<script defer src="/js/v7api.js"></script>

<!-- 관리자 공통 JS -->
<script defer src="/v7/admin/admin.js?v=<?= CACHE_VERSION ?>"></script>
```

### Hot-reload 지원 (`admin-layout.php` 127~129행)

```php
<?php if (Env::isDev()): ?>
    <?php include __DIR__ . '/../../etc/v7-hot-reload-client-code.php'; ?>
<?php endif; ?>
```

`__DIR__`이 `v7/admin/`이므로 `../../etc/`로 프로젝트 루트의 `etc/` 폴더에 접근한다.

---

## 6. 대시보드 페이지 (`index.php`)

### 파일 경로

`v7/admin/index.php` — URL: `/admin`

### 기능

- 4개 통계 카드: 전체 회원, 전체 글, 전체 코멘트, 전체 업소
- 오늘 신규 회원/글 수 표시 (카드 부제목에 "+N" 형태)
- 최근 글 10건 테이블
- 최근 가입 회원 10명 테이블

### 핵심 DB 쿼리

```php
$pdo = Db::pdo();

// 전체 통계
$totalUsers    = (int) $pdo->query("SELECT COUNT(*) FROM sf_member")->fetchColumn();
$totalPosts    = (int) $pdo->query("SELECT COUNT(*) FROM sf_post_data WHERE idx_parent = 0")->fetchColumn();
$totalComments = (int) $pdo->query("SELECT COUNT(*) FROM sf_post_data WHERE idx_parent > 0")->fetchColumn();
$totalCompanies= (int) $pdo->query("SELECT COUNT(*) FROM company")->fetchColumn();

// 오늘 통계 (stamp >= strtotime('today'))
$todayStart = strtotime('today');
$stmtTodayUsers = $pdo->prepare("SELECT COUNT(*) FROM sf_member WHERE stamp >= ?");
$stmtTodayUsers->execute([$todayStart]);
$todayUsers = (int) $stmtTodayUsers->fetchColumn();

// 최근 글 10건
$recentPosts = $pdo->query(
    "SELECT idx, subject, post_id, category, idx_member, stamp
     FROM sf_post_data WHERE idx_parent = 0
     ORDER BY idx DESC LIMIT 10"
)->fetchAll(\PDO::FETCH_ASSOC);

// 최근 가입 회원 10명
$recentUsers = $pdo->query(
    "SELECT idx, id, name, nickname, stamp
     FROM sf_member ORDER BY idx DESC LIMIT 10"
)->fetchAll(\PDO::FETCH_ASSOC);
```

### 통계 카드 HTML 패턴

```html
<div class="admin-stats-grid">
    <div class="admin-stat-card">
        <div class="admin-stat-icon users">
            <i class="fa-solid fa-users"></i>
        </div>
        <div class="admin-stat-info">
            <h3><?= number_format($totalUsers) ?></h3>
            <p>전체 회원 (오늘 +<?= number_format($todayUsers) ?>)</p>
        </div>
    </div>
    <!-- ... posts, comments, companies 동일 패턴 -->
</div>
```

아이콘 색상 클래스: `users`(파랑 #3b82f6), `posts`(초록 #10b981), `comments`(노랑 #f59e0b), `companies`(보라 #8b5cf6)

---

## 7. 회원 관리 페이지 (`users.php`)

### 파일 경로

`v7/admin/users.php` — URL: `/admin/users`

### 기능

- 검색: id, name, nickname, phone_number (LIKE 쿼리)
- 페이지네이션: 30건씩
- 테이블 컬럼: 번호(idx), 아이디(이메일), 닉네임, 이름, 전화번호, 가입일

### 핵심 쿼리 패턴

```php
$route = Route::getInstance();
$search = trim((string) $route->query('q', ''));
$page = max(1, (int) $route->query('page', 1));
$limit = 30;
$offset = ($page - 1) * $limit;

$where = '';
$params = [];
if ($search !== '') {
    $where = "WHERE (id LIKE :q OR name LIKE :q OR nickname LIKE :q OR phone_number LIKE :q)";
    $params['q'] = '%' . $search . '%';
}

$sql = "SELECT idx, id, name, nickname, phone_number, firebase_uid, stamp
        FROM sf_member $where
        ORDER BY idx DESC LIMIT $limit OFFSET $offset";
$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$users = $stmt->fetchAll(\PDO::FETCH_ASSOC);
```

### 페이지네이션 URL 함수 패턴

```php
function adminUserPageUrl(int $p, string $search): string
{
    $url = '/admin/users?page=' . $p;
    if ($search !== '') $url .= '&q=' . urlencode($search);
    return $url;
}
```

---

## 8. 게시판 관리 페이지 (`boards.php`)

### 파일 경로

`v7/admin/boards.php` — URL: `/admin/boards`

### 기능

- `sf_post_config` 테이블에서 게시판 설정 목록 조회
- 각 게시판별 글 수(idx_parent=0) 표시
- 테이블 컬럼: 게시판 ID(post_id), 이름(subject 또는 Config::boardName()), 설명, 글 수, 페이지당 글 수, 액션(글 보기 링크)

### 핵심 쿼리

```php
// 게시판 설정 목록
$boards = $pdo->query(
    "SELECT post_id, subject, description, no_of_post_in_list
     FROM sf_post_config ORDER BY post_id ASC"
)->fetchAll(\PDO::FETCH_ASSOC);

// 각 게시판별 글 수
$stmtCount = $pdo->prepare(
    "SELECT post_id, COUNT(*) as cnt
     FROM sf_post_data WHERE idx_parent = 0
     GROUP BY post_id"
);
$stmtCount->execute();
foreach ($stmtCount->fetchAll(\PDO::FETCH_ASSOC) as $row) {
    $postCounts[$row['post_id']] = (int) $row['cnt'];
}
```

### 게시판 이름 표시 로직

```php
<?= htmlspecialchars($board['subject'] ?: Config::boardName($boardId)) ?>
```

`sf_post_config.subject`가 비어있으면 `Config::boardName()`으로 대체 표시한다.

---

## 9. 글 목록 관리 페이지 (`posts.php`)

### 파일 경로

`v7/admin/posts.php` — URL: `/admin/posts`

### 기능

- 게시판 필터(post_id SELECT) + 제목/내용 검색
- 페이지네이션: 30건씩
- 테이블 컬럼: 번호, 제목, 게시판+카테고리, 작성자, 댓글 수, 조회 수, 날짜

### 핵심 쿼리

```php
$conditions = ['idx_parent = 0'];
$params = [];

if ($search !== '') {
    $conditions[] = "(subject LIKE :q OR content LIKE :q)";
    $params['q'] = '%' . $search . '%';
}
if ($postId !== '') {
    $conditions[] = "post_id = :post_id";
    $params['post_id'] = $postId;
}

$where = 'WHERE ' . implode(' AND ', $conditions);

$sql = "SELECT p.idx, p.subject, p.post_id, p.category, p.idx_member,
               p.no_of_comment, p.no_of_view, p.stamp,
               m.nickname AS author_nickname, m.name AS author_name
        FROM sf_post_data p
        LEFT JOIN sf_member m ON p.idx_member = m.idx
        $where
        ORDER BY p.idx DESC
        LIMIT $limit OFFSET $offset";
```

### 게시판 필터 드롭다운 쿼리

```php
$boardList = $pdo->query(
    "SELECT DISTINCT post_id FROM sf_post_data
     WHERE idx_parent = 0 AND post_id <> ''
     ORDER BY post_id"
)->fetchAll(\PDO::FETCH_COLUMN);
```

`post_id <> ''` 조건으로 빈 문자열 post_id를 필터에서 제외한다.

### 게시판 이름 표시

드롭다운 `<option>`에서 `Config::boardName($bid)`로 한글 게시판 이름을 표시한다:

```php
<option value="<?= htmlspecialchars($bid) ?>">
    <?= htmlspecialchars(Config::boardName($bid)) ?> (<?= htmlspecialchars($bid) ?>)
</option>
```

---

## 10. 코멘트 관리 페이지 (`comments.php`)

### 파일 경로

`v7/admin/comments.php` — URL: `/admin/comments`

### 기능

- 코멘트 내용 검색
- 페이지네이션: 30건씩
- 테이블 컬럼: 번호, 내용(미리보기 100자), 원글 제목, 작성자, 날짜

### 핵심 쿼리 — 테이블 별칭 필수

코멘트 쿼리는 JOINs를 사용하므로 **반드시 테이블 별칭(alias)으로 컬럼을 한정**해야 한다:

```php
// WHERE 조건 — 반드시 'c.' 별칭 사용
$conditions = ['c.idx_parent > 0'];
if ($search !== '') {
    $conditions[] = "(c.content LIKE :q)";
    $params['q'] = '%' . $search . '%';
}

// COUNT 쿼리 — 'c' 별칭 필수
$stmtCount = $pdo->prepare("SELECT COUNT(*) FROM sf_post_data c $where");

// 목록 쿼리 — LEFT JOIN으로 원글 제목 가져오기
$sql = "SELECT c.idx, c.content, c.idx_root, c.idx_member, c.stamp,
               m.nickname AS author_nickname, m.name AS author_name,
               p.subject AS parent_subject
        FROM sf_post_data c
        LEFT JOIN sf_member m ON c.idx_member = m.idx
        LEFT JOIN sf_post_data p ON c.idx_root = p.idx
        $where
        ORDER BY c.idx DESC
        LIMIT $limit OFFSET $offset";
```

### 코멘트 미리보기 함수

```php
function commentPreview(string $content): string
{
    $text = strip_tags($content);
    return mb_strlen($text) > 100 ? mb_substr($text, 0, 100) . '...' : $text;
}
```

### 원글 링크

`c.idx_root`로 원글 `idx`를 참조하여 `/post/view?id={idx_root}` 링크를 생성한다.

---

## 11. 업소록 관리 페이지 (`companies.php`)

### 파일 경로

`v7/admin/companies.php` — URL: `/admin/companies`

### 기능

- 카테고리 필터(Config::companyCategoryNames()) + 업소명/주소/전화번호 검색
- 페이지네이션: 30건씩
- 테이블 컬럼: 번호, 업소명, 카테고리, 주소, 전화번호, 상태(배지)

### 핵심 쿼리

```php
$conditions = [];
$params = [];

if ($search !== '') {
    $conditions[] = "(name LIKE :q OR address LIKE :q OR phone_number LIKE :q)";
    $params['q'] = '%' . $search . '%';
}
if ($category !== '') {
    $conditions[] = "category = :category";
    $params['category'] = $category;
}

$where = count($conditions) > 0 ? 'WHERE ' . implode(' AND ', $conditions) : '';

$sql = "SELECT idx, name, category, address, phone_number, status
        FROM company $where
        ORDER BY idx DESC LIMIT $limit OFFSET $offset";
```

### 카테고리 필터 드롭다운

```php
$categoryNames = Config::companyCategoryNames();
// Config 클래스에서 카테고리 key → 한글 이름 매핑 반환
```

### 업소 상태 배지 함수

```php
function companyStatusBadge(string $status): string
{
    $map = [
        'approved' => ['class' => 'admin-badge-green', 'label' => '승인'],
        'pending'  => ['class' => 'admin-badge-yellow', 'label' => '심사중'],
        'rejected' => ['class' => 'admin-badge-red', 'label' => '거절'],
    ];
    $info = $map[$status] ?? ['class' => 'admin-badge-gray', 'label' => $status ?: '-'];
    return '<span class="admin-badge ' . $info['class'] . '">'
         . htmlspecialchars($info['label']) . '</span>';
}
```

### company 테이블 컬럼명 주의

| 올바른 컬럼명 | 잘못된 이름 (사용 금지) |
|--------------|----------------------|
| `name` | `company_name` |
| `phone_number` | `phone` |
| `category` | `category_id` |
| `status` | `company_status` |

---

## 12. 설정 관리 페이지 (`settings.php`)

### 파일 경로

`v7/admin/settings.php` — URL: `/admin/settings`

### 기능

**읽기 전용** — Config 클래스의 정적 메서드를 통해 현재 설정 값을 표시한다.

### 표시 섹션

| 섹션 | 아이콘 | 표시 항목 |
|------|--------|----------|
| 시스템 정보 | `fa-solid fa-server` | 환경(개발/프로덕션), PHP 버전, 서버 시간, 타임존 |
| 서비스 정보 | `fa-solid fa-building` | 회사명, 서비스명, 도메인, 관리자 이메일, 관리자 이름 |
| 관리자 계정 | `fa-solid fa-shield-halved` | 관리자 UID 수, 각 Firebase UID |
| 은행 정보 | `fa-solid fa-building-columns` | 국민은행(KB) + BDO 은행 정보 |
| 업소록 카테고리 | `fa-solid fa-store` | 모든 카테고리 key + 한글 이름 + 아이콘 |
| 포인트 설정 | `fa-solid fa-coins` | 좋아요 포인트, 댓글 유효시간, 이벤트 설정 등 |

### 핵심 Config 메서드 호출 예시

```php
Config::philgoCompanyName()     // 회사명
Config::philgoServiceName()     // 서비스명
Config::philgoDomain()          // 도메인
Config::adminEmail()            // 관리자 이메일
Config::admins()                // 관리자 Firebase UID 배열
Config::kbName()                // 국민은행 이름
Config::kbAccountNo()           // 국민은행 계좌번호
Config::companyCategoryNames()  // 업소 카테고리 전체 목록
Config::companyCategoryIcon()   // 카테고리별 Font Awesome 아이콘
Config::pointForLike()          // 좋아요 포인트
Config::isPointEventDate()      // 오늘 이벤트 진행 여부
Env::isDev()                    // 개발 환경 여부
```

---

## 13. CSS 스타일 시스템 (`admin.css`)

### 파일 경로

`v7/admin/admin.css`

### 설계 원칙

- Bootstrap **없이** 순수 CSS로 관리자 UI 구현
- Web Awesome CSS 변수(`--wa-*`) 미사용 — 관리자 전용 커스텀 스타일
- 단일 CSS 파일로 관리자 전체 스타일 관리

### 색상 팔레트

| 용도 | 색상 | HEX |
|------|------|-----|
| 탑바 배경 | 슬레이트 | `#1e293b` |
| 탑바 텍스트 | 밝은 슬레이트 | `#f1f5f9` |
| 브랜드 아이콘 | 파랑 | `#60a5fa` |
| 활성 탭/Primary | 빨강 | `#dc2626` |
| 본문 배경 | 밝은 회색 | `#f3f4f6` |
| 카드/테이블 배경 | 흰색 | `#fff` |
| 테두리 | 연한 회색 | `#e5e7eb` |
| 보조 텍스트 | 회색 | `#6b7280` |

### 주요 CSS 클래스 목록

| 클래스 | 용도 |
|--------|------|
| `.admin-body` | body 기본 스타일 (font-family, background, margin 등) |
| `.admin-topbar` | 상단 탑바 (sticky, height: 48px) |
| `.admin-brand` | 브랜드 로고 + 텍스트 |
| `.admin-nav` | 네비게이션 탭 바 (sticky, top: 48px) |
| `.admin-nav-item` | 개별 네비 탭 아이템 |
| `.admin-nav-item.active` | 활성 탭 (빨간색 밑줄) |
| `.admin-content` | 메인 콘텐츠 영역 (max-width: 1200px) |
| `.admin-page-title` | 페이지 제목 (h1) |
| `.admin-stats-grid` | 통계 카드 그리드 (auto-fill, min 220px) |
| `.admin-stat-card` | 개별 통계 카드 |
| `.admin-stat-icon` | 통계 카드 아이콘 (color modifier: `.users`, `.posts`, `.comments`, `.companies`) |
| `.admin-panel` | 카드 패널 (header + body) |
| `.admin-panel-header` | 패널 헤더 (제목 + 액션 버튼) |
| `.admin-panel-body` | 패널 본문 |
| `.admin-table` | 데이터 테이블 |
| `.admin-toolbar` | 검색/필터 바 (flex, gap) |
| `.admin-search-input` | 검색 입력 필드 |
| `.admin-select` | 셀렉트 드롭다운 |
| `.admin-btn` | 기본 버튼 |
| `.admin-btn-primary` | 주요 버튼 (빨간색) |
| `.admin-btn-sm` | 작은 버튼 |
| `.admin-btn-danger` | 위험 버튼 |
| `.admin-pagination` | 페이지네이션 컨테이너 |
| `.admin-pagination .active` | 현재 페이지 (빨간색 배경) |
| `.admin-badge` | 배지 (pill 모양) |
| `.admin-badge-blue/green/yellow/red/gray` | 배지 색상 변형 |
| `.admin-settings-group` | 설정 그룹 컨테이너 |
| `.admin-settings-item` | 설정 항목 (label + value) |
| `.admin-access-denied` | 접근 거부 화면 |
| `.admin-empty` | 빈 상태 메시지 |
| `.truncate` | 텍스트 말줄임 (ellipsis) |

### 반응형 (모바일 대응)

```css
@media (max-width: 768px) {
    .admin-brand span { display: none; }         /* 브랜드 텍스트 숨김 */
    .admin-nav-item span { display: none; }       /* 네비 레이블 숨김 (아이콘만) */
    .admin-stats-grid { grid-template-columns: repeat(2, 1fr); }  /* 2열 그리드 */
    .admin-search-input { width: 100%; }          /* 전폭 검색 입력 */
    .admin-toolbar { flex-direction: column; align-items: stretch; }  /* 세로 정렬 */
}
```

---

## 14. JavaScript 유틸리티 (`admin.js`)

### 파일 경로

`v7/admin/admin.js`

### 함수 목록

```javascript
/**
 * Unix timestamp를 날짜 문자열로 변환
 * @param {number} stamp - Unix timestamp
 * @returns {string} 'YYYY-MM-DD HH:mm' 형식
 */
function adminFormatDate(stamp) {
    if (!stamp) return '-';
    var d = new Date(stamp * 1000);
    var y = d.getFullYear();
    var m = String(d.getMonth() + 1).padStart(2, '0');
    var day = String(d.getDate()).padStart(2, '0');
    var h = String(d.getHours()).padStart(2, '0');
    var min = String(d.getMinutes()).padStart(2, '0');
    return y + '-' + m + '-' + day + ' ' + h + ':' + min;
}

/**
 * 숫자를 천 단위 콤마 포맷
 * @param {number} num
 * @returns {string}
 */
function adminFormatNumber(num) {
    if (num === null || num === undefined) return '0';
    return Number(num).toLocaleString('ko-KR');
}
```

---

## 15. DB 테이블 참조

관리자 페이지에서 직접 쿼리하는 테이블과 주요 컬럼:

### sf_member (회원)

| 컬럼 | 타입 | 용도 |
|------|------|------|
| `idx` | int | PK |
| `id` | varchar | 이메일(아이디) |
| `name` | varchar | 이름 |
| `nickname` | varchar | 닉네임 |
| `phone_number` | varchar | 전화번호 |
| `firebase_uid` | varchar | Firebase UID (관리자 인증에 사용) |
| `stamp` | int | 가입 Unix timestamp |

### sf_post_data (게시글/코멘트)

| 컬럼 | 타입 | 용도 |
|------|------|------|
| `idx` | int | PK |
| `idx_parent` | int | 0=글, >0=코멘트(부모 글 idx) |
| `idx_root` | int | 원글 idx (코멘트가 속한 최상위 글) |
| `idx_member` | int | 작성자 sf_member.idx |
| `post_id` | varchar | 게시판 ID |
| `category` | varchar | 카테고리 |
| `subject` | varchar | 제목 |
| `content` | text | 내용 |
| `no_of_comment` | int | 댓글 수 |
| `no_of_view` | int | 조회 수 |
| `stamp` | int | 작성 Unix timestamp |

### sf_post_config (게시판 설정)

| 컬럼 | 타입 | 용도 |
|------|------|------|
| `post_id` | varchar | 게시판 ID (PK) |
| `subject` | varchar | 게시판 이름 |
| `description` | varchar | 게시판 설명 |
| `no_of_post_in_list` | int | 페이지당 글 수 |

### company (업소)

| 컬럼 | 타입 | 용도 |
|------|------|------|
| `idx` | int | PK |
| `name` | varchar | 업소명 |
| `category` | varchar | 카테고리 키 |
| `address` | varchar | 주소 |
| `phone_number` | varchar | 전화번호 |
| `status` | varchar | 상태 (approved/pending/rejected) |

---

## 16. 공통 코딩 패턴

### 페이지 구조 패턴

모든 관리자 페이지는 동일한 구조를 따른다:

```php
<?php
use Philgo\Utils\Db;
use Philgo\Utils\Seo;
use V7\Utils\Route;

Seo::title('페이지명 - 필고 관리자');

$route = Route::getInstance();
$pdo = Db::pdo();

// 1. 파라미터 추출
$search = trim((string) $route->query('q', ''));
$page = max(1, (int) $route->query('page', 1));
$limit = 30;
$offset = ($page - 1) * $limit;

// 2. WHERE 조건 구성
$conditions = [];
$params = [];
if ($search !== '') { /* 조건 추가 */ }
$where = count($conditions) > 0 ? 'WHERE ' . implode(' AND ', $conditions) : '';

// 3. 총 개수 조회
$stmtCount = $pdo->prepare("SELECT COUNT(*) FROM 테이블 $where");
$stmtCount->execute($params);
$totalCount = (int) $stmtCount->fetchColumn();
$totalPages = max(1, (int) ceil($totalCount / $limit));

// 4. 목록 조회
$stmt = $pdo->prepare("SELECT ... FROM 테이블 $where ORDER BY idx DESC LIMIT $limit OFFSET $offset");
$stmt->execute($params);
$rows = $stmt->fetchAll(\PDO::FETCH_ASSOC);

// 5. 페이지네이션 URL 함수
function adminXxxPageUrl(int $p, string $search): string { /* ... */ }
?>

<!-- 6. HTML: 제목 + 검색 툴바 + 테이블 + 페이지네이션 -->
```

### 검색 툴바 HTML 패턴

```html
<form method="get" action="/admin/xxx" class="admin-toolbar">
    <input type="text" name="q" value="<?= htmlspecialchars($search) ?>"
           placeholder="검색..." class="admin-search-input">
    <button type="submit" class="admin-btn admin-btn-primary">
        <i class="fa-solid fa-magnifying-glass"></i> 검색
    </button>
    <?php if ($search !== ''): ?>
        <a href="/admin/xxx" class="admin-btn">초기화</a>
    <?php endif; ?>
    <span style="color: #6b7280; font-size: 0.85rem; margin-left: auto;">
        총 <?= number_format($totalCount) ?>건
    </span>
</form>
```

### 페이지네이션 HTML 패턴

```html
<?php if ($totalPages > 1): ?>
    <div class="admin-pagination">
        <?php if ($page > 1): ?>
            <a href="<?= adminXxxPageUrl(1, $search) ?>">&laquo;</a>
            <a href="<?= adminXxxPageUrl($page - 1, $search) ?>">&lsaquo;</a>
        <?php endif; ?>

        <?php
        $startPage = max(1, $page - 4);
        $endPage = min($totalPages, $page + 4);
        for ($p = $startPage; $p <= $endPage; $p++):
        ?>
            <?php if ($p === $page): ?>
                <span class="active"><?= $p ?></span>
            <?php else: ?>
                <a href="<?= adminXxxPageUrl($p, $search) ?>"><?= $p ?></a>
            <?php endif; ?>
        <?php endfor; ?>

        <?php if ($page < $totalPages): ?>
            <a href="<?= adminXxxPageUrl($page + 1, $search) ?>">&rsaquo;</a>
            <a href="<?= adminXxxPageUrl($totalPages, $search) ?>">&raquo;</a>
        <?php endif; ?>
    </div>
<?php endif; ?>
```

### XSS 방어

모든 사용자 데이터 출력 시 `htmlspecialchars()` 필수 사용:

```php
<?= htmlspecialchars($user['name'] ?? '') ?>
<?= htmlspecialchars($post['subject'] ?: '(제목 없음)') ?>
```

### SQL Injection 방어

모든 사용자 입력은 prepared statement로 처리:

```php
$params['q'] = '%' . $search . '%';   // 바인딩 파라미터
$stmt = $pdo->prepare($sql);
$stmt->execute($params);              // 파라미터 바인딩 실행
```

`$limit`과 `$offset`은 `(int)` 캐스팅으로 안전하게 SQL에 직접 삽입한다.

---

## 17. 새 관리자 페이지 추가 방법

1. `v7/admin/` 폴더에 새 PHP 파일 생성 (예: `v7/admin/logs.php`)
2. `admin-layout.php`의 `$navItems` 배열에 메뉴 항목 추가:

```php
$navItems = [
    // ... 기존 항목
    '/admin/logs' => ['label' => '로그', 'icon' => 'fa-solid fa-list-check'],
];
```

3. 페이지 PHP 파일에서 공통 패턴 따르기:
   - `use Philgo\Utils\Db;` + `use Philgo\Utils\Seo;`
   - `Seo::title('페이지명 - 필고 관리자');`
   - `$pdo = Db::pdo();` 로 DB 접근
   - 검색/필터/페이지네이션 패턴 적용

4. Route 해석은 자동 — `v7/admin/logs.php`가 존재하면 `/admin/logs` URL로 접근 가능

5. 이 문서 업데이트 — 새 페이지 정보를 목차와 해당 섹션에 추가
