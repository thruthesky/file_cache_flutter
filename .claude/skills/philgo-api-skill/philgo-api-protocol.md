# PhilGo API 프로토콜

이 문서는 PhilGo API의 접근 방법, 입출력 형식, 인증 등을 설명하는 문서입니다.

## 목차

- [기본 개념](#기본-개념)
- [API 접근 방법](#api-접근-방법)
- [입력 형식](#입력-형식)
- [출력 형식](#출력-형식)
- [PHP 함수 직접 호출](#php-함수-직접-호출)
- [인증 방식](#인증-방식)
- [에러 처리](#에러-처리)
- [실제 예제](#실제-예제)

---

## 기본 개념

PhilGo API는 **PHP 함수를 직접 호출하는 방식**으로 동작합니다. 클라이언트(웹/앱)에서 `/func.php`를 통해 특정 PHP 함수를 직접 호출할 수 있습니다.

### 기본 흐름

- **엔드포인트**: `/func.php` 하나로 통일
- **함수 호출**: PHP 함수를 `func` 파라미터로 직접 호출
- **데이터 형식**: 입출력 모두 **JSON 형식**
- **인증 방식**: Firebase ID 토큰 또는 API 키
- **호출 방법**: Ajax/fetch/axios 등 모든 HTTP 클라이언트

### 장점

1. **단순한 API 설계**: 하나의 엔드포인트로 모든 함수 호출
2. **일관성**: 모든 API는 동일한 엔드포인트 사용
3. **확장성**: PHP 함수를 작성하면 바로 API로 활용 가능
4. **명확성**: PHP 함수의 파라미터가 곧 API 파라미터가 됨

---

## API 접근 방법

### 기본 URL

모든 API 요청은 `/func.php`를 통해 이루어집니다.

```
https://local.philgo.com:444/func.php
```

**실제 운영 환경**:
```
https://www.philgo.com/func.php
```

### 요청 방식

HTTP GET 또는 POST 방식을 사용할 수 있습니다.

**GET 요청 예시**:
```
GET /func.php?func=user_get&idx=12345
```

**POST 요청 예시**:
```
POST /func.php
Content-Type: application/x-www-form-urlencoded

func=user_update&token=...&nickname=...
```

---

## 입력 형식

### 필수 파라미터

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| func | string | 호출할 PHP 함수 이름 (필수) |

### 함수별 파라미터

각 PHP 함수마다 필요한 파라미터가 다릅니다. PHP 함수의 정의를 확인하면 필요한 파라미터를 알 수 있습니다.

**예시: user_update 함수**

PHP 함수 정의:
```php
function user_update(array $input) {
    // $input['token'] - Firebase ID 토큰
    // $input['nickname'] - 닉네임
    // $input['name'] - 이름
    // ...
}
```

API 호출:
```
POST /func.php
func=user_update&token=abc123&nickname=새닉네임&name=홍길동
```

### 배열 파라미터 전달

배열을 전달할 때는 `[]` 표기법을 사용합니다.

```
POST /func.php
func=post_create&files[]=url1.jpg&files[]=url2.jpg
```

또는 JSON 형식으로 전달:
```javascript
const formData = new FormData();
formData.append('func', 'post_create');
formData.append('files', JSON.stringify(['url1.jpg', 'url2.jpg']));
```

---

## 출력 형식

### 성공 응답

모든 성공 응답은 **JSON 형식**으로 반환됩니다.

**단일 값 반환**:
```json
{
  "data": true
}
```

**객체 반환**:
```json
{
  "idx": 12345,
  "nickname": "사용자닉네임",
  "email": "user@example.com"
}
```

**배열 반환**:
```json
[
  {
    "idx": 1,
    "subject": "게시글 1"
  },
  {
    "idx": 2,
    "subject": "게시글 2"
  }
]
```

### 에러 응답

에러 발생 시에도 JSON 형식으로 반환됩니다.

**기본 에러**:
```json
{
  "error": {
    "code": "user-not-found",
    "message": "사용자를 찾을 수 없습니다."
  }
}
```

**HTTP 상태 코드**:
- `200`: 성공
- `400`: 잘못된 요청
- `401`: 인증 필요
- `403`: 권한 없음
- `404`: 리소스 없음
- `500`: 서버 오류

---

## PHP 함수 직접 호출

### 기본 개념

PhilGo API의 핵심은 **PHP 함수를 직접 호출할 수 있는 구조**입니다.

```
/func.php?func=[PHP함수이름]
```

### PHP 함수 작성 및 사용법 예시

API 파라미터를 받는 방법은 간단합니다. 서버에서 PHP 함수를 정의하면 됩니다.

**예시: 사용자 정보 조회**

1. **PHP 함수 작성**: `user_get` 함수 정의

```php
// lib/user/user.php
function user_get(array $input) {
    // $input['idx'] - 사용자 idx (필수)
    // $input['uid'] - Firebase UID (선택)

    $idx = $input['idx'] ?? null;
    // ...
    return $user; // 배열 반환
}
```

2. **API 호출**:

```javascript
// JavaScript에서 호출
const response = await fetch('/func.php?func=user_get&idx=12345');
const user = await response.json();
console.log(user.nickname);
```

### 함수 명명 규칙

| 패턴 | 설명 | 예시 |
|------|------|------|
| `[module]_get` | 단일 데이터 조회 | `user_get`, `post_get` |
| `[module]_list` | 목록 조회 | `post_list`, `company_list` |
| `[module]_create` | 데이터 생성 | `post_create`, `comment_create` |
| `[module]_update` | 데이터 수정 | `user_update`, `post_update` |
| `[module]_delete` | 데이터 삭제 | `post_delete`, `comment_delete` |

### JavaScript에서 func() 헬퍼 함수 사용

PhilGo는 클라이언트에서 `func()` 헬퍼 함수를 제공합니다.

```javascript
// func() 함수를 사용하여 간편하게 /func.php를 호출합니다
const user = await func('user_get', { idx: 12345 });
console.log(user.nickname);

// 게시글 생성
const post = await func('post_create', {
  token: firebaseToken,
  post_id: 'freetalk',
  subject: '게시글 제목',
  content: '게시글 내용'
});
```

**func() 함수의 정의**:
```javascript
function func(functionName, params) {
  const formData = new FormData();
  formData.append('func', functionName);

  for (const [key, value] of Object.entries(params)) {
    formData.append(key, value);
  }

  return fetch('/func.php', {
    method: 'POST',
    body: formData
  }).then(res => res.json());
}
```

---

## 인증 방식

### Firebase ID 토큰

대부분의 API는 Firebase ID 토큰으로 사용자를 인증합니다.

```javascript
// Firebase 로그인 후 토큰 획득
const token = await firebase.auth().currentUser.getIdToken();

// API 호출 시 토큰 전달
const result = await func('user_update', {
  token: token,
  nickname: '새닉네임'
});
```

### API 키 (선택사항)

일부 API는 API 키로도 인증할 수 있습니다.

```javascript
const result = await func('post_create', {
  api_key: 'your-api-key',
  post_id: 'news',
  subject: '뉴스 제목',
  content: '뉴스 내용'
});
```

### 인증이 필요 없는 API

일부 공개 API는 인증이 필요 없습니다.

```javascript
// 앱 버전 조회
const version = await func('app_version', {});

// 게시글 목록 조회
const posts = await func('post_list', {
  post_id: 'freetalk',
  page: 1
});
```

---

## 에러 처리

### 에러 확인

응답에 `error` 필드가 있으면 에러입니다.

```javascript
const result = await func('user_get', { idx: 99999 });

if (result.error) {
  console.error('에러 발생:', result.error.message);
  console.error('에러 코드:', result.error.code);
} else {
  console.log('성공:', result);
}
```

### 일반적인 에러 코드

| 에러 코드 | 설명 |
|----------|------|
| `token-missing` | Firebase 토큰이 없음 |
| `invalid-token` | 유효하지 않은 토큰 |
| `user-not-found` | 사용자를 찾을 수 없음 |
| `permission-denied` | 권한 없음 |
| `invalid-parameter` | 잘못된 파라미터 |
| `function-not-found` | 함수를 찾을 수 없음 |

### PHP 함수에서 에러 반환

```php
function user_get(array $input) {
    $idx = $input['idx'] ?? null;

    if (!$idx) {
        return error('idx-required', 'idx 파라미터가 필요합니다.');
    }

    $user = db_get_user($idx);

    if (!$user) {
        return error('user-not-found', '사용자를 찾을 수 없습니다.');
    }

    return $user;
}
```

---

## 실제 예제

### 예제 1: 사용자 정보 조회

**PHP 함수 정의**:
```php
// lib/user/user.php
function user_get(array $input) {
    $idx = $input['idx'];
    return db_get_user($idx);
}
```

**JavaScript 호출**:
```javascript
const user = await func('user_get', { idx: 12345 });
console.log(user.nickname);
```

### 예제 2: 게시글 생성

**PHP 함수 정의**:
```php
// lib/post/post.php
function post_create(array $input) {
    $token = $input['token'];
    $post_id = $input['post_id'];
    $subject = $input['subject'];
    $content = $input['content'];

    // 인증 확인
    $user = verify_firebase_token($token);

    // 게시글 생성
    $post = create_post([
        'idx_member' => $user['idx'],
        'post_id' => $post_id,
        'subject' => $subject,
        'content' => $content
    ]);

    return $post;
}
```

**JavaScript 호출**:
```javascript
const token = await firebase.auth().currentUser.getIdToken();

const post = await func('post_create', {
  token: token,
  post_id: 'freetalk',
  subject: '안녕하세요',
  content: '첫 게시글입니다!'
});

console.log('게시글 ID:', post.idx);
```

### 예제 3: 게시글 목록 조회

**PHP 함수 정의**:
```php
// lib/post/post.php
function post_list(array $input) {
    $post_id = $input['post_id'];
    $page = $input['page'] ?? 1;
    $limit = $input['limit'] ?? 20;

    return select_posts_by_page([
        'post_id' => $post_id,
        'page' => $page,
        'limit' => $limit
    ]);
}
```

**JavaScript 호출**:
```javascript
const result = await func('post_list', {
  post_id: 'freetalk',
  page: 1,
  limit: 10
});

console.log('전체 게시글 수:', result.total);
console.log('게시글 목록:', result.posts);
```

### 예제 4: 사용자 정보 수정

**PHP 함수 정의**:
```php
// lib/user/user.php
function user_update(array $input) {
    $token = $input['token'];
    $nickname = $input['nickname'] ?? null;
    $name = $input['name'] ?? null;

    // 인증 확인
    $user = verify_firebase_token($token);

    // 정보 수정
    $updates = [];
    if ($nickname) $updates['nickname'] = $nickname;
    if ($name) $updates['name'] = $name;

    update_user($user['idx'], $updates);

    return get_user($user['idx']);
}
```

**JavaScript 호출**:
```javascript
const token = await firebase.auth().currentUser.getIdToken();

const user = await func('user_update', {
  token: token,
  nickname: '새로운닉네임',
  name: '홍길동'
});

console.log('수정된 사용자:', user);
```

### 예제 5: 에러 처리

```javascript
async function updateNickname(nickname) {
  try {
    const token = await firebase.auth().currentUser.getIdToken();

    const result = await func('user_update', {
      token: token,
      nickname: nickname
    });

    if (result.error) {
      alert('닉네임 수정 실패: ' + result.error.message);
      return;
    }

    alert('닉네임이 수정되었습니다!');
    return result;

  } catch (error) {
    console.error('API 호출 오류:', error);
    alert('네트워크 오류가 발생했습니다.');
  }
}
```

---

## 함수 작성 및 사용법 예시

### 단계 1: 코드 검색

서버에서 PHP 코드를 검색하여 함수를 찾습니다.

```bash
# 사용자 관련 함수 검색
grep -r "function user_" lib/user/

# 게시글 관련 함수 검색
grep -r "function post_" lib/post/
```

### 단계 2: 함수 정의서 확인

함수의 PHPDoc 주석을 확인합니다.

```php
/**
 * 사용자 정보를 조회합니다.
 *
 * @param array $input {
 *     @type int $idx 사용자 idx (필수)
 *     @type string $uid Firebase UID (선택)
 * }
 * @return array 사용자 정보
 */
function user_get(array $input) {
    // ...
}
```

### 단계 3: 테스트 코드 확인

각 함수의 테스트 코드를 실제 예제로 확인합니다.

```php
// tests/user/user.test.php
$user = user_get(['idx' => 12345]);
assert($user['nickname'] !== null);
```

---

## 추가 정보

### 성능 최적화

- **캐싱 활용**: 자주 조회하는 데이터는 `search_term` 사용
- **배치 함수**: `get_cached_xxxx()` 형태로 사용
- **페이지네이션**: `page`, `limit` 파라미터 활용

### 데이터 전송 최소화

성공 최소화를 위한 파라미터:

```javascript
// 전체 게시글 수 포함하지 않음
const posts = await func('post_list', {
  post_id: 'freetalk',
  post_count: 'n'
});

// 사용자 정보 제외함
const posts = await func('post_list', {
  post_id: 'freetalk',
  user_info: 'n'
});

// HTML 태그 제거
const posts = await func('post_list', {
  post_id: 'freetalk',
  strip_tags: 'y'
});
```

---

**문서 버전**: 1.0
**최종 업데이트**: 2025-01-26
**작성자**: PhilGo Development Team
