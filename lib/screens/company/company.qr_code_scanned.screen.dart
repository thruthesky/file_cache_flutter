import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/v7_api/company_api.dart';
import 'package:philgo/v7_api/user_api.dart';
import 'package:philgo/v7_api/v7_api.dart';
import 'package:philgo/v7_api/widgets/upload/v7_file_upload.dart';
import 'package:philgo_api/philgo_api.dart';

/// QR 코드 스캔 결과 화면 (Company QR Code Scanned Screen)
///
/// Purpose: QR 코드 스캔 후 업체 정보를 콤팩트하게 요약 표시하고,
/// 영수증 업로드를 통한 포인트 이벤트 참여를 유도하는 화면.
///
/// Flow: QR 스캔 → 업체 확인 → 영수증 업로드 → 텍스트 분석 →
///       날짜/시간/업체 판별 → 포인트 획득 → Spin Wheel 추첨
class CompanyQrCodeScannedScreen extends StatefulWidget {
  static const String routeName = '/company/qr-code-scanned.php';

  final int idx;
  final String verificationId;

  const CompanyQrCodeScannedScreen({
    super.key,
    required this.idx,
    required this.verificationId,
  });

  static Future<void> Function(BuildContext ctx, int idx, String verificationId)
  push = (ctx, idx, verificationId) =>
      ctx.push('$routeName?idx=$idx&verification_id=$verificationId');

  @override
  State<CompanyQrCodeScannedScreen> createState() =>
      _CompanyQrCodeScannedScreenState();
}

