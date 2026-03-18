import 'package:flutter/cupertino.dart';
import 'package:philgo/setting/setting.service.dart';

class AppService {
  static AppService instance = AppService._();

  AppService._();

  late BuildContext context;
  bool isInitialized = false;

  void initialize({required BuildContext context}) {
    if (isInitialized) return;
    isInitialized = true;
    this.context = context;

    // v7 설정 로드 및 10분 주기 갱신
    SettingService.instance.initialize(context);
  }
}
