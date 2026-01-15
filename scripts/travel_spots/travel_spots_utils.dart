/// travel_spots.json 업데이트용 공용 유틸리티.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String defaultTravelSpotsPath =
    'lib/philgo_files/travel/travel_spots.json';
const String defaultStatePath = 'tmp/travel_spots_update_state.json';
const String defaultLogPath = 'tmp/travel_spots_update_log.ndjson';

final Map<String, SerialExecutor> _hostExecutors = <String, SerialExecutor>{};
final Map<String, DateTime> _hostNextAllowedAt = <String, DateTime>{};
const Duration _wikiMinInterval = Duration(milliseconds: 180);
const Duration _translateMinInterval = Duration(milliseconds: 320);

class WikiInfo {
  final String lang;
  final String title;
  final String summary;
  final String extract;
  final String? description;
  final String? url;

  WikiInfo({
    required this.lang,
    required this.title,
    required this.summary,
    required this.extract,
    required this.description,
    required this.url,
  });
}

class TravelSpotsState {
  final int version;
  String updatedAt;
  final List<int> processed;
  final List<Map<String, dynamic>> reserved;
  final List<Map<String, dynamic>> failed;

  TravelSpotsState({
    required this.version,
    required this.updatedAt,
    required this.processed,
    required this.reserved,
    required this.failed,
  });

  factory TravelSpotsState.empty() {
    return TravelSpotsState(
      version: 1,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
      processed: <int>[],
      reserved: <Map<String, dynamic>>[],
      failed: <Map<String, dynamic>>[],
    );
  }

  factory TravelSpotsState.fromJson(Map<String, dynamic> json) {
    return TravelSpotsState(
      version: (json['version'] as num?)?.toInt() ?? 1,
      updatedAt:
          (json['updatedAt'] as String?) ??
          DateTime.now().toUtc().toIso8601String(),
      processed: (json['processed'] as List<dynamic>? ?? <dynamic>[])
          .whereType<num>()
          .map((value) => value.toInt())
          .toList(),
      reserved: (json['reserved'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList(),
      failed: (json['failed'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'updatedAt': updatedAt,
      'processed': processed,
      'reserved': reserved,
      'failed': failed,
    };
  }

  bool isProcessed(int index) => processed.contains(index);

  bool isReserved(int index) =>
      reserved.any((entry) => entry['index'] == index);

  void reserve(Map<String, dynamic> entry) {
    reserved.removeWhere((item) => item['index'] == entry['index']);
    reserved.add(entry);
  }

  void markProcessed(int index) {
    if (!processed.contains(index)) {
      processed.add(index);
    }
    reserved.removeWhere((entry) => entry['index'] == index);
    failed.removeWhere((entry) => entry['index'] == index);
  }

  void markFailed(int index, Map<String, dynamic> info) {
    failed.removeWhere((entry) => entry['index'] == index);
    failed.add(info);
    reserved.removeWhere((entry) => entry['index'] == index);
  }
}

class SerialExecutor {
  Future<void> _pending = Future<void>.value();

  Future<T> run<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _pending = _pending.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });
    return completer.future;
  }
}

Map<String, String> parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--')) {
      continue;
    }
    final trimmed = arg.substring(2);
    final parts = trimmed.split('=');
    if (parts.length > 1) {
      result[parts[0]] = parts.sublist(1).join('=');
      continue;
    }
    if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
      result[trimmed] = args[i + 1];
      i++;
      continue;
    }
    result[trimmed] = 'true';
  }
  return result;
}

int? parseIntArg(Map<String, String> args, String key) {
  final value = args[key];
  if (value == null) {
    return null;
  }
  return int.tryParse(value);
}

Future<List<dynamic>> loadTravelSpots(String path) async {
  final file = File(path);
  final contents = await file.readAsString();
  final decoded = jsonDecode(contents);
  if (decoded is! List<dynamic>) {
    throw StateError('$path 파일은 JSON 배열(List)이어야 합니다.');
  }
  return decoded;
}

Future<void> saveTravelSpots(String path, List<dynamic> spots) async {
  final encoder = JsonEncoder.withIndent('    ');
  final output = encoder.convert(spots);
  await writeFileAtomic(path, output);
}

