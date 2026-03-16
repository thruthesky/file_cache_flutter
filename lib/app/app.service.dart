import 'package:flutter/cupertino.dart';

class AppService {
  static AppService instance = AppService._();

  AppService._();

  late BuildContext context;
  bool isInitialized = false;

  void initialize({required BuildContext context}) {
    if (isInitialized) return;
    isInitialized = true;
    this.context = context;
  }
}
