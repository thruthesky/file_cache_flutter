import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/user/user.model.dart';

/// 네이버 로그인 버튼 (공식 디자인 가이드: 배경 #03C75A, 텍스트 #FFFFFF)
class NaverSignInButton extends StatefulWidget {
  final bool loading;

  const NaverSignInButton({super.key, required this.loading});

  @override
  State<NaverSignInButton> createState() => _NaverSignInButtonState();
}

class _NaverSignInButtonState extends State<NaverSignInButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.loading || _isProcessing;

    return GestureDetector(
      onTap: isDisabled ? null : _signInWithNaver,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF03C75A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isDisabled
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.n,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '네이버로 로그인'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 네이버 소셜 로그인 + Firebase Custom Token + v7 user.socialLogin 등록
  Future<void> _signInWithNaver() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final result = await FlutterNaverLogin.logIn();
      debugPrint('네이버 로그인 결과: ${result.status}');

      if (result.status == NaverLoginStatus.error) {
        throw Exception('네이버 로그인 실패: ${result.errorMessage}');
      }

      final accessToken = result.accessToken?.accessToken ?? '';
      if (accessToken.isEmpty) {
        throw Exception('네이버 access_token을 가져올 수 없습니다.');
      }
      debugPrint('네이버 access_token 획득 완료');

      final customTokenRes = await ApiService.instance.v7api(
        'user.naverFirebaseToken',
        data: {'naver_access_token': accessToken},
      );
      final customToken = customTokenRes['custom_token'] as String;

      await FirebaseAuth.instance.signInWithCustomToken(customToken);

      final json = await ApiService.instance.v7api(
        'user.socialLogin',
        data: {'login_provider': 'naver'},
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('네이버 로그인 성공!'.tr())));
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