Future<void> writeFileAtomic(String path, String contents) async {
  final tmpPath = '$path.tmp';
  final tmpFile = File(tmpPath);
  await tmpFile.writeAsString(contents);
  try {
    await tmpFile.rename(path);
  } on FileSystemException {
    final target = File(path);
    if (await target.exists()) {
      await target.delete();
    }
    await tmpFile.copy(path);
    await tmpFile.delete();
  }
}

Future<TravelSpotsState> loadState(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return TravelSpotsState.empty();
  }
  final contents = await file.readAsString();
  final decoded = jsonDecode(contents);
  if (decoded is! Map<String, dynamic>) {
    return TravelSpotsState.empty();
  }
  return TravelSpotsState.fromJson(decoded);
}

Future<void> saveState(String path, TravelSpotsState state) async {
  final encoder = JsonEncoder.withIndent('    ');
  final output = encoder.convert(state.toJson());
  await writeFileAtomic(path, output);
}

Future<void> appendLog(String path, Map<String, dynamic> entry) async {
  final dir = Directory(File(path).parent.path);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final line = jsonEncode(entry);
  final file = File(path);
  await file.writeAsString('$line\n', mode: FileMode.append);
}

String normalizeWhitespace(String input) {
  return input
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String truncateText(String input, int maxChars) {
  final text = normalizeWhitespace(input);
  if (text.length <= maxChars) {
    return text;
  }
  return '${text.substring(0, maxChars).trim()}…';
}

List<String> splitSentences(String input) {
  final text = normalizeWhitespace(input);
  if (text.isEmpty) {
    return <String>[];
  }
  final parts = text.split(RegExp(r'(?<=[.!?])\s+'));
  return parts.where((part) => part.trim().isNotEmpty).toList();
}

String takeSentences(String input, int count, int maxChars) {
  final sentences = splitSentences(input);
  if (sentences.isEmpty) {
    return truncateText(input, maxChars);
  }
  final selected = sentences.take(count).join(' ');
  return truncateText(selected, maxChars);
}

List<String> bulletizeText(String input, int maxItems, int maxChars) {
  final sentences = splitSentences(input)
      .where((sentence) => sentence.length >= 40)
      .toList();
  if (sentences.isEmpty) {
    final trimmed = truncateText(input, maxChars);
    return trimmed.isEmpty ? <String>[] : <String>[trimmed];
  }
  final output = <String>[];
  for (final sentence in sentences) {
    if (output.length >= maxItems) {
      break;
    }
    output.add(truncateText(sentence, maxChars));
  }
  return output;
}

String decorateFirstHeading(String text, String emoji) {
  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (!line.startsWith('#')) {
      continue;
    }
    final headingText = line.replaceFirst(RegExp(r'^#+\s*'), '');
    final hasEmoji =
        RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true)
            .hasMatch(line);
    if (!hasEmoji) {
      final prefix = line.split(' ').first;
      lines[i] = '$prefix $emoji $headingText'.trimRight();
    }
    break;
  }
  return lines.join('\n');
}

Future<WikiInfo?> fetchWikiInfo({
  required String name,
  required String englishName,
  String? city,
  String? province,
}) async {
  final client = WikiClient();
  try {
    final koreanQuery = name.trim();
    final englishQuery = englishName.trim();
    final queries = buildWikiQueries(
      name: koreanQuery,
      englishName: englishQuery,
      city: city,
      province: province,
    );

    for (final query in queries.ko) {
      final info = await tryFetchWiki(client, 'ko', query);
      if (info != null) {
        return info;
      }
    }

    for (final query in queries.en) {
      final info = await tryFetchWiki(client, 'en', query);
      if (info != null) {
        return info;
      }
    }

    return null;
  } finally {
    client.close();
  }
}

class WikiQueries {
  final List<String> ko;
  final List<String> en;

  WikiQueries({required this.ko, required this.en});
}

WikiQueries buildWikiQueries({
  required String name,
  required String englishName,
  String? city,
  String? province,
}) {
  final ko = <String>[];
  final en = <String>[];

  void addUnique(List<String> list, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    if (!list.contains(trimmed)) {
      list.add(trimmed);
    }
  }

  addUnique(ko, name);
  addUnique(ko, '$name 필리핀');
  addUnique(ko, englishName);

  addUnique(en, englishName);
  addUnique(en, '$englishName Philippines');

  return WikiQueries(ko: ko, en: en);
}

