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

    return SingleChildScrollView(
      child: Column(
        children: [
          /// AppBar Section (앱바 영역)
          /// Contains user avatar and settings button
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sp.s16,
                vertical: sp.s12,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// Nickname (닉네임)
                              Text(
                                user?.nickname ?? 'Guest',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: sp.s4),

                              /// Level (레벨)
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.lightStar,
                                    size: 12,
                                    color: scheme.primary,
                                  ),
                                  SizedBox(width: sp.s4),
                                  Text(
                                    'Level ${user?.level ?? 1}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
                      ...List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: sp.s8),
                          padding: EdgeInsets.all(sp.s12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              /// Post title (게시글 제목)
                              Expanded(
                                child: Text(
                                  'Post title ${index + 1}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
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
                      ...List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: sp.s8),
                          padding: EdgeInsets.all(sp.s12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: scheme.tertiary.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              /// Comment text (댓글 내용)
                              Expanded(
                                child: Text(
                                  'Comment text ${index + 1}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
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

          /// Advertisement Section (광고 영역)
          /// 2x2 grid of ad placeholders
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sp.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Section Header (섹션 헤더)
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightRectangleAd,
                      size: 14,
                      color: scheme.secondary,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      'Advertisements',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sp.s8),

                /// 2x2 Ad Grid using Column and Row (2x2 광고 그리드)
                Column(
                  children: [
                    /// First Row (첫 번째 행)
                    Row(
                      children: [
                        /// Ad 1
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLow,
                                border: Border.all(
                                  color: scheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.lightRectangleAd,
                                      size: 32,
                                      color: scheme.secondary.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    SizedBox(height: sp.s8),
                                    Text(
                                      'Ad 1',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sp.s12),

                        /// Ad 2
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLow,
                                border: Border.all(
                                  color: scheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.lightRectangleAd,
                                      size: 32,
                                      color: scheme.secondary.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    SizedBox(height: sp.s8),
                                    Text(
                                      'Ad 2',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sp.s12),

                    /// Second Row (두 번째 행)
                    Row(
                      children: [
                        /// Ad 3
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLow,
                                border: Border.all(
                                  color: scheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.lightRectangleAd,
                                      size: 32,
                                      color: scheme.secondary.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    SizedBox(height: sp.s8),
                                    Text(
                                      'Ad 3',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sp.s12),

                        /// Ad 4
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLow,
                                border: Border.all(
                                  color: scheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.lightRectangleAd,
                                      size: 32,
                                      color: scheme.secondary.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    SizedBox(height: sp.s8),
                                    Text(
                                      'Ad 4',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: sp.s24),
        ],
      ),
    );
  }
}
