import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File(
    '/Users/thruthesky/apps/flutter/philgo_app/lib/philgo_files/travel/travel_spots.json',
  );
  if (!await file.exists()) {
    //    print('File not found');
    return;
  }

  final content = await file.readAsString();
  final List<dynamic> data = json.decode(content);

  final englishRegex = RegExp(r'[a-zA-Z]');
  bool modified = false;

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final String name = item['name'] ?? '';

    if (englishRegex.hasMatch(name)) {
      //      print('English found in name: $name');
      // 여기서 한글로 변경하는 로직이 필요합니다.
      // 사용자 지침에 따라 english name, title, descriptions, texts를 파악해야 합니다.
      // 하지만 자동화된 스크립트에서 AI 없이 정확한 한글명을 찾기는 어려울 수 있습니다.
      // 일단 어떤 항목들이 있는지 출력해봅니다.
    }
  }
}
