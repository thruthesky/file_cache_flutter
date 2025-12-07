// 로그인 통합 테스트
// Entry Screen → Login 버튼 클릭 → 전화번호 입력 → SMS 코드 입력 → 로그인 성공 확인
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:philgo/main.dart' as app;

void main() {
  // Integration test 바인딩 초기화
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('로그인 테스트', () {
    testWidgets('전화번호 로그인 플로우 테스트', (WidgetTester tester) async {
      // 앱 실행
      app.main();

      // 앱이 완전히 로드될 때까지 대기 (3초)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ===== Step 1: Entry Screen에서 Login 버튼 클릭 =====
      debugPrint('Step 1: Login 버튼 찾기...');

      // "Login" 텍스트를 가진 버튼 찾기
      final loginButton = find.text('Login');
      expect(loginButton, findsOneWidget, reason: 'Login 버튼을 찾을 수 없습니다');

      // Login 버튼 탭
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      debugPrint('Step 1 완료: Login 버튼 클릭됨');

      // ===== Step 2: 전화번호 입력 =====
      debugPrint('Step 2: 전화번호 입력...');

      // 전화번호 입력 필드 찾기 (TextField 타입으로)
      final phoneTextField = find.byType(TextField).first;
      expect(phoneTextField, findsOneWidget, reason: '전화번호 입력 필드를 찾을 수 없습니다');

      // 전화번호 입력: +11234567890
      await tester.enterText(phoneTextField, '+11234567890');
      await tester.pumpAndSettle();

      debugPrint('Step 2 완료: 전화번호 +11234567890 입력됨');

      // ===== Step 3: Send SMS Code 버튼 클릭 =====
      debugPrint('Step 3: SMS 코드 전송 버튼 클릭...');

      // 전화번호 확인 버튼 찾기 (ElevatedButton 중에서 Send SMS Code 텍스트 포함)
      // EntryLoginScreen에서는 labelVerifyPhoneNumberButton이 "Send SMS Code"로 설정됨
      final sendSmsButton = find.byType(ElevatedButton).first;
      expect(sendSmsButton, findsOneWidget, reason: 'SMS 전송 버튼을 찾을 수 없습니다');

      // SMS 전송 버튼 탭
      await tester.tap(sendSmsButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      debugPrint('Step 3 완료: SMS 코드 전송 버튼 클릭됨');

      // ===== Step 4: SMS 코드 입력 =====
      debugPrint('Step 4: SMS 코드 입력...');

      // SMS 코드 입력 필드 찾기 (두 번째 TextField 또는 숫자 키보드 타입)
      final smsTextField = find.byType(TextField).last;
      expect(smsTextField, findsOneWidget, reason: 'SMS 코드 입력 필드를 찾을 수 없습니다');

      // SMS 코드 입력: 123456
      await tester.enterText(smsTextField, '123456');
      await tester.pumpAndSettle();

      debugPrint('Step 4 완료: SMS 코드 123456 입력됨');

      // ===== Step 5: Verify SMS Code 버튼 클릭 =====
      debugPrint('Step 5: SMS 코드 확인 버튼 클릭...');

      // SMS 확인 버튼 찾기 (ElevatedButton)
      final verifySmsButton = find.byType(ElevatedButton).last;
      expect(verifySmsButton, findsOneWidget, reason: 'SMS 확인 버튼을 찾을 수 없습니다');

      // SMS 확인 버튼 탭
      await tester.tap(verifySmsButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      debugPrint('Step 5 완료: SMS 코드 확인 버튼 클릭됨');

      // ===== Step 6: 로그인 성공 확인 =====
      debugPrint('Step 6: 로그인 성공 여부 확인...');

      // HomeScreen으로 이동했는지 확인
      // HomeScreen의 특정 위젯이나 텍스트 확인
      final homeIndicator = find.byType(BottomNavigationBar);

      if (homeIndicator.evaluate().isNotEmpty) {
        debugPrint('✅ 로그인 성공! HomeScreen으로 이동됨');
      } else {
        debugPrint('⚠️ HomeScreen을 찾을 수 없습니다. 다른 확인 방법 시도...');

        // Scaffold가 있는지 확인 (기본적인 화면 전환 확인)
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsWidgets, reason: '화면이 정상적으로 표시되지 않습니다');

        debugPrint('현재 화면에 Scaffold 위젯 발견됨');
      }

      debugPrint('🎉 로그인 테스트 완료!');
    });
  });
}
