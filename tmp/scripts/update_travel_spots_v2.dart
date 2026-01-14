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
  final headerRegex = RegExp(r'^#+\s*(.*)');
  final emojiRegex = RegExp(
    r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}]',
    unicode: true,
  );
  int modifiedCount = 0;

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final String name = (item['name'] ?? '').toString();

    if (englishRegex.hasMatch(name)) {
      String? newName;
      final texts = item['texts'];
      if (texts != null && texts is List && texts.isNotEmpty) {
        for (var text in texts) {
          final lines = text.toString().split('\n');
          for (var line in lines) {
            final hMatch = headerRegex.firstMatch(line.trim());
            if (hMatch != null) {
              String hContent = hMatch.group(1) ?? '';
              // Remove anything in parentheses if it's mostly English
              if (hContent.contains('(')) {
                final parts = hContent.split('(');
                final beforeParen = parts[0].replaceAll(emojiRegex, '').trim();
                final insideParen = parts[1].split(')')[0].trim();

                // If beforeParen is mostly English and insideParen has Korean, use insideParen
                if (englishRegex.hasMatch(beforeParen) &&
                    !RegExp(r'[가-힣]').hasMatch(beforeParen) &&
                    RegExp(r'[가-힣]').hasMatch(insideParen)) {
                  newName = insideParen;
                } else if (RegExp(r'[가-힣]').hasMatch(beforeParen)) {
                  newName = beforeParen;
                }
              } else {
                newName = hContent.replaceAll(emojiRegex, '').trim();
              }

              if (newName != null && RegExp(r'[가-힣]').hasMatch(newName)) {
                // If it still has English, let's try to remove it if it's just a word like "Mount" or "Island"
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
                break;
              }
            }
          }
          if (newName != null && !englishRegex.hasMatch(newName)) break;
        }
      }

      // Final check: if newName is still null or has English, fallback to transliteration for common cases
      if (newName == null ||
          newName.isEmpty ||
          englishRegex.hasMatch(newName)) {
        // Handle common cases like "Name 산" -> "네임 산"
        if (name.endsWith(' 산') ||
            name.endsWith(' 화산') ||
            name.endsWith(' 봉')) {
          // Keep it as is or try manual if possible.
          // For now, let's see.
        }
      } else {
        if (name != newName) {
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
