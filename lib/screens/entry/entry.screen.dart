import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/entry/entry.login.screen.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';

class EntryScreen extends StatelessWidget {
  static const String routeName = '/entry';
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PhilGo 로고 (세 개의 삼각형)
              const PhilGoLogoTriangles(
                size: 120,
                animated: true,
                rotating: true,
              ),
              // 로고와 앱 타이틀 사이 간격
              const SizedBox(height: 24),
              // App title - 앱 이름 (다국어 지원)
              Text(
                Lo.of(context)!.appName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              // App description - 앱 슬로건 (다국어 지원)
              Text(
                Lo.of(context)!.appSlogan,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              // 로그인 버튼 - Strong visual hierarchy
              ElevatedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.lightRightToBracket, size: 16),
                label: Text(Lo.of(context)!.login),
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(
                      context,
                    ).modalBarrierDismissLabel,
                    barrierColor: Theme.of(
                      context,
                    ).colorScheme.scrim.withValues(alpha: 0.5),
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder:
                        (
                          BuildContext buildContext,
                          Animation animation,
                          Animation secondaryAnimation,
                        ) {
                          return const EntryLoginScreen();
                        },
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                            child: ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                              child: child,
                            ),
                          );
                        },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
