import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:philgo/main.dart' as app;

void main() {
  // run philgo app
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Open a menu screen and take a screenshot', (tester) async {
      // 앱 실행
      app.main();

      // Wait for the app to fully load (3 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Press 'menuButton' key of the BottomNavigationBar
      final menuButton = find.byKey(ValueKey('menuButton'));
      expect(menuButton, findsOneWidget, reason: 'Menu 버튼을 찾을 수 없습니다');
      await tester.tap(menuButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}
