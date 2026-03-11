import 'package:flutter/cupertino.dart';

class AppService {
  static late BuildContext context;

  static void initialize({required BuildContext context}) {
    AppService.context = context;
  }
}
