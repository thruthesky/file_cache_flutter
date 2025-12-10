/// 포럼 선택 상태 모델 (Forum Selection Model)
///
/// postId (메인 카테고리)와 category (서브 카테고리)를 함께 관리합니다.
/// Manages postId (main category) and category (subcategory) together.
///
/// 이 모델은 다음 용도로 사용됩니다:
/// - NavigationState.data를 통한 딥링크 처리
/// - ForumHome과 ForumHeader 간의 선택 상태 동기화
/// - 카테고리 선택 시 postId와 category를 한 번에 전달
///
/// 사용 예시:
/// ```dart
/// // 서브카테고리가 있는 경우
/// final golfSelection = ForumSelection(postId: 'buyandsell', category: '골프');
///
/// // 서브카테고리가 없는 경우
/// final freetalkSelection = ForumSelection(postId: 'freetalk');
///
/// // 비교
/// golfSelection == ForumSelection(postId: 'buyandsell', category: '골프'); // true
/// golfSelection == ForumSelection(postId: 'buyandsell'); // false
/// ```
class ForumSelection {
  /// 메인 카테고리 ID (예: 'freetalk', 'buyandsell', 'qna')
  /// Main category ID (e.g., 'freetalk', 'buyandsell', 'qna')
  final String postId;

  /// 서브 카테고리 (예: '골프', '렌트카', null)
  /// Subcategory (e.g., '골프', '렌트카', null)
  final String? category;

  /// ForumSelection 생성자
  /// ForumSelection constructor
  const ForumSelection({
    required this.postId,
    this.category,
  });

  /// Map에서 ForumSelection 생성 (NavigationState.data에서 변환용)
  /// Create ForumSelection from Map (for converting from NavigationState.data)
  ///
  /// 지원하는 키:
  /// - 'initialPostId' 또는 'postId': 메인 카테고리 ID
  /// - 'initialCategory' 또는 'category': 서브 카테고리
  factory ForumSelection.fromMap(Map<String, dynamic> map) {
    return ForumSelection(
      postId: map['initialPostId'] as String? ??
          map['postId'] as String? ??
          'freetalk',
      category:
          map['initialCategory'] as String? ?? map['category'] as String?,
    );
  }

  /// ForumSelection을 Map으로 변환 (NavigationState.data에 저장용)
  /// Convert ForumSelection to Map (for storing in NavigationState.data)
  Map<String, dynamic> toMap() {
    return {
      'initialPostId': postId,
      if (category != null) 'initialCategory': category,
    };
  }

  /// 튜플에서 ForumSelection 생성 (PhilgoCategory.menuCategories()에서 변환용)
  /// Create ForumSelection from tuple (for converting from PhilgoCategory.menuCategories())
  ///
  /// 사용 예시:
  /// ```dart
  /// final menuItem = ('buyandsell', '골프');
  /// final selection = ForumSelection.fromTuple(menuItem);
  /// ```
  factory ForumSelection.fromTuple((String, String?) tuple) {
    return ForumSelection(
      postId: tuple.$1,
      category: tuple.$2,
    );
  }

  /// ForumSelection을 튜플로 변환 (PhilgoCategory와 호환용)
  /// Convert ForumSelection to tuple (for compatibility with PhilgoCategory)
  (String, String?) toTuple() => (postId, category);

  /// 같은지 비교 (postId와 category 모두 일치해야 함)
  /// Equality comparison (both postId and category must match)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForumSelection &&
        other.postId == postId &&
        other.category == category;
  }

  /// 해시코드 생성
  /// Generate hash code
  @override
  int get hashCode => Object.hash(postId, category);

  /// copyWith - 일부 값만 변경한 새 인스턴스 생성
  /// Create new instance with some values changed
  ///
  /// 주의: category를 명시적으로 null로 설정하려면 clearCategory: true 사용
  /// Note: Use clearCategory: true to explicitly set category to null
  ///
  /// 사용 예시:
  /// ```dart
  /// final selection = ForumSelection(postId: 'buyandsell', category: '골프');
  ///
  /// // postId만 변경
  /// selection.copyWith(postId: 'freetalk'); // ForumSelection(postId: 'freetalk', category: '골프')
  ///
  /// // category를 null로 변경
  /// selection.copyWith(clearCategory: true); // ForumSelection(postId: 'buyandsell', category: null)
  /// ```
  ForumSelection copyWith({
    String? postId,
    String? category,
    bool clearCategory = false,
  }) {
    return ForumSelection(
      postId: postId ?? this.postId,
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  /// 서브 카테고리가 있는지 확인
  /// Check if has subcategory
  bool get hasCategory => category != null;

  /// 디버그용 문자열 표현
  /// String representation for debugging
  @override
  String toString() => 'ForumSelection(postId: $postId, category: $category)';
}
