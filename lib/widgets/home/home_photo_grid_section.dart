import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/home_section_header.dart';
import 'package:philgo_api/philgo_api.dart';

/// 홈 화면 최근 사진 그리드 섹션 위젯 (Home Photo Grid Section Widget)
///
/// 장터(buyandsell) 게시판에서 사진이 있는 최근 글의 사진을 그리드로 표시합니다.
/// 4x4 그리드 레이아웃으로 총 16장의 사진을 표시합니다.
///
/// Section displaying recent photos from buyandsell board in a grid layout.
/// Displays 16 photos in a 4x4 grid.
///
/// [postId]: 게시판 ID (기본값: 'buyandsell')
/// [limit]: 표시할 사진 수 (기본값: 16)
/// [crossAxisCount]: 한 줄에 표시할 사진 수 (기본값: 4)
/// [onMoreTap]: "더보기" 버튼 클릭 시 콜백
/// [onPhotoTap]: 사진 클릭 시 콜백 (해당 게시글 전달)
class HomePhotoGridSection extends StatefulWidget {
  /// 게시판 ID (기본값: 'buyandsell')
  /// Board ID (default: 'buyandsell')
  final String postId;

  /// 표시할 사진 수 (기본값: 16)
  /// Number of photos to display (default: 16)
  final int limit;

  /// 한 줄에 표시할 사진 수 (기본값: 4)
  /// Number of photos per row (default: 4)
  final int crossAxisCount;

  /// "더보기" 버튼 클릭 콜백
  /// "More" button tap callback
  final VoidCallback? onMoreTap;

  /// 사진 클릭 콜백 (해당 게시글 전달)
  /// Photo tap callback (passes the post)
  final void Function(Post post)? onPhotoTap;

  const HomePhotoGridSection({
    super.key,
    this.postId = 'buyandsell',
    this.limit = 16,
    this.crossAxisCount = 4,
    this.onMoreTap,
    this.onPhotoTap,
  });

  @override
  State<HomePhotoGridSection> createState() => _HomePhotoGridSectionState();
}

class _HomePhotoGridSectionState extends State<HomePhotoGridSection> {
  /// 게시글 목록 (사진이 있는 글)
  /// Post list (posts with photos)
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

  /// 사진이 있는 게시글 로드
  /// Load posts with photos
  Future<void> _loadPosts() async {
    try {
      /// postList API 호출 (사진이 있는 글만 조회)
      /// - postId: 장터 게시판
      /// - has_image: true (사진이 있는 글만)
      ///
      /// Call postList API (posts with photos only)
      /// - postId: buyandsell board
      /// - has_image: true (filter posts with photos)
      final result = await postList(
        postId: widget.postId,
        has_image: true,
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

  /// 게시글의 첫 번째 이미지 URL 가져오기
  /// Get first image URL from post
  String? _getFirstImageUrl(Post post) {
    /// files 배열에서 첫 번째 이미지 URL 반환
    /// Return first image URL from files array
    if (post.files.isNotEmpty) {
      return post.files.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 섹션 타이틀: "최근 사진"
    /// Section title: "Recent Photos"
    const sectionTitle = '최근 사진';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (타이틀 + 더보기)
          /// Section header (title + more button)
          HomeSectionHeader(title: sectionTitle, onMoreTap: widget.onMoreTap),

          SizedBox(height: sp.s8),

          /// 로딩 상태: 스켈레톤 그리드
          /// Loading state: Skeleton grid
          if (_isLoading) _buildLoadingState(sp, scheme),

          /// 에러 상태: 에러 메시지 + 재시도 버튼
          /// Error state: Error message + retry button
          if (_error != null && !_isLoading)
            _buildErrorState(theme, scheme, sp),

          /// 성공 상태: 사진 그리드
          /// Success state: Photo grid
          if (_posts != null && !_isLoading && _error == null)
            _buildPhotoGrid(sp, scheme),
        ],
      ),
    );
  }

  /// 로딩 상태 UI (스켈레톤 그리드)
  /// Loading state UI (skeleton grid)
  Widget _buildLoadingState(AppSpacing sp, ColorScheme scheme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: sp.s8,
        crossAxisSpacing: sp.s8,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.limit,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
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
            '사진을 불러올 수 없습니다.',
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

  /// 사진 그리드 UI (4x4 레이아웃)
  /// Photo grid UI (4x4 layout)
  Widget _buildPhotoGrid(AppSpacing sp, ColorScheme scheme) {
    final theme = Theme.of(context);

    /// 사진이 없는 경우
    /// If no photos
    if (_posts == null || _posts!.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: sp.s16),
        child: Center(
          child: Text(
            '사진이 없습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
        ),
      );
    }

    /// 사진 그리드 표시 (4x4)
    /// Display photo grid (4x4)
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: sp.s8,
        crossAxisSpacing: sp.s8,
        childAspectRatio: 1.0,
      ),
      itemCount: _posts!.length,
      itemBuilder: (context, index) {
        final post = _posts![index];
        final imageUrl = _getFirstImageUrl(post);

        return _buildPhotoTile(post, imageUrl, scheme, sp);
      },
    );
  }

  /// 개별 사진 타일 위젯
  /// Individual photo tile widget
  Widget _buildPhotoTile(
    Post post,
    String? imageUrl,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return GestureDetector(
      onTap: () => widget.onPhotoTap?.call(post),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: scheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,

                /// 로딩 중 표시
                /// Loading placeholder
                placeholder: (context, url) => Container(
                  color: scheme.surfaceContainerHighest,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.outline,
                      ),
                    ),
                  ),
                ),

                /// 에러 시 표시
                /// Error widget
                errorWidget: (context, url, error) => Container(
                  color: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 24,
                    color: scheme.outline,
                  ),
                ),
              )
            /// 이미지 URL이 없는 경우
            /// If no image URL
            : Container(
                color: scheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_outlined,
                  size: 24,
                  color: scheme.outline,
                ),
              ),
      ),
    );
  }
}
