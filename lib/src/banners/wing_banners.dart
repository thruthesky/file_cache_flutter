import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wing 배너 위젯
/// Wing Banners Widget
///
/// 화면 사이드에 표시되는 윙 광고 배너입니다.
/// 배너 4개를 2x2 그리드 형태의 1세트로 묶어서 카로셀로 표시합니다.
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

  /// 배너 세트 목록 (4개씩 묶음)
  /// Banner sets list (grouped by 4)
  List<List<BannerModel>> bannerSets = [];

  /// 로딩 상태
  /// Loading state
  bool isLoading = true;

  /// 카로셀 컨트롤러
  /// Carousel controller for auto-scroll
  CarouselController? _carouselController;

  /// 자동 회전 타이머
  /// Timer for auto-rotation
  Timer? _autoScrollTimer;

  /// 현재 세트 인덱스
  /// Current set index
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    /// 타이머 취소
    /// Cancel timer
    _autoScrollTimer?.cancel();

    /// 컨트롤러 해제
    /// Dispose controller
    _carouselController?.dispose();
    super.dispose();
  }

  /// 배너 목록을 4개씩 묶어서 세트 리스트로 변환
  /// Convert banner list into sets of 4 banners each
  ///
  /// 예시 (Example):
  /// [1,2,3,4,5,6,7,8,9] -> [[1,2,3,4], [5,6,7,8], [9]]
  ///
  /// 마지막 세트가 4개 미만인 경우에도 그대로 유지 (빈 공간으로 표시)
  /// If the last set has fewer than 4 banners, keep it as is (show empty spaces)
  List<List<BannerModel>> _createBannerSets(List<BannerModel> banners) {
    final List<List<BannerModel>> sets = [];
    for (int i = 0; i < banners.length; i += 4) {
      final end = (i + 4 > banners.length) ? banners.length : i + 4;
      sets.add(banners.sublist(i, end));
    }
    return sets;
  }

  /// 자동 회전 타이머 시작
  /// Start auto-scroll timer
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (bannerSets.isEmpty || _carouselController == null) return;

      /// 다음 세트 인덱스로 이동
      /// Move to next set index
      _currentIndex = _currentIndex + 1;

      /// 마지막 세트에 도달하면 0으로 리셋
      /// Reset to 0 when reaching the last set
      if (_currentIndex >= bannerSets.length - 1) {
        _currentIndex = 0;
      }

      _carouselController!.animateToItem(_currentIndex);
    });
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

        /// 배너를 4개씩 세트로 묶기
        /// Group banners into sets of 4
        bannerSets = _createBannerSets(banners);

        isLoading = false;

        /// 컨트롤러 초기화 및 자동 회전 시작
        /// Initialize controller and start auto-scroll
        if (bannerSets.isNotEmpty) {
          _carouselController = CarouselController();
          _startAutoScroll();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 로딩 중에는 빈 위젯 반환
    /// Return empty widget while loading
    if (isLoading) return const SizedBox.shrink();

    /// 배너 세트가 없으면 빈 위젯 반환
    /// Return empty widget if no banner sets
    if (bannerSets.isEmpty) return const SizedBox.shrink();

    /// 화면 너비를 기준으로 세트 크기 계산
    /// Calculate set size based on screen width
    final screenWidth = MediaQuery.sizeOf(context).width;

    /// 한 화면에 2세트가 보이도록 설정
    /// 세트 너비 = 화면너비 / 2
    /// Set width = screenWidth / 2 for 2 sets per screen
    final setWidth = screenWidth / 2;

    /// 세트 높이 = 세트 너비 (정사각형 세트)
    /// Set height = set width (square set)
    final setHeight = setWidth;

    /// CarouselView로 배너 세트 표시
    /// Display banner sets with CarouselView
    return SizedBox(
      /// 세트 높이 설정
      /// Set height for the carousel
      height: setHeight,
      child: CarouselView(
        /// 카로셀 컨트롤러 (자동 회전용)
        /// Carousel controller for auto-scroll
        controller: _carouselController,

        /// 각 세트의 기본 크기 (화면의 절반)
        /// Default size for each set (half of screen width)
        itemExtent: setWidth,

        /// 가장자리 세트 크기 (다음 세트 일부가 살짝 보이도록)
        /// Edge set size (to show a glimpse of next set)
        shrinkExtent: setWidth * 0.85,

        /// 아이템 모서리 없음 (직사각형)
        /// No rounded corners (rectangle)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),

        /// 아이템 간 간격 없음 (배너가 붙어서 표시)
        /// No spacing between items (banners are displayed edge to edge)
        padding: EdgeInsets.zero,

        /// 배너 세트 목록
        /// Banner set list
        children: bannerSets
            .map((set) => _BannerSetGrid(bannerSet: set))
            .toList(),
      ),
    );
  }
}

/// 배너 4개를 2x2 그리드로 표시하는 위젯
/// Widget that displays up to 4 banners in a 2x2 grid layout
///
/// 그리드 레이아웃 (Grid layout):
/// [0][1]
/// [2][3]
///
/// 배너가 4개 미만인 경우 빈 공간으로 표시
/// If fewer than 4 banners, empty spaces are shown
class _BannerSetGrid extends StatelessWidget {
  /// 배너 세트 (최대 4개)
  /// Banner set (up to 4 banners)
  final List<BannerModel> bannerSet;

  const _BannerSetGrid({required this.bannerSet});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 상단 행: [0][1]
        /// Top row: [0][1]
        Expanded(
          child: Row(
            children: [
              /// 첫 번째 배너 (인덱스 0)
              /// First banner (index 0)
              Expanded(
                child: bannerSet.isNotEmpty
                    ? _buildBannerItem(bannerSet[0])
                    : const SizedBox.shrink(),
              ),

              /// 두 번째 배너 (인덱스 1)
              /// Second banner (index 1)
              Expanded(
                child: bannerSet.length > 1
                    ? _buildBannerItem(bannerSet[1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        /// 하단 행: [2][3]
        /// Bottom row: [2][3]
        Expanded(
          child: Row(
            children: [
              /// 세 번째 배너 (인덱스 2)
              /// Third banner (index 2)
              Expanded(
                child: bannerSet.length > 2
                    ? _buildBannerItem(bannerSet[2])
                    : const SizedBox.shrink(),
              ),

              /// 네 번째 배너 (인덱스 3)
              /// Fourth banner (index 3)
              Expanded(
                child: bannerSet.length > 3
                    ? _buildBannerItem(bannerSet[3])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
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
