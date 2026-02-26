// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// HTTP 404 오류 URL들을 해당 지역의 대표 Wikipedia 이미지로 업데이트하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/fix_404_with_region.dart
/// ```

// 404 오류가 있는 URL의 지역 매핑
final Map<String, String> regionMappings = {
  // El Nido 관련
  '엘니도 빅 라군': 'El_Nido,_Palawan',
  '엘니도 스몰 라군': 'El_Nido,_Palawan',
  '엘니도 시크릿 라군': 'El_Nido,_Palawan',
  '세븐 코만도스 비치': 'El_Nido,_Palawan',
  '시미즈 아일랜드': 'El_Nido,_Palawan',
  '마틴록 아일랜드': 'El_Nido,_Palawan',
  '타라우 클리프': 'El_Nido,_Palawan',
  '나크판 비치': 'El_Nido,_Palawan',
  '라스 카바냐스 비치': 'El_Nido,_Palawan',

  // Coron 관련
  '코론 카양안 호수': 'Kayangan_Lake',

  // Palawan 관련
  '혼다 베이': 'Puerto_Princesa',
  '스타피쉬 아일랜드': 'Puerto_Princesa',
  '루리 아일랜드': 'Puerto_Princesa',
  '판단 아일랜드': 'Puerto_Princesa',
  '카우리 아일랜드': 'Puerto_Princesa',
  '사방 비치': 'Puerto_Princesa',
  '나그타본 비치': 'Puerto_Princesa',
  '베이커스 힐': 'Puerto_Princesa',
  '팔라완 야생동물 보호센터': 'Puerto_Princesa',
  '포트 바튼': 'Palawan',

  // Ilocos 지역
  '비간 역사 도시': 'Vigan',
  '라와그 파오아이 교회': 'Paoay_Church',
  '파가드푸란 모래 언덕': 'Ilocos_Norte',

  // Cordillera 지역
  '방가이 폭포': 'Sagada',
  '카블레토그 폭포': 'Sagada',
  '바타드 라이스 테라스': 'Banaue_Rice_Terraces',
  '바나우에 라이스 테라스': 'Banaue_Rice_Terraces',

  // 기타 지역
  '리오 툭바탄가 폭포': 'Puerto_Princesa',
  '산 비센테 롱 비치': 'San_Vicente,_Palawan',
  '타본 동굴': 'Palawan',
};

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  //  print('======================================');
  //  print('📋 HTTP 404 URL 지역 이미지 업데이트 도구');
  //  print('======================================\n');

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

    // 지역 매핑이 있는 경우만 처리
    final region = regionMappings[name];
    if (region == null) {
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
