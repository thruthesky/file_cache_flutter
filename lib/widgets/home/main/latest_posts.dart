import 'dart:async';

import 'package:flutter/material.dart';
import 'package:philgo/widgets/home/main/carousel_dot_indicator.dart';
import 'package:philgo/widgets/home/home_post_section.dart';

/// 게시판 설정 데이터 클래스 (Post Section Configuration)
///
/// 각 게시판의 ID와 카테고리 정보를 담는 데이터 클래스입니다.
/// Data class containing board ID and category information.
class _PostSectionConfig {
  /// 게시판 ID (예: 'freetalk', 'qna')
  /// Board ID (e.g., 'freetalk', 'qna')
  final String postId;

  /// 서브 카테고리 (옵션)
  /// Sub-category (optional)
  final String? category;

  const _PostSectionConfig({required this.postId, this.category});
}

/// 홈 화면 최근 게시글 섹션 위젯 (Home Latest Posts Section Widget)
///
/// CarouselView를 사용하여 게시판 섹션들을 슬라이딩 방식으로 표시합니다.
/// 한 카로셀 아이템에 2개의 HomePostSection이 표시됩니다.
///
/// Displays board sections using CarouselView with sliding navigation.
/// Each carousel item shows 2 HomePostSection widgets side by side.
///
/// ### Parameters:
/// - [limit] → 각 게시판에 표시할 게시글 수 (기본값: 4)
///   Number of posts to display per board (default: 4)
///
/// ### Example:
/// ```dart
/// LatestPostsSection(
///   limit: 4,
/// )
/// ```
class LatestPostsSection extends StatefulWidget {
  const LatestPostsSection({super.key});

  @override
  State<LatestPostsSection> createState() => _LatestPostsSectionState();
}

class _LatestPostsSectionState extends State<LatestPostsSection> {
  /// 카로셀 컨트롤러 (Carousel Controller)
  /// 스크롤 및 아이템 이동 제어용
  final CarouselController _controller = CarouselController();

  /// 현재 선택된 카로셀 인덱스 (Current selected carousel index)
  /// dot indicator와 동기화됨
  int _currentIndex = 0;

  /// 자동 슬라이딩 타이머 (Auto-slide timer)
  /// 5초마다 다음 아이템으로 자동 이동
  Timer? _autoSlideTimer;

  /// 자동 슬라이딩 간격 (Auto-slide interval)
  static const Duration _autoSlideDuration = Duration(seconds: 5);

  /// 게시판 목록 (2개씩 쌍으로 구성) (Board pairs configuration)
  ///
  /// 각 카로셀 아이템에 표시될 게시판 쌍을 정의합니다.
  /// Defines board pairs to be displayed in each carousel item.
  ///
  /// - 아이템 1: 자유게시판 + 질문과 답변
  /// - 아이템 2: 사고팔고 + 구인구직
  /// - 아이템 3: 골프 + 맛집
  /// - 아이템 4: 부동산 (단독)
  static const List<List<_PostSectionConfig>> _sectionPairs = [
    /// 자유게시판 + 질문과 답변 (Freetalk + QnA)
    [_PostSectionConfig(postId: 'freetalk'), _PostSectionConfig(postId: 'qna')],

    /// 사고팔고 + 구인구직 (Buy&Sell + Wanted)
    [
      _PostSectionConfig(postId: 'buyandsell'),
      _PostSectionConfig(postId: 'wanted'),
    ],

    ///
    [
      _PostSectionConfig(postId: 'travel'),
      _PostSectionConfig(postId: 'buyandsell', category: '골프'),
    ],

    ///
    [
      _PostSectionConfig(postId: 'rest'),
      _PostSectionConfig(postId: 'buyandsell', category: 'real_estate'),
    ],
  ];

  @override
  void initState() {
    super.initState();

    /// 카로셀 스크롤 리스너 추가 (Add carousel scroll listener)
    /// 스크롤 위치에 따라 현재 인덱스 업데이트
    _controller.addListener(_onScrollChanged);

    /// 자동 슬라이딩 타이머 시작 (Start auto-slide timer)
    _startAutoSlideTimer();
  }

  @override
  void dispose() {
    /// 자동 슬라이딩 타이머 취소 (Cancel auto-slide timer)
    _autoSlideTimer?.cancel();

    /// 리스너 제거 (Remove listener)
    _controller.removeListener(_onScrollChanged);

    /// 카로셀 컨트롤러 해제 (Dispose carousel controller)
    _controller.dispose();
    super.dispose();
  }

