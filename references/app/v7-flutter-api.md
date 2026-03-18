# Flutter 앱에서 v7 API 사용 가이드

## 목차

- [1. 개요](#1-개요)
- [2. v7api() 함수](#2-v7api-함수)
  - [2.1 함수 시그니처](#21-함수-시그니처)
  - [2.2 매개변수](#22-매개변수)
  - [2.3 반환값](#23-반환값)
- [3. v6 func()과 v7api() 비교](#3-v6-func과-v7api-비교)
  - [3.1 아키텍처 비교](#31-아키텍처-비교)
  - [3.2 에러 판별 로직 비교](#32-에러-판별-로직-비교)
  - [3.3 공존 원칙](#33-공존-원칙)
- [4. 핵심 헬퍼 함수](#4-핵심-헬퍼-함수)
  - [4.1 createDio()](#41-createdìo)
  - [4.2 patchToken()](#42-patchtoken)
- [5. PhilgoConfig 설정](#5-philgoconfig-설정)
- [6. 에러 처리 패턴](#6-에러-처리-패턴)
  - [6.1 에러 처리 흐름](#61-에러-처리-흐름)
  - [6.2 에러 유형별 처리](#62-에러-유형별-처리)
- [7. 위젯에서의 사용 패턴](#7-위젯에서의-사용-패턴)
  - [7.1 기본 패턴: StatefulWidget + 3상태 관리](#71-기본-패턴-statefulwidget--3상태-관리)
  - [7.2 실전 예제: user.me 호출](#72-실전-예제-userme-호출)
  - [7.3 UI 렌더링 패턴](#73-ui-렌더링-패턴)
- [8. v7 서버 응답 형식](#8-v7-서버-응답-형식)
- [9. 인증 흐름 (Flutter → v7 서버)](#9-인증-흐름-flutter--v7-서버)
- [10. 파일 위치 참조](#10-파일-위치-참조)
- [11. v7apiFileUpload() 파일 업로드 함수](#11-v7apifileupload-파일-업로드-함수)
  - [11.1 함수 시그니처](#111-함수-시그니처)
  - [11.2 매개변수](#112-매개변수)
  - [11.3 반환값 (upload.upload 응답)](#113-반환값-uploadupload-응답)
  - [11.4 사용 예시](#114-사용-예시)
  - [11.5 v7api()와의 차이점](#115-v7api와의-차이점)
- [12. V7FileUpload 위젯 (재활용 필수)](#12-v7fileupload-위젯-재활용-필수)
  - [12.1 개요 및 재활용 원칙](#121-개요-및-재활용-원칙)
  - [12.2 위젯 속성 (Props)](#122-위젯-속성-props)
  - [12.3 사용 예시](#123-사용-예시)
  - [12.4 실전 통합 패턴: 업로드 상태 관리](#124-실전-통합-패턴-업로드-상태-관리)
  - [12.5 동작 원리](#125-동작-원리)
- [13. v7 위젯 목록](#13-v7-위젯-목록)
- [17. Reddit 스타일 코멘트 스레드 라인 (Flutter 앱)](#17-reddit-스타일-코멘트-스레드-라인-flutter-앱)
  - [17.1 구조 개요](#171-구조-개요)
  - [17.2 위젯 계층 구조](#172-위젯-계층-구조)
  - [17.3 트리 변환: buildCommentTree()](#173-트리-변환-buildcommenttree)
  - [17.4 세로선 정렬 핵심 원리](#174-세로선-정렬-핵심-원리)
  - [17.5 ThreadConnectorPainter 상세](#175-threadconnectorpainter-상세)
  - [17.6 주요 상수 정리](#176-주요-상수-정리)
  - [17.7 깊이별 들여쓰기 전략](#177-깊이별-들여쓰기-전략)
  - [17.8 주의사항 및 트러블슈팅](#178-주의사항-및-트러블슈팅)
  - [17.9 파일 위치 참조](#179-파일-위치-참조)

---

## 1. 개요

Flutter 앱에서 필고 v7 서버(api.php)와 통신하기 위한 가이드이다.

- **v7api() 함수**: `lib/v7_api/v7_api.dart`에 위치한 v7 전용 API 호출 함수
- **기존 func()과 공존**: v6 `func()`은 `func.php`를, v7 `v7api()`는 `api.php`를 호출
- **헬퍼 재사용**: 기존 `createDio()`, `patchToken()` 함수를 그대로 재사용
- **인증 자동 처리**: `patchToken()`이 Firebase ID Token을 자동으로 `id_token` 파라미터에 추가

```
Flutter App → v7api('user.me')
    ▼ HTTP POST
    ▼ https://philgo.com/api.php
    ▼ body: {method: "user.me", id_token: "Firebase토큰"}
    ▼
PHP api.php (PSR-4 Autoloading)
    ├─ RequestUtils::parseMethod("user.me") → ["user", "me"]
    ├─ FQCN: "Philgo\User\UserController"
    └─ new UserController() → me($input)
    ▼
JSON 응답: {"idx": 123, "id": "user@test.com", "name": "홍길동", ...}
```

---

## 2. v7api() 함수

### 2.1 함수 시그니처

```dart
import 'package:philgo/v7_api/v7_api.dart';

Future<Map<String, dynamic>> v7api(
  String method, {
  Map<String, dynamic>? data,
  bool debug = false,
  bool alertOnError = false,
}) async
```

### 2.2 매개변수

| 매개변수 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|-------|------|
| `method` | `String` | ✅ | — | `"모듈.액션"` 형식 (예: `"user.count"`, `"user.me"`, `"upload.image"`) |
| `data` | `Map<String, dynamic>?` | ❌ | `null` | 추가 전송 데이터. `method` 필드는 자동 추가됨 |
| `debug` | `bool` | ❌ | `false` | `true`일 때 전체 GET URL을 `dart:developer` log로 출력 |
| `alertOnError` | `bool` | ❌ | `false` | `true`일 때 에러 발생 시 `showSafeErrorDialog()` 표시 |

### 2.3 반환값

- **성공**: `Map<String, dynamic>` — v7 Controller 리턴값 그대로
- **에러**: `Exception` throw (호출측에서 try-catch 필요)

```dart
// 성공 예시
final result = await v7api('user.count');
print(result['count']);  // 188186

// 에러 발생 시 Exception
try {
  final user = await v7api('user.me');
} catch (e) {
  // "Exception: v7api(user.me): 로그인이 필요합니다."
}
```

---

## 3. v6 func()과 v7api() 비교

### 3.1 아키텍처 비교

| 항목 | func() (v6 레거시) | v7api() (v7 신규) |
|------|-------------------|-------------------|
| **서버 엔드포인트** | `/func.php` | `/api.php` |
| **method 전달** | `data['func'] = funcName` | `data['method'] = 'module.action'` |
| **서버 라우팅** | 함수명 기반 디스패치 | PSR-4 Controller 디스패치 |
| **설정 상수** | `PhilgoConfig.apiUrl` | `PhilgoConfig.v7ApiEndpoint` |
| **HTTP 방식** | POST | POST |
| **인증** | `patchToken()` 자동 | `patchToken()` 자동 (동일) |
| **SSL 처리** | `createDio()` | `createDio()` (동일) |
| **응답 타입** | 제네릭 `T` | `Map<String, dynamic>` |

### 3.2 에러 판별 로직 비교

**func() (v6)** — `error` 필드 존재 여부로 판별:
```dart
// func() 내부
if (json['error'] != null) {
  // 에러이지만 Exception 아닌 데이터로 반환
  return json as T;
}
return json as T;  // 성공

// 호출측에서 에러 확인
final result = await func('user.my');
if (result['error'] != null) {
  print('에러: ${result['message']}');
}
```

**v7api()** — `success == false`로 판별, Exception throw:
```dart
// v7api() 내부
if (json['success'] == false) {
  throw Exception('v7api($method): ${json['message']}');
}
return json;  // 성공

// 호출측에서 try-catch
try {
  final result = await v7api('user.me');
  print('이름: ${result['name']}');
} catch (e) {
  print('에러: $e');
}
```

> **핵심 차이**: func()은 에러를 데이터로 반환, v7api()는 에러 시 Exception throw

### 3.3 공존 원칙

두 함수는 **동일 화면에서 동시 사용 가능**하다:

```dart
import 'package:philgo_api/philgo_api.dart';  // func()
import 'package:philgo/v7_api/v7_api.dart';    // v7api()

// v6 API 호출 (기존 기능)
final posts = await func('post.list', {'post_id': 'freetalk', 'limit': '10'});

// v7 API 호출 (새 기능)
final userInfo = await v7api('user.me');
```

---

## 4. 핵심 헬퍼 함수

v7api()는 기존 `philgo_api` 패키지의 헬퍼 함수를 **그대로 재사용**한다.

### 4.1 createDio()

**위치**: `packages/philgo_api/lib/src/philgo/philgo.api.functions.dart`

```dart
Dio createDio() {
  final dio = Dio();
  if (kDebugMode) {
    // 디버그 모드: SSL 인증서 검증 무시 (자체 서명 인증서 허용)
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return httpClient;
    };
  }
  return dio;
}
```

**역할**:
- Dio HTTP 클라이언트 인스턴스 생성
- **kDebugMode**일 때만 SSL 인증서 검증 무시 (개발 환경의 MkCert 자체 서명 인증서 지원)
- 프로덕션에서는 정상 SSL 검증 수행

### 4.2 patchToken()

**위치**: `packages/philgo_api/lib/src/philgo/philgo.api.functions.dart`

```dart
Future<RecordType> patchToken(RecordType data) async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) return data;  // 비로그인: 토큰 없이 전송

  try {
    final token = await auth.currentUser!.getIdToken();
    data['id_token'] = token ?? '';
  } catch (e) {
    debugLog('Error getting Firebase ID token: $e');
    data['id_token'] = '';
  }
  return data;
}
```

**역할**:
- Firebase Auth 현재 사용자의 **ID Token** 획득
- 요청 데이터에 `id_token` 필드 자동 추가
- 비로그인 상태: 토큰 추가 안함 (서버에서 비로그인 처리)
- 토큰 획득 실패: `id_token: ''` 설정 (Exception 발생 안함)

**v7 서버에서의 처리**:
- `id_token` → `FirebaseService::verifyIdToken()` → Firebase UID 획득 → `sf_member` 테이블 조회

---

## 5. PhilgoConfig 설정

**위치**: `packages/philgo_api/lib/src/philgo.config.dart`

```dart
static const String v7ApiEndpoint = String.fromEnvironment(
  'V7_API_ENDPOINT',
  defaultValue: 'https://philgo.com/api.php',
);
```

### 환경별 설정

| 환경 | v7ApiEndpoint 값 | 설정 방법 |
|------|-----------------|---------|
| **프로덕션** | `https://philgo.com/api.php` | 기본값 (설정 불필요) |
| **개발 (로컬)** | `https://local.philgo.com:443/api.php` | `--dart-define` 지정 |

### 빌드 시 지정

```bash
# 개발 환경
flutter run --dart-define=V7_API_ENDPOINT='https://local.philgo.com:443/api.php'

# 프로덕션 (기본값 사용)
flutter run --release
```

### VSCode launch.json 설정 예시

```json
{
  "configurations": [{
    "name": "dev",
    "request": "launch",
    "type": "dart",
    "args": [
      "--dart-define=V7_API_ENDPOINT=https://local.philgo.com:443/api.php"
    ]
  }]
}
```

---

## 6. 에러 처리 패턴

### 6.1 에러 처리 흐름

```
v7api('user.me') 호출
    ▼
[1] 데이터 준비: {method: "user.me"} + patchToken → {method: "user.me", id_token: "..."}
    ▼
[2] dio.post(url, data: data)
    ▼
[3] 응답 파싱
    ├─ Map<String, dynamic> → 그대로 사용
    ├─ String → jsonDecode()
    └─ 기타 → Exception('예상치 못한 응답 타입')
    ▼
[4] 에러 판별
    ├─ success == false → Exception throw
    │   └─ alertOnError=true → showSafeErrorDialog()
    └─ success != false → Map 반환 (성공)
    ▼
[5] 예외 처리
    ├─ DioException → 네트워크 에러 로깅 + rethrow
    │   └─ Handshake 에러 → '서버와 접속이 안됩니다' Exception
    └─ 기타 Exception → 에러 로깅 + rethrow
```

### 6.2 에러 유형별 처리

#### (1) v7 서버 로직 에러 (`success == false`)

서버가 정상 응답했지만 비즈니스 로직상 에러인 경우:

```json
{"success": false, "message": "로그인이 필요합니다."}
```

```dart
// v7api 내부에서 자동 처리
throw Exception('v7api(user.me): 로그인이 필요합니다.');
```

#### (2) DioException (네트워크/HTTP 에러)

서버 연결 실패, 타임아웃, HTTP 4xx/5xx 등:

```dart
// v7api 내부에서 상세 로깅 후 rethrow
// 로그 예시:
// [v7API:ERROR] method: user.me
// [v7API:ERROR] 요청 URL: https://philgo.com/api.php
// [v7API:ERROR] 에러 타입: DioExceptionType.connectionTimeout
```

#### (3) Handshake 에러 (SSL 인증서 검증 실패)

```dart
// v7api 내부에서 사용자 친화적 메시지로 변환
throw Exception('서버와 접속이 안됩니다. 인터넷 연결을 확인해 주세요.');
```

### alertOnError 옵션

`alertOnError: true`를 설정하면 에러 발생 시 자동으로 다이얼로그를 표시한다:

```dart
// 에러 시 자동으로 다이얼로그 표시 + Exception throw
await v7api('user.me', alertOnError: true);
```

---

## 7. 위젯에서의 사용 패턴

### 7.1 기본 패턴: StatefulWidget + 3상태 관리

v7api() 호출 결과를 화면에 표시하는 표준 패턴:

```dart
import 'package:flutter/material.dart';
import 'package:philgo/v7_api/v7_api.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  /// v7 API 응답 데이터
  Map<String, dynamic>? data;
  /// 로딩 상태
  bool isLoading = true;
  /// 에러 메시지
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final result = await v7api('module.action', debug: true);
      if (!mounted) return;
      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const CircularProgressIndicator();
    if (errorMessage != null) return Text('에러: $errorMessage');
    if (data == null) return const SizedBox.shrink();

    return Text('결과: ${data!['field_name']}');
  }
}
```

### 7.2 실전 예제: user.me 호출

`company.qr_code_scanned.screen.dart`에서 실제 사용하는 패턴:

```dart
import 'package:philgo/v7_api/v7_api.dart';

class _CompanyQrCodeScannedScreenState extends State<CompanyQrCodeScannedScreen> {
  /// v7 API로 가져온 현재 로그인 사용자 정보
  Map<String, dynamic>? userInfo;
  bool isUserLoading = true;
  String? userErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompany();     // v6 API (기존)
    _loadUserInfo();    // v7 API (신규) — 병렬 호출
  }

  /// v7 API로 현재 로그인 사용자 정보를 가져온다
  Future<void> _loadUserInfo() async {
    try {
      final result = await v7api('user.me', debug: true);
      if (!mounted) return;
      setState(() {
        userInfo = result;
        isUserLoading = false;
      });
    } catch (e) {
      debugLog('v7api user.me 에러: $e');
      if (!mounted) return;
      setState(() {
        userErrorMessage = e.toString();
        isUserLoading = false;
      });
    }
  }
}
```

### 7.3 UI 렌더링 패턴

v7api 응답 데이터를 화면에 표시하는 위젯 구조:

```dart
Widget _buildUserInfoSection(ColorScheme scheme, ThemeData theme) {
  /// 로딩 중
  if (isUserLoading) {
    return Row(
      children: [
        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5)),
        const SizedBox(width: 8),
        Text('사용자 정보 로딩 중...'),
      ],
    );
  }

  /// 에러 발생
  if (userErrorMessage != null) {
    return Row(
      children: [
        FaIcon(FontAwesomeIcons.triangleExclamation, color: scheme.error),
        Expanded(child: Text('사용자 정보를 가져올 수 없습니다.')),
        GestureDetector(
          onTap: () {
            setState(() { isUserLoading = true; userErrorMessage = null; });
            _loadUserInfo();  // 재시도
          },
          child: FaIcon(FontAwesomeIcons.arrowsRotate),
        ),
      ],
    );
  }

  /// 데이터 없음
  if (userInfo == null) return const SizedBox.shrink();

  /// 성공: 응답 데이터에서 필드 추출
  final name = userInfo!['name']?.toString() ?? '';
  final nickname = userInfo!['nickname']?.toString() ?? '';
  final id = userInfo!['id']?.toString() ?? '';
  final phoneNumber = userInfo!['phone_number']?.toString() ?? '';

  /// 표시할 이름 결정: name > nickname > id 우선순위
  final displayName = name.isNotEmpty ? name
      : nickname.isNotEmpty ? nickname
      : id;

  return Row(
    children: [
      FaIcon(FontAwesomeIcons.solidUser, size: 16, color: scheme.primary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName, style: theme.textTheme.titleSmall),
            if (id.isNotEmpty || phoneNumber.isNotEmpty)
              Text(
                [if (id.isNotEmpty) id, if (phoneNumber.isNotEmpty) phoneNumber].join(' · '),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    ],
  );
}
```

### 7.4 추가 데이터 전송 패턴

v7api에 커스텀 데이터를 전달하는 패턴:

```dart
// 추가 파라미터 전달
final result = await v7api(
  'post.create',
  data: {
    'title': '제목',
    'content': '내용',
    'post_id': 'freetalk',
  },
  debug: true,
);
print('생성된 글 idx: ${result['idx']}');
```

---

## 8. v7 서버 응답 형식

### 성공 응답

Controller 리턴값 그대로 JSON 출력. `success: true` 래핑 **없음**:

```json
// user.count → {"count": 188186}
// user.me → {"idx": 123, "id": "user@test.com", "name": "홍길동", ...}
```

### 에러 응답

`RuntimeException` throw → api.php catch → `{success: false}`:

```json
{"success": false, "message": "로그인이 필요합니다."}
{"success": false, "message": "method 파라미터가 필요합니다."}
```

### user.me 응답 필드 (sf_member 테이블, password 제외)

```json
{
    "idx": 123,
    "id": "user@test.com",
    "name": "홍길동",
    "nickname": "닉네임",
    "phone_number": "+821012345678",
    "firebase_uid": "abc123...",
    "stamp": 1700000000
}
```

### user.count 응답 필드

```json
{"count": 188186}
```

---

## 9. 인증 흐름 (Flutter → v7 서버)

Flutter 앱은 항상 **Firebase ID Token 기반 인증** (경로 2)을 사용한다.

```
Flutter App
    ▼ v7api('user.me') 호출
    ▼ patchToken() → FirebaseAuth.instance.currentUser.getIdToken()
    ▼ HTTP POST body: {method: "user.me", id_token: "eyJhbGc..."}
    ▼
v7 서버 api.php
    ▼ AuthService::getLoginUser()
    ▼ [경로 2] id_token 파라미터 확인
    ▼ FirebaseService::verifyIdToken($idToken)
    ▼ Firebase UID 획득 → "RaHIcr45pvPzYdcDIv6JoW8DnSH2"
    ▼ SELECT * FROM sf_member WHERE firebase_uid = ?
    ▼ 사용자 레코드 반환 (password 필드 제거)
    ▼
JSON 응답: {"idx": 123, "id": "...", "name": "...", ...}
```

### 비로그인 상태

`patchToken()`이 `auth.currentUser == null`일 때 `id_token`을 추가하지 않음.
서버에서 `AuthService::getLoginUser()` → `null` → `RuntimeException('로그인이 필요합니다.')`:

```json
{"success": false, "message": "로그인이 필요합니다."}
```

### 인증 불필요 API

`user.count`처럼 인증이 필요 없는 API는 비로그인 상태에서도 정상 동작:

```dart
// 로그인하지 않아도 호출 가능
final result = await v7api('user.count');
print(result['count']);  // 188186
```

---

## 10. 파일 위치 참조

### Flutter 앱 측

| 파일 | 경로 | 설명 |
|------|------|------|
| **v7api(), v7apiFileUpload()** | `lib/v7_api/v7_api.dart` | v7 API 호출 + 파일 업로드 함수 |
| **ApiService** | `lib/api/api.service.dart` | 핵심 구현 (v7api, fileUpload, fileDelete) |
| **FileUploadModel** | `lib/file/upload/file_upload.model.dart` | 업로드 응답 데이터 모델 |
| **FileUpload (V7FileUpload)** | `lib/file/upload/widgets/file_upload.dart` | 파일 업로드 위젯 (실제 구현) |
| **V7FileUpload (별칭)** | `lib/v7_api/widgets/upload/v7_file_upload.dart` | FileUpload의 v7_api 경로 별칭 |
| func() 함수 | `packages/philgo_api/lib/src/philgo/philgo.api.functions.dart` | v6 API 호출 함수 (패키지) |
| v7ApiEndpoint 설정 | `lib/app.config.dart` | v7ApiEndpoint, v7BaseUrl 상수 |
| 사용 예시 | `lib/company/edit/widgets/form/form.image.upload.dart` | FileUpload 실전 활용 예제 |

### v7 서버 측

| 파일 | 경로 | 설명 |
|------|------|------|
| api.php | `api.php` | v7 API 엔트리포인트 |
| UserController | `lib/user/UserController.php` | User 모듈 Controller |
| UserService | `lib/user/UserService.php` | User 모듈 Service |
| AuthService | `lib/utils/AuthService.php` | 2경로 인증 (세션 + Firebase) |
| FirebaseService | `lib/utils/FirebaseService.php` | Firebase ID Token 검증 |

### v7 스킬 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| User API | `references/api/user.md` | user.count, user.me API 명세 |
| Upload API | `references/api/upload.md` | 파일 업로드 API 명세 |
| 아키텍처 | `references/architecture.md` | v7 시스템 전체 아키텍처 |

---

## 11. v7apiFileUpload() 파일 업로드 함수

v7 서버(api.php)에 multipart/form-data로 파일을 업로드하는 전용 함수.
웹의 `v7apiUpload()`와 동일하게 **백엔드 서버에 업로드**한다. Firebase Storage는 사용하지 않는다.

> **🔴 Firebase Storage 사용 금지**: `lib/storage/storage.functions.dart`의 `uploadImage()` 등
> Firebase Storage 직접 업로드 함수는 절대로 사용하지 않는다.
> 모든 파일 업로드는 반드시 이 함수(백엔드 api.php)를 통해야 한다.

### 11.1 함수 시그니처

```dart
import 'package:philgo/v7_api/v7_api.dart';

Future<FileUploadModel> v7apiFileUpload({
  required String filePath,
  String? module,
  String? code,
  Map<String, dynamic>? extraData,
  void Function(double progress)? onProgress,
}) async
```

**실제 구현 위치**: `lib/v7_api/v7_api.dart` → `ApiService.instance.fileUpload()` 위임
**핵심 구현**: `lib/api/api.service.dart` → `ApiService.fileUpload()`

### 11.2 매개변수

| 매개변수 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|-------|------|
| `filePath` | `String` | ✅ | — | 업로드할 로컬 파일 경로 |
| `module` | `String?` | ❌ | `null` | 모듈명 분류 (예: `'company'`, `'post'`, `'user'`) |
| `code` | `String?` | ❌ | `null` | 코드 분류 (모듈 내 세부 분류, 예: `'main_photo'`, `'gallery'`) |
| `extraData` | `Map<String, dynamic>?` | ❌ | `null` | FormData에 추가할 임의 필드 |
| `onProgress` | `void Function(double)?` | ❌ | `null` | 업로드 진행률 콜백 (0.0 ~ 1.0) |

> **인증**: `idxMember` 파라미터 불필요. Firebase ID Token이 자동으로 첨부된다.

### 11.3 반환값 (FileUploadModel)

성공 시 `FileUploadModel` 반환 (`lib/file/upload/file_upload.model.dart`):

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx` | `int` | 업로드 파일 고유 번호 |
| `idxMember` | `int` | 업로드한 회원번호 |
| `name` | `String` | 원본 파일명 |
| `size` | `int` | 파일 크기 (bytes) |
| `type` | `String` | MIME 타입 (예: `image/webp`) |
| `module` | `String` | 모듈 분류 |
| `code` | `String` | 코드 분류 |
| `url` | `String` | 파일 full URL (도메인 포함, 자동 변환) |
| `thumbnail400x400Url` | `String` | 400×400 썸네일 URL |
| `thumbnail800x800Url` | `String` | 800×800 썸네일 URL |
| `thumbnail1000Url` | `String` | 1000px 너비 썸네일 URL |
| `path` | `String` (getter) | 상대경로 (예: `/uploads/123/abc.webp`) |
| `isImage` | `bool` (getter) | MIME 타입 기반 이미지 여부 |
| `isVideo` | `bool` (getter) | MIME 타입 기반 영상 여부 |

> **URL**: `FileUploadModel.url`은 이미 full URL이다 (도메인 prefix 불필요).
> 서버 응답의 상대경로를 `v7BaseUrl` 기반으로 자동 변환한다.

에러 시 `ApiException` throw.

### 11.4 사용 예시

```dart
import 'package:philgo/v7_api/v7_api.dart';

// 기본 업로드
final model = await v7apiFileUpload(
  filePath: '/path/to/receipt.jpg',
  module: 'company',
  code: 'main_photo',
);
print(model.url);   // https://philgo.com/uploads/123/abc.webp (full URL)
print(model.path);  // /uploads/123/abc.webp (상대경로)

// 진행률 추적 업로드
final model = await v7apiFileUpload(
  filePath: photo.path,
  module: 'post',
  onProgress: (progress) {
    setState(() => uploadProgress = progress);
    debugPrint('${(progress * 100).toInt()}%');
  },
);
```

### 11.5 v7api()와의 차이점

| 항목 | v7api() | v7apiFileUpload() |
|------|---------|-------------------|
| **Content-Type** | `application/x-www-form-urlencoded` | `multipart/form-data` |
| **데이터 형식** | `Map<String, dynamic>` (JSON) | `FormData` + `MultipartFile` |
| **method 전달** | `data['method'] = method` | `FormData` 내 `method: 'upload.upload'` 고정 |
| **id_token** | `_patchToken(data)` 자동 | Firebase ID Token → FormData에 자동 추가 |
| **진행률** | 지원 안함 | `onSendProgress` 콜백 지원 |
| **반환값** | `Map<String, dynamic>` | `FileUploadModel` (타입 안전) |
| **용도** | 일반 API 호출 | 파일 업로드 전용 |
| **저장소** | — | 백엔드 서버 (Firebase Storage 아님) |

---

## 12. V7FileUpload 위젯 (재활용 필수)

### 12.1 개요 및 재활용 원칙

> **⚠️⚠️⚠️ 재활용 필수 원칙 ⚠️⚠️⚠️**
>
> v7 시스템에서 파일 업로드가 필요한 **모든 곳**에서 이 위젯을 재활용해야 한다.
> **절대로 새로운 업로드 위젯을 만들지 말 것.** 기존 V7FileUpload 위젯의 옵션을 활용하여
> 영수증, 프로필 사진, 게시글 첨부, 문서 업로드 등 모든 파일 업로드 시나리오를 처리한다.
>
> **🔴 Firebase Storage 사용 금지**: `lib/storage/storage.functions.dart`의 Firebase 업로드 함수는 절대 사용하지 않는다.

**위치**: `lib/v7_api/widgets/upload/v7_file_upload.dart` (타입 별칭)
**실제 구현**: `lib/file/upload/widgets/file_upload.dart` (`FileUpload` 위젯)

```dart
// v7_file_upload.dart 에서 FileUpload를 V7FileUpload로 별칭 제공
import 'package:philgo/file/upload/widgets/file_upload.dart';
typedef V7FileUpload = FileUpload;
```

**역할**: child 위젯을 GestureDetector로 감싸서, 탭 시 Bottom Sheet로 업로드 옵션(카메라/갤러리/파일)을
표시하고, `ApiService.fileUpload()`를 호출하여 백엔드 서버(api.php)에 파일을 업로드한다.

**업로드 흐름**: 웹의 `v7apiUpload()`와 동일
- 웹: `v7apiUpload(file)` → `POST /api.php` (multipart/form-data)
- 앱: `V7FileUpload` → `ApiService.fileUpload()` → `POST /api.php` (multipart/form-data)

### 12.2 위젯 속성 (Props)

| 속성 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|-------|------|
| `child` | `Widget` | ✅ | — | 탭 가능한 자식 위젯 (버튼, 아바타, 아이콘 등) |
| `onUploaded` | `Function(FileUploadModel)?` | ❌ | `null` | 업로드 완료 콜백 (`FileUploadModel` 전달) |
| `onBeforeUpload` | `Future<bool> Function()?` | ❌ | `null` | 업로드 시작 전 콜백 (false 반환 시 취소) |
| `onCancelled` | `VoidCallback?` | ❌ | `null` | 업로드 취소 시 콜백 |
| `onProgress` | `void Function(double)?` | ❌ | `null` | 진행률 콜백 (0.0 ~ 1.0) |
| `onError` | `void Function(dynamic)?` | ❌ | `null` | 에러 콜백 |
| `onUploadingChanged` | `void Function(bool)?` | ❌ | `null` | 업로드 상태 변경 콜백 (true=업로드 중) |
| `module` | `String?` | ❌ | `null` | 모듈명 분류 (예: `'company'`, `'post'`, `'user'`) |
| `code` | `String?` | ❌ | `null` | 코드 분류 (예: `'main_photo'`, `'gallery'`) |
| `extraData` | `Map<String, dynamic>?` | ❌ | `null` | FormData에 추가할 임의 필드 |
| `camera` | `bool` | ❌ | `true` | 카메라 사진 소스 활성화 |
| `cameraVideo` | `bool` | ❌ | `false` | 카메라 동영상 소스 활성화 |
| `gallery` | `bool` | ❌ | `true` | 갤러리 소스 활성화 |
| `galleryVideo` | `bool` | ❌ | `false` | 갤러리에서 동영상도 선택 가능 |
| `file` | `bool` | ❌ | `false` | 파일 피커 소스 활성화 |
| `imageQuality` | `int` | ❌ | `85` | 이미지 압축 품질 (0~100) |
| `maxWidth` | `double?` | ❌ | `null` | 이미지 최대 너비 (픽셀) |
| `maxHeight` | `double?` | ❌ | `null` | 이미지 최대 높이 (픽셀) |

> **인증**: `idxMember` 파라미터 불필요. Firebase ID Token이 자동으로 첨부된다.

### 12.3 사용 예시

#### (1) 회사 메인 사진 업로드 (카메라 + 갤러리)

```dart
import 'package:philgo/v7_api/widgets/upload/v7_file_upload.dart';

V7FileUpload(
  module: 'company',
  code: 'main_photo',
  onUploaded: (model) {
    setState(() => photoUrl = model.url);
  },
  onProgress: (progress) {
    setState(() => uploadProgress = progress);
  },
  child: FaIcon(FontAwesomeIcons.lightCamera, size: 32),
)
```

#### (2) 프로필 사진 업로드 (카메라만, 크기 제한)

```dart
V7FileUpload(
  module: 'user',
  code: 'profile_photo',
  gallery: false,
  maxWidth: 512,
  maxHeight: 512,
  imageQuality: 70,
  onUploaded: (model) => updateProfilePhoto(model.url),
  child: CircleAvatar(radius: 40, child: FaIcon(FontAwesomeIcons.lightCamera)),
)
```

#### (3) 게시글 첨부파일 (이미지 + 동영상 + 파일)

```dart
V7FileUpload(
  module: 'post',
  code: 'freetalk',
  cameraVideo: true,
  galleryVideo: true,
  file: true,
  onUploaded: (model) => addAttachment(model),
  child: FaIcon(FontAwesomeIcons.lightPaperclip),
)
```

#### (4) 갤러리에서만 이미지 선택

```dart
V7FileUpload(
  module: 'gallery',
  camera: false,
  onUploaded: (model) => addToGallery(model.url),
  child: const Text('사진 선택'),
)
```

### 12.4 실전 통합 패턴: 업로드 상태 관리

```dart
import 'package:philgo/v7_api/widgets/upload/v7_file_upload.dart';
import 'package:philgo/file/upload/file_upload.model.dart';

class _MyScreenState extends State<MyScreen> {
  FileUploadModel? _uploadedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 업로드 결과 표시 (FileUploadModel 사용)
        if (_uploadedFile != null) ...[
          Image.network(_uploadedFile!.url),  // full URL — 도메인 prefix 불필요
          Text('파일명: ${_uploadedFile!.name}'),
          Text('크기: ${_uploadedFile!.size} bytes'),
          Text('타입: ${_uploadedFile!.type}'),
        ],

        // 업로드 버튼
        V7FileUpload(
          module: 'company',
          code: 'main_photo',
          onBeforeUpload: () async {
            setState(() { _isUploading = true; _uploadProgress = 0.0; });
            return true; // false 반환 시 업로드 취소
          },
          onProgress: (p) => setState(() => _uploadProgress = p),
          onUploaded: (model) => setState(() {
            _uploadedFile = model;
            _isUploading = false;
          }),
          onError: (_) => setState(() => _isUploading = false),
          onCancelled: () => setState(() => _isUploading = false),
          child: FilledButton.icon(
            onPressed: () {},
            icon: _isUploading
                ? SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                    ),
                  )
                : FaIcon(FontAwesomeIcons.lightCloudArrowUp, size: 18),
            label: Text(_isUploading
                ? '업로드 중... ${(_uploadProgress * 100).toInt()}%'
                : '사진 업로드'),
          ),
        ),
      ],
    );
  }
}
```

### 12.5 동작 원리

```
사용자 탭 → GestureDetector.onTap
    ▼
Bottom Sheet 표시 (카메라/갤러리/파일/취소)
    ▼ 옵션 선택
ImagePicker 또는 FilePicker 실행
    ▼ 파일 선택 완료
onBeforeUpload() 콜백 (false 반환 시 취소)
    ▼
ApiService.fileUpload(filePath, module, code, ...)
    → POST /api.php (multipart/form-data, method=upload.upload)
    ▼ onSendProgress → onProgress() 콜백
    ▼
업로드 완료 → FileUploadModel.fromJson(response)
    → onUploaded(FileUploadModel) 콜백
    또는
업로드 에러 → onError(error) 콜백
```

> **주의**: `onBeforeUpload`는 `Future<bool>`을 반환해야 한다. `false` 반환 시 업로드가 취소된다.

---

## 13. v7 위젯 목록

v7 시스템에서 제공하는 Flutter 위젯 및 함수 목록.
**새 기능 개발 시 기존 위젯/함수를 반드시 재활용**하고, 중복 생성하지 말 것.

### 13.1 API 호출 함수

| 함수 | 파일 | 용도 | 재활용 |
|------|------|------|--------|
| `v7api()` | `lib/v7_api/v7_api.dart` | v7 일반 API 호출 (JSON POST) | ✅ 필수 |
| `v7apiFileUpload()` | `lib/v7_api/v7_api.dart` | v7 파일 업로드 (multipart/form-data) | ✅ 필수 |

### 13.2 페이지네이션 위젯

| 위젯 | 파일 | 용도 | 재활용 |
|------|------|------|--------|
| `ApiListView<T>` | `lib/v7_api/widgets/api_list_view/api_list_view.dart` | v7 API 무한 스크롤 리스트 (infinite_scroll_pagination encapsulation) | ✅ **필수** — v7 API 페이지네이션 목록에 이 위젯 사용 |

### 13.3 업로드 위젯

| 위젯 | 파일 | 용도 | 재활용 |
|------|------|------|--------|
| `V7FileUpload` | `lib/v7_api/widgets/upload/v7_file_upload.dart` (→ `lib/file/upload/widgets/file_upload.dart`) | 백엔드 파일 업로드 (카메라/갤러리/파일, Firebase Storage 아님) | ✅ **필수** — 모든 v7 업로드에 이 위젯 사용 |

### 13.4 사용 중인 화면

| 화면 | 파일 | v7 기능 |
|------|------|---------|
| QR 코드 스캔 결과 | `lib/screens/company/company.qr_code_scanned.screen.dart` | `UserApi.me()` + `CompanyApi.get()` + `V7FileUpload` (영수증) |
| 업소록 폼 | `lib/screens/company/company.form.screen.dart` | `CompanyApi.getReceiptName()` + `CompanyApi.updateReceiptName()` |
| 포인트 내역 | `lib/v7_api/widgets/point/point_history.screen.dart` | `PointLogApi.history()` + `ApiListView` (무한 스크롤) |

> 새 화면에서 v7 API를 사용할 때 이 목록을 업데이트한다.

---

## 14. 모듈별 API 클래스 (권장 패턴)

### 14.1 개요 및 원칙

v7 API 호출 시 `v7api('module.action')` 직접 호출 대신,
**모듈별 API 클래스의 static 메서드**를 사용하는 것을 권장한다.

**장점**:
- 일관된 인터페이스: `CompanyApi.get()`, `UserApi.me()`, `UploadApi.list()`
- IDE 자동완성 지원: 클래스명 입력 시 사용 가능한 메서드 목록 표시
- 응답 파싱 캡슐화: 모델 변환, 에러 처리를 클래스 내부에서 처리
- 중앙 관리: API 변경 시 한 곳만 수정

**규칙**:
- 모든 API 클래스는 `lib/v7_api/` 폴더에 `{module}_api.dart` 파일로 생성
- `private constructor` (`ClassName._()`)로 인스턴스화 방지
- 모든 메서드는 `static`
- 내부에서 `v7api()` 또는 `v7apiFileUpload()`를 호출

```
lib/v7_api/
├── v7_api.dart          ← 핵심 함수: v7api(), v7apiFileUpload()
├── company_api.dart     ← CompanyApi 클래스
├── user_api.dart        ← UserApi 클래스
├── upload_api.dart      ← UploadApi 클래스
├── point_log_api.dart   ← PointLogApi 클래스
└── widgets/
    ├── api_list_view/
    │   └── api_list_view.dart  ← ApiListView<T> 무한 스크롤 위젯
    ├── point/
    │   └── point_history.screen.dart  ← 포인트 내역 화면
    └── upload/
        └── v7_file_upload.dart  ← V7FileUpload 위젯
```

### 14.2 CompanyApi

**파일**: `lib/v7_api/company_api.dart`

| 메서드 | API 엔드포인트 | 인증 | 반환 타입 | 설명 |
|--------|---------------|------|----------|------|
| `CompanyApi.list()` | `company.list` | 불필요 | `CompanyList` | 업소 목록 조회 |
| `CompanyApi.get(idx)` | `company.get` | 불필요 | `Company` | 업소 단건 조회 |
| `CompanyApi.mine()` | `company.mine` | 필수 | `Company` | 내 업소 조회 (없으면 자동 생성) |
| `CompanyApi.create()` | `company.create` | 필수 | `Company` | 업소 생성 |
| `CompanyApi.update(data)` | `company.update` | 필수 | `Company` | 업소 수정 |
| `CompanyApi.getReceiptName(idx)` | `company_meta.get` | 불필요 | `String` | 영수증 표시 업소명 조회 |
| `CompanyApi.updateReceiptName(idx, name)` | `company_meta.update` | 필수 | `void` | 영수증 표시 업소명 저장 |

```dart
import 'package:philgo/v7_api/company_api.dart';

// 업소 목록 조회
final companies = await CompanyApi.list(category: 'food');

// 업소 단건 조회
final company = await CompanyApi.get(123);

// 내 업소 조회
final myCompany = await CompanyApi.mine();

// 업소 수정
final updated = await CompanyApi.update({'idx': 123, 'name': '새 이름'});

// 영수증 표시 업소명 조회/저장
final receiptName = await CompanyApi.getReceiptName(123);
await CompanyApi.updateReceiptName(123, 'ABC Store');
```

### 14.3 UserApi

**파일**: `lib/v7_api/user_api.dart`

| 메서드 | API 엔드포인트 | 인증 | 반환 타입 | 설명 |
|--------|---------------|------|----------|------|
| `UserApi.me()` | `user.me` | 필수 | `Map<String, dynamic>` | 현재 로그인 사용자 정보 |
| `UserApi.count()` | `user.count` | 불필요 | `int` | 총 사용자 수 |

```dart
import 'package:philgo/v7_api/user_api.dart';

// 현재 로그인 사용자 정보 조회
final user = await UserApi.me();
print(user['name']);        // 홍길동
print(user['idx']);          // 123
print(user['phone_number']); // +821012345678

// 총 사용자 수 조회
final total = await UserApi.count();
print(total); // 188186
```

### 14.4 UploadApi

**파일**: `lib/v7_api/upload_api.dart`

| 메서드 | API 엔드포인트 | 인증 | 반환 타입 | 설명 |
|--------|---------------|------|----------|------|
| `UploadApi.upload(...)` | `upload.upload` | 필수 | `Map<String, dynamic>` | 파일 업로드 (v7apiFileUpload 래퍼) |
| `UploadApi.get(idx)` | `upload.get` | 불필요 | `Map<String, dynamic>` | 파일 정보 단건 조회 |
| `UploadApi.list()` | `upload.list` | 필수 | `List<Map<String, dynamic>>` | 내 파일 목록 (페이지네이션) |
| `UploadApi.myFiles()` | `upload.myFiles` | 필수 | `List<Map<String, dynamic>>` | 내 전체 파일 목록 (최대 2,000개) |
| `UploadApi.delete(idx)` | `upload.delete` | 필수 | `bool` | 파일 삭제 (소유자 검증) |
| `UploadApi.updateAttached(idx)` | `upload.updateAttached` | 필수 | `bool` | attached 상태 변경 |

```dart
import 'package:philgo/v7_api/upload_api.dart';

// 파일 업로드
final result = await UploadApi.upload(
  filePath: '/path/to/receipt.jpg',
  idxMember: '123',
  module: 'receipt',
);
print(result['url']); // /uploads/123/unique_file.jpg

// 내 전체 파일 목록 조회 (최대 2,000개)
final allFiles = await UploadApi.myFiles();
for (final file in allFiles) {
  print('${file['name']} - ${file['size']} bytes');
}

// 페이지네이션으로 목록 조회
final page = await UploadApi.list(limit: 20, offset: 0);

// 파일 삭제
await UploadApi.delete(42);

// attached 상태 변경
await UploadApi.updateAttached(42, attached: 1);
```

### 14.5 새 API 클래스 추가 가이드라인

새 v7 모듈이 추가되면 동일한 패턴으로 API 클래스를 생성한다:

```dart
// lib/v7_api/{module}_api.dart
import 'v7_api.dart';

/// v7 {모듈명} API 래퍼 클래스
class {Module}Api {
  {Module}Api._();

  /// {기능 설명}
  /// API 엔드포인트: {module}.{action}
  /// 인증: {필수/불필요}
  static Future<{반환타입}> {메서드명}({파라미터}) async {
    final result = await v7api('{module}.{action}', data: {...});
    return {파싱 결과};
  }
}
```

**네이밍 규칙**:
- 파일: `{module}_api.dart` (snake_case)
- 클래스: `{Module}Api` (PascalCase)
- 메서드: v7 API의 action 이름과 동일하게 (예: `user.me` → `UserApi.me()`)

---

## 15. ApiListView<T> 위젯 (재활용 필수)

### 15.1 개요 및 재활용 원칙

> **⚠️⚠️⚠️ 재활용 필수 원칙 ⚠️⚠️⚠️**
>
> v7 API에서 페이지네이션 목록을 표시하는 **모든 곳**에서 이 위젯을 재활용해야 한다.
> **절대로 수동 ScrollController + loadMore 패턴을 사용하지 말 것.**
> `infinite_scroll_pagination` 패키지를 직접 사용하지 말고 `ApiListView<T>`를 통해 사용한다.

> **🔴🔴🔴 데이터 모델 클래스 필수 사용 — 절대 규칙 🔴🔴🔴**
>
> `ApiListView<T>`의 제네릭 타입 `T`에 **`Map<String, dynamic>`을 절대로 사용하지 않는다.**
> **반드시 데이터 모델 클래스를 만들어서 사용해야 한다.**
>
> | 사용 | 예시 | 설명 |
> |------|------|------|
> | ❌ **절대 금지** | `ApiListView<Map<String, dynamic>>` | 타입 안전성 없음, 런타임 에러 위험 |
> | ✅ **필수** | `ApiListView<PointLog>` | 데이터 모델 클래스로 타입 안전하게 사용 |
> | ✅ **필수** | `ApiListView<Company>` | 데이터 모델 클래스로 타입 안전하게 사용 |
>
> **이유**:
> - `Map<String, dynamic>`은 컴파일 타임에 필드명 오타를 감지할 수 없다
> - IDE 자동완성이 작동하지 않아 생산성이 떨어진다
> - `log['point']` 같은 문자열 키 접근은 리팩토링에 취약하다
> - 데이터 모델 클래스의 `fromJson()` 팩토리에서 타입 변환을 캡슐화하여 안전하게 처리한다
>
> **데이터 모델 클래스 패턴** (`lib/v7_api/models/` 폴더에 생성):
> ```dart
> class PointLog {
>   final int idx;
>   final int point;
>   final String module;
>   // ...
>   const PointLog({required this.idx, required this.point, ...});
>   factory PointLog.fromJson(Map<String, dynamic> json) => PointLog(...);
> }
> ```
>
> **API 클래스에서 모델로 변환하여 반환**:
> ```dart
> static Future<List<PointLog>> history({int page = 1}) async {
>   final response = await v7api('pointLog.history', data: {'page': page});
>   final items = (response['items'] as List<dynamic>?) ?? [];
>   return items.whereType<Map<String, dynamic>>().map(PointLog.fromJson).toList();
> }
> ```

**위치**: `lib/v7_api/widgets/api_list_view/api_list_view.dart`

**역할**: `infinite_scroll_pagination` 패키지(`PagingController`, `PagingListener`, `PagedListView`)를
encapsulation하여 `fetchPage` 콜백과 `itemBuilder` 콜백만으로 무한 스크롤 리스트를 구현한다.

### 15.2 위젯 속성 (Props)

| 속성 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|-------|------|
| `fetchPage` | `Future<List<T>> Function(int page)` | ✅ | — | 페이지 번호(1부터)를 받아 아이템 리스트를 반환하는 콜백 |
| `itemBuilder` | `Widget Function(BuildContext, T, int)` | ✅ | — | 각 아이템을 위젯으로 빌드하는 콜백 |
| `separatorBuilder` | `Widget Function(BuildContext, int)?` | ❌ | `null` | 아이템 사이 구분자 위젯 빌더 |
| `noItemsBuilder` | `WidgetBuilder?` | ❌ | `null` | 아이템이 없을 때 표시할 위젯 빌더 |
| `errorBuilder` | `Widget Function(BuildContext, String, VoidCallback)?` | ❌ | `null` | 첫 페이지 에러 시 표시 (error 문자열 + retry 콜백) |
| `firstPageProgressBuilder` | `WidgetBuilder?` | ❌ | `CircularProgressIndicator` | 첫 페이지 로딩 인디케이터 |
| `newPageProgressBuilder` | `WidgetBuilder?` | ❌ | `CircularProgressIndicator` | 다음 페이지 로딩 인디케이터 |
| `padding` | `EdgeInsetsGeometry?` | ❌ | `null` | 리스트 패딩 |

### 15.3 사용 예시

#### (1) 기본 사용 — 포인트 히스토리 (데이터 모델 클래스 필수)

```dart
import 'package:philgo/v7_api/widgets/api_list_view/api_list_view.dart';
import 'package:philgo/v7_api/models/v7_point_log_model.dart';
import 'package:philgo/v7_api/point_log_api.dart';

// ✅ 데이터 모델 클래스(PointLog)를 제네릭 타입으로 사용
ApiListView<PointLog>(
  padding: const EdgeInsets.all(16),
  separatorBuilder: (_, _) => const SizedBox(height: 4),
  fetchPage: (page) => PointLogApi.history(page: page, limit: 20),
  noItemsBuilder: (context) => const Center(child: Text('No data')),
  errorBuilder: (context, error, retry) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(error),
        FilledButton(onPressed: retry, child: const Text('Retry')),
      ],
    ),
  ),
  itemBuilder: (context, log, index) {
    // ✅ 타입 안전한 속성 접근 — IDE 자동완성 지원
    return ListTile(
      title: Text('${log.module}/${log.action}'),
      trailing: Text('${log.isPositive ? '+' : ''}${log.point}P'),
    );
  },
)
```

#### (2) 외부에서 새로고침

```dart
final _listKey = GlobalKey<ApiListViewState<PointLog>>();

// 위젯에 key 전달
ApiListView<PointLog>(
  key: _listKey,
  fetchPage: (page) => PointLogApi.history(page: page, limit: 20),
  itemBuilder: (context, log, index) => ListTile(title: Text(log.module)),
)

// 외부에서 새로고침 호출
_listKey.currentState?.refresh();
```

### 15.4 동작 원리

```
ApiListView 초기화
    ▼ PagingController 생성 (getNextPageKey + fetchPage)
    ▼
PagingListener가 상태 변화 감지
    ▼
fetchPage(1) 호출 → widget.fetchPage(1) → List<T> 반환
    ▼
PagedListView가 아이템 렌더링 (widget.itemBuilder)
    ▼
스크롤이 바닥에 도달
    ▼
fetchPage(2) 자동 호출 → 다음 페이지 아이템 추가
    ▼ ...반복...
fetchPage(N) → 빈 리스트 반환 → 더 이상 로드하지 않음
```

**페이지네이션 종료 조건**: `fetchPage`가 빈 리스트(`[]`)를 반환하면
`PagingController`의 `lastPageIsEmpty` 판별에 의해 자동 종료된다.

### 15.5 기존 수동 방식과의 비교

| 항목 | 수동 ScrollController | ApiListView<T> |
|------|----------------------|----------------|
| **코드량** | ~80줄 (상태변수 + 리스너 + loadMore) | ~10줄 (fetchPage + itemBuilder) |
| **상태 관리** | _isLoading, _hasMore, _currentPage, _logs 수동 관리 | PagingController가 자동 관리 |
| **에러 처리** | 직접 try-catch + setState | errorBuilder 콜백으로 선언적 처리 |
| **빈 상태** | 직접 분기 처리 | noItemsBuilder 콜백 |
| **새로고침** | 상태 초기화 + 재호출 | `refresh()` 한 줄 |

---

## 부록: debug 로그 출력 예시

`debug: true` 설정 시 `dart:developer` log 출력:

```
// 정상 호출
[v7api::user.me] v7 GET URL: https://philgo.com/api.php?method=user.me&id_token=eyJhbGci...

// DioException 발생 시
[v7API:ERROR] ========== v7 API 에러 발생 ==========
[v7API:ERROR] method: user.me
[v7API:ERROR] 요청 데이터: {method: user.me, id_token: eyJhbGci...}
[v7API:ERROR] 요청 URL: https://philgo.com/api.php
[v7API:ERROR] 에러 타입: DioExceptionType.connectionTimeout
[v7API:ERROR] 에러 메시지: The connection errored: Connection timed out
[v7API:ERROR] ==========================================
```

---

## 14. PostService — 게시글 API 서비스

### 14.1 위치

`lib/post/post.service.dart`

### 14.2 모델

`lib/post/post.model.dart` — Post 데이터 모델 (v7 PostEntity 기반, fromJson 팩토리)

### 14.3 메서드

| 메서드 | API | 인증 | 설명 |
|--------|-----|------|------|
| `PostService.list()` | `post.list` | 불필요 | 게시글 목록 (postId, category, orderby, limit, offset) |
| `PostService.get()` | `post.get` | 불필요 | 단건 조회 |
| `PostService.create()` | `post.create` | 필수 | 게시글 생성 |
| `PostService.update()` | `post.update` | 필수 | 게시글 수정 |
| `PostService.delete()` | `post.delete` | 필수 | 게시글 삭제 |
| `PostService.listComments()` | `post.commentList` | 불필요 | 코멘트 목록 조회 (list_order DESC) |
| `PostService.createComment()` | `post.commentCreate` | 필수 | 코멘트/대댓글 생성 (idxRoot, content, idxParent?) |
| `PostService.updateComment()` | `post.commentUpdate` | 필수 | 코멘트 수정 (자식 있으면 서버에서 차단) |
| `PostService.deleteComment()` | `post.commentDelete` | 필수 | 코멘트 삭제 (자식 있으면 서버에서 차단) |
| `PostService.like()` | `post.like` | 필수 | 좋아요 토글 |

### 14.4 사용 예시

```dart
// 게시글 목록 조회
final result = await PostService.list(postId: 'freetalk', limit: 20, offset: 0);
print('${result.posts.length}개 / 전체 ${result.total}개');

// 단건 조회
final post = await PostService.get(12345);
print(post.subject);
```

### 14.5 댓글 CRUD 사용 예시

```dart
// 댓글 목록 조회
final comments = await PostService.listComments(postIdx);

// 최상위 댓글 생성
await PostService.createComment(idxRoot: postIdx, content: '댓글 내용');

// 대댓글 생성 (특정 댓글에 대한 답글)
await PostService.createComment(
  idxRoot: postIdx,
  content: '대댓글 내용',
  idxParent: parentCommentIdx,
);

// 댓글 수정 (자식 댓글이 있으면 서버에서 에러 반환)
await PostService.updateComment(idx: commentIdx, content: '수정된 내용');

// 댓글 삭제 (자식 댓글이 있으면 서버에서 에러 반환)
await PostService.deleteComment(commentIdx);
```

### 14.6 댓글 위젯 구조

| 위젯 | 파일 | 설명 |
|------|------|------|
| `CommentListView` | `lib/post/view/widgets/comment.list.view.dart` | 댓글 목록 + 최상위 댓글 입력 + 대댓글 인라인 입력 |
| `CommentTile` | `lib/post/view/widgets/comment.tile.dart` | 개별 댓글 표시 (depth 기반 들여쓰기, 수정/삭제/답글 버튼) |
| `CommentInput` | `lib/post/view/widgets/comment.input.dart` | 댓글/대댓글 입력 폼 (TextField + 전송 버튼) |
| `CommentEditDialog` | `lib/post/view/widgets/comment.edit.dialog.dart` | 댓글 수정 다이얼로그 (AlertDialog) |

**자식 댓글 제한 규칙**:
- 자식 댓글이 있는 코멘트는 수정/삭제 버튼이 숨겨진다 (클라이언트 측 `_hasChildren()` 검사)
- 서버에서도 `PostRepository::hasChildComments()` 이중 검증으로 자식 있는 코멘트의 수정/삭제를 차단한다

### 14.7 PostListScreen 무한 스크롤 패턴

`lib/post/list/post.list.screen.dart`에서 `infinite_scroll_pagination` 패키지의
`PagingController<int, Post>`를 사용하여 카테고리별 게시글 무한 스크롤을 구현한다.
카테고리 변경 시 `_pagingController.refresh()`로 목록을 리프레시한다.

---

## 15. UserService — 사용자 인증 서비스

### 15.1 위치

`lib/user/user.service.dart`

### 15.2 메서드

| 메서드 | 설명 |
|--------|------|
| `UserService.signInWithEmailAndPassword()` | Firebase 이메일/비밀번호 로그인 (계정 없으면 자동 생성) |
| `UserService.signInWithGoogle()` | Google 소셜 로그인 + v7 user.socialLogin 등록 |
| `UserService.loadCurrentUser()` | v7 API(user.me)로 현재 사용자 데이터 로드 |
| `UserService.signOut()` | 로그아웃 |
| `UserService.currentUser` | 현재 로그인된 Firebase User |
| `UserService.isLoggedIn` | 로그인 여부 |

---

## 16. 🔴 State vs Service 아키텍처 — 절대 원칙 🔴

> **이 원칙은 모든 Flutter 앱 코드에 예외 없이 적용된다. 반드시 준수할 것.**

### 16.1 핵심 규칙

| 계층 | 역할 | 포함해야 할 것 | 포함하면 안 되는 것 |
|------|------|---------------|-------------------|
| **State 클래스** (ChangeNotifier) | 상태 저장 + UI 알림 | 필드 저장, `notifyListeners()`, Service 호출 | API 호출, 비즈니스 로직, 데이터 변환, 에러 처리 로직 |
| **Service 클래스** | API 호출 + 비즈니스 로직 | v7api() 호출, 데이터 변환, 에러 메시지 변환, 복잡한 로직 | UI 코드, BuildContext, setState, notifyListeners |
| **Screen/Widget** | UI 렌더링 + 사용자 입력 | 위젯 빌드, setState(로컬 UI 상태만), 네비게이션 | API 호출, 비즈니스 로직, 데이터 변환 |

### 16.2 State 클래스 작성 원칙

State 클래스는 **가능한 한 단순하고 짧게** 작성한다. 다음 패턴만 허용한다:

```dart
/// ✅ 올바른 State 클래스 — 최소한의 코드만 포함
class UserState extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  /// Service를 호출하고 결과만 저장한다.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await UserService.signInWithGoogle();
      return true;
    } catch (e) {
      _user = null;
      _error = ApiService.friendlyErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

```dart
/// ❌ 잘못된 State 클래스 — 로직이 State에 포함됨
class UserState extends ChangeNotifier {
  Future<void> signInWithGoogle() async {
    // ❌ State에서 직접 Google Sign-In API 호출
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(...);
    await FirebaseAuth.instance.signInWithCredential(credential);
    // ❌ State에서 직접 v7 API 호출
    final json = await ApiService.v7api('user.socialLogin', data: {...});
    // ❌ State에서 직접 데이터 변환
    _user = UserModel.fromJson(json);
    notifyListeners();
  }
}
```

### 16.3 Service 클래스 작성 원칙

**모든 복잡한 로직은 Service 클래스에 모은다.** 재사용 가능한 함수, API 호출, 데이터 변환, 에러 처리 등은 반드시 Service에 위치한다.

```dart
/// ✅ 올바른 Service 클래스 — 모든 로직을 Service에 집중
class UserService {
  /// Google 소셜 로그인 + v7 DB 등록
  static Future<UserModel> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google 로그인이 취소되었습니다.');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    final json = await ApiService.v7api('user.socialLogin', data: {'login_provider': 'google'});
    return UserModel.fromJson(json);
  }

  /// v7 API로 현재 사용자 데이터 로드
  static Future<UserModel?> loadCurrentUser() async {
    if (FirebaseAuth.instance.currentUser == null) return null;
    final json = await ApiService.v7api('user.me');
    return UserModel.fromJson(json);
  }
}
```

### 16.4 Screen에서의 호출 패턴

Screen은 **State를 통해 간접적으로** Service를 호출하고, UI 관련 처리만 담당한다.

```dart
/// ✅ 올바른 Screen — UI만 담당, 로직 없음
Future<void> _signInWithGoogle() async {
  setState(() => _loading = true);
  final userState = context.read<UserState>();
  final success = await userState.signInWithGoogle();
  if (!mounted) return;
  if (success) {
    context.pop();
  } else if (userState.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(userState.error!)),
    );
  }
  setState(() => _loading = false);
}
```

```dart
/// ❌ 잘못된 Screen — Screen에서 직접 Service 호출 및 에러 처리
Future<void> _signInWithGoogle() async {
  try {
    await UserService.signInWithGoogle();  // ❌ Screen에서 직접 Service 호출
    final json = await ApiService.v7api('user.me');  // ❌ Screen에서 직접 API 호출
    context.read<UserState>().setUser(UserModel.fromJson(json));  // ❌ Screen에서 데이터 변환
  } catch (e) {
    // ❌ Screen에서 복잡한 에러 처리
    if (e is DioException && e.response?.statusCode == 504) { ... }
  }
}
```

### 16.5 계층별 데이터 흐름 요약

```
[Screen] ──setState(로딩)──→ [State] ──Service 호출──→ [Service] ──v7api()──→ [서버]
                                                           ↓
[Screen] ←──UI 갱신──── [State] ←──결과 저장──── [Service] ←──응답──── [서버]
                         notifyListeners()         UserModel.fromJson()
```

**핵심**: State는 Service의 결과를 받아 저장만 한다. 복잡한 로직은 전부 Service에 있다.

---

## 17. Reddit 스타일 코멘트 스레드 라인 (Flutter 앱)

Reddit/Hacker News 스타일의 세로선(thread line)을 사용하여 코멘트의 부모-자식 관계를 시각적으로 표현하는 구현이다. 부모 아바타 중앙에서 세로선이 시작되어 자식 코멘트까지 L곡선으로 연결된다.

### 17.1 구조 개요

코멘트 스레드 라인은 4개의 핵심 구성요소로 이루어진다:

| 구성요소 | 파일 | 역할 |
|---------|------|------|
| **CommentListView** | `lib/post/view/widgets/comment.list.view.dart` | 트리 기반 코멘트 렌더링, 재귀적 노드 빌드 |
| **CommentTile** | `lib/post/view/widgets/comment.tile.dart` | 개별 코멘트 타일, 세로선 표시/미표시 분기 |
| **CommentNode** | `lib/post/view/widgets/comment_thread_painter.dart` | 트리 노드 (comment, children, depth 필드) |
| **ThreadConnectorPainter** | `lib/post/view/widgets/comment_thread_painter.dart` | CustomPaint 기반 세로선 + L곡선 페인터 |
| **buildCommentTree()** | `lib/post/view/widgets/comment_thread_painter.dart` | 플랫 리스트 → 트리 구조 변환 함수 |

### 17.2 위젯 계층 구조

```
CommentListView
├── _buildCommentTree()         ← 트리 루트 렌더링
│   └── _buildCommentNode()     ← 재귀적 노드 렌더링
│       ├── CommentTile         ← 개별 코멘트 (showThreadLine으로 세로선 분기)
│       │   ├── _buildWithThreadLine()  ← 자식 있는 노드: IntrinsicHeight + 세로선
│       │   └── _buildNormal()          ← 자식 없는 노드: 일반 레이아웃
│       └── _buildChildrenArea()        ← 자식 영역 (ThreadConnectorPainter 포함)
│           └── IntrinsicHeight > Row
│               ├── SizedBox + CustomPaint(ThreadConnectorPainter)  ← 세로선 + L곡선
│               └── Expanded > _buildCommentNode() (재귀)
```

**핵심 흐름**:
1. `CommentListView`가 `buildCommentTree()`로 플랫 리스트를 트리로 변환
2. 루트 노드부터 `_buildCommentNode()`를 재귀 호출
3. 자식이 있는 노드: `CommentTile(showThreadLine: true)` → 아바타 아래 세로선
4. 자식 영역: `_buildChildrenArea()`에서 `ThreadConnectorPainter`로 L곡선 연결
5. 각 자식에 대해 다시 `_buildCommentNode()` 재귀 호출

### 17.3 트리 변환: buildCommentTree()

서버에서 `depth`, `idxParent` 필드와 함께 플랫 리스트로 받은 코멘트를 트리 구조로 변환한다.

```dart
/// 플랫 코멘트 리스트를 트리 구조로 변환
List<CommentNode> buildCommentTree(List<Post> flatComments) {
  final Map<int, List<Post>> childrenMap = {};
  final List<Post> roots = [];

  for (final comment in flatComments) {
    if (comment.depth == 1) {
      roots.add(comment);
    } else {
      final parentIdx = comment.idxParent;
      childrenMap.putIfAbsent(parentIdx, () => []).add(comment);
    }
  }

  CommentNode buildNode(Post comment, {int nodeDepth = 1}) {
    final children = childrenMap[comment.idx] ?? [];
    return CommentNode(
      comment: comment,
      children: children.map((child) => buildNode(child, nodeDepth: nodeDepth + 1)).toList(),
      depth: nodeDepth,
    );
  }

  return roots.map((root) => buildNode(root, nodeDepth: 1)).toList();
}
```

**CommentNode 클래스**:
- `comment`: Post 모델 (코멘트 데이터)
- `children`: 자식 CommentNode 리스트
- `depth`: 트리에서의 깊이 (1부터 시작)

### 17.4 세로선 정렬 핵심 원리

세로선이 부모 아바타 중앙과 정확히 정렬되려면, **아바타 중앙 X 좌표**를 기준으로 맞춰야 한다.

```
아바타 중앙 X = _avatarRadius = 16px

┌─ paddingLeft ─┬── lineXOffset ──┐
│               │                 │
│               ↓                 │
│           lineX = paddingLeft + lineXOffset = 항상 16px (아바타 중앙)
```

**정렬 공식**:
```
lineXOffset = _avatarRadius - paddingLeft
실제 세로선 X = paddingLeft + lineXOffset = _avatarRadius = 16px (항상 일정)
```

**깊이별 동작**:

| 깊이 | paddingLeft | lineXOffset | 실제 세로선 X | 설명 |
|------|-------------|-------------|---------------|------|
| 1-2 | 16px | 0px | 16px | 정상 너비, 보정 불필요 |
| 3+ | 6px | 10px | 16px | 좁은 너비, lineXOffset으로 보정 |

### 17.5 ThreadConnectorPainter 상세

`CustomPainter`를 상속한 세로선 + L곡선 페인터이다.

```dart
ThreadConnectorPainter({
  required this.isLast,       // 마지막 자식 여부
  this.lineColor,             // 선 색상 (기본: Color(0xFF94A3B8))
  this.lineWidth,             // 선 굵기 (기본: 1.0, 실제 사용: 1.5)
  this.curveTargetY,          // 곡선 타겟 Y (기본: 24.0)
  this.curveRadius,           // 곡선 반경 (기본: 8.0)
  this.lineXOffset,           // X 오프셋 보정값 (기본: 0.0)
})
```

**그리기 로직**:

```
마지막이 아닌 자식 (isLast=false)     마지막 자식 (isLast=true)

│ (세로선: 0 → size.height)          │ (세로선: 0 → curveTargetY - curveRadius)
│                                    │
├── (L곡선 + 수평선)                  └── (L곡선 + 수평선)
│
│ (세로선 계속)
```

- **세로선**: `Offset(lx, 0)` → `Offset(lx, lineEndY)`
  - 마지막이 아닌 자식: `lineEndY = size.height` (전체 높이)
  - 마지막 자식: `lineEndY = curveTargetY - curveRadius` (곡선 시작점까지)
- **L곡선**: `quadraticBezierTo`로 세로에서 수평으로 자연스럽게 꺾임
  - 시작점: `(lx, curveTargetY - curveRadius)`
  - 제어점: `(lx, curveTargetY)`
  - 끝점: `(lx + curveRadius, curveTargetY)`
  - 이후 수평선: `(lx + curveRadius, curveTargetY)` → `(size.width, curveTargetY)`

**shouldRepaint 비교 필드**: `isLast`, `lineColor`, `lineXOffset`, `curveTargetY`

### 17.6 주요 상수 정리

```dart
// CommentListView (comment.list.view.dart)
static const _lineColor = Color(0xFF94A3B8);     // 세로선 색상
static const _avatarRadius = 16.0;                // 아바타 반지름
static const _commentTopPadding = 8.0;            // 코멘트 행 상단 패딩
static const _connectorWidth = 16.0;              // 커넥터 너비 (곡선 수평 길이)
static const _curveTargetY = _commentTopPadding + _avatarRadius;  // = 24.0 (자식 아바타 중앙 Y)

// CommentTile (comment.tile.dart)
const kThreadLineColor = Color(0xFF94A3B8);       // 전역 세로선 색상 상수
// 아바타 radius: 16, 세로선 Container width: 1.5

// ThreadConnectorPainter (comment_thread_painter.dart)
// lineWidth: 1.5 (L곡선 포함 모든 선)
// curveRadius: 8.0 (곡선 반경)
```

**선 굵기 통일**: 세로선(Container width)과 L곡선(ThreadConnectorPainter lineWidth) 모두 **1.5px**로 통일하여 시각적 일관성을 유지한다.

### 17.7 깊이별 들여쓰기 전략

깊이가 깊어질수록 화면 공간이 부족해지므로, 깊은 깊이에서는 들여쓰기를 줄이되 세로선은 정렬을 유지한다.

```dart
// _buildChildrenArea()에서의 깊이별 처리
final paddingLeft = parentNode.depth >= 3 ? 6.0 : _avatarRadius;  // 16.0
final lineXOffset = _avatarRadius - paddingLeft;

// 깊이 1-2: paddingLeft=16, lineXOffset=0  → 정상 들여쓰기
// 깊이 3+:  paddingLeft=6,  lineXOffset=10 → 좁은 들여쓰기 + 세로선 보정
```

**시각적 결과**:
```
depth 1: 코멘트 A
         │ (paddingLeft=16, 정상)
         └── depth 2: 코멘트 B
              │ (paddingLeft=16, 정상)
              └── depth 3: 코멘트 C
                 │ (paddingLeft=6, 좁게 + lineXOffset=10 보정)
                 └── depth 4: 코멘트 D
                    │ (paddingLeft=6, 좁게 + lineXOffset=10 보정)
                    └── depth 5+: ...
```

### 17.8 주의사항 및 트러블슈팅

1. **paddingLeft를 줄이면 반드시 lineXOffset으로 보정해야 세로선이 어긋나지 않음**
   - `lineXOffset = _avatarRadius - paddingLeft` 공식을 항상 적용
   - 보정하지 않으면 자식 영역의 세로선이 부모 아바타 중앙에서 벗어남

2. **ThreadConnectorPainter의 shouldRepaint에서 lineXOffset 비교 필수**
   - `lineXOffset`이 0이 아닌 값을 가질 수 있으므로, `shouldRepaint`에서 비교해야 정확한 리페인트 발생

3. **IntrinsicHeight 사용 주의**
   - `CommentTile._buildWithThreadLine()`과 `_buildChildrenArea()`에서 `IntrinsicHeight`를 사용하여 세로선이 코멘트 높이에 맞게 확장됨
   - `IntrinsicHeight`는 성능 비용이 있으므로, 대량 코멘트에서 성능 이슈 발생 시 고정 높이 방식으로 전환 고려

4. **CommentTile의 showThreadLine 분기**
   - `showThreadLine=true`: `_buildWithThreadLine()` → `IntrinsicHeight + Row(아바타+세로선 | 내용)` 구조
   - `showThreadLine=false`: `_buildNormal()` → 일반 `Row(아바타 | 내용)` 구조
   - 자식이 있는 노드만 세로선을 표시하므로, 외부에서 `hasChildren` 기반으로 결정

5. **색상 일관성**
   - `kThreadLineColor`(comment.tile.dart 전역 상수)와 `_lineColor`(CommentListView 내부 상수)가 동일한 `Color(0xFF94A3B8)` 값을 사용
   - 색상 변경 시 두 곳 모두 수정해야 함

### 17.9 파일 위치 참조

| 파일 | 경로 | 핵심 내용 |
|------|------|----------|
| 코멘트 목록 위젯 | `lib/post/view/widgets/comment.list.view.dart` | CommentListView, 트리 렌더링, 들여쓰기 전략 |
| 코멘트 타일 위젯 | `lib/post/view/widgets/comment.tile.dart` | CommentTile, 세로선 표시/미표시 분기 |
| 스레드 페인터 | `lib/post/view/widgets/comment_thread_painter.dart` | CommentNode, buildCommentTree(), ThreadConnectorPainter |
| 코멘트 입력 위젯 | `lib/post/view/widgets/comment.input.dart` | CommentInput (대댓글 입력 폼) |
| 포스트 모델 | `lib/post/post.model.dart` | Post (depth, idxParent 필드 포함) |
