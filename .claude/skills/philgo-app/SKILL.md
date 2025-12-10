---
name: philgo-app
description: 플러터 기반 필고(Philgo) 앱 개발 스킬. 필고 앱을 개발할 때 반드시 참조해야 하는 모든 정보를 포함합니다. Firebase 초기화, go_router 라우팅, Provider 상태 관리, Material 3 Flat Design 테마, philgo_api 패키지 사용법, 다국어 지원 등 필고 앱 개발에 필요한 전반적인 가이드를 제공합니다. 필고 앱 개발, 필고 API 연동, Flutter philgo, 필고 위젯 개발, 게시판 기능, 채팅 기능, 업체 등록 기능 등을 작업할 때 이 스킬을 사용하세요. (project)
---

# 필고 앱 개발 가이드

## 프로젝트 개요

- **패키지명**: `philgo`
- **버전**: 2.0.3+36
- **Flutter**: 3.35.2+
- **Dart**: ^3.8.1

## 프로젝트 구조

```
lib/
├── main.dart           # 앱 진입점, Firebase 초기화
├── router.dart         # go_router 라우팅 설정
├── globals.dart        # 전역 변수
├── firebase_options.dart
├── state/              # 상태 관리
│   ├── app.state.dart
│   └── navigation.state.dart
├── themes/             # 테마 설정
│   ├── app.theme.dart
│   └── app.spacing.dart
├── screens/            # 화면 위젯
├── widgets/            # 재사용 위젯
├── functions/          # 유틸리티 함수
├── models/             # 데이터 모델
├── l10n/               # 다국어 리소스
└── extensions/         # 확장 메서드
```

## 핵심 규칙

### 1. Theme 수정 금지
`main.dart`의 Theme은 명시적 요청 없이 절대 수정 금지.
개별 위젯에서 `Theme.of(context)` 사용.

### 2. 하드코딩 금지
```dart
// ❌ 금지
color: Colors.blue
fontSize: 16

// ✅ 올바름
color: Theme.of(context).colorScheme.primary
style: Theme.of(context).textTheme.bodyLarge
```

### 3. Provider + Selector 필수
```dart
// ❌ 금지: Riverpod, Consumer, context.watch()

// ✅ 필수: Selector
Selector<AppState, Locale?>(
  selector: (context, appState) => appState.locale,
  builder: (context, locale, child) => Text(locale.toString()),
)
```

### 4. Flat Design 원칙
- 모든 elevation = 0
- 그림자 사용 금지
- 색상 대비로만 UI 구분

### 5. i18n 필수
```dart
// ❌ 금지
Text("안녕하세요")

// ✅ 필수
Text(Lo.of(context)!.hello)
```

## 상세 문서

각 항목의 상세 정보는 `references/` 폴더 참조:

| 주제 | 문서 | 설명 |
|------|------|------|
| Firebase | [firebase.md](references/firebase.md) | 초기화, 인증, 푸시 알림 |
| 라우팅 | [routing.md](references/routing.md) | go_router, 딥링크 |
| 상태 관리 | [state-management.md](references/state-management.md) | Provider, Selector |
| 테마 | [theme.md](references/theme.md) | Material 3, AppSpacing |
| 필고 API | [philgo-api.md](references/philgo-api.md) | API 패키지 사용법 |
| 패키지 | [packages.md](references/packages.md) | 의존성 목록 |
| OTA 업데이트 | [shorebird-code-push.md](references/shorebird-code-push.md) | Shorebird 코드 푸시, 자동 업데이트 |
| 캐싱 | [post-list-cache.md](references/post-list-cache.md) | 게시글 첫 페이지 파일 캐싱 |

## 주요 파일 위치

| 용도 | 경로 |
|------|------|
| 메인 설정 | `lib/main.dart` |
| 라우터 | `lib/router.dart` |
| 앱 상태 | `lib/state/app.state.dart` |
| 네비게이션 상태 | `lib/state/navigation.state.dart` |
| 테마 | `lib/themes/app.theme.dart` |
| 간격 토큰 | `lib/themes/app.spacing.dart` |
| 다국어 | `lib/l10n/*.arb` |

## 스크립트

### API 버전 확인
```bash
./scripts/get-api-version.sh
```

## 빠른 시작

### 새 화면 추가
1. `lib/screens/`에 화면 파일 생성
2. `lib/router.dart`에 라우트 추가
3. static `push` 메서드 구현

### 상태 사용
```dart
// 읽기 (리빌드 없음)
final user = AppState.of(context, listen: false).user;

// 구독 (리빌드 필요)
Selector<AppState, User?>(
  selector: (_, state) => state.user,
  builder: (_, user, __) => Text(user?.nickname ?? ''),
)
```

### 스타일 적용
```dart
final theme = Theme.of(context);
final scheme = theme.colorScheme;
final sp = theme.extension<AppSpacing>()!;

Text('제목', style: theme.textTheme.titleLarge);
Container(
  color: scheme.surface,
  padding: EdgeInsets.all(sp.s16),
)
```

## 주의사항

1. **flutter analyze** 매 작업 후 실행
2. **main.dart Theme** 명시적 요청 없이 수정 금지
3. **Riverpod/Consumer** 사용 금지, Selector 사용
4. **하드코딩 색상/크기** 금지, Theme 사용
5. **코멘트** 한국어로 상세히 작성
