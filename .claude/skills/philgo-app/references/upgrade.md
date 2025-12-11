# 버전 업데이트 알림 시스템

## 개요

오래된 버전의 앱을 사용하는 사용자에게 업데이트 알림을 표시하여 새 버전 설치를 유도하는 시스템입니다.

## 동작 원리

```
앱 실행 → 20초 대기 → API 호출 → 빌드 번호 비교 → 알림 표시 (필요 시)
```

### 알림 표시 조건

**현재 설치된 앱의 빌드 번호 < API에서 가져온 최소 빌드 번호**

예시:
- 현재 설치된 앱: 빌드 번호 `35`
- API 응답 빌드 번호: `36`
- 결과: `35 < 36` → **알림 표시됨**

## Version API

### 호출
```
GET https://philgo.com/func.php?func=version
```

또는 Dart 코드에서:
```dart
final versionInfo = await func('version');
```

### 응답 형식
```json
{
  "version": "2025-12-11-14-41-07",
  "app": {
    "android": {"version": "2.0.3", "build_number": 36},
    "ios": {"version": "2.0.3", "build_number": 36}
  }
}
```

### 필드 설명
| 필드 | 설명 |
|------|------|
| `version` | 홈페이지 서버 버전 (빌드 날짜/시간) |
| `app.android.version` | Android 앱 버전 문자열 |
| `app.android.build_number` | Android 최소 요구 빌드 번호 |
| `app.ios.version` | iOS 앱 버전 문자열 |
| `app.ios.build_number` | iOS 최소 요구 빌드 번호 |

## 관련 파일

| 파일 | 설명 |
|------|------|
| `lib/functions/init/build_number_check.dart` | 빌드 번호 체크 및 다이얼로그 표시 로직 |
| `lib/config/app.config.dart` | PlayStore/AppStore URL 설정 |

## 호출 위치

`initMinimalBuildNumberCheck()` 함수는 앱 초기화 시점에 호출됩니다.

```dart
// main.dart 또는 초기화 함수에서 호출
initMinimalBuildNumberCheck();
```

## 전체 코드

### build_number_check.dart

