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
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class EntryLoginScreen extends StatefulWidget {
  const EntryLoginScreen({super.key});

  @override
  State<EntryLoginScreen> createState() => _EntryLoginScreenState();
}

class _EntryLoginScreenState extends State<EntryLoginScreen> {
  bool _animateHeader = false;
  bool _animateForm = false;

  /// SMS 코드 입력 단계인지 여부
  /// true일 때 여백을 줄여서 더 컴팩트한 레이아웃 제공
  bool _isSmsCodeInputStage = false;

  @override
  void initState() {
    super.initState();
    // Staggered entrance animations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _animateHeader = true);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _animateForm = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: null),
      body: Container(
        // Soft gradient using theme colors (no hardcoded colors)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.10),
              scheme.secondaryContainer.withValues(alpha: 0.06),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Main content centered on all screen sizes
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            // SMS 입력 단계에서는 상단 여백을 줄임 (s40 → s32)
                            padding: EdgeInsets.fromLTRB(
                              sp.s32,
                              _isSmsCodeInputStage ? sp.s32 : sp.s40,
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
                                    size: 120,
                                    animated: true,
                                    rotating: true,
                                    pulsing: true,
                                  ),
                                ),
                                // SMS 입력 단계에서는 로고 아래 여백을 줄임 (s24 → s16)
                                SizedBox(
                                  height: _isSmsCodeInputStage ? sp.s16 : sp.s24,
                                ),

                                // PhoneSignIn Widget - full width
                                // SMS 입력 단계에서는 상단 여백을 줄임 (s16 → s8)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: _isSmsCodeInputStage ? sp.s8 : sp.s16,
                                  ),
                                  child: AnimatedSlide(
                                    duration: const Duration(milliseconds: 360),
                                    curve: Curves.easeOutCubic,
                                    offset: _animateForm
                                        ? Offset.zero
                                        : const Offset(0, 0.08),
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 360,
                                      ),
                                      curve: Curves.easeOut,
                                      opacity: _animateForm ? 1 : 0,
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          elevatedButtonTheme:
                                              ElevatedButtonThemeData(
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor:
                                                      scheme.primary,
                                                  foregroundColor:
                                                      scheme.onPrimary,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: sp.s16,
                                                    horizontal: sp.s24,
                                                  ),
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: scheme.onPrimary,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                        ),
                                        child: PhoneSignIn(
                                          onCompletePhoneNumber:
                                              (String phoneNumber) {
                                                // Normalize common local inputs to E.164 by country prefix heuristics
                                                if (phoneNumber.startsWith(
                                                  '10',
                                                )) {
                                                  return '+82$phoneNumber';
                                                } else if (phoneNumber
                                                    .startsWith('9')) {
                                                  return '+63$phoneNumber';
                                                }
                                                return phoneNumber;
                                              },
                                          onSignInSuccess: _onSignInSuccess,
                                          onSignInFailed: _onSignInFailed,
                                          // SMS 입력 단계 전환 시 여백 조정을 위한 콜백
                                          onSmsCodeInputChanged: (isSmsStage) {
                                            setState(() {
                                              _isSmsCodeInputStage = isSmsStage;
                                            });
                                          },
                                          specialAccounts:
                                              const SpecialAccounts(
                                                reviewEmail: 'review@email.com',
                                                reviewPassword: '12345zB,*c',
                                                reviewPhoneNumber:
                                                    '+11234567890',
                                                reviewSmsCode: '123456',
                                                emailLogin: true,
                                              ),
                                          labelPhoneNumber: Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Text(
                                              Lo.of(context)!.enterPhoneNumber,
                                              style: TextStyle(color: scheme.secondary)
                                            ),
                                          ),
                                          labelUnderPhoneNumberTextField: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              Lo.of(context)!.phoneNumberExample,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ),
                                          labelPhoneNumberSelected: Text(
                                            Lo.of(context)!.phoneNumber,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: scheme.onPrimary,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                          ),
                                          hintTextPhoneNumberTextField: Lo.of(
                                            context,
                                          )!.phoneNumber,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: sp.s24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
            ],
          ),
        ),
      ),
    );
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
