import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/post/create/post.create.screen.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  /// 현재 선택된 카테고리 인덱스
  int _selectedIndex = 0;

  /// 페이지당 게시글 수
  static const _pageSize = 20;

  /// 무한 스크롤 페이지네이션 컨트롤러
  late final PagingController<int, Post> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Post>(
      getNextPageKey: (state) {
        final keys = state.keys;
        if (keys == null || keys.isEmpty) return 0;
        return keys.last + _pageSize;
      },
      fetchPage: _fetchPage,
    );

  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  /// 게시글 페이지 로드
  Future<List<Post>> _fetchPage(int offset) async {
    final (postId, category, _) = forumCategories[_selectedIndex];
    final result = await PostService.list(
      postId: postId,
      category: category,
      limit: _pageSize,
      offset: offset,
    );
    return result.posts;
  }

  /// 카테고리 변경 시 목록 리프레시
  void _onCategoryTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(theme, scheme),
            Container(height: 1, color: scheme.outlineVariant),
            _buildCategoryList(theme, scheme),
            Container(height: 1, color: scheme.outlineVariant),
            Expanded(child: _buildPostList(theme, scheme)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostCreate,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        child: const FaIcon(FontAwesomeIcons.lightPen, size: 20),
      ),
    );
  }

  /// 앱바 영역
  Widget _buildAppBar(ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.lightNewspaper,
            size: 20,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Text('게시판', style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }

  /// 카테고리 가로 스크롤 목록
  Widget _buildCategoryList(ThemeData theme, ColorScheme scheme) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: forumCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final (_, _, label) = forumCategories[index];
          final isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () => _onCategoryTap(index),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary
                    : scheme.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 게시글 무한 스크롤 목록
  Widget _buildPostList(ThemeData theme, ColorScheme scheme) {
    return PagingListener(
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
            itemBuilder: (context, post, index) => _PostListTile(
              post: post,
              theme: theme,
              scheme: scheme,
              onTap: () => _openPostView(post),
            ),
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child:
                  Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            noItemsFoundIndicatorBuilder: (_) =>
                _EmptyPostList(scheme: scheme),
            firstPageErrorIndicatorBuilder: (context) => _ErrorIndicator(
              scheme: scheme,
              onRetry: () => _pagingController.refresh(),
            ),
          ),
        );
      },
    );
  }

  /// 게시글 작성 화면 열기
  Future<void> _openPostCreate() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    final (postId, category, _) = forumCategories[_selectedIndex];
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) =>
            PostCreateScreen(postId: postId, category: category),
      ),
    );

    if (result is Post && mounted) {
      // 목록 새로고침 (새 게시글이 서버에서 첫 번째로 반환됨)
      _pagingController.refresh();
      // 새 게시글 상세 화면 열기
      _openPostView(result);
    }
  }

  /// 게시글 상세 화면 열기
  Future<void> _openPostView(Post post) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => PostViewScreen(post: post)),
    );

    // 삭제 또는 수정 시 목록 새로고침
    if ((result == 'deleted' || result is Post) && mounted) {
      _pagingController.refresh();
    }
  }
}

/// 게시글 리스트 타일 (v6 CompactPostListTile 스타일)
class _PostListTile extends StatelessWidget {
  final Post post;
  final ThemeData theme;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const _PostListTile({
    required this.post,
    required this.theme,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasThumbnail =
        post.thumbnail400x400 != null && post.thumbnail400x400!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    post.subject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 날짜
                  Text(
                    _formatDate(post.stamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 통계 (조회수, 댓글, 좋아요)
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.lightEye,
                          size: 12, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${post.noOfView}',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(width: 12),
                      FaIcon(FontAwesomeIcons.lightComment,
                          size: 12, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${post.noOfComment}',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      if (post.good > 0) ...[
                        const SizedBox(width: 12),
                        FaIcon(FontAwesomeIcons.lightThumbsUp,
                            size: 12, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('${post.good}',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 썸네일
            if (hasThumbnail) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: post.thumbnail400x400!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 72,
                    height: 72,
                    color: scheme.surfaceContainerHigh,
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 72,
                    height: 72,
                    color: scheme.surfaceContainerHigh,
                    child: Icon(Icons.broken_image,
                        color: scheme.onSurfaceVariant, size: 24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Unix timestamp → 상대 시간 또는 날짜 문자열
  String _formatDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 365) return '${date.month}/${date.day}';
    return '${date.year}/${date.month}/${date.day}';
  }
}

/// 게시글 없음 표시
class _EmptyPostList extends StatelessWidget {
  final ColorScheme scheme;
  const _EmptyPostList({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.lightFolderOpen,
              size: 48,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('게시글이 없습니다',
              style:
                  TextStyle(color: scheme.onSurfaceVariant, fontSize: 16)),
        ],
      ),
    );
  }
}

/// 에러 표시
class _ErrorIndicator extends StatelessWidget {
  final ColorScheme scheme;
  final VoidCallback onRetry;
  const _ErrorIndicator({required this.scheme, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.lightCircleExclamation,
              size: 48, color: scheme.error),
          const SizedBox(height: 16),
          Text('게시글을 불러올 수 없습니다',
              style:
                  TextStyle(color: scheme.onSurfaceVariant, fontSize: 16)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const FaIcon(FontAwesomeIcons.lightArrowRotateRight,
                size: 14),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
