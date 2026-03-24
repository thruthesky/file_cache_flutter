import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/login/widgets/apple_signin.button.dart';
import 'package:philgo/user/login/widgets/google_signin.button.dart';
import 'package:philgo/user/login/widgets/kakao_signin.button.dart';
import 'package:philgo/user/login/widgets/naver_signin.button.dart';

class UserLoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  bool isLoading = false;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        backgroundColor: color.surface,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.lightChevronLeft,
            size: 18,
            color: color.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 로고 & 타이틀
              Column(
                children: [
                  FaIcon(
                        FontAwesomeIcons.lightCircleUser,
                        size: 72,
                        color: color.primary,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 20),
                  Text(
                    // "Welcome to PhilGo"
                    '필고에 오신 것을 환영합니다'.tr(),
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 8),
                  Text(
                    // "Sign in with your social account"
                    '소셜 계정으로 간편하게 로그인하세요'.tr(),
                    style: text.bodyMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                ],
              ),

              const Spacer(),

              // 카카오 로그인 버튼
              KakaoSignInButton(loading: isLoading)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              // 네이버 로그인 버튼
              NaverSignInButton(loading: isLoading)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 225.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              // Google 로그인 버튼
              GoogleSignInButton(loading: isLoading)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 250.ms)
                  .slideY(begin: 0.2, end: 0),

              // Apple 로그인 버튼 (iOS/iPad만 표시)
              if (Platform.isIOS) ...[
                const SizedBox(height: 12),
                AppleSignInButton(loading: isLoading)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0),
              ],

              const SizedBox(height: 24),

              // 이용약관 & 개인정보처리방침
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _openUrl('https://philgo.com/help/terms'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.lightFileContract, size: 13, color: color.primary),
                        const SizedBox(width: 4),
                        Text(
                          // "Terms of Service"
                          '이용약관'.tr(),
                          style: text.bodySmall?.copyWith(
                            color: color.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('|', style: text.bodySmall?.copyWith(color: color.onSurfaceVariant)),
                  ),
                  GestureDetector(
                    onTap: () => _openUrl('https://philgo.com/help/privacy'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.lightShieldHalved, size: 13, color: color.primary),
                        const SizedBox(width: 4),
                        Text(
                          // "Privacy Policy"
                          '개인정보처리방침'.tr(),
                          style: text.bodySmall?.copyWith(
                            color: color.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
