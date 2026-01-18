// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 3: 세부 북부 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch3_cebu_north.dart
/// ```

// 세부 북부 지역 여행지 데이터
final List<Map<String, dynamic>> batch3Spots = [
  // 말라파스쿠아 섬 관련
  {
    'name': '말라파스쿠아 섬',
    'englishName': 'Malapascua Island',
    'searchTerm': 'Malapascua',
    'title': '환도상어의 천국',
    'description': '세부 북부의 작은 섬으로 환도상어(Thresher Shark)를 볼 수 있는 세계적인 다이빙 명소입니다.',
    'city': 'Daanbantayan',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '섬',
  },
  {
    'name': '바운티 비치',
    'englishName': 'Bounty Beach',
    'searchTerm': 'Malapascua',
    'title': '말라파스쿠아의 메인 비치',
    'description': '말라파스쿠아 섬의 대표적인 해변으로 하얀 모래와 맑은 바다가 특징입니다.',
    'city': 'Daanbantayan',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '모나드 숄',
    'englishName': 'Monad Shoal',
    'searchTerm': 'Thresher_shark',
    'title': '환도상어 다이빙 포인트',
    'description': '전 세계에서 환도상어를 가장 쉽게 볼 수 있는 다이빙 포인트입니다.',
    'city': 'Daanbantayan',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '갈로 섬',
    'englishName': 'Gato Island',
    'searchTerm': 'Gato_Island',
    'title': '동굴 다이빙과 상어',
    'description': '바다뱀과 백상어를 볼 수 있는 해양보호구역입니다.',
    'city': 'Daanbantayan',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '섬',
  },
  {
    'name': '랑곤 비치',
    'englishName': 'Langob Beach',
    'searchTerm': 'Malapascua',
    'title': '조용한 해변',
    'description': '말라파스쿠아 섬 북쪽의 한적한 해변으로 스노클링에 적합합니다.',
    'city': 'Daanbantayan',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },

  // 반타얀 섬 관련
  {
    'name': '반타얀 섬',
    'englishName': 'Bantayan Island',
    'searchTerm': 'Bantayan_Island',
    'title': '세부의 숨겨진 낙원',
    'description': '세부 북서쪽에 위치한 아름다운 섬으로 하얀 모래 해변과 평화로운 분위기가 특징입니다.',
    'city': 'Bantayan',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '슈가 비치 반타얀',
    'englishName': 'Sugar Beach Bantayan',
    'searchTerm': 'Bantayan_Island',
    'title': '반타얀의 대표 해변',
    'description': '반타얀 섬에서 가장 유명한 해변으로 설탕처럼 하얀 모래가 특징입니다.',
    'city': 'Bantayan',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '파라다이스 비치 반타얀',
    'englishName': 'Paradise Beach Bantayan',
    'searchTerm': 'Bantayan_Island',
    'title': '천국의 해변',
    'description': '반타얀 섬의 숨겨진 해변으로 조용하고 아름다운 풍경을 자랑합니다.',
    'city': 'Bantayan',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '버진 아일랜드 반타얀',
    'englishName': 'Virgin Island Bantayan',
    'searchTerm': 'Bantayan_Island',
    'title': '무인도 모래톱',
    'description': '반타얀 근처의 작은 섬으로 보트 투어로 방문할 수 있습니다.',
    'city': 'Bantayan',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '오그통 동굴',
    'englishName': 'Ogtong Cave',
    'searchTerm': 'Bantayan_Island',
    'title': '자연 수영장 동굴',
    'description': '반타얀 섬의 천연 동굴 수영장으로 맑은 물에서 수영을 즐길 수 있습니다.',
    'city': 'Bantayan',
    'province': 'Cebu',
    'icon': 'cave',
    'category': '자연',
  },

  // 카모테스 제도 관련
  {
    'name': '카모테스 제도',
    'englishName': 'Camotes Islands',
    'searchTerm': 'Camotes_Islands',
    'title': '세부의 숨겨진 보석',
    'description': '세부 동쪽에 위치한 섬 그룹으로 자연 그대로의 아름다움을 간직하고 있습니다.',
    'city': 'San Francisco',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '산티아고 베이',
    'englishName': 'Santiago Bay',
    'searchTerm': 'Camotes_Islands',
    'title': '카모테스의 하얀 해변',
    'description': '카모테스 제도에서 가장 유명한 해변으로 긴 백사장이 특징입니다.',
    'city': 'San Francisco',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '부호 록 풀',
    'englishName': 'Buho Rock Pool',
    'searchTerm': 'Camotes_Islands',
    'title': '절벽 다이빙 명소',
    'description': '천연 바위 수영장으로 절벽 다이빙을 즐길 수 있는 인기 명소입니다.',
    'city': 'Poro',
    'province': 'Cebu',
    'icon': 'cliff',
    'category': '자연',
  },
  {
    'name': '레이크 다나오',
    'englishName': 'Lake Danao',
    'searchTerm': 'Lake_Danao_(Camotes)',
    'title': '카모테스의 호수',
    'description': '카모테스 섬에 있는 아름다운 담수호로 카약과 보트를 즐길 수 있습니다.',
    'city': 'San Francisco',
    'province': 'Cebu',
    'icon': 'lake',
    'category': '자연',
  },
  {
    'name': '티무보 동굴',
    'englishName': 'Timubo Cave',
    'searchTerm': 'Camotes_Islands',
    'title': '지하 수영장 동굴',
    'description': '카모테스의 자연 동굴로 시원한 지하수에서 수영할 수 있습니다.',
    'city': 'San Francisco',
    'province': 'Cebu',
    'icon': 'cave',
    'category': '자연',
  },

  // 세부 북부 본섬 지역
  {
    'name': '마야 포트',
    'englishName': 'Maya Port',
    'searchTerm': 'Daanbantayan',
    'title': '말라파스쿠아 가는 항구',
    'description': '말라파스쿠아 섬으로 가는 보트를 탈 수 있는 세부 최북단 항구입니다.',
    'city': 'Daanbantayan',
    'province': 'Cebu',
    'icon': 'port',
    'category': '자연',
  },
  {
    'name': '하그나야 비치',
    'englishName': 'Hagnaya Beach',
    'searchTerm': 'San_Remigio,_Cebu',
    'title': '반타얀 가는 항구 해변',
    'description': '반타얀 섬으로 가는 페리 항구가 있는 해변 마을입니다.',
    'city': 'San Remigio',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '보고 시티 비치',
    'englishName': 'Bogo City Beach',
    'searchTerm': 'Bogo,_Cebu',
    'title': '북부 세부의 도시 해변',
    'description': '세부 북부의 주요 도시 보고의 해변으로 현지인들에게 인기 있습니다.',
    'city': 'Bogo',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '메데이야 비치',
    'englishName': 'Medellin Beach',
    'searchTerm': 'Medellin,_Cebu',
    'title': '세부 북부 해변',
    'description': '세부 북부 메데인 지역의 아름다운 해변입니다.',
    'city': 'Medellin',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '기나틸란 폭포',
    'englishName': 'Ginatilan Falls',
    'searchTerm': 'Cebu',
    'title': '숨겨진 폭포',
    'description': '세부 북부의 숨겨진 폭포로 자연 그대로의 아름다움을 간직하고 있습니다.',
    'city': 'Ginatilan',
    'province': 'Cebu',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 막탄 섬 다이빙 관련
  {
    'name': '막탄 섬',
    'englishName': 'Mactan Island',
    'searchTerm': 'Mactan',
    'title': '세부의 관문',
    'description': '세부 국제공항이 있는 섬으로 리조트와 다이빙 센터가 밀집해 있습니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '막탄 해양 보호구역',
    'englishName': 'Mactan Marine Sanctuary',
    'searchTerm': 'Mactan',
    'title': '스노클링 명소',
    'description': '막탄 섬의 해양보호구역으로 다양한 해양 생물을 볼 수 있습니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'snorkeling',
    'category': '수상스포츠',
  },
  {
    'name': '마리바고 비치',
    'englishName': 'Maribago Beach',
    'searchTerm': 'Mactan',
    'title': '막탄의 인기 해변',
    'description': '막탄 섬 동쪽의 인기 있는 해변으로 리조트가 많이 있습니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '올랑고 섬',
    'englishName': 'Olango Island',
    'searchTerm': 'Olango_Island',
    'title': '철새 보호구역',
    'description': '막탄 근처의 섬으로 철새 서식지와 해양 보호구역이 있습니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '힐루퉁안 섬',
    'englishName': 'Hilutungan Island',
    'searchTerm': 'Hilutungan_Island',
    'title': '스노클링과 다이빙',
    'description': '막탄에서 보트로 갈 수 있는 해양 보호구역으로 풍부한 산호와 물고기가 있습니다.',
    'city': 'Cordova',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '섬',
  },
  {
    'name': '나루수안 섬',
    'englishName': 'Nalusuan Island',
    'searchTerm': 'Nalusuan_Island',
    'title': '아일랜드 호핑 명소',
    'description': '막탄 아일랜드 호핑의 인기 목적지로 긴 나무 데크가 특징입니다.',
    'city': 'Cordova',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '카오하간 섬',
    'englishName': 'Caohagan Island',
    'searchTerm': 'Olango_Island',
    'title': '전통 어촌 마을',
    'description': '올랑고 근처의 작은 섬으로 전통적인 어촌 마을을 체험할 수 있습니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '판다논 섬',
    'englishName': 'Pandanon Island',
    'searchTerm': 'Pandanon_Island',
    'title': '백사장 샌드바',
    'description': '보홀과 세부 사이에 있는 아름다운 샌드바 섬입니다.',
    'city': 'Getafe',
    'province': 'Bohol',
    'icon': 'island',
    'category': '섬',
  },

  // 세부 시티 근교
  {
    'name': '탑스 전망대',
    'englishName': 'Tops Lookout',
    'searchTerm': 'Cebu_City',
    'title': '세부 시티 전망',
    'description': '세부 시티와 막탄 섬을 한눈에 볼 수 있는 인기 전망대입니다.',
    'city': 'Cebu City',
    'province': 'Cebu',
    'icon': 'viewpoint',
    'category': '자연',
  },
  {
    'name': '시라오 가든',
    'englishName': 'Sirao Garden',
    'searchTerm': 'Cebu_City',
    'title': '작은 암스테르담',
    'description': '세부의 리틀 암스테르담으로 불리는 꽃 정원입니다.',
    'city': 'Cebu City',
    'province': 'Cebu',
    'icon': 'garden',
    'category': '자연',
  },
  {
    'name': '템플 오브 레아',
    'englishName': 'Temple of Leah',
    'searchTerm': 'Temple_of_Leah',
    'title': '세부의 타지마할',
    'description': '그리스 로마 양식으로 지어진 사원으로 세부의 타지마할로 불립니다.',
    'city': 'Cebu City',
    'province': 'Cebu',
    'icon': 'temple',
    'category': '자연',
  },

  // 추가 다이빙/스노클링 포인트
  {
    'name': '콘티키 다이브 사이트',
    'englishName': 'Kontiki Dive Site',
    'searchTerm': 'Mactan',
    'title': '막탄 다이빙 포인트',
    'description': '막탄 섬의 인기 다이빙 포인트로 인공 구조물과 다양한 해양 생물이 있습니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '탈리마 해양 보호구역',
    'englishName': 'Talima Marine Sanctuary',
    'searchTerm': 'Olango_Island',
    'title': '올랑고 다이빙 포인트',
    'description': '올랑고 섬의 해양 보호구역으로 건강한 산호초가 있습니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '카빌라오 섬',
    'englishName': 'Cabilao Island',
    'searchTerm': 'Cabilao_Island',
    'title': '다이버의 천국',
    'description': '보홀 근처의 작은 섬으로 환상적인 다이빙 포인트가 많습니다.',
    'city': 'Loon',
    'province': 'Bohol',
    'icon': 'diving',
    'category': '섬',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 배치 3: 세부 북부 지역 여행지 추가');
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

  for (final spot in batch3Spots) {
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

    // 이미지가 없으면 기본 세부 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Cebu_City_Waterfront.jpg/800px-Cebu_City_Waterfront.jpg';
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
  print('📊 배치 3 결과 요약');
  print('======================================');
  print('✅ 추가됨: $added개');
  print('⏭️  건너뜀: $skipped개');
  print('📊 현재 총 개수: ${travelSpots.length}개');
}
