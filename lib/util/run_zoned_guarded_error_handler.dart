import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:philgo/router.dart';
import 'package:philgo/util/app.exception.dart';
import 'package:philgo/util/util.functions.dart';

///
///
void runZoneGuardedErrorHandler(dynamic e, StackTrace stackTrace) {
  log("----> runZoneGuarded() : Exceptions outside flutter framework.");
  log("--------------------------------------------------------------");
  log("---> runtimeType: ${e.runtimeType}");

  if (e is FirebaseAuthException) {
    String message = "${e.code} - ${e.message}";
    if (e.code == 'invalid-email') {
      message = '잘못된 이메일 주소입니다.';
    } else if (e.code == 'weak-password') {
      message = '비밀번호를 더 어렵게 해 주세요. 대소문자, 숫자 및 특수문자를 포함하여 6자 이상으로 입력해주세요.';
    } else if (e.code == 'email-already-in-use') {
      message = '메일 주소 또는 비밀번호를 잘못 입력하였습니다.';
    }
    showErrorSnackBar(globalContext, '로그인 에러 :  $message');
  } else if (e is FirebaseException) {
    if (e.code == 'unknown') {
      /// 알수 없는 에러 메시지는 사용자에게 보여주지 않는다.
      /// 예) firebase_messaging/unknown 에러가
      log("FirebaseException :  $e }");
    } else {
      log("FirebaseException :  $e }");
      showErrorSnackBar(globalContext, "에러: ${e.code}$e");
    }
  } else if (e is PlatformException) {
    /// 앱이 최초(처음) 시작 할 때, (특히, 아이폰 실제 장치를 맥북에 연결시켜, 맥북 인터넷을 사용하는 경우,)
    /// 인터넷 접속이 안되어져 있다는 메시지가 나온다.
    /// 인터넷 연결이 안됨 에러는, 이상하게 아래와 같이 에러 코드가 숫자 35 이다.
    /// PlatformException(35, Error performing request because the internet connection appears to be offline.
    ///
    if (e.code == 'OFFLINE_CONNECTION_ERROR' ||
        (int.tryParse(e.code) ?? 0) == 35) {
      showErrorSnackBar(globalContext, '인터넷 접속: 인터넷 연결을 확인해주세요.');
    } else {
      log("PlatformException :  $e");
      showErrorSnackBar(globalContext, "에러: ${e.code}$e");
    }
  } else if (e is AppException) {
    log("Exception :  $e");
    showErrorSnackBar(globalContext, "에러: ${e.title} - ${e.message}");
  } else {
    log("--> Unknown Error : Not handled in runZoneGuardedErrorHandler :  $e");
    showErrorSnackBar(globalContext, "알 수 없는 에러: ${e.toString()}");
  }

  debugPrintStack(stackTrace: stackTrace);
}
