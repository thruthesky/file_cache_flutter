import 'package:flutter/material.dart';

class CompanyCategoryTag extends StatelessWidget {
  final String category;

  const CompanyCategoryTag({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        // Comic design: Border radius 8 for small elements
        borderRadius: BorderRadius.circular(8),
        // Comic design: 2.0px border with primary color
        border: Border.all(color: scheme.primary, width: 1.5),
      ),
      child: Text(
        _getCategoryDisplayName(category),
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }

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
