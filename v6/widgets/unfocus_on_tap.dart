import 'package:flutter/material.dart';

class UnfocusOnTap extends StatelessWidget {
  final Widget child;
  const UnfocusOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping on message list area
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      // Allow scrolling and other interactions
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
