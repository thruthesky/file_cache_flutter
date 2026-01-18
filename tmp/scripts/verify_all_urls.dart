// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 모든 imageUrl의 유효성을 검증하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/verify_all_urls.dart
/// ```

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 전체 이미지 URL 검증 도구');
  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 10);

  final List<Map<String, dynamic>> failedUrls = [];
  int checked = 0;
  int success = 0;

  for (int i = 0; i < travelSpots.length; i++) {
    final spot = travelSpots[i];
    final name = spot['name']?.toString() ?? '';
    final englishName = spot['englishName']?.toString() ?? '';
    final imageUrl = spot['imageUrl']?.toString() ?? '';

    if (imageUrl.isEmpty) {
      continue;
    }

    checked++;

    try {
      final uri = Uri.parse(imageUrl);
      final request = await httpClient.headUrl(uri);
      request.headers.add('User-Agent', 'Mozilla/5.0');
      final response = await request.close();
      await response.drain();

      if (response.statusCode >= 200 && response.statusCode < 400) {
        success++;
        // 진행 상황 표시 (50개마다)
        if (checked % 50 == 0) {
          print('✅ 진행: $checked/${travelSpots.length} (성공: $success, 실패: ${failedUrls.length})');
        }
      } else {
        print('❌ [$i] $name: HTTP ${response.statusCode}');
        failedUrls.add({
          'index': i,
          'name': name,
          'englishName': englishName,
          'imageUrl': imageUrl,
          'statusCode': response.statusCode,
        });
      }
    } catch (e) {
      final errorStr = e.toString();
      String errorType = 'Unknown';
      if (errorStr.contains('HandshakeException')) {
        errorType = 'SSL';
      } else if (errorStr.contains('SocketException')) {
        errorType = 'Network';
      } else if (errorStr.contains('TimeoutException')) {
        errorType = 'Timeout';
      }

      print('❌ [$i] $name: $errorType 오류');
      failedUrls.add({
        'index': i,
        'name': name,
        'englishName': englishName,
        'imageUrl': imageUrl,
        'error': errorStr,
      });
    }

    // Rate limiting 방지 (더 긴 딜레이)
    await Future.delayed(const Duration(milliseconds: 300));
  }

  httpClient.close();

  // 결과 저장
  if (failedUrls.isNotEmpty) {
    final failedFile = File('tmp/scripts/failed_urls_final.json');
    final encoder = const JsonEncoder.withIndent('    ');
    failedFile.writeAsStringSync(encoder.convert(failedUrls));
  }

  print('\n======================================');
  print('📊 결과 요약');
  print('======================================');
  print('✅ 검증 성공: $success개');
  print('❌ 검증 실패: ${failedUrls.length}개');
  print('📊 총 검증: $checked개');

  if (failedUrls.isNotEmpty) {
    print('\n📁 실패 URL 목록이 tmp/scripts/failed_urls_final.json에 저장되었습니다.');
  }
}
