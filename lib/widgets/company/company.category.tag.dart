import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';

class CompanyCategoryTag extends StatelessWidget {
  final String category;

  const CompanyCategoryTag({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
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
