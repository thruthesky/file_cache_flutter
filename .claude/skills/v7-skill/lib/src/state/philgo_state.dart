// The global state for the app
// @Attension: Follow the state management rules
//   1. The state must be changed in multiple paces.
//   2. The state must be used in multiples places (on the screen)
// Or it should be globals.dart
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:philgo_api/philgo_api.dart';

class PhilgoState extends ChangeNotifier {
  PhilgoSetting? setting;
  User? user;
  bool loading = true;

  PhilgoState() {
    _init();
  }

  void _init() async {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        user = await philgoApiUserVerify();
      } else {
        user = null;
      }
      loading = false;
      notifyListeners();
    });

    PhilgoService.instance.loadSetting().then((loadedSetting) {
      setting = loadedSetting;
      notifyListeners();
    });
  }

  void setUser(User user) {
    this.user = user;
    notifyListeners();
  }

  /// Update user's point balance
  void setUserPoints(int newPoints) {
    if (user == null) return;

    user = User(
      uid: user!.uid,
      idx: user!.idx,
      nickname: user!.nickname,
      nicknameLowerCase: user!.nicknameLowerCase,
      photoUrl: user!.photoUrl,
      level: user!.level,
      point: newPoints, // Updated point value
      noOfComment: user!.noOfComment,
      noOfPost: user!.noOfPost,
      name: user!.name,
      gender: user!.gender,
      birthDay: user!.birthDay,
      birthMonth: user!.birthMonth,
      birthYear: user!.birthYear,
    );
    notifyListeners();
  }

  /// 현재 로그인 사용자가 관리자인지 확인 (Check if current user is admin)
  ///
  /// 관리자(운영자)는 글쓰기와 댓글 작성이 제한됨
  /// setting.adminUids 목록에 현재 사용자의 UID가 포함되어 있으면 관리자
  bool get isAdmin {
    if (user == null || setting == null) return false;
    return setting!.adminUids.contains(user!.uid);
  }

  //
  static PhilgoState of(BuildContext context, {bool listen = false}) {
    return Provider.of<PhilgoState>(context, listen: false);
  }
}
