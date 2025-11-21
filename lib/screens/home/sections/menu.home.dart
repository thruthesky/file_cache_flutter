import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/settings/settings.screen.dart';
import 'package:philgo/screens/theme/theme.preview.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/widgets/home/user.stats.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Top SafeArea
        SafeArea(child: Container()),

        /// Menu title with settings button
        Container(
          // 메뉴 타이틀 배경색 - primaryContainer 사용
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              /// My Page title
              Text(
                'Menu',
                // primaryContainer 위에서 잘 보이도록 onPrimaryContainer 사용
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const Spacer(),

            ],
          ),
        ),

        /// Scrollable content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                if (Config.isJaeho)
                  ListTile(
                    title: Text('Design Preview'),
                    trailing: FaIcon(
                      FontAwesomeIcons.lightChevronRight,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      context.push(ThemePreviewScreen.routeName);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
