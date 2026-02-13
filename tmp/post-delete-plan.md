# 게시글 삭제 후 목록에 잔류하는 버그 - 분석 및 해결 방안

## 문제 정의

**재현 경로**: 게시판 → 마사지게시판 → 글 생성 → 글 삭제 → 목록으로 돌아감 → **삭제된 글이 여전히 표시됨**

**영향 범위**: 마사지게시판뿐 아니라 **모든 게시판**에서 동일하게 발생하는 구조적 버그

**확인된 재현 게시판**:
- 마사지게시판 (massage) ✅ 재현됨
- 뉴스 (news) ✅ 재현됨
- 기타 모든 게시판 — `PagingController` 캐시 구조가 동일하므로 **모든 게시판에서 100% 동일하게 재현됨**

> 이 버그는 특정 게시판의 문제가 아니라, `PostListView`/`PostMasonryView`의 `PagingController` 캐시와 `context.pop()` 결과 미반환이라는 **앱 전체 아키텍처 레벨의 구조적 결함**입니다.

---

## COT (Chain-of-Thought) 분석

### 1단계: 삭제 실행 흐름 추적

글 삭제는 **3개의 독립적인 경로**로 실행될 수 있습니다:

#### 경로 A: AppBar → PostViewOptionMenu → onDeleteCompleted 콜백
```
PostViewAppBar (post_view_app_bar.dart:57)
  → PostViewOptionMenu._handleAction (post_view_option_menu.dart:247-265)
    → await deletePost(post.idx)           ← 서버 삭제 (API 호출)
    → onDeleteCompleted(context)           ← 콜백 호출
      → context.pop()                      ← 결과 없이 화면 닫기 ❌
```
**파일**: `lib/screens/post/post.view.screen.dart:247-248`
```dart
onDeleteCompleted: (context) {
  context.pop();  // ← 삭제 결과를 반환하지 않음!
},
```

#### 경로 B: PostViewButtons → 휴지통 버튼 직접 클릭 (onDeleteCompleted 콜백 미사용)
```
PostViewButtons (post_view_buttons.dart:184-206)
  → await deletePost(widget.post.idx)      ← 서버 삭제 (API 호출)
  → context.pop()                          ← 결과 없이 화면 닫기 ❌
```
**파일**: `lib/screens/post/widgets/post_view_buttons.dart:201-205`
```dart
if (confirm) {
  await deletePost(widget.post.idx);
  if (context.mounted) {
    context.pop();  // ← onDeleteCompleted 콜백을 사용하지 않고 직접 pop! ❌
  }
}
```
> **⚠️ 중요**: 이 경로는 `onDeleteCompleted` 콜백을 **완전히 우회**합니다.
> `PostViewScreen`에서 `onDeleteCompleted`를 전달하고 있지만, `PostViewButtons`의 휴지통 버튼은 이를 무시하고 직접 `context.pop()`을 호출합니다.

#### 경로 C: PostViewButtons → PostViewOptionMenu → onDeleteCompleted 콜백
```
PostViewButtons (post_view_buttons.dart:217-231)
  → PostViewOptionMenu._handleAction
    → await deletePost(post.idx)           ← 서버 삭제 (API 호출)
    → onDeleteCompleted(context)           ← 콜백 호출
      → context.pop()                      ← 결과 없이 화면 닫기 ❌
```
**파일**: `lib/screens/post/widgets/post_view_buttons.dart:228-230`
```dart
onDeleteCompleted: (context) {
  context.pop();  // ← 결과 없이 화면 닫기 ❌
},
```

### 2단계: 목록 복귀 시 동작

**파일**: `lib/screens/home/sections/forum.home.dart:283-290`
```dart
Future<void> onPostTapped(Post post) async {
  await PostViewScreen.push(context, post);     // ← pop 결과: null (삭제 여부 불명)
  if (mounted) {
    setState(() {});  // ← 단순 리빌드. PagingController 캐시 변경 없음 ❌
  }
}
```

### 3단계: PagingController 상태 유지

**파일**: `packages/philgo_api/lib/src/post/widgets/post.list.view.dart`

`PostListView`는 `infinite_scroll_pagination` 패키지의 `PagingController`를 사용합니다:
- `PagingController`는 **자체 `PagingState`에 페이지별 데이터를 캐시**합니다
- `didUpdateWidget`은 `postId` 또는 `category` 변경 시에만 `refresh()`를 호출합니다
- 부모의 `setState({})`로 리빌드되어도 **캐시된 데이터는 그대로 유지**됩니다

---

## TOT (Tree-of-Thought) 분석 — 근본 원인 분해

### 원인 A: 3개 삭제 경로 모두 `context.pop()` 시 결과를 반환하지 않음

