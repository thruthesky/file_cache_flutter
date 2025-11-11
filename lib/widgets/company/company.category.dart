import 'package:easy_phone_sign_in/easy_phone_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/widgets/company/company.card.dart';
import 'package:philgo/widgets/company/company.category.empty.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Category Card Widget
/// Displays a single company category with icon, name, count, and view more button
class CompanyCategory extends StatelessWidget {
  const CompanyCategory({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
  });

  final String name;
  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: sp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header with bottom border
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 1),
              ),
            ),
            padding: EdgeInsets.only(bottom: sp.s16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(icon, size: 24, color: scheme.onSurface),
                  ),
                ),
                SizedBox(width: sp.s16),
                // Category name and count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Total number of ${count.toString()}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s16),
          if (count <= 0)
            const Center(child: CompanyCategoryEmpty())
          else
            // Horizontal scrollable list of company cards
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: sp.s16),
                itemCount: count,
                separatorBuilder: (context, index) => SizedBox(width: sp.s16),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 280,
                    child: CompanyCard(
                      name: 'Company ${index + 1}',
                      categoryIcon: icon,
                      imageUrl: null,
                      onTap: () {
                        debugLog('Tapped on company ${index + 1}');
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
