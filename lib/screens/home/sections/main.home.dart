import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/main/latest.user.comments.dart';
import 'package:philgo/widgets/home/main/latest.user.posts.dart';
import 'package:philgo/widgets/home/main/user.stats.dart';

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

    return SingleChildScrollView(
      child: Column(
        children: [
          /// SafeArea
          SafeArea(child: Container()),

          /// 앱바: 로고 + 설정 버튼
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// PhilGo 로고
                Image.asset('assets/img/logo/philgo_wide_logo.png', height: 28),
                const Spacer(),

                /// 설정 버튼
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.lightGear,
                    color: scheme.onPrimaryContainer,
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

          SizedBox(height: sp.s8),

          const UserStats(),

          SizedBox(height: sp.s8),

          const LatestUserPosts(),

          SizedBox(height: sp.s8),

          const LatestUserComments(),

          SizedBox(height: sp.s24),
        ],
      ),
    );
  }
}
