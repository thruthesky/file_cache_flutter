import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/event/qr_scanner.screen.dart';
import 'package:philgo/globals.dart';

/// 업소이벤트 안내 화면
///
/// QR 코드 스캔을 통한 포인트 적립 이벤트를 안내한다.
/// 3단계로 이벤트 참여 방법을 설명하고, QR 스캔 버튼을 제공한다.
class CompanyEventScreen extends StatelessWidget {
  static const String routeName = '/company-event';
  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const CompanyEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('업소이벤트'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 안내 문구
            _buildInfoBanner(),
            const SizedBox(height: 24),

            // 헤더 섹션
            _buildHeaderSection(),
            const SizedBox(height: 24),

            // 3단계 안내
            _buildStepsSection(),
            const SizedBox(height: 32),

            // QR 스캔 버튼
            _buildScanButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 안내 문구 배너
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightCircleInfo,
            size: 20,
            color: color.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '제휴 업소에서 QR 코드를 요청하고 스캔하여 포인트를 적립하세요!'.tr(),
              style: text.bodyMedium?.copyWith(
                color: color.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 헤더 섹션 (제목 + 부제)
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.lightStar,
            size: 48,
            color: color.onPrimaryContainer,
          ),
          const SizedBox(height: 16),
          Text(
            '삼단콤보 이벤트'.tr(),
            style: text.headlineSmall?.copyWith(
              color: color.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'QR 스캔 → 포인트 획득 → 포인트 응모'.tr(),
            style: text.bodyMedium?.copyWith(
              color: color.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 3단계 안내
  Widget _buildStepsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildCompactStep(
            icon: FontAwesomeIcons.lightQrcode,
            title: 'Step 1. QR 코드 스캔'.tr(),
            description: '제휴 업소에서 QR 코드를 스캔하세요.'.tr(),
          ),
          const Divider(height: 24),
          _buildCompactStep(
            icon: FontAwesomeIcons.lightRotate,
            title: 'Step 2. 포인트 획득'.tr(),
            description: 'QR 스캔 시 1,000~2,000 포인트를 바로 획득합니다.'.tr(),
          ),
          const Divider(height: 24),
          _buildCompactStep(
            icon: FontAwesomeIcons.lightPenToSquare,
            title: 'Step 3. 포인트 응모'.tr(),
            description: '획득한 포인트로 스피닝 휠에 응모하여 쿠폰을 받으세요!'.tr(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildCompactStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(icon, size: 18, color: color.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: text.bodySmall?.copyWith(
                  color: color.onSurface.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// QR 스캔 버튼 (펄스 애니메이션)
  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: () => QrScannerScreen.push(context),
        icon: const FaIcon(FontAwesomeIcons.lightQrcode, size: 28),
        label: Text(
          'QR 코드 스캔하기'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.02, duration: 1200.ms)
        .shimmer(duration: 1500.ms);
  }
}
