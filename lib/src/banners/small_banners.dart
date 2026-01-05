import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
      children: banners.map((banner) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: _buildBannerItem(context, banner),
        );
      }).toList(),
    );
  }

  /// 개별 배너 아이템 빌드
  /// Build individual banner item
  ///
  /// Comic Design: 내부 여백 추가, Theme 기반 테두리 색상 적용
  /// Comic Design: Added internal padding, Theme-based border color
  Widget _buildBannerItem(BuildContext context, BannerModel banner) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      /// 배너 클릭 시 콜백 호출
      /// Call callback on banner tap
      onTap: () => widget.onTap(banner.link),
      /// 테두리와 동일한 borderRadius 적용 (ripple 효과용)
      borderRadius: BorderRadius.circular(12),
      child: Container(
        /// Comic Design: Theme 기반 테두리, 부드러운 모서리
        /// Comic Design: Theme-based border, rounded corners
        decoration: BoxDecoration(
          // Comic Design: 1.0px 테두리로 광고 구분
          border: Border.all(
            color: scheme.outlineVariant,
            width: 1.0,
          ),
          // Comic Design: 12px borderRadius (큰 요소)
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            /// 이미지가 있으면 왼쪽에 표시 (컴팩트 사이즈)
            /// Show image on the left if available (compact size)
            if (banner.url.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),

                /// CachedNetworkImage: 이미지 캐싱으로 성능 향상
                /// CachedNetworkImage: Improved performance with image caching
                child: CachedNetworkImage(
                  imageUrl: banner.url,
                  // 이미지 크기 증가 (96x48 → 100x56)
                  width: 100,
                  height: 56,
                  fit: BoxFit.cover,

                  /// 이미지 로드 실패 시 동일 크기의 빈 위젯 반환
                  /// Return empty widget with same size on image load error
                  errorWidget: (context, url, error) =>
                      const SizedBox(width: 100, height: 56),
                ),
              ),

            /// 텍스트 영역 (primary, secondary) - 내부 여백 증가
            /// Text area (primary, secondary) - increased internal padding
            Expanded(
              child: Padding(
                // Comic Design: 내부 여백 증가 (horizontal: 8→12, vertical: 6→10)
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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

                    // Primary와 Secondary 사이 간격 추가
                    if (banner.primary.isNotEmpty && banner.secondary.isNotEmpty)
                      const SizedBox(height: 2),

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
            ),
          ],
        ),
      ),
    );
  }
}
