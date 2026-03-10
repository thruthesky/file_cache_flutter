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
8. [게시글 목록 관리자 기능](#게시글-목록-관리자-기능)
9. [코멘트(댓글) 시스템](#코멘트댓글-시스템)
   - [코멘트 디자인 시스템](#코멘트-디자인-시스템)
   - [Reddit 스타일 스레드 구조 (gutter 방식)](#reddit-스타일-스레드-구조-gutter-방식)
   - [코멘트 HTML 구조 (SSR — gutter 방식 재귀 트리)](#코멘트-html-구조-ssr--gutter-방식-재귀-트리)
   - [코멘트 CSS 핵심 스타일 (gutter 방식)](#코멘트-css-핵심-스타일-gutter-방식)
   - [접기/펼치기 JavaScript (gutter 방식)](#접기펼치기-javascript-gutter-방식)
   - [코멘트 모바일 반응형](#코멘트-모바일-반응형-media-max-width-640px)
   - [다크모드 보정](#다크모드-보정)
   - [빈 상태 디자인](#빈-상태-디자인)
   - [코멘트 디자인 수정 시 주의사항](#코멘트-디자인-수정-시-주의사항)

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

**미디어 필드 자동 설정** (`setMediaFields`):

글 생성/수정 시 `files` 파라미터가 있으면 자동으로 미디어 관련 필드를 설정한다.

| 필드 | 용도 | 설정 조건 |
|------|------|-----------|
| `has_image` | 이미지 포함 여부 (`'y'` 또는 `''`) | files에 이미지가 있으면 `'y'` |
| `varchar_17` | 첫 번째 이미지 URL | files에서 첫 번째 이미지 URL |
| `varchar_10` | 400x400 정사각형 center-crop 썸네일 URL | uploads 테이블에서 조회 |
| `varchar_11` | 800x800 정사각형 center-crop 썸네일 URL | uploads 테이블에서 조회 |
| `varchar_12` | 1000px 비율 유지 리사이즈 썸네일 URL | uploads 테이블에서 조회 |
| `has_video` | 동영상 포함 여부 (`'y'` 또는 `''`) | files에 동영상이 있으면 `'y'` |
| `varchar_18` | 첫 번째 동영상 URL | files에서 첫 번째 동영상 URL |

**썸네일 URL 조회 로직** (핵심):

1. `files` 파라미터를 콤마로 분리하여 파일 목록 생성
2. 파일 목록에서 **첫 번째 이미지**를 찾음 (jpg, jpeg, png, gif, webp, bmp, svg, avif)
3. 첫 번째 이미지가 `/uploads/` 로 시작하면 → `UploadRepository::findByUrl()`로 uploads 테이블 검색
4. **DB 조회 우선**: uploads 레코드가 있고 `thumbnail_400x400_url`이 비어있지 않으면 → DB 값 사용
5. **폴백 처리**: uploads 레코드가 없거나, 레코드는 있지만 thumbnail URL이 비어있는 기존 파일 → `ImageService::buildThumbnailUrl()`로 URL 패턴 기반 생성 (변환 가능한 포맷만: jpg, jpeg, png, webp, bmp, avif)
6. `/uploads/` 로 시작하지 않는 URL(레거시 외부 URL) → varchar_10~12는 빈 문자열
7. GIF는 변환 불가이므로 uploads에 썸네일 없고, 폴백에서도 `isConvertible('gif')` = false → 빈 문자열

```php
// PostService::setMediaFields() 핵심 코드
$data['varchar_10'] = '';
$data['varchar_11'] = '';
$data['varchar_12'] = '';
if ($firstImage !== null && str_starts_with($firstImage, '/uploads/')) {
    $uploadEntity = UploadRepository::findByUrl($firstImage);
    if ($uploadEntity !== null && !empty($uploadEntity->thumbnail_400x400_url)) {
        // uploads 테이블에 썸네일 URL이 저장되어 있으면 그대로 사용
        $data['varchar_10'] = $uploadEntity->thumbnail_400x400_url;
        $data['varchar_11'] = $uploadEntity->thumbnail_800x800_url;
        $data['varchar_12'] = $uploadEntity->thumbnail_1000_url;
    } else {
        // uploads 테이블에 썸네일 URL이 없는 경우 (기존 업로드 파일)
        // URL 패턴으로 썸네일 URL을 생성하여 폴백
        $imgExt = strtolower(pathinfo($firstImage, PATHINFO_EXTENSION));
        if (ImageService::isConvertible($imgExt)) {
            $data['varchar_10'] = ImageService::buildThumbnailUrl($firstImage, 400, 'square');
            $data['varchar_11'] = ImageService::buildThumbnailUrl($firstImage, 800, 'square');
            $data['varchar_12'] = ImageService::buildThumbnailUrl($firstImage, 1000, 'resize');
        }
    }
}
```

> **중요**: 여러 이미지가 업로드된 경우, **오직 첫 번째 이미지**의 썸네일만 varchar_10~12에 저장된다.

**PostEntity 편의 속성**: `thumbnail_400x400`, `thumbnail_800x800`, `thumbnail_1000` 속성으로 varchar_10~12에 직접 접근 가능하다. `toArray()` 출력에도 포함된다.

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

---

## 게시글 목록 관리자 기능

### 개요

v7 게시글 목록 페이지(`v7/post/list.php`)에는 관리자 전용 기능이 포함되어 있다.
체크박스로 글을 선택하고, 다른 게시판으로 이동하거나, 작성자를 차단하거나, 임시 보관할 수 있다.
v6 `widgets/post/list/post-list-tile.php`와 `widgets/post/list/post-list-footer.php`의 로직을 v7 아키텍처로 재구현한 것이다.

### 파일 구조

| 파일 | 설명 |
|------|------|
| `v7/post/list.php` | 게시글 목록 페이지 (관리자 인증 + 차단 회원 조회 포함) |
| `v7/widgets/post/list/post-list-tile.php` | 게시글 행 위젯 (관리자 체크박스 + 차단 글 표시) |
| `v7/widgets/post/list/post-list-footer.php` | 관리자 일괄 작업 UI (모두선택, 이동, 차단, 임시보관) |
| `v7/admin/move-post.php` | 글 이동 관리 페이지 (Vue.js 동적 게시판/카테고리 선택) |

### 관리자 인증 패턴

```php
use Philgo\Utils\AuthService;
use V7\Utils\Config;

$_v7LoginUser = AuthService::getLoginUser();
$_isAdmin = false;
if ($_v7LoginUser) {
    $_isAdmin = in_array($_v7LoginUser->firebase_uid, Config::admins(), true);
}
```

### 차단 회원 조회 패턴

```php
use Philgo\Utils\Db;

$_blockedMemberIds = [];
if ($_v7LoginUser) {
    $stmtBlocked = Db::pdo()->prepare("SELECT idx_blockee FROM sf_member_blocks WHERE idx_blocker = ?");
    $stmtBlocked->execute([$_v7LoginUser->idx]);
    $_blockedMemberIds = $stmtBlocked->fetchAll(\PDO::FETCH_COLUMN, 0);
}
```

### 관리자 일괄 작업 URL 패턴

| 작업 | URL 패턴 | 설명 |
|------|----------|------|
| 글 이동 | `/admin/move-post?idxes=123,456` | 선택한 글을 다른 게시판으로 이동 |
| 글 이동 + 차단 | `/admin/move-post?idxes=123,456&block=1` | 이동 + 작성자 차단 |
| 임시 보관 | `/admin/move-post?idxes=123,456&target_post_id=temp` | 임시 보관 게시판으로 이동 |

### DB 테이블 참조

#### sf_member_blocks (회원 차단)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx` | int | PK (AUTO_INCREMENT) |
| `idx_blocker` | int | 차단한 회원의 sf_member.idx |
| `idx_blockee` | int | 차단된 회원의 sf_member.idx |
| `created_at` | int | 차단 시간 (Unix timestamp) |

#### sf_post_config.category

카테고리 컬럼명은 `category` (단수형)이다. 줄바꿈(`\n`)으로 구분된 문자열이다.

### JavaScript 주의사항

- v7에서는 `ready()` 함수가 없다. `document.addEventListener('DOMContentLoaded', ...)` 사용 필수이다.
- 전역 함수는 `window.functionName = function() {...}` 패턴으로 등록한다.
- bfcache(브라우저 back 버튼) 대응을 위해 `pageshow` 이벤트에서 체크박스를 초기화한다.

### 상세 문서

관리자 일괄 작업 UI, 글 이동 페이지, Vue.js 동적 카테고리 선택, 차단 사유 옵션 등
상세 내용은 → [v7-admin.md 18장](../web/v7-admin.md#18-게시글-목록-관리자-기능-체크박스--일괄-작업--글-이동) 참조.

---

## 코멘트(댓글) 시스템

### 개요

v7 코멘트 시스템은 `sf_post_data` 테이블을 게시글과 공유하며, `depth > 0`인 레코드가 코멘트이다.
대댓글(스레딩)은 v6의 `find_last_child_comment()` + `update_comment_thread()` 로직을 완벽 이식하여 트리 구조를 지원한다.

### 핵심 필드 (코멘트 관련)

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx_root` | int | 원글(게시글) idx — 모든 코멘트가 공유하는 루트 |
| `idx_parent` | int | 부모 코멘트 idx (최상위 코멘트는 idx_root와 동일) |
| `depth` | int | 깊이 (0=글, 1=1차 코멘트, 2=대댓글, 3=대대댓글...) |
| `list_order` | int | 트리 내 정렬 순서 (DESC 정렬, 큰 값=위쪽/오래된 것) |

### 트리 구조 알고리즘 (v6 완벽 이식)

코멘트 생성 시 `PostRepository::updateCommentThread()`가 호출되어 `list_order`와 `depth`를 계산한다.

#### 1. 최상위 코멘트 (idx_parent == idx_root)

```
list_order = 0, depth = 1
기존 모든 코멘트의 list_order를 +1 시프트
→ DESC 정렬에서 맨 아래(최신)에 표시
```

#### 2. 대댓글 (idx_parent != idx_root)

```
depth = 부모.depth + 1
부모의 마지막 자손(findLastChildComment) 위치의 list_order를 구함
그 위치 이상인 코멘트들의 list_order를 +1 시프트
→ DESC 정렬에서 부모 트리 바로 아래에 표시
```

#### 정렬 순서

```sql
ORDER BY list_order DESC
```

`list_order`가 큰(오래된) 코멘트가 먼저 표시되고, 작은(최신) 코멘트가 나중에 표시된다.
대댓글은 부모 코멘트 바로 아래에 들여쓰기와 함께 표시된다.

### 트리 표시 예시

```
Comment-A (first)        depth=1, list_order=5
  Reply-A-1              depth=2, list_order=4
    Reply-A-1-1          depth=3, list_order=3
  Reply-A-2              depth=2, list_order=2
Comment-B (second)       depth=1, list_order=1
Comment-C (third)        depth=1, list_order=0
```

### 핵심 메서드

| 클래스 | 메서드 | 설명 |
|--------|--------|------|
| `PostRepository` | `findComments($idxRoot)` | 코멘트 목록 조회 (list_order DESC) |
| `PostRepository` | `findLastChildComment($idx)` | 재귀적으로 마지막 자손 코멘트 탐색 |
| `PostRepository` | `updateCommentThread($idxRoot, $idxParent)` | 새 코멘트 삽입 위치 계산 + list_order 시프트 |
| `PostService` | `commentCreate($input)` | 코멘트 생성 (updateCommentThread 호출) |
| `PostService` | `commentList($input)` | 코멘트 목록 반환 |

### API 엔드포인트 (코멘트)

#### post.commentCreate — 코멘트 생성

인증 필요.

```
POST /api.php
method=post.commentCreate&idx_root=12345&content=댓글내용
method=post.commentCreate&idx_root=12345&idx_parent=67890&content=대댓글내용
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx_root | int | O | 원글 idx |
| idx_parent | int | X | 부모 코멘트 idx (생략 시 idx_root 사용 → 최상위 코멘트) |
| content | string | O | 코멘트 내용 |

**응답**: 생성된 코멘트의 PostEntity 배열

#### post.commentList — 코멘트 목록

인증 불필요.

```
GET /api.php?method=post.commentList&idx_root=12345
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx_root | int | O | 원글 idx |

**응답**: PostEntity 배열 (list_order DESC 정렬)

### v6 함수와의 대응 관계

| v6 (레거시) | v7 (신규) |
|------------|-----------|
| `find_last_child_comment($idx)` | `PostRepository::findLastChildComment($idx)` |
| `update_comment_thread($idx_post, $idx_parent, $idx_comment)` | `PostRepository::updateCommentThread($idxRoot, $idxParent)` |
| `get_comment($idx)` | `PostRepository::findByIdx($idx)` |
| `comment_create($input)` | `PostService::commentCreate($input)` |
| `ORDER BY list_order DESC` | `PostRepository::findComments()` 기본 정렬 |

### 웹 페이지 (코멘트 렌더링)

| 파일 | 설명 |
|------|------|
| `v7/post/view.php` (라인 243~393) | SSR 코멘트 렌더링 — **Reddit 스타일 gutter 방식 재귀 트리 구조** (`countDescendants()` + `renderCommentThread()` 재귀 함수) |
| `v7/post/view.css` (라인 679~936) | 코멘트 영역 전용 CSS — gutter 방식 세로선, 접기/펼치기, 다크모드, 반응형 |
| `v7/js/comment.js` (라인 14~63) | Vue.js 코멘트 CRUD + gutter 방식 접기/펼치기 이벤트 위임 (collapse-btn, collapse-slot, gutter-slot 클릭 모두 지원) |

코멘트는 기존의 `thread-line-col` 방식에서 **gutter 방식**으로 전면 재작성되었다.
`$childrenMap`(부모 idx → 자식 배열 맵)을 구축한 후, `renderCommentThread()` 함수가 각 코멘트를
재귀적으로 렌더링한다. 핵심 원리는 각 코멘트 왼쪽에 **depth 수만큼의 `gutter-slot`을 렌더링**하여
조상 세로선이 자손까지 자연스럽게 관통하는 것이다. `ancestorLastFlags` 배열로 마지막 자식 이후의
세로선을 숨기며(`.no-line` 클래스), 접기/펼치기는 자식이 있는 코멘트의 `collapse-btn`으로 제어한다.

### 코멘트 디자인 시스템

#### 사용 Web Awesome Pro 컴포넌트

| 컴포넌트 | 속성 | 용도 |
|----------|------|------|
| `wa-avatar` | `initials`, `shape="circle"` | 코멘트 작성자 이니셜을 원형 아바타로 표시. 작성자명 첫 글자를 `mb_substr($c->user_name, 0, 1)`로 추출하여 initials에 전달 |
| `wa-relative-time` | `date`, `lang="ko"` | 절대 시간(`2024-01-15 14:30`) 대신 상대 시간(`3시간 전`)으로 표시. date에 `date('c', $c->stamp)` ISO 8601 형식 전달 |
| `wa-badge` | `variant="brand"`, `pill` | 코멘트 섹션 타이틀에 댓글 수를 블루 배지로 표시 |

#### Reddit 스타일 스레드 구조 (gutter 방식)

기존의 `thread-line-col` 방식에서 **gutter 방식**으로 전면 재작성되었다.
gutter 방식의 핵심은 각 코멘트 왼쪽에 **depth 수만큼의 `gutter-slot`을 직접 렌더링**하여
조상 세로선이 자손 코멘트까지 자연스럽게 관통하는 것이다.

**핵심 변경 사항:**

| 항목 | 이전 (thread-line-col 방식) | 현재 (gutter 방식) |
|------|---------------------------|-------------------|
| **들여쓰기 방식** | `.thread-line-col` 단일 세로선 열 (24px) | `.gutter` 내부에 `gutter-slot × depth` + `collapse-slot` 배치 |
| **세로선 연속성** | 현재 코멘트의 세로선만 표시 | **조상 세로선이 자손까지 관통** (depth별 gutter-slot의 `::before` 의사 요소) |
| **마지막 자식 처리** | `.is-last-child` 클래스 + 곡선 마감 | `ancestorLastFlags` 배열로 `.no-line` 클래스 → 마지막 자식 이후 조상 세로선 숨김 |
| **접기/펼치기 버튼** | 모든 코멘트에 `.thread-toggle-btn` | **자식이 있는 코멘트만** `.collapse-btn` 표시 |
| **접기 트리거** | `.thread-toggle-btn` + `.thread-line` 클릭 | `.collapse-btn` + `.collapse-slot` + `.gutter-slot` 클릭 모두 지원 |
| **CSS 컨테이너** | `.comment-thread` (flex) | `.comment-node` > `.comment-row` > (`.gutter` + `.comment-content`) |
| **접힌 상태 표시** | 자식 있음: `[+N개 답글]`, 리프: `[접힌 댓글]` | 동일 (변경 없음) |
| **접힌 시 숨김** | `.collapsed` 시 본문/파일/액션/자식 숨김 | 동일 + `.collapse-slot::before` 세로선도 숨김 |

**핵심 함수:**

| 함수 | 시그니처 | 설명 |
|------|---------|------|
| `countDescendants()` | `countDescendants(int $parentIdx, array &$childrenMap): int` | 재귀적으로 하위 코멘트 총 수를 계산. 접힌 상태에서 `[+N개 답글]` 표시에 사용 |
| `renderCommentThread()` | `renderCommentThread(array $commentArr, array &$childrenMap, int $depth = 0, array $ancestorLastFlags = [], bool $isLast = false): void` | gutter 방식 재귀 렌더링. `$depth`로 gutter-slot 수 결정, `$ancestorLastFlags`로 조상 세로선 숨김 제어 |

**`ancestorLastFlags` 동작 원리:**

```
$ancestorLastFlags[$depth] = $isLast
```

각 depth에서 현재 코멘트가 마지막 자식(`$isLast = true`)인지를 기록한다.
자식 코멘트를 재귀 렌더링할 때 `$newFlags = $ancestorLastFlags; $newFlags[$depth] = $isLast;`로
부모의 마지막 여부를 전달한다. gutter-slot 렌더링 시 해당 depth의 플래그가 `true`이면
`.no-line` 클래스를 추가하여 `::before` 세로선을 숨긴다.

**데이터 흐름:**

```
$comments (flat 배열, list_order DESC)
  ↓
$childrenMap[$parentIdx][] = $commentArr  (부모별 자식 맵 구축)
  ↓
최상위 코멘트: $childrenMap[$idx] (글의 idx가 부모인 코멘트들)
  ↓
renderCommentThread($comment, $childrenMap, $depth=0, $ancestorLastFlags=[], $isLast) — 재귀 호출
  ↓
countDescendants($c->idx, $childrenMap) — 전체 하위 수 계산
  ↓
각 코멘트: .gutter(gutter-slot × depth + collapse-slot) + .comment-content(본문 + .thread-children 재귀)
```

#### 코멘트 HTML 구조 (SSR — gutter 방식 재귀 트리)

```php
<!-- 코멘트 목록 (SSR - Reddit 스타일 gutter 방식 스레드) -->
<?php if (!empty($comments)): ?>
    <?php
    // flat 리스트를 부모별 자식 맵으로 변환 (트리 구조용)
    $childrenMap = [];
    foreach ($comments as $commentArr) {
        $parentIdx = (int)($commentArr['idx_parent'] ?? 0);
        $childrenMap[$parentIdx][] = $commentArr;
    }

    /**
     * 하위 코멘트 수를 재귀적으로 계산
     */
    function countDescendants(int $parentIdx, array &$childrenMap): int {
        $children = $childrenMap[$parentIdx] ?? [];
        $count = count($children);
        foreach ($children as $child) {
            $count += countDescendants((int)$child['idx'], $childrenMap);
        }
        return $count;
    }

    /**
     * gutter 방식 코멘트 스레드 재귀 렌더링 (Reddit 스타일)
     *
     * 각 코멘트 왼쪽에 조상 세로선을 직접 렌더링하여
     * 세로선이 항상 올바른 위치에 표시됨.
     *
     * @param array $commentArr 코멘트 데이터 배열
     * @param array $childrenMap 부모 idx → 자식 배열 맵 (참조)
     * @param int $depth 현재 깊이 (0 = 최상위 코멘트)
     * @param array $ancestorLastFlags 각 depth에서 마지막 자식 여부 [depth => bool]
     * @param bool $isLast 현재 코멘트가 부모의 마지막 자식인지
     */
    function renderCommentThread(array $commentArr, array &$childrenMap, int $depth = 0, array $ancestorLastFlags = [], bool $isLast = false): void {
        $c = PostEntity::fromArray($commentArr);
        $children = $childrenMap[$c->idx] ?? [];
        $hasChildren = !empty($children);
        $totalDescendants = $hasChildren ? countDescendants($c->idx, $childrenMap) : 0;

        $nodeClasses = 'comment-node';
        if ($hasChildren) $nodeClasses .= ' has-children';
        ?>
        <div class="<?= $nodeClasses ?>" data-idx="<?= $c->idx ?>" data-depth="<?= $depth ?>">
            <div class="comment-row">
                <!-- gutter: 조상 세로선들 + 현재 토글 -->
                <div class="gutter">
                    <?php for ($d = 0; $d < $depth; $d++): ?>
                        <div class="gutter-slot<?= (!empty($ancestorLastFlags[$d])) ? ' no-line' : '' ?>"></div>
                    <?php endfor; ?>
                    <div class="collapse-slot" data-has-children="<?= $hasChildren ? '1' : '0' ?>">
                        <?php if ($hasChildren): ?>
                            <button class="collapse-btn" aria-expanded="true" title="댓글 스레드 접기/펼치기">
                                <i class="fa-regular fa-circle-minus collapse-icon-expanded"></i>
                                <i class="fa-regular fa-circle-plus collapse-icon-collapsed"></i>
                            </button>
                        <?php endif; ?>
                    </div>
                </div>

                <!-- 코멘트 내용 -->
                <div class="comment-content">
                    <div class="comment-main-row">
                        <div class="comment-avatar">
                            <wa-avatar initials="<?= htmlspecialchars(mb_substr($c->user_name ?: '?', 0, 1)) ?>"
                                       label="<?= htmlspecialchars($c->user_name ?: '익명') ?>"
                                       shape="circle"></wa-avatar>
                        </div>
                        <div class="comment-body-wrap">
                            <div class="post-comment-header">
                                <strong class="comment-author"><?= htmlspecialchars($c->user_name ?: '익명') ?></strong>
                                <span class="comment-date">
                                    <?php if ($c->stamp > 0): ?>
                                        <wa-relative-time date="<?= date('c', $c->stamp) ?>" lang="ko"></wa-relative-time>
                                    <?php endif; ?>
                                </span>
                                <?php if ($hasChildren): ?>
                                    <span class="thread-collapsed-info">[+<?= $totalDescendants ?>개 답글]</span>
                                <?php else: ?>
                                    <span class="thread-collapsed-info">[접힌 댓글]</span>
                                <?php endif; ?>
                            </div>
                            <div class="post-comment-body">
                                <!-- 본문 내용 (차단/블라인드 처리 포함) -->
                            </div>
                            <div class="comment-files"><!-- 첨부 이미지 --></div>
                            <div class="post-comment-actions" data-idx="<?= $c->idx ?>"
                                 data-idx-root="<?= $c->idx_root ?>" data-depth="<?= $c->depth ?>"></div>
                        </div>
                    </div>

                    <!-- 자식 코멘트 (재귀) -->
                    <?php if ($hasChildren): ?>
                        <div class="thread-children">
                            <?php
                            $lastIdx = count($children) - 1;
                            $newFlags = $ancestorLastFlags;
                            $newFlags[$depth] = $isLast;
                            foreach ($children as $i => $child):
                                renderCommentThread($child, $childrenMap, $depth + 1, $newFlags, $i === $lastIdx);
                            endforeach;
                            ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
        <?php
    }
    ?>

    <div class="post-comment-list reddit-threads" id="comment-list">
        <?php
        // 최상위 코멘트 렌더링 (idx_parent == idx_root)
        $topLevelComments = $childrenMap[$idx] ?? [];
        $topLastIdx = count($topLevelComments) - 1;
        foreach ($topLevelComments as $ti => $topComment):
            renderCommentThread($topComment, $childrenMap, 0, [], $ti === $topLastIdx);
        endforeach;
        ?>
    </div>
<?php endif; ?>
```

#### 코멘트 CSS 핵심 스타일 (gutter 방식)

**블루 테마 적용**: 코멘트 영역 전체가 v7 블루 테마를 따른다.

```css
/* === 코멘트 노드 === */
.comment-node { position: relative; }

/* 코멘트 행: gutter + content */
.comment-row {
    display: flex;
    align-items: stretch;
    position: relative;
}

/* 최상위 코멘트 간 구분선 */
.reddit-threads > .comment-node + .comment-node {
    border-top: 1px solid var(--wa-color-neutral-200, #e2e8f0);
    margin-top: 0.25rem;
    padding-top: 0.25rem;
}

/* === gutter: 세로선 영역 === */
.gutter {
    position: relative;
    flex: 0 0 auto;
    display: flex;
}

/* depth 하나당 한 칸 (조상 세로선) */
.gutter-slot {
    width: 24px;
    position: relative;
    flex: 0 0 24px;
}

/* 조상 세로선 (::before로 렌더링) */
.gutter-slot::before {
    content: "";
    position: absolute;
    left: 50%; top: 0; bottom: 0;
    width: 2px;
    background: var(--wa-color-neutral-300, #cbd5e1);
    transform: translateX(-50%);
    cursor: pointer;
    transition: background-color 0.15s, width 0.1s;
}
.gutter-slot:hover::before {
    background: var(--wa-color-brand-500, #3b82f6);
    width: 3px;
}

/* 마지막 자식 이후: 조상 세로선 숨김 */
.gutter-slot.no-line::before { display: none; }

/* === 현재 코멘트의 접기/펼치기 열 === */
.collapse-slot {
    width: 24px;
    position: relative;
    flex: 0 0 24px;
    cursor: pointer;
}

/* 현재 코멘트의 세로선 */
.collapse-slot::before {
    content: "";
    position: absolute;
    left: 50%; top: 0; bottom: 0;
    width: 2px;
    background: var(--wa-color-neutral-300, #cbd5e1);
    transform: translateX(-50%);
    transition: background-color 0.15s;
}
.collapse-slot:hover::before {
    background: var(--wa-color-brand-500, #3b82f6);
}

/* 자식 없는 코멘트: 세로선 숨김 */
.collapse-slot[data-has-children="0"]::before { display: none; }

/* === 접기/펼치기 버튼 (자식 있는 코멘트만) === */
.collapse-btn {
    position: absolute;
    top: 18px; left: 50%;
    transform: translate(-50%, -50%);
    width: 20px; height: 20px;
    border: none; border-radius: 50%;
    background: #fff;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.9rem; z-index: 2;
    cursor: pointer;
    color: var(--wa-color-neutral-400, #94a3b8);
    transition: color 0.15s, background-color 0.15s;
    padding: 0;
}
.collapse-btn:hover {
    color: var(--wa-color-brand-600, #2563eb);
    background-color: var(--wa-color-brand-50, #eff6ff);
}

/* 기본(펼침) 상태: ⊖ 표시, ⊕ 숨김 */
.collapse-icon-expanded { display: inline; }
.collapse-icon-collapsed { display: none; }

/* 접힌 상태 아이콘 전환 */
.comment-node.collapsed .collapse-icon-expanded { display: none; }
.comment-node.collapsed .collapse-icon-collapsed { display: inline; }

/* === 코멘트 내용 영역 === */
.comment-content {
    flex: 1; min-width: 0;
    padding: 4px 0 6px 8px;
}
.comment-main-row { display: flex; gap: 0.5rem; padding: 0.2rem 0; }
.thread-children { padding-left: 0; }

/* === 접힌 상태 처리 === */
.comment-node.collapsed .post-comment-body,
.comment-node.collapsed .comment-files,
.comment-node.collapsed .post-comment-actions,
.comment-node.collapsed .thread-children { display: none; }

/* 접힌 상태 알림 텍스트 (기본 숨김) */
.thread-collapsed-info {
    display: none;
    font-size: 0.7rem;
    color: var(--wa-color-brand-600, #2563eb);
    cursor: pointer; font-weight: 500;
}
.comment-node.collapsed .thread-collapsed-info { display: inline; }

/* 접힌 상태: collapse-slot 세로선 숨기기 */
.comment-node.collapsed > .comment-row > .gutter > .collapse-slot::before { display: none; }

/* === 아바타 크기 === */
.comment-node .comment-avatar wa-avatar { --size: 1.75rem; font-size: 0.7rem; }
.reddit-threads > .comment-node > .comment-row > .comment-content > .comment-main-row .comment-avatar wa-avatar {
    --size: 2rem; font-size: 0.75rem;
}
```

#### 접기/펼치기 JavaScript (gutter 방식)

`v7/js/comment.js` 라인 14~63에 이벤트 위임 코드로 구현되어 있다.
3가지 클릭 대상을 모두 지원한다: (1) `collapse-btn` 버튼 직접 클릭, (2) `collapse-slot` 세로선 클릭, (3) `gutter-slot` 조상 세로선 클릭.

```javascript
// Reddit 스타일 스레드 접기/펼치기 (gutter 방식 이벤트 위임)
document.addEventListener('click', function (e) {
    var btn = e.target.closest('.collapse-btn');

    // collapse-slot 세로선 직접 클릭
    if (!btn) {
        var slot = e.target.closest('.collapse-slot');
        if (slot && slot.dataset.hasChildren === '1') {
            btn = slot.querySelector('.collapse-btn');
        }
    }

    // gutter-slot 세로선 클릭 → 해당 depth의 조상 코멘트 접기
    if (!btn) {
        var gutterSlot = e.target.closest('.gutter-slot');
        if (gutterSlot && !gutterSlot.classList.contains('no-line')) {
            var gutter = gutterSlot.parentElement;
            if (!gutter || !gutter.classList.contains('gutter')) return;
            // gutter-slot의 인덱스(= 대상 depth) 계산
            var slots = [];
            for (var ch = gutter.firstElementChild; ch; ch = ch.nextElementSibling) {
                if (ch.classList.contains('gutter-slot')) slots.push(ch);
                else break;
            }
            var targetDepth = slots.indexOf(gutterSlot);
            if (targetDepth < 0) return;

            // 현재 노드에서 targetDepth까지 부모를 거슬러 올라감
            var node = gutterSlot.closest('.comment-node');
            while (node) {
                var d = parseInt(node.dataset.depth, 10);
                if (d === targetDepth) break;
                node = node.parentElement ? node.parentElement.closest('.comment-node') : null;
            }
            if (node && node.classList.contains('has-children')) {
                btn = node.querySelector(':scope > .comment-row > .gutter > .collapse-slot > .collapse-btn');
            }
        }
    }

    if (!btn) return;

    var node = btn.closest('.comment-node');
    if (!node) return;

    node.classList.toggle('collapsed');
    btn.setAttribute('aria-expanded', node.classList.contains('collapsed') ? 'false' : 'true');
});
```

**동작 방식:**

| 상태 | 아이콘 | collapse-slot 세로선 | 본문/파일/액션 | 자식 코멘트 | 알림 텍스트 |
|------|--------|---------------------|-------------|-----------|-----------|
| **펼침 (기본)** | `fa-circle-minus` (⊖) | 표시 | 표시 | 표시 | 숨김 |
| **접힘 (자식 있음)** | `fa-circle-plus` (⊕) | 숨김 | 숨김 | 숨김 | `[+N개 답글]` 표시 (전체 하위 수) |
| **접힘 (리프)** | — (버튼 없음) | — | 숨김 | — | `[접힌 댓글]` 표시 |

**접힌 상태에서 숨겨지는 요소:**
- `.post-comment-body` — 코멘트 본문 텍스트
- `.comment-files` — 첨부 파일/이미지
- `.post-comment-actions` — 답글/수정/삭제 등 액션 버튼
- `.thread-children` — 하위 코멘트 전체
- `.collapse-slot::before` — 현재 코멘트의 세로선

**트리거 방법 (3가지):**
- `.collapse-btn` 클릭 (⊖/⊕ 아이콘 버튼) — **자식이 있는 코멘트에만 존재**
- `.collapse-slot` 클릭 (현재 코멘트의 세로선 영역)
- `.gutter-slot` 클릭 (조상 세로선) — 클릭한 gutter-slot의 depth에 해당하는 **조상 코멘트**를 거슬러 올라가서 접기/펼치기

#### 코멘트 모바일 반응형 (`@media max-width: 640px`)

| 요소 | 데스크톱 | 모바일 (640px 이하) |
|------|---------|------------------|
| gutter-slot / collapse-slot 너비 | `24px` | `18px` |
| 코멘트 아바타 | `--size: 1.75rem` | `--size: 1.5rem` |
| 최상위 아바타 | `--size: 2rem` | `--size: 1.75rem` |
| collapse-btn 크기 | `20px x 20px` | `16px x 16px` |
| collapse-btn top 위치 | `18px` | `14px` |
| comment-content padding-left | `8px` | `4px` |
| 본문 행 간격 | `gap: 0.5rem` | `gap: 0.35rem` |
| 작성 폼 레이아웃 | 가로 (flex-row) | 세로 (flex-column) |
| 입력 액션 위치 | textarea 옆 | textarea 아래 (우측 정렬) |

#### 다크모드 보정

```css
@media (prefers-color-scheme: dark) {
    .gutter-slot::before,
    .collapse-slot::before {
        background: var(--wa-color-neutral-600, #475569);
    }
    .gutter-slot:hover::before,
    .collapse-slot:hover::before {
        background: var(--wa-color-brand-400, #60a5fa);
    }
    .collapse-btn {
        background: var(--wa-color-neutral-900, #0f172a);
        color: var(--wa-color-neutral-500, #64748b);
    }
    .collapse-btn:hover {
        color: var(--wa-color-brand-400, #60a5fa);
        background-color: rgba(59, 130, 246, 0.15);
    }
    .thread-collapsed-info { color: var(--wa-color-brand-400, #60a5fa); }
    .reddit-threads > .comment-node + .comment-node {
        border-top-color: var(--wa-color-neutral-700, #334155);
    }
}
```

#### 빈 상태 디자인

댓글이 없을 때 아이콘 + 분리된 메시지 + 부가 텍스트로 친근한 빈 상태를 표시한다.

```css
.post-comments-empty {
    padding: 2.5rem 1rem; text-align: center;
    color: var(--wa-color-neutral-400, #94a3b8);
}
.post-comments-empty i {
    font-size: 2.5rem; margin-bottom: 0.75rem; display: block;
    color: var(--wa-color-neutral-300, #cbd5e1);
}
.post-comments-empty p {
    margin: 0 0 0.25rem; font-size: 0.9rem; font-weight: 600;
    color: var(--wa-color-neutral-500, #64748b);
}
.post-comments-empty span {
    font-size: 0.8rem;
    color: var(--wa-color-neutral-400, #94a3b8);
}
```

#### 코멘트 디자인 수정 시 주의사항

| 규칙 | 설명 |
|------|------|
| **gutter 방식 구조 유지** | 코멘트 목록은 반드시 `renderCommentThread()` 재귀 함수로 gutter 방식 트리 구조를 렌더링해야 한다. `thread-line-col` 방식이나 flat 구조로 되돌리지 않는다 |
| **gutter-slot = depth 수** | 각 코멘트의 `.gutter` 내부에 depth 수만큼의 `.gutter-slot`이 있어야 한다. 이는 조상 세로선이 자손까지 관통하는 핵심 원리이다 |
| **collapse-btn은 자식 있는 코멘트만** | `.collapse-btn` 버튼은 `$hasChildren`이 true인 코멘트에만 렌더링한다. 리프 코멘트에는 접기 버튼이 없다 |
| **`ancestorLastFlags` 전달 필수** | `renderCommentThread()` 호출 시 `$ancestorLastFlags` 배열을 전달하여 마지막 자식 이후 조상 세로선을 `.no-line` 클래스로 숨겨야 한다 |
| **`countDescendants()` 사용** | 접힌 상태 텍스트에는 직접 자식 수가 아닌 `countDescendants()`로 계산한 **전체 하위 코멘트 수**를 표시한다 |
| **블루 테마 유지** | 코멘트 영역의 모든 interactive 요소(버튼, 포커스, hover, 세로선)는 `--wa-color-brand-*` 블루 변수를 사용해야 한다. 빨간색(`#7f1d1d`, `#dc2626`)은 삭제 액션에만 허용 |
| **3가지 접기 트리거** | `.collapse-btn` 클릭, `.collapse-slot` 클릭, `.gutter-slot` 클릭 모두 접기/펼치기를 트리거한다. 이벤트 위임(`v7/js/comment.js` 라인 14~63)으로 구현되어 있다 |
| **gutter-slot 클릭 = 조상 접기** | `.gutter-slot` 클릭 시 해당 slot의 depth에 대응하는 **조상** 코멘트를 찾아서 접기/펼치기한다. DOM 트리를 거슬러 올라가는 로직이 `comment.js`에 구현됨 |
| **`collapsed` 클래스** | `.comment-node.collapsed` 클래스가 토글되면 본문/파일/액션/자식 숨김, 아이콘 전환, `[+N개 답글]` 또는 `[접힌 댓글]` 표시, `.collapse-slot::before` 세로선 숨김이 모두 CSS로 처리된다. JavaScript에서 `classList.toggle('collapsed')`만 호출하면 된다 |
| **접힌 상태 표시 분기** | 자식이 있는 코멘트: `[+N개 답글]` (N = 전체 하위 수). 리프 코멘트: `[접힌 댓글]` |
| **wa-avatar initials 필수** | 코멘트 작성자 아바타는 `wa-avatar`의 `initials` 속성으로 구현. 이미지 URL 없이 이니셜로 표시 |
| **wa-relative-time 필수** | 코멘트 시간은 `wa-relative-time`으로 표시. `date` 속성에 ISO 8601(`date('c', $stamp)`) 전달, `lang="ko"` 필수 |
| **$childrenMap 구조** | `$childrenMap[$parentIdx][]`로 부모별 자식 맵을 구축한다. 최상위 코멘트는 `$childrenMap[$idx]`(글의 idx)에서 가져온다 |
| **hover 효과** | gutter-slot/collapse-slot hover 시 `brand-500` 파란색 + 3px 굵기. 첨부 이미지 hover 시 `scale(1.02)` |
| **collapse-btn 배경** | 다크모드에서 `.collapse-btn` 배경은 `neutral-900`으로 설정하여 gutter 세로선 위에 원형 버튼이 떠있는 효과를 낸다 |
