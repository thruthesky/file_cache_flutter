import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'translations.dart';

/// Dart Map 기반 커스텀 AssetLoader
///
/// JSON/CSV/YAML 파일 대신 [Translations] 클래스의 Map 데이터를 사용합니다.
/// easy_localization의 [AssetLoader]를 구현하여 코드 내에서 직접 번역을 관리합니다.
class CodeAssetLoader extends AssetLoader {
  const CodeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    switch (locale.languageCode) {
      case 'ko':
        return Translations.ko;
      case 'en':
        return Translations.en;
      default:
        return Translations.en;
    }
  }
}
