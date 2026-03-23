import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/view/company.view.screen.dart';
import 'package:philgo/globals.dart';

/// 후기 작성 포인트 결과 화면
///
/// QR 삼단콤보 마지막 단계.
/// submitVisitReview API 결과로 받은 보상 포인트를 표시한다.
class CompanyReviewPointResultScreen extends StatelessWidget {
  static const String routeName = '/company/review-point-result';

  final int rewardPoints;
  final int pointBefore;
  final int pointAfter;
  final int idxCompany;

  const CompanyReviewPointResultScreen({
    super.key,
    required this.rewardPoints,
    required this.pointBefore,
    required this.pointAfter,
    required this.idxCompany,
  });

  static Future<dynamic> push(
    BuildContext context, {
    required int rewardPoints,
    required int pointBefore,
    required int pointAfter,
    required int idxCompany,
  }) =>
      context.push(routeName, extra: {
        'rewardPoints': rewardPoints,
        'pointBefore': pointBefore,
        'pointAfter': pointAfter,
        'idxCompany': idxCompany,
      });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        // "Review Point Result"
        title: Text('후기 포인트 결과'.tr()),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: FaIcon(FontAwesomeIcons.lightStar, size: 40,
                            color: color.primary),
                      ),
                    ).animate().scale(
                          duration: 500.ms,
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.elasticOut,
                        ),
                    const SizedBox(height: 24),
                    Text(
                      '후기 보상 ${formatter.format(rewardPoints)}P 적립!',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color.primary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${formatter.format(pointBefore)}P → ${formatter.format(pointAfter)}P',
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  context.go('/');
                  CompanyViewScreen.push(
                    context,
                    company: CompanyModel.minimal(idx: idxCompany),
                  );
                },
                icon: const FaIcon(FontAwesomeIcons.lightBuilding, size: 18),
                // "View Business Info"
                label: Text('업소 정보 보기'.tr()),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }
}
