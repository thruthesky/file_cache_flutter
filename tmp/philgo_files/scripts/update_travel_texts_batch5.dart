// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// 배치 5: 보라카이 워터스포츠 업데이트 스크립트
/// - [839] 보라카이 아일랜드 호핑 (Boracay Island Hopping)
/// - [840] 보라카이 스쿠버 다이빙 (Boracay Scuba Diving)
/// - [841] 보라카이 선셋 세일링 (Boracay Sunset Sailing)
/// - [842] 보라카이 플라이피시 (Boracay Flyfish)
/// - [843] 보라카이 바나나 보트 (Boracay Banana Boat)

void main() {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final List<dynamic> spots = jsonDecode(jsonFile.readAsStringSync());

  //  print('총 여행지 수: ${spots.length}');

  // 업데이트할 데이터
  final Map<int, Map<String, dynamic>> updatesData = {
    // [839] 보라카이 아일랜드 호핑
    839: {
      'texts': [
        {
          'title': '투어 개요',
          'description':
              '보라카이 아일랜드 호핑은 전통 방카 보트를 타고 주변 섬과 해변을 탐험하는 투어입니다. 보통 4~6시간 소요되며, 푸카 비치, 코럴 가든, 크로코다일 아일랜드, 매직 아일랜드 등을 방문합니다.',
        },
        {
          'title': '가격 정보',
          'description':
              '그룹 투어는 1인당 800~1,500페소(15~30달러)입니다. 프라이빗 투어는 보트당 3,500~7,000페소입니다. 입장료는 별도로 크리스탈 코브 300페소, 매직 아일랜드 250페소가 추가됩니다.',
        },
        {
          'title': '포함 사항',
          'description':
              '방카 보트 이용, 필리피노 스타일 BBQ 뷔페 점심(해산물, 치킨, 야채, 쌀, 과일), 스노클링 장비가 포함됩니다. 코럴 가든과 크로코다일 아일랜드에서 열대어와 산호초를 감상할 수 있습니다.',
        },
        {
          'title': '주요 스팟',
          'description':
              '푸카 비치(야팍 비치)는 조개껍데기가 섞인 모래가 특징인 북쪽 해변입니다. 매직 아일랜드는 1m~10m 높이의 클리프 다이빙 스팟입니다. 탐비사안 비치는 점심 정류장으로 인기 있습니다.',
        },
      ],
      'description':
          '전통 방카 보트로 보라카이 주변 섬을 탐험하는 4~6시간 투어입니다. 푸카 비치, 코럴 가든, 크로코다일 아일랜드 등을 방문하며 BBQ 점심과 스노클링이 포함됩니다.',
    },

    // [840] 보라카이 스쿠버 다이빙
    840: {
      'texts': [
        {
          'title': '다이빙 개요',
          'description':
              '보라카이는 맑은 물과 건강한 산호초로 유명한 다이빙 천국입니다. 앵글 포인트, 푼타 붕아, 라구나 데 보라카이 등 20개 이상의 다이브 사이트가 보트로 20분 이내 거리에 있습니다.',
        },
        {
          'title': '초보자 코스',
          'description':
              'Discover Scuba Diving(DSD)은 경험이 없는 초보자를 위한 코스로 약 2시간 30분 소요됩니다. 이론, 수영장 실습, 보트 다이빙이 포함되며 최대 수심 12m까지 내려갑니다. 가격은 약 80~120달러입니다.',
        },
        {
          'title': 'PADI 자격증',
          'description':
              'Open Water 자격증 코스는 약 27,000페소입니다. 10세부터 Junior Open Water Diver 자격증 취득이 가능합니다. New Wave Divers, Fisheye Divers, Calypso Diving 등 PADI 5성급 다이브 센터가 있습니다.',
        },
        {
          'title': '해양 생물',
          'description':
              '앵무고기, 엔젤피시, 버터플라이피시, 라이언피시, 스콜피온피시, 스내퍼 등 열대어와 녹색거북, 매부리바다거북을 흔히 볼 수 있습니다. 최적 시즌은 10월~5월입니다.',
        },
      ],
      'description':
          '보라카이의 맑은 바다에서 즐기는 스쿠버 다이빙입니다. 앵글 포인트 등 20개 이상의 다이브 사이트가 있으며, 초보자용 체험 다이빙부터 PADI 자격증 코스까지 다양한 프로그램을 제공합니다.',
    },

    // [841] 보라카이 선셋 세일링
    841: {
      'texts': [
        {
          'title': '파라우 세일링 소개',
          'description':
              '파라우(Paraw)는 필리핀 전통 아웃리거 범선입니다. 나무와 대나무로 만들어지며, 양쪽에 균형을 위한 부목이 달려 있습니다. 엔진 없이 오직 바람의 힘으로 항해하는 친환경 체험입니다.',
        },
        {
          'title': '선셋 크루즈 체험',
          'description':
              '30분간 화이트 비치를 출발해 석양 속을 항해합니다. 하늘이 다채로운 빛으로 물드는 가운데 따뜻한 바람과 파도 소리를 즐기며 보라카이 해안선, 디니위드 비치, 넓은 바다를 감상합니다.',
        },
        {
          'title': '예약 정보',
          'description':
              '오후 3시~5시 사이에 운영됩니다. 화이트 비치 스테이션 1 또는 스테이션 3에서 출발합니다. 숙련된 뱃사공, 안전 장비, 가이드 서비스가 포함됩니다. 현장 예약 또는 Klook, GetYourGuide 등에서 온라인 예약 가능합니다.',
        },
        {
          'title': '추천 대상',
          'description':
              '가족 여행, 커플의 로맨틱한 데이트, 친구들과의 특별한 추억 만들기에 완벽합니다. 크루즈 승객의 짧은 보라카이 방문 시에도 추천하는 액티비티입니다.',
        },
      ],
      'description':
          '필리핀 전통 파라우 범선을 타고 보라카이 석양을 감상하는 30분 크루즈입니다. 엔진 없이 바람만으로 항해하며, 화이트 비치 해안선과 아름다운 노을을 즐길 수 있습니다.',
    },

    // [842] 보라카이 플라이피시
    842: {
      'texts': [
        {
          'title': '액티비티 개요',
          'description':
              '플라이피시는 공기 쿠션을 가진 호버크래프트형 튜브를 타고 스피드보트에 끌려 물 위를 날아다니는 스릴 넘치는 워터스포츠입니다. 속도가 붙으면 튜브가 물 위로 떠올라 짜릿한 비행감을 느낄 수 있습니다.',
        },
        {
          'title': '체험 정보',
          'description':
              '그룹으로 함께 탑승하여 즐기는 액티비티로, 아드레날린을 즐기는 분들과 친구 그룹에게 인기 있습니다. 구명조끼와 안전 장비가 제공되며, 스피드보트 조종사가 속도를 조절합니다.',
        },
        {
          'title': '최적의 시기',
          'description':
              '건기인 11월~5월이 가장 좋은 시즌입니다. 날씨가 맑고 바다가 잔잔해 워터스포츠를 즐기기에 최적입니다. 만남 장소는 스테이션 1 Astoria Boracay 또는 스테이션 3 Swiss Inn Restaurant입니다.',
        },
        {
          'title': '함께 즐기기 좋은 액티비티',
          'description':
              '바나나보트, 제트스키, UFO 라이드 등 다른 워터스포츠와 패키지로 예약하면 할인을 받을 수 있습니다. 하루에 여러 액티비티를 즐기는 것이 효율적입니다.',
        },
      ],
      'description':
          '호버크래프트형 튜브를 타고 스피드보트에 끌려 물 위를 날아다니는 스릴 넘치는 워터스포츠입니다. 속도가 붙으면 튜브가 떠올라 짜릿한 비행감을 경험할 수 있습니다.',
    },

    // [843] 보라카이 바나나 보트
    843: {
      'texts': [
        {
          'title': '액티비티 개요',
          'description':
              '바나나 모양의 노란색 튜브 보트를 타고 스피드보트에 끌려 보라카이 바다를 질주하는 인기 워터스포츠입니다. 보라카이에서 가장 접근하기 쉽고 저렴한 워터스포츠 중 하나입니다.',
        },
        {
          'title': '가격 및 시간',
          'description':
              '가격은 1인당 약 9~11달러(500~600페소)로 15분간 진행됩니다. 최소 2명부터 최대 7명까지 함께 탈 수 있어 친구나 가족 그룹에게 적합합니다.',
        },
        {
          'title': '안전 정보',
          'description':
              '구명조끼가 제공되며, 출발 전 기본 안전 수칙에 대한 브리핑이 있습니다. 5~24명 그룹까지 수용 가능한 패키지도 있습니다. 스피드보트 조종사가 안전하게 운영합니다.',
        },
        {
          'title': '만남 장소',
          'description':
              '스테이션 1 Astoria Boracay 또는 스테이션 3 Swiss Inn Restaurant에서 만납니다. 하바갓(몬순) 시즌(6~9월)에는 불라복 비치의 Reef Retreat Resort에서 모입니다. 건기(11~5월)가 최적의 시즌입니다.',
        },
      ],
      'description':
          '바나나 모양 튜브를 타고 스피드보트에 끌려 바다를 질주하는 인기 워터스포츠입니다. 1인당 약 500~600페소로 15분간 즐길 수 있으며, 최대 7명까지 함께 탈 수 있습니다.',
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