Future<WikiInfo?> tryFetchWiki(
  WikiClient client,
  String lang,
  String query,
) async {
  final search = await client.search(lang, query);
  if (search == null) {
    return null;
  }
  if (!isWikiTitleRelevant(query, search.title)) {
    return null;
  }
  return await client.fetchInfo(lang, search.title, search.url);
}

bool isWikiTitleRelevant(String query, String title) {
  final q = normalizeForMatch(query);
  final t = normalizeForMatch(title);
  if (q.isEmpty || t.isEmpty) {
    return false;
  }
  if (q == t) {
    return true;
  }
  if (t.contains(q) || q.contains(t)) {
    return true;
  }
  final tokens = extractMatchTokens(query);
  for (final token in tokens) {
    final nt = normalizeForMatch(token);
    if (nt.length < 2) {
      continue;
    }
    if (t.contains(nt)) {
      return true;
    }
  }
  return false;
}

String normalizeForMatch(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^0-9a-z가-힣]'), '');
}

List<String> extractMatchTokens(String input) {
  return input
      .split(RegExp(r'[\s\-_/·,.:;()\[\]{}]+'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList();
}

class WikiSearchResult {
  final String title;
  final String? url;

  WikiSearchResult({required this.title, required this.url});
}

class WikiClient {
  final HttpClient _client = HttpClient();
  final String _userAgent = 'philgo-travel-spots-updater/1.0';

  Future<WikiSearchResult?> search(String lang, String query) async {
    final uri = Uri.https('$lang.wikipedia.org', '/w/api.php', <String, String>{
      'action': 'opensearch',
      'search': query,
      'limit': '1',
      'namespace': '0',
      'format': 'json',
    });
    final data = await _getJson(uri);
    if (data is! List<dynamic> || data.length < 2) {
      return null;
    }
    final titles = data[1] as List<dynamic>;
    if (titles.isEmpty) {
      return null;
    }
    final urls = data.length > 3 ? data[3] as List<dynamic> : <dynamic>[];
    return WikiSearchResult(
      title: titles.first.toString(),
      url: urls.isNotEmpty ? urls.first.toString() : null,
    );
  }

  Future<WikiInfo?> fetchInfo(
    String lang,
    String title,
    String? url,
  ) async {
    final summaryUri = Uri.parse(
      'https://$lang.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title.replaceAll(' ', '_'))}',
    );
    final summaryData = await _getJson(summaryUri);
    final summaryText = summaryData is Map<String, dynamic>
        ? (summaryData['extract'] as String?) ?? ''
        : '';
    final summaryDescription = summaryData is Map<String, dynamic>
        ? summaryData['description'] as String?
        : null;

    final extractUri = Uri.https('$lang.wikipedia.org', '/w/api.php',
        <String, String>{
          'action': 'query',
          'prop': 'extracts',
          'explaintext': '1',
          'exsectionformat': 'plain',
          'exchars': '2000',
          'format': 'json',
          'titles': title,
        });
    final extractData = await _getJson(extractUri);
    String extractText = '';
    if (extractData is Map<String, dynamic>) {
      final query = extractData['query'];
      if (query is Map<String, dynamic>) {
        final pages = query['pages'];
        if (pages is Map<String, dynamic> && pages.isNotEmpty) {
          final first = pages.values.first;
          if (first is Map<String, dynamic>) {
            extractText = first['extract'] as String? ?? '';
          }
        }
      }
    }

    if (summaryText.trim().isEmpty && extractText.trim().isEmpty) {
      return null;
    }

    return WikiInfo(
      lang: lang,
      title: title,
      summary: normalizeWhitespace(summaryText),
      extract: normalizeWhitespace(extractText),
      description: summaryDescription,
      url: url,
    );
  }

  Future<dynamic> _getJson(Uri uri) async {
    return await _runWithHostLimit(uri.host, () async {
      const maxAttempts = 6;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final request = await _client.getUrl(uri);
        request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(body);
        }

        final retryAfter = _parseRetryAfterSeconds(response.headers);
        if (response.statusCode == 429 ||
            response.statusCode == 503 ||
            response.statusCode == 502 ||
            response.statusCode == 504) {
          if (attempt == maxAttempts - 1) {
            throw HttpException('요청 실패 (${response.statusCode})', uri: uri);
          }
          final wait = retryAfter ?? _backoffDuration(attempt);
          await Future.delayed(wait);
          continue;
        }

        throw HttpException('요청 실패 (${response.statusCode})', uri: uri);
      }
      throw HttpException('요청 실패 (재시도 초과)', uri: uri);
    });
  }

  void close() {
    _client.close(force: true);
  }
}

