import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/widgets/company/company.category.dart';

/// Company Directory Screen
/// Displays company categories and allows navigation to company creation
class CompanyViewScreen extends StatefulWidget {
  static const String routeName = '/company-view';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const CompanyViewScreen({super.key});

  @override
  State<CompanyViewScreen> createState() => _CompanyViewScreenState();
}

class _CompanyViewScreenState extends State<CompanyViewScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Office',
      'icon': FontAwesomeIcons.building,
      'color': Colors.blue,
      'count': 3,
    },
    {
      'name': 'Education',
      'icon': FontAwesomeIcons.graduationCap,
      'color': Colors.green,
    },
    {'name': 'Food', 'icon': FontAwesomeIcons.utensils, 'color': Colors.orange},
    {'name': 'Transport', 'icon': FontAwesomeIcons.bus, 'color': Colors.purple},
    {
      'name': 'Hospital',
      'icon': FontAwesomeIcons.hospitalUser,
      'color': Colors.red,
      'count': 5,
    },
    {
      'name': 'Mart',
      'icon': FontAwesomeIcons.cartShopping,
      'color': Colors.teal,
    },
    {
      'name': 'Bank',
      'icon': FontAwesomeIcons.buildingColumns,
      'color': Colors.indigo,
    },
    {
      'name': 'Gadget',
      'icon': FontAwesomeIcons.mobileScreen,
      'color': Colors.blueGrey,
    },
    {
      'name': 'Travel Agency',
      'icon': FontAwesomeIcons.planeDeparture,
      'color': Colors.cyan,
    },
    {'name': 'Hotel', 'icon': FontAwesomeIcons.hotel, 'color': Colors.pink},
    {
      'name': 'Rent Car',
      'icon': FontAwesomeIcons.car,
      'color': Colors.deepOrange,
    },
    {
      'name': 'Beauty Salon',
      'icon': FontAwesomeIcons.scissors,
      'color': Colors.pinkAccent,
    },
    {
      'name': 'Real Estate',
      'icon': FontAwesomeIcons.houseChimney,
      'color': Colors.brown,
    },
    {
      'name': 'KTV',
      'icon': FontAwesomeIcons.microphone,
      'color': Colors.deepPurple,
    },
    {'name': 'Spa', 'icon': FontAwesomeIcons.spa, 'color': Colors.lightGreen},
    {'name': 'ETC', 'icon': FontAwesomeIcons.ellipsis, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(T.companyDirectoryTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with icon and description
            Padding(
              padding: EdgeInsets.all(sp.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.building,
                        size: 32,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: sp.s16),
                  // Title
                  Text(
                    T.companyDirectoryTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: sp.s8),
                  // Description
                  Text(
                    T.companyDirectoryDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: sp.s24),
                  // Register button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        // TODO: Navigate to company creation page
                      },
                      icon: const FaIcon(FontAwesomeIcons.plus, size: 20),
                      label: Text(T.registerCompany),
                    ),
                  ),
                ],
              ),
            ),

            // Categories list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(sp.s16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: sp.s8),
                  child: CompanyCategory(
                    name: category['name'] as String,
                    icon: category['icon'] as IconData,
                    color: category['color'] as Color,
                    count: (category['count'] as int?) ?? 0,
                  ),
                );
              },
            ),

            // Empty state at bottom (when no companies)
          ],
        ),
      ),
    );
  }
}
