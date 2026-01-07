1. 누가 (Who)
개발자가 직접 하드코딩하여 입력
2. 무엇을 (What)
_ContactItem 클래스로 정의된 연락처 정보:

긴급 핫라인 (911)
필리핀 국립경찰 (PNP) - 117
필리핀 소방청 (BFP) - 116
앰뷸런스
대사관 연락처 (추정)
병원 연락처 등
3. 어디에 (Where)
📁 lib/screens/info/emergency/emergency_contact.screen.dart

5. 어떻게
사용자 탭 → EmergencyContactScreen 진입 → _emergencyNumbers 리스트 렌더링

4. 언제 (When)
시점	설명
컴파일 타임	static const로 선언되어 앱 빌드 시 바이너리에 포함
런타임	화면 진입 시 즉시 접근 가능 (별도 로딩 불필요)

6. 왜 (Why)
✅ 오프라인 접근성: 인터넷 없이도 긴급 연락처 확인 가능
✅ 빠른 로딩: 서버 요청 없이 즉시 표시
✅ 안정성: 외부 의존성 없음
⚠️ 개선 제안
현재 구조의 단점과 개선 방안:

현재	개선안
State 클래스 내부에 데이터 혼재	별도 데이터 파일로 분리
업데이트 시 앱 재배포 필요	Firebase Remote Config 활용

---

누가: _EmergencyContactScreenState가 대사관/경찰/병원 연락처 데이터를 보유하고 렌더링합니다 (emergency_contact.screen.dart (line 64)).
언제: 사용자가 긴급 연락처 화면에 진입할 때 build에서 각 목록을 화면에 구성합니다 (emergency_contact.screen.dart (line 340)).
어디서: 대사관은 _koreanEmbassy, 경찰은 _policeStations, 병원은 _hospitals에 각각 기록되어 있습니다 (emergency_contact.screen.dart (line 107), emergency_contact.screen.dart (line 183), emergency_contact.screen.dart (line 243)).
무엇을: 각 항목은 _ContactItem에 이름/전화번호/설명/주소/이메일/웹사이트 등을 담아 저장합니다 (emergency_contact.screen.dart (line 12)).
왜: 필리핀 생활 중 긴급·안전 정보를 한 화면에서 바로 확인·통화할 수 있게 제공하기 위해서입니다 (emergency_contact.screen.dart (line 52)).
어떻게: 정적 상수 리스트(static const List<_ContactItem>)로 하드코딩된 데이터를 섹션별로 _buildContactCards로 출력합니다 (emergency_contact.screen.dart (line 66), emergency_contact.screen.dart (line 371)).