// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 9: 레이테/사마르 지역 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch9_leyte.dart
/// ```

// 레이테/사마르 지역 여행지 데이터
final List<Map<String, dynamic>> batch9Spots = [
  // 레이테 지역
  {
    'name': '타클로반 시티',
    'englishName': 'Tacloban City',
    'searchTerm': 'Tacloban',
    'title': '레이테의 수도',
    'description': '레이테 주의 수도로 역사적 명소와 현대적 시설이 공존합니다.',
    'city': 'Tacloban',
    'province': 'Leyte',
    'icon': 'city',
    'category': '자연',
  },
  {
    'name': '산 후아니코 다리',
    'englishName': 'San Juanico Bridge',
    'searchTerm': 'San_Juanico_Bridge',
    'title': '필리핀 최장 다리',
    'description': '레이테와 사마르를 연결하는 필리핀에서 가장 긴 다리입니다.',
    'city': 'Tacloban',
    'province': 'Leyte',
    'icon': 'bridge',
    'category': '자연',
  },
  {
    'name': '레드비치',
    'englishName': 'Red Beach Leyte',
    'searchTerm': 'Battle_of_Leyte',
    'title': '맥아더 상륙지',
    'description': '2차 세계대전 맥아더 장군의 상륙 역사 현장입니다.',
    'city': 'Palo',
    'province': 'Leyte',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '톤토난 온천',
    'englishName': 'Tontonan Hot Springs',
    'searchTerm': 'Leyte',
    'title': '천연 온천',
    'description': '레이테의 천연 온천으로 지열 활동이 활발한 지역입니다.',
    'city': 'Ormoc',
    'province': 'Leyte',
    'icon': 'hotspring',
    'category': '자연',
  },
  {
    'name': '오르목 시티',
    'englishName': 'Ormoc City',
    'searchTerm': 'Ormoc',
    'title': '레이테의 도시',
    'description': '레이테 서쪽의 주요 도시로 세부행 페리가 있습니다.',
    'city': 'Ormoc',
    'province': 'Leyte',
    'icon': 'city',
    'category': '자연',
  },
  {
    'name': '레이크 다나오 레이테',
    'englishName': 'Lake Danao Leyte',
    'searchTerm': 'Lake_Danao_(Leyte)',
    'title': '바이올린 모양 호수',
    'description': '레이테의 화산 호수로 바이올린 모양이 특징입니다.',
    'city': 'Ormoc',
    'province': 'Leyte',
    'icon': 'lake',
    'category': '자연',
  },
  {
    'name': '팔롬폰',
    'englishName': 'Palompon',
    'searchTerm': 'Palompon',
    'title': '칼랑가만 가는 항구',
    'description': '칼랑가만 섬으로 가는 보트를 탈 수 있는 항구 마을입니다.',
    'city': 'Palompon',
    'province': 'Leyte',
    'icon': 'port',
    'category': '자연',
  },
  {
    'name': '빌리란 섬',
    'englishName': 'Biliran Island',
    'searchTerm': 'Biliran',
    'title': '숨겨진 섬',
    'description': '레이테 북쪽의 작은 섬으로 폭포와 해변이 아름답습니다.',
    'city': 'Naval',
    'province': 'Biliran',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '카시빌란 폭포',
    'englishName': 'Kasibilan Falls',
    'searchTerm': 'Biliran',
    'title': '빌리란 폭포',
    'description': '빌리란 섬의 아름다운 폭포입니다.',
    'city': 'Caibiran',
    'province': 'Biliran',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '티나고 폭포 빌리란',
    'englishName': 'Tinago Falls Biliran',
    'searchTerm': 'Biliran',
    'title': '숨겨진 폭포',
    'description': '빌리란 섬의 숨겨진 폭포입니다.',
    'city': 'Caibiran',
    'province': 'Biliran',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '아가타스 폭포',
    'englishName': 'Agtas Falls',
    'searchTerm': 'Biliran',
    'title': '빌리란 트윈 폭포',
    'description': '빌리란 섬의 쌍둥이 폭포입니다.',
    'city': 'Biliran',
    'province': 'Biliran',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '삼버노안 해변',
    'englishName': 'Sambawan Island',
    'searchTerm': 'Biliran',
    'title': '핑크 비치',
    'description': '빌리란 근처의 작은 섬으로 핑크빛 모래가 특징입니다.',
    'city': 'Maripipi',
    'province': 'Biliran',
    'icon': 'beach',
    'category': '해변',
  },

  // 사마르 지역
  {
    'name': '사마르 섬',
    'englishName': 'Samar Island',
    'searchTerm': 'Samar',
    'title': '필리핀 3번째 큰 섬',
    'description': '필리핀에서 세 번째로 큰 섬으로 자연 그대로의 모습을 간직합니다.',
    'city': 'Catbalogan',
    'province': 'Samar',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '소호톤 내츄럴 브릿지',
    'englishName': 'Sohoton Natural Bridge',
    'searchTerm': 'Sohoton_Natural_Bridge_National_Park',
    'title': '천연 다리',
    'description': '사마르의 국립공원으로 석회암 동굴과 라군이 있습니다.',
    'city': 'Basey',
    'province': 'Samar',
    'icon': 'nature',
    'category': '자연',
  },
  {
    'name': '칼발로간 시티',
    'englishName': 'Catbalogan City',
    'searchTerm': 'Catbalogan',
    'title': '사마르의 수도',
    'description': '사마르 주의 수도로 행정과 상업의 중심입니다.',
    'city': 'Catbalogan',
    'province': 'Samar',
    'icon': 'city',
    'category': '자연',
  },
  {
    'name': '보롱간 서핑',
    'englishName': 'Borongan Surfing',
    'searchTerm': 'Borongan',
    'title': '동부 사마르 서핑',
    'description': '동부 사마르의 서핑 명소로 큰 파도가 특징입니다.',
    'city': 'Borongan',
    'province': 'Eastern Samar',
    'icon': 'surfing',
    'category': '수상스포츠',
  },
  {
    'name': '칸이곤 폭포',
    'englishName': 'Can-Igon Falls',
    'searchTerm': 'Samar',
    'title': '사마르 폭포',
    'description': '사마르 섬의 아름다운 폭포입니다.',
    'city': 'Catbalogan',
    'province': 'Samar',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '라오잉 폭포',
    'englishName': 'Laoang Falls',
    'searchTerm': 'Northern_Samar',
    'title': '북부 사마르 폭포',
    'description': '북부 사마르의 폭포입니다.',
    'city': 'Laoang',
    'province': 'Northern Samar',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '발리카사그 동굴',
    'englishName': 'Torpedo Boat Cave',
    'searchTerm': 'Samar',
    'title': '2차 대전 동굴',
    'description': '2차 세계대전 유적이 있는 사마르의 동굴입니다.',
    'city': 'Catbalogan',
    'province': 'Samar',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '울로트 리버 크루즈',
    'englishName': 'Ulot River Cruise',
    'searchTerm': 'Samar',
    'title': '강 크루즈',
    'description': '사마르의 울로트 강을 따라 가는 자연 크루즈입니다.',
    'city': 'Paranas',
    'province': 'Samar',
    'icon': 'river',
    'category': '자연',
  },

  // 추가 레이테/사마르 명소
  {
    'name': '레이테 다이빙',
    'englishName': 'Leyte Diving',
    'searchTerm': 'Leyte',
    'title': '레이테 해역 다이빙',
    'description': '레이테 주변의 다이빙 포인트입니다.',
    'city': 'Tacloban',
    'province': 'Leyte',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '마비니 레이테',
    'englishName': 'Mabini Leyte',
    'searchTerm': 'Leyte',
    'title': '마비니 해변',
    'description': '레이테 남부의 해변 마을입니다.',
    'city': 'Mabini',
    'province': 'Leyte',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '힌다강 동굴',
    'englishName': 'Hindang Cave',
    'searchTerm': 'Leyte',
    'title': '석회암 동굴',
    'description': '레이테의 석회암 동굴입니다.',
    'city': 'Hindang',
    'province': 'Leyte',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '칸기파이 폭포',
    'englishName': 'Cangipai Falls',
    'searchTerm': 'Leyte',
    'title': '레이테 폭포',
    'description': '레이테의 아름다운 폭포입니다.',
    'city': 'Ormoc',
    'province': 'Leyte',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '리마사와 섬',
    'englishName': 'Limasawa Island',
    'searchTerm': 'Limasawa',
    'title': '첫 미사 장소',
    'description': '필리핀에서 첫 가톨릭 미사가 열린 역사적 섬입니다.',
    'city': 'Limasawa',
    'province': 'Southern Leyte',
    'icon': 'island',
    'category': '섬',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 배치 9: 레이테/사마르 지역 여행지 추가');
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

  for (final spot in batch9Spots) {
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

    // 이미지가 없으면 기본 레이테 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/SanJuanicoBridge.jpg/800px-SanJuanicoBridge.jpg';
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
  print('📊 배치 9 결과 요약');
  print('======================================');
  print('✅ 추가됨: $added개');
  print('⏭️  건너뜀: $skipped개');
  print('📊 현재 총 개수: ${travelSpots.length}개');
}
