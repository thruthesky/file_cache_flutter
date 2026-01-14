#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
batch_6.json의 5개 여행지를 업데이트하는 스크립트
"""

import json
import os

# 파일 경로
JSON_PATH = 'lib/philgo_files/travel/travel_spots.json'

# 업데이트할 데이터
updates = [
    {
        "name": "Cuernos de Negros (Talinis Peak)",
        "province": "Negros Oriental",
        "title": "Negros Oriental의 산/화산 명소",
        "description": "Negros Oriental에 위치한 산/화산 여행지입니다. 해발 약 1,903m. 잠재적 활화산으로, 네그로스 섬에서 두 번째로 높은 산입니다.",
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Mount_Talinis_%28Cuernos_de_Negros%29%2C_Negros_Oriental%2C_Philippines_02.JPG/1280px-Mount_Talinis_%28Cuernos_de_Negros%29%2C_Negros_Oriental%2C_Philippines_02.JPG",
        "texts": [
            "# Cuernos de Negros (Talinis Peak)\n\n네그로스 섬의 뿔(Horns of Negros)이라는 뜻을 가진 탈리니스 산은 해발 1,903m로 네그로스 섬에서 두 번째로 높은 산입니다. 칸라온 화산 다음으로 높으며, 필리핀 화산지진연구소(PHIVOLCS)에 의해 잠재적 활화산으로 분류되어 있습니다.\n\n## 특징\n\n기저 직경 36km에 달하는 거대한 화산 복합체로, Talinis, Magaso, Guinsayawan, Yagumyum Peak, Guintabon Dome 등 여러 화산추와 봉우리로 구성되어 있습니다. 산 정상 부근에는 Nailig, Yagumyum, Mabilog 등 분화구 호수가 있으며, 유황 온천과 지열 활동이 활발합니다. 인근의 팔린피논 지열발전소에 에너지를 공급하고 있습니다.",
            "## 방문 정보\n\n**위치**: 네그로스 오리엔탈 주, 발렌시아 시에서 남서쪽 9km, 두마게테 시에서 20km 거리\n\n**등산 코스**: 가장 인기 있는 아폴롱 트레일(Apolong Trail)은 약 15.8km, 고도 상승 1,532m로 8.5~9시간 소요됩니다. 일반 탈리니스 코스는 9.5km, 고도 상승 1,172m로 6~6.5시간 소요됩니다.\n\n**교통편**: 두마게테에서 발렌시아 행 지프니 탑승 후, 시티오 아폴롱까지 이동\n\n**필수 사항**: 발렌시아 관광사무소 등록, DENR 네그로스 오리엔탈 및 탈리니스 산 태스크포스와 사전 조율 필요. 가이드 동반 필수입니다.\n\n**접근 제한**: 2020년 발렌시아 시 조례 제4호에 따라 생태관광 규정 정비 및 생물다양성 회복을 위해 일반 등산이 현재 중단된 상태입니다.",
            "## 추천 포인트\n\n- **분화구 호수**: Balinsasayao와 Danao 쌍둥이 호수, 그리고 Kabalin-an 호수가 Guintabon 칼데라 내에 위치\n- **캠핑**: Lake Nailig가 주요 캠핑장으로, 정상까지 30분 거리\n- **유황 계곡**: Kaipuhan Sulfur River에서 화산 활동 흔적 관찰 가능\n- **이끼 숲**: 중고도 지역의 신비로운 이끼 숲\n\n## 여행 팁\n\n- 등반 시즌: 건기인 11월~5월 권장\n- 난이도: 상급자용, 체력과 경험 필요\n- 장비: 방수 장비, 따뜻한 옷, 충분한 식수 필수\n- 야생동물: 타릭틱 혼빌, 필리핀 점박이 사슴, 비사얀 혹멧돼지, 네그로스 블리딩하트 비둘기 등 희귀 동물 서식\n- 식물: 91종의 나무, 야생 난초, 식용 열매, 넓은잎 양치류 등 다양한 식생"
        ]
    },
    {
        "name": "Dagot 산",
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Cordillera_Mountains_Philippines.jpg/1280px-Cordillera_Mountains_Philippines.jpg",
        "texts": [
            "# Dagot 산 (Mount Dagot)\n\nDagot 산은 필리핀 Abra 주의 Cordillera 행정구역에 위치한 해발 약 1,239~1,311m의 산입니다. Cordillera Central 산맥의 일부로, 북부 루손의 험준한 산악 지형을 대표하는 봉우리 중 하나입니다.\n\n## 특징\n\n- **해발고도**: 약 1,239~1,311m\n- **돌출도(Prominence)**: 약 373m\n- **지역**: Abra Province, Cordillera Administrative Region (CAR)\n- Cordillera Central 산맥에 속하며, Mount Sagang(7.1km), Mount Cayudungan(7.7km), Mount Naltoot(7.5km) 등 인근 봉우리들과 함께 산악 지대를 형성\n- 필리핀 북부의 전통 산악 문화가 살아있는 지역",
            "## 방문 정보\n\n**위치**: Abra Province, Cordillera Administrative Region (CAR), 루손 섬 북부\n\n**교통편**:\n1. 마닐라에서 Abra 주도 Bangued까지 버스로 약 8~10시간\n2. Bangued에서 현지 교통수단(지프니/트라이시클)으로 등산 기점까지 이동\n3. 산악 지역 특성상 4WD 차량 권장\n\n**최적 방문 시기**: 건기인 11월~5월이 트레킹하기 가장 좋습니다. 우기(6월~10월)에는 산사태 위험이 있습니다.\n\n**허가**: Cordillera 지역 산악 등반 시 현지 바랑가이 및 DENR 허가가 필요할 수 있습니다.",
            "## 추천 포인트 & 여행 팁\n\n### 추천 포인트\n1. **미개척 자연**: 관광객이 적어 순수한 자연을 체험할 수 있음\n2. **Cordillera 문화**: 전통 산악민족(Tingguian/Itneg)의 문화와 생활 방식 체험\n3. **산악 경관**: Cordillera Central의 웅장한 산악 풍경\n4. **생태 다양성**: 고산 지대의 독특한 동식물 관찰\n\n### 여행 팁\n\n- 현지 가이드 동행 필수 (지역 정보와 안전을 위해)\n- 등산 장비: 트레킹화, 방수복, 따뜻한 옷 필수\n- 충분한 식수와 식량 지참\n- 숙박: Bangued 시내에서 숙박 후 당일 또는 1박 2일 코스로 계획\n- 통신: 산악 지역이라 휴대폰 신호가 약할 수 있음\n\n### 주변 명소\n- Abra의 Kapao 언덕 (신흥 관광지)\n- Bangued 시내 역사 유적지\n- Cordillera 전통 마을"
        ]
    },
    {
        "name": "Culangalan 산",
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Bulusan_Volcano_Sorsogon.jpg/1280px-Bulusan_Volcano_Sorsogon.jpg",
        "texts": [
            "# Culangalan 산 (Mount Culangalan)\n\nCulangalan 산은 필리핀 Sorsogon 주에 위치한 해발 약 165~360m의 휴화산입니다. Bicol 지역의 화산 지대에 속하며, 인근에 유명한 Bulusan 활화산이 있습니다. 필리핀 화산지진연구소(PHIVOLCS)에 의해 비활성 화산으로 분류되어 있습니다.\n\n## 특징\n\n- **해발고도**: 약 165~360m (540ft)\n- **분류**: 휴화산 (Inactive Volcano)\n- **지역**: Sorsogon Province, Bicol Region\n- Sorsogon에서 8번째로 높은 산\n- Mount Bulusan, Mount Bintacan, Mount Batuan, Mount Caloomutan, Mount Homahan, Sharp Peak, Gate Mountains와 함께 Sorsogon의 화산 지대를 형성",
            "## 방문 정보\n\n**위치**: Sabang 인근, Sorsogon Province, Bicol Region, 필리핀\n\n**교통편**:\n1. **항공**: 마닐라에서 Legazpi 공항까지 약 1시간, 이후 육로로 Sorsogon까지 약 2시간\n2. **육로**: 마닐라에서 Sorsogon까지 버스로 약 10~12시간\n3. **해상**: 세부에서 Matnog 항까지 페리 후 육로 이동\n\n**인근 접근**: Sorsogon City에서 지프니 또는 트라이시클로 이동\n\n**최적 방문 시기**: 건기인 3월~5월이 가장 좋습니다. 6월~11월은 우기이므로 주의가 필요합니다.",
            "## 추천 포인트 & 여행 팁\n\n### 추천 포인트\n1. **화산 지형 탐험**: Bicol 화산대의 지질학적 특성 관찰\n2. **자연 그대로의 환경**: 관광지화되지 않은 순수한 자연\n3. **Bulusan 연계 여행**: 인근 Bulusan Volcano Natural Park와 함께 방문\n4. **Sorsogon 해안**: 근처의 아름다운 해안선과 섬 탐험\n\n### 여행 팁\n\n- Bulusan 화산 상태 확인 필수 (PHIVOLCS 경보 참조)\n- 현지 가이드와 함께 방문 권장\n- 트레킹 장비: 편한 등산화, 물, 간식 준비\n- 자외선 차단제와 모자 필수\n- 모기 기피제 지참\n\n### 주변 명소\n- Bulusan Volcano Natural Park\n- Bulusan Lake (호수 주변 2.2km 트레킹 가능)\n- Matnog 섬 호핑\n- Sorsogon의 화이트 비치"
        ]
    },
    {
        "name": "Culasi 산",
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Bicol_Region_mountains.jpg/1280px-Bicol_Region_mountains.jpg",
        "texts": [
            "# Culasi 산 (Mount Culasi)\n\nCulasi 산(또는 Culasi Peak, Colasi Peak)은 필리핀 Camarines Norte 주에 위치한 해발 약 364~387m의 휴화산입니다. Bicol Volcanic Arc의 일부로, Mount Labo, Mount Cone 등과 함께 Bicol 지역의 화산 지대를 형성합니다.\n\n## 특징\n\n- **해발고도**: 약 364~387m\n- **분류**: 휴화산 (Inactive Volcano)\n- **지역**: Camarines Norte Province, Bicol Region\n- Bicol Volcanic Arc: 필리핀 모빌 벨트(PMB)의 중앙-동부를 따라 260km에 걸쳐 형성된 화산대\n- Camarines Norte에서 Mount Labo(1,544m)와 함께 주요 화산 봉우리\n- 인근에 Magsatangi Point, Tacubtacuban Hill 위치",
            "## 방문 정보\n\n**위치**: Camarines Norte Province, Bicol Region, 필리핀\n\n**교통편**:\n1. **항공**: 마닐라에서 Naga 공항까지 약 1시간, 이후 육로로 Camarines Norte까지 약 2시간\n2. **육로**: 마닐라에서 Daet(Camarines Norte 주도)까지 버스로 약 7~8시간\n3. **자가용**: NLEX-SLEX-Maharlika Highway 경유\n\n**최적 방문 시기**: 건기인 11월~5월이 트레킹하기 가장 좋습니다.\n\n**참고**: 더 도전적인 등반을 원한다면 인근의 Mount Labo(1,544m, 2~3일 코스)를 추천합니다.",
            "## 추천 포인트 & 여행 팁\n\n### 추천 포인트\n1. **Bicol 화산대 탐험**: 필리핀의 대표적인 화산 지대 체험\n2. **비교적 쉬운 코스**: 해발 400m 이하로 초보자도 접근 가능\n3. **Mount Labo 연계**: 인근 최고봉 Mount Labo와 함께 계획 가능\n4. **Camarines Norte 해변**: 트레킹 후 인근 해변에서 휴식\n\n### 여행 팁\n\n- 현지 정보 수집 필수 (지역 관광청 또는 등산 동호회)\n- 트레킹 장비: 편한 등산화, 물, 간식 준비\n- 우기(6월~10월)에는 산사태 위험이 있으므로 주의\n- Mount Labo 등반 시 Rafflesia 꽃 시즌(계절성) 확인\n\n### 주변 명소\n- Mount Labo (Camarines Norte 최고봉, 1,544m)\n- Daet 해변 (서핑 명소)\n- Calaguas Islands (청정 해변)\n- Mercedes 섬 호핑"
        ]
    },
    {
        "name": "Cuyapo 산",
        "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Nueva_Ecija_landscape.jpg/1280px-Nueva_Ecija_landscape.jpg",
        "texts": [
            "# Cuyapo 산 (Mount Cuyapo)\n\nCuyapo 산은 필리핀 Nueva Ecija 주 Cuyapo 지역에 위치한 해발 약 209~244m의 언덕입니다. AllTrails에서 쉬운 난이도의 하이킹 코스로 소개되며, 약 8.9km(5.5마일) 거리에 267m의 고도 상승이 있어 2.5~3시간이면 완주할 수 있습니다.\n\n## 특징\n\n- **해발고도**: 약 209~244m (801ft)\n- **돌출도(Prominence)**: 191m (627ft)\n- **난이도**: 쉬움 (Easy)\n- **거리**: 약 8.9km (5.5마일)\n- **소요시간**: 2.5~3시간\n- Cuyapo 지역의 주요 산악 명소 중 하나\n- 인근에 Mount Bangcay(406m, 화산), Mount Bulaylay(286m) 등이 있음",
            "## 방문 정보\n\n**위치**: Cuyapo, Nueva Ecija Province, Central Luzon, 필리핀\n\n**교통편**:\n1. **마닐라에서**: NLEX를 이용해 약 3~4시간 소요\n2. **버스**: 마닐라 Cubao에서 Nueva Ecija행 버스 탑승, Cuyapo에서 하차\n3. **현지 이동**: 트라이시클 또는 오토바이 렌트로 등산 기점까지 이동\n\n**최적 방문 시기**: 건기인 11월~5월이 가장 좋습니다. Nueva Ecija는 더운 지역이므로 이른 아침 출발을 권장합니다.\n\n**입장료**: 지역에 따라 소정의 환경 부담금이 있을 수 있습니다.",
            "## 추천 포인트 & 여행 팁\n\n### 추천 포인트\n1. **초보자 친화적**: 쉬운 난이도로 가족 단위 방문에 적합\n2. **Colosboa Hills**: 인근의 \"뉴질랜드 of Cuyapo\"로 불리는 롤링 힐스 (사진 촬영 명소)\n3. **Mount Bulaylay**: 집라인과 전망대가 있는 관광지 (공화국법 11406호로 관광지 지정)\n4. **자전거 트레일**: Colosboa Hills의 3km 산악자전거 코스\n\n### 여행 팁\n\n- 이른 아침 출발 권장 (더위 피하기)\n- 충분한 물 지참 (더운 지역)\n- 자외선 차단제, 모자 필수\n- Colosboa Hills: 캠핑, 포토존, 자전거 트레일 등 다양한 활동 가능\n- Mount Bulaylay: 탠덤 집라인 체험 가능\n\n### 주변 명소\n- Colosboa Hills (10헥타르 자연 공원)\n- Mount Bulaylay Trail of Faith and Adventure Park\n- Mount Bangcay (406m 화산, 5~5.5시간 코스)\n- Paitan Lake\n- San Roque Parish Church\n- Apolinario Mabini 역사 기념지"
        ]
    }
]

def main():
    # JSON 파일 읽기
    with open(JSON_PATH, 'r', encoding='utf-8') as f:
        items = json.load(f)

    print(f"총 {len(items)}개의 항목 로드됨")

    # 각 업데이트 항목 처리
    updated_count = 0
    for update in updates:
        name = update['name']

        # 이름으로 항목 찾기
        for i, item in enumerate(items):
            if item.get('name') == name:
                print(f"\n업데이트: {name}")

                # 필드 업데이트
                if 'province' in update:
                    item['province'] = update['province']
                if 'title' in update:
                    item['title'] = update['title']
                if 'description' in update:
                    item['description'] = update['description']
                if 'imageUrl' in update:
                    item['imageUrl'] = update['imageUrl']
                if 'texts' in update:
                    item['texts'] = update['texts']

                items[i] = item
                updated_count += 1
                print(f"  - imageUrl: 추가됨")
                print(f"  - texts: {len(update.get('texts', []))}개 섹션 추가됨")
                break
        else:
            print(f"경고: '{name}' 항목을 찾을 수 없습니다.")

    # JSON 파일 저장
    with open(JSON_PATH, 'w', encoding='utf-8') as f:
        json.dump(items, f, ensure_ascii=False, indent=4)

    print(f"\n완료: {updated_count}개 항목 업데이트됨")
    print(f"저장됨: {JSON_PATH}")

if __name__ == '__main__':
    main()
