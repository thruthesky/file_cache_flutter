# Flutter 앱 업소록(Company) v7 API 연동 가이드

## 개요

필고 앱의 업소록(Company) 기능은 **v7 API**를 통해 모든 데이터를 가져온다.
기존 레거시 API(`func.php`)를 사용하지 않고, v7 시스템(`api.php`)만을 사용하여
업소 목록 조회, 상세 보기, 생성, 수정, QR 코드, 방문 후기 등 모든 기능을 처리한다.

### 핵심 원칙

| 원칙 | 설명 |
|------|------|
| **v7 API 전용** | 업소록 관련 모든 데이터는 `v7api()` 함수로 가져온다 |
| **CompanyApi 클래스 사용** | `lib/v7_api/company_api.dart`의 래퍼 메서드를 사용한다 |
| **로컬 DB 직접 접근** | 개발 모드에서 v7 API를 호출하면 **로컬 MariaDB**에서 데이터를 가져온다 |
| **프로덕션 DB 직접 접근** | 프로덕션 모드에서는 **프로덕션 MariaDB**에서 데이터를 가져온다 |
| **동일 DB 구조** | 로컬/프로덕션 모두 동일한 `company` 테이블을 사용한다 |

---

## 1. 개발 모드 vs 프로덕션 모드

### 환경 변수 설정

v7 API 엔드포인트는 `--dart-define`으로 컴파일 시점에 결정된다.

```bash
# 개발 모드: 로컬 서버 → 로컬 MariaDB
flutter run --dart-define=ENV=dev --dart-define=V7_API_ENDPOINT=https://local.philgo.com/api.php

# 프로덕션 모드: 프로덕션 서버 → 프로덕션 MariaDB
flutter run --dart-define=ENV=prod --dart-define=V7_API_ENDPOINT=https://philgo.com/api.php

# 기본값 (V7_API_ENDPOINT 미지정 시)
# → https://philgo.com/api.php (프로덕션)
```

### PhilgoConfig 설정 (`packages/philgo_api/lib/src/philgo.config.dart`)

```dart
class PhilgoConfig {
  static const String getEnv = String.fromEnvironment("ENV", defaultValue: prod);
  static bool get isDevelopment => getEnv == dev;
  static bool get isProduction => getEnv == prod;

  static const String v7ApiEndpoint = String.fromEnvironment(
    'V7_API_ENDPOINT',
    defaultValue: 'https://philgo.com/api.php',
  );
}
```

### 데이터 흐름

```
[개발 모드]
Flutter 앱 → v7api() → https://local.philgo.com/api.php
                              ↓
                     CompanyController → CompanyService
                              ↓
                     로컬 MariaDB (company 테이블)

[프로덕션 모드]
Flutter 앱 → v7api() → https://philgo.com/api.php
                              ↓
                     CompanyController → CompanyService
                              ↓
                     프로덕션 MariaDB (company 테이블)
```

**중요**: 개발 모드에서 v7 API를 사용하면 **로컬 Docker MariaDB**에서 데이터를 직접 가져온다.
이를 통해 프로덕션 데이터를 건드리지 않고 안전하게 개발/테스트가 가능하다.

---

## 2. CompanyApi 클래스

### 파일 위치

`lib/v7_api/company_api.dart`

### 메서드 목록

| 메서드 | v7 엔드포인트 | 인증 | 설명 |
|--------|-------------|------|------|
| `CompanyApi.list()` | `company.list` | 불필요 | 업소 목록 조회 |
| `CompanyApi.get(idx)` | `company.get` | 불필요 | 업소 단건 조회 |
| `CompanyApi.mine()` | `company.mine` | 필수 | 내 업소 조회 (없으면 자동 생성) |
| `CompanyApi.create()` | `company.create` | 필수 | 업소 생성 |
| `CompanyApi.update(data)` | `company.update` | 필수 | 업소 정보 수정 |
| `CompanyApi.reVisitPoint(usageIdx)` | `company.reVisitPoint` | 필수 | 재방문 포인트 추첨 |
| `CompanyApi.submitVisitReview(...)` | `company.submitVisitReview` | 필수 | 방문 후기 작성 |
| `CompanyApi.getVisitReviews(...)` | `company.getVisitReviews` | 불필요 | 방문 후기 목록 조회 |

### 사용 예시

