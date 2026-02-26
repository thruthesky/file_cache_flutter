// Batch 21: 인덱스 706-713 (El Nido 섬/마켓, Coron 해변)
// 아브이트 섬, 쿄와 섬, 엘니도 씨푸드 마켓, 카누엔 섬,
// 시에테 페카도스, 아트와얀 비치, 바놀 비치, 스미스 비치

import 'dart:convert';
import 'dart:io';

void main() async {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final jsonString = await jsonFile.readAsString();
  final List<dynamic> spots = jsonDecode(jsonString);

  // 업데이트할 데이터: 인덱스 706-713
  final Map<int, Map<String, dynamic>> updatesData = {
    // 706: 아브이트 섬 (Abuit Island)
    706: {
      'englishName': 'Abuit Island',
      'texts': [
        {
          'title': '아브이트 섬 개요',
          'description':
              '아브이트 섬(Abuit Island)은 엘니도 바쿠잇 만에 위치한 45개 이상의 섬 중 하나입니다. 독특한 석회암 지형과 열대 식생이 어우러진 전형적인 엘니도 섬 풍경을 보여줍니다. 덜 알려져 있어 조용한 섬 경험을 원하는 여행자에게 적합합니다.',
        },
        {
          'title': '해변 & 스노클링',
          'description':
              '작은 백사장과 맑은 청록색 바다가 특징입니다. 주변 바다에서 스노클링 시 건강한 산호초와 다양한 열대어를 관찰할 수 있습니다. 파도가 적고 잔잔해 수영하기에 적합합니다.',
        },
        {
          'title': '접근 방법',
          'description':
              '일반 투어(A, B, C, D)에 포함되지 않는 경우가 많아 커스텀 투어나 프라이빗 보트로 방문합니다. 엘니도 타운에서 보트로 약 30-45분. 현지 투어 업체에 문의하여 방문 가능 여부 확인.',
        },
        {
          'title': '방문 팁',
          'description':
              '환경세 ₱400 필요. 시설이 없으므로 음식, 물 충분히 지참. 스노클링 장비 준비 권장. 프라이빗 보트 대여 ₱3,000-5,000/일. 건기(11-5월) 방문 추천.',
        },
      ],
      'description':
          '엘니도의 한적한 작은 섬. 스노클링과 해변 휴식에 적합. 커스텀 투어로 방문, 보트 ₱3,000-5,000/일.',
    },

    // 707: 쿄와 섬 (Kyowa Island)
    707: {
      'englishName': 'Kyowa Island',
      'texts': [
        {
          'title': '쿄와 섬 개요',
          'description':
              '쿄와 섬(Kyowa Island)은 엘니도 바쿠잇 만에 위치한 섬입니다. 일본식 이름을 가진 이 섬은 과거 일본과의 연관성을 시사합니다. 석회암 절벽과 열대 식생이 어우러진 아름다운 풍경을 자랑합니다.',
        },
        {
          'title': '해변 특징',
          'description':
              '작은 해변과 맑은 바다가 특징입니다. 관광객이 적어 프라이빗한 섬 경험을 원하는 여행자에게 적합합니다. 주변에서 스노클링을 즐기며 산호와 열대어를 관찰할 수 있습니다.',
        },
        {
          'title': '접근 방법',
          'description':
              '일반 투어에 포함되지 않아 프라이빗 보트나 커스텀 투어로 방문합니다. 엘니도 타운에서 보트로 약 30-45분. 현지 투어 업체에 문의하여 예약 가능.',
        },
        {
          'title': '방문 팁',
          'description':
              '환경세 ₱400 필요. 음식, 물 지참 필수. 스노클링 장비 대여 ₱150. 프라이빗 보트 대여 ₱3,000-5,000/일. 건기(11-5월) 방문 권장.',
        },
      ],
      'description': '엘니도의 작은 섬. 조용한 해변과 스노클링 가능. 커스텀 투어로 방문, 환경세 ₱400.',
    },

    // 708: 엘니도 씨푸드 마켓 (El Nido Seafood Market)
    708: {
      'englishName': 'El Nido Seafood Market',
      'texts': [
        {
          'title': '엘니도 씨푸드 마켓 개요',
          'description':
              '엘니도 씨푸드 마켓(El Nido Seafood Market)은 신선한 해산물을 구입할 수 있는 현지 시장입니다. 코롱코롱 지역의 팔렝케(공공시장)와 피셔맨스 워프에서 당일 잡은 해산물을 저렴하게 구입할 수 있습니다. 로컬 라이프를 체험하기 좋은 장소입니다.',
        },
        {
          'title': '해산물 가격',
          'description':
              '신선한 생선 ₱50/kg부터, 랍스터 ₱600부터 시작합니다. 피셔맨스 워프에서 살아있는 랍스터를 구입하여 근처 레스토랑에서 조리해 먹을 수 있습니다. 레스토랑 가격(₱3,800/kg)보다 훨씬 저렴합니다.',
        },
        {
          'title': '추천 해산물',
          'description':
              '그릴드 랍스터, 새우, 게, 그루퍼(농어), 키닐라우(세비체 스타일 생선요리)가 인기입니다. 해변가 레스토랑에서 BBQ 스타일로 조리해줍니다. 그릴드 생선+돼지고기 약 ₱400.',
        },
        {
          'title': '방문 팁',
          'description':
              '피셔맨스 워프는 저녁 시간대에 가장 신선한 해산물 선택 가능. 현금 준비 필수. 가격 흥정 가능. Jarace Grill, Barakuda 등 해변 레스토랑에서 조리 서비스. 당일 잡은 신선한 해산물 맛보기 추천.',
        },
      ],
      'description':
          '엘니도 신선 해산물 시장. 랍스터 ₱600부터, 생선 ₱50/kg부터. 피셔맨스 워프에서 구입 후 조리 가능.',
    },

    // 709: 카누엔 섬 (Canuen Island)
    709: {
      'englishName': 'Canuen Island',
      'texts': [
        {
          'title': '카누엔 섬 개요',
          'description':
              '카누엔 섬(Canuen Island)은 엘니도 바쿠잇 만에 있는 작은 섬 중 하나입니다. 45개 이상의 섬으로 이루어진 엘니도 군도에 속하며, 각 섬마다 독특한 지질학적 특성과 아름다운 풍경을 가지고 있습니다.',
        },
        {
          'title': '해변 & 스노클링',
          'description':
              '작은 백사장과 맑은 청록색 바다가 특징입니다. 주변 산호초에서 스노클링을 즐길 수 있으며, 다양한 열대어와 해양생물을 관찰할 수 있습니다. 관광객이 적어 한적한 분위기입니다.',
        },
        {
          'title': '접근 방법',
          'description':
              '일반 투어에 포함되지 않는 경우가 많아 커스텀 투어나 프라이빗 보트로 방문합니다. 엘니도 타운에서 보트로 약 30-45분. 현지 투어 업체에 문의.',
        },
        {
          'title': '방문 팁',
          'description':
              '환경세 ₱400 필요. 시설이 없으므로 음식, 물 충분히 지참. 스노클링 장비 준비 권장. 프라이빗 보트 대여 ₱3,000-5,000/일. 건기(11-5월) 방문 추천.',
        },
      ],
      'description':
          '엘니도의 작은 섬. 한적한 해변과 스노클링 스팟. 커스텀 투어로 방문, 보트 ₱3,000-5,000/일.',
    },

    // 710: 시에테 페카도스 (Siete Pecados)
    710: {
      'englishName': 'Siete Pecados Marine Park',
      'texts': [
        {
          'title': '시에테 페카도스 개요',
          'description':
              '시에테 페카도스(Siete Pecados)는 코론 최고의 스노클링 스팟 중 하나입니다. "7가지 죄"라는 의미의 이름은 바다 위에 솟아 있는 7개의 작은 섬을 뜻합니다. 건강한 산호초와 풍부한 해양생물로 유명하며, 매일 많은 스노클러가 방문해도 산호가 잘 보존되어 있습니다.',
        },
        {
          'title': '해양 생태계',
          'description':
              '다양한 산호와 열대어, 대형 조개(자이언트 클램), 거북이가 서식합니다. 특히 동쪽 섬의 "바라쿠다 포인트"에서 수백 마리의 바라쿠다 떼를 만날 수 있습니다. 수심 2-6m로 초보자도 쉽게 즐길 수 있습니다.',
        },
        {
          'title': '방문 정보',
          'description':
              '코론 타운에서 보트로 약 20-25분. 마퀴닛 온천과 같은 방향. 입장료 ₱100-150, 보트 대여(2시간) 2인 기준 ₱350. 스노클링 장비 대여 가능. 투어리스트 오피스에서 예약.',
        },
        {
          'title': '방문 팁',
          'description':
              '이른 아침이나 늦은 오후 방문 시 덜 혼잡. 건기(11-5월) 최적. 수중 카메라 필수. 윤리적 스노클링 실천(산호 밟지 않기). 엘니도보다 산호 상태가 좋다는 평가 많음.',
        },
      ],
      'description':
          '코론 최고의 스노클링 명소. 7개 섬 주변 건강한 산호와 바라쿠다 떼. 입장료 ₱100-150, 보트 20-25분.',
    },

    // 711: 아트와얀 비치 (Atwayan Beach)
    711: {
      'englishName': 'Atwayan Beach',
      'texts': [
        {
          'title': '아트와얀 비치 개요',
          'description':
              '아트와얀 비치(Atwayan Beach)는 코론 섬의 숨겨진 보석입니다. 높은 석회암 절벽과 울창한 녹지에 둘러싸인 작은 만에 위치합니다. 코론 섬 북서쪽 해안의 작은 만 아래 자리 잡고 있어 아늑하고 친밀한 분위기가 특징입니다.',
        },
        {
          'title': '해변 특징',
          'description':
              '좁은 모래사장 해변으로, 가제보(정자)와 테이블이 설치되어 점심 식사 장소로 인기입니다. 산호 삼각지대에 속해 다양한 산호와 클라운피쉬, 바다거북, 돌고래를 볼 수 있습니다.',
        },
        {
          'title': '투어 정보',
          'description':
              '코론 아일랜드 호핑 투어 A에 포함되어 카양안 레이크, 트윈 라군, CYC 비치와 함께 방문합니다. 마닐라에서 부수앙가 공항까지 1시간 비행 후 코론 타운에서 보트로 이동. 입장료 ₱100.',
        },
        {
          'title': '방문 팁',
          'description':
              '이른 아침 방문 시 덜 혼잡. 현지인 거주, 작은 상점과 무료 화장실 있음. 스노클링 장비 지참 권장. 다른 해변(₱200-300)보다 저렴(₱100). 건기 방문 추천.',
        },
      ],
      'description':
          '코론 투어 A의 숨겨진 해변. 석회암 절벽에 둘러싸인 아늑한 만. 입장료 ₱100, 점심 장소로 인기.',
    },

    // 712: 바놀 비치 (Banol Beach)
    712: {
      'englishName': 'Banol Beach',
      'texts': [
        {
          'title': '바놀 비치 개요',
          'description':
              '바놀 비치(Banol Beach, Banul Beach)는 코론 섬의 아름다운 해변입니다. 하얀 모래와 맑은 청록색 바다가 특징이며, 석회암 절벽이 배경을 이루어 그림 같은 풍경을 만들어냅니다. 수영과 스노클링에 최적인 장소입니다.',
        },
        {
          'title': '해변 특징',
          'description':
              '부드러운 백사장과 얕고 잔잔한 물이 특징입니다. 해변에 야자수가 늘어서 있어 그늘에서 휴식하기 좋습니다. 맑은 물에서 스노클링 시 다양한 산호와 열대어를 볼 수 있습니다.',
        },
        {
          'title': '투어 정보',
          'description':
              '코론 타운에서 보트로 15-20분. 그룹 투어에 포함되거나 프라이빗 보트로 방문 가능. 입장료 ₱150(USD 약 3달러). 그룹 투어 시 입장료 포함.',
        },
        {
          'title': '방문 팁',
          'description':
              '건기(12-4월) 방문 시 날씨 최적. 점심 시간대에 투어 보트가 몰리므로 오전이나 오후에 방문 권장. 스노클링 장비 지참. 해변에 편의시설 있음.',
        },
      ],
      'description': '코론 섬의 백사장 해변. 맑은 물과 스노클링 최적. 입장료 ₱150, 코론에서 보트 15-20분.',
    },

    // 713: 스미스 비치 (Smith Beach)
    713: {
      'englishName': 'Smith Beach',
      'texts': [
        {
          'title': '스미스 비치 개요',
          'description':
              '스미스 비치(Smith Beach)는 코론 만 중심부에 위치한 미개발 해변입니다. 터키석 빛 바다, 파우더처럼 부드러운 백사장, 이국적인 야생 자연이 어우러진 원시적인 아름다움을 자랑합니다. 해변 애호가, 모험가, 천국을 찾는 이들에게 완벽한 곳입니다.',
        },
        {
          'title': '해변 특징',
          'description':
              '하얀 모래와 맑은 물이 특징입니다. 니파 헛(오두막)이 있어 휴식하기 좋습니다. 상대적으로 작은 해변으로, 점심 시간에 투어 보트가 몰려 혼잡해질 수 있습니다. 늦은 오후에는 한적해져 일몰 감상에 좋습니다.',
        },
        {
          'title': '액티비티',
          'description':
              '수영, 스노클링, 해변 휴식이 주요 활동입니다. 카약으로 인근 해변까지 이동 가능. 세계적으로 유명한 다이빙 사이트가 근처에 있습니다. 음식과 물 판매점이 없어 지참 필수.',
        },
        {
          'title': '방문 정보',
          'description':
              '코론 타운에서 프라이빗 투어로 방문. 표준 투어에는 잘 포함되지 않음. TripAdvisor 4.4점, 코론 47곳 중 15위. Viator, GetYourGuide 등에서 투어 예약 가능. 건기 방문 추천.',
        },
      ],
      'description': '코론의 미개발 백사장 해변. 일몰 명소. 프라이빗 투어로 방문. TripAdvisor 4.4점.',
    },
  };

  int updateCount = 0;
  updatesData.forEach((index, data) {
    if (index < spots.length) {
      final spot = spots[index];

      // texts 업데이트
      if (data.containsKey('texts')) {
        spot['texts'] = data['texts'];
      }

      // description 업데이트
      if (data.containsKey('description')) {
        spot['description'] = data['description'];
      }

      // englishName 업데이트 (null인 경우)
      if (data.containsKey('englishName') && spot['englishName'] == null) {
        spot['englishName'] = data['englishName'];
      }

      updateCount++;
      //      print('✅ [$index] ${spot['name']} 업데이트 완료');
    } else {
      //      print('❌ [$index] 인덱스 범위 초과');
    }
  });

  // JSON 파일 저장 (4칸 들여쓰기)
  final encoder = const JsonEncoder.withIndent('    ');
  await jsonFile.writeAsString(encoder.convert(spots));

  //  print('\n총 업데이트: $updateCount개 항목');
  //  print('저장 완료: lib/philgo_files/travel/travel_spots.json');
}
