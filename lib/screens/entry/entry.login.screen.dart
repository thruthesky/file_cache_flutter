import 'package:flutter/material.dart';
import 'package:easy_phone_sign_in/easy_phone_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/dialogs/policy.dialogs.dart';
import 'package:philgo/widgets/layout/content_container.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo/widgets/unfocus_on_tap.dart';
import 'package:philgo_api/philgo_api.dart';

class EntryLoginScreen extends StatefulWidget {
  const EntryLoginScreen({super.key});

  @override
  State<EntryLoginScreen> createState() => _EntryLoginScreenState();
}

class _EntryLoginScreenState extends State<EntryLoginScreen> {
  bool compact = false;
  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return UnfocusOnTap(
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: null),
        body: SingleChildScrollView(
          child: ContentContainer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    sp.s32,
                    compact ? 0 : sp.s40,
                    sp.s32,
                    sp.s32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PhilGo 로고 - 세 개의 삼각형 조합
                      // animated: 등장 애니메이션, rotating: 회전, pulsing: 크기 펄스
                      // 불필요한 래퍼(AnimatedScale, Hero 등) 제거하여 자체 애니메이션 활용
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: PhilGoLogoTriangles(
                          size: 100,
                          animated: true,
                          rotating: true,
                          pulsing: true,
                        ),
                      ),

                      if (compact == false) SizedBox(height: sp.s24),

                      Theme(
                        data: Theme.of(context).copyWith(
                          elevatedButtonTheme: ElevatedButtonThemeData(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              padding: EdgeInsets.symmetric(
                                vertical: sp.s16,
                                horizontal: sp.s24,
                              ),
                              textStyle: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: scheme.onPrimary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        child: PhoneSignIn(
                          onCompletePhoneNumber: (String phoneNumber) {
                            // 로컬 입력을 E.164 국제 형식으로 변환
                            // 한국: '10'으로 시작 → +82 추가
                            if (phoneNumber.startsWith('10')) {
                              return '+82$phoneNumber';
                            }
                            // 필리핀: '9'로 시작 → +63 추가
                            else if (phoneNumber.startsWith('9')) {
                              return '+63$phoneNumber';
                            }
                            return phoneNumber;
                          },
                          onValidatePhoneNumber: (String phoneNumber) {
                            return _validatePhoneNumber(context, phoneNumber);
                          },
                          onSignInSuccess: _onSignInSuccess,
                          onSignInFailed: _onSignInFailed,
                          specialAccounts: const SpecialAccounts(
                            reviewEmail: 'review@email.com',
                            reviewPassword: '12345zB,*c',
                            reviewPhoneNumber: '+11234567890',
                            reviewSmsCode: '123456',
                            emailLogin: true,
                          ),
                          labelPhoneNumber: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              Lo.of(context)!.enterPhoneNumber,
                              style: TextStyle(color: scheme.secondary),
                            ),
                          ),
                          // SMS 입력 단계에서 전화번호 라벨 (fontWeight: normal)
                          labelUnderPhoneNumberTextField: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              Lo.of(context)!.phoneNumberExample,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          labelPhoneNumberSelected: Text(
                            Lo.of(context)!.phoneNumber,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.normal),
                          ),
                          labelOnSmsCodeTextField: Text(
                            Lo.of(context)!.enterSmsCode,
                          ),
                          hintTextSmsCodeTextField: Lo.of(
                            context,
                          )!.enterSmsCode,
                          labelRetry:
                              // SMS 재 전송 버튼을 표시하지 않음
                              SizedBox.shrink(),
                          // Text(
                          // Lo.of(context)!.resendSms,
                          // ),
                          labelVerifySmsCodeButton: Text(
                            Lo.of(context)!.verifySmsCode,
                          ),
                          labelVerifyPhoneNumberButton: Text(
                            Lo.of(context)!.sendSmsCode,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.w300,
                                ),
                          ),
                          hintTextPhoneNumberTextField: Lo.of(
                            context,
                          )!.phoneNumber,
                          onFocusPhoneNumberTextField: () {
                            setState(() {
                              compact = true;
                            });
                          },
                          onUnfocusPhoneNumberTextField: () {
                            setState(() {
                              compact = false;
                            });
                          },
                          onFocusSmsCodeTextField: () {
                            setState(() {
                              compact = true;
                            });
                          },
                          onUnfocusSmsCodeTextField: () {
                            setState(() {
                              compact = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 개인정보 처리 방침 & 이용약관 버튼 - bottomNavigationBar 영역에 배치
        // SafeArea로 감싸서 기기의 하단 안전 영역 확보
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: sp.s8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 개인정보 처리 방침 버튼 (Privacy Policy button)
                TextButton.icon(
                  onPressed: () async {
                    await showPrivacyPolicy(context);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s12,
                      vertical: sp.s8,
                    ),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.userShield, size: 14),
                  label: Text(
                    Lo.of(context)!.privacyPolicy,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SizedBox(width: sp.s12),
                // 이용약관 버튼 (Terms of Service button)
                TextButton.icon(
                  onPressed: () async {
                    await showTermsAndConditions(context);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s12,
                      vertical: sp.s8,
                    ),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.fileLines, size: 14),
                  label: Text(
                    Lo.of(context)!.termsOfService,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 전화번호 검증: 한국/필리핀 번호만 허용, +1은 화이트리스트만 허용
  ///
  /// 허용 규칙:
  /// - +82 (한국) → 무조건 허용
  /// - +63 (필리핀) → 무조건 허용
  /// - +1 (미국/캐나다) → 화이트리스트에 등록된 번호만 허용
  /// - 그 외 모든 국가 → 차단
  ///
  /// null 반환 시 유효, String 반환 시 에러 메시지
  static String? _validatePhoneNumber(
    BuildContext context,
    String phoneNumber,
  ) {
    // 한국 (+82) 번호 → 허용
    if (phoneNumber.startsWith('+82')) return null;

    // 필리핀 (+63) 번호 → 허용
    if (phoneNumber.startsWith('+63')) return null;

    // +1 (미국/캐나다) 번호 → 화이트리스트만 허용
    if (phoneNumber.startsWith('+1')) {
      const allowedNumbers = {
        '+11234567890',
        '+11111111111',
        '+12222222222',
        '+13333333333',
        '+14444444444',
        '+15555555555',
        '+16666666666',
        '+17777777777',
      };
      if (allowedNumbers.contains(phoneNumber)) return null;
      return Lo.of(context)!.phoneNumberNotAllowed;
    }

    // 그 외 국가 → 차단
    return Lo.of(context)!.phoneNumberNotAllowed;
  }

  void _onSignInSuccess() {
    // 로그인 성공 시 홈 탭으로 네비게이션 상태 초기화
    NavigationState.of(
      context,
      listen: false,
    ).setHomeNavigation(HomeNavigationItem.home);
    context.go(HomeScreen.routeName);
  }

  void _onSignInFailed(FirebaseAuthException error) {
    showErrorSnackBar(
      context,
      error.message ?? Lo.of(context)!.phoneAuthFailed,
    );
  }
}
