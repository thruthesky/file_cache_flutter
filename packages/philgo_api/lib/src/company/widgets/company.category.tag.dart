import 'package:flutter/material.dart';

/// Company category tag widget
///
/// Displays the company category as a styled tag chip.
/// Accepts an optional [displayName] for localized category names.
/// Falls back to the raw [category] id if [displayName] is not provided.
class CompanyCategoryTag extends StatelessWidget {
  final String category;

  /// Optional localized display name for the category.
  /// If not provided, falls back to a default English mapping.
  final String? displayName;

  const CompanyCategoryTag({
    super.key,
    required this.category,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        /// Flat Design: primaryContainer background for color contrast
        /// No border (Flat Design rule: distinguish by color only)
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayName ?? _getCategoryDisplayName(category),
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }

  /// Fallback English category name mapping
  /// Used only when [displayName] is not provided
  String _getCategoryDisplayName(String category) {
    final categoryMap = {
      'public-office': 'Public Office',
      'education': 'Education',
      'food': 'Food',
      'transport': 'Transport',
      'hospital': 'Hospital',
      'mart': 'Mart',
      'bank': 'Bank',
      'gadget': 'Gadget',
      'travel-agency': 'Travel Agency',
      'hotel': 'Hotel',
      'rentcar': 'Rent Car',
      'beauty': 'Beauty',
      'real-estate': 'Real Estate',
      'ktv': 'KTV',
      'spa': 'Spa',
      'etc': 'ETC',
    };

    return categoryMap[category.toLowerCase()] ?? category;
  }
}
