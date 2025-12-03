import 'package:flutter/material.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/entry/entry.login.screen.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo/widgets/theme/comic_button.dart';

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
              // rotating: 회전 애니메이션, pulsing: 크기 펄스 애니메이션
              const PhilGoLogoTriangles(
                size: 180,
                animated: true,
                rotating: true,
                pulsing: true,
              ),
              // 로고와 앱 타이틀 사이 간격
              const SizedBox(height: 24),
              // App title - 앱 이름 (다국어 지원)
              // headlineMedium 사용하여 1.2배 정도 크기 증가
              Text(
                Lo.of(context)!.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              // App description - 앱 슬로건 (다국어 지원)
              // bodyMedium 사용하여 1.2배 정도 크기 증가
              Text(
                Lo.of(context)!.appSlogan,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              // 로그인 버튼 - Comic 스타일 디자인 (large 텍스트, pill 형태)
              // ComicButton 위젯을 사용하여 재사용 가능한 Comic 스타일 버튼 적용
              // customPadding: 좌우 패딩을 더 넓게 (48), 상하는 large 기준 유지 (20)
              ComicButton(
                rounded: ComicButtonRounded.full,
                textSize: ComicButtonTextSize.large,
                customPadding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
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
                child: Text(Lo.of(context)!.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
