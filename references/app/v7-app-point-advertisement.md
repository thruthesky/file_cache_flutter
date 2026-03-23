# Flutter 앱 포인트 광고 시스템

## 목차

1. [개요](#1-개요)
2. [Post 모델 광고 필드](#2-post-모델-광고-필드)
3. [PointAdvertisement 모델 (목록 표시용)](#3-pointadvertisement-모델)
4. [PointAdvertisementService](#4-pointadvertisementservice)
5. [PostListResult 포인트 광고 통합](#5-postlistresult-포인트-광고-통합)
6. [위젯: PointAdvertisements (목록 상단 광고)](#6-위젯-pointadvertisements)
7. [위젯: PointAdSelectionBottomSheet (기간 선택)](#7-위젯-pointadselectionbottomsheet)
8. [글 작성 시 포인트 광고 (PostCreateScreen)](#8-글-작성-시-포인트-광고)
9. [글 수정 시 포인트 광고 (PostUpdateScreen)](#9-글-수정-시-포인트-광고)
10. [글 보기에서 광고 표시 + 연장 (PostViewScreen)](#10-글-보기에서-광고-표시--연장)
11. [글 목록에서 D-day 뱃지 (PostListTile)](#11-글-목록에서-d-day-뱃지)
12. [파일 경로 요약](#12-파일-경로-요약)

---

## 1. 개요

Flutter 앱의 포인트 광고 시스템은 v7 백엔드 API(`post.advertisementConfig`, `post.advertise`, `post.list`)를 활용하여 사용자가 자신의 글을 게시판 목록 상단에 고정 노출할 수 있는 기능을 제공한다.

백엔드 상세 로직(비용 계산, DB 필드, 적격 게시판 목록)은 → [v7-point.md](../v7-point.md) 11장 참조.

### 핵심 흐름

```
[글 작성/수정] → 기간 선택(BottomSheet) → submit → post.advertise API → 포인트 차감
[글 목록] → post.list API (1페이지) → point_advertisements 파싱 → 상단 광고 위젯
[글 보기] → int_5 > now → 만료일 배너 표시 → 팝업 메뉴에서 연장
[글 목록 타일] → int_5 > now → D-day 뱃지 표시
```

---

## 2. Post 모델 광고 필드

### 소스코드

```dart
// lib/post/post.model.dart
class Post {
  // 포인트 광고 관련 필드
  final int adEndTime;   // int_5: 광고 종료 Unix timestamp (초)
  final int adStartTime; // int_6: 마지막 광고 등록 시간
  final int adDays;      // int_7: 마지막 등록 기간 (일)
  final int adPoints;    // int_8: 마지막 등록에 소비한 포인트

  /// 포인트 광고 활성 여부
  bool get isAdActive =>
      adEndTime > DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 포인트 광고 남은 일수
  int get adRemainingDays {
    if (!isAdActive) return 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return ((adEndTime - now) / 86400).ceil();
  }

  /// 포인트 광고 만료 DateTime
  DateTime? get adEndDateTime {
    if (adEndTime <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(adEndTime * 1000);
  }
}
```

### fromJson 매핑

```dart
factory Post.fromJson(Map<String, dynamic> json) {
  return Post(
    // ...기존 필드...
    adEndTime: _toInt(json['int_5']),
    adStartTime: _toInt(json['int_6']),
    adDays: _toInt(json['int_7']),
    adPoints: _toInt(json['int_8']),
  );
}
```

### copyWith 지원

```dart
Post copyWith({
  // ...기존 필드...
  int? adEndTime,
}) {
  return Post(
    // ...
    adEndTime: adEndTime ?? this.adEndTime,
    adStartTime: adStartTime,
    adDays: adDays,
    adPoints: adPoints,
  );
}
```

---

## 3. PointAdvertisement 모델

게시판 목록 상단에 표시되는 포인트 광고 전용 모델. `post.list` API 응답의 `point_advertisements` 배열에서 파싱된다.

### 소스코드

```dart
// lib/point/point_advertisement.model.dart
class PointAdvertisement {
  final int idx;
  final int idxMember;
  final String postId;
  final String subject;
  final int adEndTime;       // int_5
  final String? resolvedThumbnail;
  final int noOfView;
  final int noOfComment;
  final String link;
  final String category;

  bool get isActive => adEndTime > DateTime.now().millisecondsSinceEpoch ~/ 1000;

  int get remainingDays {
    if (!isActive) return 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return ((adEndTime - now) / 86400).ceil();
  }

  /// 클릭 시 URL: link가 있으면 외부, 없으면 글 보기
  String get clickUrl => link.isNotEmpty ? link : '';

  factory PointAdvertisement.fromJson(Map<String, dynamic> json) {
    return PointAdvertisement(
      idx: ApiService.toInt(json['idx']),
      idxMember: ApiService.toInt(json['idx_member']),
      postId: json['post_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      adEndTime: ApiService.toInt(json['int_5']),
      resolvedThumbnail: json['resolved_thumbnail']?.toString(),
      noOfView: ApiService.toInt(json['no_of_view']),
      noOfComment: ApiService.toInt(json['no_of_comment']),
      link: json['link']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }
}
```

---

## 4. PointAdvertisementService

### 소스코드

```dart
// lib/point/point_advertisement.service.dart
class PointAdvertisementService {
  /// 포인트 광고 설정 조회
  /// API: post.advertisementConfig
  static Future<PointAdvertisementConfig> getConfig({
    required String postId,
    String? category,
  }) async {
    final result = await ApiService.instance.v7api(
      'post.advertisementConfig',
      data: {
        'post_id': postId,
        if (category != null) 'category': category,
      },
    );
    return PointAdvertisementConfig.fromJson(result);
  }

  /// 포인트 광고 등록/연장
  /// API: post.advertise (인증 필수)
  static Future<Post> advertise({
    required int idx,
    required int days,
  }) async {
    final result = await ApiService.instance.v7api(
      'post.advertise',
      data: {'idx': idx, 'days': days},
    );
    return Post.fromJson(result);
  }
}

/// 포인트 광고 설정 모델
class PointAdvertisementConfig {
  final bool eligible;     // 광고 가능 여부
  final int costPerHour;   // 시간당 포인트 비용 (240)
  final List<PointAdvertisementDayOption> dayOptions;

  factory PointAdvertisementConfig.fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List<dynamic>?) ?? [];
    return PointAdvertisementConfig(
      eligible: json['eligible'] == true,
      costPerHour: ApiService.toInt(json['cost_per_hour']),
      dayOptions: days
          .whereType<Map<String, dynamic>>()
          .map(PointAdvertisementDayOption.fromJson)
          .toList(),
    );
  }
}

/// 광고 기간 옵션
class PointAdvertisementDayOption {
  final int days;
  final int points;
}
```

---

## 5. PostListResult 포인트 광고 통합

### 소스코드

```dart
// lib/post/post_list_result.model.dart
class PostListResult {
  final List<Post> posts;
  final int total;
  final List<PointAdvertisement> pointAdvertisements;

  factory PostListResult.fromJson(Map<String, dynamic> json) {
    final postsJson = json['posts'] as List<dynamic>? ?? [];
    final adsJson = json['point_advertisements'] as List<dynamic>? ?? [];
    return PostListResult(
      posts: postsJson
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList(),
      total: ApiService.toInt(json['total']),
      pointAdvertisements: adsJson
          .whereType<Map<String, dynamic>>()
          .map(PointAdvertisement.fromJson)
          .toList(),
    );
  }
}
```

**핵심**: `point_advertisements`는 1페이지에서만 반환된다.

---

## 6. 위젯: PointAdvertisements

게시판 목록 상단에 포인트 광고 목록을 표시하는 위젯.

### 소스코드 핵심

```dart
// lib/point/widgets/point_advertisements.dart
class PointAdvertisements extends StatelessWidget {
  final List<PointAdvertisement> advertisements;
  final void Function(PointAdvertisement) onTap;

  // UI 구조:
  // 헤더: bullhorn 아이콘 + "포인트 광고"
  // 각 광고: [56x56 썸네일] [제목 / 조회수 · D-n · 댓글수]
  // D-n은 primary 색상으로 강조
}
```

### ForumScreen 통합

```dart
// lib/post/list/forum.screen.dart
List<PointAdvertisement> _pointAdvertisements = [];

Future<List<Post>> _fetchPage(int page) async {
  final result = await PostService.list(...);
  if (page == 1 && mounted) {
    setState(() => _pointAdvertisements = result.pointAdvertisements);
  }
  return result.posts;
}

// build()에서:
if (_pointAdvertisements.isNotEmpty && !isMasonryLayout)
  PointAdvertisements(
    advertisements: _pointAdvertisements,
    onTap: _onAdTap,
  ),

// 광고 클릭: 외부 링크 → 브라우저, 내부 글 → PostViewScreen
void _onAdTap(PointAdvertisement ad) {
  if (ad.link.isNotEmpty) {
    launchUrl(Uri.parse(ad.link), mode: LaunchMode.externalApplication);
    return;
  }
  PostService.get(ad.idx).then((post) => PostViewScreen.push(context, post));
}
```

---

## 7. 위젯: PointAdSelectionBottomSheet

포인트 광고 기간을 선택하는 바텀시트. 글 작성/수정 화면에서 공통 사용.

### 소스코드 핵심

```dart
// lib/point/widgets/point_ad_selection_bottom_sheet.dart
class PointAdSelectionBottomSheet extends StatefulWidget {
  final PointAdvertisementConfig config;
  final int userPoints;
  final int? initialSelectedDays;
  final void Function(int? days) onDaysSelected;
}

// UI 구조:
// 헤더: bullhorn 아이콘 + "포인트 광고" + 보유 포인트
// 3열 그리드: 각 카드(포인트 + 일수), 포인트 부족 시 비활성화
// 확인 버튼: "선택 확인" / "선택 해제" / "광고 기간을 선택하세요"
```

### 사용 패턴

```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (_) => PointAdSelectionBottomSheet(
    config: adConfig,
    userPoints: context.read<UserState>().point,
    initialSelectedDays: _advertisementDays,
    onDaysSelected: (days) {
      Navigator.pop(context);
      setState(() => _advertisementDays = days);
    },
  ),
);
```

---

## 8. 글 작성 시 포인트 광고 (PostCreateScreen)

### 핵심 로직

```dart
// lib/post/create/post.create.screen.dart

// 상태 변수
PointAdvertisementConfig? _adConfig;
int? _advertisementDays;

// initState에서 설정 로드
_loadAdConfig();

// 게시판 변경 시 설정 재로드
setState(() {
  _selectedPostId = postId;
  _advertisementDays = null;
  _adConfig = null;
});
_loadAdConfig();

// 글 제출 시 광고 등록
final post = await PostService.create(...);
if (_advertisementDays != null && _advertisementDays! > 0) {
  await PointAdvertisementService.advertise(
    idx: post.idx,
    days: _advertisementDays!,
  );
}
```

### UI 구조

```
[게시판 선택] [카테고리 선택]
[제목 입력]
[내용 입력]
[포인트 광고 선택 버튼]  ← 적격 게시판에서만 표시
[파일 업로드 + 전송 버튼]
```

- 미선택: 회색 배경 + "포인트 광고"
- 선택됨: primary 배경 + "포인트 광고: 7일"

---

## 9. 글 수정 시 포인트 광고 (PostUpdateScreen)

### 핵심 로직

```dart
// lib/post/update/post.update.screen.dart

// 상태 변수 (글 작성과 동일)
PointAdvertisementConfig? _adConfig;
int? _advertisementDays;

// initState에서 설정 로드
_loadAdConfig();

// 수정 제출 시 광고 등록/연장
_latestPost = await PostService.update(...);
if (_advertisementDays != null && _advertisementDays! > 0) {
  final adResult = await PointAdvertisementService.advertise(
    idx: widget.post.idx,
    days: _advertisementDays!,
  );
  _latestPost = _latestPost.copyWith(adEndTime: adResult.adEndTime);
}
```

### UI 특이사항

- 기존 광고 활성 시: "포인트 광고 중 (D-n)" 표시
- 기간 선택 시: "포인트 광고 연장: +7일" (+기호 포함)
- 광고 미등록 시: "포인트 광고" (글 작성과 동일)

---

## 10. 글 보기에서 광고 표시 + 연장 (PostViewScreen)

### 만료일 배너

```dart
// lib/post/view/post.view.screen.dart
// 글 제목 위에 표시
if (_post.isAdActive) _buildAdBanner(scheme),

Widget _buildAdBanner(ColorScheme scheme) {
  final endDate = _post.adEndDateTime;
  final formatted = DateFormat('yyyy.MM.dd HH:mm').format(endDate!);
  // UI: primaryContainer 배경 + bullhorn 아이콘 + "광고 만료일: 2026.03.25 18:30 (D-5)"
}
```

### 팝업 메뉴에서 광고 등록/연장

본인 글(isMine)의 팝업 메뉴에 "포인트 광고" 항목 추가:
- 활성 광고: "포인트 광고 연장"
- 미등록: "포인트 광고"

```dart
PopupMenuItem(
  value: 'pointAd',
  child: Row(children: [
    FaIcon(FontAwesomeIcons.lightBullhorn, color: popScheme.primary),
    Text(_post.isAdActive ? '포인트 광고 연장' : '포인트 광고'),
  ]),
),

// switch에서 처리
case 'pointAd':
  _showPointAdOption();
```

### 광고 등록/연장 흐름

```dart
Future<void> _showPointAdOption() async {
  // 1. 설정 로드
  final config = await PointAdvertisementService.getConfig(
    postId: _post.postId, category: _post.category);
  if (!config.eligible) return;

  // 2. 기간 선택 바텀시트
  showModalBottomSheet(builder: (_) => PointAdSelectionBottomSheet(...));

  // 3. 확인 다이얼로그
  final confirm = await showDialog(
    title: '포인트 광고 등록/연장',
    content: '7일 등록 (40320 P 사용)',
  );

  // 4. API 호출 + 상태 업데이트
  final result = await PointAdvertisementService.advertise(idx, days);
  setState(() {
    _post = _post.copyWith(adEndTime: result.adEndTime);
    _postChanged = true;
  });
}
```

---

## 11. 글 목록에서 D-day 뱃지 (PostListTile)

### 소스코드

```dart
// lib/post/list/widgets/post.list.tile.dart
// 통계 행(조회수, 댓글수, 좋아요) 뒤에 표시
if (post.isAdActive) ...[
  const SizedBox(width: 8),
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: color.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      'D-${post.adRemainingDays}',
      style: text.bodySmall?.copyWith(
        color: color.primary,
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
    ),
  ),
],
```

---

## 12. 파일 경로 요약

| 파일 | 역할 |
|------|------|
| `lib/post/post.model.dart` | Post 모델 — adEndTime/adStartTime/adDays/adPoints + isAdActive/adRemainingDays/adEndDateTime |
| `lib/point/point_advertisement.model.dart` | PointAdvertisement 모델 (목록 상단 광고용) |
| `lib/point/point_advertisement.service.dart` | PointAdvertisementService + Config + DayOption 모델 |
| `lib/point/widgets/point_advertisements.dart` | 목록 상단 포인트 광고 위젯 |
| `lib/point/widgets/point_ad_selection_bottom_sheet.dart` | 기간 선택 바텀시트 |
| `lib/post/post_list_result.model.dart` | PostListResult — pointAdvertisements 필드 |
| `lib/post/create/post.create.screen.dart` | 글 작성 — 포인트 광고 선택 + 등록 |
| `lib/post/update/post.update.screen.dart` | 글 수정 — 포인트 광고 등록/연장 |
| `lib/post/view/post.view.screen.dart` | 글 보기 — 만료일 배너 + 연장 메뉴 |
| `lib/post/list/widgets/post.list.tile.dart` | 글 목록 타일 — D-day 뱃지 |
| `lib/post/list/forum.screen.dart` | ForumScreen — 광고 목록 로드 + 상단 표시 |
