// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 5: 보홀 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch5_bohol.dart
/// ```

// 보홀 지역 여행지 데이터
final List<Map<String, dynamic>> batch5Spots = [
  // 초콜릿 힐 관련
  {
    'name': '초콜릿 힐 전망대',
    'englishName': 'Chocolate Hills Viewpoint',
    'searchTerm': 'Chocolate_Hills',
    'title': '1,268개의 원뿔 언덕',
    'description': '보홀의 상징적인 지형으로 건기에 초콜릿색으로 변하는 언덕들입니다.',
    'city': 'Carmen',
    'province': 'Bohol',
    'icon': 'hill',
    'category': '자연',
  },
  {
    'name': '초콜릿 힐 ATV',
    'englishName': 'Chocolate Hills ATV Adventure',
    'searchTerm': 'Chocolate_Hills',
    'title': 'ATV 어드벤처',
    'description': '초콜릿 힐 주변을 ATV로 탐험하는 인기 액티비티입니다.',
    'city': 'Carmen',
    'province': 'Bohol',
    'icon': 'adventure',
    'category': '자연',
  },
  {
    'name': '사그바얀 피크',
    'englishName': 'Sagbayan Peak',
    'searchTerm': 'Chocolate_Hills',
    'title': '또 다른 전망대',
    'description': '초콜릿 힐을 볼 수 있는 또 다른 전망대로 놀이공원도 있습니다.',
    'city': 'Sagbayan',
    'province': 'Bohol',
    'icon': 'viewpoint',
    'category': '자연',
  },

  // 타르시어 관련
  {
    'name': '타르시어 보호구역',
    'englishName': 'Tarsier Sanctuary',
    'searchTerm': 'Philippine_tarsier',
    'title': '세계 최소 영장류',
    'description': '보홀의 상징인 타르시어를 자연 환경에서 볼 수 있는 보호구역입니다.',
    'city': 'Corella',
    'province': 'Bohol',
    'icon': 'animal',
    'category': '자연',
  },
  {
    'name': '타르시어 연구센터',
    'englishName': 'Philippine Tarsier Research Center',
    'searchTerm': 'Philippine_tarsier',
    'title': '타르시어 연구 시설',
    'description': '타르시어 보존 및 연구를 위한 시설로 교육 프로그램도 운영합니다.',
    'city': 'Loboc',
    'province': 'Bohol',
    'icon': 'animal',
    'category': '자연',
  },

  // 로복 강 관련
  {
    'name': '로복 강',
    'englishName': 'Loboc River',
    'searchTerm': 'Loboc_River',
    'title': '에메랄드빛 강',
    'description': '보홀의 아름다운 강으로 크루즈 투어가 유명합니다.',
    'city': 'Loboc',
    'province': 'Bohol',
    'icon': 'river',
    'category': '자연',
  },
  {
    'name': '로복 에코 파크',
    'englishName': 'Loboc Eco Tourism Park',
    'searchTerm': 'Loboc,_Bohol',
    'title': '짚라인 어드벤처',
    'description': '로복 강 위를 가로지르는 짚라인으로 유명한 에코 파크입니다.',
    'city': 'Loboc',
    'province': 'Bohol',
    'icon': 'adventure',
    'category': '자연',
  },
  {
    'name': '수플라이드 케이브',
    'englishName': 'SUP Loboc River',
    'searchTerm': 'Loboc_River',
    'title': '스탠드업 패들보드',
    'description': '로복 강에서 즐기는 스탠드업 패들보드 체험입니다.',
    'city': 'Loboc',
    'province': 'Bohol',
    'icon': 'paddle',
    'category': '수상스포츠',
  },

  // 팡라오 섬 관련
  {
    'name': '팡라오 섬',
    'englishName': 'Panglao Island',
    'searchTerm': 'Panglao_Island',
    'title': '보홀의 해변 천국',
    'description': '보홀 본섬과 다리로 연결된 섬으로 아름다운 해변이 많습니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '알로나 비치',
    'englishName': 'Alona Beach',
    'searchTerm': 'Alona_Beach',
    'title': '팡라오의 메인 비치',
    'description': '팡라오에서 가장 유명한 해변으로 다이빙 센터와 레스토랑이 많습니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '두말룽 비치',
    'englishName': 'Dumaluan Beach',
    'searchTerm': 'Panglao_Island',
    'title': '긴 백사장',
    'description': '팡라오의 긴 백사장 해변으로 한적한 분위기입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '돌조 비치',
    'englishName': 'Doljo Beach',
    'searchTerm': 'Panglao_Island',
    'title': '로컬 해변',
    'description': '팡라오 북쪽의 조용한 해변으로 현지인들이 많이 찾습니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '비킹 비치',
    'englishName': 'Bikini Beach',
    'searchTerm': 'Panglao_Island',
    'title': '작은 해변',
    'description': '팡라오의 작고 아늑한 해변입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '힐나그다난 동굴 팡라오',
    'englishName': 'Hinagdanan Cave Panglao',
    'searchTerm': 'Hinagdanan_Cave',
    'title': '동굴 수영장',
    'description': '팡라오의 석회암 동굴로 내부에 천연 수영장이 있습니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '벌플라이 가든',
    'englishName': 'Bohol Butterfly Garden',
    'searchTerm': 'Bohol',
    'title': '나비 정원',
    'description': '다양한 나비 종을 볼 수 있는 보홀의 나비 정원입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'butterfly',
    'category': '자연',
  },

  // 보홀 다이빙/스노클링
  {
    'name': '발리카삭 섬',
    'englishName': 'Balicasag Island',
    'searchTerm': 'Balicasag_Island',
    'title': '다이빙 천국',
    'description': '보홀 최고의 다이빙 포인트로 바다거북과 풍부한 산호가 있습니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'diving',
    'category': '섬',
  },
  {
    'name': '돌핀 워칭 보홀',
    'englishName': 'Bohol Dolphin Watching',
    'searchTerm': 'Bohol',
    'title': '돌고래 투어',
    'description': '팡라오에서 출발하는 돌고래 워칭 투어입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'dolphin',
    'category': '수상스포츠',
  },
  {
    'name': '팡라오 해양보호구역',
    'englishName': 'Panglao Marine Sanctuary',
    'searchTerm': 'Panglao_Island',
    'title': '스노클링 명소',
    'description': '팡라오의 해양 보호구역으로 스노클링에 적합합니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'snorkeling',
    'category': '수상스포츠',
  },
  {
    'name': '파밀라칸 섬',
    'englishName': 'Pamilacan Island',
    'searchTerm': 'Pamilacan_Island',
    'title': '고래/돌고래 워칭',
    'description': '돌고래와 고래를 볼 수 있는 보홀의 작은 섬입니다.',
    'city': 'Baclayon',
    'province': 'Bohol',
    'icon': 'whale',
    'category': '섬',
  },

  // 안다/칸디자이 지역
  {
    'name': '안다 비치',
    'englishName': 'Anda Beach',
    'searchTerm': 'Anda,_Bohol',
    'title': '숨겨진 해변',
    'description': '보홀 동쪽의 한적한 해변 마을로 자연 그대로의 아름다움이 있습니다.',
    'city': 'Anda',
    'province': 'Bohol',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '퀸존 비치 안다',
    'englishName': 'Quinale Beach Anda',
    'searchTerm': 'Anda,_Bohol',
    'title': '긴 백사장',
    'description': '안다 지역의 긴 백사장 해변입니다.',
    'city': 'Anda',
    'province': 'Bohol',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '안다 풀',
    'englishName': 'Anda Pools',
    'searchTerm': 'Anda,_Bohol',
    'title': '자연 수영장',
    'description': '안다의 천연 수영장으로 맑은 물이 특징입니다.',
    'city': 'Anda',
    'province': 'Bohol',
    'icon': 'pool',
    'category': '자연',
  },
  {
    'name': '칸디자이 동굴',
    'englishName': 'Candijay Caves',
    'searchTerm': 'Bohol',
    'title': '탐험 동굴',
    'description': '보홀 동부의 동굴 시스템으로 탐험이 가능합니다.',
    'city': 'Candijay',
    'province': 'Bohol',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '라일라 비치',
    'englishName': 'Laila Beach',
    'searchTerm': 'Anda,_Bohol',
    'title': '프라이빗 해변',
    'description': '안다의 작은 프라이빗 해변입니다.',
    'city': 'Anda',
    'province': 'Bohol',
    'icon': 'beach',
    'category': '해변',
  },

  // 보홀 본섬 명소
  {
    'name': '바클레이온 교회',
    'englishName': 'Baclayon Church',
    'searchTerm': 'Baclayon_Church',
    'title': '필리핀 최고 교회',
    'description': '1595년에 건설된 필리핀에서 가장 오래된 석조 교회 중 하나입니다.',
    'city': 'Baclayon',
    'province': 'Bohol',
    'icon': 'church',
    'category': '자연',
  },
  {
    'name': '혈맹 기념비',
    'englishName': 'Blood Compact Shrine',
    'searchTerm': 'Blood_compact',
    'title': '역사적 기념물',
    'description': '스페인과 필리핀 추장 간의 혈맹을 기념하는 장소입니다.',
    'city': 'Tagbilaran',
    'province': 'Bohol',
    'icon': 'monument',
    'category': '자연',
  },
  {
    'name': '맨메이드 포레스트',
    'englishName': 'Man Made Forest',
    'searchTerm': 'Man_Made_Forest_(Bohol)',
    'title': '마호가니 숲',
    'description': '2km에 걸친 마호가니 나무 터널로 사진 명소입니다.',
    'city': 'Bilar',
    'province': 'Bohol',
    'icon': 'forest',
    'category': '자연',
  },
  {
    'name': '시파탄 트윈 폭포',
    'englishName': 'Sipatan Twin Falls',
    'searchTerm': 'Bohol',
    'title': '쌍둥이 폭포',
    'description': '보홀 내륙의 아름다운 쌍둥이 폭포입니다.',
    'city': 'Dimiao',
    'province': 'Bohol',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '칸우망 폭포',
    'englishName': 'Can-umantad Falls',
    'searchTerm': 'Bohol',
    'title': '보홀 최대 폭포',
    'description': '보홀에서 가장 높은 폭포로 약 60m 높이입니다.',
    'city': 'Candijay',
    'province': 'Bohol',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '마그 아소 폭포',
    'englishName': 'Mag-Aso Falls',
    'searchTerm': 'Bohol',
    'title': '연기 나는 폭포',
    'description': '이름이 "연기 나는"을 의미하는 아름다운 폭포입니다.',
    'city': 'Antequera',
    'province': 'Bohol',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 추가 보홀 섬
  {
    'name': '시케이호르 바지 다이브',
    'englishName': 'Siquijor Bohol Dive',
    'searchTerm': 'Bohol',
    'title': '보홀-시키호르 다이빙',
    'description': '보홀에서 시키호르까지 이어지는 다이빙 사파리입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '보홀 비 팜',
    'englishName': 'Bohol Bee Farm',
    'searchTerm': 'Bohol',
    'title': '유기농 리조트',
    'description': '유기농 농장과 리조트가 결합된 에코 관광 명소입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'farm',
    'category': '자연',
  },
  {
    'name': '헤난 리조트 보홀',
    'englishName': 'Henann Resort Bohol',
    'searchTerm': 'Panglao_Island',
    'title': '프리미엄 리조트',
    'description': '알로나 비치의 대표적인 리조트입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'resort',
    'category': '해변',
  },
  {
    'name': '모파스 록',
    'englishName': 'Mophas Rock',
    'searchTerm': 'Bohol',
    'title': '암석 형성',
    'description': '보홀의 독특한 암석 형성물입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'rock',
    'category': '자연',
  },

  // 보홀 주변 섬들
  {
    'name': '포콕 섬',
    'englishName': 'Pocok Island',
    'searchTerm': 'Bohol',
    'title': '작은 섬 호핑',
    'description': '보홀 아일랜드 호핑 코스의 작은 섬입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '보홀 씨바나',
    'englishName': 'Bohol Sea Banana',
    'searchTerm': 'Bohol',
    'title': '바나나 보트',
    'description': '팡라오 해변에서 즐기는 바나나 보트 액티비티입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'boat',
    'category': '수상스포츠',
  },
  {
    'name': '카아테드랄 동굴',
    'englishName': 'Cathedral Cave',
    'searchTerm': 'Bohol',
    'title': '대성당 동굴',
    'description': '보홀의 인상적인 석회암 동굴로 대성당 같은 내부가 특징입니다.',
    'city': 'Anda',
    'province': 'Bohol',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '다우이스 교회',
    'englishName': 'Dauis Church',
    'searchTerm': 'Dauis',
    'title': '기적의 우물',
    'description': '교회 바닥 아래에 기적의 우물이 있는 것으로 유명한 교회입니다.',
    'city': 'Dauis',
    'province': 'Bohol',
    'icon': 'church',
    'category': '자연',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 배치 5: 보홀 지역 여행지 추가');
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

  for (final spot in batch5Spots) {
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

    // 이미지가 없으면 기본 보홀 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Bohol_Chocolate_Hills.jpg/800px-Bohol_Chocolate_Hills.jpg';
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
  print('📊 배치 5 결과 요약');
  print('======================================');
  print('✅ 추가됨: $added개');
  print('⏭️  건너뜀: $skipped개');
  print('📊 현재 총 개수: ${travelSpots.length}개');
}
