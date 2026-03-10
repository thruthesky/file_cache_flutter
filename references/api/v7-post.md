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
   - [Reddit 스타일 스레드 구조 (thread-line 절대 위치 + L자형 수평 연결선)](#reddit-스타일-스레드-구조-thread-line-절대-위치-방식)
   - [코멘트 HTML 구조 (SSR — thread-line 방식 재귀 트리)](#코멘트-html-구조-ssr--thread-line-방식-재귀-트리)
   - [코멘트 CSS 핵심 스타일 (thread-line + L자형 수평 연결선)](#코멘트-css-핵심-스타일-thread-line-절대-위치-방식)
   - [접기/펼치기 JavaScript (thread-line + collapse-btn 방식)](#접기펼치기-javascript-thread-line--collapse-btn-방식)
   - [코멘트 모바일 반응형](#코멘트-모바일-반응형-media-max-width-640px)
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
| `v7/post/view.php` (라인 243~383) | SSR 코멘트 렌더링 — **Reddit 스타일 thread-line 절대 위치 방식 재귀 트리 구조** (`countDescendants()` + `renderCommentThread()` 재귀 함수) |
| `v7/post/view.css` (라인 679~896) | 코멘트 영역 전용 CSS — `div.thread-line` 절대 위치 세로선, L자형 수평 연결선(`::before`), collapse-toggle 접기/펼치기, 반응형 |
| `v7/js/comment.js` (라인 14~47) | Vue.js 코멘트 CRUD + thread-line 클릭 + collapse-btn/collapse-toggle 클릭 접기/펼치기 이벤트 위임 |

코멘트는 **`div.thread-line` 절대 위치 방식 + L자형 수평 연결선**으로 구현되어 있다.
`$childrenMap`(부모 idx → 자식 배열 맵)을 구축한 후, `renderCommentThread()` 함수가 각 코멘트를
재귀적으로 렌더링한다. 핵심 원리는 `$hasChildren`인 코멘트 노드에 `<div class="thread-line">`
요소를 추가하고, `position: absolute`로 collapse 버튼 아래(`top: 30px`)에서 노드 하단(`bottom: 0`)까지
끊기지 않는 연속 세로선을 구현하는 것이다. 추가로 `.thread-children > .comment-node::before`
의사 요소로 부모 세로선에서 자식 코멘트까지 L자형 수평 연결선(2px 높이)을 렌더링한다.
`.thread-children`에는 `border-left` 없이 `margin-left: 11px; padding-left: 21px`로 들여쓰기를
처리하며, 수평 연결선은 `left: -21px`에서 시작하여 `width: 18px`로 부모 세로선까지 연결한다.
접기/펼치기는 `.thread-line` 클릭, `.collapse-btn` 클릭, `.collapse-toggle` 영역 클릭 3가지로 제어한다.

### 코멘트 디자인 시스템

#### 사용 Web Awesome Pro 컴포넌트

| 컴포넌트 | 속성 | 용도 |
|----------|------|------|
| `wa-avatar` | `initials`, `shape="circle"` | 코멘트 작성자 이니셜을 원형 아바타로 표시. 작성자명 첫 글자를 `mb_substr($c->user_name, 0, 1)`로 추출하여 initials에 전달 |
| `wa-relative-time` | `date`, `lang="ko"` | 절대 시간(`2024-01-15 14:30`) 대신 상대 시간(`3시간 전`)으로 표시. date에 `date('c', $c->stamp)` ISO 8601 형식 전달 |
| `wa-badge` | `variant="brand"`, `pill` | 코멘트 섹션 타이틀에 댓글 수를 블루 배지로 표시 |

#### Reddit 스타일 스레드 구조 (thread-line 절대 위치 방식)

세로선은 **`<div class="thread-line">` 절대 위치 요소**로 구현한다.
자식이 있는(`$hasChildren`) 코멘트 노드에 `<div class="thread-line">`을 삽입하고,
`position: absolute`로 collapse 버튼 중앙 아래(`top: 30px`)에서 노드 하단(`bottom: 0`)까지
끊기지 않는 연속 세로선을 렌더링한다. `.thread-children`에는 `border-left`를 적용하지 않고
`margin-left: 11px; padding-left: 21px`로 들여쓰기를 처리한다.

**L자형 수평 연결선**: `.thread-children > .comment-node::before` 의사 요소로 부모 세로선에서
자식 코멘트 아바타 높이까지 수평 연결선(2px 높이)을 렌더링한다. `left: -21px`에서 시작하여
`width: 18px`로 부모 세로선의 위치까지 연결하며, 색상은 세로선과 동일한 `#64748b`이다.

**방식 변경 이력:**

| 항목 | 이전 (border-left 방식) | 현재 (thread-line 절대 위치 방식) |
|------|------------------------|-------------------------------|
| **세로선 구현** | `.comment-node.has-children`에 `border-left: 3px solid` 적용 — 노드 전체 높이에 자동 관통 | `<div class="thread-line">` 요소를 `.comment-node` 내부에 삽입, `position: absolute; left: 10px; top: 30px; bottom: 0; width: 3px` — collapse 버튼 아래부터 노드 하단까지 |
| **세로선 색상** | `#cbd5e1` (neutral-300 계열, 정적) | `#64748b` (neutral-500 계열), hover 시 `#3b82f6` (blue) |
| **세로선 클릭 가능 여부** | 불가 (CSS border는 클릭 불가) | **가능** — `cursor: pointer`로 세로선 자체를 클릭하여 스레드 접기/펼치기 |
| **들여쓰기 방식** | `.thread-children`에 `margin-left: 10px` | `.thread-children`에 `margin-left: 11px; padding-left: 21px` |
| **L자형 수평 연결선** | 없음 | `.thread-children > .comment-node::before`로 부모 세로선에서 자식 코멘트까지 수평 연결선 (`left: -21px; top: 18px; width: 18px; height: 2px`) |
| **접기/펼치기 영역** | `.collapse-toggle > .collapse-btn` (2가지 클릭) | `.thread-line` + `.collapse-btn` + `.collapse-toggle` (3가지 클릭) |
| **접힌 상태 세로선** | border-left가 헤더까지만 표시 | `display: none`으로 세로선 완전 숨김 |
| **CSS 컨테이너** | `.comment-node(.has-children) > .comment-row > (.collapse-toggle + .comment-content) + .thread-children` | `.comment-node(.has-children) > .thread-line + .comment-row > (.collapse-toggle + .comment-content) + .thread-children` |
| **JavaScript** | collapse-btn/collapse-toggle 클릭만 처리 | `.thread-line` 클릭 우선 처리 + collapse-btn/collapse-toggle 클릭 보조 처리 |

**핵심 함수:**

| 함수 | 시그니처 | 설명 |
|------|---------|------|
| `countDescendants()` | `countDescendants(int $parentIdx, array &$childrenMap): int` | 재귀적으로 하위 코멘트 총 수를 계산. 접힌 상태에서 `[+N개 답글]` 표시에 사용 |
| `renderCommentThread()` | `renderCommentThread(array $commentArr, array &$childrenMap, int $depth = 0): void` | thread-line 절대 위치 + L자형 수평 연결선 방식 재귀 렌더링. `$depth`로 data-depth 속성 설정. `ancestorLastFlags`/`isLast` 파라미터 제거 |

**데이터 흐름:**

```
$comments (flat 배열, list_order DESC)
  ↓
$childrenMap[$parentIdx][] = $commentArr  (부모별 자식 맵 구축)
  ↓
최상위 코멘트: $childrenMap[$idx] (글의 idx가 부모인 코멘트들)
  ↓
renderCommentThread($comment, $childrenMap, $depth=0) — 재귀 호출
  ↓
countDescendants($c->idx, $childrenMap) — 전체 하위 수 계산
  ↓
각 코멘트: .comment-node(.has-children)
           > .thread-line (position: absolute, 세로선)
           + .comment-row > (.collapse-toggle + .comment-content)
           + .thread-children (margin-left: 11px, padding-left: 21px, 재귀)
               > .comment-node::before (L자형 수평 연결선, left: -21px, width: 18px)
```

#### 코멘트 HTML 구조 (SSR — thread-line 방식 재귀 트리)

```php
<!-- 코멘트 목록 (SSR - Reddit 스타일 thread-line 절대 위치 방식 스레드) -->
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
     * thread-line 절대 위치 방식 코멘트 스레드 재귀 렌더링 (Reddit 스타일)
     *
     * $hasChildren인 코멘트 노드에 <div class="thread-line">을 삽입하고,
     * position: absolute로 collapse 버튼 아래(top:30px)에서 노드 하단(bottom:0)까지
     * 끊기지 않는 연속 세로선 구현.
     * .thread-children에는 border-left 없이 margin-left + padding-left로 들여쓰기만 처리.
     *
     * @param array $commentArr 코멘트 데이터 배열
     * @param array $childrenMap 부모 idx → 자식 배열 맵 (참조)
     * @param int $depth 현재 깊이 (0 = 최상위 코멘트)
     */
    function renderCommentThread(array $commentArr, array &$childrenMap, int $depth = 0): void {
        $c = PostEntity::fromArray($commentArr);
        $children = $childrenMap[$c->idx] ?? [];
        $hasChildren = !empty($children);
        $totalDescendants = $hasChildren ? countDescendants($c->idx, $childrenMap) : 0;

        $nodeClasses = 'comment-node';
        if ($hasChildren) $nodeClasses .= ' has-children';
        ?>
        <div class="<?= $nodeClasses ?>" data-idx="<?= $c->idx ?>" data-depth="<?= $depth ?>">
            <?php if ($hasChildren): ?>
                <div class="thread-line" title="클릭하여 스레드 접기/펼치기"></div>
            <?php endif; ?>
            <div class="comment-row">
                <!-- 접기/펼치기 토글 -->
                <div class="collapse-toggle">
                    <?php if ($hasChildren): ?>
                        <button class="collapse-btn" aria-expanded="true" title="댓글 스레드 접기/펼치기">
                            <i class="fa-regular fa-circle-minus collapse-icon-expanded"></i>
                            <i class="fa-regular fa-circle-plus collapse-icon-collapsed"></i>
                        </button>
                    <?php endif; ?>
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
                </div>
            </div>

            <!-- 자식 코멘트: thread-line이 세로선, ::before가 L자형 수평 연결선 담당, 들여쓰기만 처리 -->
            <?php if ($hasChildren): ?>
                <div class="thread-children">
                    <!-- 각 자식 .comment-node에 ::before 의사 요소로 L자형 수평 연결선 자동 렌더링 -->
                    <?php foreach ($children as $child):
                        renderCommentThread($child, $childrenMap, $depth + 1);
                    endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
        <?php
    }
    ?>

    <div class="post-comment-list reddit-threads" id="comment-list">
        <?php
        // 최상위 코멘트 렌더링 (idx_parent == idx_root)
        $topLevelComments = $childrenMap[$idx] ?? [];
        foreach ($topLevelComments as $topComment):
            renderCommentThread($topComment, $childrenMap, 0);
        endforeach;
        ?>
    </div>
<?php endif; ?>
```

**border-left 방식과의 HTML 구조 차이:**

| 요소 | border-left 방식 (이전) | thread-line 절대 위치 방식 (현재) |
|------|------------------------|-------------------------------|
| 세로선 렌더링 | `.comment-node.has-children`의 `border-left: 3px solid` (CSS만으로 자동) | `<div class="thread-line">` 요소, `position: absolute` (클릭 가능한 독립 요소) |
| 세로선 인터랙션 | 클릭 불가 (CSS border) | **클릭 가능** (`cursor: pointer`, hover 시 파란색 `#3b82f6`) |
| 토글 버튼 위치 | `.collapse-toggle > .collapse-btn` | `.collapse-toggle > .collapse-btn` (동일) |
| 자식 코멘트 위치 | `.comment-node > .thread-children` (comment-row 외부) | `.comment-node > .thread-children` (동일, margin-left: 11px; padding-left: 21px) + L자형 수평 연결선(`.comment-node::before`) |
| 접힌 상태 세로선 | border-left가 여전히 보임 | `.collapsed > .thread-line { display: none }` 으로 완전 숨김 |

#### 코멘트 CSS 핵심 스타일 (thread-line 절대 위치 방식)

```css
/* === 코멘트 노드: thread-line의 절대 위치 기준 === */
.comment-node { position: relative; }

/* 코멘트 행: toggle + content */
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

/* === 절대 위치 세로선 (Reddit 동일) === */
/* collapse 버튼 중앙 아래에서 노드 하단까지 관통 */
.thread-line {
    position: absolute;
    left: 10px;
    top: 30px;
    bottom: 0;
    width: 3px;
    background-color: #64748b;
    border-radius: 2px;
    cursor: pointer;
    z-index: 10;
    transition: background-color 0.15s;
}

.thread-line:hover {
    background-color: #3b82f6;
}

/* 접힌 상태에서 세로선 숨김 */
.comment-node.collapsed > .thread-line {
    display: none;
}

/* === 접기/펼치기 토글 영역 === */
.collapse-toggle {
    width: 24px;
    flex: 0 0 24px;
    position: relative;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    z-index: 2;
}

/* === 접기/펼치기 버튼 (자식 있는 코멘트만) === */
.collapse-btn {
    position: relative;
    margin-top: 8px;
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
    padding: 4px 0 6px 4px;
}
.comment-main-row { display: flex; gap: 0.5rem; padding: 0.2rem 0; }

/* === 자식 코멘트 영역: 들여쓰기 (세로선은 thread-line이 담당) === */
.thread-children {
    margin-left: 11px;
    padding-left: 21px;
}

/* === L자형 수평 연결선: 부모 세로선에서 자식 코멘트로 연결 === */
.thread-children > .comment-node::before {
    content: '';
    position: absolute;
    left: -21px;
    top: 18px;
    width: 18px;
    height: 2px;
    background-color: #64748b;
    z-index: 5;
}

/* === 접힌 상태 처리 === */
.comment-node.collapsed > .comment-row .post-comment-body,
.comment-node.collapsed > .comment-row .comment-files,
.comment-node.collapsed > .comment-row .post-comment-actions,
.comment-node.collapsed > .thread-children { display: none; }

/* 접힌 상태 알림 텍스트 (기본 숨김) */
.thread-collapsed-info {
    display: none;
    font-size: 0.7rem;
    color: var(--wa-color-brand-600, #2563eb);
    cursor: pointer; font-weight: 500;
}
.comment-node.collapsed .thread-collapsed-info { display: inline; }

/* === 아바타 크기 === */
.comment-node .comment-avatar wa-avatar { --size: 1.75rem; font-size: 0.7rem; }
.reddit-threads > .comment-node > .comment-row > .comment-content > .comment-main-row .comment-avatar wa-avatar {
    --size: 2rem; font-size: 0.75rem;
}
```

#### 접기/펼치기 JavaScript (thread-line + collapse-btn 방식)

`v7/js/comment.js` 라인 16~47에 이벤트 위임 코드로 구현되어 있다.
3가지 클릭 대상을 지원한다: (1) `.thread-line` 세로선 클릭, (2) `.collapse-btn` 버튼 직접 클릭, (3) `.collapse-toggle` 영역 클릭.
`.thread-line` 클릭이 최우선으로 처리되고, 이후 collapse-btn/collapse-toggle 클릭이 보조 처리된다.

```javascript
// Reddit 스타일 스레드 접기/펼치기 (thread-line + collapse-btn 이벤트 위임)
document.addEventListener('click', function (e) {
    // 세로선 클릭: 해당 스레드 접기/펼치기
    var line = e.target.closest('.thread-line');
    if (line) {
        var node = line.closest('.comment-node');
        if (node) {
            node.classList.toggle('collapsed');
            var btn = node.querySelector('.collapse-btn');
            if (btn) {
                btn.setAttribute('aria-expanded', node.classList.contains('collapsed') ? 'false' : 'true');
            }
        }
        return;
    }

    // collapse 버튼 또는 토글 영역 클릭
    var btn = e.target.closest('.collapse-btn');
    if (!btn) {
        var toggle = e.target.closest('.collapse-toggle');
        if (toggle) {
            btn = toggle.querySelector('.collapse-btn');
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

| 상태 | 아이콘 | thread-line 세로선 | 본문/파일/액션 | 자식 코멘트 | 알림 텍스트 |
|------|--------|-------------------|-------------|-----------|-----------|
| **펼침 (기본)** | `fa-circle-minus` (⊖) | 표시 (`#64748b`, hover 시 `#3b82f6`) | 표시 | 표시 | 숨김 |
| **접힘 (자식 있음)** | `fa-circle-plus` (⊕) | **숨김** (`display: none`) | 숨김 | 숨김 | `[+N개 답글]` 표시 (전체 하위 수) |
| **접힘 (리프)** | — (버튼 없음) | — | 숨김 | — | `[접힌 댓글]` 표시 |

**접힌 상태에서 숨겨지는 요소:**
- `.thread-line` — 세로선 자체 (`display: none`)
- `.post-comment-body` — 코멘트 본문 텍스트
- `.comment-files` — 첨부 파일/이미지
- `.post-comment-actions` — 답글/수정/삭제 등 액션 버튼
- `.thread-children` — 하위 코멘트 전체

**트리거 방법 (3가지):**
- `.thread-line` 클릭 (세로선 자체) — **자식이 있는 코멘트에만 존재**, hover 시 파란색으로 변경되어 클릭 가능함을 시각적으로 표시
- `.collapse-btn` 클릭 (⊖/⊕ 아이콘 버튼) — **자식이 있는 코멘트에만 존재**
- `.collapse-toggle` 클릭 (토글 영역 전체)

#### 코멘트 모바일 반응형 (`@media max-width: 640px`)

| 요소 | 데스크톱 | 모바일 (640px 이하) |
|------|---------|------------------|
| collapse-toggle 너비 | `24px` | `20px` |
| 코멘트 아바타 | `--size: 1.75rem` | `--size: 1.5rem` |
| 최상위 아바타 | `--size: 2rem` | `--size: 1.75rem` |
| collapse-btn 크기 | `20px x 20px` | `16px x 16px` |
| collapse-btn margin-top | `8px` | `6px` |
| **thread-line left** | `10px` | `9px` |
| **thread-line top** | `30px` | `24px` |
| **thread-line bottom** | `0` | `6px` |
| comment-content padding-left | `4px` | `2px` |
| 본문 행 간격 | `gap: 0.5rem` | `gap: 0.35rem` |
| thread-children margin-left | `11px` | `9px` |
| thread-children padding-left | `21px` | `15px` |
| **수평 연결선 left** | `-21px` | `-15px` |
| **수평 연결선 top** | `18px` | `14px` |
| **수평 연결선 width** | `18px` | `12px` |
| 작성 폼 레이아웃 | 가로 (flex-row) | 세로 (flex-column) |
| 입력 액션 위치 | textarea 옆 | textarea 아래 (우측 정렬) |

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
| **thread-line 절대 위치 구조 유지** | 코멘트 목록은 반드시 `renderCommentThread()` 재귀 함수로 thread-line 방식 트리 구조를 렌더링해야 한다. border-left 방식이나 gutter-slot 방식으로 되돌리지 않는다 |
| **`.has-children` = thread-line 렌더링** | 자식이 있는 `.comment-node`에 `.has-children` 클래스를 추가하고, PHP에서 `<div class="thread-line">` 요소를 렌더링한다. 세로선은 CSS `position: absolute`로 구현한다 |
| **`.thread-line`은 `.comment-row` 형제** | `.thread-line`은 `.comment-node`의 직속 자식으로, `.comment-row`와 형제 관계이다. `.comment-row` 내부에 넣지 않는다 |
| **`.thread-children`에 border-left 금지** | `.thread-children`에는 `border-left`를 적용하지 않는다. 세로선은 오직 `.thread-line` 요소만 담당한다. `margin-left: 11px; padding-left: 21px`로 들여쓰기만 처리한다 |
| **L자형 수평 연결선 유지** | `.thread-children > .comment-node::before` 의사 요소로 부모 세로선에서 자식 코멘트까지 수평 연결선을 렌더링한다. `left: -21px; top: 18px; width: 18px; height: 2px; background-color: #64748b`. 이 연결선은 CSS만으로 자동 렌더링되므로 PHP에서 별도 HTML을 추가할 필요 없다 |
| **collapse-btn + thread-line은 자식 있는 코멘트만** | `.collapse-btn` 버튼과 `.thread-line` 요소는 `$hasChildren`이 true인 코멘트에만 렌더링한다. 리프 코멘트에는 없다 |
| **`ancestorLastFlags`/`isLast` 사용 금지** | thread-line 방식에서는 이 파라미터들이 불필요하다. `renderCommentThread()` 호출 시 `$depth`만 전달한다 |
| **`countDescendants()` 사용** | 접힌 상태 텍스트에는 직접 자식 수가 아닌 `countDescendants()`로 계산한 **전체 하위 코멘트 수**를 표시한다 |
| **블루 테마 유지** | 코멘트 영역의 모든 interactive 요소(버튼, 포커스, hover)는 `--wa-color-brand-*` 블루 변수를 사용해야 한다. 빨간색(`#7f1d1d`, `#dc2626`)은 삭제 액션에만 허용 |
| **3가지 접기 트리거** | `.thread-line` 클릭, `.collapse-btn` 클릭, `.collapse-toggle` 클릭이 접기/펼치기를 트리거한다. 이벤트 위임(`v7/js/comment.js` 라인 16~47)으로 구현되어 있다 |
| **`collapsed` 클래스** | `.comment-node.collapsed` 클래스가 토글되면 thread-line 숨김, 본문/파일/액션/자식 숨김, 아이콘 전환, `[+N개 답글]` 또는 `[접힌 댓글]` 표시가 모두 CSS로 처리된다. JavaScript에서 `classList.toggle('collapsed')`만 호출하면 된다 |
| **접힌 상태 세로선 숨김** | `.comment-node.collapsed > .thread-line { display: none }` — 접힌 상태에서 세로선이 **완전히 숨겨진다** (border-left 방식과 다름) |
| **접힌 상태 표시 분기** | 자식이 있는 코멘트: `[+N개 답글]` (N = 전체 하위 수). 리프 코멘트: `[접힌 댓글]` |
| **wa-avatar initials 필수** | 코멘트 작성자 아바타는 `wa-avatar`의 `initials` 속성으로 구현. 이미지 URL 없이 이니셜로 표시 |
| **wa-relative-time 필수** | 코멘트 시간은 `wa-relative-time`으로 표시. `date` 속성에 ISO 8601(`date('c', $stamp)`) 전달, `lang="ko"` 필수 |
| **$childrenMap 구조** | `$childrenMap[$parentIdx][]`로 부모별 자식 맵을 구축한다. 최상위 코멘트는 `$childrenMap[$idx]`(글의 idx)에서 가져온다 |
| **thread-line 세로선 색상** | 기본 `#64748b` (neutral-500 계열), hover 시 `#3b82f6` (blue — 클릭 가능함을 시각적으로 표시) |
