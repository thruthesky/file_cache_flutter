# v7 Post API 문서

## 목차

1. [개요](#개요)
2. [아키텍처](#아키텍처)
3. [API 엔드포인트](#api-엔드포인트)
   - [post.get](#postget---게시글-조회)
   - [post.list](#postlist---게시글-목록)
   - [post.create](#postcreate---게시글-생성)
   - [post.update](#postupdate---게시글-수정)
   - [post.delete](#postdelete---게시글-삭제)
4. [포인트 시스템](#포인트-시스템)
5. [PostEntity 필드](#postentity-필드)
6. [에러 처리](#에러-처리)
7. [테스트](#테스트)

---

## 개요

v7 Post API는 게시글 CRUD(생성/조회/수정/삭제) 기능을 제공한다.
PSR-4 기반 Controller + Service + Repository + Entity 아키텍처를 사용하며,
기존 v6 시스템과 100% 공존한다.

### 주요 특징

- 게시글 생성 시 포인트 자동 지급 (게시판 설정 기반)
- 게시글 삭제 시 포인트 자동 차감 (게시판 설정 기반)
- 포인트 변경 내역 sf_point_log 자동 기록
- 댓글 있는 게시글 삭제 방지
- 하드 삭제 (물리적 DELETE, 기존 v6와 동일)

---

## 아키텍처

```
클라이언트 → api.php → PostController → PostService → PostRepository → DB
                                              ↓
                                    포인트 증/감 처리
                                    (sf_member, sf_point_log)
```

### 파일 구조

```
lib/post/
├── PostController.php    # API 엔드포인트 (인증 처리)
├── PostService.php       # 비즈니스 로직 (포인트 증/감 포함)
├── PostRepository.php    # DB CRUD (prepared statement)
├── PostEntity.php        # 데이터 구조체 (POPO)
│
├── post.functions.php          # (기존 v6 레거시)
├── post.create.functions.php   # (기존 v6 레거시)
├── post.update.functions.php   # (기존 v6 레거시)
├── post.delete.functions.php   # (기존 v6 레거시)
└── ...                         # (기존 v6 레거시 파일들)
```

### PSR-4 네임스페이스

```json
"Philgo\\Post\\": "lib/post/"
```

---

## API 엔드포인트

### post.get — 게시글 조회

인증 불필요.

```
GET https://local.philgo.com/api.php?method=post.get&idx=12345
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx | int | O | 게시글 번호 |

**응답**: PostEntity 배열 (toArray())

---

### post.list — 게시글 목록

인증 불필요.

```
GET https://local.philgo.com/api.php?method=post.list&post_id=freetalk&limit=20&offset=0
GET https://local.philgo.com/api.php?method=post.list&post_id=wanted&category=job&orderby=stamp+DESC
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| post_id | string | O | 게시판 ID |
| category | string | X | 카테고리 필터 |
| orderby | string | X | 정렬 (기본: stamp DESC) |
| limit | int | X | 최대 조회 수 (기본: 20, 최대: 100) |
| offset | int | X | 오프셋 (기본: 0) |

**허용 정렬**:
`stamp DESC/ASC`, `stamp_update DESC/ASC`, `stamp_last_comment DESC/ASC`,
`no_of_view DESC/ASC`, `good DESC/ASC`, `idx DESC/ASC`, `list_order ASC/DESC`

**응답**:
```json
{
  "posts": [ { PostEntity... }, ... ],
  "total": 42
}
```

---

### post.create — 게시글 생성

인증 필수.

```
GET https://local.philgo.com/api.php?method=post.create&session_id=xxx&post_id=freetalk&subject=제목&content=내용
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| post_id | string | O | 게시판 ID |
| subject | string | O | 제목 (최대 126자, 특수문자 필터링) |
| content | string | O | 내용 |
| category | string | X | 카테고리 |
| files | string/array | X | 첨부 파일 URL (쉼표 구분 또는 배열) |
| link | string | X | 외부 링크 |
| region | string | X | 지역 |
| secret | string | X | 비밀글 ('Y') |
| int_1 ~ int_10 | int | X | 커스텀 정수 필드 |
| char_1 ~ char_10 | string | X | 커스텀 문자 필드 |
| varchar_1 ~ varchar_20 | string | X | 커스텀 문자열 필드 |
| text_1 ~ text_10 | string | X | 커스텀 텍스트 필드 |

**포인트 처리**:
- sf_post_config.point_write 설정에 따라 자동 포인트 지급
- 실제 지급된 포인트는 int_10 필드에 저장
- sf_point_log에 로그 기록

**응답**: PostEntity 배열

---

### post.update — 게시글 수정

인증 필수 (작성자 또는 관리자).

```
GET https://local.philgo.com/api.php?method=post.update&session_id=xxx&idx=12345&subject=새제목&content=새내용
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx | int | O | 게시글 번호 |
| subject | string | X | 새 제목 |
| content | string | X | 새 내용 |
| files | string/array | X | 새 첨부 파일 |
| (기타) | - | X | create와 동일한 선택 필드 |

**변경 불가 필드**: idx, idx_member, stamp, depth, idx_root, idx_parent

**수정 시간**: subject, content, files 중 하나라도 변경되면 stamp_update 자동 갱신

**응답**: PostEntity 배열

---

### post.delete — 게시글 삭제

인증 필수 (작성자 또는 관리자).

```
GET https://local.philgo.com/api.php?method=post.delete&session_id=xxx&idx=12345
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx | int | O | 게시글 번호 |

**삭제 제한**:
- 댓글이 있는 게시글은 삭제 불가 (no_of_comment > 0)

**포인트 처리**:
- sf_post_config.point_write_delete 설정에 따라 포인트 차감
- sf_point_log에 로그 기록

**삭제 방식**: 하드 삭제 (물리적 DELETE, 기존 v6와 동일)

**응답**: 삭제된 게시글 정보 배열

---

## 포인트 시스템

### 포인트 증/감 흐름도

```
글 생성 시:
PostService::create()
  → increasePointsForCreate()
    → getPostConfig() → sf_post_config.point_write 조회
    → changeUserPoints()
      → sf_member.point 업데이트 (최소값 0 보장)
      → sf_point_log에 로그 기록
    → sf_post_data.int_10에 실제 지급 포인트 저장

글 삭제 시:
PostService::delete()
  → decreasePointsForDelete()
    → getPostConfig() → sf_post_config.point_write_delete 조회
    → changeUserPoints()
      → sf_member.point 업데이트 (최소값 0 보장)
      → sf_point_log에 로그 기록
```

### 포인트 로그 (sf_point_log) 기록 형식

| 필드 | 글 생성 시 | 글 삭제 시 |
|------|-----------|-----------|
| module | 'post' | 'post' |
| action | 'create' | 'delete' |
| etc | 'point_write' | 'point_write_delete' |
| point | +N (양수) | -N (음수) |
| idx_post | 해당 글 idx | 해당 글 idx |

### 포인트 규칙

- 포인트 최소값은 0 (음수 방지)
- 검열(checked='R')에 걸린 글은 포인트 지급/차감하지 않음
- 블라인드(blind='Y') 처리된 글도 포인트 지급/차감하지 않음
- 게시판 설정에 point_write=0이면 포인트 미지급

### 게시판 포인트 설정 (sf_post_config)

| 설정 필드 | 설명 | 예시 |
|-----------|------|------|
| point_write | 글 작성 시 지급 포인트 | 10 |
| point_comment | 댓글 작성 시 지급 포인트 | 5 |
| point_write_delete | 글 삭제 시 차감 포인트 | -10 |
| point_comment_delete | 댓글 삭제 시 차감 포인트 | -5 |

---

## PostEntity 필드

### 핵심 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| idx | int | 게시글 고유 번호 (PK) |
| idx_member | int | 작성자 회원 번호 |
| post_id | string | 게시판 ID |
| subject | string | 제목 |
| content | string | 내용 |
| stamp | int | 작성 시간 (UNIX timestamp) |
| stamp_update | int | 수정 시간 |
| depth | int | 깊이 (0=글, 1=댓글, 2=대댓글) |
| no_of_comment | int | 댓글 수 |
| no_of_view | int | 조회 수 |
| good | int | 좋아요 수 |
| category | string | 카테고리 |
| int_10 | int | 획득 포인트 |

### 계산 필드 (toArray()에서 자동 추가)

| 필드 | 타입 | 설명 |
|------|------|------|
| is_comment | bool | 댓글 여부 (depth > 0) |
| earned_point | int | 획득 포인트 (int_10 값) |

### 비즈니스 로직 메서드

| 메서드 | 반환 | 설명 |
|--------|------|------|
| isComment() | bool | 댓글인지 (depth > 0) |
| isPost() | bool | 글인지 (depth === 0) |
| isBlocked() | bool | 검열 거부 (checked === 'R') |
| isBlinded() | bool | 블라인드 (blind === 'Y') |
| isBlockedOrBlinded() | bool | 검열 또는 블라인드 |
| isSecret() | bool | 비밀글 (secret === 'Y') |
| exists() | bool | 존재 여부 (idx > 0) |

---

## 에러 처리

모든 에러는 `RuntimeException`으로 발생하며, api.php에서 JSON으로 변환된다.

| 상황 | 에러 메시지 |
|------|------------|
| idx 없음 | '게시글 idx가 필요합니다.' |
| 게시글 미존재 | '해당 게시글을 찾을 수 없습니다.' |
| post_id 없음 | '게시판 ID(post_id)가 필요합니다.' |
| 미로그인 | '로그인이 필요합니다.' |
| 수정 권한 없음 | '게시글 수정 권한이 없습니다.' |
| 삭제 권한 없음 | '게시글 삭제 권한이 없습니다.' |
| 댓글 있는 글 삭제 | '댓글이 있는 게시글은 삭제할 수 없습니다.' |
| 회원 미존재 | '회원 정보를 찾을 수 없습니다.' |

---

## 테스트

### 실행 방법

```bash
# 전체 Post 테스트
./vendor/bin/pest tests/Unit/PostControllerTest.php

# curl 테스트
curl "https://local.philgo.com/api.php?method=post.list&post_id=freetalk&limit=5"
curl "https://local.philgo.com/api.php?method=post.get&idx=12345"
```

### 테스트 범위

| 분류 | 테스트 수 | 설명 |
|------|----------|------|
| PostEntity | 7 | fromArray, toArray, 계산 필드, 비즈니스 메서드 |
| PostRepository | 8 | CRUD, 목록, 카운트, 설정 조회, 커스텀 필드 |
| PostService | 11 | CRUD + 포인트 증/감 + 권한 검사 + 에러 처리 |
| PostController | 7 | 인증/비인증 + CRUD |
| **합계** | **36** | 115 assertions |
