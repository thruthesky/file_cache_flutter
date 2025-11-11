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
          borderRadius: BorderRadius.circular(16),
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
                        return _buildPlaceholder(scheme);
                      },
                    )
                  : _buildPlaceholder(scheme),
            ),

            // Company name section
            Padding(
              padding: EdgeInsets.all(sp.s16),
              child: Row(
                children: [
                  // Category icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: FaIcon(
                        categoryIcon,
                        size: 20,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s12),

                  // Company name
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder with category icon when no image is available
  Widget _buildPlaceholder(ColorScheme scheme) {
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
