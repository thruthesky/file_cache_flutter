import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/event/event.model.dart';
import 'package:philgo/event/event.service.dart';
import 'package:philgo/event/event_coupon.screen.dart';
import 'package:philgo/event/widgets/spinning_wheel.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/setting/setting.state.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/user.service.dart';
import 'package:provider/provider.dart';

/// 이벤트응모(스피닝 휠) 화면
///
/// 사용자 프로필과 포인트를 표시하고, 스피닝 휠로 경품에 응모한다.
/// 쿠폰이 소진되면 안내 배너를 표시한다.
class EventEntryScreen extends StatefulWidget {
  static const String routeName = '/event-entry';
  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const EventEntryScreen({super.key});

  @override
  State<EventEntryScreen> createState() => _EventEntryScreenState();
}

class _EventEntryScreenState extends State<EventEntryScreen> {
  UserModel? _userInfo;
  bool _isUserLoading = true;
  String? _userErrorMessage;

  /// 마지막 서버 스핀 응답 (결과 배너에서 현재 포인트 표시용)
  SpinResult? _lastSpinResult;

  /// 원판 활동 상태 (회전 중 또는 연속 돌리기 중)
  bool _isWheelBusy = false;

  /// 원판 섹션 정의 (build에서 초기화)
  late List<WheelSection> _sections;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// 원판 섹션 초기화 (10개 섹션, 총 weight = 1000 → 확률 0.1% 단위)
  /// 꽝 30%, 50P 37.9%, 100P 8%, 200P 7%, 300P 6%, 400P 5%,
  /// 500P 4%, 1000P 1.5%, 2000P 0.4%, 스타벅스 쿠폰 0.2%
  /// 서버 section_index와 동일한 순서:
  /// 0=50P, 1=100P, 2=200P, 3=300P, 4=400P, 5=500P,
  /// 6=1000P, 7=2000P, 8=스타벅스, 9=꽝
  void _buildSections() {
    _sections = [
      const WheelSection(
        label: '50',
        color: Color(0xFFE88B8B),
        points: 50,
        weight: 379,
      ),
      const WheelSection(
        label: '100',
        color: Color(0xFFE8A87C),
        points: 100,
        weight: 80,
      ),
      const WheelSection(
        label: '200',
        color: Color(0xFFF5B971),
        points: 200,
        weight: 70,
      ),
      const WheelSection(
        label: '300',
        color: Color(0xFFD4A76A),
        points: 300,
        weight: 60,
      ),
      const WheelSection(
        label: '400',
        color: Color(0xFFD4B896),
        points: 400,
        weight: 50,
      ),
      const WheelSection(
        label: '500',
        color: Color(0xFFE8C170),
        points: 500,
        weight: 40,
      ),
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
        label: '쿠폰'.tr(),
        color: const Color(0xFF8BC78B),
        points: -1,
        weight: 2,
        icon: FontAwesomeIcons.lightMugHot,
      ),
      WheelSection(
        label: '꽝'.tr(),
        color: const Color(0xFFB0B0B0),
        points: 0,
        weight: 300,
      ),
    ];
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isUserLoading = true;
      _userErrorMessage = null;
    });
    try {
      final user = await UserService.loadCurrentUser();
      if (!mounted) return;
      setState(() {
        _userInfo = user;
        _isUserLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userErrorMessage = e.toString();
        _isUserLoading = false;
      });
    }
  }

  /// 조용히 사용자 정보 갱신 (포인트 반영)
  Future<void> _refreshUserInfo() async {
    try {
      final user = await UserService.loadCurrentUser();
      if (!mounted) return;
      setState(() => _userInfo = user);
    } catch (_) {}
  }

  /// 서버 event.spin API 호출 → 결과 section_index 반환.
  /// 에러 시 스낵바 표시 후 null 반환 (스핀 취소).
  /// 쿠폰 소진 에러이면 SettingsState를 갱신하여 스피닝 휠을 숨긴다.
  Future<int?> _callSpinApi() async {
    try {
      final result = await EventService.spin();
      _lastSpinResult = result;

      // 쿠폰 당첨이 아닌 경우만 즉시 쿠폰 수량 갱신
      if (mounted && !result.isCoupon) {
        SettingsState.of(context)
            .updateAvailableStarbucksCoupons(result.availableCoupons);
      }

      return result.sectionIndex;
    } catch (e) {
      if (mounted) {
        final errorMsg = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll(RegExp(r'^v7api\([^)]*\):\s*'), '');

        // 쿠폰 소진 에러이면 busy 상태 해제 후 SettingsState 갱신
        if (errorMsg.contains('쿠폰') || errorMsg.contains('coupon')) {
          setState(() => _isWheelBusy = false);
          SettingsState.of(context).updateAvailableStarbucksCoupons(0);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
      return null;
    }
  }

  /// 스타벅스 쿠폰 당첨 축하 다이얼로그 + pangpare.mp3 사운드 재생
  Future<void> _showCouponWinDialog() async {
    final player = AudioPlayer();
    try {
      await player.play(AssetSource('sound/pangpare.mp3'));
    } catch (_) {}

    if (!mounted) {
      player.dispose();
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.solidMugHot,
              size: 56,
              color: color.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '축하합니다!'.tr(),
              style: text.headlineSmall?.copyWith(
                color: color.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '스타벅스 쿠폰에 당첨되었습니다!'.tr(),
              style: text.bodyLarge?.copyWith(color: color.onSurface),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('확인'.tr()),
            ),
          ),
        ],
      ),
    );

    player.dispose();

    // 다이얼로그 닫힌 후 쿠폰 수량 갱신
    if (mounted && _lastSpinResult != null) {
      SettingsState.of(context)
          .updateAvailableStarbucksCoupons(_lastSpinResult!.availableCoupons);
    }

    // 쿠폰 목록 페이지로 이동
    if (mounted) EventCouponScreen.push(context);
  }

  @override
  Widget build(BuildContext context) {
    _buildSections();
    final spinCost = SettingsState.of(context).settings?.spinCost ?? 200;

    return Scaffold(
      appBar: AppBar(
        title: Text('이벤트응모'.tr()),
        actions: [
          IconButton(
            onPressed: () {
              if (_isWheelBusy) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('원판이 회전 중입니다. 잠시만 기다려주세요.'.tr()),
                  ),
                );
                return;
              }
              EventCouponScreen.push(context);
            },
            icon: const FaIcon(FontAwesomeIcons.lightTicket, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            _buildUserProfileSection(),
            const SizedBox(height: 16),
            _buildWheelOrExhaustedSection(spinCost),
          ],
        ),
      ),
    );
  }

  /// 사용자 프로필 + 포인트 섹션
  Widget _buildUserProfileSection() {
    if (_isUserLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
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
              '로딩 중...'.tr(),
              style: text.bodySmall?.copyWith(
                color: color.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_userErrorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 14,
              color: color.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '사용자 정보를 가져올 수 없습니다.'.tr(),
                style: text.bodySmall?.copyWith(color: color.error),
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
                color: color.error,
              ),
            ),
          ],
        ),
      );
    }

    final user = _userInfo;
    if (user == null) return const SizedBox.shrink();

    /// 포인트 포맷 (천 단위 콤마)
    final pointFormatted = user.point.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// 프로필 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.solidUser,
                size: 18,
                color: color.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          /// 이름 + 레벨
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: text.titleSmall?.copyWith(
                    color: color.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.level > 0 ? 'Lv.${user.level}' : 'Lv...',
                  style: text.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
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
              color: color.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.solidCoins,
                  size: 12,
                  color: color.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${pointFormatted}P',
                  style: text.labelMedium?.copyWith(
                    color: color.primary,
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

  /// 스피닝 휠 또는 쿠폰 소진 안내
  Widget _buildWheelOrExhaustedSection(int spinCost) {
    return Selector<SettingsState, int>(
      selector: (_, state) =>
          state.settings?.availableStarbucksCoupons ?? -1,
      builder: (context, availableCoupons, _) {
        if (availableCoupons == 0) return _buildExhaustedBanner();

        return SpinningWheel(
          sections: _sections,
          instructionText: '원판을 돌려 스타벅스 쿠폰에 도전해 보세요!'.tr(),
          disclaimerText: '회전판의 당첨 영역은 실제 당첨 확률과 다를 수 있습니다.'.tr(),
          costNoticeText: '추첨을 할 때마다 $spinCost 포인트가 소진됩니다.',
          spinButtonText: '원판 돌리기'.tr(),
          onSpinRequested: _callSpinApi,
          onResult: (section) {
            _refreshUserInfo();
            // 쿠폰 당첨(points == -1)이면 축하 다이얼로그
            if (section.points == -1) {
              _showCouponWinDialog();
            }
          },
          resultBuilder: (section) => _buildResultBanner(section),
          autoSpinButtonText: '연속 돌리기'.tr(),
          autoSpinStopText: '중지'.tr(),
          autoSpinOptions: [
            AutoSpinOption(label: '5회'.tr(), count: 5),
            AutoSpinOption(label: '10회'.tr(), count: 10),
            AutoSpinOption(label: '20회'.tr(), count: 20),
            AutoSpinOption(label: '30회'.tr(), count: 30),
            AutoSpinOption(label: '50회'.tr(), count: 50),
            AutoSpinOption(
              label: '스타벅스 쿠폰 나올 때까지'.tr(),
              count: -1,
            ),
          ],

          /// 쿠폰(points == -1) 당첨 시 연속 돌리기 중지
          autoSpinStopCondition: (section) => section.points == -1,
          onBusyChanged: (busy) => setState(() => _isWheelBusy = busy),
        );
      },
    );
  }

  /// 당첨 결과 인라인 배너
  Widget _buildResultBanner(WheelSection section) {
    final isMiss = section.points == 0;
    final isCoupon = section.points == -1;
    final String message;
    if (isMiss) {
      message = '아쉽게도 꽝입니다. 다시 도전해보세요!'.tr();
    } else if (isCoupon) {
      message = '스타벅스 쿠폰에 당첨되었습니다!'.tr();
    } else {
      message = '${section.points}P 포인트를 획득했습니다!';
    }

    /// 잔여 포인트 표시
    final currentPoint = _lastSpinResult?.currentPoint;
    final pointSuffix = currentPoint != null
        ? ' (${currentPoint.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            )}P)'
        : '';

    final Color bgColor;
    final Color textColor;
    if (isMiss) {
      bgColor = color.surfaceContainerHighest;
      textColor = color.onSurfaceVariant;
    } else {
      bgColor = color.primaryContainer;
      textColor = color.onPrimaryContainer;
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
        style: text.titleMedium?.copyWith(
          color: textColor,
          fontWeight: isMiss ? FontWeight.normal : FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 쿠폰 소진 안내 배너
  Widget _buildExhaustedBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더
        Padding(
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
              FaIcon(
                FontAwesomeIcons.lightMugHot,
                size: 14,
                color: color.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '이벤트 쿠폰'.tr(),
                style: text.titleSmall?.copyWith(
                  color: color.onSurface,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),

        /// 메인 카드
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.primaryContainer.withValues(alpha: 0.6),
                      color.primaryContainer.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightMugHot,
                    size: 36,
                    color: color.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '현재 쿠폰이 모두 소진되었습니다.\n새로운 쿠폰이 추가될 때까지 잠시만 기다려주세요.'
                    .tr(),
                style: text.bodyMedium?.copyWith(
                  color: color.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
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
                  label: Text('이벤트 쿠폰'.tr()),
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
