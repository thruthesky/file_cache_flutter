---
title: Shorebird 를 통한 코드 푸시 (Code Push)
description: Shorebird 는 Flutter 앱에 대한 코드 푸시 업데이트를 지원하는 도구입니다. 이를 통해 앱 스토어에 다시 제출하지 않고도 버그 수정 및 기능 개선을 사용자에게 빠르게 배포할 수 있습니다. 이 문서에서는 Shorebird 를 사용하여 Philgo Flutter 앱에 코드 푸시 업데이트를 설정하고 배포하는 방법을 설명합니다.
---

# Shorebird Code Push

## 목차

1. [개요](#개요)
2. [패키지 설치](#패키지-설치)
3. [주요 클래스 및 메서드](#주요-클래스-및-메서드)
4. [자동 업데이트 구현](#자동-업데이트-구현)
5. [트랙(Track) 기능](#트랙track-기능)
6. [Philgo 앱 적용 예시](#philgo-앱-적용-예시)

---

## 개요

Shorebird Code Push는 Flutter 앱에 OTA(Over-The-Air) 업데이트를 제공하는 패키지입니다.

### 주요 특징

- 앱 스토어 심사 없이 즉시 업데이트 배포
- Dart 코드 변경 사항만 패치 가능 (네이티브 코드 변경 불가)
- 사용자가 앱을 재시작하면 새 패치 적용
- 다양한 트랙(stable, beta 등)을 통한 단계별 배포 지원

### 공식 문서

- pub.dev: https://pub.dev/packages/shorebird_code_push
- Shorebird 공식 사이트: https://shorebird.dev

---

## 패키지 설치

### 1. 의존성 추가

```bash
flutter pub add shorebird_code_push
```

또는 `pubspec.yaml`에 직접 추가:

```yaml
dependencies:
  shorebird_code_push: ^2.0.0
```

### 2. 패키지 가져오기

```dart
import 'package:shorebird_code_push/shorebird_code_push.dart';
```

---

## 주요 클래스 및 메서드

### ShorebirdCodePush 클래스 (Legacy)

기존 API로, 간단한 메서드를 제공합니다.

```dart
final shorebirdCodePush = ShorebirdCodePush();
```

| 메서드 | 설명 | 반환 타입 |
|--------|------|-----------|
| `isNewPatchAvailableForDownload()` | 새 패치 다운로드 가능 여부 확인 | `Future<bool>` |
| `downloadUpdateIfAvailable()` | 새 패치가 있으면 다운로드 | `Future<void>` |
| `currentPatchNumber()` | 현재 패치 번호 반환 | `Future<int?>` |

### ShorebirdUpdater 클래스 (Recommended)

최신 API로, 더 세밀한 제어가 가능합니다.

```dart
final updater = ShorebirdUpdater();
```

| 메서드 | 설명 | 반환 타입 |
|--------|------|-----------|
| `readCurrentPatch()` | 현재 설치된 패치 정보 반환 (패치가 없으면 null) | `Future<Patch?>` |
| `checkForUpdate()` | 새 업데이트 가능 여부 확인 | `Future<UpdateStatus>` |
| `update()` | 새 패치 다운로드 및 설치 | `Future<void>` |

### UpdateStatus 열거형

`checkForUpdate()` 메서드의 반환값입니다.

| 상태 | 설명 |
|------|------|
| `UpdateStatus.upToDate` | 최신 버전 (업데이트 불필요) |
| `UpdateStatus.outdated` | 새 버전 이용 가능 |
| `UpdateStatus.restartRequired` | 이미 다운로드됨, 재시작 필요 |
| `UpdateStatus.unavailable` | 업데이트 확인 불가 |

### Patch 클래스

패치 정보를 담는 클래스입니다.

```dart
final patch = await updater.readCurrentPatch();
if (patch != null) {
  print('현재 패치 번호: ${patch.number}');
}
```

### UpdateException

업데이트 중 발생하는 예외를 처리합니다.

```dart
try {
  await updater.update();
} on UpdateException catch (e) {
  print('업데이트 실패: ${e.message}');
}
```

---

## 자동 업데이트 구현

### 방법 1: Timer를 사용한 주기적 업데이트 확인 (권장)

일정 간격으로 업데이트를 확인하는 패턴입니다. 앱 사용 중에도 지속적으로 업데이트를 확인할 수 있습니다.

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Shorebird 업데이트 타이머
/// Shorebird update timer
Timer? _shorebirdTimer;

/// Shorebird 코드 푸시 초기화 및 주기적 업데이트 확인
/// Initialize Shorebird code push and check for updates periodically
///
/// 릴리즈 모드에서만 동작합니다.
/// Only works in release mode.
void initShorebirdCodePush() async {
  /// 릴리즈 모드에서만 동작 (디버그 모드에서는 에러 발생)
  /// Only works in release mode (error occurs in debug mode)
  if (!kReleaseMode) return;

  try {
    final shorebirdCodePush = ShorebirdCodePush();

    /// 주기적으로 업데이트 확인 (디버그: 20초, 릴리즈: 180초)
    /// Check for updates periodically (debug: 20s, release: 180s)
    _shorebirdTimer = Timer.periodic(
      const Duration(
        seconds: kDebugMode ? 20 : 180,
      ),
      (_) async {
        /// 신규 패치가 있는지 확인
        /// Check if new patch is available
        final isUpdateAvailable =
            await shorebirdCodePush.isNewPatchAvailableForDownload();

        if (isUpdateAvailable) {
          /// 업데이트가 있으면 타이머 중지 (중복 다운로드 방지)
          /// Stop timer if update available (prevent duplicate downloads)
          _shorebirdTimer?.cancel();

          debugPrint('[Shorebird] 새 패치 발견. 다운로드 시작...');

          /// 신규 패치 다운로드
          /// Download new patch
          await shorebirdCodePush.downloadUpdateIfAvailable();

          debugPrint('[Shorebird] 다운로드 완료. 앱 재시작 시 적용됩니다.');

          /// 사용자에게 알림 (선택적)
          /// Notify user (optional)
          // toast(
          //   context: globalContext,
          //   title: const Text('버전 업데이트'),
          //   message: const Text('앱을 종료하고 다시 실행하시면, 새 버전을 사용 할 수 있습니다.'),
          //   duration: const Duration(seconds: 30),
          // );
        }
      },
    );
  } catch (e) {
    /// 에러 발생 시 로그만 출력하고 무시
    /// Log and ignore errors
    debugPrint('[Shorebird] 초기화 오류: $e');
  }
}

/// 타이머 정리 (앱 종료 시 호출)
/// Clean up timer (call when app closes)
void disposeShorebirdCodePush() {
  _shorebirdTimer?.cancel();
  _shorebirdTimer = null;
}
```

### 방법 2: 앱 시작 시 1회 확인 (기본 패턴)

앱 시작 시 자동으로 업데이트를 확인하고 다운로드하는 패턴입니다.

```dart
import 'package:shorebird_code_push/shorebird_code_push.dart';

class ShorebirdUpdateService {
  /// Shorebird 업데이터 인스턴스
  /// Shorebird updater instance
  final _updater = ShorebirdUpdater();

  /// 업데이트 확인 및 자동 다운로드
  /// Check for updates and download automatically
  Future<void> checkAndUpdate() async {
    try {
      /// 업데이트 상태 확인
      /// Check update status
      final status = await _updater.checkForUpdate();

      switch (status) {
        case UpdateStatus.outdated:
          /// 새 버전이 있으면 자동 다운로드
          /// Auto download if new version available
          await _downloadUpdate();
          break;

        case UpdateStatus.restartRequired:
          /// 이미 다운로드됨 - 재시작 시 적용됨
          /// Already downloaded - will apply on restart
          print('업데이트가 다운로드되었습니다. 앱 재시작 시 적용됩니다.');
          break;

        case UpdateStatus.upToDate:
          /// 최신 버전
          /// Already up to date
          print('최신 버전입니다.');
          break;

        case UpdateStatus.unavailable:
          /// 업데이트 확인 불가 (오프라인 등)
          /// Cannot check for updates (offline, etc.)
          print('업데이트를 확인할 수 없습니다.');
          break;
      }
    } catch (e) {
      print('업데이트 확인 중 오류: $e');
    }
  }

  /// 업데이트 다운로드 실행
  /// Execute update download
  Future<void> _downloadUpdate() async {
    try {
      print('업데이트 다운로드 중...');
      await _updater.update();
      print('업데이트 다운로드 완료. 앱 재시작 시 적용됩니다.');
    } on UpdateException catch (e) {
      print('업데이트 다운로드 실패: ${e.message}');
    }
  }

  /// 현재 패치 번호 확인
  /// Get current patch number
  Future<int?> getCurrentPatchNumber() async {
    final patch = await _updater.readCurrentPatch();
    return patch?.number;
  }
}
```

### 앱 시작 시 자동 업데이트 적용

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Shorebird 업데이트 확인 (백그라운드에서 실행)
  /// Check Shorebird updates (run in background)
  final updateService = ShorebirdUpdateService();
  updateService.checkAndUpdate();

  runApp(const MyApp());
}
```

### 사용자에게 알림 표시 (선택적)

업데이트 다운로드 완료 후 사용자에게 재시작을 권유할 수 있습니다.

```dart
Future<void> checkAndNotifyUser(BuildContext context) async {
  final updater = ShorebirdUpdater();
  final status = await updater.checkForUpdate();

  if (status == UpdateStatus.outdated) {
    /// 업데이트 다운로드
    /// Download update
    await updater.update();

    /// 사용자에게 재시작 권유 다이얼로그 표시
    /// Show restart recommendation dialog to user
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('업데이트 완료'),
          content: const Text('새로운 업데이트가 다운로드되었습니다.\n앱을 재시작하면 적용됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('나중에'),
            ),
            TextButton(
              onPressed: () {
                /// 앱 재시작 로직 (플랫폼에 따라 다름)
                /// App restart logic (varies by platform)
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }
}
```

---

## 트랙(Track) 기능

Shorebird는 여러 트랙을 통해 단계별 배포를 지원합니다.

### 트랙 종류

| 트랙 | 설명 |
|------|------|
| `UpdateTrack.stable` | 안정 버전 (기본값) |
| `UpdateTrack.beta` | 베타 테스터용 |

### 트랙별 업데이트 확인

```dart
/// 베타 트랙에서 업데이트 확인
/// Check for updates from beta track
final status = await updater.checkForUpdate(track: UpdateTrack.beta);

/// 베타 트랙에서 업데이트 다운로드
/// Download update from beta track
await updater.update(track: UpdateTrack.beta);
```

### 사용 예시: 베타 테스터 지원

```dart
class ShorebirdUpdateService {
  final _updater = ShorebirdUpdater();

  /// 사용자가 베타 테스터인지 여부
  /// Whether the user is a beta tester
  final bool isBetaTester;

  ShorebirdUpdateService({this.isBetaTester = false});

  Future<void> checkAndUpdate() async {
    /// 베타 테스터는 beta 트랙, 일반 사용자는 stable 트랙 사용
    /// Beta testers use beta track, regular users use stable track
    final track = isBetaTester ? UpdateTrack.beta : UpdateTrack.stable;

    final status = await _updater.checkForUpdate(track: track);

    if (status == UpdateStatus.outdated) {
      await _updater.update(track: track);
    }
  }
}
```

---

## Philgo 앱 적용 예시

### 1. 서비스 파일 생성

`lib/services/shorebird_update_service.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Shorebird 업데이트 서비스 (Shorebird Update Service)
///
/// 앱 시작 시 자동으로 업데이트를 확인하고 다운로드합니다.
/// Automatically checks for updates and downloads them on app start.
class ShorebirdUpdateService {
  /// 싱글톤 인스턴스
  /// Singleton instance
  static final ShorebirdUpdateService _instance = ShorebirdUpdateService._();
  static ShorebirdUpdateService get instance => _instance;

  ShorebirdUpdateService._();

  /// Shorebird 업데이터
  /// Shorebird updater
  final _updater = ShorebirdUpdater();

  /// 초기화 및 업데이트 확인
  /// Initialize and check for updates
  Future<void> initialize() async {
    /// 릴리즈 모드에서만 업데이트 확인
    /// Only check for updates in release mode
    if (kReleaseMode) {
      await _checkAndUpdate();
    }
  }

  /// 업데이트 확인 및 다운로드
  /// Check and download updates
  Future<void> _checkAndUpdate() async {
    try {
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        debugPrint('[Shorebird] 새 업데이트 발견. 다운로드 중...');
        await _updater.update();
        debugPrint('[Shorebird] 업데이트 다운로드 완료. 재시작 시 적용됩니다.');
      } else if (status == UpdateStatus.restartRequired) {
        debugPrint('[Shorebird] 업데이트가 이미 다운로드됨. 재시작 필요.');
      } else {
        debugPrint('[Shorebird] 최신 버전입니다.');
      }
    } catch (e) {
      debugPrint('[Shorebird] 업데이트 확인 실패: $e');
    }
  }

  /// 현재 패치 번호 가져오기
  /// Get current patch number
  Future<int?> getCurrentPatchNumber() async {
    try {
      final patch = await _updater.readCurrentPatch();
      return patch?.number;
    } catch (e) {
      return null;
    }
  }
}
```

### 2. main.dart에서 초기화

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... 기존 초기화 코드 ...

  /// Shorebird 업데이트 확인 (백그라운드)
  /// Check Shorebird updates (background)
  ShorebirdUpdateService.instance.initialize();

  runApp(const PhilgoApp());
}
```

### 3. 설정 화면에서 버전 정보 표시 (선택적)

```dart
FutureBuilder<int?>(
  future: ShorebirdUpdateService.instance.getCurrentPatchNumber(),
  builder: (context, snapshot) {
    final patchNumber = snapshot.data;
    return ListTile(
      title: const Text('앱 버전'),
      subtitle: Text(
        patchNumber != null
            ? '1.0.0 (패치 $patchNumber)'
            : '1.0.0',
      ),
    );
  },
)
```

---

## 주의사항

### 1. Dart 코드만 패치 가능

네이티브 코드(iOS/Android)나 에셋 변경은 앱 스토어 업데이트 필요

### 2. 릴리즈 모드에서만 동작

디버그 모드에서 Shorebird를 초기화하면 다음과 같은 에러가 발생합니다:

```
[ShorebirdCodePush]: Error initializing updater: Invalid argument(s):
Failed to lookup symbol 'shorebird_current_boot_patch_number':
dlsym(RTLD_DEFAULT, shorebird_current_boot_patch_number): symbol not found

[ShorebirdCodePush]: Shorebird Engine not available, using no-op implementation.
```

**해결 방법**: `kReleaseMode` 체크를 통해 릴리즈 모드에서만 초기화합니다.

```dart
if (!kReleaseMode) return; // 릴리즈 모드에서만 동작
```

### 3. 재시작 필요

다운로드된 패치는 앱 재시작 후 적용됨

### 4. 네트워크 필요

업데이트 확인 및 다운로드에 인터넷 연결 필요

### 5. Timer 사용 시 주의

- 타이머 간격은 60초 ~ 180초가 적당합니다
- 업데이트 발견 후에는 타이머를 중지하여 중복 다운로드를 방지하세요
- 앱 종료 시 타이머를 정리(dispose)하세요

---

## 참고 자료

- [Shorebird 공식 문서](https://docs.shorebird.dev/)
- [shorebird_code_push pub.dev](https://pub.dev/packages/shorebird_code_push)
- [Shorebird CLI 설치](https://docs.shorebird.dev/guides/code-push/initialize/)
