// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 6: 보라카이/아클란 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch6_boracay.dart
/// ```

// 보라카이/아클란 지역 여행지 데이터
final List<Map<String, dynamic>> batch6Spots = [
  // 보라카이 해변들
  {
    'name': '화이트 비치',
    'englishName': 'White Beach Boracay',
    'searchTerm': 'White_Beach_(Boracay)',
    'title': '세계적인 백사장',
    'description': '보라카이의 대표적인 4km 길이의 하얀 모래 해변입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '스테이션 1',
    'englishName': 'Station 1 Boracay',
    'searchTerm': 'Boracay',
    'title': '프리미엄 구역',
    'description': '화이트 비치의 북쪽 구역으로 고급 리조트가 밀집해 있습니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '스테이션 2',
    'englishName': 'Station 2 Boracay',
    'searchTerm': 'Boracay',
    'title': '보라카이 중심가',
    'description': '화이트 비치의 중앙 구역으로 상점과 레스토랑이 많습니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '스테이션 3',
    'englishName': 'Station 3 Boracay',
    'searchTerm': 'Boracay',
    'title': '배낭여행자 구역',
    'description': '화이트 비치의 남쪽 구역으로 저렴한 숙소가 많습니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '디니위드 비치',
    'englishName': 'Diniwid Beach',
    'searchTerm': 'Boracay',
    'title': '숨겨진 해변',
    'description': '화이트 비치 북쪽의 조용하고 아름다운 해변입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '불라봉 비치',
    'englishName': 'Bulabog Beach',
    'searchTerm': 'Boracay',
    'title': '카이트서핑 메카',
    'description': '화이트 비치 반대편에 위치한 카이트서핑과 윈드서핑의 명소입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'kite',
    'category': '수상스포츠',
  },
  {
    'name': '푸카 쉘 비치',
    'englishName': 'Puka Shell Beach',
    'searchTerm': 'Boracay',
    'title': '조개껍질 해변',
    'description': '보라카이 북쪽의 자연 그대로의 해변으로 푸카 조개로 유명합니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '일리그일리간 비치',
    'englishName': 'Ilig-Iligan Beach',
    'searchTerm': 'Boracay',
    'title': '바위 해변',
    'description': '보라카이 북동쪽의 한적한 해변으로 바위 풍경이 특징입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '크리스탈 코브 섬',
    'englishName': 'Crystal Cove Island',
    'searchTerm': 'Boracay',
    'title': '동굴 탐험 섬',
    'description': '보라카이 근처의 작은 섬으로 동굴 탐험이 가능합니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '크로코다일 섬',
    'englishName': 'Crocodile Island',
    'searchTerm': 'Boracay',
    'title': '스노클링 포인트',
    'description': '악어 모양의 섬으로 다이빙과 스노클링 명소입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'snorkeling',
    'category': '섬',
  },

  // 보라카이 액티비티
  {
    'name': '보라카이 파라세일링',
    'englishName': 'Boracay Parasailing',
    'searchTerm': 'Parasailing',
    'title': '하늘에서 보는 보라카이',
    'description': '보라카이 해변 위를 날며 전경을 감상하는 액티비티입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'parasailing',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 헬멧 다이빙',
    'englishName': 'Boracay Helmet Diving',
    'searchTerm': 'Boracay',
    'title': '해저 걷기 체험',
    'description': '헬멧을 쓰고 바닷속을 걸으며 물고기를 볼 수 있는 체험입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 아일랜드 호핑',
    'englishName': 'Boracay Island Hopping',
    'searchTerm': 'Boracay',
    'title': '섬 투어',
    'description': '보라카이 주변 섬들을 돌아보는 인기 투어입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'boat',
    'category': '섬',
  },
  {
    'name': '보라카이 스쿠버 다이빙',
    'englishName': 'Boracay Scuba Diving',
    'searchTerm': 'Boracay',
    'title': '다이빙 체험',
    'description': '보라카이 주변의 다이빙 포인트에서 즐기는 스쿠버 다이빙입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 선셋 세일링',
    'englishName': 'Boracay Sunset Sailing',
    'searchTerm': 'Boracay',
    'title': '일몰 세일링',
    'description': '보라카이의 아름다운 일몰을 보트에서 감상하는 투어입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'sailing',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 플라이피시',
    'englishName': 'Boracay Flyfish',
    'searchTerm': 'Boracay',
    'title': '플라이피시 튜브',
    'description': '스피드 보트에 끌려가며 물 위를 나는 짜릿한 액티비티입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'watersport',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 바나나 보트',
    'englishName': 'Boracay Banana Boat',
    'searchTerm': 'Boracay',
    'title': '바나나 보트',
    'description': '그룹으로 즐기는 인기 수상 액티비티입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'boat',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 제트스키',
    'englishName': 'Boracay Jet Ski',
    'searchTerm': 'Boracay',
    'title': '제트스키',
    'description': '보라카이 바다에서 즐기는 제트스키 체험입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'jetski',
    'category': '수상스포츠',
  },

  // 보라카이 명소
  {
    'name': '윌리스 록',
    'englishName': 'Willy\'s Rock',
    'searchTerm': 'Boracay',
    'title': '성모마리아상',
    'description': '화이트 비치의 상징적인 바위로 성모마리아상이 있습니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'rock',
    'category': '자연',
  },
  {
    'name': '마운트 루호 전망대',
    'englishName': 'Mount Luho Viewpoint',
    'searchTerm': 'Boracay',
    'title': '보라카이 최고점',
    'description': '보라카이에서 가장 높은 지점으로 섬 전체를 조망할 수 있습니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'viewpoint',
    'category': '자연',
  },
  {
    'name': '아리엘스 포인트',
    'englishName': 'Ariel\'s Point',
    'searchTerm': 'Boracay',
    'title': '클리프 점프',
    'description': '절벽 다이빙과 카약, 스노클링을 즐길 수 있는 명소입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'cliff',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 나이트라이프',
    'englishName': 'Boracay D\'Mall',
    'searchTerm': 'Boracay',
    'title': '쇼핑과 엔터테인먼트',
    'description': '보라카이 중심가의 쇼핑몰로 상점, 레스토랑, 바가 밀집해 있습니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'entertainment',
    'category': '자연',
  },

  // 아클란 본토 및 주변
  {
    'name': '칼리보',
    'englishName': 'Kalibo',
    'searchTerm': 'Kalibo',
    'title': '아클란의 수도',
    'description': '아클란 주의 주도로 아티아티한 축제로 유명합니다.',
    'city': 'Kalibo',
    'province': 'Aklan',
    'icon': 'city',
    'category': '자연',
  },
  {
    'name': '카티클란',
    'englishName': 'Caticlan',
    'searchTerm': 'Caticlan',
    'title': '보라카이 관문',
    'description': '보라카이로 가는 페리를 탈 수 있는 항구 마을입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'port',
    'category': '자연',
  },
  {
    'name': '나바스 비치',
    'englishName': 'Nabaoy Beach',
    'searchTerm': 'Aklan',
    'title': '현지인 해변',
    'description': '아클란 본토의 한적한 해변입니다.',
    'city': 'Nabaoy',
    'province': 'Aklan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '티그아스온 폭포',
    'englishName': 'Tigauson Falls',
    'searchTerm': 'Aklan',
    'title': '아클란 폭포',
    'description': '아클란 내륙의 아름다운 폭포입니다.',
    'city': 'Malinao',
    'province': 'Aklan',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 인근 지역 (안티크, 일로일로)
  {
    'name': '말라파스쿠아 아클란',
    'englishName': 'Antique Beach',
    'searchTerm': 'Antique_(province)',
    'title': '안티크 해변',
    'description': '파나이 섬 서쪽 안티크 지방의 해변입니다.',
    'city': 'San Jose',
    'province': 'Antique',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '기가테스 제도',
    'englishName': 'Gigantes Islands',
    'searchTerm': 'Gigantes_Islands',
    'title': '거인의 섬',
    'description': '일로일로 북부의 아름다운 섬 그룹으로 석회암 절벽이 특징입니다.',
    'city': 'Carles',
    'province': 'Iloilo',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '카보간 동굴',
    'englishName': 'Cabugao Gamay Island',
    'searchTerm': 'Gigantes_Islands',
    'title': '작은 섬 호핑',
    'description': '기가테스 제도의 아름다운 작은 섬입니다.',
    'city': 'Carles',
    'province': 'Iloilo',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '탕케 살트워터 라군',
    'englishName': 'Tangke Saltwater Lagoon',
    'searchTerm': 'Gigantes_Islands',
    'title': '숨겨진 라군',
    'description': '기가테스 제도의 절벽에 둘러싸인 바닷물 라군입니다.',
    'city': 'Carles',
    'province': 'Iloilo',
    'icon': 'lagoon',
    'category': '자연',
  },
  {
    'name': '일로일로 시티',
    'englishName': 'Iloilo City',
    'searchTerm': 'Iloilo_City',
    'title': '필리핀의 사랑의 도시',
    'description': '비사야 지역의 주요 도시로 역사적 건물과 맛집이 많습니다.',
    'city': 'Iloilo City',
    'province': 'Iloilo',
    'icon': 'city',
    'category': '자연',
  },
  {
    'name': '기마라스 섬',
    'englishName': 'Guimaras Island',
    'searchTerm': 'Guimaras',
    'title': '망고의 섬',
    'description': '세계에서 가장 달콤한 망고로 유명한 섬입니다.',
    'city': 'Jordan',
    'province': 'Guimaras',
    'icon': 'island',
    'category': '섬',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 배치 6: 보라카이/아클란 지역 여행지 추가');
  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  print('📊 현재 여행지 개수: ${travelSpots.length}개\n');

  // 기존 이름 목록 (중복 체크용)
  final existingNames = travelSpots
      .map((spot) => (spot['name']?.toString() ?? '').toLowerCase())
      .toSet();

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 10);

  int added = 0;
  int skipped = 0;

  for (final spot in batch6Spots) {
    final name = spot['name'] as String;

    // 중복 체크
    if (existingNames.contains(name.toLowerCase())) {
      print('⏭️  건너뜀 (중복): $name');
      skipped++;
      continue;
    }

    // Wikipedia에서 이미지 URL 가져오기
    String imageUrl = '';
    final searchTerm = spot['searchTerm'] as String;

    try {
      final apiUrl = Uri.parse(
          'https://en.wikipedia.org/w/api.php?action=query&titles=$searchTerm&prop=pageimages&format=json&pithumbsize=800');
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
      print('⚠️  이미지 검색 실패: $name - $e');
    }

    // 이미지가 없으면 기본 보라카이 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Boracay_White_Beach.jpg/800px-Boracay_White_Beach.jpg';
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
    print('✅ 추가됨: $name');

    // Rate limiting
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // JSON 파일 저장
  final encoder = const JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(travelSpots);
  file.writeAsStringSync(updatedJsonString);

  httpClient.close();

  print('\n======================================');
  print('📊 배치 6 결과 요약');
  print('======================================');
  print('✅ 추가됨: $added개');
  print('⏭️  건너뜀: $skipped개');
  print('📊 현재 총 개수: ${travelSpots.length}개');
}
