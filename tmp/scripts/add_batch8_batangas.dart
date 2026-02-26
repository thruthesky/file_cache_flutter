// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 8: 바탕가스/잠발레스 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch8_batangas.dart
/// ```

// 바탕가스/잠발레스 지역 여행지 데이터
final List<Map<String, dynamic>> batch8Spots = [
  // 바탕가스 해변 및 다이빙
  {
    'name': '아니라오',
    'englishName': 'Anilao',
    'searchTerm': 'Anilao,_Batangas',
    'title': '필리핀 다이빙의 수도',
    'description': '마닐라에서 가장 가까운 다이빙 명소로 마크로 다이빙으로 유명합니다.',
    'city': 'Mabini',
    'province': 'Batangas',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '소호톤 코브 아니라오',
    'englishName': 'Sombrero Island',
    'searchTerm': 'Anilao,_Batangas',
    'title': '모자 모양 섬',
    'description': '아니라오 근처의 작은 섬으로 스노클링에 좋습니다.',
    'city': 'Mabini',
    'province': 'Batangas',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '마스카라 섬',
    'englishName': 'Masasa Beach',
    'searchTerm': 'Tingloy,_Batangas',
    'title': '틴글로이 해변',
    'description': '바탕가스의 아름다운 백사장 해변으로 보트로 접근합니다.',
    'city': 'Tingloy',
    'province': 'Batangas',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '포르투나 섬',
    'englishName': 'Fortune Island',
    'searchTerm': 'Fortune_Island',
    'title': '그리스 유적 섬',
    'description': '그리스풍 기둥이 있는 작은 섬으로 절벽 점프로 유명합니다.',
    'city': 'Nasugbu',
    'province': 'Batangas',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '라이야 비치',
    'englishName': 'Laiya Beach',
    'searchTerm': 'San_Juan,_Batangas',
    'title': '가족 휴양지',
    'description': '바탕가스 동쪽의 인기 있는 해변 리조트 지역입니다.',
    'city': 'San Juan',
    'province': 'Batangas',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '칼라타간 비치',
    'englishName': 'Calatagan Beach',
    'searchTerm': 'Calatagan',
    'title': '등대 해변',
    'description': '역사적인 등대가 있는 바탕가스의 해변 지역입니다.',
    'city': 'Calatagan',
    'province': 'Batangas',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '나수부 비치',
    'englishName': 'Nasugbu Beach',
    'searchTerm': 'Nasugbu',
    'title': '마닐라 근교 해변',
    'description': '마닐라에서 가장 가까운 해변 휴양지 중 하나입니다.',
    'city': 'Nasugbu',
    'province': 'Batangas',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '타알 호수',
    'englishName': 'Taal Lake',
    'searchTerm': 'Taal_Lake',
    'title': '화산 호수',
    'description': '타알 화산을 품고 있는 칼데라 호수로 보트 투어가 유명합니다.',
    'city': 'Talisay',
    'province': 'Batangas',
    'icon': 'lake',
    'category': '자연',
  },
  {
    'name': '베르데 섬',
    'englishName': 'Verde Island',
    'searchTerm': 'Verde_Island',
    'title': '생물 다양성의 중심',
    'description': '세계에서 가장 생물 다양성이 풍부한 해양 지역 중 하나입니다.',
    'city': 'Batangas City',
    'province': 'Batangas',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '세푸럭 폭포',
    'englishName': 'Sepulok Falls',
    'searchTerm': 'Batangas',
    'title': '바탕가스 폭포',
    'description': '바탕가스 내륙의 아름다운 폭포입니다.',
    'city': 'Cuenca',
    'province': 'Batangas',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 잠발레스 해변 및 섬
  {
    'name': '아니와야 코브',
    'englishName': 'Anawangin Cove',
    'searchTerm': 'Anawangin_Cove',
    'title': '소나무 해변',
    'description': '해변에 소나무가 자라는 독특한 풍경의 캠핑 명소입니다.',
    'city': 'San Antonio',
    'province': 'Zambales',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '나그사사 코브',
    'englishName': 'Nagsasa Cove',
    'searchTerm': 'Zambales',
    'title': '숨겨진 코브',
    'description': '아니와야 근처의 한적한 코브로 캠핑에 좋습니다.',
    'city': 'San Antonio',
    'province': 'Zambales',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '티나글라얀 코브',
    'englishName': 'Talisayan Cove',
    'searchTerm': 'Zambales',
    'title': '프라이빗 해변',
    'description': '잠발레스의 작은 코브 해변입니다.',
    'city': 'San Antonio',
    'province': 'Zambales',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '카만둥 섬',
    'englishName': 'Camara Island',
    'searchTerm': 'Zambales',
    'title': '섬 호핑',
    'description': '잠발레스의 아일랜드 호핑 목적지입니다.',
    'city': 'Subic',
    'province': 'Zambales',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '포톨란 비치',
    'englishName': 'Potipot Island',
    'searchTerm': 'Potipot_Island',
    'title': '작은 섬',
    'description': '잠발레스 북부의 작은 백사장 섬입니다.',
    'city': 'Candelaria',
    'province': 'Zambales',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '산 안토니오 비치',
    'englishName': 'San Antonio Beach',
    'searchTerm': 'San_Antonio,_Zambales',
    'title': '잠발레스 해변',
    'description': '산 안토니오의 해변으로 보트 출발지입니다.',
    'city': 'San Antonio',
    'province': 'Zambales',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '크리스탈 비치 잠발레스',
    'englishName': 'Crystal Beach Zambales',
    'searchTerm': 'San_Narciso,_Zambales',
    'title': '서핑 비치',
    'description': '잠발레스의 서핑 명소로 알려진 해변입니다.',
    'city': 'San Narciso',
    'province': 'Zambales',
    'icon': 'surfing',
    'category': '수상스포츠',
  },
  {
    'name': '이바 비치',
    'englishName': 'Iba Beach',
    'searchTerm': 'Iba,_Zambales',
    'title': '잠발레스 주도 해변',
    'description': '잠발레스 주도 이바의 해변입니다.',
    'city': 'Iba',
    'province': 'Zambales',
    'icon': 'beach',
    'category': '해변',
  },

  // 라 유니온 서핑
  {
    'name': '산 후안 서프',
    'englishName': 'San Juan Surf Beach',
    'searchTerm': 'San_Juan,_La_Union',
    'title': '필리핀 서핑 수도',
    'description': '루손 북부의 서핑 명소로 초보자부터 고수까지 즐길 수 있습니다.',
    'city': 'San Juan',
    'province': 'La Union',
    'icon': 'surfing',
    'category': '수상스포츠',
  },
  {
    'name': '어반스 비치',
    'englishName': 'Urbiztondo Beach',
    'searchTerm': 'San_Juan,_La_Union',
    'title': '서퍼의 해변',
    'description': '라 유니온의 메인 서핑 해변입니다.',
    'city': 'San Juan',
    'province': 'La Union',
    'icon': 'surfing',
    'category': '수상스포츠',
  },
  {
    'name': '바곡 비치',
    'englishName': 'Bacnotan Beach',
    'searchTerm': 'La_Union',
    'title': '라 유니온 해변',
    'description': '라 유니온의 또 다른 해변 지역입니다.',
    'city': 'Bacnotan',
    'province': 'La Union',
    'icon': 'beach',
    'category': '해변',
  },

  // 팡가시난 해변
  {
    'name': '헌드레드 아일랜드',
    'englishName': 'Hundred Islands',
    'searchTerm': 'Hundred_Islands_National_Park',
    'title': '124개의 섬',
    'description': '링가옌 만의 국립공원으로 수많은 작은 섬들이 있습니다.',
    'city': 'Alaminos',
    'province': 'Pangasinan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '퀘존 섬',
    'englishName': 'Quezon Island',
    'searchTerm': 'Hundred_Islands_National_Park',
    'title': '헌드레드 아일랜드 메인',
    'description': '헌드레드 아일랜드에서 가장 개발된 섬으로 시설이 잘 갖춰져 있습니다.',
    'city': 'Alaminos',
    'province': 'Pangasinan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '거번너스 섬',
    'englishName': 'Governor\'s Island',
    'searchTerm': 'Hundred_Islands_National_Park',
    'title': '전망대 섬',
    'description': '헌드레드 아일랜드의 전망대가 있는 섬입니다.',
    'city': 'Alaminos',
    'province': 'Pangasinan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '마르코스 섬',
    'englishName': 'Marcos Island',
    'searchTerm': 'Hundred_Islands_National_Park',
    'title': '절벽 섬',
    'description': '헌드레드 아일랜드의 절벽 점프 명소입니다.',
    'city': 'Alaminos',
    'province': 'Pangasinan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '다스올 비치',
    'englishName': 'Dasol Beach',
    'searchTerm': 'Dasol',
    'title': '팡가시난 해변',
    'description': '팡가시난 서쪽의 해변 마을입니다.',
    'city': 'Dasol',
    'province': 'Pangasinan',
    'icon': 'beach',
    'category': '해변',
  },

  // 민도로 해변
  {
    'name': '푸에르토 갈레라',
    'englishName': 'Puerto Galera',
    'searchTerm': 'Puerto_Galera',
    'title': '다이빙과 해변',
    'description': '민도로 섬의 인기 휴양지로 다이빙과 나이트라이프로 유명합니다.',
    'city': 'Puerto Galera',
    'province': 'Oriental Mindoro',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '화이트 비치 푸에르토',
    'englishName': 'White Beach Puerto Galera',
    'searchTerm': 'Puerto_Galera',
    'title': '푸에르토 갈레라 메인',
    'description': '푸에르토 갈레라의 대표적인 백사장 해변입니다.',
    'city': 'Puerto Galera',
    'province': 'Oriental Mindoro',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '사방 비치',
    'englishName': 'Sabang Beach',
    'searchTerm': 'Puerto_Galera',
    'title': '다이빙 허브',
    'description': '푸에르토 갈레라의 다이빙 센터가 밀집한 해변입니다.',
    'city': 'Puerto Galera',
    'province': 'Oriental Mindoro',
    'icon': 'diving',
    'category': '해변',
  },
  {
    'name': '타마라 비치',
    'englishName': 'Tamaraw Beach',
    'searchTerm': 'Puerto_Galera',
    'title': '한적한 해변',
    'description': '푸에르토 갈레라의 조용한 해변입니다.',
    'city': 'Puerto Galera',
    'province': 'Oriental Mindoro',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '푸에르토 갈레라 다이빙',
    'englishName': 'Puerto Galera Diving',
    'searchTerm': 'Puerto_Galera',
    'title': '다이빙 포인트',
    'description': '푸에르토 갈레라의 다양한 다이빙 사이트들입니다.',
    'city': 'Puerto Galera',
    'province': 'Oriental Mindoro',
    'icon': 'diving',
    'category': '수상스포츠',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  //  print('======================================');
  //  print('📋 배치 8: 바탕가스/잠발레스 지역 여행지 추가');
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

  for (final spot in batch8Spots) {
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

    // 이미지가 없으면 기본 바탕가스 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl =
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Taal_Volcano_aerial_2013.jpg/800px-Taal_Volcano_aerial_2013.jpg';
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
  //  print('📊 배치 8 결과 요약');
  //  print('======================================');
  //  print('✅ 추가됨: $added개');
  //  print('⏭️  건너뜀: $skipped개');
  //  print('📊 현재 총 개수: ${travelSpots.length}개');
}
