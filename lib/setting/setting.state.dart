import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:philgo/setting/setting.model.dart';

/// v7 설정 상태 관리
///
/// settings.get API 응답 데이터를 Provider로 관리한다.
/// SettingService에서 설정을 로드하고, 10분마다 자동으로 갱신한다.
class SettingsState extends ChangeNotifier {
  Settings? _settings;
  Settings? get settings => _settings;

  /// 설정 데이터 업데이트
  void setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }

  /// Provider에서 SettingsState 읽기
  static SettingsState of(BuildContext context) =>
      context.read<SettingsState>();
}
