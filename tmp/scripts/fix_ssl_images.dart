// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// SSL 오류가 있는 philippines.travel 이미지를 Wikipedia 이미지로 교체하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/fix_ssl_images.dart
/// ```

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';
  final failedUrlsPath = 'lib/philgo_files/scripts/real_failed_image_urls.json';

  print('======================================');
  print('📋 SSL 오류 이미지 URL 교체 도구');
  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  // 실패한 URL 읽기
  final failedFile = File(failedUrlsPath);
  final failedJsonString = failedFile.readAsStringSync();
  final List<dynamic> failedUrls = jsonDecode(failedJsonString);

  // SSL 오류 URL만 필터링
  final sslErrors = failedUrls.where((item) {
    final error = item['error']?.toString() ?? '';
    return error.contains('HandshakeException') || error.contains('CERTIFICATE_VERIFY_FAILED');
  }).toList();

  print('📊 SSL 오류 URL 개수: ${sslErrors.length}개\n');

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 10);

  int updated = 0;
  int failed = 0;

  for (final item in sslErrors) {
    final index = item['index'] as int;
    final englishName = item['englishName']?.toString() ?? '';
    final name = item['name']?.toString() ?? '';

    print('🔍 [$index] $name ($englishName)');

    // Wikipedia API로 이미지 URL 가져오기
    final wikiTitle = englishName.replaceAll(' ', '_');
    final apiUrl = 'https://en.wikipedia.org/w/api.php?action=query&titles=$wikiTitle&prop=pageimages&format=json&pithumbsize=800';

    try {
      final uri = Uri.parse(apiUrl);
      final request = await httpClient.getUrl(uri);
      request.headers.add('User-Agent', 'Mozilla/5.0');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;

        final pages = data['query']?['pages'] as Map<String, dynamic>?;
        if (pages != null && pages.isNotEmpty) {
          final page = pages.values.first as Map<String, dynamic>;
          final thumbnail = page['thumbnail'] as Map<String, dynamic>?;

          if (thumbnail != null) {
            final newImageUrl = thumbnail['source'] as String;

            // URL 유효성 확인
            final checkRequest = await httpClient.headUrl(Uri.parse(newImageUrl));
            checkRequest.headers.add('User-Agent', 'Mozilla/5.0');
            final checkResponse = await checkRequest.close();
            await checkResponse.drain();

            if (checkResponse.statusCode >= 200 && checkResponse.statusCode < 400) {
              // 업데이트
              travelSpots[index]['imageUrl'] = newImageUrl;
              print('   ✅ 업데이트: $newImageUrl');
              updated++;
            } else {
              print('   ❌ 이미지 접근 불가: HTTP ${checkResponse.statusCode}');
              failed++;
            }
          } else {
            print('   ⚠️  Wikipedia에 이미지 없음');
            failed++;
          }
        } else {
          print('   ⚠️  Wikipedia 페이지를 찾을 수 없음');
          failed++;
        }
      } else {
        print('   ❌ API 호출 실패: HTTP ${response.statusCode}');
        failed++;
      }
    } catch (e) {
      print('   ❌ 오류: $e');
      failed++;
    }

    // Rate limiting 방지
    await Future.delayed(const Duration(milliseconds: 500));
  }

  httpClient.close();

  // JSON 파일 저장
  final encoder = const JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(travelSpots);
  file.writeAsStringSync(updatedJsonString);

  print('\n======================================');
  print('📊 결과 요약');
  print('======================================');
  print('✅ 업데이트 성공: $updated개');
  print('❌ 업데이트 실패: $failed개');
  print('\n📁 $jsonFilePath 파일이 수정되었습니다.');
}
