# 필고 API

## 개요

필고 API는 `philgo_api` 패키지로 제공됩니다.
로컬 패키지 경로: `packages/philgo_v6_flutter`

> **📌 중요**: 필고 백엔드 API의 상세한 사용법, 프로토콜, 엔드포인트, 인증 방법 등은 반드시 [philgo-api-skill/SKILL.md](../../philgo-api-skill/SKILL.md)를 참조하세요. 이 문서는 Flutter 패키지 사용법만 다루며, API 프로토콜 전반에 대한 완전한 정보는 philgo-api-skill에서 제공합니다.

## 주요 서비스

### UserService

사용자 관련 기능:

```dart
UserService.instance.initialize(
  useUserPresence: true,
  onTapViewProfile: (context, user) { ... },
  onTapUserRecentPostItem: (context, post) { ... },
);
```

### MessagingService

푸시 알림:

```dart
await MessagingService.instance.initialize(
  domain: 'philgo_v6_app',
  onForegroundMessage: (message) { ... },
  onMessageOpenedFromBackground: (message) { ... },
  onMessageOpenedFromTerminated: (message) { ... },
);
```

### ChatService

채팅 기능:
- `ChatRoomScreen` - 채팅방 화면
- `CreateChatRoomScreen` - 채팅방 생성

### ReceiveShareService

외부 공유 수신:

```dart
ReceiveShareService.instance.initialize(
  categories: PhilgoCategory.majorCategories(),
  onCategorySelect: (postId, category, data) { ... },
  onData: (data) { ... },
);
```

## 주요 모델

### Post

게시글 모델:
```dart
Post.fromJson({'idx': 123})
post.subject    // 제목
post.content    // 내용
post.files      // 첨부파일 URL 목록
post.no_of_view // 조회수
post.no_of_comment // 댓글수
post.good       // 좋아요수
post.timeString // 작성시간
```

### User

사용자 모델:
```dart
user.uid        // Firebase UID
user.nickname   // 닉네임
user.photoUrl   // 프로필 사진
```

### Company

업체 모델:
```dart
company.idx     // 업체 ID
company.name    // 업체명
```

## PhilgoCategory

카테고리 관리:

```dart
// 주요 카테고리 목록
PhilgoCategory.majorCategories()

// 메뉴 카테고리 (서브카테고리 포함)
PhilgoCategory.menuCategories()  // List<(String postId, String? subcategory)>

// 홈 메뉴 카테고리
PhilgoCategory.homeMenuCategories()
```

## 다국어 지원

```dart
// 카테고리 번역
philgoTr(context, 'freetalk')  // 자유게시판
philgoTr(context, 'buyandsell') // 회원장터
```

## GlobalContext 설정

앱 시작 시 globalContext 설정 필수:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (globalNavigatorKey.currentContext != null) {
    PhilgoConfig.setGlobalContext(globalNavigatorKey.currentContext!);
  }
});
```

## PostListView

게시글 목록 위젯:

```dart
PostListView(
  postId: 'freetalk',
  category: null,
  enableHeroTransition: true,
  gridColumns: 2,  // 그리드 레이아웃 (null이면 리스트)
  tileBuilder: (post, onTap) => PostCard(post: post, onTap: onTap),
  onTap: (post) => PostViewScreen.push(context, post),
)
```

## API 엔드포인트

필고 API 서버: `https://philgo.com/api/`

버전 확인:
```bash
curl https://philgo.com/api/version.php
```
