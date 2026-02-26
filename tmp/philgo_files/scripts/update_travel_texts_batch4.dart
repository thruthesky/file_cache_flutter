// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// 배치 4: 보라카이 관련 여행 정보 업데이트 스크립트
/// - [829] 스테이션 1 (Station 1 Boracay)
/// - [830] 스테이션 2 (Station 2 Boracay)
/// - [831] 스테이션 3 (Station 3 Boracay)
/// - [837] 보라카이 파라세일링 (Boracay Parasailing)
/// - [838] 보라카이 헬멧 다이빙 (Boracay Helmet Diving)

void main() {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final List<dynamic> spots = jsonDecode(jsonFile.readAsStringSync());

  //  print('총 여행지 수: ${spots.length}');

  // 업데이트할 데이터
  final Map<int, Map<String, dynamic>> updatesData = {
    // [829] 스테이션 1
    829: {
      'texts': [
        {
          'title': '럭셔리와 평화로움',
          'description':
              '스테이션 1은 보라카이 화이트 비치에서 가장 고급스럽고 한적한 구역입니다. 스테이션 2, 3에 비해 관광객이 적어 조용한 휴식을 원하는 여행자에게 이상적입니다. Discovery Shores, The Lind, Ambassador in Paradise 등 럭셔리 리조트가 위치해 있습니다.',
        },
        {
          'title': '최고의 해변',
          'description':
              '스테이션 1은 화이트 비치에서 가장 아름다운 구간으로, 상징적인 윌리스 록(Willys Rock) 성모상과 파란 돛의 파라우 보트가 늘어선 풍경을 볼 수 있습니다. 모래가 가장 곱고 해변이 넓어 여유로운 분위기를 즐길 수 있습니다.',
        },
        {
          'title': '파라세일링의 출발지',
          'description':
              '스테이션 1은 보라카이 파라세일링의 주요 출발지입니다. 석양 무렵 패러세일을 타고 하늘에서 보라카이 해안선을 감상하는 것은 잊지 못할 경험입니다.',
        },
        {
          'title': '주의사항',
          'description':
              '레스토랑이 많지 않아 식사 옵션이 제한적입니다. 다양한 음식과 쇼핑을 원한다면 도보로 스테이션 2의 D-Mall까지 이동하면 됩니다. 해변을 따라 세 스테이션 간 자유롭게 이동 가능합니다.',
        },
      ],
      'description':
          '보라카이 화이트 비치의 가장 고급스럽고 한적한 구역입니다. 윌리스 록 성모상, 파란 돛 파라우 보트가 있으며 럭셔리 리조트가 밀집해 있습니다. 파라세일링의 주요 출발지이기도 합니다.',
    },

    // [830] 스테이션 2
    830: {
      'texts': [
        {
          'title': '보라카이의 중심',
          'description':
              '스테이션 2는 보라카이에서 가장 활기찬 지역입니다. 쇼핑, 레스토랑, 나이트라이프의 중심지로, 많은 사람들이 모래사장 위를 걸어다니며 활기찬 분위기를 자아냅니다.',
        },
        {
          'title': 'D-Mall',
          'description':
              'D-Mall은 보라카이의 메인 야외 쇼핑몰입니다. 화이트 비치와 메인 도로 사이에 위치하며, 다양한 레스토랑, 카페, 기념품점, 마사지샵이 밀집해 있습니다. 밤에는 특히 많은 관광객으로 붐빕니다.',
        },
        {
          'title': '숙박 옵션',
          'description':
              '중급 호텔부터 저렴한 게스트하우스까지 다양한 숙박시설이 있습니다. 스테이션 1, 2의 모래가 스테이션 3보다 곱습니다. 편의시설과 해변 품질의 균형을 원한다면 스테이션 2가 최선의 선택입니다.',
        },
        {
          'title': '접근성',
          'description':
              '보라카이의 중심부에 위치해 어디든 이동하기 편리합니다. 각종 워터스포츠 예약, 투어 예약도 이 지역에서 쉽게 할 수 있습니다.',
        },
      ],
      'description':
          '보라카이의 가장 활기찬 중심 지역으로 D-Mall 쇼핑몰이 위치해 있습니다. 레스토랑, 나이트라이프, 쇼핑을 즐기기에 최적이며 다양한 숙박시설과 워터스포츠 예약이 가능합니다.',
    },

    // [831] 스테이션 3
    831: {
      'texts': [
        {
          'title': '여유로운 분위기',
          'description':
              '스테이션 3은 보라카이에서 가장 한적하고 느긋한 분위기의 지역입니다. 사람이 적고 조용해서 번잡함을 피하고 싶은 여행자에게 적합합니다. 특히 Angol 지역은 매우 평화롭습니다.',
        },
        {
          'title': '예산 친화적',
          'description':
              '예산이 중요하다면 스테이션 3을 고려하세요. 저렴한 호텔, 인, 아파트, 게스트하우스를 쉽게 찾을 수 있습니다. 불라복 비치나 내륙 지역도 저렴한 숙소가 많습니다.',
        },
        {
          'title': '모래 품질',
          'description':
              '스테이션 1, 2에 비해 모래가 약간 거칩니다. 하지만 여전히 아름다운 화이트 비치의 일부이며, 해변을 따라 스테이션 1, 2까지 자유롭게 걸어갈 수 있습니다.',
        },
        {
          'title': '레스토랑과 편의시설',
          'description':
              '레스토랑과 상점이 상대적으로 적습니다. 식사나 쇼핑을 위해 스테이션 2까지 이동해야 할 수 있습니다. 하지만 조용한 저녁 시간을 원한다면 완벽한 선택입니다.',
        },
      ],
      'description':
          '보라카이 화이트 비치의 가장 한적하고 예산 친화적인 구역입니다. 저렴한 숙박시설이 많고 조용한 분위기를 즐길 수 있습니다. 해변을 따라 다른 스테이션으로 쉽게 이동 가능합니다.',
    },

    // [837] 보라카이 파라세일링
    837: {
      'texts': [
        {
          'title': '액티비티 개요',
          'description':
              '파라세일링은 보라카이의 대표 워터스포츠입니다. 스피드보트에 연결된 패러슈트를 타고 하늘로 올라가 보라카이 해안선과 청록색 바다의 파노라마 전경을 감상합니다. 혼자 또는 2인 탠덤으로 즐길 수 있습니다.',
        },
        {
          'title': '가격 및 시간',
          'description':
              '가격은 1인당 약 46달러(2,500페소)부터 시작합니다. 비행 시간은 약 15분이며, 24시간 전까지 무료 취소가 가능합니다. 운영 시간은 오전 9시~오후 5시(마지막 탑승 오후 4시)입니다.',
        },
        {
          'title': '포함 사항',
          'description':
              '스테이션 1~3 내 호텔 픽업, 보트 이동, 파라세일링 장비, 구명조끼, 코디네이터 지원이 포함됩니다. 탠덤의 경우 2인 합산 체중 200kg 제한이 있습니다.',
        },
        {
          'title': '주의사항',
          'description':
              '6세 이상 참여 가능하며, 체중 제한은 1인당 약 90kg입니다. 임산부, 허리 질환자, 수영 불가자, 멀미가 심한 분은 권장하지 않습니다. 편한 옷을 입고 슬리퍼나 헐거운 안경은 피하세요.',
        },
      ],
      'description':
          '보라카이 대표 워터스포츠로 15분간 하늘에서 해안선 파노라마를 감상합니다. 스테이션 1에서 주로 출발하며, 솔로 또는 탠덤으로 즐길 수 있습니다. 석양 시간대가 가장 인기 있습니다.',
    },

    // [838] 보라카이 헬멧 다이빙
    838: {
      'texts': [
        {
          'title': '액티비티 개요',
          'description':
              '헬멧 다이빙은 수영을 못하거나 스쿠버 장비가 부담스러운 분들을 위한 수중 체험입니다. 투명 유리창이 달린 헬멧을 쓰고 수심 3m의 바다 바닥을 걸으며 해양 생물을 가까이서 관찰합니다.',
        },
        {
          'title': '체험 방식',
          'description':
              '스피드보트로 다이빙 포인트까지 이동 후, 사다리를 타고 내려갑니다. 헬멧에는 압축 공기가 지속적으로 공급되어 코와 입으로 자연스럽게 호흡할 수 있습니다. 다이빙 강사가 항상 동행합니다.',
        },
        {
          'title': '가격 및 시간',
          'description':
              '가격은 1인당 약 18~20달러(1,000페소) 정도입니다. 총 소요 시간은 약 40분이며, 실제 수중 체험은 약 15~20분입니다. 무료 수중 사진과 동영상이 제공됩니다.',
        },
        {
          'title': '안전 정보',
          'description':
              '12세부터 80세까지 참여 가능하며 다이빙 자격증이 필요 없습니다. 헬멧은 물 밖에서 11kg, 물 속에서 2kg으로 가벼워집니다. 고혈압, 간질, 심장질환이 있는 분과 임산부는 참여 제한됩니다.',
        },
      ],
      'description':
          '수영을 못해도 즐길 수 있는 수중 체험 액티비티입니다. 공기가 공급되는 헬멧을 쓰고 수심 3m 바다 바닥을 걸으며 열대어와 산호를 관찰합니다. PADI 강사가 동행하여 안전합니다.',
    },
  };

  int updatedCount = 0;

  for (final entry in updatesData.entries) {
    final index = entry.key;
    final updateData = entry.value;

    if (index < spots.length) {
      final spot = spots[index] as Map<String, dynamic>;
      final name = spot['name'] ?? '(이름 없음)';

      //      print('\n[$index] $name 업데이트 중...');

      // texts 업데이트
      if (updateData.containsKey('texts')) {
        spot['texts'] = updateData['texts'];
        //        print('  - texts: ${(updateData['texts'] as List).length}개 항목');
      }

      // description 업데이트
      if (updateData.containsKey('description')) {
        spot['description'] = updateData['description'];
        //        print('  - description 업데이트 완료');
      }

      updatedCount++;
    } else {
      //      print('\n⚠️ 인덱스 $index가 범위를 벗어났습니다.');
    }
  }

  // JSON 파일 저장
  final encoder = JsonEncoder.withIndent('    ');
  jsonFile.writeAsStringSync(encoder.convert(spots));

  //  print('\n${'=' * 50}');
  //  print('✅ 업데이트 완료: $updatedCount개 항목');
  //  print('=' * 50);
}
