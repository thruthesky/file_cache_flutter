import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'
    as kakao_sdk;
import 'package:philgo/api/api.service.dart';
import 'package:philgo/user/merge/merge_account.service.dart';
import 'package:philgo/user/user.model.dart';

/// 카카오 로그인 버튼 (공식 디자인 가이드: 배경 #FEE500, 텍스트 #191919)
class KakaoSignInButton extends StatelessWidget {
  final bool loading;
  final ValueChanged<bool>? onLoadingChanged;

  const KakaoSignInButton({
    super.key,
    required this.loading,
    this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: loading ? null : () => _signInWithKakao(context),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE500),
          borderRadius: BorderRadius.circular(12),
        ),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF191919),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 카카오 말풍선 아이콘
                  FaIcon(
                    FontAwesomeIcons.comment,
                    size: 20,
                    color: const Color(0xFF191919).withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '카카오로 로그인'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF191919).withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 카카오톡 소셜 로그인 + Firebase Custom Token + v7 user.socialLogin 등록
  Future<void> _signInWithKakao(BuildContext context) async {
    onLoadingChanged?.call(true);
    try {
      kakao_sdk.OAuthToken token;
      final isInstalled = await kakao_sdk.isKakaoTalkInstalled();
      debugPrint('카카오톡 앱 설치 여부: $isInstalled');
      final keyHash = await kakao_sdk.KakaoSdk.origin;
      debugPrint('카카오 Android keyHash: $keyHash');
      if (isInstalled) {
        try {
          token = await kakao_sdk.UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          debugPrint('카카오톡 앱 로그인 실패, 웹 로그인으로 폴백: $e');
          if (e is PlatformException && e.code == 'CANCELED') rethrow;
          token = await kakao_sdk.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao_sdk.UserApi.instance.loginWithKakaoAccount();
      }

      final customTokenRes = await ApiService.instance.v7api(
        'user.kakaoFirebaseToken',
        data: {'kakao_access_token': token.accessToken},
      );
      final customToken = customTokenRes['custom_token'] as String;

      await FirebaseAuth.instance.signInWithCustomToken(customToken);

      final json = await ApiService.instance.v7api(
        'user.socialLogin',
        data: {'login_provider': 'kakao'},
      );

      // 아이디 합치기 감지: Custom Token으로 v6 계정 전환
      final merged = await MergeAccountService.handleMergedLogin(
        json,
        loginProvider: 'kakao',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('카카오 로그인 성공!'.tr())));
        context.pop();
      }
      if (merged) {
        final meJson = await ApiService.instance.v7api('user.me');
        UserModel.fromJson(meJson);
      }
    } catch (e) {
      debugPrint('카카오 로그인 에러: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 에러 :  $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      onLoadingChanged?.call(false);
    }
  }
}
