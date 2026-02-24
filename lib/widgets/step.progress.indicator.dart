import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 스텝 프로그레스 인디케이터
///
/// 멀티스텝 폼에서 현재 진행 상황을 시각적으로 보여줍니다.
/// 각 스텝은 번호 원, 라벨, 연결선으로 구성됩니다.
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabels,
  });

  final int totalSteps;
  final int currentStep;

  /// 각 스텝의 라벨 텍스트
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        /// 홀수 인덱스: 스텝 간 연결선
        if (index.isOdd) {
          final prevStep = index ~/ 2;
          final isCompleted = prevStep < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 18),
              color: isCompleted
                  ? scheme.primary
                  : scheme.surfaceContainerHighest,
            ),
          );
        }

        /// 짝수 인덱스: 스텝 원 + 라벨
        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        final isActive = isCompleted || isCurrent;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 스텝 원 (완료: 체크 아이콘, 현재/미래: 번호)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isCurrent ? 32 : 28,
              height: isCurrent ? 32 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
              ),
              child: Center(
                child: isCompleted
                    ? FaIcon(
                        FontAwesomeIcons.check,
                        size: 12,
                        color: scheme.onPrimary,
                      )
                    : Text(
                        '${stepIndex + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isCurrent
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),

            /// 스텝 라벨
            Text(
              stepIndex < stepLabels.length ? stepLabels[stepIndex] : '',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }
}
