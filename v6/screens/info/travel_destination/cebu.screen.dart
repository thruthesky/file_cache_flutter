import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 정보 아이템 데이터 클래스 (Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명, 이동 정보를 담습니다.
/// Contains icon, title, description and transport info for each info item.
class _InfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  /// 이동 정보 (Transport info)
  final String? transport;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
    this.transport,
  });
}

/// 관광지 정보 데이터 클래스 (Tourist Spot Info Data Class)
///
/// 관광지의 상세 정보를 담습니다.
/// Contains detailed information about tourist spots.
class _SpotInfo {
  /// 관광지 이름 (Spot name)
  final String name;

  /// 설명 (Description)
  final String description;

  /// 특징 목록 (Features list)
  final List<String> features;

  /// 아이콘 (Icon)
  final IconData icon;

  /// 이동 정보 (Transport info)
  final String transport;

  const _SpotInfo({
    required this.name,
    required this.description,
    required this.features,
    required this.icon,
    required this.transport,
  });
}

/// 세부 여행 정보 화면 (Cebu Travel Screen)
///
/// 필리핀 세부 여행 정보를 제공합니다.
/// Provides travel information about Cebu in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// CebuScreen.push(context);
/// ```
class CebuScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Cebu';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const CebuScreen({super.key});

  @override
  State<CebuScreen> createState() => _CebuScreenState();
}

