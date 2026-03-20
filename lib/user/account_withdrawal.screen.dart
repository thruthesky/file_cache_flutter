import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:url_launcher/url_launcher.dart';

/// 회원 탈퇴 화면
///
/// 5단계로 구성된 계정 삭제 안내 화면.
/// 이메일을 통해 탈퇴를 요청한다.
class AccountWithdrawalScreen extends StatefulWidget {
  static const String routeName = '/account-withdrawal';

  const AccountWithdrawalScreen({super.key});

  static void push(BuildContext context) {
    context.push(routeName);
  }

  @override
  State<AccountWithdrawalScreen> createState() =>
      _AccountWithdrawalScreenState();
}

class _AccountWithdrawalScreenState extends State<AccountWithdrawalScreen> {
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
        title: Text('회원 탈퇴'.tr()),
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
            /// 인트로 섹션
            _buildIntroSection(),
            const SizedBox(height: 32),

            /// 1단계: 삭제되는 데이터
            _SectionTitle(
              title: '1. ${'삭제되는 데이터'.tr()}',
              isAnimated: _isAnimated,
              delay: 0,
            ),
            const SizedBox(height: 16),
            _DataCategoryCard(
              icon: FontAwesomeIcons.lightCreditCard,
              title: '계정 정보'.tr(),
              description: '이메일, 이름, 프로필 사진 등 계정과 관련된 모든 개인 정보'.tr(),
              isAnimated: _isAnimated,
              index: 0,
            ),
            _DataCategoryCard(
              icon: FontAwesomeIcons.lightChartColumn,
              title: '이용 기록'.tr(),
              description: '게시글, 댓글, 채팅 기록, 포인트 등 서비스 이용 기록'.tr(),
              isAnimated: _isAnimated,
              index: 1,
            ),
            _DataCategoryCard(
              icon: FontAwesomeIcons.lightCloud,
              title: '기타 데이터'.tr(),
              description: '업소 등록 정보, 북마크, 알림 설정 등 기타 저장된 데이터'.tr(),
              isAnimated: _isAnimated,
              index: 2,
            ),
            const SizedBox(height: 8),
            _buildInfoBox(
              message: '결제 관련 데이터는 관련 법률에 따라 별도 보관될 수 있습니다.'.tr(),
              icon: FontAwesomeIcons.lightCircleInfo,
              bgColor: color.secondaryContainer.withValues(alpha: 0.3),
              delay: 600,
            ),
            const SizedBox(height: 32),

            /// 2단계: 삭제 방법
            _SectionTitle(
              title: '2. ${'삭제 방법'.tr()}',
              isAnimated: _isAnimated,
              delay: 100,
            ),
            const SizedBox(height: 16),
            _buildIconCard(
              icon: FontAwesomeIcons.lightEnvelope,
              content: '이메일로 탈퇴를 요청합니다.'.tr(),
              delay: 700,
            ),
            const SizedBox(height: 32),

            /// 3단계: 처리 기간
            _SectionTitle(
              title: '3. ${'처리 기간'.tr()}',
              isAnimated: _isAnimated,
              delay: 200,
            ),
            const SizedBox(height: 16),
            _buildTextCard(
              content: '탈퇴 요청 후 영업일 기준 7일 이내에 처리됩니다. 처리 완료 시 등록된 이메일로 안내드립니다.'
                  .tr(),
              delay: 800,
            ),
            const SizedBox(height: 8),
            _buildInfoBox(
              message: '탈퇴 처리가 완료되면 되돌릴 수 없습니다. 신중하게 결정해 주세요.'.tr(),
              icon: FontAwesomeIcons.lightTriangleExclamation,
              bgColor: color.errorContainer.withValues(alpha: 0.3),
              delay: 900,
            ),
            const SizedBox(height: 32),

            /// 4단계: 데이터 보관 예외
            _SectionTitle(
              title: '4. ${'데이터 보관 예외'.tr()}',
              isAnimated: _isAnimated,
              delay: 300,
            ),
            const SizedBox(height: 16),
            _buildRetentionCard(
              content:
                  '관련 법률에 따라 일부 데이터는 일정 기간 보관될 수 있습니다. (전자상거래법, 통신비밀보호법 등)'
                      .tr(),
              delay: 1000,
            ),
            const SizedBox(height: 32),

