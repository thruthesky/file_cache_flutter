import 'package:flutter/material.dart';

/// A customizable loading placeholder widget.
///
/// `LoadingBox` displays a rectangular area with a circular progress
/// indicator centered inside. It can be used as a temporary placeholder
/// for loading content such as images, cards, or data blocks.
///
/// ### Parameters:
/// - [width] → The width of the box. Defaults to `120`.
/// - [height] → The height of the box. Defaults to `120`.
/// - [borderRadius] → The roundness of the box corners. Defaults to `8`.
/// - [color] → The background color of the box.
///   If not provided, it uses the theme’s `surfaceContainerHighest`.
/// - [indicatorColor] → The color of the loading indicator.
///   If not provided, it uses the theme’s primary color.
///
/// ### Example:
/// ```dart
/// LoadingBox(
///   width: 100,
///   height: 100,
///   borderRadius: 12,
///   color: Colors.grey.shade300,
///   indicatorColor: Colors.blue,
/// )
/// ```
class LoadingBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;
  final Color? indicatorColor;

  const LoadingBox({
    super.key,
    this.width = 120,
    this.height = 120,
    this.borderRadius = 8,
    this.color,
    this.indicatorColor,
  });
  @override
  State<LoadingBox> createState() => _LoadingBoxState();
}

class _LoadingBoxState extends State<LoadingBox> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        width: widget.width,
        height: widget.height,
        color: widget.color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: widget.indicatorColor ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
