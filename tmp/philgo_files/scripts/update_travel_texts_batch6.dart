// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// 배치 6: 보라카이 추가 액티비티 업데이트 스크립트
/// - [844] 보라카이 제트스키 (Boracay Jet Ski)
/// - [848] 보라카이 나이트라이프 (Boracay D'Mall)
/// - [988] 보라카이 스탠드업패들 (Boracay SUP)
/// - [989] 보라카이 웨이크보드 (Boracay Wakeboard)
/// - [990] 보라카이 스노클링 (Boracay Snorkeling)

void main() {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final List<dynamic> spots = jsonDecode(jsonFile.readAsStringSync());

  //  print('총 여행지 수: ${spots.length}');

  // 업데이트할 데이터
  final Map<int, Map<String, dynamic>> updatesData = {
    // [844] 보라카이 제트스키
    844: {
      'texts': [
        {
          'title': '액티비티 개요',
          'description':
              '제트스키는 보라카이의 인기 워터스포츠로, 청록색 바다 위를 스릴 넘치게 질주하는 경험을 제공합니다. 화이트 비치와 불라복 비치에서 즐길 수 있으며, 초보자도 쉽게 참여할 수 있습니다.',
        },
        {
          'title': '가격 정보',
          'description':
              '15분 약 2,700페소(47달러), 30분 약 4,600페소(80달러), 1시간 약 4,900페소(86달러)입니다. 2인까지 탑승 가능하며 장비, 스피드보트 이동, 안전장비, 가이드가 포함됩니다. 정부 시설비 30페소가 별도 부과됩니다.',
        },
        {
          'title': '체험 방법',
          'description':
              '사전 경험이 필요 없습니다. 출발 전 강사가 제트스키 조작법을 알려주며, 자신 없으면 강사가 동승할 수 있습니다. 구명조끼 필수 착용이며, 18세 이상 성인만 조종 가능합니다.',
        },
        {
          'title': '예약 팁',
          'description':
              '30분 옵션이 가성비가 좋습니다. 대형 그룹은 가격 협상이 가능합니다. 날씨에 따라 취소될 수 있으니 여유 있는 일정을 잡으세요. 유효한 운전면허가 필요할 수 있습니다.',
        },
      ],
      'description':
          '보라카이의 인기 워터스포츠로 화이트 비치와 불라복 비치에서 즐길 수 있습니다. 15분~1시간 코스가 있으며, 초보자도 강사 안내하에 쉽게 체험할 수 있습니다.',
    },

    // [848] 보라카이 나이트라이프 (D'Mall)
    848: {
      'texts': [
        {
          'title': 'D-Mall 개요',
          'description':
              'D-Mall은 보라카이의 심장부로, 스테이션 2에 위치한 야외 쇼핑몰입니다. 낮에는 쇼핑과 식사, 밤에는 바와 클럽으로 활기가 넘칩니다. 대부분의 해변가 숙소에서 도보 10분 거리입니다.',
        },
        {
          'title': '인기 클럽',
          'description':
              'Epic Boracay는 낮에는 레스토랑, 밤에는 비치프론트 클럽으로 변신합니다. Summer Place는 거대한 댄스플로어와 EDM, 힙합 음악으로 유명합니다. Club ADHD는 독특한 사일런트 디스코를 제공합니다.',
        },
        {
          'title': '바 & 라운지',
          'description':
              'Pelican Sky Bar는 루프탑에서 석양을 감상하며 칵테일을 즐기는 곳입니다. Club Paraw는 해변가 파티 분위기로 현지인들에게 인기입니다. Rumbas는 스포츠 경기를 시청하기 좋은 스포츠 바입니다.',
        },
        {
          'title': '파티 보트',
          'description':
              'Manic Monkey Crew는 보라카이의 유명한 파티 보트입니다. DJ, 무제한 칵테일과 함께 해안선을 따라 항해하며 바다 위 파티를 즐깁니다. 오후 7시경 라이브 어쿠스틱 공연도 추천합니다.',
        },
      ],
      'description':
          '보라카이 스테이션 2의 중심 쇼핑몰이자 나이트라이프의 허브입니다. Epic, Summer Place 등 클럽과 Pelican Sky Bar 등 루프탑 바, 파티 보트까지 다양한 밤문화를 즐길 수 있습니다.',
    },

    // [988] 보라카이 스탠드업패들
    988: {
      'texts': [
        {
          'title': '액티비티 개요',
          'description':
              '스탠드업 패들보드(SUP)는 보라카이의 맑은 바다에서 즐기는 수상 액티비티입니다. 패들보드 위에 서서 노를 저으며 해안선을 탐험합니다. 온 가족이 함께 즐길 수 있는 안전한 스포츠입니다.',
        },
        {
          'title': '체험 정보',
          'description':
              '30분 또는 1시간 세션을 선택할 수 있습니다. 현지 강사가 패들보딩 방법을 알려주며 금방 배울 수 있습니다. 패들보드, 패들, 구명조끼가 포함됩니다.',
        },
        {
          'title': '최적 시간대',
          'description':
              '맑은 날이나 석양 무렵 바다가 가장 잔잔할 때가 최적입니다. 10~5월(아미한 시즌)에는 스테이션 1 Astoria Hotel, 6~9월(하바갓 시즌)에는 불라복 비치에서 진행됩니다.',
        },
        {
          'title': '추가 체험',
          'description':
              'SUP 요가 클래스로 바다 위에서 명상과 균형을 경험할 수 있습니다. 스노클 장비를 가져가면 패들보딩과 스노클링을 함께 즐길 수 있습니다. 에코 투어로 맹그로브와 석호도 탐험 가능합니다.',
        },
      ],
      'description':
          '패들보드 위에 서서 보라카이 해안선을 탐험하는 수상 액티비티입니다. 초보자도 쉽게 배울 수 있으며, 석양 시간대가 가장 아름답습니다. SUP 요가와 에코 투어도 인기 있습니다.',
    },

    // [989] 보라카이 웨이크보드
    989: {
      'texts': [
        {
          'title': '액티비티 개요',
          'description':
              '웨이크보드는 스피드보트에 끌려 파도 위를 타며 트릭을 수행하는 익스트림 스포츠입니다. 보라카이의 잔잔한 바다는 웨이크보드를 배우기에 이상적인 환경을 제공합니다.',
        },
        {
          'title': '체험 정보',
          'description':
              '초보자용 레슨부터 고급 트릭 연습까지 다양한 프로그램이 있습니다. 전문 강사가 기본 자세부터 물 위에서 일어서는 법까지 단계별로 가르쳐줍니다. 장비와 구명조끼가 제공됩니다.',
        },
        {
          'title': '체험 장소',
          'description':
              '불라복 비치가 웨이크보드의 주요 스팟입니다. 화이트 비치보다 파도가 적고 바람이 일정해 수상 스포츠에 적합합니다. 여러 워터스포츠 업체에서 예약 가능합니다.',
        },
        {
          'title': '최적 시즌',
          'description':
              '건기인 11월~5월이 최적입니다. 바다가 잔잔하고 날씨가 맑아 웨이크보드를 즐기기에 좋습니다. 바나나보트, 플라이피시 등 다른 액티비티와 패키지로 예약하면 할인됩니다.',
        },
      ],
      'description':
          '스피드보트에 끌려 파도 위를 타는 익스트림 스포츠입니다. 불라복 비치가 주요 스팟이며, 초보자도 전문 강사의 레슨을 통해 도전할 수 있습니다.',
    },

    // [990] 보라카이 스노클링
    990: {
      'texts': [
        {
          'title': '액티비티 개요',
          'description':
              '보라카이 스노클링은 맑은 바다에서 산호초와 열대어를 관찰하는 액티비티입니다. 아일랜드 호핑 투어에 포함되거나 개별 스노클링 투어로 즐길 수 있습니다.',
        },
        {
          'title': '주요 스팟',
          'description':
              '크로코다일 아일랜드와 코럴 가든은 스노클링의 명소입니다. 형형색색의 산호와 열대어를 가까이서 볼 수 있습니다. 일리그-일리간 비치는 투명한 물과 산호초가 뛰어난 숨은 명소입니다.',
        },
        {
          'title': '장비 및 비용',
          'description':
              '아일랜드 호핑 투어(800~1,500페소)에 스노클링 장비가 포함됩니다. 개별 스노클링 장비 대여는 약 100페소입니다. 마린 파크 입장료 40페소가 별도 부과됩니다.',
        },
        {
          'title': '해양 생물',
          'description':
              '앵무고기, 나비고기, 엔젤피시 등 다양한 열대어와 대왕조개, 불가사리를 관찰할 수 있습니다. 운이 좋으면 바다거북도 만날 수 있습니다. 11월~5월 건기가 시야가 가장 좋습니다.',
        },
      ],
      'description':
          '보라카이의 맑은 바다에서 산호초와 열대어를 관찰하는 액티비티입니다. 크로코다일 아일랜드와 코럴 가든이 주요 스팟이며, 아일랜드 호핑 투어에 포함됩니다.',
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
