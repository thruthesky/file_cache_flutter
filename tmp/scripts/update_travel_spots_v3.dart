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
  final l1HeaderRegex = RegExp(r'^#\s*(.*)');
  final emojiRegex = RegExp(
    r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}]',
    unicode: true,
  );

  final forbiddenNames = {
    '개요',
    '특징',
    '방문 정보',
    '추천 포인트 & 여행 팁',
    '추천 포인트',
    '여행 팁',
    '역사',
    '지질학적 특징',
    '교통',
    '주변 지역',
    '인근 명산',
  };

  int modifiedCount = 0;

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final String name = (item['name'] ?? '').toString();

    // Even if it doesn't have English now, it might have been corrupted to "방문 정보" in the last run.
    // So we check if it's one of the forbidden names OR has English.
    if (englishRegex.hasMatch(name) || forbiddenNames.contains(name)) {
      String? newName;
      final texts = item['texts'];
      if (texts != null && texts is List && texts.isNotEmpty) {
        // Look for the FIRST L1 header in ANY of the texts
        for (var text in texts) {
          final lines = text.toString().split('\n');
          for (var line in lines) {
            final hMatch = l1HeaderRegex.firstMatch(line.trim());
            if (hMatch != null) {
              String hContent = hMatch.group(1) ?? '';

              // Handle parenthesis
              if (hContent.contains('(')) {
                final parts = hContent.split('(');
                final beforeParen = parts[0].replaceAll(emojiRegex, '').trim();
                final insideParen = parts[1].split(')')[0].trim();

                if (RegExp(r'[가-힣]').hasMatch(beforeParen)) {
                  newName = beforeParen;
                } else if (RegExp(r'[가-힣]').hasMatch(insideParen)) {
                  // If before is English and inside has Korean, take the Korean part of inside
                  // Usually it's "English (Korean Name)" or "Korean (English Name)"
                  // If insideParen is "Bataan 산", we still want "바탄 산" if possible,
                  // but let's see.
                  newName = insideParen;
                }
              } else {
                newName = hContent.replaceAll(emojiRegex, '').trim();
              }

              if (newName != null && !forbiddenNames.contains(newName)) {
                // Remove trailing English if it's like "바탄 산 Bataan"
                if (englishRegex.hasMatch(newName)) {
                  // Only remove if it's mixed.
                }
                break;
              } else {
                newName = null;
              }
            }
          }
          if (newName != null) break;
        }
      }

      if (newName != null && !forbiddenNames.contains(newName)) {
        // Extra cleanup: remove common English words if they remain
        if (englishRegex.hasMatch(newName)) {
          newName = newName
              .replaceAll(
                RegExp(
                  r'Mount|Island|Volcano|Peak|Lake|Falls|River|Park|Beach',
                  caseSensitive: false,
                ),
                '',
              )
              .trim();
        }

        // Only update if it's mostly Korean now
        if (RegExp(r'[가-힣]').hasMatch(newName) && name != newName) {
          print('Updating: "$name" -> "$newName"');
          item['name'] = newName;
          modifiedCount++;
        }
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