Future<T> _runWithHostLimit<T>(String host, Future<T> Function() action) async {
  final executor = _hostExecutors.putIfAbsent(host, () => SerialExecutor());
  return await executor.run(() async {
    final now = DateTime.now();
    final nextAllowed = _hostNextAllowedAt[host];
    if (nextAllowed != null && now.isBefore(nextAllowed)) {
      await Future.delayed(nextAllowed.difference(now));
    }
    _hostNextAllowedAt[host] = DateTime.now().add(_minIntervalForHost(host));
    return await action();
  });
}

Duration _minIntervalForHost(String host) {
  if (host.contains('translate.googleapis.com')) {
    return _translateMinInterval;
  }
  return _wikiMinInterval;
}

Duration _backoffDuration(int attempt) {
  final seconds = 1 << attempt;
  final capped = seconds > 30 ? 30 : seconds;
  return Duration(seconds: capped);
}

Duration? _parseRetryAfterSeconds(HttpHeaders headers) {
  final values = headers[HttpHeaders.retryAfterHeader];
  if (values == null || values.isEmpty) {
    return null;
  }
  final raw = values.first.trim();
  final seconds = int.tryParse(raw);
  if (seconds == null) {
    return null;
  }
  return Duration(seconds: seconds);
}

Map<String, dynamic> buildUpdatedSpot(
  Map<String, dynamic> spot,
  WikiInfo? wiki,
  int textIndexOffset,
) {
  final updated = Map<String, dynamic>.from(spot);
  final currentTitle = (spot['title'] ?? '').toString().trim();
  final currentDescription = (spot['description'] ?? '').toString().trim();
  final currentName = (spot['name'] ?? '').toString().trim();
  final currentEnglishName = (spot['english name'] ?? '').toString().trim();

  final newTitle = buildTitle(currentTitle, wiki);
  final newDescription = buildDescription(currentDescription, wiki);

  updated['title'] = newTitle;
  updated['description'] = newDescription;

  final spotForTexts = Map<String, dynamic>.from(spot);
  spotForTexts['title'] = newTitle;
  spotForTexts['description'] = newDescription;

  final existingTexts = (spot['texts'] as List<dynamic>? ?? <dynamic>[])
      .map((text) => text.toString())
      .where((text) => !isGeneratedTextBlock(text))
      .toList();
  final decoratedExisting = decorateTexts(existingTexts, textIndexOffset);

  final newTexts = <String>[
    buildOverviewText(spotForTexts, wiki),
    buildHighlightsText(spotForTexts, wiki),
    buildDetailsText(spotForTexts, wiki),
  ].where((text) => text.trim().isNotEmpty).toList();

  updated['texts'] = <String>[...newTexts, ...decoratedExisting];

  if (wiki != null) {
    if (wiki.lang == 'en' && wiki.title.isNotEmpty && currentEnglishName.isEmpty) {
      updated['english name'] = wiki.title;
    }
    if (wiki.lang == 'ko' && wiki.title.isNotEmpty && currentName.isEmpty) {
      updated['name'] = wiki.title;
    }
  }

  return updated;
}

/// travel_spots.json 정리(번역 + 중복 제거)를 위한 기본 경로들.
const String defaultCleanupStatePath = 'tmp/travel_spots_cleanup_state.json';
const String defaultCleanupLogPath = 'tmp/travel_spots_cleanup_log.ndjson';

