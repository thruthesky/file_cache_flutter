import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/user/merge/merge_account.service.dart';
import 'package:philgo/user/user.model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple 로그인 버튼 (iOS/iPad 전용)
class AppleSignInButton extends StatelessWidget {
  final bool loading;

  const AppleSignInButton({super.key, required this.loading});

  /// SHA256 해시 nonce 생성
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = math.Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// 문자열의 SHA256 해시 반환
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: loading ? null : () => _signInWithApple(context),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: scheme.onSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: loading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.surface,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.apple,
                    size: 22,
                    color: scheme.surface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Apple로 로그인'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.surface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Apple 소셜 로그인 + Firebase Auth + v7 user.socialLogin 등록
  Future<UserModel> _signInWithApple(BuildContext context) async {
    // nonce 생성 (리플레이 공격 방지)
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    // Apple 로그인 요청
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Firebase OAuthCredential 생성
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Firebase 로그인
    await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    log(
      'Apple 로그인 성공, Firebase 인증 완료. UID: ${FirebaseAuth.instance.currentUser?.uid}',
    );

    // v7 소셜 로그인 API 호출
    final json = await ApiService.instance.v7api(
      'user.socialLogin',
      data: {'login_provider': 'apple'},
    );
    log('Apple 로그인 성공: v7 API 응답 수신');

    // 아이디 합치기 감지: Custom Token으로 v6 계정 전환
    final merged = await MergeAccountService.handleMergedLogin(
      json,
      loginProvider: 'apple',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Apple 로그인 성공!'.tr())));
      context.pop();
    }

    if (merged) {
      final meJson = await ApiService.instance.v7api('user.me');
      return UserModel.fromJson(meJson);
    }
    return UserModel.fromJson(json);
  }
}
