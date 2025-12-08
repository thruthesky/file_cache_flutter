# 게시글 목록 첫 페이지 캐시

## 개요

게시글 목록 화면 진입 시 빠른 로딩을 위해 첫 페이지 데이터를 파일 기반으로 캐시합니다.

### 핵심 원칙

1. **캐시 우선 표시**: 캐시된 데이터가 있으면 즉시 화면에 표시
2. **항상 서버 요청**: 캐시 유무와 관계없이 서버에서 최신 데이터 가져옴
3. **캐시 업데이트**: 서버 응답으로 화면 갱신 및 캐시 저장
4. **첫 페이지만 캐시**: 2페이지 이상은 캐시하지 않음

---

## 동작 흐름

```
1. 화면 진입 (initState)
   ↓
2. 캐시 파일에서 첫 페이지 로드 (getPostsFromCache)
   ↓
3. 캐시 있음 → PagingController에 즉시 삽입 → 화면 표시
   ↓
4. 서버 API 호출 (getPosts) - 항상 실행됨
   ↓
5. 서버 응답 → PagingController 업데이트 → 화면 갱신
   ↓
6. 첫 페이지(page == 1)면 캐시 저장 (savePostsToCache)
```

### 시퀀스 다이어그램

```
User          PostListView        Cache              Server
  |                |                |                   |
  |---(화면진입)-->|                |                   |
  |                |---(캐시조회)-->|                   |
  |                |<--(캐시데이터)-|                   |
  |<--(즉시표시)---|                |                   |
  |                |---(API요청)----------------------->|
  |                |<--(서버응답)----------------------|
  |<--(화면갱신)---|                |                   |
  |                |---(캐시저장)-->|                   |
  |                |                |                   |
```

---

## 구현 파일

### 1. 캐시 유틸리티

**파일**: `packages/philgo_v6_flutter/lib/src/cache/post_cache.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 캐시 키 생성: posts_{postId}_{category}.json
String _getCacheKey(String? postId, String? category) {
  final safePostId = postId ?? 'all';
  final safeCategory = category ?? 'all';
  return 'posts_${safePostId}_$safeCategory.json';
}

/// 캐시 디렉토리 경로 반환
Future<Directory> _getCacheDirectory() async {
  final tempDir = await getTemporaryDirectory();
  final cacheDir = Directory('${tempDir.path}/philgo_post_cache');
  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }
  return cacheDir;
}

/// 캐시에서 첫 페이지 읽기
Future<PostList?> getPostsFromCache(String? postId, String? category);

/// 캐시에 첫 페이지 저장
Future<void> savePostsToCache(String? postId, String? category, PostList data);

/// 전체 캐시 삭제
Future<void> clearPostCache();

/// 특정 카테고리 캐시만 삭제
Future<void> clearPostCacheFor(String? postId, String? category);
```

### 2. PostSimpleListView 수정

**파일**: `packages/philgo_v6_flutter/lib/src/post/widgets/post.simple.list.view.dart`

```dart
class PostSimpleListViewState extends State<PostSimpleListView> {
  bool _cacheLoaded = false;

  late final pagingController = PagingController<int, Post>(
    fetchPage: (pagekey) async {
      final res = await getPosts(...);

      // 첫 페이지면 캐시 저장
      if (pagekey == 1) {
        savePostsToCache(widget.postId, widget.category, res);
      }

      return res.posts;
    },
  );

  @override
  void initState() {
    super.initState();
    _loadCachedFirstPage();  // 캐시 먼저 로드
  }

  Future<void> _loadCachedFirstPage() async {
    if (_cacheLoaded) return;
    _cacheLoaded = true;

    final cached = await getPostsFromCache(widget.postId, widget.category);

    if (cached != null && cached.posts.isNotEmpty && mounted) {
      final currentPages = pagingController.value.pages;
      if (currentPages == null || currentPages.isEmpty) {
        // 캐시 데이터를 PagingController에 삽입
        pagingController.value = PagingState<int, Post>(
          pages: [cached.posts],
          keys: [1],
          hasNextPage: cached.posts.length >= 20,
          isLoading: false,
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant PostSimpleListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 카테고리 변경 시 캐시 다시 로드
    if (oldWidget.postId != widget.postId ||
        oldWidget.category != widget.category) {
      _cacheLoaded = false;
      _loadCachedFirstPage();
      pagingController.refresh();
    }
  }
}
```

### 3. PostGridView 수정

**파일**: `packages/philgo_v6_flutter/lib/src/post/widgets/post.grid.view.dart`

PostSimpleListView와 동일한 캐시 로직 적용

---

## 캐시 파일 저장 위치

```
{임시디렉토리}/philgo_post_cache/
├── posts_freetalk_all.json
├── posts_freetalk_discussion.json
├── posts_buyandsell_호텔.json
├── posts_qna_all.json
└── ...
```

### 캐시 키 규칙

| postId | category | 캐시 파일명 |
|--------|----------|-------------|
| `freetalk` | `null` | `posts_freetalk_all.json` |
| `freetalk` | `discussion` | `posts_freetalk_discussion.json` |
| `buyandsell` | `호텔` | `posts_buyandsell_호텔.json` |

---

## 캐시 API

### getPostsFromCache

```dart
/// 캐시에서 첫 페이지 게시글 로드
///
/// 캐시가 없거나 읽기 실패 시 null 반환
Future<PostList?> getPostsFromCache(String? postId, String? category)
```

### savePostsToCache

```dart
/// 첫 페이지 게시글을 캐시에 저장
///
/// 저장 실패 시 조용히 무시 (캐시는 선택적 기능)
Future<void> savePostsToCache(String? postId, String? category, PostList data)
```

### clearPostCache

```dart
/// 모든 게시글 캐시 삭제
///
/// 로그아웃 시 또는 캐시 초기화 필요 시 호출
Future<void> clearPostCache()
```

### clearPostCacheFor

```dart
/// 특정 카테고리의 캐시만 삭제
///
/// 게시글 작성/수정/삭제 후 해당 카테고리 캐시 갱신 필요 시 호출
Future<void> clearPostCacheFor(String? postId, String? category)
```

---

## 패키지 의존성

`packages/philgo_v6_flutter/pubspec.yaml`에 추가:

```yaml
dependencies:
  path_provider: ^2.1.0
```

---

## 주의사항

### 캐시와 서버 데이터 경쟁 조건

캐시 로드와 서버 요청이 동시에 진행되므로:
- 캐시 로드가 먼저 완료되면 캐시 데이터 표시 → 서버 데이터로 교체
- 서버 요청이 먼저 완료되면 서버 데이터만 표시 (캐시 무시)

### 캐시 무효화 시점

다음 상황에서 캐시 삭제를 고려:
- 사용자 로그아웃 시 (`clearPostCache()`)
- 게시글 작성/수정/삭제 후 (`clearPostCacheFor(postId, category)`)
- 앱 버전 업데이트 시

### 캐시 만료

현재 구현에서는 캐시 만료 시간이 없습니다.
항상 서버에서 최신 데이터를 가져오므로 캐시 만료가 필수적이지 않습니다.
필요시 캐시 저장 시 타임스탬프를 추가하여 만료 로직 구현 가능합니다.

---

## 향후 개선 사항

1. **캐시 만료 시간 추가**: 오래된 캐시 자동 삭제
2. **캐시 크기 제한**: 너무 많은 캐시 파일 방지
3. **게시글 작성/수정/삭제 시 자동 캐시 무효화**
4. **메모리 캐시 레이어 추가**: 파일 I/O 감소
