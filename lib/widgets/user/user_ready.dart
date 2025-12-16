import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:philgo_api/philgo_api.dart';

/// UserReady 위젯은 PhilgoState 에서 user 정보가 준비될 때까지 로딩 인디케이터를 보여주고,
/// user 정보가 준비되면 builder 함수를 호출하여 실제 UI를 렌더링한다.
///
/// [init] 사용자 정보를 가져온 경우, 한번만 호출되는 함수. 사용자에 값이 있는 경우에만 호출된다.
/// [builder] user 정보가 준비된 후에 호출되는 빌더 함수. 이 함수는 사용자 정보가 업데이트 될 때마다, notifyListeners() 함수에 의해서, 호출되어, 지속적으로 rebuild 될 수 있다.
///
/// NOTE:
/// - 이 위젯은 사용자 정보가 업데이트 될 때 마다 builder() 를 rebuild 한다.
/// - 그래서, 이 위젯 하위에서 Selector< PhilgoState, User? >(...) 와 같이 할 필요가 없이, 이 함수의 콜백이 전달하는 user 를 사용하면 된다.
class UserReady extends StatefulWidget {
  const UserReady({super.key, required this.builder, this.init});

  final Widget Function(BuildContext context, User) builder;
  final Future<void> Function(BuildContext context, User)? init;

  @override
  State<UserReady> createState() => _UserReadyState();
}

class _UserReadyState extends State<UserReady> {
  bool _initialized = false;
  @override
  Widget build(BuildContext context) {
    return Selector<PhilgoState, User?>(
      selector: (_, state) => state.user,
      builder: (_, user, _) {
        if (user == null) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        if (!_initialized && widget.init != null) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await widget.init!(context, user);
          });
        }
        return widget.builder(context, user);
      },
    );
  }
}
