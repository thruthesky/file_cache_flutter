import 'package:flutter/material.dart';
import 'package:philgo/extensions/nav.context.dart';
import 'package:philgo/widgets/home/home_section_header.dart';
import 'package:philgo_api/philgo_api.dart';

/// 홈 게시판 섹션 Shimmer 로딩 위젯 (Home Post Section Shimmer Widget)
///
/// 게시글 데이터 로딩 중일 때 표시되는 shimmer 효과 위젯입니다.
/// HomePostSection과 동일한 레이아웃을 유지하여 로딩 → 데이터 표시 전환이 자연스럽습니다.
///
/// Shimmer loading widget displayed while post data is loading.
/// Maintains the same layout as HomePostSection for smooth loading → data transition.
///
/// ### Parameters:
/// - [postId]: 게시판 ID (헤더 타이틀 및 네비게이션용)
/// - [category]: 서브 카테고리 (옵션)
/// - [itemCount]: shimmer 아이템 개수 (기본값: 4)
///
/// ### Example:
/// ```dart
/// // 기본 사용
/// HomePostSectionShimmer(postId: 'freetalk')
///
/// // 카테고리 지정
/// HomePostSectionShimmer(
///   postId: 'buyandsell',
///   category: '골프',
/// )
///
/// // 아이템 개수 지정
/// HomePostSectionShimmer(
///   postId: 'qna',
///   itemCount: 6,
/// )
/// ```
class HomePostSectionShimmer extends StatelessWidget {
  /// 게시판 ID (예: 'freetalk', 'qna')
  /// Board ID (e.g., 'freetalk', 'qna')
  final String postId;

  /// 서브 카테고리 (옵션)
  /// Sub-category (optional)
  final String? category;

  /// Shimmer 아이템 개수 (기본값: 4)
  /// Number of shimmer items (default: 4)
  final int itemCount;

  const HomePostSectionShimmer({
    super.key,
    required this.postId,
    this.category,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    /// 섹션 타이틀 (다국어 지원) (Localized section title)
    final sectionTitle = philgoTr(context, category ?? postId);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (타이틀 + 더보기) - 실제 헤더와 동일
          /// Section header (title + more button) - same as actual header
          HomeSectionHeader(
            title: sectionTitle,
            onMoreTap: () {
              /// 로딩 중에도 게시판으로 이동 가능
              /// Allow navigation to board even while loading
              context.openForum(postId, category: category);
            },
          ),

          /// Shimmer 로딩 효과 (Shimmer loading effect)
          ...List.generate(
            itemCount,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                /// 게시글 제목 높이에 맞춤 (24px)
                /// Match the height of post title rows (24px)
                height: 24,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
