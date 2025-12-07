import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
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

  /// 메인 카테고리의 다국어 이름 반환
  /// Returns localized name for main category (postId)
  ///
  /// [l10n] Lo instance for localization
  /// [postId] Main category ID (e.g., 'freetalk', 'buyandsell')
  ///
  /// 지원하지 않는 카테고리는 원본 postId를 반환
  /// Returns original postId for unsupported categories
  String _getLocalizedMainCategory(Lo l10n, String postId) {
    switch (postId) {
      case 'freetalk':
        return l10n.categoryFreetalk;
      case 'qna':
        return l10n.categoryQna;
      case 'buyandsell':
        return l10n.categoryBuyandsell;
      case 'blog':
        return l10n.categoryBlog;
      case 'boarding_house':
        return l10n.categoryBoardingHouse;
      case 'caution':
        return l10n.categoryCaution;
      case 'lookfor':
        return l10n.categoryLookfor;
      case 'food_delivery':
        return l10n.categoryFoodDelivery;
      case 'greeting':
        return l10n.categoryGreeting;
      case 'wanted':
        return l10n.categoryWanted;
      case 'business':
        return l10n.categoryBusiness;
      case 'massage':
        return l10n.categoryMassage;
      case 'rest':
        return l10n.categoryRest;
      case 'school':
        return l10n.categorySchool;
      case 'study':
        return l10n.categoryStudy;
      case 'travel':
        return l10n.categoryTravel;
      case 'youtube':
        return l10n.categoryYoutube;
      case 'momcafe':
        return l10n.categoryMomcafe;
      case 'news':
        return l10n.categoryNews;
      case 'newcomer':
        return l10n.categoryNewcomer;
      case 'nature':
        return l10n.categoryNature;
      case 'company_info':
        return l10n.categoryCompanyInfo;
      case 'english_biz':
        return l10n.categoryEnglishBiz;
      case 'temp':
        return l10n.categoryTemp;
      case 'travel_good':
        return l10n.categoryTravelGood;
      default:
        return postId;
    }
  }

  /// 서브 카테고리의 다국어 이름 반환
  /// Returns localized name for sub-category
  ///
  /// [l10n] Lo instance for localization
  /// [category] Sub-category name (e.g., 'discussion', '백과')
  ///
  /// 지원하지 않는 서브카테고리는 원본 category를 반환
  /// Returns original category for unsupported sub-categories
  String _getLocalizedSubCategory(Lo l10n, String category) {
    switch (category) {
      // freetalk 서브카테고리
      case 'discussion':
        return l10n.subCategoryDiscussion;
      case '백과':
        return l10n.subCategoryEncyclopedia;
      case '취미':
        return l10n.subCategoryHobby;
      case 'info':
        return l10n.subCategoryInfo;
      case '코필커플':
        return l10n.subCategoryKoPhCouple;
      case '코피노':
        return l10n.subCategoryKopino;
      case '이민':
        return l10n.subCategoryImmigration;
      case '사진':
        return l10n.subCategoryPhoto;
      case '생활의팁':
        return l10n.subCategoryLifeTips;
      case '행방불명':
        return l10n.subCategoryMissing;
      case '국제결혼':
        return l10n.subCategoryIntlMarriage;
      case '모임':
        return l10n.subCategoryMeeting;
      case 'column':
        return l10n.subCategoryColumn;
      case '먹방':
        return l10n.subCategoryMukbang;
      case '뉴스':
        return l10n.subCategoryNotice;
      case '공지사항':
        return l10n.subCategoryNotice;
      case '경험담':
        return l10n.subCategoryExperience;
      case '공부':
        return l10n.subCategoryStudyLearn;
      case '태풍':
        return l10n.subCategoryTyphoon;
      // buyandsell 서브카테고리
      case '사업/동업구함':
        return l10n.subCategoryBusinessPartner;
      case '컴퓨터/인터넷':
        return l10n.subCategoryComputer;
      case '페소환전':
        return l10n.subCategoryExchange;
      case '핸드폰':
        return l10n.subCategoryPhone;
      case '호텔':
        return l10n.subCategoryHotel;
      case '가전/생활용품':
        return l10n.subCategoryAppliances;
      case '골프':
        return l10n.subCategoryGolf;
      case 'promotion':
        return l10n.subCategoryPromotion;
      case '개인장터':
        return l10n.subCategoryPersonalMarket;
      case 'real_estate':
        return l10n.subCategoryRealEstate;
      case '주택임대':
        return l10n.subCategoryHouseRental;
      case '렌트카':
        return l10n.subCategoryCarRental;
      case '중고차':
        return l10n.subCategoryUsedCar;
      default:
        return category;
    }
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
    /// Lo를 통해 다국어 지원
    /// Multi-language support via Lo (AppLocalizations)
    final l10n = Lo.of(context)!;

    /// majorCategories()를 사용하여 주요 메인 카테고리만 표시
    /// Use majorCategories() to show only major main categories
    return PhilgoCategory.majorCategories().map((postId) {
      /// 메인 카테고리의 다국어 이름 가져오기
      /// Get localized main category name
      final localizedMainCategory = _getLocalizedMainCategory(l10n, postId);

      /// 서브 카테고리가 있는 경우: SubmenuButton 사용
      /// If sub-categories exist: use SubmenuButton
      if (PhilgoCategory.hasSubCategories(postId)) {
        return SubmenuButton(
          /// 서브 카테고리 목록을 MenuItemButton으로 표시
          /// Display sub-categories as MenuItemButton list
          menuChildren: PhilgoCategory.subCategories(postId).map((category) {
            /// 서브 카테고리의 다국어 이름 가져오기
            /// Get localized sub-category name
            final localizedSubCategory = _getLocalizedSubCategory(
              l10n,
              category,
            );
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

    /// 다국어 지원을 위해 Lo 인스턴스 가져오기
    /// Get Lo instance for localization
    final l10n = Lo.of(context)!;

    /// 메인 카테고리 및 서브 카테고리의 다국어 이름 가져오기
    /// Get localized names for main and sub categories
    final localizedMainCategory = _getLocalizedMainCategory(l10n, postId);
    final localizedSubCategory = category != null
        ? _getLocalizedSubCategory(l10n, category)
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
