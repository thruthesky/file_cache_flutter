import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/review/company.visit_review.screen.dart';
import 'package:philgo/globals.dart';

/// 재방문 포인트 결과 화면
///
/// QR 삼단콤보 중 [2단계] 재방문 보너스.
/// 화면 진입 시 자동으로 company.reVisitPoint API 호출하여 2~3천P 적립.
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

  int _rewardPoints = 0;
  int _pointBefore = 0;
  int _pointAfter = 0;

  @override
  void initState() {
    super.initState();
    _claimRevisitPoint();
  }

  Future<void> _claimRevisitPoint() async {
    final result = await CompanyService.reVisitPoint(widget.usageIdx);
    if (!mounted) return;
    setState(() {
      _rewardPoints = (result['reward_points'] as num?)?.toInt() ?? 0;
      _pointBefore = (result['point_before'] as num?)?.toInt() ?? 0;
      _pointAfter = (result['point_after'] as num?)?.toInt() ?? 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        // "Revisit Point Result"
        title: Text('재방문 포인트 결과'.tr()),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _isLoading
                    ? _buildLoading()
                    : _errorMessage != null
                        ? _buildError()
                        : _buildSuccess(formatter),
              ),
            ),
          ),
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
                  // "Earn Points by Writing a Review"
                  label: Text('후기 작성으로 포인트 받기'.tr()),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(color.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          // "Drawing points..."
          '포인트 추첨 중...'.tr(),
          style: text.titleMedium?.copyWith(color: color.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(FontAwesomeIcons.lightCircleExclamation, size: 48,
            color: color.error),
        const SizedBox(height: 16),
        Text(
          _errorMessage!,
          style: text.bodyMedium?.copyWith(color: color.error),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            _claimRevisitPoint();
          },
          icon: const FaIcon(FontAwesomeIcons.lightArrowsRotate, size: 16),
          // "Try Again"
          label: Text('다시 시도'.tr()),
        ),
      ],
    );
  }

  Widget _buildSuccess(NumberFormat formatter) {
    return Column(
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
            child: FaIcon(FontAwesomeIcons.lightPartyHorn, size: 40,
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
          '재방문 보너스 ${formatter.format(_rewardPoints)}P 적립!',
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
            '${formatter.format(_pointBefore)}P → ${formatter.format(_pointAfter)}P',
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
      ],
    );
  }
}
