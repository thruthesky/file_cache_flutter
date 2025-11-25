import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Login
///
/// Use this widget to listen to the login user's authentication state changes
/// and rebuild the UI accordingly.
///
/// It simply wraps [FirebaseAuth.instance.authStateChanges] inside a [StreamBuilder].
///
/// [builder] is the UI builder callback that will be called when the user's
/// authentication state changes.
///
class Login extends StatelessWidget {
  const Login({
    super.key,
    required this.builder,
    this.loading,
    this.notLoggedIn,
  });

  final Widget Function(String uid) builder;
  final Widget? loading;
  final Widget? notLoggedIn;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // To reduce the flickering
      initialData: FirebaseAuth.instance.currentUser,
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.hasData == false) {
          return loading ?? const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(LibTr.of(context)!.something_went_wrong),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return notLoggedIn ?? const SizedBox.shrink();
        } else {
          return builder(user.uid);
        }
      },
    );
  }
}
