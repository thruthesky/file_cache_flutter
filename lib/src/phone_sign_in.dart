// import 'package:country_picker/country_picker.dart';
import 'package:easy_phone_sign_in/easy_phone_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// 전화번호 로그인 위젯
///
/// Firebase 전화 인증 API를 래핑한 위젯으로, 사용자가 전화번호로 로그인할 수 있게 해줍니다.
///
/// 주요 기능:
/// - 전화번호 입력 및 검증
/// - SMS 코드 전송 및 확인
/// - 국가 코드 선택 (선택적)
/// - 특수 계정 처리 (리뷰용, 테스트용)
///
/// 사용자가 입력한 전화번호가 '+'로 시작하면 포맷팅 없이 그대로 사용됩니다.
class PhoneSignIn extends StatefulWidget {
  const PhoneSignIn({
    super.key,
    this.countryCode,
    this.countryPickerOptions,
    this.firebaseAuthLanguageCode = 'en',
    this.onCompletePhoneNumber,
    this.onDisplayPhoneNumber,
    required this.onSignInSuccess,
    required this.onSignInFailed,
    this.onSmsCodeInputChanged,
    this.labelPhoneNumber,
    this.labelUnderPhoneNumberTextField,
    this.labelVerifyPhoneNumberButton,
    this.labelPhoneNumberSelected,
    this.labelOnSmsCodeTextField,
    this.labelRetry,
    this.labelVerifySmsCodeButton,
    this.labelCountryPicker,
    this.labelCountryPickerSelected,
    this.labelChangeCountry,
    this.labelEmptyCountry,
    this.codeAutoRetrievalTimeoutText,
    this.hintTextPhoneNumberTextField,
    this.hintTextSmsCodeTextField,
    this.linkCurrentUser = false,
    this.specialAccounts,
    this.isPhoneNumberRegistered,
    this.debug = false,
    this.onValidatePhoneNumber,
    this.onFocusPhoneNumberTextField,
    this.onUnfocusPhoneNumberTextField,
    this.onFocusSmsCodeTextField,
    this.onUnfocusSmsCodeTextField,
  });

  /// 기본 국가 코드 (예: 'KR', 'PH')
  final String? countryCode;

  /// 국가 선택기 옵션 설정
  final CountryPickerOptions? countryPickerOptions;

  /// Firebase Auth에서 사용할 언어 코드 (SMS 메시지 언어)
  final String firebaseAuthLanguageCode;

  /// 전화번호를 국제 형식으로 변환하는 콜백
  /// 예: '01012345678' → '+821012345678'
  final String Function(String)? onCompletePhoneNumber;

  /// 화면에 표시할 전화번호 형식을 변환하는 콜백
  /// 예: '+821012345678' → '010-1234-5678'
  final String Function(String)? onDisplayPhoneNumber;

  /// 로그인 성공 시 호출되는 콜백
  final VoidCallback onSignInSuccess;

  /// 로그인 실패 시 호출되는 콜백
  /// FirebaseAuthException 에러를 파라미터로 받음
  final void Function(FirebaseAuthException) onSignInFailed;

  /// SMS 코드 입력 화면 전환 시 호출되는 콜백
  /// true: SMS 입력 화면으로 전환됨
  /// false: 전화번호 입력 화면으로 돌아감
  final void Function(bool)? onSmsCodeInputChanged;

  // UI 라벨 커스터마이징을 위한 위젯들
  final Widget? labelPhoneNumber;
  final Widget? labelUnderPhoneNumberTextField;
  final Widget? labelVerifyPhoneNumberButton;
  final Widget? labelPhoneNumberSelected;
  final Widget? labelOnSmsCodeTextField;
  final Widget? labelRetry;
  final Widget? labelVerifySmsCodeButton;
  final Widget? labelCountryPicker;
  final Widget? labelCountryPickerSelected;
  final Widget? labelChangeCountry;
  final Widget? labelEmptyCountry;
  final Widget? codeAutoRetrievalTimeoutText;

  // TextField 힌트 텍스트
  final String? hintTextPhoneNumberTextField;
  final String? hintTextSmsCodeTextField;

