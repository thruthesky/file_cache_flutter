import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/extensions/nav.context.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/widgets/home/main/latest_posts.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/home_photo_grid_section.dart';
import 'package:philgo/widgets/home/home_popular_post_section.dart';
import 'package:philgo/widgets/home/menu/home_menu_categories.dart';
import 'package:philgo/widgets/layout/content_container.dart';
import 'package:philgo/widgets/theme/comic_fab.dart';
import 'package:philgo_api/philgo_api.dart';

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
    final sp = theme.extension<AppSpacing>()!;

    /// CustomScrollView + Sliver 조합 사용
    /// flutter-layout.md 가이드에 따라 복합 스크롤 화면에 적용
    /// 장점: 스크롤 영역 조립 가능, 고급 UX 지원, 대규모 화면 표준 패턴
    /// CustomScrollView + Sliver 조합 사용
    /// flutter-layout.md 가이드에 따라 복합 스크롤 화면에 적용
    /// 장점: 스크롤 영역 조립 가능, 고급 UX 지원, 대규모 화면 표준 패턴
    /// ContentContainer: 컨텐츠 최대 너비 800px 제한 + 중앙 정렬
    /// ContentContainer: Constrain content to 800px max width + center align
    return Scaffold(
      /// 배경색을 투명하게 설정 (부모 배경 사용)
      /// Set background transparent (use parent background)
      backgroundColor: Colors.transparent,

      /// 글쓰기 FAB (Floating Action Button)
      /// Create Post FAB (Floating Action Button)
      /// Comic Design: 흰색 배경, 검정 아이콘, 2.0px 테두리, borderRadius 24
      /// Comic Design: white background, black icon, 2.0px border, borderRadius 24
      floatingActionButton: ComicFab(
        /// FAB 클릭 시 카테고리 선택 다이얼로그 표시
        /// Show category selection dialog on FAB tap
        onPressed: () => _showCategoryDialog(context),

        /// FAB 툴팁
        /// FAB tooltip
        tooltip: '글쓰기',

        /// FAB 아이콘
        /// FAB icon
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
      body: ContentContainer(
        child: CustomScrollView(
          slivers: [
            /// [메뉴 섹션] - 홈 메뉴 카테고리 표시
            /// Home Menu Section - Display home menu categories
            /// PhilgoCategory.homeMenuCategories() 를 반복하여 메뉴 아이템 생성
            SliverToBoxAdapter(
              child: SafeArea(bottom: false, child: const HomeMenuCategories()),
            ),

            /// [Top Banners]
            /// 상단 배너 - 전체 페이지 배너 표시
            /// Top banners - display all page banners
            SliverToBoxAdapter(child: const TopBanners()),

            /// [게시판 섹션 - 2단 레이아웃]
            /// Forum Sections - 2-column layout
            /// 왼쪽: 자유게시판, 오른쪽: 질문과 답변
            /// Left: Freetalk, Right: QnA
            SliverToBoxAdapter(child: LatestPostsSection(limit: 4)),

            /// [Square Banners]
            /// 사각 배너 - 1줄에 4개씩 그리드로 표시
            /// Square banners - display 4 per row in grid
            // SliverToBoxAdapter(child: const WingBanners()),
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
                  context.openForum('buyandsell');
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
      ),
    );
  }

  /// Major 카테고리 선택 다이얼로그 표시
  /// Show major category selection dialog
  ///
  /// Major 카테고리 목록을 팝업 다이얼로그로 표시하고,
  /// 카테고리 선택 시 글쓰기 다이얼로그를 엽니다.
  /// Display major categories in a popup dialog,
  /// and open post create dialog when category is selected.
  void _showCategoryDialog(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          /// 다이얼로그 제목
          /// Dialog title
          title: Text('게시판 선택', style: theme.textTheme.titleLarge),

          /// 다이얼로그 내용: Major 카테고리 목록
          /// Dialog content: Major category list
          content: SizedBox(
            /// 다이얼로그 너비 설정
            /// Set dialog width
            width: double.maxFinite,
            child: ListView.builder(
              /// 내용 크기에 맞게 축소
              /// Shrink to fit content
              shrinkWrap: true,

              /// Major 카테고리 개수
              /// Number of major categories
              itemCount: PhilgoCategory.majorCategories().length,

              /// 카테고리 아이템 빌더
              /// Category item builder
              itemBuilder: (context, index) {
                final postId = PhilgoCategory.majorCategories()[index];

                /// 카테고리 다국어 이름
                /// Localized category name
                final localizedName = philgoTr(context, postId);

                return ListTile(
                  /// 카테고리 이름
                  /// Category name
                  title: Text(localizedName),

                  /// 서브 카테고리 존재 여부 표시
                  /// Show if sub-categories exist
                  trailing: PhilgoCategory.hasSubCategories(postId)
                      ? FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        )
                      : null,

                  /// 카테고리 선택 시
                  /// On category tap
                  onTap: () {
                    /// 다이얼로그 닫기
                    /// Close dialog
                    Navigator.pop(context);

                    /// 서브 카테고리가 있으면 서브 카테고리 다이얼로그 표시
                    /// If sub-categories exist, show sub-category dialog
                    if (PhilgoCategory.hasSubCategories(postId)) {
                      _showSubCategoryDialog(context, postId);
                    } else {
                      /// 서브 카테고리가 없으면 바로 글쓰기 다이얼로그 표시
                      /// If no sub-categories, show post create dialog directly
                      showPostCreateDialog(context, postId: postId);
                    }
                  },
                );
              },
            ),
          ),

          /// 취소 버튼
          /// Cancel button
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  /// 서브 카테고리 선택 다이얼로그 표시
  /// Show sub-category selection dialog
  ///
  /// 선택한 Major 카테고리의 서브 카테고리 목록을 표시합니다.
  /// Display sub-categories of the selected major category.
  void _showSubCategoryDialog(BuildContext context, String postId) {
    final theme = Theme.of(context);

    /// Major 카테고리 다국어 이름
    /// Localized major category name
    final localizedMainCategory = philgoTr(context, postId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          /// 다이얼로그 제목: Major 카테고리 이름
          /// Dialog title: Major category name
          title: Text(localizedMainCategory, style: theme.textTheme.titleLarge),

          /// 다이얼로그 내용: 서브 카테고리 목록
          /// Dialog content: Sub-category list
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: PhilgoCategory.subCategories(postId).length,
              itemBuilder: (context, index) {
                final category = PhilgoCategory.subCategories(postId)[index];

                /// 서브 카테고리 다국어 이름
                /// Localized sub-category name
                final localizedSubCategory = philgoTr(context, category);

                return ListTile(
                  title: Text(localizedSubCategory),
                  onTap: () {
                    /// 다이얼로그 닫기
                    /// Close dialog
                    Navigator.pop(context);

                    /// 글쓰기 다이얼로그 표시
                    /// Show post create dialog
                    showPostCreateDialog(
                      context,
                      postId: postId,
                      category: category,
                    );
                  },
                );
              },
            ),
          ),

          /// 뒤로가기 버튼
          /// Back button
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                /// Major 카테고리 다이얼로그로 돌아가기
                /// Go back to major category dialog
                _showCategoryDialog(context);
              },
              child: const Text('뒤로'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }
}
