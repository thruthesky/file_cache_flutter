---
name: philgo-api-skill
description: 본 스킬은 필고 <https://philgo.com> 홈페이지 API 연동 및 개발을 할 때에 반드시 따라야 하는 표준 코딩 가이드를 제공합니다. 필고(Philgo) 홈페이지 및 앱 개발을 위한 백엔드 API 접근 방법, 프로토콜, 로그인, 글/코멘트 생성/수정/삭제, 파일 업로드/삭제, API 함수 목록, EndPoints 등 필고 홈페이지 및 앱을 개발 할 때에 필요한 전반적인 데이터 액세스 및 데이터베이스 접근에 대한 완전하고 상세한 정보를 제공합니다. 홈페이지 개발 및 웹 플러터 앱 개발을 할 때에 API 관련한 모든 코딩은 이 스킬 문서를 따르면 됩니다.
---


본 문서는 필고 웹/앱을 개발할 때 필요한 API 연동 및 데이터베이스 접근에 관한 모든 정보를 담고 있습니다. 데이터베이스, 데이터 접근, API 연동에 관한 내용이라면 반드시 이 문서를 참고해야 합니다.


## 📚 문서 구조 개요

`.claude/skills/philgo-api-skill` 폴더는 PhilGo API 개발에 필요한 모든 문서와 도구를 포함합니다.

```
.claude/skills/philgo-api-skill/
├── SKILL.md                      # 본 문서 (가이드 및 인덱스)
├── philgo-api-protocol.md        # API 프로토콜 상세 문서
├── philgo-api-endpoints.md       # 허용된 함수 목록 및 전체 API 엔드포인트 상세 문서
├── file-upload.md                # 파일 업로드 API 문서
└── scripts/
    └── function_list.sh          # 허용된 함수 목록 조회 스크립트
```

---

## 📖 각 문서의 역할

### 1. SKILL.md (본 문서)

**역할**: PhilGo API 문서의 메타 가이드이자 인덱스

**내용**:
- 전체 문서 구조 설명
- 각 문서의 역할과 사용 시기
- scripts 폴더의 도구 설명
- 상황별 문서 참조 가이드

**언제 참조하는가**:
- API 개발을 처음 시작할 때
- 어떤 문서를 참조해야 할지 모를 때
- 전체 구조를 파악하고 싶을 때

---

### 2. philgo-api-protocol.md

**역할**: PhilGo API의 핵심 프로토콜 및 접근 방법 문서

**주요 내용**:
- `/func.php` 엔드포인트를 통한 API 접근 방법
- PHP 함수 직접 호출 방식 설명
- 입력 형식 (파라미터 전달 방법)
- 출력 형식 (JSON 응답 구조)
- 인증 방식 (Firebase ID 토큰, API 키)
- 에러 처리 및 에러 코드
- 실용적인 예제 코드 (JavaScript, PHP)

**언제 참조하는가**:
- API 호출 방법을 처음 배울 때
- `/func.php` 사용법을 이해해야 할 때
- API 요청/응답 형식을 확인해야 할 때
- 인증 방법을 구현해야 할 때
- 에러 처리 로직을 작성해야 할 때

**사용 예시**:
```javascript
// JavaScript에서 API 호출
const token = await firebase.auth().currentUser.getIdToken();
const result = await func('get_my_data', { token: token });
console.log('내 정보:', result);
```

**관련 PHP 파일**:
- `func.php` - API 엔드포인트
- `lib/api/func.functions.php` - API 함수 처리

---

### 3. philgo-api-endpoints.md

**역할**: PhilGo API의 허용된 함수 목록 및 모든 엔드포인트 상세 문서

**주요 내용**:
- **허용된 함수 목록 (ALLOWED_FUNCTIONS)**: `func.php`를 통해 호출 가능한 8개 함수의 상세 문서
  - 각 함수의 시그니처 및 파일 위치
  - 입력 파라미터 상세 설명
  - 리턴 값 형식
  - JavaScript 및 Vue.js 사용 예제
  - 에러 코드 및 처리 방법
