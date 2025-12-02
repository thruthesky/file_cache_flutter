import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';

/// Post List View - Wrapper widget that delegates to either grid or list view
/// This widget determines the layout based on gridColumns parameter
class PostListView extends StatelessWidget {
  const PostListView({
    super.key,
    required this.postCategory,
    required this.headerBuilder,
    required this.onTap,
    this.noItemsFoundIndicatorBuilder,
    this.enableHeroTransition = false,
    this.tileBuilder,
    this.gridColumns,
    this.listViewKey,
    this.gridViewKey,
  });

  final PostCategoryItem postCategory;
  final void Function(Post post) onTap;
  final Widget Function(BuildContext context, int? totalPostCount) headerBuilder;
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
  final GlobalKey<PostGridViewState>? gridViewKey;

  @override
  Widget build(BuildContext context) {
    final isGridLayout = gridColumns != null && gridColumns! > 1;

    /// Render as Masonry Grid Layout
    if (isGridLayout) {
      return PostGridView(
        key: gridViewKey,
        postCategory: postCategory,
        headerBuilder: headerBuilder,
        onTap: onTap,
        noItemsFoundIndicatorBuilder: noItemsFoundIndicatorBuilder,
        enableHeroTransition: enableHeroTransition,
        tileBuilder: tileBuilder,
        gridColumns: gridColumns!,
      );
    }

    /// Render as List Layout (default)
    return PostSimpleListView(
      key: listViewKey,
      postCategory: postCategory,
      headerBuilder: headerBuilder,
      onTap: onTap,
      noItemsFoundIndicatorBuilder: noItemsFoundIndicatorBuilder,
      enableHeroTransition: enableHeroTransition,
      tileBuilder: tileBuilder,
    );
  }
}