```dart
/// 앱 실행 시, 약 20초 후, 빌드 번호를 점검하는 초기화 함수입니다.
/// API에서 최소 요구 빌드 번호를 가져와서 현재 앱의 빌드 번호와 비교합니다.
/// 빌드 번호가 최소 요구 빌드 번호보다 낮으면 업그레이드 안내 다이얼로그를 표시합니다.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:philgo/config/app.config.dart';
import 'package:philgo/router.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo/widgets/theme/comic_button.dart';
import 'package:philgo_api/philgo_api.dart';

/// 앱 실행 후 약 20초 후에 빌드 번호를 점검합니다.
/// API func('version')을 호출하여 서버에서 최소 요구 빌드 번호를 가져옵니다.
/// 현재 앱의 빌드 번호가 서버의 최소 요구 빌드 번호보다 낮으면
/// 사용자에게 업그레이드를 안내하는 다이얼로그를 표시합니다.
void initMinimalBuildNumberCheck() {
  // 20초 후에 빌드 번호 체크 실행
  Timer(const Duration(seconds: 20), () async {
    try {
      // 1. 현재 앱의 빌드 번호 조회
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      // 2. API에서 버전 정보 가져오기
      // API 응답 형식:
      // {"version":"2025-12-11-14-41-07","app":{"android":{"version":"2.0.3","build_number":36},"ios":{"version":"2.0.3","build_number":36}}}
      final versionInfo = await func('version');

      // 3. 플랫폼별 최소 요구 빌드 번호 추출
      int minBuildNumber = 0;
      if (Platform.isAndroid) {
        // Android 플랫폼: app.android.build_number 값 사용
        minBuildNumber = versionInfo['app']?['android']?['build_number'] ?? 0;
      } else if (Platform.isIOS) {
        // iOS 플랫폼: app.ios.build_number 값 사용
        minBuildNumber = versionInfo['app']?['ios']?['build_number'] ?? 0;
      }

      debugPrint(
        '[BuildNumberCheck] 현재 빌드 번호: $currentBuildNumber, '
        'API 최소 요구 빌드 번호: $minBuildNumber',
      );

      // 4. 현재 빌드 번호가 최소 요구 빌드 번호보다 낮으면 업그레이드 안내 다이얼로그 표시
      if (currentBuildNumber < minBuildNumber) {
        _showUpgradeDialog();
      }
    } catch (e) {
      // API 호출 실패 또는 파싱 오류 시 로그만 출력하고 종료
      // 네트워크 오류 등으로 인해 사용자 경험을 방해하지 않음
      debugPrint('[BuildNumberCheck] 빌드 번호 체크 중 오류 발생: $e');
    }
  });
}

/// 업그레이드 안내 다이얼로그를 표시합니다.
/// Comic 스타일 다이얼로그를 사용하며, 플랫폼에 따라 적절한 스토어로 이동합니다.
void _showUpgradeDialog() {
  // globalContext가 마운트되어 있는지 확인
  if (!globalNavigatorKey.currentContext!.mounted) {
    debugPrint('[BuildNumberCheck] Context가 마운트되어 있지 않습니다.');
    return;
  }

  final context = globalContext;
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  showDialog(
    context: context,
    barrierDismissible: false, // 바깥 영역 탭으로 닫기 불가
    builder: (dialogContext) {
      return Dialog(
        elevation: 0, // Comic Design: 그림자 없음
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Comic Design: 12px 라운드
          side: BorderSide(
            color: scheme.outline, // Comic Design: outline 색상 테두리
            width: 2.0, // Comic Design: 2.0px 테두리
          ),
        ),
        backgroundColor: scheme.surface,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24), // 8의 배수
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PhilGo 로고 (애니메이션 효과 적용)
              const PhilGoLogoTriangles(
                size: 100,
                animated: true,
                rotating: true,
                pulsing: true,
              ),
              const SizedBox(height: 16),

              // 제목
              Text(
                '업데이트 필요',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 안내 메시지
              Text(
                '새로운 버전이 출시되었습니다.\n더 나은 서비스를 위해 앱을 업데이트해 주세요.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Android 전용 강조 메시지
              if (Platform.isAndroid) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // 경고 색상 배경 (연한 주황색)
                    color: scheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: scheme.error.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: scheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '만약, 업데이트가 잘 안되면, 기존에 설치된 앱을 삭제하고 새로 설치를 해야합니다.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),

              // 버튼 영역
              Row(
                children: [
                  // 닫기 버튼 (연하게 표시)
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        // 연하게 표시하기 위해 opacity 적용
                        foregroundColor: scheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '닫기',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 업데이트 버튼 (강조, 다운로드 아이콘 포함)
                  Expanded(
                    flex: 2,
                    child: ComicPrimaryButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _openStore();
                      },
                      padding: ComicButtonPadding.medium,
                      textSize: ComicButtonTextSize.medium,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download, size: 18),
                          SizedBox(width: 8),
                          Text('업데이트'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 플랫폼에 따라 적절한 앱 스토어를 엽니다.
/// Android: PlayStore, iOS: AppStore
void _openStore() {
  final String storeUrl;

  if (Platform.isAndroid) {
    storeUrl = AppConfig.playstoreUrl;
  } else if (Platform.isIOS) {
    storeUrl = AppConfig.appstoreUrl;
  } else {
    debugPrint('[BuildNumberCheck] 지원하지 않는 플랫폼입니다.');
    return;
  }

  debugPrint('[BuildNumberCheck] 스토어 열기: $storeUrl');
  launchApp(storeUrl, true);
}
```

## 다이얼로그 UI 구성

| 요소 | 설명 |
|------|------|
| **로고** | PhilGoLogoTriangles (애니메이션 효과) |
| **제목** | "업데이트 필요" |
| **내용** | 새 버전 업데이트 안내 메시지 |
| **Android 전용** | 경고 박스: "업데이트가 잘 안되면 기존 앱 삭제 후 새로 설치" |
| **닫기 버튼** | 연하게 표시 (50% opacity) |
| **업데이트 버튼** | ComicPrimaryButton + 다운로드 아이콘 |

## 스토어 URL

- **PlayStore**: `AppConfig.playstoreUrl`
- **AppStore**: `AppConfig.appstoreUrl`

## 빌드 번호 참고사항

- 앱의 빌드 번호는 `pubspec.yaml`에서 `version: x.x.x+build_number` 형식으로 관리
- 예: `version: 2.0.7+37`에서 `37`이 빌드 번호
- `package_info_plus` 패키지의 `buildNumber` 속성으로 조회

## 업데이트 유도 시나리오

1. 개발자가 새 버전 (예: 빌드 번호 `40`) 배포
2. 서버에서 API 응답의 `app.android.build_number` 또는 `app.ios.build_number`를 `40`으로 설정
3. 빌드 번호 `39` 이하 사용자에게 알림 표시
4. 사용자가 "업데이트" 클릭 → 스토어로 이동

## 이전 방식 (사용 안 함)

이전에는 로컬 상수 `minimalBuildNumberToUpgrade`를 사용했으나, 현재는 API에서 동적으로 값을 가져옵니다.

| 변경 전 | 변경 후 |
|---------|---------|
| `minimalBuildNumberToUpgrade` 상수 사용 | API `func('version')` 호출 |
| 앱 업데이트 필요 | 서버에서 값만 변경하면 됨 |