class _CebuScreenState extends State<CebuScreen> {
  /// [역사/문화 유적지 정보 - History/Culture Spots]
  ///
  /// 마젤란의 십자가, 산토 니뇨 성당, 산 페드로 요새, 막탄 슈라인, 세부 도교사원 정보를 포함합니다.
  /// 세부는 필리핀에 가톨릭이 처음 전파된 역사의 현장이며, 스페인 식민 시대의 유산이 곳곳에 남아 있습니다.
  static const List<_SpotInfo> _historyCultureSpots = [
    _SpotInfo(
      name: '마젤란의 십자가 (Magellan\'s Cross)',
      description:
          '1521년 포르투갈 탐험가 페르디난드 마젤란이 세부에 상륙하여 세운 기념비적인 십자가로, 세부 시청 인근 마젤란 크로스 파빌리온 안에 보존되어 있습니다. 이 십자가는 필리핀에 기독교를 전파한 상징으로 여겨지며, 천장에는 당시 원주민들이 세례를 받는 장면을 묘사한 벽화가 그려져 있습니다. 국가문화보물로 지정되어 보호받고 있으며, 바로 옆 산토 니뇨 성당과 함께 세부 시티 투어의 필수 방문지로 손꼽힙니다.',
      features: [
        '위치: 세부 시청 인근 마젤란 크로스 파빌리온',
        '역사: 1521년 마젤란이 세운 필리핀 기독교 전파 상징물',
        '볼거리: 원주민 세례 장면 천장 벽화',
        '지정: 국가문화보물로 보호',
      ],
      icon: FontAwesomeIcons.lightCross,
      transport: '세부 시청에서 도보 5분, SM 시티 세부에서 택시로 15분',
    ),
    _SpotInfo(
      name: '산토 니뇨 성당 (Basilica Minore del Santo Niño)',
      description:
          '1565년에 설립된 필리핀 최古의 가톨릭 성당 중 하나로, 마젤란이 세부 왕에게 선물한 예수상(산토 니뇨)을 모시고 있습니다. 매년 1월 열리는 대규모 종교축제 시눌로그(Sinulog)의 중심지이며, 현지 신자들에게 매우 중요한 순례 장소입니다. 스페인 양식의 외관과 아름다운 내부 경당으로 유명하며, 마젤란의 십자가와 불과 수십 미터 거리에 있어 함께 둘러보기 좋습니다.',
      features: [
        '역사: 1565년 설립, 필리핀 최고(最古) 성당 중 하나',
        '볼거리: 아기 예수상(산토 니뇨), 스페인 양식 건축',
        '축제: 매년 1월 시눌로그(Sinulog) 축제 개최지',
        '중요성: 현지 신자들의 중요한 순례 장소',
      ],
      icon: FontAwesomeIcons.lightChurch,
      transport: 'SM 시티 세부에서 약 4km, 택시로 15분',
    ),
    _SpotInfo(
      name: '산 페드로 요새 (Fort San Pedro)',
      description:
          '세부 시내 항구 옆 플라자 인데펜덴시아(Plaza Independencia) 공원에 위치한 삼각형 모양의 스페인 요새입니다. 1565년 미겔 로페스 데 레가스피가 세부에 정착하며 처음 나무 방책으로 건설했고, 1738년에 현재의 석조 요새로 개축되었습니다. 필리핀에서 가장 오래된 요새로 벽이 두껍고 견고하며, 스페인 통치의 거점이자 필리핀 혁명 시기에는 혁명군의 거점으로도 사용되었습니다. 요새 내부는 작은 박물관과 정원으로 조성되어 있으며, 성벽 위에 오르면 항구와 도시를 조망할 수 있습니다.',
      features: [
        '역사: 1565년 레가스피가 건설, 1738년 석조로 개축',
        '구조: 삼각형 모양의 성채, 두꺼운 돌벽과 대포',
        '현재: 박물관과 정원으로 조성, 항구 조망 가능',
        '위치: 플라자 인데펜덴시아 공원 내',
      ],
      icon: FontAwesomeIcons.lightLandmark,
      transport: '세부 시내 중심에서 남쪽 약 3km, 택시로 10~15분',
    ),
    _SpotInfo(
      name: '막탄 슈라인 (라푸라푸 기념비)',
      description:
          '1521년 필리핀 원주민 지도자 라푸라푸가 마젤란을 물리친 막탄 전투의 승전을 기념하는 역사공원입니다. 막탄섬 푼타 앙가뇨(Punta Engaño) 지역에 위치하며, 공원 안에 스페인 탐험가 마젤란을 기리는 돌탑과 20피트 높이의 라푸라푸 청동상이 세워져 있습니다. 전투가 벌어진 해변으로 전해지는 장소로서 역사적 의미가 크며, Liberty Shrine이라고도 불리는 이곳은 현지인들에게도 애국심의 상징입니다. 주변에 해산물로 유명한 수산시장과 기념품 가게들이 있어 함께 둘러볼 만합니다.',
      features: [
        '역사: 1521년 막탄 전투 승전 기념 역사공원',
        '볼거리: 마젤란 돌탑, 20피트 라푸라푸 청동상',
        '의미: 필리핀 독립정신의 상징, Liberty Shrine',
        '주변: 해산물 수산시장, 기념품 가게',
      ],
      icon: FontAwesomeIcons.lightMonument,
      transport: '막탄 국제공항에서 약 7km(차로 20분), 세부 시내에서 40~50분',
    ),
    _SpotInfo(
      name: '세부 도교사원 (Cebu Taoist Temple)',
      description:
          '세부 시내 라후그(Lahug) 언덕 지구에 있는 이색적인 중국식 사원입니다. 1972년 세부의 화교(華僑) 커뮤니티가 세운 도교 사원으로, 해발 약 300m 고지에 위치하여 세부 시가지와 바다를 한눈에 조망할 수 있습니다. 붉은 기와 지붕과 용 조각 등 중국 전통 양식으로 지어진 이 사원은 현지 신자들뿐만 아니라 관광객에게도 인기 있는 명소입니다. 내부에는 도교 경전을 보관한 도서관과 용왕을 모시는 연못 등이 있으며, 무료로 입장 가능합니다.',
      features: [
        '위치: Beverly Hills 고급 주택단지, 해발 약 300m',
        '역사: 1972년 세부 화교 사회가 건립',
        '볼거리: 붉은 기와 지붕, 용 조각, 중국 전통 건축',
        '특징: 무료 입장, 도교 도서관과 연못 보유',
      ],
      icon: FontAwesomeIcons.lightPlaceOfWorship,
      transport: '시내 중심에서 약 8km, 택시로 20~30분 (04번 지프니 이용 가능)',
    ),
  ];

