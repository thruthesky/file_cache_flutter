// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 7: 시키호르/네그로스 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch7_siquijor.dart
/// ```

// 시키호르/네그로스 지역 여행지 데이터
final List<Map<String, dynamic>> batch7Spots = [
  // 시키호르 섬
  {
    'name': '시키호르 섬',
    'englishName': 'Siquijor Island',
    'searchTerm': 'Siquijor',
    'title': '신비의 섬',
    'description': '신비로운 분위기와 마법사 전설로 유명한 작은 섬입니다.',
    'city': 'Siquijor',
    'province': 'Siquijor',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '살라그도옹 비치',
    'englishName': 'Salagdoong Beach',
    'searchTerm': 'Siquijor',
    'title': '절벽 점프 명소',
    'description': '시키호르의 아름다운 해변으로 절벽 다이빙으로 유명합니다.',
    'city': 'Maria',
    'province': 'Siquijor',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '캄바가호 폭포',
    'englishName': 'Cambugahay Falls',
    'searchTerm': 'Cambugahay_Falls',
    'title': '3단 폭포',
    'description': '시키호르의 대표적인 3단 폭포로 타잔 스윙이 유명합니다.',
    'city': 'Lazi',
    'province': 'Siquijor',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '팔리톤 비치',
    'englishName': 'Paliton Beach',
    'searchTerm': 'Siquijor',
    'title': '일몰 해변',
    'description': '시키호르 서쪽의 아름다운 해변으로 일몰이 유명합니다.',
    'city': 'San Juan',
    'province': 'Siquijor',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '산 후안 비치',
    'englishName': 'San Juan Beach',
    'searchTerm': 'Siquijor',
    'title': '시키호르 메인 비치',
    'description': '시키호르에서 가장 인기 있는 해변 구역입니다.',
    'city': 'San Juan',
    'province': 'Siquijor',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '라지 수도원',
    'englishName': 'Lazi Convent',
    'searchTerm': 'Lazi,_Siquijor',
    'title': '역사적 수도원',
    'description': '아시아에서 가장 큰 수도원 중 하나로 역사적 건물입니다.',
    'city': 'Lazi',
    'province': 'Siquijor',
    'icon': 'church',
    'category': '자연',
  },
  {
    'name': '올드 인챈티드 바오밥 트리',
    'englishName': 'Old Enchanted Balete Tree',
    'searchTerm': 'Siquijor',
    'title': '400년 된 나무',
    'description': '신비로운 분위기의 고대 바오밥 나무로 물고기 스파가 있습니다.',
    'city': 'Lazi',
    'province': 'Siquijor',
    'icon': 'tree',
    'category': '자연',
  },
  {
    'name': '칸팔리안 폭포',
    'englishName': 'Cantabon Cave',
    'searchTerm': 'Siquijor',
    'title': '동굴 탐험',
    'description': '시키호르의 석회암 동굴로 탐험이 가능합니다.',
    'city': 'San Juan',
    'province': 'Siquijor',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '루그나손 폭포',
    'englishName': 'Lugnason Falls',
    'searchTerm': 'Siquijor',
    'title': '숨겨진 폭포',
    'description': '시키호르의 작은 폭포로 한적합니다.',
    'city': 'San Juan',
    'province': 'Siquijor',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '투블로드 비치',
    'englishName': 'Tubod Beach',
    'searchTerm': 'Siquijor',
    'title': '담수 해변',
    'description': '담수 스프링이 바다로 흘러드는 독특한 해변입니다.',
    'city': 'San Juan',
    'province': 'Siquijor',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '시키호르 피어',
    'englishName': 'Siquijor Pier',
    'searchTerm': 'Siquijor',
    'title': '선셋 포인트',
    'description': '시키호르 항구로 일몰 사진 명소입니다.',
    'city': 'Siquijor',
    'province': 'Siquijor',
    'icon': 'pier',
    'category': '자연',
  },

  // 네그로스 오리엔탈
  {
    'name': '두마게테',
    'englishName': 'Dumaguete',
    'searchTerm': 'Dumaguete',
    'title': '온화한 사람들의 도시',
    'description': '네그로스 오리엔탈의 주도로 대학 도시이자 다이빙 허브입니다.',
    'city': 'Dumaguete',
    'province': 'Negros Oriental',
    'icon': 'city',
    'category': '자연',
  },
  {
    'name': '리자르 블러바드',
    'englishName': 'Rizal Boulevard',
    'searchTerm': 'Dumaguete',
    'title': '해안 산책로',
    'description': '두마게테의 대표적인 해안 산책로로 레스토랑이 즐비합니다.',
    'city': 'Dumaguete',
    'province': 'Negros Oriental',
    'icon': 'promenade',
    'category': '자연',
  },
  {
    'name': '다우인 비치',
    'englishName': 'Dauin Beach',
    'searchTerm': 'Dauin',
    'title': '다이빙 천국',
    'description': '마크로 다이빙으로 유명한 해변으로 희귀 해양 생물이 많습니다.',
    'city': 'Dauin',
    'province': 'Negros Oriental',
    'icon': 'diving',
    'category': '해변',
  },
  {
    'name': '쌍둥이 호수 발린사사야오',
    'englishName': 'Twin Lakes Balinsasayao',
    'searchTerm': 'Lake_Balinsasayao',
    'title': '산 속 쌍둥이 호수',
    'description': '네그로스 고지대의 화산 호수로 카약과 하이킹이 가능합니다.',
    'city': 'Sibulan',
    'province': 'Negros Oriental',
    'icon': 'lake',
    'category': '자연',
  },
  {
    'name': '카사로로 폭포',
    'englishName': 'Casaroro Falls',
    'searchTerm': 'Casaroro_Falls',
    'title': '웅장한 폭포',
    'description': '발렌시아의 웅장한 폭포로 트레킹이 필요합니다.',
    'city': 'Valencia',
    'province': 'Negros Oriental',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '풀랑바토 폭포',
    'englishName': 'Pulangbato Falls',
    'searchTerm': 'Valencia,_Negros_Oriental',
    'title': '붉은 바위 폭포',
    'description': '붉은색 바위가 특징인 발렌시아의 아름다운 폭포입니다.',
    'city': 'Valencia',
    'province': 'Negros Oriental',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '마사플로드 네이처 파크',
    'englishName': 'Malatapay Market',
    'searchTerm': 'Zamboanguita',
    'title': '수요 시장',
    'description': '잠보앙기타의 전통 수요 시장으로 현지 문화를 체험할 수 있습니다.',
    'city': 'Zamboanguita',
    'province': 'Negros Oriental',
    'icon': 'market',
    'category': '자연',
  },

  // 네그로스 옥시덴탈
  {
    'name': '바콜로드 시티',
    'englishName': 'Bacolod City',
    'searchTerm': 'Bacolod',
    'title': '미소의 도시',
    'description': '네그로스 옥시덴탈의 주도로 마스카라 축제로 유명합니다.',
    'city': 'Bacolod',
    'province': 'Negros Occidental',
    'icon': 'city',
    'category': '자연',
  },
  {
    'name': '라카와안 섬',
    'englishName': 'Lakawon Island',
    'searchTerm': 'Cadiz,_Negros_Occidental',
    'title': '화이트 비치',
    'description': '카디즈 근처의 아름다운 섬으로 플로팅 바가 유명합니다.',
    'city': 'Cadiz',
    'province': 'Negros Occidental',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '더 루인스',
    'englishName': 'The Ruins',
    'searchTerm': 'The_Ruins_(Talisay,_Philippines)',
    'title': '필리핀의 타지마할',
    'description': '불타버린 대저택 유적으로 로맨틱한 분위기가 있습니다.',
    'city': 'Talisay',
    'province': 'Negros Occidental',
    'icon': 'ruins',
    'category': '자연',
  },
  {
    'name': '시파와이 섬',
    'englishName': 'Sipaway Island',
    'searchTerm': 'San_Carlos,_Negros_Occidental',
    'title': '프라이빗 섬',
    'description': '산카를로스 근처의 작은 섬으로 스노클링이 좋습니다.',
    'city': 'San Carlos',
    'province': 'Negros Occidental',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '마부카이 고래상어',
    'englishName': 'Mabucay Whale Sharks',
    'searchTerm': 'Negros_Occidental',
    'title': '고래상어 포인트',
    'description': '네그로스 옥시덴탈에서 고래상어를 볼 수 있는 곳입니다.',
    'city': 'Tan-awan',
    'province': 'Negros Occidental',
    'icon': 'whale',
    'category': '수상스포츠',
  },
  {
    'name': '시라오 섬',
    'englishName': 'Suyac Island',
    'searchTerm': 'Sagay,_Negros_Occidental',
    'title': '맹그로브 에코 파크',
    'description': '사가이의 작은 섬으로 맹그로브 생태계를 체험할 수 있습니다.',
    'city': 'Sagay',
    'province': 'Negros Occidental',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '캄팔라스 폭포',
    'englishName': 'Camplas Falls',
    'searchTerm': 'Negros_Occidental',
    'title': '네그로스 폭포',
    'description': '네그로스 내륙의 아름다운 폭포입니다.',
    'city': 'Murcia',
    'province': 'Negros Occidental',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '마그소호트 스프링',
    'englishName': 'Mag-sohot Spring',
    'searchTerm': 'Negros_Occidental',
    'title': '천연 수영장',
    'description': '네그로스의 천연 온천 스프링입니다.',
    'city': 'Negros Occidental',
    'province': 'Negros Occidental',
    'icon': 'spring',
    'category': '자연',
  },

  // 추가 시키호르/네그로스 명소
  {
    'name': '수밀론 아일랜드 호핑',
    'englishName': 'Siquijor Island Hopping',
    'searchTerm': 'Siquijor',
    'title': '섬 투어',
    'description': '시키호르 주변의 작은 섬들을 돌아보는 투어입니다.',
    'city': 'Siquijor',
    'province': 'Siquijor',
    'icon': 'boat',
    'category': '섬',
  },
  {
    'name': '시키호르 스노클링',
    'englishName': 'Siquijor Snorkeling',
    'searchTerm': 'Siquijor',
    'title': '스노클링 포인트',
    'description': '시키호르 해안의 스노클링 명소들입니다.',
    'city': 'San Juan',
    'province': 'Siquijor',
    'icon': 'snorkeling',
    'category': '수상스포츠',
  },
  {
    'name': '시키호르 반딧불이 투어',
    'englishName': 'Siquijor Firefly Watching',
    'searchTerm': 'Siquijor',
    'title': '반딧불이 투어',
    'description': '시키호르에서 밤에 즐기는 반딧불이 관찰 투어입니다.',
    'city': 'Siquijor',
    'province': 'Siquijor',
    'icon': 'firefly',
    'category': '자연',
  },
  {
    'name': '네그로스 다이빙',
    'englishName': 'Negros Diving',
    'searchTerm': 'Dumaguete',
    'title': '다이빙 투어',
    'description': '네그로스 오리엔탈의 다이빙 포인트 투어입니다.',
    'city': 'Dumaguete',
    'province': 'Negros Oriental',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '람보안 폭포',
    'englishName': 'Lamboan Falls',
    'searchTerm': 'Siquijor',
    'title': '시키호르 폭포',
    'description': '시키호르의 또 다른 아름다운 폭포입니다.',
    'city': 'Lazi',
    'province': 'Siquijor',
    'icon': 'waterfall',
    'category': '자연',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  //  print('======================================');
  //  print('📋 배치 7: 시키호르/네그로스 지역 여행지 추가');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  //  print('📊 현재 여행지 개수: ${travelSpots.length}개\n');

  // 기존 이름 목록 (중복 체크용)
  final existingNames = travelSpots
      .map((spot) => (spot['name']?.toString() ?? '').toLowerCase())
      .toSet();

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 10);

  int added = 0;
  int skipped = 0;

  for (final spot in batch7Spots) {
    final name = spot['name'] as String;

    // 중복 체크
    if (existingNames.contains(name.toLowerCase())) {
      //      print('⏭️  건너뜀 (중복): $name');
      skipped++;
      continue;
    }

    // Wikipedia에서 이미지 URL 가져오기
    String imageUrl = '';
    final searchTerm = spot['searchTerm'] as String;

    try {
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
          imageUrl = page['thumbnail']['source'] ?? '';
          break;
        }
      }
    } catch (e) {
      //      print('⚠️  이미지 검색 실패: $name - $e');
    }

    // 이미지가 없으면 기본 시키호르 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl =
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Ph_locator_siquijor.png/800px-Ph_locator_siquijor.png';
    }

    // 새 여행지 추가
    final newSpot = {
      'name': name,
      'english name': spot['englishName'],
      'title': spot['title'],
      'description': spot['description'],
      'city': spot['city'],
      'province': spot['province'],
      'icon': spot['icon'],
      'category': spot['category'],
      'imageUrl': imageUrl,
      'texts': <String>[],
    };

    travelSpots.add(newSpot);
    existingNames.add(name.toLowerCase());
    added++;
    //    print('✅ 추가됨: $name');

    // Rate limiting
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // JSON 파일 저장
  final encoder = const JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(travelSpots);
  file.writeAsStringSync(updatedJsonString);

  httpClient.close();

  //  print('\n======================================');
  //  print('📊 배치 7 결과 요약');
  //  print('======================================');
  //  print('✅ 추가됨: $added개');
  //  print('⏭️  건너뜀: $skipped개');
  //  print('📊 현재 총 개수: ${travelSpots.length}개');
}
