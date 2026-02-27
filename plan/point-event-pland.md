# 먹방 이벤트 포인트 기능 개발 계획

## 목차

1. [개요](#1-개요)
2. [CoT (Chain-of-Thought) 분석](#2-cot-chain-of-thought-분석)
3. [ToT (Tree-of-Thought) 분석](#3-tot-tree-of-thought-분석)
4. [v7 PHP 백엔드 설계](#4-v7-php-백엔드-설계)
5. [Flutter 앱 설계](#5-flutter-앱-설계)
6. [데이터베이스 설계](#6-데이터베이스-설계)
7. [포인트 이벤트 로직 상세](#7-포인트-이벤트-로직-상세)
8. [영수증 검증 로직](#8-영수증-검증-로직)
9. [파일 목록 및 수정 계획](#9-파일-목록-및-수정-계획)
10. [구현 순서](#10-구현-순서)
11. [테스트 계획](#11-테스트-계획)

---

## 1. 개요

### 1.1 기능 설명

필리핀에서 한국 음식점 등에서 식사 후, 먹방 후기 글(제목 + 먹방 사진 + 내용)을 등록하고
영수증을 별도 첨부하면 랜덤 포인트를 지급하는 이벤트 기능.

**핵심 원칙**: 먹방 이벤트 = 먹방 후기 **글 등록**이다.
글 생성과 이벤트 포인트가 **하나의 API**에서 같이 동작한다.

### 1.2 핵심 요구사항

| 항목 | 내용 |
|------|------|
| 게시판 | post_id: `freetalk`, category: `먹방` |
| 필수 입력 | 제목, 영수증 사진(별도), 먹방 사진/동영상, 내용 |
| 영수증 처리 | **글의 files에 첨부하지 않음** (별도 검증용) |
| 포인트 | 기본 1,000~2,000 랜덤, ≥1,900이면 보너스 2,000~10,000 |
| 주간 제한 | 7일 이내 3개 이하 등록 시에만 포인트 지급 (최대 4회) |
| 영수증 검증 | 24시간 이내 + 필리핀 업소 |
| 삭제 정책 | 글 삭제 시 지급 포인트 차감 (이벤트 횟수는 유지) |
| 글 수정 | **일반 글 수정 화면(PostUpdateScreen)과 100% 동일** |
| 홈 메뉴 | 퀵메뉴에 "내 정보" 다음, "필독 정보" 앞에 배치 |

### 1.3 전체 플로우

```
홈 → 먹방 이벤트 클릭 → 먹방 글 등록 화면
    → 제목, 영수증(별도), 먹방 사진, 내용 입력
    → 저장 클릭
    → 먹방 글 생성 API 호출 (단일 API)
        → 글 생성 (기존 PostService::create() 로직 참고)
        → 영수증은 글에 첨부하지 않음
        → 영수증 검증 (24시간 이내 + 필리핀)
        → 주간 횟수 확인 (3개 이하)
        → 랜덤 포인트 지급
    → 먹방 글 읽기 화면 (PostViewScreen)
```

### 1.4 기술 스택

- **프론트엔드**: Flutter (MukbangEventScreen, V7FileUpload 재활용)
- **백엔드**: PHP v7 시스템 (PointEvent 모듈 신규 생성)
- **API 통신**: v7api() + MukbangEventApi 래퍼 클래스

---

## 2. CoT (Chain-of-Thought) 분석

### 2.1 (1단계) 문제의 핵심 이해

**먹방 이벤트 = 먹방 후기 글 등록.**

기존 게시판 글 생성(PostService::create())과의 차이점:

| 비교 항목 | 일반 글 생성 | 먹방 이벤트 글 생성 |
|-----------|-------------|-------------------|
| API | post.create | pointEvent.createMukbang (신규) |
| 글 생성 | PostService::create() | PostService::create() **재활용** |
| 포인트 | 고정값 (sf_post_config) | 랜덤 (1,000~2,000) + 보너스 |
| 영수증 | 없음 | 별도 업로드 + AI 검증 |
| 횟수 제한 | 없음 | 주간 4회 (3개 이하일 때 등록 가능) |
| 글 수정 | PostUpdateScreen | **동일한 PostUpdateScreen** |

**결론**: 새 API(`pointEvent.createMukbang`)를 만들되, 내부에서 기존 `PostService::create()`를 직접 호출하여 글을 생성한다. 그 후 영수증 검증 + 포인트 지급을 추가 수행한다.

### 2.2 (2단계) 단일 API 전략

```
[Flutter 앱]
    │
    └─ pointEvent.createMukbang API 호출 (단일 API)
        │
        ├─ (1) PostService::create() 호출 → 게시글 생성
        │      post_id='freetalk', category='먹방'
        │      files = 먹방 사진 URL만 (영수증 제외)
        │
        ├─ (2) 영수증 검증 (날짜 + 국가)
        │      → 실패 시: 글은 생성되었지만 포인트 없음
        │
        ├─ (3) 주간 횟수 확인 (3개 이하)
        │      → 초과 시: 글은 생성되었지만 포인트 없음
        │
        ├─ (4) 랜덤 포인트 계산 + 보너스
        │
        ├─ (5) 포인트 지급 + 로그 기록
        │
        └─ 응답: 게시글 정보 + 포인트 정보
```

**장점:**
- Flutter에서 한 번의 API 호출로 글 생성 + 이벤트 처리 완료
- 기존 PostService::create()를 그대로 재활용
- 글 수정은 일반 PostUpdateScreen과 100% 동일 (추가 개발 불필요)

### 2.3 (3단계) 기존 코드 참고하되 독립적 설계

기존 PostService::create()를 내부에서 직접 호출하여 글 생성 로직을 재활용.
이벤트 포인트 로직은 PointEventService에서 독립적으로 처리.

```php
// PointEventService::createMukbang() 내부
$postEntity = PostService::create($postInput);  // 기존 글 생성 재활용
// → 영수증 검증 → 포인트 지급
```

### 2.4 (4단계) 코드 작성 계획 → 섹션 4, 5 참조

### 2.5 (5단계) 테스트 계획 → 섹션 11 참조

---

## 3. ToT (Tree-of-Thought) 분석

### 3.1 서브 문제 분해

```
먹방 이벤트 기능
├── [A] UI/UX 서브 문제
│   ├── [A1] 홈 퀵메뉴 아이템 추가
│   ├── [A2] MukbangEventScreen (글 등록 화면)
│   ├── [A3] 포인트 결과 표시 UI
│   ├── [A4] 글 수정 → 일반 PostUpdateScreen 그대로 사용
│   └── [A5] i18n 번역 키 추가
│
├── [B] API 서브 문제 — 단일 API
│   ├── [B1] PointEventController (createMukbang, weeklyCount)
│   ├── [B2] PointEventService (글 생성 + 영수증 검증 + 포인트)
│   ├── [B3] PointEventRepository (DB 계층)
│   └── [B4] PSR-4 네임스페이스 등록
│
├── [C] 포인트 서브 문제
│   ├── [C1] 랜덤 포인트 알고리즘 (1,000~2,000)
│   ├── [C2] 보너스 알고리즘 (≥1,900 → 2,000~10,000)
│   ├── [C3] 주간 횟수 제한 (7일 이내 3개 이하)
│   └── [C4] 글 삭제 시 포인트 차감
│
├── [D] 영수증 서브 문제
│   ├── [D1] V7FileUpload 영수증 업로드 (글에 첨부하지 않음)
│   ├── [D2] AI 영수증 분석 (ai.analyzeReceipt 재활용)
│   ├── [D3] 날짜 검증 (24시간 이내)
│   └── [D4] 국가 검증 (필리핀)
│
└── [E] 통합 서브 문제
    ├── [E1] go_router 라우트 등록
    ├── [E2] MukbangEventApi 래퍼 클래스
    └── [E3] 제출 플로우 (단일 API → 글 읽기 화면)
```

### 3.2 각 서브 문제의 독립적 해결

#### [A] UI/UX 서브 문제

**[A1] 홈 퀵메뉴 아이템 추가**

파일: `lib/widgets/home/main/home_quick_menu_section.dart`

현재 순서:
1. 내 정보 (아바타)
2. 필독 정보

**변경 후:**
1. 내 정보 (아바타)
2. **→ 먹방 이벤트 (신규)**
3. 필독 정보

```dart
/// 먹방 이벤트 메뉴 (내 정보 다음 위치)
_buildMenuItem(
  context: context,
  icon: FontAwesomeIcons.lightUtensils,
  label: l10n.quickMenuMukbangEvent,
  onTap: () => MukbangEventScreen.push(context),
  scheme: scheme,
  theme: theme,
  sp: sp,
  backgroundColor: scheme.secondaryContainer,
  iconColor: scheme.onSecondaryContainer,
),
```

**[A2] MukbangEventScreen 폼 디자인**

**입력 필드**: 제목, 영수증(별도), 먹방 사진, 내용

```
┌─────────────────────────────────┐
│  ← 먹방 이벤트     📷  ✈️       │  AppBar (카메라, 제출 버튼)
├─────────────────────────────────┤
│                                 │
│  📝 제목                        │  TextField
│  ────────────────────────────── │
│                                 │
│  🧾 영수증 업로드               │  V7FileUpload (module='receipt')
│  [영수증 사진 미리보기]          │  method='ai.analyzeReceipt'
│  ⚠️ 영수증은 글에 첨부되지 않음  │  ※ 글 files에 포함 안 함
│                                 │
│  ────────────────────────────── │
│  📸 먹방 사진/동영상 업로드      │  V7FileUpload (module='post')
│  [사진/동영상 미리보기 그리드]   │  image: true, video: true
│                                 │
│  ────────────────────────────── │
│  📝 내용 (리뷰)                 │  TextField (multiline)
│                                 │
│  ────────────────────────────── │
│  ℹ️ 이번 주 이벤트: 2/4회 남음  │  주간 횟수 표시
│                                 │
│  [    먹방 이벤트 제출    ]      │  제출 버튼
│                                 │
└─────────────────────────────────┘
```

**[A3] 포인트 결과 표시 UI**

제출 성공 후 다이얼로그 → 확인 → PostViewScreen으로 이동

```
┌──────────────────────────┐
│    🎉 축하합니다!         │
│                          │
│  1,500 포인트 획득!       │
│                          │
│  (≥1,900인 경우)          │
│  🎊 보너스!               │
│  +5,000 포인트 추가!      │
│  합계: 6,500 포인트       │
│                          │
│       [확인]              │
└──────────────────────────┘
```

영수증 검증 실패 또는 주간 제한 초과 시:
→ 글은 정상 생성되었지만 포인트 미지급 안내

**[A4] 글 수정 → 일반 PostUpdateScreen 그대로 사용**

먹방 이벤트 글도 일반 게시글(freetalk, 먹방)이므로,
수정 시 기존 PostUpdateScreen을 100% 그대로 사용한다.
별도의 수정 화면을 만들지 않는다.

**[A5] i18n 번역 키**

| 키 | 한국어 | 영어 |
|----|--------|------|
| quickMenuMukbangEvent | 먹방이벤트 | Food Event |
| mukbangEventTitle | 먹방 이벤트 | Food Review Event |
| mukbangReceiptUpload | 영수증 업로드 | Upload Receipt |
| mukbangReceiptNotAttached | 영수증은 글에 첨부되지 않습니다 | Receipt won't be attached to the post |
| mukbangFoodPhotos | 먹방 사진/동영상 | Food Photos/Videos |
| mukbangReviewContent | 내용 | Content |
| mukbangWeeklyCount | 이번 주 이벤트: {count}/4회 | This week: {count}/4 |
| mukbangPointEarned | {point} 포인트 획득! | {point} points earned! |
| mukbangBonusEarned | 보너스! +{bonus} 포인트 추가! | Bonus! +{bonus} extra points! |
| mukbangReceiptRequired | 영수증을 업로드해주세요 | Please upload a receipt |
| mukbangPhotosRequired | 먹방 사진을 1장 이상 업로드해주세요 | Please upload at least 1 food photo |
| mukbangNoPointReceipt | 영수증 검증 실패로 포인트가 지급되지 않았습니다 | Points not awarded due to receipt validation failure |
| mukbangNoPointWeekly | 주간 이벤트 횟수 초과로 포인트가 지급되지 않았습니다 | Points not awarded: weekly limit exceeded |
| mukbangSubmitSuccess | 먹방 후기가 등록되었습니다! | Food review posted! |

---

#### [B] API 서브 문제 — 단일 API

**[B1] PointEventController**

```php
namespace Philgo\PointEvent;

class PointEventController {

    /**
     * 먹방 이벤트 글 생성 (단일 API)
     *
     * 글 생성 + 영수증 검증 + 포인트 지급을 한 번에 처리한다.
     *
     * GET /api.php?method=pointEvent.createMukbang
     *     &session_id=xxx
     *     &subject=맛있는 삼겹살
     *     &content=정말 맛있었어요
     *     &files=photo1.jpg,photo2.jpg
     *     &receipt_url=/uploads/123/receipt.jpg
     *     &receipt_date=2026-02-27 12:30:00
     *     &receipt_country=PH
     *
     * @return array {
     *   idx: int,               // 생성된 게시글 번호
     *   subject: string,        // 제목
     *   ...PostEntity fields,   // 게시글 정보
     *   event_point: {          // 이벤트 포인트 정보
     *     awarded: bool,        // 포인트 지급 여부
     *     base_point: int,      // 기본 포인트 (0이면 미지급)
     *     bonus_point: int,     // 보너스 포인트
     *     total_point: int,     // 총 포인트
     *     reason: string,       // 미지급 사유 (지급 시 빈 문자열)
     *   },
     *   weekly_count: int,      // 이번 주 이벤트 횟수
     *   weekly_remaining: int,  // 이번 주 남은 횟수
     * }
     */
    public function createMukbang(array $input): array

    /**
     * 주간 이벤트 횟수 조회
     *
     * GET /api.php?method=pointEvent.weeklyCount&session_id=xxx
     *
     * @return array {count: int, remaining: int, limit: int}
     */
    public function weeklyCount(array $input): array
}
```

**[B2] PointEventService 비즈니스 로직**

핵심: PostService::create()를 내부에서 호출하여 글 생성을 재활용.

```php
namespace Philgo\PointEvent;

use Philgo\Post\PostService;

class PointEventService {

    const WEEKLY_LIMIT = 4;        // 주간 최대 횟수
    const BASE_POINT_MIN = 1000;
    const BASE_POINT_MAX = 2000;
    const BONUS_THRESHOLD = 1900;
    const BONUS_POINT_MIN = 2000;
    const BONUS_POINT_MAX = 10000;
    const RECEIPT_VALID_SECONDS = 86400; // 24시간

    /**
     * 먹방 이벤트 글 생성 (단일 처리)
     *
     * 1. PostService::create() 호출하여 글 생성
     *    (영수증은 files에 포함하지 않음)
     * 2. 영수증 검증 (실패 시 글은 유지, 포인트만 미지급)
     * 3. 주간 횟수 확인 (초과 시 글은 유지, 포인트만 미지급)
     * 4. 랜덤 포인트 계산 + 지급
     * 5. 게시글 + 포인트 결과 반환
     */
    public static function createMukbang(int $idxMember, array $input): array

    /**
     * 주간 이벤트 횟수 조회
     * sf_point_log에서 module='point_event', action='mukbang_create' 카운트
     */
    public static function getWeeklyCount(int $idxMember): int

    /**
     * 랜덤 포인트 계산
     * @return array{base: int, bonus: int, total: int}
     */
    public static function calculateRandomPoints(): array

    /**
     * 영수증 검증
     * @throws RuntimeException 검증 실패 시 (catch하여 포인트만 미지급)
     */
    public static function validateReceipt(string $receiptDate, string $receiptCountry): void

    /**
     * 포인트 지급 + 로그 기록
     * module='point_event', action='mukbang_create'
     */
    private static function grantPoints(int $points, array $member, int $idxPost, string $etc): array

    /**
     * 이벤트 포인트 차감 (글 삭제 시)
     * 이벤트 횟수(weekly count)는 차감하지 않음
     */
    public static function revokePoints(int $idxPost, int $idxMember): void
}
```

**[B3] PointEventRepository DB 계층**

```php
namespace Philgo\PointEvent;

class PointEventRepository {
    public static function countWeeklyEvents(int $idxMember): int
    public static function getMember(int $idxMember): ?array
    public static function updateMemberPoint(int $idxMember, int $newPoints): bool
    public static function insertPointLog(array $data): int
    public static function updatePostFields(int $idxPost, array $data): bool
    public static function getEventLogsByPost(int $idxPost): array
}
```

**[B4] PSR-4 네임스페이스**

`composer.json`에 추가:
```json
"Philgo\\PointEvent\\": "lib/point_event/"
```

---

#### [C] 포인트 서브 문제

**[C1] 랜덤 포인트 알고리즘**

```php
public static function calculateRandomPoints(): array {
    // 기본: 1,000 ~ 2,000 (100 단위, 11가지)
    $base = random_int(self::BASE_POINT_MIN / 100, self::BASE_POINT_MAX / 100) * 100;

    // 보너스: 기본 ≥ 1,900이면 2,000 ~ 10,000 (100 단위)
    $bonus = 0;
    if ($base >= self::BONUS_THRESHOLD) {
        $bonus = random_int(self::BONUS_POINT_MIN / 100, self::BONUS_POINT_MAX / 100) * 100;
    }

    return ['base' => $base, 'bonus' => $bonus, 'total' => $base + $bonus];
}
```

**포인트 분포:**

| 기본 | 보너스 | 합계 | 확률 |
|------|--------|------|------|
| 1,000~1,800 | 0 | 1,000~1,800 | ~81.82% |
| 1,900 | 2,000~10,000 | 3,900~11,900 | ~9.09% |
| 2,000 | 2,000~10,000 | 4,000~12,000 | ~9.09% |

**[C2] 주간 횟수 제한**

```sql
SELECT COUNT(*) FROM sf_point_log
WHERE idx_member_to = :idx_member
  AND module = 'point_event'
  AND action = 'mukbang_create'
  AND stamp >= :week_start    -- time() - 604800
```

- 카운트 ≤ 3이면 포인트 지급 가능 (최대 4회)
- 글 삭제해도 횟수 유지 (mukbang_create 로그가 남아있음)

**[C3] 글 삭제 시 포인트 차감**

PostService::delete() 마지막에 추가:

```php
// 이벤트 포인트 차감 (해당되는 경우)
PointEventService::revokePoints($entity->idx, $entity->idx_member);
```

revokePoints()는:
1. sf_point_log에서 해당 게시글의 이벤트 포인트 합산
2. sf_member.point 차감 (최소 0)
3. sf_point_log에 차감 로그 기록 (action='mukbang_delete')
4. 주간 횟수는 차감하지 않음

---

#### [D] 영수증 서브 문제

**[D1] V7FileUpload 영수증 업로드 (글에 첨부하지 않음)**

```dart
V7FileUpload(
  idxMember: userIdx,
  module: 'receipt',
  method: 'ai.analyzeReceipt',
  onUploaded: (result) {
    setState(() {
      receiptData = result;   // AI 분석 결과
      receiptUrl = result['url'];
    });
  },
  child: FilledButton.icon(
    icon: FaIcon(FontAwesomeIcons.lightReceipt),
    label: Text(l10n.mukbangReceiptUpload),
  ),
)
```

**핵심:** 영수증 URL은 receiptUrl 상태에만 저장하고, 게시글의 files 파라미터에는 포함하지 않는다. API 호출 시 receipt_url 파라미터로 별도 전달.

**[D2] AI 영수증 분석**

기존 `ai.analyzeReceipt` API 반환 필드:
- `store_name`, `receipt_date`, `receipt_country`, `total_amount`, `currency`

**[D3] 서버 측 영수증 검증**

```php
public static function validateReceipt(string $receiptDate, string $receiptCountry): void {
    // 날짜: strtotime() → 24시간 이내 확인
    // 국가: 'PH' 또는 'PHILIPPINES'만 허용
    // 실패 시 RuntimeException throw
}
```

**[D4] 검증 실패 시 처리**

검증 실패 시 **글은 정상 생성**, 포인트만 미지급.
응답의 `event_point.awarded = false`, `event_point.reason`에 사유 기록.

---

#### [E] 통합 서브 문제

**[E1] go_router 라우트 등록**

```dart
GoRoute(
  path: MukbangEventScreen.routeName,
  builder: (context, state) => const MukbangEventScreen(),
),
```

**[E2] MukbangEventApi 래퍼 클래스**

```dart
class MukbangEventApi {
  MukbangEventApi._();

  /// 먹방 이벤트 글 생성 (단일 API)
  static Future<Map<String, dynamic>> create({
    required String subject,
    required String content,
    required String files,          // 먹방 사진 URLs (쉼표 구분, 영수증 제외)
    required String receiptUrl,
    required String receiptDate,
    required String receiptCountry,
  }) async {
    return await v7api('pointEvent.createMukbang', data: {
      'subject': subject,
      'content': content,
      'files': files,
      'receipt_url': receiptUrl,
      'receipt_date': receiptDate,
      'receipt_country': receiptCountry,
    });
  }

  /// 주간 이벤트 횟수 조회
  static Future<Map<String, dynamic>> weeklyCount() async {
    return await v7api('pointEvent.weeklyCount');
  }
}
```

**[E3] 제출 플로우**

```
사용자 → "먹방 이벤트 제출" 버튼 클릭
    │
    ├─ (1) 클라이언트 유효성 검증
    │   ├─ 제목 비어있으면 에러
    │   ├─ 영수증 미업로드면 에러
    │   ├─ 먹방 사진 0장이면 에러
    │   └─ 내용 비어있으면 에러
    │
    ├─ (2) MukbangEventApi.create() 호출 (단일 API)
    │   ├─ subject: 제목
    │   ├─ content: 내용
    │   ├─ files: 먹방사진URLs (영수증 제외)
    │   ├─ receipt_url: 영수증 URL
    │   ├─ receipt_date: AI 분석 영수증 날짜
    │   └─ receipt_country: AI 분석 국가
    │
    ├─ (3) 응답 처리
    │   ├─ event_point.awarded == true → 포인트 결과 다이얼로그
    │   └─ event_point.awarded == false → 미지급 사유 안내
    │
    └─ (4) PostViewScreen으로 이동 (생성된 글 조회)
```

### 3.3 서브 문제 통합 순서

1. [B] v7 PHP 백엔드 (PointEvent 모듈) → 독립 테스트 가능
2. [E2] MukbangEventApi Flutter 래퍼
3. [A5] i18n 번역 키
4. [A2] MukbangEventScreen UI
5. [D] 영수증 업로드+검증
6. [A1] 홈 퀵메뉴 아이템 추가
7. [E1] 라우터 등록
8. [C3] 글 삭제 포인트 차감 (PostService 확장)
9. [A3] 포인트 결과 UI

---

## 4. v7 PHP 백엔드 설계

### 4.1 파일 구조

```
lib/point_event/
├── PointEventController.php    # API 엔드포인트
├── PointEventService.php       # 비즈니스 로직
└── PointEventRepository.php    # DB 계층
```

### 4.2 PointEventController 전체 설계

```php
<?php

namespace Philgo\PointEvent;

use Philgo\Utils\AuthService;
use RuntimeException;

class PointEventController {

    private function getAuthenticatedMemberIdx(): int {
        $user = AuthService::getLoginUser();
        if ($user === null) {
            throw new RuntimeException('로그인이 필요합니다.');
        }
        return (int)$user['idx'];
    }

    /**
     * 먹방 이벤트 글 생성 (단일 API)
     *
     * 글 생성 + 영수증 검증 + 포인트 지급을 한 번에 처리.
     *
     * GET /api.php?method=pointEvent.createMukbang
     *     &session_id=xxx
     *     &subject=맛있는 삼겹살
     *     &content=정말 맛있었어요
     *     &files=photo1.jpg,photo2.jpg
     *     &receipt_url=/uploads/123/receipt.jpg
     *     &receipt_date=2026-02-27 12:30:00
     *     &receipt_country=PH
     */
    public function createMukbang(array $input): array {
        $idxMember = $this->getAuthenticatedMemberIdx();
        return PointEventService::createMukbang($idxMember, $input);
    }

    /**
     * 주간 이벤트 횟수 조회
     *
     * GET /api.php?method=pointEvent.weeklyCount&session_id=xxx
     */
    public function weeklyCount(array $input): array {
        $idxMember = $this->getAuthenticatedMemberIdx();
        $count = PointEventService::getWeeklyCount($idxMember);

        return [
            'count' => $count,
            'remaining' => max(0, PointEventService::WEEKLY_LIMIT - $count),
            'limit' => PointEventService::WEEKLY_LIMIT,
        ];
    }
}
```

### 4.3 PointEventService 전체 설계

```php
<?php

namespace Philgo\PointEvent;

use Philgo\Post\PostService;
use RuntimeException;

class PointEventService {

    const WEEKLY_LIMIT = 4;
    const BASE_POINT_MIN = 1000;
    const BASE_POINT_MAX = 2000;
    const BONUS_THRESHOLD = 1900;
    const BONUS_POINT_MIN = 2000;
    const BONUS_POINT_MAX = 10000;
    const RECEIPT_VALID_SECONDS = 86400;

    /**
     * 먹방 이벤트 글 생성 (단일 처리)
     */
    public static function createMukbang(int $idxMember, array $input): array {
        // ─── (1) 글 생성 (PostService::create() 재활용) ───
        $postInput = [
            'idx_member' => $idxMember,
            'post_id' => 'freetalk',
            'category' => '먹방',
            'subject' => $input['subject'] ?? '',
            'content' => $input['content'] ?? '',
        ];
        // 먹방 사진만 files에 포함 (영수증 제외)
        if (!empty($input['files'])) {
            $postInput['files'] = $input['files'];
        }

        $postEntity = PostService::create($postInput);
        $postArray = $postEntity->toArray();

        // ─── (2) 이벤트 포인트 처리 ───
        $eventPoint = [
            'awarded' => false,
            'base_point' => 0,
            'bonus_point' => 0,
            'total_point' => 0,
            'reason' => '',
        ];

        $receiptUrl = trim($input['receipt_url'] ?? '');
        $receiptDate = trim($input['receipt_date'] ?? '');
        $receiptCountry = trim($input['receipt_country'] ?? '');

        // (2-1) 영수증 검증
        try {
            if (!empty($receiptDate) && !empty($receiptCountry)) {
                self::validateReceipt($receiptDate, $receiptCountry);
            } else {
                throw new RuntimeException('영수증 정보가 부족합니다.');
            }
        } catch (RuntimeException $e) {
            // 영수증 검증 실패 → 글은 유지, 포인트 미지급
            $eventPoint['reason'] = $e->getMessage();
            return self::buildResponse($postArray, $eventPoint, $idxMember);
        }

        // (2-2) 주간 횟수 확인 (3개 이하일 때만 지급)
        $weeklyCount = self::getWeeklyCount($idxMember);
        if ($weeklyCount >= self::WEEKLY_LIMIT) {
            $eventPoint['reason'] = '이번 주 이벤트 참여 횟수를 초과했습니다.';
            return self::buildResponse($postArray, $eventPoint, $idxMember);
        }

        // (2-3) 회원 정보 조회
        $member = PointEventRepository::getMember($idxMember);
        if ($member === null) {
            $eventPoint['reason'] = '회원 정보를 찾을 수 없습니다.';
            return self::buildResponse($postArray, $eventPoint, $idxMember);
        }

        // (2-4) 랜덤 포인트 계산
        $points = self::calculateRandomPoints();

        // (2-5) 기본 포인트 지급
        self::grantPoints(
            points: $points['base'],
            member: $member,
            idxPost: $postEntity->idx,
            etc: 'mukbang_event_base'
        );

        // (2-6) 보너스 포인트 지급 (해당 시)
        if ($points['bonus'] > 0) {
            $member = PointEventRepository::getMember($idxMember);
            self::grantPoints(
                points: $points['bonus'],
                member: $member,
                idxPost: $postEntity->idx,
                etc: 'mukbang_event_bonus'
            );
        }

        // (2-7) 게시글에 이벤트 포인트 기록
        PointEventRepository::updatePostFields($postEntity->idx, [
            'int_1' => $points['base'],
            'int_2' => $points['bonus'],
        ]);

        // (2-8) 영수증 URL 기록 (varchar_1에 저장)
        PointEventRepository::updatePostFields($postEntity->idx, [
            'varchar_1' => $receiptUrl,
        ]);

        $eventPoint = [
            'awarded' => true,
            'base_point' => $points['base'],
            'bonus_point' => $points['bonus'],
            'total_point' => $points['total'],
            'reason' => '',
        ];

        return self::buildResponse($postArray, $eventPoint, $idxMember);
    }

    /**
     * 응답 빌드 헬퍼
     */
    private static function buildResponse(
        array $postArray,
        array $eventPoint,
        int $idxMember
    ): array {
        $weeklyCount = self::getWeeklyCount($idxMember);
        return array_merge($postArray, [
            'event_point' => $eventPoint,
            'weekly_count' => $weeklyCount,
            'weekly_remaining' => max(0, self::WEEKLY_LIMIT - $weeklyCount),
        ]);
    }

    /**
     * 주간 이벤트 횟수 조회
     */
    public static function getWeeklyCount(int $idxMember): int {
        return PointEventRepository::countWeeklyEvents($idxMember);
    }

    /**
     * 랜덤 포인트 계산
     */
    public static function calculateRandomPoints(): array {
        $base = random_int(self::BASE_POINT_MIN / 100, self::BASE_POINT_MAX / 100) * 100;
        $bonus = 0;
        if ($base >= self::BONUS_THRESHOLD) {
            $bonus = random_int(self::BONUS_POINT_MIN / 100, self::BONUS_POINT_MAX / 100) * 100;
        }
        return ['base' => $base, 'bonus' => $bonus, 'total' => $base + $bonus];
    }

    /**
     * 영수증 검증
     */
    public static function validateReceipt(string $receiptDate, string $receiptCountry): void {
        $receiptTimestamp = strtotime($receiptDate);
        if ($receiptTimestamp === false) {
            throw new RuntimeException('영수증 날짜를 확인할 수 없습니다.');
        }
        $elapsed = time() - $receiptTimestamp;
        if ($elapsed > self::RECEIPT_VALID_SECONDS) {
            throw new RuntimeException('영수증이 24시간이 지났습니다.');
        }
        if ($elapsed < -300) {
            throw new RuntimeException('영수증 날짜가 유효하지 않습니다.');
        }
        $country = strtoupper(trim($receiptCountry));
        if ($country !== 'PH' && $country !== 'PHILIPPINES') {
            throw new RuntimeException('필리핀 영수증만 인정됩니다.');
        }
    }

    /**
     * 포인트 지급 + 로그 기록
     */
    private static function grantPoints(
        int $points, array $member, int $idxPost, string $etc
    ): array {
        if ($points <= 0) return [];
        $idxMember = (int)($member['idx'] ?? 0);
        if ($idxMember <= 0) return [];

        $currentPoints = (int)($member['point'] ?? 0);
        $newPoints = $currentPoints + $points;

        PointEventRepository::updateMemberPoint($idxMember, $newPoints);
        $logData = [
            'idx_member_from' => $idxMember,
            'idx_member_to' => $idxMember,
            'point_before' => $currentPoints,
            'point' => $points,
            'point_after' => $newPoints,
            'module' => 'point_event',
            'action' => 'mukbang_create',
            'idx_post' => $idxPost,
            'etc' => $etc,
            'stamp' => time(),
            'ip' => '',
        ];
        $logIdx = PointEventRepository::insertPointLog($logData);
        $logData['idx'] = $logIdx;
        return $logData;
    }

    /**
     * 이벤트 포인트 차감 (글 삭제 시)
     */
    public static function revokePoints(int $idxPost, int $idxMember): void {
        $eventLogs = PointEventRepository::getEventLogsByPost($idxPost);
        if (empty($eventLogs)) return;

        $totalGranted = 0;
        foreach ($eventLogs as $log) {
            $totalGranted += (int)$log['point'];
        }
        if ($totalGranted <= 0) return;

        $member = PointEventRepository::getMember($idxMember);
        if ($member === null) return;

        $currentPoints = (int)($member['point'] ?? 0);
        $newPoints = max(0, $currentPoints - $totalGranted);

        PointEventRepository::updateMemberPoint($idxMember, $newPoints);
        PointEventRepository::insertPointLog([
            'idx_member_from' => $idxMember,
            'idx_member_to' => $idxMember,
            'point_before' => $currentPoints,
            'point' => -$totalGranted,
            'point_after' => $newPoints,
            'module' => 'point_event',
            'action' => 'mukbang_delete',
            'idx_post' => $idxPost,
            'etc' => 'mukbang_event_revoke',
            'stamp' => time(),
            'ip' => '',
        ]);
    }
}
```

### 4.4 PostService 확장 — 글 삭제 시 이벤트 포인트 차감

기존 `PostService::delete()` 마지막에 추가:

```php
use Philgo\PointEvent\PointEventService;

// 기존 decreasePointsForDelete() 호출 후에 추가
PointEventService::revokePoints($idx, $entity->idx_member);
```

---

## 5. Flutter 앱 설계

### 5.1 파일 구조

```
lib/
├── v7_api/
│   └── mukbang_event_api.dart         # MukbangEventApi 래퍼
│
├── screens/
│   └── event/
│       └── mukbang_event.screen.dart  # MukbangEventScreen
│
├── widgets/home/main/
│   └── home_quick_menu_section.dart   # 퀵메뉴 수정
│
├── l10n/
│   ├── app_en.arb / app_ko.arb / app_ja.arb / app_zh.arb
│
└── router.dart                        # 라우트 등록
```

### 5.2 MukbangEventScreen 핵심 구조

```dart
class MukbangEventScreen extends StatefulWidget {
  static const String routeName = '/mukbang-event';
  static Future push(BuildContext ctx) => ctx.push(routeName);
}

class _MukbangEventScreenState extends State<MukbangEventScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool isLoading = false;
  bool isUploading = false;
  Map<String, dynamic>? receiptData;   // 영수증 AI 분석 결과
  String? receiptUrl;                   // 영수증 URL (글에 첨부 안 함)
  List<String> foodPhotoUrls = [];      // 먹방 사진 URLs (글 files에 첨부)
  int weeklyCount = 0;

  Future<void> _submit() async {
    // (1) 유효성 검증 (제목, 영수증, 사진, 내용)

    // (2) 단일 API 호출
    final result = await MukbangEventApi.create(
      subject: _titleController.text.trim(),
      content: _contentController.text.trim(),
      files: foodPhotoUrls.join(','),    // 먹방 사진만 (영수증 제외)
      receiptUrl: receiptUrl!,
      receiptDate: receiptData?['receipt_date'] ?? '',
      receiptCountry: receiptData?['receipt_country'] ?? '',
    );

    // (3) 포인트 결과 처리
    final eventPoint = result['event_point'] as Map<String, dynamic>;
    if (eventPoint['awarded'] == true) {
      _showPointDialog(eventPoint);  // 포인트 획득 다이얼로그
    } else {
      _showNoPointMessage(eventPoint['reason']);  // 미지급 안내
    }

    // (4) PostViewScreen으로 이동
  }
}
```

### 5.3 글 수정 — 일반 PostUpdateScreen 그대로 사용

먹방 이벤트 글도 post_id='freetalk', category='먹방'인 일반 게시글이므로,
PostViewScreen에서 수정 버튼 → PostUpdateScreen으로 이동.
**추가 개발 불필요.**

---

## 6. 데이터베이스 설계

### 6.1 사용 테이블 (기존 테이블 활용, 새 테이블 없음)

| 테이블 | 용도 |
|--------|------|
| sf_post_data | 게시글 저장 (post_id='freetalk', category='먹방') |
| sf_member | 회원 포인트 (point 필드) |
| sf_point_log | 포인트 이벤트 로그 |

### 6.2 sf_post_data 커스텀 필드

| 필드 | 용도 | 예시 |
|------|------|------|
| varchar_1 | 영수증 URL (검증용) | "/uploads/123/receipt.jpg" |
| int_1 | 이벤트 기본 포인트 | 1900 |
| int_2 | 이벤트 보너스 포인트 | 5000 |
| int_10 | 게시판 기본 포인트 (기존) | 10 |
| files | **먹방 사진만** (영수증 제외) | "photo1.jpg,photo2.jpg" |

### 6.3 sf_point_log 이벤트 로그 형식

| 상황 | module | action | etc |
|------|--------|--------|-----|
| 이벤트 기본 포인트 | point_event | mukbang_create | mukbang_event_base |
| 이벤트 보너스 포인트 | point_event | mukbang_create | mukbang_event_bonus |
| 글 삭제 포인트 차감 | point_event | mukbang_delete | mukbang_event_revoke |

---

## 7. 포인트 이벤트 로직 상세

### 7.1 포인트 지급 플로우 (단일 API 내)

```
pointEvent.createMukbang API 호출
    │
    ├─ (1) PostService::create() → 글 생성
    │      post_id='freetalk', category='먹방'
    │      files = 먹방 사진만 (영수증 미포함)
    │      → 기존 freetalk 포인트도 자동 지급 (sf_post_config)
    │
    ├─ (2) 영수증 검증
    │      → 실패 시: 글 유지, 포인트 미지급, reason 기록
    │
    ├─ (3) 주간 횟수 확인 (≤ 3)
    │      → 초과 시: 글 유지, 포인트 미지급, reason 기록
    │
    ├─ (4) 랜덤 포인트 계산 + 지급
    │      ├─ 기본: 1,000~2,000
    │      └─ 보너스 (≥1,900): 2,000~10,000
    │
    ├─ (5) sf_point_log 기록
    │
    └─ 응답: 게시글 정보 + event_point + weekly_count
```

### 7.2 포인트 차감 플로우 (글 삭제 시)

```
PostService::delete() 호출
    │
    ├─ (1) 기존 포인트 차감 (sf_post_config.point_write_delete)
    │
    └─ (2) PointEventService::revokePoints()
        ├─ sf_point_log에서 이벤트 포인트 합산
        ├─ sf_member.point 차감 (최소 0)
        ├─ sf_point_log에 차감 로그 (action='mukbang_delete')
        └─ 주간 횟수는 유지
```

### 7.3 주간 제한 예시

```
월요일: 이벤트 참여 → count=1 ✅
화요일: 이벤트 참여 → count=2 ✅
수요일: 월요일 글 삭제 → count=2 (유지), 포인트만 차감
목요일: 이벤트 참여 → count=3 ✅
금요일: 이벤트 참여 → count=4 ✅
토요일: 이벤트 시도 → 글은 생성, 포인트 미지급 (주간 초과)
다음 월요일+: 월요일 로그가 7일 경과 → count 자동 감소
```

---

## 8. 영수증 검증 로직

### 8.1 영수증 업로드 흐름

```
사용자 → 영수증 촬영/선택
    │
    ├─ V7FileUpload (method='ai.analyzeReceipt')
    │   └─ v7apiFileUpload() → 파일 업로드 + AI 분석
    │
    └─ AI 분석 결과
        ├─ store_name, receipt_date, receipt_country
        ├─ total_amount, currency
        └─ url (영수증 파일 URL)

    ※ receiptUrl은 상태에만 저장
    ※ 글의 files에는 포함하지 않음
```

### 8.2 서버 측 검증

| 검증 | 기준 | 실패 시 |
|------|------|---------|
| 날짜 | strtotime() → 24시간 이내 | 글 유지, 포인트 미지급 |
| 국가 | 'PH' 또는 'PHILIPPINES' | 글 유지, 포인트 미지급 |
| 미래 날짜 | 5분 이상 미래 | 글 유지, 포인트 미지급 |

---

## 9. 파일 목록 및 수정 계획

### 9.1 신규 파일 (v7 PHP 백엔드)

| # | 파일 경로 | 설명 |
|---|----------|------|
| 1 | `lib/point_event/PointEventController.php` | API (createMukbang, weeklyCount) |
| 2 | `lib/point_event/PointEventService.php` | 글 생성 + 검증 + 포인트 |
| 3 | `lib/point_event/PointEventRepository.php` | DB 계층 |
| 4 | `tests/Unit/PointEventControllerTest.php` | PEST 테스트 |

### 9.2 수정 파일 (v7 PHP 백엔드)

| # | 파일 경로 | 변경 |
|---|----------|------|
| 5 | `composer.json` | PSR-4: `"Philgo\\PointEvent\\": "lib/point_event/"` |
| 6 | `lib/post/PostService.php` | delete()에 revokePoints() 추가 |

### 9.3 신규 파일 (Flutter 앱)

| # | 파일 경로 | 설명 |
|---|----------|------|
| 7 | `lib/v7_api/mukbang_event_api.dart` | MukbangEventApi 래퍼 |
| 8 | `lib/screens/event/mukbang_event.screen.dart` | MukbangEventScreen |

### 9.4 수정 파일 (Flutter 앱)

| # | 파일 경로 | 변경 |
|---|----------|------|
| 9 | `lib/widgets/home/main/home_quick_menu_section.dart` | 퀵메뉴 추가 |
| 10 | `lib/router.dart` | 라우트 등록 |
| 11 | `lib/l10n/app_en.arb` | 영어 번역 |
| 12 | `lib/l10n/app_ko.arb` | 한국어 번역 |
| 13 | `lib/l10n/app_ja.arb` | 일본어 번역 |
| 14 | `lib/l10n/app_zh.arb` | 중국어 번역 |

### 9.5 요약

| 분류 | 신규 | 수정 | 합계 |
|------|------|------|------|
| v7 PHP 백엔드 | 4 | 2 | 6 |
| Flutter 앱 | 2 | 6 | 8 |
| **합계** | **6** | **8** | **14** |

---

## 10. 구현 순서

### Phase 1: v7 PHP 백엔드

```
1. composer.json에 PSR-4 매핑 추가
2. PointEventRepository.php 생성
3. PointEventService.php 생성 (PostService::create() 호출 포함)
4. PointEventController.php 생성
5. composer dump-autoload
6. PEST 테스트 작성 + 실행
7. curl로 API 검증
```

### Phase 2: PostService 확장

```
8. PostService::delete()에 PointEventService::revokePoints() 추가
9. 기존 PostControllerTest 재실행
```

### Phase 3: Flutter 앱

```
10. mukbang_event_api.dart 생성
11. i18n 번역 키 추가 (4개 arb)
12. mukbang_event.screen.dart 생성
13. router.dart에 라우트 등록
14. home_quick_menu_section.dart에 퀵메뉴 추가
```

### Phase 4: 통합 테스트

```
15. flutter analyze (에러 0개)
16. 앱 실행 → 퀵메뉴 → 먹방 이벤트 → 글 등록 → 포인트 확인
17. 글 삭제 → 포인트 차감 확인
18. 글 수정 → 일반 PostUpdateScreen 동작 확인
19. 주간 4회 제한 확인
```

---

## 11. 테스트 계획

### 11.1 PEST 유닛 테스트 (v7 PHP)

| # | 테스트 | 설명 |
|---|--------|------|
| 1 | 먹방 글 생성 | post_id='freetalk', category='먹방' 글 생성 확인 |
| 2 | 영수증 글 미첨부 확인 | files에 영수증 URL 미포함 확인 |
| 3 | 포인트 지급 (정상) | 영수증 OK + 주간 미초과 → 포인트 지급 |
| 4 | 포인트 미지급 (영수증 만료) | 25시간 전 영수증 → awarded=false |
| 5 | 포인트 미지급 (비필리핀) | KR 영수증 → awarded=false |
| 6 | 포인트 미지급 (주간 초과) | 5번째 시도 → awarded=false |
| 7 | 글은 생성됨 (포인트 실패 시) | 검증 실패해도 글은 존재 |
| 8 | 랜덤 포인트 범위 | 1,000~2,000, 보너스 0 또는 2,000~10,000 |
| 9 | 보너스 트리거 | base ≥ 1,900일 때만 bonus > 0 |
| 10 | 포인트 차감 (글 삭제) | sf_member.point 감소 확인 |
| 11 | 주간 횟수 유지 (글 삭제 후) | 삭제해도 count 유지 |
| 12 | 비로그인 시 에러 | 인증 필수 |

### 11.2 Flutter 수동 테스트

- [ ] 홈 퀵메뉴에 "먹방이벤트" 표시
- [ ] 먹방 이벤트 화면 → 제목, 영수증, 사진, 내용 입력
- [ ] 영수증 업로드 → AI 분석 결과 표시
- [ ] 먹방 사진 업로드 (복수)
- [ ] 주간 이벤트 횟수 표시
- [ ] 제출 → 포인트 결과 다이얼로그
- [ ] 제출 → PostViewScreen 이동
- [ ] 글 수정 → 일반 PostUpdateScreen 동일 동작
- [ ] 글 삭제 → 포인트 차감
- [ ] 주간 4회 초과 → 글 생성 OK, 포인트 미지급 안내

---

## 부록: API 호출 예시

### 먹방 이벤트 글 생성

```
POST /api.php
method=pointEvent.createMukbang
&session_id=abc123-456
&subject=맛있는 삼겹살 후기
&content=마닐라 코리안타운의 서울식당에서...
&files=photo1.jpg,photo2.jpg
&receipt_url=/uploads/456/receipt.jpg
&receipt_date=2026-02-27 12:30:00
&receipt_country=PH
```

**응답 (포인트 지급):**
```json
{
  "idx": 12345,
  "subject": "맛있는 삼겹살 후기",
  "content": "마닐라 코리안타운의 서울식당에서...",
  "files": "photo1.jpg,photo2.jpg",
  "event_point": {
    "awarded": true,
    "base_point": 1900,
    "bonus_point": 5000,
    "total_point": 6900,
    "reason": ""
  },
  "weekly_count": 3,
  "weekly_remaining": 1
}
```

**응답 (포인트 미지급 — 영수증 만료):**
```json
{
  "idx": 12346,
  "subject": "어제 먹은 갈비",
  "event_point": {
    "awarded": false,
    "base_point": 0,
    "bonus_point": 0,
    "total_point": 0,
    "reason": "영수증이 24시간이 지났습니다."
  },
  "weekly_count": 3,
  "weekly_remaining": 1
}
```

### 주간 횟수 조회

```
GET /api.php?method=pointEvent.weeklyCount&session_id=abc123-456
```

```json
{
  "count": 2,
  "remaining": 2,
  "limit": 4
}
```