  /// [쇼핑/도심 관광지 정보 - Shopping/City Center Spots]
  ///
  /// 아얄라 센터, SM 시사이드, 망고 스퀘어 & IT 파크 정보를 포함합니다.
  /// 세부의 도심에서는 대형 쇼핑몰과 현대적인 시티 관광지도 즐길 수 있습니다.
  static const List<_SpotInfo> _shoppingSpots = [
    _SpotInfo(
      name: '아얄라 센터 세부 (Ayala Center Cebu)',
      description:
          '세부 비즈니스 지구(Cebu Business Park)에 위치한 세부의 대표적인 고급 쇼핑몰입니다. 여러 개의 동으로 이루어진 대형 몰로, 200여 개 이상의 매장과 레스토랑을 갖추고 있습니다. 특히 더 테라스(The Terraces)라 불리는 야외 정원형 식당가가 유명한데, 인공 연못을 둘러싼 계단식 정원에 각종 음식점과 카페가 모여 있어 휴식과 만남의 장소로 인기가 많습니다. BGC처럼 세련된 도시 분위기를 느낄 수 있습니다.',
      features: [
        '규모: 200여 개 이상의 매장과 레스토랑',
        '특징: 더 테라스 - 야외 정원형 식당가, 인공 연못',
        '영업: 10:00~21:00 (주말 연장)',
        '안전: 치안이 좋아 현지 거주 외국인과 관광객에게 인기',
      ],
      icon: FontAwesomeIcons.lightStore,
      transport: '시내 중심부에서 택시로 10분 이내',
    ),
    _SpotInfo(
      name: 'SM 시사이드 시티 세부',
      description:
          '2015년에 개장한 세부 최대 규모의 쇼핑몰로, SM 몰 오브 아시아를 설계한 건축팀이 디자인했습니다. 연면적 약 47만 m²에 달하는 초대형 몰로서 필리핀에서 다섯 번째, 세계에서도 20위권 규모의 쇼핑센터입니다. 몰 중앙에 돔 형태의 스카이 파크(Sky Park)와 147m 높이의 전망 타워가 있어 세부 시내와 바다를 360도 전망할 수 있습니다. 외부에는 거대한 금속 조형물 더 큐브(The Cube)가 랜드마크로 서 있습니다.',
      features: [
        '규모: 연면적 47만 m², 필리핀 5위 규모 쇼핑센터',
        '시설: 올림픽 규격 아이스 스케이트장, 16개관 영화관, 볼링장',
        '전망: 147m 높이 스카이 파크 전망 타워',
        '랜드마크: 더 큐브(The Cube) 금속 조형물',
      ],
      icon: FontAwesomeIcons.lightBuildingColumns,
      transport: '시내 중심에서 약 5km, 택시/그랩으로 15~20분, MyBus 정류장 있음',
    ),
    _SpotInfo(
      name: '망고 스퀘어 & IT 파크',
      description:
          '세부 시내의 즐길 거리 밀집 지역입니다. 망고 애비뉴(Mango Avenue) 일대는 세부의 번화가로서 밤에는 바와 클럽, 노천 맥주집들이 몰려 활기찹니다. 인근 망고 스퀘어는 저녁에 노점 먹거리와 실외 공연 등이 열려 젊은 여행객들이 찾습니다. IT 파크는 현대적 오피스 빌딩과 글로벌 기업 콜센터가 모인 지역이지만, 저녁 시간에는 야외 푸드몰과 카페 거리로 변신하며 수그보 메르카도(Sugbo Mercado) 야시장에서 다양한 현지 음식과 길거리 간식을 맛볼 수 있습니다.',
      features: [
        '망고 애비뉴: 바, 클럽, 노천 맥주집 밀집 번화가',
        '수그보 메르카도: 세부 대표 야시장 푸드 마켓',
        '분위기: 야외 광장 라이브 공연, 야간 명소',
        '요금: 택시 기본요금 수준(₱70~100)으로 이동 가능',
      ],
      icon: FontAwesomeIcons.lightCity,
      transport: '시내 중심에서 가까움, 도보로 여러 장소 연결 가능',
    ),
  ];

