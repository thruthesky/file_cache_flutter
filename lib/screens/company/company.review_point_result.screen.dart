import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.view.screen.dart';

/// 후기 작성 포인트 결과 화면
///
/// QR 삼단콤보 중 마지막 단계.
/// submitVisitReview API 결과로 받은 보상 포인트를 표시하고
/// "업소 정보 보기" 버튼으로 CompanyViewScreen으로 이동.
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

  /// 화면 이동 헬퍼
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
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: Text(T.reviewPointResult),
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
                    /// 별 아이콘
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.lightStar,
                          size: 40,
                          color: scheme.primary,
                        ),
                      ),
                    ).animate().scale(
                          duration: 500.ms,
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 24),

                    /// 보상 포인트 텍스트
                    Text(
                      T.reviewBonusEarned(formatter.format(rewardPoints)),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                    const SizedBox(height: 32),

                    /// 포인트 변동 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        T.pointChange(
                          formatter.format(pointBefore),
                          formatter.format(pointAfter),
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                  ],
                ),
              ),
            ),
          ),

          /// 하단: "업소 정보 보기" 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  /// 홈 화면만 남기고 nav stack 초기화 후 업소 보기 push
                  context.go('/');
                  context.push(CompanyViewScreen.routeName, extra: idxCompany);
                },
                icon:
                    const FaIcon(FontAwesomeIcons.lightBuilding, size: 18),
                label: Text(T.viewCompanyInfo),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }
}