/// 영어 문장을 한국어로 번역하고, texts 중복을 정리합니다.
Future<Map<String, dynamic>> cleanupSpotKo(Map<String, dynamic> spot) async {
  final updated = Map<String, dynamic>.from(spot);

  Future<void> translateField(String key) async {
    final value = (updated[key] ?? '').toString();
    if (value.trim().isEmpty) {
      return;
    }
    if (!looksMostlyEnglish(value)) {
      return;
    }
    updated[key] = await translateEnToKoPreservingMarkup(value);
  }

  // english name 필드는 수정하지 않습니다.
  await translateField('title');
  await translateField('description');
  await translateField('category');
  await translateField('city');
  await translateField('province');

  final texts = (updated['texts'] as List<dynamic>? ?? const <dynamic>[])
      .map((value) => value.toString())
      .toList();

  final translatedTexts = <String>[];
  for (final text in texts) {
    final translated = await translateMarkdownToKo(text);
    final normalized = normalizeTemplateHeadings(translated);
    final fixed = await translateKnownBulletValues(normalized);
    translatedTexts.add(fixed);
  }

  updated['texts'] = dedupeTexts(translatedTexts);
  return updated;
}

/// 마크다운 구조를 최대한 유지하면서 번역합니다(영어 비율이 높은 단락만 번역).
Future<String> translateMarkdownToKo(String input) async {
  final original = input;
  final paragraphs = original.split('\n\n');
  var changed = false;
  for (var i = 0; i < paragraphs.length; i++) {
    final p = paragraphs[i];
    if (!looksMostlyEnglish(p)) {
      continue;
    }
    final translated = await translateEnToKoPreservingMarkup(p);
    if (translated != p) {
      paragraphs[i] = translated;
      changed = true;
    }
  }
  return changed ? paragraphs.join('\n\n') : original;
}

/// 템플릿 형태의 헤딩은 번역되더라도 일정한 형태로 고정합니다.
String normalizeTemplateHeadings(String text) {
  var out = text;
  out = out.replaceAllMapped(
    RegExp(r'^##\s*✨.*$', multiLine: true),
    (_) => '## ✨ 핵심 포인트',
  );
  out = out.replaceAllMapped(
    RegExp(r'^##\s*✅.*$', multiLine: true),
    (_) => '## ✅ 방문 전 체크',
  );
  out = out.replaceAllMapped(
    RegExp(r'^##\s*📌.*$', multiLine: true),
    (_) => '## 📌 한눈에 보기',
  );
  out = out.replaceAllMapped(
    RegExp(r'^###\s*📝.*$', multiLine: true),
    (_) => '### 📝 요약',
  );
  out = out.replaceAllMapped(
    RegExp(r'^##\s*📚.*$', multiLine: true),
    (_) => '## 📚 추가 정보',
  );
  out = out.replaceAllMapped(
    RegExp(r'^###\s*🔗.*$', multiLine: true),
    (_) => '### 🔗 참고',
  );
  return out;
}

/// 한국어 문단 안에 섞여 있는 “값 영역”의 영어(예: 위키 키워드)를 추가 번역합니다.
Future<String> translateKnownBulletValues(String text) async {
  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final replaced = await _translateBulletValue(line, '💡 위키 키워드:');
    if (replaced != null) {
      lines[i] = replaced;
      continue;
    }
    final replacedTitle = await _translateBulletValue(line, '🏷️ 한 줄 소개:');
    if (replacedTitle != null) {
      lines[i] = replacedTitle;
      continue;
    }
    final replacedCategory = await _translateBulletValue(line, '🧭 분류:');
    if (replacedCategory != null) {
      lines[i] = replacedCategory;
      continue;
    }
  }
  return lines.join('\n');
}

Future<String?> _translateBulletValue(String line, String label) async {
  final trimmed = line.trimLeft();
  if (!trimmed.startsWith('- ')) {
    return null;
  }
  final idx = line.indexOf(label);
  if (idx == -1) {
    return null;
  }
  final valueStart = idx + label.length;
  final value = line.substring(valueStart).trim();
  if (value.isEmpty) {
    return null;
  }
  if (!looksEnglishValue(value)) {
    return null;
  }
  final translated = await translateEnToKoPreservingMarkup(value);
  if (translated == value) {
    return null;
  }
  return '${line.substring(0, valueStart)} ${translated.trim()}';
}

