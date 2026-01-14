import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File(
    '/Users/thruthesky/apps/flutter/philgo_app/lib/philgo_files/travel/travel_spots.json',
  );
  if (!await file.exists()) {
    print('File not found');
    return;
  }

  final content = await file.readAsString();
  final List<dynamic> data = json.decode(content);

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 10);

  final List<Map<String, dynamic>> failed = [];

  print('Checking ${data.length} items...');

  for (int i = 0; i < data.length; i++) {
    final item = data[i];
    final String name = item['name'] ?? '';
    final String englishName = item['english name'] ?? '';
    final String imageUrl = item['imageUrl'] ?? '';

    if (imageUrl.isEmpty) {
      failed.add({
        'index': i,
        'name': name,
        'englishName': englishName,
        'error': 'Empty URL',
      });
      continue;
    }

    try {
      final request = await httpClient.getUrl(Uri.parse(imageUrl));
      // Add User-Agent to avoid 403/429
      request.headers.set(
        'User-Agent',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      );
      final response = await request.close();
      await response.drain();

      if (response.statusCode != 200) {
        failed.add({
          'index': i,
          'name': name,
          'englishName': englishName,
          'imageUrl': imageUrl,
          'error': 'HTTP ${response.statusCode}',
        });
        print('FAILED: $name ($englishName) - HTTP ${response.statusCode}');
      }
    } catch (e) {
      failed.add({
        'index': i,
        'name': name,
        'englishName': englishName,
        'imageUrl': imageUrl,
        'error': e.toString(),
      });
      print('FAILED: $name ($englishName) - $e');
    }

    if (i % 50 == 0) {
      print('Progress: $i/${data.length}');
    }
  }

  httpClient.close();

  final resultFile = File(
    '/Users/thruthesky/apps/flutter/philgo_app/tmp/scripts/broken_images.json',
  );
  await resultFile.writeAsString(JsonEncoder.withIndent('  ').convert(failed));
  print(
    'Done. Found ${failed.length} broken images. Saved to tmp/scripts/broken_images.json',
  );
}
