import 'package:philgo_api/philgo_api.dart';
import 'package:flutter/material.dart';

/// Post List View - Wrapper widget that delegates to either grid or list view
/// 게시글 리스트 뷰 - gridColumns 파라미터에 따라 그리드 또는 리스트 뷰로 위임
/// This widget determines the layout based on gridColumns parameter
class PostListView extends StatelessWidget {
  const PostListView({
    super.key,
    required this.postId,
    this.category,
    required this.onTap,
    this.noItemsFoundIndicatorBuilder,
    this.enableHeroTransition = false,
    this.tileBuilder,
    this.gridColumns,
    this.listViewKey,
    this.gridViewKey,
  });

  /// 메인 카테고리 ID (Main category ID)
  /// 예: 'freetalk', 'buyandsell', 'qna'
  final String postId;

  /// 서브 카테고리 (Sub category, optional)
  /// 예: 'discussion', '호텔', '렌트카'
  final String? category;

  final void Function(Post post) onTap;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final bool enableHeroTransition;

  /// Optional custom tile builder for rendering individual post items
  /// If null, defaults to PostListTile widget
  final Widget Function(Post post, VoidCallback onTap)? tileBuilder;

  /// Number of columns for grid layout
  /// If null or 1, displays as a list. If 2 or more, displays as a grid
  final int? gridColumns;

  /// Optional key for list view (used when gridColumns is null or 1)
  final GlobalKey<PostSimpleListViewState>? listViewKey;

  /// Optional key for grid view (used when gridColumns is 2 or more)
  final GlobalKey<PostMasonryViewState>? gridViewKey;

  @override
  Widget build(BuildContext context) {
    final isGridLayout = gridColumns != null && gridColumns! > 1;

    /// Masonry 그리드 레이아웃으로 렌더링
    /// Render as Masonry Grid Layout
    if (isGridLayout) {
      return PostMasonryView(
        key: gridViewKey,
        postId: postId,
        category: category,
        onTap: onTap,
        noItemsFoundIndicatorBuilder: noItemsFoundIndicatorBuilder,
        enableHeroTransition: enableHeroTransition,
        tileBuilder: tileBuilder,
        gridColumns: gridColumns!,
      );
    }

    /// 리스트 레이아웃으로 렌더링 (기본값)
    /// Render as List Layout (default)
    return PostSimpleListView(
      key: listViewKey,
      postId: postId,
      category: category,
      onTap: onTap,
      noItemsFoundIndicatorBuilder: noItemsFoundIndicatorBuilder,
      enableHeroTransition: enableHeroTransition,
      tileBuilder: tileBuilder,
    );
  }
}
