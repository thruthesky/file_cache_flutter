import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/privacy/privacy.screen.dart';
import 'package:philgo/screens/terms/terms.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:philgo/widgets/home/menu.tile.dart';

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

    final menuItems = [
      {
        'icon': FontAwesomeIcons.userPen,
        'title': T.editProfileTitle,
        'subtitle': T.editProfileSubtitle,
        'onTap': () => ProfileEditScreen.push(context),
      },
      {
        'icon': FontAwesomeIcons.comments,
        'title': T.openChatTitle,
        'subtitle': T.openChatSubtitle,
        'onTap': () {
          NavigationState.of(context, listen: false).openOpenChat();
        },
      },
      {
        'icon': FontAwesomeIcons.rectangleAd,
        'title': T.bannerAdTitle,
        'subtitle': T.bannerAdSubtitle,
        'onTap': () {
          WebViewScreen.push(context, bannerPageUrl(), title: T.bannerAdTitle);
        },
      },
      {
        'icon': FontAwesomeIcons.coins,
        'title': T.pointAdTitle,
        'subtitle': T.pointAdSubtitle,
        'onTap': () {
          WebViewScreen.push(context, pointPageUrl(), title: T.pointAdTitle);
        },
      },
      {
        'icon': FontAwesomeIcons.store,
        'title': T.businessDirectoryTitle,
        'subtitle': T.businessDirectorySubtitle,
        'onTap': () {
          NavigationState.of(context, listen: false).openCompanyPage();
        },
      },
      {
        'icon': FontAwesomeIcons.circleInfo,
        'title': T.appGuideTitle,
        'subtitle': T.appGuideSubtitle,
        'onTap': () => AppGuideScreen.push(context),
      },
      {
        'icon': FontAwesomeIcons.fileContract,
        'title': T.termsOfServiceTitle,
        'subtitle': T.termsOfServiceSubtitle,
        'onTap': () => TermsScreen.push(context),
      },
      {
        'icon': FontAwesomeIcons.userShield,
        'title': T.privacyPolicyTitle,
        'subtitle': T.privacyPolicySubtitle,
        'onTap': () => PrivacyScreen.push(context),
      },
      {
        'icon': FontAwesomeIcons.userXmark,
        'title': T.withdrawTitle,
        'subtitle': T.withdrawSubtitle,
        'onTap': () => AccountWithdrawalScreen.push(context),
      },
      {
        'icon': FontAwesomeIcons.rightFromBracket,
        'title': T.logoutTitle,
        'subtitle': T.logoutSubtitle,
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
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sp.s8,
                                vertical: sp.s4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    scheme.primary.withValues(alpha: 0.2),
                                    scheme.secondary.withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: const PhilGoLogoTriangles(size: 44),
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
                  return MenuTile(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    subtitle: item['subtitle'] as String,
                    onTap: item['onTap'] as VoidCallback?,
                    index: index,
                    isAnimated: _isAnimated,
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
