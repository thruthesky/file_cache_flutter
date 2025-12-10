import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/widgets/empty.post.list.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/headers/forum_header.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:philgo/widgets/post/post.card.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:provider/provider.dart';

/// 게시판 홈 화면 (Forum Home Screen)
///
/// 로컬 상태로 현재 선택된 카테고리를 관리합니다.
/// Manages currently selected category with local state.
///
/// 딥링크 처리:
/// - NavigationState.data에 'initialPostId' 키로 postId가 전달되면
/// - 해당 카테고리로 초기화됩니다.
class ForumHome extends StatefulWidget {
  const ForumHome({super.key});

  @override
  State<ForumHome> createState() => _ForumHomeState();
}

class _ForumHomeState extends State<ForumHome> {
  /// 현재 선택된 메인 카테고리 ID (로컬 상태)
  /// Currently selected main category ID (local state)
  late String _selectedPostId;

  /// 현재 선택된 서브 카테고리 (로컬 상태)
  /// Currently selected sub category (local state)
  String? _selectedCategory;

  /// 마지막으로 처리한 initialPostId를 추적
  /// Track last processed initialPostId to avoid duplicate processing
  String? _lastProcessedInitialPostId;

  /// TODO: Very bad. Use controller pattern instead of global keys.
  final GlobalKey<PostSimpleListViewState> listViewKey = GlobalKey();

  /// TODO: Very bad. Use controller pattern instead of global keys.
  final GlobalKey<PostMasonryViewState> gridViewKey = GlobalKey();

  /// 헤더 표시 여부 (스크롤에 따라 변경)
  /// Whether to show header (changes based on scroll)
  bool _showHeader = true;

  /// 마지막 스크롤 위치 (스크롤 방향 감지용)
  /// Last scroll position (for detecting scroll direction)
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();