```dart
import 'package:philgo/v7_api/company_api.dart';

/// 업소 목록 가져오기
final companyList = await CompanyApi.list(category: 'food', status: 'a');
for (final company in companyList.companies) {
  print('${company.name} - ${company.location}');
}

/// 업소 단건 조회
final company = await CompanyApi.get(1025);
print(company.name);

/// 내 업소 조회 (없으면 자동 생성)
final myCompany = await CompanyApi.mine();
print(myCompany.idx);

/// 업소 정보 수정
final updated = await CompanyApi.update({
  'name': '새 이름',
  'description': '새 설명',
});

/// 방문 후기 목록 조회
final reviews = await CompanyApi.getVisitReviews(idxCompany: 1025);
```

---

## 3. v7api() 핵심 함수

### 파일 위치

`lib/v7_api/v7_api.dart`

### 시그니처

```dart
Future<Map<String, dynamic>> v7api(
  String method, {
  Map<String, dynamic>? data,
  bool debug = false,
  bool alertOnError = false,
}) async
```

### 동작 방식

1. `data['method'] = method` 자동 추가
2. `patchToken(data)` — Firebase ID Token 자동 삽입
3. `createDio()` — SSL 처리된 Dio 인스턴스 생성
4. `dio.post(PhilgoConfig.v7ApiEndpoint, data: data)` — HTTP POST 요청
5. 응답 파싱: Map 또는 JSON String 자동 감지
6. `success == false` 시 Exception throw

### 에러 처리 패턴

```dart
try {
  final result = await v7api('company.list');
  // 성공 처리
} catch (e) {
  // v7api가 자동으로 Exception throw
  // DioException: 네트워크 에러
  // Exception: v7api(company.list): 에러 메시지
}
```

---

## 4. 화면 구조

### 업소록 화면 목록

| 화면 | 클래스명 | routeName | 설명 |
|------|---------|-----------|------|
| 업소 목록 | `CompanyListScreen` | `/company-list` | 카테고리별 업소 그리드 |
| 업소 보기 | `CompanyViewScreen` | `/company/view.php` | 업소 상세 정보 + 후기 |
| 업소 폼 | `CompanyFormScreen` | `/company-form` | 업소 정보 입력/수정 (멀티스텝) |
| QR 코드 | `CompanyQrCodeScreen` | `/company-qr-code` | QR 코드 발행/표시 + 부정 사용 경고 배너 |
| QR 스캐너 | `QrScannerScreen` | `/qr-scanner` | 카메라 QR 코드 스캔 |
| QR 스캔 결과 | `CompanyQrCodeScannedScreen` | `/company/qr-code-scanned.php` | QR 스캔 + 포인트 적립 |
| 재방문 결과 | `CompanyRevisitPointResultScreen` | `/company/revisit-point-result` | 재방문 포인트 결과 |
| 후기 작성 | `CompanyVisitReviewScreen` | `/company/visit-review` | 방문 후기 입력 |
| 후기 결과 | `CompanyReviewPointResultScreen` | `/company/review-point-result` | 후기 포인트 결과 |

### 화면 파일 위치

모든 화면은 `lib/screens/company/` 폴더에 위치한다.

### 폼 섹션 컴포넌트

| 파일 | 설명 |
|------|------|
| `form.basic.info.dart` | 업소명 필드 |
| `form.contact.info.dart` | 전화, 카카오톡, 텔레그램 연락처 |
| `form.detailed.info.dart` | 업소명, 카테고리, 위치, 주소, 설명 |
| `form.image.upload.dart` | 로고, 사업면허증, 소개 이미지, 사무실 이미지 |
| `form_field_label.dart` | 폼 필드 라벨 위젯 |

---

## 5. API 엔드포인트 상세

### 5.1 company.list — 업소 목록 조회

```dart
final companies = await CompanyApi.list(
  category: 'food',     // 카테고리 필터 (선택)
  status: 'a',          // 상태 필터 (기본: 'a' 승인됨)
  orderby: 'updated_at DESC', // 정렬 (선택)
  limit: 20,            // 최대 조회 수 (선택, 최대 100)
);
```

**v7 응답 → CompanyList 변환**:
```dart
// v7 응답: { items: [...] }
// CompanyList.fromJson() 호환 형식으로 자동 변환:
// { page: 1, company_count: N, companies: [...], config: {} }
```

### 5.2 company.get — 업소 단건 조회

