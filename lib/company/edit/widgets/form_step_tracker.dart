import 'package:flutter/material.dart';

/// 멀티 스텝 폼의 진행 상태를 표시하는 위젯
///
/// [currentStep] 현재 활성 스텝 (0-indexed)
/// [totalSteps] 전체 스텝 수
/// [labels] 각 스텝의 라벨 목록 (optional)
class FormStepTracker extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? labels;

  const FormStepTracker({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const activeColor = Color(0xFFFF6D00);

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (i) {
            if (i.isOdd) {
              // connector line
              final stepIndex = i ~/ 2;
              final isCompleted = stepIndex < currentStep;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isCompleted ? activeColor : colorScheme.outlineVariant,
                ),
              );
            }
            final stepIndex = i ~/ 2;
            final isCompleted = stepIndex < currentStep;
            final isActive = stepIndex == currentStep;

            return _StepCircle(
              index: stepIndex,
              isCompleted: isCompleted,
              isActive: isActive,
              activeColor: activeColor,
              colorScheme: colorScheme,
            );
          }),
        ),
        if (labels != null && labels!.length == totalSteps) ...[
          const SizedBox(height: 6),
          Row(
            children: List.generate(totalSteps, (i) {
              final isActive = i == currentStep;
              return Expanded(
                child: Text(
                  labels![i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? activeColor : colorScheme.onSurfaceVariant,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isCompleted;
  final bool isActive;
  final Color activeColor;
  final ColorScheme colorScheme;

  const _StepCircle({
    required this.index,
    required this.isCompleted,
    required this.isActive,
    required this.activeColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;

    if (isCompleted) {
      bgColor = activeColor;
      fgColor = Colors.white;
    } else if (isActive) {
      bgColor = activeColor;
      fgColor = Colors.white;
    } else {
      bgColor = colorScheme.surfaceContainerHighest;
      fgColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: activeColor, width: 2)
            : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, size: 14, color: fgColor)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
      ),
    );
  }
}
