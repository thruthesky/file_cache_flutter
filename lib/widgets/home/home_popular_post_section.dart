import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/home_section_header.dart';
import 'package:philgo_api/philgo_api.dart';

/// 홈 화면 인기글 섹션 위젯 (Home Popular Post Section Widget)
///
/// 최근 7일간 댓글이 많은 인기글을 표시하는 섹션입니다.
/// API에서 댓글 많은 순으로 정렬된 글을 가져와 제목만 간결하게 표시합니다.
///
/// Section displaying popular posts from the last 7 days.
/// Fetches posts sorted by comment count and displays only titles.
///
/// [limit]: 표시할 게시글 수 (기본값: 5)
/// [withinDays]: 최근 N일 이내의 글 (기본값: 7)
/// [onMoreTap]: "더보기" 버튼 클릭 시 콜백
/// [onPostTap]: 게시글 클릭 시 콜백
class HomePopularPostSection extends StatefulWidget {
  /// 표시할 게시글 수 (기본값: 5)
  /// Number of posts to display (default: 5)
  final int limit;

  /// 최근 N일 이내의 글 (기본값: 7)
  /// Posts within N days (default: 7)
  final int withinDays;

  /// "더보기" 버튼 클릭 콜백
  /// "More" button tap callback
  final VoidCallback? onMoreTap;

  /// 게시글 클릭 콜백
  /// Post tap callback
  final void Function(Post post)? onPostTap;

  const HomePopularPostSection({
    super.key,
    this.limit = 3,
    this.withinDays = 7,
    this.onMoreTap,
    this.onPostTap,
  });

  @override
  State<HomePopularPostSection> createState() => _HomePopularPostSectionState();
}

class _HomePopularPostSectionState extends State<HomePopularPostSection> {
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

  /// 인기글 로드 (최근 7일간 댓글 많은 순)
  /// Load popular posts (sorted by comment count within last 7 days)
  Future<void> _loadPosts() async {
    try {
      /// postList API 호출 (인기글 조회)
      /// - orderBy: 댓글 많은 순 → 최신순
      /// - extraConditions: 최근 7일 이내, 최소 필드만 조회
      ///
      /// Call postList API (popular posts query)
      /// - orderBy: Most comments → Most recent
      /// - extraConditions: Within 7 days, minimal fields for performance
      final result = await getPosts(
        limit: widget.limit,
        page: 1,
        orderBy: 'no_of_comment DESC, stamp DESC',
        extraConditions: {
          'within_days': widget.withinDays,
          'minimal_fields': 'y',
        },
        type: 'post',
      );

      if (mounted) {
        setState(() {
          _posts = result;
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

    /// 섹션 타이틀: "인기글"
    /// Section title: "Popular Posts"
    const sectionTitle = '인기글';

    return Padding(
      padding: EdgeInsets.only(left: sp.s16, right: sp.s16, top: sp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (타이틀 + 더보기)
          /// Section header (title + more button)
          HomeSectionHeader(title: sectionTitle, onMoreTap: widget.onMoreTap),

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
            height: 40,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  /// 에러 상태 UI
  /// Error state UI
  Widget _buildErrorState(ThemeData theme, ColorScheme scheme, AppSpacing sp) {
    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '인기글을 불러올 수 없습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
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
            '인기글이 없습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
        ),
      );
    }

    /// 인기글 목록 표시 (제목 + 댓글 수)
    /// Display popular post list (title + comment count)
    return Column(
      children: _posts!.map((post) {
        return InkWell(
          onTap: () => widget.onPostTap?.call(post),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: sp.s8, horizontal: sp.s4),
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

                /// 게시글 제목
                /// Post title
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

                /// 댓글 수 표시
                /// Comment count
                if (post.no_of_comment > 0) ...[
                  SizedBox(width: sp.s8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s8,
                      vertical: sp.s4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${post.no_of_comment}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
