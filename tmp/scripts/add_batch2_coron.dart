// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 2: 팔라완 코론 지역 여행 정보 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch2_coron.dart
/// ```

// 배치 2: 팔라완 코론 지역 (35개)
final List<Map<String, dynamic>> batch2Coron = [
  {
    "name": "시에테 페카도스",
    "english name": "Siete Pecados Marine Park",
    "title": "일곱 개의 죄악 섬",
    "description": "7개의 작은 섬으로 이루어진 해양공원으로, 스노클링의 천국입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🐠",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 시에테 페카도스\n\n## 개요\n코론의 대표적인 스노클링 명소입니다.\n\n## 특징\n- 7개의 작은 섬\n- 풍부한 산호\n- 열대어 관찰",
    ],
  },
  {
    "name": "아트와얀 비치",
    "english name": "Atwayan Beach",
    "title": "청록빛 바다의 해변",
    "description": "맑고 청록빛 바다와 백사장이 어우러진 코론의 아름다운 해변입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏖️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 아트와얀 비치\n\n## 개요\n코론의 인기 해변입니다.\n\n## 특징\n- 청록빛 바다\n- 백사장\n- 수영 및 피크닉",
    ],
  },
  {
    "name": "바놀 비치",
    "english name": "Banol Beach",
    "title": "조용한 백사장 해변",
    "description": "관광객이 적은 조용하고 평화로운 백사장 해변입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🌴",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 바놀 비치\n\n## 개요\n코론의 한적한 해변입니다.\n\n## 특징\n- 한적한 분위기\n- 백사장\n- 스노클링",
    ],
  },
  {
    "name": "스미스 비치",
    "english name": "Smith Beach",
    "title": "야자수 그늘의 해변",
    "description": "야자수 그늘 아래서 휴식을 취할 수 있는 평화로운 해변입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🌴",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 스미스 비치\n\n## 개요\n코론의 조용한 해변입니다.\n\n## 특징\n- 야자수 그늘\n- 평화로운 분위기\n- 피크닉 장소",
    ],
  },
  {
    "name": "CYC 비치",
    "english name": "CYC Beach",
    "title": "요트 클럽 해변",
    "description": "코론 요트 클럽이 있는 아름다운 해변으로, 일몰 감상에 좋습니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "⛵",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# CYC 비치\n\n## 개요\n코론 요트 클럽 해변입니다.\n\n## 특징\n- 요트 클럽\n- 일몰 명소\n- 수영 가능",
    ],
  },
  {
    "name": "상갓 섬",
    "english name": "Sangat Island",
    "title": "다이빙 리조트 섬",
    "description": "다이빙 리조트가 있는 섬으로, 2차 세계대전 난파선 다이빙으로 유명합니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🤿",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 상갓 섬\n\n## 개요\n코론의 다이빙 리조트 섬입니다.\n\n## 특징\n- 난파선 다이빙\n- 다이브 리조트\n- 산호초 다이빙",
    ],
  },
  {
    "name": "쿨리온 섬",
    "english name": "Culion Island",
    "title": "역사적인 나환자촌 섬",
    "description": "과거 나환자촌이었던 역사적인 섬으로, 현재는 평화로운 관광지입니다.",
    "city": "Culion",
    "province": "Palawan",
    "icon": "🏛️",
    "category": "history-culture",
    "searchTerm": "Culion",
    "texts": [
      "# 쿨리온 섬\n\n## 개요\n역사적 의미가 있는 팔라완의 섬입니다.\n\n## 특징\n- 쿨리온 박물관\n- 역사 투어\n- 해변",
    ],
  },
  {
    "name": "루숭 건보트",
    "english name": "Lusong Gunboat",
    "title": "얕은 수심의 난파선",
    "description": "수면 가까이에 있어 스노클링으로도 볼 수 있는 일본 건보트 난파선입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🚢",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 루숭 건보트\n\n## 개요\n스노클링으로 볼 수 있는 난파선입니다.\n\n## 특징\n- 얕은 수심\n- 스노클링 가능\n- 2차 세계대전 유적",
    ],
  },
  {
    "name": "오키카와 마루",
    "english name": "Okikawa Maru Wreck",
    "title": "거대한 유조선 난파선",
    "description": "길이 160m의 거대한 일본 유조선 난파선으로, 코론 최고의 다이빙 포인트입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "⚓",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 오키카와 마루\n\n## 개요\n코론 최대의 난파선입니다.\n\n## 특징\n- 160m 길이\n- 기술 다이빙\n- 해양 생물",
    ],
  },
  {
    "name": "이라코 마루",
    "english name": "Irako Maru Wreck",
    "title": "냉동선 난파선",
    "description": "2차 세계대전 당시 격침된 일본 냉동선으로, 심해 다이빙 포인트입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🚢",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 이라코 마루\n\n## 개요\n코론의 심해 난파선입니다.\n\n## 특징\n- 심해 다이빙\n- 2차 세계대전 유적\n- 기술 다이빙",
    ],
  },
  {
    "name": "아키츠시마",
    "english name": "Akitsushima Wreck",
    "title": "수상기 모함 난파선",
    "description": "세계 유일하게 다이빙 가능한 수상기 모함 난파선입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "✈️",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 아키츠시마\n\n## 개요\n세계 유일의 다이빙 가능한 수상기 모함입니다.\n\n## 특징\n- 수상기 모함\n- 독특한 다이빙\n- 역사적 가치",
    ],
  },
  {
    "name": "모라소 마루",
    "english name": "Morazan Maru Wreck",
    "title": "화물선 난파선",
    "description": "다양한 해양 생물이 서식하는 일본 화물선 난파선입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "📦",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 모라소 마루\n\n## 개요\n코론의 화물선 난파선입니다.\n\n## 특징\n- 다양한 해양 생물\n- 중급 다이빙\n- 좋은 시야",
    ],
  },
  {
    "name": "올림피아 마루",
    "english name": "Olympia Maru Wreck",
    "title": "대형 화물선 난파선",
    "description": "코론에서 가장 큰 난파선 중 하나로, 다양한 해양 생물이 서식합니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🚢",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 올림피아 마루\n\n## 개요\n코론의 대형 난파선입니다.\n\n## 특징\n- 대형 선박\n- 해양 생물 풍부\n- 다이빙 명소",
    ],
  },
  {
    "name": "코그마 마루",
    "english name": "Kogyo Maru Wreck",
    "title": "보급선 난파선",
    "description": "건설 자재를 싣고 있던 보급선 난파선으로, 트럭 잔해를 볼 수 있습니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🚛",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 코그마 마루\n\n## 개요\n건설 자재를 싣고 있던 난파선입니다.\n\n## 특징\n- 트럭 잔해\n- 건설 장비\n- 독특한 다이빙",
    ],
  },
  {
    "name": "마마미 비치",
    "english name": "Mamami Beach",
    "title": "숨겨진 로컬 해변",
    "description": "관광객이 거의 없는 현지인들의 숨겨진 해변입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏖️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 마마미 비치\n\n## 개요\n코론의 숨겨진 해변입니다.\n\n## 특징\n- 로컬 분위기\n- 한적함\n- 백사장",
    ],
  },
  {
    "name": "디부양앙 섬",
    "english name": "Dibuyunan Island",
    "title": "스노클링 천국",
    "description": "풍부한 산호와 열대어가 서식하는 스노클링 명소입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🐠",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 디부양앙 섬\n\n## 개요\n코론의 스노클링 섬입니다.\n\n## 특징\n- 풍부한 산호\n- 열대어\n- 맑은 바다",
    ],
  },
  {
    "name": "디탈리스 섬",
    "english name": "Ditaytayan Island",
    "title": "긴 샌드바의 섬",
    "description": "길게 뻗은 하얀 샌드바가 특징인 아름다운 섬입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏝️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 디탈리스 섬\n\n## 개요\n샌드바로 유명한 코론의 섬입니다.\n\n## 특징\n- 긴 샌드바\n- 백사장\n- 사진 명소",
    ],
  },
  {
    "name": "파스 섬",
    "english name": "Pass Island",
    "title": "호핑 투어의 정거장",
    "description": "코론 호핑 투어의 인기 정거장으로, 점심 피크닉에 적합합니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🍽️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 파스 섬\n\n## 개요\n코론 호핑 투어의 정거장입니다.\n\n## 특징\n- 피크닉 장소\n- 해변 점심\n- 스노클링",
    ],
  },
  {
    "name": "블랙 아일랜드",
    "english name": "Black Island (Malajon Island)",
    "title": "검은 절벽의 신비로운 섬",
    "description": "검은색 석회암 절벽이 인상적인 신비로운 분위기의 섬입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🖤",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 블랙 아일랜드\n\n## 개요\n검은 절벽으로 유명한 섬입니다.\n\n## 특징\n- 검은 석회암 절벽\n- 동굴 탐험\n- 해변",
    ],
  },
  {
    "name": "마라카논 섬",
    "english name": "Malcapuya Island",
    "title": "파라다이스 해변 섬",
    "description": "코론 지역에서 가장 아름다운 백사장 중 하나로 꼽히는 섬입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏖️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 마라카논 섬\n\n## 개요\n코론 최고의 해변 섬입니다.\n\n## 특징\n- 아름다운 백사장\n- 청록빛 바다\n- 피크닉",
    ],
  },
  {
    "name": "칼라미안 제도",
    "english name": "Calamianes Islands",
    "title": "섬들의 천국",
    "description": "코론, 부수앙가, 쿨리온 등 여러 섬으로 이루어진 아름다운 제도입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🗺️",
    "category": "nature",
    "searchTerm": "Calamianes",
    "texts": [
      "# 칼라미안 제도\n\n## 개요\n팔라완 북부의 섬 군도입니다.\n\n## 특징\n- 여러 섬 구성\n- 다양한 액티비티\n- 자연 경관",
    ],
  },
  {
    "name": "코론 뷰덱",
    "english name": "Coron Viewdeck",
    "title": "코론 타운 전망대",
    "description": "700개의 계단을 오르면 코론 타운과 주변 섬들의 장관이 펼쳐집니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏔️",
    "category": "nature",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 코론 뷰덱\n\n## 개요\n코론 타운의 전망대입니다.\n\n## 특징\n- 700계단\n- 파노라마 뷰\n- 일출/일몰 명소",
    ],
  },
  {
    "name": "바락 비치",
    "english name": "Barracuda Lake Beach",
    "title": "바라쿠다 호수 입구 해변",
    "description": "바라쿠다 호수로 가는 길목에 있는 작은 해변입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏖️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 바락 비치\n\n## 개요\n바라쿠다 호수 입구의 해변입니다.\n\n## 특징\n- 호수 입구\n- 휴식 공간\n- 스노클링",
    ],
  },
  {
    "name": "디코롬 섬",
    "english name": "Dicorom Island",
    "title": "조용한 무인도",
    "description": "개발되지 않은 자연 그대로의 조용한 무인도입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏝️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 디코롬 섬\n\n## 개요\n코론의 조용한 무인도입니다.\n\n## 특징\n- 무인도\n- 자연 그대로\n- 평화로운 분위기",
    ],
  },
  {
    "name": "라하 섬",
    "english name": "Laha Island",
    "title": "호핑 투어 스탑",
    "description": "코론 호핑 투어에서 방문하는 작은 섬입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏝️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 라하 섬\n\n## 개요\n코론 호핑 투어 정거장입니다.\n\n## 특징\n- 작은 섬\n- 스노클링\n- 피크닉",
    ],
  },
  {
    "name": "칼루이트 기린",
    "english name": "Calauit Safari Giraffe Encounter",
    "title": "기린 먹이주기 체험",
    "description": "칼라위트 사파리에서 기린에게 직접 먹이를 줄 수 있는 체험입니다.",
    "city": "Busuanga",
    "province": "Palawan",
    "icon": "🦒",
    "category": "nature",
    "searchTerm": "Calauit_Safari_Park",
    "texts": [
      "# 칼루이트 기린\n\n## 개요\n칼라위트 사파리의 기린 체험입니다.\n\n## 특징\n- 기린 먹이주기\n- 아프리카 동물\n- 가족 친화적",
    ],
  },
  {
    "name": "부수앙가 만 코랄가든",
    "english name": "Busuanga Bay Coral Garden",
    "title": "산호 정원",
    "description": "다양한 종류의 산호가 군락을 이루고 있는 스노클링 포인트입니다.",
    "city": "Busuanga",
    "province": "Palawan",
    "icon": "🪸",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 부수앙가 만 코랄가든\n\n## 개요\n부수앙가의 산호 정원입니다.\n\n## 특징\n- 다양한 산호\n- 스노클링\n- 해양 생물",
    ],
  },
  {
    "name": "빅 드림 보트맨 아일랜드",
    "english name": "Big Dream Boatman Island",
    "title": "다이빙 베이스 섬",
    "description": "다이빙 투어의 베이스로 사용되는 작은 섬입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🤿",
    "category": "diving",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 빅 드림 보트맨 아일랜드\n\n## 개요\n코론의 다이빙 베이스 섬입니다.\n\n## 특징\n- 다이빙 투어\n- 리브어보드\n- 숙박 가능",
    ],
  },
  {
    "name": "코론 베이 선셋",
    "english name": "Coron Bay Sunset Cruise",
    "title": "일몰 크루즈",
    "description": "코론 베이에서 즐기는 로맨틱한 일몰 크루즈입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🌅",
    "category": "water-sports",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 코론 베이 선셋\n\n## 개요\n코론의 일몰 크루즈입니다.\n\n## 특징\n- 선셋 크루즈\n- 로맨틱\n- 와인 서비스",
    ],
  },
  {
    "name": "디마양앙 섬",
    "english name": "Dimanglet Island",
    "title": "원시 열대 섬",
    "description": "개발되지 않은 원시 그대로의 열대 섬입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🌴",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 디마양앙 섬\n\n## 개요\n코론의 원시 열대 섬입니다.\n\n## 특징\n- 개발 안됨\n- 원시 자연\n- 탐험",
    ],
  },
  {
    "name": "카바요 비치",
    "english name": "Cabayo Beach",
    "title": "고요한 현지 해변",
    "description": "현지인들이 즐겨 찾는 고요하고 평화로운 해변입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏖️",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 카바요 비치\n\n## 개요\n코론의 현지 해변입니다.\n\n## 특징\n- 현지 분위기\n- 조용함\n- 수영",
    ],
  },
  {
    "name": "카노보 섬",
    "english name": "Canobo Island",
    "title": "프라이빗 리조트 섬",
    "description": "프라이빗 리조트가 있는 독점적인 섬입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🏨",
    "category": "beaches-islands",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 카노보 섬\n\n## 개요\n코론의 프라이빗 리조트 섬입니다.\n\n## 특징\n- 프라이빗 리조트\n- 독점적\n- 럭셔리",
    ],
  },
  {
    "name": "타오 익스피디션",
    "english name": "Tao Expedition",
    "title": "섬 호핑 어드벤처",
    "description": "코론에서 엘니도까지 5일간의 섬 호핑 어드벤처 투어입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "⛵",
    "category": "water-sports",
    "searchTerm": "El_Nido,_Palawan",
    "texts": [
      "# 타오 익스피디션\n\n## 개요\n코론-엘니도 5일 어드벤처입니다.\n\n## 특징\n- 5일 여정\n- 섬 호핑\n- 어드벤처",
    ],
  },
  {
    "name": "코론 마켓",
    "english name": "Coron Public Market",
    "title": "현지 수산물 시장",
    "description": "신선한 해산물과 현지 음식을 맛볼 수 있는 전통 시장입니다.",
    "city": "Coron",
    "province": "Palawan",
    "icon": "🦀",
    "category": "food",
    "searchTerm": "Coron,_Palawan",
    "texts": [
      "# 코론 마켓\n\n## 개요\n코론의 전통 시장입니다.\n\n## 특징\n- 신선한 해산물\n- 현지 음식\n- 저렴한 가격",
    ],
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  //  print('======================================');
  //  print('📋 배치 2: 팔라완 코론 지역 추가');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  //  print('현재 여행지 수: ${travelSpots.length}개');

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);

  // 기존 이름 목록 (중복 체크용)
  final existingNames = <String>{};
  final existingEnglishNames = <String>{};
  for (final spot in travelSpots) {
    existingNames.add(spot['name']?.toString().toLowerCase() ?? '');
    existingEnglishNames.add(
      spot['english name']?.toString().toLowerCase() ?? '',
    );
  }

  int added = 0;
  int skipped = 0;

  //  print('\n📍 코론 지역 여행지 추가 중...\n');

  for (final spot in batch2Coron) {
    final name = spot['name'] as String;
    final englishName = spot['english name'] as String;

    // 중복 체크
    if (existingNames.contains(name.toLowerCase()) ||
        existingEnglishNames.contains(englishName.toLowerCase())) {
      //      print('⏭️  $name: 이미 존재 (건너뜀)');
      skipped++;
      continue;
    }

    // Wikipedia API로 이미지 가져오기
    final searchTerm = spot['searchTerm'] as String;
    String? imageUrl;

    try {
      final apiUrl =
          'https://en.wikipedia.org/w/api.php?action=query&titles=$searchTerm&prop=pageimages&format=json&pithumbsize=800';
      final uri = Uri.parse(apiUrl);
      final request = await httpClient.getUrl(uri);
      request.headers.add('User-Agent', 'Mozilla/5.0');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final pages = data['query']?['pages'] as Map<String, dynamic>?;

        if (pages != null && pages.isNotEmpty) {
          final page = pages.values.first as Map<String, dynamic>;
          final thumbnail = page['thumbnail'] as Map<String, dynamic>?;
          if (thumbnail != null) {
            imageUrl = thumbnail['source'] as String;
          }
        }
      }
    } catch (e) {
      //      print('   ⚠️  이미지 가져오기 실패: $e');
    }

    // 이미지 URL이 없으면 Coron 기본 이미지 사용
    imageUrl ??=
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Coron_Town_with_Mt._Tapyas_%28Palawan%2C_Philippines%29.jpg/960px-Coron_Town_with_Mt._Tapyas_%28Palawan%2C_Philippines%29.jpg';

    // 새 항목 생성
    final newSpot = {
      'name': name,
      'english name': englishName,
      'title': spot['title'],
      'description': spot['description'],
      'city': spot['city'],
      'province': spot['province'],
      'icon': spot['icon'],
      'category': spot['category'],
      'imageUrl': imageUrl,
      'texts': spot['texts'],
    };

    travelSpots.add(newSpot);
    existingNames.add(name.toLowerCase());
    existingEnglishNames.add(englishName.toLowerCase());
    added++;

    //    print('✅ $name 추가됨');

    // Rate limiting 방지
    await Future.delayed(const Duration(milliseconds: 300));
  }

  httpClient.close();

  // JSON 파일 저장
  final encoder = const JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(travelSpots);
  file.writeAsStringSync(updatedJsonString);

  //  print('\n======================================');
  //  print('📊 배치 2 결과 요약');
  //  print('======================================');
  //  print('✅ 추가됨: $added개');
  //  print('⏭️  건너뜀: $skipped개');
  //  print('📊 현재 총 개수: ${travelSpots.length}개');
  //  print('\n📁 $jsonFilePath 파일이 수정되었습니다.');
}
