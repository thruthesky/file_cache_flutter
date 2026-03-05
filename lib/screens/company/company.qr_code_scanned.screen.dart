import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.revisit_point_result.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/screens/company/company.visit_review.screen.dart';
import 'package:philgo/v7_api/company_api.dart';
import 'package:philgo/v7_api/user_api.dart';
import 'package:philgo/v7_api/v7_api.dart';
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
  final String code;

  const CompanyQrCodeScannedScreen({
    super.key,
    required this.idx,
    required this.code,
  });

  static Future<void> Function(BuildContext ctx, int idx, String code)
  push = (ctx, idx, code) =>
      ctx.push('$routeName?idx=$idx&code=$code');

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

  /// QR 코드 검증 상태
  Map<String, dynamic>? scanResult;
  bool isScanLoading = true;
  String? scanErrorMessage;

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print('[QR-SCANNED] ===== CompanyQrCodeScannedScreen initState =====');
    // ignore: avoid_print
    print('[QR-SCANNED] widget.idx: ${widget.idx}, widget.code: ${widget.code}');

    /// idx가 있으면 바로 업소 정보 로드, 없으면 scanQrCode 응답 후 로드
    if (widget.idx > 0) {
      _loadCompany(widget.idx);
    }
    _loadUserInfo();
    _scanQrCode();
  }

  /// 업소 정보 로드 (idx로 CompanyApi.get 호출)
  Future<void> _loadCompany(int idx) async {
    // ignore: avoid_print
    print('[QR-SCANNED] _loadCompany 호출, idx: $idx');
    try {
      final details = await CompanyApi.get(idx);
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
  /// 성공 응답: { success, usage_idx, idx_company, company_name, reward_points,
  ///            point_before, point_after, is_revisit }
  /// 거부 응답: { result: 'r', message: '...' }
  /// 실패 시: RuntimeException → catch로 처리
  Future<void> _scanQrCode() async {
    // ignore: avoid_print
    print('[QR-SCANNED] ===== _scanQrCode 호출 =====');
    // ignore: avoid_print
    print('[QR-SCANNED] code: ${widget.code}');
    try {
      final result = await v7api('company.scanQrCode', data: {
        'code': widget.code,
      });
      // ignore: avoid_print
      print('[QR-SCANNED] scanQrCode 성공 응답: $result');
      if (!mounted) return;
      setState(() {
        scanResult = result;
        isScanLoading = false;
      });

      /// idx가 0이었으면 서버 응답의 idx_company로 업소 정보 로드
      if (widget.idx == 0 && result['idx_company'] != null) {
        final companyIdx = (result['idx_company'] as num).toInt();
        // ignore: avoid_print
        print('[QR-SCANNED] widget.idx==0, 서버 응답 idx_company: $companyIdx');
        if (companyIdx > 0) {
          _loadCompany(companyIdx);
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[QR-SCANNED] scanQrCode API 에러: $e');
      debugLog('company.scanQrCode API 에러: $e');
      if (!mounted) return;
      setState(() {
        scanErrorMessage = e.toString();
        isScanLoading = false;
        /// idx가 0이면 업소 정보도 로딩 해제
        if (widget.idx == 0) isLoading = false;
      });
    }
  }

  /// v7 API 에러 메시지에서 핵심 메시지만 추출
  /// "Exception: v7api(company.scanQrCode): 만료된 QR 코드입니다." → "만료된 QR 코드입니다."
  String _extractErrorMessage(String rawError) {
    final colonIdx = rawError.lastIndexOf('): ');
    if (colonIdx != -1) {
      return rawError.substring(colonIdx + 3);
    }
    if (rawError.startsWith('Exception: ')) {
      return rawError.substring(11);
    }
    return rawError;
  }

  /// 에러 메시지를 분석하여 에러 유형 정보를 반환
  /// { icon, title, description, extra }
  ({IconData icon, String title, String description, String? extra})
      _classifyError(String? rawError) {
    if (rawError == null) {
      return (
        icon: FontAwesomeIcons.lightCircleExclamation,
        title: T.qrErrorGeneric,
        description: T.qrErrorGenericDesc,
        extra: null,
      );
    }

    final msg = _extractErrorMessage(rawError);

    /// 24시간 중복: "24시간_중복|2026년 03월 02일 04:43"
    if (msg.startsWith('24시간_중복')) {
      final parts = msg.split('|');
      final lastVisitTime = parts.length > 1 ? parts[1] : '';
      return (
        icon: FontAwesomeIcons.lightClockRotateLeft,
        title: T.qrErrorDuplicate24h,
        description: T.qrErrorDuplicate24hDesc,
        extra: lastVisitTime.isNotEmpty ? T.qrErrorLastVisit(lastVisitTime) : null,
      );
    }

    /// 만료된 QR 코드
    if (msg.contains('만료된')) {
      return (
        icon: FontAwesomeIcons.lightHourglassEnd,
        title: T.qrErrorExpired,
        description: T.qrErrorExpiredDesc,
        extra: null,
      );
    }

    /// 유효하지 않은 QR 코드
    if (msg.contains('유효하지 않은')) {
      return (
        icon: FontAwesomeIcons.lightQrcode,
        title: T.qrErrorInvalid,
        description: T.qrErrorInvalidDesc,
        extra: null,
      );
    }

    /// 비활성화된 QR 코드
    if (msg.contains('비활성화')) {
      return (
        icon: FontAwesomeIcons.lightBan,
        title: T.qrErrorDisabled,
        description: T.qrErrorDisabledDesc,
        extra: null,
      );
    }

    /// 업소 유효하지 않음
    if (msg.contains('업소')) {
      return (
        icon: FontAwesomeIcons.lightBuilding,
        title: T.qrErrorCompanyInvalid,
        description: T.qrErrorCompanyInvalidDesc,
        extra: null,
      );
    }

    /// 기타 에러
    return (
      icon: FontAwesomeIcons.lightCircleExclamation,
      title: T.qrErrorGeneric,
      description: msg,
      extra: null,
    );
  }

  /// QR 스캔 실패 또는 업소 정보 없음 에러 화면
  /// 에러 유형별 아이콘, 제목, 설명을 구조화하여 표시
  Widget _buildScanErrorScreen(ColorScheme scheme, ThemeData theme) {
    final errorInfo = _classifyError(scanErrorMessage);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 에러 아이콘 (원형 배경)
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(44),
              ),
              child: Center(
                child: FaIcon(
                  errorInfo.icon,
                  size: 38,
                  color: scheme.error,
                ),
              ),
            ).animate().scale(
                  duration: 500.ms,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 24),

            /// 에러 제목
            Text(
              errorInfo.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 16),

            /// 에러 상세 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  /// 설명 텍스트
                  Text(
                    errorInfo.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  /// 추가 정보 (예: 이전 방문 시간)
                  if (errorInfo.extra != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightClock,
                            size: 14,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            errorInfo.extra!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.primary,
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

            const SizedBox(height: 12),

            /// 안내 텍스트
            Text(
              T.qrScanRetryGuide,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            const SizedBox(height: 32),

            /// 돌아가기 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const FaIcon(FontAwesomeIcons.lightArrowLeft, size: 16),
                label: Text(T.goBack),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  /// Check if a string value is a URL (not a real address/location)
  bool _isUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }


  /// 현재 로그인 사용자 정보 섹션 위젯
  /// v7 API user.me 응답 데이터를 중앙 정렬로 표시
  /// 아바타 + 닉네임 + 포인트 + 관리레벨
  Widget _buildUserInfoSection(ColorScheme scheme, ThemeData theme) {
    /// 로딩 중
    if (isUserLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ),
      );
    }

    /// 에러 발생 시
    if (userErrorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 14,
              color: scheme.error,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '사용자 정보를 가져올 수 없습니다.',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
            const SizedBox(width: 8),
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

    final nickname = userInfo!['nickname']?.toString() ?? '';
    final name = userInfo!['name']?.toString() ?? '';
    final id = userInfo!['id']?.toString() ?? '';
    final photoUrl = userInfo!['photo_url']?.toString() ?? '';
    final point = (userInfo!['point'] as num?)?.toInt() ?? 0;

    /// 표시할 이름: nickname > name > id
    final displayName = nickname.isNotEmpty
        ? nickname
        : name.isNotEmpty
            ? name
            : id;

    /// 컴팩트 가로 레이아웃: 아바타 + 닉네임 + 포인트 배지
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// 아바타 (컴팩트 36px)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.1),
            ),
            clipBehavior: Clip.antiAlias,
            child: photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: FaIcon(
                        FontAwesomeIcons.solidUser,
                        size: 16,
                        color: scheme.primary,
                      ),
                    ),
                  )
                : Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidUser,
                      size: 16,
                      color: scheme.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          /// 닉네임
          Expanded(
            child: Text(
              displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// 포인트 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCoins,
                  size: 12,
                  color: scheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatNumber(point)}P',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
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


  /// 숫자를 천 단위 콤마로 포맷
  String _formatNumber(int number) {
    final result = StringBuffer();
    final str = number.toString();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) result.write(',');
      result.write(str[i]);
    }
    return result.toString();
  }

  /// Best Practice 섹션 헤더 위젯 (인디케이터 바 + 아이콘 + 타이틀)
  Widget _buildSectionHeader(
    String title,
    IconData icon,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          /// 세로 인디케이터 바
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),

          /// 아이콘
          FaIcon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),

          /// 타이틀
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 고정 CTA 버튼 (강조 디자인)
  /// 삼단콤보: 재방문 → 추첨, 첫방문 → 후기 작성
  Widget _buildBottomActionButton(ColorScheme scheme, ThemeData theme) {
    final isRevisit = scanResult!['is_revisit'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 안내 텍스트
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightSparkles,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  T.earnExtraPoints,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// CTA 버튼 — 강조 디자인 (primary 배경 + 큰 아이콘/텍스트 + 펄스 + shimmer)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final usageIdx =
                      (scanResult?['usage_idx'] as num?)?.toInt() ?? 0;
                  final idxCompany =
                      (scanResult?['idx_company'] as num?)?.toInt() ??
                          widget.idx;
                  if (isRevisit) {
                    CompanyRevisitPointResultScreen.push(
                      context,
                      usageIdx: usageIdx,
                      idxCompany: idxCompany,
                      companyName: company?.name ?? '',
                    );
                  } else {
                    CompanyVisitReviewScreen.push(
                      context,
                      usageIdx: usageIdx,
                      idxCompany: idxCompany,
                      companyName: company?.name ?? '',
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
                        color: scheme.onPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isRevisit
                            ? T.revisitPointEventDraw
                            : T.writeReviewForPoints,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scaleXY(
                begin: 1.0,
                end: 1.03,
                duration: 1200.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .shimmer(
                duration: 1500.ms,
                color: scheme.onPrimary.withValues(alpha: 0.3),
              ),
        ],
      ),
    );
  }

  /// QR 코드 검증 결과 섹션 위젯
  /// company.scanQrCode API 응답 표시:
  /// - 성공: reward_points, is_revisit, point_after 등 표시
  /// - 거부: result='r', message 표시
  /// - 에러: 에러 메시지 + 재시도 버튼
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

    /// API 호출 에러 (RuntimeException 등)
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

    /// 응답 형식 판별:
    /// - 성공: { success: true, reward_points, is_revisit, ... }
    /// - 거부: { result: 'r', message: '...' }
    final bool isSuccess = scanResult!['success'] == true;
    final bool isRejected = scanResult!['result']?.toString() == 'r';
    final message = scanResult!['message']?.toString() ?? '';
    final rewardPoints = (scanResult!['reward_points'] as num?)?.toInt() ?? 0;
    final pointAfter = (scanResult!['point_after'] as num?)?.toInt() ?? 0;
    final companyName = scanResult!['company_name']?.toString() ?? '';

    /// 결과 코드별 색상 및 아이콘 결정
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

    /// 포인트 포맷 (천 단위 콤마)
    String formatPoint(int p) => p.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    return Column(
      children: [
        /// 스캔 결과 상태 카드
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
                              : 'QR 코드 스캔 성공!')
                          : message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              /// 성공 시 적립 포인트 표시
              if (isSuccess && rewardPoints > 0) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.solidCoins,
                        size: 16,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${formatPoint(rewardPoints)}P 적립!',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pointAfter > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(현재 ${formatPoint(pointAfter)}P)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
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
      appBar: AppBar(
        title: _buildAppBarTitle(theme, scheme),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ),
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
                  /// 재시도: widget.idx > 0이면 widget.idx, 아니면 scanResult에서 idx_company 사용
                  final retryIdx = widget.idx > 0
                      ? widget.idx
                      : (scanResult?['idx_company'] as num?)?.toInt() ?? 0;
                  if (retryIdx > 0) {
                    _loadCompany(retryIdx);
                  } else {
                    setState(() => isLoading = false);
                  }
                },
                icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                label: Text(T.retry),
              ),
            ],
          ),
        ),
      );
    }

    /// QR 스캔 에러 또는 업소 정보 없음: 에러 화면 표시
    if (company == null) {
      return _buildScanErrorScreen(scheme, theme);
    }

    final c = company!;
    final validAddress = _getValidAddress(c);
    /// 전화번호 표시: phone_number 우선, 없으면 mobile_number
    final phoneDisplay = c.phone_number.isNotEmpty
        ? c.phone_number
        : c.mobile_number.isNotEmpty
            ? c.mobile_number
            : '';

    return Column(
      children: [
        /// 스크롤 가능한 콘텐츠 영역
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                /// 섹션 1: 업소 정보
                _buildSectionHeader(
                  T.companyInfoSection,
                  FontAwesomeIcons.lightBuilding,
                  scheme,
                  theme,
                ),
                /// 업소 정보 — 컴팩트 (전화번호 + 주소 + 상세보기)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      /// 전화번호 + 주소
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (phoneDisplay.isNotEmpty)
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
                                      phoneDisplay,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            if (validAddress.isNotEmpty) ...[
                              if (phoneDisplay.isNotEmpty)
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
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
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

                      /// 상세보기 버튼
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            CompanyViewScreen.push(context, widget.idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            T.viewDetails,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                /// 섹션 2: 방문자 정보
                _buildSectionHeader(
                  T.visitorInfo,
                  FontAwesomeIcons.lightUser,
                  scheme,
                  theme,
                ),
                _buildUserInfoSection(scheme, theme),

                const SizedBox(height: 24),

                /// 섹션 3: QR 스캔 결과
                _buildSectionHeader(
                  T.qrScanResult,
                  FontAwesomeIcons.lightQrcode,
                  scheme,
                  theme,
                ),
                _buildScanResultSection(scheme, theme),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        /// 하단 고정 CTA 버튼 (강조)
        if (scanResult != null && scanResult!['success'] == true)
          _buildBottomActionButton(scheme, theme),
      ],
    );
  }
}
