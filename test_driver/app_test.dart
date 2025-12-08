import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  late FlutterDriver driver;

  setUpAll(() async {
    // Driver 연결
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    // Driver 연결 해제
    await driver.close();
  });

  test('탭 테스트', () async {
    // 텍스트로 위젯 찾기
    final button = find.text('로그인');
    await driver.tap(button);
    
    // 결과 확인
    final result = find.text('환영합니다');
    await driver.waitFor(result);
  });
}