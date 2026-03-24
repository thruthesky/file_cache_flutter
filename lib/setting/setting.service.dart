import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/setting/build_number_check.dart';
import 'package:philgo/setting/setting.model.dart';
import 'package:philgo/setting/setting.state.dart';

/// v7 설정 서비스
///
/// settings.get API 호출 및 주기적 갱신을 담당한다.
/// 개발 모드: 30초마다, 프로덕션 모드: 10분마다 설정을 다시 로드한다.
/// AppService.initialize()에서 호출된다.
class SettingService {
  static SettingService instance = SettingService._();
  SettingService._();

  late BuildContext _context;
  Timer? _countdownTimer;

  /// 설정 리로드까지 남은 초 (카운트다운)
  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(0);

  /// 리로드 주기 (초 단위)
  int get refreshIntervalSeconds => kDebugMode ? 30 : 600;

  /// 설정 서비스 초기화
  ///
  /// 즉시 설정을 로드하고, 카운트다운 타이머를 시작한다.
  void initialize(BuildContext context) {
    _context = context;
    _loadSettings();
    _startCountdown();
  }

  /// 카운트다운 타이머 시작
  void _startCountdown() {
    _countdownTimer?.cancel();
    remainingSeconds.value = refreshIntervalSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = remainingSeconds.value - 1;
      if (next <= 0) {
        remainingSeconds.value = refreshIntervalSeconds;
        _loadSettings();
      } else {
        remainingSeconds.value = next;
      }
    });
  }

  /// v7 settings.get API를 호출하여 SettingsState에 저장
  Future<void> _loadSettings() async {
    try {
      final json = await ApiService.instance.v7api('settings.get');
      final settings = Settings.fromJson(json);
      if (_context.mounted) {
        SettingsState.of(_context).setSettings(settings);
        // 빌드 번호 비교 → 강제 업데이트 다이얼로그 표시
        checkBuildNumber(settings);
      }
    } catch (e) {
      debugPrint('v7 설정 로드 실패: $e');
    }
  }
}
