import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/login/user.login.screen.dart';

/// 로그인이 필요할 때 표시하는 다이얼로그
///
/// 취소 버튼과 로그인 버튼을 제공한다.
/// 로그인 버튼을 누르면 로그인 화면으로 이동한다.
class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  /// 다이얼로그를 표시한다.
  ///
  /// 로그인 버튼을 누르면 true를 반환하고 로그인 화면으로 이동한다.
  /// 취소 버튼을 누르면 false를 반환한다.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const LoginRequiredDialog(),
    );
    if (result == true && context.mounted) {
      UserLoginScreen.push(context);
    }
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Center(
        child: FaIcon(
          FontAwesomeIcons.lightCircleUser,
          size: 48,
          color: color.primary,
        ),
      ),
      // "Login required"
      title: Text('로그인이 필요합니다'.tr()),
      content: Text(
        // "Login to access all features"
        '로그인하여 모든 기능을 이용하세요'.tr(),
        textAlign: TextAlign.center,
        style: text.bodyMedium?.copyWith(color: color.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          // "Cancel"
          child: Text('취소'.tr()),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          // "Login"
          child: Text('로그인'.tr()),
        ),
      ],
    );
  }
}
