# Travel Spots JSON 업데이트 계획

## 개요

- **대상 파일**: `lib/philgo_files/travel/travel_spots.json`
- **총 항목 수**: 487개
- **현재 파일 크기**: 4,870줄
- **목적**: 각 여행 명소에 대표 이미지 URL과 상세 여행 콘텐츠 추가

---

## 현재 JSON 구조

```json
{
    "name": "10,000 로지스 카페",
    "english name": "10,000 Roses Cafe",
    "title": "세부의 LED 장미 정원",
    "description": "1만 송이의 LED 장미가 불을 밝히는 바닷가 카페입니다...",
    "city": "코르도바",
    "province": "세부",
    "icon": "🌹",
    "category": "꽃 정원"
}
```

## 목표 JSON 구조 (업데이트 후)

```json
{
    "name": "10,000 로지스 카페",
    "english name": "10,000 Roses Cafe",
    "title": "세부의 LED 장미 정원",
    "description": "1만 송이의 LED 장미가 불을 밝히는 바닷가 카페입니다...",
    "city": "코르도바",
    "province": "세부",
    "icon": "🌹",
    "category": "꽃 정원",
    "imageUrl": "https://example.com/images/10000-roses-cafe.jpg",
    "texts": [
        "# 10,000 로지스 카페 🌹\n\n세부 막탄 섬 코르도바에 위치한...",
        "## 방문 정보\n\n- **위치**: 코르도바, 세부\n- **운영시간**: ...",
        "## 추천 포인트\n\n1. 일몰 시간대 방문 추천\n2. 사진 촬영 명소..."
    ]
}
```

---

## 추가할 필드 상세 설명

### 1. imageUrl 필드

