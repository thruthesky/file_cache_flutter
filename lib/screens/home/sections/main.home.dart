import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Stack(
            children: [
              /// Background color from top to half screen (화면 상단부터 절반까지 배경색)
              /// Provides visual separation for top section with rounded bottom corners
              /// Comic Design: No border needed for background, just rounded corners
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.485,
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    // Comic Design: Rounded corners (border radius 16)
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),

              /// Main content (메인 콘텐츠)
              Column(
                children: [
                  /// AppBar Section (앱바 영역)
                  /// Contains user avatar and settings button
                  /// Comic Design: 2.0px bottom border
                  SafeArea(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s16,
                        vertical: sp.s12,
                      ),
                      decoration: BoxDecoration(
                        // Comic Design: 2.0px bottom border with outline color
                        border: Border(
                          bottom: BorderSide(color: scheme.outline, width: 2.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          /// User Profile Section (사용자 프로필 영역)
                          /// Displays avatar, nickname, and level
                          Selector<AppState, User?>(
                            selector: (_, appState) => appState.user,
                            builder: (_, user, _) {
                              return Row(
                                children: [
                                  /// User Avatar (사용자 아바타)
                                  Avatar(
                                    photoUrl: user?.photoUrl,
                                    size: 40,
                                    radius: 20,
                                  ),
                                  SizedBox(width: sp.s12),

                                  /// User Info: Nickname + Level (닉네임 + 레벨)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      /// Nickname (닉네임)
                                      Text(
                                        user?.nickname ?? 'Guest',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: scheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: sp.s4),

                                      /// Level (레벨)
                                      Text(
                                        'Level ${user?.level ?? 1}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const Spacer(),

                          /// Settings Button (설정 버튼)
                          /// Navigates to menu section
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
                  ),

                  SizedBox(height: sp.s20),

                  /// Quick Action Buttons (빠른 작업 버튼)
                  /// Provides shortcuts to frequently used features
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sp.s16),
                    child: Row(
                      children: [
                        /// Create Post Button (게시글 작성)
                        Expanded(
                          child: _QuickActionButton(
                            icon: FontAwesomeIcons.lightPenToSquare,
                            label: 'Create Post',
                            onTap: () {
                              // TODO: Navigate to create post screen
                            },
                          ),
                        ),
                        SizedBox(width: sp.s8),

                        /// Create Company Button (회사 생성)
                        Expanded(
                          child: _QuickActionButton(
                            icon: FontAwesomeIcons.lightBuilding,
                            label: 'Company',
                            onTap: () {
                              // TODO: Navigate to create company screen
                            },
                          ),
                        ),
                        SizedBox(width: sp.s8),

                        /// Edit Profile Button (프로필 수정)
                        Expanded(
                          child: _QuickActionButton(
                            icon: FontAwesomeIcons.lightUser,
                            label: 'Profile',
                            onTap: () {
                              // TODO: Navigate to edit profile screen
                            },
                          ),
                        ),
                        SizedBox(width: sp.s8),

                        /// Language Button (언어 설정)
                        Expanded(
                          child: _QuickActionButton(
                            icon: FontAwesomeIcons.lightLanguage,
                            label: 'Language',
                            onTap: () {
                              // TODO: Show language selection dialog
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: sp.s24),

                  /// Latest Posts & Comments Section (최근 게시글 & 댓글 영역)
                  /// Side-by-side 2-column layout
                  Padding(
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
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.lightPenToSquare,
                                    size: 14,
                                    color: scheme.primary,
                                  ),
                                  SizedBox(width: sp.s8),
                                  Text(
                                    'Posts',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: sp.s8),

                              /// Post Items (게시글 목록)
                              /// Display 3 latest posts with title only
                              /// Comic Design: 2.0px border, no shadow
                              ...List.generate(3, (index) {
                                return Container(
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
                                      /// Post title (게시글 제목)
                                      Expanded(
                                        child: Text(
                                          'Post title ${index + 1}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: scheme.onSurface,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
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
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.lightMessageDots,
                                    size: 14,
                                    color: scheme.tertiary,
                                  ),
                                  SizedBox(width: sp.s8),
                                  Text(
                                    'Comments',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: sp.s8),

                              /// Comment Items (댓글 목록)
                              /// Display 3 latest comments with title only
                              /// Comic Design: 2.0px border, no shadow
                              ...List.generate(3, (index) {
                                return Container(
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
                                      /// Comment text (댓글 내용)
                                      Expanded(
                                        child: Text(
                                          'Comment text ${index + 1}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: scheme.onSurface,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: sp.s24),
                ],
              ),
            ],
          ),
        );
      },
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
