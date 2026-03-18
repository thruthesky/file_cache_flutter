import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/setting/setting.model.dart';
import 'package:philgo/setting/setting.state.dart';

/// v7 설정 서비스
///
/// settings.get API 호출 및 10분 주기 갱신을 담당한다.
/// AppService.initialize()에서 호출된다.
class SettingService {
  static SettingService instance = SettingService._();
  SettingService._();

  late BuildContext _context;

  /// 설정 서비스 초기화
  ///
  /// 즉시 설정을 로드하고, 10분마다 자동 갱신 타이머를 시작한다.
  void initialize(BuildContext context) {
    _context = context;
    _loadSettings();
    Timer.periodic(
      const Duration(minutes: 10),
      (_) => _loadSettings(),
    );
  }

  /// v7 settings.get API를 호출하여 SettingsState에 저장
  Future<void> _loadSettings() async {
    try {
      final json = await ApiService.instance.v7api('settings.get');
      final settings = Settings.fromJson(json);
      if (_context.mounted) {
        SettingsState.of(_context).setSettings(settings);
      }
    } catch (e) {
      debugPrint('v7 설정 로드 실패: $e');
    }
  }
}
