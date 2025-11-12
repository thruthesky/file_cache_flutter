import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/widgets/company/company.image.placeholder.dart';

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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(sp.s12),
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
              padding: EdgeInsets.all(sp.s12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(sp.s12),
                  bottomRight: Radius.circular(sp.s12),
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
