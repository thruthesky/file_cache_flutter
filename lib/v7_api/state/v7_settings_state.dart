import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:philgo/v7_api/v7_api.dart';
import 'package:philgo/v7_api/models/v7_settings.dart';

/// v7 Settings 상태 관리
///
/// 앱 시작 시 v7 api.php → settings.get 호출하여 설정을 로딩한다.
/// Provider로 등록하여 앱 전체에서 접근 가능.
///
/// 기존 PhilgoState.setting (레거시 func.php → bank_info/point/admin_uids)과
/// 별도로 관리되며, v7 설정(앱 버전, 이벤트 토글)을 담당한다.
class V7SettingsState extends ChangeNotifier {
  V7Settings? settings;
  String? error;

  V7SettingsState() {
    _loadSettings();
  }

  /// v7 settings.get API 호출하여 설정 로딩
  Future<void> _loadSettings() async {
    try {
      final json = await v7api('settings.get');
      settings = V7Settings.fromJson(json);
      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      debugPrint('v7 설정 로딩 실패: $e');
      notifyListeners();
    }
  }

  /// 스타벅스 쿠폰 잔여 수량을 업데이트한다.
  ///
  /// event.spin API 응답의 available_coupons 값으로 실시간 갱신하거나,
  /// 서버 에러(쿠폰 소진) 시 0으로 설정하여 UI를 즉시 반영한다.
  void updateAvailableStarbucksCoupons(int count) {
    if (settings == null) return;
    settings = V7Settings(
      appVersionAndroid: settings!.appVersionAndroid,
      appVersionAndroidBuild: settings!.appVersionAndroidBuild,
      appVersionIos: settings!.appVersionIos,
      appVersionIosBuild: settings!.appVersionIosBuild,
      companyQrEventEnabled: settings!.companyQrEventEnabled,
      eventEntryEnabled: settings!.eventEntryEnabled,
      availableStarbucksCoupons: count,
    );
    notifyListeners();
  }

  /// BuildContext에서 V7SettingsState 접근 헬퍼
  static V7SettingsState of(BuildContext context, {bool listen = false}) {
    return Provider.of<V7SettingsState>(context, listen: listen);
  }
}
