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
| **v7api() 함수** | `lib/v7_api/v7_api.dart` | v7 API 호출 함수 (앱 레벨) |
| func() 함수 | `packages/philgo_api/lib/src/philgo/philgo.api.functions.dart` | v6 API 호출 함수 (패키지) |
| createDio() | `packages/philgo_api/lib/src/philgo/philgo.api.functions.dart:268` | Dio 인스턴스 생성 |
| patchToken() | `packages/philgo_api/lib/src/philgo/philgo.api.functions.dart:285` | Firebase ID Token 자동 추가 |
| PhilgoConfig | `packages/philgo_api/lib/src/philgo.config.dart` | v7ApiEndpoint 등 설정 상수 |
| 사용 예시 | `lib/screens/company/company.qr_code_scanned.screen.dart` | user.me 호출 실전 예제 |

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
`v7api()`는 JSON POST만 지원하므로, 파일 업로드는 반드시 이 함수를 사용해야 한다.

### 11.1 함수 시그니처

```dart
import 'package:philgo/v7_api/v7_api.dart';

Future<Map<String, dynamic>> v7apiFileUpload({
  required String filePath,
  required String idxMember,
  String? module,
  String? code,
  void Function(double progress)? onProgress,
  bool debug = false,
}) async
```

### 11.2 매개변수

| 매개변수 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|-------|------|
| `filePath` | `String` | ✅ | — | 업로드할 로컬 파일 경로 |
| `idxMember` | `String` | ✅ | — | 회원번호 (sf_member.idx) |
| `module` | `String?` | ❌ | `null` | 모듈명 분류 (예: `'receipt'`, `'profile'`, `'post'`) |
| `code` | `String?` | ❌ | `null` | 코드 분류 (모듈 내 세부 분류) |
| `onProgress` | `void Function(double)?` | ❌ | `null` | 업로드 진행률 콜백 (0.0 ~ 1.0) |
| `debug` | `bool` | ❌ | `false` | 디버그 로깅 |

### 11.3 반환값 (upload.upload 응답)

성공 시 v7 upload.upload 응답 Map:

```json
{
  "idx": 42,
  "idx_member": "123",
  "name": "receipt_20240101.jpg",
  "size": 245760,
  "type": "image/jpeg",
  "module": "receipt",
  "code": null,
  "url": "/uploads/123/unique_filename.jpg",
  "attached": "N",
  "created_at": "2024-01-01 12:00:00",
  "updated_at": "2024-01-01 12:00:00"
}
```

> **URL 형식**: `/uploads/{회원번호}/{유니크파일명}` — 상대경로. 화면 표시 시 도메인 prefix 필요:
> `'${PhilgoConfig.v7ApiEndpoint.replaceAll('/api.php', '')}$url'`

에러 시 Exception throw (v7api()와 동일한 패턴).

### 11.4 사용 예시

```dart
import 'package:philgo/v7_api/v7_api.dart';

// 기본 업로드
final result = await v7apiFileUpload(
  filePath: '/path/to/receipt.jpg',
  idxMember: '123',
  module: 'receipt',
);
print(result['url']); // /uploads/123/unique_file.jpg

// 진행률 추적 업로드
final result = await v7apiFileUpload(
  filePath: photo.path,
  idxMember: userInfo!['idx'].toString(),
  module: 'receipt',
  debug: true,
  onProgress: (progress) {
    setState(() { uploadProgress = progress; });
    print('${(progress * 100).toInt()}%');
  },
);
```

### 11.5 v7api()와의 차이점

| 항목 | v7api() | v7apiFileUpload() |
|------|---------|-------------------|
| **Content-Type** | `application/x-www-form-urlencoded` | `multipart/form-data` |
| **데이터 형식** | `Map<String, dynamic>` (JSON) | `FormData` + `MultipartFile` |
| **method 전달** | `data['method'] = method` | `FormData` 내 `method: 'upload.upload'` 고정 |
| **id_token** | `patchToken(data)` 자동 | `patchToken({})` → id_token 추출 → FormData에 추가 |
| **진행률** | 지원 안함 | `onSendProgress` 콜백 지원 |
| **용도** | 일반 API 호출 | 파일 업로드 전용 |

---

## 12. V7FileUpload 위젯 (재활용 필수)

### 12.1 개요 및 재활용 원칙

