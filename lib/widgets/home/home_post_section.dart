import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/home_section_header.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 홈 화면 게시판 섹션 위젯 (Home Post Section Widget)
///
/// 특정 게시판의 최근 글을 표시하는 섹션입니다.
/// API에서 최근 글을 가져와서 제목만 간결하게 표시합니다.
///
/// Section displaying latest posts from a specific board.
/// Fetches latest posts from API and displays only titles for simplicity.
///
/// [postId]: 게시판 ID (예: 'freetalk', 'qna')
/// [category]: 서브 카테고리 (옵션)
/// [limit]: 표시할 게시글 수 (기본값: 4)
/// [onMoreTap]: "더보기" 버튼 클릭 시 콜백
/// [onPostTap]: 게시글 클릭 시 콜백
class HomePostSection extends StatefulWidget {
  /// 게시판 ID (예: 'freetalk', 'qna')
  /// Board ID (e.g., 'freetalk', 'qna')
  final String postId;

  /// 서브 카테고리 (옵션)
  /// Sub-category (optional)
  final String? category;

  /// 표시할 게시글 수 (기본값: 4)
  /// Number of posts to display (default: 4)
  final int limit;

  /// "더보기" 버튼 클릭 콜백
  /// "More" button tap callback
  final VoidCallback? onMoreTap;

  /// 게시글 클릭 콜백
  /// Post tap callback
  final void Function(Post post)? onPostTap;

  const HomePostSection({
    super.key,
    required this.postId,
    this.category,
    this.limit = 4,
    this.onMoreTap,
    this.onPostTap,
  });

  @override
  State<HomePostSection> createState() => _HomePostSectionState();
}

class _HomePostSectionState extends State<HomePostSection> {
  /// 게시글 목록
  /// Post list
  List<Post>? _posts;

  /// 로딩 상태
  /// Loading state
  bool _isLoading = true;

  /// 에러 메시지
  /// Error message
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  /// 게시글 로드
  /// Load posts from API
  Future<void> _loadPosts() async {
    try {
      /// getPosts API 호출 (postId, limit 파라미터 사용)
      /// Call getPosts API (using postId, limit parameters)
      final result = await getPosts(
        postId: widget.postId,
        category: widget.category,
        limit: widget.limit,
        page: 1,
      );

      if (mounted) {
        setState(() {
          _posts = result.posts;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 섹션 타이틀 (다국어 지원)
    /// Section title (localized)
    final sectionTitle = philgoTr(context, widget.postId);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (타이틀 + 더보기)
          /// Section header (title + more button)
          HomeSectionHeader(
            title: sectionTitle,
            onMoreTap: widget.onMoreTap,
          ),

          /// 로딩 상태: Shimmer 효과
          /// Loading state: Shimmer effect
          if (_isLoading) _buildLoadingState(sp, scheme),

          /// 에러 상태: 에러 메시지 + 재시도 버튼
          /// Error state: Error message + retry button
          if (_error != null && !_isLoading)
            _buildErrorState(theme, scheme, sp),

          /// 성공 상태: 게시글 목록
          /// Success state: Post list
          if (_posts != null && !_isLoading && _error == null)
            _buildPostList(sp),
        ],
      ),
    );
  }

  /// 로딩 상태 UI
  /// Loading state UI
  Widget _buildLoadingState(AppSpacing sp, ColorScheme scheme) {
    return Column(
      children: List.generate(
        widget.limit,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: sp.s8),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  /// 에러 상태 UI
  /// Error state UI
  Widget _buildErrorState(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '게시글을 불러올 수 없습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.error,
            ),
          ),
          SizedBox(height: sp.s8),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadPosts();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 게시글 목록 UI (제목만 표시)
  /// Post list UI (title only)
  Widget _buildPostList(AppSpacing sp) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 게시글이 없는 경우
    /// If no posts
    if (_posts == null || _posts!.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: sp.s16),
        child: Center(
          child: Text(
            '게시글이 없습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.outline,
            ),
          ),
        ),
      );
    }

    /// 게시글 목록 표시 (제목만 표시)
    /// Display post list (title only)
    return Column(
      children: _posts!.map((post) {
        return InkWell(
          onTap: () => widget.onPostTap?.call(post),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sp.s8,
              horizontal: sp.s4,
            ),
            child: Row(
              children: [
                /// 글머리 기호 (bullet point)
                /// Bullet point indicator
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: sp.s8),

                /// 게시글 제목 (제목만 표시)
                /// Post title (title only)
                Expanded(
                  child: Text(
                    post.subject,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
