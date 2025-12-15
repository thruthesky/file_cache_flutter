import 'package:philgo/services/philgo/philgo.setting.model.dart';
import 'package:philgo_api/philgo_api.dart';

class PhilgoService {
  static PhilgoService? _instance;
  static PhilgoService get instance => _instance ??= PhilgoService._();

  PhilgoService._();

  Future<PhilgoSetting> loadSetting() async {
    final json = await func('setting');
    return PhilgoSetting(json);
  }
}
