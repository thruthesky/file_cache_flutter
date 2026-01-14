import 'dart:convert';
import 'dart:io';

void main() async {
  final filePath =
      '/Users/thruthesky/apps/flutter/philgo_app/lib/philgo_files/travel/travel_spots.json';
  final file = File(filePath);
  if (!await file.exists()) {
    print('File not found');
    return;
  }

  final content = await file.readAsString();
  final List<dynamic> data = json.decode(content);

  final englishRegex = RegExp(r'[a-zA-Z]');

  final Map<String, String> translationMap = {
    'Babuyanes': '바부야네스',
    'Negros': '네그로스',
    'Mountain': '산',
    'Hill': '힐',
    'Hills': '힐즈',
    'Peak': '피크',
    'Ridge': '리지',
    'Point': '포인트',
    'Dulang‑dulang': '둘랑둘랑',
    'Dulang-dulang': '둘랑둘랑',
  };

  int modifiedCount = 0;

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final String currentNameRaw = (item['name'] ?? '').toString();

    if (englishRegex.hasMatch(currentNameRaw)) {
      String newName = currentNameRaw;

      // Replace known terms
      for (var entry in translationMap.entries) {
        newName = newName.replaceAll(
          RegExp(entry.key, caseSensitive: false),
          entry.value,
        );
      }

      // Remove helper words that should be ignored or are redundant
      newName = newName
          .replaceAll(
            RegExp(
              r'\b(Mount|Mountains|Volcano|Island|Lake|Falls|River|Park|Beach|de)\b',
              caseSensitive: false,
            ),
            '',
          )
          .trim();

      // Clean up double "산" like "아바오 산 산"
      newName = newName.replaceAll(RegExp(r'산\s+산'), '산');
      newName = newName.replaceAll(RegExp(r'화산\s+산'), '화산');
      newName = newName.replaceAll(RegExp(r'봉\s+산'), '봉');

      // Clean up spaces
      newName = newName.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (currentNameRaw != newName && !englishRegex.hasMatch(newName)) {
        print('Final Final Updating: "$currentNameRaw" -> "$newName"');
        item['name'] = newName;
        modifiedCount++;
      }
    }
  }

  if (modifiedCount > 0) {
    const encoder = JsonEncoder.withIndent('    ');
    await file.writeAsString(encoder.convert(data));
    print('Updated $modifiedCount items.');
  } else {
    print('No items updated.');
  }
}
