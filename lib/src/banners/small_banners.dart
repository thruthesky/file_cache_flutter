import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_v6_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import './banner.model.dart';

/// Small 배너 위젯 (작은 배너)
/// Small Banners Widget
///
/// 사각 배너 아래에 표시되는 작은 광고 배너입니다.
/// 텍스트(primary, secondary)를 포함할 수 있습니다.
///
/// [postIdOrCategory]: 게시판/카테고리 ID (필수)
/// - 해당 카테고리의 작은 배너 + 전체 페이지 배너를 표시
class SmallBanners extends StatefulWidget {
  /// 게시판/카테고리 ID (필수)
  /// Post ID or Category (required)
  final String postIdOrCategory;

  const SmallBanners({super.key, required this.postIdOrCategory});

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
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildBannerItem(context, banner),
        );
      }).toList(),
    );
  }

  /// 개별 배너 아이템 빌드
  /// Build individual banner item
  Widget _buildBannerItem(BuildContext context, BannerModel banner) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      /// 배너 클릭 시 외부 링크 열기
      /// Open external link on banner tap
      onTap: () async {
        if (banner.link.isNotEmpty) {
          final uri = Uri.tryParse(banner.link);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        /// flat design: elevation 0, 배경색만으로 구분
        /// Flat design: no elevation, distinguish by background color
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            /// 이미지가 있으면 왼쪽에 표시
            /// Show image on the left if available
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
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,

                  /// 이미지 로드 실패 시 동일 크기의 빈 위젯 반환
                  /// Return empty widget with same size on image load error
                  errorWidget: (context, url, error) =>
                      const SizedBox(width: 80, height: 80),
                ),
              ),

            /// 텍스트 영역 (primary, secondary)
            /// Text area (primary, secondary)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Primary 텍스트 (주요 텍스트)
                    /// Primary text
                    if (banner.primary.isNotEmpty)
                      Text(
                        banner.primary,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    /// Secondary 텍스트 (부가 텍스트)
                    /// Secondary text
                    if (banner.secondary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        banner.secondary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