class _CompanyQrCodeScannedScreenState
    extends State<CompanyQrCodeScannedScreen> {
  Company? company;
  bool isLoading = true;
  String? errorMessage;

  /// v7 API로 가져온 현재 로그인 사용자 정보
  Map<String, dynamic>? userInfo;
  bool isUserLoading = true;
  String? userErrorMessage;

  /// 영수증 업로드 상태
  Map<String, dynamic>? receiptData;
  bool isUploading = false;
  double uploadProgress = 0.0;

  /// QR 코드 검증 상태
  Map<String, dynamic>? scanResult;
  bool isScanLoading = true;
  String? scanErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompany();
    _loadUserInfo();
    _scanQrCode();
  }

  Future<void> _loadCompany() async {
    try {
      final details = await CompanyApi.get(widget.idx);
      if (!mounted) return;
      setState(() {
        company = details;
        isLoading = false;
      });

    } catch (e) {
      debugLog('v7 업소 조회 오류: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// v7 API로 현재 로그인 사용자 정보를 가져온다
  /// user.me 엔드포인트: Firebase ID Token으로 인증 후 sf_member 테이블에서 사용자 정보 반환
  Future<void> _loadUserInfo() async {
    try {
      final result = await UserApi.me();
      if (!mounted) return;
      setState(() {
        userInfo = result;
        isUserLoading = false;
      });
    } catch (e) {
      debugLog('v7api user.me 에러: $e');
      if (!mounted) return;
      setState(() {
        userErrorMessage = e.toString();
        isUserLoading = false;
      });
    }
  }

  /// v7 API company.scanQrCode를 호출하여 QR 코드 검증
  /// 응답: result ('s'=성공, 'f'=실패, 'r'=24시간 중복 거부), message, company_name 등
  Future<void> _scanQrCode() async {
    try {
      final result = await v7api('company.scanQrCode', data: {
        'code': widget.verificationId,
      });
      if (!mounted) return;
      setState(() {
        scanResult = result;
        isScanLoading = false;
      });
    } catch (e) {
      debugLog('company.scanQrCode API 에러: $e');
      if (!mounted) return;
      setState(() {
        scanErrorMessage = e.toString();
        isScanLoading = false;
      });
    }
  }

  /// Check if a string value is a URL (not a real address/location)
  bool _isUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  /// Build a single-line contact summary string
  /// Combines phone, mobile, kakao into one compact line
  String _buildContactSummary(Company c) {
    final parts = <String>[];
    if (c.phone_number.isNotEmpty) parts.add(c.phone_number);
    if (c.mobile_number.isNotEmpty) parts.add(c.mobile_number);
    if (c.kakaotalk_id.isNotEmpty) parts.add(c.kakaotalk_id);
    if (c.telegram_id.isNotEmpty) parts.add(c.telegram_id);
    return parts.join(' · ');
  }

  /// 현재 로그인 사용자 정보 섹션 위젯
  /// v7 API user.me 응답 데이터를 콤팩트하게 표시
  Widget _buildUserInfoSection(ColorScheme scheme, ThemeData theme) {
    /// 로딩 중
    if (isUserLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '사용자 정보 로딩 중...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    /// 에러 발생 시
    if (userErrorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 14,
              color: scheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '사용자 정보를 가져올 수 없습니다.',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isUserLoading = true;
                  userErrorMessage = null;
                });
                _loadUserInfo();
              },
              child: FaIcon(
                FontAwesomeIcons.arrowsRotate,
                size: 14,
                color: scheme.error,
              ),
            ),
          ],
        ),
      );
    }

    /// 사용자 정보 없음
    if (userInfo == null) return const SizedBox.shrink();

    final name = userInfo!['name']?.toString() ?? '';
    final nickname = userInfo!['nickname']?.toString() ?? '';
    final id = userInfo!['id']?.toString() ?? '';
    final phoneNumber = userInfo!['phone_number']?.toString() ?? '';

    /// 표시할 이름 결정: name > nickname > id
    final displayName = name.isNotEmpty
        ? name
        : nickname.isNotEmpty
        ? nickname
        : id;

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              /// 사용자 아이콘
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    size: 16,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              /// 사용자 정보 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 이름 (또는 닉네임)
                    Text(
                      displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    /// 이메일 · 전화번호 (한 줄)
                    if (id.isNotEmpty || phoneNumber.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (id.isNotEmpty) id,
                          if (phoneNumber.isNotEmpty) phoneNumber,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 150.ms)
        .slideY(begin: 0.05, end: 0);
  }

  /// QR 코드 검증 결과 섹션 위젯
  /// company.scanQrCode API 응답을 표시 (성공/실패/거부)
  Widget _buildScanResultSection(ColorScheme scheme, ThemeData theme) {
    /// 로딩 중
    if (isScanLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'QR 코드 검증 중...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    /// API 호출 에러
    if (scanErrorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 14,
              color: scheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                scanErrorMessage!,
                style:
                    theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  isScanLoading = true;
                  scanErrorMessage = null;
                });
                _scanQrCode();
              },
              child: FaIcon(
                FontAwesomeIcons.arrowsRotate,
                size: 14,
                color: scheme.error,
              ),
            ),
          ],
        ),
      );
    }

    /// 결과 없음
    if (scanResult == null) return const SizedBox.shrink();

    final result = scanResult!['result']?.toString() ?? '';
    final message = scanResult!['message']?.toString() ?? '';

    /// 결과 코드별 색상 및 아이콘 결정
    final bool isSuccess = result == 's';
    final bool isRejected = result == 'r';
    final Color statusColor =
        isSuccess ? scheme.primary : (isRejected ? scheme.tertiary : scheme.error);
    final Color bgColor = isSuccess
        ? scheme.primaryContainer.withValues(alpha: 0.3)
        : isRejected
            ? scheme.tertiaryContainer.withValues(alpha: 0.3)
            : scheme.errorContainer.withValues(alpha: 0.3);
    final IconData statusIcon = isSuccess
        ? FontAwesomeIcons.solidCircleCheck
        : isRejected
            ? FontAwesomeIcons.solidClock
            : FontAwesomeIcons.solidTriangleExclamation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          FaIcon(statusIcon, size: 20, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  /// 영수증 AI 분석 결과 카드 위젯
  /// ai.analyzeReceipt 응답 데이터를 표시 (인증 상태 + 상점/금액/날짜 + 의심 사유)
  Widget _buildReceiptResultCard(ColorScheme scheme, ThemeData theme) {
    final data = receiptData!;
    final isAuthentic = data['is_authentic'] == true;
    final storeName = data['store_name']?.toString() ?? '';
    final totalAmount = data['total_amount']?.toString() ?? '';
    final date = data['date']?.toString() ?? '';
    final currency = data['currency']?.toString() ?? '';
    final paymentMethod = data['payment_method']?.toString() ?? '';
    final receiptType = data['receipt_type']?.toString() ?? '';
    final summary = data['summary']?.toString() ?? '';
    final int confidenceScore =
        (data['confidence_score'] as num?)?.toInt() ?? 0;
    final suspiciousReasons =
        (data['suspicious_reasons'] as List<dynamic>?) ?? [];

    /// 인증 상태에 따른 색상
    final statusColor = isAuthentic ? scheme.primary : scheme.error;
    final statusBgColor = isAuthentic
        ? scheme.primaryContainer.withValues(alpha: 0.3)
        : scheme.errorContainer.withValues(alpha: 0.3);
    final statusBorderColor = isAuthentic
        ? scheme.primary.withValues(alpha: 0.3)
        : scheme.error.withValues(alpha: 0.4);

    /// 신뢰도 점수 색상
    Color scoreColor(int score) {
      if (score >= 70) return scheme.primary;
      if (score >= 50) return scheme.tertiary;
      return scheme.error;
    }

    /// 상세 정보 행 빌더
    Widget infoRow(IconData icon, String label, String value) {
      if (value.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, size: 12, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    /// store_name 비교: 서버 응답의 store_name_match 필드 또는 클라이언트 fallback
    final bool storeNameMatches;
    if (data.containsKey('store_name_match')) {
      storeNameMatches = data['store_name_match'] == true;
    } else {
      /// 클라이언트 fallback: 영수증 store_name과 업소명 비교
      final normalizedStore = storeName.trim().toLowerCase();
      final normalizedCompany = (company?.name ?? '').trim().toLowerCase();
      storeNameMatches = normalizedStore.isEmpty ||
          normalizedStore.contains(normalizedCompany) ||
          normalizedCompany.contains(normalizedStore);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusBorderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 인증 상태 배너
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  isAuthentic
                      ? FontAwesomeIcons.solidCircleCheck
                      : FontAwesomeIcons.solidTriangleExclamation,
                  size: 20,
                  color: statusColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAuthentic ? '영수증 인증 완료' : '영수증 인증 실패',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAuthentic
                            ? '영수증이 정상적으로 확인되었습니다.'
                            : '한인 업소 영수증으로 인증되지 않았습니다.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                /// 신뢰도 점수 배지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor(confidenceScore).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$confidenceScore%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scoreColor(confidenceScore),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// 영수증 상세 정보
          infoRow(FontAwesomeIcons.store, '상점', storeName),
          infoRow(FontAwesomeIcons.moneyBill, '금액', totalAmount),
          infoRow(FontAwesomeIcons.calendar, '날짜', date),
          infoRow(FontAwesomeIcons.coins, '통화', currency),
          infoRow(FontAwesomeIcons.creditCard, '결제', paymentMethod),
          infoRow(FontAwesomeIcons.receipt, '유형', receiptType),

          /// 요약
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          /// 의심 사유 목록 (is_authentic == false일 때 강조 표시)
          if (!isAuthentic && suspiciousReasons.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightCircleExclamation,
                        size: 14,
                        color: scheme.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '의심 사유',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...suspiciousReasons.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              reason.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          /// store_name 불일치 경고 (영수증 상점명과 업소명/receipt_name이 다를 때)
          if (!storeNameMatches && storeName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightTriangleExclamation,
                        size: 14,
                        color: scheme.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        T.storeNameMismatch,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    T.storeNameMismatchDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// 영수증 스토어명 vs 업소명 비교 표시
                  _buildComparisonRow(
                    theme: theme,
                    scheme: scheme,
                    label: T.receiptStoreName,
                    value: storeName,
                  ),
                  const SizedBox(height: 4),
                  _buildComparisonRow(
                    theme: theme,
                    scheme: scheme,
                    label: T.companyNameLabel,
                    value: company?.name ?? '',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  /// store_name 불일치 비교 표시용 행 위젯
  Widget _buildComparisonRow({
    required ThemeData theme,
    required ColorScheme scheme,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Get valid address (non-URL) from location or address field
  String _getValidAddress(Company c) {
    if (c.location.isNotEmpty && !_isUrl(c.location)) return c.location;
    if (c.address.isNotEmpty && !_isUrl(c.address)) return c.address;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      /// AppBar: show logo + company name when loaded
      appBar: AppBar(title: _buildAppBarTitle(theme, scheme), elevation: 0),
      body: _buildBody(scheme, theme),
    );
  }

  /// AppBar title: logo + company name (compact)
  Widget _buildAppBarTitle(ThemeData theme, ColorScheme scheme) {
    if (company == null) {
      return Text(T.pointEvent, style: theme.textTheme.titleLarge);
    }

    final c = company!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Company logo in AppBar
        if (c.logo_url.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              c.logo_url,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FaIcon(
                  FontAwesomeIcons.building,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        if (c.logo_url.isNotEmpty) const SizedBox(width: 8),
        Flexible(
          child: Text(
            c.name,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme scheme, ThemeData theme) {
    /// Loading state
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              T.loading,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    /// Error state
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 48,
                color: scheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                T.failedToLoadCompanies,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadCompany();
                },
                icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                label: Text(T.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (company == null) return const SizedBox.shrink();

    final c = company!;
    final contactSummary = _buildContactSummary(c);
    final validAddress = _getValidAddress(c);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// Compact company info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Company name + title (one line each)
                if (c.title.isNotEmpty)
                  Text(
                    c.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                /// Category tag (compact)
                if (c.category.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      c.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],

                /// Contact summary (one line: phone · mobile · kakao)
                if (contactSummary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.phone,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          contactSummary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                /// Address (one line)
                if (validAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          validAddress,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                /// Description (one line)
                if (c.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.circleInfo,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                /// View full details link
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => CompanyViewScreen.push(context, widget.idx),
                  child: Text(
                    T.viewDetails,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 12),

          /// 현재 로그인 사용자 정보 카드 (v7 API user.me)
          _buildUserInfoSection(scheme, theme),

          const SizedBox(height: 12),

          /// QR 코드 검증 결과 카드
          _buildScanResultSection(scheme, theme),

          /// 업로드된 영수증 결과 표시
          if (receiptData != null) ...[
            const SizedBox(height: 12),
            _buildReceiptResultCard(scheme, theme),
          ],

          /// Spacer to push button to bottom
          const Spacer(),

          /// 영수증 업로드 버튼 (V7FileUpload로 감싸기)
          if (userInfo != null)
            V7FileUpload(
                  idxMember: userInfo!['idx']?.toString() ?? '',
                  apiMethod: 'ai.analyzeReceipt',
                  module: 'receipt',
                  extraData: {
                    'company_idx': widget.idx.toString(),
                    'company_name': company?.name ?? '',
                  },
                  onBeforeUpload: () {
                    setState(() {
                      isUploading = true;
                      uploadProgress = 0.0;
                    });
                  },
                  onProgress: (progress) {
                    setState(() {
                      uploadProgress = progress;
                    });
                  },
                  onUploaded: (result) {
                    setState(() {
                      receiptData = result;
                      isUploading = false;
                      uploadProgress = 0.0;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      isUploading = false;
                      uploadProgress = 0.0;
                    });
                  },
                  onCancelled: () {
                    setState(() {
                      isUploading = false;
                      uploadProgress = 0.0;
                    });
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: isUploading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: uploadProgress > 0
                                    ? uploadProgress
                                    : null,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  scheme.onPrimary,
                                ),
                              ),
                            )
                          : const FaIcon(FontAwesomeIcons.receipt, size: 18),
                      label: Text(
                        isUploading
                            ? '업로드 중... ${(uploadProgress * 100).toInt()}%'
                            : T.uploadReceiptForPointEvent,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

          /// userInfo 로딩 중이면 비활성 버튼 표시
          if (userInfo == null)
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const FaIcon(FontAwesomeIcons.receipt, size: 18),
                    label: Text(
                      T.uploadReceiptForPointEvent,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
