# v7 Info API

> **✅ 구현 완료** — 다용도 정보 CRUD + FULLTEXT 검색 API

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [DB 테이블 구조](#3-db-테이블-구조)
4. [Entity 클래스](#4-entity-클래스)
5. [API 엔드포인트](#5-api-엔드포인트)
6. [카테고리/서브카테고리 규약](#6-카테고리서브카테고리-규약)
7. [JSON 컬럼 구조](#7-json-컬럼-구조)
8. [권한 모델](#8-권한-모델)
9. [Flutter/웹 호출 예시](#9-flutter웹-호출-예시)

---

## 1. 개요

Info 모듈은 여행지, 병원, 경찰, 긴급연락처, 비자, 축제, 생활정보, 맛집, 숙소 등 **다양한 카테고리의 정보를 단일 테이블(info)로 관리**하는 범용 정보 API임.

| 항목 | 설명 |
|------|------|
| **네임스페이스** | `Philgo\Info` |
| **API 접두사** | `info.*` |
| **DB 테이블** | `info` (단일 테이블) |
| **인증** | 조회/목록/검색은 인증 불필요, 생성/수정/삭제는 관리자 전용 |
| **확장성** | `texts`(JSON), `extra_data`(JSON) 컬럼으로 유연한 데이터 확장 |
| **검색** | `FULLTEXT` 인덱스 기반 통합 검색 지원 |
| **사용처** | 웹 홈페이지 + Flutter 앱 공통 |

### 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **단일 테이블** | 카테고리별 별도 테이블을 만들지 않고 `info` 테이블 하나로 통합 관리 |
| **JSON 확장** | `texts`(마크다운 섹션 배열)와 `extra_data`(카테고리별 추가 데이터)로 유연하게 확장 |
| **FULLTEXT 검색** | `name`, `english_name`, `title`, `description`, `tags` 5개 필드에 FULLTEXT 인덱스 적용 |
| **카테고리+이모지** | 카테고리/서브카테고리에 이모지 아이콘 지원 (`category_icon`, `subcategory_icon`) |
| **관리자 전용 CUD** | 생성/수정/삭제는 관리자만 가능, 조회/검색은 누구나 가능 |

---

## 2. 파일 구조

```
lib/info/
├── InfoEntity.php        # Entity — info 테이블 행을 객체로 표현 (30+ 필드)
├── InfoRepository.php    # Repository — DB CRUD + 목록/검색/카운트 쿼리
├── InfoService.php       # Service — 비즈니스 로직 (CRUD, 검색, 조회수)
└── InfoController.php    # Controller — API 엔드포인트 (info.*)
```

### 아키텍처

```
클라이언트 → api.php → InfoController → InfoService → InfoRepository → Db::pdo()
                │
                ├─ info.get     (인증 불필요)
                ├─ info.list    (인증 불필요)
                ├─ info.search  (인증 불필요)
                ├─ info.create  (관리자 전용)
                ├─ info.update  (관리자 전용)
                └─ info.delete  (관리자 전용)
```

---

## 3. DB 테이블 구조

### info 테이블

```sql
CREATE TABLE `info` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,

  -- 분류
  `category` varchar(50) NOT NULL DEFAULT '' COMMENT '카테고리 (travel, hospital, police 등)',
  `subcategory` varchar(50) NOT NULL DEFAULT '' COMMENT '서브카테고리',
  `category_icon` varchar(20) NOT NULL DEFAULT '' COMMENT '카테고리 이모지 아이콘',
  `subcategory_icon` varchar(20) NOT NULL DEFAULT '' COMMENT '서브카테고리 이모지 아이콘',

  -- 기본 정보
  `name` varchar(200) NOT NULL DEFAULT '' COMMENT '이름 (한국어)',
  `english_name` varchar(200) NOT NULL DEFAULT '' COMMENT '영문 이름',
  `title` varchar(300) NOT NULL DEFAULT '' COMMENT '제목/타이틀',
  `icon` varchar(50) NOT NULL DEFAULT '' COMMENT '아이콘 (이모지 또는 FA 클래스)',
  `description` text NOT NULL COMMENT '짧은 설명',
  `content` longtext NOT NULL COMMENT '본문 내용 (마크다운)',

  -- JSON 컬럼
  `texts` json DEFAULT NULL COMMENT '마크다운 섹션 배열 (JSON)',
  `extra_data` json DEFAULT NULL COMMENT '카테고리별 추가 데이터 (JSON)',

  -- 이미지
  `image_url` varchar(500) NOT NULL DEFAULT '' COMMENT '대표 이미지 URL',

  -- 위치 정보
  `city` varchar(100) NOT NULL DEFAULT '' COMMENT '도시',
  `province` varchar(100) NOT NULL DEFAULT '' COMMENT '주/도',
  `region` varchar(100) NOT NULL DEFAULT '' COMMENT '지역 (세부, 마닐라 등)',
  `address` varchar(500) NOT NULL DEFAULT '' COMMENT '상세 주소',
  `latitude` decimal(10,7) DEFAULT NULL COMMENT '위도',
  `longitude` decimal(10,7) DEFAULT NULL COMMENT '경도',

  -- 연락처
  `phone` varchar(50) NOT NULL DEFAULT '' COMMENT '전화번호',
  `phone2` varchar(50) NOT NULL DEFAULT '' COMMENT '보조 전화번호',
  `email` varchar(200) NOT NULL DEFAULT '' COMMENT '이메일',
  `url` varchar(500) NOT NULL DEFAULT '' COMMENT '웹사이트 URL',

  -- 운영 정보
  `hours` varchar(300) NOT NULL DEFAULT '' COMMENT '운영시간',
  `fee` varchar(200) NOT NULL DEFAULT '' COMMENT '입장료/이용료',

  -- 축제/이벤트
  `month` tinyint(2) UNSIGNED NOT NULL DEFAULT 0 COMMENT '해당 월 (1~12)',
  `event_date` varchar(100) NOT NULL DEFAULT '' COMMENT '이벤트 날짜',

  -- 태그/관리
  `tags` varchar(500) NOT NULL DEFAULT '' COMMENT '태그 (쉼표 구분)',
  `sort_order` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '정렬 순서 (작을수록 먼저)',
  `view_count` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '조회수',
  `status` char(1) NOT NULL DEFAULT 'Y' COMMENT '상태 (Y: 활성, N: 비활성)',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`idx`),
  KEY `idx_category` (`category`),
  KEY `idx_region` (`region`),
  KEY `idx_status` (`status`),
  FULLTEXT KEY `ft_search` (`name`, `english_name`, `title`, `description`, `tags`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='다용도 정보 테이블';
```

### 주요 인덱스

| 인덱스 | 타입 | 대상 컬럼 | 용도 |
|--------|------|-----------|------|
| `PRIMARY` | PK | `idx` | 고유 키 |
| `idx_category` | INDEX | `category` | 카테고리 필터 |
| `idx_region` | INDEX | `region` | 지역 필터 |
| `idx_status` | INDEX | `status` | 상태 필터 |
| `ft_search` | FULLTEXT | `name, english_name, title, description, tags` | 통합 검색 |

---

## 4. Entity 클래스

### InfoEntity 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx` | `int` | 고유 ID |
| `category` | `string` | 카테고리 (travel, hospital, police 등) |
| `subcategory` | `string` | 서브카테고리 |
| `category_icon` | `string` | 카테고리 이모지 아이콘 |
| `subcategory_icon` | `string` | 서브카테고리 이모지 아이콘 |
| `name` | `string` | 이름 (한국어) |
| `english_name` | `string` | 영문 이름 |
| `title` | `string` | 제목/타이틀 |
| `icon` | `string` | 아이콘 |
| `description` | `string` | 짧은 설명 |
| `content` | `string` | 본문 (마크다운) |
| `texts` | `array` | 마크다운 섹션 배열 (JSON → PHP 배열) |
| `image_url` | `string` | 대표 이미지 URL |
| `city` | `string` | 도시 |
| `province` | `string` | 주/도 |
| `region` | `string` | 지역 |
| `address` | `string` | 상세 주소 |
| `latitude` | `?float` | 위도 (nullable) |
| `longitude` | `?float` | 경도 (nullable) |
| `phone` | `string` | 전화번호 |
| `phone2` | `string` | 보조 전화번호 |
| `email` | `string` | 이메일 |
| `url` | `string` | 웹사이트 URL |
| `hours` | `string` | 운영시간 |
| `fee` | `string` | 입장료/이용료 |
| `month` | `int` | 해당 월 (1~12, 축제용) |
| `event_date` | `string` | 이벤트 날짜 |
| `extra_data` | `array` | 카테고리별 추가 데이터 (JSON → PHP 배열) |
| `tags` | `string` | 태그 (쉼표 구분) |
| `sort_order` | `int` | 정렬 순서 |
| `view_count` | `int` | 조회수 |
| `status` | `string` | 상태 (Y/N) |
| `created_at` | `string` | 생성 시각 |
| `updated_at` | `string` | 수정 시각 |

### JSON 컬럼 변환

`texts`와 `extra_data`는 DB에 JSON 문자열로 저장되며, `fromArray()`에서 자동으로 PHP 배열로 변환됨. `toArray()`에서는 PHP 배열 그대로 반환됨.

```php
// fromArray() 내부 처리
$textsRaw = $data['texts'] ?? null;
if (is_string($textsRaw) && $textsRaw !== '') {
    $decoded = json_decode($textsRaw, true);
    $entity->texts = is_array($decoded) ? $decoded : [];
} elseif (is_array($textsRaw)) {
    $entity->texts = $textsRaw;
}
```

---

## 5. API 엔드포인트

### 엔드포인트 요약

| API | 인증 | 설명 |
|-----|------|------|
| `info.get` | 불필요 | 단건 조회 (view_count 자동 증가) |
| `info.list` | 불필요 | 목록 조회 (카테고리/지역/월 필터 + 페이지네이션) |
| `info.search` | 불필요 | FULLTEXT 검색 |
| `info.create` | 관리자 | 정보 생성 |
| `info.update` | 관리자 | 정보 수정 |
| `info.delete` | 관리자 | 정보 삭제 |

---

### 5.1 info.get -- 단건 조회

단건 정보를 조회하고, 조회수(`view_count`)를 1 증가시킴.

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=info.get&idx=1` |
| **인증** | 불필요 |
| **입력** | `idx` (int, 필수) -- 정보 idx |
| **출력** | `InfoEntity.toArray()` |

**curl 예시:**

```bash
curl "https://v7-local.philgo.com/api.php?method=info.get&idx=1"
```

**응답:**

```json
{
  "success": true,
  "data": {
    "idx": 1,
    "category": "hospital",
    "subcategory": "",
    "category_icon": "🏥",
    "name": "세부종합병원",
    "english_name": "Cebu General Hospital",
    "description": "세부 시내 대형 종합병원",
    "region": "세부",
    "phone": "+63-32-2536071",
    "view_count": 42,
    "texts": ["## 진료과목\n- 내과\n- 외과"],
    "extra_data": { "insurance": true },
    "status": "Y",
    "...": "..."
  }
}
```

---

### 5.2 info.list -- 목록 조회

카테고리, 서브카테고리, 지역, 도시, 월(축제용) 필터 + 페이지네이션 목록 조회.

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=info.list&category=travel&region=세부&page=1&limit=20` |
| **인증** | 불필요 |

**입력 파라미터:**

| 파라미터 | 타입 | 기본값 | 설명 |
|---------|------|--------|------|
| `category` | string | (빈) | 카테고리 필터 |
| `subcategory` | string | (빈) | 서브카테고리 필터 |
| `region` | string | (빈) | 지역 필터 |
| `city` | string | (빈) | 도시 필터 |
| `month` | int | 0 | 월 필터 (1~12, 축제용) |
| `status` | string | `Y` | 상태 필터 (Y: 활성, N: 비활성) |
| `orderBy` | string | `sort_order ASC, idx DESC` | 정렬 기준 |
| `page` | int | 1 | 페이지 번호 |
| `limit` | int | 20 | 페이지당 항목 수 (최대 100) |

**허용 정렬 기준 (orderBy 화이트리스트):**

| orderBy 값 | 설명 |
|------------|------|
| `sort_order ASC, idx DESC` | 정렬순서 + 최신순 (기본) |
| `idx DESC` | 최신순 |
| `idx ASC` | 오래된순 |
| `name ASC` | 이름 오름차순 |
| `name DESC` | 이름 내림차순 |
| `created_at DESC` | 생성일 최신순 |
| `created_at ASC` | 생성일 오래된순 |
| `view_count DESC` | 조회수 높은순 |

**출력:**

```json
{
  "success": true,
  "data": {
    "items": [
      { "idx": 1, "category": "travel", "name": "막탄 해변", "..." : "..." },
      { "idx": 2, "category": "travel", "name": "카와산 폭포", "..." : "..." }
    ],
    "total": 45,
    "page": 1,
    "limit": 20
  }
}
```

**curl 예시:**

```bash
# 여행지 목록 (세부 지역)
curl "https://v7-local.philgo.com/api.php?method=info.list&category=travel&region=세부"

# 병원 목록 (마닐라)
curl "https://v7-local.philgo.com/api.php?method=info.list&category=hospital&city=마닐라"

# 1월 축제 목록
curl "https://v7-local.philgo.com/api.php?method=info.list&category=festival&month=1"

# 긴급연락처 전체 목록
curl "https://v7-local.philgo.com/api.php?method=info.list&category=emergency"
```

---

### 5.3 info.search -- FULLTEXT 검색

`name`, `english_name`, `title`, `description`, `tags` 5개 필드에 대해 FULLTEXT 검색을 수행함. Boolean Mode로 동작함.

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=info.search&keyword=병원&category=hospital` |
| **인증** | 불필요 |

**입력 파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `keyword` | string | 필수 | 검색어 |
| `category` | string | 선택 | 카테고리 필터 |
| `region` | string | 선택 | 지역 필터 |
| `page` | int | 선택 | 페이지 번호 (기본 1) |
| `limit` | int | 선택 | 페이지당 항목 수 (기본 20, 최대 100) |

**출력:** `info.list`와 동일한 형식 (`items`, `total`, `page`, `limit`)

**주의:** 검색은 `status = 'Y'`인 활성 항목만 대상으로 함.

**curl 예시:**

```bash
# 전체 카테고리에서 "세부" 검색
curl "https://v7-local.philgo.com/api.php?method=info.search&keyword=세부"

# 병원 카테고리에서 "한국어" 검색
curl "https://v7-local.philgo.com/api.php?method=info.search&keyword=한국어&category=hospital"

# 세부 지역에서 "맛집" 검색
curl "https://v7-local.philgo.com/api.php?method=info.search&keyword=맛집&region=세부"
```

---

### 5.4 info.create -- 정보 생성 (관리자 전용)

새 정보를 생성함. 관리자 인증 필수.

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=info.create&session_id=xxx&category=hospital&name=세부종합병원` |
| **인증** | 관리자 전용 (`ADMINS` 상수의 firebase_uid 배열로 확인) |

**필수 입력:**

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `category` | string | 필수 | 카테고리 |
| `name` | string | 필수 | 이름 |

**선택 입력:** `subcategory`, `category_icon`, `subcategory_icon`, `english_name`, `title`, `icon`, `description`, `content`, `texts`(JSON 배열), `image_url`, `city`, `province`, `region`, `address`, `latitude`, `longitude`, `phone`, `phone2`, `email`, `url`, `hours`, `fee`, `month`, `event_date`, `extra_data`(JSON 객체), `tags`, `sort_order`, `status`

**출력:** `InfoEntity.toArray()`

**curl 예시:**

```bash
curl "https://v7-local.philgo.com/api.php?method=info.create&session_id=xxx&category=hospital&name=세부종합병원&region=세부&phone=%2B63-32-2536071&category_icon=🏥"
```

---

### 5.5 info.update -- 정보 수정 (관리자 전용)

기존 정보를 수정함. 관리자 인증 필수.

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=info.update&session_id=xxx&idx=1&name=새이름` |
| **인증** | 관리자 전용 |
| **입력** | `idx` (int, 필수) + 수정할 필드들 |
| **출력** | `InfoEntity.toArray()` |

**curl 예시:**

```bash
curl "https://v7-local.philgo.com/api.php?method=info.update&session_id=xxx&idx=1&name=세부도립의료원&description=업데이트된설명"
```

---

### 5.6 info.delete -- 정보 삭제 (관리자 전용)

정보를 삭제함. 관리자 인증 필수.

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=info.delete&session_id=xxx&idx=1` |
| **인증** | 관리자 전용 |
| **입력** | `idx` (int, 필수) |
| **출력** | `{ deleted: true, idx: 1 }` |

**curl 예시:**

```bash
curl "https://v7-local.philgo.com/api.php?method=info.delete&session_id=xxx&idx=1"
```

---

## 6. 카테고리/서브카테고리 규약

### 기본 카테고리

| category | category_icon | 설명 | 용도 |
|----------|---------------|------|------|
| `travel` | 🧳 | 여행지 | 관광 명소, 해변, 폭포 등 |
| `festival` | 🎉 | 축제 | 월별 축제/이벤트 (month 필드 활용) |
| `hospital` | 🏥 | 병원 | 종합병원, 클리닉, 치과 등 |
| `police` | 🚔 | 경찰 | 경찰서, 파출소 |
| `emergency` | 🆘 | 긴급연락처 | 대사관, 영사관, 긴급전화 |
| `visa` | 🛂 | 비자 | 비자 종류, 연장 절차 |
| `living` | 📱 | 생활정보 | SIM 카드, 환전, 교통 등 |
| `food` | 🍽️ | 맛집 | 식당, 카페, 바 |
| `accommodation` | 🏨 | 숙소 | 호텔, 리조트, 에어비앤비 |

### 서브카테고리 예시

| category | subcategory | subcategory_icon | 설명 |
|----------|------------|------------------|------|
| `travel` | `beach` | 🏖️ | 해변 |
| `travel` | `waterfall` | 💧 | 폭포 |
| `travel` | `temple` | 🛕 | 사원/성당 |
| `hospital` | `general` | 🏥 | 종합병원 |
| `hospital` | `dental` | 🦷 | 치과 |
| `emergency` | `embassy` | 🏛️ | 대사관/영사관 |
| `living` | `sim` | 📱 | SIM 카드 |
| `living` | `exchange` | 💱 | 환전 |

> 카테고리/서브카테고리는 고정 값이 아니라 DB에 자유롭게 입력할 수 있음. 위 표는 권장 규약임.

---

## 7. JSON 컬럼 구조

### 7.1 texts -- 마크다운 섹션 배열

`texts` 컬럼은 긴 본문을 마크다운 섹션 배열로 저장함. 각 항목은 마크다운 문자열임.

```json
[
  "## 진료과목\n- 내과\n- 외과\n- 소아과",
  "## 오시는 길\n세부 시내에서 택시로 10분 소요",
  "## 진료시간\n- 평일: 08:00~17:00\n- 주말: 09:00~12:00"
]
```

**용도:** 상세 페이지에서 각 섹션을 독립적으로 렌더링하거나, 아코디언/탭으로 표시할 때 유용함.

### 7.2 extra_data -- 카테고리별 추가 데이터

`extra_data` 컬럼은 카테고리별로 필요한 추가 데이터를 JSON 객체로 저장함.

**병원 (hospital):**

```json
{
  "insurance": true,
  "korean_staff": true,
  "departments": ["내과", "외과", "소아과"],
  "emergency_24h": false
}
```

**비자 (visa):**

```json
{
  "visa_type": "관광비자",
  "duration": "30일",
  "fee_usd": 0,
  "extension_possible": true,
  "required_documents": ["여권", "왕복 항공권"]
}
```

**축제 (festival):**

```json
{
  "duration_days": 9,
  "main_event": "그랜드 퍼레이드",
  "ticket_required": false
}
```

---

## 8. 권한 모델

| 접근 수준 | 대상 | API |
|-----------|------|-----|
| **공개** | 모든 사용자 (비로그인 포함) | `info.get`, `info.list`, `info.search` |
| **관리자 전용** | ADMINS 상수에 firebase_uid가 포함된 사용자 | `info.create`, `info.update`, `info.delete` |

**관리자 인증 흐름:**

1. `AuthService::getLoginUser()`로 로그인 사용자 확인
2. 사용자의 `firebase_uid`가 `ADMINS` 상수 배열에 포함되는지 확인
3. 미포함 시 `RuntimeException('관리자만 접근할 수 있습니다')` throw

---

## 9. Flutter/웹 호출 예시

### Flutter 앱

```dart
// 여행지 목록 조회
final result = await v7api('info.list', {
  'category': 'travel',
  'region': '세부',
  'page': 1,
  'limit': 20,
});
final items = (result['items'] as List).map((e) => InfoModel.fromJson(e)).toList();
final total = result['total'] as int;

// 병원 검색
final searchResult = await v7api('info.search', {
  'keyword': '한국어',
  'category': 'hospital',
});

// 단건 조회
final info = await v7api('info.get', {'idx': 1});

// 긴급연락처 전체 목록
final emergency = await v7api('info.list', {
  'category': 'emergency',
});

// 1월 축제 목록
final festivals = await v7api('info.list', {
  'category': 'festival',
  'month': 1,
});
```

### 웹 (JavaScript)

```javascript
// 여행지 목록 조회
const result = await v7api('info.list', {
  category: 'travel',
  region: '세부',
  page: 1,
  limit: 20,
});
console.log(result.items, result.total);

// 병원 검색
const hospitals = await v7api('info.search', {
  keyword: '한국어',
  category: 'hospital',
});

// 단건 조회
const info = await v7api('info.get', { idx: 1 });

// 긴급연락처 전체 목록
const emergency = await v7api('info.list', {
  category: 'emergency',
});
```

### 웹 (PHP SSR)

```php
use Philgo\Info\InfoService;

// 여행지 목록
$result = InfoService::list([
    'category' => 'travel',
    'region' => '세부',
    'page' => 1,
    'limit' => 20,
]);
foreach ($result['items'] as $item) {
    echo $item['name'] . '<br>';
}

// 단건 조회
$info = InfoService::get(['idx' => 1]);

// 검색
$searchResult = InfoService::search([
    'keyword' => '병원',
    'category' => 'hospital',
]);
```

### 관리자 전용 (생성/수정/삭제)

```javascript
// 정보 생성 (관리자)
const created = await v7api('info.create', {
  category: 'hospital',
  name: '세부종합병원',
  english_name: 'Cebu General Hospital',
  region: '세부',
  phone: '+63-32-2536071',
  category_icon: '🏥',
  texts: JSON.stringify(['## 진료과목\n- 내과\n- 외과']),
  extra_data: JSON.stringify({ insurance: true }),
});

// 정보 수정 (관리자)
const updated = await v7api('info.update', {
  idx: 1,
  name: '세부도립의료원',
  description: '업데이트된 설명',
});

// 정보 삭제 (관리자)
const deleted = await v7api('info.delete', { idx: 1 });
```
