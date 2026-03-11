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
    final scheme = Theme.of(context).colorScheme;
    final activeColor = scheme.primary;

    return Column(
      children: [
        // Circles + connector lines in a single Stack layer
        SizedBox(
          height: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Connector lines drawn behind circles
              Positioned.fill(
                child: Row(
                  children: List.generate(totalSteps, (i) {
                    final leftCompleted = i > 0 && i <= currentStep;
                    final rightCompleted = i < totalSteps - 1 && i < currentStep;
                    return Expanded(
                      child: Row(
                        children: [
                          // Left half-line (skip for first step)
                          Expanded(
                            child: i == 0
                                ? const SizedBox.shrink()
                                : Container(
                                    height: 2,
                                    color: leftCompleted
                                        ? activeColor
                                        : scheme.outlineVariant,
                                  ),
                          ),
                          // Placeholder for the circle width
                          const SizedBox(width: 28),
                          // Right half-line (skip for last step)
                          Expanded(
                            child: i == totalSteps - 1
                                ? const SizedBox.shrink()
                                : Container(
                                    height: 2,
                                    color: rightCompleted
                                        ? activeColor
                                        : scheme.outlineVariant,
                                  ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              // Circles drawn on top
              Row(
                children: List.generate(totalSteps, (i) {
                  final isCompleted = i < currentStep;
                  final isActive = i == currentStep;
                  return Expanded(
                    child: Center(
                      child: _StepCircle(
                        index: i,
                        isCompleted: isCompleted,
                        isActive: isActive,
                        activeColor: activeColor,
                        scheme: scheme,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        // Labels row
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
                    fontSize: 11,
                    color: isActive ? activeColor : scheme.onSurfaceVariant,
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
  final ColorScheme scheme;

  const _StepCircle({
    required this.index,
    required this.isCompleted,
    required this.isActive,
    required this.activeColor,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color fgColor;

    if (isCompleted || isActive) {
      bgColor = activeColor;
      fgColor = Colors.white;
    } else {
      bgColor = scheme.surfaceContainerHighest;
      fgColor = scheme.onSurfaceVariant;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
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
