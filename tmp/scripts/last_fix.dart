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

  final Map<String, String> translationMap = {
    'Cuernos': '쿠에르노스',
    'Negros': '네그로스',
    'Dulangdulang': '둘랑둘랑',
    'Dulang': '둘랑',
    'EDSA': '에드사',
  };

  int modifiedCount = 0;

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final String currentNameRaw = (item['name'] ?? '').toString();

    String newName = currentNameRaw;
    for (var entry in translationMap.entries) {
      newName = newName.replaceAll(
        RegExp(entry.key, caseSensitive: false),
        entry.value,
      );
    }

    // Clean up parenthesis and empty spaces
    newName = newName.replaceAll(RegExp(r'\(\s+\)'), '').trim();
    newName = newName.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (currentNameRaw != newName) {
      print('Last fix: "$currentNameRaw" -> "$newName"');
      item['name'] = newName;
      modifiedCount++;
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
