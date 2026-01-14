# Travel Spots 병렬 업데이트 작업 계획

## 목적
- `lib/philgo_files/travel/travel_spots.json` 파일의 여행 정보에 대해 인터넷 검색을 통해 `imageUrl`과 `texts` 필드를 업데이트합니다.
- 병렬 처리를 통해 작업 속도를 대폭 향상시킵니다.

## 병렬 처리 구조
- **한 번에 5개 여행 정보** x **6개 병렬 실행** = **총 30개 동시 처리**

---

## 1단계: 미완료 항목 추출 (6개 배치 파일 생성)

아래 6개 명령을 **동시에 병렬로** 실행하여 각각 다른 범위의 미완료 항목을 추출합니다:

```bash
dart run tmp/scripts/extract_incomplete.dart --offset 0 --limit 5 --output tmp/batch_0.json
dart run tmp/scripts/extract_incomplete.dart --offset 5 --limit 5 --output tmp/batch_1.json
dart run tmp/scripts/extract_incomplete.dart --offset 10 --limit 5 --output tmp/batch_2.json
dart run tmp/scripts/extract_incomplete.dart --offset 15 --limit 5 --output tmp/batch_3.json
dart run tmp/scripts/extract_incomplete.dart --offset 20 --limit 5 --output tmp/batch_4.json
dart run tmp/scripts/extract_incomplete.dart --offset 25 --limit 5 --output tmp/batch_5.json
```

---

## 2단계: 병렬 에이전트 실행 프롬프트

Claude에게 아래 프롬프트를 전달하여 6개의 Task 에이전트를 **동시에 병렬로** 실행합니다:

### 병렬 실행 프롬프트 (복사해서 사용)

```
다음 6개의 배치 파일을 병렬로 처리해주세요. 각 배치 파일에 있는 여행지 정보를 인터넷 검색하여 imageUrl과 texts를 수집하고 update_item.dart로 업데이트해주세요.

배치 파일 목록:
1. tmp/batch_0.json
2. tmp/batch_1.json
3. tmp/batch_2.json
4. tmp/batch_3.json
5. tmp/batch_4.json
6. tmp/batch_5.json

각 배치에 대해 Task 에이전트를 "in parallel" (병렬)로 실행해주세요.

각 에이전트가 수행할 작업:
1. 배치 JSON 파일 읽기
2. 각 여행지에 대해 인터넷 검색 (itsmorefuninthephilippines, Wikipedia, Wikimedia Commons 등)
3. 대표 이미지 URL 찾기
4. texts 배열 작성:
   - texts[0]: 여행지 소개 (제목, 아이콘, 상세 설명)
   - texts[1]: 방문 정보 (위치, 운영시간, 입장료, 교통편)
   - texts[2]: 추천 포인트 및 여행 팁
5. update_item.dart 스크립트로 JSON 업데이트

작업 완료 후 기존 백업 파일은 삭제하고 최신 백업만 유지해주세요.
```

---

## 3단계: 반복 실행

1단계와 2단계를 **모든 미완료 항목이 완료될 때까지** 반복합니다.

---

## 스크립트 사용법

### extract_incomplete.dart 옵션
| 옵션 | 설명 | 예시 |
|------|------|------|
| `--limit N` | 추출할 항목 수 | `--limit 5` |
| `--offset N` | 시작 위치 (0부터) | `--offset 10` |
| `--output PATH` | 출력 파일 경로 | `--output tmp/batch_0.json` |
| `--province NAME` | 지역 필터 | `--province "세부"` |
| `--category NAME` | 카테고리 필터 | `--category "해변/섬"` |

### update_item.dart 옵션
| 옵션 | 설명 | 예시 |
|------|------|------|
| `--city` | 도시명 (필수) | `--city "코르도바"` |
| `--name` | 여행지명 (필수) | `--name "10,000 로지스 카페"` |
| `--imageUrl` | 이미지 URL | `--imageUrl "https://..."` |
| `--texts` | texts JSON 배열 | `--texts '["텍스트1", "텍스트2"]'` |
| `--texts-file` | texts JSON 파일 | `--texts-file tmp/texts.json` |
| `--dry-run` | 미리보기 모드 | `--dry-run` |

---

## texts 배열 작성 가이드

### texts[0]: 여행지 소개
```markdown
# 여행지명 (영문명)

여행지에 대한 상세 소개...

## 특징
- 특징 1
- 특징 2
- 특징 3
```

### texts[1]: 방문 정보
```markdown
## 방문 정보

### 위치
- **주소**: ...
- **거리**: ...

### 운영 시간
- **개관일**: ...
- **개관 시간**: ...

### 입장료
- **일반**: ...

### 교통편
- ...
```

### texts[2]: 추천 포인트 및 여행 팁
```markdown
## 추천 포인트 & 여행 팁

### 추천 포인트
1. ...
2. ...

### 여행 팁
- ...
- ...
```

---

## 주의사항

1. **백업 관리**: 매번 작업 시 기존 백업을 삭제하고 최신 백업만 유지
2. **이미지 URL**: 직접 접근 가능한 이미지 URL 사용 (gttp.images.tshiftcdn.com 권장)
3. **한글 이름**: name이 영문인 경우 한글로 변경
4. **병렬 실행**: 6개 에이전트를 반드시 동시에 실행하여 효율성 극대화
