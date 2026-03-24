import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:philgo/api/api.service.dart';

import 'merge_account.model.dart';

/// 아이디 합치기 서비스
///
/// v7 소셜 계정을 v6 전화번호 계정으로 병합하는 API를 호출한다.
class MergeAccountService {
  /// v6 계정 검색 (user.findV6Account)
  ///
  /// [phoneNumber] E.164 포맷 전화번호 (예: +821012345678)
  static Future<V6AccountPreview> findV6Account({
    required String phoneNumber,
  }) async {
    final json = await ApiService.instance.v7api(
      'user.findV6Account',
      data: {'phone_number': phoneNumber},
    );
    return V6AccountPreview.fromJson(json);
  }

  /// 아이디 합치기 실행 (user.mergeAccount)
  ///
  /// [phoneIdToken] Firebase Phone Auth로 받은 ID Token
  static Future<void> mergeAccount({
    required String phoneIdToken,
  }) async {
    await ApiService.instance.v7api(
      'user.mergeAccount',
      data: {'phone_id_token': phoneIdToken},
    );
  }

  /// 소셜 로그인 후 merged 상태 처리
  ///
  /// socialLogin 응답에서 status == 'merged'이면 Custom Token으로
  /// v6 계정으로 전환 후 재로그인한다.
  ///
  /// [loginResult] v7api('user.socialLogin') 응답
  /// [loginProvider] 소셜 로그인 제공자 (kakao, google 등)
  /// 반환: merged 처리를 했으면 true, 일반 로그인이면 false
  static Future<bool> handleMergedLogin(
    Map<String, dynamic> loginResult, {
    String? loginProvider,
  }) async {
    if (loginResult['status'] != 'merged' ||
        loginResult['custom_token'] == null) {
      return false;
    }

    final customToken = loginResult['custom_token'] as String;
    log('아이디 합치기 감지: Custom Token으로 v6 계정 전환');

    // v6 계정으로 전환
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInWithCustomToken(customToken);

    // v6 계정으로 재로그인
    final data = <String, dynamic>{};
    if (loginProvider != null) {
      data['login_provider'] = loginProvider;
    }
    await ApiService.instance.v7api('user.socialLogin', data: data);

    log('v6 계정으로 전환 완료');
    return true;
  }

  /// 전화번호를 E.164 포맷으로 변환
  ///
  /// [countryCode] 국가 코드 (예: 82)
  /// [phoneNumber] 전화번호 (예: 01012345678)
  static String formatE164(String countryCode, String phoneNumber) {
    // 숫자만 추출
    final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final code = countryCode.replaceAll(RegExp(r'[^0-9]'), '');

    // 앞의 0 제거
    final number = digits.startsWith('0') ? digits.substring(1) : digits;

    return '+$code$number';
  }
}