> **⚠️⚠️⚠️ 재활용 필수 원칙 ⚠️⚠️⚠️**
>
> v7 시스템에서 파일 업로드가 필요한 **모든 곳**에서 이 위젯을 재활용해야 한다.
> **절대로 새로운 업로드 위젯을 만들지 말 것.** 기존 V7FileUpload 위젯의 옵션을 활용하여
> 영수증, 프로필 사진, 게시글 첨부, 문서 업로드 등 모든 파일 업로드 시나리오를 처리한다.

**위치**: `lib/widgets/upload/v7_file_upload.dart`

**역할**: child 위젯을 GestureDetector로 감싸서, 탭 시 Bottom Sheet로 업로드 옵션(카메라/갤러리/파일)을
표시하고, `v7apiFileUpload()`를 호출하여 v7 서버에 파일을 업로드한다.

**기존 FileUpload(v6) 대비 차이점**:
- v6 FileUpload: `philgoApiFileUpload()` → `PhilgoConfig.fileUploadUrl` (func.php)
- **V7FileUpload**: `v7apiFileUpload()` → `PhilgoConfig.v7ApiEndpoint` (api.php, upload.upload)

### 12.2 위젯 속성 (Props)

| 속성 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|-------|------|
| `child` | `Widget` | ✅ | — | 탭 가능한 자식 위젯 (버튼, 아바타, 아이콘 등) |
| `idxMember` | `String` | ✅ | — | 회원번호 (필수) |
| `onUploaded` | `Function(Map<String, dynamic>)` | ✅ | — | 업로드 완료 콜백 (v7 응답 Map 전달) |
| `onBeforeUpload` | `VoidCallback?` | ❌ | `null` | 업로드 시작 전 콜백 |
| `onCancelled` | `VoidCallback?` | ❌ | `null` | 업로드 취소 시 콜백 |
| `onProgress` | `void Function(double)?` | ❌ | `null` | 진행률 콜백 (0.0 ~ 1.0) |
| `onError` | `void Function(String)?` | ❌ | `null` | 에러 콜백 (에러 메시지 전달) |
| `module` | `String?` | ❌ | `null` | 모듈명 분류 (예: `'receipt'`, `'profile'`) |
| `code` | `String?` | ❌ | `null` | 코드 분류 |
| `image` | `bool` | ❌ | `true` | 이미지 선택 가능 여부 |
| `video` | `bool` | ❌ | `false` | 비디오 선택 가능 여부 |
| `file` | `bool` | ❌ | `false` | 일반 파일 선택 가능 여부 |
| `camera` | `bool` | ❌ | `true` | 카메라 촬영 옵션 표시 여부 |
| `gallery` | `bool` | ❌ | `true` | 갤러리 선택 옵션 표시 여부 |
| `imageQuality` | `int` | ❌ | `85` | 이미지 압축 품질 (0~100) |
| `maxWidth` | `double?` | ❌ | `null` | 이미지 최대 너비 (픽셀) |
| `maxHeight` | `double?` | ❌ | `null` | 이미지 최대 높이 (픽셀) |
| `maxDuration` | `Duration?` | ❌ | `null` | 비디오 최대 촬영 시간 |
| `showErrorSnackBar` | `bool` | ❌ | `true` | 에러 시 스낵바 자동 표시 여부 |
| `debug` | `bool` | ❌ | `true` | 디버그 로깅 |

### 12.3 사용 예시

#### (1) 영수증 이미지 업로드 (카메라 + 갤러리)

```dart
V7FileUpload(
  idxMember: userInfo!['idx'].toString(),
  module: 'receipt',
  onUploaded: (result) {
    setState(() { receiptUrl = result['url']?.toString(); });
  },
  onProgress: (progress) {
    setState(() { uploadProgress = progress; });
  },
  child: FilledButton.icon(
    onPressed: () {},
    icon: const FaIcon(FontAwesomeIcons.receipt, size: 18),
    label: const Text('영수증 업로드'),
  ),
)
```

#### (2) 프로필 사진 업로드 (카메라만, 크기 제한)

```dart
V7FileUpload(
  idxMember: '123',
  module: 'profile',
  gallery: false,       // 갤러리 비활성
  maxWidth: 512,         // 최대 512px
  maxHeight: 512,
  imageQuality: 70,      // 품질 70%
  onUploaded: (result) => updateProfilePhoto(result['url']),
  child: CircleAvatar(
    radius: 40,
    child: Icon(Icons.camera_alt),
  ),
)
```

