import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/user/latest.user.posts.dart';
import 'package:philgo/widgets/home/main/user.stats.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 메인 홈 화면
///
/// 구성:
/// - 앱바: 로고 + 설정 버튼
/// - 사용자 통계: 프로필, 레벨, 게시글 수, 댓글 수, 포인트
/// - 최근 게시글 3개
/// - 최근 댓글 3개
/// - 광고 배너
class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// SafeArea
        SafeArea(
          child:
              /// 앱바: 로고 + 설정 버튼
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: scheme.outlineVariant, width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/img/logo/philgo_wide_logo_icon.png',
                      height: 28,
                    ),
                    const Spacer(),

                    /// 설정 버튼
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
                      tooltip: Lo.of(context)!.settings,
                    ),
                  ],
                ),
              ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: sp.s16),
                const UserStats(),
                Login(
                  builder: (uid) {
                    return LatestUserPosts(firebase_uid: uid);
                  },
                ),
                SizedBox(height: sp.s24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
