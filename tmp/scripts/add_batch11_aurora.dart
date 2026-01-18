// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 11: 오로라/카가얀 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch11_aurora.dart
/// ```

// 오로라/카가얀/북부 루손 지역 여행지 데이터
final List<Map<String, dynamic>> batch11Spots = [
  // 오로라 지역 (서핑)
  {
    'name': '발레르 서핑',
    'englishName': 'Baler Surfing',
    'searchTerm': 'Baler,_Aurora',
    'title': '필리핀 서핑의 발상지',
    'description': '필리핀 서핑 문화의 발상지로 서퍼들의 성지입니다.',
    'city': 'Baler',
    'province': 'Aurora',
    'icon': 'surfing',
    'category': '수상스포츠',
  },
  {
    'name': '사방가 비치',
    'englishName': 'Sabang Beach Baler',
    'searchTerm': 'Baler,_Aurora',
    'title': '발레르 메인 서핑 비치',
    'description': '발레르의 메인 서핑 해변으로 서핑 스쿨이 많습니다.',
    'city': 'Baler',
    'province': 'Aurora',
    'icon': 'surfing',
    'category': '해변',
  },
  {
    'name': '세뮬 포인트',
    'englishName': 'Cemento Point',
    'searchTerm': 'Baler,_Aurora',
    'title': '상급자 서핑 포인트',
    'description': '발레르의 상급자용 서핑 포인트입니다.',
    'city': 'Baler',
    'province': 'Aurora',
    'icon': 'surfing',
    'category': '수상스포츠',
  },
  {
    'name': '디카솔 폭포',
    'englishName': 'Ditumabo Falls',
    'searchTerm': 'Ditumabo_Falls',
    'title': '마더 폭포',
    'description': '발레르 근처의 웅장한 폭포로 트레킹이 필요합니다.',
    'city': 'San Luis',
    'province': 'Aurora',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '담밤 폭포',
    'englishName': 'Dambang Falls',
    'searchTerm': 'Aurora_(province)',
    'title': '오로라 폭포',
    'description': '오로라의 아름다운 폭포입니다.',
    'city': 'Dipaculao',
    'province': 'Aurora',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '딜리앙 비치',
    'englishName': 'Dingalan Beach',
    'searchTerm': 'Dingalan,_Aurora',
    'title': '숨겨진 서핑 비치',
    'description': '오로라 남부의 한적한 서핑 해변입니다.',
    'city': 'Dingalan',
    'province': 'Aurora',
    'icon': 'surfing',
    'category': '해변',
  },

  // 카가얀/바타네스 지역
  {
    'name': '바타네스',
    'englishName': 'Batanes',
    'searchTerm': 'Batanes',
    'title': '필리핀의 뉴질랜드',
    'description': '필리핀 최북단의 섬으로 독특한 자연 경관이 특징입니다.',
    'city': 'Basco',
    'province': 'Batanes',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '바탄 섬',
    'englishName': 'Batan Island',
    'searchTerm': 'Batan_Island,_Philippines',
    'title': '바타네스 메인 섬',
    'description': '바타네스의 가장 큰 섬으로 주도 바스코가 있습니다.',
    'city': 'Basco',
    'province': 'Batanes',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '사브탕 섬',
    'englishName': 'Sabtang Island',
    'searchTerm': 'Sabtang',
    'title': '전통 마을',
    'description': '바타네스의 섬으로 전통 이바탄 가옥이 보존되어 있습니다.',
    'city': 'Sabtang',
    'province': 'Batanes',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '발루가스 베이',
    'englishName': 'Valugan Boulder Beach',
    'searchTerm': 'Batanes',
    'title': '둥근 바위 해변',
    'description': '바타네스의 독특한 둥근 바위 해변입니다.',
    'city': 'Basco',
    'province': 'Batanes',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '라크노이 언덕',
    'englishName': 'Racuh a Payaman',
    'searchTerm': 'Batanes',
    'title': '말보로 컨트리',
    'description': '광고에 나올 법한 푸른 초원 언덕입니다.',
    'city': 'Mahatao',
    'province': 'Batanes',
    'icon': 'hill',
    'category': '자연',
  },
  {
    'name': '바스코 등대',
    'englishName': 'Naidi Hills Lighthouse',
    'searchTerm': 'Batanes',
    'title': '바스코 전망대',
    'description': '바스코 시내를 내려다볼 수 있는 등대 전망대입니다.',
    'city': 'Basco',
    'province': 'Batanes',
    'icon': 'lighthouse',
    'category': '자연',
  },
  {
    'name': '푼탄 비치',
    'englishName': 'Fundacion Pacita',
    'searchTerm': 'Batanes',
    'title': '예술가의 휴식처',
    'description': '바타네스의 예술적인 숙소이자 전망 명소입니다.',
    'city': 'Basco',
    'province': 'Batanes',
    'icon': 'viewpoint',
    'category': '자연',
  },

  // 일로코스 지역
  {
    'name': '파라오아케 샌드 듄',
    'englishName': 'Paoay Sand Dunes',
    'searchTerm': 'Paoay_Sand_Dunes',
    'title': '모래 언덕',
    'description': '일로코스의 사막 같은 모래 언덕으로 ATV가 유명합니다.',
    'city': 'Paoay',
    'province': 'Ilocos Norte',
    'icon': 'desert',
    'category': '자연',
  },
  {
    'name': '비간 시티',
    'englishName': 'Vigan City',
    'searchTerm': 'Vigan',
    'title': '스페인 식민지 도시',
    'description': '유네스코 세계문화유산으로 스페인 시대 건물이 보존되어 있습니다.',
    'city': 'Vigan',
    'province': 'Ilocos Sur',
    'icon': 'city',
    'category': '자연',
  },
  {
    'name': '파가다 비치',
    'englishName': 'Pagudpud Beach',
    'searchTerm': 'Pagudpud',
    'title': '일로코스의 보라카이',
    'description': '일로코스 북부의 아름다운 해변으로 화이트 비치가 있습니다.',
    'city': 'Pagudpud',
    'province': 'Ilocos Norte',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '사우드 비치',
    'englishName': 'Saud Beach',
    'searchTerm': 'Pagudpud',
    'title': '백사장 해변',
    'description': '파구드푸드의 유명한 백사장 해변입니다.',
    'city': 'Pagudpud',
    'province': 'Ilocos Norte',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '블루 라군 파구드푸드',
    'englishName': 'Blue Lagoon Pagudpud',
    'searchTerm': 'Pagudpud',
    'title': '청색 라군',
    'description': '파구드푸드의 맑고 푸른 바다 라군입니다.',
    'city': 'Pagudpud',
    'province': 'Ilocos Norte',
    'icon': 'lagoon',
    'category': '자연',
  },
  {
    'name': '방귀 풍력발전소',
    'englishName': 'Bangui Windmills',
    'searchTerm': 'Bangui_Wind_Farm',
    'title': '풍력발전 단지',
    'description': '필리핀 최초의 풍력발전 단지로 관광 명소입니다.',
    'city': 'Bangui',
    'province': 'Ilocos Norte',
    'icon': 'windmill',
    'category': '자연',
  },
  {
    'name': '카푸리얀 등대',
    'englishName': 'Cape Bojeador Lighthouse',
    'searchTerm': 'Cape_Bojeador_Lighthouse',
    'title': '역사적 등대',
    'description': '1892년에 지어진 스페인 시대 등대입니다.',
    'city': 'Burgos',
    'province': 'Ilocos Norte',
    'icon': 'lighthouse',
    'category': '자연',
  },

  // 카가얀 밸리
  {
    'name': '카요 섬',
    'englishName': 'Cagayan Valley',
    'searchTerm': 'Cagayan_Valley',
    'title': '카가얀 밸리',
    'description': '루손 북동부의 광활한 계곡 지역입니다.',
    'city': 'Tuguegarao',
    'province': 'Cagayan',
    'icon': 'valley',
    'category': '자연',
  },
  {
    'name': '파라파이쿠 동굴',
    'englishName': 'Callao Cave',
    'searchTerm': 'Callao_Cave',
    'title': '대성당 동굴',
    'description': '대성당 모양의 거대한 석회암 동굴입니다.',
    'city': 'Penablanca',
    'province': 'Cagayan',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '팔루이 섬',
    'englishName': 'Palaui Island',
    'searchTerm': 'Palaui_Island',
    'title': '자연 그대로의 섬',
    'description': '카가얀 끝의 섬으로 자연 그대로 보존되어 있습니다.',
    'city': 'Santa Ana',
    'province': 'Cagayan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '엔가노 등대',
    'englishName': 'Cape Engano Lighthouse',
    'searchTerm': 'Palaui_Island',
    'title': '팔루이 등대',
    'description': '팔루이 섬의 역사적인 등대입니다.',
    'city': 'Santa Ana',
    'province': 'Cagayan',
    'icon': 'lighthouse',
    'category': '자연',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 배치 11: 오로라/카가얀 지역 여행지 추가');
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

  for (final spot in batch11Spots) {
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

    // 이미지가 없으면 기본 바타네스 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Basco_Lighthouse.jpg/800px-Basco_Lighthouse.jpg';
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
  print('📊 배치 11 결과 요약');
  print('======================================');
  print('✅ 추가됨: $added개');
  print('⏭️  건너뜀: $skipped개');
  print('📊 현재 총 개수: ${travelSpots.length}개');
}
