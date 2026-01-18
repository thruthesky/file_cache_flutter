// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 잘못된 thumb 경로 패턴을 가진 URL들을 수정하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/fix_invalid_thumb_urls.dart
/// ```

// 잘못된 thumb 경로를 가진 URL 인덱스와 대체 검색어 매핑
final Map<int, String> searchTerms = {
  570: 'Sagada', // 사그나 캐년
  571: 'Sagada', // 수메깅 동굴
  572: 'Sagada', // 키나코 폭포
  573: 'Hundred_Islands_National_Park', // 하우드레드 아일랜드
  574: 'Subic_Bay', // 수빅 베이
  578: 'Tagaytay', // 타가이타이
  579: 'Taal_Volcano', // 타알 화산
  580: 'Laguna_(province)', // 라구나 핫 스프링스
  581: 'Pagsanjan', // 파그산한 폭포
  582: 'Laguna_(province)', // 히든 밸리 스프링스
  583: 'Antequera,_Bohol', // 마요혼 폭포
  588: 'Intramuros', // 인트라무로스
  590: 'Rizal_Park', // 리잘 공원
  591: 'Manila_Ocean_Park', // 마닐라 오션파크
  592: 'San_Agustin_Church_(Manila)', // 산 아구스틴 성당
  593: 'Mayon_Volcano', // 마욘 화산
  598: 'Boracay', // 보라카이 푸카 비치
  601: 'Miagao_Church', // 일로일로 미아가오 교회
  602: 'Iloilo', // 기가테스 아일랜드
  603: 'Siquijor', // 시키호르 섬
  605: 'Siquijor', // 시키호르 사라그둥동 폭포
  610: 'Negros_Oriental', // 트윈 레이크스
  611: 'Talisay,_Negros_Occidental', // 바콜로드 더 루인스
  612: 'MassKara_Festival', // 바콜로드 마스카라 축제
  613: 'Sipalay', // 시파위 아일랜드
  614: 'Leyte_Gulf_landings', // 레이테 맥아더 상륙지
  615: 'San_Juanico_Bridge', // 레이테 산 후아니코 다리
  616: 'Sohoton_Natural_Bridge_National_Park', // 소호톤 동굴
  618: 'Moalboal', // 모알보알 페스카도르 섬
  620: 'Malapascua', // 말라파스쿠아 섬
  624: 'Panglao', // 힌나그다난 동굴
  625: 'Loboc,_Bohol', // 로복 강 크루즈
  627: 'Panglao', // 버진 아일랜드 샌드바
  628: 'Philippine_eagle', // 필리핀 독수리 센터
  629: 'Bohol', // 파밀라칸 아일랜드
  631: 'Battle_of_Mactan', // 라푸라푸 기념비
  632: 'Oslob,_Cebu', // 오슬롭 투말록 폭포
  633: 'Cebu_City', // 세부 탑스
  634: 'Cebu_City', // 시라오 가든
  636: 'Siargao', // 시얄가오 서핑
  637: 'Siargao', // 수그바 라군
  638: 'Siargao', // 막푸풍코 락풀
  639: 'Siargao', // 네이키드 아일랜드
  641: 'Siargao', // 구욤 아일랜드
  642: 'Siargao', // 타쿠탁 폭포
  643: 'Siargao', // 소조간 동굴
  645: 'Surigao_del_Sur', // 틱탁 폭포
  646: 'La_Union', // 라 우니온 서핑
  649: 'Pangasinan', // 푸구 비치
  654: 'Batanes', // 바타네스 롤링 힐스
  655: 'Batanes', // 바타네스 마를보로 컨트리
  656: 'Batanes', // 바타네스 혼노스비치
  657: 'Batanes', // 사부탕 아일랜드
  662: 'La_Union', // 탕카단 폭포
  663: 'Southern_Leyte', // 마아신 폭포
  665: 'Siquijor', // 라지 교회
  666: 'Camiguin', // 산 이시드로 수중 공원
  667: 'Camiguin', // 화이트 아일랜드 카미긴
  668: 'Camiguin', // 카티바왓 폭포
  670: 'Camiguin', // 오르드 동굴
  671: 'Camiguin', // 투멍스 폭포
  672: 'Camiguin', // 기오 바르도 유적
};

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 잘못된 thumb 경로 URL 수정 도구');
  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);

  // 이미지 캐시
  final Map<String, String?> imageCache = {};

  int updated = 0;
  int failed = 0;

  for (final entry in searchTerms.entries) {
    final index = entry.key;
    final searchTerm = entry.value;
    final name = travelSpots[index]['name']?.toString() ?? '';

    print('🔍 [$index] $name → $searchTerm');

    // 캐시 확인
    if (imageCache.containsKey(searchTerm)) {
      final cachedUrl = imageCache[searchTerm];
      if (cachedUrl != null) {
        travelSpots[index]['imageUrl'] = cachedUrl;
        print('   ✅ 캐시 사용');
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
            imageCache[searchTerm] = newImageUrl;
            travelSpots[index]['imageUrl'] = newImageUrl;
            print('   ✅ 업데이트: ${newImageUrl.substring(0, 60)}...');
            updated++;
          } else {
            imageCache[searchTerm] = null;
            print('   ⚠️  Wikipedia에 이미지 없음');
            failed++;
          }
        } else {
          imageCache[searchTerm] = null;
          print('   ⚠️  Wikipedia 페이지 없음');
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
    await Future.delayed(const Duration(milliseconds: 800));
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
