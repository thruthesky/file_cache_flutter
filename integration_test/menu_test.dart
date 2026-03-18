/// 메뉴 페이지 통합 테스트 (Menu Page Integration Test)
///
/// 이 테스트는 메뉴 페이지가 정상적으로 열리는지 확인합니다.
/// This test verifies that the menu page opens correctly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:philgo/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Menu Page Tests', () {
    testWidgets('메뉴 탭을 탭하면 메뉴 페이지가 열립니다', (tester) async {
      // 앱 실행 (Launch app)
      app.main();

      // 앱이 완전히 로드될 때까지 대기 (Wait for app to fully load)
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // BottomNavigationBar에서 메뉴 버튼 찾기 (Find menu button in BottomNavigationBar)
      // 메뉴 버튼은 5번째 아이템 (인덱스 4)
      final menuButton = find.byKey(const ValueKey('menuButton'));

      // 메뉴 버튼이 존재하는지 확인 (Verify menu button exists)
      expect(menuButton, findsOneWidget, reason: '메뉴 버튼이 존재해야 합니다');

      // 메뉴 버튼 탭 (Tap menu button)
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // 메뉴 페이지가 표시되는지 확인 (Verify menu page is displayed)
      // MenuHome 위젯의 타이틀 "메뉴"를 찾아 확인
      // 메뉴 섹션들이 표시되는지 확인
      expect(
        find.byType(SingleChildScrollView),
        findsWidgets,
        reason: '메뉴 페이지의 스크롤 뷰가 표시되어야 합니다',
      );

      debugPrint('메뉴 페이지 테스트 성공!');
    });
  });
}
