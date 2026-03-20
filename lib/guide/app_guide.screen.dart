import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';

/// 앱 사용 안내 화면
class AppGuideScreen extends StatefulWidget {
  static const String routeName = '/app-guide';

  const AppGuideScreen({super.key});

  static void push(BuildContext context) {
    context.push(routeName);
  }

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isAnimated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('앱 사용 안내'.tr()),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: color.outlineVariant),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 환영 메시지
            _buildWelcomeSection(),
            const SizedBox(height: 32),

            /// 시작하기 섹션
            _buildGettingStartedSection(),
            const SizedBox(height: 32),

            /// 주요 기능 섹션
            _buildFeaturesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 환영 메시지 섹션
  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.primary.withValues(alpha: 0.08),
            color.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          /// 로고
          Image.asset(
            'assets/img/logo/philgo_wide_logo_icon.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 16),

          /// 환영 타이틀
          Text(
            '필고에 오신 것을 환영합니다!'.tr(),
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          /// 환영 설명
          Text(
            '필리핀 생활의 모든 것을 필고에서 만나보세요. 커뮤니티, 채팅, 업소록 등 다양한 기능을 제공합니다.'.tr(),
            style: text.bodyMedium?.copyWith(
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate(target: _isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0);
  }

  /// 시작하기 섹션
  Widget _buildGettingStartedSection() {
    final steps = [
      _GuideStepData(
        icon: FontAwesomeIcons.lightCompass,
        title: '둘러보기'.tr(),
        description: '게시판, 업소록, 채팅 등 다양한 메뉴를 탐색해 보세요.'.tr(),
      ),
      _GuideStepData(
        icon: FontAwesomeIcons.lightPenToSquare,
        title: '글쓰기'.tr(),
        description: '자유게시판, 묻고 답하기 등에서 자유롭게 글을 작성하세요.'.tr(),
      ),
      _GuideStepData(
        icon: FontAwesomeIcons.lightUsers,
        title: '소통하기'.tr(),
        description: '오픈 채팅방에서 다른 회원들과 실시간으로 소통하세요.'.tr(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: FontAwesomeIcons.lightRocket,
          title: '시작하기'.tr(),
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return _buildStepCard(
            step: step,
            stepNumber: index + 1,
            delay: (200 + index * 100).ms,
          );
        }),
      ],
    );
  }

  /// 주요 기능 섹션
  Widget _buildFeaturesSection() {
    final features = [
      _GuideStepData(
        icon: FontAwesomeIcons.lightComments,
        title: '커뮤니티'.tr(),
        description: '자유게시판, 묻고 답하기, 블로그 등 다양한 게시판에서 정보를 공유하세요.'.tr(),
      ),
      _GuideStepData(
        icon: FontAwesomeIcons.lightMessage,
        title: '채팅'.tr(),
        description: '오픈 채팅방에 참여하거나 1:1 채팅으로 대화하세요.'.tr(),
      ),
      _GuideStepData(
        icon: FontAwesomeIcons.lightStore,
        title: '업소록'.tr(),
        description: '필리핀 현지 업소 정보를 검색하고 나의 업소를 등록하세요.'.tr(),
      ),
      _GuideStepData(
        icon: FontAwesomeIcons.lightCartShopping,
        title: '회원장터'.tr(),
        description: '사고팔기, 구인구직 게시판에서 거래하세요.'.tr(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: FontAwesomeIcons.lightStar,
          title: '주요 기능'.tr(),
        ),
        const SizedBox(height: 16),
        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return _buildFeatureCard(
            feature: feature,
            delay: (400 + index * 100).ms,
          );
        }),
      ],
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        FaIcon(icon, size: 18, color: color.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color.primary,
          ),
        ),
      ],
    );
  }

  /// 시작하기 스텝 카드
  Widget _buildStepCard({
    required _GuideStepData step,
    required int stepNumber,
    required Duration delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          /// 스텝 번호 뱃지
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: text.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(target: _isAnimated ? 1 : 0)
        .fadeIn(duration: 500.ms, delay: delay)
        .slideX(begin: -0.1, end: 0);
  }

  /// 주요 기능 카드
  Widget _buildFeatureCard({
    required _GuideStepData feature,
    required Duration delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          /// 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                feature.icon,
                size: 22,
                color: color.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: text.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(target: _isAnimated ? 1 : 0)
        .fadeIn(duration: 500.ms, delay: delay)
        .slideX(begin: -0.1, end: 0);
  }
}

/// 가이드 스텝 데이터
class _GuideStepData {
  final IconData icon;
  final String title;
  final String description;

  const _GuideStepData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