            /// 5단계: 문의
            _SectionTitle(
              title: '5. ${'문의'.tr()}',
              isAnimated: _isAnimated,
              delay: 400,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              content: '탈퇴 관련 문의는 philgohelp@gmail.com 으로 연락해 주세요.'.tr(),
              delay: 1100,
            ),
            const SizedBox(height: 32),

            /// 탈퇴 요청 버튼
            _buildWithdrawalButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 인트로 섹션
  Widget _buildIntroSection() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.lightUserXmark,
                      size: 24,
                      color: color.error,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '회원 탈퇴 안내'.tr(),
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '탈퇴 전 아래 내용을 꼭 확인해 주세요.'.tr(),
                        style: text.bodyMedium?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )
        .animate(target: _isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.1, end: 0);
  }

  /// 정보 박스 (배경색 + 아이콘 + 텍스트)
  Widget _buildInfoBox({
    required String message,
    required IconData icon,
    required Color bgColor,
    required int delay,
  }) {
    return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(icon, size: 16, color: color.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: text.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(target: _isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .slideX(begin: 0.1, end: 0);
  }

  /// 아이콘 + 텍스트 카드
  Widget _buildIconCard({
    required IconData icon,
    required String content,
    required int delay,
  }) {
    return _buildCard(
      delay: delay,
      child: Row(
        children: [
          _buildIconContainer(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              content,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// 텍스트 전용 카드
  Widget _buildTextCard({required String content, required int delay}) {
    return _buildCard(
      delay: delay,
      child: Text(content, style: text.bodyMedium),
    );
  }

  /// 데이터 보관 카드 (쉴드 아이콘)
  Widget _buildRetentionCard({required String content, required int delay}) {
    return _buildCard(
      delay: delay,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconContainer(
            icon: FontAwesomeIcons.lightShieldCheck,
            backgroundColor: color.tertiaryContainer,
            iconColor: color.tertiary,
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(content, style: text.bodyMedium)),
        ],
      ),
    );
  }

  /// 문의 카드 (물음표 아이콘)
  Widget _buildContactCard({required String content, required int delay}) {
    return _buildCard(
      delay: delay,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconContainer(icon: FontAwesomeIcons.lightCircleQuestion),
          const SizedBox(width: 16),
          Expanded(child: Text(content, style: text.bodyMedium)),
        ],
      ),
    );
  }

  /// 공통 카드 컨테이너
  Widget _buildCard({required Widget child, required int delay}) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        )
        .animate(target: _isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .slideX(begin: -0.1, end: 0);
  }

  /// 공통 아이콘 컨테이너
  Widget _buildIconContainer({
    required IconData icon,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor ?? color.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FaIcon(
          icon,
          size: 22,
          color: iconColor ?? color.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 탈퇴 요청 버튼
  Widget _buildWithdrawalButton() {
    return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _sendWithdrawalEmail(),
            icon: const FaIcon(FontAwesomeIcons.lightEnvelope, size: 18),
            label: Text('탈퇴 요청하기'.tr()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        )
        .animate(target: _isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: 1200.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Future<void> _sendWithdrawalEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'philgohelp@gmail.com',
      query:
          'subject=${Uri.encodeComponent('Account Withdrawal Request')}&body=${Uri.encodeComponent('I would like to request account withdrawal.\n\nPlease delete all my personal data.\n\nThank you.')}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이메일 앱을 열 수 없습니다.'.tr())));
      }
    }
  }
}

/// 섹션 타이틀
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isAnimated;
  final int delay;

  const _SectionTitle({
    required this.title,
    required this.isAnimated,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
          title,
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color.primary,
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .slideY(begin: -0.1, end: 0);
  }
}

/// 데이터 카테고리 카드
class _DataCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isAnimated;
  final int index;

  const _DataCategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isAnimated,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: 22,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: text.bodyMedium?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: (300 + index * 100).ms)
        .slideX(begin: -0.1, end: 0);
  }
}