  /// 현재 로그인된 사용자와 전화번호를 연결할지 여부
  /// true: 익명 사용자를 전화번호와 연결
  /// false: 새로운 전화번호 계정으로 로그인
  final bool linkCurrentUser;

  /// 특수 계정 설정 (앱 리뷰용, 테스트용)
  final SpecialAccounts? specialAccounts;

  /// 전화번호가 이미 등록되어 있는지 확인하는 콜백
  final Future<bool> Function(String)? isPhoneNumberRegistered;

  /// 디버그 로그 출력 여부
  final bool debug;

  /// 전화번호 검증 콜백
  /// 국제 형식으로 변환된 전화번호를 받아 검증 수행
  /// null 반환 시 유효, String 반환 시 에러 메시지로 SnackBar 표시
  final String? Function(String)? onValidatePhoneNumber;

  final Function()? onFocusPhoneNumberTextField;
  final Function()? onUnfocusPhoneNumberTextField;
  final Function()? onFocusSmsCodeTextField;
  final Function()? onUnfocusSmsCodeTextField;

  @override
  State<PhoneSignIn> createState() => _PhoneSignInState();
}

class _PhoneSignInState extends State<PhoneSignIn> {
  /// 진행 중 상태 (로딩 인디케이터 표시용)
  bool progress = false;

  /// 선택된 국가 정보
  Country? country;

  /// 전화번호 입력 컨트롤러
  final TextEditingController phoneNumberController = TextEditingController();

  /// SMS 코드 입력 컨트롤러
  final TextEditingController smsCodeController = TextEditingController();

  /// 국가 선택기 사용 여부
  bool get countryPicker => widget.countryPickerOptions != null;

  /// Firebase에서 받은 검증 ID (SMS 코드 확인 시 사용)
  String? verificationId;

  /// SMS 코드 입력 UI 표시 여부
  bool showSmsCodeInput = false;

  final FocusNode _focusNodePhoneNumber = FocusNode();
  final FocusNode _focusNodeSmsCode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 위젯 생성 시 국가 코드가 제공되면 파싱하여 설정
    if (widget.countryCode != null) {
      country = Country.parse(widget.countryCode!);
    }

    _focusNodePhoneNumber.addListener(() {
      if (_focusNodePhoneNumber.hasFocus) {
        // debug('Phone number TextField focused');
        widget.onFocusPhoneNumberTextField?.call();
      } else {
        // debug('Phone number TextField unfocused');
        widget.onUnfocusPhoneNumberTextField?.call();
      }
    });

