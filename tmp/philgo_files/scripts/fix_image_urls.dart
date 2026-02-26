// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// 무효한 이미지 URL을 Wikipedia API로 자동 수정하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run lib/philgo_files/scripts/fix_image_urls.dart
/// dart run lib/philgo_files/scripts/fix_image_urls.dart --dry-run
/// ```

/// JSON 파일 경로
const String jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

/// 실패한 URL 목록 파일 경로
const String failedUrlsPath = 'lib/philgo_files/scripts/failed_image_urls.json';

/// 기본 이미지 URL (검색 실패 시 사용)
const String defaultImageUrl =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Flag_of_the_Philippines.svg/800px-Flag_of_the_Philippines.svg.png';

/// 지역별 기본 이미지 URL
const Map<String, String> regionDefaultImages = {
  'Palawan':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/El_Nido_viewpoint.jpg/800px-El_Nido_viewpoint.jpg',
  'Cebu':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Cebu_Taoist_Temple.jpg/800px-Cebu_Taoist_Temple.jpg',
  'Bohol':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Bohol_Chocolate_Hills.jpg/800px-Bohol_Chocolate_Hills.jpg',
  'Boracay':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Boracay_White_Beach.jpg/800px-Boracay_White_Beach.jpg',
  'Metro Manila':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Makati_skyline_%28Poblacion%2C_Makati%29%28from_The_Stratosphere%29.jpg/800px-Makati_skyline_%28Poblacion%2C_Makati%29%28from_The_Stratosphere%29.jpg',
};

void main(List<String> args) async {
  //  print('======================================');
  //  print('🔧 이미지 URL 자동 수정 도구');
  //  print('======================================\n');

  // dry-run 모드 체크
  final isDryRun = args.contains('--dry-run');
  if (isDryRun) {
    //    print('🔍 Dry-run 모드: 실제 수정 없이 미리보기만 수행합니다.\n');
  }

  // 실패한 URL 목록 파일 확인
  final failedUrlsFile = File(failedUrlsPath);
  if (!failedUrlsFile.existsSync()) {
    //    print('⚠️  실패한 URL 목록 파일이 없습니다.');
    //    print('   먼저 check_image_urls.dart를 실행하세요:');
    //    print('   dart run lib/philgo_files/scripts/check_image_urls.dart');
    exit(1);
  }

  // 실패한 URL 목록 읽기
  final failedUrlsJson = failedUrlsFile.readAsStringSync();
  final List<dynamic> failedUrls = jsonDecode(failedUrlsJson);

  if (failedUrls.isEmpty) {
    //    print('✅ 수정할 URL이 없습니다. 모든 URL이 유효합니다.');
    exit(0);
  }

  //  print('📋 수정 대상: ${failedUrls.length}개\n');

  // JSON 파일 읽기
  final jsonFile = File(jsonFilePath);
  final jsonString = jsonFile.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 10);

  int fixedCount = 0;
  int failedCount = 0;

  for (final failedItem in failedUrls) {
    final index = failedItem['index'] as int;
    final name = failedItem['name']?.toString() ?? '';
    final englishName = failedItem['englishName']?.toString() ?? '';

    //    print('🔍 [$index] $name 처리 중...');

    // Wikipedia API로 이미지 검색
    String? newImageUrl;

    try {
      // 영문 이름으로 검색
      final searchTerm = englishName.isNotEmpty
          ? englishName.replaceAll(' ', '_')
          : name.replaceAll(' ', '_');

      final apiUrl = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&titles=$searchTerm&prop=pageimages&format=json&pithumbsize=800',
      );

      final request = await httpClient.getUrl(apiUrl);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);

      final pages = data['query']['pages'] as Map<String, dynamic>;
      for (final page in pages.values) {
        if (page['thumbnail'] != null) {
          newImageUrl = page['thumbnail']['source'];
          break;
        }
      }
    } catch (e) {
      //      print('   ⚠️  Wikipedia API 검색 실패: $e');
    }

    // 검색 실패 시 지역별 기본 이미지 사용
    if (newImageUrl == null || newImageUrl.isEmpty) {
      final province = travelSpots[index]['province']?.toString() ?? '';
      newImageUrl = regionDefaultImages[province] ?? defaultImageUrl;
      //      print('   📷 기본 이미지 사용 ($province)');
    } else {
      //      print('   ✅ Wikipedia 이미지 발견');
    }

    // 이미지 URL 업데이트
    if (!isDryRun) {
      travelSpots[index]['imageUrl'] = newImageUrl;
      fixedCount++;
    } else {
      //      print('   🔗 새 URL: $newImageUrl');
      fixedCount++;
    }

    // Rate limiting
    await Future.delayed(const Duration(milliseconds: 500));
  }

  httpClient.close();

  // JSON 파일 저장 (dry-run이 아닌 경우)
  if (!isDryRun) {
    final encoder = const JsonEncoder.withIndent('    ');
    final updatedJsonString = encoder.convert(travelSpots);
    jsonFile.writeAsStringSync(updatedJsonString);

    //    print('\n======================================');
    //    print('📊 수정 결과');
    //    print('======================================');
    //    print('  ✅ 수정 완료: $fixedCount개');
    //    print('  ❌ 수정 실패: $failedCount개');
    //    print('\n📁 $jsonFilePath 파일이 업데이트되었습니다.');
  } else {
    //    print('\n======================================');
    //    print('📊 Dry-run 결과 (미리보기)');
    //    print('======================================');
    //    print('  🔍 수정 예정: $fixedCount개');
    //    print('\n💡 실제 수정하려면 --dry-run 옵션 없이 실행하세요.');
  }

  //  print('======================================');
}
