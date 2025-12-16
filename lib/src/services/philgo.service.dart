import 'package:philgo_api/philgo_api.dart';

class PhilgoService {
  static PhilgoService? _instance;
  static PhilgoService get instance => _instance ??= PhilgoService._();

  PhilgoService._();

  /// PhilGo 설정 정보 로드
  ///
  /// API에서 설정 정보를 가져와 PhilgoSetting 모델로 파싱하여 저장
  Future<PhilgoSetting> loadSetting() async {
    final json = await apiCall('setting', apiServerUrl: PhilgoConfig.phpApiUrl);
    final setting = PhilgoSetting.fromJson(json);

    return setting;
  }
}
