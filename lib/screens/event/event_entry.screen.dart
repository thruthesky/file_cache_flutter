import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
import 'package:philgo/v7_api/user_api.dart';
import 'package:philgo/screens/event/event_coupon.screen.dart';
import 'package:philgo/v7_api/state/v7_settings_state.dart';
import 'package:philgo/v7_api/v7_api.dart';
import 'package:philgo/widgets/spinning_wheel.dart';
import 'package:provider/provider.dart' show Selector;

/// 이벤트 응모 화면 (Event Entry Screen)
///
/// 스피닝 휠 형태의 원판 돌리기 랜덤 뽑기 게임.
/// 서버 event.spin API로 결과를 미리 결정하고, 클라이언트는 해당 결과에 맞춰 원판을 돌림.
/// AppBar 우측에 쿠폰 확인 버튼으로 당첨 쿠폰 목록 화면으로 이동 가능.
class EventEntryScreen extends StatefulWidget {
  static const String routeName = '/event-entry';

  /// 화면 이동 헬퍼
  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const EventEntryScreen({super.key});

  @override
  State<EventEntryScreen> createState() => _EventEntryScreenState();
}

class _EventEntryScreenState extends State<EventEntryScreen> {
  /// 원판 섹션 목록 (build에서 l10n 필요하므로 late 초기화)
  late List<WheelSection> _sections;

  /// 마지막 서버 스핀 응답 (쿠폰 URL 등 추가 정보용)
  Map<String, dynamic>? _lastSpinResult;

  /// 원판 활동 상태 (회전 중 또는 연속 돌리기 중)
  bool _isWheelBusy = false;

  /// v7 API로 가져온 현재 로그인 사용자 정보
  Map<String, dynamic>? _userInfo;
  bool _isUserLoading = true;
  String? _userErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// v7 API user.me로 현재 로그인 사용자 정보를 가져온다
  Future<void> _loadUserInfo() async {
    try {
      final result = await UserApi.me();
      if (!mounted) return;
      setState(() {
        _userInfo = result;
        _isUserLoading = false;
      });
    } catch (e) {
      debugPrint('v7api user.me 에러: $e');
      if (!mounted) return;
      setState(() {
        _userErrorMessage = e.toString();
        _isUserLoading = false;
      });
    }
  }

  /// 원판 회전 완료 후 사용자 포인트/레벨 갱신 (로딩 표시 없이 조용히)
  Future<void> _refreshUserInfo() async {
    try {
      final result = await UserApi.me();
      if (!mounted) return;
      setState(() {
        _userInfo = result;
      });
    } catch (_) {
      // 갱신 실패 시 무시 (기존 정보 유지)
    }
  }

