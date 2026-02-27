# v7 API 호출 시스템 구축 계획

## CoT (Chain-of-Thought) 분석

### 1단계: 문제의 핵심 이해

필고 앱(Flutter)에서 v7 서버 API(`api.php`)를 호출하는 전용 함수가 필요하다.
기존 `func()` 함수는 레거시 `func.php` 전용이므로, v7 프로토콜에 맞는 새 함수를 추가해야 한다.

### 2단계: 현재 상태 파악

| 항목 | 레거시 (v6) | v7 |
|------|------------|-----|
| 서버 엔드포인트 | `func.php` | `api.php` |
| 호출 방식 | `func=함수명` 파라미터 | `method=모듈.액션` 파라미터 |
| 응답 형식 | `{error: null, ...data}` 또는 `{error: "코드", message: "..."}` | Controller 리턴값 그대로 (에러 시만 `{success: false, message: "..."}`) |
| Flutter 호출 함수 | `func()` (`philgo.api.functions.dart`) | **아직 없음** ← 새로 만들어야 함 |
| 설정 | `PhilgoConfig.phpApiUrl` → `func.php` | `PhilgoConfig.v7ApiEndpoint` → `api.php` (✅ 이미 추가됨) |

### 3단계: 기존 코드 분석 결과

**기존 func() 함수 위치**: `packages/philgo_api/lib/src/philgo/philgo.api.functions.dart`

**재사용 가능한 헬퍼 함수들** (같은 파일에 존재):
- `createDio()` — Dio 인스턴스 생성 + 디버그 SSL 무시
- `patchToken()` — Firebase ID Token 자동 추가 (`data['id_token']`)

**PhilgoConfig.v7ApiEndpoint** (`packages/philgo_api/lib/src/philgo.config.dart`):
```dart
static const String v7ApiEndpoint = String.fromEnvironment(
  'V7_API_ENDPOINT',
  defaultValue: 'https://philgo.com/api.php',
);
```

**launch.json 로컬 테스트 시**:
```
--dart-define=V7_API_ENDPOINT=https://local.philgo.com:444/api.php
```

### 4단계: 핵심 차이점 (기존 func() vs 새 v7api())

| 구분 | 기존 `func()` | 새 `v7api()` |
|------|-------------|-------------|
| URL | `PhilgoConfig.phpApiUrl` (func.php) | `PhilgoConfig.v7ApiEndpoint` (api.php) |
| 키 파라미터 | `data['func'] = functionName` | `data['method'] = method` |
| method 형식 | 단순 함수명 (`"get_posts"`) | 모듈.액션 (`"user.count"`) |
| 에러 판별 | `json['error'] != null` | `json['success'] == false` |
| 성공 응답 | `{error: null, ...data}` | Controller 리턴값 그대로 (예: `{count: 188186}`) |
| 반환 타입 | 제너릭 `T` | `Map<String, dynamic>` |

---

## ToT (Tree-of-Thought) 분석

### 서브 문제 1: 파일 위치 결정

**✅ 결정: `lib/v7_api/v7_api.dart`** — 앱 레벨 `lib/` 하위에 v7 전용 폴더를 생성한다.

- ✅ v7 전용 코드를 기존 패키지(`packages/philgo_api`)와 완전히 분리
- ✅ 앱에서 직접 import하여 사용 (`import 'package:philgo_app/v7_api/v7_api.dart'`)
- ✅ `createDio()`, `patchToken()`은 `package:philgo_api/philgo_api.dart`에서 import하여 재사용

### 서브 문제 2: v7api() 함수 시그니처 설계

