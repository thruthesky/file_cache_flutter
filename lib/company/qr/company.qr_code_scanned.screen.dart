import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/review/company.revisit_point_result.screen.dart';
import 'package:philgo/company/review/company.visit_review.screen.dart';
import 'package:philgo/company/view/company.view.screen.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/user.service.dart';

/// QR 코드 스캔 결과 화면
///
/// QR 코드 스캔 후 업소 정보와 스캔 결과를 표시한다.
/// 삼단콤보: 재방문 → 추첨, 첫방문 → 후기 작성
class CompanyQrCodeScannedScreen extends StatefulWidget {
  static const String routeName = '/company/qr-code-scanned';

  final int idx;
  final String code;

  const CompanyQrCodeScannedScreen({
    super.key,
    required this.idx,
    required this.code,
  });

  static Future<void> Function(BuildContext ctx, int idx, String code) push =
      (ctx, idx, code) => ctx.push('$routeName?idx=$idx&code=$code');

  @override
  State<CompanyQrCodeScannedScreen> createState() =>
      _CompanyQrCodeScannedScreenState();
}

class _CompanyQrCodeScannedScreenState
    extends State<CompanyQrCodeScannedScreen> {
  CompanyModel? _company;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? _userInfo;
  bool _isUserLoading = true;

  Map<String, dynamic>? _scanResult;
  bool _isScanLoading = true;
  String? _scanErrorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.idx > 0) _loadCompany(widget.idx);
    _loadUserInfo();
    _scanQrCode();
  }

  Future<void> _loadCompany(int idx) async {
    final company = await CompanyService.get(idx);
    if (!mounted) return;
    if (company != null) {
      setState(() {
        _company = company;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = '업소 정보를 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserInfo() async {
    final user = await UserService.loadCurrentUser();
    if (!mounted) return;
    setState(() {
      _userInfo = user;
      _isUserLoading = false;
    });
  }

  Future<void> _scanQrCode() async {
    try {
      final result = await CompanyService.scanQrCode(widget.code);
      if (!mounted) return;
      setState(() {
        _scanResult = result;
        _isScanLoading = false;
      });

      if (widget.idx == 0 && result['idx_company'] != null) {
        final companyIdx = (result['idx_company'] as num).toInt();
        if (companyIdx > 0) {
          _loadCompany(companyIdx);
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanErrorMessage = e.toString();
        _isScanLoading = false;
        if (widget.idx == 0) _isLoading = false;
      });
    }
  }

  String _extractErrorMessage(String rawError) {
    final colonIdx = rawError.lastIndexOf('): ');
    if (colonIdx != -1) return rawError.substring(colonIdx + 3);
    if (rawError.startsWith('Exception: ')) return rawError.substring(11);
    return rawError;
  }

  ({IconData icon, String title, String description, String? extra})
      _classifyError(String? rawError) {
    if (rawError == null) {
      return (
        icon: FontAwesomeIcons.lightCircleExclamation,
        title: '스캔 오류'.tr(),
        description: '알 수 없는 오류가 발생했습니다.'.tr(),
        extra: null,
      );
    }

    final msg = _extractErrorMessage(rawError);

    if (msg.startsWith('24시간_중복')) {
      final parts = msg.split('|');
      final lastVisitTime = parts.length > 1 ? parts[1] : '';
      return (
        icon: FontAwesomeIcons.lightClockRotateLeft,
        title: '24시간 이내 중복 스캔'.tr(),
        description: '동일 업소에서 24시간 이내에는 1회만 스캔할 수 있습니다.'.tr(),
        extra: lastVisitTime.isNotEmpty ? '이전 방문: $lastVisitTime' : null,
      );
    }

    if (msg.contains('만료된')) {
      return (
        icon: FontAwesomeIcons.lightHourglassEnd,
        title: '만료된 QR 코드'.tr(),
        description: 'QR 코드가 만료되었습니다. 업소에서 새로운 QR 코드를 요청해 주세요.'.tr(),
        extra: null,
      );
    }

    if (msg.contains('유효하지 않은')) {
      return (
        icon: FontAwesomeIcons.lightQrcode,
        title: '유효하지 않은 QR 코드'.tr(),
        description: '올바른 필고 업소 QR 코드를 스캔해 주세요.'.tr(),
        extra: null,
      );
    }

    if (msg.contains('비활성화')) {
      return (
        icon: FontAwesomeIcons.lightBan,
        title: '비활성화된 QR 코드'.tr(),
        description: '이 업소의 QR 코드가 비활성화되어 있습니다.'.tr(),
        extra: null,
      );
    }

    if (msg.contains('업소')) {
      return (
        icon: FontAwesomeIcons.lightBuilding,
        title: '업소 확인 불가'.tr(),
        description: '업소 정보를 확인할 수 없습니다.'.tr(),
        extra: null,
      );
    }

    return (
      icon: FontAwesomeIcons.lightCircleExclamation,
      title: '스캔 오류'.tr(),
      description: msg,
      extra: null,
    );
  }

  String _formatNumber(int number) {
    final result = StringBuffer();
    final str = number.toString();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return result.toString();
  }

  bool _isUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  String _getValidAddress(CompanyModel c) {
    if (c.location.isNotEmpty && !_isUrl(c.location)) return c.location;
    if (c.address.isNotEmpty && !_isUrl(c.address)) return c.address;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: color.outlineVariant),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildAppBarTitle() {
    if (_company == null) {
      return Text('포인트 이벤트'.tr(), style: text.titleLarge);
    }
    final c = _company!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (c.logoUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              c.logoUrl,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FaIcon(
                  FontAwesomeIcons.building,
                  size: 14,
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            c.name,
            style: text.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color.primary),
            ),
            const SizedBox(height: 16),
            Text(
              '로딩 중...'.tr(),
              style: text.bodyMedium?.copyWith(color: color.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_scanErrorMessage != null && _company == null) {
      return _buildScanErrorScreen();
    }

    if (_company == null) {
      return _buildScanErrorScreen();
    }

    final c = _company!;
    final validAddress = _getValidAddress(c);
    final phoneDisplay = c.phoneNumber.isNotEmpty
        ? c.phoneNumber
        : c.mobileNumber.isNotEmpty
            ? c.mobileNumber
            : '';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildSectionHeader(
                  '업소 정보'.tr(),
                  FontAwesomeIcons.lightBuilding,
                ),
                _buildCompanyInfoCard(phoneDisplay, validAddress),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  '방문자 정보'.tr(),
                  FontAwesomeIcons.lightUser,
                ),
                _buildUserInfoSection(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'QR 스캔 결과'.tr(),
                  FontAwesomeIcons.lightQrcode,
                ),
                _buildScanResultSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        if (_scanResult != null && _scanResult!['success'] == true)
          _buildBottomActionButton(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          FaIcon(icon, size: 14, color: color.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            title,
            style: text.titleSmall?.copyWith(
              color: color.onSurface,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard(String phoneDisplay, String validAddress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (phoneDisplay.isNotEmpty)
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.phone, size: 12,
                          color: color.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          phoneDisplay,
                          style: text.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (validAddress.isNotEmpty) ...[
                  if (phoneDisplay.isNotEmpty) const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.locationDot, size: 12,
                          color: color.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          validAddress,
                          style: text.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => CompanyViewScreen.push(
              context,
              company: CompanyModel.minimal(idx: _company!.idx),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '상세보기'.tr(),
                style: text.labelSmall?.copyWith(
                  color: color.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildUserInfoSection() {
    if (_isUserLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color.primary),
            ),
          ),
        ),
      );
    }

    if (_userInfo == null) return const SizedBox.shrink();

    final user = _userInfo!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.primary.withValues(alpha: 0.1),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.solidUser,
                size: 16,
                color: color.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.displayName,
              style: text.bodyMedium?.copyWith(
                color: color.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.lightCoins, size: 12,
                    color: color.primary),
                const SizedBox(width: 4),
                Text(
                  '${_formatNumber(user.point)}P',
                  style: text.labelMedium?.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildScanResultSection() {
    if (_isScanLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(color.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'QR 코드 검증 중...'.tr(),
              style: text.bodySmall?.copyWith(color: color.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_scanErrorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.triangleExclamation, size: 14,
                color: color.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _extractErrorMessage(_scanErrorMessage!),
                style: text.bodySmall?.copyWith(color: color.error),
              ),
            ),
          ],
        ),
      );
    }

    if (_scanResult == null) return const SizedBox.shrink();

    final isSuccess = _scanResult!['success'] == true;
    final rewardPoints = (_scanResult!['reward_points'] as num?)?.toInt() ?? 0;
    final pointAfter = (_scanResult!['point_after'] as num?)?.toInt() ?? 0;
    final companyName = _scanResult!['company_name']?.toString() ?? '';

    final statusColor = isSuccess ? color.primary : color.error;
    final bgColor = isSuccess
        ? color.primaryContainer.withValues(alpha: 0.3)
        : color.errorContainer.withValues(alpha: 0.3);
    final statusIcon = isSuccess
        ? FontAwesomeIcons.solidCircleCheck
        : FontAwesomeIcons.solidTriangleExclamation;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  FaIcon(statusIcon, size: 20, color: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isSuccess
                          ? (companyName.isNotEmpty
                              ? '$companyName QR 스캔 성공!'
                              : 'QR 코드 스캔 성공!'.tr())
                          : _scanResult!['message']?.toString() ?? '',
                      style: text.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (isSuccess && rewardPoints > 0) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.solidCoins, size: 16,
                          color: color.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatNumber(rewardPoints)}P 적립!',
                        style: text.titleSmall?.copyWith(
                          color: color.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pointAfter > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(현재 ${_formatNumber(pointAfter)}P)',
                          style: text.bodySmall?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildBottomActionButton() {
    final isRevisit = _scanResult!['is_revisit'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(
          top: BorderSide(
              color: color.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.lightSparkles, size: 14,
                    color: color.primary),
                const SizedBox(width: 6),
                Text(
                  '추가 포인트를 받으세요!'.tr(),
                  style: text.bodySmall?.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final usageIdx =
                      (_scanResult?['usage_idx'] as num?)?.toInt() ?? 0;
                  final idxCompany =
                      (_scanResult?['idx_company'] as num?)?.toInt() ??
                          widget.idx;
                  if (isRevisit) {
                    CompanyRevisitPointResultScreen.push(
                      context,
                      usageIdx: usageIdx,
                      idxCompany: idxCompany,
                      companyName: _company?.name ?? '',
                    );
                  } else {
                    CompanyVisitReviewScreen.push(
                      context,
                      usageIdx: usageIdx,
                      idxCompany: idxCompany,
                      companyName: _company?.name ?? '',
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        isRevisit
                            ? FontAwesomeIcons.lightDice
                            : FontAwesomeIcons.lightPenToSquare,
                        size: 28,
                        color: color.onPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isRevisit
                            ? '재방문 포인트 추첨'.tr()
                            : '후기 작성으로 포인트 받기'.tr(),
                        style: text.titleLarge?.copyWith(
                          color: color.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.03, duration: 1200.ms,
                  curve: Curves.easeInOut)
              .then()
              .shimmer(
                  duration: 1500.ms,
                  color: color.onPrimary.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  Widget _buildScanErrorScreen() {
    final errorInfo = _classifyError(_scanErrorMessage);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(44),
              ),
              child: Center(
                child: FaIcon(errorInfo.icon, size: 38, color: color.error),
              ),
            ).animate().scale(
                  duration: 500.ms,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 24),
            Text(
              errorInfo.title,
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color.onSurface,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    errorInfo.description,
                    style: text.bodyMedium?.copyWith(
                      color: color.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (errorInfo.extra != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.lightClock, size: 14,
                              color: color.primary),
                          const SizedBox(width: 8),
                          Text(
                            errorInfo.extra!,
                            style: text.bodySmall?.copyWith(
                              color: color.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const FaIcon(FontAwesomeIcons.lightArrowLeft, size: 16),
                label: Text('돌아가기'.tr()),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
