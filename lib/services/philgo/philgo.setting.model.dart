import 'dart:convert';

class PhilgoSettingPoint {
  late final List<String> advertising_post_categories;

  PhilgoSettingPoint(Map<dynamic, dynamic> point) {
    advertising_post_categories = List<String>.from(
      point['advertising_post_categories'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {'advertising_post_categories': advertising_post_categories};
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class PhilgoSetting {
  late final PhilgoSettingPoint point;
  PhilgoSetting(Map<dynamic, dynamic> json) {
    point = PhilgoSettingPoint(json['point']);
  }

  Map<dynamic, dynamic> toJson() {
    return {"point": point.toJson()};
  }

  @override
  String toString() {
    return "PhilgoSetting(${toJson()})";
  }
}
