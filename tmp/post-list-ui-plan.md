# 게시판 목록 디자인 개선 계획

> **핵심 원칙: 레이아웃과 로직은 절대 변경하지 않음**
> 색상, 폰트 무게, 애니메이션, 배지 등 **디자인 요소만** 수정

---

## 1. 현재 구현 분석

### 1.1 게시판 목록 컴포넌트 구조

| 컴포넌트 | 파일 위치 | 사용처 | 레이아웃 |
|---------|----------|--------|---------|
| **PostListTileItem** | `packages/philgo_api/.../post_list_tile.item.dart` | 일반 게시판 (freetalk, qna 등) | 조건부 레이아웃 |
| **PostCard** | `lib/widgets/post/post.card.dart` | buyandsell, youtube | Masonry 그리드 |
| **CompactPostListTile** | `lib/widgets/post/compact.post.list.tile.dart` | 사용자 화면 | 3행 고정 레이아웃 |

### 1.2 PostListTileItem 레이아웃 조건 (변경 금지)

```
조건 1: 썸네일 있음 (이미지/YouTube)
  → Row: [썸네일 81x81] + [제목 + 메타]

조건 2: 썸네일 없음 + 제목 24자 이상
  → Column: [제목] / [메타]

조건 3: 썸네일 없음 + 제목 24자 미만
  → Row: [제목 Expanded] + [메타 세로 2줄]

조건 4: 차단된 사용자
  → Row: [금지 아이콘] + [차단 메시지]
```

### 1.3 현재 디자인 요소

| 요소 | 현재 값 | 사용 위치 |
|------|--------|----------|
| **제목 색상** | `onSurface` (자동) | PostSubject |
| **메타 색상** | `outline` | PostListTileMeta |
| **닉네임 색상** | `onSurfaceVariant` | PostListTileMeta |
| **아이콘 색상** | `outline` | 모든 메타 아이콘 |
| **아이콘 크기** | 12-14px | lightClock, lightEye 등 |
| **썸네일 크기** | 81x81 | PostListTileUploadPreview |
| **모서리 반지름** | 12-16px | 카드, 썸네일 |
| **패딩** | 12-16px | 8배수 기반 |

---

## 2. 디자인 개선 방안 (레이아웃 변경 없음)

### 2.1 색상 계층구조 강화

#### 제목 색상 강조
**현재**: `onSurface` (검은색)
**개선**: `primary` (파란색) + `fontWeight: w600`

```dart
// PostSubject 수정
Text(
  post.subject,
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.w600,
  ),
)
```

#### 메타정보 색상 체계화

| 요소 | 현재 | 개선 | 효과 |
|------|------|------|------|
| 닉네임 | onSurfaceVariant | primary.withOpacity(0.8) | 작성자 강조 |
| 날짜 | outline | onSurfaceVariant | 가독성 향상 |
| 통계 아이콘 | outline | onSurfaceVariant | 일관성 |
| 통계 숫자 | outline | onSurfaceVariant | 가독성 |

### 2.2 상태 배지 시스템

**위치**: 제목 오른쪽 (Row에 추가, 레이아웃 변경 없음)

#### 새 댓글 배지 (N)
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: scheme.errorContainer,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text('N', style: TextStyle(
    fontSize: 10,
    color: scheme.onErrorContainer,
    fontWeight: FontWeight.w600,
  )),
)
```

#### 인기글 배지 (HOT) - 댓글 10개 이상
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  decoration: BoxDecoration(
    color: scheme.secondaryContainer,
    borderRadius: BorderRadius.circular(4),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      FaIcon(FontAwesomeIcons.lightFire, size: 10),
      SizedBox(width: 2),
      Text('HOT', style: TextStyle(
        fontSize: 10,
        color: scheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      )),
    ],
  ),
)
```

### 2.3 애니메이션 효과

#### 리스트 아이템 등장 애니메이션
```dart
PostListTileItem(post: post)
  .animate()
  .fadeIn(duration: 200.ms, delay: (index * 50).ms)
  .slideX(begin: 0.02, end: 0, curve: Curves.easeOut)
```

#### 탭 피드백 강화
```dart
InkWell(
  splashColor: scheme.primary.withOpacity(0.1),
  highlightColor: scheme.primary.withOpacity(0.05),
  // ... 기존 onTap
)
```

---

## 3. 수정 대상 파일 (정밀 분석)

### 3.1 PostSubject (제목 위젯)
**파일**: `packages/philgo_api/lib/src/post/widgets/post.subject.dart`

