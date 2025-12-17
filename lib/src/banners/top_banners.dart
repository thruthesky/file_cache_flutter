import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// Top 배너 위젯
/// Top Banners Widget
///
/// 페이지 상단에 표시되는 광고 배너입니다.
/// 왼쪽/오른쪽 배너를 분리하여 9초마다 회전하며 표시합니다.
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
/// TopBanners(
///   postIdOrCategory: 'freetalk',
///   onTap: (link) => launchUrl(Uri.parse(link)),
/// )
/// ```
class TopBanners extends StatefulWidget {
  /// 게시판/카테고리 ID (옵션)
  /// Post ID or Category (optional)
  final String? postIdOrCategory;

  /// 배너 클릭 시 호출되는 콜백 (Banner tap callback)
  ///
  /// 배너의 링크 URL을 파라미터로 전달받습니다.
  /// Receives banner link URL as parameter.
  final void Function(String link) onTap;

  const TopBanners({
    super.key,
    this.postIdOrCategory,
    required this.onTap,
  });

  @override
  State<TopBanners> createState() => _TopBannersState();
}

class _TopBannersState extends State<TopBanners> {
  /// 왼쪽 배너 목록
  /// Left banner list
  List<BannerModel> leftBanners = [];

  /// 오른쪽 배너 목록
  /// Right banner list
  List<BannerModel> rightBanners = [];

  /// 현재 표시 중인 왼쪽 배너 인덱스
  /// Current left banner index
  int leftIndex = 0;

  /// 현재 표시 중인 오른쪽 배너 인덱스
  /// Current right banner index
  int rightIndex = 0;

  /// 배너 회전 타이머 (9초 간격)
  /// Banner rotation timer (9 second interval)
  Timer? _rotationTimer;

  /// 로딩 상태
  /// Loading state
  bool isLoading = true;

  /// 배너 회전 주기 (9초)
  /// Banner rotation interval (9 seconds)
  static const _rotationDuration = Duration(seconds: 9);

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    /// 타이머 해제 (메모리 누수 방지)
    /// Cancel timer to prevent memory leak
    _rotationTimer?.cancel();
    super.dispose();
  }

  /// 배너 로드
  /// Load banners from API
  Future<void> _loadBanners() async {
    final result = await BannerApi.getTopBanners(
      category: widget.postIdOrCategory,
    );

    if (mounted) {
      setState(() {
        /// 왼쪽/오른쪽 배너 분리 저장
        /// Store left/right banners separately
        leftBanners = result['left'] ?? [];
        rightBanners = result['right'] ?? [];
        isLoading = false;
      });

      /// 배너가 2개 이상인 경우에만 회전 타이머 시작
      /// Start rotation timer only if there are 2+ banners on either side
      if (leftBanners.length > 1 || rightBanners.length > 1) {
        _startRotationTimer();
      }
    }
  }

  /// 배너 회전 타이머 시작
  /// Start banner rotation timer
  void _startRotationTimer() {
    _rotationTimer = Timer.periodic(_rotationDuration, (_) {
      if (mounted) {
        setState(() {
          /// 왼쪽 배너 인덱스 순환 (0 -> 1 -> 2 -> 0 -> ...)
          /// Cycle left banner index
          if (leftBanners.length > 1) {
            leftIndex = (leftIndex + 1) % leftBanners.length;
          }

          /// 오른쪽 배너 인덱스 순환 (0 -> 1 -> 2 -> 0 -> ...)
          /// Cycle right banner index
          if (rightBanners.length > 1) {
            rightIndex = (rightIndex + 1) % rightBanners.length;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 로딩 중에는 빈 위젯 반환
    /// Return empty widget while loading
    if (isLoading) return const SizedBox.shrink();

    /// 양쪽 모두 배너가 없으면 빈 위젯 반환
    /// Return empty widget if no banners on both sides
    if (leftBanners.isEmpty && rightBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    /// Row로 왼쪽/오른쪽 배너 분리 표시
    /// Display left/right banners separately using Row
    return Row(
      children: [
        /// 왼쪽 배너 영역
        /// Left banner area
        if (leftBanners.isNotEmpty)
          Expanded(child: _buildAnimatedBanner(leftBanners, leftIndex)),

        /// 양쪽 모두 배너가 있을 때만 간격 추가
        /// Add spacing only when both sides have banners
        if (leftBanners.isNotEmpty && rightBanners.isNotEmpty)
          const SizedBox(width: 8),

        /// 오른쪽 배너 영역
        /// Right banner area
        if (rightBanners.isNotEmpty)
          Expanded(child: _buildAnimatedBanner(rightBanners, rightIndex)),
      ],
    );
  }

  /// 애니메이션이 적용된 배너 빌드
  /// Build animated banner with fade transition
  Widget _buildAnimatedBanner(List<BannerModel> banners, int currentIndex) {
    final banner = banners[currentIndex];

    /// AnimatedSwitcher: 배너 전환 시 부드러운 페이드 애니메이션
    /// AnimatedSwitcher: Smooth fade animation on banner change
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),

      /// 페이드 전환 효과
      /// Fade transition effect
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },

      /// key를 배너 ID로 설정하여 배너 변경 감지
      /// Set key to banner ID to detect banner changes
      child: _buildBannerItem(banner, key: ValueKey(banner.idx)),
    );
  }

  /// 개별 배너 아이템 빌드
  /// Build individual banner item
  Widget _buildBannerItem(BannerModel banner, {Key? key}) {
    return InkWell(
      key: key,

      /// 배너 클릭 시 외부 링크 열기
      /// Open external link on banner tap
      onTap: () => widget.onTap(banner.link),

      /// AspectRatio: 배너 비율 유지 (3:1 가로형)
      /// AspectRatio: Maintain banner ratio (3:1 landscape)
      child: AspectRatio(
        aspectRatio: 3.0,

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
    );
  }
}