```dart
final company = await CompanyApi.get(1025);
// v7 응답: { data: { idx, name, ... } } 또는 직접 { idx, name, ... }
// 자동으로 Company.fromJson() 변환
```

### 5.3 company.mine — 내 업소 조회

```dart
final myCompany = await CompanyApi.mine();
// 인증 필수 (Firebase ID Token 자동 전송)
// 업소가 없으면 서버에서 자동 생성 (status='')
```

### 5.4 company.update — 업소 수정

```dart
final updated = await CompanyApi.update({
  'name': '새 업소명',
  'description': '새 설명',
  'category': 'restaurant',
});
// description, title_image_url, photo_url 변경 시 → status='p'(심사중) 자동 전환
```

### 5.5 company.reVisitPoint — 재방문 포인트 추첨

```dart
final result = await CompanyApi.reVisitPoint(usageIdx);
// 응답: { reward_points, point_before, point_after, company_name, idx_company }
// 포인트: 2,000~3,000P 랜덤
```

### 5.6 company.submitVisitReview — 방문 후기 작성

```dart
final result = await CompanyApi.submitVisitReview(
  usageIdx: 42,
  content: '맛있었습니다. 분위기도 좋고 서비스도 훌륭해요!', // 10자 이상
  photoIdxs: [101, 102], // 업로드된 사진 idx 목록 (1장 이상)
);
// 응답: { review_idx, reward_points, point_before, point_after }
// 포인트: 2,000~3,000P 랜덤
```

### 5.7 company.getVisitReviews — 방문 후기 목록

```dart
final result = await CompanyApi.getVisitReviews(
  idxCompany: 1025,
  page: 1,    // 선택
  limit: 10,  // 선택
);
// 응답: { reviews: [...], total: N, page: 1, limit: 10 }
// 각 review: { idx, idx_company, idx_member, content, reward_points, created_at, photos: [...] }
```

---

## 6. 업소 상태 흐름

```
생성(mine/create)     수정(update)        관리자 승인/거절
  ↓                    ↓                    ↓
 '' (신규)  →  'p' (심사중)  →  'a' (승인) 또는 'p' (거절)
```

| 상태 | 코드 | 설명 | QR 활성화 |
|------|------|------|-----------|
| 신규 | `''` | 처음 생성 | 불가 |
| 심사중 | `'p'` | 관리자 검토 대기 | 불가 |
| 승인됨 | `'a'` | 승인 완료 | 가능 (`show_qr_code=1` 시) |

### 자동 Pending 처리

다음 필드 변경 시 `status`가 자동으로 `'p'`로 변경됨:
- `description` (업소 설명)
- `title_image_url` (제목 이미지)
- `photo_url` (사진)

---

## 7. QR 코드 삼단콤보 흐름

### CompanyQrCodeScreen 위젯 구성

`lib/screens/company/company.qr_code.screen.dart`

| 순서 | 위젯 메서드 | 설명 |
|------|-------------|------|
| [1] | `_buildCompanyInfoSection` | 로고, 업소명, 카테고리 태그, 위치, 연락처 |
| [2] | `_buildEventBanner` | "필고 + {업소명} 이벤트 참여" 그라데이션 배너 |
| [3] | `_buildQrCodeSection` | QR 코드 이미지 (RepaintBoundary로 캡처 지원) |
| [4] | QR 스캔 가이드 | `T.qrCodeScanGuide` 안내 문구 |
| [5] | `_buildFraudWarningBanner` | QR 코드 부정 사용 경고 배너 (`T.qrCodeFraudWarning`) |

#### 부정 사용 경고 배너 (`_buildFraudWarningBanner`)

- **디자인**: `scheme.error` 색상 그라데이션 배경 (8%→4% 투명도) + error 테두리 (25%)
- **아이콘**: `FontAwesomeIcons.lightTriangleExclamation`
- **텍스트**: `T.qrCodeFraudWarning` (fontWeight: w600, height: 1.5)
- **애니메이션**: fadeIn 500ms + slideY (delay: 400ms)
- **i18n 키**: `qrCodeFraudWarning` (ko/en/ja/zh 4개 언어 지원)

### 재방문 흐름 (is_revisit == true)

