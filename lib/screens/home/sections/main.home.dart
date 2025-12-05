import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/philgo_app.config.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/settings/language.screen.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/forum.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/appbar/app_header.dart';
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
            /// Action buttons displayed after avatar (아바타 뒤에 표시되는 액션 버튼들)
            actions: [
              /// Settings Button (설정 버튼)
              /// Navigates to menu section when tapped
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.lightGear,
                  color: scheme.onSurface,
                  size: 24,
                ),
                onPressed: () {
                  NavigationState.of(
                    context,
                    listen: false,
                  ).setHomeNavigation(HomeNavigationItem.menu);
                },
                tooltip: 'Settings',
              ),
            ],
          ),
        ),

        /// Spacing after AppBar (앱바 하단 여백)
        SliverToBoxAdapter(child: SizedBox(height: sp.s20)),


        /// Latest Posts & Comments Section (최근 게시글 & 댓글 영역)
        /// Side-by-side 2-column layout
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sp.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Left Column: Latest Posts (왼쪽: 최근 게시글)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Section Header (섹션 헤더)
                      Text(
                        'Posts',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: sp.s8),

                      /// Post Items (게시글 목록)
                      /// Display 3 latest posts with title only
                      /// Comic Design: 2.0px border, no shadow
                      if (isLoadingPosts)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(sp.s16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (latestPosts == null || latestPosts!.isEmpty)
                        Container(
                          padding: EdgeInsets.all(sp.s16),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: scheme.outline,
                              width: 2.0,
                            ),
                          ),
                          child: Text(
                            Lo.of(context)!.noPostsYet,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...latestPosts!.map((post) {
                          return InkWell(
                            onTap: () {
                              PostViewScreen.push(context, post);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: EdgeInsets.only(bottom: sp.s8),
                              padding: EdgeInsets.all(sp.s12),
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                // Comic Design: 2.0px border with outline color
                                border: Border.all(
                                  color: scheme.outline,
                                  width: 2.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  /// Post subject (게시글 제목)
                                  Expanded(
                                    child: Text(
                                      post.subject,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: scheme.onSurface),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                SizedBox(width: sp.s12),

                /// Right Column: Latest Comments (오른쪽: 최근 댓글)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Section Header (섹션 헤더)
                      Text(
                        'Comments',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: sp.s8),

                      /// Comment Items (댓글 목록)
                      /// Display 3 latest comments with content
                      /// Comic Design: 2.0px border, no shadow
                      if (isLoadingComments)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(sp.s16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (latestComments == null ||
                          latestComments!.isEmpty)
                        Container(
                          padding: EdgeInsets.all(sp.s16),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: scheme.outline,
                              width: 2.0,
                            ),
                          ),
                          child: Text(
                            'No comments yet',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...latestComments!.map((comment) {
                          return InkWell(
                            onTap: () async {
                              try {
                                final post = await getPost(comment.idx_root);
                                if (context.mounted) {
                                  await PostViewScreen.push(context, post);
                                }
                              } catch (e) {
                                debugLog(
                                  'Error navigating from comment to post: $e',
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: EdgeInsets.only(bottom: sp.s8),
                              padding: EdgeInsets.all(sp.s12),
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                // Comic Design: 2.0px border with outline color
                                border: Border.all(
                                  color: scheme.outline,
                                  width: 2.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  /// Comment content (댓글 내용)
                                  Expanded(
                                    child: Text(
                                      comment.content,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: scheme.onSurface),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Bottom spacing (하단 여백)
        SliverToBoxAdapter(child: SizedBox(height: sp.s24)),
      ],
    );
  }
}

/// Quick Action Button Widget (빠른 작업 버튼 위젯)
/// Reusable button component for quick actions on home screen
/// Comic Design: 2.0px border, no shadow, rounded corners
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: sp.s12, horizontal: sp.s8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          // Comic Design: 2.0px border with outline color
          border: Border.all(color: scheme.outline, width: 2.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Icon (아이콘)
            FaIcon(icon, size: 24, color: scheme.primary),
            SizedBox(height: sp.s8),

            /// Label (라벨)
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
