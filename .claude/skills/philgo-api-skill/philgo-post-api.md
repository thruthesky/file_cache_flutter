# 글과 코멘트 관련 API

이 문서는 PhilGo API의 게시글, 댓글, 게시판 설정과 관련된 모든 API를 정리한 문서입니다.

## 목차

- [🔥 핵심 API: get_posts() (필독)](#-핵심-api-get_posts-필독)
- [게시글 관리 API (Post)](#게시글-관리-api-post)
- [댓글 관리 API (Comment)](#댓글-관리-api-comment)
- [게시판 설정 API (Post-Config)](#게시판-설정-api-post-config)

---

## 🔥 핵심 API: get_posts() (필독)

> **⚠️ 중요 지침**: 글과 관련된 모든 데이터 추출 작업을 할 때에는 **반드시 `get_posts` API 함수를 먼저 사용**해야 한다. 이 API는 필고의 핵심 게시글 조회 함수로서, 대부분의 게시글/댓글 목록 조회 요구사항을 충족할 수 있다.

### 개요

`get_posts` API는 PhilGo의 게시글 및 댓글을 조회하는 **가장 유연하고 강력한 API**이다. 다양한 조건과 옵션을 지원하며, 필고의 내부 `select_posts_by_page()` 함수의 모든 기능을 API로 노출한다.

**엔드포인트**: `func.php?func=get_posts`

**HTTP 메서드**: GET / POST

**인증 필요**: 아니오 (단, `firebase_uid` 파라미터 사용 시 해당 사용자의 글만 조회)

### 핵심 파라미터

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| firebase_uid | string | 아니오 | - | Firebase UID로 특정 사용자의 글만 조회. 자동으로 `idx_member`로 변환됨 |
| idx_member | int | 아니오 | - | 회원 번호로 특정 사용자의 글만 조회 |
| post_id | string | 아니오 | - | 게시판 ID (freetalk, qna, wanted 등) |
| category | string | 아니오 | - | 카테고리 |
| page | int | 아니오 | 1 | 페이지 번호 |
| limit | int | 아니오 | 20 | 한 페이지당 글 수 |
| type | string | 아니오 | 'post' | 'post' = 게시글만, 'comment' = 댓글만, 그 외 = 모두 |
| fields | string | 아니오 | POST_LIST_FIELDS | 조회할 필드 목록 (쉼표로 구분) |
| user_info | bool | 아니오 | false | 사용자 정보 포함 여부 |
| strip_tags | bool | 아니오 | true | HTML 태그 제거 여부 |
| order_by | string | 아니오 | 'stamp DESC' | 정렬 기준 |
| extra_conditions | array | 아니오 | - | 추가 조건 (아래 참조) |
| debug | bool | 아니오 | false | 디버그 모드 (쿼리 출력) |

### extra_conditions 옵션

`extra_conditions` 파라미터를 통해 추가적인 조건을 지정할 수 있다:

| 옵션 | 타입 | 설명 |
|-----|------|------|
| minimal_fields | string | 'y'로 설정 시 최소 필드만 조회 (text_9 제외, 성능 최적화) |
| short_content | string | 값이 있으면 짧은 내용만 조회 |
| exclude_post_id | string | 특정 게시판 제외 |
| idx_member | int | 특정 회원의 글만 조회 (직접 파라미터보다 우선) |

### Firebase UID 지원

`get_posts` API는 **`firebase_uid` 파라미터를 지원**한다. Firebase UID를 전달하면 자동으로 해당 사용자의 `idx_member`로 변환되어 해당 사용자가 작성한 글/댓글만 조회된다.

```javascript
// Firebase UID로 특정 사용자의 글 조회
const posts = await func('get_posts', {
    firebase_uid: 'user-firebase-uid-here',
    type: 'post',
    limit: 10
});

// 특정 사용자의 댓글만 조회
const comments = await func('get_posts', {
    firebase_uid: 'user-firebase-uid-here',
    type: 'comment',
    limit: 20
});
```

### 사용 예제

#### 기본 사용법

```javascript
// 전체 최신 게시글 20개 조회
const posts = await func('get_posts', {});

// 특정 게시판의 글 조회
const posts = await func('get_posts', {
    post_id: 'freetalk',
    page: 1,
    limit: 10
});

// 특정 카테고리의 글 조회
const posts = await func('get_posts', {
    post_id: 'wanted',
    category: 'manila'
});
```

#### 댓글 조회

```javascript
// 최신 댓글 조회
const comments = await func('get_posts', {
    type: 'comment',
    limit: 10
});

// 특정 게시판의 댓글만 조회
const comments = await func('get_posts', {
    post_id: 'qna',
    type: 'comment',
    limit: 20
});
```

#### 성능 최적화

```javascript
// 최소 필드만 조회 (빠른 로딩)
const posts = await func('get_posts', {
    post_id: 'freetalk',
    extra_conditions: {
        minimal_fields: 'y'
    }
});

// 사용자 정보 없이 조회 (더 빠름)
const posts = await func('get_posts', {
    post_id: 'qna',
    user_info: false
});
```

#### 정렬 변경

```javascript
// 댓글 많은 순으로 정렬
const posts = await func('get_posts', {
    post_id: 'freetalk',
    order_by: 'no_of_comment DESC'
});

// 조회수 높은 순으로 정렬
const posts = await func('get_posts', {
    post_id: 'qna',
    order_by: 'no_of_view DESC'
});
```

#### 🔥 인기글 조회 (최근 N일 이내 댓글 많은 순)

**인기글**이란 최근 N일 이내에 작성된 글 중에서 댓글이 많은 순서로 정렬된 글 목록을 의미한다. `extra_conditions`의 `within_days` 옵션과 `order_by`를 조합하여 인기글을 조회할 수 있다.

**PHP 예제**:
```php
// 최근 30일 이내 인기글 20개 조회 (댓글 많은 순)
$popular_posts = get_posts(
    page: 1,
    limit: 20,                    // 최대 20개
    post_id: null,                // 모든 게시판
    category: null,
    fields: null,
    user_info: false,
    type: 'post',
    strip_tags: true,
    idx_member: null,
    extra_conditions: [
        'within_days' => 30,      // 최근 30일 이내
        'minimal_fields' => 'y'   // 최소 필드만 조회 (성능 최적화)
    ],
    order_by: 'no_of_comment DESC, stamp DESC'  // 댓글 많은 순, 동일 시 최신순
);
```

**JavaScript API 호출 예제**:
```javascript
// 최근 30일 이내 인기글 20개 조회
const popularPosts = await func('get_posts', {
    page: 1,
    limit: 20,
    type: 'post',
    strip_tags: true,
    extra_conditions: {
        within_days: 30,
        minimal_fields: 'y'
    },
    order_by: 'no_of_comment DESC, stamp DESC'
});

// 특정 게시판의 최근 7일 이내 인기글
const boardPopularPosts = await func('get_posts', {
    post_id: 'freetalk',
    limit: 10,
    extra_conditions: {
        within_days: 7,
        minimal_fields: 'y'
    },
    order_by: 'no_of_comment DESC, stamp DESC'
});
```

**주요 옵션 설명**:
| 옵션 | 값 | 설명 |
|-----|---|------|
| `within_days` | 30 | 최근 30일 이내에 작성된 글만 조회 |
| `minimal_fields` | 'y' | 불필요한 필드 제외하여 성능 최적화 |
| `order_by` | 'no_of_comment DESC, stamp DESC' | 댓글 많은 순 → 최신순 정렬 |

### 응답 형식

```json
[
  {
    "idx": 67890,
    "idx_member": 12345,
    "post_id": "freetalk",
    "category": "general",
    "subject": "글 제목",
    "stamp": 1704067200,
    "no_of_comment": 5,
    "no_of_view": 123,
    "has_image": "y",
    "has_video": "n",
    "files": ["https://example.com/image.jpg"]
  }
]
```

### 다른 API와의 비교

| API | 용도 | 유연성 |
|-----|------|--------|
| **get_posts** | 범용 게시글/댓글 조회 | ⭐⭐⭐⭐⭐ 최고 |
| post_list | 게시판별 글 목록 (페이지네이션 포함) | ⭐⭐⭐⭐ |
| post_latest | 최신 글/댓글 조회 | ⭐⭐⭐ |
| post_latest_by_user | 특정 사용자 글 조회 | ⭐⭐ |

> **결론**: 글 데이터 추출 작업 시 **먼저 `get_posts` API로 해결 가능한지 검토**하고, 특수한 요구사항이 있는 경우에만 다른 API를 사용한다.

---

## 게시글 관리 API (Post)

### post.create - 게시글 작성

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

### post.update - 게시글 수정

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

### post.delete - 게시글 삭제

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

### post.get - 게시글 조회

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

### post.view - 게시글 상세 보기

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

### post.list - 게시글 목록

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
      "varchar_17": "https://example.com/image1.jpg",
      "varchar_18": "https://example.com/image2.mp3",
      "varchar_19": "https://youtu.be/dQw4w9WgXcQ"
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

### post.latest - 최신 게시글

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
curl "https://philgo.com/func.php?func=post_latest&limit=10"

# 모든 게시판의 최신 댓글 10개
curl "https://philgo.com/func.php?func=post_latest&type=comment&limit=10"

# 특정 게시판의 최신 댓글
curl "https://philgo.com/func.php?func=post_latest&post_id=freetalk&type=comment&limit=20"

# 사용자 정보 포함한 댓글 목록
curl "https://philgo.com/func.php?func=post_latest&type=comment&limit=10&user_info=y"

# 성능 최적화된 댓글 목록
curl "https://philgo.com/func.php?func=post_latest&type=comment&limit=10&strip_tags=y&minimal_fields=y"
```

---

### post.latest-by-attach - 첨부파일 있는 최신글

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

### post.latest-by-comments - 댓글 많은 순 게시글

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

### post.latest-by-user - 사용자별 최신글

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

### post.today - 오늘의 게시글

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

### post.count-view - 조회수 증가

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

### post.region - 지역별 게시글

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

### post.news-poster - 뉴스 포스터 이미지

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

### post.news-link-export - 뉴스 링크 내보내기

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

### post.change-post-id-category - 게시판/카테고리 변경

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

### post.approve - 게시글 승인

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

---

## 댓글 관리 API (Comment)

### comment.create - 댓글 작성

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

### comment.update - 댓글 수정

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

### comment.delete - 댓글 삭제

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

---

## 게시판 설정 API (Post-Config)

### post-config.get - 게시판 설정 조회

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

### post-config.create - 게시판 생성

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

### post-config.update - 게시판 설정 수정

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

### post-config.delete - 게시판 삭제

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