  /// [전통 시장 정보 - Traditional Market Info]
  static const _InfoItem _traditionalMarketInfo = _InfoItem(
    icon: FontAwesomeIcons.lightShop,
    title: '전통 시장 투어: 콜론 거리 & 카본 시장',
    description:
        '콜론 거리(Colon St.)는 필리핀에서 가장 오래된 거리로 스페인 식민시대의 흔적이 남아 있고, 카본 시장(Carbon Market)은 100년 넘은 재래시장으로 다양한 농산물과 해산물 건어물을 저렴하게 구입할 수 있는 곳입니다. 다만 관광 인프라는 부족하고 주변 치안이 쾌적하지 않을 수 있어, 주간에 짧게 방문하거나 현지 가이드 동행 하에 둘러보는 것을 권장합니다.',
    transport: 'SM 시티 세부에서 택시로 10분 이내',
  );

  /// [자연/해변 관광지 정보 - Nature/Beach Spots]
  ///
  /// 카와산 폭포, 오슬롭 고래상어, 모알보알, 말라파스쿠아 & 반타얀, 막탄섬, 세부 시티 고지대 정보를 포함합니다.
  /// 세부 섬은 열대의 자연경관과 해양 액티비티의 천국으로 불립니다.
  static const List<_SpotInfo> _natureSpots = [
    _SpotInfo(
      name: '카와산 폭포 (Kawasan Falls)',
      description:
          '에메랄드 빛 물빛으로 유명한 다단(多段) 폭포로, 바디안(Badian) 지역의 밀림 속에 자리잡고 있습니다. 카와산 폭포는 3단의 폭포로 이루어져 있고 가장 낮은 1단 폭포수가 특히 크고 아름답습니다. 폭포수를 이용한 캐녀닝(canyoneering) 투어의 명소로도 잘 알려져 있어, 상류 계곡부터 뛰어내리기와 바디보트 타기 등의 액티비티를 즐길 수 있습니다. 입구 매표소에서 폭포까지는 약 15~20분 정도 정글 속 산책로를 걸어가야 합니다.',
      features: [
        '구조: 3단 폭포, 1단 폭포가 가장 웅장',
        '액티비티: 캐녀닝 투어 (1인당 ₱1,500~2,000)',
        '특징: 에메랄드빛 천연 풀장, 대나무 뗏목 체험',
        '팁: 주말 혼잡, 이른 오전 방문 권장',
      ],
      icon: FontAwesomeIcons.lightWater,
      transport: '세부 시내에서 남서쪽 약 100km, 차로 약 3시간',
    ),
    _SpotInfo(
      name: '오슬롭 고래상어 체험',
      description:
          '세부 남부 오슬롭(Oslob) 해안에서는 세계적으로 유명한 고래상어(Whale Shark) 체험이 가능합니다. 매일 아침 6시~12시 사이에 진행되는 투어에서 바다에 나가 거대한 고래상어를 바로 눈앞에서 볼 수 있고, 스노클링으로 함께 수영도 할 수 있습니다. 고래상어 관광은 연중 가능하지만 파도가 잔잔한 11~5월 건기가 최적입니다. 투어 후에는 인근의 투말로그 폭포(Tumalog Falls)나 숨힐론 섬(Sumilon Island)을 함께 방문하는 코스도 인기 있습니다.',
      features: [
        '시간: 매일 06:00~12:00 운영',
        '최적기: 11~5월 건기 (파도가 잔잔한 시기)',
        '비용: 보트 및 장비 포함 1인 ₱1,000~1,500',
        '주의: 환경보호를 위해 선크림 사용 제한',
      ],
      icon: FontAwesomeIcons.lightFish,
      transport: '세부 시내에서 약 120km 남쪽, 차로 3.5~4시간',
    ),
    _SpotInfo(
      name: '모알보알 (Moalboal)',
      description:
          '세부 남서쪽 해안의 작은 해변 마을로, 환상적인 스노클링과 다이빙 명소로 이름높습니다. 특히 파낙사마 비치(Panagsama Beach) 앞바다에서는 수만 마리의 정어리가 떼지어 이동하는 정어리 떼(Sardine Run)를 연중 관찰할 수 있어 전 세계 다이버들을 끌어모읍니다. 인근 페스카도르 섬(Pescador Island)의 다이빙 포인트는 형형색색의 산호와 해양 생물로 가득합니다. 마을 북쪽 화이트 비치(White Beach)는 고운 백사장이 펼쳐진 휴양지로 스노클링에 적합합니다.',
      features: [
        '명소: 정어리 떼(Sardine Run) 연중 관찰 가능',
        '다이빙: 페스카도르 섬 - 산호와 해양 생물의 보고',
        '해변: 화이트 비치 - 백사장 휴양지',
        '교통: 남부 버스터미널에서 버스 ₱200 미만',
      ],
      icon: FontAwesomeIcons.lightFishFins,
      transport: '세부 시내에서 약 90km, 차로 약 3시간 (버스 또는 그랩 이용)',
    ),
    _SpotInfo(
      name: '말라파스쿠아 & 반타얀 섬',
      description:
          '세부 섬 북쪽 끝 또는 인근에 위치한 섬들로, 한층 여유로운 섬 생활과 천혜의 해변을 즐길 수 있습니다. 말라파스쿠아 섬(Malapascua)은 큰눈탐꼴상어(Thresher Shark)를 볼 수 있는 특급 다이빙 포인트로 세계적으로 유명합니다. 반타얀 섬(Bantayan)은 비교적 큰 섬으로, 한적한 어촌 풍경과 긴 백사장 해변이 매력적입니다. 두 섬 모두 이동 시간이 긴 편이지만, 군청색 빛 바다와 붐비지 않는 한적함 덕분에 장기 여행자나 다이버들에게 인기있는 목적지입니다.',
      features: [
        '말라파스쿠아: 큰눈탐꼴상어 다이빙 포인트',
        '반타얀: 한적한 어촌, 긴 백사장 해변',
        '이동: 자전거/스쿠터 대여로 섬 탐험',
        '분위기: 소박한 현지 분위기, 장기 체류 적합',
      ],
      icon: FontAwesomeIcons.lightIslandTropical,
      transport: '말라파스쿠아: 마야항까지 4~5시간 + 페리 40분 / 반타얀: 하그나야항까지 3시간 + 페리 1.5시간',
    ),
    _SpotInfo(
      name: '막탄섬 & 아일랜드 호핑',
      description:
          '세부 본섬 바로 옆에 위치한 막탄 섬(Mactan Island)은 세부 국제공항이 있는 리조트 지구로, 아름다운 해변과 특급 리조트들이 모여 있습니다. 투명한 바다에서 즐기는 스노클링과 스쿠버 다이빙, 제트스키 등의 해양 액티비티가 특히 유명하며, 인접한 작은 섬들을 배로 돌아보는 아일랜드 호핑 투어도 인기입니다. 대표 코스로 산호와 열대어가 풍부한 힐룽뚜안 섬과 날루수안 섬 방문이 있으며, 오후에는 막탄 섬 해변에서 장관인 석양을 감상할 수 있습니다.',
      features: [
        '위치: 세부 본섬 옆, 세부 국제공항 소재',
        '액티비티: 스노클링, 스쿠버 다이빙, 제트스키',
        '호핑 투어: 힐룽뚜안 섬, 날루수안 섬 방문',
        '추천: 오후 석양 감상, 허니문 여행지로 인기',
      ],
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      transport: '세부-코르도바 링크 교량 이용, 시내에서 30분~1시간',
    ),
    _SpotInfo(
      name: '세부 시티 고지대 관광 (Tops 전망대 등)',
      description:
          '세부 도심을 벗어나 버사이(Busay) 산악지역으로 올라가면 시원한 공기와 함께 도시와 바다를 내려다볼 수 있는 명소들이 있습니다. 그 중 해발 600m 고지에 위치한 탑스 전망대(Tops Lookout)는 원형 성곽 형태의 전망 공간으로, 낮에는 세부 시내와 막탄 섬까지 한눈에 보이고 밤에는 반짝이는 도시 야경으로 유명합니다. 인근에는 로마식 신전 컨셉의 템플 오브 레아(Temple of Leah)와 형형색색의 꽃밭 시라오 가든(Sirao Garden)도 있습니다.',
      features: [
        '탑스 전망대: 해발 600m, 360도 전망, 야경 명소',
        '템플 오브 레아: 로마식 신전 컨셉 전망대',
        '시라오 가든: 작은 암스테르담이라 불리는 꽃밭',
        '팁: 세 곳을 하루 코스로 묶어 방문 권장',
      ],
      icon: FontAwesomeIcons.lightMountain,
      transport: 'SM 시티 세부에서 15km 내외, 택시로 30~40분',
    ),
  ];

