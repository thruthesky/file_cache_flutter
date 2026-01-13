# 검색 기능 추가 구현 계획

## 1. 개요

### 1.1 목적
홈 화면(메인)과 게시판에서 맨 위의 카테고리 목록의 맨 처음 항목에 검색 버튼을 추가합니다.

### 1.2 사용자 플로우
```
[돋보기 아이콘] 검색 클릭
    ↓
검색 화면으로 바로 이동 (WebView)
    ↓
Google CSE 검색창에서 검색어 입력
    ↓
검색 결과 표시 (CSE 자체 렌더링)
```

**핵심**: 별도의 검색 다이얼로그 없이, CSE 페이지에 내장된 검색창을 사용합니다.

### 1.3 Google CSE 정보
| 항목 | 값 |
|------|-----|
| **CSE ID** | `d37786943cf92484d` |
| **검색 페이지** | `/page/search/cse.php` |
| **검색 대상** | philgo.com 도메인 전체 |

### 1.4 검색 URL
```
https://philgo.com/page/search/cse.php
```

**참고**: 검색어 파라미터 없이 기본 CSE 페이지를 로드합니다. CSE가 자체적으로 검색창, 자동완성, 검색 결과, "결과 없음" 메시지를 모두 렌더링합니다.

---

## 2. 파일 변경 사항

### 2.1 생성할 파일 (1개)

| 파일 | 용도 |
|------|------|
| `/lib/screens/search/search.screen.dart` | WebView 기반 Google CSE 검색 화면 |

~~`/lib/widgets/dialogs/search_dialog.dart`~~ → **불필요** (CSE 내장 검색창 사용)

### 2.2 수정할 파일 (3개)

| 파일 | 수정 내용 |
|------|----------|
| `/lib/widgets/headers/forum_header.dart` | 카테고리 목록 맨 앞에 검색 항목 추가 |
| `/lib/widgets/home/menu/home_menu_categories.dart` | 카테고리 목록 맨 앞에 검색 항목 추가 |
| `/lib/router.dart` | SearchScreen 라우트 등록 |

---

## 3. 상세 구현 계획

### 3.1 검색 화면 (`search.screen.dart`)

**파일 경로**: `/lib/screens/search/search.screen.dart`

**참조 패턴**: `/lib/screens/webview/webview.screen.dart`

#### 클래스 구조
```dart
class SearchScreen extends StatefulWidget {
  /// 라우트 이름
  static const String routeName = '/search';

  /// 화면 이동 메서드 (검색어 파라미터 없음)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  const SearchScreen({super.key});
}
```

#### UI 레이아웃
```
┌──────────────────────────────────────────┐
│ < 돌아가기                          (X)  │  ← AppBar
├──────────────────────────────────────────┤
│                                          │
│  ┌────────────────────────────────────┐  │
│  │ 🔍 검색어를 입력하세요...          │  │  ← CSE 내장 검색창
│  └────────────────────────────────────┘  │
│                                          │
│           [WebViewWidget]                │  ← Google CSE
│                                          │
│    (CSE가 검색창 + 결과 모두 렌더링)      │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

#### AppBar 구성 (WebViewScreen 패턴)
- **leading**: "< 돌아가기" 텍스트 버튼 (터치 영역 확대)
- **actions**: 원형 닫기 버튼 (`surfaceDim` 배경)
- **elevation**: 0

#### WebView URL
```dart
static const String _searchUrl = 'https://philgo.com/page/search/cse.php';
```

#### WebViewController 설정
```dart
_controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)  // JavaScript 필수 (CSE 동작)
  ..loadRequest(Uri.parse(_searchUrl));
