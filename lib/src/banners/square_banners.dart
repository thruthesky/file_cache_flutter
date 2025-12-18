import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// Square 배너 위젯 (사각 배너)
/// Square Banners Widget
///
/// 게시판 목록 상단이나 사이드바에 표시되는 사각형 광고 배너입니다.
/// 권장 크기: 300x300
///
/// [postIdOrCategory]: 게시판/카테고리 ID (옵션)
/// - null인 경우: 전체 페이지 배너 표시 (all_page='y')
/// - 지정된 경우: 해당 카테고리 배너 + 전체 페이지 배너 표시
///
/// [onTap]: 배너 클릭 시 호출되는 콜백 (필수)
/// - 배너의 링크 URL을 파라미터로 전달받습니다.
/// - 외부 링크 열기, 내부 라우팅 등을 처리할 수 있습니다.
///
/// ### 사용법 (Usage):
/// ```dart
/// SquareBanners(
///   postIdOrCategory: 'freetalk',
///   onTap: (link) => openBannerUrl(context, link),
/// )
/// ```
class SquareBanners extends StatefulWidget {
  /// 게시판/카테고리 ID (옵션)
  /// Post ID or Category (optional)
  final String? postIdOrCategory;

  /// 배너 클릭 시 호출되는 콜백 (Banner tap callback)
  ///
  /// 배너의 링크 URL을 파라미터로 전달받습니다.
  /// Receives banner link URL as parameter.
  final void Function(String link) onTap;

  /// 배너 주변 패딩 (Banner padding)
  /// Optional padding around the banners
  final EdgeInsetsGeometry padding;

  const SquareBanners({
    super.key,
    this.postIdOrCategory,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(0, 8, 0, 0),
  });

  @override
  State<SquareBanners> createState() => _SquareBannersState();
}

class _SquareBannersState extends State<SquareBanners> {
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
    final result = await BannerApi.getSquareBanners(
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

    /// 4열 그리드로 배너 표시 (1줄에 4개씩)
    /// Display banners in 4-column grid (4 per row)
    return GridView.builder(
      padding: widget.padding,

      /// 스크롤 비활성화 (부모 스크롤뷰 사용)
      /// Disable scroll (uses parent scroll view)
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      /// 그리드 레이아웃 설정
      /// Grid layout configuration
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        // crossAxisSpacing: 8.0,
        // mainAxisSpacing: 8.0,

        /// 사각 배너 비율: 1:1
        /// Square banner aspect ratio: 1:1
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
      /// 배너 클릭 시 콜백 호출
      /// Call callback on banner tap
      onTap: () => widget.onTap(banner.link),
      child: ClipRRect(
        /// 모서리 둥글게 (flat design)
        /// Rounded corners (flat design)
        borderRadius: BorderRadius.circular(0),
        child: AspectRatio(
          /// 사각 배너는 1:1 비율 권장
          /// Square banners use 1:1 aspect ratio
          aspectRatio: 1.0,

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
        ),
      ),
    );
  }
}
