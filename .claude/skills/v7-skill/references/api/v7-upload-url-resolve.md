# Upload URL 경로 변환 — v4/v6/v7 통합 해결 로직

> **v7-upload.md의 서브 문서** — v4/v6/v7 세 버전의 파일 업로드 경로를 통합 처리하는 URL 변환 로직을 상세 기술한다.
> 게시글 목록, 상세보기, API 응답 등 모든 이미지 표시 시 이 변환 로직을 거친다.

## 목차

- [1. 개요: 왜 URL 경로 변환이 필요한가](#1-개요-왜-url-경로-변환이-필요한가)
- [2. 버전별 파일 경로 패턴](#2-버전별-파일-경로-패턴)
- [3. resolveImageThumbnail() — 단일 이미지 URL 변환](#3-resolveimagethumbnail--단일-이미지-url-변환)
- [4. resolvePostThumbnail() — 게시글 최종 썸네일 결정](#4-resolvepostthumbnail--게시글-최종-썸네일-결정)
- [5. buildV4FileUrl() — v4 파일 인덱스 → URL 변환](#5-buildv4fileurl--v4-파일-인덱스--url-변환)
- [6. extractFirstImageFromFiles() — files 필드 파싱](#6-extractfirstimagefromfiles--files-필드-파싱)
- [7. PostEntity 런타임 썸네일 설정](#7-postentity-런타임-썸네일-설정)
- [8. enrichThumbnails() — 배치 썸네일 보강](#8-enrichthumbnails--배치-썸네일-보강)
- [9. 유튜브 썸네일 폴백](#9-유튜브-썸네일-폴백)
- [10. 전체 데이터 흐름 다이어그램](#10-전체-데이터-흐름-다이어그램)
- [11. sf_post_data 미디어 관련 필드 매핑](#11-sf_post_data-미디어-관련-필드-매핑)
- [12. 웹(PHP)과 앱(Flutter) 플랫폼별 차이](#12-웹php과-앱flutter-플랫폼별-차이)
- [13. 테스트 커버리지](#13-테스트-커버리지)

---

## 1. 개요: 왜 URL 경로 변환이 필요한가

필고 시스템은 **v4(2010년대 초~중반)**, **v6(2017~2024)**, **v7(2024~현재)** 세 버전의 데이터가 하나의 DB에 공존한다.
각 버전이 서로 다른 파일 저장 경로를 사용하므로, 이미지를 표시할 때 **모든 버전의 경로를 통합 처리**해야 한다.

**핵심 문제**: 20년간 쌓인 게시글(수십만 건)의 이미지 URL이 3가지 형태로 혼재한다.
**해결책**: `UploadService`의 공용 메서드가 어떤 버전의 URL이든 받아서 적절한 썸네일 URL을 반환한다.

### 변환이 적용되는 위치

| 위치 | 설명 | 호출 메서드 |
|------|------|------------|
| `PostEntity::fromArray()` | DB → Entity 변환 시 resolved_thumbnail 자동 설정 | `resolvePostThumbnail()` |
| `PostService::enrichThumbnails()` | 목록 조회 후 gid/유튜브 폴백 배치 처리 | `buildV4FileMapByGids()` + `resolveImageThumbnail()` |
| `PostService::list()`, `get()` 등 | Service 계층에서 Entity 반환 전 보강 | 위 두 메서드 내부 호출 |
| Flutter 앱 | 서버 API 응답의 `resolved_thumbnail` 필드를 그대로 사용 | 서버에서 처리 완료 |

---

## 2. 버전별 파일 경로 패턴

### v7 (2024~현재) — 로컬 서버 저장

```
/uploads/{idx_member}/{filename}.webp
```

- **저장 위치**: 필고 웹서버 로컬 `./uploads/` 폴더
- **절대 경로**: `{ROOT_DIR}/uploads/{idx_member}/{filename}.webp`
- **파일명 규칙**: `{uniqid()}_{timestamp}.webp` (예: `6789abcdef_1709876543.webp`)
- **썸네일 생성**: 업로드 시 자동 생성 (400x400, 800x800, 600, 1000)
- **WebP 변환**: 자동 (GIF 제외)

**예시**:
```
원본:     /uploads/190076/6789abcdef_1709876543.webp
400x400:  /uploads/190076/400x400-6789abcdef_1709876543.webp
800x800:  /uploads/190076/800x800-6789abcdef_1709876543.webp
600:      /uploads/190076/600-6789abcdef_1709876543.webp
1000:     /uploads/190076/1000-6789abcdef_1709876543.webp
```

### v6 (2017~2024) — 외부 파일 서버 (file.philgo.com)

```
https://file.philgo.com/v5-files/uploaded-files/{경로}/{filename}
```

- **저장 위치**: 외부 CDN 서버 (`file.philgo.com`)
- **썸네일**: 외부 서버의 `thumbnail.php` 스크립트가 동적 생성
- **특징**: `uploaded-files/` 경로 포함으로 v6 URL 식별

**예시**:
```
원본:  https://file.philgo.com/v5-files/uploaded-files/99801/old_image.jpg
썸네일: https://file.philgo.com/v5-files/thumbnail.php?src=99801/old_image.jpg&w=400&h=400&q=85
```

### v4 (2010년대 초~중반) — 파일 인덱스 기반

```
https://file.philgo.com/data/upload/{idx%10}/{idx}
```

- **저장 위치**: 외부 CDN 서버의 인덱스 기반 폴더
- **디렉토리 규칙**: 파일 idx를 10으로 나눈 나머지가 하위 폴더
- **파일 확장자 없음**: URL에 확장자가 포함되지 않는 경우가 많음
- **썸네일**: 동적 생성 불가, 원본 그대로 반환

**예시**:
```
idx=1234567 → https://file.philgo.com/data/upload/7/1234567
idx=13      → https://file.philgo.com/data/upload/3/13
idx=10      → https://file.philgo.com/data/upload/0/10
```

### 버전별 비교 요약

| 항목 | v4 | v6 | v7 |
|------|----|----|-----|
| **저장 위치** | file.philgo.com | file.philgo.com | 로컬 ./uploads/ |
| **경로 패턴** | `/data/upload/{idx%10}/{idx}` | `uploaded-files/{path}/{file}` | `/uploads/{idx_member}/{file}` |
| **식별 키워드** | `/data/upload/` | `uploaded-files/` | `/uploads/` |
| **썸네일** | 불가 (원본 반환) | `thumbnail.php` 동적 | `ImageService` 업로드 시 생성 |
| **확장자** | 없을 수 있음 | 원본 확장자 | `.webp` (자동 변환) |
| **DB 참조 필드** | `no_of_first_image`, `gid` | `files` (쉼표/JSON) | `varchar_17`, `files` |

---

## 3. resolveImageThumbnail() — 단일 이미지 URL 변환

**파일**: `lib/upload/UploadService.php`
**네임스페이스**: `Philgo\Upload\UploadService`

### 역할

어떤 버전의 이미지 URL이든 받아서, 지정된 크기와 타입의 **썸네일 URL을 반환**한다.
v4/v6/v7 모든 경로를 자동으로 식별하여 적절한 변환을 수행한다.

### 시그니처

```php
public static function resolveImageThumbnail(
    string $imageUrl,
    int $width = 0,
    string $type = 'resize'
): string
```

### 파라미터

| 파라미터 | 타입 | 설명 |
|----------|------|------|
| `$imageUrl` | string | 원본 이미지 URL (v4/v6/v7 어떤 형태든 가능) |
| `$width` | int | 썸네일 너비 (0이면 원본 반환) |
| `$type` | string | `'square'` (정사각형 center-crop) 또는 `'resize'` (비율 유지) |

### 반환값

| 조건 | 반환값 |
|------|--------|
| 빈 URL 입력 | `''` (빈 문자열) |
| width ≤ 0 | 원본 URL 그대로 |
| v7 경로 + 변환 가능 확장자 | `ImageService::buildThumbnailUrl()` 결과 |
| v7 경로 + GIF | 원본 URL 그대로 (애니메이션 보존) |
| v6 경로 + 프로덕션 | `thumbnail.php` URL |
| v6 경로 + 개발환경 | 원본 URL 그대로 |
| v4 경로 | 원본 URL 그대로 (동적 썸네일 불가) |
| 외부 URL | 원본 URL 그대로 |

### 처리 플로우

```
입력: resolveImageThumbnail($imageUrl, $width, $type)
│
├─ 빈 URL? → return ''
├─ width ≤ 0? → return $imageUrl (원본)
│
├─ str_starts_with('/uploads/') → [v7 경로]
│  ├─ ImageService::isConvertible($ext) = true?
│  │  → return ImageService::buildThumbnailUrl($imageUrl, $width, $type)
│  │    ├─ type='square' → {dir}/{width}x{width}-{basename}
│  │    └─ type='resize' → {dir}/{width}-{basename}
│  └─ GIF 등 변환 불가
│     → return $imageUrl (원본)
│
├─ 'uploaded-files/' 포함 → [v6 경로]
│  ├─ 개발 환경 (HTTP_HOST에 'local' 포함)
│  │  → return $imageUrl (로컬 파일 서버 접근 불가)
│  └─ 프로덕션 환경
│     → return 'https://file.philgo.com/v5-files/thumbnail.php?src={path}&w={width}[&h={width}]&q=85'
│        ├─ type='square' → &h={width} 추가 (정사각형)
│        └─ type='resize' → h 파라미터 없음 (비율 유지)
│
├─ '/data/upload/' 포함 → [v4 경로]
│  → return $imageUrl (동적 썸네일 불가, 원본 반환)
│
└─ 기타 (외부 URL 등)
   → return $imageUrl (원본 반환)
```

### 핵심 소스 코드

```php
// lib/upload/UploadService.php (약 411-449줄)
public static function resolveImageThumbnail(string $imageUrl, int $width = 0, string $type = 'resize'): string
{
    if (empty($imageUrl)) return '';
    if ($width <= 0) return $imageUrl;

    // v7 업로드 (/uploads/ 경로)
    if (str_starts_with($imageUrl, '/uploads/')) {
        $ext = strtolower((string)pathinfo($imageUrl, PATHINFO_EXTENSION));
        if (ImageService::isConvertible($ext)) {
            return ImageService::buildThumbnailUrl($imageUrl, $width, $type);
        }
        return $imageUrl;
    }

    // v6 파일 서버 (uploaded-files/ 경로)
    $parts = explode('uploaded-files/', $imageUrl);
    if (count($parts) === 2) {
        $isDev = str_contains($_SERVER['HTTP_HOST'] ?? '', 'local');
        if ($isDev) {
            return $imageUrl;
        }
        $base = 'https://file.philgo.com/v5-files/thumbnail.php';
        $params = '?src=' . urlencode($parts[1]) . '&w=' . $width;
        if ($type === 'square') {
            $params .= '&h=' . $width;
        }
        $params .= '&q=85';
        return $base . $params;
    }

    // v4 파일 (/data/upload/ 경로) — 동적 썸네일 불가
    if (str_contains($imageUrl, '/data/upload/')) {
        return $imageUrl;
    }

    // 외부 URL 또는 기타 — 원본 반환
    return $imageUrl;
}
```

### 의존성

- `ImageService::isConvertible(string $ext): bool` — 확장자가 변환 대상인지 확인 (jpg, jpeg, png, webp, avif → true, gif → false)
- `ImageService::buildThumbnailUrl(string $fileUrl, int $size, string $type): string` — 파일명 기반 썸네일 URL 패턴 생성

---

## 4. resolvePostThumbnail() — 게시글 최종 썸네일 결정

**파일**: `lib/upload/UploadService.php`

### 역할

게시글의 **최종 대표 썸네일 URL**을 결정한다.
`varchar_17` → `files` → `no_of_first_image` 순서로 우선순위를 적용하며,
각 단계에서 `resolveImageThumbnail()`을 호출하여 적절한 크기로 변환한다.

### 시그니처

```php
public static function resolvePostThumbnail(
    string $varchar17,
    string $files,
    int $noOfFirstImage,
    int $width = 1000,
    string $type = 'resize'
): string
```

### 파라미터

| 파라미터 | 타입 | 설명 |
|----------|------|------|
| `$varchar17` | string | sf_post_data.varchar_17 — 첫 번째 이미지 URL |
| `$files` | string | sf_post_data.files — 쉼표/JSON 형태 첨부파일 목록 |
| `$noOfFirstImage` | int | sf_post_data.no_of_first_image — v4 파일 인덱스 |
| `$width` | int | 썸네일 너비 (기본: 1000) |
| `$type` | string | `'square'` 또는 `'resize'` (기본: `'resize'`) |

### 우선순위 로직

```
resolvePostThumbnail($varchar17, $files, $noOfFirstImage, $width, $type)
│
├─ 1단계: varchar_17이 비어있지 않으면
│  → resolveImageThumbnail($varchar17, $width, $type)
│  → 결과가 비어있지 않으면 return
│
├─ 2단계: files가 비어있지 않으면
│  → extractFirstImageFromFiles($files) 호출
│  → 이미지 URL 추출 성공 시
│  → resolveImageThumbnail($firstImage, $width, $type)
│  → 결과가 비어있지 않으면 return
│
├─ 3단계: no_of_first_image > 0 이면
│  → buildV4FileUrl($noOfFirstImage) 호출
│  → v4 URL 반환
│
└─ 모두 비어있으면 → return '' (빈 문자열)
```

### 핵심 소스 코드

```php
// lib/upload/UploadService.php (약 539-567줄)
public static function resolvePostThumbnail(
    string $varchar17,
    string $files,
    int $noOfFirstImage,
    int $width = 1000,
    string $type = 'resize'
): string {
    // 1단계: varchar_17
    if (!empty($varchar17)) {
        $url = self::resolveImageThumbnail($varchar17, $width, $type);
        if (!empty($url)) return $url;
    }

    // 2단계: files 필드에서 이미지 추출
    if (!empty($files)) {
        $firstImage = self::extractFirstImageFromFiles($files);
        if (!empty($firstImage)) {
            $url = self::resolveImageThumbnail($firstImage, $width, $type);
            if (!empty($url)) return $url;
        }
    }

    // 3단계: no_of_first_image → v4 URL
    if ($noOfFirstImage > 0) {
        return self::buildV4FileUrl($noOfFirstImage);
    }

    return '';
}
```

### 실전 예시

| 게시글 상태 | varchar_17 | files | no_of_first_image | 결과 |
|------------|-----------|-------|-------------------|------|
| v7 이미지 | `/uploads/190076/abc.webp` | (상관없음) | (상관없음) | `/uploads/190076/400x400-abc.webp` (square, 400) |
| v6 이미지 | (빈) | `https://file.philgo.com/.../img.jpg` | 0 | `thumbnail.php` URL |
| v4 이미지 | (빈) | (빈) | 1234567 | `https://file.philgo.com/data/upload/7/1234567` |
| 이미지 없음 | (빈) | (빈) | 0 | `''` |
| v7 GIF | `/uploads/190076/ani.gif` | (상관없음) | (상관없음) | `/uploads/190076/ani.gif` (원본) |

---

## 5. buildV4FileUrl() — v4 파일 인덱스 → URL 변환

**파일**: `lib/upload/UploadService.php`

### 역할

v4 시스템의 **파일 인덱스 (정수)**를 완전한 URL로 변환한다.
v4에서는 `sf_data` 테이블의 `idx` 또는 `sf_post_data.no_of_first_image` 값이 파일 식별자이다.

### 시그니처

```php
public static function buildV4FileUrl(int $fileIdx): string
```

### 변환 규칙

```
입력: fileIdx (정수)
변환: https://file.philgo.com/data/upload/{fileIdx % 10}/{fileIdx}

예시:
  fileIdx = 1234567  → https://file.philgo.com/data/upload/7/1234567
  fileIdx = 13       → https://file.philgo.com/data/upload/3/13
  fileIdx = 10       → https://file.philgo.com/data/upload/0/10
  fileIdx = 0        → '' (빈 문자열)
  fileIdx < 0        → '' (빈 문자열)
```

### 핵심 소스 코드

```php
// lib/upload/UploadService.php (약 460-464줄)
public static function buildV4FileUrl(int $fileIdx): string
{
    if ($fileIdx <= 0) return '';
    return 'https://file.philgo.com/data/upload/' . ($fileIdx % 10) . '/' . $fileIdx;
}
```

---

## 6. extractFirstImageFromFiles() — files 필드 파싱

**파일**: `lib/upload/UploadService.php`

### 역할

`sf_post_data.files` 필드의 다양한 형식(쉼표/줄바꿈 구분, JSON 배열)에서 **첫 번째 이미지 URL**을 추출한다.

### 시그니처

```php
public static function extractFirstImageFromFiles(string $files): string
```

### 지원 형식

| 형식 | 예시 | 추출 결과 |
|------|------|---------|
| **쉼표 구분** | `/uploads/190076/a.webp,/uploads/190076/b.webp` | `/uploads/190076/a.webp` |
| **줄바꿈 구분** | `/uploads/190076/a.jpg\n/uploads/190076/b.png` | `/uploads/190076/a.jpg` |
| **JSON 배열** | `[{"url":"/uploads/.../a.webp","url_thumbnail":"/uploads/.../400x400-a.webp"}]` | `/uploads/.../400x400-a.webp` (url_thumbnail 우선) |
| **v4 파일 인덱스** | `1234567,7654321` | `1234567` (7자리 숫자 파일명) |
| **v6 URL** | `https://file.philgo.com/uploaded-files/abc/photo.jpg` | 해당 URL |

### 이미지 필터링 규칙

- **이미지 확장자**: jpg, jpeg, png, gif, webp, bmp, avif
- **v4 파일**: 정확히 7자리 숫자 (예: `1234567`)
- **v6 URL**: `uploaded-files/` 경로 포함
- **비이미지**: pdf, docx 등은 건너뜀

### 처리 플로우

```
입력: extractFirstImageFromFiles($files)
│
├─ 빈 문자열? → return ''
│
├─ $files[0] === '[' → [JSON 배열]
│  ├─ json_decode() 성공
│  │  └─ $filesData[0]['url_thumbnail'] ?? $filesData[0]['url'] ?? ''
│  └─ json_decode() 실패 → return ''
│
└─ 그 외 → [쉼표/줄바꿈 구분 문자열]
   └─ preg_split('/[,\n]/', $files)
      └─ 각 항목에 대해 순회:
         ├─ 이미지 확장자? → return (첫 번째 이미지)
         ├─ 7자리 숫자 파일명? → return (v4 파일)
         ├─ 'uploaded-files/' 포함? → return (v6 파일)
         └─ 해당 없음 → 다음 항목으로
```

### 핵심 소스 코드

```php
// lib/upload/UploadService.php (약 476-518줄)
public static function extractFirstImageFromFiles(string $files): string
{
    $files = trim($files);
    if ($files === '') return '';

    // JSON 배열 형식
    if ($files[0] === '[') {
        $filesData = json_decode($files, true);
        if (is_array($filesData) && !empty($filesData[0])) {
            return (string)($filesData[0]['url_thumbnail'] ?? $filesData[0]['url'] ?? '');
        }
        return '';
    }

    // 쉼표/줄바꿈 구분 문자열
    $fileList = array_filter(preg_split('/[,\n]/', $files) ?: []);
    $imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'avif'];

    foreach ($fileList as $file) {
        $file = trim($file);
        if (empty($file)) continue;

        // URL 파라미터 제거 후 확장자 체크
        $cleanPath = (string)preg_replace('/[?#].*$/', '', $file);
        $ext = strtolower((string)pathinfo($cleanPath, PATHINFO_EXTENSION));
        if (in_array($ext, $imageExtensions, true)) {
            return $file;
        }

        // v4 old file (7자리 숫자 파일명)
        $basename = basename($cleanPath);
        if (strlen($basename) === 7 && is_numeric($basename)) {
            return $file;
        }

        // uploaded-files/ 경로가 있으면 이미지로 간주
        if (str_contains($file, 'uploaded-files/')) {
            return $file;
        }
    }

    return '';
}
```

---

## 7. PostEntity 런타임 썸네일 설정

**파일**: `lib/post/PostEntity.php` (약 261-278줄)

### 역할

`PostEntity::fromArray()`에서 DB 행을 Entity로 변환할 때,
`varchar_17`(첫 번째 이미지 URL)을 기반으로 **3가지 크기의 썸네일 + resolved_thumbnail**을 자동 설정한다.

### 설정되는 런타임 속성

| 속성 | 크기 | 타입 | 용도 |
|------|------|------|------|
| `thumbnail_400x400` | 400x400 | square | 목록 썸네일 (작은 카드) |
| `thumbnail_800x800` | 800x800 | square | 목록 썸네일 (큰 카드) |
| `thumbnail_1000` | 1000px | resize | 상세보기 미리보기 |
| `resolved_thumbnail` | 400x400 | square | **최종 대표 썸네일** (모든 폴백 적용) |

### 핵심 소스 코드

```php
// lib/post/PostEntity.php (약 261-278줄)

// varchar_17 기반 3가지 썸네일 동적 생성
if (!empty($entity->varchar_17)) {
    $entity->thumbnail_400x400 = \Philgo\Upload\UploadService::resolveImageThumbnail(
        $entity->varchar_17, 400, 'square'
    );
    $entity->thumbnail_800x800 = \Philgo\Upload\UploadService::resolveImageThumbnail(
        $entity->varchar_17, 800, 'square'
    );
    $entity->thumbnail_1000 = \Philgo\Upload\UploadService::resolveImageThumbnail(
        $entity->varchar_17, 1000, 'resize'
    );
}

// resolved_thumbnail: 최종 썸네일 (varchar_17 → files → no_of_first_image 순)
$entity->resolved_thumbnail = \Philgo\Upload\UploadService::resolvePostThumbnail(
    $entity->varchar_17,
    $entity->files,
    $entity->no_of_first_image,
    400,
    'square'
);
```

### 주의사항

> **이 단계에서 gid 기반 v4 파일 조회와 유튜브 썸네일은 처리되지 않는다.**
> gid 기반 조회는 DB 추가 쿼리가 필요하므로, `PostService::enrichThumbnails()`에서 배치로 처리한다.

---

## 8. enrichThumbnails() — 배치 썸네일 보강

**파일**: `lib/post/PostService.php` (약 2407-2438줄)

### 역할

`PostEntity::fromArray()`에서 설정되지 않은 `resolved_thumbnail`을 **배치로 보강**한다.
DB 추가 쿼리가 필요한 두 가지 폴백을 처리한다:

1. **gid 기반 v4 파일 배치 조회** — sf_data 테이블에서 gid별 첫 파일 idx를 일괄 조회
2. **유튜브 URL → 썸네일 URL 변환** — has_youtube/varchar_19에서 유튜브 썸네일 생성

### 호출 시점

`PostService::list()`, `PostService::get()`, `PostService::todayInHistory()` 등
Entity 배열을 반환하기 직전에 호출된다.

### 처리 플로우

```
enrichThumbnails($posts)
│
├─ resolved_thumbnail이 비어있는 글만 gid 수집
│
├─ buildV4FileMapByGids($gids) 호출
│  → sf_data 테이블에서 gid별 MIN(idx) 일괄 조회
│  → gid → v4 URL 맵 생성
│
└─ 각 게시글 순회 (resolved_thumbnail이 비어있는 것만):
   ├─ gid 맵에 존재? → resolveImageThumbnail(v4Url, 400, 'square')
   └─ has_youtube이고 varchar_19 있으면? → resolveYoutubeThumbnail(varchar_19)
```

### 핵심 소스 코드

```php
// lib/post/PostService.php (약 2407-2438줄)
public static function enrichThumbnails(array $posts): void
{
    if (empty($posts)) return;

    // gid 수집 (resolved_thumbnail이 아직 비어있는 글만)
    $gids = [];
    foreach ($posts as $post) {
        if (empty($post->resolved_thumbnail) && !empty($post->gid)) {
            $gids[] = $post->gid;
        }
    }

    // gid 기반 v4 파일 URL 배치 조회
    $v4FileMap = \Philgo\Upload\UploadService::buildV4FileMapByGids($gids);

    foreach ($posts as $post) {
        if (!empty($post->resolved_thumbnail)) continue;

        // gid 폴백
        if (!empty($post->gid) && isset($v4FileMap[$post->gid])) {
            $post->resolved_thumbnail = \Philgo\Upload\UploadService::resolveImageThumbnail(
                $v4FileMap[$post->gid], 400, 'square'
            );
            continue;
        }

        // 유튜브 폴백
        if (!empty($post->has_youtube) && $post->has_youtube !== '' && !empty($post->varchar_19)) {
            $post->resolved_thumbnail = self::resolveYoutubeThumbnail($post->varchar_19);
        }
    }
}
```

### buildV4FileMapByGids() — gid 배치 조회

```php
// lib/upload/UploadService.php (약 577-593줄)
public static function buildV4FileMapByGids(array $gids): array
{
    if (empty($gids)) return [];

    $placeholders = implode(',', array_fill(0, count($gids), '?'));
    $rows = Db::fetchAll(
        "SELECT gid, MIN(idx) as first_idx FROM sf_data WHERE gid IN ($placeholders) GROUP BY gid",
        $gids
    );

    $map = [];
    foreach ($rows as $row) {
        $idx = (int)$row['first_idx'];
        $map[$row['gid']] = self::buildV4FileUrl($idx);
    }
    return $map;
}
```

> **성능 포인트**: 게시글 목록 20개에 대해 v4 gid가 5개 있다면, **1번의 IN 쿼리**로 모든 파일 URL을 일괄 조회한다 (N+1 문제 방지).

---

## 9. 유튜브 썸네일 폴백

**파일**: `lib/post/PostService.php` (약 2452-2480줄)

### 역할

유튜브 URL에서 video ID를 추출하여 유튜브 썸네일 이미지 URL을 생성한다.
이미지가 없는 글 중 유튜브 링크가 포함된 경우의 최종 폴백이다.

### 지원 형식

| 형식 | 예시 |
|------|------|
| youtu.be | `https://youtu.be/dQw4w9WgXcQ` |
| youtube.com/watch | `https://www.youtube.com/watch?v=dQw4w9WgXcQ` |
| youtube.com/shorts | `https://www.youtube.com/shorts/dQw4w9WgXcQ` |
| youtube.com/embed | `https://www.youtube.com/embed/dQw4w9WgXcQ` |

### 생성되는 썸네일 URL

```
https://img.youtube.com/vi/{videoId}/hqdefault.jpg
```

---

## 10. 전체 데이터 흐름 다이어그램

### 게시글 작성 시 (이미지 포함)

```
[클라이언트] 파일 업로드
  → upload.upload API
  → UploadService::store()
     ├─ 원본 저장: /uploads/{idx_member}/{uniqueName}.webp
     ├─ 썸네일 자동 생성 (400x400, 800x800, 600, 1000)
     └─ uploads 테이블에 메타데이터 저장

[클라이언트] 게시글 작성 (files 파라미터에 URL 포함)
  → PostService::create()
     ├─ setMediaFields() 호출
     │  ├─ extractFirstImageFromFiles(files) → 첫 이미지 URL 추출
     │  ├─ has_image = 'y' 설정
     │  └─ varchar_17 = 첫 이미지 URL 저장
     └─ PostRepository::create() → DB INSERT
```

### 게시글 목록 조회 시

```
PostService::list()
  → PostRepository::findAll()
     └─ DB SELECT → array_map(PostEntity::fromArray)
        └─ 각 Entity에서:
           ├─ thumbnail_400x400 = resolveImageThumbnail(varchar_17, 400, 'square')
           ├─ thumbnail_800x800 = resolveImageThumbnail(varchar_17, 800, 'square')
           ├─ thumbnail_1000 = resolveImageThumbnail(varchar_17, 1000, 'resize')
           └─ resolved_thumbnail = resolvePostThumbnail(varchar_17, files, no_of_first_image, 400, 'square')

  → PostService::enrichThumbnails($posts)
     ├─ gid 기반 v4 파일 배치 조회
     └─ 유튜브 폴백

  → 클라이언트에 JSON 응답
     └─ 각 게시글의 resolved_thumbnail 필드 포함
```

### resolved_thumbnail 결정 전체 우선순위

```
1. varchar_17이 있으면 → resolveImageThumbnail() (PostEntity::fromArray에서)
2. files 필드에서 이미지 추출 → resolveImageThumbnail() (PostEntity::fromArray에서)
3. no_of_first_image > 0 → buildV4FileUrl() (PostEntity::fromArray에서)
4. gid가 있으면 → sf_data 배치 조회 → buildV4FileUrl() (enrichThumbnails에서)
5. has_youtube + varchar_19 → 유튜브 썸네일 (enrichThumbnails에서)
6. 모두 해당 없으면 → '' (빈 문자열)
```

---

## 11. sf_post_data 미디어 관련 필드 매핑

| 필드 | 용도 | 버전 | 설명 |
|------|------|------|------|
| `varchar_17` | 첫 번째 이미지 URL | v6, v7 | 글 작성 시 `setMediaFields()`가 저장 |
| `files` | 첨부파일 URL 목록 | v4, v6, v7 | 쉼표/줄바꿈/JSON 구분 |
| `no_of_first_image` | v4 첫 이미지 인덱스 | v4 | sf_data.idx 값 |
| `gid` | v4 게시글 그룹 ID | v4 | sf_data 테이블 그룹 식별자 |
| `has_image` | 이미지 포함 여부 | 공통 | `'y'` 또는 `''` |
| `has_video` | 동영상 포함 여부 | 공통 | `'y'` 또는 `''` |
| `has_youtube` | 유튜브 포함 여부 | v6, v7 | 비어있지 않으면 유튜브 포함 |
| `varchar_18` | 첫 번째 동영상 URL | v7 | 동영상 URL 저장 |
| `varchar_19` | 유튜브 URL | v6, v7 | 유튜브 썸네일 폴백에 사용 |
---

## 12. 웹(PHP)과 앱(Flutter) 플랫폼별 차이

### 웹(PHP) — 서버사이드 처리

- **URL 변환**: 서버(PHP)에서 `resolveImageThumbnail()` 호출하여 변환된 URL을 클라이언트에 전달
- **상대 경로 사용**: `/uploads/190076/400x400-abc.webp` (브라우저가 자동으로 현재 도메인 기준 해석)
- **HTML 출력**: `<img src="<?= $post->resolved_thumbnail ?>">` 형태로 직접 사용
- **개발환경 v6**: `HTTP_HOST`에 `local`이 포함되면 v6 썸네일 변환을 건너뛰고 원본 반환

### 앱(Flutter) — 클라이언트사이드

- **API 응답 사용**: 서버 API가 반환한 `resolved_thumbnail` 필드를 그대로 사용
- **절대 경로 변환 필요**: 상대 경로(`/uploads/...`)에 서버 도메인을 붙여야 함
  ```dart
  // 상대 경로 → 절대 경로 변환
  final absoluteUrl = 'https://philgo.com${post.resolvedThumbnail}';
  ```
- **toArray() 응답**: PostEntity의 `toArray()`가 `resolved_thumbnail`, `thumbnail_400x400`, `thumbnail_800x800`, `thumbnail_1000` 필드를 모두 포함하여 반환
- **Flutter에서 별도 URL 변환 로직 불필요**: 서버에서 모든 v4/v6/v7 변환을 완료하여 전달

### 공통 사항

- **resolved_thumbnail**은 양 플랫폼에서 **최종 대표 썸네일**으로 사용
- URL 변환 로직은 **서버(PHP)에서만** 실행되며, 클라이언트(웹 JS, Flutter)에서는 변환된 결과만 소비
- v4/v6 레거시 경로 처리는 서버가 투명하게 처리하므로 클라이언트는 버전 차이를 인지할 필요 없음

---

## 13. 테스트 커버리지

### UploadServiceResolveTest.php

**파일**: `tests/Unit/UploadServiceResolveTest.php`
**실행**: `./vendor/bin/pest tests/Unit/UploadServiceResolveTest.php`

| 테스트 | 검증 내용 |
|--------|---------|
| resolveImageThumbnail — v7 square | `/uploads/...` → `400x400-...` 변환 |
| resolveImageThumbnail — v7 resize | `/uploads/...` → `1000-...` 변환 |
| resolveImageThumbnail — v7 GIF | GIF는 원본 반환 |
| resolveImageThumbnail — v6 프로덕션 | `uploaded-files/` → `thumbnail.php` URL |
| resolveImageThumbnail — v6 개발환경 | `uploaded-files/` → 원본 반환 |
| resolveImageThumbnail — v4 | `/data/upload/` → 원본 반환 |
| resolveImageThumbnail — 빈 URL | `''` 반환 |
| resolveImageThumbnail — width 0 | 원본 반환 |
| buildV4FileUrl — 유효 idx | 올바른 URL 생성 |
| buildV4FileUrl — 0 또는 음수 | `''` 반환 |
| extractFirstImageFromFiles — 쉼표 구분 | 첫 이미지 추출 |
| extractFirstImageFromFiles — JSON 배열 | url_thumbnail 우선 |
| extractFirstImageFromFiles — 7자리 숫자 | v4 파일 인식 |
| extractFirstImageFromFiles — 빈 문자열 | `''` 반환 |
| resolvePostThumbnail — varchar_17 우선 | 1단계 확인 |
| resolvePostThumbnail — files 폴백 | 2단계 확인 |
| resolvePostThumbnail — no_of_first_image 폴백 | 3단계 확인 |
| resolvePostThumbnail — 모두 비어있음 | `''` 반환 |
| buildV4FileMapByGids — 유효 gid | gid → URL 맵 생성 |
| buildV4FileMapByGids — 빈 배열 | 빈 맵 반환 |

### PostThumbnailTest.php

**파일**: `tests/Unit/PostThumbnailTest.php`
**실행**: `./vendor/bin/pest tests/Unit/PostThumbnailTest.php`

| 테스트 | 검증 내용 |
|--------|---------|
| 단일 이미지 | varchar_17 + 썸네일 URL 저장 검증 |
| 다중 이미지 | 첫 번째만 varchar_17에 저장 |
| 이미지 + 동영상 | 이미지 우선 처리 |
| GIF | 썸네일 미생성, 원본 유지 |
| 텍스트만 (이미지 없음) | 비어있는 필드 검증 |
| 레거시 URL (v6) | uploaded-files 경로 처리 |
| 고아 URL | uploads 레코드 없을 때 폴백 |
| 기존 파일 | 썸네일 URL 비어있을 때 폴백 |
