import 'dart:async';

import 'package:flutter/material.dart';
import 'package:philgo/widgets/home/home_post_section_shimmer.dart';
import 'package:philgo/widgets/home/main/carousel_dot_indicator.dart';
import 'package:philgo/widgets/home/home_post_section.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo_api/philgo_api.dart';

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

  /// API 호출용 카테고리 키 생성 (API category key generator)
  ///
  /// get_latest_posts API의 카테고리 형식에 맞게 키를 생성합니다.
  /// - postId만 있는 경우: 'postId' (예: 'freetalk')
  /// - category가 있는 경우: 'postId/category' (예: 'buyandsell/골프')
  String get categoryKey => category != null ? '$postId/$category' : postId;
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
  static const Duration _autoSlideDuration = Duration(seconds: 7);

  /// 모든 카테고리의 게시글 데이터 (All categories post data)
  ///
  /// get_latest_posts API로 한 번에 fetch한 데이터를 저장합니다.
  /// 키: 카테고리 키 (예: 'freetalk', 'buyandsell/골프')
  /// 값: 해당 카테고리의 Post 목록
  Map<String, List<Post>>? _postsData;

  /// NavigationState 참조 (Provider reference)
  /// didChangeDependencies에서 한 번만 등록하고, dispose에서 제거합니다.
  NavigationState? _navigationState;

  /// NavigationState 변화 감지 리스너 (Navigation change listener)
  /// 다른 탭에서 홈으로 돌아올 때 _loadAllPosts()를 호출합니다.
  VoidCallback? _navigationListener;

  /// 이전 homeNav 값 추적 (Previous homeNav value tracking)
  /// 다른 탭에서 홈으로 전환된 것인지 판별하는데 사용합니다.
  /// 이미 홈인 상태에서 홈 탭을 다시 클릭하면 새로고침하지 않습니다.
  HomeNavigationItem? _lastKnownHomeNav;

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

    /// 모든 카테고리의 게시글 데이터를 한 번에 로드 (Load all categories posts at once)
    _loadAllPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// 첫 호출 시에만 NavigationState에 listener 등록 (Register listener only on first call)
    /// IndexedStack 구조에서 위젯이 dispose되지 않으므로,
    /// NavigationState의 homeNav 변화를 감지하여 다른 탭에서 홈으로 돌아올 때
    /// _loadAllPosts()를 재호출합니다.
    if (_navigationState == null) {
      _navigationState = NavigationState.of(context, listen: false);
      _lastKnownHomeNav = _navigationState!.homeNav;

      _navigationListener = () {
        final currentHomeNav = _navigationState!.homeNav;

        /// homeNav가 다른 값에서 home으로 변경된 경우에만 데이터 새로고침
        /// Only refresh when homeNav changes from another tab to home
        if (currentHomeNav == HomeNavigationItem.home &&
            _lastKnownHomeNav != HomeNavigationItem.home &&
            mounted) {
          _loadAllPosts();
        }
        _lastKnownHomeNav = currentHomeNav;
      };

      _navigationState!.addListener(_navigationListener!);
    }
  }

  /// 모든 카테고리의 게시글 데이터를 한 번에 로드 (Load all categories posts at once)
  ///
  /// get_latest_posts API를 사용하여 모든 게시판/카테고리의 최신 글을
  /// 한 번의 API 호출로 가져옵니다.
  ///
  /// 기존 방식: 각 HomePostSection에서 개별 API 호출 (8회)
  /// 개선 방식: 부모에서 한 번만 API 호출 (1회) → 자식에게 데이터 전달
  Future<void> _loadAllPosts() async {
    try {
      /// 모든 카테고리 키 수집 (Collect all category keys)
      /// _sectionPairs에서 모든 config의 categoryKey를 추출
      final categories = _sectionPairs
          .expand((pair) => pair.map((config) => config.categoryKey))
          .toList();

      /// get_latest_posts API 호출 (한 번의 호출로 모든 데이터 fetch)
      /// API returns: {'freetalk': [...], 'qna': [...], 'buyandsell/골프': [...], ...}
      final result = await getLatestPosts(categories: categories, limit: 4);

      if (mounted) {
        setState(() {
          _postsData = result;
        });
      }
    } catch (e) {
      /// 에러 발생 시 _postsData는 null로 유지 (Keep _postsData null on error)
      /// HomePostSection이 자체적으로 데이터를 로드하도록 fallback
      debugLog('LatestPostsSection._loadAllPosts 에러: $e');
    }
  }

  @override
  void dispose() {
    /// NavigationState 리스너 제거 (Remove NavigationState listener)
    if (_navigationListener != null) {
      _navigationState?.removeListener(_navigationListener!);
    }

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
        /// LayoutBuilder ensures CarouselView gets valid constraints during orientation changes
        Listener(
          /// 사용자가 터치를 시작하면 자동 슬라이딩 중지
          /// Stop auto-slide when user starts touching
          onPointerDown: (_) => _stopAutoSlideTimer(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              /// Use the smaller of screenWidth or available width to handle orientation changes
              /// This prevents layout errors when switching to fullscreen
              final availableWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : screenWidth;
              final safeWidth = availableWidth > 0
                  ? availableWidth
                  : screenWidth;

              return SizedBox(
                /// 카로셀 높이 설정 (게시글 4개 + 헤더 표시 가능한 높이)
                /// Carousel height (enough for 4 posts + header)
                height: 164,
                child: CarouselView(
                  enableSplash: false,
                  controller: _controller,

                  /// 각 아이템이 화면 전체 너비 차지 (왼쪽 여백 제거)
                  /// Each item takes full screen width (removes left margin)
                  itemExtent: safeWidth,

                  /// edge 아이템의 최소 크기 (85%)
                  /// Minimum size for edge items (85%)
                  shrinkExtent: safeWidth * 0.85,

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
              );
            },
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
  ///
  /// 부모에서 fetch한 데이터(_postsData)가 있으면 HomePostSection에 전달하여
  /// 개별 API 호출을 방지합니다. (Prevent individual API calls by passing pre-fetched data)
  ///
  /// posts가 null인 경우 shimmer 로딩 효과를 표시합니다.
  Widget _buildCarouselItem(List<_PostSectionConfig> configs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: configs.map((config) {
        /// 해당 카테고리의 게시글 데이터 추출 (Extract posts for this category)
        final posts = _postsData?[config.categoryKey];

        /// posts가 null이면 shimmer 로딩 효과 표시 (Show shimmer loading when posts is null)
        /// HomePostSectionShimmer 공용 위젯 사용
        if (posts == null) {
          return Expanded(
            child: HomePostSectionShimmer(
              postId: config.postId,
              category: config.category,
            ),
          );
        }

        return Expanded(
          child: HomePostSection(
            postId: config.postId,
            category: config.category,
            posts: posts,
          ),
        );
      }).toList(),
    );
  }
}
