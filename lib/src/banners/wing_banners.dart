import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_v6_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wing 배너 위젯
/// Wing Banners Widget
///
/// 화면에 표시되는 윙 광고 배너입니다.
/// 한 줄에 5개씩 GridView로 모든 배너를 나열합니다.
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

  /// 한 줄에 표시할 배너 개수
  /// Number of banners per row
  static const int crossAxisCount = 5;

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
        /// left와 right 배너를 합쳐서 저장
        /// Combine left and right banners
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

    /// 화면 너비를 기준으로 배너 크기 계산
    /// Calculate banner size based on screen width
    final screenWidth = MediaQuery.sizeOf(context).width;

    /// 배너 하나의 크기 (화면너비 / 5)
    /// Single banner size (screenWidth / 5)
    final bannerSize = screenWidth / crossAxisCount;

    /// 총 행 수 계산
    /// Calculate total number of rows
    final rowCount = (banners.length / crossAxisCount).ceil();

    /// GridView 높이 = 배너 크기 * 행 수
    /// GridView height = banner size * row count
    final gridHeight = bannerSize * rowCount;

    /// GridView로 배너 표시 (한 줄에 5개씩)
    /// Display banners with GridView (5 per row)
    return SizedBox(
      height: gridHeight,
      child: GridView.builder(
        padding: EdgeInsets.zero,

        /// 스크롤 비활성화 (부모 스크롤에 맡김)
        /// Disable scroll (let parent handle scrolling)
        physics: const NeverScrollableScrollPhysics(),

        /// 그리드 설정: 5열, 정사각형 아이템
        /// Grid configuration: 5 columns, square items
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.0,
        ),

        /// 배너 개수
        /// Number of banners
        itemCount: banners.length,

        /// 배너 아이템 빌더
        /// Banner item builder
        itemBuilder: (context, index) => _buildBannerItem(banners[index]),
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
      child: CachedNetworkImage(
        imageUrl: banner.url,
        width: double.infinity,
        height: double.infinity,

        /// 이미지가 컨테이너를 꽉 채우도록 cover 사용
        /// Use cover to fill container
        fit: BoxFit.cover,

        /// 이미지 로드 실패 시 빈 위젯
        /// Return empty widget on image load error
        errorWidget: (context, url, error) => const SizedBox.shrink(),
      ),
    );
  }
}
