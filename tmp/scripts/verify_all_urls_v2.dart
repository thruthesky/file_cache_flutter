// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 모든 imageUrl의 유효성을 검증하는 스크립트 (Rate Limiting 방지)
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/verify_all_urls_v2.dart
/// ```

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 전체 이미지 URL 검증 도구 v2');
  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);

  final List<Map<String, dynamic>> failedUrls = [];
  int checked = 0;
  int success = 0;

  for (int i = 0; i < travelSpots.length; i++) {
    final spot = travelSpots[i];
    final name = spot['name']?.toString() ?? '';
    final englishName = spot['englishName']?.toString() ?? spot['english name']?.toString() ?? '';
    final imageUrl = spot['imageUrl']?.toString() ?? '';

    if (imageUrl.isEmpty) {
      continue;
    }

    checked++;

    // 진행 상황 표시
    if (checked % 20 == 0) {
      print('⏳ 진행: $checked/${travelSpots.length}...');
    }

    // 최대 3번 재시도
    int retryCount = 0;
    bool isSuccess = false;
    int lastStatusCode = 0;
    String lastError = '';

    while (retryCount < 3 && !isSuccess) {
      try {
        final uri = Uri.parse(imageUrl);
        final request = await httpClient.headUrl(uri);
        request.headers.add('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36');
        final response = await request.close();
        await response.drain();
        lastStatusCode = response.statusCode;

        if (response.statusCode >= 200 && response.statusCode < 400) {
          isSuccess = true;
          success++;
        } else if (response.statusCode == 429) {
          // Rate Limited - 더 긴 대기 후 재시도
          retryCount++;
          if (retryCount < 3) {
            await Future.delayed(Duration(seconds: 3 * retryCount));
          }
        } else {
          // 다른 오류 (404, 403 등)
          break;
        }
      } catch (e) {
        lastError = e.toString();
        retryCount++;
        if (retryCount < 3) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    if (!isSuccess) {
      print('❌ [$i] $name: ${lastStatusCode > 0 ? "HTTP $lastStatusCode" : lastError.split(":").first}');
      failedUrls.add({
        'index': i,
        'name': name,
        'englishName': englishName,
        'imageUrl': imageUrl,
        'statusCode': lastStatusCode,
        'error': lastError,
      });
    }

    // Rate limiting 방지 - 1초 대기
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  httpClient.close();

  // 결과 저장
  if (failedUrls.isNotEmpty) {
    final failedFile = File('tmp/scripts/failed_urls_v2.json');
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
    print('\n📁 실패 URL 목록이 tmp/scripts/failed_urls_v2.json에 저장되었습니다.');

    // 오류 유형별 분류
    final http404 = failedUrls.where((e) => e['statusCode'] == 404).length;
    final http429 = failedUrls.where((e) => e['statusCode'] == 429).length;
    final http403 = failedUrls.where((e) => e['statusCode'] == 403).length;
    final sslErrors = failedUrls.where((e) => (e['error'] as String).contains('Handshake')).length;
    final others = failedUrls.length - http404 - http429 - http403 - sslErrors;

    print('\n📊 오류 유형별 분류:');
    if (http404 > 0) print('   HTTP 404: $http404개');
    if (http429 > 0) print('   HTTP 429 (Rate Limit): $http429개');
    if (http403 > 0) print('   HTTP 403: $http403개');
    if (sslErrors > 0) print('   SSL 오류: $sslErrors개');
    if (others > 0) print('   기타: $others개');
  }
}
