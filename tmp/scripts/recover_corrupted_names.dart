import 'dart:convert';
import 'dart:io';

void main() async {
  final filePath =
      '/Users/thruthesky/apps/flutter/philgo_app/lib/philgo_files/travel/travel_spots.json';
  final file = File(filePath);
  if (!await file.exists()) {
    //    print('File not found');
    return;
  }

  final content = await file.readAsString();
  final List<dynamic> data = json.decode(content);

  final forbiddenNames = {
    '개요',
    '특징',
    '방문 정보',
    '추천 포인트 & 여행 팁',
    '추천 포인트',
    '여행 팁',
    '역사',
  };

  final Map<String, String> translationMap = {
    'Mount Abimay': '아비마이 산',
    'Mount Abas': '아바스 산',
    'Mount Abao': '아바오 산',
    'Mount Abunug': '아부눅 산',
    // ... I'll add a more general logic to handle "Mount X" -> "X 산"
  };

  int modifiedCount = 0;

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final String name = (item['name'] ?? '').toString();
    final String englishName = (item['english name'] ?? '').toString();

    if (forbiddenNames.contains(name)) {
      String newName = englishName;

      // General rule: "Mount [Name]" -> "[Name] 산"
      if (newName.startsWith('Mount ')) {
        newName = newName.replaceFirst('Mount ', '') + ' 산';
      } else if (newName.startsWith('Mount')) {
        newName = newName.replaceFirst('Mount', '') + ' 산';
      }

      // Also check my previous translationMap logic or just use a simple transliteration for these few
      // But actually, I'll just use the items' title if it's better.
      // Or I'll just use the texts' first line again but more carefully.

      final texts = item['texts'];
      if (texts != null && texts is List && texts.isNotEmpty) {
        final lines = texts[0].toString().split('\n');
        for (var line in lines) {
          if (line.startsWith('# ') &&
              !forbiddenNames.any((f) => line.contains(f))) {
            final hContent = line.replaceFirst('# ', '').split('(')[0].trim();
            if (RegExp(r'[가-힣]').hasMatch(hContent)) {
              newName = hContent;
              break;
            }
          }
        }
      }

      if (name != newName) {
        //        print('Recovering: "$name" ($englishName) -> "$newName"');
        item['name'] = newName;
        modifiedCount++;
      }
    }
  }

  if (modifiedCount > 0) {
    const encoder = JsonEncoder.withIndent('    ');
    await file.writeAsString(encoder.convert(data));
    //    print('Recovered $modifiedCount items.');
  } else {
    //    print('No items recovered.');
  }
}