```

#### 필요한 import
```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
```

---

### 3.2 ForumHeader 수정

**파일**: `/lib/widgets/headers/forum_header.dart`

**수정 위치**: line 104 부근, `children: [` 배열 맨 앞

#### 추가할 위젯 구조
```dart
children: [
  /// 검색 항목 (Search item)
  /// 카테고리 목록 맨 앞에 배치
  /// 클릭 시 WebView 검색 화면으로 바로 이동
  InkWell(
    onTap: () => SearchScreen.push(context),
    borderRadius: BorderRadius.circular(buttonRadius),
    child: Container(
      decoration: BoxDecoration(
        color: _isExpanded
            ? scheme.surfaceContainerLowest
            : Colors.transparent,
        borderRadius: BorderRadius.circular(buttonRadius),
      ),
      padding: buttonPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.lightMagnifyingGlass,
            size: 12,
            color: scheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            lo.searchHint,  // "검색"
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ),

  /// 기존 카테고리 목록...
  ...categoriesToShow.map((menuItem) { ... }),
```

#### 추가할 import
```dart
import 'package:philgo/screens/search/search.screen.dart';
```

---

### 3.3 HomeMenuCategories 수정

**파일**: `/lib/widgets/home/menu/home_menu_categories.dart`

**수정 위치**: line 51 부근, `children:` 배열 맨 앞

#### 추가할 위젯 구조
```dart
children: [
  /// 검색 항목 (Search item)
  /// 카테고리 목록 맨 앞에 배치
  /// 클릭 시 WebView 검색 화면으로 바로 이동
  InkWell(
    onTap: () => SearchScreen.push(context),
    borderRadius: BorderRadius.circular(4),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.lightMagnifyingGlass,
            size: 12,
            color: scheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            lo.searchHint,  // "검색"
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ),

  /// 기존 카테고리 목록...
  ...PhilgoCategory.homeMenuCategories().map((menuItem) { ... }).toList(),
],
```

#### 추가할 import
```dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/search/search.screen.dart';
```

---

### 3.4 라우터 등록

**파일**: `/lib/router.dart`

#### 추가할 import
```dart
import 'package:philgo/screens/search/search.screen.dart';
```

#### 추가할 GoRoute (routes 배열 내)
```dart
/// 검색 화면 (Search Screen)
/// Google CSE를 WebView로 표시 (검색어 파라미터 없음)
GoRoute(
  path: SearchScreen.routeName,
  name: SearchScreen.routeName,
  builder: (context, state) => const SearchScreen(),
),
```

---

## 4. 번역 키

### 4.1 사용할 번역 키
| 키 | 한국어 | 영어 | 용도 |
|----|--------|------|------|
| `searchHint` | 검색 | Search | 검색 버튼 텍스트 |

### 4.2 불필요한 번역 키
CSE가 WebView 내에서 모든 UI를 자체 렌더링하므로 추가 번역 키 불필요:
- ~~`searchResults`~~
- ~~`searchNoResults`~~
- ~~`searchPlaceholder`~~ (다이얼로그 입력창용)

---

## 5. 구현 순서

1. [ ] `/lib/screens/search/search.screen.dart` 생성
2. [ ] `/lib/router.dart`에 SearchScreen 라우트 등록
3. [ ] `/lib/widgets/headers/forum_header.dart` 수정
4. [ ] `/lib/widgets/home/menu/home_menu_categories.dart` 수정
5. [ ] `flutter analyze` 실행 및 오류 수정
6. [ ] 앱 실행하여 기능 검증

---

## 6. 디자인 가이드라인

### 6.1 Font Awesome 아이콘 (Light 우선)
| 용도 | 아이콘 |
|------|--------|
| 검색 | `FontAwesomeIcons.lightMagnifyingGlass` |
| 닫기 | `FontAwesomeIcons.lightXmark` |

### 6.2 색상
- 검색 아이콘/텍스트: `scheme.primary`
- 검색 텍스트 스타일: `fontWeight: FontWeight.bold`

---

## 7. 검증 방법

### 7.1 UI 검증
- [ ] 홈 화면 카테고리 목록 맨 앞에 "[🔍] 검색" 표시 확인
- [ ] 게시판 화면 카테고리 목록 맨 앞에 "[🔍] 검색" 표시 확인
- [ ] 검색 아이콘과 텍스트가 primary 색상으로 표시 확인

### 7.2 기능 검증
- [ ] 검색 클릭 → WebView 검색 화면 바로 이동
- [ ] CSE 검색창 정상 표시 및 입력 가능
- [ ] 검색어 입력 후 검색 결과 정상 표시
- [ ] CSE 자동완성 기능 동작 확인

### 7.3 WebView 검증
- [ ] JavaScript 정상 동작 (CSE 필수)
- [ ] 뒤로가기 버튼 정상 작동
- [ ] 닫기 버튼 정상 작동

---

## 8. 참조 파일

| 참조 대상 | 파일 경로 |
|----------|----------|
| WebView 화면 | `/lib/screens/webview/webview.screen.dart` |
| 라우팅 패턴 | `/lib/router.dart` |
| 검색 문서 | `/.claude/skills/philgo-skill/references/search/search.md` |
| 번역 파일 | `/lib/l10n/app_ko.arb`, `/lib/l10n/app_en.arb` |

---

## 9. 방식 선택 이유

### CSE 내장 검색창 사용 (다이얼로그 없음)

**장점**:
1. **코드 간소화**: SearchDialog 파일 불필요 (생성 파일 1개 감소)
2. **검색창 중복 제거**: 다이얼로그 + CSE 검색창 → CSE 검색창만
3. **CSE 기능 활용**: 자동완성, 검색 제안 등 구글 기능 사용 가능
4. **일관된 검색 경험**: 웹과 동일한 검색 UI

**고려사항**:
- 검색 화면 진입 시 빈 검색창이 표시됨 (사용자가 직접 입력)
- 웹뷰 로딩 시간이 있을 수 있음
