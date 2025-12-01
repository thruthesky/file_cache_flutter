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

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        // Modern elevation with subtle shadow
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Full-width image with category badge overlay
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
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
                                /// Shimmer loading effect
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        scheme.surfaceContainerHighest,
                                        scheme.surfaceContainer,
                                        scheme.surfaceContainerHighest,
                                      ],
                                    ),
                                  ),
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

                      /// Category badge overlay (top-right) with vibrant colors
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.shadow.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            categoryName,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onTertiaryContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.3,
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
                padding: const EdgeInsets.all(16),
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    letterSpacing: -0.2,
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
