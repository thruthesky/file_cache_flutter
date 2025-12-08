import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Top 배너 위젯
/// Top Banners Widget
///
/// 페이지 상단에 표시되는 광고 배너입니다.
/// API에서 left/right로 분리된 배너를 합쳐서 수직으로 표시합니다.
///
/// [postIdOrCategory]: 게시판/카테고리 ID (옵션)
/// - null인 경우: 전체 페이지 배너 표시 (all_page='y')
/// - 지정된 경우: 해당 카테고리 배너 + 전체 페이지 배너 표시
class TopBanners extends StatefulWidget {
  /// 게시판/카테고리 ID (옵션)
  /// Post ID or Category (optional)
  final String? postIdOrCategory;

  const TopBanners({super.key, this.postIdOrCategory});

  @override
  State<TopBanners> createState() => _TopBannersState();
}

class _TopBannersState extends State<TopBanners> {
  /// 배너 목록 (left + right 합친 것)
  /// Banner list (combined left + right)
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
    final result = await BannerApi.getTopBanners(
      category: widget.postIdOrCategory,
    );

    if (mounted) {
      setState(() {
        /// left와 right 배너를 합쳐서 수직으로 표시
        /// Combine left and right banners for vertical display
        banners = [...result['left']!, ...result['right']!];
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

    /// 2열 그리드로 배너 표시 (1줄에 2개씩)
    /// Display banners in 2-column grid (2 per row)
    return GridView.builder(
      padding: EdgeInsets.zero,

      /// 스크롤 비활성화 (부모 스크롤뷰 사용)
      /// Disable scroll (uses parent scroll view)
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      /// 그리드 레이아웃 설정
      /// Grid layout configuration
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,

        /// Top 배너 비율: 가로형 (2:1)
        /// Top banner aspect ratio: landscape (2:1)
        childAspectRatio: 3.0,
      ),
      itemCount: banners.length,
      itemBuilder: (context, index) => _buildBannerItem(banners[index]),
    );
  }

  /// 개별 배너 아이템 빌드
  /// Build individual banner item
  Widget _buildBannerItem(BannerModel banner) {
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

      /// CachedNetworkImage: 이미지 캐싱으로 성능 향상
      /// CachedNetworkImage: Improved performance with image caching
      child: CachedNetworkImage(
        imageUrl: banner.url,
        width: double.infinity,
        fit: BoxFit.cover,

        /// 이미지 로드 실패 시 빈 위젯
        /// Return empty widget on image load error
        errorWidget: (context, url, error) => const SizedBox.shrink(),
      ),
    );
  }
}