    _focusNodeSmsCode.addListener(() {
      if (_focusNodeSmsCode.hasFocus) {
        // debug('SMS code TextField focused');
        widget.onFocusSmsCodeTextField?.call();
      } else {
        // debug('SMS code TextField unfocused');
        widget.onUnfocusSmsCodeTextField?.call();
      }
    });
  }

  @override
  void dispose() {
    // 컨트롤러 정리
    phoneNumberController.dispose();
    smsCodeController.dispose();
    _focusNodePhoneNumber.dispose();
    _focusNodeSmsCode.dispose();
    super.dispose();
  }

  /// SMS 코드 재전송
  /// 사용자가 재시도 버튼을 눌렀을 때 SMS를 다시 전송
  void _resendSms() async {
    // 프로그레스 표시
    showProgress();

    // SMS 코드 입력 필드 초기화
    smsCodeController.clear();

    // Firebase 전화 인증 재시도
    final phoneNumber = onCompletePhoneNumber();

    // 앱 리뷰용 특수 계정 처리
    if (phoneNumber == widget.specialAccounts?.reviewPhoneNumber) {
      hideProgress();
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // 자동 인증 완료 (Android만 해당)
          debug('---> PhoneSignIn::_resendSms() -> verificationCompleted');
          hideProgress();
        },
        verificationFailed: (FirebaseAuthException e) {
          // 인증 실패
          debug(
              '---> PhoneSignIn::_resendSms() -> verificationFailed: ${e.message}');
          hideProgress();
          widget.onSignInFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          // SMS 재전송 성공
          debug('---> PhoneSignIn::_resendSms() -> codeSent: $verificationId');
          this.verificationId = verificationId;
          hideProgress();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // SMS 자동 감지 타임아웃
          debug('---> PhoneSignIn::_resendSms() -> codeAutoRetrievalTimeout');
        },
      );
    } catch (e) {
      hideProgress();
      debug('Error resending SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ==================== 국가 선택기 섹션 ====================
        // countryPickerOptions가 설정되어 있을 때만 표시
        if (countryPicker)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // 국가 선택 다이얼로그 표시
              showCountryPicker(
                context: context,
                onClosed: widget.countryPickerOptions?.onClosed,
                favorite: widget.countryPickerOptions?.favorite,
                exclude: widget.countryPickerOptions?.exclude,
                countryFilter: widget.countryPickerOptions?.countryFilter,
                showPhoneCode:
                    widget.countryPickerOptions?.showPhoneCode ?? true,
                customFlagBuilder:
                    widget.countryPickerOptions?.customFlagBuilder,
                countryListTheme:
                    widget.countryPickerOptions?.countryListTheme ??
                        CountryListThemeData(
                          // 기본 테마: 화면 높이의 50%로 바텀시트 표시
                          bottomSheetHeight:
                              MediaQuery.of(context).size.height * 0.5,
                          borderRadius: BorderRadius.circular(16.8),
                        ),
                searchAutofocus:
                    widget.countryPickerOptions?.searchAutofocus ?? false,
                showWorldWide:
                    widget.countryPickerOptions?.showWorldWide ?? false,
                showSearch: widget.countryPickerOptions?.showSearch ?? true,
                useSafeArea: widget.countryPickerOptions?.useSafeArea ?? true,
                onSelect: (Country country) {
                  // 국가 선택 시 상태 업데이트
                  setState(() {
                    this.country = country;
                    widget.countryPickerOptions?.onSelect?.call(country);
                  });
                },
                useRootNavigator:
                    widget.countryPickerOptions?.useRootNavigator ?? false,
                moveAlongWithKeyboard:
                    widget.countryPickerOptions?.moveAlongWithKeyboard ?? false,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 국가가 선택되지 않았을 때
                if (country == null)
                  widget.labelCountryPicker ??
                      const Text('Select your country'),
                // 국가가 선택되었을 때
                if (country != null)
                  widget.labelCountryPickerSelected ??
                      widget.labelCountryPicker ??
                      const Text('Select your country'),
                // 선택된 국가 정보 표시
                if (country == null)
                  widget.labelEmptyCountry ?? const SizedBox.shrink()
                else ...[
                  // 국가 코드와 이름 표시 (예: (+82) 대한민국)
                  Text('(+${country!.phoneCode}) ${country!.name}',
                      style: Theme.of(context).textTheme.titleLarge),
                  // 변경 버튼
                  widget.labelChangeCountry ??
                      Text('Change',
                          style: Theme.of(context).textTheme.labelSmall),
                ]
              ],
            ),
          ),

        // ==================== 전화번호 입력 섹션 ====================
        // SMS 코드 입력 화면이 아니고, 국가가 선택되었거나 국가 선택기를 사용하지 않을 때
        if (showSmsCodeInput == false &&
            (countryPicker == false || country != null)) ...[
          const SizedBox(height: 16),
          // 전화번호 입력 라벨
          widget.labelPhoneNumber ?? const Text('Enter your phone number'),
          // 전화번호 입력 필드
          TextField(
            focusNode: _focusNodePhoneNumber,
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: InputDecoration(
              // 국가 코드 prefix 표시
              prefixIcon: country != null
                  ? SizedBox(
                      // 국가 코드 길이에 따라 너비 조절
                      width: country!.phoneCode.length <= 2 ? 60 : 80,
                      child: Center(
                        child: Text(
                          '+${country!.phoneCode}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    )
                  : null,
              hintText: widget.hintTextPhoneNumberTextField ?? 'Phone number',
              hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    // 힌트 텍스트는 40% 투명도로 표시
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // 입력 시마다 상태 업데이트 (버튼 표시용)
            onChanged: (value) => setState(() {}),
          ),
          // 전화번호 입력 필드 아래 추가 라벨 (예: 형식 안내)
          if (widget.labelUnderPhoneNumberTextField != null)
            widget.labelUnderPhoneNumberTextField!,

          // ==================== 전화번호 검증 버튼 ====================
          // 전화번호가 입력되었을 때만 표시
          if (phoneNumberController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            progress
                ? const Center(child: CircularProgressIndicator.adaptive())
                : ElevatedButton(
                    onPressed: () async {
                      debug(
                          'PhoneSignIn::build() -> onPressed("Verify phone number") -> Begin: phone number verification');

                      // 완성된 국제 전화번호 형식 가져오기
                      final completePhoneNumber = onCompletePhoneNumber();

                      // ===== 특수 계정 처리 =====
                      // 이메일 로그인 (테스트용)
                      if (widget.specialAccounts?.emailLogin == true &&
                          phoneNumberController.text.contains('@')) {
                        return doEmailLogin();
                      }
                      // 앱 리뷰용 계정
                      else if (completePhoneNumber ==
                          widget.specialAccounts?.reviewPhoneNumber) {
                        return doReviewPhoneNumberSubmit();
                      }
                      // 전화번호가 비어있으면 에러
                      else if (completePhoneNumber.isEmpty) {
                        throw Exception(
                          '@phone_sign_in/malformed-phone-number Phone number is empty or malformed.',
                        );
                      }

                      // ===== 전화번호 검증 (화이트리스트 등) =====
                      if (widget.onValidatePhoneNumber != null) {
                        final validationError =
                            widget.onValidatePhoneNumber!(completePhoneNumber);
                        if (validationError != null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(validationError)),
                            );
                          }
                          return;
                        }
                      }

                      // 로딩 표시 시작
                      showProgress();

                      // Firebase Auth 언어 설정 (SMS 메시지 언어)
                      FirebaseAuth.instance
                          .setLanguageCode(widget.firebaseAuthLanguageCode);

                      debug(
                          'Begin: FirebaseAuth.instance.verifyPhoneNumber with completePhoneNumber: $completePhoneNumber');

                      // ===== Firebase 전화번호 인증 시작 =====
                      try {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          timeout: const Duration(seconds: 60),
                          phoneNumber: completePhoneNumber,

                          // Android에서 SMS 자동 감지 시 호출
                          // SMS 코드 입력 없이 자동으로 로그인 처리
                          verificationCompleted:
                              (PhoneAuthCredential credential) async {
                            debug('verificationCompleted: $credential');
                            // 주의: Android에서 자동 로그인 시 time-expire나 invalid sms code 에러가
                            // 발생할 수 있으나 무시해도 됨

                            try {
                              // linkCurrentUser 옵션에 따라 처리 분기
                              if (widget.linkCurrentUser) {
                                // 현재 사용자(익명 등)와 전화번호 연결
                                debug(
                                    'linkCurrentUser options is set. Linking current user account with the phone number ');
                                await linkOrSignInWithCredential(credential);
                              } else {
                                // 새로운 전화번호 계정으로 로그인
                                debug(
                                    'linkCurrentUser options is NOT set. Signing in with the phone number.');
                                await FirebaseAuth.instance
                                    .signInWithCredential(credential);
                              }

                              onSignInSuccess();
                            } on FirebaseAuthException catch (e) {
                              onSignInFailed(e);
                            }
                          },

                          // 전화번호 검증 실패 또는 Firebase 오류 시 호출
                          // 주의: SMS 코드 검증 실패가 아닌 전화번호 자체 검증 실패
                          verificationFailed: (FirebaseAuthException e) {
                            debug(
                                '---> verificationFailed: code=${e.code}, message=${e.message}');
                            onSignInFailed(e);
                          },

                          // 전화번호 검증 성공, SMS 코드 전송됨
                          // SMS 코드 입력 UI로 전환
                          codeSent:
                              (String verificationId, int? resendToken) {
                            debug(
                                '---> codeSent: verificationId=$verificationId');
                            this.verificationId = verificationId;
                            setState(() {
                              showSmsCodeInput = true; // SMS 입력 화면으로 전환
                              hideProgress();
                            });
                            // SMS 입력 화면 전환 콜백 호출
                            widget.onSmsCodeInputChanged?.call(true);
                          },

                          // Android 전용: SMS 자동 감지 타임아웃
                          // 네트워크 불안정 등으로 발생 가능
                          codeAutoRetrievalTimeout: (String verificationId) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      widget.codeAutoRetrievalTimeoutText ??
                                          const Text(
                                            'SMS code auto-resolution timed out. Please retry.',
                                          ),
                                ),
                              );
                              setState(() {
                                showSmsCodeInput =
                                    false; // 전화번호 입력으로 돌아가기
                              });
                              // 전화번호 입력 화면으로 돌아감 콜백 호출
                              widget.onSmsCodeInputChanged?.call(false);
                              hideProgress();
                            }
                          },
                        );
                        debug('verifyPhoneNumber 호출 완료 (await 반환)');
                      } catch (e, stackTrace) {
                        debug(
                            'verifyPhoneNumber 예외 발생: $e');
                        debug('스택 트레이스: $stackTrace');
                        hideProgress();
                        if (e is FirebaseAuthException) {
                          onSignInFailed(e);
                        } else {
                          // FirebaseAuthException이 아닌 다른 예외
                          debug('예상하지 못한 예외 타입: ${e.runtimeType}');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('인증 오류: $e'),
                              ),
                            );
                          }
                        }
                      }
                    },
                    // 버튼 라벨 (위젯이나 기본 텍스트)
                    child: widget.labelVerifyPhoneNumberButton ??
                        const Text('Verify phone number'),
                  ),
          ],
        ],

        // ==================== SMS 코드 입력 섹션 ====================
        // SMS 코드가 전송된 후 표시되는 화면
        if (showSmsCodeInput) ...[
          const SizedBox(height: 16),
          // 전화번호 확인 라벨
          widget.labelPhoneNumberSelected ?? const Text('Phone number'),
          // 입력한 전화번호 표시 (사용자 친화적 형식)
          Text(
            onDisplayPhoneNumber(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          // SMS 코드 입력 라벨
          widget.labelOnSmsCodeTextField ?? const Text('Enter the SMS code'),
          // SMS 코드 입력 필드
          TextField(
            focusNode: _focusNodeSmsCode,
            controller: smsCodeController,
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: InputDecoration(
              hintText: widget.hintTextSmsCodeTextField ?? 'SMS code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // 입력 시마다 상태 업데이트 (버튼 표시용)
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // 재시도 버튼 (TextButton으로 덜 강조)
              // 2024.06.26 @thruthesky: ElevatedButton 대신 TextButton 사용
              // 이유: 너무 강한 시각적 강조를 피하기 위함
              TextButton(
                onPressed: () {
                  // SMS 재전송
                  _resendSms();
                },
                child: widget.labelRetry ?? const Text('Retry'),
              ),
              const Spacer(),
              // SMS 코드 확인 버튼
              // 코드가 입력되었을 때만 표시
              if (smsCodeController.text.isNotEmpty)
                progress
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: CircularProgressIndicator.adaptive())
                    : ElevatedButton(
                        onPressed: () async {
                          // 앱 리뷰용 특수 계정 처리
                          if (onCompletePhoneNumber() ==
                              widget.specialAccounts?.reviewPhoneNumber) {
                            return doReviewSmsCodeSubmit();
                          }

                          showProgress();

                          // SMS 코드와 verification ID로 credential 생성
                          final credential = PhoneAuthProvider.credential(
                            verificationId: verificationId!,
                            smsCode: smsCodeController.text.trim(),
                          );

                          // Firebase 로그인 시도
                          try {
                            // linkCurrentUser 옵션에 따라 처리 분기
                            if (widget.linkCurrentUser) {
                              debug(
                                  'Linking current user account with phone number ');
                              await linkOrSignInWithCredential(credential);
                            } else {
                              await FirebaseAuth.instance
                                  .signInWithCredential(credential);
                            }
                            onSignInSuccess();
                          } on FirebaseAuthException catch (e) {
                            onSignInFailed(e);
                          }
                        },
                        child: widget.labelVerifySmsCodeButton ??
                            const Text('Verify SMS code'),
                      ),
            ],
          )
        ],
      ],
    );
  }

  /// 현재 사용자와 전화번호 credential을 연결하거나 로그인 처리
  ///
  /// 동작 순서:
  /// 1. 현재 로그인된 사용자가 없으면 → 바로 전화번호로 로그인
  /// 2. 현재 사용자가 있고 전화번호가 이미 등록되어 있으면 → 전화번호로 로그인 (계정 전환)
  /// 3. 현재 사용자가 있고 전화번호가 등록되지 않았으면 → 현재 계정에 전화번호 연결
  ///
  /// 주의사항:
  /// - linkWithCredential()과 signInWithCredential()에서 같은 credential을
  ///   두 번 사용하면 SMS expired 에러 발생
  /// - 따라서 isPhoneNumberRegistered 콜백으로 미리 확인 후 적절한 메서드 호출
  Future<void> linkOrSignInWithCredential(AuthCredential credential) async {
    debug('Begin: linkOrSignInWithCredential();');

    final currentUser = FirebaseAuth.instance.currentUser;

    // 현재 로그인된 사용자가 없는 경우
    if (currentUser == null) {
      debug(
          'currentUser == null. Meaning, the user is not signed in. Not even as anonymous. So, it will simply sign in with the phone number.');
      await FirebaseAuth.instance.signInWithCredential(credential);
      return;
    }

    // 전화번호가 이미 등록되어 있는지 확인
    // phoneNumbers 컬렉션에서 확인 (보안상 uid는 저장하지 않음)
    debug(
        'Check if the phone number is already registered with: isPhoneNumberRegistered() callback.');
    final re = await widget.isPhoneNumberRegistered!(onCompletePhoneNumber());
    if (re) {
      // 이미 등록된 전화번호면 로그인만 수행 (계정 전환)
      debug(
          'Phone number already in use!! So, it will sign-in with phone number without linking.');
      await FirebaseAuth.instance.signInWithCredential(credential);
      return;
    }

    // 전화번호가 등록되지 않았고 현재 사용자가 있는 경우
    // 현재 계정(익명 등)에 전화번호 연결
    debug(
      'The phone number is not in use. And the user is signed in (maybe as an anonymous). Try to link with the phone number sign-in credential.',
    );
    await currentUser.linkWithCredential(credential);
  }

  /// 화면에 표시할 전화번호 형식 반환
  ///
  /// Firebase에 전송하는 국제 형식과 달리 사용자에게 친숙한 형식으로 표시
  /// 예: +821012345678 → 010-1234-5678
  String onDisplayPhoneNumber() {
    final phoneNumber = onCompletePhoneNumber();
    return widget.onDisplayPhoneNumber?.call(phoneNumber) ?? phoneNumber;
  }

  /// Firebase에 전송할 국제 전화번호 형식 반환
  ///
  /// 처리 로직:
  /// 1. 전화번호에서 숫자와 + 기호만 남기고 모든 특수문자 제거
  /// 2. 맨 앞의 0 제거 (국가 내 지역번호)
  /// 3. +로 시작하면 그대로 반환 (이미 국제 형식)
  /// 4. 그렇지 않으면 onCompletePhoneNumber 콜백 호출 또는 국가 코드 추가
  String onCompletePhoneNumber() {
    final phoneNumber = phoneNumberController.text;
    String number = phoneNumber.trim();

    // 특수문자 제거 (괄호, 하이픈, 공백 등)
    number = number.replaceAll(RegExp(r'[^\+0-9]'), '');
    // 맨 앞 0 제거 (예: 010 → 10)
    number = number.replaceFirst(RegExp(r'^0'), '');

    // 이미 국제 형식인 경우
    if (number.startsWith('+')) {
      debug(
          'onCompletePhoneNumber(): $number starts with +. No formatting needed.');
      return number;
    }

    // 커스텀 formatter가 있으면 사용
    if (widget.onCompletePhoneNumber != null) {
      return widget.onCompletePhoneNumber?.call(number) ?? number;
    }
    // 국가가 선택되었으면 국가 코드 추가
    else if (country != null) {
      return '+${country!.phoneCode}$number';
    }
    // 그 외의 경우 그대로 반환
    else {
      return number;
    }
  }

  /// 로그인 성공 처리
  void onSignInSuccess() {
    hideProgress();
    widget.onSignInSuccess.call();
  }

  /// 로그인 실패 처리
  void onSignInFailed(FirebaseAuthException e) {
    hideProgress();
    widget.onSignInFailed.call(e);
  }

  /// 로딩 인디케이터 표시
  void showProgress() {
    setState(() => progress = true);
  }

  /// 로딩 인디케이터 숨김
  void hideProgress() {
    setState(() => progress = false);
  }

  /// 재시도 - 모든 입력 초기화
  void retry() {
    setState(() {
      showSmsCodeInput = false;
      verificationId = null;
      phoneNumberController.clear();
      smsCodeController.clear();
    });
    // 전화번호 입력 화면으로 돌아감 콜백 호출
    widget.onSmsCodeInputChanged?.call(false);
  }

  /// 이메일 로그인 처리 (테스트/개발용)
  ///
  /// 전화번호 필드에 이메일:비밀번호 형식으로 입력 시 처리
  /// 예: test@email.com:password123
  void doEmailLogin([String? emailPassword]) async {
    debug('BEGIN: doEmailLogin()');

    emailPassword ??= phoneNumberController.text;

    showProgress();
    try {
      // ':' 기준으로 이메일과 비밀번호 분리
      final email = emailPassword.split(':').first;
      final password = emailPassword.split(':').last;

      // 로그인 또는 회원가입 시도
      await loginOrRegister(
        email: email,
        password: password,
        photoUrl: '',
        displayName: '',
      );
      onSignInSuccess();
    } on FirebaseAuthException catch (e) {
      debug('ERROR: doEmailLogin error: $e');
      onSignInFailed(e);
      if (context.mounted) {
        hideProgress();
      }
      rethrow;
    }
  }

  /// 이메일로 로그인 또는 회원가입
  ///
  /// 동작 순서:
  /// 1. 먼저 로그인 시도
  /// 2. 로그인 실패 시 새 계정 생성
  /// 3. 계정 생성 후 프로필 정보 업데이트
  Future loginOrRegister({
    required String email,
    required String password,
    String? photoUrl,
    String? displayName,
  }) async {
    try {
      // 먼저 로그인 시도
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // 로그인 실패 시 새 계정 생성
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    }
  }

  /// 앱 리뷰용 전화번호 처리
  ///
  /// 실제 SMS 전송 없이 SMS 입력 화면으로 바로 전환
  void doReviewPhoneNumberSubmit() {
    if (context.mounted) {
      debug('Begin: doReviewPhoneNumberSubmit()');
      setState(() {
        showSmsCodeInput = true;
        progress = false;
      });
      // SMS 입력 화면 전환 콜백 호출
      widget.onSmsCodeInputChanged?.call(true);
    }
  }

  /// 앱 리뷰용 SMS 코드 확인
  ///
  /// 미리 정의된 코드와 비교하여 일치하면 이메일 로그인 수행
  void doReviewSmsCodeSubmit() {
    if (smsCodeController.text == widget.specialAccounts?.reviewSmsCode) {
      // 리뷰 계정으로 이메일 로그인
      return doEmailLogin(
          "${widget.specialAccounts!.reviewEmail}:${widget.specialAccounts!.reviewPassword}");
    } else {
      // 잘못된 코드
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid SMS code. Please retry.'),
        ),
      );
    }
  }

  /// 디버그 로그 출력
  ///
  /// widget.debug가 true일 때만 로그 출력
  void debug(String message) {
    if (widget.debug) {
      print("[PhoneSignIn] $message");
    }
  }
}
