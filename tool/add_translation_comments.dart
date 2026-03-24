import 'dart:io';

/// Usage:
/// cd philgo_app && dart run tool/add_translation_comments.dart
/// Adds English translation comments above .tr() calls in all Dart files.
///
/// Reads the English translation map from lib/l10n/translations.dart,
/// then processes all .dart files in lib/ to insert comments like:
///   // "English Translation"
///   Text('한글키'.tr()),
void main() {
  final projectRoot = _findProjectRoot();
  final translationsFile = File('$projectRoot/lib/l10n/translations.dart');

  if (!translationsFile.existsSync()) {
    print('Error: translations.dart not found');
    exit(1);
  }

  final enMap = _parseEnglishTranslations(translationsFile.readAsStringSync());
  print('Parsed ${enMap.length} English translations');

  final libDir = Directory('$projectRoot/lib');
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.contains('v6'))
      .where((f) => !f.path.endsWith('translations.dart'))
      .toList();

  print('Found ${dartFiles.length} Dart files to process');

  int totalComments = 0;
  int filesModified = 0;

  for (final file in dartFiles) {
    final count = _processFile(file, enMap);
    if (count > 0) {
      totalComments += count;
      filesModified++;
    }
  }

  print('Done! Added $totalComments comments across $filesModified files');
}

String _findProjectRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      print('Error: Could not find project root (no pubspec.yaml found)');
      exit(1);
    }
    dir = parent;
  }
}

/// Parses the English translation map from translations.dart content.
Map<String, String> _parseEnglishTranslations(String content) {
  final map = <String, String>{};

  // Find the English map section
  final enStart = content.indexOf("static const Map<String, dynamic> en = {");
  if (enStart == -1) {
    print('Error: Could not find English translation map');
    exit(1);
  }

  final enSection = content.substring(enStart);

  // Match entries with single-quoted values: 'key': 'value',
  final singleQuotePattern = RegExp(r"'([^']+)'\s*:\s*'((?:[^'\\]|\\.)*)'");
  for (final match in singleQuotePattern.allMatches(enSection)) {
    final key = match.group(1)!;
    final value = match.group(2)!;
    map[key] = value;
  }

  // Match entries with double-quoted values: 'key': "value",
  final doubleQuotePattern = RegExp(
    r"""'([^']+)'\s*:\s*"((?:[^"\\]|\\.)*)"""
    '"',
  );
  for (final match in doubleQuotePattern.allMatches(enSection)) {
    final key = match.group(1)!;
    final value = match.group(2)!;
    map[key] = value;
  }

  // Match multi-line entries: 'key':\n        'value',
  final multiLinePattern = RegExp(r"'([^']+)'\s*:\s*\n\s*'((?:[^'\\]|\\.)*)'");
  for (final match in multiLinePattern.allMatches(enSection)) {
    final key = match.group(1)!;
    final value = match.group(2)!;
    map[key] = value;
  }

  return map;
}

/// Pattern to extract Korean keys from .tr() calls
final _trPattern = RegExp(r"'([^']+)'\.tr\(");

/// Processes a single Dart file, adding English translation comments.
/// Returns the number of comments added.
int _processFile(File file, Map<String, String> enMap) {
  final lines = file.readAsLinesSync();
  final newLines = <String>[];
  int commentsAdded = 0;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final keys = _extractKoreanKeys(line);

    if (keys.isEmpty) {
      newLines.add(line);
      continue;
    }

    // Build the comment
    final translations = keys.map((key) {
      final en = enMap[key];
      if (en == null) return '"[NO TRANSLATION: $key]"';
      final truncated = en.length > 100 ? '${en.substring(0, 100)}...' : en;
      return '"$truncated"';
    }).toList();

    final indent = _getIndent(line);
    final comment = '$indent// ${translations.join(", ")}';

    // Check if previous line already has this exact comment
    if (newLines.isNotEmpty &&
        newLines.last.trimRight() == comment.trimRight()) {
      newLines.add(line);
      continue;
    }

    // Check if previous line in original file already has a translation comment
    // that we should replace
    if (i > 0 && _isTranslationComment(lines[i - 1]) && newLines.isNotEmpty) {
      // Replace the last added line (which was the old comment) with new comment
      newLines[newLines.length - 1] = comment;
      newLines.add(line);
      commentsAdded++; // count as added (replacement)
      continue;
    }

    newLines.add(comment);
    newLines.add(line);
    commentsAdded++;
  }

  if (commentsAdded > 0) {
    file.writeAsStringSync('${newLines.join('\n')}\n');
    print('  ${file.path}: +$commentsAdded comments');
  }

  return commentsAdded;
}

/// Extracts all Korean keys from .tr() calls in a line
List<String> _extractKoreanKeys(String line) {
  final matches = _trPattern.allMatches(line);
  return matches.map((m) => m.group(1)!).toList();
}

/// Gets the leading whitespace of a line
String _getIndent(String line) {
  final match = RegExp(r'^(\s*)').firstMatch(line);
  return match?.group(1) ?? '';
}

/// Checks if a line looks like a translation comment we previously added
bool _isTranslationComment(String line) {
  final trimmed = line.trimLeft();
  return trimmed.startsWith('// "') &&
      !trimmed.contains('TODO') &&
      !trimmed.contains('FIXME');
}
