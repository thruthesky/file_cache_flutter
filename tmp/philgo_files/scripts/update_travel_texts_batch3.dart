// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// 배치 3: 여행 정보 업데이트 스크립트
/// - [779] 화이트 비치 모알보알 (White Beach Moalboal)
/// - [799] 초콜릿 힐 전망대 (Chocolate Hills Viewpoint)
/// - [800] 초콜릿 힐 ATV (Chocolate Hills ATV Adventure)
/// - [808] 힐나그다난 동굴 팡라오 (Hinagdanan Cave Panglao)
/// - [811] 팡라오 해양보호구역 (Panglao Marine Sanctuary)

void main() {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final List<dynamic> spots = jsonDecode(jsonFile.readAsStringSync());

  //  print('총 여행지 수: ${spots.length}');

  // 업데이트할 데이터
  final Map<int, Map<String, dynamic>> updatesData = {
    // [779] 화이트 비치 모알보알
    779: {
      'texts': [
        {
          'title': '바스다쿠 비치의 매력',
          'description':
              '화이트 비치 모알보알은 현지어로 "큰 모래"를 뜻하는 바스다쿠(Basdaku)라고도 불립니다. 세부에서 가장 긴 해안선 중 하나로 1km 이상 뻗어 있으며, 고운 백사장과 투명한 바닷물이 특징입니다.',
        },
        {
          'title': '방문 정보',
          'description':
              '입장료는 10~20페소로 저렴합니다. 파나그사마 로드에서 약 15분 거리에 있으며, 세부 시티에서는 버스로 3~4시간 소요됩니다. 세부 사우스 버스 터미널에서 에어컨 버스 요금은 약 209페소입니다.',
        },
        {
          'title': '선셋 포인트',
          'description':
              '화이트 비치는 타뇬 해협 너머 네그로스 오리엔탈 섬 뒤로 지는 석양을 감상하기에 완벽한 장소입니다. 스탠드업 패들보드, 스노클링 등 수상 액티비티도 즐길 수 있습니다.',
        },
        {
          'title': '주변 명소',
          'description':
              '모알보알의 대표 액티비티로는 해안에서 30m 거리에서 수백만 마리의 정어리와 수영하는 사딘 런(Sardine Run)과 카와산 폭포 캐녀니어링이 있습니다. 페스카도르 섬도 보트로 15분 거리입니다.',
        },
      ],
      'description':
          '세부 모알보알의 대표 해변으로 1km 이상의 백사장이 펼쳐진 바스다쿠 비치입니다. 투명한 청록색 바다와 아름다운 석양으로 유명하며, 사딘 런과 카와산 폭포 캐녀니어링의 출발점입니다.',
    },

    // [799] 초콜릿 힐 전망대
    799: {
      'texts': [
        {
          'title': '전망대 개요',
          'description':
              '초콜릿 힐 전망대는 보홀 카르멘에 위치한 메인 뷰포인트입니다. 타그빌라란 시티에서 55km 거리에 있으며, 214개의 계단을 올라 전망대에 도달하면 1,200개 이상의 원뿔형 언덕이 펼쳐진 장관을 감상할 수 있습니다.',
        },
        {
          'title': '입장 정보',
          'description':
              '입장료는 1인당 150페소이며, 주차비는 오토바이 20페소, 자동차 50페소입니다. 운영 시간은 매일 오전 6시부터 오후 6시까지입니다. 레스토랑, 기념품점, 화장실 등 편의시설이 갖춰져 있습니다.',
        },
        {
          'title': '방문 팁',
          'description':
              '일몰 시간대 방문을 추천합니다. 기온이 낮고 조명이 아름다우며 관광객도 적습니다. 오전 11시~오후 1시는 가장 붐비는 시간대이므로 피하는 것이 좋습니다. 초콜릿 색으로 변하는 건기(3~6월)가 최적의 방문 시기입니다.',
        },
        {
          'title': '대안 전망대',
          'description':
              '사그바얀 피크(Sagbayan Peak)는 카르멘에서 18km 거리에 있는 대안 전망대입니다. 입장료 50페소로 더 저렴하며, 짚라인, ATV 등 모험 액티비티도 즐길 수 있습니다.',
        },
      ],
      'description':
          '보홀의 상징 초콜릿 힐을 감상하는 메인 전망대입니다. 214개의 계단을 올라 1,200개 이상의 원뿔형 언덕을 파노라마로 조망할 수 있으며, 건기에는 언덕이 초콜릿색으로 변하는 장관을 볼 수 있습니다.',
    },

    // [800] 초콜릿 힐 ATV
    800: {
      'texts': [
        {
          'title': 'ATV 모험 개요',
          'description':
              '초콜릿 힐 ATV 어드벤처는 보홀의 유명한 지질 명소를 ATV(사륜 오토바이)로 탐험하는 액티비티입니다. 1,200개 이상의 완벽한 원뿔형 언덕 사이를 달리며 스릴과 경관을 동시에 즐길 수 있습니다.',
        },
        {
          'title': '투어 정보',
          'description':
              'ATV 투어는 30분~1시간 코스가 있으며, 가격은 1인당 약 2,500페소(50달러) 부터 시작합니다. 초보자도 참여 가능하며, 출발 전 안전 교육과 헬멧 등 보호 장비가 제공됩니다.',
        },
        {
          'title': '예약 장소',
          'description':
              'Carmen ATV Rental, Chocolate Hills Adventure Park(CHAP), Graham ATV 등에서 예약 가능합니다. CHAP는 초콜릿 힐 컴플렉스 근처에 위치해 있어 접근성이 좋습니다. 버기카 옵션도 있습니다.',
        },
        {
          'title': '방문 팁',
          'description':
              '오전 8~10시 또는 오후 3~5시가 최적의 시간대입니다. 더위가 덜하고 사진 촬영에도 좋은 조명입니다. 더러워져도 괜찮은 옷을 입고, 방수팩을 준비하세요. 팡라오에서 약 90분, 타그빌라란에서 약 1시간 소요됩니다.',
        },
      ],
      'description':
          '보홀 초콜릿 힐에서 즐기는 ATV 어드벤처입니다. 1,200개의 원뿔형 언덕 사이를 ATV로 달리며 스릴과 절경을 동시에 경험할 수 있으며, 초보자도 안전하게 참여할 수 있습니다.',
    },

    // [808] 힐나그다난 동굴
    808: {
      'texts': [
        {
          'title': '동굴 개요',
          'description':
              '힐나그다난 동굴은 팡라오 섬 다우이스에 위치한 석회암 동굴입니다. 천장의 구멍으로 햇빛이 들어와 자연 조명을 만들어내며, 아름다운 종유석과 석순, 12m 깊이의 담수 라군이 있습니다.',
        },
        {
          'title': '역사',
          'description':
              '20세기 초 농부가 땅을 개간하다 우연히 발견했습니다. 제2차 세계대전 당시 주민들이 일본군을 피해 숨었던 장소로도 알려져 있습니다. 현재는 보홀의 인기 관광지가 되었습니다.',
        },
        {
          'title': '입장 정보',
          'description':
              '입장료 75페소, 주차비 20페소입니다. 운영 시간은 매일 오전 8시~오후 4시입니다. 알로나 비치에서 차로 15분, 보홀-팡라오 국제공항에서 10km, 타그빌라란 시티에서 12km 거리입니다.',
        },
        {
          'title': '방문 팁',
          'description':
              '이른 아침에 방문하면 관광객이 적고 천장 구멍으로 들어오는 빛이 신비로운 분위기를 연출합니다. 동굴 내부는 미끄럽고 습하니 주의하세요. 수정처럼 맑은 라군에서 수영도 가능합니다.',
        },
      ],
      'description':
          '팡라오 섬 다우이스의 석회암 동굴로, 천장 구멍으로 들어오는 자연광과 종유석, 석순이 어우러진 신비로운 공간입니다. 12m 깊이의 맑은 담수 라군에서 수영을 즐길 수 있습니다.',
    },

    // [811] 팡라오 해양보호구역
    811: {
      'texts': [
        {
          'title': '해양보호구역 개요',
          'description':
              '팡라오 해양보호구역은 보홀 팡라오 섬 주변의 풍부한 해양 생태계를 보호하는 구역입니다. 알로나 비치, 발리카삭 섬, 파밀라칸 섬 등이 포함되며, 스노클링과 다이빙의 천국으로 알려져 있습니다.',
        },
        {
          'title': '발리카삭 섬',
          'description':
              '1985년부터 보호되어 온 해양 보호구역으로, 100m 이상의 절벽 다이빙, 잭피시와 바라쿠다 무리, 새끼 화이트팁 상어, 바다거북을 만날 수 있습니다. 하루 다이버 수가 150명으로 제한되어 사전 예약 필수입니다.',
        },
        {
          'title': '해양 생물',
          'description':
              '바다거북, 트레발리, 대왕조개, 형형색색의 앵무고기를 흔히 볼 수 있습니다. 운이 좋으면 문어, 바다뱀, 가오리, 상어도 만날 수 있습니다. 파밀라칸으로 가는 보트에서 돌고래를 볼 수도 있습니다.',
        },
        {
          'title': '방문 정보',
          'description':
              '3월~7월이 최적의 시즌으로 수온이 따뜻하고 시야가 좋습니다. 알로나 비치 주변에 많은 다이브센터가 있어 투어 예약이 편리합니다. 나팔링(Napaling)에서는 팡라오 정어리 떼와 스노클링을 즐길 수 있습니다.',
        },
      ],
      'description':
          '팡라오 섬 주변의 해양보호구역으로 발리카삭 섬, 파밀라칸 섬 등이 포함됩니다. 바다거북, 잭피시, 바라쿠다 등 다양한 해양 생물을 만날 수 있는 스노클링과 다이빙의 천국입니다.',
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

  //  print('\n' + '=' * 50);
  //  print('✅ 업데이트 완료: $updatedCount개 항목');
  //  print('=' * 50);
}