  /// 자동 슬라이딩 타이머 시작 (Start auto-slide timer)
  ///
  /// 5초마다 다음 아이템으로 자동 이동합니다.
  /// 마지막 아이템에서는 처음으로 돌아갑니다.
  void _startAutoSlideTimer() {
    _autoSlideTimer = Timer.periodic(_autoSlideDuration, (_) {
      if (!mounted) return;

      /// 다음 인덱스 계산 (마지막이면 0으로 돌아감)
      /// Calculate next index (wrap to 0 at the end)
      final nextIndex = (_currentIndex + 1) % _sectionPairs.length;
      final screenWidth = MediaQuery.sizeOf(context).width;

      _animateToIndex(nextIndex, screenWidth);
    });
  }

  /// 자동 슬라이딩 타이머 중지 (Stop auto-slide timer)
  ///
  /// 사용자가 카로셀과 인터랙션(탭, 스와이프 등)할 때 호출됩니다.
  /// 타이머를 완전히 중지하고 다시 시작하지 않습니다.
  void _stopAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  /// 스크롤 변경 시 현재 인덱스 업데이트 (Update current index on scroll change)
  ///
  /// offset을 itemExtent(화면 너비)로 나누어 현재 인덱스 계산
  void _onScrollChanged() {
    if (!_controller.hasClients) return;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final offset = _controller.offset;

    /// 현재 인덱스 계산 (반올림하여 가장 가까운 아이템 선택)
    /// Calculate current index (round to nearest item)
    final newIndex = (offset / screenWidth).round().clamp(
      0,
      _sectionPairs.length - 1,
    );

    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// 화면 너비 기준으로 아이템 크기 계산
    /// Calculate item size based on screen width
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 카로셀 뷰 (Carousel View)
        /// Listener로 감싸서 사용자 터치(스와이프) 감지
        /// Wrapped with Listener to detect user touch (swipe)
        Listener(
          /// 사용자가 터치를 시작하면 자동 슬라이딩 중지
          /// Stop auto-slide when user starts touching
          onPointerDown: (_) => _stopAutoSlideTimer(),
          child: SizedBox(
            /// 카로셀 높이 설정 (게시글 4개 + 헤더 표시 가능한 높이)
            /// Carousel height (enough for 4 posts + header)
            height: 164,
            child: CarouselView(
              enableSplash: false,
              controller: _controller,

              /// 각 아이템이 화면 전체 너비 차지 (왼쪽 여백 제거)
              /// Each item takes full screen width (removes left margin)
              itemExtent: screenWidth,

              /// edge 아이템의 최소 크기 (85%)
              /// Minimum size for edge items (85%)
              shrinkExtent: screenWidth * 0.85,

              /// 스냅 효과 활성화 (아이템에 딱 맞게 정렬)
              /// Enable snap effect (align to item boundaries)
              itemSnapping: true,

              /// 패딩 제거 (왼쪽 가장자리에 붙이기 위해)
              /// Remove padding (to align to left edge)
              padding: EdgeInsets.zero,

              /// 카로셀 아이템 생성
              /// Generate carousel items
              children: _sectionPairs.map((pair) {
                return _buildCarouselItem(pair);
              }).toList(),
            ),
          ),
        ),

        /// 네비게이션 Dot Indicator (Navigation Dot Indicator)
        /// 현재 페이지를 표시하고 클릭 시 해당 페이지로 이동
        const SizedBox(height: 8),
        CarouselDotIndicator(
          itemCount: _sectionPairs.length,
          currentIndex: _currentIndex,
          onDotTap: (index) {
            _animateToIndex(index, screenWidth);
            _stopAutoSlideTimer();
          },
        ),
      ],
    );
  }

  /// 특정 인덱스로 카로셀 애니메이션 이동 (Animate carousel to specific index)
  ///
  /// [index] → 이동할 카로셀 인덱스
  /// [screenWidth] → 화면 너비 (offset 계산용)
  void _animateToIndex(int index, double screenWidth) {
    final targetOffset = index * screenWidth;

    _controller.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 카로셀 아이템 빌드 (Build Carousel Item)
  ///
  /// 2개의 HomePostSection을 Row로 배치하여 하나의 카로셀 아이템을 구성합니다.
  /// Creates a carousel item with 2 HomePostSection widgets arranged in a Row.
  ///
  /// [configs] → 표시할 게시판 설정 목록 (1개 또는 2개)
  ///             List of board configurations to display (1 or 2)
  Widget _buildCarouselItem(List<_PostSectionConfig> configs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: configs.map((config) {
        return Expanded(
          child: HomePostSection(
            postId: config.postId,
            category: config.category,
          ),
        );
      }).toList(),
    );
  }
}