| 삭제 경로 | 파일:라인 | 문제 |
|-----------|-----------|------|
| AppBar → OptionMenu | `post.view.screen.dart:248` | `context.pop()` — 결과 미반환 |
| Buttons → 휴지통 직접 | `post_view_buttons.dart:204` | `context.pop()` — 콜백 우회 + 결과 미반환 |
| Buttons → OptionMenu | `post_view_buttons.dart:229` | `context.pop()` — 결과 미반환 |

`PostViewScreen.push`의 시그니처는 `Future<Post?>` 반환이지만, 삭제 시 `pop()`에 결과를 전달하지 않으므로 호출측에서 삭제 여부를 **절대 알 수 없습니다**.

### 원인 B: ForumHome에서 삭제 후 처리 로직 없음

`forum.home.dart:289`의 `setState(() {})`는 위젯 트리를 리빌드하지만:
- `PostListView` 내부의 `PagingController`는 **자체 상태를 유지**
- `didUpdateWidget`은 `postId`/`category` 변경만 감지 → 리빌드로는 캐시 갱신 불가
- 결과: **삭제된 글이 PagingController 캐시에 잔류**

### 원인 C: Controller에 remove 메서드 부재

| Controller | add() | remove() |
|------------|-------|----------|
| `PostListViewController` | ✅ 있음 | ❌ **없음** |
| `PostMasonryViewController` | ✅ 있음 (비어있음) | ❌ **없음** |

외부에서 `PagingController` 캐시의 특정 게시글을 제거할 방법이 전혀 없습니다.

---

## 종합 해결 방안 (4곳 수정)

### 수정 1: `PostListViewController`에 `remove()` 메서드 추가

**파일**: `packages/philgo_api/lib/src/post/widgets/post.list.view.dart`

**위치**: `PostListViewController` 클래스 내부 (`add()` 메서드 아래)

```dart
class PostListViewController {
  late PostListViewState state;

  // ... 기존 add() 메서드 ...

  /// 삭제된 게시글을 목록에서 즉시 제거
  /// Remove a deleted post from the cached pages immediately
  ///
  /// [post] 삭제된 게시글 객체 (idx로 식별)
  /// [post] The deleted post object (identified by idx)
  ///
  /// PagingController의 모든 페이지를 순회하며 해당 게시글을 제거합니다.
  /// 서버 재요청 없이 클라이언트 캐시에서만 제거하므로 즉각적인 UI 반영이 가능합니다.
  void remove(Post post) {
    final controller = state.pagingController;
    final currentState = controller.value;

    // 캐시된 페이지가 없으면 무시
    // Ignore if no cached pages
    if (currentState.pages == null || currentState.pages!.isEmpty) return;

    // 모든 페이지에서 해당 idx의 게시글 필터링 제거
    // Filter out the post with matching idx from all pages
    final updatedPages = currentState.pages!.map((page) {
      return page.where((p) => p.idx != post.idx).toList();
    }).toList();

    // 업데이트된 상태로 컨트롤러 갱신
    // Update controller with filtered state
    controller.value = PagingState<int, Post>(
      pages: updatedPages,
      keys: currentState.keys,
      hasNextPage: currentState.hasNextPage,
      isLoading: false,
    );
  }
}
```

### 수정 2: `PostMasonryViewController`에 `remove()` 메서드 추가

**파일**: `packages/philgo_api/lib/src/post/widgets/post.masonry.view.dart`

**위치**: `PostMasonryViewController` 클래스 내부

```dart
class PostMasonryViewController {
  late PostMasonryViewState state;

  void add(Post post) {}  // 기존 코드 (현재 비어있음)

  /// 삭제된 게시글을 Masonry 그리드에서 즉시 제거
  /// Remove a deleted post from the masonry grid immediately
  void remove(Post post) {
    final controller = state.pagingController;
    final currentState = controller.value;

    if (currentState.pages == null || currentState.pages!.isEmpty) return;

    final updatedPages = currentState.pages!.map((page) {
      return page.where((p) => p.idx != post.idx).toList();
    }).toList();

    controller.value = PagingState<int, Post>(
      pages: updatedPages,
      keys: currentState.keys,
      hasNextPage: currentState.hasNextPage,
      isLoading: false,
    );
  }
}
```

### 수정 3: 3개 삭제 경로 모두에서 `context.pop(widget.post)` 반환

#### 수정 3-A: PostViewScreen — AppBar의 onDeleteCompleted 콜백

**파일**: `lib/screens/post/post.view.screen.dart:246-249`

```dart
// 변경 전
onDeleteCompleted: (context) {
  context.pop();
},

// 변경 후: 삭제된 게시글을 pop 결과로 반환
onDeleteCompleted: (context) {
  context.pop(widget.post);
},
```

#### 수정 3-B: PostViewButtons — 휴지통 버튼 직접 클릭 (가장 중요!)

