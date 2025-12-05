---
name: philgo-api
description: PhilGo.Com 홈페이지 API 정보 및 기능 별 상세 설명과 예제 코드를 제공하는 스킬. 필고(Philgo) 홈페이지 및 앱 개발을 위한 백엔드 API 엔드포인트, 요청 및 응답 형식, 인증 방법, 오류 처리 등에 대한 상세한 설명과 함께 다양한 기능을 구현하는 예제 코드를 포함하고 있습니다. 웹/앱에서 Philgo API를 사용하려는 경우, PHILGO, API, 백엔드, 정보 저장, DB 정보 읽기 등의 요청에서 본 스킬을 사용합니다.
---

# PhilGo API 가이드
본 문서에서는 PhilGo 웹과 앱 개발에 필요한 API 엔드포인트를 설명합니다.

## 개요

PhilGo API는 웹과 앱 개발을 위한 함수 기반 API를 제공합니다.

### 핵심 특징

- **단일 엔드포인트**: `/func.php` 를 통해 모든 API 접근
- **PHP 함수 직접 호출**: `func=function_name` 형식으로 PHP 함수를 직접 호출
- **응답 형식**: 모든 응답은 JSON 형식
- **인증 방식**: Firebase 토큰 인증 또는 API 키 인증

### API 프로토콜

API 접근 방법, 요청/응답 형식, 인증 등 프로토콜 상세 정보는 별도 문서를 참조하세요:

**📚 [PhilGo API 프로토콜 문서](./philgo-api-protocol.md)**

주요 내용:
- `/func.php` 를 통한 API 접근
- PHP 함수를 직접 호출하는 방법
- 요청/응답 형식
- 인증 방식
- 에러 처리
- 실용적인 예제 코드

### 명명 규칙

- 검색어 변수: 모든 검색에서 `search_term` 사용
- 캐시 함수: `get_cached_xxxx()` 접두사 사용
- 함수 패턴: `[module]_[action]` (예: `user_get`, `post_create`)

---

## 허용된 API 함수 목록 (ALLOWED_FUNCTIONS)

> **중요**: 이 섹션에 나열된 함수들만 `/func.php` 엔드포인트를 통해 호출할 수 있습니다.
>
> 모든 함수는 `func.php` 파일의 `ALLOWED_FUNCTIONS` 상수에 정의되어 있으며, 이 목록에 없는 함수는 호출할 수 없습니다.

### 목차

