import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Category Card Widget
/// Displays a single company category with icon, name, count, and horizontal list of companies
class CompanyCategory extends StatelessWidget {
  const CompanyCategory({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    required this.companies,
    this.onCompanyTap,
  });

  final String name;
  final IconData icon;
  final Color color;
  final int count;
  final List<Company> companies;
  final void Function(Company)? onCompanyTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(icon, size: 16, color: scheme.onSurface),
                  ),
                ),
                SizedBox(width: 16),
                // Category name and count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
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
          SizedBox(height: 16),
          if (count <= 0)
            const Center(child: CompanyCategoryEmpty())
          else
            // Horizontal scrollable list of company cards
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: companies.length,
                separatorBuilder: (context, index) => SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final company = companies[index];
                  return SizedBox(
                    width: 220,
                    child: CompanyCard(
                      name: company.name.isNotEmpty
                          ? company.name
                          : company.title,
                      categoryIcon: icon,
                      imageUrl: company.title_image_url.isNotEmpty
                          ? company.title_image_url
                          : company.logo_url,
                      onTap: onCompanyTap != null
                          ? () => onCompanyTap!(company)
                          : null,
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
