import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/appbar/app_header.dart';
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
              /// Updates ForumState and navigates to PostCreateScreen
              /// ForumState 업데이트 후 글쓰기 화면으로 이동
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.lightPlus,
                  color: scheme.onSurface,
                  size: 24,
                ),
                onPressed: () {
                  /// 1. ForumState의 editPostCategory를 현재 homePostCategory로 설정
                  /// Set editPostCategory to current homePostCategory
                  final forumState = ForumState.of(context, listen: false);
                  forumState.setEditCategory(forumState.homePostCategory);

                  /// 2. PostCreateScreen으로 이동
                  /// Navigate to PostCreateScreen
                  PostCreateScreen.push(context);
                },
                tooltip: 'Create Post',
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
}