    /// 기본값: 첫 번째 메인 카테고리
    /// Default: first major category
    _selectedPostId = PhilgoCategory.majorCategories(
      includeTemp: kDebugMode,
    ).first;
    _selectedCategory = null;
  }

  /// 카테고리 변경 핸들러
  /// Category change handler
  void _onCategoryChanged(String postId, String? category) {
    if (_selectedPostId == postId && _selectedCategory == category) {
      return;
    }

    setState(() {
      _selectedPostId = postId;
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Selector를 사용하여 NavigationState.data 변경사항을 감지
    /// Use Selector to listen to NavigationState.data changes
    /// This is crucial for IndexedStack where widgets are always mounted
    return Selector<NavigationState, Object?>(
      selector: (context, state) => state.data,
      builder: (context, data, child) {
        /// initialPostId 처리 - 빌더 내에서 동기적으로 처리
        /// Process initialPostId synchronously within builder
        /// This ensures the correct category is shown from the first frame
        final navData = data as Map<String, dynamic>?;
        final initialPostId = navData?['initialPostId'] as String?;

        /// 새로운 initialPostId가 있고 아직 처리하지 않은 경우
        /// Only process if we have new initialPostId that hasn't been processed yet
        if (initialPostId != null &&
            initialPostId != _lastProcessedInitialPostId) {
          debugLog('ForumHome: Processing initialPostId = $initialPostId');
          _lastProcessedInitialPostId = initialPostId;

          /// 로컬 상태 변수를 직접 업데이트 (빌드 중이므로 setState 사용 안 함)
          /// Update local state variables directly (can't use setState during build)
          _selectedPostId = initialPostId;
          _selectedCategory = null;

          /// 데이터 사용 후 제거 (다음 네비게이션에 영향 없도록)
          /// Clear data after use to avoid affecting next navigation
          /// Schedule this for after build to avoid modifying state during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NavigationState.of(context, listen: false).data = null;
          });
        }

        return _buildContent(context);
      },
    );
  }

  /// 스크롤 알림 처리 - 스크롤 방향에 따라 헤더 표시/숨김
  /// Handle scroll notification - show/hide header based on scroll direction
  bool _handleScrollNotification(ScrollNotification notification) {
    /// ScrollUpdateNotification만 처리 (실제 스크롤 이벤트)
    /// Only handle ScrollUpdateNotification (actual scroll events)
    if (notification is ScrollUpdateNotification) {
      final currentOffset = notification.metrics.pixels;

      /// 스크롤 델타값으로 방향 판단 (더 정확함)
      /// Determine direction by scroll delta (more accurate)
      final delta = notification.scrollDelta ?? 0;

      /// 스크롤 업 (위로 스와이프, 컨텐츠가 아래로 이동) - 헤더 숨기기
      /// Scroll up (swipe up, content moves down) - hide header
      if (delta > 0 && currentOffset > 50) {
        if (_showHeader) {
          setState(() => _showHeader = false);
        }
      }
      /// 스크롤 다운 (아래로 스와이프, 컨텐츠가 위로 이동) - 헤더 표시
      /// Scroll down (swipe down, content moves up) - show header
      else if (delta < 0) {
        if (!_showHeader) {
          setState(() => _showHeader = true);
        }
      }

      _lastScrollOffset = currentOffset;
    }

    /// false 반환: 알림을 계속 전파
    /// Return false: continue propagating notification
    return false;
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// NotificationListener로 스크롤 이벤트 감지
    /// Detect scroll events with NotificationListener
    ///
    /// 스크롤 업 (위로 스와이프): 헤더가 스르륵 위로 숨겨짐
    /// 스크롤 다운 (아래로 스와이프): 헤더가 즉시 스르륵 나타남
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ClipRect + AnimatedAlign으로 헤더 숨기기/표시 애니메이션
          /// Header hide/show animation with ClipRect + AnimatedAlign
          ///
          /// ClipRect: 헤더가 위로 올라갈 때 넘치는 부분 잘라냄
          /// ClipRect: clips overflow when header moves up
          ///
          /// AnimatedAlign(heightFactor): 높이를 0~1 사이로 애니메이션
          /// AnimatedAlign(heightFactor): animates height between 0~1
          ClipRect(
            child: AnimatedAlign(
              /// 상단 정렬 (헤더가 위에서부터 사라짐)
              /// Top alignment (header disappears from top)
              alignment: Alignment.topCenter,

              /// 숨김 시 높이를 0으로, 표시 시 원래 높이로
              /// Height 0 when hidden, original height when shown
              heightFactor: _showHeader ? 1.0 : 0.0,

              /// 부드러운 애니메이션 (200ms)
              /// Smooth animation (200ms)
              duration: const Duration(milliseconds: 200),

              /// 자연스러운 커브
              /// Natural curve
              curve: Curves.easeInOut,

              child: Container(
                /// 하단 테두리 (Comic design)
                /// Bottom border (Comic design)
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: scheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                ),

                child: ForumHeader(
                  /// 현재 선택된 메인 카테고리 전달 (UI 동기화)
                  /// Pass currently selected main category (UI sync)
                  selectedPostId: _selectedPostId,

                  /// 현재 선택된 서브 카테고리 전달 (UI 동기화)
                  /// Pass currently selected subcategory (UI sync)
                  selectedCategory: _selectedCategory,

                  /// 카테고리 선택 시 로컬 상태 업데이트 (메인 + 서브 카테고리)
                  /// Update local state when category selected (main + subcategory)
                  onCategorySelected: (String postId, String? category) {
                    _onCategoryChanged(postId, category);
                  },

                  /// 글쓰기 버튼 클릭 시 현재 선택된 카테고리로 글쓰기 다이얼로그 표시
                  /// Show post create dialog with currently selected category
                  onCreatePost: () {
                    showPostCreateDialog(
                      context,
                      postId: _selectedPostId,
                      category: _selectedCategory,
                      onSubmitted: (post) {
                        /// 글 생성 후 목록 새로고침
                        /// Refresh list after post creation
                        listViewKey.currentState?.pagingController.refresh();
                        gridViewKey.currentState?.pagingController.refresh();
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          /// 본문: PostListView (게시글 목록)
          /// Body: PostListView (post list)
          Expanded(
            child: PostListView(
              /// buyandsell 카테고리는 그리드 레이아웃 사용
              /// Use grid layout for buyandsell category
              listViewKey: _selectedPostId != 'buyandsell' ? listViewKey : null,
              gridViewKey: _selectedPostId == 'buyandsell' ? gridViewKey : null,
              postId: _selectedPostId,
              category: _selectedCategory,

              /// Hero 트랜지션 항상 활성화
              /// Forum 탭에서만 PostListTile 사용되므로 충돌 없음
              /// Always enable Hero transition
              /// No conflict since PostListTile is only used in Forum tab
              enableHeroTransition: true,

              /// Use PostCard with 2-column masonry grid for all Buy & Sell categories
              /// Including main category and subcategories (hotel, 렌트카)
              /// Masonry layout is automatically used when gridColumns > 1
              gridColumns: _selectedPostId == 'buyandsell' ? 2 : null,
              tileBuilder: _selectedPostId == 'buyandsell'
                  ? (post, onTap) => PostCard(post: post, onTap: onTap)
                  : null,

              /// 게시물 탭 시 PostViewScreen으로 네비게이션하는 콜백 함수 제공
              /// Navigate to PostViewScreen when post is tapped
              onTap: (post) async {
                await PostViewScreen.push(context, post);

                /// setState를 호출하여 UI 업데이트
                /// PostListView가 다시 빌드되면서 수정된 내용이 화면에 반영됨
                if (mounted) {
                  setState(() {});
                }
              },

              noItemsFoundIndicatorBuilder: (context) {
                return const Center(child: EmptyPostList());
              },
            ),
          ),
        ],
      ),
    );
  }

  void onNewPostCreated(Post newPost) {
    // Refresh the appropriate view (list or grid) based on which one is currently active
    listViewKey.currentState?.pagingController.refresh();
    gridViewKey.currentState?.pagingController.refresh();
  }
}