bool looksEnglishValue(String text) {
  final s = text.trim();
  if (s.isEmpty) {
    return false;
  }
  var latin = 0;
  var hangul = 0;
  for (final code in s.runes) {
    if ((code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A)) {
      latin++;
      continue;
    }
    if (code >= 0xAC00 && code <= 0xD7A3) {
      hangul++;
    }
  }
  if (latin < 8) {
    return false;
  }
  if (hangul == 0) {
    return true;
  }
  return latin >= hangul * 2;
}

/// 번역 시 URL/코드스팬을 보존합니다.
Future<String> translateEnToKoPreservingMarkup(String input) async {
  final placeholders = <String, String>{};
  var working = input;

  working = _replaceWithPlaceholders(
    working,
    RegExp(r'`[^`]*`'),
    placeholders,
    'CODE',
  );
  working = _replaceWithPlaceholders(
    working,
    RegExp(r'https?://\S+'),
    placeholders,
    'URL',
  );

  final translated = await TranslateClient.instance.translateEnToKo(working);
  var restored = translated;
  placeholders.forEach((key, value) {
    restored = restored.replaceAll(key, value);
  });
  return restored;
}

String _replaceWithPlaceholders(
  String input,
  RegExp pattern,
  Map<String, String> placeholders,
  String prefix,
) {
  var index = placeholders.length;
  return input.replaceAllMapped(pattern, (match) {
    final key = '__${prefix}_${index}__';
    index++;
    placeholders[key] = match.group(0) ?? '';
    return key;
  });
}

bool looksMostlyEnglish(String text) {
  final s = text.trim();
  if (s.isEmpty) {
    return false;
  }
  var latin = 0;
  var hangul = 0;
  for (final code in s.runes) {
    if ((code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A)) {
      latin++;
      continue;
    }
    if (code >= 0xAC00 && code <= 0xD7A3) {
      hangul++;
    }
  }
  if (latin < 25) {
    return false;
  }
  // 한국어가 거의 없고 영어가 우세한 경우만 번역 대상으로 봅니다.
  if (hangul == 0) {
    return true;
  }
  return latin >= hangul * 2;
}

List<String> dedupeTexts(List<String> texts) {
  final output = <String>[];
  final seen = <String>{};
  for (final text in texts) {
    final cleaned = dedupeLinesInBlock(text);
    final fp = fingerprintForDedupe(cleaned);
    if (fp.isEmpty) {
      continue;
    }
    if (seen.contains(fp)) {
      continue;
    }
    seen.add(fp);
    output.add(cleaned);
  }
  return output;
}

String dedupeLinesInBlock(String text) {
  final lines = text.split('\n');
  final output = <String>[];
  final seen = <String>{};
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      output.add(line);
      continue;
    }
    final isListLine =
        trimmed.startsWith('- ') || RegExp(r'^\d+\.\s+').hasMatch(trimmed);
    if (!isListLine) {
      output.add(line);
      continue;
    }
    final fp = fingerprintForDedupe(trimmed);
    if (seen.contains(fp)) {
      continue;
    }
    seen.add(fp);
    output.add(line);
  }
  return output.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trimRight();
}

String fingerprintForDedupe(String text) {
  final normalized = normalizeWhitespace(text)
      .replaceAll(
        RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true),
        '',
      )
      .replaceAll(RegExp(r'[#*`>\\-\\[\\]\\(\\)\\d\\s]'), '')
      .toLowerCase();
  return normalized;
}

/// 간단한 EN->KO 번역 클라이언트(비공식 Google Translate 엔드포인트 사용).
class TranslateClient {
  static final TranslateClient instance = TranslateClient._();
  final HttpClient _client = HttpClient();
  final Map<String, String> _cache = <String, String>{};

  TranslateClient._();

