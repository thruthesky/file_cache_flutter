import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/post/list/widgets/empty_post_list.dart';
import 'package:philgo/post/list/widgets/post.list.tile.dart';
import 'package:philgo/post/list/widgets/post_list_error_indicator.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 내 글 목록 화면
///
/// 로그인한 사용자의 게시글 목록을 무한 스크롤로 표시한다.
class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final int _pageSize = 20;

  late final PagingController<int, Post> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Post>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        final keys = state.keys;
        if (keys == null || keys.isEmpty) return 1;
        return keys.last + 1;
      },
      fetchPage: _fetchPage,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<Post>> _fetchPage(int page) async {
    final userState = Provider.of<UserState>(context, listen: false);
    final result = await PostService.list(
      idxMember: userState.idx,
      limit: _pageSize,
      page: page,
    );
    if (page > 1 && result.posts.isEmpty) return [];
    return result.posts;
  }

  Future<void> _openPostView(Post post) async {
    final result = await PostViewScreen.push(context, post);
    if ((result == 'deleted' || result is Post) && mounted) {
      _pagingController.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.lightRectangleList,
              size: 18,
              color: scheme.primary,
            ),
            const SizedBox(width: 8),
            Text('내 글 목록'.tr(), style: theme.textTheme.titleMedium),
          ],
        ),
      ),
      body: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) {
          return PagedListView<int, Post>.separated(
            state: state,
            fetchNextPage: fetchNextPage,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
            builderDelegate: PagedChildBuilderDelegate<Post>(
              itemBuilder: (context, post, index) =>
                  PostListTile(post: post, onTap: () => _openPostView(post)),
              firstPageProgressIndicatorBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              newPageProgressIndicatorBuilder: (_) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              noItemsFoundIndicatorBuilder: (_) =>
                  EmptyPostList(scheme: scheme),
              firstPageErrorIndicatorBuilder: (context) =>
                  PostListErrorIndicator(
                    scheme: scheme,
                    onRetry: () => _pagingController.refresh(),
                  ),
            ),
          );
        },
      ),
    );
  }
}
