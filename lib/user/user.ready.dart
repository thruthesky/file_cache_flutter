import 'package:flutter/material.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

class UserReady extends StatelessWidget {
  const UserReady({super.key, this.yes, this.no})
    : assert(yes != null || no != null, 'yes 또는 no 중 하나는 반드시 제공되어야 합니다.');

  final Widget Function(BuildContext, UserModel)? yes;
  final Widget Function(BuildContext)? no;

  @override
  Widget build(BuildContext context) {
    return Selector<UserState, UserModel?>(
      selector: (context, userState) => userState.user,
      builder: (context, user, child) {
        if (user == null) {
          return no?.call(context) ?? const SizedBox.shrink();
        } else {
          return yes?.call(context, user) ?? const SizedBox.shrink();
        }
      },
    );
  }
}
