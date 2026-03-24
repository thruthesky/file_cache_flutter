import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/user/merge/merge_account.service.dart';
import 'package:philgo/user/user.model.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool loading;
  final ValueChanged<bool>? onLoadingChanged;

  const GoogleSignInButton({
    super.key,
    required this.loading,
    this.onLoadingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: loading ? null : () => _onSignIn(context),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border.all(color: scheme.outlineVariant, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: loading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.google,
                    size: 20,
                    color: scheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Google로 로그인'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Google 소셜 로그인 + v7 user.socialLogin 등록
  Future<void> _onSignIn(BuildContext context) async {
    onLoadingChanged?.call(true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // 사용자가 취소
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      log(
        'Google 로그인 성공, Firebase 인증 완료. UID: ${FirebaseAuth.instance.currentUser?.uid}',
      );

      final json = await ApiService.instance.v7api(
        'user.socialLogin',
        data: {'login_provider': 'google'},
      );
      log('Google 로그인 성공: v7 API 응답 수신');

      // 아이디 합치기 감지: Custom Token으로 v6 계정 전환
      final merged = await MergeAccountService.handleMergedLogin(
        json,
        loginProvider: 'google',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google 로그인 성공!'.tr())));
        context.pop();
      }

      if (merged) {
        final meJson = await ApiService.instance.v7api('user.me');
        UserModel.fromJson(meJson);
      }
    } catch (e) {
      log('Google 로그인 에러: $e');
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
