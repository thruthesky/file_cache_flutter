# v7 도움말 페이지

## 목차

1. [개요](#1-개요)
2. [게시판 별 포인트 안내 페이지](#2-게시판-별-포인트-안내-페이지)
3. [이용안내 페이지](#3-이용안내-페이지)
4. [개인정보 처리방침 페이지](#4-개인정보-처리방침-페이지)
5. [이용약관 페이지](#5-이용약관-페이지)
6. [포인트 이벤트 날짜 페이지](#6-포인트-이벤트-날짜-페이지)
7. [파일 구조](#7-파일-구조)
8. [URL 라우팅](#8-url-라우팅)
9. [DB 쿼리](#9-db-쿼리)
10. [디자인 패턴](#10-디자인-패턴)

---

## 1. 개요

v7 도움말 페이지는 `v7/help/` 폴더에 위치하며, 사용자에게 포인트 정책, 이용약관, 개인정보처리방침, 포인트 이벤트 등의 안내 정보를 제공한다.
v6 `page/help/` 폴더의 로직을 v7 아키텍처(Web Awesome Pro, Db 클래스, url() 함수)로 100% 재작성한 것이다.

| 페이지 | URL | 설명 |
|--------|-----|------|
| 게시판 별 포인트 안내 | `/help/point-guideline` | sf_post_config 테이블 기반 게시판별 포인트 안내 |
| 이용안내 | `/help/guideline` | wa-details 아코디언 기반 사이트 이용안내 |
| 개인정보 처리방침 | `/help/privacy` | 12개 조항의 개인정보 처리방침 (wa-details) |
| 이용약관 | `/help/terms` | 6개 장 15개 조항의 이용약관 (wa-details) |
| 포인트 이벤트 | `/help/point-event` | Config::pointEventDates() 기반 이벤트 일정 |

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

## 4. 개인정보 처리방침 페이지

### 접속 URL

- **v7**: `https://v7-local.philgo.com/help/privacy`
- **v6 원본**: `https://local.philgo.com/page/help/privacy.php`

### 기능

v6 개인정보처리방침 페이지를 v7 아키텍처로 이식한 법적 문서 페이지이다.
Web Awesome `wa-details` 아코디언 컴포넌트로 12개 조항을 표시한다.

포함 조항:
1. **제1조** — 수집하는 개인정보의 항목 (필수/선택/자동수집)
2. **제2조** — 개인정보의 수집 및 이용목적
3. **제3조** — 개인정보의 보유 및 이용기간
4. **제4조** — 개인정보의 파기절차 및 방법
5. **제5조** — 개인정보의 제3자 제공
6. **제6조** — 개인정보의 위탁
7. **제7조** — 정보주체의 권리/의무 및 행사방법
8. **제8조** — 개인정보의 안전성 확보 조치
9. **제9조** — 개인정보 보호책임자 (`Config::adminName()`, `Config::adminEmail()`)
10. **제10조** — 개인정보 처리방침 변경
11. **제11조** — 권익침해 구제방법
12. **제12조** — 쿠키의 운영

### 디자인 특징

- **CSS 클래스 접두사**: `.legal-*` (이용약관과 공유)
- **조항 번호 배지**: `.legal-badge` (파란색 둥근 배지)
- **정보 카드**: `.legal-info-card` (보호책임자 정보 등)
- **아코디언**: `<wa-details class="legal-item">` 컴포넌트
- **브레드크럼**: 홈 > 메뉴 > 개인정보 처리방침

### 핵심 소스코드

```php
use V7\Utils\Config;

$adminName = Config::adminName();
$adminEmail = Config::adminEmail();

// 각 조항은 wa-details 아코디언으로 표시
<wa-details class="legal-item">
    <span slot="summary" class="legal-summary">
        <span class="legal-badge">제1조</span> 수집하는 개인정보의 항목
    </span>
    <div class="legal-content">...</div>
</wa-details>
```

---

## 5. 이용약관 페이지

### 접속 URL

- **v7**: `https://v7-local.philgo.com/help/terms`
- **v6 원본**: `https://local.philgo.com/page/help/terms-and-conditions.php`

### 기능

v6 이용약관 페이지를 v7 아키텍처로 이식한 법적 문서 페이지이다.
6개 장, 15개 조항으로 구성되며, Web Awesome `wa-details` 아코디언과 `<h2>` 장 제목으로 구조화한다.

장 구성:
1. **제1장 총칙** — 목적(제1조), 약관의 효력 및 변경(제2조), 용어의 정의(제3조)
2. **제2장 서비스 이용계약** — 이용계약의 성립(제4조), 이용신청(제5조), 이용신청의 승낙(제6조), 이용자정보의 변경(제7조)
3. **제3장 계약 당사자의 의무** — 본사의 의무(제8조), 회원의 의무(제9조)
4. **제4장 서비스 제공 및 이용** — 회원 로그인 정보 관리(제10조), 서비스 제한 및 정지(제11조)
5. **제5장 계약사항의 변경, 해지** — 정보의 변경(제12조), 계약사항의 해지(제13조)
6. **제6장 손해배상** — 면책조항(제14조), 관할법원(제15조)

### 디자인 특징

- **CSS 클래스 접두사**: `.legal-*` (개인정보처리방침과 공유)
- **장 제목**: `<h2 class="legal-chapter">` (아이콘 + 장 제목)
- **조항 번호 배지**: `.legal-badge`
- **첫 번째 조항 기본 열림**: `<wa-details class="legal-item" open>`
- **부칙**: `.legal-supplementary` 영역에 시행일 표시

### 핵심 소스코드

```php
use V7\Utils\Config;

$companyName = Config::philgoCompanyName();
$serviceName = Config::philgoServiceName();

// 장 제목
<h2 class="legal-chapter"><i class="fa-solid fa-bookmark"></i> 제 1 장 총 칙</h2>

// 각 조항은 wa-details 아코디언으로 표시
<wa-details class="legal-item" open>
    <span slot="summary" class="legal-summary">
        <span class="legal-badge">제1조</span> 목적
    </span>
    <div class="legal-content">...</div>
</wa-details>
```

---

## 6. 포인트 이벤트 날짜 페이지

### 접속 URL

- **v7**: `https://v7-local.philgo.com/help/point-event`

### 기능

`Config::pointEventDates()`에서 포인트 이벤트 날짜를 가져와서 오늘 이후의 이벤트만 표시한다.

주요 기능:
1. **이벤트 상태 표시** — `Config::isPointEventDate()`로 오늘이 이벤트 기간인지 확인하여 `wa-callout`으로 상태 표시
2. **날짜 필터링** — 끝 날짜가 오늘 이후인 이벤트만 필터링 (진행 중 + 미래)
3. **날짜 포맷팅** — `formatEventDate()` 함수로 Ymd 정수를 "2024년 3월 14일(목)" 형식으로 변환
4. **진행 중 표시** — 현재 진행 중인 이벤트에 `wa-badge variant="success"` 배지 표시
5. **빈 상태** — 예정된 이벤트가 없을 때 빈 상태 UI 표시

### 디자인 특징

- **CSS 클래스 접두사**: `.pe-*` (point-event)
- **이벤트 상태**: `wa-callout variant="success"` (이벤트 중) / `wa-callout variant="neutral"` (이벤트 아님)
- **날짜 카드**: `.pe-date-item` (진행 중이면 `.pe-date-active` 추가)
- **안내 사항**: 포인트 배율, 남용 방지, 일정 변경 안내
- **브레드크럼**: 홈 > 메뉴 > 포인트 이벤트

### 핵심 소스코드

```php
use V7\Utils\Config;

// 오늘 날짜 (Ymd 형식의 정수)
$today = (int) date('Ymd');

// 포인트 이벤트 날짜 가져오기 (오늘 이후만 필터링)
$allDates = Config::pointEventDates();
$futureDates = [];
foreach ($allDates as $range) {
    if ($range[1] >= $today) {
        $futureDates[] = $range;
    }
}

// 오늘이 이벤트 기간인지 확인
$isEventToday = Config::isPointEventDate();

// Ymd 정수를 읽기 쉬운 날짜 문자열로 변환
function formatEventDate(int $ymd): string
{
    $y = (int) substr((string) $ymd, 0, 4);
    $m = (int) substr((string) $ymd, 4, 2);
    $d = (int) substr((string) $ymd, 6, 2);
    $dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'];
    $w = $dayOfWeek[(int) date('w', mktime(0, 0, 0, $m, $d, $y))];
    return "{$y}년 {$m}월 {$d}일({$w})";
}
```

---

## 7. 파일 구조

| 파일 | 용도 |
|------|------|
| `v7/help/point-guideline.php` | 게시판 별 포인트 안내 페이지 (SSR) |
| `v7/help/point-guideline.css` | 포인트 안내 페이지 전용 CSS |
| `v7/help/guideline.php` | 이용안내 페이지 (wa-details 아코디언) |
| `v7/help/guideline.css` | 이용안내 페이지 전용 CSS |
| `v7/help/privacy.php` | 개인정보 처리방침 페이지 (12개 조항, wa-details) |
| `v7/help/privacy.css` | 개인정보 처리방침 페이지 전용 CSS (`.legal-*` 클래스) |
| `v7/help/terms.php` | 이용약관 페이지 (6개 장, 15개 조항, wa-details) |
| `v7/help/terms.css` | 이용약관 페이지 전용 CSS (`.legal-*` 클래스) |
| `v7/help/point-event.php` | 포인트 이벤트 날짜 페이지 (Config 기반) |
| `v7/help/point-event.css` | 포인트 이벤트 날짜 페이지 전용 CSS (`.pe-*` 클래스) |
| `v7/layout.php` | `/help` 경로에서 CSS 조건부 로드 |
| `tests/Unit/PointGuidelinePageTest.php` | PEST 유닛 테스트 (8개 케이스) |

---

## 8. URL 라우팅

`v7/utils/Url.php`의 `HelpUrl` 클래스에 정의되어 있다.

```php
class HelpUrl
{
    public string $guideline = '/help/guideline';
    public string $terms = '/help/terms';
    public string $privacy = '/help/privacy';
    public string $pointGuideline = '/help/point-guideline';
    public string $pointEvent = '/help/point-event';
}

// 사용법
url()->help->pointGuideline  // '/help/point-guideline'
url()->help->guideline        // '/help/guideline'
url()->help->terms            // '/help/terms'
url()->help->privacy          // '/help/privacy'
url()->help->pointEvent       // '/help/point-event'
```

---

## 9. DB 쿼리

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

## 10. 디자인 패턴

- **UI 프레임워크**: Web Awesome Pro v3.3.1 (Bootstrap 미사용)
- **아이콘**: Font Awesome Pro v7.2.0
- **색상 테마**: 블루 기본 (Web Awesome default theme)
- **다크 모드**: 미적용 (라이트 모드 전용)
- **CSS 클래스 네이밍**: `.point-guideline-page`, `.pg-*` 접두사
- **반응형**: 992px 미만에서 모바일 대응 (테이블 가로 스크롤)

### CSS 클래스 목록

#### 포인트 안내 페이지 (`.pg-*`)

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

#### 법적 문서 페이지 — 개인정보처리방침 + 이용약관 공통 (`.legal-*`)

| 클래스 | 용도 |
|--------|------|
| `.legal-page` | 페이지 컨테이너 |
| `.legal-header` | 페이지 헤더 (아이콘 + 제목 + 시행일) |
| `.legal-effective` | 시행일 텍스트 |
| `.legal-intro` | 서문 영역 |
| `.legal-articles` | 조항 목록 컨테이너 |
| `.legal-item` | 개별 조항 (`wa-details`) |
| `.legal-summary` | 조항 제목 (배지 + 조항명) |
| `.legal-badge` | 조항 번호 배지 (파란색 둥근 배지) |
| `.legal-content` | 조항 내용 |
| `.legal-chapter` | 장 제목 (이용약관에서 사용) |
| `.legal-info-card` | 정보 카드 (보호책임자 등) |
| `.legal-supplementary` | 부칙 영역 |

#### 포인트 이벤트 페이지 (`.pe-*`)

| 클래스 | 용도 |
|--------|------|
| `.point-event-page` | 페이지 컨테이너 |
| `.pe-header` | 페이지 헤더 |
| `.pe-dates` | 이벤트 날짜 목록 영역 |
| `.pe-date-list` | 날짜 카드 리스트 |
| `.pe-date-item` | 개별 날짜 카드 |
| `.pe-date-active` | 진행 중인 이벤트 카드 (강조 스타일) |
| `.pe-date-icon` | 날짜 카드 아이콘 |
| `.pe-date-text` | 날짜 카드 텍스트 |
| `.pe-date-range` | 날짜 범위 텍스트 |
| `.pe-empty` | 빈 상태 UI |
| `.pe-info` | 안내 사항 영역 |
