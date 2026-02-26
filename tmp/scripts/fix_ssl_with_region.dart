// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 남은 SSL 오류 URL들을 해당 지역의 대표 Wikipedia 이미지로 업데이트하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/fix_ssl_with_region.dart
/// ```

// philippines.travel 도메인의 URL을 가진 여행지와 해당 지역 매핑
final Map<String, String> regionMappings = {
  // Cebu 지역 (세부 관련)
  '아귀니드 폭포': 'Cebu',
  '만타유판 폭포': 'Cebu',
  '이남바칸 폭포': 'Cebu',
  '다오 폭포': 'Cebu',
  '카르카르 헤리티지 타운': 'Carcar',
  '올랑고 섬 야생동물 보호구역': 'Cebu',
  '카몬테스 섬': 'Camotes_Islands',
  '막탄 신사': 'Mactan',
  '테라자스 데 플로레스': 'Cebu',

  // Bohol 지역 (보홀 관련)
  '블러드 컴팩트 신사': 'Bohol',
  '캔 움안 폭포': 'Bohol',
  '마그 아소 폭포': 'Bohol',
  '두말루안 비치': 'Bohol',
  '보홀 비 팜': 'Bohol',
  '버진 아일랜드 팡라오': 'Bohol',
  '보홀 돌핀 와칭': 'Bohol',
  '파히 폭포': 'Bohol',
  '라용 캐년': 'Bohol',
  '다나오 어드벤처 파크': 'Bohol',
  '세콰이어 폭포': 'Bohol',
  '보홀 파이톤 야생동물 파크': 'Bohol',
  '버터플라이 가든 보홀': 'Bohol',
  '사캉 비치': 'Bohol',
  '사그바얀 피크': 'Chocolate_Hills',
  '클라린 물고기 보호구역': 'Bohol',
  '로복 교회 및 수녀원': 'Loboc,_Bohol',
  '보홀 뮤지엄': 'Bohol',
};

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  //  print('======================================');
  //  print('📋 SSL 오류 URL 지역 이미지 업데이트 도구');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);

  // Wikipedia 이미지 캐시 (같은 지역 검색 최소화)
  final Map<String, String?> imageCache = {};

  int updated = 0;
  int failed = 0;

  for (int i = 0; i < travelSpots.length; i++) {
    final spot = travelSpots[i];
    final name = spot['name']?.toString() ?? '';
    final currentUrl = spot['imageUrl']?.toString() ?? '';

    // philippines.travel URL인지 확인
    if (!currentUrl.contains('philippines.travel')) {
      continue;
    }

    // 지역 매핑 확인
    final region = regionMappings[name];
    if (region == null) {
      //      print('⏭️  [$i] $name: 지역 매핑 없음');
      failed++;
      continue;
    }

    //    print('🔍 [$i] $name → $region');

    // 캐시에서 이미지 URL 확인
    if (imageCache.containsKey(region)) {
      final cachedUrl = imageCache[region];
      if (cachedUrl != null) {
        travelSpots[i]['imageUrl'] = cachedUrl;
        //        print('   ✅ 캐시 사용: $cachedUrl');
        updated++;
        continue;
      } else {
        //        print('   ⚠️  캐시됨 (이미지 없음)');
        failed++;
        continue;
      }
    }

    // Wikipedia API로 이미지 URL 가져오기
    final apiUrl =
        'https://en.wikipedia.org/w/api.php?action=query&titles=$region&prop=pageimages&format=json&pithumbsize=800';

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
              imageCache[region] = newImageUrl;
              travelSpots[i]['imageUrl'] = newImageUrl;
              //              print('   ✅ 업데이트: $newImageUrl');
              updated++;
            } else {
              imageCache[region] = null;
              //              print('   ❌ 이미지 접근 불가');
              failed++;
            }
          } else {
            imageCache[region] = null;
            //            print('   ⚠️  Wikipedia에 이미지 없음');
            failed++;
          }
        } else {
          imageCache[region] = null;
          //          print('   ⚠️  Wikipedia 페이지를 찾을 수 없음');
          failed++;
        }
      } else {
        //        print('   ❌ API 호출 실패: HTTP ${response.statusCode}');
        failed++;
      }
    } catch (e) {
      //      print('   ❌ 오류: $e');
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

  //  print('\n======================================');
  //  print('📊 결과 요약');
  //  print('======================================');
  //  print('✅ 업데이트 성공: $updated개');
  //  print('❌ 업데이트 실패: $failed개');
  //  print('\n📁 $jsonFilePath 파일이 수정되었습니다.');
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