#### (3) 게시글 첨부파일 (이미지 + 비디오 + 파일)

```dart
V7FileUpload(
  idxMember: '123',
  module: 'post',
  code: 'freetalk',
  video: true,          // 비디오 활성
  file: true,           // 일반 파일 활성
  maxDuration: const Duration(minutes: 5),
  onUploaded: (result) => addAttachment(result),
  child: IconButton(
    onPressed: () {},
    icon: const Icon(Icons.attach_file),
  ),
)
```

#### (4) 갤러리에서만 이미지 선택

```dart
V7FileUpload(
  idxMember: '123',
  module: 'gallery',
  camera: false,        // 카메라 비활성
  onUploaded: (result) => addToGallery(result['url']),
  child: const Text('사진 선택'),
)
```

### 12.4 실전 통합 패턴: 업로드 상태 관리

화면에서 V7FileUpload를 사용할 때 권장하는 상태 관리 패턴:

```dart
class _MyScreenState extends State<MyScreen> {
  /// 업로드 상태 변수
  String? uploadedUrl;
  bool isUploading = false;
  double uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 업로드된 이미지 미리보기
        if (uploadedUrl != null)
          Image.network(
            '${PhilgoConfig.v7ApiEndpoint.replaceAll('/api.php', '')}$uploadedUrl',
          ),

        /// 업로드 버튼
        V7FileUpload(
          idxMember: userIdx,
          module: 'receipt',
          onBeforeUpload: () => setState(() {
            isUploading = true;
            uploadProgress = 0.0;
          }),
          onProgress: (p) => setState(() { uploadProgress = p; }),
          onUploaded: (result) => setState(() {
            uploadedUrl = result['url']?.toString();
            isUploading = false;
          }),
          onError: (_) => setState(() {
            isUploading = false;
            uploadProgress = 0.0;
          }),
          onCancelled: () => setState(() {
            isUploading = false;
            uploadProgress = 0.0;
          }),
          child: FilledButton.icon(
            onPressed: () {},
            icon: isUploading
                ? SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: uploadProgress > 0 ? uploadProgress : null,
                    ),
                  )
                : const Icon(Icons.upload),
            label: Text(isUploading
                ? '업로드 중... ${(uploadProgress * 100).toInt()}%'
                : '파일 업로드'),
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
onBeforeUpload() 콜백
    ▼
v7apiFileUpload(filePath, idxMember, module, ...)
    ▼ onSendProgress → onProgress() 콜백
    ▼
업로드 완료 → onUploaded(결과 Map) 콜백
    또는
업로드 에러 → onError(에러메시지) 콜백 + showSafeErrorSnackBar()
```

**IgnorePointer 패턴**: V7FileUpload는 child를 `IgnorePointer`로 감싸서,
child(예: FilledButton)의 자체 탭 이벤트가 GestureDetector를 방해하지 않도록 한다.
따라서 child 내 `onPressed: () {}`는 실행되지 않으며, V7FileUpload의 GestureDetector가 탭을 처리한다.

---

## 13. v7 위젯 목록

v7 시스템에서 제공하는 Flutter 위젯 및 함수 목록.
**새 기능 개발 시 기존 위젯/함수를 반드시 재활용**하고, 중복 생성하지 말 것.

### 13.1 API 호출 함수

| 함수 | 파일 | 용도 | 재활용 |
|------|------|------|--------|
| `v7api()` | `lib/v7_api/v7_api.dart` | v7 일반 API 호출 (JSON POST) | ✅ 필수 |
| `v7apiFileUpload()` | `lib/v7_api/v7_api.dart` | v7 파일 업로드 (multipart/form-data) | ✅ 필수 |

### 13.2 업로드 위젯

| 위젯 | 파일 | 용도 | 재활용 |
|------|------|------|--------|
| `V7FileUpload` | `lib/widgets/upload/v7_file_upload.dart` | v7 파일 업로드 (카메라/갤러리/파일) | ✅ **필수** — 모든 v7 업로드에 이 위젯 사용 |

### 13.3 사용 중인 화면

| 화면 | 파일 | v7 기능 |
|------|------|---------|
| QR 코드 스캔 결과 | `lib/screens/company/company.qr_code_scanned.screen.dart` | `v7api('user.me')` + `V7FileUpload` (영수증) |

> 새 화면에서 v7 API를 사용할 때 이 목록을 업데이트한다.

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
