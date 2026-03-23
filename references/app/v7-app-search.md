# Flutter 앱 검색 기능 (Google CSE WebView)

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처](#2-아키텍처)
- [3. 파일 구조](#3-파일-구조)
- [4. SearchScreen — Google CSE WebView 검색 화면](#4-searchscreen--google-cse-webview-검색-화면)
  - [4.1 기본 정보](#41-기본-정보)
  - [4.2 Google CSE 설정](#42-google-cse-설정)
  - [4.3 WebView URL 생성](#43-webview-url-생성)
  - [4.4 필고 URL 감지 및 앱 내 이동](#44-필고-url-감지-및-앱-내-이동)
  - [4.5 URL 파싱 로직](#45-url-파싱-로직)
- [5. SearchDialog — Comic 스타일 검색 다이얼로그](#5-searchdialog--comic-스타일-검색-다이얼로그)
  - [5.1 기본 정보](#51-기본-정보)
  - [5.2 사용법](#52-사용법)
  - [5.3 디자인 요소](#53-디자인-요소)
- [6. 포럼 헤더 검색 버튼 연동](#6-포럼-헤더-검색-버튼-연동)
- [7. 라우팅](#7-라우팅)
- [8. 번역 키](#8-번역-키)
- [9. 전체 검색 흐름도](#9-전체-검색-흐름도)

---

## 1. 개요

필고 앱의 검색 기능은 **Google Custom Search Engine (CSE)**을 WebView로 표시하여
philgo.com 도메인 전체를 검색하는 방식이다.
검색 결과에서 필고 게시글 URL을 클릭하면 WebView 대신 앱 내 `PostViewScreen`으로 이동한다.

### 핵심 원칙

| 원칙 | 설명 |
|------|------|
| **Google CSE 사용** | philgo.com 전용 커스텀 검색 엔진 (CSE ID: `d37786943cf92484d`) |
| **WebView 표시** | `webview_flutter` 패키지로 CSE 검색 결과 페이지 렌더링 |
| **URL 인터셉트** | WebView 내 링크 클릭 시 필고 게시글 URL이면 앱 내 화면으로 이동 |
| **Comic 스타일** | 검색 다이얼로그는 2.0 테두리, 그라데이션 헤더, 애니메이션 적용 |

---

## 2. 아키텍처

```
[ForumScreen 카테고리 헤더]
    │ 검색 버튼(돋보기 아이콘) 클릭
    ▼
[SearchDialog] ← Comic 스타일, 자동 키보드 표시
    │ 검색어 입력 후 "검색" 버튼 또는 Enter
    ▼
[SearchScreen] ← Google CSE WebView
    │ 검색 결과 링크 클릭
    ├─ 필고 게시글 URL → PostViewScreen (앱 내 이동)
    └─ 기타 URL → WebView 내 로딩
```

---

## 3. 파일 구조

```
lib/search/
├── search.screen.dart      # SearchScreen — Google CSE WebView 검색 화면
└── search_dialog.dart       # SearchDialog — Comic 스타일 검색어 입력 다이얼로그
```

---

## 4. SearchScreen — Google CSE WebView 검색 화면

### 4.1 기본 정보

| 항목 | 값 |
|------|-----|
| 클래스명 | `SearchScreen` |
| 파일 위치 | `lib/search/search.screen.dart` |
| routeName | `/search` |
| 필수 파라미터 | `searchTerm` (String) — 검색어 |
| 화면 이동 | `SearchScreen.push(context, searchTerm)` |

### 4.2 Google CSE 설정

| 항목 | 값 |
|------|-----|
| CSE ID | `d37786943cf92484d` |
| 검색 대상 | philgo.com 도메인 전체 |
| 기본 URL | `https://philgo.com/page/search/cse.php` |

### 4.3 WebView URL 생성

```dart
final encodedSearchTerm = Uri.encodeComponent(widget.searchTerm);
final searchUrl = '$_baseSearchUrl?search_term=$encodedSearchTerm&view_mode=webview&device=mobile';
```

| URL 파라미터 | 설명 |
|-------------|------|
| `search_term` | 검색어 (URL 인코딩) |
| `view_mode=webview` | 웹뷰 전용 모드 (불필요한 UI 숨김) |
| `device=mobile` | 모바일 최적화 레이아웃 |

### 4.4 필고 URL 감지 및 앱 내 이동

WebView의 `NavigationDelegate.onNavigationRequest`에서 URL을 인터셉트한다.

```dart
_controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onNavigationRequest: (NavigationRequest request) {
        final parsed = _parsePhilgoUrl(request.url);
        if (parsed != null && parsed.isPostView && parsed.idx != null) {
          // Post 객체 생성 → PostViewScreen으로 이동
          PostViewScreen.push(context, post);
          return NavigationDecision.prevent; // WebView 네비게이션 차단
        }
        return NavigationDecision.navigate; // 그 외는 WebView 내 로딩
      },
    ),
  )
  ..loadRequest(Uri.parse(searchUrl));
```

### 4.5 URL 파싱 로직

`_parsePhilgoUrl()` 함수는 SearchScreen 파일 내에 private으로 정의되어 있다.

**지원하는 URL 패턴:**

| 패턴 | 예시 |
|------|------|
| v6 게시글 | `https://philgo.com/post/view.php?idx=123&post_id=freetalk` |
| v4 숫자만 | `https://philgo.com/?1275666415` |
| v4 module+action | `https://philgo.com/?module=post&action=view&post_id=freetalk&idx=123` |

**반환 타입:**

```dart
typedef _PhilgoUrlResult = ({
  String? postId,
  int? idx,
  String? category,
  bool isPostView,
});
```

---

## 5. SearchDialog — Comic 스타일 검색 다이얼로그

### 5.1 기본 정보

| 항목 | 값 |
|------|-----|
| 클래스명 | `SearchDialog` |
| 파일 위치 | `lib/search/search_dialog.dart` |
| 반환값 | `String?` (검색어, 취소 시 null) |

### 5.2 사용법

```dart
final searchTerm = await SearchDialog.show(context);
if (searchTerm != null && searchTerm.isNotEmpty) {
  SearchScreen.push(context, searchTerm);
}
```

### 5.3 디자인 요소

| 요소 | 구현 |
|------|------|
| **스타일** | Comic 스타일 — 2.0 테두리, 둥근 모서리(16px), 그림자 없음 |
| **헤더** | `primaryContainer` 그라데이션 배경, 돋보기 아이콘 + "검색" 텍스트 |
| **입력 필드** | `surfaceContainerHighest` 배경, 2.0 outline 테두리, 포커스 시 `primary` 2.5 테두리 |
| **자동 키보드** | `addPostFrameCallback`에서 `_focusNode.requestFocus()` 호출 |
| **애니메이션** | `flutter_animate` — fadeIn, slideY, scale 효과 |
| **취소 버튼** | outline 스타일, `onSurfaceVariant` 색상 |
| **검색 버튼** | `primary` 그라데이션 배경, `onPrimary` 색상, bold 텍스트 |
| **키보드 액션** | `TextInputAction.search` — Enter로 바로 검색 |

---

## 6. 포럼 헤더 검색 버튼 연동

`ForumScreen`의 카테고리 헤더(`PostListHeaderCategories`) 오른쪽에 검색 버튼을 배치한다.

### 구현 위치

`lib/post/list/forum.screen.dart`

### 레이아웃 구조

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: PostListHeaderCategories(...), // 카테고리 Wrap
    ),
    Padding(
      padding: const EdgeInsets.only(right: 8, top: 8),
      child: GestureDetector(
        onTap: () => _openSearch(context),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: FaIcon(FontAwesomeIcons.lightMagnifyingGlass, size: 16),
        ),
      ),
    ),
  ],
)
```

### 검색 메서드

```dart
void _openSearch(BuildContext context) async {
  final searchTerm = await SearchDialog.show(context);
  if (searchTerm != null && searchTerm.isNotEmpty && mounted) {
    SearchScreen.push(context, searchTerm);
  }
}
```

---

## 7. 라우팅

### GoRouter 라우트 정의 (`lib/router.dart`)

```dart
GoRoute(
  path: SearchScreen.routeName,  // '/search'
  name: SearchScreen.routeName,
  builder: (context, state) {
    final searchTerm = state.extra as String? ?? '';
    return SearchScreen(searchTerm: searchTerm);
  },
),
```

### 화면 이동 패턴

```dart
// SearchDialog → SearchScreen
SearchScreen.push(context, searchTerm);
// 내부: ctx.push('/search', extra: searchTerm)

// SearchScreen → PostViewScreen (필고 URL 감지 시)
PostViewScreen.push(context, post);
```

---

## 8. 번역 키

`lib/l10n/translations.dart`에 다음 키가 등록되어 있다.

| 키 (한글) | ko | en |
|----------|----|----|
| `'검색'` | 검색 | Search |
| `'돌아가기'` | 돌아가기 | Back |
| `'취소'` | 취소 | Cancel |

---

## 9. 전체 검색 흐름도

```
┌──────────────────────────────────────────────────────────────┐
│ ForumScreen — 카테고리 헤더                                    │
│   [자유게시판] [질문답변] [사고팔기] ... [🔍]                     │
└──────────────────────┬───────────────────────────────────────┘
                       │ 🔍 버튼 클릭
                       ▼
┌──────────────────────────────────────────────────────────────┐
│ SearchDialog (Comic 스타일)                                   │
│   ┌─────────────────────────────────────────┐                │
│   │ 🔍 검색                           [X]   │ ← 그라데이션 헤더│
│   ├─────────────────────────────────────────┤                │
│   │ [🔍 검색어 입력...]                      │ ← 자동 포커스   │
│   │                                         │                │
│   │ [✕ 취소]        [🔍 검색]               │                │
│   └─────────────────────────────────────────┘                │
└──────────────────────┬───────────────────────────────────────┘
                       │ 검색어 입력 → 검색 버튼 또는 Enter
                       ▼
┌──────────────────────────────────────────────────────────────┐
│ SearchScreen (Google CSE WebView)                             │
│   [< 돌아가기]                                          [X]   │
│   ┌─────────────────────────────────────────┐                │
│   │ Google CSE 검색 결과                      │                │
│   │                                         │                │
│   │ 📄 필리핀 비자 연장 방법 - 필고              │ ← 클릭 시      │
│   │ 📄 필리핀 체류 7개월 - 필고                 │   PostViewScreen│
│   │ 📄 관광비자 연장비용 - 필고                  │   으로 이동     │
│   └─────────────────────────────────────────┘                │
└──────────────────────────────────────────────────────────────┘
                       │ 필고 URL 클릭
                       ▼
┌──────────────────────────────────────────────────────────────┐
│ PostViewScreen — 게시글 상세 보기                               │
│   (idx로 전체 게시글 정보 로드)                                  │
└──────────────────────────────────────────────────────────────┘
```