  /// [가족/어린이 관광지 정보 - Family/Kids Spots]
  ///
  /// 세부 오션 파크, 세부 사파리, 안조 월드 정보를 포함합니다.
  /// 아이들과 함께하는 여행자라면 세부의 테마파크와 동물원을 놓칠 수 없습니다.
  static const List<_SpotInfo> _familySpots = [
    _SpotInfo(
      name: '세부 오션 파크 (Cebu Ocean Park)',
      description:
          '2019년에 문을 연 필리핀 최대의 해양 테마파크로, 마닐라 오션 파크의 3배 규모에 달하는 대형 수족관 시설입니다. 세부 시티 SRP(South Road Properties) 해안 지역에 위치하며, 7.2미터 깊이의 거대한 오션아리움 수조와 360도 둘러볼 수 있는 해저 터널을 자랑합니다. 다양한 열대어와 산호, 파충류와 조류까지 전시되어 있으며, 아이들을 위한 터치풀(체험 수조)과 조류 먹이주기 체험 프로그램도 운영됩니다.',
      features: [
        '규모: 마닐라 오션 파크의 3배, 필리핀 최대 해양 테마파크',
        '볼거리: 7.2m 오션아리움, 360도 해저 터널',
        '체험: 터치풀, 조류 먹이주기 프로그램',
        '입장료: 성인 ₱600, 어린이 ₱500',
        '운영: 매일 10:00~18:00 (입장마감 17:00)',
      ],
      icon: FontAwesomeIcons.lightFishFins,
      transport: 'SM 시사이드 몰 옆, 시내에서 택시로 30분 이내',
    ),
    _SpotInfo(
      name: '세부 사파리 & 어드벤처 파크',
      description:
          '세부 섬 북부 카르멘(Carmen) 지역의 산악 지대에 있는 대형 사파리 동물원으로, 부지 면적이 170헥타르에 달하는 필리핀 최대 규모의 야생 공원입니다. 2018년 개장하여 사자, 호랑이, 기린, 얼룩말 등 120여 종, 1,000마리 이상의 동물을 보유하고 있으며, 아프리카 사바나존, 식물원, 화이트 라이온 사파리 등 테마 구역으로 조성되어 있습니다. 넓은 공원을 전기차를 타고 투어하며 동물을 가까이 관찰할 수 있고, 지프라인·ATV 같은 어드벤처 시설도 갖추었습니다.',
      features: [
        '규모: 170ha 부지, 필리핀 최대 야생 공원',
        '동물: 사자, 호랑이, 기린 등 120여 종 1,000마리 이상',
        '체험: 전기차 사파리 투어, 기린 먹이주기',
        '입장료: 성인 ₱800, 어린이 ₱400',
        '운영: 수~일 08:00~17:00 (입장마감 13:30, 월·화 휴무)',
      ],
      icon: FontAwesomeIcons.lightHippo,
      transport: '세부 시내에서 북쪽으로 약 50km, 차량으로 1.5~2시간',
    ),
    _SpotInfo(
      name: '안조 월드 테마파크 (Anjo World)',
      description:
          '2018년 말 세부 최초의 놀이공원으로 개장한 테마파크로, 세부 시티 남쪽 교외 밍글라닐라(Minglanilla) 지역에 위치합니다. 규모는 약 1.5헥타르로 아담하지만, 비사야 지역 최대 규모의 놀이공원으로서 12종 이상의 놀이기구를 갖추고 있습니다. 200ft 높이의 대관람차 안조 아이(Anjo Eye), 25m 자유낙하 타워 드롭, 회전 코스터, 바이킹, 회전목마 등의 어트랙션이 있습니다. 또한 실내 눈썰매 체험 시설인 스노우 월드가 있어 열대 세부에서 눈과 얼음을 경험해볼 수도 있습니다.',
      features: [
        '규모: 비사야 지역 최대 테마파크, 12종 이상 놀이기구',
        '대표 시설: 안조 아이(200ft 대관람차), 타워 드롭(25m)',
        '특별 시설: 스노우 월드 - 실내 눈썰매장',
        '입장료: 놀이기구 무제한 이용권 ₱600~800',
        '운영: 주중 운영 (월요일 휴무 있음)',
      ],
      icon: FontAwesomeIcons.lightFerrisWheel,
      transport: '시내에서 약 15km, 차로 30~40분, MyBus 이용 가능',
    ),
  ];