**현재 코드**:
```dart
Text(
  post.subject,
  style: Theme.of(context).textTheme.titleLarge,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

**개선 코드**:
```dart
Text(
  post.subject,
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.w600,
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

### 3.2 PostListTileMeta (메타정보 위젯)
**파일**: `packages/philgo_api/lib/src/post/widgets/post_list_tile/post_list_tile.meta.dart`

**현재 색상**:
- 닉네임: `onSurfaceVariant`
- 날짜/통계: `outline`
- 아이콘: `outline`

**개선 색상**:
- 닉네임: `primary.withOpacity(0.8)`
- 날짜: `onSurfaceVariant`
- 통계: `onSurfaceVariant`
- 아이콘: `onSurfaceVariant`

### 3.3 PostListTileItem (메인 타일 위젯)
**파일**: `packages/philgo_api/lib/src/post/widgets/post_list_tile/post_list_tile.item.dart`

**추가할 내용** (레이아웃 변경 없이):
- InkWell의 splashColor: `scheme.primary.withOpacity(0.1)`
- 상태 배지 추가 (제목 Row에)
- 애니메이션 효과 적용

### 3.4 CompactPostListTile (사용자 화면용)
**파일**: `lib/widgets/post/compact.post.list.tile.dart`

**개선**: PostSubject와 동일한 색상 체계 적용

### 3.5 PostListView (리스트 뷰)
**파일**: `packages/philgo_api/lib/src/post/widgets/post.list.view.dart`

**추가할 내용**:
- itemBuilder에서 index 기반 애니메이션 적용

---

## 4. 유지 사항 (변경 금지)

| 항목 | 현재 값 | 이유 |
|------|--------|------|
| Row/Column 구조 | 조건부 레이아웃 | 로직 변경 금지 |
| 썸네일 크기 | 81x81 | 레이아웃 유지 |
| 썸네일 위치 | 왼쪽 | 레이아웃 유지 |
| 패딩 값 | 12-16px | 8배수 유지 |
| 모서리 반지름 | 12-16px | Flat Design 유지 |
| 제목 최대 줄 수 | 1줄 | 레이아웃 유지 |
| 조건부 렌더링 | 24자 기준 | 로직 유지 |
| Masonry 그리드 | 2열 | 레이아웃 유지 |
| 게시판별 뷰 | List/Masonry | 로직 유지 |

---

## 5. 디자인 원칙 준수

### PhilGo Flat Design 2.0 규칙
- elevation: 0 유지
- 그림자 사용 안 함
- 색상 대비로만 구분
- 8배수 간격 유지
- Font Awesome Light 우선

### Material Design 3 규칙
- ColorScheme 사용
- TextTheme 사용
- Theme.of(context) 필수

---

## 6. 구현 순서 (확정)

### Step 1: PostSubject 제목 색상 변경
- color: scheme.primary
- fontWeight: FontWeight.w600

### Step 2: PostListTileMeta 색상 체계 조정
- 닉네임: primary.withOpacity(0.8)
- 날짜/통계: onSurfaceVariant

### Step 3: 상태 배지 추가
- 새 댓글 배지 (N) - errorContainer
- 인기글 배지 (HOT) - secondaryContainer

### Step 4: 애니메이션 적용
- fadeIn(200ms) + slideX(0.02)
- delay: index * 50ms

### Step 5: CompactPostListTile 동일 적용

### Step 6: 검증
- flutter analyze
- 다크/라이트 모드 테스트
- 성능 프로파일링

---

## 7. 예상 결과

### Before
- 제목: 검은색 (onSurface)
- 메타: 연한 회색 (outline)
- 상태 표시: 없음
- 애니메이션: 없음

### After
- 제목: 파란색 (primary) + 굵은 폰트
- 메타: 체계적 색상 (닉네임 강조)
- 상태 표시: 새 댓글(N)/인기글(HOT) 배지
- 애니메이션: 부드러운 등장 효과

---

## 8. 주의사항

1. **레이아웃 절대 변경 금지**
   - Row/Column 구조 유지
   - 썸네일 위치/크기 유지 (81x81)
   - 조건부 렌더링 로직 유지 (24자 기준)

2. **로직 변경 금지**
   - 차단 사용자 처리 유지
   - 게시판별 뷰 선택 유지 (List/Masonry)

3. **성능 고려**
   - 애니메이션 duration: 200ms (가볍게)
   - delay: index * 50ms (순차적)
   - 이미지 캐싱 유지
