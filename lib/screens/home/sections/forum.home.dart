import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/widgets/empty.post.list.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/headers/forum_header.dart';
import 'package:philgo/widgets/headers/sub_category_list.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
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

  final GlobalKey<PostSimpleListViewState> listViewKey = GlobalKey();
  final GlobalKey<PostGridViewState> gridViewKey = GlobalKey();

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
    return Selector<NavigationState, Object?>(
      selector: (context, state) => state.data,
      builder: (context, data, child) {
        /// 딥링크로 전달된 카테고리 확인 및 적용
        /// Check and apply category from deeplink/navigation data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navData = data as Map<String, dynamic>?;
          final initialPostId = navData?['initialPostId'] as String?;

          // Only process if we have new data and haven't processed it yet
          if (initialPostId != null &&
              initialPostId != _lastProcessedInitialPostId) {
            debugLog('ForumHome: Processing initialPostId = $initialPostId');
            _lastProcessedInitialPostId = initialPostId;

            setState(() {
              _selectedPostId = initialPostId;
              _selectedCategory = null;
            });

            /// 데이터 사용 후 제거하여 다음 진입 시 영향 없도록 함
            /// Clear data after use to avoid affecting next entry
            NavigationState.of(context, listen: false).data = null;
          }
        });

        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ForumHeader(
          /// 현재 선택된 카테고리 전달 (UI 동기화)
          /// Pass currently selected category (UI sync)
          selectedPostId: _selectedPostId,

          /// 카테고리 선택 시 로컬 상태 업데이트
          /// Update local state when category selected
          onCategorySelected: (String postId) {
            /// 메인 카테고리만 선택 (서브 카테고리는 null)
            /// Select main category only (sub-category is null)
            _onCategoryChanged(postId, null);
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

        /// 서브 카테고리 목록 (Sub Category List)
        /// 선택된 메인 카테고리에 서브 카테고리가 있을 때만 표시
        /// Only show when selected main category has subcategories
        if (PhilgoCategory.hasSubCategories(_selectedPostId))
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: SubCategoryList(
              postId: _selectedPostId,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                /// 서브 카테고리 선택 시 로컬 상태 업데이트
                /// Update local state when subcategory selected
                _onCategoryChanged(_selectedPostId, category);
              },
            ),
          ),

        // Post List
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
    );
  }

  void onNewPostCreated(Post newPost) {
    // Refresh the appropriate view (list or grid) based on which one is currently active
    listViewKey.currentState?.pagingController.refresh();
    gridViewKey.currentState?.pagingController.refresh();
  }
}
