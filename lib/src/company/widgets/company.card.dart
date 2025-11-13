import 'package:flutter/material.dart';
import 'company.image.placeholder.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: onTap,
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
                        return CompanyImagePlaceholder(icon: categoryIcon);
                      },
                    )
                  : CompanyImagePlaceholder(icon: categoryIcon),
            ),

            // Company name section with background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
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
