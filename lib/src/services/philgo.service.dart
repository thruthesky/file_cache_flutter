import 'package:philgo_api/philgo_api.dart';

class PhilgoService {
  static PhilgoService? _instance;
  static PhilgoService get instance => _instance ??= PhilgoService._();

  PhilgoSetting? setting;

  PhilgoService._();

  /// PhilGo 설정 정보 로드
  ///
  /// API에서 설정 정보를 가져와 PhilgoSetting 모델로 파싱하여 저장
  Future<PhilgoSetting> loadSetting() async {
    final json = await apiCall('setting', apiServerUrl: PhilgoConfig.phpApiUrl);
    setting = PhilgoSetting.fromJson(json);

    print('광고 게시물 카테고리: ${setting?.point.advertisingPostCategories}');
    print('광고 가능 일수: ${setting?.point.advertisementDays}');
    print('시간당 광고 비용: ${setting?.point.advCostPerHour}');
    print('은행 정보: ${setting?.bankInfo.banks.keys}');

    return setting!;
  }
}
