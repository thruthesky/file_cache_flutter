import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'company.image.placeholder.dart';

/// Company Card Widget
/// Displays a company card with full-width image (or category-based placeholder),
/// category badge overlay, and company name
class CompanyCard extends StatelessWidget {
  const CompanyCard({
    super.key,
    required this.name,
    required this.categoryName,
    required this.categoryIcon,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final String categoryName;
  final IconData categoryIcon;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Comic design: Card with border and no elevation
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        // Comic design: Border radius 12 for large elements
        borderRadius: BorderRadius.circular(12),
        // Comic design: 2.0px border with outline color
        border: Border.all(color: scheme.outline, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // Comic design: Border radius 12 for large elements
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Full-width image with category badge overlay
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  // Comic design: Border radius 10.5 to account for 1.5px border
                  top: Radius.circular(10.5),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      /// Cached network image or placeholder
                      imageUrl != null && imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                // Comic design: Simple loading color instead of gradient
                                return Container(
                                  color: scheme.surfaceContainerHighest,
                                );
                              },
                              errorWidget: (context, url, error) {
                                /// Show placeholder if image fails to load
                                return CompanyImagePlaceholder(
                                  icon: categoryIcon,
                                );
                              },
                            )
                          : CompanyImagePlaceholder(icon: categoryIcon),

                      /// Category badge overlay (top-right)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            // Comic design: Border radius 8 for small elements
                            borderRadius: BorderRadius.circular(8),
                            // Comic design: 2.0px border
                            border: Border.all(
                              color: scheme.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            categoryName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Company name section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
