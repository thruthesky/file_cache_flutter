import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/merge/merge_account.model.dart';
import 'package:philgo/user/merge/merge_account.service.dart';
import 'package:philgo/user/user.service.dart';

/// 아이디 합치기 화면
///
/// v7 소셜 계정을 v6 전화번호 계정으로 병합하는 4단계 UI.
/// 1단계: 전화번호 입력 → v6 계정 검색
/// 2단계: v6 계정 미리보기 + SMS 인증 코드 전송
/// 3단계: SMS 인증 코드 입력 → 합치기 실행
/// 4단계: 완료 → 자동 로그아웃
class MergeAccountScreen extends StatefulWidget {
  static const String routeName = '/user/merge-account';
  static void push(BuildContext context) => context.push(routeName);

  const MergeAccountScreen({super.key});

  @override
  State<MergeAccountScreen> createState() => _MergeAccountScreenState();
}

enum _MergeStep { search, preview, smsVerify, complete }

class _MergeAccountScreenState extends State<MergeAccountScreen> {
  _MergeStep _step = _MergeStep.search;

  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();

  String _countryCode = '82';
  bool _loading = false;
  String? _errorMessage;

  V6AccountPreview? _v6Account;
  String? _verificationId;
  int? _resendToken;

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  /// 1단계: 전화번호로 v6 계정 검색
  Future<void> _searchAccount() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = '전화번호를 입력해 주세요.'.tr());
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final e164 = MergeAccountService.formatE164(_countryCode, phone);
      _v6Account = await MergeAccountService.findV6Account(
        phoneNumber: e164,
      );
      setState(() {
        _step = _MergeStep.preview;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = ApiService.friendlyErrorMessage(e);
      });
    }
  }

  /// 2단계: Firebase Phone Auth SMS 전송
  Future<void> _sendSmsCode() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final e164 = MergeAccountService.formatE164(
        _countryCode,
        _phoneController.text.trim(),
      );
      log('SMS 전송: $e164');

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: e164,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android 자동 인증 시 바로 합치기 실행
          log('Phone Auth 자동 인증 완료');
          await _mergeWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Phone Auth 실패: ${e.message}');
          setState(() {
            _loading = false;
            _errorMessage = e.message ?? '인증에 실패했습니다.'.tr();
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          log('SMS 코드 전송 완료');
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _step = _MergeStep.smsVerify;
            _loading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = ApiService.friendlyErrorMessage(e);
      });
    }
  }

  /// 3단계: SMS 코드 확인 + 합치기 실행
  Future<void> _verifySmsAndMerge() async {
    final smsCode = _smsCodeController.text.trim();
    if (smsCode.isEmpty) {
      setState(() => _errorMessage = '인증 코드를 입력해 주세요.'.tr());
      return;
    }

    if (_verificationId == null) {
      setState(() => _errorMessage = 'SMS 인증 정보가 없습니다. 다시 시도해 주세요.'.tr());
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _mergeWithCredential(credential);
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = ApiService.friendlyErrorMessage(e);
      });
    }
  }

  /// Phone Auth 크레덴셜로 합치기 실행
  Future<void> _mergeWithCredential(PhoneAuthCredential credential) async {
    try {
      // 전화번호 인증용 별도 Firebase 인스턴스로 로그인하여 ID Token 획득
      // 현재 소셜 로그인 상태를 유지하면서 전화번호 인증만 수행
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _loading = false;
          _errorMessage = '로그인 상태가 아닙니다.'.tr();
        });
        return;
      }

      // 임시로 전화번호 계정에 링크하여 phone ID token 획득
      // 별도 앱 인스턴스 대신 signInWithCredential 후 getIdToken 사용
      final phoneResult = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final phoneIdToken = await phoneResult.user?.getIdToken();

      if (phoneIdToken == null) {
        setState(() {
          _loading = false;
          _errorMessage = '전화번호 인증 토큰을 가져올 수 없습니다.'.tr();
        });
        return;
      }

      // 원래 소셜 계정으로 다시 돌아와서 mergeAccount 호출
      // (signInWithCredential이 현재 사용자를 바꿨으므로,
      //  phone ID token만 얻은 것이고 mergeAccount는 phone_id_token만 필요)
      // 주의: 이 시점에서 Firebase Auth 사용자가 전화번호 사용자로 바뀌었으므로,
      // mergeAccount API는 세션 기반이 아닌 phone_id_token만으로 동작해야 함
      await MergeAccountService.mergeAccount(phoneIdToken: phoneIdToken);

      setState(() {
        _step = _MergeStep.complete;
        _loading = false;
      });

      // 3초 후 로그아웃 + 로그인 화면으로 이동
      Future.delayed(const Duration(seconds: 3), () async {
        await UserService.signOut();
        if (mounted) {
          context.go('/');
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = ApiService.friendlyErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('아이디 합치기'.tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 진행 상태 표시
              _buildProgressIndicator(),
              const SizedBox(height: 32),

              // 단계별 콘텐츠
              _buildStepContent(),

              // 에러 메시지
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightCircleExclamation,
                        size: 16,
                        color: color.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: text.bodySmall?.copyWith(
                            color: color.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 진행 상태 표시 (4단계)
  Widget _buildProgressIndicator() {
    final steps = [
      '전화번호 검색'.tr(),
      '계정 확인'.tr(),
      'SMS 인증'.tr(),
      '완료'.tr(),
    ];
    final currentIndex = _step.index;

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= currentIndex
                    ? color.primary
                    : color.outlineVariant,
              ),
            ),
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= currentIndex
                      ? color.primary
                      : color.surfaceContainerHigh,
                ),
                child: Center(
                  child: i < currentIndex
                      ? FaIcon(
                          FontAwesomeIcons.check,
                          size: 12,
                          color: color.onPrimary,
                        )
                      : Text(
                          '${i + 1}',
                          style: text.bodySmall?.copyWith(
                            color: i <= currentIndex
                                ? color.onPrimary
                                : color.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: text.labelSmall?.copyWith(
                  color: i <= currentIndex
                      ? color.primary
                      : color.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 단계별 콘텐츠 빌드
  Widget _buildStepContent() {
    switch (_step) {
      case _MergeStep.search:
        return _buildSearchStep();
      case _MergeStep.preview:
        return _buildPreviewStep();
      case _MergeStep.smsVerify:
        return _buildSmsVerifyStep();
      case _MergeStep.complete:
        return _buildCompleteStep();
    }
  }

  /// 1단계: 전화번호 검색
  Widget _buildSearchStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기존 계정 전화번호를 입력하세요'.tr(),
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '기존에 전화번호로 가입한 계정과 현재 소셜 로그인 계정을 합칩니다.'.tr(),
          style: text.bodySmall?.copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // 국가 코드 + 전화번호 입력
        Row(
          children: [
            // 국가 코드
            SizedBox(
              width: 80,
              child: DropdownButtonFormField<String>(
                initialValue: _countryCode,
                decoration: InputDecoration(
                  labelText: '국가'.tr(),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: '82', child: Text('+82')),
                  DropdownMenuItem(value: '63', child: Text('+63')),
                  DropdownMenuItem(value: '1', child: Text('+1')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _countryCode = v);
                },
              ),
            ),
            const SizedBox(width: 12),

            // 전화번호
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '전화번호'.tr(),
                  hintText: '01012345678',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 검색 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _loading ? null : _searchAccount,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('계정 검색'.tr()),
          ),
        ),
      ],
    );
  }

  /// 2단계: v6 계정 미리보기 + SMS 전송
  Widget _buildPreviewStep() {
    final account = _v6Account;
    if (account == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기존 계정을 찾았습니다'.tr(),
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // v6 계정 정보 카드
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleUser,
                size: 48,
                color: color.primary,
              ),
              const SizedBox(height: 12),
              Text(
                account.nickname,
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '포인트: ${_formatNumber(account.point)}P'.tr(),
                style: text.bodyMedium?.copyWith(
                  color: color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          '이 계정이 맞으면 SMS 인증을 진행하세요.'.tr(),
          style: text.bodySmall?.copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // SMS 인증 시작 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _loading ? null : _sendSmsCode,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('SMS 인증 코드 전송'.tr()),
          ),
        ),
        const SizedBox(height: 12),

        // 다른 번호로 검색
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step = _MergeStep.search;
              _v6Account = null;
              _errorMessage = null;
            }),
            child: Text('다른 전화번호로 검색'.tr()),
          ),
        ),
      ],
    );
  }

  /// 3단계: SMS 인증 코드 입력 + 합치기
  Widget _buildSmsVerifyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SMS 인증 코드 입력'.tr(),
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '전화번호로 전송된 인증 코드를 입력하세요.'.tr(),
          style: text.bodySmall?.copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // SMS 코드 입력
        TextField(
          controller: _smsCodeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: '인증 코드'.tr(),
            hintText: '123456',
            border: const OutlineInputBorder(),
            prefixIcon: const FaIcon(FontAwesomeIcons.lightLock),
          ),
        ),
        const SizedBox(height: 24),

        // 합치기 실행 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _loading ? null : _verifySmsAndMerge,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('아이디 합치기'.tr()),
          ),
        ),
        const SizedBox(height: 12),

        // 코드 재전송
        Center(
          child: TextButton(
            onPressed: _loading ? null : _sendSmsCode,
            child: Text('인증 코드 재전송'.tr()),
          ),
        ),
      ],
    );
  }

  /// 4단계: 완료
  Widget _buildCompleteStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.primary.withValues(alpha: 0.1),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightCircleCheck,
                size: 40,
                color: color.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '아이디 합치기가 완료되었습니다!'.tr(),
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '잠시 후 로그아웃됩니다. 다시 로그인하면 기존 계정으로 이용할 수 있습니다.'.tr(),
            style: text.bodyMedium?.copyWith(
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  /// 숫자 포맷 (1234 → 1,234)
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
