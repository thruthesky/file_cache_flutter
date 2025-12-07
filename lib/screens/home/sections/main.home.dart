import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/headers/app_header.dart';
import 'package:philgo/widgets/logo/logo.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

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
  List<Post>? latestPosts;
  List<Comment>? latestComments;
  bool isLoadingPosts = true;
  bool isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLatestPosts(context);
      _loadLatestComments();
    });
  }

  /// Load latest 3 posts of the current user
  Future<void> _loadLatestPosts(BuildContext context) async {
    setState(() {
      isLoadingPosts = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final idx = appState.user?.idx;

      // Fetch latest 3 posts of the user (fallback to global latest)
      List<Post> posts;
      if (idx != null && idx > 0) {
        posts = await getLatestByUser(idx_member: idx, limit: 3);
      } else {
        final postsResult = await getPosts(limit: 3);
        posts = postsResult.posts;
      }

      if (mounted) {
        setState(() {
          latestPosts = posts;
          isLoadingPosts = false;
        });
      }
    } catch (e) {
      debugLog('Error loading latest posts: $e');
      if (mounted) {
        setState(() {
          isLoadingPosts = false;
        });
      }
    }
  }

  /// Load latest 3 comments of the current user
  Future<void> _loadLatestComments() async {
    setState(() {
      isLoadingComments = true;
    });

    try {
      // Fetch latest 3 comments from the user
      final commentsResult = await getMyComments(limit: 3);

      if (mounted) {
        setState(() {
          latestComments = commentsResult;
          isLoadingComments = false;
        });
      }
    } catch (e) {
      debugLog('Error loading latest comments: $e');
      if (mounted) {
        setState(() {
          isLoadingComments = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// CustomScrollView + Sliver 조합 사용
    /// flutter-layout.md 가이드에 따라 복합 스크롤 화면에 적용
    /// 장점: 스크롤 영역 조립 가능, 고급 UX 지원, 대규모 화면 표준 패턴
    return CustomScrollView(
      slivers: [
        /// AppBar Section (앱바 영역)
        /// Uses reusable AppHeader widget for consistent header design
        /// Layout: [필고] ─── [Avatar] [Settings]
        /// 재사용 가능한 AppHeader 위젯 사용
        SliverToBoxAdapter(
          child: AppHeader(
            /// Leading Widget - PhilGo Logo (리딩 위젯 - 필고 로고)
            /// Displays PhilGo triangle logo before title
            /// Size: 48 (smaller than default 64)
            leading: Logo(size: 48),

            /// Title removed - only logo is displayed (타이틀 삭제 - 로고만 표시)
            title: '',

            /// Action buttons displayed after avatar (아바타 뒤에 표시되는 액션 버튼들)
            actions: [
              /// Create Post Button (글쓰기 버튼)
              /// MenuAnchor 기반 2단계 드롭다운 메뉴
              /// - 1단계: 메인 카테고리 목록 표시
              /// - 2단계: 서브 카테고리가 있으면 SubmenuButton으로 확장 표시
              /// Two-level dropdown menu using MenuAnchor
              /// - Level 1: Main category list
              /// - Level 2: SubmenuButton for categories with sub-categories
              MenuAnchor(
                /// 메뉴 스타일 (elevation 0, flat design)
                /// Menu style (elevation 0, flat design)
                style: MenuStyle(
                  elevation: WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    scheme.surfaceContainerHighest,
                  ),
                ),

                /// 메뉴 아이템 빌더
                /// Menu items builder
                menuChildren: _buildCategoryMenuItems(context),

                /// 메뉴 버튼 빌더
                /// Menu button builder
                builder: (context, controller, child) {
                  return IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.lightPlusLarge,
                      color: scheme.onSurface,
                      size: 24,
                    ),
                    tooltip: 'Create Post',
                    onPressed: () {
                      /// 메뉴 열기/닫기 토글
                      /// Toggle menu open/close
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),

        /// Spacing after AppBar (앱바 하단 여백)
        SliverToBoxAdapter(child: SizedBox(height: sp.s20)),

        /// Bottom spacing (하단 여백)
        SliverToBoxAdapter(child: SizedBox(height: sp.s24)),
      ],
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
                _showPostCreateDialog(context, postId, category);
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
            _showPostCreateDialog(context, postId, null);
          },
          child: Text(localizedMainCategory),
        );
      }
    }).toList();
  }

  /// 글쓰기 다이얼로그 표시
  /// Shows PostCreateForm dialog using showGeneralDialog
  ///
  /// [context] BuildContext for dialog
  /// [postId] Main category ID (e.g., 'freetalk', 'buyandsell')
  /// [category] Sub-category (optional, null if no sub-category)
  void _showPostCreateDialog(
    BuildContext context,
    String postId,
    String? category,
  ) {
    /// GlobalKey로 외부에서 폼 상태 접근
    /// Access form state externally via GlobalKey
    final formKey = GlobalKey<PostCreateFormState>();

    /// 메인 카테고리 및 서브 카테고리의 다국어 이름 가져오기 (philgoTr 사용)
    /// Get localized names for main and sub categories (using philgoTr)
    final localizedMainCategory = philgoTr(context, postId);
    final localizedSubCategory = category != null
        ? philgoTr(context, category)
        : null;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PostCreate',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final theme = Theme.of(dialogContext);
        final scheme = theme.colorScheme;

        return SafeArea(
          child: Scaffold(
            /// AppBar - Comic Design 스타일 적용 (elevation 0)
            /// AppBar with Comic Design style (elevation 0)
            appBar: AppBar(
              elevation: 0,
              title: Text(
                /// 다국어 카테고리 표시: "localizedMainCategory > localizedSubCategory" 또는 "localizedMainCategory"
                /// Display localized category: "localizedMainCategory > localizedSubCategory" or "localizedMainCategory"
                localizedSubCategory != null
                    ? '$localizedMainCategory > $localizedSubCategory'
                    : localizedMainCategory,
              ),

              /// 닫기 버튼
              /// Close button
              leading: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.lightXmark,
                  color: scheme.onSurface,
                ),
                onPressed: () => Navigator.pop(dialogContext),
              ),
              actions: [
                /// 제출 버튼 - GlobalKey를 통해 폼의 submit() 호출
                /// Submit button - calls form's submit() via GlobalKey
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.lightCheck,
                    color: scheme.primary,
                  ),
                  onPressed: () => formKey.currentState?.submit(),
                ),
              ],
            ),

            /// PostCreateForm - 재사용 가능한 글쓰기 폼
            /// PostCreateForm - reusable post creation form
            body: PostCreateForm(
              key: formKey,
              postId: postId,
              category: category,

              /// AppBar에서 제출 버튼을 처리하므로 폼 내부 버튼 숨김
              /// Hide form's internal submit button (handled by AppBar)
              showSubmitButton: false,

              /// 제출 성공 시 다이얼로그 닫기
              /// Close dialog on successful submission
              onSubmitted: (post) {
                Navigator.pop(dialogContext);

                /// 선택적: 생성된 글 보기 화면으로 이동
                /// Optional: Navigate to post view screen
              },
            ),
          ),
        );
      },

      /// 슬라이드 애니메이션 (하단에서 위로)
      /// Slide animation (from bottom to top)
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
    );
  }
}