- **전체 API 엔드포인트 상세 설명** (레거시 및 참고용):
  - 앱 관련 API (App)
  - 사용자 관리 API (User)
  - 게시판 API (Post)
  - 댓글 API (Comment)
  - 게시판 설정 API (Post Config)
  - 중재 API (Moderate)
  - 포인트 API (Point)
  - 업소록 API (Company)
  - 광고 API (Advertisement)
  - 패밀리사이트 API (Family Site)
  - 검색 API (Search)
  - 도움말 API (Help)
  - 좋아요 API (Like)
  - 신고 API (Report)
  - 소셜 API (Social)
  - FCM API
  - 테이블 API (Table)
  - 기타 API (Etc)

**허용된 함수 목록**:
1. `function_list` - 허용된 함수 목록 조회
2. `get_my_data` - 로그인한 사용자 정보 조회
3. `update_my_profile` - 사용자 프로필 업데이트
4. `get_user_lang` - 사용자 언어 설정 조회
5. `family_site_exists` - 패밀리사이트 도메인 존재 여부 확인
6. `approve_company` - 업소록 승인 (관리자 전용)
7. `reject_company` - 업소록 거부 (관리자 전용)
8. `report` - 글/댓글 신고

**언제 참조하는가**:
- **특정 API 함수의 사용법을 확인해야 할 때**
- **함수의 입력 파라미터 및 리턴 값 형식을 확인해야 할 때**
- **함수 사용 예제가 필요할 때**
- **새로운 함수를 ALLOWED_FUNCTIONS에 추가한 후 문서화할 때**
- 특정 기능의 API가 있는지 확인해야 할 때
- 특정 모듈(User, Post, Company 등)의 모든 API를 확인해야 할 때
- API 파라미터 및 응답 형식의 전체 목록이 필요할 때
- 레거시 API 정보를 확인해야 할 때

**사용 예시**:
```javascript
// 내 정보 조회
const token = await firebase.auth().currentUser.getIdToken();
const myData = await func('get_my_data', { token });
console.log('내 닉네임:', myData.nickname);

// 닉네임 업데이트
const result = await func('update_my_profile', {
  token: token,
  nickname: '새닉네임'
});
```

**관련 PHP 파일**:
- `func.php` - ALLOWED_FUNCTIONS 상수 정의
- `lib/user/user.functions.php` - get_my_data, update_my_profile
- `lib/intl.functions.php` - get_user_lang
- `lib/family-site/family-site.functions.php` - family_site_exists
- `lib/company.functions.php` - approve_company, reject_company
- `lib/post/report.functions.php` - report
- `lib/api/func.functions.php` - function_list

**⚠️ 주의사항**:
- 이 문서의 모든 엔드포인트는 `/func.php?func=function_name` 형식으로 변경되었습니다
- **실제 사용 가능한 함수는 `ALLOWED_FUNCTIONS`에 등록된 함수만 가능합니다**
- 새로운 API 개발 시 레거시 엔드포인트 섹션은 참고용으로만 사용하세요
- **실제 구현은 이 문서의 "허용된 API 함수 목록" 섹션을 참조하세요**

## 4. file-upload.md

**역할**: PhilGo 파일 업로드 API 문서
**주요 내용**:
- 파일 업로드 API 사용법
- 파일 삭제 API 사용법
- 입력 파라미터 및 리턴 값 형식
- JavaScript 및 PHP 사용 예제
**언제 참조하는가**:
- 파일 업로드 기능을 구현할 때
- 파일 삭제 기능을 구현할 때
---

## 🛠️ scripts 폴더

### function_list.sh

**역할**: 허용된 함수 목록을 조회하는 스크립트

**내용**:
```bash
curl "https://local.philgo.com:444/func.php?func=function_list"
```

**사용법**:
```bash
cd .claude/skills/philgo-api/scripts
./function_list.sh
```

**출력 예시**:
```json
{
  "approve_company": "업소록 정보를 승인합니다.",
  "family_site_exists": "가족 사이트가 존재하는지 확인합니다.",
  "function_list": "필고 API 에서 사용 가능한(허용된) 함수 목록을 가져옵니다.",
  "get_user_lang": "사용자의 언어 정보를 가져옵니다.",
  "get_my_data": "내 정보를 가져옵니다.",
  "reject_company": "업소록 정보를 거부합니다.",
  "report": "글 또는 댓글을 신고합니다.",
  "update_my_profile": "내 프로필을 업데이트합니다."
}
```

