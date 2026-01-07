# 포인트 광고 가능한 게시판에만 글 생성/수정 시 포인트 옵션 표시

## 수정해야 할 파일

### 1. 헬퍼 함수 파일 (새로 생성)
**파일**: `packages/philgo_api/lib/src/post/functions/point_advertisement.functions.dart`

```dart
/// 포인트 광고 가능 게시판인지 확인하는 헬퍼 함수
bool isPointAdvertisementAllowed({
  required BuildContext context,
  String? postId,
  String? category,
}) {
  final setting = PhilgoState.of(context).setting;
  
  // 설정이 로드되지 않았으면 false (안전한 기본값)
  if (setting == null) return false;
  
  // 목록이 비어있으면 false
  final allowedCategories = setting.point.advertisingPostCategories;
  if (allowedCategories.isEmpty) return false;
  
  // 우선순위: category가 있으면 category, 없으면 postId
  final target = category?.isNotEmpty == true ? category : postId;
  if (target == null) return false;
  
  return allowedCategories.contains(target);
}
```

### 2. 글 작성 폼 수정
**파일**: `packages/philgo_api/lib/src/post/widgets/post.create.form.dart`
**라인**: 약 737-740

**현재 코드**:
```dart
        const Spacer(),

        PointSelectionButton(
          onDaysSelected: (days) => setState(() => advertisementDays = days),
          disabled: _isLoading || _uploadingCount > 0,
        ),
```

**변경 후 코드**:
```dart
        const Spacer(),

        // 광고 가능 게시판에서만 포인트 옵션 표시
        if (isPointAdvertisementAllowed(
          context: context,
          postId: _selectedPostId,
          category: _selectedCategory,
        ))
          PointSelectionButton(
            onDaysSelected: (days) => setState(() => advertisementDays = days),
            disabled: _isLoading || _uploadingCount > 0,
          ),
```

### 3. 글 수정 폼 수정
**파일**: `packages/philgo_api/lib/src/post/widgets/post.update.form.dart`
**라인**: 약 520-524

**현재 코드**:
```dart
        const Spacer(),

        PointSelectionButton(
          update: true,
          onDaysSelected: (days) => setState(() => advertisementDays = days),
          disabled: _isLoading || _uploadingCount > 0,
        ),
```

**변경 후 코드**:
```dart
        const Spacer(),

        // 광고 가능 게시판에서만 포인트 옵션 표시
        if (isPointAdvertisementAllowed(
          context: context,
          postId: widget.post.postId,
          category: widget.post.category,
        ))
          PointSelectionButton(
            update: true,
            onDaysSelected: (days) => setState(() => advertisementDays = days),
            disabled: _isLoading || _uploadingCount > 0,
          ),
```

### 4. import 추가 필요
두 파일에 다음 import를 추가해야 합니다:

```dart
import 'package:philgo_api/philgo_api.dart'; // PhilgoState 접근을 위해
// 헬퍼 함수 import (파일 생성 후)
import '../functions/point_advertisement.functions.dart';
```

## 데이터 흐름
1. 서버 설정(`PhilgoSettingPoint.advertisingPostCategories`)을 통해 광고 가능 게시판 목록 로드
2. `isPointAdvertisementAllowed()` 함수로 현재 게시판/카테고리가 목록에 포함되는지 확인
3. 포함되면 `PointSelectionButton` 표시, 아니면 숨김
4. 숨김 상태에서는 `point_advertisement_days` 필드가 API 요청에 포함되지 않음

## 주의사항
- `PhilgoState`는 앱 시작 시 설정을 로드하므로, 로딩 중이거나 실패한 경우 기본값으로 false 반환
- 게시판 선택 시 `setState()` 호출로 조건 재평가 필요
- 서버 설정 변경 시 앱 재시작 필요 (현재 아키텍처)