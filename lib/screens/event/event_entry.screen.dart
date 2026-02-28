import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
import 'package:philgo/v7_api/user_api.dart';
import 'package:philgo/widgets/spinning_wheel.dart';

/// 이벤트 응모 화면 (Event Entry Screen)
///
/// 스피닝 휠 형태의 원판 돌리기 랜덤 뽑기 게임.
/// 서버에서 미리 결과를 결정하고, 클라이언트는 해당 결과에 맞춰 원판을 돌림.
/// 현재는 서버 연동 전이므로 상단에 테스트용 결과 선택 UI 제공.
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
  /// 테스트용: 미리 선택된 당첨 섹션 인덱스 (null이면 랜덤)
  int? _testTargetIndex;

  /// 원판 섹션 목록 (build에서 l10n 필요하므로 late 초기화)
  late List<WheelSection> _sections;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = Lo.of(context)!;

    /// 원판 섹션 정의 (6개 섹션)
    /// 꽝: 30%, 50: 30%, 500: 20%, 1000: 10%, 2000: 5%, 스타벅스 쿠폰: 5%
    _sections = [
      WheelSection(label: '50', color: const Color(0xFFE88B8B), points: 50, weight: 30),
      WheelSection(label: '500', color: const Color(0xFFF5B971), points: 500, weight: 20),
      WheelSection(
        label: '1,000',
        color: const Color(0xFFC9A9C9),
        points: 1000,
        weight: 10,
        icon: FontAwesomeIcons.solidStar,
      ),
      WheelSection(
        label: '2,000',
        color: const Color(0xFF9CC2D8),
        points: 2000,
        weight: 5,
        icon: FontAwesomeIcons.solidStar,
        iconCount: 2,
      ),
      WheelSection(
        label: l10n.spinWheelCoupon,
        color: const Color(0xFF8BC78B),
        points: -1,
        weight: 5,
        icon: FontAwesomeIcons.lightMugHot,
      ),
      WheelSection(
        label: l10n.spinWheelMiss,
        color: const Color(0xFFB0B0B0),
        points: 0,
        weight: 30,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickMenuEventEntry),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            /// 사용자 프로필 + 포인트 정보
            _buildUserProfileSection(theme, scheme),
            const SizedBox(height: 16),

            /// 테스트용 결과 선택 UI
            _buildTestSelector(theme, scheme, l10n),
            const SizedBox(height: 16),

            /// 스피닝 휠
            SpinningWheel(
              sections: _sections,
              instructionText: l10n.spinWheelInstruction,
              spinButtonText: l10n.spinWheelSpin,
              onSpinRequested: () async => _resolveTargetIndex(),
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
            ),
          ],
        ),
      ),
    );
  }

  /// 타겟 인덱스 반환.
  /// 테스트 선택값이 있으면 그 값, 없으면 랜덤.
  /// 추후 서버 API 호출로 교체.
  int _resolveTargetIndex() {
    if (_testTargetIndex != null) return _testTargetIndex!;
    return DateTime.now().microsecond % _sections.length;
  }

  /// 테스트용: 상단 결과 선택 드롭다운
  Widget _buildTestSelector(
    ThemeData theme,
    ColorScheme scheme,
    Lo l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.science_outlined, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _testTargetIndex,
                isExpanded: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onTertiaryContainer,
                ),
                dropdownColor: scheme.tertiaryContainer,
                hint: Text(
                  'TEST: Random',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                items: [
                  /// 랜덤 옵션
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Random',
                      style: TextStyle(color: scheme.onTertiaryContainer),
                    ),
                  ),
                  /// 각 섹션 옵션
                  ...List.generate(_sections.length, (i) {
                    final section = _sections[i];
                    return DropdownMenuItem<int?>(
                      value: i,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: section.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            section.label,
                            style: TextStyle(color: scheme.onTertiaryContainer),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (value) => setState(() => _testTargetIndex = value),
              ),
            ),
          ),
        ],
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
        message,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor,
          fontWeight: isMiss ? FontWeight.normal : FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
