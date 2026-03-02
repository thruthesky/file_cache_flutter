import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.visit_review.screen.dart';
import 'package:philgo/v7_api/company_api.dart';

/// 재방문 포인트 결과 화면
///
/// QR 삼단콤보 중 [2단계] 재방문 보너스.
/// 화면 진입 시 자동으로 company.reVisitPoint API 호출하여 2~3천P 적립.
/// 하단에 "후기 작성 → 3천 포인트 랜덤" 버튼으로 후기 작성 화면 이동.
class CompanyRevisitPointResultScreen extends StatefulWidget {
  static const String routeName = '/company/revisit-point-result';

  final int usageIdx;
  final int idxCompany;
  final String companyName;

  const CompanyRevisitPointResultScreen({
    super.key,
    required this.usageIdx,
    required this.idxCompany,
    required this.companyName,
  });

  /// 화면 이동 헬퍼
  static Future<dynamic> push(
    BuildContext context, {
    required int usageIdx,
    required int idxCompany,
    required String companyName,
  }) =>
      context.push(routeName, extra: {
        'usageIdx': usageIdx,
        'idxCompany': idxCompany,
        'companyName': companyName,
      });

  @override
  State<CompanyRevisitPointResultScreen> createState() =>
      _CompanyRevisitPointResultScreenState();
}

class _CompanyRevisitPointResultScreenState
    extends State<CompanyRevisitPointResultScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  /// API 결과값
  int _rewardPoints = 0;
  int _pointBefore = 0;
  int _pointAfter = 0;

  @override
  void initState() {
    super.initState();
    _claimRevisitPoint();
  }

  /// 재방문 포인트 추첨 API 호출
  Future<void> _claimRevisitPoint() async {
    try {
      final result = await CompanyApi.reVisitPoint(widget.usageIdx);
      if (!mounted) return;
      setState(() {
        _rewardPoints = (result['reward_points'] as num?)?.toInt() ?? 0;
        _pointBefore = (result['point_before'] as num?)?.toInt() ?? 0;
        _pointAfter = (result['point_after'] as num?)?.toInt() ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: Text(T.revisitPointResult),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _isLoading
                    ? _buildLoading(scheme, theme)
                    : _errorMessage != null
                        ? _buildError(scheme, theme)
                        : _buildSuccess(scheme, theme, formatter),
              ),
            ),
          ),

          /// 하단: "후기 작성 → 3천 포인트 랜덤" 버튼
          if (!_isLoading && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    CompanyVisitReviewScreen.push(
                      context,
                      usageIdx: widget.usageIdx,
                      idxCompany: widget.idxCompany,
                      companyName: widget.companyName,
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.lightPenToSquare,
                      size: 18),
                  label: Text(T.writeReviewForPoints),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }

  /// 로딩 상태 UI
  Widget _buildLoading(ColorScheme scheme, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          T.pointDrawing,
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 에러 상태 UI
  Widget _buildError(ColorScheme scheme, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          FontAwesomeIcons.lightCircleExclamation,
          size: 48,
          color: scheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          _errorMessage!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        /// 재시도 버튼
        FilledButton.icon(
          onPressed: () {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            _claimRevisitPoint();
          },
          icon: const FaIcon(FontAwesomeIcons.lightArrowsRotate, size: 16),
          label: Text(T.retry),
        ),
      ],
    );
  }

  /// 성공 상태 UI
  Widget _buildSuccess(
      ColorScheme scheme, ThemeData theme, NumberFormat formatter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 파티 아이콘
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.lightPartyHorn,
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
          T.revisitBonusEarned(formatter.format(_rewardPoints)),
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
              formatter.format(_pointBefore),
              formatter.format(_pointAfter),
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
      ],
    );
  }
}