- [function_list](#function_list) - 허용된 함수 목록 조회
- [get_my_data](#get_my_data) - 내 정보 조회
- [update_my_profile](#update_my_profile) - 내 프로필 업데이트
- [get_user_lang](#get_user_lang) - 사용자 언어 정보 조회
- [family_site_exists](#family_site_exists) - 패밀리사이트 도메인 존재 여부 확인
- [approve_company](#approve_company) - 업소록 승인
- [reject_company](#reject_company) - 업소록 거부
- [report](#report) - 글/댓글 신고

---

### function_list

**허용된 API 함수 목록을 가져옵니다.**

#### 함수 정의

```php
function function_list(): array
```

**파일 위치**: `lib/api/func.functions.php`

#### 설명

`func.php`의 `ALLOWED_FUNCTIONS` 상수에 정의된 모든 허용된 함수 목록을 리턴합니다. 각 함수의 이름과 설명이 포함되어 있습니다.

#### 입력 파라미터

이 함수는 입력 파라미터가 필요 없습니다.

#### 리턴 값

**타입**: `array`

**형식**: 연관 배열 (함수명 => 설명)

**예시**:
```json
{
  "function_list": "필고 API 에서 사용 가능한(허용된) 함수 목록을 가져옵니다.",
  "get_my_data": "내 정보를 가져옵니다.",
  "update_my_profile": "내 프로필을 업데이트합니다.",
  "get_user_lang": "사용자의 언어 정보를 가져옵니다.",
  "family_site_exists": "가족 사이트가 존재하는지 확인합니다.",
  "approve_company": "업소록 정보를 승인합니다.",
  "reject_company": "업소록 정보를 거부합니다.",
  "report": "글 또는 댓글을 신고합니다."
}
```

#### 사용 예제

**JavaScript**:
```javascript
// 허용된 함수 목록 조회
const functions = await func('function_list', {});
console.log('사용 가능한 함수들:', functions);

// 각 함수의 설명 출력
Object.entries(functions).forEach(([name, description]) => {
  console.log(`${name}: ${description}`);
});
```

**직접 HTTP 요청**:
```bash
curl https://www.philgo.com/func.php?func=function_list
```

#### 에러 처리

이 함수는 에러를 발생시키지 않습니다. 항상 성공적으로 함수 목록을 리턴합니다.

---

### get_my_data

**로그인한 사용자의 정보를 가져옵니다.**

#### 함수 정의

```php
function get_my_data(): array
```

**파일 위치**: `lib/user/user.functions.php:556`

#### 설명

현재 로그인한 사용자의 전체 정보를 리턴합니다. 사용자의 레벨, 레벨 진행도 등 계산된 값들도 포함됩니다. 빈 문자열이나 0과 같은 falsy 값은 리턴하지 않습니다.

#### 입력 파라미터

이 함수는 입력 파라미터가 필요 없습니다. Firebase ID 토큰을 통해 로그인한 사용자를 자동으로 식별합니다.

#### 리턴 값

**타입**: `array`

**포함 필드**:
- `idx` - 사용자 번호
- `nickname` - 닉네임
- `name` - 이름
- `email` - 이메일
- `phone_number` - 전화번호
- `photo_url` - 프로필 사진 URL
- `gender` - 성별
- `point` - 포인트
- `level` - 레벨 (포인트 기반으로 자동 계산)
- `level_progress` - 레벨 진행도 (0-100)
- `firebase_uid` - Firebase UID
- 기타 사용자 정보 필드들

#### 사용 예제

**JavaScript**:
```javascript
// Firebase 로그인 후 토큰 획득
const token = await firebase.auth().currentUser.getIdToken();

// 내 정보 조회
const myData = await func('get_my_data', { token: token });

console.log('내 닉네임:', myData.nickname);
console.log('내 포인트:', myData.point);
console.log('내 레벨:', myData.level);
console.log('레벨 진행도:', myData.level_progress + '%');
```

**Vue.js 컴포넌트에서 사용**:
```javascript
async mounted() {
  try {
    const token = await firebase.auth().currentUser.getIdToken();
    this.user = await func('get_my_data', { token });
  } catch (error) {
    if (error.error && error.error.code === 'login-required') {
      alert('로그인이 필요합니다.');
      location.href = '/user/login.php';
    }
  }
}
```

#### 에러 처리

**에러 코드**: `login-required`
- **HTTP 상태**: 401
- **메시지**: "Login required"
- **발생 조건**: 로그인하지 않은 상태에서 호출한 경우

```javascript
const result = await func('get_my_data', { token });

if (result.error) {
  if (result.error.code === 'login-required') {
    console.error('로그인이 필요합니다.');
    // 로그인 페이지로 이동
  }
}
```

---

### update_my_profile

**로그인한 사용자 자신의 프로필 정보를 업데이트합니다.**

#### 함수 정의

```php
function update_my_profile(array $params): array
```

**파일 위치**: `lib/user/user.functions.php:577`

#### 설명

로그인한 사용자가 자신의 프로필 정보를 수정할 때 사용합니다. 닉네임은 한 번만 설정할 수 있으며, 이후에는 변경할 수 없습니다 (관리자 제외).

#### 입력 파라미터

**필수 파라미터**:
- `token` (string) - Firebase ID 토큰

**선택 파라미터** (업데이트할 필드만 전달):
- `nickname` (string) - 닉네임 (최초 1회만 설정 가능, 2자 이상, 영문/숫자/한글/언더스코어/대시만 허용)
- `name` (string) - 이름
- `photo_url` (string) - 프로필 사진 URL
- `gender` (string) - 성별
- `birth_year` (int) - 출생 연도
- `birth_month` (int) - 출생 월
- `birth_day` (int) - 출생 일

#### 리턴 값

**타입**: `array`

업데이트된 사용자 정보를 전체 리턴합니다 (`get_my_data()`와 동일한 형식).

#### 사용 예제

**닉네임 설정 (최초 1회)**:
```javascript
const token = await firebase.auth().currentUser.getIdToken();

const result = await func('update_my_profile', {
  token: token,
  nickname: '철수짱'
});

console.log('닉네임이 설정되었습니다:', result.nickname);
```

**프로필 사진 업데이트**:
```javascript
const token = await firebase.auth().currentUser.getIdToken();

// 파일 업로드 후 URL 획득
const photoUrl = await uploadPhoto(file);

// 프로필 사진 URL 업데이트
const result = await func('update_my_profile', {
  token: token,
  photo_url: photoUrl
});

console.log('프로필 사진이 업데이트되었습니다:', result.photo_url);
```

**여러 필드 동시 업데이트**:
```javascript
const token = await firebase.auth().currentUser.getIdToken();

const result = await func('update_my_profile', {
  token: token,
  name: '홍길동',
  gender: 'M',
  birth_year: 1990,
  birth_month: 5,
  birth_day: 15
});

console.log('프로필이 업데이트되었습니다:', result);
```

#### 에러 처리

**에러 코드**: `login-required`
- **HTTP 상태**: 401
- **메시지**: "Login required"
- **발생 조건**: 로그인하지 않은 상태

**에러 코드**: `nickname-required`
- **HTTP 상태**: 400
- **메시지**: "닉네임은 비워 둘 수 없습니다."
- **발생 조건**: 빈 닉네임을 입력한 경우

**에러 코드**: `nickname-already-exists`
- **HTTP 상태**: 409
- **메시지**: "입력하신 닉네임은 이미 존재합니다. 다른 닉네임을 입력하세요."
- **발생 조건**: 이미 다른 사용자가 사용 중인 닉네임

**에러 코드**: `nickname-too-short`
- **HTTP 상태**: 400
- **메시지**: "닉네임은 최소 2자 이상이어야 합니다."
- **발생 조건**: 닉네임이 2자 미만

**에러 코드**: `nickname-invalid-characters`
- **HTTP 상태**: 400
- **메시지**: "닉네임에는 영어, 숫자, 한글, 밑줄(_), 대시(-)만 사용할 수 있습니다."
- **발생 조건**: 허용되지 않은 문자 사용

**에러 코드**: `nickname-update-not-allowed`
- **HTTP 상태**: 403
- **메시지**: "닉네임은 변경할 수 없습니다."
- **발생 조건**: 이미 닉네임이 설정된 사용자가 닉네임을 변경하려고 시도

```javascript
try {
  const result = await func('update_my_profile', {
    token: token,
    nickname: '철수'
  });
} catch (error) {
  if (error.error) {
    switch (error.error.code) {
      case 'nickname-already-exists':
        alert('이미 사용 중인 닉네임입니다.');
        break;
      case 'nickname-too-short':
        alert('닉네임은 최소 2자 이상이어야 합니다.');
        break;
      case 'nickname-update-not-allowed':
        alert('닉네임은 한 번만 설정할 수 있습니다.');
        break;
      default:
        alert('오류: ' + error.error.message);
    }
  }
}
```

---

### get_user_lang

**사용자의 현재 언어 설정을 가져옵니다.**

#### 함수 정의

```php
function get_user_lang(): string
```

**파일 위치**: `lib/intl.functions.php:56`

#### 설명

사용자의 언어 설정을 우선순위에 따라 반환합니다:
1. URL 파라미터 `?lang=xx`
2. 쿠키에 저장된 `lang` 값
3. 기본값: 한국어 (`ko`)

지원 언어: `en` (영어), `ko` (한국어), `ja` (일본어), `zh` (중국어)

#### 입력 파라미터

이 함수는 입력 파라미터가 필요 없습니다.

#### 리턴 값

**타입**: `string` (단일 값)

**가능한 값**: `en`, `ko`, `ja`, `zh`

**중요**: 이 함수는 배열이 아닌 **단일 문자열 값**을 리턴합니다. JavaScript에서 `result.data`로 접근해야 합니다.

#### 사용 예제

**JavaScript**:
```javascript
// 사용자 언어 조회
const result = await func('get_user_lang', {});
const userLang = result.data; // 'ko', 'en', 'ja', 'zh' 중 하나

console.log('현재 언어:', userLang);

// 언어별 처리
switch (userLang) {
  case 'ko':
    console.log('한국어 사용자입니다.');
    break;
  case 'en':
    console.log('English user');
    break;
  case 'ja':
    console.log('日本語ユーザー');
    break;
  case 'zh':
    console.log('中文用户');
    break;
}
```

**다국어 메시지 표시**:
```javascript
const result = await func('get_user_lang', {});
const lang = result.data;

const messages = {
  ko: '안녕하세요',
  en: 'Hello',
  ja: 'こんにちは',
  zh: '你好'
};

alert(messages[lang] || messages.ko);
```

**URL 파라미터로 언어 변경**:
```html
<!-- 언어 선택 링크 -->
<a href="?lang=ko">한국어</a>
<a href="?lang=en">English</a>
<a href="?lang=ja">日本語</a>
<a href="?lang=zh">中文</a>
```

#### 에러 처리

이 함수는 에러를 발생시키지 않습니다. 항상 유효한 언어 코드를 리턴합니다.

---

### family_site_exists

**패밀리사이트 도메인이 존재하는지 확인합니다.**

#### 함수 정의

```php
function family_site_exists(array $input): bool
```

**파일 위치**: `lib/family-site/family-site.functions.php:59`

#### 설명

입력받은 도메인이 이미 사용 중인지 확인합니다. 패밀리사이트 생성 시 도메인 중복 체크에 사용됩니다.

**도메인 검증 규칙**:
- 최소 길이: 3자 이상
- 최대 길이: 63자 이하 (DNS 표준)
- 허용 문자: 영문, 숫자, 하이픈(-)
- 시작/끝: 영문 또는 숫자 (하이픈 불가)

#### 입력 파라미터

**필수 파라미터**:
- `domain` (string) - 확인할 패밀리사이트 도메인

#### 리턴 값

**타입**: `boolean` (단일 값)

**중요**: 이 함수는 배열이 아닌 **boolean 값**을 리턴합니다. JavaScript에서 `result.data`로 접근해야 합니다.

- `true` - 도메인이 이미 존재함 (사용 불가)
- `false` - 도메인이 존재하지 않음 (사용 가능)

#### 사용 예제

**도메인 중복 체크**:
```javascript
// 사용자가 입력한 도메인 체크
const domainInput = 'mysite';

const result = await func('family_site_exists', {
  domain: domainInput
});

const exists = result.data;

if (exists) {
  alert('이미 사용 중인 도메인입니다. 다른 도메인을 선택해주세요.');
} else {
  alert('사용 가능한 도메인입니다!');
  // 도메인 등록 진행
}
```

**실시간 도메인 확인 (Vue.js)**:
```javascript
data() {
  return {
    domain: '',
    isChecking: false,
    domainStatus: null // 'available', 'taken', 'invalid'
  };
},
methods: {
  async checkDomain() {
    if (this.domain.length < 3) {
      this.domainStatus = 'invalid';
      return;
    }

    this.isChecking = true;

    try {
      const result = await func('family_site_exists', {
        domain: this.domain
      });

      this.domainStatus = result.data ? 'taken' : 'available';
    } catch (error) {
      console.error('도메인 확인 오류:', error);
    } finally {
      this.isChecking = false;
    }
  }
}
```

**폼 제출 전 검증**:
```javascript
async function createFamilySite() {
  const domain = document.getElementById('domain').value;

  // 도메인 형식 검증
  if (domain.length < 3) {
    alert('도메인은 최소 3자 이상이어야 합니다.');
    return;
  }

  if (!/^[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]$/.test(domain)) {
    alert('도메인은 영문, 숫자, 하이픈만 사용 가능합니다.');
    return;
  }

  // 도메인 존재 여부 확인
  const checkResult = await func('family_site_exists', { domain });

  if (checkResult.data) {
    alert('이미 사용 중인 도메인입니다.');
    return;
  }

  // 패밀리사이트 생성 진행
  console.log('도메인 사용 가능:', domain);
}
```

#### 에러 처리

이 함수는 에러를 발생시키지 않습니다. 잘못된 입력에 대해서는 `false`를 리턴합니다.

**자동 검증 (false를 리턴하는 경우)**:
- 도메인이 비어있는 경우
- 도메인 길이가 3자 미만인 경우
- 도메인 길이가 63자를 초과하는 경우
- 도메인 형식이 올바르지 않은 경우
- 데이터베이스 오류가 발생한 경우

---

### approve_company

**업소록 정보를 승인합니다.**

#### 함수 정의

```php
function approve_company(array $in): array
```

**파일 위치**: `lib/company.functions.php:421`

#### 설명

관리자가 대기 중인 업소록을 승인합니다. 승인된 업소록은 `status`가 `a`(approved)로 변경되어 공개 목록에 표시됩니다.

**권한**: 관리자만 사용 가능

#### 입력 파라미터

**필수 파라미터**:
- `token` (string) - Firebase ID 토큰 (관리자 권한 확인용)
- `idx` (int) - 승인할 업소록 번호

#### 리턴 값

**타입**: `array`

승인된 업소록 전체 정보를 리턴합니다.

**주요 필드**:
- `idx` - 업소록 번호
- `status` - 상태 (`a` = approved)
- `name` - 업소 이름
- `category` - 카테고리
- `location` - 지역
- `description` - 설명
- 기타 업소록 정보

#### 사용 예제

**업소록 승인**:
```javascript
// 관리자 토큰 획득
const token = await firebase.auth().currentUser.getIdToken();

// 업소록 승인
const result = await func('approve_company', {
  token: token,
  idx: 123
});

console.log('업소록이 승인되었습니다:', result.name);
console.log('상태:', result.status); // 'a'
```

**관리자 페이지에서 승인 처리**:
```javascript
async function approveCompany(companyIdx) {
  if (!confirm('이 업소록을 승인하시겠습니까?')) {
    return;
  }

  try {
    const token = await firebase.auth().currentUser.getIdToken();

    const result = await func('approve_company', {
      token: token,
      idx: companyIdx
    });

    alert('업소록이 승인되었습니다.');

    // UI 업데이트
    updateCompanyStatus(companyIdx, 'approved');
  } catch (error) {
    if (error.error && error.error.code === 'admin-only') {
      alert('관리자만 승인할 수 있습니다.');
    } else {
      alert('승인 처리 중 오류가 발생했습니다.');
    }
  }
}
```

#### 에러 처리

**에러 코드**: `admin-only`
- **HTTP 상태**: 403
- **메시지**: "관리자가 아닙니다"
- **발생 조건**: 관리자 권한이 없는 사용자가 호출한 경우

```javascript
const result = await func('approve_company', {
  token: token,
  idx: 123
});

if (result.error) {
  if (result.error.code === 'admin-only') {
    console.error('관리자 권한이 필요합니다.');
  }
}
```

---

### reject_company

**업소록 정보를 거부합니다.**

#### 함수 정의

```php
function reject_company(array $in): array
```

**파일 위치**: `lib/company.functions.php:469`

#### 설명

관리자가 승인된 업소록을 거부하거나 보류 상태로 변경합니다. 거부된 업소록은 `status`가 `p`(pending)로 변경되어 공개 목록에서 제외됩니다.

**권한**: 관리자만 사용 가능

#### 입력 파라미터

**필수 파라미터**:
- `token` (string) - Firebase ID 토큰 (관리자 권한 확인용)
- `idx` (int) - 거부할 업소록 번호

#### 리턴 값

**타입**: `array`

거부된 업소록 전체 정보를 리턴합니다.

**주요 필드**:
- `idx` - 업소록 번호
- `status` - 상태 (`p` = pending)
- `name` - 업소 이름
- 기타 업소록 정보

#### 사용 예제

**업소록 거부**:
```javascript
// 관리자 토큰 획득
const token = await firebase.auth().currentUser.getIdToken();

// 업소록 거부
const result = await func('reject_company', {
  token: token,
  idx: 123
});

console.log('업소록이 거부되었습니다:', result.name);
console.log('상태:', result.status); // 'p'
```

**관리자 페이지에서 거부 처리**:
```javascript
async function rejectCompany(companyIdx) {
  const reason = prompt('거부 사유를 입력하세요:');

  if (!reason) {
    alert('거부 사유를 입력해주세요.');
    return;
  }

  try {
    const token = await firebase.auth().currentUser.getIdToken();

    const result = await func('reject_company', {
      token: token,
      idx: companyIdx
    });

    alert('업소록이 거부되었습니다.');

    // 거부 사유를 업소 소유자에게 알림 (별도 처리)
    await notifyRejection(companyIdx, reason);

    // UI 업데이트
    updateCompanyStatus(companyIdx, 'pending');
  } catch (error) {
    if (error.error && error.error.code === 'admin-only') {
      alert('관리자만 거부할 수 있습니다.');
    } else {
      alert('거부 처리 중 오류가 발생했습니다.');
    }
  }
}
```

**승인/거부 토글 기능**:
```javascript
async function toggleCompanyApproval(companyIdx, currentStatus) {
  const token = await firebase.auth().currentUser.getIdToken();

  try {
    let result;

    if (currentStatus === 'a') {
      // 승인 상태면 거부
      result = await func('reject_company', {
        token: token,
        idx: companyIdx
      });
      alert('업소록이 보류 상태로 변경되었습니다.');
    } else {
      // 보류 상태면 승인
      result = await func('approve_company', {
        token: token,
        idx: companyIdx
      });
      alert('업소록이 승인되었습니다.');
    }

    return result;
  } catch (error) {
    console.error('상태 변경 오류:', error);
    throw error;
  }
}
```

#### 에러 처리

**에러 코드**: `admin-only`
- **HTTP 상태**: 403
- **메시지**: "관리자가 아닙니다"
- **발생 조건**: 관리자 권한이 없는 사용자가 호출한 경우

```javascript
const result = await func('reject_company', {
  token: token,
  idx: 123
});

if (result.error) {
  if (result.error.code === 'admin-only') {
    console.error('관리자 권한이 필요합니다.');
  }
}
```

---

### report

**글 또는 댓글을 신고합니다.**

#### 함수 정의

```php
function report(array $in): array
```

**파일 위치**: `lib/post/report.functions.php:3`

#### 설명

부적절한 게시글이나 댓글을 신고합니다. 한 사용자는 동일한 글/댓글을 한 번만 신고할 수 있습니다. 신고된 항목은 관리자가 확인하여 조치를 취할 수 있습니다.

**권한**: 로그인한 사용자만 사용 가능

#### 입력 파라미터

**필수 파라미터**:
- `token` (string) - Firebase ID 토큰
- `type` (string) - 신고 대상 유형 (`post` 또는 `comment`)
- `idx` (int) - 신고할 글/댓글 번호

#### 리턴 값

**타입**: `array`

**성공 응답**:
```json
{
  "idx": 123,
  "message": "신고가 접수되었습니다."
}
```

#### 사용 예제

**게시글 신고**:
```javascript
const token = await firebase.auth().currentUser.getIdToken();

const result = await func('report', {
  token: token,
  type: 'post',
  idx: 456
});

if (result.idx) {
  alert(result.message); // "신고가 접수되었습니다."
}
```

**댓글 신고**:
```javascript
const token = await firebase.auth().currentUser.getIdToken();

const result = await func('report', {
  token: token,
  type: 'comment',
  idx: 789
});

if (result.idx) {
  alert('댓글이 신고되었습니다.');
}
```

**신고 버튼 구현 (Vue.js)**:
```javascript
methods: {
  async reportPost(postIdx) {
    if (!confirm('이 게시글을 신고하시겠습니까?')) {
      return;
    }

    try {
      const token = await firebase.auth().currentUser.getIdToken();

      const result = await func('report', {
        token: token,
        type: 'post',
        idx: postIdx
      });

      alert(result.message);

      // 신고 완료 표시
      this.isReported = true;
    } catch (error) {
      if (error.error) {
        switch (error.error.code) {
          case 'login-required':
            alert('로그인이 필요합니다.');
            break;
          case 'already-reported':
            alert(error.error.message);
            break;
          default:
            alert('신고 처리 중 오류가 발생했습니다.');
        }
      }
    }
  }
}
```

**신고 상태 확인**:
```javascript
async function checkIfReported(postIdx) {
  try {
    const token = await firebase.auth().currentUser.getIdToken();

    // 신고 시도
    const result = await func('report', {
      token: token,
      type: 'post',
      idx: postIdx
    });

    return false; // 신고되지 않았음
  } catch (error) {
    if (error.error && error.error.code === 'already-reported') {
      return true; // 이미 신고함
    }
    throw error;
  }
}
```

#### 에러 처리

**에러 코드**: `login-required`
- **HTTP 상태**: 401
- **메시지**: "로그인이 필요합니다."
- **발생 조건**: 로그인하지 않은 상태에서 호출한 경우

**에러 코드**: `invalid-parameters`
- **HTTP 상태**: 400
- **메시지**: "유효하지 않은 파라미터입니다."
- **발생 조건**: `type` 또는 `idx`가 누락된 경우

**에러 코드**: `invalid-type`
- **HTTP 상태**: 400
- **메시지**: "유효하지 않은 신고 유형입니다."
- **발생 조건**: `type`이 `post` 또는 `comment`가 아닌 경우

**에러 코드**: `not-found`
- **HTTP 상태**: 404
- **메시지**: "신고할 항목을 찾을 수 없습니다."
- **발생 조건**: 해당 idx의 글/댓글이 존재하지 않는 경우

**에러 코드**: `already-reported`
- **HTTP 상태**: 400
- **메시지**: "이미 신고를 하였습니다."
- **발생 조건**: 이미 신고한 글/댓글을 다시 신고하려고 한 경우

```javascript
try {
  const result = await func('report', {
    token: token,
    type: 'post',
    idx: 123
  });

  alert(result.message);
} catch (error) {
  if (error.error) {
    switch (error.error.code) {
      case 'login-required':
        alert('로그인이 필요합니다.');
        location.href = '/user/login.php';
        break;
      case 'already-reported':
        alert('이미 신고한 게시글입니다.');
        break;
      case 'not-found':
        alert('해당 게시글을 찾을 수 없습니다.');
        break;
      case 'invalid-type':
        alert('잘못된 신고 유형입니다.');
        break;
      default:
        alert('신고 처리 중 오류: ' + error.error.message);
    }
  }
}
```

---

## 함수 사용 시 주의사항

### 1. 단일 값 리턴 함수

일부 함수는 배열이 아닌 **단일 값**을 리턴합니다. 이 경우 JavaScript에서 `result.data`로 접근해야 합니다.

**단일 값을 리턴하는 함수들**:
- `get_user_lang()` - string 리턴
- `family_site_exists()` - boolean 리턴

**올바른 사용법**:
```javascript
// ❌ 잘못된 방법
const lang = await func('get_user_lang', {});
console.log(lang.ko); // undefined

// ✅ 올바른 방법
const result = await func('get_user_lang', {});
const lang = result.data; // 'ko', 'en', 'ja', 'zh'
console.log(lang); // 'ko'
```

```javascript
// ❌ 잘못된 방법
const exists = await func('family_site_exists', { domain: 'test' });
if (exists) { ... } // 항상 true (객체는 truthy)

// ✅ 올바른 방법
const result = await func('family_site_exists', { domain: 'test' });
if (result.data) { // true 또는 false
  alert('도메인이 이미 존재합니다.');
}
```

### 2. Firebase 인증

대부분의 API는 Firebase ID 토큰이 필요합니다.

```javascript
// 토큰 획득
const token = await firebase.auth().currentUser.getIdToken();

// API 호출
const result = await func('update_my_profile', {
  token: token,
  nickname: '닉네임'
});
```

### 3. 에러 처리

모든 API 호출에는 에러 처리를 추가해야 합니다.

```javascript
try {
  const result = await func('function_name', { ... });

  if (result.error) {
    console.error('API 에러:', result.error.code, result.error.message);
    return;
  }

  // 성공 처리
  console.log('성공:', result);
} catch (error) {
  console.error('네트워크 오류:', error);
}
```

### 4. 관리자 권한

일부 함수는 관리자 권한이 필요합니다.

**관리자 전용 함수**:
- `approve_company()`
- `reject_company()`

관리자가 아닌 사용자가 호출하면 `admin-only` 에러가 발생합니다.

---

## API 엔드포인트 상세

> **중요**: 아래에 표시된 엔드포인트는 이해를 돕기 위한 참고 정보입니다. 실제 API 사용 시에는 **`/func.php?func=function_name`** 형식으로 PHP 함수를 직접 호출합니다.
>
> **예시**:
> - ❌ ~~`/api.php?action=app.version`~~
> - ✅ `/func.php?func=app_version`
>
> **상세한 사용법은 [PhilGo API 프로토콜 문서](./philgo-api-protocol.md)를 참조하세요.**

### 앱 관련 API (App)

#### app.version - 앱 버전 정보

**설명**: 현재 앱의 버전 정보를 반환합니다.

**엔드포인트**: `func.php?func=app_version`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**응답 형식**:
```json
{
  "version": "6.0.0"
}
```

**사용 예시**:
```bash
curl "https://local.philgo.com:444/func.php?func=app_version"
```

---

#### app.ping - 서버 연결 확인

**설명**: 서버의 연결 상태를 확인합니다.

**엔드포인트**: `func.php?func=app_ping`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**응답 형식**:
```json
{
  "pong": true,
  "timestamp": 1704067200
}
```

---

#### app.server-info - 서버 정보

**설명**: 서버의 상세 정보를 반환합니다.

**엔드포인트**: `func.php?func=app_server_info`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**응답 형식**:
```json
{
  "server_name": "local.philgo.com",
  "php_version": "8.2.0",
  "database_version": "10.6.0-MariaDB",
  "timezone": "Asia/Manila"
}
```

---

#### app.admins - 관리자 UID 목록

**설명**: 시스템에 등록된 관리자 Firebase UID 목록과 채팅 관리자 UID를 반환합니다. 이 정보는 클라이언트에서 관리자 권한 여부를 확인하거나 관리자 전용 기능을 표시할 때 사용됩니다.

**엔드포인트**: `func.php?func=app_admins`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**응답 형식**:
```json
{
  "admins": [
    "xG3UczB56qazt2fMLH97154Cda62",
    "wbrmRkdyBzNiG9IxUQt6cqv5Ukx1",
    "RaHIcr45pvPzYdcDIv6JoW8DnSH2",
    "sgYFj4mqrhaCDcZqRrYUZ225cjo2",
    "kql4vedC4PYwFJTAMzk7oamACjh1"
  ],
  "chat_admin": "RaHIcr45pvPzYdcDIv6JoW8DnSH2"
}
```

**응답 필드 설명**:
- `admins`: 모든 관리자의 Firebase UID 배열 (ADMINS 상수에서 가져옴)
- `chat_admin`: 채팅 상담 및 자동 메시지 전송용 관리자 UID (get_chat_admin_firebase_uid() 함수에서 가져옴)

**사용 예시**:
```bash
curl "https://local.philgo.com:444/func.php?func=app_admins"
```

**JavaScript 사용 예시**:
```javascript
// 현재 사용자가 관리자인지 확인
async function isAdmin(currentUserUid) {
  const response = await fetch('/func.php?func=app_admins');
  const data = await response.json();
  return data.admins.includes(currentUserUid);
}

// 채팅 관리자 UID 가져오기
async function getChatAdminUid() {
  const response = await fetch('/func.php?func=app_admins');
  const data = await response.json();
  return data.chat_admin;
}
```

**참고 사항**:
- 관리자 UID 목록은 `etc/app.config.php`의 ADMINS 상수에 정의되어 있습니다
- 채팅 관리자는 로컬 환경과 프로덕션 환경에서 다를 수 있습니다
- 이 API는 인증이 필요하지 않으므로 공개적으로 접근 가능합니다
- 클라이언트는 이 정보를 캐시하여 성능을 최적화할 수 있습니다

---

#### app.produce - 프로덕션 데이터 생성

**설명**: 테스트용 프로덕션 데이터를 생성합니다.

**엔드포인트**: `func.php?func=app_produce`

**HTTP 메서드**: POST

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| type | string | 예 | 생성할 데이터 타입 (users, posts, comments 등) |
| count | int | 아니오 | 생성할 데이터 개수 (기본: 10) |

**응답 형식**:
```json
{
  "success": true,
  "type": "users",
  "count": 10,
  "message": "10개의 사용자 데이터가 생성되었습니다."
}
```

### 사용자 관리 API (User)

#### user.verify - Firebase 토큰 검증 및 로그인

**설명**: Firebase ID 토큰을 검증하고 사용자를 로그인합니다. 가입되어 있지 않으면 자동으로 가입 처리합니다.

**엔드포인트**: `func.php?func=user_verify`

**HTTP 메서드**: POST

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |

**응답 형식**:
```json
{
  "idx": 12345,
  "idx_member": 12345,
  "uid": "firebase-uid-string",
  "user_login": "user_login_id",
  "nickname": "사용자닉네임",
  "name": "사용자명",
  "mobile": "+1234567890",
  "email": "user@example.com",
  "point": 100,
  "level": 2,
  "level_progress": 45,
  "stamp": 1704067200,
  "admin": true
}
```

**에러 코드**:
- `token-missing`: Firebase 토큰이 없음
- `phone-number-missing`: 전화번호가 없음
- `invalid-token`: 유효하지 않은 토큰

---

#### user.my - 현재 사용자 정보

**설명**: 현재 로그인한 사용자의 상세 정보를 반환합니다.

**엔드포인트**: `func.php?func=user_my`

**HTTP 메서드**: GET/POST

**인증 필요**: 예 (Firebase 토큰)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |

**응답 형식**:
```json
{
  "idx": 12345,
  "user_login": "user_login_id",
  "nickname": "사용자닉네임",
  "name": "사용자명",
  "mobile": "+1234567890",
  "email": "user@example.com",
  "point": 100,
  "level": 2,
  "level_progress": 45,
  "profile_photo": "https://example.com/photo.jpg",
  "int_8": 0,
  "int_9": 0,
  "varchar_10": ""
}
```

---

#### user.get - 사용자 정보 조회

**설명**: 특정 사용자의 공개 정보를 조회합니다.

**엔드포인트**: `func.php?func=user_get`

**HTTP 메서드**: GET

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 조회할 사용자의 idx |

**응답 형식**:
```json
{
  "idx": 12345,
  "nickname": "사용자닉네임",
  "profile_photo": "https://example.com/photo.jpg",
  "level": 2,
  "point": 100
}
```

---

#### user.list - 사용자 목록

**설명**: 사용자 목록을 페이지네이션과 함께 반환합니다.

**엔드포인트**: `func.php?func=user_list`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| page | int | 아니오 | 페이지 번호 (기본: 1) |
| limit | int | 아니오 | 한 페이지당 항목 수 (기본: 20, 최대: 100) |
| order | string | 아니오 | 정렬 방식 (idx, name, point, level) |

**응답 형식**:
```json
{
  "users": [
    {
      "idx": 12345,
      "nickname": "사용자닉네임",
      "level": 2,
      "point": 100,
      "profile_photo": "https://example.com/photo.jpg"
    }
  ],
  "total": 150,
  "page": 1,
  "limit": 20,
  "total_pages": 8
}
```

---

#### user.select - 사용자 검색

**설명**: 검색어로 사용자를 검색합니다.

**엔드포인트**: `func.php?func=user_select`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| search_term | string | 예 | 검색어 (닉네임, 이름, 이메일 등) |
| limit | int | 아니오 | 결과 수 제한 (기본: 20) |

**응답 형식**:
```json
[
  {
    "idx": 12345,
    "nickname": "사용자닉네임",
    "name": "사용자명",
    "email": "user@example.com"
  }
]
```

---

#### user.update - 사용자 정보 수정

**설명**: 사용자 정보를 수정합니다. 관리자는 다른 사용자의 정보도 수정할 수 있습니다.

**엔드포인트**: `func.php?func=user_update`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 아니오 | 수정할 사용자 idx (관리자만) |
| nickname | string | 아니오 | 닉네임 |
| name | string | 아니오 | 이름 |
| mobile | string | 아니오 | 휴대폰 번호 |
| email | string | 아니오 | 이메일 |
| profile_photo | string | 아니오 | 프로필 사진 URL |
| mode | string | 아니오 | 포인트 수정 모드 (add/subtract) |
| point | int | 아니오 | 포인트 값 (mode와 함께 사용) |

**응답 형식**:
```json
{
  "idx": 12345,
  "nickname": "수정된닉네임",
  "name": "수정된이름",
  "mobile": "+1234567890",
  "email": "updated@example.com",
  "point": 150
}
```

---

#### user.block - 사용자 차단

**설명**: 특정 사용자를 차단합니다. 관리자만 사용 가능합니다.

**엔드포인트**: `func.php?func=user_block`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자만)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | 관리자 Firebase ID 토큰 |
| idx_member | int | 예 | 차단할 사용자의 idx |
| reason | string | 예 | 차단 사유 |

**응답 형식**:
```json
{
  "success": true,
  "idx_member": 12345,
  "blocked_until": 1704153600,
  "block_count": 1,
  "reason": "욕설/모욕"
}
```

**차단 기간**:
- 첫 차단: 24시간
- 재차단: 차단 횟수 × 24시간

---

#### user.merge - 계정 병합

**설명**: 두 개의 Firebase 계정을 하나로 병합합니다.

**엔드포인트**: `func.php?func=user_merge`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| sourceUid | string | 예 | 병합할 소스 Firebase UID |
| targetUid | string | 예 | 병합 대상 Firebase UID |

**응답 형식**:
```json
{
  "success": true,
  "merged_uid": "target-firebase-uid",
  "posts_updated": 15,
  "comments_updated": 42
}
```

---

#### user.merge-old-philgo-id - 구 PhilGo ID 병합

**설명**: 기존 PhilGo v5 계정을 현재 계정으로 병합합니다.

**엔드포인트**: `func.php?func=user_merge_old_philgo_id`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| old_id | string | 예 | 구 PhilGo v5 아이디 |
| password | string | 예 | 구 PhilGo v5 비밀번호 |

**응답 형식**:
```json
{
  "success": true,
  "old_id": "old_user_id",
  "new_idx": 12345,
  "merged_data": {
    "posts": 30,
    "comments": 150,
    "points": 500
  }
}
```

---

#### user.find-id-password - ID/비밀번호 찾기

**설명**: 사용자의 ID 또는 비밀번호를 찾습니다.

**엔드포인트**: `func.php?func=user_find_id_password`

**HTTP 메서드**: POST

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx_member | int | 예 | 사용자의 회원 번호 |
| email | string | 아니오 | 등록된 이메일 |
| mobile | string | 아니오 | 등록된 휴대폰 번호 |

**응답 형식**:
```json
{
  "success": true,
  "user_login": "found_user_id",
  "message": "비밀번호 재설정 링크가 이메일로 발송되었습니다."
}
```

**에러 코드**:
- `not-found`: 회원 정보를 찾을 수 없음
- `password-not-match`: 비밀번호가 틀림

### 게시글 관리 API (Post)

#### post.create - 게시글 작성

**설명**: 새로운 게시글을 작성합니다. Firebase 토큰 또는 API 키로 인증할 수 있습니다.

**엔드포인트**: `func.php?func=post_create`

**HTTP 메서드**: POST

**인증 필요**: 예 (Firebase 토큰 또는 API 키)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 선택 | Firebase ID 토큰 (api_key가 없을 경우 필수) |
| api_key | string | 선택 | API 키 (token이 없을 경우 필수) |
| post_id | string | 예 | 게시판 ID |
| category | string | 아니오 | 카테고리 |
| subject | string | 아니오 | 글 제목 |
| content | string | 아니오 | 글 내용 |
| files | array | 아니오 | 첨부 파일 URL 배열 |
| youtube | string | 아니오 | YouTube 동영상 URL |
| link | string | 아니오 | 외부 링크 |

**응답 형식**:
```json
{
  "idx": 67890,
  "idx_member": 12345,
  "post_id": "freetalk",
  "category": "general",
  "subject": "게시글 제목",
  "content": "게시글 내용",
  "files": ["https://example.com/file1.jpg"],
  "no_of_attach": 1,
  "stamp": 1704067200,
  "uid": "firebase-uid",
  "nickname": "작성자닉네임"
}
```

**에러 코드**:
- `invalid-api-key`: 유효하지 않은 API 키
- `body-or-image-required`: 글 내용과 첨부 파일이 모두 없음
- `post-id-required`: 게시판 ID가 없음

---

#### post.update - 게시글 수정

**설명**: 기존 게시글을 수정합니다.

**엔드포인트**: `func.php?func=post_update`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 수정할 글의 고유 번호 |
| subject | string | 아니오 | 글 제목 |
| content | string | 아니오 | 글 내용 |
| files | array | 아니오 | 첨부 파일 URL 배열 |
| category | string | 아니오 | 카테고리 |

**응답 형식**:
```json
{
  "idx": 67890,
  "subject": "수정된 제목",
  "content": "수정된 내용",
  "files": ["https://example.com/updated.jpg"],
  "updated_at": 1704067300
}
```

---

#### post.delete - 게시글 삭제

**설명**: 게시글을 삭제합니다.

**엔드포인트**: `func.php?func=post_delete`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 삭제할 글의 고유 번호 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 67890,
  "message": "글이 삭제되었습니다."
}
```

---

#### post.get - 게시글 조회

**설명**: 특정 게시글의 정보를 조회합니다.

**엔드포인트**: `func.php?func=post_get`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx | int | 예 | 조회할 글의 고유 번호 |

**응답 형식**:
```json
{
  "idx": 67890,
  "idx_member": 12345,
  "post_id": "freetalk",
  "category": "general",
  "subject": "글 제목",
  "content": "글 내용",
  "files": ["https://example.com/file.jpg"],
  "no_of_comment": 15,
  "no_of_view": 234,
  "good": 10,
  "stamp": 1704067200,
  "user": {
    "nickname": "작성자닉네임",
    "profile_photo": "https://example.com/photo.jpg"
  }
}
```

---

#### post.view - 게시글 상세 보기

**설명**: 게시글과 댓글을 포함한 상세 정보를 조회합니다.

**엔드포인트**: `func.php?func=post_view`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx | int | 예 | 조회할 글의 고유 번호 |

**응답 형식**:
```json
{
  "post": {
    "idx": 67890,
    "subject": "글 제목",
    "content": "글 내용",
    "files": [],
    "user": {
      "nickname": "작성자"
    }
  },
  "comments": [
    {
      "idx": 12345,
      "content": "댓글 내용",
      "user": {
        "nickname": "댓글작성자"
      },
      "stamp": 1704067300
    }
  ]
}
```

---

#### post.list - 게시글 목록

**설명**: 게시글 목록을 페이지네이션과 함께 반환합니다.

**엔드포인트**: `func.php?func=post_list`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| post_id | string | 예 | 게시판 ID |
| category | string | 아니오 | 카테고리 |
| page | int | 아니오 | 페이지 번호 (기본: 1) |
| limit | int | 아니오 | 한 페이지당 글 수 (기본: 20) |
| search_term | string | 아니오 | 검색어 |
| order | string | 아니오 | 정렬 방식 (idx, stamp, no_of_comment) |
| post_count | string | 아니오 | 'n'으로 설정 시 전체 글 수를 세지 않음 (성능 최적화) |
| user_info | string | 아니오 | 'n'으로 설정 시 작성자 정보를 조인하지 않음 (성능 최적화) |
| strip_tags | string | 아니오 | 'y'로 설정 시 글 내용에서 HTML 태그 제거 (보안 강화) |

**Extra Conditions 메커니즘**:
클라이언트가 요청하는 모든 파라미터는 `select_posts_by_page()` 함수의 `extra_conditions` 파라미터로 전달됩니다. 이를 통해 추가적인 조건을 유연하게 적용할 수 있습니다.

**성능 최적화**:
메인 페이지나 대량의 데이터를 빠르게 로드해야 하는 경우, 다음 파라미터들을 사용하여 성능을 최적화할 수 있습니다:

- **post_count=n**: 전체 글 수를 카운트하지 않습니다. 페이지네이션에서 전체 페이지 수가 필요하지 않은 경우 사용하면 쿼리 성능이 크게 향상됩니다.
- **user_info=n**: 각 글의 작성자 정보를 조인하지 않습니다. 사용자 정보가 필요하지 않은 경우 JOIN 쿼리를 생략하여 성능을 개선합니다.
- **strip_tags=y**: 글 내용에서 HTML 태그를 제거하여 순수 텍스트만 반환합니다. XSS 공격 방지와 데이터 전송량 감소 효과가 있습니다.

**최적화 예제 (메인 페이지 글 목록)**:
```
func.php?func=post_list&post_id=qna&post_count=n&user_info=n&strip_tags=y
```

이 요청은 QnA 게시판의 글을 빠르고 안전하게 로드합니다:
- 전체 글 수 카운트 생략 (post_count=n)
- 사용자 정보 JOIN 생략 (user_info=n)
- HTML 태그 제거 (strip_tags=y)

**응답 형식**:
```json
{
  "posts": [
    {
      "idx": 67890,
      "subject": "글 제목",
      "content": "글 내용 일부...",
      "no_of_comment": 5,
      "no_of_view": 123,
      "stamp": 1704067200,
      "nickname": "작성자닉네임",
      "photo_url": "https://example.com/photo.jpg",
      "level": 2,
      "point": 100,
      "has_image": "y",
      "has_video": "n",
      "has_youtube": "y",
      "files": ["https://example.com/image1.jpg"],
      "link": "https://example.com",
      "varchar_17": "https://example.com/image1.jpg", // The first image URL
      "varchar_18": "https://example.com/image2.mp3"  // The first video URL
      "varchar_19": "https://youtu.be/dQw4w9WgXcQ" // The first YouTube URL
    }
  ],
  "total": 150,
  "page": 1,
  "limit": 20,
  "total_pages": 8
}
```

**참고**: 간단한 글 목록을 가져올 때에는, 아래와 같이 하면, 보다 퀘적하게 서버로 부터 데이터를 슬림하게 가져옵니다.
- `post_count=n` 설정 시 응답에서 `total`과 `total_pages` 필드가 생략됩니다.
- `user_info=n` 설정 시 각 글의 `user` 필드가 생략됩니다.
- `strip_tags=y` 설정 시 각 글의 `content` 필드에서 HTML 태그가 제거된 상태로 전달됩니다.
- `minimal_fields=y` 설정 시 각 글의 필드가 제한되어 전달됩니다.


**참고**: 각글의 응답 필드는 아래와 같다. 아래에서 빈 값은 생략되어 전달되어져 오지 않는다.
```
idx, idx_member, post_id, category, subject, subject_private, stamp, stamp_update, no_of_comment, no_of_view, good, link, gid, files, deleted, blind, region, char_1, char_2, char_3, char_4, char_5, char_6, char_7, char_8, char_9, char_10, int_1, int_2, int_3, int_4, int_5, int_6, int_7, int_8, int_9, int_10, varchar_1, varchar_2, varchar_3, varchar_4, varchar_5, varchar_6, varchar_7, varchar_8, varchar_9, varchar_10, varchar_11, varchar_12, varchar_13, varchar_14, varchar_15, varchar_16, varchar_17, varchar_18, varchar_19, varchar_20, text_8, text_9, has_image, has_video, has_youtube
```


**참고**: `minimal_fields=y` 설정 시 응답에서 각 글의 필드가 아래와 같이 제한된다. 특히, text_9 의 값을 가져오지 않습니다. 즉, 서버로 부터 가져오는 데이터의 양이 보다 작아, 빠르게 로드 할 수 있습니다.


---

#### post.latest - 최신 게시글

**설명**: 최신 게시글 목록을 반환합니다.

**엔드포인트**: `func.php?func=post_latest`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| post_id | string | 아니오 | 특정 게시판 ID |
| limit | int | 아니오 | 가져올 글 수 (기본: 10) |
| type | string | 아니오 | post 또는 comment (기본: post) |
| short_content | bool | 아니오 | 내용을 일부만 가져올지 여부 |
| user_info | bool/string | 아니오 | 사용자 정보 포함 여부 (y 또는 true) |
| strip_tags | bool/string | 아니오 | HTML 태그 제거 여부 (y 또는 true) |
| minimal_fields | bool/string | 아니오 | 최소한의 필드만 반환 (y 또는 true) |
| post_count | bool/string | 아니오 | 전체 개수 카운트 포함 (n 또는 false로 생략 가능) |

**type=comment 사용 시 중요사항**:
- `type=comment` 파라미터를 사용하면 최신 댓글 목록을 가져옵니다
- 댓글은 `idx_parent > 0` 조건으로 구분되며, `idx_root`로 원글을 참조할 수 있습니다
- 댓글 응답에는 `subject` 필드가 없고 `content` 필드가 포함됩니다
- 성능 최적화를 위해 `user_info=n`, `strip_tags=y`, `minimal_fields=y` 옵션 사용을 권장합니다

**응답 형식 (type=post)**:
```json
[
  {
    "idx": 67890,
    "idx_member": 12345,
    "post_id": "freetalk",
    "subject": "최신 글 제목",
    "content": "글 내용 일부...",
    "stamp": 1704067200,
    "no_of_comment": 3,
    "nickname": "작성자닉네임",
    "photo_url": "https://example.com/photo.jpg"
  }
]
```

**응답 형식 (type=comment)**:
```json
[
  {
    "idx": 98765,
    "idx_member": 12345,
    "post_id": "freetalk",
    "category": "general",
    "content": "댓글 내용입니다...",
    "no_of_view": 0,
    "good": 2,
    "stamp": 1704067300,
    "idx_root": 67890,
    "nickname": "댓글작성자",
    "photo_url": "https://example.com/photo.jpg"
  }
]
```

**사용 예제**:
```bash
# 최신 게시글 10개
curl "https://local.philgo.com:444/func.php?func=post_latest&limit=10"

# 모든 게시판의 최신 댓글 10개
curl "https://local.philgo.com:444/func.php?func=post_latest&type=comment&limit=10"

# 특정 게시판의 최신 댓글
curl "https://local.philgo.com:444/func.php?func=post_latest&post_id=freetalk&type=comment&limit=20"

# 사용자 정보 포함한 댓글 목록
curl "https://local.philgo.com:444/func.php?func=post_latest&type=comment&limit=10&user_info=y"

# 성능 최적화된 댓글 목록
curl "https://local.philgo.com:444/func.php?func=post_latest&type=comment&limit=10&strip_tags=y&minimal_fields=y"
```

---

#### post.latest-by-attach - 첨부파일 있는 최신글

**설명**: 첨부파일이 있는 최신 게시글 목록을 반환합니다.

**엔드포인트**: `func.php?func=post_latest_by_attach`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| post_id | string | 아니오 | 특정 게시판 ID |
| limit | int | 아니오 | 가져올 글 수 (기본: 10) |

**응답 형식**:
```json
[
  {
    "idx": 67890,
    "subject": "사진이 있는 글",
    "files": [
      "https://example.com/photo1.jpg",
      "https://example.com/photo2.jpg"
    ],
    "no_of_attach": 2,
    "stamp": 1704067200
  }
]
```

---

#### post.latest-by-comments - 댓글 많은 순 게시글

**설명**: 댓글이 많은 순서로 게시글을 반환합니다.

**엔드포인트**: `func.php?func=post_latest_by_comments`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| limit | int | 아니오 | 가져올 글 수 (기본: 10) |
| days | int | 아니오 | 최근 N일 내의 글 (기본: 7) |

**응답 형식**:
```json
[
  {
    "idx": 67890,
    "subject": "인기 글",
    "no_of_comment": 45,
    "no_of_view": 1234,
    "stamp": 1704067200
  }
]
```

---

#### post.latest-by-user - 사용자별 최신글

**설명**: 특정 사용자가 작성한 최신 글 목록을 반환합니다.

**엔드포인트**: `func.php?func=post_latest_by_user`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx_member | int | 선택 | 사용자의 회원 번호 |
| uid | string | 선택 | Firebase UID (idx_member가 없을 때) |
| limit | int | 아니오 | 가져올 글 수 (기본: 10, 최대: 100) |

**주의**: idx_member 또는 uid 중 하나는 반드시 제공되어야 합니다.

**응답 형식**:
```json
[
  {
    "idx": 67890,
    "idx_member": 12345,
    "post_id": "freetalk",
    "category": "general",
    "subject": "사용자가 작성한 글",
    "content": "글 내용 일부...",
    "stamp": 1704067200,
    "no_of_comment": 5,
    "no_of_view": 123,
    "files": []
  }
]
```

**에러 코드**:
- `idx-member-required`: idx_member나 uid가 제공되지 않음
- `limit-too-large`: limit이 100을 초과함

---

#### post.today - 오늘의 게시글

**설명**: 오늘 작성된 게시글 목록을 반환합니다.

**엔드포인트**: `func.php?func=post_today`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| post_id | string | 아니오 | 특정 게시판 ID |

**응답 형식**:
```json
[
  {
    "idx": 67890,
    "subject": "오늘 작성된 글",
    "stamp": 1704067200,
    "hour": "14:30"
  }
]
```

---

#### post.count-view - 조회수 증가

**설명**: 게시글의 조회수를 증가시킵니다.

**엔드포인트**: `func.php?func=post_count_view`

**HTTP 메서드**: POST

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx | int | 예 | 글의 고유 번호 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 67890,
  "no_of_view": 235
}
```

---

#### post.region - 지역별 게시글

**설명**: 특정 지역의 게시글을 반환합니다.

**엔드포인트**: `func.php?func=post_region`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| region | string | 예 | 지역명 (Manila, Cebu, Davao 등) |

**응답 형식**:
```json
[
  {
    "idx": 67890,
    "subject": "Manila 지역 글",
    "region": "Manila",
    "stamp": 1704067200
  }
]
```

---

#### post.news-poster - 뉴스 포스터 이미지

**설명**: 뉴스 게시글의 포스터 이미지를 반환합니다.

**엔드포인트**: `func.php?func=post_news_poster`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| limit | int | 아니오 | 가져올 이미지 수 (기본: 5) |

**응답 형식**:
```json
[
  {
    "idx": 67890,
    "subject": "뉴스 제목",
    "poster_url": "https://example.com/news-poster.jpg",
    "link": "https://news.example.com/article"
  }
]
```

---

#### post.news-link-export - 뉴스 링크 내보내기

**설명**: 뉴스 게시글의 링크를 내보내기 형식으로 반환합니다.

**엔드포인트**: `func.php?func=post_news_link_export`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| limit | int | 아니오 | 가져올 링크 수 (기본: 10) |

**응답 형식**:
```json
[
  {
    "title": "뉴스 제목",
    "link": "https://news.example.com/article",
    "date": "2024-01-01",
    "source": "News Source"
  }
]
```

---

#### post.change-post-id-category - 게시판/카테고리 변경

**설명**: 글의 게시판 ID나 카테고리를 변경합니다.

**엔드포인트**: `func.php?func=post_change_post_id_category`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 글의 고유 번호 |
| post_id | string | 아니오 | 새로운 게시판 ID |
| category | string | 아니오 | 새로운 카테고리 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 67890,
  "post_id": "news",
  "category": "politics"
}
```

---

#### post.approve - 게시글 승인

**설명**: 대기 중인 게시글을 승인합니다.

**엔드포인트**: `func.php?func=post_approve`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 승인할 글의 고유 번호 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 67890,
  "status": "approved",
  "approved_at": 1704067200
}
```

### 댓글 관리 API (Comment)

#### comment.create - 댓글 작성

**설명**: 게시글에 댓글을 작성합니다.

**엔드포인트**: `func.php?func=comment_create`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx_root | int | 예 | 최상위 글의 idx |
| idx_parent | int | 예 | 부모 글/댓글의 idx |
| content | string | 예 | 댓글 내용 |
| files | array | 아니오 | 첨부 파일 URL 배열 |

**응답 형식**:
```json
{
  "idx": 98765,
  "idx_root": 67890,
  "idx_parent": 67890,
  "idx_member": 12345,
  "content": "댓글 내용",
  "files": [],
  "stamp": 1704067300,
  "user": {
    "nickname": "댓글작성자",
    "profile_photo": "https://example.com/photo.jpg"
  }
}
```

---

#### comment.update - 댓글 수정

**설명**: 기존 댓글을 수정합니다.

**엔드포인트**: `func.php?func=comment_update`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 수정할 댓글의 idx |
| content | string | 예 | 수정할 내용 |
| files | array | 아니오 | 첨부 파일 URL 배열 |

**응답 형식**:
```json
{
  "idx": 98765,
  "content": "수정된 댓글 내용",
  "files": [],
  "updated_at": 1704067400
}
```

---

#### comment.delete - 댓글 삭제

**설명**: 댓글을 삭제합니다.

**엔드포인트**: `func.php?func=comment_delete`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 삭제할 댓글의 idx |

**응답 형식**:
```json
{
  "success": true,
  "idx": 98765,
  "message": "댓글이 삭제되었습니다."
}
```

### 게시판 설정 API (Post-Config)

#### post-config.get - 게시판 설정 조회

**설명**: 특정 게시판의 설정 정보를 조회합니다.

**엔드포인트**: `func.php?func=post_config_get`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| post_id | string | 예 | 게시판 ID |

**응답 형식**:
```json
{
  "post_id": "freetalk",
  "name": "자유게시판",
  "description": "자유롭게 이야기하는 공간",
  "categories": ["general", "humor", "info"],
  "point_write": 10,
  "point_write_delete": -10,
  "comment_write": 5,
  "moderation_enabled": true,
  "approval_required": false
}
```

---

#### post-config.create - 게시판 생성

**설명**: 새로운 게시판을 생성합니다.

**엔드포인트**: `func.php?func=post_config_create`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| post_id | string | 예 | 게시판 ID |
| name | string | 예 | 게시판 이름 |
| description | string | 아니오 | 게시판 설명 |
| categories | array | 아니오 | 카테고리 목록 |

**응답 형식**:
```json
{
  "success": true,
  "post_id": "newboard",
  "name": "새 게시판",
  "created_at": 1704067200
}
```

---

#### post-config.update - 게시판 설정 수정

**설명**: 게시판 설정을 수정합니다.

**엔드포인트**: `func.php?func=post_config_update`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| post_id | string | 예 | 게시판 ID |
| name | string | 아니오 | 게시판 이름 |
| description | string | 아니오 | 게시판 설명 |
| point_write | int | 아니오 | 글 작성 포인트 |
| point_write_delete | int | 아니오 | 글 삭제 시 차감 포인트 |
| comment_write | int | 아니오 | 댓글 작성 포인트 |

**응답 형식**:
```json
{
  "success": true,
  "post_id": "freetalk",
  "updated_fields": ["name", "point_write"]
}
```

---

#### post-config.delete - 게시판 삭제

**설명**: 게시판을 삭제합니다.

**엔드포인트**: `func.php?func=post_config_delete`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| post_id | string | 예 | 게시판 ID |

**응답 형식**:
```json
{
  "success": true,
  "post_id": "deletedboard",
  "message": "게시판이 삭제되었습니다."
}
```


### 콘텐츠 검열 API (Moderate)

#### moderate.chat - 채팅 메시지 검열

**설명**: 채팅 메시지를 AI로 검열합니다.

**엔드포인트**: `func.php?func=moderate_chat`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| roomId | string | 예 | 채팅방 ID |
| messageId | string | 예 | 메시지 ID |
| content | string | 예 | 검열할 메시지 내용 |

**응답 형식**:
```json
{
  "flagged": false,
  "category": "safe",
  "reason": "",
  "gambling": false,
  "selling": false,
  "contact": false
}
```

---

#### moderate.gemini-post - Gemini AI 텍스트 검열

**설명**: Google Gemini AI를 사용하여 게시글 텍스트를 검열합니다.

**엔드포인트**: `func.php?func=moderate_gemini_post`

**HTTP 메서듍**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 검열할 글의 idx |

**응답 형식**:
```json
{
  "model": "gemini",
  "flagged": false,
  "category": "safe",
  "reason": "",
  "selling": false,
  "job": false,
  "seek": false,
  "gambling": false,
  "exchange": false,
  "spam": false,
  "contact": false,
  "info_score": 85
}
```

**검열 결과 필드**:
- `flagged`: 차단 필요 여부
- `category`: 검열 카테고리 (safe, violence, adult, etc.)
- `selling`: 판매글 여부
- `job`: 구인글 여부
- `gambling`: 도박/카지노 관련 여부
- `info_score`: 필리핀 정보 점수 (0-100)

---

#### moderate.omni-post - OpenAI 이미지 검열

**설명**: OpenAI API를 사용하여 이미지를 검열합니다.

**엔드포인트**: `func.php?func=moderate_omni_post`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 검열할 글의 idx |

**응답 형식**:
```json
{
  "model": "omni",
  "flagged": false,
  "category": "safe",
  "reason": "",
  "images_checked": 2
}
```


### 포인트 시스템 API (Point)

#### point.update - 포인트 수정

**설명**: 관리자가 사용자의 포인트를 수정합니다.

**엔드포인트**: `func.php?func=point_update`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 사용자 idx |
| mode | string | 예 | add(추가) 또는 subtract(감소) |
| point | int | 예 | 포인트 값 (양의 정수) |
| reason | string | 아니오 | 포인트 변경 사유 |

**응답 형식**:
```json
{
  "success": true,
  "idx_member": 12345,
  "previous_point": 100,
  "new_point": 150,
  "change": 50,
  "mode": "add"
}
```

---

#### point.list - 포인트 광고 목록

**설명**: 포인트 광고 목록을 조회합니다.

**엔드포인트**: `func.php?func=point_list`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| post_id | string | 아니오 | 게시판 ID |
| category | string | 아니오 | 카테고리 |
| limit | int | 아니오 | 결과 수 제한 |

**응답 형식**:
```json
[
  {
    "idx": 67890,
    "subject": "포인트 광고 제목",
    "content": "광고 내용",
    "int_5": 1704153600,
    "int_6": 1704067200,
    "int_7": 7,
    "int_8": 100,
    "int_10": 500
  }
]
```

**필드 설명**:
- `int_5`: 광고 종료 시간
- `int_6`: 광고 시작 시간
- `int_7`: 광고 일수
- `int_8`: 사용한 포인트
- `int_10`: 획득 가능 포인트

---

#### point.log - 포인트 기록 조회

**설명**: 포인트 변경 기록을 조회합니다.

**엔드포인트**: `func.php?func=point_log`

**HTTP 메서드**: GET

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx_member | int | 아니오 | 특정 사용자 idx (관리자만) |
| page | int | 아니오 | 페이지 번호 (기본: 1) |
| limit | int | 아니오 | 한 페이지당 항목 수 (기본: 20) |

**응답 형식**:
```json
{
  "logs": [
    {
      "idx": 123,
      "idx_member": 12345,
      "point_change": 10,
      "point_after": 110,
      "reason": "글 작성",
      "etc": "post-create",
      "stamp": 1704067200
    },
    {
      "idx": 124,
      "idx_member": 12345,
      "point_change": -100,
      "point_after": 10,
      "reason": "포인트 광고",
      "etc": "point-ad",
      "stamp": 1704067300
    }
  ],
  "total": 50,
  "page": 1,
  "limit": 20
}
```

---

#### point.post - 포인트 광고 등록

**설명**: 게시글을 포인트 광고로 등록합니다.

**엔드포인트**: `func.php?func=point_post`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 광고할 글의 idx |
| days | int | 예 | 광고 일수 |
| points | int | 예 | 사용할 포인트 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 67890,
  "start_time": 1704067200,
  "end_time": 1704672000,
  "days": 7,
  "points_used": 100,
  "remaining_points": 400
}
```

---

#### point.event-info - 포인트 이벤트 정보

**설명**: 현재 진행 중인 포인트 이벤트 정보를 조회합니다.

**엔드포인트**: `func.php?func=point_event_info`

**HTTP 메서드**: GET

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |

**응답 형식**:
```json
{
  "active_events": [
    {
      "event_id": "new_year_2024",
      "name": "새해 포인트 이벤트",
      "description": "로그인 시 2배 포인트",
      "multiplier": 2,
      "start_date": "2024-01-01",
      "end_date": "2024-01-31"
    }
  ],
  "user_points": 500,
  "user_level": 3
}
```


### 업소록 API (Company)

#### company.get - 업소 정보 조회

**설명**: 특정 업소의 상세 정보를 조회합니다.

**엔드포인트**: `func.php?func=company_get`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx | int | 예 | 업소 idx |

**응답 형식**:
```json
{
  "idx": 100,
  "idx_member": 12345,
  "name": "업소명",
  "category": "restaurant",
  "location": "Manila",
  "address": "상세 주소",
  "phone": "+63 2 1234 5678",
  "email": "info@company.com",
  "website": "https://company.com",
  "description": "업소 설명",
  "business_hours": "09:00-18:00",
  "status": "a",
  "stamp": 1704067200
}
```

---

#### company.list - 업소 목록

**설명**: 업소 목록을 조회합니다.

**엔드포인트**: `func.php?func=company_list`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| category | string | 아니오 | 업소 카테고리 |
| location | string | 아니오 | 지역 |
| page | int | 아니오 | 페이지 번호 |
| limit | int | 아니오 | 한 페이지당 항목 수 |

**응답 형식**:
```json
[
  {
    "idx": 100,
    "name": "업소명",
    "category": "restaurant",
    "location": "Manila",
    "phone": "+63 2 1234 5678",
    "status": "a"
  }
]
```

---

#### company.mine - 내 업소 정보

**설명**: 현재 로그인한 사용자의 업소 정보를 조회합니다.

**엔드포인트**: `func.php?func=company_mine`

**HTTP 메서드**: GET

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |

**응답 형식**:
```json
{
  "idx": 100,
  "name": "내 업소",
  "category": "shop",
  "location": "Cebu",
  "status": "a",
  "can_edit": true
}
```

---

#### company.update - 업소 정보 수정

**설명**: 업소 정보를 수정합니다.

**엔드포인트**: `func.php?func=company_update`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 업소 idx |
| name | string | 아니오 | 업소명 |
| category | string | 아니오 | 카테고리 |
| location | string | 아니오 | 지역 |
| address | string | 아니오 | 주소 |
| phone | string | 아니오 | 전화번호 |
| email | string | 아니오 | 이메일 |
| website | string | 아니오 | 웹사이트 |
| description | string | 아니오 | 설명 |
| business_hours | string | 아니오 | 영업시간 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 100,
  "updated_fields": ["name", "phone", "address"]
}
```

---

#### company.delete - 업소 삭제

**설명**: 업소를 삭제합니다.

**엔드포인트**: `func.php?func=company_delete`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 업소 idx |

**응답 형식**:
```json
{
  "success": true,
  "idx": 100,
  "message": "업소가 삭제되었습니다."
}
```

---

#### company.approve - 업소 승인

**설명**: 관리자가 업소를 승인합니다.

**엔드포인트**: `func.php?func=company_approve`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 업소 idx |

**응답 형식**:
```json
{
  "success": true,
  "idx": 100,
  "status": "a",
  "approved_at": 1704067200
}
```

---

#### company.reject - 업소 반려

**설명**: 관리자가 업소를 반려합니다.

**엔드포인트**: `func.php?func=company_reject`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 업소 idx |
| reason | string | 예 | 반려 사유 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 100,
  "status": "r",
  "reason": "정보 불충분"
}
```

---

#### company.locations - 업소 위치 목록

**설명**: 등록된 업소들의 위치 목록을 반환합니다.

**엔드포인트**: `func.php?func=company_locations`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**응답 형식**:
```json
[
  "Manila",
  "Cebu",
  "Davao",
  "Makati",
  "Quezon City"
]
```

---

#### company.info - 업소 상세 정보

**설명**: 업소의 상세 정보와 메타 데이터를 포함하여 조회합니다.

**엔드포인트**: `func.php?func=company_info`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx | int | 예 | 업소 idx |

**응답 형식**:
```json
{
  "company": {
    "idx": 100,
    "name": "업소명",
    "category": "restaurant",
    "location": "Manila"
  },
  "meta": [
    {
      "key": "parking",
      "value": "available"
    },
    {
      "key": "payment_methods",
      "value": "cash, credit card"
    }
  ],
  "reviews": {
    "count": 15,
    "average_rating": 4.5
  }
}
```

---

#### company.info-by-idx-member - 회원별 업소 정보

**설명**: 특정 회원이 등록한 업소 정보를 조회합니다.

**엔드포인트**: `func.php?func=company_info_by_idx_member`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx_member | int | 예 | 회원 idx |

**응답 형식**:
```json
{
  "idx": 100,
  "idx_member": 12345,
  "name": "회원의 업소",
  "category": "service",
  "status": "a"
}
```

---

#### company.get-by-idx-member - 회원별 업소 조회

**설명**: 특정 회원이 등록한 모든 업소를 조회합니다.

**엔드포인트**: `func.php?func=company_get_by_idx_member`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx_member | int | 예 | 회원 idx |

**응답 형식**:
```json
[
  {
    "idx": 100,
    "name": "업소 1",
    "category": "restaurant",
    "status": "a"
  },
  {
    "idx": 101,
    "name": "업소 2",
    "category": "shop",
    "status": "a"
  }
]
```


### 광고 관리 API (Advertisement)

#### advertisement.create - 광고 생성

**설명**: 새로운 광고를 생성합니다.

**엔드포인트**: `func.php?func=advertisement_create`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| title | string | 예 | 광고 제목 |
| description | string | 아니오 | 광고 설명 |
| position | string | 예 | 광고 위치 (top, side, bottom) |
| start_date | string | 예 | 시작일 (YYYY-MM-DD) |
| end_date | string | 예 | 종료일 (YYYY-MM-DD) |
| url | string | 예 | 광고 클릭 시 이동 URL |

**응답 형식**:
```json
{
  "idx": 200,
  "title": "광고 제목",
  "position": "top",
  "start_date": "2024-01-01",
  "end_date": "2024-01-31",
  "status": "active",
  "created_at": 1704067200
}
```

---

#### advertisement.update - 광고 수정

**설명**: 기존 광고를 수정합니다.

**엔드포인트**: `func.php?func=advertisement_update`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 광고 idx |
| title | string | 아니오 | 광고 제목 |
| description | string | 아니오 | 광고 설명 |
| position | string | 아니오 | 광고 위치 |
| url | string | 아니오 | 광고 URL |

**응답 형식**:
```json
{
  "success": true,
  "idx": 200,
  "updated_fields": ["title", "url"]
}
```

---

#### advertisement.get - 광고 조회

**설명**: 특정 광고의 상세 정보를 조회합니다.

**엔드포인트**: `func.php?func=advertisement_get`

**HTTP 메서드**: GET

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 광고 idx |

**응답 형식**:
```json
{
  "idx": 200,
  "title": "광고 제목",
  "description": "광고 설명",
  "position": "top",
  "url": "https://example.com",
  "banners": [
    {
      "url": "https://example.com/banner1.jpg",
      "target": "_blank"
    }
  ],
  "views": 1234,
  "clicks": 56
}
```

---

#### advertisement.all - 전체 광고 목록

**설명**: 현재 활성화된 모든 광고를 조회합니다.

**엔드포인트**: `func.php?func=advertisement_all`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**응답 형식**:
```json
[
  {
    "idx": 200,
    "title": "광고 1",
    "position": "top",
    "banners": [
      {
        "url": "https://example.com/banner1.jpg",
        "link": "https://example.com"
      }
    ]
  },
  {
    "idx": 201,
    "title": "광고 2",
    "position": "side",
    "banners": [
      {
        "url": "https://example.com/banner2.jpg",
        "link": "https://example.com"
      }
    ]
  }
]
```

---

#### advertisement.add-banner - 배너 추가

**설명**: 광고에 배너 이미지를 추가합니다.

**엔드포인트**: `func.php?func=advertisement_add_banner`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 광고 idx |
| banner | object | 예 | 배너 정보 (url, link, target) |

**요청 예시**:
```json
{
  "token": "firebase-token",
  "idx": 200,
  "banner": {
    "url": "https://example.com/new-banner.jpg",
    "link": "https://example.com/promo",
    "target": "_blank"
  }
}
```

**응답 형식**:
```json
{
  "success": true,
  "idx": 200,
  "banner_count": 2
}
```

---

#### advertisement.update-banner - 배너 수정

**설명**: 광고의 특정 배너를 수정합니다.

**엔드포인트**: `func.php?func=advertisement_update_banner`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 광고 idx |
| index | int | 예 | 배너 인덱스 (0부터 시작) |
| banner | object | 예 | 수정할 배너 정보 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 200,
  "index": 0
}
```

---

#### advertisement.delete-banner - 배너 삭제

**설명**: 광고의 특정 배너를 삭제합니다.

**엔드포인트**: `func.php?func=advertisement_delete_banner`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 광고 idx |
| index | int | 예 | 삭제할 배너 인덱스 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 200,
  "remaining_banners": 1
}
```


### 패밀리 사이트 API (Family-Site)

#### family-site.get - 패밀리 사이트 정보

**설명**: 패밀리 사이트 정보를 조회합니다. 메인 페이지 SEO 및 SSR을 위한 콘텐츠를 제공합니다.

**엔드포인트**: `func.php?func=family_site_get`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| section | string | 아니오 | 섹션 타입 (blog-, contact-, photo-, video-, youtube-) |

**응답 형식**:
```json
{
  "site_info": {
    "name": "PhilGo",
    "description": "필리핀 교민 커뮤니티",
    "url": "https://www.philgo.com"
  },
  "sections": {
    "blog": [
      {
        "idx": 12345,
        "title": "최근 블로그 글",
        "excerpt": "내용 요약...",
        "url": "/post/view/12345"
      }
    ],
    "contact": {
      "email": "info@philgo.com",
      "phone": "+63 2 1234 5678",
      "address": "Manila, Philippines"
    }
  }
}
```

**섹션 타입**:
- `blog-`: 최근 블로그 12개
- `contact-`: 연락처 정보
- `photo-`: 사진 콘텐츠
- `video-`: 비디오 콘텐츠
- `youtube-`: YouTube 콘텐츠

---

#### family-site.create - 패밀리 사이트 생성

**설명**: 새로운 패밀리 사이트를 등록합니다.

**엔드포인트**: `func.php?func=family_site_create`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| name | string | 예 | 사이트명 |
| url | string | 예 | 사이트 URL |
| description | string | 아니오 | 사이트 설명 |
| category | string | 아니오 | 카테고리 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 10,
  "name": "새 패밀리 사이트",
  "created_at": 1704067200
}
```

---

#### family-site.update - 패밀리 사이트 수정

**설명**: 패밀리 사이트 정보를 수정합니다.

**엔드포인트**: `func.php?func=family_site_update`

**HTTP 메서드**: POST

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 사이트 idx |
| name | string | 아니오 | 사이트명 |
| url | string | 아니오 | 사이트 URL |
| description | string | 아니오 | 사이트 설명 |

**응답 형식**:
```json
{
  "success": true,
  "idx": 10,
  "updated_fields": ["name", "url"]
}
```


### 파일 관리 API (File)

#### file.upload - 파일 업로드

**설명**: 서버에 파일을 업로드합니다. 이미지, 문서 등 다양한 파일 형식을 지원합니다.

**엔드포인트**:
- 로컬: `https://local.philgo.com/v5-files/upload.php`
- 프로덕션: `https://file.philgo.com/v5-files/upload.php`

**HTTP 메서드**: POST (multipart/form-data)

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| uid | string | 예 | Firebase UID (사용자 인증) |
| file | file | 예 | 업로드할 파일 (multipart/form-data) |
| deleteFile | string | 아니오 | 삭제할 기존 파일 URL (단일 파일 교체 시) |
| decodeQrCode | string | 아니오 | 'Y'로 설정 시 이미지의 QR 코드 디코딩 |

**응답 형식**:
- `deleted`: 입력 파라메타가의 `deelteFile` 에 값이 있으면, 삭제되었으면 true, 아니면, false.
```json
{
  "url": "https://file.philgo.com/uploads/2024/01/image_123456.jpg",
  "deleted": true, // 
  "qr_code": "QR코드내용" // decodeQrCode=Y인 경우만
}
```

**에러 코드**:
- `no-uid`: Firebase UID가 없음
- `no-file`: 업로드할 파일이 없음
- `upload-failed`: 파일 업로드 실패
- `file-too-large`: 파일 크기 초과
- `invalid-file-type`: 허용되지 않은 파일 형식

**파일 크기 제한**:
- 이미지: 최대 10MB
- 문서: 최대 20MB
- 동영상: 최대 100MB

**허용 파일 형식**:
- 이미지: jpg, jpeg, png, gif, webp, svg
- 문서: pdf, doc, docx, xls, xlsx, ppt, pptx
- 압축: zip, rar, 7z
- 동영상: mp4, avi, mov, wmv

---

#### file.delete - 파일 삭제

**설명**: 서버에 업로드된 파일을 삭제합니다.

**엔드포인트**:
- 로컬: `https://local.philgo.com/v5-files/delete.php`
- 프로덕션: `https://file.philgo.com/v5-files/delete.php`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| uid | string | 예 | Firebase UID (파일 소유자 확인) |
| url | string | 예 | 삭제할 파일의 전체 URL |

**응답 형식**:
```json
{
  "success": true,
  "url": "https://file.philgo.com/uploads/2024/01/image_123456.jpg",
  "message": "파일이 성공적으로 삭제되었습니다."
}
```

**에러 코드**:
- `no-uid`: Firebase UID가 없음
- `no-url`: 삭제할 파일 URL이 없음
- `file-not-found`: 파일을 찾을 수 없음
- `permission-denied`: 파일 삭제 권한 없음
- `delete-failed`: 파일 삭제 실패

---

#### 파일 업로드 JavaScript 라이브러리 사용법

PhilGo는 파일 업로드를 쉽게 처리할 수 있는 JavaScript 라이브러리를 제공합니다. 이 라이브러리는 `widgets/file/upload/upload-v2.php`에 정의되어 있으며, Alpine.js와 함께 사용하도록 설계되었습니다.

**라이브러리 포함 방법**:
```php
<?php include 'widgets/file/upload/upload-v2.php'; ?>
```

**주요 함수**:

1. **initFileUpload(uploadId, initialFiles, extra)**: 파일 업로드 컨텍스트 초기화
   - `uploadId`: 고유 업로드 식별자
   - `initialFiles`: 기존 파일 URL 목록 (콤마 구분 문자열)
   - `extra`: 추가 옵션 객체
     - `single`: true로 설정 시 단일 파일만 허용
     - `decodeQrCode`: true로 설정 시 QR 코드 자동 디코딩

2. **uploadFile(event, context)**: 파일 업로드 처리
   - `event`: 파일 선택 이벤트
   - `context`: 업로드 컨텍스트 객체

3. **deleteFile(url, context)**: 파일 삭제 처리
   - `url`: 삭제할 파일 URL
   - `context`: 업로드 컨텍스트 객체

**컨텍스트 객체 속성**:
- `files`: 업로드된 파일 URL 배열
- `progress`: 업로드 진행률 (0-100)
- `add(file)`: 파일 추가
- `addFiles(files)`: 여러 파일 추가
- `clear()`: 파일 목록 초기화
- `handleFileChange(event)`: 파일 선택 이벤트 처리
- `handleDelete(url)`: 파일 삭제 처리

---

#### Alpine.js와 함께 사용하기

**기본 설정**:
```html
<div x-data="initFileUpload('myUpload', '')">
    <!-- 파일 선택 버튼 -->
    <input type="file" @change="handleFileChange($event)" accept="image/*">

    <!-- 업로드 진행률 표시 -->
    <div x-show="progress > 0" class="progress">
        <div class="progress-bar" :style="`width: ${progress}%`"></div>
    </div>

    <!-- 업로드된 파일 목록 -->
    <div class="uploaded-files">
        <template x-for="file in files" :key="file">
            <div class="file-item">
                <img :src="file" alt="Uploaded file" style="max-width: 200px;">
                <button @click="handleDelete(file)" class="btn btn-sm btn-danger">삭제</button>
            </div>
        </template>
    </div>
</div>
```

---

#### 단일 파일 업로드 예제

단일 파일만 허용하고 기존 파일을 자동으로 교체하는 예제입니다.

```html
<div x-data="initFileUpload('profilePhoto', '<?= $user['profile_photo'] ?? '' ?>', { single: true })">
    <h4>프로필 사진</h4>

    <!-- 현재 프로필 사진 -->
    <div x-show="files.length > 0" class="current-photo mb-3">
        <img :src="files[0]" alt="프로필 사진" class="rounded-circle" style="width: 150px; height: 150px; object-fit: cover;">
    </div>

    <!-- 파일 선택 -->
    <div class="mb-3">
        <label class="form-label">새 프로필 사진 선택</label>
        <input type="file"
               class="form-control"
               @change="handleFileChange($event)"
               accept="image/jpeg,image/png,image/gif">
    </div>

    <!-- 업로드 진행률 -->
    <div x-show="progress > 0" class="progress mb-3" style="height: 5px;">
        <div class="progress-bar progress-bar-striped progress-bar-animated"
             :style="`width: ${progress}%`"></div>
    </div>

    <!-- 삭제 버튼 -->
    <button x-show="files.length > 0"
            @click="handleDelete(files[0])"
            class="btn btn-outline-danger btn-sm">
        <i class="fas fa-trash"></i> 프로필 사진 삭제
    </button>
</div>
```

---

#### 다중 파일 업로드 예제

여러 파일을 업로드하고 관리하는 예제입니다.

```html
<div x-data="initFileUpload('postImages', '')">
    <h4>게시글 이미지 (최대 10개)</h4>

    <!-- 파일 선택 -->
    <div class="mb-3">
        <input type="file"
               class="form-control"
               @change="handleFileChange($event)"
               accept="image/*"
               multiple
               :disabled="files.length >= 10">
        <div class="form-text">
            현재 <span x-text="files.length"></span>/10개 업로드됨
        </div>
    </div>

    <!-- 업로드 진행률 -->
    <div x-show="progress > 0" class="progress mb-3">
        <div class="progress-bar bg-success"
             :style="`width: ${progress}%`"
             x-text="`${progress}%`"></div>
    </div>

    <!-- 업로드된 이미지 갤러리 -->
    <div class="row g-2">
        <template x-for="(file, index) in files" :key="file">
            <div class="col-6 col-md-3">
                <div class="card">
                    <img :src="file" class="card-img-top" alt="업로드 이미지">
                    <div class="card-body p-2">
                        <button @click="handleDelete(file)"
                                class="btn btn-sm btn-danger w-100">
                            <i class="fas fa-times"></i> 삭제
                        </button>
                    </div>
                </div>
            </div>
        </template>
    </div>

    <!-- 폼 제출 시 파일 URL 전송 -->
    <input type="hidden" name="files" :value="files.join(',')">
</div>
```

---

#### QR 코드 디코딩 예제

이미지에서 QR 코드를 자동으로 디코딩하는 예제입니다.

```html
<div x-data="{
    ...initFileUpload('qrScanner', '', { decodeQrCode: true }),
    qrContent: ''
}">
    <h4>QR 코드 스캔</h4>

    <!-- QR 코드 이미지 선택 -->
    <div class="mb-3">
        <label class="form-label">QR 코드가 포함된 이미지를 선택하세요</label>
        <input type="file"
               class="form-control"
               @change="async (e) => {
                   const result = await handleFileChange(e);
                   if (result && result.qr_code) {
                       qrContent = result.qr_code;
                   }
               }"
               accept="image/*">
    </div>

    <!-- 업로드 진행률 -->
    <div x-show="progress > 0" class="progress mb-3">
        <div class="progress-bar progress-bar-striped"
             :style="`width: ${progress}%`"></div>
    </div>

    <!-- 업로드된 이미지 -->
    <div x-show="files.length > 0" class="mb-3">
        <img :src="files[0]" alt="QR 코드 이미지" class="img-fluid" style="max-width: 300px;">
    </div>

    <!-- 디코딩된 QR 코드 내용 -->
    <div x-show="qrContent" class="alert alert-success">
        <h5>QR 코드 내용:</h5>
        <pre x-text="qrContent"></pre>
    </div>

    <!-- 삭제 및 재시도 -->
    <button x-show="files.length > 0"
            @click="() => { handleDelete(files[0]); qrContent = ''; }"
            class="btn btn-secondary">
        <i class="fas fa-redo"></i> 다시 스캔
    </button>
</div>
```

**서버 응답 처리**:

업로드 성공 시 서버는 다음과 같은 응답을 반환합니다:
```javascript
{
    "url": "https://file.philgo.com/uploads/2024/01/qr_image.jpg",
    "qr_code": "https://example.com/scanned-content" // QR 코드 내용
}
```

**주의사항**:
- QR 코드 디코딩은 서버 리소스를 사용하므로 필요한 경우에만 활성화하세요
- 이미지 품질이 낮거나 QR 코드가 명확하지 않으면 디코딩이 실패할 수 있습니다
- 여러 QR 코드가 있는 경우 첫 번째로 발견된 코드만 디코딩됩니다


### 검색 API (Search)

#### search.fulltext-search - 전체 텍스트 검색

**설명**: 전체 텍스트 검색을 수행합니다.

**엔드포인트**: `func.php?func=search_fulltext_search`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| search_term | string | 예 | 검색어 |
| post_id | string | 아니오 | 특정 게시판에서만 검색 |
| page | int | 아니오 | 페이지 번호 (기본: 1) |
| limit | int | 아니오 | 한 페이지당 결과 수 (기본: 20) |

**응답 형식**:
```json
{
  "results": [
    {
      "idx": 67890,
      "post_id": "freetalk",
      "subject": "검색된 글 제목",
      "content": "검색어가 포함된 내용...",
      "match_score": 0.95,
      "stamp": 1704067200
    }
  ],
  "total": 42,
  "page": 1,
  "search_term": "검색어"
}
```

---

#### search.vector-search - 벡터 검색

**설명**: AI 기반 벡터 검색을 수행합니다.

**엔드포인트**: `func.php?func=search_vector_search`

**HTTP 메서듍**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| query | string | 예 | 검색 쿼리 |
| limit | int | 아니오 | 결과 수 제한 (기본: 10) |

**응답 형식**:
```json
[
  {
    "idx": 67890,
    "subject": "유사한 글 제목",
    "content": "의미적으로 유사한 내용...",
    "similarity": 0.89,
    "post_id": "freetalk"
  }
]
```


### 도움말 API (Help)

#### help.terms-and-conditions - 이용약관

**설명**: 지정된 언어로 이용약관 전체 텍스트를 가져옵니다.

**엔드포인트**: `func.php?func=help_terms_and_conditions`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| lang | string | 아니오 | 언어 코드 (ko, en, ja, zh). 기본값: ko |

**응답 형식**:
```json
{
  "terms": "이용약관\n\n시행일: 2023년 2월 8일\n\n제 1 장 총칙\n\n제 1 조 (목적)\n본 약관은 PhilGo 웹사이트 및 앱 서비스의 이용에 관한 사항을 규정합니다.\n\n제 2 조 (약관의 효력 및 변경)\n..."
}
```

**특징**:
- 15개 조항과 부칙을 포함한 전체 이용약관 텍스트 반환
- 지원되지 않는 언어 코드는 한국어로 자동 폴백
- 플레인 텍스트 형식으로 반환 (줄바꿈과 구분선 포함)

---

#### help.privacy - 개인정보 처리방침

**설명**: 지정된 언어로 개인정보 처리방침을 가져옵니다.

**엔드포인트**: `func.php?func=help_privacy`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| lang | string | 아니오 | 언어 코드 (ko, en, ja, zh). 기본값: ko |

**응답 형식**:
```json
{
  "privacy": "개인정보 처리방침\n\nPhilGo는 사용자의 개인정보를 중요시합니다.\n\n1. 수집하는 개인정보\n..."
}
```


**용도**: 지정된 언어로 이용약관 전체 텍스트를 가져옵니다.

**엔드포인트**: `func.php?func=help_terms_and_conditions`

**파라미터**:
- `lang` (선택): 언어 코드 (ko, en, ja, zh). 기본값: ko
  - `ko`: 한국어
  - `en`: 영어
  - `ja`: 일본어
  - `zh`: 중국어

**응답 형식**:
```json
{
  "terms": "이용약관\n\n시행일: 2023년 2월 8일\n\n제 1 장 총칙\n..."
}
```

**사용 예시**:
```bash
# 한국어 이용약관 (기본값)
curl "https://local.philgo.com:444/func.php?func=help_terms_and_conditions"

# 영어 이용약관
curl "https://local.philgo.com:444/func.php?func=help_terms_and_conditions&lang=en"

# 일본어 이용약관
curl "https://local.philgo.com:444/func.php?func=help_terms_and_conditions&lang=ja"
```

**특징**:
- 15개 조항과 부칙을 포함한 전체 이용약관 텍스트 반환
- 지원되지 않는 언어 코드는 한국어로 자동 폴백
- 플레인 텍스트 형식으로 반환 (줄바꿈과 구분선 포함)

### 기타 기능 API

#### like.like - 좋아요 토글

**설명**: 게시글이나 댓글에 좋아요를 토글합니다.

**엔드포인트**: `func.php?func=like_like`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| idx | int | 예 | 글/댓글의 idx |
| mode | string | 예 | like(좋아요) 또는 unlike(취소) |

**응답 형식**:
```json
{
  "success": true,
  "idx": 67890,
  "liked": true,
  "total_likes": 25
}
```

---

#### report.report - 신고하기

**설명**: 게시글이나 댓글을 신고합니다.

**엔드포인트**: `func.php?func=report_report`

**HTTP 메서드**: POST

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx | int | 예 | 신고할 글/댓글의 idx |
| reason | string | 예 | 신고 사유 |
| details | string | 아니오 | 상세 내용 |

**응답 형식**:
```json
{
  "success": true,
  "report_id": 456,
  "message": "신고가 접수되었습니다."
}
```

---

#### report.list - 신고 목록

**설명**: 신고 목록을 조회합니다.

**엔드포인트**: `func.php?func=report_list`

**HTTP 메서드**: GET

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| page | int | 아니오 | 페이지 번호 (기본: 1) |
| limit | int | 아니오 | 한 페이지당 항목 수 (기본: 20) |

**응답 형식**:
```json
[
  {
    "report_id": 456,
    "idx_post": 67890,
    "reason": "욕설/모욕",
    "details": "상세 내용",
    "reporter_idx": 12345,
    "stamp": 1704067200,
    "status": "pending"
  }
]
```

---

#### social.get - 소셜 정보 조회

**설명**: 사용자의 소셜 미디어 정보를 조회합니다.

**엔드포인트**: `func.php?func=social_get`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| idx_member | int | 예 | 사용자 idx |

**응답 형식**:
```json
{
  "idx_member": 12345,
  "facebook": "https://facebook.com/username",
  "twitter": "@username",
  "instagram": "@username",
  "youtube": "https://youtube.com/channel/...",
  "linkedin": "https://linkedin.com/in/username"
}
```

---

#### social.mine - 내 소셜 정보

**설명**: 현재 로그인한 사용자의 소셜 미디어 정보를 조회합니다.

**엔드포인트**: `func.php?func=social_mine`

**HTTP 메서드**: GET

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |

**응답 형식**: `social.get`과 동일

---

#### social.update - 소셜 정보 수정

**설명**: 사용자의 소셜 미디어 정보를 수정합니다.

**엔드포인트**: `func.php?func=social_update`

**HTTP 메서드**: POST

**인증 필요**: 예

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| facebook | string | 아니오 | Facebook URL |
| twitter | string | 아니오 | Twitter 핸들 |
| instagram | string | 아니오 | Instagram 핸들 |
| youtube | string | 아니오 | YouTube 채널 URL |
| linkedin | string | 아니오 | LinkedIn URL |

**응답 형식**:
```json
{
  "success": true,
  "updated_fields": ["facebook", "twitter"]
}
```

---

#### fcm.save_token - FCM 토큰 저장

**설명**: 푸시 알림을 위한 FCM 토큰을 저장합니다.

**엔드포인트**: `func.php?func=fcm_save_token`

**HTTP 메서드**: POST

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| fcm_token | string | 예 | FCM 토큰 |
| device | string | 예 | 디바이스 정보 (ios, android, web) |
| domain | string | 아니오 | 도메인 |
| uid | string | 아니오 | Firebase UID |

**응답 형식**:
```json
{
  "success": true,
  "token_id": 789,
  "message": "FCM 토큰이 저장되었습니다."
}
```

---

#### table.select - 테이블 데이터 조회

**설명**: 특정 테이블의 데이터를 조회합니다. (관리자 전용)

**엔드포인트**: `func.php?func=table_select`

**HTTP 메서드**: GET

**인증 필요**: 예 (관리자)

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| token | string | 예 | Firebase ID 토큰 |
| table | string | 예 | 테이블명 |
| where | string | 아니오 | WHERE 조건 |
| order | string | 아니오 | ORDER BY 조건 |
| limit | int | 아니오 | 결과 수 제한 |

**응답 형식**:
```json
[
  {
    "field1": "value1",
    "field2": "value2"
  }
]
```

---

#### etc.status - 홈페이지 통계

**설명**: 홈페이지의 전체 통계 정보를 조회합니다.

**엔드포인트**: `func.php?func=etc_status`

**HTTP 메서드**: GET

**인증 필요**: 아니오

**응답 형식**:
```json
{
  "total_users": 15234,
  "total_posts": 87654,
  "total_comments": 234567,
  "today_posts": 123,
  "today_comments": 456,
  "today_users": 78,
  "active_users_24h": 1234,
  "server_time": 1704067200
}
```

---

#### etc.set_timezone - 타임존 설정

**설명**: 세션의 타임존을 설정합니다.

**엔드포인트**: `func.php?func=etc_set_timezone`

**HTTP 메서드**: POST

**인증 필요**: 아니오

**파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| tz | string | 예 | 타임존 (Asia/Seoul, Asia/Manila 등) |

**응답 형식**:
```json
{
  "success": true,
  "timezone": "Asia/Seoul",
  "current_time": "2024-01-01 12:00:00"
}
```


---

## 핵심 개념

### 디렉토리 구조

```
/api/           # API 엔드포인트 파일 (라우팅 레이어)
/lib/           # 핵심 함수와 비즈니스 로직
  *.functions.php    # 모듈별 함수
  /moderate/         # 콘텐츠 검열 함수
  /post/, /chat/     # 모듈 서브디렉토리
/tests/         # Pest PHP 테스트
  /features/    # 모듈별 기능 테스트
  /functions/   # 함수 단위 테스트
/cli/           # 커맨드라인 스크립트
/etc/           # 설정 및 부트스트랩 파일
```

### 함수 명명 규칙

- 컨트롤러 함수: `{module}_{action}_controller()`
- 데이터베이스 함수: `get_{entity}()`, `update_{entity}()`, `delete_{entity}()`
- 검증 함수: `assert_{condition}()`
- 유틸리티 함수: 접두사 없이 설명적 이름

### 인증 시스템

- Firebase 토큰 인증: `assert_token()` 함수 사용
- API 키 인증: 서버 간 통신용
- 로그인 정보: `$loggedIn` 변수에 저장

### 데이터베이스 접근

- ORM 없이 Raw SQL 쿼리 사용
- PDO를 통한 직접 데이터베이스 접근
- 파라미터 바인딩으로 SQL 인젝션 방지
- 테이블명 상수: `lib/constants.php`에 정의 (USER_TABLE, POST_TABLE 등)

---

## 개발 가이드

### 새로운 API 엔드포인트 생성

1. `/api/{module}/{action}.php` 파일 생성
2. `/lib/{module}.functions.php`에 컨트롤러 함수 작성
3. 필요시 `assert_token()`으로 인증 추가
4. `/tests/features/{module}/`에 테스트 작성

### 에러 처리

- 설명적인 에러 코드 사용 (kebab-case)
- 한글 에러 메시지 포함
- 개발 환경에서 `debug_log()`로 로깅
- 적절한 HTTP 상태 코드 반환

### 디버깅

- `index.php`에서 `DEBUG` 상수 활성화
- `/var/debug.log`에서 디버그 출력 확인
- `debug_log()` 함수로 로깅

### PhilGo API 백엔드 실행

[필고 API 백엔드 실행 방법](../system-setup.md#philgo-api-backend-실행) 문서를 참고하여 PhilGo API Backend를 실행할 수 있습니다.

---

## 데이터베이스

### 글 데이터베이스 구조 (sf_post_data)

`sf_post_data` 테이블은 글과 코멘트를 저장합니다. `POST_TABLE` 상수로 접근 가능합니다.

**주요 필드:**
- `idx`: 글의 고유 번호 (Primary key)
- `idx_root`: 글인 경우 0, 코멘트인 경우 최상위 글 번호
- `idx_parent`: 글인 경우 0, 코멘트인 경우 부모 글의 idx
- `idx_member`: 작성자의 회원 고유 번호
- `subject`: 글 제목 (옵션)
- `content`: 글 내용 (옵션)
- `files`: 첨부 파일 (옵션)
- `no_of_attach`: 첨부 파일 개수 (자동 계산)
- `no_of_comment`: 댓글 개수 (자동 계산)
- `good`: 추천 수

**참고:** 글 내용과 첨부 파일 모두 없으면 `body-or-image-required` 에러 발생

### 사용자 테이블 (sf_member)

**차단 관련 필드:**
- `int_8`: 차단 횟수
- `int_9`: 차단 종료 시간 (Unix timestamp)
- `varchar_10`: 차단 사유

---

## 기능별 상세 설명

### 데이터 추출 (Table Select API)

- `select_rows()` 함수로 DB 값 추출
- 보안 처리된 내부 함수
- REST API에서는 `table_select_controller()` → `select_table_from_user_input()` 호출
- 클라이언트 자바스크립트에 테이블명 직접 노출 금지

### 사용자 목록 조회

호출 체인: `index.php?action=user.select` → `select_users_from_user_input()` → `select_table_from_user_input()`

- 테이블명, 필드명, 검색 조건은 내부 설정
- `search_term`만 전달

### 사용자 차단 시스템

#### 차단 조건
- AI Moderation에 의한 자동 차단
- 관리자의 수동 차단
- 차단 사유: 게임/도박/카지노, 욕설/모욕, 부적절한 콘텐츠

#### 차단 로직
1. **관리자 차단**: `index.php?action=user.block&idx_member=xxx` 호출
2. **AI 자동 차단**: 
   - `flagged = true` 또는
   - `gambling = true`인 경우 자동 차단

#### 차단 기간
- 첫 차단: 24시간
- 재차단: 차단 횟수 × 24시간 (48시간, 72시간...)

#### 차단 효과
- 글/코멘트 작성, 수정, 삭제 불가

### 콘텐츠 검열 시스템

#### 검열 함수
- **텍스트**: `gemini_moderate()` - Google Gemini API 사용
- **이미지**: `omni_moderate()` - OpenAI API 사용
- **통합**: `moderate_text_and_images()`

#### 검열 결과 (text_9 필드 저장)

검열 결과는 다음 정보를 포함:
- `model`: 검열 모델 (gemini/omni)
- `flagged`: 검열 여부 (true/false)
- `category`: 검열 카테고리 또는 'safe'
- `reason`: 검열 사유
- `selling`, `job`, `seek`: 판매/구인/사람찾기 여부
- `gambling`, `exchange`, `spam`: 도박/환전/스팸 여부
- `contact`: 연락처 포함 여부
- `info_score`: 필리핀 정보 점수 (0-100)

#### 검열 조치
1. **selling/job/seek = true**: 게시판 변경, char_5 = 'R'
2. **flagged = true**: 블라인드 처리
   - char_5 = 'M'
   - subject → subject_private
   - content → content_private
   - files → text_10

### 채팅 메시지 전송

```sh
php index.php --script=cli/chat/send_a_message.php --no-database
```

상세 테스트: `tests/features/chat/send_chat_message_Test.php` 참조

### 포인트 시스템

#### 포인트 광고
- **등록**: `index.php?action=point.post`
- **필드 저장**:
  - `int_6`: 시작 시간
  - `int_5`: 끝 시간
  - `int_7`: 광고 일수
  - `int_8`: 사용 포인트
  - `int_10`: 획득 포인트

#### 포인트 광고 목록
- `index.php?action=point.list`로 조회
- `int_5 > 현재시간`인 광고 표시

#### 포인트 구매
- `sf_point_log` 테이블의 `etc = 'biz-point-buy'`로 구분

#### 관리자 포인트 수정
- `index.php?action=user.update` 사용
- 파라미터:
  - `idx`: 사용자 번호
  - `mode`: add(추가) / subtract(감소)
  - `point`: 양의 정수

#### 포인트 자동 증감 (게시판별 설정)
- `point_write`: 글 작성 시 포인트
- `point_write_delete`: 글 삭제 시 차감 포인트
- `comment_write`: 댓글 작성 시 포인트

#### 포인트 기록 조회
- 일반 사용자: 본인 기록만 조회
- 관리자: 모든 사용자 기록 조회 (`idx_member` 파라미터 사용)

### 사용자별 최신 글 조회 (post.latest-by-user)

**용도**: 특정 사용자가 작성한 최신 글 목록을 가져옵니다.

**엔드포인트**: `index.php?action=post.latest-by-user`

**파라미터**:
- `idx_member` (선택): 사용자의 회원 번호
- `uid` (선택): Firebase UID (idx_member가 없을 때 사용)
- `limit` (선택): 가져올 글 개수 (기본: 10, 최대: 100)

**특징**:
- idx_member 또는 uid 중 하나는 반드시 제공되어야 함
- idx_member가 우선순위가 높음 (둘 다 제공된 경우 idx_member 사용)
- 글은 최신순(idx 역순)으로 정렬됨
- HTML 태그가 제거된 일부 내용만 포함됨
- 사용자 정보는 포함되지 않음
- 코멘트는 제외하고 글만 반환

**에러 코드**:
- `idx-member-required`: idx_member나 uid가 제공되지 않음
- `limit-too-large`: limit이 100을 초과함

**응답 예시**:
```json
[
  {
    "idx": 12345,
    "idx_member": 100,
    "post_id": "freetalk",
    "category": "general",
    "subject": "테스트 글 제목",
    "content": "글 내용의 일부...",
    "stamp": 1704067200,
    "no_of_comment": 5,
    "no_of_view": 123,
    "files": ["url1", "url2"]
  }
]
```

**사용 예시**:
```bash
# idx_member로 조회
curl "http://localhost/index.php?action=post.latest-by-user&idx_member=100&limit=5"

# Firebase UID로 조회
curl "http://localhost/index.php?action=post.latest-by-user&uid=abc123xyz&limit=10"
```

### 패밀리 사이트

**용도**: 메인 페이지 SEO 및 SSR 콘텐츠 제공

**동작**:
- `action=family-site.get` 호출
- section 값 조사:
  - `blog-`: 최근 블로그 12개
  - `contact-`: 연락처 정보
  - `photo-`, `video-`, `youtube-`: 해당 콘텐츠

---

## 언어 요구사항

- 모든 주석과 에러 메시지는 한글 사용
- 변수명과 함수명은 영어 사용
- 테스트 설명은 영어 가능


