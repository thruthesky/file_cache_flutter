import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';

/// Company Card Widget
/// Displays a company card with full-width image (or category-based placeholder), and company name
class CompanyCard extends StatelessWidget {
  const CompanyCard({
    super.key,
    required this.name,
    required this.categoryIcon,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final IconData categoryIcon;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(sp.s16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full-width image or placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Show placeholder if image fails to load
                        return _CompanyCardPlaceholder(
                          scheme: scheme,
                          categoryIcon: categoryIcon,
                        );
                      },
                    )
                  : _CompanyCardPlaceholder(
                      scheme: scheme,
                      categoryIcon: categoryIcon,
                    ),
            ),

            // Company name section with background
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(sp.s16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(sp.s16),
                  bottomRight: Radius.circular(sp.s16),
                ),
              ),
              child: Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Build placeholder with category icon when no image is available
class _CompanyCardPlaceholder extends StatelessWidget {
  const _CompanyCardPlaceholder({
    required this.scheme,
    required this.categoryIcon,
  });

  final ColorScheme scheme;
  final IconData categoryIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: FaIcon(
          categoryIcon,
          size: 64,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
