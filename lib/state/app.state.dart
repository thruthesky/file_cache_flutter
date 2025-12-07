// The global state for the app
// @Attension: Follow the state management rules
//   1. The state must be changed in multiple paces.
//   2. The state must be used in multiples places (on the screen)
// Or it should be globals.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:philgo/router.dart';
import 'package:provider/provider.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class AppState extends ChangeNotifier {
  //
  static AppState of(BuildContext context, {bool listen = false}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  // User information
  String uid = '';
  String phoneNumber = '';
  User? user;
  int idx = 0;

  // Locale (언어 설정)
  Locale? _locale;

  static const List<String> supportedLanguageCodes = ['en', 'ko', 'ja', 'zh'];

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void initializeLocaleFromDevice() {
    if (_locale != null) {
      return;
    }

    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final deviceLanguageCode = deviceLocale.languageCode;

    if (supportedLanguageCodes.contains(deviceLanguageCode)) {
      _locale = Locale(deviceLanguageCode);
    } else {
      _locale = const Locale('ko');
    }

    notifyListeners();
  }

  void setFirebaseLogin(String uid, String phoneNumber) {
    uid = uid;
    phoneNumber = phoneNumber;
    notifyListeners();
  }

  void setPhilgoLogin(int idx) {
    idx = idx;
    notifyListeners();
  }

  void setLogout() {
    uid = '';
    phoneNumber = '';
    idx = 0;
    notifyListeners();
  }

  String get getUid => uid;

  void setUser(User user) {
    this.user = user;
    notifyListeners();
  }

  void deletePhotoUrl() {
    // photoUrl을 빈 문자열로 설정
    if (user != null) {
      user!.photoUrl = '';
      // User 객체를 새로 할당하여 참조 변경 (선택적, 더 확실한 변경 감지를 위해)
      // user = User.fromJson(user!.toJson());
      notifyListeners();
    }
  }
}

User get login => AppState.of(globalContext, listen: false).user!;