**언제 사용하는가**:
- 현재 사용 가능한 API 함수 목록을 빠르게 확인하고 싶을 때
- API 함수가 제대로 등록되었는지 테스트할 때
- ALLOWED_FUNCTIONS 업데이트 후 변경사항을 확인할 때

---

## 🎯 상황별 문서 참조 가이드

### API 개발을 처음 시작하는 경우

1. **SKILL.md** (본 문서) - 전체 구조 파악
2. **philgo-api-protocol.md** - API 프로토콜 학습
3. **philgo-api-endpoints.md** - 사용 가능한 함수 확인

### 특정 API 함수를 사용하고 싶은 경우

1. **scripts/function_list.sh** - 허용된 함수 목록 확인
2. **philgo-api-endpoints.md** - 해당 함수의 상세 문서 참조 (허용된 API 함수 목록 섹션)
3. **philgo-api-protocol.md** - 호출 방법 및 인증 확인

### 새로운 API 함수를 추가하는 경우

1. PHP 함수 작성 (예: `lib/xxx/xxx.functions.php`)
2. `func.php`의 `ALLOWED_FUNCTIONS`에 함수 추가
3. **philgo-api-endpoints.md**에 함수 문서 추가 (허용된 API 함수 목록 섹션)
4. **scripts/function_list.sh** 실행하여 등록 확인
5. 테스트 코드 작성 및 실행

### API 호출 방법을 확인하고 싶은 경우

1. **philgo-api-protocol.md** - 기본 호출 방법 확인
2. **philgo-api-endpoints.md** - 구체적인 사용 예제 확인 (허용된 API 함수 목록 섹션)

### 에러 처리를 구현하는 경우

1. **philgo-api-protocol.md** - 에러 응답 형식 확인
2. **philgo-api-endpoints.md** - 함수별 에러 코드 확인 (허용된 API 함수 목록 섹션)

### API 인증을 구현하는 경우

1. **philgo-api-protocol.md** - Firebase 토큰 인증 방법 확인
2. **philgo-api-endpoints.md** - 인증이 필요한 함수 확인 (허용된 API 함수 목록 섹션)

---

## 💡 활용 및 사용처

### 웹 개발 (JavaScript)

**언제 사용하는가**:
- 웹 페이지에서 서버 데이터를 가져올 때
- 사용자 정보를 업데이트할 때
- 게시글, 댓글을 작성/수정/삭제할 때
- 관리자 기능을 구현할 때

**참조 문서**:
- `philgo-api-protocol.md` - JavaScript에서 func() 함수 사용법
- `philgo-api-endpoints.md` - JavaScript 예제 코드 (허용된 API 함수 목록 섹션)

**예제**:
```javascript
// 사용자 정보 조회
const token = await firebase.auth().currentUser.getIdToken();
const myData = await func('get_my_data', { token });

// 닉네임 업데이트
await func('update_my_profile', { token, nickname: '새닉네임' });
```

### 앱 개발 (Flutter, React Native)

**언제 사용하는가**:
- 앱에서 서버 API를 호출할 때
- 사용자 인증 및 프로필 관리
- 콘텐츠 생성, 수정, 삭제
- 실시간 데이터 동기화

**참조 문서**:
- `philgo-api-protocol.md` - HTTP 요청 형식
- `philgo-api-endpoints.md` - API 함수 목록 (허용된 API 함수 목록 섹션)

### PHP 백엔드 개발

**언제 사용하는가**:
- 새로운 API 함수를 추가할 때
- 기존 함수를 수정할 때
- API 보안을 강화할 때

**참조 문서**:
- `philgo-api-protocol.md` - PHP 함수 작성 규칙
- `philgo-api-endpoints.md` - 기존 함수 구조 참조 (허용된 API 함수 목록 섹션)

**관련 파일**:
- `func.php` - API 엔드포인트 및 ALLOWED_FUNCTIONS
- `lib/*/` - 각 모듈별 함수 구현

### API 테스트

**언제 사용하는가**:
- API 함수가 제대로 동작하는지 확인할 때
- 새로 추가한 함수를 테스트할 때
- 배포 전 API 검증

