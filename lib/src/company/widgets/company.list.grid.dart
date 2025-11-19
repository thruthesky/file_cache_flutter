import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class CompanyListGrid extends StatelessWidget {
  const CompanyListGrid({
    super.key,
    required this.icon,
    required this.name,
    required this.count,
    required this.companies,
    this.onCompanyTap,
  });

  final IconData icon;
  final String name;
  final int count;
  final List<Company> companies;
  final Function(Company)? onCompanyTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name • $count',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          if (count <= 0)
            const Center(child: CompanyCategoryEmpty())
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8, // Add vertical spacing between cards
                childAspectRatio: 1.2,
              ),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return CompanyCard(
                  name: company.name.isNotEmpty ? company.name : company.title,
                  categoryIcon: icon,
                  imageUrl: company.title_image_url.isNotEmpty
                      ? company.title_image_url
                      : company.logo_url,
                  onTap: onCompanyTap != null
                      ? () => onCompanyTap!(company)
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
