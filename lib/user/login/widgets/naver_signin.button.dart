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
class NaverSignInButton extends StatelessWidget {
  final bool loading;

  const NaverSignInButton({super.key, required this.loading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: loading ? null : () => _signInWithNaver(context),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF03C75A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: loading
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
  ///
  /// 1. 네이버 SDK로 로그인 (앱 설치 시 앱 로그인, 미설치 시 웹 로그인)
  /// 2. v7 서버에 access_token 전송 → Firebase Custom Token 발급
  /// 3. Firebase signInWithCustomToken()으로 Firebase 로그인
  /// 4. v7 user.socialLogin 호출하여 DB 등록/업데이트
  Future<UserModel> _signInWithNaver(BuildContext context) async {
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

    // v7 API로 Firebase Custom Token 발급
    final customTokenRes = await ApiService.instance.v7api(
      'user.naverFirebaseToken',
      data: {'naver_access_token': accessToken},
    );
    final customToken = customTokenRes['custom_token'] as String;

    // Firebase 로그인
    await FirebaseAuth.instance.signInWithCustomToken(customToken);

    // v7 소셜 로그인 등록
    final json = await ApiService.instance.v7api(
      'user.socialLogin',
      data: {'login_provider': 'naver'},
    );

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('네이버 로그인 성공!'.tr())));
      context.pop();
    }
    return UserModel.fromJson(json);
  }
}
