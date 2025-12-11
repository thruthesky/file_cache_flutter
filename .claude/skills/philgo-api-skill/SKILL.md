---
name: philgo-api-skill
description: 본 스킬은 필고 <https://philgo.com> 홈페이지 API 연동 및 개발을 할 때에 반드시 따라야 하는 표준 코딩 가이드를 제공합니다. 필고(Philgo) 홈페이지 및 앱 개발을 위한 백엔드 API 접근 방법, 프로토콜, 로그인, 글/코멘트 생성/수정/삭제, 파일 업로드/삭제, API 함수 목록, EndPoints 등 필고 홈페이지 및 앱을 개발 할 때에 필요한 전반적인 데이터 액세스 및 데이터베이스 접근에 대한 완전하고 상세한 정보를 제공합니다. 홈페이지 개발 및 웹 플러터 앱 개발을 할 때에 API 관련한 모든 코딩은 이 스킬 문서를 따르면 됩니다.
---

# PhilGo API 스킬

필고 웹/앱 개발에 필요한 API 연동 및 데이터베이스 접근에 관한 모든 정보를 제공합니다.

## 핵심 개념

- **엔드포인트**: `/func.php` 하나로 모든 API 접근
- **함수 호출**: `func=function_name` 파라미터로 PHP 함수 직접 호출
- **데이터 형식**: 입출력 모두 JSON
- **인증 방식**: Firebase ID 토큰 또는 API 키

## Quick Start

```javascript
// JavaScript에서 API 호출
const result = await func('get_user_lang', {});

// 인증이 필요한 API
const token = await firebase.auth().currentUser.getIdToken();
const myData = await func('get_my_data', { token });
```

```bash
# 터미널에서 함수 목록 조회
curl "https://philgo.com/func.php?func=get_functions"
```

---

## 레퍼런스 문서

상세한 정보는 아래 레퍼런스 문서를 참조하세요.

### [references/protocol.md](references/protocol.md) - API 프로토콜

**언제 참조**: API 호출 방법, 요청/응답 형식, 인증 방식을 확인할 때

- `/func.php` 엔드포인트 접근 방법
- 입력/출력 형식 (JSON)
- Firebase 토큰 인증 방식
- 에러 처리 및 에러 코드
- JavaScript/PHP 예제 코드

### [references/endpoints.md](references/endpoints.md) - API 엔드포인트 목록

**언제 참조**: 특정 API 함수의 사용법, 파라미터, 리턴 값을 확인할 때

- 허용된 함수 목록 (ALLOWED_FUNCTIONS)
- 각 함수의 시그니처 및 파일 위치
- 입력 파라미터 상세 설명
- 리턴 값 형식
- 사용 예제 및 에러 코드

주요 함수:
- `get_my_data` - 내 정보 조회
- `update_my_profile` - 프로필 업데이트
- `create_post` / `update_post` / `delete_post` - 게시글 관리
- `create_comment` / `update_comment` / `delete_comment` - 댓글 관리

### [references/post-api.md](references/post-api.md) - 게시글/댓글 API

**언제 참조**: 글/댓글 조회, 생성, 수정, 삭제 기능을 구현할 때

- `get_posts()` 핵심 API 상세 설명
- 게시글 관리 API (Post)
- 댓글 관리 API (Comment)
- 게시판 설정 API (Post-Config)
- 검색, 필터링, 페이지네이션

### [references/advertisement.md](references/advertisement.md) - 광고 API

**언제 참조**: 광고 배너를 화면에 표시할 때

- 광고 시스템 개요 (업소 → 광고 → 배너)
- 배너 타입 (top, wing, square, small)
- `get_all_active_advertisements` - 모든 활성 광고 조회
- `get_top_banners` / `get_wing_banners` / `get_square_banners` / `get_small_banners`

### [references/file-upload.md](references/file-upload.md) - 파일 업로드

**언제 참조**: 파일/이미지 업로드 기능을 구현할 때

- Vue.js 파일 업로드 컴포넌트 사용법
- 단일/다중 파일 업로드
- QR 코드 디코딩
- API 연동 방법

### [references/api/version.md](references/api/version.md) - 버전 API

**언제 참조**: 앱 버전 체크, 업데이트 알림 기능을 구현할 때

- `func('version')` API 응답 형식
- Android/iOS 빌드 번호 정보

---

## 스크립트

### scripts/get_functions.sh

허용된 함수 목록을 조회하는 스크립트

```bash
cd .claude/skills/philgo-api-skill/scripts
./get_functions.sh
```

---

## 상황별 가이드

### API 개발 시작

1. 본 문서(SKILL.md)로 전체 구조 파악
2. [references/protocol.md](references/protocol.md)로 프로토콜 학습
3. [references/endpoints.md](references/endpoints.md)로 사용 가능한 함수 확인

### 특정 API 함수 사용

1. `scripts/get_functions.sh`로 함수 목록 확인
2. [references/endpoints.md](references/endpoints.md)에서 함수 상세 문서 참조

### 게시글/댓글 기능 구현

1. [references/post-api.md](references/post-api.md)의 `get_posts()` 참조 (핵심 API)
2. 검색, 필터링, 페이지네이션 옵션 확인

### 새 API 함수 추가

1. PHP 함수 작성 (`lib/xxx/xxx.functions.php`)
2. `FunctionClass::get_functions()`에 함수 추가
3. [references/endpoints.md](references/endpoints.md)에 문서 추가
4. `scripts/get_functions.sh`로 등록 확인

---

## 보안 주의사항

### FunctionClass 화이트리스트

`FunctionClass::get_functions()`에 등록된 함수만 API로 호출 가능합니다.

### Firebase 인증이 필요한 함수

- `get_my_data`, `update_my_profile` - 로그인 필요
- `report` - 신고 기능
- `approve_company`, `reject_company` - 관리자 전용

```javascript
const token = await firebase.auth().currentUser.getIdToken();
const result = await func('function_name', { token, ...params });
```

---

## 관련 PHP 파일

| 파일 | 설명 |
|------|------|
| `func.php` | API 엔드포인트 |
| `lib/api/function.class.php` | 허용된 함수 목록 및 래핑 메서드 |
| `lib/user/user.functions.php` | 사용자 관련 함수 |
| `lib/post/` | 게시글/댓글 관련 함수 |
| `lib/company.functions.php` | 업소록 함수 |
