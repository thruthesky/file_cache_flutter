import 'package:flutter_driver/driver_extension.dart';
import 'package:philgo/main.dart' as app;

void main() {
  // Flutter Driver Extension 활성화
  // 이것이 있어야 외부에서 앱을 제어할 수 있음
  enableFlutterDriverExtension();
  
  // 원래 앱 실행
  app.main();
}