```dart
/// v7 API 호출 함수
///
/// [method] - "모듈.액션" 형식 (예: "user.count", "post.create")
/// [data] - 전송할 데이터 (method 필드는 자동 추가됨)
/// [debug] - 디버그 모드 (GET URL 로깅)
/// [alertOnError] - 에러 발생 시 사용자에게 다이얼로그 표시
///
/// v7 서버 응답 규칙:
/// - 성공: Controller 리턴값 그대로 (예: {"count": 188186})
/// - 에러: {"success": false, "message": "에러 설명"}
///
/// 사용 예시:
/// ```dart
/// final result = await v7api('user.count');
/// print(result['count']); // 188186
/// ```
Future<Map<String, dynamic>> v7api(
  String method, {
  Map<String, dynamic>? data,
  bool debug = false,
  bool alertOnError = false,
}) async {
  data = data ?? <String, dynamic>{};
  data['method'] = method;

  final url = PhilgoConfig.v7ApiEndpoint;

  try {
    // Firebase ID Token 자동 추가
    data = await patchToken(data);

    if (debug) {
      final stringParams = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      log(
        'v7 GET URL: $url?${Uri(queryParameters: stringParams).query}',
        name: "v7api::$method",
      );
    }

    // Dio 인스턴스 생성 (기존 createDio() 재사용)
    final dio = createDio();

    // HTTP POST 요청
    final response = await dio.post(url, data: data);

    final responseData = response.data;
    Map<String, dynamic> json;

    if (responseData is Map<String, dynamic>) {
      json = responseData;
    } else if (responseData is String) {
      json = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      throw Exception(
        'v7api($method) 예상치 못한 응답 타입: ${responseData.runtimeType}',
      );
    }

    // v7 에러 판별: success == false일 때만 에러
    if (json['success'] == false) {
      final errorMessage = json['message'] ?? '알 수 없는 오류';
      if (alertOnError) {
        showSafeErrorDialog('v7 API 오류: $errorMessage');
      }
      throw Exception('v7api($method): $errorMessage');
    }

    return json;
  } on DioException catch (dioError) {
    // 기존 func()와 동일한 에러 처리 패턴
    log('========== v7 API 에러 발생 ==========', name: 'v7API:ERROR');
    log('method: $method', name: 'v7API:ERROR');
    log('요청 데이터: $data', name: 'v7API:ERROR');
    log('요청 URL: $url', name: 'v7API:ERROR');
    log('에러 타입: ${dioError.type}', name: 'v7API:ERROR');
    log('에러 메시지: ${dioError.message}', name: 'v7API:ERROR');
    log('==========================================', name: 'v7API:ERROR');

    if (dioError.message?.contains('Handshake') ?? false) {
      final userMessage = '서버와 접속이 안됩니다. 인터넷 연결을 확인해 주세요.';
      if (alertOnError) showSafeErrorDialog(userMessage);
      throw Exception(userMessage);
    }

    if (alertOnError) {
      showSafeErrorDialog('v7 서버와 통신 중 오류가 발생했습니다.');
    }
    rethrow;
  } catch (e) {
    log('========== v7 API 일반 에러 ==========', name: 'v7API:ERROR');
    log('method: $method', name: 'v7API:ERROR');
    log('에러: $e', name: 'v7API:ERROR');
    log('==========================================', name: 'v7API:ERROR');
    rethrow;
  }
}
```

### 서브 문제 3: import 방법

앱 코드에서 직접 import하여 사용:
```dart
import 'package:philgo_app/v7_api/v7_api.dart';
```

별도의 export 등록 불필요 — 앱 레벨 `lib/` 하위에 위치하므로 직접 import 가능.

### 서브 문제 4: 사용 예시

```dart
// 사용자 수 조회
final result = await v7api('user.count');
print(result['count']); // 188186

// 게시글 생성 (향후)
final post = await v7api('post.create', data: {
  'post_id': 'freetalk',
  'title': '제목',
  'content': '내용',
});

// 디버그 모드 + 에러 알림
final setting = await v7api('setting.get', debug: true, alertOnError: true);
```

---

## 구현 계획

### ✅ 1단계: PhilgoConfig에 v7 엔드포인트 추가 — 완료

`packages/philgo_api/lib/src/philgo.config.dart`에 이미 존재:
```dart
static const String v7ApiEndpoint = String.fromEnvironment(
  'V7_API_ENDPOINT',
  defaultValue: 'https://philgo.com/api.php',
);
```

### 📋 2단계: v7 전용 API 호출 파일 생성

**생성할 파일**: `lib/v7_api/v7_api.dart`

내용:
- `v7api()` 함수 (위 코드 참조)
- 기존 `createDio()`, `patchToken()` import하여 재사용 (`package:philgo_api/philgo_api.dart`)
- v7 전용 에러 처리 (success == false 패턴)

**import 구조**:
```dart
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:philgo_api/philgo_api.dart';
```

### 📋 3단계: 테스트 검증

v7api() 함수 호출 테스트:
```dart
final result = await v7api('user.count', debug: true);
debugLog('v7 user.count 결과: $result');
```

---

## 파일 구조 요약

```
lib/
├── v7_api/
│   └── v7_api.dart                          ← 🆕 v7api() 함수 정의
└── ...                                      ← 기존 앱 코드

packages/philgo_api/lib/
├── philgo_api.dart                          ← 수정 없음
└── src/
    ├── philgo/
    │   └── philgo.api.functions.dart        ← 기존 func() 유지 (수정 없음)
    └── philgo.config.dart                   ← v7ApiEndpoint 이미 존재 (수정 없음)
```

## 핵심 설계 원칙

1. **기존 코드 무수정**: `func()`, `createDio()`, `patchToken()` 등 기존 코드는 건드리지 않음
2. **헬퍼 함수 재사용**: `createDio()` (SSL 처리), `patchToken()` (Firebase 토큰) 그대로 사용
3. **v7 프로토콜 준수**: `method=모듈.액션` 파라미터, `success == false` 에러 판별
4. **기존 패턴 일관성**: 에러 로깅, alertOnError, debug 옵션 등 기존 func()와 동일한 UX
5. **앱 레벨 분리**: `lib/v7_api/` 하위에 배치하여 기존 패키지와 독립적으로 관리
