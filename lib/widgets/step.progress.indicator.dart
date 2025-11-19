import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final double spacing;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.height = 6,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // spacing between segments
          return SizedBox(width: spacing);
        } else {
          final segmentIndex = index ~/ 2;
          return Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: segmentIndex <= currentStep
                    ? activeColor
                    : inactiveColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          );
        }
      }),
    );
  }
}
