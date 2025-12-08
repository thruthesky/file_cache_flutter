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

    /// 화면 너비를 기준으로 아이템 크기 계산
    /// Calculate item size based on screen width
    final screenWidth = MediaQuery.sizeOf(context).width;

    /// 4개 아이템이 보이도록 itemExtent 계산 (간격 포함)
    /// Calculate itemExtent for 4 visible items (including spacing)
    final itemExtent = screenWidth / 4;

    /// CarouselView.weighted로 배너 표시 (가장자리 아이템 작게)
    /// Display banners with CarouselView.weighted (smaller edge items)
    return SizedBox(
      /// 정사각형 아이템 높이 설정
      /// Set height for square items
      height: itemExtent,
      child: CarouselView.weighted(
        /// 가중치 배열: 가장자리(3) < 중앙(4)
        /// Weight array: edge(3) < center(4)
        flexWeights: const <int>[4, 4, 4, 3],

        /// 아이템 모서리 없음 (직사각형)
        /// No rounded corners (rectangle)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),

        /// 아이템 간 간격
        /// Spacing between items
        padding: const EdgeInsets.symmetric(horizontal: 4),

        /// 배너 아이템 목록
        /// Banner item list
        children: banners.map((banner) => _buildBannerItem(banner)).toList(),
      ),
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
        /// 이미지 모서리 둥글게 (8px)
        /// Rounded corners for image (8px)
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: banner.url,
          width: double.infinity,
          height: double.infinity,

          /// 이미지가 컨테이너를 꽉 채우도록 cover 사용 (ClipRRect 효과 적용)
          /// Use cover to fill container (enables ClipRRect effect)
          fit: BoxFit.cover,

          /// 이미지 로드 실패 시 빈 위젯
          /// Return empty widget on image load error
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
