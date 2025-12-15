import 'package:philgo/functions/api.functions.dart';
import 'package:philgo/services/philgo/philgo.setting.model.dart';
import 'package:philgo_api/philgo_api.dart';

class PhilgoService {
  static PhilgoService? _instance;
  static PhilgoService get instance => _instance ??= PhilgoService._();

  PhilgoSetting? setting;

  PhilgoService._();

  Future<PhilgoSetting> loadSetting() async {
    final json = await apiCall('setting', apiServerUrl: PhilgoConfig.phpApiUrl);
    setting = PhilgoSetting(json);

    print(setting);

    return setting!;
  }
}
