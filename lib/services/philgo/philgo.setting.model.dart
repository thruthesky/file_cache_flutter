class PhilgoSettingPoint {
  late final List<String> advertising_post_categories;

  PhilgoSettingPoint(Map<dynamic, dynamic> point) {
    advertising_post_categories = List<String>.from(
      point['advertising_post_categories'],
    );
  }
}

class PhilgoSetting {
  late final PhilgoSettingPoint point;
  PhilgoSetting(Map<dynamic, dynamic> json) {
    point = PhilgoSettingPoint(json['point']);
  }
}
