import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// Small 배너 위젯 (작은 배너)
/// Small Banners Widget
///
/// 사각 배너 아래에 표시되는 작은 광고 배너입니다.
/// 텍스트(primary, secondary)를 포함할 수 있습니다.
///
/// [postIdOrCategory]: 게시판/카테고리 ID (필수)
/// - 해당 카테고리의 작은 배너 + 전체 페이지 배너를 표시
///
/// [onTap]: 배너 클릭 시 호출되는 콜백 (필수)
/// - 배너의 링크 URL을 파라미터로 전달받습니다.
/// - 외부 링크 열기, 내부 라우팅 등을 처리할 수 있습니다.
///
/// ### 사용법 (Usage):
/// ```dart
/// SmallBanners(
///   postIdOrCategory: 'freetalk',
///   onTap: (link) => openBannerUrl(context, link),
/// )
/// ```
class SmallBanners extends StatefulWidget {
  /// 게시판/카테고리 ID (필수)
  /// Post ID or Category (required)
  final String postIdOrCategory;

  /// 배너 클릭 시 호출되는 콜백 (Banner tap callback)
  ///
  /// 배너의 링크 URL을 파라미터로 전달받습니다.
  /// Receives banner link URL as parameter.
  final void Function(String link) onTap;

  const SmallBanners({
    super.key,
    required this.postIdOrCategory,
    required this.onTap,
  });

  @override
  State<SmallBanners> createState() => _SmallBannersState();
}

class _SmallBannersState extends State<SmallBanners> {
  /// 배너 목록
  /// Banner list
  List<BannerModel> banners = [];

  /// 로딩 상태
  /// Loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void didUpdateWidget(covariant SmallBanners oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postIdOrCategory != widget.postIdOrCategory) {
      setState(() {
        isLoading = true;
        banners = [];
      });
      _loadBanners();
    }
  }

  /// 배너 로드
  /// Load banners from API
  Future<void> _loadBanners() async {
    final result = await BannerApi.getSmallBanners(
      category: widget.postIdOrCategory,
    );

    if (mounted) {
      setState(() {
        banners = result;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 로딩 중에는 빈 위젯 반환
    /// Return empty widget while loading
    if (isLoading) return const SizedBox.shrink();

    /// 배너가 없으면 빈 위젯 반환
    /// Return empty widget if no banners
    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        /// 배너 목록
        /// Banner list
        ...banners.map((banner) {
          return Padding(
            /// 외부 여백: 좌우 4px
            /// Outer margin: left/right 4px
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: _buildBannerItem(context, banner),
          );
        }),

        /// 배너 영역 상단 구분선
        /// Divider at the top of banner area
        Divider(
          height: 16,
          thickness: 1,
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  /// 개별 배너 아이템 빌드
  /// Build individual banner item
  ///
  /// Flat Design: 보더 없이 배경색으로 영역 구분, Chevron 아이콘으로 클릭 유도
  /// Flat Design: No border, area separation by background color, chevron icon for click guidance
  Widget _buildBannerItem(BuildContext context, BannerModel banner) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      /// Flat Design: 보더 대신 배경색으로 영역 구분
      /// Flat Design: Use background color instead of border for area separation
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        /// 배너 클릭 시 콜백 호출
        /// Call callback on banner tap
        onTap: () => widget.onTap(banner.link),
        borderRadius: BorderRadius.circular(12),

        /// 터치 피드백 강화 (splashColor, highlightColor)
        /// Enhanced touch feedback
        splashColor: scheme.primary.withValues(alpha: 0.1),
        highlightColor: scheme.primary.withValues(alpha: 0.05),
        child: Padding(
          /// 8배수 규칙 준수: 왼쪽 8px (줄임), 오른쪽 16px (늘림)
          /// 8-multiple rule: left 8px (reduced), right 16px (increased)
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
          child: Row(
            children: [
              /// 이미지가 있으면 왼쪽에 표시 (확대된 크기: 110x64)
              /// Show image on the left if available (enlarged size: 110x64)
              if (banner.url.isNotEmpty)
                ClipRRect(
                  /// 부드러운 모서리 (8px borderRadius)
                  /// Smooth corners (8px borderRadius)
                  borderRadius: BorderRadius.circular(8),

                  /// CachedNetworkImage: 이미지 캐싱으로 성능 향상
                  /// CachedNetworkImage: Improved performance with image caching
                  child: CachedNetworkImage(
                    imageUrl: banner.url,

                    /// 이미지 크기 확대 (100x56 → 110x64)
                    /// Enlarged image size (100x56 → 110x64)
                    width: 108,
                    height: 54,
                    fit: BoxFit.cover,

                    /// 이미지 로드 실패 시 동일 크기의 빈 위젯 반환
                    /// Return empty widget with same size on image load error
                    errorWidget: (context, url, error) =>
                        const SizedBox(width: 110, height: 64),
                  ),
                ),

              /// 이미지와 텍스트 사이 간격
              /// Spacing between image and text
              if (banner.url.isNotEmpty) const SizedBox(width: 12),

              /// 텍스트 영역 (primary, secondary)
              /// Text area (primary, secondary)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Primary 텍스트 (주요 텍스트)
                    /// Primary text
                    if (banner.primary.isNotEmpty)
                      Text(
                        banner.primary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    /// Primary와 Secondary 사이 간격 (4px)
                    /// Spacing between Primary and Secondary (4px)
                    if (banner.primary.isNotEmpty &&
                        banner.secondary.isNotEmpty)
                      const SizedBox(height: 4),

                    /// Secondary 텍스트 (부가 텍스트) - 1줄 제한, ellipsis 처리
                    /// Secondary text - limited to 1 line with ellipsis
                    if (banner.secondary.isNotEmpty)
                      Text(
                        banner.secondary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              /// 우측 간격 (8px)
              /// Right spacing (8px)
              const SizedBox(width: 8),

              /// Chevron 아이콘 (클릭 유도) - Font Awesome Light 스타일
              /// Chevron icon (click guidance) - Font Awesome Light style
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
