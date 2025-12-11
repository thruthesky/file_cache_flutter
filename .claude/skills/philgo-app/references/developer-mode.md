# 개발자 모드 (Developer Mode)

PhilGo 앱의 개발자 모드 기능에 대한 문서입니다.

## 개요

`isDeveloperModeEnabled` 전역 변수를 통해 개발자 전용 기능을 활성화/비활성화합니다.
이 변수는 **상태관리(Provider/Selector)를 사용하지 않는 단순 전역 변수**입니다.

## 파일 구조

```
lib/
├── globals.dart                    # 변수 정의
├── screens/version/version.screen.dart  # 변수 업데이트
└── widgets/headers/forum_header.dart    # 변수 사용
```

## 상세 설명

### 1. 변수 정의 (`lib/globals.dart`)

```dart
bool isDeveloperModeEnabled = false;
```

- 기본값: `false` (비활성화)
- 전역 변수로 앱 전체에서 접근 가능

### 2. 변수 업데이트 (`lib/screens/version/version.screen.dart`)

버전 화면의 섹션 헤더를 **5번 이상 탭**하면 개발자 모드가 활성화됩니다.

```dart
Widget _buildSectionHeader(
  BuildContext context, {
  required IconData icon,
  required String title,
}) {
  int count = 0;

  return InkWell(
    onTap: () {
      if (++count > 5) {
        isDeveloperModeEnabled = true;  // 6번째 탭에서 활성화
      }
    },
    child: // ... 위젯 내용
  );
}
```

**활성화 방법:**
1. 설정 > 버전 정보 화면으로 이동
2. 아무 섹션 헤더(앱 정보, 디바이스 기본 정보 등)를 6회 이상 탭
3. 개발자 모드 활성화 (시각적 피드백 없음)

### 3. 변수 사용 (`lib/widgets/headers/forum_header.dart`)

포럼 헤더에서 임시(temp) 카테고리 표시 여부를 결정합니다.

```dart
final allCategories = PhilgoCategory.menuCategories(
  includeTemp: isDeveloperModeEnabled,  // 개발자 모드일 때만 temp 카테고리 표시
);
```

## 중요: 실시간 업데이트 불가

### 상태관리를 사용하지 않음

`isDeveloperModeEnabled`는 **단순 전역 변수**이므로:

- Provider/Selector를 통한 상태관리가 아님
- 변수 값이 변경되어도 **자동으로 UI가 업데이트되지 않음**
- 변수를 사용하는 위젯이 **다시 빌드되어야만** 변경 사항이 반영됨

### 변경 사항 적용 방법

개발자 모드를 활성화한 후, 다음 방법 중 하나로 변경 사항을 적용해야 합니다:

1. **화면 이동**: 다른 화면으로 이동 후 포럼 화면으로 돌아오기
2. **앱 재시작**: 앱을 완전히 종료 후 다시 실행 (권장하지 않음 - 변수가 초기화됨)
3. **Pull to Refresh**: 포럼 화면에서 새로고침 (구현된 경우)

```
[버전 화면에서 6번 탭]
        ↓
isDeveloperModeEnabled = true (변수만 변경)
        ↓
[포럼 화면은 아직 이전 상태 유지]
        ↓
[다른 화면으로 이동 후 포럼 화면 재진입]
        ↓
[포럼 헤더 위젯 다시 빌드]
        ↓
[temp 카테고리 표시됨]
```

## 개발자 모드 기능

현재 개발자 모드에서 활성화되는 기능:

| 기능 | 설명 | 위치 |
|------|------|------|
| Temp 카테고리 | 임시 게시판 카테고리 표시 | 포럼 헤더 |

## 향후 개선 사항

실시간 UI 업데이트가 필요한 경우, 다음과 같이 상태관리로 전환할 수 있습니다:

```dart
// AppState에 추가 (예시)
class AppState extends ChangeNotifier {
  bool _isDeveloperMode = false;

  bool get isDeveloperMode => _isDeveloperMode;

  void enableDeveloperMode() {
    _isDeveloperMode = true;
    notifyListeners();  // UI 자동 업데이트
  }
}

// 사용 시
Selector<AppState, bool>(
  selector: (_, state) => state.isDeveloperMode,
  builder: (context, isDeveloperMode, _) {
    final allCategories = PhilgoCategory.menuCategories(
      includeTemp: isDeveloperMode,
    );
    // ...
  },
)
```

## 관련 파일

- [lib/globals.dart](../../../lib/globals.dart) - 전역 변수 정의
- [lib/screens/version/version.screen.dart](../../../lib/screens/version/version.screen.dart) - 변수 업데이트
- [lib/widgets/headers/forum_header.dart](../../../lib/widgets/headers/forum_header.dart) - 변수 사용
- [상태관리 문서](./state-management.md) - Provider/Selector 패턴 참고