  /// [주요 관광지 이동 소요 시간 정보 - Travel Time Info]
  ///
  /// 세부 시티 중심부에서 각 관광지까지의 거리와 이동 시간 정보입니다.
  /// 이동 수단은 차량 기준입니다.
  static const List<Map<String, String>> _travelTimeInfo = [
    {'name': '막탄 라푸라푸 기념비', 'distance': '약 20km', 'time': '40~50분'},
    {'name': '세부 도교사원', 'distance': '약 8km', 'time': '20~30분'},
    {'name': '세부 오션 파크', 'distance': '약 5km', 'time': '15~20분'},
    {'name': '안조 월드 테마파크', 'distance': '약 15km', 'time': '30~40분'},
    {'name': '세부 사파리 (카르멘)', 'distance': '약 50km', 'time': '1.5~2시간'},
    {'name': '모알보알', 'distance': '약 90km', 'time': '약 3시간'},
    {'name': '카와산 폭포 (바디안)', 'distance': '약 105km', 'time': '약 3시간'},
    {'name': '오슬롭 (고래상어)', 'distance': '약 120km', 'time': '3.5~4시간'},
    {'name': '말라파스쿠아 섬 (마야항)', 'distance': '약 130km', 'time': '4~5시간'},
    {'name': '반타얀 섬 (하그나야항)', 'distance': '약 100km', 'time': '3시간 + 페리 1.5시간'},
  ];

