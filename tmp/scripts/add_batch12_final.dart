// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 배치 12: 추가 보완 여행지 추가 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/add_batch12_final.dart
/// ```

// 추가 보완 여행지 데이터 (다양한 지역의 누락된 명소들)
final List<Map<String, dynamic>> batch12Spots = [
  // 추가 팔라완 명소
  {
    'name': '포트 바튼',
    'englishName': 'Port Barton',
    'searchTerm': 'Port_Barton',
    'title': '숨겨진 낙원',
    'description': '엘니도와 푸에르토 프린세사 사이의 조용한 해변 마을입니다.',
    'city': 'San Vicente',
    'province': 'Palawan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '산 비센테 롱비치',
    'englishName': 'San Vicente Long Beach',
    'searchTerm': 'San_Vicente,_Palawan',
    'title': '필리핀 최장 해변',
    'description': '14km에 달하는 필리핀에서 가장 긴 백사장 해변입니다.',
    'city': 'San Vicente',
    'province': 'Palawan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '타봉 케이브',
    'englishName': 'Tabon Caves',
    'searchTerm': 'Tabon_Caves',
    'title': '문명의 요람',
    'description': '선사시대 유적이 발견된 팔라완의 동굴 시스템입니다.',
    'city': 'Quezon',
    'province': 'Palawan',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '발라박 섬',
    'englishName': 'Balabac Island',
    'searchTerm': 'Balabac,_Palawan',
    'title': '팔라완의 끝',
    'description': '팔라완 최남단의 섬으로 말레이시아와 가깝습니다.',
    'city': 'Balabac',
    'province': 'Palawan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '온욱 섬',
    'englishName': 'Onuk Island',
    'searchTerm': 'Balabac,_Palawan',
    'title': '발라박의 보석',
    'description': '발라박의 아름다운 무인도입니다.',
    'city': 'Balabac',
    'province': 'Palawan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '리리 아일랜드',
    'englishName': 'Liuli Island',
    'searchTerm': 'Palawan',
    'title': '핑크 비치',
    'description': '발라박의 핑크빛 모래 해변이 있는 섬입니다.',
    'city': 'Balabac',
    'province': 'Palawan',
    'icon': 'beach',
    'category': '해변',
  },

  // 추가 세부/보홀 명소
  {
    'name': '세부 오션 파크',
    'englishName': 'Cebu Ocean Park',
    'searchTerm': 'Cebu',
    'title': '해양 테마파크',
    'description': '세부 시티의 해양 테마파크입니다.',
    'city': 'Cebu City',
    'province': 'Cebu',
    'icon': 'park',
    'category': '자연',
  },
  {
    'name': '스미론 섬',
    'englishName': 'Smilon Island',
    'searchTerm': 'Oslob',
    'title': '오슬롭 근처 섬',
    'description': '오슬롭 고래상어 체험 후 방문하기 좋은 섬입니다.',
    'city': 'Oslob',
    'province': 'Cebu',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '보홀 패들보드',
    'englishName': 'Bohol Paddleboard',
    'searchTerm': 'Bohol',
    'title': 'SUP 체험',
    'description': '팡라오에서 즐기는 스탠드업 패들보드입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'paddle',
    'category': '수상스포츠',
  },
  {
    'name': '칼리파요 강',
    'englishName': 'Calipayo River',
    'searchTerm': 'Bohol',
    'title': '강 투어',
    'description': '보홀의 또 다른 강 크루즈 명소입니다.',
    'city': 'Dimiao',
    'province': 'Bohol',
    'icon': 'river',
    'category': '자연',
  },

  // 추가 보라카이/비사야 명소
  {
    'name': '보라카이 스탠드업패들',
    'englishName': 'Boracay SUP',
    'searchTerm': 'Boracay',
    'title': 'SUP 체험',
    'description': '보라카이에서 즐기는 스탠드업 패들보드입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'paddle',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 웨이크보드',
    'englishName': 'Boracay Wakeboard',
    'searchTerm': 'Boracay',
    'title': '웨이크보드',
    'description': '보라카이에서 즐기는 웨이크보드 액티비티입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'watersport',
    'category': '수상스포츠',
  },
  {
    'name': '보라카이 스노클링',
    'englishName': 'Boracay Snorkeling',
    'searchTerm': 'Boracay',
    'title': '스노클링 투어',
    'description': '보라카이 주변의 스노클링 포인트 투어입니다.',
    'city': 'Malay',
    'province': 'Aklan',
    'icon': 'snorkeling',
    'category': '수상스포츠',
  },
  {
    'name': '힐리가이논 비치',
    'englishName': 'Hiligaynon Beach',
    'searchTerm': 'Iloilo',
    'title': '일로일로 해변',
    'description': '일로일로 지역의 해변입니다.',
    'city': 'Iloilo City',
    'province': 'Iloilo',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '안티케 해변',
    'englishName': 'Antique Beach',
    'searchTerm': 'Antique_(province)',
    'title': '안티케 지역 해변',
    'description': '파나이 섬 서쪽 안티케 지역의 해변입니다.',
    'city': 'San Jose',
    'province': 'Antique',
    'icon': 'beach',
    'category': '해변',
  },

  // 추가 마닐라 근교 명소
  {
    'name': '수빅 오션 어드벤처',
    'englishName': 'Subic Ocean Adventure',
    'searchTerm': 'Subic_Bay',
    'title': '해양 테마파크',
    'description': '수빅 베이의 해양 테마파크입니다.',
    'city': 'Subic',
    'province': 'Zambales',
    'icon': 'park',
    'category': '자연',
  },
  {
    'name': '수빅 사파리',
    'englishName': 'Subic Safari',
    'searchTerm': 'Subic_Bay',
    'title': '동물 사파리',
    'description': '수빅 베이의 야생동물 사파리 파크입니다.',
    'city': 'Subic',
    'province': 'Zambales',
    'icon': 'safari',
    'category': '자연',
  },
  {
    'name': '인플레터블 아일랜드 수빅',
    'englishName': 'Inflatable Island Subic',
    'searchTerm': 'Subic_Bay',
    'title': '물놀이 파크',
    'description': '아시아 최대의 플로팅 물놀이 파크입니다.',
    'city': 'Subic',
    'province': 'Zambales',
    'icon': 'waterpark',
    'category': '수상스포츠',
  },
  {
    'name': '타가이타이 피플스 파크',
    'englishName': 'Tagaytay Peoples Park',
    'searchTerm': 'Tagaytay',
    'title': '타알 전망대',
    'description': '타알 호수와 화산을 볼 수 있는 전망대 공원입니다.',
    'city': 'Tagaytay',
    'province': 'Cavite',
    'icon': 'viewpoint',
    'category': '자연',
  },
  {
    'name': '스카이 랜치 타가이타이',
    'englishName': 'Sky Ranch Tagaytay',
    'searchTerm': 'Tagaytay',
    'title': '놀이공원',
    'description': '타가이타이의 놀이공원으로 관람차가 유명합니다.',
    'city': 'Tagaytay',
    'province': 'Cavite',
    'icon': 'amusement',
    'category': '자연',
  },

  // 추가 폭포 명소
  {
    'name': '마리아 크리스티나 폭포',
    'englishName': 'Maria Cristina Falls',
    'searchTerm': 'Maria_Cristina_Falls',
    'title': '필리핀의 나이아가라',
    'description': '일리간 시티의 대형 폭포로 발전에 이용됩니다. (민다나오 제외 참고용)',
    'city': 'Iligan',
    'province': 'Lanao del Norte',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '파가다 폭포',
    'englishName': 'Pagayayan Falls',
    'searchTerm': 'Laguna',
    'title': '라구나 폭포',
    'description': '라구나의 숨겨진 폭포입니다.',
    'city': 'Majayjay',
    'province': 'Laguna',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '타판 폭포',
    'englishName': 'Tapaan Falls',
    'searchTerm': 'Laguna',
    'title': '라구나 캐녀닝',
    'description': '라구나의 캐녀닝 폭포 코스입니다.',
    'city': 'Paete',
    'province': 'Laguna',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 추가 섬 명소
  {
    'name': '쿨리온 섬',
    'englishName': 'Culion Island',
    'searchTerm': 'Culion',
    'title': '역사적 섬',
    'description': '과거 나병 환자 격리 시설이 있던 역사적인 섬입니다.',
    'city': 'Culion',
    'province': 'Palawan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '부수앙가 섬',
    'englishName': 'Busuanga Island',
    'searchTerm': 'Busuanga,_Palawan',
    'title': '코론의 메인 섬',
    'description': '코론 지역의 가장 큰 섬으로 공항이 있습니다.',
    'city': 'Coron',
    'province': 'Palawan',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '카미긴 섬',
    'englishName': 'Camiguin Island',
    'searchTerm': 'Camiguin',
    'title': '화산 섬',
    'description': '7개의 화산이 있는 작은 섬으로 독특한 자연이 있습니다.',
    'city': 'Mambajao',
    'province': 'Camiguin',
    'icon': 'island',
    'category': '섬',
  },
  {
    'name': '화이트 아일랜드 카미긴',
    'englishName': 'White Island Camiguin',
    'searchTerm': 'Camiguin',
    'title': '하얀 모래섬',
    'description': '카미긴 근처의 작은 모래섬입니다.',
    'city': 'Mambajao',
    'province': 'Camiguin',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '침몰한 묘지 카미긴',
    'englishName': 'Sunken Cemetery Camiguin',
    'searchTerm': 'Camiguin',
    'title': '수몰된 묘지',
    'description': '화산 폭발로 바다에 잠긴 옛 묘지입니다.',
    'city': 'Catarman',
    'province': 'Camiguin',
    'icon': 'history',
    'category': '자연',
  },

  // 추가 다이빙/스노클링 명소
  {
    'name': '투바타하 리프',
    'englishName': 'Tubbataha Reef',
    'searchTerm': 'Tubbataha_Reefs_Natural_Park',
    'title': '유네스코 해양 공원',
    'description': '팔라완 술루해의 유네스코 세계유산 산호초입니다.',
    'city': 'Puerto Princesa',
    'province': 'Palawan',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '아포 리프 다이빙',
    'englishName': 'Apo Reef Diving',
    'searchTerm': 'Apo_Reef',
    'title': '다이빙 명소',
    'description': '민도로 근처의 세계적인 다이빙 명소입니다.',
    'city': 'Sablayan',
    'province': 'Occidental Mindoro',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '리콤비나 섬',
    'englishName': 'Linapacan Island',
    'searchTerm': 'Linapacan',
    'title': '세계에서 가장 맑은 바다',
    'description': '엘니도와 코론 사이의 섬으로 맑은 바다로 유명합니다.',
    'city': 'Linapacan',
    'province': 'Palawan',
    'icon': 'island',
    'category': '섬',
  },

  // 추가 해변 명소
  {
    'name': '누사투포 비치',
    'englishName': 'Nacpan Twin Beach',
    'searchTerm': 'El_Nido',
    'title': '트윈 비치',
    'description': '엘니도 근처의 쌍둥이 해변입니다.',
    'city': 'El Nido',
    'province': 'Palawan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '마림보 비치',
    'englishName': 'Marimbo Beach',
    'searchTerm': 'El_Nido',
    'title': '엘니도 해변',
    'description': '엘니도의 아름다운 해변입니다.',
    'city': 'El Nido',
    'province': 'Palawan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '코랄리 비치',
    'englishName': 'Corong Corong Beach',
    'searchTerm': 'El_Nido',
    'title': '일몰 해변',
    'description': '엘니도의 일몰 명소 해변입니다.',
    'city': 'El Nido',
    'province': 'Palawan',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '라스 카바나스 비치',
    'englishName': 'Las Cabanas Beach',
    'searchTerm': 'El_Nido',
    'title': '짚라인 해변',
    'description': '엘니도의 짚라인이 있는 해변입니다.',
    'city': 'El Nido',
    'province': 'Palawan',
    'icon': 'beach',
    'category': '해변',
  },

  // 추가 수상스포츠 명소
  {
    'name': '세부 씨워킹',
    'englishName': 'Cebu Sea Walking',
    'searchTerm': 'Mactan',
    'title': '해저 걷기',
    'description': '막탄에서 즐기는 해저 걷기 체험입니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '세부 플라이보드',
    'englishName': 'Cebu Flyboard',
    'searchTerm': 'Mactan',
    'title': '플라이보드',
    'description': '막탄에서 즐기는 플라이보드 액티비티입니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'watersport',
    'category': '수상스포츠',
  },
  {
    'name': '보홀 카약킹',
    'englishName': 'Bohol Kayaking',
    'searchTerm': 'Bohol',
    'title': '로복 강 카약',
    'description': '로복 강에서 즐기는 카약킹입니다.',
    'city': 'Loboc',
    'province': 'Bohol',
    'icon': 'kayak',
    'category': '수상스포츠',
  },
  {
    'name': '보홀 제트스키',
    'englishName': 'Bohol Jet Ski',
    'searchTerm': 'Panglao_Island',
    'title': '제트스키',
    'description': '팡라오에서 즐기는 제트스키입니다.',
    'city': 'Panglao',
    'province': 'Bohol',
    'icon': 'jetski',
    'category': '수상스포츠',
  },

  // 추가 자연 명소
  {
    'name': '피나투보 호수',
    'englishName': 'Mount Pinatubo Crater Lake',
    'searchTerm': 'Mount_Pinatubo',
    'title': '화산 호수',
    'description': '피나투보 화산 분화구의 아름다운 호수입니다.',
    'city': 'Botolan',
    'province': 'Zambales',
    'icon': 'lake',
    'category': '자연',
  },
  {
    'name': '바나헤 라이스 테라스 하이킹',
    'englishName': 'Banaue Rice Terraces',
    'searchTerm': 'Banaue_Rice_Terraces',
    'title': '세계문화유산',
    'description': '2000년 된 계단식 논으로 유네스코 세계문화유산입니다.',
    'city': 'Banaue',
    'province': 'Ifugao',
    'icon': 'terrace',
    'category': '자연',
  },
  {
    'name': '사가다 동굴',
    'englishName': 'Sagada Cave Connection',
    'searchTerm': 'Sagada',
    'title': '동굴 탐험',
    'description': '사가다의 동굴 연결 탐험 코스입니다.',
    'city': 'Sagada',
    'province': 'Mountain Province',
    'icon': 'cave',
    'category': '자연',
  },
  {
    'name': '사가다 교수대 관',
    'englishName': 'Sagada Hanging Coffins',
    'searchTerm': 'Sagada',
    'title': '매달린 관',
    'description': '절벽에 매달린 전통 장례 방식의 관들입니다.',
    'city': 'Sagada',
    'province': 'Mountain Province',
    'icon': 'history',
    'category': '자연',
  },

  // 추가 익스트림 스포츠
  {
    'name': '팔라완 짚라인',
    'englishName': 'Palawan Zipline',
    'searchTerm': 'Sabang,_Palawan',
    'title': '사방 짚라인',
    'description': '사방 비치의 짚라인 액티비티입니다.',
    'city': 'Puerto Princesa',
    'province': 'Palawan',
    'icon': 'adventure',
    'category': '자연',
  },
  {
    'name': '세부 에지 코스터',
    'englishName': 'Crown Regency Sky Experience',
    'searchTerm': 'Cebu_City',
    'title': '스카이 어드벤처',
    'description': '세부 시티의 고층 빌딩 스카이 어드벤처입니다.',
    'city': 'Cebu City',
    'province': 'Cebu',
    'icon': 'adventure',
    'category': '자연',
  },

  // 추가 일로코스/북부 명소
  {
    'name': '마라와 비치',
    'englishName': 'Maira-ira Beach',
    'searchTerm': 'Pagudpud',
    'title': '블루 라군',
    'description': '파구드푸드의 블루 라군으로 알려진 해변입니다.',
    'city': 'Pagudpud',
    'province': 'Ilocos Norte',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '한나 비치',
    'englishName': 'Hannah Beach',
    'searchTerm': 'Pagudpud',
    'title': '파구드푸드 해변',
    'description': '파구드푸드의 또 다른 아름다운 해변입니다.',
    'city': 'Pagudpud',
    'province': 'Ilocos Norte',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '파오에이 호수',
    'englishName': 'Paoay Lake',
    'searchTerm': 'Paoay',
    'title': '일로코스 호수',
    'description': '파오에이의 호수로 수상스키가 가능합니다.',
    'city': 'Paoay',
    'province': 'Ilocos Norte',
    'icon': 'lake',
    'category': '자연',
  },

  // 추가 중부 루손 명소
  {
    'name': '앙헬레스 시티 비치',
    'englishName': 'Angeles City Beach',
    'searchTerm': 'Pampanga',
    'title': '팜팡가 해변',
    'description': '팜팡가 근교의 해변 지역입니다.',
    'city': 'Angeles',
    'province': 'Pampanga',
    'icon': 'beach',
    'category': '해변',
  },
  {
    'name': '부라칸 폭포',
    'englishName': 'Bulacan Falls',
    'searchTerm': 'Bulacan',
    'title': '부라칸 자연',
    'description': '부라칸 지역의 자연 폭포입니다.',
    'city': 'San Miguel',
    'province': 'Bulacan',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 추가 비사야 명소
  {
    'name': '시키호르 다이빙',
    'englishName': 'Siquijor Diving',
    'searchTerm': 'Siquijor',
    'title': '다이빙 포인트',
    'description': '시키호르의 다이빙 사이트들입니다.',
    'city': 'San Juan',
    'province': 'Siquijor',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '시키호르 클리프점프',
    'englishName': 'Siquijor Cliff Jump',
    'searchTerm': 'Siquijor',
    'title': '절벽 점프',
    'description': '시키호르의 절벽 점프 포인트입니다.',
    'city': 'Maria',
    'province': 'Siquijor',
    'icon': 'cliff',
    'category': '수상스포츠',
  },

  // 추가 코론 명소
  {
    'name': '코론 타운 투어',
    'englishName': 'Coron Town Tour',
    'searchTerm': 'Coron,_Palawan',
    'title': '시내 투어',
    'description': '코론 타운의 주요 명소들을 둘러보는 투어입니다.',
    'city': 'Coron',
    'province': 'Palawan',
    'icon': 'tour',
    'category': '자연',
  },
  {
    'name': '코론 선셋 크루즈',
    'englishName': 'Coron Sunset Cruise',
    'searchTerm': 'Coron,_Palawan',
    'title': '일몰 크루즈',
    'description': '코론의 아름다운 일몰을 바다에서 감상하는 투어입니다.',
    'city': 'Coron',
    'province': 'Palawan',
    'icon': 'sailing',
    'category': '수상스포츠',
  },
  {
    'name': '코론 딥 다이브',
    'englishName': 'Coron Deep Dive',
    'searchTerm': 'Coron,_Palawan',
    'title': '난파선 다이빙',
    'description': '코론의 깊은 난파선 다이빙 포인트입니다.',
    'city': 'Coron',
    'province': 'Palawan',
    'icon': 'diving',
    'category': '수상스포츠',
  },

  // 추가 엘니도 명소
  {
    'name': '엘니도 카약킹',
    'englishName': 'El Nido Kayaking',
    'searchTerm': 'El_Nido',
    'title': '라군 카약',
    'description': '엘니도 라군에서 즐기는 카약킹입니다.',
    'city': 'El Nido',
    'province': 'Palawan',
    'icon': 'kayak',
    'category': '수상스포츠',
  },
  {
    'name': '엘니도 클리프 다이빙',
    'englishName': 'El Nido Cliff Diving',
    'searchTerm': 'El_Nido',
    'title': '절벽 다이빙',
    'description': '엘니도의 절벽 다이빙 포인트입니다.',
    'city': 'El Nido',
    'province': 'Palawan',
    'icon': 'cliff',
    'category': '수상스포츠',
  },
  {
    'name': '엘니도 선셋 크루즈',
    'englishName': 'El Nido Sunset Cruise',
    'searchTerm': 'El_Nido',
    'title': '일몰 세일링',
    'description': '엘니도의 일몰을 보트에서 감상하는 투어입니다.',
    'city': 'El Nido',
    'province': 'Palawan',
    'icon': 'sailing',
    'category': '수상스포츠',
  },

  // 추가 바탕가스/민도로 명소
  {
    'name': '베르데 섬 다이빙',
    'englishName': 'Verde Island Diving',
    'searchTerm': 'Verde_Island',
    'title': '다이빙 사파리',
    'description': '베르데 섬의 다이빙 포인트들입니다.',
    'city': 'Batangas City',
    'province': 'Batangas',
    'icon': 'diving',
    'category': '수상스포츠',
  },
  {
    'name': '민도로 스노클링',
    'englishName': 'Mindoro Snorkeling',
    'searchTerm': 'Puerto_Galera',
    'title': '스노클링 투어',
    'description': '푸에르토 갈레라의 스노클링 포인트들입니다.',
    'city': 'Puerto Galera',
    'province': 'Oriental Mindoro',
    'icon': 'snorkeling',
    'category': '수상스포츠',
  },

  // 추가 레이테/사마르 명소
  {
    'name': '칼랑가만 캠핑',
    'englishName': 'Kalanggaman Camping',
    'searchTerm': 'Kalanggaman_Island',
    'title': '섬 캠핑',
    'description': '칼랑가만 섬에서의 비치 캠핑 체험입니다.',
    'city': 'Palompon',
    'province': 'Leyte',
    'icon': 'camping',
    'category': '해변',
  },
  {
    'name': '삼바완 캠핑',
    'englishName': 'Sambawan Camping',
    'searchTerm': 'Biliran',
    'title': '섬 캠핑',
    'description': '삼바완 섬에서의 캠핑 체험입니다.',
    'city': 'Maripipi',
    'province': 'Biliran',
    'icon': 'camping',
    'category': '해변',
  },

  // 추가 세부 명소
  {
    'name': '세부 스노클링',
    'englishName': 'Cebu Snorkeling',
    'searchTerm': 'Mactan',
    'title': '스노클링 투어',
    'description': '막탄 주변의 스노클링 포인트 투어입니다.',
    'city': 'Lapu-Lapu',
    'province': 'Cebu',
    'icon': 'snorkeling',
    'category': '수상스포츠',
  },
  {
    'name': '모알보알 캐녀닝',
    'englishName': 'Moalboal Canyoneering',
    'searchTerm': 'Kawasan_Falls',
    'title': '협곡 탐험',
    'description': '모알보알에서 카와산까지 이어지는 캐녀닝 투어입니다.',
    'city': 'Moalboal',
    'province': 'Cebu',
    'icon': 'adventure',
    'category': '수상스포츠',
  },

  // 추가 일반 명소
  {
    'name': '마닐라 선셋 베이',
    'englishName': 'Manila Bay Sunset',
    'searchTerm': 'Manila_Bay',
    'title': '마닐라 베이 일몰',
    'description': '마닐라 베이의 유명한 일몰 명소입니다.',
    'city': 'Manila',
    'province': 'Metro Manila',
    'icon': 'sunset',
    'category': '자연',
  },
  {
    'name': '코레히도르 섬',
    'englishName': 'Corregidor Island',
    'searchTerm': 'Corregidor',
    'title': '역사적 섬',
    'description': '마닐라 만의 역사적 섬으로 2차 대전 유적이 있습니다.',
    'city': 'Cavite City',
    'province': 'Cavite',
    'icon': 'island',
    'category': '섬',
  },

  // 추가 폭포
  {
    'name': '마리오 폭포',
    'englishName': 'Marian Falls',
    'searchTerm': 'Batangas',
    'title': '바탕가스 폭포',
    'description': '바탕가스의 숨겨진 폭포입니다.',
    'city': 'Cuenca',
    'province': 'Batangas',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '팔라야 폭포',
    'englishName': 'Palayan Falls',
    'searchTerm': 'Quezon',
    'title': '퀘존 폭포',
    'description': '퀘존 지역의 폭포입니다.',
    'city': 'Lucban',
    'province': 'Quezon',
    'icon': 'waterfall',
    'category': '자연',
  },

  // 추가 라구나/리잘 명소
  {
    'name': '리잘 숨겨진 폭포',
    'englishName': 'Rizal Hidden Falls',
    'searchTerm': 'Tanay,_Rizal',
    'title': '숨겨진 폭포들',
    'description': '리잘 지역의 숨겨진 폭포들입니다.',
    'city': 'Tanay',
    'province': 'Rizal',
    'icon': 'waterfall',
    'category': '자연',
  },
  {
    'name': '라구나 에코 파크',
    'englishName': 'Laguna Eco Park',
    'searchTerm': 'Laguna',
    'title': '에코 파크',
    'description': '라구나의 자연 생태 공원입니다.',
    'city': 'Los Banos',
    'province': 'Laguna',
    'icon': 'park',
    'category': '자연',
  },

  // 추가 비치 리조트
  {
    'name': '라라이야 리조트',
    'englishName': 'Laiya Resort Area',
    'searchTerm': 'San_Juan,_Batangas',
    'title': '리조트 단지',
    'description': '바탕가스 라이야의 리조트 단지 지역입니다.',
    'city': 'San Juan',
    'province': 'Batangas',
    'icon': 'resort',
    'category': '해변',
  },
  {
    'name': '모얄란 리조트',
    'englishName': 'Matabungkay Beach',
    'searchTerm': 'Lian,_Batangas',
    'title': '마닐라 근교 리조트',
    'description': '마닐라에서 가장 가까운 비치 리조트 중 하나입니다.',
    'city': 'Lian',
    'province': 'Batangas',
    'icon': 'beach',
    'category': '해변',
  },
];

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  //  print('======================================');
  //  print('📋 배치 12: 추가 보완 여행지 추가');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  //  print('📊 현재 여행지 개수: ${travelSpots.length}개\n');

  // 기존 이름 목록 (중복 체크용)
  final existingNames = travelSpots
      .map((spot) => (spot['name']?.toString() ?? '').toLowerCase())
      .toSet();

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 10);

  int added = 0;
  int skipped = 0;

  for (final spot in batch12Spots) {
    final name = spot['name'] as String;

    // 중복 체크
    if (existingNames.contains(name.toLowerCase())) {
      //      print('⏭️  건너뜀 (중복): $name');
      skipped++;
      continue;
    }

    // Wikipedia에서 이미지 URL 가져오기
    String imageUrl = '';
    final searchTerm = spot['searchTerm'] as String;

    try {
      final apiUrl = Uri.parse(
        'https://en.wikipedia.org/w/api.php?action=query&titles=$searchTerm&prop=pageimages&format=json&pithumbsize=800',
      );
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
      //      print('⚠️  이미지 검색 실패: $name - $e');
    }

    // 이미지가 없으면 기본 필리핀 이미지 사용
    if (imageUrl.isEmpty) {
      imageUrl =
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Flag_of_the_Philippines.svg/800px-Flag_of_the_Philippines.svg.png';
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
    //    print('✅ 추가됨: $name');

    // Rate limiting
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // JSON 파일 저장
  final encoder = const JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(travelSpots);
  file.writeAsStringSync(updatedJsonString);

  httpClient.close();

  //  print('\n======================================');
  //  print('📊 배치 12 결과 요약');
  //  print('======================================');
  //  print('✅ 추가됨: $added개');
  //  print('⏭️  건너뜀: $skipped개');
  //  print('📊 현재 총 개수: ${travelSpots.length}개');
}
