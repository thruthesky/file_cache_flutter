import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/info/emergency/emergency_contact.screen.dart';
import 'package:philgo/screens/info/essential/essential_info.screen.dart';
import 'package:philgo/screens/info/exchange/exchange_rate.screen.dart';
import 'package:philgo/screens/info/monthly/monthly_living.screen.dart';
import 'package:philgo/screens/info/notice/notice.screen.dart';
import 'package:philgo/screens/info/travel/travel_info.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/version/version.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/dialogs/policy.dialogs.dart';
import 'package:philgo/widgets/home/menu/menu.item.dart';
import 'package:philgo/widgets/home/menu/menu.section.dart';
import 'package:philgo/widgets/logo/logo.dart';
import 'package:philgo_api/philgo_api.dart';

class MenuHome extends StatefulWidget {
  const MenuHome({super.key});

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome> {
  /// Handle logout
  Future<void> _handleLogout() async {
    final confirmed = await showConfirmDialog(
      title: Lo.of(context)!.logoutTitle,
      message: Lo.of(context)!.logoutConfirmMessage,
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go(EntryScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        /// Top SafeArea
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Comic design: 1.0px border with outlineVariant color (matches bottom nav)
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 1.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Logo(size: 48),
                Text(Lo.of(context)!.menu, style: theme.textTheme.titleLarge),
                const Spacer(),
                SizedBox(width: 48, height: 48),
              ],
            ),
          ),
        ),

        /// Menu content
        Expanded(
          child: SingleChildScrollView(
            // Comic design: Add horizontal padding for menu sections
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Philippine Life Info Section (필리핀 생활 정보 섹션)
                /// 퀵 메뉴의 페이지들을 메뉴 화면에서도 접근 가능하도록 추가
                MenuSection(
                  title: Lo.of(context)!.philippineLifeInfo,
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.bullhorn,
                      title: Lo.of(context)!.quickMenuNotice,
                      onTap: () => showFullScreen(
                        context,
                        child: const NoticeScreen(),
                        barrierLabel: '공지사항 닫기',
                      ),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.coins,
                      title: Lo.of(context)!.quickMenuExchangeRate,
                      onTap: () => showFullScreen(
                        context,
                        child: const ExchangeRateScreen(),
                        barrierLabel: '환율 정보 닫기',
                      ),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.phoneVolume,
                      title: Lo.of(context)!.quickMenuEmergency,
                      onTap: () => showFullScreen(
                        context,
                        child: const EmergencyContactScreen(),
                        barrierLabel: '긴급 연락처 닫기',
                      ),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.circleInfo,
                      title: Lo.of(context)!.quickMenuEssentialInfo,
                      onTap: () => showFullScreen(
                        context,
                        child: const EssentialInfoScreen(),
                        barrierLabel: '필수정보 닫기',
                      ),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.calendarDays,
                      title: Lo.of(context)!.quickMenuMonthlyLiving,
                      onTap: () => showFullScreen(
                        context,
                        child: const MonthlyLivingScreen(),
                        barrierLabel: '한달살기 닫기',
                      ),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.umbrellaBeach,
                      title: Lo.of(context)!.quickMenuTravel,
                      onTap: () => showFullScreen(
                        context,
                        child: const TravelInfoScreen(),
                        barrierLabel: '여행 정보 닫기',
                      ),
                    ),
                  ],
                ),

                /// Account Section
                MenuSection(
                  title: Lo.of(context)!.account,
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.user,
                      title: Lo.of(context)!.editProfile,
                      onTap: () => ProfileEditScreen.push(context),
                    ),
                    // MenuItem(
                    //   icon: FontAwesomeIcons.globe,
                    //   title: Lo.of(context)!.languageTitle,
                    //   onTap: () => LanguageScreen.push(context),
                    // ),
                    MenuItem(
                      icon: FontAwesomeIcons.building,
                      title: Lo.of(context)!.businessDirectoryTitle,
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        if (context.mounted) {
                          NavigationState.of(
                            context,
                            listen: false,
                          ).setHomeNavigation(HomeNavigationItem.company);
                        }
                      },
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.comments,
                      title: Lo.of(context)!.openChatTitle,
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        if (context.mounted) {
                          NavigationState.of(
                            context,
                            listen: false,
                          ).setHomeNavigation(HomeNavigationItem.chat);
                        }
                      },
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.usersSlash,
                      title: Lo.of(context)!.blockedUsers,
                      onTap: () async {
                        showBlockedUserListDialog(context);
                      },
                    ),
                  ],
                ),

                /// Advertising Section
                MenuSection(
                  title: Lo.of(context)!.advertising,
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.rectangleAd,
                      title: Lo.of(context)!.bannerAdTitle,
                      onTap: () {
                        WebViewScreen.push(
                          context,
                          bannerPageUrl(),
                          title: Lo.of(context)!.bannerAdTitle,
                        );
                      },
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.dollarSign,
                      title: Lo.of(context)!.pointAdTitle,
                      onTap: () {
                        WebViewScreen.push(
                          context,
                          pointPageUrl(),
                          title: Lo.of(context)!.pointAdTitle,
                        );
                      },
                    ),
                  ],
                ),

                /// Support & Information Section
                MenuSection(
                  title: Lo.of(context)!.support,
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.circleQuestion,
                      title: Lo.of(context)!.appGuideTitle,
                      onTap: () => AppGuideScreen.push(context),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.fileLines,
                      title: Lo.of(context)!.termsOfServiceTitle,
                      onTap: () => showTermsAndConditions(context),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.shieldHalved,
                      title: Lo.of(context)!.privacyPolicyTitle,
                      onTap: () => showPrivacyPolicy(context),
                    ),
                  ],
                ),

                /// [앱 정보 섹션] - App Information Section
                /// 앱 버전 및 디바이스 정보를 확인할 수 있는 메뉴
                /// Menu for checking app version and device information
                MenuSection(
                  title: Lo.of(context)!.appInfoTitle,
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.circleInfo,
                      title: Lo.of(context)!.versionTitle,
                      onTap: () => VersionScreen.push(context),
                    ),
                  ],
                ),

                /// Account Actions Section
                MenuSection(
                  title: Lo.of(context)!.accountActions,
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.userMinus,
                      title: Lo.of(context)!.withdrawTitle,
                      onTap: () => AccountWithdrawalScreen.push(context),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.rightFromBracket,
                      title: Lo.of(context)!.logoutTitle,
                      onTap: _handleLogout,
                    ),
                  ],
                ),
                SizedBox(height: sp.s16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