  /// [핵심 요약 정보 - Summary Info]
  ///
  /// 세부 여행의 핵심 포인트를 요약합니다.
  static const List<String> _summaryItems = [
    '마젤란의 십자가, 산토 니뇨 성당, 막탄 슈라인 등 역사 유적지',
    '아얄라 센터, SM 시사이드 등 대형 쇼핑몰과 망고 스퀘어 번화가',
    '막탄섬 아일랜드 호핑 & 해양 액티비티',
    '카와산 폭포 캐녀닝, 오슬롭 고래상어, 모알보알 정어리 떼',
    '말라파스쿠아 큰눈탐꼴상어 다이빙, 반타얀 섬 백사장',
    '세부 오션 파크, 세부 사파리, 안조 월드 등 가족 관광지',
    '택시/그랩 이용 편리, 서울 대비 저렴한 요금',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightPlaneDeparture,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.travelDestinationCebu),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [히어로 배너 섹션 - Hero Banner Section]
            _buildHeroBanner(context),

            SizedBox(height: sp.s24),

            /// [역사/문화 유적지 섹션 - History/Culture Section]
            _buildSectionHeader(
              context,
              emoji: '🏛️',
              title: '역사/문화 유적지',
            ),
            SizedBox(height: sp.s12),
            _buildSpotCards(context, _historyCultureSpots, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [쇼핑/도심 관광지 섹션 - Shopping/City Section]
            _buildSectionHeader(
              context,
              emoji: '🏙️',
              title: '쇼핑/도심 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildSpotCards(context, _shoppingSpots, scheme.secondaryContainer),
            SizedBox(height: sp.s12),
            _buildTraditionalMarketCard(context),

            SizedBox(height: sp.s24),

            /// [자연/해변 관광지 섹션 - Nature/Beach Section]
            _buildSectionHeader(
              context,
              emoji: '🏖️',
              title: '자연/해변 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildSpotCards(context, _natureSpots, scheme.tertiaryContainer),

            SizedBox(height: sp.s24),

            /// [가족/어린이 관광지 섹션 - Family/Kids Section]
            _buildSectionHeader(
              context,
              emoji: '🎡',
              title: '가족/어린이 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildSpotCards(context, _familySpots, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [이동 소요 시간 섹션 - Travel Time Section]
            _buildSectionHeader(
              context,
              emoji: '🚗',
              title: '주요 관광지 이동 소요 시간',
            ),
            SizedBox(height: sp.s12),
            _buildTravelTimeSection(context),

            SizedBox(height: sp.s24),

            /// [핵심 요약 섹션 - Summary Section]
            _buildSummarySection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 히어로 배너 빌드 (Build hero banner)
  ///
  /// 세부 여행 가이드의 메인 배너를 생성합니다.
  /// Creates the main banner for Cebu travel guide.
  Widget _buildHeroBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '✈️',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🌴',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 세부 주요\n관광지 종합 안내',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '역사 유적지부터 해양 액티비티까지, 세부의 모든 것',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header with emoji)
  ///
  /// 각 섹션의 제목을 이모지와 함께 표시합니다.
  /// Displays section titles with emojis.
  Widget _buildSectionHeader(
    BuildContext context, {
    required String emoji,
    required String title,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Text(
          emoji,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(width: sp.s8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 관광지 카드 목록 빌드 (Build spot cards list)
  ///
  /// 관광지 정보를 카드 형태로 표시합니다.
  /// Displays tourist spot information in card format.
  Widget _buildSpotCards(
    BuildContext context,
    List<_SpotInfo> spots,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: spots.map((spot) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// [카드 헤더 - Card Header]
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FaIcon(
                        spot.icon,
                        size: 20,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s12),
                  Expanded(
                    child: Text(
                      spot.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),

              /// [설명 - Description]
              Text(
                spot.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              SizedBox(height: sp.s12),

              /// [특징 목록 - Features List]
              ...spot.features.map((feature) {
                return Padding(
                  padding: EdgeInsets.only(bottom: sp.s4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: sp.s8),

              /// [이동 정보 - Transport Info]
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightLocationDot,
                      size: 14,
                      color: scheme.primary,
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        spot.transport,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 전통 시장 카드 빌드 (Build traditional market card)
  ///
  /// 전통 시장 정보를 특별한 스타일의 카드로 표시합니다.
  /// Displays traditional market info in a special styled card.
  Widget _buildTraditionalMarketCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.tertiaryContainer,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    _traditionalMarketInfo.icon,
                    size: 18,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '💡',
                      style: theme.textTheme.bodyMedium,
                    ),
                    SizedBox(width: sp.s4),
                    Expanded(
                      child: Text(
                        _traditionalMarketInfo.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            _traditionalMarketInfo.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),

          /// [이동 정보 - Transport Info]
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightLocationDot,
                size: 14,
                color: scheme.tertiary,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  _traditionalMarketInfo.transport!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 이동 소요 시간 섹션 빌드 (Build travel time section)
  ///
  /// 주요 관광지까지의 거리와 이동 시간을 테이블 형태로 표시합니다.
  /// Displays distance and travel time to major attractions in table format.
  Widget _buildTravelTimeSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// [테이블 헤더 - Table Header]
          Container(
            padding: EdgeInsets.symmetric(vertical: sp.s8, horizontal: sp.s4),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '관광지',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '거리',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '소요 시간',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s8),

          /// [테이블 데이터 - Table Data]
          ..._travelTimeInfo.asMap().entries.map((entry) {
            final index = entry.key;
            final info = entry.value;
            final isEven = index % 2 == 0;

            return Container(
              padding: EdgeInsets.symmetric(vertical: sp.s8, horizontal: sp.s4),
              decoration: BoxDecoration(
                color: isEven
                    ? scheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      info['name']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      info['distance']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      info['time']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: sp.s12),

          /// [이동 팁 - Travel Tips]
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 16,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '택시/그랩 이용이 편리하며 서울 대비 저렴합니다. 장거리는 전용차량 투어나 에어컨 버스를 권장합니다. 출퇴근 시간대 정체에 유의하세요.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 핵심 요약 섹션 빌드 (Build summary section)
  ///
  /// 세부 여행의 핵심 요약을 그라데이션 카드로 표시합니다.
  /// Displays key summary of Cebu travel in a gradient card.
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🌟',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(width: sp.s8),
              Text(
                '✨',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(width: sp.s8),
              Text(
                '세부 여행 핵심 요약',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ..._summaryItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
