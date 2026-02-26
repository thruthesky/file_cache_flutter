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

  final englishRegex = RegExp(r'[a-zA-Z]');
  final l1HeaderRegex = RegExp(r'^#\s+([^#\n]+)');
  final emojiRegex = RegExp(
    r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}]',
    unicode: true,
  );
  final korEngParenRegex = RegExp(r'([가-힣]+)\s*\(([a-zA-Z\s/-]+)\)');

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
    final String currentName = (item['name'] ?? '').toString();
    final String englishName = (item['english name'] ?? '').toString();

    // Only process if it has English or if it was corrupted in previous runs
    if (englishRegex.hasMatch(currentName) ||
        forbiddenNames.any((e) => currentName.contains(e))) {
      String? newName;
      final texts = item['texts'];

      if (texts != null && texts is List && texts.isNotEmpty) {
        // Strategy 1: Try to find L1 header with format "# Korean (English)"
        for (var text in texts) {
          final lines = text.toString().split('\n');
          for (var line in lines) {
            final hMatch = l1HeaderRegex.firstMatch(line.trim());
            if (hMatch != null) {
              String hContent =
                  hMatch.group(1)?.replaceAll(emojiRegex, '').trim() ?? '';
              if (hContent.contains('(')) {
                final parts = hContent.split('(');
                final beforeParen = parts[0].trim();
                final insideParen = parts[1].split(')')[0].trim();

                if (RegExp(r'[가-힣]').hasMatch(beforeParen) &&
                    !forbiddenNames.contains(beforeParen)) {
                  newName = beforeParen;
                  break;
                } else if (RegExp(r'[가-힣]').hasMatch(insideParen) &&
                    !forbiddenNames.contains(insideParen)) {
                  // If it's something like "(Bataan 산)", we still have English.
                  // But if it's "(바탄 산)", it's good.
                  if (!englishRegex.hasMatch(insideParen)) {
                    newName = insideParen;
                    break;
                  }
                }
              } else {
                if (RegExp(r'[가-힣]').hasMatch(hContent) &&
                    !forbiddenNames.contains(hContent) &&
                    !englishRegex.hasMatch(hContent)) {
                  newName = hContent;
                  break;
                }
              }
            }
          }
          if (newName != null) break;
        }

        // Strategy 2: Look for transliteration clues in the text: "Korean(English)"
        if (newName == null) {
          for (var text in texts) {
            final matches = korEngParenRegex.allMatches(text.toString());
            for (var match in matches) {
              final kor = match.group(1)!;
              final eng = match.group(2)!;

              // If the English in parenthesis is part of the item's English name
              if (englishName.toLowerCase().contains(eng.toLowerCase()) &&
                  eng.length > 2) {
                // We found a likely transliteration!
                // If the current name is "Bataan 산", and we found Bataan -> 바탄,
                // then change it to "바탄 산".
                if (currentName.contains(eng)) {
                  newName = currentName.replaceAll(eng, kor);
                  break;
                } else {
                  // Or just construct it
                  if (currentName.endsWith(' 산'))
                    newName = '$kor 산';
                  else if (currentName.endsWith(' 화산'))
                    newName = '$kor 화산';
                }
              }
              if (newName != null) break;
            }
            if (newName != null) break;
          }
        }
      }

      // Strategy 3: Manual Mapping for remaining common ones (based on my knowledge as AI)
      if (newName == null || englishRegex.hasMatch(newName)) {
        final Map<String, String> manualMap = {
          'Bataan': '바탄',
          'Batulao': '바투라오',
          'Hibok-Hibok': '히복히복',
          'Batelian': '바텔리안',
          'Batorampon': '바토람폰',
          'Baya': '바야',
          'Bayabas': '바야바스',
          'Bayaguitos': '바야기토스',
          'Bernacci': '베르나치',
          'Biliran': '빌리란',
          'Binaca': '비나카',
          'Bilusic': '빌루식',
          'Bulusan': '불루산',
          'Cabalian': '카발리안',
          'Cagua': '카구아',
          'Calavite': '칼라비테',
          'Davao': '다바오',
          'Lantaw': '란타우',
        };

        for (var entry in manualMap.entries) {
          if (currentName.contains(entry.key)) {
            newName = currentName.replaceAll(entry.key, entry.value);
            break;
          }
        }
      }

      if (newName != null && !forbiddenNames.contains(newName)) {
        // Clean up remaining English types if they exist as separate words
        newName = newName
            .replaceAll(
              RegExp(
                r'\b(Mount|Island|Volcano|Peak|Lake|Falls|River|Park|Beach)\b',
                caseSensitive: false,
              ),
              '',
            )
            .trim();

        // Final sanity check: should have Korean and not be English-only
        if (RegExp(r'[가-힣]').hasMatch(newName) && currentName != newName) {
          //          print('Updating: "$currentName" -> "$newName"');
          item['name'] = newName;
          modifiedCount++;
        }
      }
    }
  }

  if (modifiedCount > 0) {
    const encoder = JsonEncoder.withIndent('    ');
    await file.writeAsString(encoder.convert(data));
    //    print('Updated $modifiedCount items.');
  } else {
    //    print('No items updated.');
  }
}
