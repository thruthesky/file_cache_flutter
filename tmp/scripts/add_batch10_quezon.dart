// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 10: 퀘존/라구나 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch10_quezon.dart
/// ```

// 퀘존/라구나 지역 여행지 데이터
final List<Map<String, dynamic>> batch10Spots = [
  // 퀘존 지역
  {
    'name': '보락 비치',
    'englishName': 'Borawan Beach',
    'searchTerm': 'Padre_Burgos,_Quezon',
    'title': '보라카이+팔라완',
    'description': '보라카이와 팔라완을 합친 이름으로 아름다운 해변이 특징입니다.',
    'city': 'Padre Burgos',
    'province': 'Quezon',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '다마팔리 비치',
    'englishName': 'Dampalitan Beach',
    'searchTerm': 'Padre_Burgos,_Quezon',
    'title': '캠핑 해변',
    'description': '퀘존의 인기 캠핑 해변으로 바위 지형이 특징입니다.',
    'city': 'Padre Burgos',
    'province': 'Quezon',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '파히나다 비치',
    'englishName': 'Pahinigda Beach',
    'searchTerm': 'Padre_Burgos,_Quezon',
    'title': '숨겨진 해변',
    'description': '퀘존의 숨겨진 해변으로 한적한 분위기입니다.',
    'city': 'Padre Burgos',
    'province': 'Quezon',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '조마리그 섬',
    'englishName': 'Jomalig Island',
    'searchTerm': 'Jomalig,_Quezon',
    'title': '황금빛 모래섬',
    'description': '퀘존 끝자락의 섬으로 황금빛 모래가 특징입니다.',
    'city': 'Jomalig',
    'province': 'Quezon',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '풀랑로파 비치',
    'englishName': 'Pulang Lupa Beach',
    'searchTerm': 'Jomalig,_Quezon',
    'title': '핑크빛 해변',
    'description': '조마리그 섬의 아름다운 해변입니다.',
    'city': 'Jomalig',
    'province': 'Quezon',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '코타 비치',
    'englishName': 'Cota Beach',
    'searchTerm': 'Pagbilao,_Quezon',
    'title': '퀘존 해변',
    'description': '퀘존의 해변 리조트 지역입니다.',
    'city': 'Pagbilao',
    'province': 'Quezon',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '베르데 섬 패시지',
    'englishName': 'Verde Island Passage',
    'searchTerm': 'Verde_Island_Passage',
    'title': '해양 생물 다양성',
    'description': '세계에서 가장 생물 다양성이 풍부한 해역 중 하나입니다.',
    'city': 'Pagbilao',
    'province': 'Quezon',
    'icon': 'ocean',
    'category': '자연',
  },
  {
    'name': '폴릴로 섬',
    'englishName': 'Polillo Islands',
    'searchTerm': 'Polillo_Islands',
    'title': '섬 그룹',
    'description': '퀘존 동쪽의 섬 그룹으로 자연 그대로의 해변이 있습니다.',
    'city': 'Polillo',
    'province': 'Quezon',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '보르드네오스 섬',
    'englishName': 'Burdeos Island',
    'searchTerm': 'Burdeos,_Quezon',
    'title': '숨겨진 낙원',
    'description': '폴릴로 제도의 섬으로 미개발 해변이 많습니다.',
    'city': 'Burdeos',
    'province': 'Quezon',
    'icon': 'island',
    'category': '섬',
  },

  // 라구나 지역
  {
    'name': '파그산잔 폭포',
    'englishName': 'Pagsanjan Falls',
    'searchTerm': 'Pagsanjan_Falls',
    'title': '악마의 폭포',
    'description': '라구나의 대표적인 폭포로 보트 래프팅으로 접근합니다.',
    'city': 'Pagsanjan',
    'province': 'Laguna',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '히든 밸리 스프링스',
    'englishName': 'Hidden Valley Springs',
    'searchTerm': 'Hidden_Valley_Springs',
    'title': '천연 온천',
    'description': '라구나의 고급 온천 리조트로 자연 수영장이 있습니다.',
    'city': 'Alaminos',
    'province': 'Laguna',
    'icon': 'hotspring',
    'category': '자연',
  },
  {
    'name': '산 파블로 호수',
    'englishName': 'Seven Lakes of San Pablo',
    'searchTerm': 'San_Pablo,_Laguna',
    'title': '7개의 호수',
    'description': '산 파블로 시의 7개 화산 호수입니다.',
    'city': 'San Pablo',
    'province': 'Laguna',
    'icon': 'lake',
    'category': '자연',
  },
  {
    'name': '삼팔록 호수',
    'englishName': 'Lake Sampaloc',
    'searchTerm': 'San_Pablo,_Laguna',
    'title': '가장 큰 호수',
    'description': '산 파블로의 7개 호수 중 가장 큰 호수입니다.',
    'city': 'San Pablo',
    'province': 'Laguna',
    'icon': 'lake',
    'category': '자연',
  },
  {
    'name': '칼람바 온천',
    'englishName': 'Calamba Hot Springs',
    'searchTerm': 'Calamba,_Laguna',
    'title': '온천 리조트 단지',
    'description': '라구나의 온천 리조트가 밀집한 지역입니다.',
    'city': 'Calamba',
    'province': 'Laguna',
    'icon': 'hotspring',
    'category': '자연',
  },
  {
    'name': '로스 바뇨스 핫 스프링',
    'englishName': 'Los Banos Hot Springs',
    'searchTerm': 'Los_Baños,_Laguna',
    'title': '대학 도시 온천',
    'description': 'UPLB가 있는 대학 도시의 온천 지역입니다.',
    'city': 'Los Banos',
    'province': 'Laguna',
    'icon': 'hotspring',
    'category': '자연',
  },
  {
    'name': '마킬링 식물원',
    'englishName': 'Makiling Botanic Gardens',
    'searchTerm': 'Mount_Makiling',
    'title': '식물 연구 정원',
    'description': '마킬링 산 기슭의 식물 연구 정원입니다.',
    'city': 'Los Banos',
    'province': 'Laguna',
    'icon': 'garden',
    'category': '자연',
  },
  {
    'name': '후루간 폭포',
    'englishName': 'Hulugan Falls',
    'searchTerm': 'Luisiana,_Laguna',
    'title': '라구나 최고 폭포',
    'description': '라구나에서 가장 높은 폭포 중 하나입니다.',
    'city': 'Luisiana',
    'province': 'Laguna',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '부리갈락 폭포',
    'englishName': 'Burilag Falls',
    'searchTerm': 'Laguna',
    'title': '숨겨진 폭포',
    'description': '라구나의 숨겨진 폭포입니다.',
    'city': 'Luisiana',
    'province': 'Laguna',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 리잘 지역
  {
    'name': '안고노 페트로글리프',
    'englishName': 'Angono Petroglyphs',
    'searchTerm': 'Angono_Petroglyphs',
    'title': '선사시대 암각화',
    'description': '필리핀에서 가장 오래된 예술 작품인 암각화가 있습니다.',
    'city': 'Angono',
    'province': 'Rizal',
    'icon': 'history',
    'category': '자연',
  },
  {
    'name': '피트산 예술마을',
    'englishName': 'Pinto Art Museum',
    'searchTerm': 'Pinto_Art_Museum',
    'title': '현대 미술관',
    'description': '안고노의 현대 미술관으로 건축과 정원이 아름답습니다.',
    'city': 'Antipolo',
    'province': 'Rizal',
    'icon': 'museum',
    'category': '자연',
  },
  {
    'name': '다리탁 폭포',
    'englishName': 'Daranak Falls',
    'searchTerm': 'Tanay,_Rizal',
    'title': '타나이 폭포',
    'description': '타나이의 인기 있는 폭포로 수영이 가능합니다.',
    'city': 'Tanay',
    'province': 'Rizal',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '티나고 폭포 리잘',
    'englishName': 'Tinipak River',
    'searchTerm': 'Tanay,_Rizal',
    'title': '강 트레킹',
    'description': '타나이의 강으로 트레킹과 수영이 가능합니다.',
    'city': 'Tanay',
    'province': 'Rizal',
    'icon': 'river',
    'category': '자연',
  },
  {
    'name': '마시누록 폭포',
    'englishName': 'Masinunok Falls',
    'searchTerm': 'Tanay,_Rizal',
    'title': '타나이 숨겨진 폭포',
    'description': '타나이의 숨겨진 폭포입니다.',
    'city': 'Tanay',
    'province': 'Rizal',
    'icon': 'waterfall',
    'category': '자연',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  //  print('======================================');
  //  print('📋 배치 10: 퀘존/라구나 지역 여행지 추가');
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

  for (final spot in batch10Spots) {
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

    // 이미지가 없으면 기본 라구나 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl =
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Pagsanjanfallsjf.JPG/800px-Pagsanjanfallsjf.JPG';
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
  //  print('📊 배치 10 결과 요약');
  //  print('======================================');
  //  print('✅ 추가됨: $added개');
  //  print('⏭️  건너뜀: $skipped개');
  //  print('📊 현재 총 개수: ${travelSpots.length}개');
}
