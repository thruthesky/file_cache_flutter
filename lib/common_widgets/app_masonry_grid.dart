import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// 범용 Masonry 그리드 위젯
///
/// [PagingController] 기반 무한 스크롤 Masonry 레이아웃을 제공한다.
/// 게시판(회원장터), 업소록, 사진 갤러리 등 다양한 목록에서 재사용 가능.
///
/// ```dart
/// AppMasonryGrid<Post>(
///   pagingController: _pagingController,
///   itemBuilder: (context, post, index) => MasonryCard(
///     title: post.subject,
///     youtubeUrl: post.youtubeUrl,
///     imageUrl: post.thumbnail,
///     onTap: () => openPost(post),
///   ),
/// )
/// ```
class AppMasonryGrid<T> extends StatelessWidget {
  /// 페이지네이션 컨트롤러
  final PagingController<int, T> pagingController;

  /// 각 아이템의 위젯을 빌드하는 콜백
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 열 수 (기본값: 2)
  final int crossAxisCount;

  /// 세로 간격
  final double mainAxisSpacing;

  /// 가로 간격
  final double crossAxisSpacing;

  /// 그리드 패딩
  final EdgeInsets padding;

  /// 아이템이 없을 때 표시할 위젯
  final WidgetBuilder? emptyBuilder;

  /// 첫 페이지 에러 시 표시할 위젯
  final WidgetBuilder? errorBuilder;

  const AppMasonryGrid({
    super.key,
    required this.pagingController,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.padding = const EdgeInsets.all(8),
    this.emptyBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: pagingController,
      builder: (context, state, fetchNextPage) {
        return PagedMasonryGridView<int, T>.count(
          state: state,
          fetchNextPage: fetchNextPage,
          physics: const ClampingScrollPhysics(),
          crossAxisCount: crossAxisCount,
          padding: padding,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          builderDelegate: PagedChildBuilderDelegate<T>(
            itemBuilder: itemBuilder,
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            noItemsFoundIndicatorBuilder: emptyBuilder ??
                (_) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          '항목이 없습니다'.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
            firstPageErrorIndicatorBuilder: errorBuilder ??
                (_) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('불러오기에 실패했습니다'.tr()),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => pagingController.refresh(),
                              child: Text('다시 시도'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        );
      },
    );
  }
}
