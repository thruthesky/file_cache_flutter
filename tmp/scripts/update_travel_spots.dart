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
  final nameInTextsRegex = RegExp(r'^#\s*([^(]+)');
  int modifiedCount = 0;

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final String name = (item['name'] ?? '').toString();

    if (englishRegex.hasMatch(name)) {
      String? newName;
      final texts = item['texts'];
      if (texts != null && texts is List && texts.isNotEmpty) {
        final String firstText = texts[0].toString();
        final match = nameInTextsRegex.firstMatch(firstText);
        if (match != null) {
          newName = match.group(1)?.trim();
        }
      }

      // If still not found, check title or English name for transliteration clues
      if (newName == null ||
          newName.isEmpty ||
          englishRegex.hasMatch(newName)) {
        // Here we could add more logic, but for now let's see which ones are like this
        //        print('Could not find Korean name for: $name');
      } else {
        if (name != newName) {
          //          print('Updating: "$name" -> "$newName"');
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
