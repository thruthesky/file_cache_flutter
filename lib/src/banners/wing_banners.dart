import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wing 배너 위젯
/// Wing Banners Widget
///
/// 화면 사이드에 표시되는 윙 광고 배너입니다.
/// 모바일에서는 left/right를 합쳐서 수직으로 표시합니다.
///
/// [postIdOrCategory]: 게시판/카테고리 ID (옵션)
/// - null인 경우: 전체 페이지 배너 표시 (all_page='y')
/// - 지정된 경우: 해당 카테고리 배너 + 전체 페이지 배너 표시
class WingBanners extends StatefulWidget {
  /// 게시판/카테고리 ID (옵션)
  /// Post ID or Category (optional)
  final String? postIdOrCategory;

  const WingBanners({super.key, this.postIdOrCategory});

  @override
  State<WingBanners> createState() => _WingBannersState();
}

class _WingBannersState extends State<WingBanners> {
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
    final result = await BannerApi.getWingBanners(
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

    /// 4열 그리드로 배너 표시 (1줄에 4개씩)
    /// Display banners in 4-column grid (4 per row)
    return GridView.builder(
      padding: EdgeInsets.zero,

      /// 스크롤 비활성화 (부모 스크롤뷰 사용)
      /// Disable scroll (uses parent scroll view)
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      /// 그리드 레이아웃 설정
      /// Grid layout configuration
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,

        /// Wing 배너 비율: 1:1 (정사각형)
        /// Wing banner aspect ratio: 1:1 (square)
        childAspectRatio: 1.0,
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
      child: ClipRRect(
        /// 모서리 둥글게 (flat design)
        /// Rounded corners (flat design)
        borderRadius: BorderRadius.circular(8),

        /// CachedNetworkImage: 이미지 캐싱으로 성능 향상
        /// CachedNetworkImage: Improved performance with image caching
        child: CachedNetworkImage(
          imageUrl: banner.url,
          width: double.infinity,

          /// Wing 배너는 다양한 aspect ratio 대응을 위해 contain 사용
          /// Use contain for wing banners to handle various aspect ratios
          fit: BoxFit.contain,

          /// 이미지 로드 실패 시 빈 위젯
          /// Return empty widget on image load error
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
