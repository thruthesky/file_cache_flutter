# 라우팅 시스템

## 개요

필고 앱은 `go_router` 패키지(^16.0.0)를 사용하여 라우팅을 관리합니다.

## 라우터 설정

`lib/router.dart`에서 라우터를 정의합니다.

## 글로벌 네비게이터 키

```dart
final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext!;
```

`globalContext`를 통해 어디서든 네비게이션 접근 가능합니다.

## 주요 라우트

| 경로 | 화면 | 설명 |
|------|------|------|
| `/` | HomeScreen | 홈 화면 |
| `/entry` | EntryScreen | 로그인 전 진입점 |
| `/chat/:id` | ChatRoomScreen | 채팅방 |
| `/post` | PostViewScreen | 게시글 상세 |
| `/post/create` | PostCreateScreen | 글쓰기 |
| `/profile/edit` | ProfileEditScreen | 프로필 수정 |
| `/profile/:uid` | ProfileViewScreen | 프로필 보기 |
| `/company` | CompanyListScreen | 업체 목록 |
| `/company/form` | CompanyFormScreen | 업체 등록/수정 |
| `/company/view` | CompanyViewScreen | 업체 상세 |

## 리다이렉트 로직

로그인 상태에 따른 자동 리다이렉트:

```dart
redirect: (context, state) {
  if (state.fullPath == EntryScreen.routeName) {
    return null;
  }
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return EntryScreen.routeName;
  }
  return null;
}
```

## 딥링크 처리

- `/post/list.php` → ForumHome으로 리다이렉트
- `/post/view.php?idx=123` → PostViewScreen으로 이동
- `/chat/rooms.php?id=xxx` → ChatRoomScreen으로 이동

## 화면 이동 패턴

각 화면에 static `push` 메서드 제공:

```dart
// 예시: PostViewScreen
static Future<void> push(BuildContext context, Post post) async {
  await context.push(routeName, extra: post);
}
```
