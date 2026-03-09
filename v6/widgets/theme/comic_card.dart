import 'package:flutter/material.dart';

/// Comic-styled Card widget following the Comic design principles
///
/// Features:
/// - 2.0px border with outline color
/// - Zero elevation (no shadow)
/// - Rounded corners (borderRadius: 12)
/// - Theme-based colors
class ComicCard extends StatelessWidget {
  const ComicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      child: Card(
        elevation: 0, // Comic Design: no shadow
        margin: EdgeInsets.zero,
        color: scheme.surface,
        // Comic Design: 2.0 border with rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: scheme.outline,
            width: 2.0,
          ),
        ),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
      ),
    );
  }
}

/// Comic-styled List Card widget for list items (thinner border)
///
/// Features:
/// - 1.5px border with outline color (thinner for compact lists)
/// - Zero elevation (no shadow)
/// - Rounded corners (borderRadius: 12)
/// - Theme-based colors
class ComicListCard extends StatelessWidget {
  const ComicListCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      child: Card(
        elevation: 0, // Comic Design: no shadow
        margin: EdgeInsets.zero,
        color: scheme.surface,
        // Comic Design: 1.5 border with rounded corners for list items
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: scheme.outline,
            width: 1.5,
          ),
        ),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
      ),
    );
  }
}
