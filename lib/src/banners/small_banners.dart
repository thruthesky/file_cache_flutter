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
  /// 컴팩트한 디자인으로 작은 공간에 효율적으로 배너 표시
  /// Compact design for efficient banner display in small spaces
  Widget _buildBannerItem(BuildContext context, BannerModel banner) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      /// 배너 클릭 시 콜백 호출
      /// Call callback on banner tap
      onTap: () => widget.onTap(banner.link),
      child: Container(
        /// flat design: elevation 0, 진한 amber 테두리로 광고 구분
        /// Flat design: no elevation, dark amber border to distinguish ads
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38, width: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            /// 이미지가 있으면 왼쪽에 표시 (컴팩트 사이즈)
            /// Show image on the left if available (compact size)
            if (banner.url.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),

                /// CachedNetworkImage: 이미지 캐싱으로 성능 향상
                /// CachedNetworkImage: Improved performance with image caching
                child: CachedNetworkImage(
                  imageUrl: banner.url,
                  width: 96,
                  height: 48,
                  fit: BoxFit.cover,

                  /// 이미지 로드 실패 시 동일 크기의 빈 위젯 반환
                  /// Return empty widget with same size on image load error
                  errorWidget: (context, url, error) =>
                      const SizedBox(width: 96, height: 48),
                ),
              ),

            /// 텍스트 영역 (primary, secondary) - 컴팩트 패딩
            /// Text area (primary, secondary) - compact padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

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
