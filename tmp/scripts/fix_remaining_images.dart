// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 남은 실패 이미지 URL을 수정하는 스크립트
///
/// 특정 패턴의 관광지에 대해 더 스마트한 검색을 수행합니다:
/// - El Nido 관련 → El Nido 메인 이미지 사용
/// - Coron 관련 → Coron 메인 이미지 사용
/// - 폭포, 비치 등 → 지역 이름으로 검색
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/fix_remaining_images.dart
/// ```

// 대체 이미지 매핑 (영문명 키워드 -> Wikipedia 검색어)
final Map<String, String> alternativeSearchTerms = {
  // El Nido 관련
  'El Nido': 'El_Nido,_Palawan',
  'Big Lagoon': 'El_Nido,_Palawan',
  'Small Lagoon': 'El_Nido,_Palawan',
  'Secret Lagoon': 'El_Nido,_Palawan',
  'Seven Commandos': 'El_Nido,_Palawan',
  'Shimizu Island': 'El_Nido,_Palawan',
  'Matinloc': 'El_Nido,_Palawan',
  'Taraw Cliff': 'El_Nido,_Palawan',
  'Nacpan': 'El_Nido,_Palawan',
  'Las Cabanas': 'El_Nido,_Palawan',

  // Coron 관련
  'Coron': 'Coron,_Palawan',
  'Kayangan': 'Kayangan_Lake',
  'Barracuda Lake': 'Coron,_Palawan',
  'Twin Lagoon': 'Coron,_Palawan',
  'Maquinit': 'Coron,_Palawan',
  'Malcapuya': 'Coron,_Palawan',
  'Skeleton Wreck': 'Coron,_Palawan',
  'Irako': 'Coron,_Palawan',
  'Banana Island': 'Coron,_Palawan',

  // Bohol 관련
  'Moalboal': 'Moalboal',
  'Sardine Run': 'Moalboal',
  'Aguinid': 'Samboan,_Cebu',
  'Mantayupan': 'Barili,_Cebu',
  'Inambakan': 'Ginatilan,_Cebu',
  'Dao Falls': 'Samboan,_Cebu',
  'Carcar': 'Carcar,_Cebu',
  'Olango': 'Olango_Island',
  'Mactan Guitar': 'Mactan',
  'Yap-Sandiego': 'Cebu_City',
  'Jesuit House': 'Cebu_City',
  'San Remigio': 'San_Remigio,_Cebu',
  'Camotes': 'Camotes_Islands',
  'Crown Regency': 'Cebu_City',
  'Mactan Shrine': 'Battle_of_Mactan',
  'Fuente Osmeña': 'Cebu_City',
  'Plaza Independencia': 'Fort_San_Pedro',
  'Terrazas de Flores': 'Busay,_Cebu_City',
  'Boding Beach': 'Cebu',
  'Tingko Beach': 'Alcoy,_Cebu',
  'Moalboal White Beach': 'Moalboal',
  'Bantayan': 'Bantayan_Island',
  'Cebu Heritage Monument': 'Cebu_City',
  'Tarsier': 'Philippine_tarsier',
  'Man-Made Forest': 'Bilar,_Bohol',
  'Blood Compact': 'Blood_compact_(Philippines)',
  'Anda Beach': 'Anda,_Bohol',
  'Can-umantad': 'Candijay,_Bohol',
  'Mag-Aso': 'Antequera,_Bohol',
  'Dumaluan': 'Panglao',
  'Bohol Bee Farm': 'Panglao',
  'Virgin Island Panglao': 'Panglao',
  'Cabilao': 'Cabilao',
  'Dolphin Watching': 'Bohol',
  'Pahintad': 'Bohol',
  'Laong Canyon': 'Danao,_Bohol',
  'Danao Adventure': 'Danao,_Bohol',
  'Sekway': 'Dimiao,_Bohol',
  'Python': 'Bohol',
  'Butterfly': 'Bohol',
  'Sagang': 'Sagbayan,_Bohol',
  'Sagbayan Peak': 'Sagbayan,_Bohol',
  'Clarin': 'Clarin,_Bohol',
  'Quinale': 'Anda,_Bohol',
  'Tagbilaran Cathedral': 'Tagbilaran',
  'Loboc Church': 'Loboc,_Bohol',
  'Bohol Museum': 'Tagbilaran',

  // Puerto Princesa 관련
  'Puerto Princesa': 'Puerto_Princesa_Subterranean_River_National_Park',
  'Underground River': 'Puerto_Princesa_Subterranean_River_National_Park',

  // 산악 지역
  'Imbing': 'Benguet',
  'Imoc': 'Mountain_Province',
};

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';
  final failedUrlsPath = 'lib/philgo_files/scripts/real_failed_image_urls.json';

  //  print('======================================');
  //  print('📋 남은 실패 이미지 URL 수정 도구');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  // 실패한 URL 다시 읽기
  final failedFile = File(failedUrlsPath);
  final failedJsonString = failedFile.readAsStringSync();
  final List<dynamic> failedUrls = jsonDecode(failedJsonString);

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);

  int updated = 0;
  int failed = 0;

  // 이미 처리된 인덱스 추적
  final Set<int> processedIndices = {};

  for (final item in failedUrls) {
    final index = item['index'] as int;
    final englishName = item['englishName']?.toString() ?? '';
    final name = item['name']?.toString() ?? '';
    final error = item['error']?.toString() ?? '';

    // 이미 현재 URL이 유효한지 확인
    final currentUrl = travelSpots[index]['imageUrl']?.toString() ?? '';
    if (currentUrl.isNotEmpty &&
        !currentUrl.contains('philippines.travel') &&
        !currentUrl.contains('peakvisor.com')) {
      // 현재 URL 유효성 검사
      final isValid = await _validateImageUrl(httpClient, currentUrl);
      if (isValid) {
        //        print('⏭️  [$index] $name: 이미 유효한 URL');
        processedIndices.add(index);
        continue;
      }
    }

    // 대체 검색어 찾기
    String? searchTerm;
    for (final entry in alternativeSearchTerms.entries) {
      if (englishName.contains(entry.key)) {
        searchTerm = entry.value;
        break;
      }
    }

    if (searchTerm == null) {
      //      print('⏭️  [$index] $name: 대체 검색어 없음');
      failed++;
      continue;
    }

    //    print('🔍 [$index] $name → $searchTerm');

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

            if (await _validateImageUrl(httpClient, newImageUrl)) {
              travelSpots[index]['imageUrl'] = newImageUrl;
              //              print('   ✅ 업데이트: $newImageUrl');
              updated++;
            } else {
              //              print('   ❌ 이미지 접근 불가');
              failed++;
            }
          } else {
            //            print('   ⚠️  Wikipedia에 이미지 없음');
            failed++;
          }
        } else {
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
