// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 마지막 남은 문제 URL 4개를 수정하는 스크립트
///
/// - philippines.travel URL 2개 (SSL 오류)
/// - peakvisor.com URL 2개 (HTTP 403 오류)
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/fix_final_urls.dart
/// ```

// 마지막 남은 문제 URL 매핑 (한글 이름 -> Wikipedia 검색어)
final Map<String, String> finalMappings = {
  // philippines.travel SSL 오류
  '카몬테스 섬': 'Camotes_Islands',
  '로복 교회 및 수녀원': 'Loboc_Church',

  // peakvisor.com HTTP 403 오류
  '이바 산': 'Zambales_Mountains',
  '마운트 이리드': 'Rizal_(province)',
};

// 영문명 매핑 (영문 이름 -> Wikipedia 검색어)
final Map<String, String> englishMappings = {
  'Camotes Islands': 'Camotes_Islands',
  'Loboc Church and Convent': 'Loboc_Church',
  'Mount Iba': 'Zambales_Mountains',
  'Mount Irid': 'Rizal_(province)',
};

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 마지막 남은 문제 URL 수정 도구');
  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);

  // Wikipedia 이미지 캐시
  final Map<String, String?> imageCache = {};

  int updated = 0;
  int failed = 0;

  for (int i = 0; i < travelSpots.length; i++) {
    final spot = travelSpots[i];
    final name = spot['name']?.toString() ?? '';
    final englishName = spot['englishName']?.toString() ?? '';
    final currentUrl = spot['imageUrl']?.toString() ?? '';

    // 문제 도메인인지 확인
    if (!currentUrl.contains('philippines.travel') &&
        !currentUrl.contains('peakvisor.com')) {
      continue;
    }

    // Wikipedia 검색어 찾기 (한글명 또는 영문명으로)
    String? searchTerm = finalMappings[name];
    if (searchTerm == null) {
      // 영문명으로 시도
      for (final entry in englishMappings.entries) {
        if (englishName.contains(entry.key)) {
          searchTerm = entry.value;
          break;
        }
      }
    }

    if (searchTerm == null) {
      print('⏭️  [$i] $name: 매핑 없음');
      failed++;
      continue;
    }

    print('🔍 [$i] $name → $searchTerm');

    // 캐시 확인
    if (imageCache.containsKey(searchTerm)) {
      final cachedUrl = imageCache[searchTerm];
      if (cachedUrl != null) {
        travelSpots[i]['imageUrl'] = cachedUrl;
        print('   ✅ 캐시 사용: $cachedUrl');
        updated++;
        continue;
      } else {
        print('   ⚠️  캐시됨 (이미지 없음)');
        failed++;
        continue;
      }
    }

    // Wikipedia API로 이미지 URL 가져오기
    final apiUrl =
        'https://en.wikipedia.org/w/api.php?action=query&titles=$searchTerm&prop=pageimages&format=json&pithumbsize=800';

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
            if (await _validateImageUrl(httpClient, newImageUrl)) {
              imageCache[searchTerm] = newImageUrl;
              travelSpots[i]['imageUrl'] = newImageUrl;
              print('   ✅ 업데이트: $newImageUrl');
              updated++;
            } else {
              imageCache[searchTerm] = null;
              print('   ❌ 이미지 접근 불가');
              failed++;
            }
          } else {
            imageCache[searchTerm] = null;
            print('   ⚠️  Wikipedia에 이미지 없음');
            failed++;
          }
        } else {
          imageCache[searchTerm] = null;
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

/// 이미지 URL 유효성 검증
Future<bool> _validateImageUrl(HttpClient client, String url) async {
  try {
    final checkRequest = await client.headUrl(Uri.parse(url));
    checkRequest.headers.add('User-Agent', 'Mozilla/5.0');
    final checkResponse = await checkRequest.close();
    await checkResponse.drain();
    return checkResponse.statusCode >= 200 && checkResponse.statusCode < 400;
  } catch (e) {
    return false;
  }
}