**파일**: `lib/screens/post/widgets/post_view_buttons.dart:197-206`

```dart
// 변경 전
ComicActionButton(
  icon: FontAwesomeIcons.trash,
  color: Theme.of(context).colorScheme.error,
  onPressed: () async {
    if (post.no_of_comment >= 1) {
      showInfoDialog(
        context,
        Lo.of(context)!.alert,
        Lo.of(context)!.postWithCommentsCannotBeDeleted,
      );
      return;
    }

    final confirm = await showConfirmDialog(
      message: Lo.of(context)!.confirmDeletePost,
    );

    if (confirm) {
      await deletePost(widget.post.idx);
      if (context.mounted) {
        context.pop();          // ← 결과 없이 pop ❌
      }
    }
  },
),

// 변경 후: onDeleteCompleted 콜백을 사용하도록 통일
ComicActionButton(
  icon: FontAwesomeIcons.trash,
  color: Theme.of(context).colorScheme.error,
  onPressed: () async {
    if (post.no_of_comment >= 1) {
      showInfoDialog(
        context,
        Lo.of(context)!.alert,
        Lo.of(context)!.postWithCommentsCannotBeDeleted,
      );
      return;
    }

    final confirm = await showConfirmDialog(
      message: Lo.of(context)!.confirmDeletePost,
    );

    if (confirm) {
      await deletePost(widget.post.idx);
      if (context.mounted) {
        widget.onDeleteCompleted?.call(context);  // ← 콜백으로 통일 ✅
      }
    }
  },
),
```

> **⚠️ 핵심 수정**: 현재 `PostViewButtons`의 휴지통 버튼은 `onDeleteCompleted` 콜백을 **완전히 무시**하고 직접 `context.pop()`을 호출합니다.
> 이를 콜백 호출 방식으로 통일해야 삭제 결과를 안정적으로 전달할 수 있습니다.

#### 수정 3-C: PostViewButtons 내부 PostViewOptionMenu의 onDeleteCompleted 콜백

**파일**: `lib/screens/post/widgets/post_view_buttons.dart:228-230`

```dart
// 변경 전
onDeleteCompleted: (context) {
  context.pop();
},

// 변경 후: 부모 콜백을 호출하여 삭제 결과를 위임
onDeleteCompleted: (context) {
  widget.onDeleteCompleted?.call(context);
},
```

#### 수정 3-D: PostViewScreen — PostViewButtons의 onDeleteCompleted 콜백

**파일**: `lib/screens/post/post.view.screen.dart:716-718`

```dart
// 변경 전
onDeleteCompleted: (context) {
  context.pop();
},

// 변경 후: 삭제된 게시글을 pop 결과로 반환
onDeleteCompleted: (context) {
  context.pop(widget.post);
},
```

### 수정 4: `ForumHome.onPostTapped`에서 삭제 결과 처리

**파일**: `lib/screens/home/sections/forum.home.dart:283-291`

```dart
// 변경 전
Future<void> onPostTapped(Post post) async {
  await PostViewScreen.push(context, post);

  /// 돌아왔을 때 UI 업데이트 (수정된 내용 반영)
  /// Update UI when returned (reflect edited content)
  if (mounted) {
    setState(() {});
  }
}

// 변경 후: 삭제 결과를 받아서 목록 캐시에서 즉시 제거
Future<void> onPostTapped(Post post) async {
  final result = await PostViewScreen.push(context, post);

  // result != null이면 삭제된 게시글 → PagingController 캐시에서 제거
  // If result is not null, the post was deleted → remove from PagingController cache
  if (result != null) {
    if (isMasonryForum) {
      masonryController.remove(result);
    } else {
      listController.remove(result);
    }
  }

  /// 돌아왔을 때 UI 업데이트 (수정된 내용 반영)
  /// Update UI when returned (reflect edited content)
  if (mounted) {
    setState(() {});
  }
}
```

---

## 수정 파일 요약

| # | 파일 | 수정 내용 | 영향도 |
|---|------|-----------|--------|
| 1 | `packages/philgo_api/.../post.list.view.dart` | `PostListViewController`에 `remove()` 추가 | **핵심** |
| 2 | `packages/philgo_api/.../post.masonry.view.dart` | `PostMasonryViewController`에 `remove()` 추가 | **핵심** |
| 3-A | `lib/screens/post/post.view.screen.dart:248` | AppBar `onDeleteCompleted`에서 `pop(widget.post)` | **필수** |
| 3-B | `lib/.../post_view_buttons.dart:201-205` | 휴지통 버튼에서 `onDeleteCompleted` 콜백 사용으로 통일 | **가장 중요** |
| 3-C | `lib/.../post_view_buttons.dart:228-230` | OptionMenu `onDeleteCompleted`에서 부모 콜백 위임 | **필수** |
| 3-D | `lib/screens/post/post.view.screen.dart:716-718` | Buttons `onDeleteCompleted`에서 `pop(widget.post)` | **필수** |
| 4 | `lib/.../forum.home.dart:283-291` | `onPostTapped`에서 삭제 결과 처리 + `remove()` 호출 | **핵심** |