- **타입**: String
- **용도**: 해당 여행지의 대표 이미지 URL
- **소스**: 인터넷 검색을 통해 고품질 이미지 URL 수집
- **형식**: 직접 접근 가능한 이미지 URL (https://...)

### 2. texts 배열 필드

- **타입**: Array<String>
- **용도**: 여행지에 대한 상세 콘텐츠 (Markdown 형식)
- **소스**: 인터넷 검색을 통한 여행 정보 수집 후 Markdown으로 작성
- **구성 예시**:
  - `texts[0]`: 여행지 소개 및 개요 (제목, 아이콘, 주요 설명)
  - `texts[1]`: 방문 정보 (위치, 운영시간, 입장료, 교통편 등)
  - `texts[2]`: 추천 포인트 및 팁
  - `texts[3]`: 주변 관광지 또는 추가 정보 (선택)

### Markdown 콘텐츠 포함 요소

- 제목 (`#`, `##`, `###`)
- 문장 및 단락
- 이모지 아이콘
- 이미지 (`![alt](url)`)
- 리스트 (`-`, `1.`)
- 강조 (`**bold**`, `*italic*`)
- 링크 (`[text](url)`)

---

## 작업 전략 (487개 항목 효율적 처리)

### 전략 1: 배치 처리 방식

대용량 파일이므로 한 번에 모든 항목을 처리하지 않고 **배치(batch)** 단위로 나누어 작업

#### 배치 분류 기준: 지역(Province)별 그룹

| 배치 | 지역 그룹 | 예상 항목 수 |
|------|----------|-------------|
| 1 | 세부 (Cebu) | ~50개 |
| 2 | 팔라완 (Palawan) | ~40개 |
| 3 | 보홀 (Bohol) | ~30개 |
| 4 | 메트로 마닐라 | ~40개 |
| 5 | 시아르가오 | ~20개 |
| ... | 기타 지역 | ... |

### 전략 2: 카테고리별 우선순위

| 우선순위 | 카테고리 | 이유 |
|---------|---------|------|
| 1 | 해변/섬 | 필리핀 대표 관광 유형 |
| 2 | 폭포 | 인기 액티비티 |
| 3 | 다이빙 포인트 | 특수 관심 그룹 |
| 4 | 역사 유적 | 문화 관광 |
| 5 | 기타 | 나머지 |

### 전략 3: AI 교차 검증

각 항목의 정보는 다음 AI 도구들을 통해 교차 검증:

1. **Claude Code** - 정보 수집 및 Markdown 작성
2. **GPT-5.2** - 정보 검증 및 보완
3. **Gemini Pro 3** - 최종 검토 및 확인

---

## 작업 단계별 계획

### Phase 1: 준비 단계

- [ ] JSON 파일 백업 생성
- [ ] 지역별/카테고리별 항목 분류 목록 생성
- [ ] 작업 진행 추적용 체크리스트 생성
- [ ] 이미지 URL 수집 기준 정의 (해상도, 저작권 등)

### Phase 2: 데이터 수집 단계

- [ ] 각 항목별 영문 이름으로 이미지 검색
- [ ] 고품질 대표 이미지 URL 수집
- [ ] 여행 정보 콘텐츠 검색 및 수집
- [ ] 수집된 정보를 Markdown 형식으로 정리

### Phase 3: JSON 업데이트 단계

- [ ] 배치별로 imageUrl 필드 추가
- [ ] 배치별로 texts 배열 필드 추가
- [ ] JSON 유효성 검증 (syntax check)
- [ ] 앱에서 데이터 로딩 테스트

### Phase 4: 검증 단계

- [ ] AI 교차 검증 수행
- [ ] 이미지 URL 접근 가능 여부 확인
- [ ] Markdown 렌더링 테스트
- [ ] 앱 화면에서 최종 확인

---

## 작업 실행 방법

### 반자동 스크립트 활용

#### 개요

스크립트를 통해 작업 진행 상황을 자동으로 추적하고, 미완료 항목만 선별하여 효율적으로 작업합니다.

#### 스크립트 위치

```
tmp/scripts/
├── extract_incomplete.dart  # 미완료 항목 추출 + 진행 상황 확인 스크립트
└── update_item.dart         # 개별 항목 업데이트 스크립트 (city + name 기반)
```

---

#### Step 1: 미완료 항목 추출 및 진행 상황 확인 (`extract_incomplete.dart`)

**기능**:
- JSON 파일을 읽어 각 항목의 완료 상태를 분석
- 미완료 항목만 추출하여 작업용 파일 생성

**완료 판정 기준**:
- `imageUrl` 필드가 존재하고 빈 문자열이 아님
- `texts` 배열 필드가 존재하고 최소 1개 이상의 요소가 있음

**사용법**:
```bash
# 전체 미완료 항목 추출
dart run tmp/scripts/extract_incomplete.dart

# 상위 10개만 추출
dart run tmp/scripts/extract_incomplete.dart --limit 10

# 특정 지역 필터링
dart run tmp/scripts/extract_incomplete.dart --province "세부"

# 특정 카테고리 필터링
dart run tmp/scripts/extract_incomplete.dart --category "해변/섬"
```

**출력 예시**:
```
========================================
Travel Spots 미완료 항목 추출
========================================
총 항목 수: 487개

필터 조건:
  - 없음 (전체)

분석 결과:
  - 완료된 항목: 0개 (0.0%)
  - 미완료 항목: 487개 (100.0%)

[미완료 항목 목록 - 상위 20개]
  ❌ 10,000 로지스 카페 (코르도바) - 누락: imageUrl, texts
  ❌ 가와산 폭포 (바디안) - 누락: imageUrl, texts
  ...

[지역별 미완료 항목 수]
  - Metro Manila (National Capital Region): 70개
  - 세부: 14개
  ...
========================================
출력 파일: tmp/incomplete_items.json
추출된 항목 수: 487개
========================================
```

**출력 파일**: `tmp/incomplete_items.json`

**출력 형식**:
```json
{
  "generated_at": "2026-01-14T10:30:00",
  "total_items": 487,
  "total_complete": 0,
  "total_incomplete": 487,
  "filter": {
    "province": null,
    "category": null,
    "limit": null
  },
  "items": [
    {
      "index": 0,
      "name": "10,000 로지스 카페",
      "english_name": "10,000 Roses Cafe",
      "title": "세부의 LED 장미 정원",
      "description": "1만 송이의 LED 장미가...",
      "city": "코르도바",
      "province": "세부",
      "category": "꽃 정원",
      "icon": "🌹",
      "search_query": "10,000 Roses Cafe 코르도바 Philippines travel",
      "missing_fields": ["imageUrl", "texts"]
    },
    ...
  ]
}
```

**검색 쿼리 자동 생성 규칙**:
```
{english name} + {city} + "Philippines" + "travel"
```

---

#### Step 2: AI 기반 정보 수집 워크플로우

**2-1. 단일 항목 처리 프로세스**:

```
┌─────────────────────────────────────────────────────────┐
│  1. 미완료 항목 선택                                      │
│     └─> incomplete_items.json에서 다음 항목 가져오기      │
├─────────────────────────────────────────────────────────┤
│  2. 이미지 검색                                          │
│     └─> 검색 쿼리: "{english name} {city} Philippines"   │
│     └─> 소스: Wikimedia Commons, 공식 관광청 사이트        │
│     └─> 결과: imageUrl 확보                              │
├─────────────────────────────────────────────────────────┤
│  3. 여행 정보 수집                                        │
│     └─> 검색 쿼리: "{english name} travel guide info"    │
│     └─> 소스: 공식 관광 사이트, 여행 블로그, 위키피디아     │
│     └─> 수집 정보:                                       │
│         - 상세 설명                                      │
│         - 방문 정보 (운영시간, 입장료, 교통편)             │
│         - 추천 포인트 및 팁                               │
│         - 주변 관광지                                    │
├─────────────────────────────────────────────────────────┤
│  4. Markdown 콘텐츠 생성                                  │
│     └─> texts[0]: 소개 및 개요                           │
│     └─> texts[1]: 방문 정보                              │
│     └─> texts[2]: 추천 포인트                            │
│     └─> texts[3]: 주변 관광지 (선택)                      │
├─────────────────────────────────────────────────────────┤
│  5. JSON 업데이트                                         │
│     └─> update_item.dart 스크립트로 해당 항목 업데이트     │
│     └─> 유효성 검증                                      │
└─────────────────────────────────────────────────────────┘
```

**2-2. Claude Code 실행 명령 템플릿**:

```
다음 여행지에 대해 imageUrl과 texts 정보를 수집해주세요:

- 이름: {name}
- 영문명: {english name}
- 도시: {city}
- 지역: {province}
- 카테고리: {category}
- 기존 설명: {description}

요청사항:
1. 해당 여행지의 대표 이미지 URL을 찾아주세요 (Wikimedia Commons 우선)
2. 다음 구조로 Markdown 콘텐츠를 작성해주세요:
   - texts[0]: 여행지 소개 (제목, 아이콘, 상세 설명)
   - texts[1]: 방문 정보 (위치, 운영시간, 입장료, 교통편)
   - texts[2]: 추천 포인트 및 여행 팁
   - texts[3]: 주변 관광지 정보 (선택)
```

---

#### Step 3: JSON 업데이트 스크립트 (`update_item.dart`)

**기능**: 수집된 정보를 원본 JSON 파일에 병합 (city + name 기반으로 항목 식별)

**중요**: 동일한 이름의 여행지가 다른 도시에 존재할 수 있으므로, `city + name` 조합으로 항목을 찾습니다.

**사용법**:
```bash
# 기본 사용법 (city + name 필수)
dart run tmp/scripts/update_item.dart \
  --city "코르도바" \
  --name "10,000 로지스 카페" \
  --imageUrl "https://upload.wikimedia.org/..." \
  --texts-file "tmp/collected/roses-cafe-texts.json"

# texts를 직접 JSON 배열로 전달
dart run tmp/scripts/update_item.dart \
  --city "바디안" \
  --name "가와산 폭포" \
  --imageUrl "https://example.com/image.jpg" \
  --texts '["# 가와산 폭포\n\n내용...", "## 방문 정보\n\n..."]'

# 영문 이름도 함께 업데이트
dart run tmp/scripts/update_item.dart \
  --city "마닐라" \
  --name "국립 박물관" \
  --english-name "National Museum of the Philippines" \
  --imageUrl "https://example.com/image.jpg"

# 미리보기 (실제 저장 안함)
dart run tmp/scripts/update_item.dart \
  --city "코르도바" \
  --name "10,000 로지스 카페" \
  --imageUrl "https://example.com/test.jpg" \
  --dry-run
```

**texts-file 형식** (`tmp/collected/xxx-texts.json`):
```json
{
  "texts": [
    "# 10,000 로지스 카페 🌹\n\n세부 막탄 섬 코르도바에 위치한...",
    "## 방문 정보\n\n- **위치**: 코르도바, 세부\n- **운영시간**: ...",
    "## 추천 포인트\n\n1. 일몰 시간대 방문 추천\n2. 사진 촬영 명소..."
  ]
}
```

**안전 기능**:
- 업데이트 전 자동 백업 생성 (`tmp/backups/` 폴더)
- JSON 유효성 자동 검증
- `--dry-run` 옵션으로 미리보기 가능

**출력 예시**:
```
========================================
Travel Spots 항목 업데이트
========================================
검색 조건: city="코르도바", name="10,000 로지스 카페"

찾은 항목:
  - 이름: 10,000 로지스 카페
  - 영문명: 10,000 Roses Cafe
  - 도시: 코르도바
  - 지역: 세부
  - 인덱스: 0

[업데이트 내용]
  - imageUrl: (없음) -> https://example.com/test.jpg
  - texts: 0개 -> 3개

백업 생성: tmp/backups/travel_spots_1705234567890.json

========================================
업데이트 완료!
========================================
JSON 유효성 검증: 통과
```

---

#### 전체 워크플로우 다이어그램

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  Step 1          │    │  Step 2          │    │  Step 3          │
│  extract         │───>│  AI 정보 수집     │───>│  update          │
│  _incomplete     │    │  (Claude Code)   │    │  _item           │
│  .dart           │    │                  │    │  .dart           │
└──────────────────┘    └──────────────────┘    └────────┬─────────┘
        │                                                │
        │                                                v
        │                                       ┌──────────────────┐
        └──────────────────────────────────────>│  다음 항목으로   │
                    (반복)                      │  반복            │
                                               └──────────────────┘
```

---

#### 배치 처리 옵션

한 번에 여러 항목을 처리할 경우:

```bash
# 미완료 항목 중 상위 10개 추출
dart run tmp/scripts/extract_incomplete.dart --limit 10

# 특정 지역만 추출
dart run tmp/scripts/extract_incomplete.dart --province "세부"

# 특정 카테고리만 추출
dart run tmp/scripts/extract_incomplete.dart --category "해변/섬"
```

---

#### 진행 상황 확인

`extract_incomplete.dart` 스크립트 실행 시 자동으로 진행 상황이 표시됩니다:

```
분석 결과:
  - 완료된 항목: 12개 (2.5%)
  - 미완료 항목: 475개 (97.5%)

[지역별 미완료 항목 수]
  - Metro Manila: 70개
  - 세부: 14개
  ...
```

---

## 예상 작업량

| 항목 | 수량 | 비고 |
|-----|------|------|
| 총 항목 수 | 487개 | |
| 배치 크기 | 20개 | 권장 |
| 총 배치 수 | ~25개 | |
| 항목당 예상 작업 | imageUrl 1개 + texts 3~4개 | |

---

## 주의사항

1. **이미지 URL 안정성**: 외부 URL은 시간이 지나면 접근 불가능해질 수 있음
   - 권장: 안정적인 공식 사이트 또는 위키미디어 커먼스 이미지 사용

2. **저작권 고려**: 상업적 사용 가능한 이미지만 수집

3. **JSON 유효성**: 큰따옴표 이스케이프, 특수문자 처리 주의

4. **Markdown 호환성**: Flutter에서 사용할 Markdown 패키지와 호환되는 문법 사용

5. **파일 크기 관리**: 하나의 json 파일로 모든 콘텐츠 포함

---

## 화면 표시 계획

각 여행 아이템 클릭 시:

1. **재사용 가능한 상세 페이지 스크린** 활용
2. `imageUrl`로 상단 대표 이미지 표시
3. `texts` 배열의 Markdown 콘텐츠를 순차적으로 렌더링
4. `flutter_markdown` 또는 유사 패키지로 Markdown 파싱/표시

---

## 기존 계획 메모 (참고)

- travel_spots.json에서 name을 모두 한글로 변환 완료
- 대표 이미지를 인터넷에서 찾기 → imageUrl 필드로 추가
- 각 여행 아이템의 긴 설명을 claude code와 교차 검증하여 texts 필드에 저장
- Markdown code 요소에는 제목, 문장, 이모지 아이콘, 이미지 등 포함 가능