  /// 서버 event.spin API 호출 → 결과 section_index 반환.
  /// 에러 시 스낵바 표시 후 null 반환 (스핀 취소).
  /// 쿠폰 소진 에러이면 V7SettingsState를 갱신하여 스피닝 휠을 숨긴다.
  Future<int?> _callSpinApi() async {
    try {
      final result = await v7api('event.spin');

      // 서버 응답 저장 (결과 배너에서 쿠폰 정보 등 사용)
      _lastSpinResult = result;

      // 서버 응답의 남은 쿠폰 수로 V7SettingsState 실시간 갱신
      // 쿠폰 당첨(starbucks)인 경우: 즉시 갱신하지 않음 (onResult에서 축하 다이얼로그 표시 후 갱신)
      final prizeType = result['prize_type']?.toString();
      final availableCoupons = (result['available_coupons'] as num?)?.toInt();
      if (mounted && availableCoupons != null && prizeType != 'starbucks') {
        V7SettingsState.of(context).updateAvailableStarbucksCoupons(availableCoupons);
      }

      return result['section_index'] as int;
    } catch (e) {
      if (mounted) {
        final errorMsg = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll(RegExp(r'^v7api\([^)]*\):\s*'), '');

        // 쿠폰 소진 에러이면 V7SettingsState를 0으로 갱신 → 스피닝 휠 숨김
        // V7SettingsState 갱신 전에 busy 상태를 먼저 해제한다.
        // Selector 리빌드로 SpinningWheel이 제거되면 onBusyChanged가
        // 호출되지 않을 수 있으므로, 여기서 선제적으로 reset한다.
        if (errorMsg.contains('쿠폰') || errorMsg.contains('coupon')) {
          setState(() => _isWheelBusy = false);
          V7SettingsState.of(context).updateAvailableStarbucksCoupons(0);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = Lo.of(context)!;

    /// 원판 섹션 정의 (10개 섹션, 총 weight = 1000 → 확률 0.1% 단위)
    /// 꽝 30%, 50P 37.9%, 100P 8%, 200P 7%, 300P 6%, 400P 5%,
    /// 500P 4%, 1000P 1.5%, 2000P 0.4%, 스타벅스 쿠폰 0.2%
    /// 서버 section_index와 동일한 순서:
    /// 0=50P, 1=100P, 2=200P, 3=300P, 4=400P, 5=500P,
    /// 6=1000P, 7=2000P, 8=스타벅스, 9=꽝
    _sections = [
      WheelSection(label: '50', color: const Color(0xFFE88B8B), points: 50, weight: 379),
      WheelSection(label: '100', color: const Color(0xFFE8A87C), points: 100, weight: 80),
      WheelSection(label: '200', color: const Color(0xFFF5B971), points: 200, weight: 70),
      WheelSection(label: '300', color: const Color(0xFFD4A76A), points: 300, weight: 60),
      WheelSection(label: '400', color: const Color(0xFFD4B896), points: 400, weight: 50),
      WheelSection(label: '500', color: const Color(0xFFE8C170), points: 500, weight: 40),
      WheelSection(
        label: '1,000',
        color: const Color(0xFFC9A9C9),
        points: 1000,
        weight: 15,
        icon: FontAwesomeIcons.solidStar,
      ),
      WheelSection(
        label: '2,000',
        color: const Color(0xFF9CC2D8),
        points: 2000,
        weight: 4,
        icon: FontAwesomeIcons.solidStar,
        iconCount: 2,
      ),
      WheelSection(
        label: l10n.spinWheelCoupon,
        color: const Color(0xFF8BC78B),
        points: -1,
        weight: 2,
        icon: FontAwesomeIcons.lightMugHot,
      ),
      WheelSection(
        label: l10n.spinWheelMiss,
        color: const Color(0xFFB0B0B0),
        points: 0,
        weight: 300,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickMenuEventEntry),
        actions: [
          /// 이벤트 쿠폰 당첨 목록 화면 이동 버튼
          IconButton(
            onPressed: () {
              if (_isWheelBusy) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.spinWheelStopFirst)),
                );
                return;
              }
              EventCouponScreen.push(context);
            },
            icon: const FaIcon(FontAwesomeIcons.lightTicket, size: 20),
            tooltip: l10n.eventCoupon,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            /// 사용자 프로필 + 포인트 정보
            _buildUserProfileSection(theme, scheme),
            const SizedBox(height: 16),

            /// 스타벅스 쿠폰 소진 여부에 따라 스피닝 휠 또는 안내 메시지 표시
            Selector<V7SettingsState, int>(
              selector: (_, state) =>
                  state.settings?.availableStarbucksCoupons ?? -1,
              builder: (context, availableCoupons, _) {
                /// 쿠폰 수량 0이면 소진 안내 메시지
                if (availableCoupons == 0) {
                  return _buildCouponsExhaustedBanner(theme, scheme, l10n);
                }

                /// 쿠폰이 남아있거나 아직 로딩 중(-1)이면 스피닝 휠 표시
                return SpinningWheel(
              sections: _sections,
              instructionText: l10n.spinWheelInstruction,
              disclaimerText: l10n.spinWheelDisclaimer,
              costNoticeText: l10n.spinWheelCostNotice,
              spinButtonText: l10n.spinWheelSpin,
              onSpinRequested: _callSpinApi,
              onResult: (section) {
                _refreshUserInfo();
                // 쿠폰 당첨(points == -1)이면 축하 다이얼로그 + 사운드 재생
                if (section.points == -1) {
                  _showCouponCongratulationsDialog();
                }
              },
              resultBuilder: (section) => _buildResultBanner(
                theme: theme,
                scheme: scheme,
                l10n: l10n,
                section: section,
              ),
              autoSpinButtonText: l10n.spinWheelAutoSpin,
              autoSpinStopText: l10n.spinWheelStop,
              autoSpinOptions: [
                AutoSpinOption(label: l10n.spinWheelAutoSpinCount(5), count: 5),
                AutoSpinOption(label: l10n.spinWheelAutoSpinCount(10), count: 10),
                AutoSpinOption(label: l10n.spinWheelAutoSpinCount(20), count: 20),
                AutoSpinOption(label: l10n.spinWheelAutoSpinCount(30), count: 30),
                AutoSpinOption(label: l10n.spinWheelAutoSpinCount(50), count: 50),
                AutoSpinOption(label: l10n.spinWheelUntilCoupon, count: -1),
              ],
              /// 쿠폰(points == -1) 당첨 시 연속 돌리기 중지
              autoSpinStopCondition: (section) => section.points == -1,
              onBusyChanged: (busy) => setState(() => _isWheelBusy = busy),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 사용자 프로필 + 포인트 정보 섹션
  Widget _buildUserProfileSection(ThemeData theme, ColorScheme scheme) {
    /// 로딩 중
    if (_isUserLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
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
              '로딩 중...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    /// 에러 발생 시
    if (_userErrorMessage != null) {
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isUserLoading = true;
                  _userErrorMessage = null;
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
    if (_userInfo == null) return const SizedBox.shrink();

    final name = _userInfo!['name']?.toString() ?? '';
    final nickname = _userInfo!['nickname']?.toString() ?? '';
    final id = _userInfo!['id']?.toString() ?? '';
    final photoUrl = _userInfo!['photo_url']?.toString() ?? '';
    final point = (_userInfo!['point'] as num?)?.toInt() ?? 0;
    final level = (_userInfo!['level'] as num?)?.toInt() ?? 0;

    /// 표시할 이름 결정: name > nickname > id
    final displayName = name.isNotEmpty
        ? name
        : nickname.isNotEmpty
            ? nickname
            : id;

    /// 포인트 포맷 (천 단위 콤마)
    final pointFormatted = point.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// 프로필 사진 / 기본 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: photoUrl.startsWith('http')
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: FaIcon(
                        FontAwesomeIcons.solidUser,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ),
                  )
                : Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidUser,
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          /// 이름 + 서브 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  level > 0 ? 'Lv.$level' : 'Lv...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          /// 포인트 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.solidCoins,
                  size: 12,
                  color: scheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${pointFormatted}P',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  /// 당첨 결과 인라인 배너 (버튼 아래 표시)
  Widget _buildResultBanner({
    required ThemeData theme,
    required ColorScheme scheme,
    required Lo l10n,
    required WheelSection section,
  }) {
    final isMiss = section.points == 0;
    final isCoupon = section.points == -1;
    final String message;
    if (isMiss) {
      message = l10n.spinWheelResultMiss;
    } else if (isCoupon) {
      message = l10n.spinWheelResultCoupon;
    } else {
      message = l10n.spinWheelResultPoints(section.points);
    }

    /// 서버 응답에서 잔여 포인트 (표시용)
    final currentPoint = (_lastSpinResult?['current_point'] as num?)?.toInt();
    final pointSuffix = currentPoint != null
        ? ' (${currentPoint.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            )}P)'
        : '';

    /// 결과 유형에 따른 배경색/텍스트색
    final Color bgColor;
    final Color textColor;
    if (isMiss) {
      bgColor = scheme.surfaceContainerHighest;
      textColor = scheme.onSurfaceVariant;
    } else {
      bgColor = scheme.primaryContainer;
      textColor = scheme.onPrimaryContainer;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$message$pointSuffix',
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor,
          fontWeight: isMiss ? FontWeight.normal : FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 스타벅스 쿠폰 당첨 축하 다이얼로그 + pangpare.mp3 사운드 재생
  ///
  /// 다이얼로그가 닫힌 후 V7SettingsState의 available_coupons를 갱신한다.
  /// 쿠폰이 마지막이었으면(0) Selector가 감지하여 소진 메시지를 표시한다.
  Future<void> _showCouponCongratulationsDialog() async {
    final player = AudioPlayer();
    try {
      // pangpare.mp3 사운드 재생
      await player.play(AssetSource('sound/pangpare.mp3'));
    } catch (e) {
      debugPrint('축하 사운드 재생 실패: $e');
    }

    if (!mounted) {
      player.dispose();
      return;
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // 축하 다이얼로그 표시
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.solidMugHot,
              size: 56,
              color: scheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '축하합니다!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '스타벅스 쿠폰에 당첨되었습니다!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );

    // 다이얼로그 닫힌 후 사운드 정리
    player.dispose();

    // 다이얼로그 닫힌 후 V7SettingsState 갱신 → 0이면 소진 메시지 전환
    final availableCoupons =
        (_lastSpinResult?['available_coupons'] as num?)?.toInt();
    if (mounted && availableCoupons != null) {
      V7SettingsState.of(context)
          .updateAvailableStarbucksCoupons(availableCoupons);
    }

    // 축하 다이얼로그 확인 후 쿠폰 목록 페이지로 이동
    if (mounted) {
      EventCouponScreen.push(context);
    }
  }

  /// 스타벅스 쿠폰 소진 안내 배너
  ///
  /// 카드 형태의 레이아웃으로 아이콘 + 설명 + 쿠폰 확인 버튼을 구성.
  /// Flat design 원칙에 따라 색상 대비만으로 요소를 구분한다.
  Widget _buildCouponsExhaustedBanner(
    ThemeData theme,
    ColorScheme scheme,
    Lo l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 (인디케이터 바 + 아이콘 + 타이틀)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              /// 인디케이터 바 (3px × 16px)
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.lightMugHot,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.eventCoupon,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),

        /// 메인 카드 컨테이너
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            children: [
              /// 커피 아이콘 (그라데이션 원형 배경)
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer.withValues(alpha: 0.6),
                      scheme.primaryContainer.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightMugHot,
                    size: 36,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// 안내 메시지
              Text(
                l10n.spinWheelCouponsExhausted,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              /// 쿠폰 목록 보기 버튼
              /// FilledButton 내부에 inline style을 지정하지 않아야 기본 foreground 색상 적용됨
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => EventCouponScreen.push(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.lightTicket, size: 16),
                  label: Text(l10n.eventCoupon),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0),
      ],
    );
  }
}
