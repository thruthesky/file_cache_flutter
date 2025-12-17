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

  PhilgoState() {
    _init();
  }

  void _init() async {
    setting = await PhilgoService.instance.loadSetting();
    notifyListeners();

    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        user = await philgoApiUserVerify();
        notifyListeners();
      } else {
        user = null;
        notifyListeners();
      }
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

  //
  static PhilgoState of(BuildContext context, {bool listen = false}) {
    return Provider.of<PhilgoState>(context, listen: listen);
  }
}
