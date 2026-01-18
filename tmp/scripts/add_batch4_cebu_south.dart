// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 4: 세부 남부 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch4_cebu_south.dart
/// ```

// 세부 남부 지역 여행지 데이터 (오슬롭, 모알보알 등)
final List<Map<String, dynamic>> batch4Spots = [
  // 오슬롭 지역
  {
    'name': '오슬롭 고래상어 투어',
    'englishName': 'Oslob Whale Shark Watching',
    'searchTerm': 'Whale_shark',
    'title': '고래상어와 수영하기',
    'description': '세계적으로 유명한 고래상어 체험 명소로 매일 아침 고래상어를 볼 수 있습니다.',
    'city': 'Oslob',
    'province': 'Cebu',
    'icon': 'whale',
    'category': '수상스포츠',
  },
  {
    'name': '수밀론 섬',
    'englishName': 'Sumilon Island',
    'searchTerm': 'Sumilon_Island',
    'title': '이동하는 샌드바',
    'description': '오슬롭 근처의 아름다운 섬으로 계절에 따라 위치가 바뀌는 샌드바가 유명합니다.',
    'city': 'Oslob',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '수밀론 블루워터',
    'englishName': 'Sumilon Bluewater',
    'searchTerm': 'Sumilon_Island',
    'title': '프라이빗 리조트',
    'description': '수밀론 섬의 유일한 리조트로 독점적인 해변 경험을 제공합니다.',
    'city': 'Oslob',
    'province': 'Cebu',
    'icon': 'resort',
    'category': '해변',
  },

  // 모알보알 지역
  {
    'name': '모알보알',
    'englishName': 'Moalboal',
    'searchTerm': 'Moalboal',
    'title': '다이버의 천국',
    'description': '세부 남서부의 다이빙 메카로 정어리 떼와 거북이로 유명합니다.',
    'city': 'Moalboal',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '파나그사마 비치',
    'englishName': 'Panagsama Beach',
    'searchTerm': 'Moalboal',
    'title': '모알보알의 중심',
    'description': '모알보알의 메인 비치로 다이빙 샵과 레스토랑이 밀집해 있습니다.',
    'city': 'Moalboal',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '사딘 런',
    'englishName': 'Sardine Run',
    'searchTerm': 'Sardine_run',
    'title': '정어리 대군 스노클링',
    'description': '수백만 마리의 정어리 떼와 함께 수영할 수 있는 세계적 명소입니다.',
    'city': 'Moalboal',
    'province': 'Cebu',
    'icon': 'snorkeling',
    'category': '수상스포츠',
  },
  {
    'name': '페스카도르 섬',
    'englishName': 'Pescador Island',
    'searchTerm': 'Pescador_Island',
    'title': '최고의 다이빙 포인트',
    'description': '모알보알 최고의 다이빙 사이트로 풍부한 해양 생물이 있습니다.',
    'city': 'Moalboal',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '섬',
  },
  {
    'name': '화이트 비치 모알보알',
    'englishName': 'White Beach Moalboal',
    'searchTerm': 'Moalboal',
    'title': '하얀 모래 해변',
    'description': '모알보알의 아름다운 백사장 해변으로 일몰이 유명합니다.',
    'city': 'Moalboal',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '터틀 포인트 모알보알',
    'englishName': 'Turtle Point Moalboal',
    'searchTerm': 'Moalboal',
    'title': '바다거북 서식지',
    'description': '바다거북을 쉽게 볼 수 있는 스노클링 포인트입니다.',
    'city': 'Moalboal',
    'province': 'Cebu',
    'icon': 'turtle',
    'category': '수상스포츠',
  },

  // 바디안/카와산 폭포 지역
  {
    'name': '카와산 폭포',
    'englishName': 'Kawasan Falls',
    'searchTerm': 'Kawasan_Falls',
    'title': '세부 최고의 폭포',
    'description': '세부에서 가장 유명한 폭포로 에메랄드빛 물이 특징입니다.',
    'city': 'Badian',
    'province': 'Cebu',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '카와산 캐녀닝',
    'englishName': 'Kawasan Canyoneering',
    'searchTerm': 'Kawasan_Falls',
    'title': '협곡 어드벤처',
    'description': '점프, 수영, 트레킹을 포함한 카와산 폭포 캐녀닝 투어입니다.',
    'city': 'Badian',
    'province': 'Cebu',
    'icon': 'adventure',
    'category': '수상스포츠',
  },
  {
    'name': '바디안 섬',
    'englishName': 'Badian Island',
    'searchTerm': 'Badian,_Cebu',
    'title': '프라이빗 리조트 섬',
    'description': '바디안 근처의 작은 섬으로 고급 리조트가 있습니다.',
    'city': 'Badian',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '람부안 피크',
    'englishName': 'Lambug Beach',
    'searchTerm': 'Badian,_Cebu',
    'title': '조용한 해변',
    'description': '바디안의 한적한 해변으로 현지인들에게 인기 있습니다.',
    'city': 'Badian',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },

  // 산탄더/릴로안 지역
  {
    'name': '산탄더 해변',
    'englishName': 'Santander Beach',
    'searchTerm': 'Santander,_Cebu',
    'title': '세부 최남단 해변',
    'description': '세부 최남단에 위치한 조용한 해변 마을입니다.',
    'city': 'Santander',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '릴로안 포트',
    'englishName': 'Liloan Port',
    'searchTerm': 'Santander,_Cebu',
    'title': '보홀 가는 항구',
    'description': '세부에서 보홀로 가는 페리를 탈 수 있는 항구입니다.',
    'city': 'Santander',
    'province': 'Cebu',
    'icon': 'port',
    'category': '자연',
  },

  // 알코이/볼존 지역
  {
    'name': '팅코 비치',
    'englishName': 'Tingko Beach',
    'searchTerm': 'Alcoy,_Cebu',
    'title': '알코이의 백사장',
    'description': '세부 남동부의 아름다운 백사장 해변입니다.',
    'city': 'Alcoy',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '볼존 해양 보호구역',
    'englishName': 'Boljoon Marine Sanctuary',
    'searchTerm': 'Boljoon',
    'title': '스노클링 명소',
    'description': '볼존의 해양 보호구역으로 건강한 산호초가 있습니다.',
    'city': 'Boljoon',
    'province': 'Cebu',
    'icon': 'snorkeling',
    'category': '수상스포츠',
  },

  // 말라파스쿠아 추가 다이빙 포인트
  {
    'name': '칼랑가만 섬',
    'englishName': 'Kalanggaman Island',
    'searchTerm': 'Kalanggaman_Island',
    'title': '긴 샌드바의 섬',
    'description': '레이테에 속하지만 세부에서도 접근 가능한 아름다운 샌드바 섬입니다.',
    'city': 'Palompon',
    'province': 'Leyte',
    'icon': 'island',
    'category': '섬',
  },

  // 세부 남부 폭포들
  {
    'name': '이나보락 폭포',
    'englishName': 'Inambakan Falls',
    'searchTerm': 'Ginatilan,_Cebu',
    'title': '숨겨진 폭포',
    'description': '기나틸란의 다층 폭포로 점프 포인트가 있습니다.',
    'city': 'Ginatilan',
    'province': 'Cebu',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '아그와 폭포',
    'englishName': 'Aguinid Falls',
    'searchTerm': 'Samboan,_Cebu',
    'title': '어드벤처 폭포',
    'description': '삼보안의 다층 폭포로 클라이밍과 점프를 즐길 수 있습니다.',
    'city': 'Samboan',
    'province': 'Cebu',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '다오 폭포',
    'englishName': 'Dao Falls',
    'searchTerm': 'Samboan,_Cebu',
    'title': '삼보안의 폭포',
    'description': '삼보안에 위치한 아름다운 폭포입니다.',
    'city': 'Samboan',
    'province': 'Cebu',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '봉개 폭포',
    'englishName': 'Binalayan Falls',
    'searchTerm': 'Samboan,_Cebu',
    'title': '히든 폴스',
    'description': '삼보안의 숨겨진 폭포로 트레킹이 필요합니다.',
    'city': 'Samboan',
    'province': 'Cebu',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 카르멘/다나오 지역
  {
    'name': '카르멘 체리 블라썸',
    'englishName': 'Carmen Cebu Cherry Blossoms',
    'searchTerm': 'Carmen,_Cebu',
    'title': '세부의 벚꽃',
    'description': '세부 카르멘의 벚꽃 농장으로 시즌에 아름다운 꽃이 핍니다.',
    'city': 'Carmen',
    'province': 'Cebu',
    'icon': 'flower',
    'category': '자연',
  },
  {
    'name': '다나오 어드벤처 파크',
    'englishName': 'Danao Adventure Park',
    'searchTerm': 'Danao,_Cebu',
    'title': '익스트림 스포츠',
    'description': '세부의 어드벤처 파크로 번지, 짚라인 등을 즐길 수 있습니다.',
    'city': 'Danao',
    'province': 'Cebu',
    'icon': 'adventure',
    'category': '자연',
  },

  // 아르가오/달라게테 지역
  {
    'name': '아르가오 비치',
    'englishName': 'Argao Beach',
    'searchTerm': 'Argao',
    'title': '남부 세부 해변',
    'description': '세부 남부 아르가오의 해변으로 로컬 분위기가 있습니다.',
    'city': 'Argao',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '달라게테 해변',
    'englishName': 'Dalaguete Beach',
    'searchTerm': 'Dalaguete',
    'title': '평화로운 해변',
    'description': '달라게테의 조용한 해변으로 일상을 벗어나기 좋습니다.',
    'city': 'Dalaguete',
    'province': 'Cebu',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '만타롱곤 피크',
    'englishName': 'Mantalongon Peak',
    'searchTerm': 'Dalaguete',
    'title': '채소의 수도',
    'description': '달라게테 고원의 시원한 기후로 채소 농장이 많습니다.',
    'city': 'Dalaguete',
    'province': 'Cebu',
    'icon': 'mountain',
    'category': '자연',
  },

  // 추가 섬/해변
  {
    'name': '타농 해협',
    'englishName': 'Tanon Strait',
    'searchTerm': 'Tañon_Strait',
    'title': '돌고래 서식지',
    'description': '세부와 네그로스 사이의 해협으로 돌고래 워칭이 유명합니다.',
    'city': 'Bais',
    'province': 'Negros Oriental',
    'icon': 'dolphin',
    'category': '수상스포츠',
  },
  {
    'name': '바이스 돌핀 워칭',
    'englishName': 'Bais Dolphin Watching',
    'searchTerm': 'Bais,_Negros_Oriental',
    'title': '돌고래 투어',
    'description': '타농 해협에서 돌고래와 고래를 볼 수 있는 투어입니다.',
    'city': 'Bais',
    'province': 'Negros Oriental',
    'icon': 'dolphin',
    'category': '수상스포츠',
  },
  {
    'name': '만주요드 샌드바',
    'englishName': 'Manjuyod Sandbar',
    'searchTerm': 'Manjuyod_White_Sandbar',
    'title': '필리핀의 몰디브',
    'description': '네그로스의 아름다운 샌드바로 필리핀의 몰디브로 불립니다.',
    'city': 'Manjuyod',
    'province': 'Negros Oriental',
    'icon': 'beach',
    'category': '해변',
  },

  // 시부얀 해 관련
  {
    'name': '바이스 샌드바',
    'englishName': 'Bais Sandbar',
    'searchTerm': 'Bais,_Negros_Oriental',
    'title': '숨겨진 샌드바',
    'description': '바이스 시티 근처의 아름다운 샌드바입니다.',
    'city': 'Bais',
    'province': 'Negros Oriental',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '아포 섬',
    'englishName': 'Apo Island',
    'searchTerm': 'Apo_Island_(Negros_Oriental)',
    'title': '거북이의 섬',
    'description': '바다거북과 함께 수영할 수 있는 해양 보호구역입니다.',
    'city': 'Dauin',
    'province': 'Negros Oriental',
    'icon': 'turtle',
    'category': '섬',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 배치 4: 세부 남부 지역 여행지 추가');
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

  for (final spot in batch4Spots) {
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
      imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Oslob_whale_sharks.jpg/800px-Oslob_whale_sharks.jpg';
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
  print('📊 배치 4 결과 요약');
  print('======================================');
  print('✅ 추가됨: $added개');
  print('⏭️  건너뜀: $skipped개');
  print('📊 현재 총 개수: ${travelSpots.length}개');
}