```
[QR 스캔 결과 화면] → 1~2천P QR 스캔 포인트 적립
  ↓ "재방문 포인트 추첨" 버튼
[CompanyRevisitPointResultScreen] → company.reVisitPoint API → 2~3천P 추가
  ↓ "후기 작성" 버튼
[CompanyVisitReviewScreen] → 내용(10자+) + 사진(1장+) 입력
  ↓ company.submitVisitReview API
[CompanyReviewPointResultScreen] → 2~3천P 추가 적립 결과
  ↓ "업소 정보 보기" 버튼
[CompanyViewScreen] → 업소 상세 + 후기 목록
```

### 첫방문 흐름 (is_revisit != true)

```
[QR 스캔 결과 화면] → 1~2천P QR 스캔 포인트 적립
  ↓ "후기 작성" 버튼
[CompanyVisitReviewScreen] → 내용(10자+) + 사진(1장+) 입력
  ↓ company.submitVisitReview API
[CompanyReviewPointResultScreen] → 2~3천P 추가 적립 결과
  ↓ "업소 정보 보기" 버튼
[CompanyViewScreen] → 업소 상세 + 후기 목록
```

---

## 8. CompanyEntity 주요 필드

### 기본 정보

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx` | int | 업소 고유번호 (PK) |
| `idx_member` | int | 소유자 회원번호 (UNIQUE) |
| `name` | String | 업소명 |
| `title` | String | 업소 제목 |
| `description` | String | 업소 설명 |
| `category` | String | 카테고리 |
| `location` | String | 지역 |
| `address` | String | 주소 |

### 연락처

| 필드 | 타입 | 설명 |
|------|------|------|
| `phone_number` | String | 전화번호 |
| `mobile_number` | String | 휴대폰번호 |
| `kakaotalk_id` | String | 카카오톡 ID |
| `telegram_id` | String | 텔레그램 ID |

### 이미지

| 필드 | 타입 | 설명 |
|------|------|------|
| `logo_url` | String | 로고 URL |
| `photo_url` | String | 사진 URL |
| `title_image_url` | String | 제목 이미지 URL |
| `business_license_url` | String | 사업자등록증 URL |

### 상태

| 필드 | 타입 | 설명 |
|------|------|------|
| `status` | String | 상태 (`''`, `'p'`, `'a'`) |
| `show_qr_code` | int | QR 코드 표시 (0 또는 1) |
| `qr_code_enabled` | bool | QR 활성화 (계산 필드: `status='a' AND show_qr_code=1`) |

---

## 9. 라우팅

### GoRouter 라우트 정의 (`lib/router.dart`)

```dart
// 업소 목록
GoRoute(path: '/company-list', builder: (_, __) => const CompanyListScreen())

// 업소 보기 (Deeplink 지원: ?idx=1025)
GoRoute(path: '/company/view.php', builder: (context, state) {
  final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
  if (idx > 0) return HomeScreen(redirect: CompanyViewScreen(companyIdx: idx));
  return CompanyViewScreen(companyIdx: state.extra as int? ?? 0);
})

// QR 코드
GoRoute(path: '/company-qr-code', builder: (_, state) =>
  CompanyQrCodeScreen(companyIdx: state.extra as int? ?? 0))

// QR 스캔 결과 (?code={64자 hex})
// ⚠️ CompanyQrCodeScannedScreen을 직접 반환 (HomeScreen redirect 미사용)
// → QR 스캐너에서 pushReplacement로 이동하므로 스택이 쌓이지 않음
GoRoute(path: '/company/qr-code-scanned.php', builder: (context, state) {
  final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
  final code = state.uri.queryParameters['code'] ?? '';
  return CompanyQrCodeScannedScreen(idx: idx, code: code);
})

// 업소 폼
GoRoute(path: '/company-form', builder: (_, state) =>
  CompanyFormScreen(company: state.extra as Company?))

// 후기 작성, 후기 결과, 재방문 결과 (extra: Map<String, dynamic>)
```

### 화면 이동 패턴

```dart
// 업소 목록 → 업소 보기
context.push(CompanyViewScreen.routeName, extra: companyIdx);

// 업소 보기 → QR 코드
context.push(CompanyQrCodeScreen.routeName, extra: companyIdx);

// 업소 보기 → 업소 정보 수정
context.push(CompanyFormScreen.routeName, extra: company);

// 후기 결과 → 업소 보기 (nav stack 초기화)
context.go('/');
context.push(CompanyViewScreen.routeName, extra: idxCompany);