---

## pop 결과 규약

| 상황 | `context.pop()` 호출 | `PostViewScreen.push` 반환값 |
|------|---------------------|----------------------------|
| 뒤로가기 (일반) | `pop()` 또는 `pop(null)` | `null` |
| 글 삭제 후 | `pop(widget.post)` | `Post` 객체 (삭제된 글) |

호출측에서는 `result != null`이면 삭제로 판단하고, `result.idx`로 캐시에서 해당 글을 제거합니다.

---

## 추가 고려사항: PostViewScreen.push를 호출하는 다른 위치들

`PostViewScreen.push`를 호출하는 곳이 **총 13곳**입니다. ForumHome 외에도 삭제 후 돌아갈 때 동일한 문제가 발생할 수 있는 위치:

| 파일 | 라인 | 컨텍스트 | 영향 여부 |
|------|------|----------|-----------|
| `forum.home.dart` | 284 | 게시판 목록 → 글 상세 | ✅ **직접 영향** (본 수정 대상) |
| `main.home.dart` | 134, 152, 175 | 메인 홈 위젯 | ⚠️ 영향 가능 (별도 위젯이므로 리빌드로 갱신) |
| `home_post_section.dart` | 131 | 홈 게시판 섹션 | ⚠️ 영향 가능 |
| `latest.user.posts.dart` | 205 | 사용자 최근 게시글 | ⚠️ 영향 가능 |
| `user.posts.dart` | 48 | 사용자 게시글 목록 | ⚠️ 영향 가능 |
| `comment.card.dart` | 49 | 댓글 → 부모 글 이동 | △ 낮음 |
| `search.screen.dart` | 93 | 검색 결과 → 글 이동 | △ 낮음 |
| `init.functions.dart` | 65, 69 | FCM 푸시 알림 → 글 이동 | △ 낮음 |
| `post.create.screen.dart` | 403, 450 | 글 작성 → 글 보기 | △ 낮음 (생성 직후) |
| `quick_post.screen.dart` | 470 | 빠른 글 작성 → 글 보기 | △ 낮음 |
| `main.dart` | 84 | 유저 최근글 아이템 탭 | ⚠️ 영향 가능 |
| `driver_main.dart` | 73 | 드라이버 메인 | ⚠️ 영향 가능 |

> **참고**: `⚠️ 영향 가능` 표시된 위치들은 현재 `PostViewScreen.push`의 반환값을 사용하지 않으므로,
> 삭제 후에도 로컬 데이터가 갱신되지 않습니다. 단, 이 위치들은 `PagingController`를 사용하지 않고
> 서버에서 매번 데이터를 가져오는 경우가 많아, 재진입 시 자연스럽게 갱신될 수 있습니다.
> **최우선으로 `forum.home.dart`만 수정하면 핵심 문제가 해결**됩니다.

---

## 검증 시나리오

수정 후 아래 시나리오를 테스트해야 합니다:

### 시나리오 1: 기본 삭제 (PostViewButtons 휴지통 버튼)
1. 마사지게시판 → 글 작성 → 글 상세 → 하단 휴지통 아이콘 클릭 → 삭제 확인
2. 목록으로 돌아온 후 삭제된 글이 **표시되지 않아야** 함 ✅

### 시나리오 2: AppBar 메뉴 삭제 (PostViewOptionMenu)
1. 마사지게시판 → 글 작성 → 글 상세 → AppBar 점세개 메뉴 → 삭제
2. 목록으로 돌아온 후 삭제된 글이 **표시되지 않아야** 함 ✅

### 시나리오 3: PostViewButtons 내 OptionMenu 삭제
1. 마사지게시판 → 글 작성 → 글 상세 → 하단 점세개 메뉴 → 삭제
2. 목록으로 돌아온 후 삭제된 글이 **표시되지 않아야** 함 ✅

### 시나리오 4: Masonry 레이아웃 (buyandsell/youtube 게시판)
1. buyandsell 게시판 → 글 작성 → 글 상세 → 삭제
2. 목록으로 돌아온 후 삭제된 글이 **표시되지 않아야** 함 ✅

### 시나리오 5: 일반 뒤로가기 (삭제 없이)
1. 게시판 → 글 상세 → 뒤로가기
2. 목록이 정상적으로 표시되어야 함 (기존 동작 유지) ✅

### 시나리오 6: 댓글 있는 글 삭제 시도
1. 댓글이 있는 글 → 삭제 시도
2. "댓글이 있는 글은 삭제할 수 없습니다" 알림 표시 (기존 동작 유지) ✅
