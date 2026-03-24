import 'package:flutter/material.dart';

class ShareWhereButton extends StatelessWidget {
  const ShareWhereButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.color,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final Function() onTap;
  final String text;
  final Color color;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