  Future<String> translateEnToKo(String input) async {
    final text = input.trim();
    if (text.isEmpty) {
      return input;
    }
    final cached = _cache[text];
    if (cached != null) {
      return cached;
    }

    final uri = Uri.https('translate.googleapis.com', '/translate_a/single', {
      'client': 'gtx',
      'sl': 'en',
      'tl': 'ko',
      'dt': 't',
      'q': text,
    });

    try {
      final decoded = await _runWithHostLimit(uri.host, () async {
        const maxAttempts = 6;
        for (var attempt = 0; attempt < maxAttempts; attempt++) {
          final request = await _client.getUrl(uri);
          final response = await request.close();
          final body = await response.transform(utf8.decoder).join();
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return jsonDecode(body);
          }

          final retryAfter = _parseRetryAfterSeconds(response.headers);
          if (response.statusCode == 429 ||
              response.statusCode == 503 ||
              response.statusCode == 502 ||
              response.statusCode == 504) {
            if (attempt == maxAttempts - 1) {
              throw HttpException('번역 요청 실패 (${response.statusCode})', uri: uri);
            }
            final wait = retryAfter ?? _backoffDuration(attempt);
            await Future.delayed(wait);
            continue;
          }

          throw HttpException('번역 요청 실패 (${response.statusCode})', uri: uri);
        }
        throw HttpException('번역 요청 실패 (재시도 초과)', uri: uri);
      });

      final translated = _extractTranslatedText(decoded) ?? input;
      _cache[text] = translated;
      return translated;
    } catch (_) {
      // 번역이 실패하면 원문을 유지합니다.
      return input;
    }
  }

  String? _extractTranslatedText(dynamic decoded) {
    if (decoded is! List) {
      return null;
    }
    if (decoded.isEmpty) {
      return null;
    }
    final parts = decoded[0];
    if (parts is! List) {
      return null;
    }
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is List && part.isNotEmpty) {
        buffer.write(part[0]?.toString() ?? '');
      }
    }
    final out = buffer.toString();
    return out.trim().isEmpty ? null : out;
  }
}

bool isGeneratedTextBlock(String text) {
  final trimmed = text.trimLeft();
  if (trimmed.contains('## 📌 한눈에 보기') &&
      trimmed.contains('### 📝 요약')) {
    return true;
  }
  if (trimmed.startsWith('## ✨ 핵심 포인트') ||
      trimmed.contains('## ✅ 방문 전 체크')) {
    return true;
  }
  if (trimmed.startsWith('## 📚 추가 정보')) {
    return true;
  }
  return false;
}

String buildTitle(String currentTitle, WikiInfo? wiki) {
  if (wiki == null) {
    return currentTitle;
  }
  final baseTitle = currentTitle.split(' · ').first.trim();
  if (wiki.lang == 'en') {
    return baseTitle.isEmpty ? currentTitle : baseTitle;
  }
  final description = wiki.description ?? '';
  final snippet = description.isNotEmpty
      ? truncateText(description, 50)
      : takeSentences(wiki.summary, 1, 60);
  if (snippet.isEmpty) {
    return currentTitle;
  }
  if (currentTitle.contains(snippet)) {
    return currentTitle;
  }
  final candidate = baseTitle.isEmpty ? snippet : '$baseTitle · $snippet';
  return candidate.length > 90 ? baseTitle : candidate;
}

String buildDescription(String current, WikiInfo? wiki) {
  final buffer = StringBuffer();
  final base = takeSentences(current, 2, 260);
  if (base.isNotEmpty) {
    buffer.write(base);
  }
  if (wiki == null) {
    return buffer.toString().trim();
  }
  if (wiki.lang != 'ko') {
    return buffer.toString().trim();
  }
  final additions = <String>[];
  if (wiki.summary.isNotEmpty) {
    additions.add(takeSentences(wiki.summary, 2, 240));
  }
  if (wiki.extract.isNotEmpty) {
    additions.add(takeSentences(wiki.extract, 2, 260));
  }
  for (final addition in additions) {
    if (addition.isEmpty) {
      continue;
    }
    if (buffer.toString().contains(addition)) {
      continue;
    }
    if (buffer.isNotEmpty) {
      buffer.write(' ');
    }
    buffer.write(addition);
  }
  return buffer.toString().trim();
}

