import 'package:flutter/cupertino.dart';
import 'package:philgo/app.config.dart';
import 'package:provider/provider.dart';

import 'package:philgo/setting/setting.model.dart';

/// v7 설정 상태 관리
///
/// settings.get API 응답 데이터를 Provider로 관리한다.
/// SettingService에서 설정을 로드하고, 10분마다 자동으로 갱신한다.
class SettingsState extends ChangeNotifier {
  Settings? _settings;
  Settings? get settings => _settings;

  String get adminChatUid => _settings?.chatAdmin ?? chatAdminUid;

  /// 설정 데이터 업데이트
  void setSettings(Settings settings) {
    _settings = settings;
    notifyListeners();
  }

  /// 스타벅스 쿠폰 수량 업데이트 (스핀 결과 반영)
  void updateAvailableStarbucksCoupons(int count) {
    if (_settings == null) return;
    _settings = _settings!.copyWith(availableStarbucksCoupons: count);
    notifyListeners();
  }

  /// Provider에서 SettingsState 읽기
  static SettingsState of(BuildContext context) =>
      context.read<SettingsState>();
}
