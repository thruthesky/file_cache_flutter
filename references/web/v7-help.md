# v7 도움말 페이지

## 목차

1. [개요](#1-개요)
2. [게시판 별 포인트 안내 페이지](#2-게시판-별-포인트-안내-페이지)
3. [이용안내 페이지](#3-이용안내-페이지)
4. [파일 구조](#4-파일-구조)
5. [URL 라우팅](#5-url-라우팅)
6. [DB 쿼리](#6-db-쿼리)
7. [디자인 패턴](#7-디자인-패턴)

---

## 1. 개요

v7 도움말 페이지는 `v7/help/` 폴더에 위치하며, 사용자에게 포인트 정책, 이용약관 등의 안내 정보를 제공한다.
v6 `page/help/` 폴더의 로직을 v7 아키텍처(Web Awesome Pro, Db 클래스, url() 함수)로 100% 재작성한 것이다.

---

## 2. 게시판 별 포인트 안내 페이지

### 접속 URL

- **v7**: `https://v7-local.philgo.com/help/point-guideline`
- **v6 원본**: `https://local.philgo.com/page/help/point-guideline.php`

### 기능

- `sf_post_config` 테이블에서 포인트가 설정된 게시판만 조회
- 게시판별 글 쓰기/삭제, 코멘트 쓰기/삭제 포인트를 테이블로 표시
- 포인트 값 색상 포맷팅: 양수(초록), 음수(빨강), 0(회색)
- 게시판 이름 클릭 시 해당 게시판 목록으로 이동
- Web Awesome `wa-callout` 컴포넌트로 안내 카드 표시

### 핵심 소스코드

```php
// DB 쿼리 — Philgo\Utils\Db 사용
$pdo = Db::pdo();
$stmt = $pdo->prepare("
    SELECT post_id, subject, point_write, point_write_delete,
           point_comment, point_comment_delete
    FROM sf_post_config
    WHERE point_write <> 0
       OR point_write_delete <> 0
       OR point_comment <> 0
       OR point_comment_delete <> 0
    ORDER BY subject ASC
");
$stmt->execute();
$configs = $stmt->fetchAll(\PDO::FETCH_ASSOC);

// 포인트 값 포맷팅
function v7_format_point_value(int $point): string
{
    if ($point > 0) {
        return '<span class="point-earned">+' . number_format($point) . '</span>';
    } elseif ($point < 0) {
        return '<span class="point-deducted">' . number_format($point) . '</span>';
    }
    return '<span class="point-none">0</span>';
}

// 게시판 목록 링크 생성 — Route::postList() 사용
<a href="<?= Route::postList($row['post_id']) ?>">
```

---

## 3. 이용안내 페이지

### 접속 URL

- **v7**: `https://v7-local.philgo.com/help/guideline`
- **v6 원본**: `https://local.philgo.com/page/help/guideline.php`

### 기능

v6 이용안내 페이지의 주요 항목을 Web Awesome `wa-details` 아코디언 컴포넌트로 표시한다.

포함 항목:
1. **문의하기** — 운영자 이메일/이름 (`Config::adminEmail()`, `Config::adminName()`)
2. **포인트 구매 안내** — 은행 계좌 정보 (`Config::kbName()`, `Config::bdoName()` 등)
3. **게시판 별 포인트 안내** — `url()->help->pointGuideline` 링크
4. **포인트 이벤트** — `Config::pointEventDates()`로 이벤트 기간 표시
5. **포인트 광고 등록** — 포인트 광고 사용 방법 안내
6. **글 등록: 유튜브 추가하기** — 유튜브 링크 붙여넣기 방법
7. **구인 구직 글 등록 안내** — 규정(5개 항목) + 작성 예제
8. **업소록 관리 안내** — QR코드 발행 제한/만료 안내

### 핵심 소스코드

```php
// Config 클래스를 통해 설정값 접근 (v6 레거시 직접 호출 방지)
use V7\Utils\Config;

// 포인트 이벤트 날짜 조회
$eventDates = Config::pointEventDates();

// 은행 정보
Config::kbName();        // '국민은행'
Config::kbAccountNo();   // 계좌번호
Config::bdoName();       // 'BDO'

// 관리자 정보
Config::adminEmail();    // 'philgohelp@gmail.com'
Config::adminName();     // '송재호'
```

### 디자인 특징

- **아코디언**: `<wa-details>` Web Awesome 컴포넌트 사용
- **아이콘**: Font Awesome Light(`fal`) 아이콘 + 색상별 배경 래퍼
- **보더리스**: 연한 배경색(`#f8fafc`)으로 영역 구분, 보더 없음
- **CSS 클래스**: `.guideline-page`, `.guideline-item`, `.guideline-summary`, `.guideline-icon-*`

---

## 4. 파일 구조

| 파일 | 용도 |
|------|------|
| `v7/help/point-guideline.php` | 게시판 별 포인트 안내 페이지 (SSR) |
| `v7/help/point-guideline.css` | 포인트 안내 페이지 전용 CSS |
| `v7/help/guideline.php` | 이용안내 페이지 (wa-details 아코디언) |
| `v7/help/guideline.css` | 이용안내 페이지 전용 CSS |
| `v7/layout.php` | `/help` 경로에서 CSS 조건부 로드 |
| `tests/Unit/PointGuidelinePageTest.php` | PEST 유닛 테스트 (8개 케이스) |

---

## 5. URL 라우팅

`v7/utils/Url.php`의 `HelpUrl` 클래스에 정의되어 있다.

```php
class HelpUrl
{
    public string $guideline = '/help/guideline';
    public string $terms = '/help/terms';
    public string $pointGuideline = '/help/point-guideline';
    public string $pointEvent = '/help/point-event';
}

// 사용법
url()->help->pointGuideline  // '/help/point-guideline'
url()->help->guideline        // '/help/guideline'
```

---

## 6. DB 쿼리

### sf_post_config 테이블 (포인트 관련 컬럼)

| 컬럼명 | 타입 | 설명 |
|--------|------|------|
| `post_id` | varchar(64) | 게시판 ID (PK) |
| `subject` | varchar(255) | 게시판 제목 |
| `point_write` | int(11) | 글 작성 포인트 (양수=획득, 음수=차감) |
| `point_write_delete` | int(11) | 글 삭제 시 포인트 |
| `point_comment` | int(11) | 코멘트 작성 포인트 |
| `point_comment_delete` | int(11) | 코멘트 삭제 시 포인트 |

---

## 7. 디자인 패턴

- **UI 프레임워크**: Web Awesome Pro v3.3.1 (Bootstrap 미사용)
- **아이콘**: Font Awesome Pro v7.2.0
- **색상 테마**: 블루 기본 (Web Awesome default theme)
- **다크 모드**: 미적용 (라이트 모드 전용)
- **CSS 클래스 네이밍**: `.point-guideline-page`, `.pg-*` 접두사
- **반응형**: 992px 미만에서 모바일 대응 (테이블 가로 스크롤)

### CSS 클래스 목록

| 클래스 | 용도 |
|--------|------|
| `.point-guideline-page` | 페이지 컨테이너 |
| `.pg-header` | 페이지 헤더 (아이콘 + 제목) |
| `.pg-legend` | 포인트 색상 범례 |
| `.pg-table` | 포인트 테이블 |
| `.pg-col-point` | 포인트 컬럼 (가운데 정렬) |
| `.pg-board-name` | 게시판 이름 셀 |
| `.point-earned` | 양수 포인트 (초록색) |
| `.point-deducted` | 음수 포인트 (빨간색) |
| `.point-none` | 0 포인트 (회색) |
