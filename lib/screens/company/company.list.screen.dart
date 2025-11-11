import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/widgets/company/company.category.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Company Directory Screen
/// Displays company categories and allows navigation to company creation
class CompanyListScreen extends StatefulWidget {
  static const String routeName = '/company-list';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  CompanyList? companyList;
  Company? myCompany;
  bool isLoading = true;
  bool isLoadingMyCompany = true;
  String? errorMessage;

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'public-office',
      'name': 'Public Office',
      'icon': FontAwesomeIcons.building,
      'color': Colors.blue,
    },
    {
      'id': 'education',
      'name': 'Education',
      'icon': FontAwesomeIcons.graduationCap,
      'color': Colors.green,
    },
    {
      'id': 'food',
      'name': 'Food',
      'icon': FontAwesomeIcons.utensils,
      'color': Colors.orange,
    },
    {
      'id': 'transport',
      'name': 'Transport',
      'icon': FontAwesomeIcons.bus,
      'color': Colors.purple,
    },
    {
      'id': 'hospital',
      'name': 'Hospital',
      'icon': FontAwesomeIcons.hospitalUser,
      'color': Colors.red,
    },
    {
      'id': 'mart',
      'name': 'Mart',
      'icon': FontAwesomeIcons.cartShopping,
      'color': Colors.teal,
    },
    {
      'id': 'bank',
      'name': 'Bank',
      'icon': FontAwesomeIcons.buildingColumns,
      'color': Colors.indigo,
    },
    {
      'id': 'gadget',
      'name': 'Gadget',
      'icon': FontAwesomeIcons.mobileScreen,
      'color': Colors.blueGrey,
    },
    {
      'id': 'travel-agency',
      'name': 'Travel Agency',
      'icon': FontAwesomeIcons.planeDeparture,
      'color': Colors.cyan,
    },
    {
      'id': 'hotel',
      'name': 'Hotel',
      'icon': FontAwesomeIcons.hotel,
      'color': Colors.pink,
    },
    {
      'id': 'rentcar',
      'name': 'Rent Car',
      'icon': FontAwesomeIcons.car,
      'color': Colors.deepOrange,
    },
    {
      'id': 'beauty',
      'name': 'Beauty',
      'icon': FontAwesomeIcons.scissors,
      'color': Colors.pinkAccent,
    },
    {
      'id': 'real-estate',
      'name': 'Real Estate',
      'icon': FontAwesomeIcons.houseChimney,
      'color': Colors.brown,
    },
    {
      'id': 'ktv',
      'name': 'KTV',
      'icon': FontAwesomeIcons.microphone,
      'color': Colors.deepPurple,
    },
    {
      'id': 'spa',
      'name': 'Spa',
      'icon': FontAwesomeIcons.spa,
      'color': Colors.lightGreen,
    },
    {
      'id': 'etc',
      'name': 'ETC',
      'icon': FontAwesomeIcons.ellipsis,
      'color': Colors.grey,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMyCompany();
    _loadCompanies();
  }

  /// Fetch current user's company
  Future<void> _loadMyCompany() async {
    try {
      final result = await getMyCompany();
      myCompany = result;
      debugLog('My Company: $myCompany');
    } catch (e) {
      debugLog('Error loading my company: $e');
    } finally {
      setState(() {
        isLoadingMyCompany = false;
      });
    }
  }

  /// Fetch companies from API
  Future<void> _loadCompanies() async {
    isLoading = true;
    errorMessage = null;
    setState(() {});

    try {
      final result = await getCompanies();
      companyList = result;
      debugLog('Company List: $companyList');
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  /// Get companies by category ID
  List<Company> _getCompaniesByCategory(String categoryId) {
    if (companyList == null) return [];
    return companyList!.companies
        .where(
          (company) =>
              company.category.toLowerCase() == categoryId.toLowerCase(),
        )
        .toList();
  }

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
                  // Register/Update button (hidden while loading)
                  if (!isLoadingMyCompany)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          // Navigate to company form (with company data for update, null for create)
                          await CompanyFormScreen.push(
                            context,
                            company: myCompany,
                          );
                        },
                        icon: FaIcon(
                          myCompany == null
                              ? FontAwesomeIcons.plus
                              : FontAwesomeIcons.penToSquare,
                          size: 20,
                        ),
                        label: Text(
                          myCompany == null
                              ? T.registerCompany
                              : T.updateCompany,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Loading, Error, or Categories list
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(sp.s24),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              Padding(
                padding: EdgeInsets.all(sp.s24),
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      size: 48,
                      color: scheme.error,
                    ),
                    SizedBox(height: sp.s16),
                    Text(
                      'Failed to load companies',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                    SizedBox(height: sp.s8),
                    Text(
                      errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: sp.s16),
                    FilledButton.icon(
                      onPressed: _loadCompanies,
                      icon: const FaIcon(
                        FontAwesomeIcons.arrowRotateRight,
                        size: 16,
                      ),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(sp.s16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryId = category['id'] as String;
                  final categoryName = category['name'] as String;
                  final companiesInCategory = _getCompaniesByCategory(
                    categoryId,
                  );

                  return Padding(
                    padding: EdgeInsets.only(bottom: sp.s8),
                    child: CompanyCategory(
                      name: categoryName,
                      icon: category['icon'] as IconData,
                      color: category['color'] as Color,
                      count: companiesInCategory.length,
                      companies: companiesInCategory,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
