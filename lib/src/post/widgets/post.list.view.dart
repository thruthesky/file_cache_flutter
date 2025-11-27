import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostListViewController {
  late final PostListViewState state;
}

class PostListView extends StatefulWidget {
  const PostListView({
    super.key,
    required this.controller,
    required this.postCategory,
    required this.headerBuilder,
    required this.onTap,
    this.noItemsFoundIndicatorBuilder,
  });

  final PostListViewController controller;

  final PostCategoryItem postCategory;
  final void Function(Post post) onTap;
  final Widget Function(BuildContext context, int? totalPostCount)
  headerBuilder;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;

  @override
  State<PostListView> createState() => PostListViewState();
}

class PostListViewState extends State<PostListView> {
  int? _totalPostCount;

  late final pagingController = PagingController<int, Post>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pagekey) async {
      // d('Fetching page: $pagekey, category: ${widget.selectedCategory}');
      final res = await getPosts(
        limit: 20,
        page: pagekey,
        postId: widget.postCategory.postId,
        category: widget.postCategory.category,
      );

      if (_totalPostCount != res.post_count) {
        setState(() {
          _totalPostCount = res.post_count;
        });
      }

      return res.posts;
    },
  );

  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
  }

  @override
  void didUpdateWidget(covariant PostListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postCategory.postId != widget.postCategory.postId ||
        oldWidget.postCategory.category != widget.postCategory.category) {
      pagingController.refresh();
    }
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener<int, Post>(
      controller: pagingController,
      builder: (context, state, fetchNextPage) => PagedListView.separated(
        // 게시글 사이에 간격 추가
        separatorBuilder: (context, index) => const SizedBox(height: 8),

        padding: const EdgeInsets.all(8.0),
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder,
          itemBuilder: (context, post, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.headerBuilder(context, _totalPostCount),
                  SizedBox(height: 8),
                  PostListTile(post: post, onTap: () => widget.onTap(post)),
                ],
              );
            }
            return PostListTile(
              post: post,
              // 사용자가 게시물을 탭했을 때 부모에서 전달받은 콜백 함수 실행
              onTap: () => widget.onTap(post),
            );
          },
          firstPageProgressIndicatorBuilder: (context) =>
              const Center(child: CircularProgressIndicator.adaptive()),
          newPageProgressIndicatorBuilder: (context) =>
              const Center(child: CircularProgressIndicator.adaptive()),
        ),
      ),
    );
  }
}
