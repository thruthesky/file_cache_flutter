# Flutter 앱 Masonry 이미지 표시 가이드

## 목차

- [1. 개요](#1-개요)
- [2. MasonryCard 위젯 구조](#2-masonrycard-위젯-구조)
  - [2.1 파일 위치](#21-파일-위치)
  - [2.2 미디어 타입 우선순위](#22-미디어-타입-우선순위)
  - [2.3 이미지 비율 기반 높이 자동 조절](#23-이미지-비율-기반-높이-자동-조절)
- [3. 서버 썸네일 필드 매핑](#3-서버-썸네일-필드-매핑)
  - [3.1 v7 API 썸네일 응답 필드](#31-v7-api-썸네일-응답-필드)
  - [3.2 Flutter Post 모델 매핑](#32-flutter-post-모델-매핑)
  - [3.3 Masonry 목록에서의 이미지 URL 우선순위](#33-masonry-목록에서의-이미지-url-우선순위)
- [4. 업소록(Company) Masonry 이미지](#4-업소록company-masonry-이미지)
- [5. 빌드 중 setState 에러 문제 및 해결](#5-빌드-중-setstate-에러-문제-및-해결)
  - [5.1 문제 현상](#51-문제-현상)
  - [5.2 원인 분석](#52-원인-분석)
  - [5.3 해결 코드](#53-해결-코드)
- [6. 상대 경로 → 절대 경로 변환](#6-상대-경로--절대-경로-변환)
- [7. 이미지 표시 디버깅 가이드](#7-이미지-표시-디버깅-가이드)

---

## 1. 개요

Flutter 앱의 Masonry 그리드 목록에서 게시글/업소록 이미지를 표시하는 전체 흐름을 다룬다.
서버 API 썸네일 필드 매핑, MasonryCard 위젯의 이미지 렌더링 구조, 빌드 중 setState 에러 해결,
상대/절대 경로 변환, 디버깅 방법을 포함한다.

**관련 파일:**

| 파일 | 역할 |
|------|------|
| `lib/common_widgets/masonry_card.dart` | 범용 Masonry 카드 위젯 (이미지/YouTube/동영상) |
| `lib/common_widgets/app_masonry_grid.dart` | 범용 Masonry 그리드 (무한 스크롤) |
| `lib/post/list/post_list_masonry_view.dart` | 게시글 Masonry 뷰 |
| `lib/post/list/widgets/display_thumbnail.dart` | 게시글 썸네일 공통 위젯 |
| `lib/post/post.model.dart` | Post 데이터 모델 (썸네일 필드 포함) |
| `lib/company/list/company.list.screen.dart` | 업소록 Masonry 목록 화면 |
| `lib/company/company.model.dart` | CompanyModel (이미지 필드 포함) |

---

## 2. MasonryCard 위젯 구조

### 2.1 파일 위치

`lib/common_widgets/masonry_card.dart`

### 2.2 미디어 타입 우선순위

MasonryCard는 미디어 타입을 아래 우선순위로 판별한다:

```dart
enum _MediaType { youtube, video, image, none }

_MediaType get _mediaType {
  if (_isNotEmpty(widget.youtubeUrl)) return _MediaType.youtube;  // 1순위
  if (_isNotEmpty(widget.videoUrl)) return _MediaType.video;       // 2순위
  if (_isNotEmpty(widget.imageUrl)) return _MediaType.image;       // 3순위
  return _MediaType.none;
}
```

- **YouTube** → 썸네일 + 재생 아이콘 오버레이
- **동영상** → 동영상 썸네일 + 재생 아이콘
- **이미지** → CachedNetworkImage로 표시
- **없음** → placeholder 또는 텍스트 전용 카드

### 2.3 이미지 비율 기반 높이 자동 조절

MasonryCard는 이미지 로드 후 원본 비율에 따라 카드 높이를 자동 조절한다.

**핵심 메서드: `_updateResolvedHeight()`**

```dart
/// 이미지 비율에 따라 높이를 조절하는 공통 메서드 (빌드 중 setState 방지)
void _updateResolvedHeight(ImageProvider imageProvider, double cardWidth) {
  if (_resolvedHeight != null) return;
  imageProvider.resolve(ImageConfiguration.empty).addListener(
    ImageStreamListener((info, _) {
      final imgW = info.image.width.toDouble();
      final imgH = info.image.height.toDouble();
      final resolved = (imgH / imgW) * cardWidth;
      final clamped = resolved.clamp(widget.minHeight, widget.maxHeight);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _resolvedHeight = clamped);
        });
      }
    }),
  );
}
```

**높이 제한:**
- `minHeight`: 120px (기본값)
- `maxHeight`: 350px (기본값)
- `defaultHeight`: 200px (이미지 로드 전 초기 높이)

**imageBuilder에서 사용:**

```dart
imageBuilder: (context, imageProvider) {
  _updateResolvedHeight(imageProvider, constraints.maxWidth);
  return Image(image: imageProvider, fit: BoxFit.cover);
},
```

> **🔴 주의: `_updateResolvedHeight()` 내부의 `setState()`는 반드시 `addPostFrameCallback()`으로 감싸야 한다.**
> 자세한 이유는 [5장 빌드 중 setState 에러](#5-빌드-중-setstate-에러-문제-및-해결) 참조.

---

## 3. 서버 썸네일 필드 매핑

### 3.1 v7 API 썸네일 응답 필드

v7 API (`post.list`, `post.get`)는 게시글마다 다음 썸네일 필드를 반환한다:

| API 필드 | 크기 | 설명 |
|----------|------|------|
| `thumbnail_400x400` | 400×400 정사각형 | varchar_10에서 매핑. 레거시 호환용 |
| `thumbnail_600` | 600px 비율 유지 | v7 API `resolveImageThumbnail()`이 동적 생성 |
| `thumbnail_800x800` | 800×800 정사각형 | varchar_11에서 매핑. 레거시 호환용 |
| `thumbnail_1000` | 1000px 비율 유지 | varchar_12에서 매핑 |
| `resolved_thumbnail` | 서버 결정 | `resolvePostThumbnail()`이 최적 썸네일 결정 |
| `varchar_17` | 원본 | 업로드된 원본 이미지 URL |
| `files` | 다중 | 첨부 파일 URL 목록 (쉼표 구분) |

**v7 업로드 글 예시 (API 응답):**

```json
{
  "thumbnail_400x400": "http://philgo.com/uploads/190466/400x400-69bbbd791f3f7_1773911417.webp",
  "thumbnail_600": "http://philgo.com/uploads/190466/600-69bbbd791f3f7_1773911417.webp",
  "thumbnail_800x800": "http://philgo.com/uploads/190466/800x800-69bbbd791f3f7_1773911417.webp",
  "thumbnail_1000": "http://philgo.com/uploads/190466/1000-69bbbd791f3f7_1773911417.webp",
  "resolved_thumbnail": "http://philgo.com/uploads/190466/400x400-69bbbd791f3f7_1773911417.webp",
  "varchar_17": "http://philgo.com/uploads/190466/69bbbd791f3f7_1773911417.webp"
}
```

**v6 레거시 글 예시 (API 응답):**

```json
{
  "thumbnail_400x400": "https://file.philgo.com/v5-files/thumbnail.php?src=...&w=400&h=400&q=85",
  "thumbnail_600": "https://file.philgo.com/v5-files/thumbnail.php?src=...&w=600&q=85",
  "resolved_thumbnail": "https://file.philgo.com/v5-files/thumbnail.php?src=...&w=400&h=400&q=85",
  "varchar_17": "https://file.philgo.com/v5-files/uploaded-files/..."
}
```

> 상세한 썸네일 URL 변환 로직은 → [api/v7-upload-url-resolve.md](../api/v7-upload-url-resolve.md) 참조.

### 3.2 Flutter Post 모델 매핑

`lib/post/post.model.dart`에서 JSON 필드를 매핑한다:

```dart
// 필드 정의
final String? thumbnail400x400;
final String? thumbnail800x800;
final String? thumbnail600;       // 600px 비율 유지 썸네일
final String? thumbnail1000;
final String? resolvedThumbnail;  // 서버 결정 최적 썸네일

// fromJson 매핑
thumbnail400x400: json['thumbnail_400x400']?.toString(),
thumbnail600: json['thumbnail_600']?.toString(),
thumbnail800x800: json['thumbnail_800x800']?.toString(),
thumbnail1000: json['varchar_12']?.toString(),
resolvedThumbnail: json['resolved_thumbnail']?.toString(),
```

### 3.3 Masonry 목록에서의 이미지 URL 우선순위

`lib/post/list/post_list_masonry_view.dart`의 `_getImageUrl()`:

```dart
String? _getImageUrl(Post post) {
  String? url;
  // 1순위: 600px 비율 유지 — Masonry에 최적 (비율 유지, 적절한 크기)
  if (post.thumbnail600 != null && post.thumbnail600!.isNotEmpty) {
    url = post.thumbnail600;
  }
  // 2순위: 서버 결정 썸네일
  else if (post.resolvedThumbnail != null && post.resolvedThumbnail!.isNotEmpty) {
    url = post.resolvedThumbnail;
  }
  // 3순위: 원본 이미지 (varchar_17)
  else if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
    url = post.imageUrl;
  }
  // 4순위: 첨부 파일 목록의 첫 번째
  else if (post.files.isNotEmpty) {
    url = post.files.first;
  }
  return url != null ? toAbsoluteUrl(url) : null;
}
```

**왜 `thumbnail_600`이 1순위인가:**
- Masonry 그리드는 카드 폭이 화면의 약 절반이므로 600px이 적절한 크기
- 비율 유지 썸네일이므로 원본 이미지의 가로세로 비율이 보존됨
- 400x400 정사각형은 원본 비율을 잃어 Masonry에 부적합

---

## 4. 업소록(Company) Masonry 이미지

업소록은 Post와 다른 모델(`CompanyModel`)을 사용한다.

**CompanyModel의 이미지 필드** (`lib/company/company.model.dart`):

```dart
final String logoUrl;          // json['logo_url']
final String photoUrl;         // json['photo_url']
final String titleImageUrl;    // json['title_image_url']

/// 대표 이미지 URL — 우선순위: titleImageUrl > photoUrl > logoUrl
String get primaryImageUrl {
  if (titleImageUrl.isNotEmpty) return titleImageUrl;
  if (photoUrl.isNotEmpty) return photoUrl;
  if (logoUrl.isNotEmpty) return logoUrl;
  return '';
}
```

**Masonry 카드에 전달** (`lib/company/list/company.list.screen.dart`):

```dart
MasonryCard(
  imageUrl: company.primaryImageUrl.isNotEmpty
      ? company.primaryImageUrl
      : null,
  title: company.name.isNotEmpty ? company.name : '(이름 없음)'.tr(),
  onTap: () => CompanyViewScreen.push(context, company: company),
  placeholder: _buildCompanyPlaceholder(company),
  defaultHeight: company.primaryImageUrl.isNotEmpty ? 200 : 140,
);
```

> 업소록 API 응답의 이미지 URL은 `https://file.philgo.com/v5-files/uploaded-files/...` 형태의 절대 경로로 반환된다.
> 상대 경로 변환이 필요 없다.

---

## 5. 빌드 중 setState 에러 문제 및 해결

### 5.1 문제 현상

Masonry 목록에서 **모든 이미지가 broken_image 아이콘으로 표시**되는 현상.
MasonryCard의 `errorWidget`에 에러 정보를 텍스트로 표시하면 다음 에러가 확인됨:

```
setState() or markNeedsBuild() called during build.
This MasonryCard widget cannot be marked as needing to build...
```

### 5.2 원인 분석

`CachedNetworkImage`의 `imageBuilder` 콜백은 빌드 메서드 내에서 호출된다.
이 콜백에서 `ImageStreamListener`를 등록하는데, **이미지가 이미 캐시에 있으면 리스너가 동기적으로 즉시 실행**된다.
이때 `setState()`가 빌드 중에 호출되면서 Flutter 프레임워크 에러가 발생한다.

**에러 발생 코드 (수정 전):**

```dart
imageBuilder: (context, imageProvider) {
  if (_resolvedHeight == null) {
    imageProvider.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((info, _) {
        // ...
        if (mounted) {
          setState(() => _resolvedHeight = clamped); // 🔴 빌드 중 setState!
        }
      }),
    );
  }
  return Image(image: imageProvider, fit: BoxFit.cover);
},
```

**에러 발생 조건:**
1. 이미지가 CachedNetworkImage 캐시에 이미 존재
2. `imageBuilder`가 빌드 메서드 내에서 호출됨
3. `ImageStreamListener`가 동기적으로 즉시 실행됨
4. `setState()`가 빌드 프레임 내에서 호출 → 에러

### 5.3 해결 코드

`setState()`를 `WidgetsBinding.instance.addPostFrameCallback()`으로 감싸서
현재 빌드 프레임이 완료된 후에 호출되도록 수정한다.

**수정 후 코드:**

```dart
/// 이미지 비율에 따라 높이를 조절하는 공통 메서드 (빌드 중 setState 방지)
void _updateResolvedHeight(ImageProvider imageProvider, double cardWidth) {
  if (_resolvedHeight != null) return;
  imageProvider.resolve(ImageConfiguration.empty).addListener(
    ImageStreamListener((info, _) {
      final imgW = info.image.width.toDouble();
      final imgH = info.image.height.toDouble();
      final resolved = (imgH / imgW) * cardWidth;
      final clamped = resolved.clamp(widget.minHeight, widget.maxHeight);
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _resolvedHeight = clamped);
        });
      }
    }),
  );
}

// _buildImage()에서 사용:
imageBuilder: (context, imageProvider) {
  _updateResolvedHeight(imageProvider, constraints.maxWidth);
  return Image(image: imageProvider, fit: BoxFit.cover);
},

// _buildCachedImage()에서도 동일하게 사용:
imageBuilder: (context, imageProvider) {
  _updateResolvedHeight(imageProvider, constraints.maxWidth);
  return Image(image: imageProvider, fit: BoxFit.cover);
},
```

**핵심 포인트:**
- `mounted` 체크를 2회 수행 (리스너 시점 + 콜백 시점)
- `_resolvedHeight != null` 가드로 중복 실행 방지
- `_buildImage()`와 `_buildCachedImage()` 모두 동일한 `_updateResolvedHeight()` 사용

> **🔴 CachedNetworkImage의 `imageBuilder`에서 `setState()`를 직접 호출하면 안 된다.**
> 반드시 `addPostFrameCallback()`으로 감싸야 한다.

---

## 6. 상대 경로 → 절대 경로 변환

v7 API가 상대 경로(`/uploads/...`)를 반환할 수 있으므로, 이미지 URL에는 절대 경로 변환이 필요하다.

**`toAbsoluteUrl()` 함수:**

Masonry 목록의 `_getImageUrl()` 메서드에서 최종 반환 시 `toAbsoluteUrl(url)`을 적용한다.

```dart
return url != null ? toAbsoluteUrl(url) : null;
```

**변환 규칙:**
- `http://` 또는 `https://`로 시작 → 그대로 반환 (이미 절대 경로)
- `/uploads/...` 등 상대 경로 → v7 API 베이스 URL 앞에 추가

> 상세 변환 로직은 → [api/v7-upload-url-resolve.md](../api/v7-upload-url-resolve.md) 참조.

---

## 7. 이미지 표시 디버깅 가이드

Masonry 목록에서 이미지가 안 보일 때 디버깅 순서:

### 7.1 API 응답 확인

```bash
# 게시글 목록의 썸네일 필드 확인
curl -s -X POST 'https://philgo.com/api.php' \
  -d 'method=post.list&post_id=buyandsell&category=렌트카&limit=3' \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
for post in data.get('posts', []):
    print(post.get('subject', '')[:40])
    print('  thumbnail_600:', post.get('thumbnail_600', ''))
    print('  resolved_thumbnail:', post.get('resolved_thumbnail', ''))
    print('  varchar_17:', post.get('varchar_17', ''))
"
```

### 7.2 URL 형태 확인

| URL 형태 | 상태 | 조치 |
|----------|------|------|
| `https://philgo.com/uploads/...` | 정상 절대 경로 | 조치 불필요 |
| `https://file.philgo.com/v5-files/...` | 정상 절대 경로 | 조치 불필요 |
| `/uploads/190466/...` | 상대 경로 | `toAbsoluteUrl()` 적용 필요 |
| 빈 문자열 | 이미지 없음 | 서버에서 `enrichThumbnails()` 미적용 확인 |

### 7.3 MasonryCard errorWidget에 에러 표시

이미지 로드 에러의 상세 내용을 확인하려면 `errorWidget`에 텍스트를 표시한다:

```dart
errorWidget: (_, url, error) {
  debugPrint('❌ 에러: url=$url error=$error');
  return Container(
    color: scheme.surfaceContainerHigh,
    padding: const EdgeInsets.all(4),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, color: scheme.outline, size: 20),
        Text('ERR: $error', style: TextStyle(fontSize: 8, color: scheme.error)),
        Text('URL: $url', style: TextStyle(fontSize: 7, color: scheme.outline)),
      ],
    ),
  );
},
```

### 7.4 일반적인 에러 원인과 해결

| 에러 메시지 | 원인 | 해결 |
|------------|------|------|
| `setState() called during build` | imageBuilder 내 동기 setState | `addPostFrameCallback()` 감싸기 (5장 참조) |
| `No host specified in URI` | 상대 경로 사용 | `toAbsoluteUrl()` 적용 |
| `Invalid argument(s)` | URL이 빈 문자열 또는 null | null 체크 후 MasonryCard에 전달 |
| broken_image 아이콘 표시 (에러 없음) | 이전 에러가 캐시됨 | **hot restart** 필요 (hot reload로는 캐시 미초기화) |
| HTTP 403/404 | 이미지 파일 미존재 또는 권한 | curl로 URL 직접 접근 테스트 |

### 7.5 CachedNetworkImage 에러 캐시 주의

CachedNetworkImage는 한 번 실패한 URL을 에러로 캐시한다.
코드를 수정한 후 **hot reload만으로는 에러 캐시가 초기화되지 않는다.**
반드시 **hot restart**를 수행해야 캐시가 클리어된다.

```
코드 수정 → hot reload (❌ 에러 캐시 유지)
코드 수정 → hot restart (✅ 에러 캐시 초기화)
```
