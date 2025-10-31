import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/user/profile.screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class MenuHome extends StatefulWidget {
  const MenuHome({super.key});

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome>
    with SingleTickerProviderStateMixin {
  // 애니메이션을 위한 변수
  bool _isAnimated = false;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    // 떠다니는 애니메이션 컨트롤러
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // 화면 진입 애니메이션 트리거
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isAnimated = true);
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // 메뉴 아이템 데이터
    final menuItems = [
      {
        'icon': FontAwesomeIcons.userPen,
        'title': T.editProfileTitle,
        'subtitle': T.editProfileSubtitle,
        'color': Colors.blue,
        'onTap': () => ProfileScreen.push(context),
      },
      {
        'icon': FontAwesomeIcons.comments,
        'title': T.openChatTitle,
        'subtitle': T.openChatSubtitle,
        'color': Colors.green,
        'onTap': () {
          NavigationState.of(context, listen: false).openOpenChat();
        },
      },
      {
        'icon': FontAwesomeIcons.rectangleAd,
        'title': T.bannerAdTitle,
        'subtitle': T.bannerAdSubtitle,
        'color': Colors.orange,
        'onTap': () {
          WebViewScreen.push(context, bannerPageUrl(), title: T.bannerAdTitle);
        },
      },
      {
        'icon': FontAwesomeIcons.coins,
        'title': T.pointAdTitle,
        'subtitle': T.pointAdSubtitle,
        'color': Colors.amber,
        'onTap': () {
          WebViewScreen.push(context, pointPageUrl(), title: T.pointAdTitle);
        },
      },
      {
        'icon': FontAwesomeIcons.store,
        'title': T.businessDirectoryTitle,
        'subtitle': T.businessDirectorySubtitle,
        'color': Colors.purple,
        'onTap': () {},
      },
      {
        'icon': FontAwesomeIcons.sitemap,
        'title': T.familySiteTitle,
        'subtitle': T.familySiteSubtitle,
        'color': Colors.teal,
        'onTap': () {},
      },
      {
        'icon': FontAwesomeIcons.circleInfo,
        'title': T.appGuideTitle,
        'subtitle': T.appGuideSubtitle,
        'color': Colors.indigo,
        'onTap': () {},
      },
      {
        'icon': FontAwesomeIcons.fileContract,
        'title': T.termsOfServiceTitle,
        'subtitle': T.termsOfServiceSubtitle,
        'color': Colors.blueGrey,
        'onTap': () {},
      },
      {
        'icon': FontAwesomeIcons.userShield,
        'title': T.privacyPolicyTitle,
        'subtitle': T.privacyPolicySubtitle,
        'color': Colors.cyan,
        'onTap': () {},
      },
      {
        'icon': FontAwesomeIcons.userXmark,
        'title': T.withdrawTitle,
        'subtitle': T.withdrawSubtitle,
        'color': Colors.red.shade400,
        'onTap': () {},
      },
      {
        'icon': FontAwesomeIcons.rightFromBracket,
        'title': T.logoutTitle,
        'subtitle': T.logoutSubtitle,
        'color': Colors.red.shade600,
        'onTap': () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            context.go(EntryScreen.routeName);
          }
        },
      },
    ];

    return Container(
      // 그라디언트 배경
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.05),
            scheme.secondaryContainer.withValues(alpha: 0.08),
            scheme.tertiaryContainer.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Container(
              padding: EdgeInsets.all(sp.s24),
              child: Column(
                children: [
                  // 타이틀 애니메이션
                  AnimatedBuilder(
                        animation: _floatingController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 5 * _floatingController.value),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(sp.s12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    scheme.primary.withValues(alpha: 0.2),
                                    scheme.secondary.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.compass,
                                color: scheme.primary,
                                size: 32,
                              ),
                            ),
                            SizedBox(width: sp.s16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  T.menuTitle,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary,
                                      ),
                                ),
                                Text(
                                  T.menuSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      .animate(target: _isAnimated ? 1 : 0)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                ],
              ),
            ),

            // 메뉴 리스트
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: sp.s16),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Container(
                        margin: EdgeInsets.only(bottom: sp.s12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: item['onTap'] as VoidCallback?,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.all(sp.s16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    scheme.surface,
                                    scheme.surface.withValues(alpha: 0.95),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: (item['color'] as Color).withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // 아이콘 컨테이너
                                  Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              (item['color'] as Color)
                                                  .withValues(alpha: 0.2),
                                              (item['color'] as Color)
                                                  .withValues(alpha: 0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            item['icon'] as IconData,
                                            color: item['color'] as Color,
                                            size: 24,
                                          ),
                                        ),
                                      )
                                      .animate(target: _isAnimated ? 1 : 0)
                                      .scale(
                                        delay: (50 * index).ms,
                                        duration: 400.ms,
                                        begin: const Offset(0.8, 0.8),
                                        end: const Offset(1, 1),
                                      ),
                                  SizedBox(width: sp.s16),
                                  // 텍스트 영역
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] as String,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        SizedBox(height: sp.s4),
                                        Text(
                                          item['subtitle'] as String,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 화살표 아이콘
                                  FaIcon(
                                    FontAwesomeIcons.chevronRight,
                                    size: 16,
                                    color: scheme.onSurfaceVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate(target: _isAnimated ? 1 : 0)
                      .fadeIn(delay: (100 * index).ms, duration: 500.ms)
                      .slideX(
                        begin: 0.2,
                        end: 0,
                        delay: (100 * index).ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
