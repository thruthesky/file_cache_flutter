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

  //
  static PhilgoState of(BuildContext context, {bool listen = false}) {
    return Provider.of<PhilgoState>(context, listen: listen);
  }
}
