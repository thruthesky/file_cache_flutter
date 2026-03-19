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
  final _wheelKey = GlobalKey<SpinningWheelWidgetState>();

  UserModel? _userInfo;
  bool _isUserLoading = true;
  String? _userErrorMessage;
  SpinResult? _lastResult;
  bool _isSpinning = false;

  /// 원판 섹션 색상
  static const _sectionColors = [
    Color(0xFFE88B8B), // 50P
    Color(0xFFE8A87C), // 100P
    Color(0xFFF5B971), // 200P
    Color(0xFFD4A76A), // 300P
    Color(0xFFD4B896), // 400P
    Color(0xFFE8C170), // 500P
    Color(0xFFC9A9C9), // 1,000P
    Color(0xFF9CC2D8), // 2,000P
    Color(0xFF8BC78B), // 쿠폰
    Color(0xFFB0B0B0), // 꽝
  ];

  static const _sectionLabels = [
    '50P',
    '100P',
    '200P',
    '300P',
    '400P',
    '500P',
    '1,000P',
    '2,000P',
    '쿠폰',
    '꽝',
  ];

  List<WheelSectionData> get _sections => List.generate(
        _sectionLabels.length,
        (i) => WheelSectionData(
          label: _sectionLabels[i],
          color: _sectionColors[i],
        ),
      );

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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

  Future<void> _onSpin() async {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _lastResult = null;
    });

    try {
      final result = await EventService.spin();
      if (!mounted) return;

      // 스피닝 휠 회전
      await _wheelKey.currentState?.spinTo(result.sectionIndex);
      if (!mounted) return;

      // 쿠폰 수량 업데이트
      SettingsState.of(context).updateAvailableStarbucksCoupons(
        result.availableCoupons,
      );

      // 사용자 포인트 재로드
      _loadUserInfo();

      setState(() => _lastResult = result);

      // 쿠폰 당첨 시 축하 다이얼로그
      if (result.isCoupon && mounted) {
        _showCouponWinDialog();
      }
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString();
      // 쿠폰 소진 에러 감지
      if (errorMsg.contains('쿠폰') || errorMsg.contains('coupon')) {
        SettingsState.of(context).updateAvailableStarbucksCoupons(0);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      if (mounted) setState(() => _isSpinning = false);
    }
  }

  void _showCouponWinDialog() async {
    // 축하 사운드
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('sound/pangpare.mp3'));
    } catch (_) {}

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
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
              style:
                  text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '스타벅스 쿠폰에 당첨되었습니다!'.tr(),
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              EventCouponScreen.push(context);
            },
            child: Text('쿠폰 확인하기'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이벤트응모'.tr()),
        actions: [
          IconButton(
            onPressed: () {
              if (_isSpinning) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('원판이 회전 중입니다. 잠시만 기다려주세요.'.tr())),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserProfileSection(),
            const SizedBox(height: 24),
            _buildWheelOrExhaustedSection(),
          ],
        ),
      ),
    );
  }

  /// 사용자 프로필 + 포인트 섹션
  Widget _buildUserProfileSection() {
    if (_isUserLoading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userErrorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 14,
              color: color.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _userErrorMessage!,
                style:
                    text.bodySmall?.copyWith(color: color.onErrorContainer),
              ),
            ),
            IconButton(
              onPressed: _loadUserInfo,
              icon: FaIcon(
                FontAwesomeIcons.arrowsRotate,
                size: 14,
                color: color.onErrorContainer,
              ),
            ),
          ],
        ),
      );
    }

    final user = _userInfo;
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 프로필 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.12),
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
          // 이름 + 레벨
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user.level > 0)
                  Text(
                    'Lv.${user.level}',
                    style: text.bodySmall?.copyWith(
                      color: color.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          // 포인트 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.solidCoins,
                  size: 12,
                  color: color.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  '${user.point}P',
                  style: text.labelMedium?.copyWith(
                    color: color.onPrimaryContainer,
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
  Widget _buildWheelOrExhaustedSection() {
    return Selector<SettingsState, int>(
      selector: (_, state) =>
          state.settings?.availableStarbucksCoupons ?? -1,
      builder: (context, availableCoupons, _) {
        if (availableCoupons == 0) {
          return _buildExhaustedBanner();
        }
        return _buildWheelSection();
      },
    );
  }

  /// 스피닝 휠 섹션
  Widget _buildWheelSection() {
    final settings = SettingsState.of(context).settings;
    final spinCost = settings?.spinCost ?? 200;

    return Column(
      children: [
        // 스피닝 휠
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SpinningWheelWidget(
            key: _wheelKey,
            sections: _sections,
            onSpinComplete: () {},
          ),
        ),
        const SizedBox(height: 16),

        // 비용 안내
        Text(
          '참가비: ${spinCost}P'.tr(),
          style: text.bodySmall?.copyWith(
            color: color.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),

        // 스핀 버튼
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: _isSpinning ? null : _onSpin,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSpinning
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    '스핀!'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // 결과 배너
        if (_lastResult != null) _buildResultBanner(_lastResult!),

        // 면책 조항
        const SizedBox(height: 16),
        Text(
          '포인트 차감 후에는 환불이 불가합니다.'.tr(),
          style: text.bodySmall?.copyWith(
            color: color.onSurface.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// 스핀 결과 배너
  Widget _buildResultBanner(SpinResult result) {
    final Color bgColor;
    final Color fgColor;
    final String message;

    if (result.isCoupon) {
      bgColor = const Color(0xFF4CAF50);
      fgColor = Colors.white;
      message = '스타벅스 쿠폰에 당첨되었습니다!'.tr();
    } else if (result.isMiss) {
      bgColor = color.surfaceContainerHighest;
      fgColor = color.onSurface;
      message = '아쉽게도 꽝입니다. 다시 도전해보세요!'.tr();
    } else {
      bgColor = color.primaryContainer;
      fgColor = color.onPrimaryContainer;
      final points = _sectionLabels[result.sectionIndex];
      message = '$points 포인트를 획득했습니다! (현재: ${result.currentPoint}P)';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: text.bodyMedium?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// 쿠폰 소진 안내 배너
  Widget _buildExhaustedBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightMugHot,
                size: 36,
                color: color.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '현재 쿠폰이 모두 소진되었습니다.'.tr(),
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 쿠폰이 추가될 때까지 잠시만 기다려주세요.'.tr(),
            style: text.bodySmall?.copyWith(
              color: color.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => EventCouponScreen.push(context),
            icon: const FaIcon(FontAwesomeIcons.lightTicket, size: 16),
            label: Text('내 쿠폰 목록 보기'.tr()),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
