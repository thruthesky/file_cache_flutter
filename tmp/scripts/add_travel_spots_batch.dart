// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 여행 정보를 배치로 추가하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_travel_spots_batch.dart
/// ```

// 배치 1: 팔라완 엘니도 지역 (35개)
final List<Map<String, dynamic>> batch1ElNido = [
  {
    "name": "카들라오 섬",
    "english name": "Cadlao Island",
    "title": "엘니도의 거대한 섬",
    "description": "엘니도 앞바다에 위치한 가장 큰 섬으로, 하이킹과 해변 탐험이 가능합니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏝️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 카들라오 섬\n\n## 개요\n엘니도 타운 앞에 우뚝 솟은 가장 큰 섬입니다.\n\n## 특징\n- 카들라오 라군\n- 파라다이스 비치\n- 하이킹 트레일"]
  },
  {
    "name": "딜루마카드 섬",
    "english name": "Dilumacad Island (Helicopter Island)",
    "title": "헬리콥터 모양의 섬",
    "description": "하늘에서 보면 헬리콥터 모양을 닮아 헬리콥터 섬이라고 불리는 아름다운 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🚁",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 딜루마카드 섬\n\n## 개요\n헬리콥터 모양으로 유명한 엘니도의 인기 섬입니다.\n\n## 특징\n- 독특한 섬 모양\n- 스노클링 포인트\n- 화이트 비치"]
  },
  {
    "name": "피나그부유탄 섬",
    "english name": "Pinagbuyutan Island",
    "title": "천혜의 무인도 해변",
    "description": "길고 하얀 모래사장과 청록색 바다가 어우러진 그림 같은 무인도입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏖️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 피나그부유탄 섬\n\n## 개요\n엘니도 투어 C의 하이라이트 섬입니다.\n\n## 특징\n- 긴 백사장\n- 피크닉 장소\n- 수영 및 스노클링"]
  },
  {
    "name": "미닐록 섬",
    "english name": "Miniloc Island",
    "title": "빅 라군과 스몰 라군의 본거지",
    "description": "엘니도의 상징적인 빅 라군과 스몰 라군이 있는 석회암 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏝️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 미닐록 섬\n\n## 개요\n엘니도 투어 A의 중심 섬입니다.\n\n## 특징\n- 빅 라군 입구\n- 스몰 라군 입구\n- 럭셔리 리조트"]
  },
  {
    "name": "팡울라시안 섬",
    "english name": "Pangulasian Island",
    "title": "럭셔리 아일랜드 리조트",
    "description": "백사장과 청록빛 바다가 어우러진 프라이빗 럭셔리 리조트 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🌴",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 팡울라시안 섬\n\n## 개요\n엘니도 리조트가 운영하는 럭셔리 섬입니다.\n\n## 특징\n- 프라이빗 비치\n- 고급 리조트\n- 선라이즈 명소"]
  },
  {
    "name": "파파야 비치",
    "english name": "Papaya Beach",
    "title": "한적한 숨겨진 해변",
    "description": "관광객이 적은 한적한 해변으로, 조용한 휴식을 원하는 이들에게 인기입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏖️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 파파야 비치\n\n## 개요\n엘니도의 숨겨진 보석 같은 해변입니다.\n\n## 특징\n- 한적한 분위기\n- 스노클링\n- 피크닉 장소"]
  },
  {
    "name": "히든 비치",
    "english name": "Hidden Beach",
    "title": "동굴 속 비밀 해변",
    "description": "좁은 석회암 통로를 지나야 나오는 숨겨진 해변으로, 신비로운 분위기가 특징입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🔮",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 히든 비치\n\n## 개요\n마틴록 섬에 위치한 숨겨진 해변입니다.\n\n## 특징\n- 동굴 입구\n- 비밀스러운 분위기\n- 수영 가능"]
  },
  {
    "name": "스타 비치",
    "english name": "Star Beach",
    "title": "불가사리 천국",
    "description": "다양한 색상의 불가사리를 볼 수 있는 얕은 바다가 특징인 해변입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "⭐",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 스타 비치\n\n## 개요\n불가사리로 유명한 엘니도의 해변입니다.\n\n## 특징\n- 다양한 불가사리\n- 얕은 바다\n- 가족 친화적"]
  },
  {
    "name": "탈리사이 비치",
    "english name": "Talisay Beach",
    "title": "조용한 로컬 해변",
    "description": "현지인들이 즐겨 찾는 조용하고 평화로운 해변입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🌊",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 탈리사이 비치\n\n## 개요\n엘니도 타운에서 가까운 로컬 해변입니다.\n\n## 특징\n- 현지 분위기\n- 조용한 환경\n- 일몰 감상"]
  },
  {
    "name": "데펠데트 섬",
    "english name": "Depeldet Island",
    "title": "프라이빗 섬 체험",
    "description": "작고 아담한 섬으로, 조용한 섬 체험을 원하는 이들에게 적합합니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏝️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 데펠데트 섬\n\n## 개요\n엘니도의 작은 프라이빗 섬입니다.\n\n## 특징\n- 소규모 섬\n- 프라이빗 느낌\n- 스노클링"]
  },
  {
    "name": "스네이크 아일랜드",
    "english name": "Snake Island (Vigan Island)",
    "title": "뱀처럼 구불구불한 모래톱",
    "description": "썰물 때 드러나는 S자 형태의 긴 모래톱이 특징인 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🐍",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 스네이크 아일랜드\n\n## 개요\n비간 아일랜드라고도 불리는 모래톱 섬입니다.\n\n## 특징\n- S자 모래톱\n- 썰물 시 도보 가능\n- 사진 명소"]
  },
  {
    "name": "엔탈루라 아일랜드",
    "english name": "Entalula Island",
    "title": "하얀 모래와 야자수의 파라다이스",
    "description": "긴 백사장과 야자수가 어우러진 전형적인 열대 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🌴",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 엔탈루라 아일랜드\n\n## 개요\n엘니도 투어의 인기 정차지입니다.\n\n## 특징\n- 넓은 백사장\n- 야자수 숲\n- 비치 피크닉"]
  },
  {
    "name": "쿠두그논 동굴",
    "english name": "Cudugnon Cave",
    "title": "고대 유적이 발견된 동굴",
    "description": "신석기 시대 유물이 발견된 역사적인 동굴로, 탐험과 수영이 가능합니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🦇",
    "category": "nature",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 쿠두그논 동굴\n\n## 개요\n엘니도의 역사적인 동굴입니다.\n\n## 특징\n- 신석기 유물 발견지\n- 동굴 탐험\n- 투어 C 포함"]
  },
  {
    "name": "시미즈 다이빙 사이트",
    "english name": "Shimizu Diving Site",
    "title": "산호와 열대어의 세계",
    "description": "다양한 산호와 열대어가 서식하는 엘니도 최고의 다이빙 포인트입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🤿",
    "category": "diving",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 시미즈 다이빙 사이트\n\n## 개요\n시미즈 아일랜드 근처의 다이빙 포인트입니다.\n\n## 특징\n- 다양한 산호\n- 열대어 관찰\n- 초보자 적합"]
  },
  {
    "name": "사우스 미닐록 다이빙 사이트",
    "english name": "South Miniloc Diving Site",
    "title": "수심 깊은 다이빙 포인트",
    "description": "미닐록 섬 남쪽의 다이빙 포인트로, 다양한 해양 생물을 관찰할 수 있습니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🐠",
    "category": "diving",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 사우스 미닐록 다이빙 사이트\n\n## 개요\n미닐록 섬 남쪽의 다이빙 명소입니다.\n\n## 특징\n- 다양한 수심\n- 해양 생물 풍부\n- 경험자 추천"]
  },
  {
    "name": "딜럼파냐 섬",
    "english name": "Dilumpayna Island",
    "title": "투어 B의 숨은 보석",
    "description": "엘니도 투어 B에서 방문하는 작고 아름다운 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏝️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 딜럼파냐 섬\n\n## 개요\n엘니도 투어 B의 정차지입니다.\n\n## 특징\n- 작은 섬\n- 스노클링\n- 한적한 분위기"]
  },
  {
    "name": "마탁인 섬",
    "english name": "Matinloc Island",
    "title": "마틴록 신사가 있는 섬",
    "description": "버려진 성당과 신비로운 분위기가 특징인 석회암 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "⛪",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 마탁인 섬\n\n## 개요\n마틴록 신사로 유명한 섬입니다.\n\n## 특징\n- 버려진 성당\n- 시크릿 비치\n- 투어 C 포함"]
  },
  {
    "name": "타피탄 스트레이트",
    "english name": "Tapuitan Strait",
    "title": "카약킹 명소",
    "description": "잔잔한 물살과 아름다운 석회암 절벽 사이를 카약으로 탐험할 수 있습니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🛶",
    "category": "water-sports",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 타피탄 스트레이트\n\n## 개요\n엘니도의 카약킹 명소입니다.\n\n## 특징\n- 카약 투어\n- 석회암 절벽\n- 조용한 물길"]
  },
  {
    "name": "이필 비치",
    "english name": "Ipil Beach",
    "title": "선셋 포인트",
    "description": "엘니도 타운 근처에서 일몰을 감상하기 좋은 해변입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🌅",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 이필 비치\n\n## 개요\n엘니도의 일몰 명소입니다.\n\n## 특징\n- 일몰 감상\n- 타운 근처\n- 로맨틱 분위기"]
  },
  {
    "name": "마리마바자 섬",
    "english name": "Marimaba Island",
    "title": "프라이빗 피크닉 섬",
    "description": "작은 규모의 조용한 섬으로, 프라이빗 피크닉을 즐기기에 적합합니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🧺",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 마리마바자 섬\n\n## 개요\n엘니도의 소규모 피크닉 섬입니다.\n\n## 특징\n- 프라이빗 분위기\n- 피크닉 장소\n- 스노클링"]
  },
  {
    "name": "나긋-나긋 해변",
    "english name": "Nagkalit-kalit Beach",
    "title": "바위와 해변의 조화",
    "description": "독특한 바위 지형과 해변이 어우러진 사진 명소입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "📷",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 나긋-나긋 해변\n\n## 개요\n엘니도 근교의 독특한 해변입니다.\n\n## 특징\n- 바위 지형\n- 사진 명소\n- 일몰 감상"]
  },
  {
    "name": "코랄리 비치",
    "english name": "Corally Beach",
    "title": "조용한 산호 해변",
    "description": "산호가 풍부한 조용한 해변으로, 스노클링하기 좋습니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🪸",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 코랄리 비치\n\n## 개요\n산호로 유명한 엘니도의 해변입니다.\n\n## 특징\n- 풍부한 산호\n- 스노클링\n- 한적한 분위기"]
  },
  {
    "name": "헬레나 가든",
    "english name": "Helena's Garden",
    "title": "산호 정원",
    "description": "다양한 산호가 군락을 이루고 있는 스노클링 포인트입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🌺",
    "category": "diving",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 헬레나 가든\n\n## 개요\n엘니도의 스노클링 명소입니다.\n\n## 특징\n- 산호 정원\n- 열대어 관찰\n- 스노클링 추천"]
  },
  {
    "name": "파사디타 코브",
    "english name": "Pasadita Cove",
    "title": "작은 석호",
    "description": "빅 라군 근처에 있는 작은 석호로, 카약으로 탐험할 수 있습니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🛶",
    "category": "nature",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 파사디타 코브\n\n## 개요\n빅 라군 근처의 작은 석호입니다.\n\n## 특징\n- 카약 탐험\n- 석회암 절벽\n- 조용한 분위기"]
  },
  {
    "name": "리오 비치",
    "english name": "Lio Beach",
    "title": "럭셔리 리조트 해변",
    "description": "고급 리조트와 레스토랑이 있는 개발된 해변 지역입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏨",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 리오 비치\n\n## 개요\n엘니도의 개발된 리조트 해변입니다.\n\n## 특징\n- 럭셔리 리조트\n- 레스토랑 거리\n- 해변 클럽"]
  },
  {
    "name": "다퀘트 비치",
    "english name": "Daqueit Beach",
    "title": "현지인의 숨은 해변",
    "description": "관광객이 적은 현지인들의 비밀 해변입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏖️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 다퀘트 비치\n\n## 개요\n엘니도의 숨겨진 로컬 해변입니다.\n\n## 특징\n- 현지인 추천\n- 조용한 분위기\n- 수영 가능"]
  },
  {
    "name": "팡알랍 폭포",
    "english name": "Pangalap Falls",
    "title": "정글 속 숨은 폭포",
    "description": "엘니도 내륙 정글 속에 있는 상쾌한 폭포입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "💦",
    "category": "waterfalls",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 팡알랍 폭포\n\n## 개요\n엘니도 정글 속의 폭포입니다.\n\n## 특징\n- 트레킹 필요\n- 수영 가능\n- 자연 경관"]
  },
  {
    "name": "나그카릿카릿 폭포",
    "english name": "Nagkalit-kalit Falls",
    "title": "쌍둥이 폭포",
    "description": "두 갈래로 갈라지는 아름다운 쌍둥이 폭포입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🌊",
    "category": "waterfalls",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 나그카릿카릿 폭포\n\n## 개요\n엘니도의 쌍둥이 폭포입니다.\n\n## 특징\n- 두 갈래 폭포\n- 트레킹\n- 수영 가능"]
  },
  {
    "name": "마구에이 섬",
    "english name": "Maguey Island",
    "title": "프라이빗 아일랜드 피크닉",
    "description": "프라이빗 아일랜드 피크닉을 즐길 수 있는 작은 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🍽️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 마구에이 섬\n\n## 개요\n엘니도의 피크닉 섬입니다.\n\n## 특징\n- 프라이빗 투어\n- 점심 피크닉\n- 스노클링"]
  },
  {
    "name": "라겐 섬",
    "english name": "Lagen Island",
    "title": "에코 리조트 섬",
    "description": "에코 프렌들리 럭셔리 리조트가 있는 자연 보호 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🌿",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 라겐 섬\n\n## 개요\n엘니도 리조트의 에코 리조트 섬입니다.\n\n## 특징\n- 에코 리조트\n- 프라이빗 비치\n- 카약킹"]
  },
  {
    "name": "아브이트 섬",
    "english name": "Abuuet Island",
    "title": "작은 열대 파라다이스",
    "description": "야자수와 하얀 모래가 어우러진 작은 열대 섬입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🌴",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 아브이트 섬\n\n## 개요\n엘니도의 작은 열대 섬입니다.\n\n## 특징\n- 야자수 해변\n- 백사장\n- 스노클링"]
  },
  {
    "name": "쿄와 섬",
    "english name": "Kyowa Island",
    "title": "평화로운 무인도",
    "description": "관광객이 거의 없는 평화로운 무인도입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🏝️",
    "category": "beaches-islands",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 쿄와 섬\n\n## 개요\n엘니도의 조용한 무인도입니다.\n\n## 특징\n- 무인도 체험\n- 평화로운 분위기\n- 스노클링"]
  },
  {
    "name": "엘니도 씨푸드 마켓",
    "english name": "El Nido Seafood Market",
    "title": "신선한 해산물의 천국",
    "description": "현지에서 잡은 신선한 해산물을 맛볼 수 있는 시장입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🦐",
    "category": "food",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 엘니도 씨푸드 마켓\n\n## 개요\n엘니도의 해산물 시장입니다.\n\n## 특징\n- 신선한 해산물\n- 현지 요리\n- 저렴한 가격"]
  },
  {
    "name": "카누엔 섬",
    "english name": "Canuen Island",
    "title": "다이버들의 비밀 장소",
    "description": "숙련된 다이버들이 찾는 산호 보존이 잘된 다이빙 포인트입니다.",
    "city": "El Nido",
    "province": "Palawan",
    "icon": "🤿",
    "category": "diving",
    "searchTerm": "El_Nido,_Palawan",
    "texts": ["# 카누엔 섬\n\n## 개요\n엘니도의 다이빙 명소입니다.\n\n## 특징\n- 산호 보존 양호\n- 다이빙 포인트\n- 해양 생물 다양"]
  }
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  print('======================================');
  print('📋 여행 정보 배치 추가 도구');
  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  print('현재 여행지 수: ${travelSpots.length}개');

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);

  // 기존 이름 목록 (중복 체크용)
  final existingNames = <String>{};
  final existingEnglishNames = <String>{};
  for (final spot in travelSpots) {
    existingNames.add(spot['name']?.toString().toLowerCase() ?? '');
    existingEnglishNames.add(spot['english name']?.toString().toLowerCase() ?? '');
  }

  int added = 0;
  int skipped = 0;

  // 배치 1: 엘니도 지역 추가
  print('\n📍 배치 1: 팔라완 엘니도 지역 추가 중...\n');

  for (final spot in batch1ElNido) {
    final name = spot['name'] as String;
    final englishName = spot['english name'] as String;

    // 중복 체크
    if (existingNames.contains(name.toLowerCase()) ||
        existingEnglishNames.contains(englishName.toLowerCase())) {
      print('⏭️  $name: 이미 존재 (건너뜀)');
      skipped++;
      continue;
    }

    // Wikipedia API로 이미지 가져오기
    final searchTerm = spot['searchTerm'] as String;
    String? imageUrl;

    try {
      final apiUrl = 'https://en.wikipedia.org/w/api.php?action=query&titles=$searchTerm&prop=pageimages&format=json&pithumbsize=800';
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
      print('   ⚠️  이미지 가져오기 실패: $e');
    }

    // 이미지 URL이 없으면 El Nido 기본 이미지 사용
    imageUrl ??= 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/El_Nido_Bay_December_2018.jpg/960px-El_Nido_Bay_December_2018.jpg';

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

    print('✅ $name 추가됨');

    // Rate limiting 방지
    await Future.delayed(const Duration(milliseconds: 300));
  }

  httpClient.close();

  // JSON 파일 저장
  final encoder = const JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(travelSpots);
  file.writeAsStringSync(updatedJsonString);

  print('\n======================================');
  print('📊 배치 1 결과 요약');
  print('======================================');
  print('✅ 추가됨: $added개');
  print('⏭️  건너뜀: $skipped개');
  print('📊 현재 총 개수: ${travelSpots.length}개');
  print('\n📁 $jsonFilePath 파일이 수정되었습니다.');
}