// ⚠️ QR 스캐너 → QR 스캔 결과 (pushReplacement 필수)
// pushReplacement로 QR 스캐너를 스택에서 제거하여
// 결과 화면에서 백 버튼 시 홈으로 바로 돌아가도록 한다.
// context.push()를 사용하면 스택이 쌓여 백 버튼으로 홈에 갈 수 없음.
context.pushReplacement(
  '${CompanyQrCodeScannedScreen.routeName}?idx=$idx&code=$code',
);
```

---

## 10. 파일 업로드

업소록에서 사진 업로드는 `v7apiFileUpload()` 함수와 `V7FileUpload` 위젯을 사용한다.

### V7FileUpload 위젯

```dart
import 'package:philgo/v7_api/widgets/upload/v7_file_upload.dart';

V7FileUpload(
  module: 'company',
  code: 'visit_review',
  onUploaded: (Map<String, dynamic> result) {
    // result['idx'] — 업로드된 파일 idx
    // result['url'] — 파일 URL
    photoIdxs.add(result['idx'] as int);
  },
)
```

### v7apiFileUpload() 함수

```dart
final result = await v7apiFileUpload(
  filePath: '/path/to/photo.jpg',
  idxMember: loginUser.idx.toString(),
  module: 'company',
  code: 'visit_review',
  onProgress: (progress) => setState(() => uploadProgress = progress),
);
```

---

## 11. 포인트 적립 규칙

| 행동 | 포인트 범위 | 모듈/액션 | 조건 |
|------|-----------|----------|------|
| QR 스캔 | 1,000~2,000P | `company/qr_scan` | 로그인 사용자만 |
| 재방문 추첨 | 2,000~3,000P | `company/revisit` | 24시간 이전 방문 기록 필요 |
| 방문 후기 | 2,000~3,000P | `company/visit_review` | 내용 10자+, 사진 1장+ |

**최대 적립**: 재방문 시 최대 8,000P, 첫방문 시 최대 5,000P

---

## 12. 에러 처리

### v7 API 에러 응답

```json
{ "success": false, "message": "에러 메시지" }
```

### 주요 에러 케이스

| 상황 | 에러 메시지 |
|------|-----------|
| 미인증 | `'로그인이 필요합니다.'` |
| 업소 없음 | `'해당 업소를 찾을 수 없습니다.'` |
| 중복 업소 | `'이미 등록된 업소가 있습니다.'` |
| 중복 후기 | `'이미 후기를 작성하셨습니다.'` |
| QR 만료 | `'만료된 QR 코드입니다.'` |
| 24시간 중복 | `'24시간_중복\|마지막방문시간'` |

### Flutter에서 에러 처리 패턴

```dart
try {
  final result = await CompanyApi.get(1025);
  setState(() { company = result; });
} catch (e) {
  setState(() { errorMessage = e.toString(); });
  // 또는 showComicErrorSnackBar(context, e.toString());
}
```

---

## 13. 데이터베이스 참조

### company 테이블

업소 데이터를 저장하는 핵심 테이블.

- **PK**: `idx` (AUTO_INCREMENT)
- **UNIQUE**: `idx_member` (한 회원당 하나의 업소)
- **UNIQUE**: `family_site_domain` (도메인 중복 불가)
- 전체 필드: 33개 (기본 정보, 연락처, 이미지, Family Site, 광고, 상태)

### company_reviews 테이블

방문 후기 데이터를 저장하는 테이블.

- **PK**: `idx` (AUTO_INCREMENT)
- `idx_company`: 업소 번호
- `idx_member`: 작성자 회원번호
- `usage_idx`: QR 스캔 기록 번호
- `content`: 후기 내용
- `reward_points`: 적립된 포인트

### uploads 테이블

후기 사진 등 파일 업로드 데이터.

- `module='company'`, `code='visit_review'`로 후기 사진 연결

---

## 14. 권한 모델

| 접근 수준 | 대상 | 가능 API |
|-----------|------|---------|
| **공개** | 모든 사용자 | `list`, `get`, `getVisitReviews` |
| **로그인 필수** | 인증된 사용자 | `mine`, `create`, `scanQrCode` |
| **소유자/관리자** | 업소 소유자 또는 관리자 | `update`, `delete`, `issueQrCode` |
| **관리자만** | 관리자 | `approve`, `reject`, `toggleQrCode` |
