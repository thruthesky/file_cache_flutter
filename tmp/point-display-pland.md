# 포인트 이벤트 획득 포인트 표시 계획

## 목차

1. [문제 분석](#1-문제-분석)
2. [현재 시스템 구조 분석](#2-현재-시스템-구조-분석)
3. [해결 방안](#3-해결-방안)
4. [상세 설계](#4-상세-설계)
5. [파일 목록 및 수정 계획](#5-파일-목록-및-수정-계획)
6. [구현 순서](#6-구현-순서)
7. [UI 디자인](#7-ui-디자인)

---

## 1. 문제 분석

### 1.1 현재 문제

사용자가 **포인트 이벤트 기간**에 글을 읽거나 댓글을 작성하면 포인트를 획득하지만,
획득한 포인트가 **글 읽기 화면(PostViewScreen)에 표시되지 않는 문제**가 있다.

### 1.2 기대 동작

- **글 읽기(post_view)** 시: 글에서 획득한 포인트가 화면에 표시되어야 함
- **댓글 작성(create_comment)** 시: 댓글에서 획득한 포인트가 화면에 표시되어야 함

### 1.3 5W1H 분석

| 항목 | 내용 |
|------|------|
| **When** | 포인트 이벤트 기간에 글 읽기/댓글 작성 시 |
| **Where** | PostViewScreen (글 읽기 화면) |
| **What** | 글/댓글에서 획득한 포인트 표시 |
| **How** | API 응답의 포인트 데이터를 UI에 반영 |
| **Why** | 사용자가 포인트 획득 사실을 인지하고 활동 동기 부여 |
| **Who** | 포인트 이벤트 기간에 활동하는 모든 로그인 사용자 |

---

## 2. 현재 시스템 구조 분석

### 2.1 포인트 관련 데이터 흐름

```
[서버] 글/댓글 생성 시 포인트 지급
  → sf_post_data.int_10에 획득 포인트 기록
  → sf_member.point 업데이트
  → sf_point_log에 로그 기록

[API 응답] 글/댓글 데이터에 int_10 필드 포함
  → 포인트 이벤트 기간: 랜덤 배율 적용 (3배~200배)
  → 일반 기간: 고정 포인트 (sf_post_config 기반)

[Flutter 앱] 현재 int_10 데이터를 받아도 UI에 표시하지 않음
```

### 2.2 서버 측 포인트 지급 구조

#### 일반 포인트 지급
- **글 작성**: `sf_post_config.point_write` 만큼 포인트 지급
- **댓글 작성**: `sf_post_config.comment_write` 만큼 포인트 지급
- **글 삭제**: `sf_post_config.point_write_delete` 만큼 포인트 차감

#### 포인트 이벤트 기간 포인트 지급
- `PointConfig::$point_event_dates` 배열에 이벤트 기간 정의
- 적용 게시판: `freetalk`, `qna`
- 랜덤 배율: 3배(50%), 10배(40%), 20배(5%), 40배(4%), 200배(1%)
- 남용 방지: 10분 이내 3회 이상 시 8포인트만 지급

### 2.3 현재 데이터 모델 분석

#### Post 모델 (`packages/philgo_api/lib/src/post/models/post.model.dart`)

```dart
class Post {
  final int point;        // 사용자 보유 포인트 (sf_member.point)
  final int? int10;       // 해당 글에서 획득한 포인트 (sf_post_data.int_10)
  // ... 기타 필드
}
```

- `int10` 필드는 이미 Post 모델에 존재하고 `Post.fromJson()`에서 파싱됨
- API 응답에서 `int_10` 값이 이미 전달되고 있음

#### Comment 모델 (`packages/philgo_api/lib/src/post/models/comment.model.dart`)

```dart
class Comment {
  final int point;        // 사용자 보유 포인트
  final int? int10;       // 현재 존재하지 않음 → 추가 필요할 수 있음
  // ... 기타 필드
}
```

- Comment 모델에는 `int10` 필드가 존재하나, `fromJson` 파싱 시 `int.parse(json['int10'])` 형태로 되어 있어 서버에서 int_10을 보내는 경우에 호환되지 않을 수 있음 (키 이름 확인 필요)

### 2.4 현재 UI 구조 (PostViewScreen)

```
PostViewScreen
├── PostViewAppBar              → 앱바 (옵션 메뉴)
├── TopBanners                  → 상단 배너
├── _buildPostContent()         → 게시글 본문 영역
│   ├── PostViewSubject         → 제목
│   ├── PostViewMeta            → 아바타, 닉네임, 날짜
│   ├── PostViewDisplayYouTubes → 유튜브
│   ├── PostViewFiles           → 첨부 파일
│   ├── PostViewContent         → 본문 내용
│   └── PostViewButtons         → 액션 버튼 (좋아요, 답글 등)
├── SliverCommentList           → 댓글 목록
│   └── CommentDetail           → 개별 댓글 위젯
└── PostViewCommentBox          → 댓글 입력 박스 (하단 고정)
    ├── CommentCreateForm       → 일반 댓글 작성
    ├── ReplyToComment          → 답글 작성
    └── CommentUpdate           → 댓글 수정
```

### 2.5 API 응답에서 포인트 데이터

#### `post_view` API 응답
- 게시글 데이터에 `int_10` 필드 포함 (획득 포인트)
- `point` 필드에 사용자 보유 포인트 포함

#### `create_comment` API 응답
- 생성된 댓글 데이터 반환
- 댓글에서 획득한 포인트 정보 확인 필요

---

## 3. 해결 방안

### 3.1 방안 개요

두 가지 포인트 표시가 필요하다:

#### A. 글 읽기 시 — 해당 글의 획득 포인트 표시

- `post_view` API 응답의 `int_10` 필드를 활용
- 글 제목 아래 또는 메타 정보 옆에 포인트 뱃지 표시
- 포인트 이벤트 기간이고 `int_10 > 0`일 때만 표시

#### B. 댓글 작성 시 — 획득 포인트 SnackBar/토스트 표시

- `create_comment` API 응답에서 포인트 정보 추출
- 댓글 작성 성공 시 "댓글 작성 완료! +XX 포인트 획득" SnackBar 표시
- 댓글 목록의 각 댓글에도 획득 포인트 뱃지 표시

### 3.2 표시 위치 결정

| 위치 | 표시 내용 | 조건 |
|------|----------|------|
| PostViewMeta 영역 (닉네임 아래) | 글 작성자가 해당 글에서 획득한 포인트 | `int_10 > 0` |
| CommentDetail (댓글 닉네임 옆) | 댓글 작성자가 해당 댓글에서 획득한 포인트 | 댓글의 포인트 > 0 |
| SnackBar (댓글 작성 후) | 방금 작성한 댓글에서 획득한 포인트 | 댓글 생성 성공 후 포인트 > 0 |

---

## 4. 상세 설계

### 4.1 글 읽기 화면 — 획득 포인트 표시

#### 수정 대상: `PostViewMeta` 위젯

파일: `lib/screens/post/widgets/post_view_meta.dart`

**현재 구조:**
```
[아바타] | 닉네임
        | 2024-01-15
```

**변경 후:**
```
[아바타] | 닉네임
        | 2024-01-15 · +500P ⭐
```

또는 (이벤트 포인트가 큰 경우):

```
[아바타] | 닉네임              [+2,000P 🎉]
        | 2024-01-15
```

#### 구현 방법

1. `PostViewMeta`에 `earnedPoint` 파라미터 추가
2. `earnedPoint > 0`일 때 포인트 뱃지 표시
3. Theme 기반 스타일링 (primary 색상 사용)

```dart
class PostViewMeta extends StatelessWidget {
  final int idxMember;
  final String nickname;
  final String? photoUrl;
  final String formattedDate;
  final int earnedPoint;  // 신규 추가
  // ...
}
```

### 4.2 댓글 목록 — 각 댓글의 획득 포인트 표시

#### 수정 대상: `CommentDetail` 위젯

파일: `packages/philgo_api/lib/src/post/widgets/comment.detail.dart`

**현재 구조:**
```
[아바타] | 닉네임 · 3시간 전
        | 댓글 내용
        | [좋아요] [답글] [채팅]
```

**변경 후:**
```
[아바타] | 닉네임 · 3시간 전 · +100P
        | 댓글 내용
        | [좋아요] [답글] [채팅]
```

#### 구현 방법

Comment 모델에는 이미 `point` 필드가 있지만, 이것은 사용자 보유 포인트이다.
획득 포인트는 해당 댓글의 `int_10` 필드에 저장된다.

1. Comment 모델의 `int10` 필드가 이미 존재하므로 API에서 올바르게 파싱되는지 확인
2. `CommentDetail`에서 `comment.int10` 값이 있을 때 포인트 뱃지 표시

### 4.3 댓글 작성 후 SnackBar — 획득 포인트 표시

#### 수정 대상: `PostViewCommentBox` / `CommentCreateForm`

**현재 동작:**
```dart
// 댓글 작성 성공 후
showSuccessSnackBar(context, Lo.of(context)!.commentCreated);
```

**변경 후:**
```dart
// 댓글 작성 성공 후 포인트 정보 포함
final earnedPoint = createdComment.int10 ?? 0;
if (earnedPoint > 0) {
  showSuccessSnackBar(
    context,
    '${Lo.of(context)!.commentCreated} +${earnedPoint}P',
  );
} else {
  showSuccessSnackBar(context, Lo.of(context)!.commentCreated);
}
```

### 4.4 포인트 뱃지 위젯 (공통 컴포넌트)

재사용 가능한 포인트 뱃지 위젯을 생성한다.

```dart
/// 획득 포인트 뱃지 위젯
/// 글 또는 댓글에서 획득한 포인트를 표시하는 작은 뱃지
class EarnedPointBadge extends StatelessWidget {
  final int point;

  const EarnedPointBadge({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    if (point <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '+${_formatPoint(point)}P',
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatPoint(int point) {
    if (point >= 1000) {
      return '${(point / 1000).toStringAsFixed(point % 1000 == 0 ? 0 : 1)}K';
    }
    return point.toString();
  }
}
```

### 4.5 포인트 이벤트 배너 (글 읽기 화면 상단)

포인트 이벤트 기간일 때 글 읽기 화면에 이벤트 안내 배너를 추가할 수 있다.
이는 선택 사항이며, 핵심 작업이 아니다.

### 4.6 서버 API 확인 필요 사항

#### `create_comment` 응답에서 `int_10` 포함 여부

현재 `create_comment` API 응답 구조:
```json
{
  "idx": 1275690701,
  "idx_root": 1275690699,
  "idx_parent": 1275690699,
  "content": "댓글 내용입니다.",
  "stamp": 1765962100,
  "idx_member": 188638
}
```

**확인 필요**: `int_10` 필드가 응답에 포함되는지 확인.
포함되지 않는다면 서버 측 수정이 필요하거나, 별도의 API 호출이 필요하다.

**대안 1**: 서버 `create_comment` 응답에 `int_10` 필드 추가 (서버 수정 필요)
**대안 2**: 댓글 작성 후 `post_view` API를 다시 호출하여 갱신된 데이터 가져오기 (이미 구현된 패턴)
**대안 3**: `getPointEventInfo()`로 이벤트 기간 여부만 확인하고, SnackBar에 "포인트 획득!" 메시지만 표시 (서버 수정 불필요)

#### `post_view` 응답에서 각 댓글의 `int_10` 포함 여부

`post_view` API는 게시글과 함께 댓글 목록을 반환한다.
각 댓글 객체에 `int_10` 필드가 포함되는지 확인 필요.

---

## 5. 파일 목록 및 수정 계획

### 5.1 신규 파일

| # | 파일 경로 | 설명 |
|---|----------|------|
| 1 | `packages/philgo_api/lib/src/widgets/earned_point_badge.dart` | 획득 포인트 뱃지 위젯 |

### 5.2 수정 파일

| # | 파일 경로 | 변경 내용 |
|---|----------|----------|
| 2 | `lib/screens/post/widgets/post_view_meta.dart` | `earnedPoint` 파라미터 추가, 포인트 뱃지 표시 |
| 3 | `lib/screens/post/post.view.screen.dart` | PostViewMeta에 `earnedPoint` 전달 |
| 4 | `packages/philgo_api/lib/src/post/widgets/comment.detail.dart` | 댓글의 획득 포인트 뱃지 표시 |
| 5 | `lib/screens/post/widgets/post_view_comment_box.dart` | 댓글 작성 성공 시 포인트 SnackBar |
| 6 | `packages/philgo_api/lib/philgo_api.dart` | EarnedPointBadge export 추가 |

### 5.3 조건부 수정 파일 (서버 응답 확인 후)

| # | 파일 경로 | 변경 내용 | 조건 |
|---|----------|----------|------|
| 7 | `packages/philgo_api/lib/src/post/models/comment.model.dart` | `int_10` 필드 파싱 키 확인 | API 응답 키 이름이 다른 경우 |

### 5.4 i18n 수정 파일

| # | 파일 경로 | 추가 키 |
|---|----------|---------|
| 8 | `lib/l10n/app_en.arb` | `earnedPointMessage`, `commentCreatedWithPoint` |
| 9 | `lib/l10n/app_ko.arb` | 동일 |
| 10 | `lib/l10n/app_ja.arb` | 동일 |
| 11 | `lib/l10n/app_zh.arb` | 동일 |

### 5.5 i18n 키 상세

| 키 | 영어 | 한국어 | 일본어 | 중국어 |
|----|------|--------|--------|--------|
| `earnedPointMessage` | `+{point}P earned` | `+{point}P 획득` | `+{point}P 獲得` | `+{point}P 获得` |
| `commentCreatedWithPoint` | `Comment posted! +{point}P earned` | `댓글 작성 완료! +{point}P 획득` | `コメント投稿完了！+{point}P獲得` | `评论发布成功！+{point}P获得` |

---

## 6. 구현 순서

### Phase 1: API 응답 확인 (서버 확인)

```
1. post_view API 호출 → int_10 필드 확인
2. post_view 댓글 목록에서 int_10 필드 확인
3. create_comment API 호출 → int_10 필드 포함 여부 확인
```

curl 테스트:
```bash
# 글 조회 (int_10 확인)
PHILGO_ENV=local ./test-api-function.sh post_view idx=1275689504

# 댓글 작성 후 응답 확인 (int_10 포함 여부)
# 브라우저 콘솔에서:
# func('create_comment', { idx_root: 12345, content: '테스트' }).then(r => console.log(r))
```

### Phase 2: 공통 위젯 생성

```
4. EarnedPointBadge 위젯 생성
5. philgo_api 패키지에서 export
```

### Phase 3: 글 읽기 화면 포인트 표시

```
6. PostViewMeta에 earnedPoint 파라미터 추가
7. PostViewScreen에서 post.int10 값 전달
```

### Phase 4: 댓글 포인트 표시

```
8. CommentDetail에서 comment.int10 표시
9. 댓글 작성 성공 시 SnackBar에 포인트 포함
```

### Phase 5: i18n

```
10. 4개 ARB 파일에 번역 키 추가
11. flutter gen-l10n 실행
```

### Phase 6: 검증

```
12. flutter analyze (에러 0개)
13. 앱 실행 → 글 읽기 → 포인트 확인
14. 댓글 작성 → 포인트 SnackBar 확인
```

---

## 7. UI 디자인

### 7.1 글 읽기 화면 — PostViewMeta 영역

```
┌─────────────────────────────────────────┐
│                                         │
│  [아바타]  닉네임                        │
│           2024-01-15 · [+500P]          │
│                                         │
│  ── 본문 내용 ──                         │
│                                         │
└─────────────────────────────────────────┘
```

포인트 뱃지 스타일:
- 배경: `scheme.primaryContainer`
- 텍스트: `scheme.onPrimaryContainer`
- 크기: `labelSmall`
- 패딩: 수평 6px, 수직 2px
- 모서리: borderRadius 4

### 7.2 댓글 영역 — CommentDetail

```
┌─────────────────────────────────────────┐
│                                         │
│  [아바타]  닉네임 · 3시간 전 · [+100P]   │
│           댓글 내용입니다.               │
│           [좋아요] [답글] [채팅]          │
│                                         │
└─────────────────────────────────────────┘
```

### 7.3 댓글 작성 후 SnackBar

```
┌──────────────────────────────────────┐
│  댓글 작성 완료! +100P 획득           │
└──────────────────────────────────────┘
```

### 7.4 디자인 원칙

- Flat Design: 그림자/테두리 없이 색상 대비로만 구분
- Theme 기반: 하드코딩 색상 금지
- `scheme.primaryContainer` / `scheme.onPrimaryContainer` 조합
- 포인트 > 0일 때만 표시 (0이거나 null이면 숨김)
- 포인트 큰 숫자 (1000 이상)는 `1K`, `2K` 형태로 축약하거나 천 단위 콤마 표시

---

## 핵심 체크리스트

- [ ] API 응답에서 int_10 필드 확인 (post_view, create_comment)
- [ ] EarnedPointBadge 공통 위젯 생성
- [ ] PostViewMeta에 획득 포인트 표시
- [ ] CommentDetail에 획득 포인트 표시
- [ ] 댓글 작성 SnackBar에 포인트 포함
- [ ] i18n 번역 키 추가 (4개 언어)
- [ ] flutter analyze 통과
- [ ] Theme 기반 스타일링 확인
- [ ] 포인트 0 또는 null일 때 숨김 확인
