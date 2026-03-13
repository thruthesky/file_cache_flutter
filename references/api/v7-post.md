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
6. [content_type 판별 및 저장](#content_type-판별-및-저장)
7. [에러 처리](#에러-처리)
8. [테스트](#테스트)
9. [게시글 목록 관리자 기능](#게시글-목록-관리자-기능)
10. [게시글 보기 페이지 디자인](#게시글-보기-페이지-디자인)
11. [코멘트(댓글) 시스템](#코멘트댓글-시스템)
   - [코멘트 디자인 시스템](#코멘트-디자인-시스템)
   - [Reddit 스타일 스레드 구조 (세로선 클릭 접기/펼치기 + adjustThreadLines 동적 높이)](#reddit-스타일-스레드-구조-세로선-클릭-접기펼치기--adjustthreadlines-동적-높이)
   - [코멘트 HTML 구조 (SSR — avatar-col + body-col 재귀 트리)](#코멘트-html-구조-ssr--avatar-col--body-col-재귀-트리)
   - [코멘트 CSS 핵심 스타일 (thread-line 절대 위치 + 동적 높이)](#코멘트-css-핵심-스타일-thread-line-절대-위치--동적-높이)
   - [adjustThreadLines() — 세로선 높이 동적 계산 JavaScript](#adjustthreadlines--세로선-높이-동적-계산-javascript)
   - [접기/펼치기 JavaScript (세로선 클릭 + 답글 텍스트 클릭)](#접기펼치기-javascript-세로선-클릭--답글-텍스트-클릭)
   - [코멘트 모바일 반응형](#코멘트-모바일-반응형-media-max-width-640px)
   - [빈 상태 디자인](#빈-상태-디자인)
   - [기본 댓글 작성 폼 — 접기/펼치기 (Collapsed/Expanded)](#기본-댓글-작성-폼--접기펼치기-collapsedexpanded)
   - [대댓글(답글) 작성 폼 — 개선된 디자인](#대댓글답글-작성-폼--개선된-디자인)
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
| post_id | string | 조건부 | 게시판 ID (`post_id` 또는 `idx_member` 중 하나 필수) |
| idx_member | int | 조건부 | 작성자 회원 번호 — 특정 사용자의 글만 조회 (`post_id` 또는 `idx_member` 중 하나 필수) |
| category | string | X | 카테고리 필터 |
| orderby | string | X | 정렬 (기본: stamp DESC) |
| limit | int | X | 최대 조회 수 (기본: 20, 최대: 100) |
| offset | int | X | 오프셋 (기본: 0) |

> **`post_id`와 `idx_member` 조합 규칙**: 둘 다 없으면 RuntimeException 발생. `post_id`만 전달하면 해당 게시판 전체 글 조회. `idx_member`만 전달하면 전체 게시판에서 해당 사용자의 글만 조회. 둘 다 전달하면 특정 게시판에서 특정 사용자의 글만 조회.

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
| content_type | string | 콘텐츠 타입 (`text`, `markdown`, `html`). 저장 시 자동 계산 |
| stamp | int | 작성 시간 (UNIX timestamp) |
| stamp_update | int | 수정 시간 |
| depth | int | 깊이 (0=글, 1=댓글, 2=대댓글) |
| no_of_comment | int | 댓글 수 |
| no_of_view | int | 조회 수 |
| good | int | 좋아요 수 |
| category | string | 카테고리 |
| int_10 | int | 획득 포인트 |

### 사용자 정보 필드

| 필드 | 타입 | 설명 | 소스 |
|------|------|------|------|
| user_id | string | 작성자 ID | sf_post_data.user_id |
| user_name | string | 작성자 이름/닉네임 | sf_post_data.user_name (글 생성 시 sf_member.nickname에서 복사) |
| user_email | string | 작성자 이메일 | sf_post_data.user_email |
| user_photo_url | string | 작성자 프로필 사진 URL | sf_member.photo_url (LEFT JOIN으로 실시간 조회) |

> **참고**: `user_photo_url`은 sf_post_data 테이블에 저장되지 않고, `findByIdx()`, `findAll()`, `findComments()` 조회 시 `sf_member` 테이블과 LEFT JOIN하여 실시간으로 가져온다. 따라서 사용자가 프로필 사진을 변경하면 즉시 반영된다.

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

## content_type 판별 및 저장

글/코멘트의 `content` 필드를 분석하여 렌더링 타입(`text`, `markdown`, `html`)을 결정하고 DB에 저장한다.

- 상세 계획: [tmp/plans/post-content-format-plan.md](../../../../../tmp/plans/post-content-format-plan.md)
- DB 컬럼: `sf_post_data.content_type` VARCHAR(16) DEFAULT NULL
- v6 원본 로직: `lib/functions.php`의 `is_markdown()`, `is_html()` + `lib/post/process_after_read.php`의 `detect_content_format()`

### 판별 우선순위

```
markdown > html > text (기본값)
```

1. `content`가 비어 있으면 → `text`
2. `is_markdown()` 규칙에 맞으면 → `markdown`
3. `is_html()` 규칙에 맞으면 → `html`
4. 그 외 → `text`

### is_markdown() 판별 조건

소스 위치: `lib/functions.php:857-894`

조건 (하나라도 참이면 `markdown`):

1. **헤딩**: `preg_match('/^#{1,6}\s+.+/', $text)` — 문자열 **시작**에 `#` 1~6개 + 공백 + 텍스트
2. **이미지**: `![alt](url)` 구문 — `![` 와 `](` 가 존재하고, 그 사이에 줄바꿈 없음

주의사항:
- 최소 길이: `trim($text)` 2자 이상
- 헤딩은 `^` 앵커 사용 → `"안녕\n# 제목"`은 `text`, `"# 제목\n안녕"`은 `markdown`

### is_html() 판별 조건

소스 위치: `lib/functions.php:676-849`

- 최소 길이: `trim($text)` 3자 이상
- `strtolower()` 후 검사 (대소문자 무관)
- `strpos()` 기반 — 위치 무관, 어디에든 태그가 있으면 `true`

닫는 태그 (54개): `</div>`, `</span>`, `</a>`, `</p>`, `</h1>`~`</h6>`, `</ul>`, `</ol>`, `</li>`, `</table>`, `</tbody>`, `</thead>`, `</tfoot>`, `</tr>`, `</td>`, `</th>`, `</blockquote>`, `</pre>`, `</code>`, `</strong>`, `</em>`, `</b>`, `</i>`, `</u>`, `</s>`, `</strike>`, `</del>`, `</ins>`, `</sub>`, `</sup>`, `</small>`, `</big>`, `</center>`, `</font>`, `</form>`, `</button>`, `</label>`, `</select>`, `</option>`, `</textarea>`, `</fieldset>`, `</legend>`, `</article>`, `</section>`, `</nav>`, `</aside>`, `</header>`, `</footer>`, `</main>`, `</figure>`, `</figcaption>`, `</video>`, `</audio>`, `</canvas>`, `</svg>`, `</iframe>`, `</object>`, `</script>`, `</style>`, `</title>`, `</head>`, `</body>`, `</html>`

여는/self-closing 태그 (40+개): `<br`, `<img `, `<hr`, `<input `, `<meta `, `<link `, `<source `, `<track `, `<embed `, `<area `, `<base `, `<col `, `<param `, `<wbr`, `<div>`, `<div `, `<span>`, `<span `, `<a `, `<p>`, `<p `, `<h1>`~`<h6>`, `<ul>`, `<ol>`, `<li>`, `<table>`, `<tr>`, `<td>`, `<th>`, `<blockquote>`, `<pre>`, `<code>`, `<strong>`, `<em>`, `<b>`, `<i>`, `<u>`, `<form `, `<button>`, `<video `, `<audio `, `<iframe `, `<script>`, `<style>`, `<!doctype`, `<!--`

### 저장 동작

| 경로 | 메서드 | 동작 |
|------|--------|------|
| 글 생성 | `PostService::create()` | `content` 기반 content_type 계산 후 DB 저장 |
| 글 수정 | `PostService::update()` | `content` 변경 시에만 재계산, 파일만 수정 시 유지 |
| 코멘트 생성 | `PostService::commentCreate()` | 글 생성과 동일 |
| 코멘트 수정 | `PostService::commentUpdate()` | 글 수정과 동일 |

`PostRepository::create()`의 `$defaults`에 `content_type` 포함, 기본값 `'text'`.

### 조회 동작

- DB에 `content_type` 값이 있으면 그대로 사용
- `NULL` 또는 빈 문자열이면 `PostEntity::fromArray()`에서 폴백 계산
- 이 폴백은 기존 데이터(v6에서 생성된 레코드) 호환용

### sanitize_user_input() 전처리 주의사항

v6는 판별 전에 `html_entity_decode($str, ENT_QUOTES | ENT_HTML5, 'UTF-8')`을 거친다.
v7 저장 시점에서는 클라이언트가 보낸 원본 `content`로 판별하므로,
Quill 같은 리치 에디터가 HTML 엔티티로 인코딩해서 저장하는 경우 차이가 발생할 수 있다.

대응: v7에서도 판별 전에 `html_entity_decode()` 1회 적용 후 판별할 것을 권장.

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
| 자식 댓글 있는 코멘트 수정 | '자식 댓글이 있는 코멘트는 수정할 수 없습니다.' |
| 자식 댓글 있는 코멘트 삭제 | '자식 댓글이 있는 코멘트는 삭제할 수 없습니다.' |
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

## 게시글 목록 글쓰기 버튼

### 디자인

글쓰기 버튼(`.post-write-btn`)은 블루 아웃라인 스타일로 표시된다.
v7 홈페이지의 블루 테마에 맞춰 `--wa-color-brand-500/600` CSS 변수를 사용한다.

| 속성 | 값 |
|------|-----|
| 색상 | `var(--wa-color-brand-600, #2563eb)` (블루) |
| 보더 | `1px solid var(--wa-color-brand-500, #3b82f6)` |
| 배경 | 투명 (hover 시 블루 채움) |
| 폰트 | `0.9rem`, `font-weight: 600` |
| 아이콘 | `fa-solid fa-pen-to-square` |

### 비로그인 시 동작

비로그인 사용자가 글쓰기 버튼을 클릭하면 `alert('로그인을 하셔야 글을 쓸 수 있습니다.')`를 표시한다.
서버에서 `AuthService::getLoginUser()` 결과에 따라 PHP 조건문으로 분기한다.

```php
<?php if ($loginUser): ?>
    <a href="<?= Route::postCreate($postId, $category) ?>" class="post-write-btn">
        <i class="fa-solid fa-pen-to-square"></i> 글쓰기
    </a>
<?php else: ?>
    <a href="#" class="post-write-btn" onclick="alert('로그인을 하셔야 글을 쓸 수 있습니다.'); return false;">
        <i class="fa-solid fa-pen-to-square"></i> 글쓰기
    </a>
<?php endif; ?>
```

### 적용 위치

| 파일 | 설명 |
|------|------|
| `v7/post/list.php` | 게시판 목록 페이지 헤더 |
| `v7/post/view.php` | 글 읽기 페이지 하단 목록 헤더 |
| `v7/post/list.css` | `.post-write-btn` 스타일 정의 |

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

## 게시글 보기 페이지 디자인

### 최근 디자인 변경 이력

| 항목 | 이전 | 현재 |
|------|------|------|
| 액션바 버튼 모양 | 사각형 + 보더 | 보더 없는 미니멀 텍스트 버튼 |
| 액션바 아이콘 | `fa-solid` (굵은 아이콘) | `fa-regular` (얇은 아웃라인 아이콘) |
| 좋아요 버튼 | 블루 테두리 + 흰 배경 | 보더 없음, 블루 텍스트만 |
| 삭제 버튼 | hover 시 빨간색 강조 | 다른 버튼과 동일 (강조 없음) |
| 댓글 textarea 배경 | `neutral-50` (연한 회색) | 순백색 (`#fff`) |
| 첨부 버튼 배경 | `neutral-50` (연한 회색) | 순백색 (`#fff`) |
| 코멘트 노드 패딩 | 없음 | `padding: 0.4rem 0` 추가 |
| thread-line 색상 | `#94a3b8` (neutral-400) | `#cbd5e1` (neutral-300) |
| L자 곡선 연결선 색상 | `#94a3b8` (neutral-400) | `#cbd5e1` (neutral-300, 세로선과 동일) |

### 파일 구조

| 파일 | 용도 |
|------|------|
| `v7/post/view.php` | 게시글 보기 메인 페이지 (SSR) |
| `v7/post/view.css` | 게시글 보기 전용 스타일 |
| `v7/js/post-actions.js` | 액션바 Vue.js 앱 (좋아요/수정/삭제) |
| `v7/js/comment.js` | 댓글 CRUD Vue.js 앱 |

### 글 헤더 디자인

글 헤더는 카테고리 뱃지, 제목, 작성자 정보(아바타 + 이름 + 메타)로 구성된다.

```html
<header class="post-view-header">
    <span class="post-category-badge"><i class="fa-solid fa-tag"></i> 카테고리</span>
    <h1 class="post-view-title">제목</h1>
    <div class="post-view-author-row">
        <wa-avatar initials="홍" image="프로필URL" shape="circle"></wa-avatar>
        <div class="post-view-author-info">
            <span class="post-view-author">홍길동</span>
            <div class="post-view-meta">
                <span class="post-view-date">2026-03-11 12:00</span>
                <span class="post-view-stat"><i class="fa-regular fa-eye"></i> 조회수</span>
            </div>
        </div>
    </div>
</header>
```

**핵심 CSS 규칙:**
- 카테고리 뱃지: 블루 pill 스타일 (`background: brand-50`, `color: brand-700`, `border-radius: 20px`)
- 작성자 아바타: `wa-avatar --size: 2.25rem`, `shape="circle"`, `user_photo_url` 지원
- 구분선: `border-bottom: 1px solid neutral-200` (얇은 회색, 두꺼운 검정 금지)

### 액션 바 디자인

좋아요/수정/삭제/목록 버튼은 **보더 없는 미니멀 텍스트 버튼** 스타일로 표시된다. 아이콘은 `fa-regular` (얇은 아웃라인) 스타일을 사용한다.

| 버튼 | 스타일 | 색상 | 아이콘 |
|------|--------|------|--------|
| 좋아요 | `.post-like-btn` | 블루 텍스트 (`brand-600`), 보더 없음, 투명 배경 | `fa-regular fa-thumbs-up` |
| 수정 | `.post-action-btn` | 중립 회색 텍스트, 보더 없음, 투명 배경 | `fa-regular fa-pen-to-square` |
| 삭제 | `.post-action-btn .post-delete-btn` | 중립 회색 텍스트 (다른 버튼과 동일), 보더 없음 | `fa-regular fa-trash-can` |
| 목록 | `.post-action-btn` | 중립 회색 텍스트, 보더 없음, 투명 배경 | `fa-regular fa-rectangle-list` |
| 삭제 확인 | `.post-delete-confirm-btn` | 빨간 배경 + 흰 텍스트 (확인 단계만) | `fa-regular fa-trash-can` |

**핵심 CSS 규칙:**
- 모든 버튼: `border: none`, `background: transparent`, `font-size: 0.8rem`
- 아이콘 크기: `font-size: 0.75rem` (본문보다 작게)
- hover 시: 연한 배경색(`neutral-50`)만 표시, 보더 추가 금지
- 좋아요 hover: `brand-50` 배경
- 삭제 버튼: 다른 버튼과 동일한 스타일 (강조 없음, 빨간색 금지)

**🔴 좋아요 버튼은 반드시 블루 텍스트**: `--wa-color-brand-*` 변수 사용. 보더/배경 없이 텍스트 색상만 블루.

### 댓글 입력 폼 디자인

```css
.comment-create-form {
    background: #fff;           /* 흰 배경 */
    border-radius: 12px;
    border: 1px solid neutral-200;
}
.comment-create-form:focus-within {
    border-color: brand-300;    /* 포커스 시 블루 테두리 */
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.08);
}
.comment-textarea {
    background: #fff;           /* 순백색 배경 */
    border-radius: 10px;
}
.comment-textarea:focus {
    background: #fff;           /* 포커스 시에도 순백색 유지 */
}
.comment-attach-btn {
    background: #fff;           /* 첨부 버튼도 순백색 배경 */
}
```

**디자인 변경 이력 (배경색 통일):**

| 항목 | 이전 | 현재 |
|------|------|------|
| 댓글 textarea 배경 | `neutral-50` (연한 회색) | `#fff` (순백색) |
| 첨부 버튼 배경 | `neutral-50` (연한 회색) | `#fff` (순백색) |

---

## 코멘트(댓글) 시스템

### 개요

v7 코멘트 시스템은 `sf_post_data` 테이블을 게시글과 공유하며, `depth > 0`인 레코드가 코멘트이다.
대댓글(스레딩)은 v6의 `find_last_child_comment()` + `update_comment_thread()` 로직을 완벽 이식하여 트리 구조를 지원한다.

### 핵심 필드 (코멘트 관련)

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx_root` | int | 원글(게시글) idx -- 모든 코멘트가 공유하는 루트 |
| `idx_parent` | int | 부모 코멘트 idx (최상위 코멘트는 idx_root와 동일) |
| `depth` | int | 깊이 (0=글, 1=1차 코멘트, 2=대댓글, 3=대대댓글...) |
| `list_order` | int | 트리 내 정렬 순서 (DESC 정렬, 큰 값=위쪽/오래된 것) |

### 트리 구조 알고리즘 (v6 완벽 이식)

코멘트 생성 시 `PostRepository::updateCommentThread()`가 호출되어 `list_order`와 `depth`를 계산한다.

#### 1. 최상위 코멘트 (idx_parent == idx_root)

```
list_order = 0, depth = 1
기존 모든 코멘트의 list_order를 +1 시프트
-> DESC 정렬에서 맨 아래(최신)에 표시
```

#### 2. 대댓글 (idx_parent != idx_root)

```
depth = 부모.depth + 1
부모의 마지막 자손(findLastChildComment) 위치의 list_order를 구함
그 위치 이상인 코멘트들의 list_order를 +1 시프트
-> DESC 정렬에서 부모 트리 바로 아래에 표시
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
| `PostRepository` | `hasChildComments($idx)` | 자식 댓글 존재 여부 확인 (idx_parent 기반) |
| `PostService` | `commentCreate($input)` | 코멘트 생성 (updateCommentThread 호출) |
| `PostService` | `commentUpdate($input)` | 코멘트 수정 (자식 있으면 차단) |
| `PostService` | `commentDelete($input)` | 코멘트 삭제 (자식 있으면 차단) |
| `PostService` | `commentList($input)` | 코멘트 목록 반환 |

### API 엔드포인트 (코멘트)

#### post.commentCreate -- 코멘트 생성

인증 필요.

```
POST /api.php
method=post.commentCreate&idx_root=12345&content=댓글내용
method=post.commentCreate&idx_root=12345&idx_parent=67890&content=대댓글내용
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx_root | int | O | 원글 idx |
| idx_parent | int | X | 부모 코멘트 idx (생략 시 idx_root 사용 -> 최상위 코멘트) |
| content | string | O | 코멘트 내용 |

**응답**: 생성된 코멘트의 PostEntity 배열

#### post.commentList -- 코멘트 목록

인증 불필요.

```
GET /api.php?method=post.commentList&idx_root=12345
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx_root | int | O | 원글 idx |

**응답**: PostEntity 배열 (list_order DESC 정렬)

#### post.commentUpdate -- 코멘트 수정

인증 필요 (작성자 또는 관리자).

```
POST /api.php
method=post.commentUpdate&idx=67890&content=수정된댓글내용
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx | int | O | 코멘트 idx |
| content | string | O | 수정할 내용 |

**수정 제한**:
- 자식 댓글이 있는 코멘트는 수정 불가 (`PostRepository::hasChildComments()` 검사)

**응답**: 수정된 코멘트의 PostEntity 배열

#### post.commentDelete -- 코멘트 삭제

인증 필요 (작성자 또는 관리자).

```
POST /api.php
method=post.commentDelete&idx=67890
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx | int | O | 코멘트 idx |

**삭제 제한**:
- 자식 댓글이 있는 코멘트는 삭제 불가 (`PostRepository::hasChildComments()` 검사)

**삭제 방식**: 하드 삭제 (물리적 DELETE) + 원글의 `no_of_comment` 카운트 -1 갱신

**응답**: `{ "success": true }`

### v6 함수와의 대응 관계

| v6 (레거시) | v7 (신규) |
|------------|-----------|
| `find_last_child_comment($idx)` | `PostRepository::findLastChildComment($idx)` |
| `update_comment_thread($idx_post, $idx_parent, $idx_comment)` | `PostRepository::updateCommentThread($idxRoot, $idxParent)` |
| `get_comment($idx)` | `PostRepository::findByIdx($idx)` |
| `comment_create($input)` | `PostService::commentCreate($input)` |
| `comment_update($input)` | `PostService::commentUpdate($input)` |
| `comment_delete($idx)` | `PostService::commentDelete($input)` |
| `ORDER BY list_order DESC` | `PostRepository::findComments()` 기본 정렬 |

### 웹 페이지 (코멘트 렌더링)

| 파일 | 설명 |
|------|------|
| `v7/post/view.php` (라인 243~383) | SSR 코멘트 렌더링 -- **Reddit 스타일 avatar-col + body-col 방식 재귀 트리 구조** (`countDescendants()` + `renderCommentThread()` 재귀 함수) |
| `v7/post/view.css` (라인 679~823) | 코멘트 영역 전용 CSS -- `div.thread-line` 절대 위치 세로선 (아바타 아래~마지막 자식 아바타 중앙), 접기/펼치기, 반응형 |
| `v7/js/comment.js` (라인 14~83) | `adjustThreadLines()` 세로선 높이 동적 계산 + 세로선 클릭 / `[+N개 답글]` 클릭 접기/펼치기 이벤트 위임 + Vue.js 코멘트 CRUD |

코멘트는 **`div.thread-line` 절대 위치 방식 + `adjustThreadLines()` 동적 높이 계산**으로 구현되어 있다.
`$childrenMap`(부모 idx -> 자식 배열 맵)을 구축한 후, `renderCommentThread()` 함수가 각 코멘트를
재귀적으로 렌더링한다. 핵심 원리:

1. **아바타를 `.comment-avatar-col`로 독립 분리**: 코멘트 행은 `.comment-row > (.comment-avatar-col + .comment-body-col)` 구조이다
2. **세로선이 아바타 바로 아래에서 시작**: `$hasChildren`인 코멘트 노드에 `<div class="thread-line">`을 추가하고, `position: absolute`로 아바타 하단에서부터 세로선을 렌더링한다
3. **세로선 높이를 JS로 동적 계산**: `adjustThreadLines()` 함수가 마지막 직접 자식의 아바타 중앙까지만 세로선 높이를 계산한다 (기존 `bottom: 0` 고정 방식 제거)
4. **L자형 수평 연결선 제거**: `::before` 의사 요소를 사용한 수평 연결선은 완전히 제거되었다
5. **collapse-toggle/collapse-btn 제거**: 세로선 클릭과 `[+N개 답글]` 텍스트 클릭으로만 접기/펼치기를 제어한다

### 코멘트 디자인 시스템

#### 사용 Web Awesome Pro 컴포넌트

| 컴포넌트 | 속성 | 용도 |
|----------|------|------|
| `wa-avatar` | `initials`, `shape="circle"` | 코멘트 작성자 이니셜을 원형 아바타로 표시. 작성자명 첫 글자를 `mb_substr($c->user_name, 0, 1)`로 추출하여 initials에 전달 |
| `wa-relative-time` | `date`, `lang="ko"` | 절대 시간(`2024-01-15 14:30`) 대신 상대 시간(`3시간 전`)으로 표시. date에 `date('c', $c->stamp)` ISO 8601 형식 전달 |
| `wa-badge` | `variant="brand"`, `pill` | 코멘트 섹션 타이틀에 댓글 수를 블루 배지로 표시 |

#### Reddit 스타일 스레드 구조 (세로선 클릭 접기/펼치기 + adjustThreadLines 동적 높이)

세로선은 **`<div class="thread-line">` 절대 위치 요소**로 구현한다.
자식이 있는(`$hasChildren`) 코멘트 노드에 `<div class="thread-line">`을 삽입하고,
`position: absolute`로 아바타 바로 아래에서 세로선을 시작한다.
세로선의 높이는 **`adjustThreadLines()` JavaScript 함수**가 마지막 직접 자식의 아바타 중앙 위치까지만 동적으로 계산하여 설정한다.

**이전 방식과의 핵심 차이:**

| 항목 | 이전 (collapse-btn + L자형 연결선) | **현재 (avatar-col + adjustThreadLines)** |
|------|-----------------------------------|-----------------------------------------|
| **HTML 구조** | `.comment-row > (.collapse-toggle + .comment-content > .comment-main-row > (.comment-avatar + .comment-body-wrap))` | **`.comment-row > (.comment-avatar-col + .comment-body-col)`** |
| **아바타 위치** | `.comment-content` 내부의 `.comment-main-row` 안에 위치 | **`.comment-avatar-col`로 독립 분리**, `.comment-row`의 직속 자식 |
| **본문 영역** | `.comment-content > .comment-body-wrap` | **`.comment-body-col`** (이름 변경) |
| **collapse-toggle/collapse-btn** | 존재 (세로선 옆 ⊖/⊕ 아이콘 버튼) | **완전 제거** |
| **접기/펼치기 방법** | 세로선 클릭 + collapse-btn 클릭 + collapse-toggle 클릭 (3가지) | **세로선 클릭 + `[+N개 답글]` 텍스트 클릭 (2가지)** |
| **세로선 시작점** | collapse 버튼 아래 (`top: 30px` 고정) | **아바타 바로 아래** (JS `adjustThreadLines()`로 `padding-top + avatarSize + gap` 계산) |
| **세로선 끝점** | 노드 하단 (`bottom: 0` 고정) | **마지막 직접 자식의 아바타 중앙** (JS `adjustThreadLines()`로 동적 계산) |
| **세로선 높이 방식** | CSS `top`/`bottom`으로 고정 | **JS `adjustThreadLines()`로 `top`과 `height`를 동적 설정** |
| **세로선 색상** | `#64748b` (neutral-500) | **`#cbd5e1`** (neutral-300, 더 연한 톤) |
| **L자형 수평 연결선** | `::before` 의사 요소 존재 (`left: -21px; width: 18px; height: 2px`) | **완전 제거** |
| **들여쓰기** | `margin-left: 11px; padding-left: 21px` | **`margin-left: 18px; padding-left: 18px`** |
| **세로선 left 위치** | `left: 10px` | **`left: 17px`** (avatar-col 36px/2 - 1px) |

**핵심 함수:**

| 함수 | 시그니처 | 설명 |
|------|---------|------|
| `countDescendants()` | `countDescendants(int $parentIdx, array &$childrenMap): int` | 재귀적으로 하위 코멘트 총 수를 계산. 접힌 상태에서 `[+N개 답글]` 표시에 사용 |
| `renderCommentThread()` | `renderCommentThread(array $commentArr, array &$childrenMap, int $depth = 0): void` | avatar-col + body-col 방식 재귀 렌더링. `$depth`로 data-depth 속성 설정 |
| `adjustThreadLines()` | `adjustThreadLines(): void` (JavaScript) | `.comment-node.has-children`의 `.thread-line` 높이를 마지막 직접 자식 아바타 중앙까지 동적 계산 |

**데이터 흐름:**

```
$comments (flat 배열, list_order DESC)
  |
$childrenMap[$parentIdx][] = $commentArr  (부모별 자식 맵 구축)
  |
최상위 코멘트: $childrenMap[$idx] (글의 idx가 부모인 코멘트들)
  |
renderCommentThread($comment, $childrenMap, $depth=0) -- 재귀 호출
  |
countDescendants($c->idx, $childrenMap) -- 전체 하위 수 계산
  |
각 코멘트: .comment-node(.has-children)
           > .thread-line (position: absolute, 세로선 -- 높이는 JS 동적 계산)
           + .comment-row > (.comment-avatar-col + .comment-body-col)
           + .thread-children (margin-left: 18px, padding-left: 18px, 재귀)
  |
DOMContentLoaded -> adjustThreadLines() -- 세로선 높이 계산
                 -> window.resize -> adjustThreadLines() -- 리사이즈 대응
```

#### 코멘트 HTML 구조 (SSR -- avatar-col + body-col 재귀 트리)

```php
<!-- 코멘트 목록 (SSR - Reddit 스타일 세로선 클릭 접기/펼치기 스레드) -->
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
     * 코멘트 스레드 재귀 렌더링 (Reddit 스타일)
     *
     * 구조: .comment-node > .thread-line + .comment-row > (.comment-avatar-col + .comment-body-col)
     * 세로선 높이는 JS adjustThreadLines()로 동적 계산.
     * collapse-toggle/collapse-btn 없음 -- 세로선 클릭 + [+N개 답글] 클릭으로 접기/펼치기.
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
                <!-- 아바타 컬럼: 독립 분리 -->
                <div class="comment-avatar-col">
                    <wa-avatar initials="<?= htmlspecialchars(mb_substr($c->user_name ?: '?', 0, 1)) ?>"
                               label="<?= htmlspecialchars($c->user_name ?: '익명') ?>"
                               shape="circle"></wa-avatar>
                </div>

                <!-- 코멘트 본문 -->
                <div class="comment-body-col">
                    <div class="post-comment-header">
                        <strong class="comment-author"><?= htmlspecialchars($c->user_name ?: '익명') ?></strong>
                        <span class="comment-date">
                            <?php if ($c->stamp > 0): ?>
                                <wa-relative-time date="<?= date('c', $c->stamp) ?>" lang="ko"></wa-relative-time>
                            <?php endif; ?>
                        </span>
                        <?php if ($hasChildren): ?>
                            <span class="thread-collapsed-info" role="button">[+<?= $totalDescendants ?>개 답글]</span>
                        <?php else: ?>
                            <span class="thread-collapsed-info" role="button">[접힌 댓글]</span>
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

            <!-- 자식 코멘트: 들여쓰기만 처리 (L자형 수평 연결선 없음) -->
            <?php if ($hasChildren): ?>
                <div class="thread-children">
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
        $topLevelComments = $childrenMap[$idx] ?? [];
        foreach ($topLevelComments as $topComment):
            renderCommentThread($topComment, $childrenMap, 0);
        endforeach;
        ?>
    </div>
<?php endif; ?>
```

**HTML 구조 핵심 차이 (이전 vs 현재):**

| 요소 | 이전 (collapse-toggle 방식) | 현재 (avatar-col 방식) |
|------|---------------------------|----------------------|
| 코멘트 행 내부 | `.comment-row > (.collapse-toggle + .comment-content > .comment-main-row > (.comment-avatar + .comment-body-wrap))` | **`.comment-row > (.comment-avatar-col + .comment-body-col)`** |
| 아바타 | `.comment-content` 내부에 중첩 | **`.comment-avatar-col`로 `.comment-row` 직속 자식으로 독립** |
| 본문 래퍼 | `.comment-body-wrap` | **`.comment-body-col`** |
| 접기 버튼 | `.collapse-toggle > .collapse-btn` (⊖/⊕) | **없음** (제거됨) |
| 접기 아이콘 | `.collapse-icon-expanded` / `.collapse-icon-collapsed` | **없음** (제거됨) |
| 수평 연결선 | `.thread-children > .comment-node::before` (CSS) | **없음** (제거됨) |

#### 코멘트 CSS 핵심 스타일 (thread-line 절대 위치 + 동적 높이)

```css
/* === 코멘트 노드: thread-line의 절대 위치 기준 === */
.comment-node { position: relative; padding: 0.4rem 0; }

/* 코멘트 행: avatar-col + body-col */
.comment-row {
    display: flex;
    align-items: flex-start;
    position: relative;
}

/* 최상위 코멘트 간 구분선 */
.reddit-threads > .comment-node + .comment-node {
    border-top: 1px solid var(--wa-color-neutral-200, #e2e8f0);
    margin-top: 0.25rem;
    padding-top: 0.25rem;
}

/* === 아바타 컬럼: 독립 분리, 세로선 시작점 역할 === */
.comment-avatar-col {
    width: 36px;
    flex: 0 0 36px;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding-top: 6px;
}

/* 아바타 크기 */
.comment-avatar-col wa-avatar {
    --size: 1.75rem;
    font-size: 0.7rem;
}

/* 최상위 코멘트 아바타 (약간 더 크게) */
.reddit-threads > .comment-node > .comment-row > .comment-avatar-col wa-avatar {
    --size: 2rem;
    font-size: 0.75rem;
}

/* === 절대 위치 세로선: 아바타 바로 아래에서 시작 === */
/* height는 JS adjustThreadLines()로 동적 계산 */
.thread-line {
    position: absolute;
    left: 17px;       /* 아바타 컬럼 중앙 (36px/2 - 1px) */
    top: 40px;        /* 초기값, JS adjustThreadLines()에서 재계산 */
    width: 1px;
    background-color: #cbd5e1;  /* neutral-300 */
    cursor: pointer;
    z-index: 10;
    transition: background-color 0.15s, width 0.15s;
}

.thread-line:hover {
    background-color: #3b82f6;
    width: 3px;
    left: 16px;       /* hover 시 중앙 정렬 보정 */
}

/* 접힌 상태에서 세로선 숨김 */
.comment-node.collapsed > .thread-line {
    display: none;
}

/* === 코멘트 본문 컬럼 === */
.comment-body-col {
    flex: 1;
    min-width: 0;
    padding: 4px 0 6px 4px;
}

/* === 접힌 상태 처리 === */
.comment-node.collapsed > .comment-row .post-comment-body,
.comment-node.collapsed > .comment-row .comment-files,
.comment-node.collapsed > .comment-row .post-comment-actions,
.comment-node.collapsed > .thread-children { display: none; }

/* 접힌 상태 알림 텍스트 (기본 숨김) */
.thread-collapsed-info {
    display: none;
    font-size: 0.75rem;
    color: var(--wa-color-brand-600, #2563eb);
    cursor: pointer;
    font-weight: 500;
    margin-left: 0.25rem;
}
.comment-node.collapsed .thread-collapsed-info { display: inline; }

/* === 자식 코멘트 영역: 아바타 중앙 기준 들여쓰기 === */
.thread-children {
    margin-left: 18px;
    padding-left: 18px;
}
```

**제거된 CSS 요소 (이전에 존재했으나 현재 삭제됨):**

| 제거된 요소 | 설명 |
|------------|------|
| `.collapse-toggle` | 접기/펼치기 토글 영역 (24px 너비 컬럼) |
| `.collapse-btn` | ⊖/⊕ 아이콘 버튼 |
| `.collapse-icon-expanded` / `.collapse-icon-collapsed` | 접힘/펼침 상태 아이콘 전환 |
| `.comment-content` | 코멘트 내용 래퍼 (`.comment-body-col`로 대체) |
| `.comment-main-row` | 아바타 + 본문 수평 배치 행 (아바타가 avatar-col로 분리되어 불필요) |
| `.comment-body-wrap` | 본문 래퍼 (`.comment-body-col`로 대체) |
| `.thread-children > .comment-node::before` | L자형 수평 연결선 의사 요소 |

#### adjustThreadLines() -- 세로선 높이 동적 계산 JavaScript

`v7/js/comment.js` 라인 17~48에 정의되어 있다. 세로선의 시작점(`top`)과 높이(`height`)를 동적으로 계산하여 마지막 직접 자식의 아바타 중앙까지만 세로선을 표시한다.

```javascript
// === 세로선 높이 동적 계산: 마지막 직접 자식의 아바타 중앙까지만 ===
function adjustThreadLines() {
    document.querySelectorAll('.comment-node.has-children').forEach(function(node) {
        var threadLine = node.querySelector(':scope > .thread-line');
        if (!threadLine) return;

        // 접힌 상태면 스킵
        if (node.classList.contains('collapsed')) return;

        var threadChildren = node.querySelector(':scope > .thread-children');
        if (!threadChildren) return;

        var lastChild = threadChildren.querySelector(':scope > .comment-node:last-child');
        if (!lastChild) return;

        var nodeRect = node.getBoundingClientRect();

        // 세로선 시작: 부모 아바타 하단 (고정값 기반)
        var depth = parseInt(node.getAttribute('data-depth')) || 0;
        var avatarSize = depth === 0 ? 32 : 28; // 2rem vs 1.75rem
        var lineTop = 6 + avatarSize + 2; // padding-top(6) + avatar + gap(2)

        // 세로선 끝: 마지막 직접 자식의 아바타 중앙
        var lastChildRect = lastChild.getBoundingClientRect();
        var lastChildDepth = parseInt(lastChild.getAttribute('data-depth')) || 0;
        var lastChildAvatarSize = lastChildDepth === 0 ? 32 : 28;
        var lastChildAvatarCenterY = lastChildRect.top + 6 + lastChildAvatarSize / 2 - nodeRect.top;

        // 세로선 위치/높이 설정
        threadLine.style.top = lineTop + 'px';
        threadLine.style.height = Math.max(0, lastChildAvatarCenterY - lineTop) + 'px';
    });
}

// 글로벌 노출: Vue 앱에서 코멘트 추가/삭제 시 재계산 가능
window.adjustThreadLines = adjustThreadLines;

// Web Component(wa-avatar) 렌더링 후 세로선 계산
adjustThreadLines();
setTimeout(adjustThreadLines, 200);
window.addEventListener('load', adjustThreadLines);
window.addEventListener('resize', adjustThreadLines);
```

**adjustThreadLines() 계산 로직 상세:**

| 단계 | 설명 | 계산식 |
|------|------|--------|
| 1. 대상 선택 | `.comment-node.has-children` 모든 노드 | `querySelectorAll()` |
| 2. 접힌 상태 스킵 | `.collapsed` 클래스가 있으면 건너뜀 | `classList.contains('collapsed')` |
| 3. 마지막 자식 탐색 | `.thread-children > .comment-node:last-child` | `:scope >` 직접 자식만 |
| 4. lineTop 계산 | 부모 아바타 하단 = `padding-top + avatarSize + gap` | `6 + (depth===0 ? 32 : 28) + 2` |
| 5. lineEnd 계산 | 마지막 자식 아바타 중앙의 부모 기준 Y좌표 | `lastChildRect.top + 6 + lastChildAvatarSize/2 - nodeRect.top` |
| 6. height 설정 | `lineEnd - lineTop` (최소 0) | `Math.max(0, lastChildAvatarCenterY - lineTop)` |

**호출 시점:**
- `DOMContentLoaded`: 초기 렌더링 직후
- `setTimeout(200)`: Web Component(`wa-avatar`) 렌더링 지연 대응
- `window.load`: 모든 리소스 로드 완료 후
- `window.resize`: 창 크기 변경 시
- `requestAnimationFrame(adjustThreadLines)`: 접기/펼치기 후 재계산
- Vue 앱에서 코멘트 추가/삭제 시 `window.adjustThreadLines()` 수동 호출 가능

#### 접기/펼치기 JavaScript (세로선 클릭 + 답글 텍스트 클릭)

`v7/js/comment.js` 라인 60~83에 이벤트 위임 코드로 구현되어 있다.
**2가지 클릭 대상**을 지원한다: (1) `.thread-line` 세로선 클릭 (토글), (2) `.thread-collapsed-info` `[+N개 답글]` 텍스트 클릭 (펼치기만).

```javascript
// === Reddit 스타일 스레드 접기/펼치기 (이벤트 위임) ===
document.addEventListener('click', function (e) {
    // 세로선 클릭: 해당 스레드 접기/펼치기
    var line = e.target.closest('.thread-line');
    if (line) {
        var node = line.closest('.comment-node');
        if (node) {
            node.classList.toggle('collapsed');
            // 접기/펼치기 후 세로선 높이 재계산
            requestAnimationFrame(adjustThreadLines);
        }
        return;
    }

    // "[+N개 답글]" 클릭: 펼치기
    var collapsedInfo = e.target.closest('.thread-collapsed-info');
    if (collapsedInfo) {
        var node = collapsedInfo.closest('.comment-node');
        if (node && node.classList.contains('collapsed')) {
            node.classList.remove('collapsed');
            requestAnimationFrame(adjustThreadLines);
        }
        return;
    }
});
```

**동작 방식:**

| 상태 | thread-line 세로선 | 본문/파일/액션 | 자식 코멘트 | 알림 텍스트 |
|------|-------------------|-------------|-----------|-----------|
| **펼침 (기본)** | 표시 (`#cbd5e1` neutral-300, hover 시 `#3b82f6`, hover 시 width 3px) | 표시 | 표시 | 숨김 |
| **접힘 (자식 있음)** | **숨김** (`display: none`) | 숨김 | 숨김 | `[+N개 답글]` 표시 (클릭 시 펼치기) |
| **접힘 (리프)** | -- | 숨김 | -- | `[접힌 댓글]` 표시 |

**접힌 상태에서 숨겨지는 요소:**
- `.thread-line` -- 세로선 자체 (`display: none`)
- `.post-comment-body` -- 코멘트 본문 텍스트
- `.comment-files` -- 첨부 파일/이미지
- `.post-comment-actions` -- 답글/수정/삭제 등 액션 버튼
- `.thread-children` -- 하위 코멘트 전체

**트리거 방법 (2가지):**
- `.thread-line` 클릭 (세로선 자체) -- **토글** (접기/펼치기 모두), 기본 `#cbd5e1`(neutral-300), hover 시 파란색(`#3b82f6`) + 두께 증가(`3px`)로 클릭 가능함을 시각적으로 표시
- `.thread-collapsed-info` 클릭 (`[+N개 답글]` 텍스트) -- **펼치기만** (접힌 상태에서만 작동)

#### 코멘트 모바일 반응형 (`@media max-width: 640px`)

| 요소 | 데스크톱 | 모바일 (640px 이하) |
|------|---------|------------------|
| avatar-col 너비 | `36px` | `30px` |
| 코멘트 아바타 | `--size: 1.75rem` | `--size: 1.5rem` |
| 최상위 아바타 | `--size: 2rem` | `--size: 1.75rem` |
| avatar-col padding-top | `6px` | `4px` |
| **thread-line left** | `17px` | `14px` |
| **thread-line hover left** | `16px` | `13px` |
| comment-body-col padding-left | `4px` | `2px` |
| thread-children margin-left | `18px` | `15px` |
| thread-children padding-left | `18px` | `15px` |
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

#### 기본 댓글 작성 폼 — 접기/펼치기 (Collapsed/Expanded)

기본 댓글 작성 폼(`#comment-create-app`)은 화면 영역을 절약하기 위해 **접힌/펼친 두 가지 상태**로 동작한다.

**접힌 상태 (기본)**:
- 카메라 아이콘(`.comment-camera-btn`) + 한 줄 입력(`.comment-collapsed-input`, readonly) + 전송 아이콘(`.comment-send-btn`)
- 둥근 pill 모양(`border-radius: 999px`), 회색 배경
- 전체 영역이 클릭 가능

**펼친 상태 (사용자 클릭 시)**:
- 큰 textarea(4줄) + 하단에 카메라(왼쪽), 취소+저장(오른쪽)
- 흰색 배경, 포커스 시 블루 하이라이트
- `commentExpandIn` 애니메이션으로 부드럽게 전환

**전환 트리거**:
| 동작 | 트리거 |
|------|--------|
| 접힌 → 펼친 | 입력창 클릭, 카메라 아이콘 클릭, 전송 아이콘 클릭 |
| 펼친 → 접힌 | 취소 버튼 클릭 (내용이 있으면 confirm 확인) |

**Vue.js 상태**: `expanded: false`(기본) → `true`(펼친 상태)

**핵심 CSS 클래스**:
```css
.comment-collapsed-row    /* 접힌 상태 한 줄 컨테이너 */
.comment-collapsed-input   /* 접힌 상태 readonly input */
.comment-camera-btn        /* 카메라 아이콘 버튼 (접힌/펼친 공통) */
.comment-send-btn          /* 접힌 상태 전송 아이콘 */
.comment-expanded-area     /* 펼친 상태 컨테이너 */
.comment-expanded-actions  /* 펼친 상태 하단 버튼 영역 */
.comment-expanded-right    /* 펼친 상태 우측 버튼 그룹 */
.comment-save-btn          /* 저장 버튼 (비행기 아이콘 + "저장") */
.comment-create-form.expanded  /* 펼친 상태 폼 컨테이너 */
```

#### 대댓글(답글) 작성 폼 — 개선된 디자인

대댓글(답글) 작성 폼(`.comment-reply-form`)은 다음과 같은 디자인 원칙을 따른다:

- **2행 구조**: textarea가 전체 너비를 차지하고, 버튼(첨부/등록/취소)이 하단 우측에 정렬
- **왼쪽 파란색 액센트 보더**: `border-left: 3px solid #60a5fa`로 답글임을 시각적으로 표시
- **흰색 배경**: 이전 회색(`#f8fafc`) 대신 깔끔한 흰색
- **슬라이드인 애니메이션**: `replyFormSlideIn` 키프레임으로 부드러운 등장
- **포커스 효과**: `focus-within` 시 블루 하이라이트 + 좌측 보더 진하게

```css
.comment-reply-form {
    border-left: 3px solid var(--wa-color-brand-400, #60a5fa);
    background: #fff;
}
.comment-reply-form .comment-input-row {
    flex-direction: column;  /* 세로 배치 */
}
.comment-reply-form .comment-input-actions {
    align-self: flex-end;   /* 버튼 우측 정렬 */
}
```

#### 코멘트 디자인 수정 시 주의사항

| 규칙 | 설명 |
|------|------|
| **avatar-col + body-col 구조 유지** | 코멘트 행은 반드시 `.comment-row > (.comment-avatar-col + .comment-body-col)` 구조를 유지해야 한다. 아바타를 body-col 내부로 이동하거나, collapse-toggle 컬럼을 추가하지 않는다 |
| **collapse-toggle/collapse-btn 사용 금지** | 접기/펼치기는 오직 세로선 클릭과 `[+N개 답글]` 텍스트 클릭으로만 제어한다. ⊖/⊕ 아이콘 버튼을 추가하지 않는다 |
| **`.has-children` = thread-line 렌더링** | 자식이 있는 `.comment-node`에 `.has-children` 클래스를 추가하고, PHP에서 `<div class="thread-line">` 요소를 렌더링한다 |
| **`.thread-line`은 `.comment-row` 형제** | `.thread-line`은 `.comment-node`의 직속 자식으로, `.comment-row`와 형제 관계이다. `.comment-row` 내부에 넣지 않는다 |
| **`.thread-children`에 border-left 금지** | `.thread-children`에는 `border-left`를 적용하지 않는다. 세로선은 오직 `.thread-line` 요소만 담당한다. `margin-left: 18px; padding-left: 18px`로 들여쓰기만 처리한다 |
| **L자형 수평 연결선(::before) 사용 금지** | `.thread-children > .comment-node::before` 수평 연결선은 제거되었다. 다시 추가하지 않는다 |
| **adjustThreadLines() 필수** | 세로선 높이는 반드시 `adjustThreadLines()` JavaScript 함수로 동적 계산해야 한다. CSS `bottom: 0` 고정 방식을 사용하지 않는다 |
| **세로선 top/height는 CSS 고정 금지** | 세로선의 `top`과 `height`는 `adjustThreadLines()`에서 JavaScript로 설정한다. CSS에서 `top: 30px; bottom: 0` 같은 고정값을 사용하면 세로선이 마지막 자식을 초과하여 표시된다 |
| **`ancestorLastFlags`/`isLast` 사용 금지** | `renderCommentThread()` 호출 시 `$depth`만 전달한다 |
| **`countDescendants()` 사용** | 접힌 상태 텍스트에는 직접 자식 수가 아닌 `countDescendants()`로 계산한 **전체 하위 코멘트 수**를 표시한다 |
| **블루 테마 유지** | 코멘트 영역의 모든 interactive 요소는 `--wa-color-brand-*` 블루 변수를 사용. 빨간색은 삭제 액션에만 허용 |
| **`collapsed` 클래스** | `.comment-node.collapsed` 클래스가 토글되면 thread-line 숨김, 본문/파일/액션/자식 숨김, `[+N개 답글]` 텍스트 표시가 모두 CSS로 처리된다. JavaScript에서 `classList.toggle('collapsed')`만 호출하면 된다 |
| **접힌 상태 세로선 숨김** | `.comment-node.collapsed > .thread-line { display: none }` -- 접힌 상태에서 세로선이 완전히 숨겨진다 |
| **접힌 상태 표시 분기** | 자식이 있는 코멘트: `[+N개 답글]` (N = 전체 하위 수, 클릭 시 펼치기). 리프 코멘트: `[접힌 댓글]` |
| **wa-avatar initials 필수** | 코멘트 작성자 아바타는 `wa-avatar`의 `initials` 속성으로 구현. 이미지 URL 없이 이니셜로 표시 |
| **wa-relative-time 필수** | 코멘트 시간은 `wa-relative-time`으로 표시. `date` 속성에 ISO 8601(`date('c', $stamp)`) 전달, `lang="ko"` 필수 |
| **$childrenMap 구조** | `$childrenMap[$parentIdx][]`로 부모별 자식 맵을 구축한다. 최상위 코멘트는 `$childrenMap[$idx]`(글의 idx)에서 가져온다 |
| **thread-line 세로선 색상** | 기본 `#cbd5e1` (neutral-300), hover 시 `#3b82f6` (blue) + width `3px`로 두께 증가. L자 곡선 연결선도 동일하게 neutral-300(`#cbd5e1`) 적용 |
| **thread-line left 위치** | 데스크톱 `left: 17px` (avatar-col 36px/2 - 1px), 모바일 `left: 14px` (30px/2 - 1px) |
| **adjustThreadLines() 재호출 필수** | 코멘트 추가/삭제/접기/펼치기 후 반드시 `requestAnimationFrame(adjustThreadLines)` 또는 `window.adjustThreadLines()` 호출하여 세로선 높이를 재계산해야 한다 |