**사용 도구**:
- `scripts/function_list.sh` - 함수 목록 확인
- `curl` 명령어 - 직접 API 호출 테스트
- Chrome DevTools MCP - 웹 페이지에서 테스트

**예제**:
```bash
# 함수 목록 조회
./scripts/function_list.sh

# 특정 함수 테스트
curl "https://local.philgo.com:444/func.php?func=get_user_lang"
```

### 문서 업데이트

**언제 업데이트하는가**:
- 새로운 API 함수를 추가했을 때
- 기존 함수의 파라미터가 변경되었을 때
- API 프로토콜이 변경되었을 때

**업데이트 절차**:
1. PHP 함수 구현
2. `func.php`의 `ALLOWED_FUNCTIONS`에 추가
3. `philgo-api-endpoints.md`에 함수 문서 추가 (허용된 API 함수 목록 섹션)
4. 테스트 실행
5. Git commit

---

## 🔐 보안 및 주의사항

### ALLOWED_FUNCTIONS 화이트리스트

**중요**: API를 통해 호출 가능한 함수는 `func.php`의 `ALLOWED_FUNCTIONS` 상수에 등록된 함수만 가능합니다.

**이유**:
- 보안: 임의의 PHP 함수 호출 방지
- 제어: 공개 API 범위 제한
- 문서화: 허용된 함수만 문서화

**새 함수 추가 시 필수 작업**:
1. `func.php`의 `ALLOWED_FUNCTIONS`에 함수명과 설명 추가
2. `philgo-api-endpoints.md`에 상세 문서 추가 (허용된 API 함수 목록 섹션)

### Firebase 인증

**인증이 필요한 함수**:
- `get_my_data` - 로그인한 사용자 정보 조회
- `update_my_profile` - 프로필 업데이트
- `report` - 신고 기능
- `approve_company`, `reject_company` - 관리자 전용 함수

**인증 방법**:
```javascript
const token = await firebase.auth().currentUser.getIdToken();
const result = await func('function_name', { token, ...params });
```

---

## 📝 문서 작성 규칙

### API 함수 문서 작성 시 필수 포함 사항

1. **함수 시그니처**: PHP 함수 정의
2. **파일 위치**: 함수가 구현된 파일 경로
3. **설명**: 함수의 목적과 기능
4. **입력 파라미터**: 모든 파라미터의 타입과 설명
5. **리턴 값**: 리턴 형식 (배열 또는 단일 값)
6. **사용 예제**: JavaScript, Vue.js 예제
7. **에러 코드**: 발생 가능한 에러와 처리 방법
8. **중요 노트**: 특별히 주의할 사항

### 예제 작성 규칙

- **JavaScript 예제**: 일반적인 fetch 또는 func() 사용
- **Vue.js 예제**: Options API 스타일 컴포넌트
- **실용적**: 실제 사용 상황을 반영
- **명확한 주석**: 각 단계 설명

---

## 🚀 Quick Start

### 1. API 목록 확인
```bash
cd .claude/skills/philgo-api/scripts
./function_list.sh
```

### 2. 특정 API 사용법 확인
`philgo-api-endpoints.md` 파일의 "허용된 API 함수 목록" 섹션에서 해당 함수 검색

### 3. API 호출 테스트
```bash
curl "https://local.philgo.com:444/func.php?func=get_user_lang"
```

### 4. JavaScript에서 사용
```javascript
const result = await func('get_user_lang', {});
console.log('사용자 언어:', result.data);
```

---

## 📞 추가 정보

### 관련 문서
- `docs/www/api.md` - API 개요 및 빠른 시작
- `docs/index.md` - 전체 문서 인덱스
- `CLAUDE.md` - 개발 가이드라인

### 관련 PHP 파일
- `func.php` - API 엔드포인트
- `lib/api/func.functions.php` - API 함수 처리
- `lib/user/user.functions.php` - 사용자 관련 함수
- `lib/family-site/family-site.functions.php` - 패밀리사이트 함수
- `lib/company.functions.php` - 업소록 함수
- `lib/post/report.functions.php` - 신고 함수
- `lib/intl.functions.php` - 다국어 함수

---

**문서 버전**: 2.0
**최종 업데이트**: 2025-10-26
**작성자**: PhilGo Development Team