List<String> decorateTexts(List<String> texts, int offset) {
  final emojis = <String>[
    '🌟',
    '🗺️',
    '💡',
    '📌',
    '🎒',
    '📷',
    '🧭',
  ];
  final output = <String>[];
  for (var i = 0; i < texts.length; i++) {
    final emoji = emojis[(i + offset) % emojis.length];
    output.add(decorateFirstHeading(texts[i], emoji));
  }
  return output;
}

String buildOverviewText(Map<String, dynamic> spot, WikiInfo? wiki) {
  final name = spot['name']?.toString().trim() ?? '';
  final englishName = spot['english name']?.toString().trim() ?? '';
  final icon = spot['icon']?.toString().trim() ?? '📍';
  final title = spot['title']?.toString().trim() ?? '';
  final city = spot['city']?.toString().trim() ?? '';
  final province = spot['province']?.toString().trim() ?? '';
  final category = spot['category']?.toString().trim() ?? '';

  final buffer = StringBuffer();
  buffer.writeln('# $icon $name${englishName.isEmpty ? '' : ' ($englishName)'}');
  buffer.writeln('');
  buffer.writeln('## 📌 한눈에 보기');
  if (title.isNotEmpty) {
    buffer.writeln('- 🏷️ 한 줄 소개: $title');
  }
  if (category.isNotEmpty) {
    buffer.writeln('- 🧭 분류: $category');
  }
  if (city.isNotEmpty || province.isNotEmpty) {
    buffer.writeln('- 📍 위치: ${[city, province].where((v) => v.isNotEmpty).join(', ')}');
  }
  if (wiki?.description != null && wiki!.description!.isNotEmpty) {
    buffer.writeln('- 💡 위키 키워드: ${truncateText(wiki.description!, 80)}');
  }
  if (wiki?.url != null && wiki!.url!.isNotEmpty) {
    buffer.writeln('- 🔗 참고 링크: ${wiki.url}');
  }
  if (wiki != null && wiki.summary.isNotEmpty) {
    buffer.writeln('');
    buffer.writeln('### 📝 요약');
    buffer.writeln(truncateText(wiki.summary, 500));
  }
  return buffer.toString().trim();
}

String buildHighlightsText(Map<String, dynamic> spot, WikiInfo? wiki) {
  if (wiki == null) {
    return '';
  }
  final bullets = bulletizeText(wiki.extract.isNotEmpty
      ? wiki.extract
      : wiki.summary, 4, 160);
  if (bullets.isEmpty) {
    return '';
  }
  final emojis = <String>['✨', '🌟', '📍', '🧭', '🏝️', '🏛️'];
  final buffer = StringBuffer();
  buffer.writeln('## ✨ 핵심 포인트');
  for (var i = 0; i < bullets.length; i++) {
    final emoji = emojis[i % emojis.length];
    buffer.writeln('- $emoji ${bullets[i]}');
  }
  buffer.writeln('');
  buffer.writeln('## ✅ 방문 전 체크');
  buffer.writeln('- 🕒 운영 시간·입장료는 공식 채널에서 최신 정보를 확인하세요.');
  buffer.writeln('- 🚗 이동 수단은 현지 교통 상황에 따라 소요 시간이 달라질 수 있습니다.');
  buffer.writeln('- ☀️ 날씨와 시즌에 따라 체감 분위기가 크게 달라집니다.');
  return buffer.toString().trim();
}

String buildDetailsText(Map<String, dynamic> spot, WikiInfo? wiki) {
  if (wiki == null) {
    return '';
  }
  final details = wiki.extract.isNotEmpty
      ? takeSentences(wiki.extract, 6, 900)
      : takeSentences(wiki.summary, 4, 600);
  if (details.isEmpty) {
    return '';
  }
  final buffer = StringBuffer();
  buffer.writeln('## 📚 추가 정보');
  buffer.writeln(details);
  if (wiki.url != null && wiki.url!.isNotEmpty) {
    buffer.writeln('');
    buffer.writeln('### 🔗 참고');
    buffer.writeln('- ${wiki.url}');
  }
  return buffer.toString().trim();
}

Map<String, dynamic> buildIndexInfo(Map<String, dynamic> spot, int index) {
  return <String, dynamic>{
    'index': index,
    'name': spot['name'],
    'englishName': spot['english name'],
    'city': spot['city'],
    'province': spot['province'],
  };
}
