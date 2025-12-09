import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/headers/app_header.dart';
import 'package:philgo/widgets/home/home_photo_grid_section.dart';
import 'package:philgo/widgets/home/home_popular_post_section.dart';
import 'package:philgo/widgets/home/home_post_section.dart';
import 'package:philgo/widgets/layout/content_container.dart';
import 'package:philgo/widgets/logo/logo.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 메인 홈 화면 (Main Home Screen)
///
/// Composition:
/// - AppBar: User avatar + Settings button
/// - Latest 3 posts and 3 comments in side-by-side 2-column layout
/// - 2x2 Advertisement grid at the bottom
///
/// 구성:
/// - 앱바: 사용자 아바타 + 설정 버튼
/// - 최근 게시글 3개 + 최근 댓글 3개 (좌우 2단 레이아웃)
/// - 하단 광고 배너 2x2 그리드
class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// CustomScrollView + Sliver 조합 사용
    /// flutter-layout.md 가이드에 따라 복합 스크롤 화면에 적용
    /// 장점: 스크롤 영역 조립 가능, 고급 UX 지원, 대규모 화면 표준 패턴
    /// CustomScrollView + Sliver 조합 사용
    /// flutter-layout.md 가이드에 따라 복합 스크롤 화면에 적용
    /// 장점: 스크롤 영역 조립 가능, 고급 UX 지원, 대규모 화면 표준 패턴
    /// ContentContainer: 컨텐츠 최대 너비 800px 제한 + 중앙 정렬
    /// ContentContainer: Constrain content to 800px max width + center align
    return ContentContainer(
      child: CustomScrollView(
        slivers: [
          /// AppBar Section (앱바 영역)
          /// Uses reusable AppHeader widget for consistent header design
          /// Layout: [필고] ─── [Avatar] [Settings]
          /// 재사용 가능한 AppHeader 위젯 사용
          // SliverToBoxAdapter(
          //   child: AppHeader(
          //     /// Leading Widget - PhilGo Logo (리딩 위젯 - 필고 로고)
          //     /// Displays PhilGo triangle logo before title
          //     /// Size: 48 (smaller than default 64)
          //     leading: Logo(size: 48),

          //     /// Title removed - only logo is displayed (타이틀 삭제 - 로고만 표시)
          //     title: '',

          //     /// Action buttons displayed after avatar (아바타 뒤에 표시되는 액션 버튼들)
          //     actions: [
          //       /// Create Post Button (글쓰기 버튼)
          //       /// MenuAnchor 기반 2단계 드롭다운 메뉴
          //       /// - 1단계: 메인 카테고리 목록 표시
          //       /// - 2단계: 서브 카테고리가 있으면 SubmenuButton으로 확장 표시
          //       /// Two-level dropdown menu using MenuAnchor
          //       /// - Level 1: Main category list
          //       /// - Level 2: SubmenuButton for categories with sub-categories
          //       MenuAnchor(
          //         /// 메뉴 스타일 (elevation 0, flat design)
          //         /// Menu style (elevation 0, flat design)
          //         style: MenuStyle(
          //           elevation: WidgetStatePropertyAll(0),
          //           backgroundColor: WidgetStatePropertyAll(
          //             scheme.surfaceContainerHighest,
          //           ),
          //         ),

          //         /// 메뉴 아이템 빌더
          //         /// Menu items builder
          //         menuChildren: _buildCategoryMenuItems(context),

          //         /// 메뉴 버튼 빌더
          //         /// Menu button builder
          //         builder: (context, controller, child) {
          //           return IconButton(
          //             icon: FaIcon(
          //               FontAwesomeIcons.lightPlusLarge,
          //               color: scheme.onSurface,
          //               size: 24,
          //             ),
          //             tooltip: 'Create Post',
          //             onPressed: () {
          //               /// 메뉴 열기/닫기 토글
          //               /// Toggle menu open/close
          //               if (controller.isOpen) {
          //                 controller.close();
          //               } else {
          //                 controller.open();
          //               }
          //             },
          //           );
          //         },
          //       ),
          //     ],
          //   ),
          // ),

          /// [Top Banners]
          /// 상단 배너 - 전체 페이지 배너 표시
          /// Top banners - display all page banners
          SliverToBoxAdapter(child: const TopBanners()),

          /// [게시판 섹션 - 2단 레이아웃]
          /// Forum Sections - 2-column layout
          /// 왼쪽: 자유게시판, 오른쪽: 질문과 답변
          /// Left: Freetalk, Right: QnA
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// [자유게시판 섹션] - 최근 글 4개 표시 (왼쪽)
                /// Freetalk Section - Display latest 4 posts (left)
                Expanded(
                  child: HomePostSection(
                    postId: 'freetalk',
                    limit: 3,
                    onMoreTap: () {
                      /// ForumHome으로 이동하면서 freetalk 선택
                      /// Navigate to ForumHome with freetalk selected
                      final navState = NavigationState.of(
                        context,
                        listen: false,
                      );
                      navState.data = {'initialPostId': 'freetalk'};
                      navState.setHomeNavigation(HomeNavigationItem.forum);
                    },
                    onPostTap: (post) {
                      /// PostViewScreen으로 이동
                      /// Navigate to PostViewScreen
                      PostViewScreen.push(context, post);
                    },
                  ),
                ),

                /// [질문과 답변 섹션] - 최근 글 4개 표시 (오른쪽)
                /// QnA Section - Display latest 4 posts (right)
                Expanded(
                  child: HomePostSection(
                    postId: 'qna',
                    limit: 3,
                    onMoreTap: () {
                      /// ForumHome으로 이동하면서 qna 선택
                      /// Navigate to ForumHome with qna selected
                      final navState = NavigationState.of(
                        context,
                        listen: false,
                      );
                      navState.data = {'initialPostId': 'qna'};
                      navState.setHomeNavigation(HomeNavigationItem.forum);
                    },
                    onPostTap: (post) {
                      /// PostViewScreen으로 이동
                      /// Navigate to PostViewScreen
                      PostViewScreen.push(context, post);
                    },
                  ),
                ),
              ],
            ),
          ),

          /// [Square Banners]
          /// 사각 배너 - 1줄에 4개씩 그리드로 표시
          /// Square banners - display 4 per row in grid
          SliverToBoxAdapter(child: const WingBanners()),

          /// [인기글 섹션] - 최근 7일간 댓글 많은 글 5개 표시
          /// Popular Posts Section - Display top 5 posts with most comments in last 7 days
          SliverToBoxAdapter(
            child: HomePopularPostSection(
              limit: 3,
              withinDays: 7,
              onMoreTap: () {
                /// ForumHome으로 이동 (인기글은 전체 게시판 대상)
                /// Navigate to ForumHome (popular posts from all boards)
                final navState = NavigationState.of(context, listen: false);
                navState.setHomeNavigation(HomeNavigationItem.forum);
              },
              onPostTap: (post) {
                /// PostViewScreen으로 이동
                /// Navigate to PostViewScreen
                PostViewScreen.push(context, post);
              },
            ),
          ),

          /// [최근 사진 섹션] - 장터 게시판에서 사진 16개 (4x4 그리드)
          /// Recent Photos Section - 16 photos from buyandsell board (4x4 grid)
          SliverToBoxAdapter(
            child: HomePhotoGridSection(
              postId: 'buyandsell',
              limit: 16,
              crossAxisCount: 4,
              onMoreTap: () {
                /// ForumHome으로 이동하면서 buyandsell 선택
                /// Navigate to ForumHome with buyandsell selected
                final navState = NavigationState.of(context, listen: false);
                navState.data = {'initialPostId': 'buyandsell'};
                navState.setHomeNavigation(HomeNavigationItem.forum);
              },
              onPhotoTap: (post) {
                /// PostViewScreen으로 이동
                /// Navigate to PostViewScreen
                PostViewScreen.push(context, post);
              },
            ),
          ),

          /// Bottom spacing (하단 여백)
          SliverToBoxAdapter(child: SizedBox(height: sp.s24)),
        ],
      ),
    );
  }

  /// 카테고리 메뉴 아이템 빌더
  /// Builds menu items for 2-level category dropdown
  ///
  /// 구조:
  /// - 서브 카테고리가 있는 메인 카테고리: SubmenuButton (확장 가능)
  /// - 서브 카테고리가 없는 메인 카테고리: MenuItemButton (즉시 선택)
  ///
  /// Structure:
  /// - Main category with sub-categories: SubmenuButton (expandable)
  /// - Main category without sub-categories: MenuItemButton (direct selection)
  List<Widget> _buildCategoryMenuItems(BuildContext context) {
    /// majorCategories()를 사용하여 주요 메인 카테고리만 표시
    /// Use majorCategories() to show only major main categories
    return PhilgoCategory.majorCategories().map((postId) {
      /// 메인 카테고리의 다국어 이름 가져오기 (philgoTr 사용)
      /// Get localized main category name (using philgoTr)
      final localizedMainCategory = philgoTr(context, postId);

      /// 서브 카테고리가 있는 경우: SubmenuButton 사용
      /// If sub-categories exist: use SubmenuButton
      if (PhilgoCategory.hasSubCategories(postId)) {
        return SubmenuButton(
          /// 서브 카테고리 목록을 MenuItemButton으로 표시
          /// Display sub-categories as MenuItemButton list
          menuChildren: PhilgoCategory.subCategories(postId).map((category) {
            /// 서브 카테고리의 다국어 이름 가져오기 (philgoTr 사용)
            /// Get localized sub-category name (using philgoTr)
            final localizedSubCategory = philgoTr(context, category);
            return MenuItemButton(
              onPressed: () {
                /// 서브 카테고리 선택 시 글쓰기 다이얼로그 표시
                /// Show post create dialog when sub-category selected
                showPostCreateDialog(
                  context,
                  postId: postId,
                  category: category,
                );
              },
              child: Text(localizedSubCategory),
            );
          }).toList(),
          child: Text(localizedMainCategory),
        );
      } else {
        /// 서브 카테고리가 없는 경우: MenuItemButton 사용
        /// If no sub-categories: use MenuItemButton
        return MenuItemButton(
          onPressed: () {
            /// 메인 카테고리만 선택하여 글쓰기 다이얼로그 표시
            /// Show post create dialog with main category only
            showPostCreateDialog(context, postId: postId);
          },
          child: Text(localizedMainCategory),
        );
      }
    }).toList();
  }
}
