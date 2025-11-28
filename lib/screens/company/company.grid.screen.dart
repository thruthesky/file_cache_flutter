import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/company/company.list.screen.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Company Directory Screen
/// Displays company categories in a grid layout
/// User can tap on a category to view companies in that category
class CompanyGridScreen extends StatefulWidget {
  static const String routeName = '/company-list';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const CompanyGridScreen({super.key});

  @override
  State<CompanyGridScreen> createState() => _CompanyGridScreenState();
}

class _CompanyGridScreenState extends State<CompanyGridScreen> {
  Company? myCompany;
  bool isLoadingMyCompany = true;

  /// Category definitions with icons and descriptions
  /// Translation keys are defined in app_localizations.dart
  List<Map<String, dynamic>> _getCategories(BuildContext context) {
    return [
      {
        'id': 'public-office',
        'name': Lo.of(context)!.publicOffice,
        'description': Lo.of(context)!.publicOfficeDesc,
        'icon': FontAwesomeIcons.lightBuilding,
      },
      {
        'id': 'education',
        'name': Lo.of(context)!.education,
        'description': Lo.of(context)!.educationDesc,
        'icon': FontAwesomeIcons.lightGraduationCap,
      },
      {
        'id': 'food',
        'name': Lo.of(context)!.foodAndDrink,
        'description': Lo.of(context)!.foodAndDrinkDesc,
        'icon': FontAwesomeIcons.lightUtensils,
      },
      {
        'id': 'transport',
        'name': Lo.of(context)!.transportation,
        'description': Lo.of(context)!.transportationDesc,
        'icon': FontAwesomeIcons.lightBus,
      },
      {
        'id': 'hospital',
        'name': Lo.of(context)!.healthAndHospitals,
        'description': Lo.of(context)!.healthAndHospitalsDesc,
        'icon': FontAwesomeIcons.lightHospital,
      },
      {
        'id': 'mart',
        'name': Lo.of(context)!.shoppingAndMarts,
        'description': Lo.of(context)!.shoppingAndMartsDesc,
        'icon': FontAwesomeIcons.lightCartShopping,
      },
      {
        'id': 'bank',
        'name': Lo.of(context)!.bankingAndFinance,
        'description': Lo.of(context)!.bankingAndFinanceDesc,
        'icon': FontAwesomeIcons.lightBuildingColumns,
      },
      {
        'id': 'gadget',
        'name': Lo.of(context)!.gadgets,
        'description': Lo.of(context)!.gadgetsDesc,
        'icon': FontAwesomeIcons.lightMobileScreen,
      },
      {
        'id': 'travel-agency',
        'name': Lo.of(context)!.travelAndTourism,
        'description': Lo.of(context)!.travelAndTourismDesc,
        'icon': FontAwesomeIcons.lightPlaneDeparture,
      },
      {
        'id': 'hotel',
        'name': Lo.of(context)!.hotels,
        'description': Lo.of(context)!.hotelsDesc,
        'icon': FontAwesomeIcons.lightHotel,
      },
      {
        'id': 'rentcar',
        'name': Lo.of(context)!.carRental,
        'description': Lo.of(context)!.carRentalDesc,
        'icon': FontAwesomeIcons.lightCar,
      },
      {
        'id': 'beauty',
        'name': Lo.of(context)!.beautyAndWellness,
        'description': Lo.of(context)!.beautyAndWellnessDesc,
        'icon': FontAwesomeIcons.lightScissors,
      },
      {
        'id': 'real-estate',
        'name': Lo.of(context)!.realEstate,
        'description': Lo.of(context)!.realEstateDesc,
        'icon': FontAwesomeIcons.lightHouseChimney,
      },
      {
        'id': 'ktv',
        'name': Lo.of(context)!.entertainment,
        'description': Lo.of(context)!.entertainmentDesc,
        'icon': FontAwesomeIcons.lightMicrophone,
      },
      {
        'id': 'spa',
        'name': Lo.of(context)!.spaAndRelaxation,
        'description': Lo.of(context)!.spaAndRelaxationDesc,
        'icon': FontAwesomeIcons.lightSpa,
      },
      {
        'id': 'etc',
        'name': Lo.of(context)!.otherServices,
        'description': Lo.of(context)!.otherServicesDesc,
        'icon': FontAwesomeIcons.lightEllipsis,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadMyCompany();
  }

  /// Fetch current user's company
  Future<void> _loadMyCompany() async {
    try {
      final result = await getMyCompany();
      myCompany = result;
    } catch (e) {
      debugLog('Error loading my company: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingMyCompany = false;
        });
      }
    }
  }

  /// Handle company registration button press (Register or Update)
  Future<void> _handleCreateOrUpdateButton() async {
    if (isLoadingMyCompany) return;

    // Update existing company
    if (myCompany != null) {
      final result = await CompanyFormScreen.push(context, company: myCompany);
      if (result != null) setState(() => myCompany = result);
      return;
    }

    // Create new company
    setState(() => isLoadingMyCompany = true);
    try {
      myCompany = await createCompany();
      if (mounted) {
        showSuccessSnackBar(context, "Your company is already created");
      }
    } finally {
      if (mounted) setState(() => isLoadingMyCompany = false);
    }
  }

  /// Navigate to category screen showing companies for selected category
  void _handleCategoryTap(String categoryId, String categoryName) {
    CompanyListScreen.push(
      context,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }

  /// Get color for category based on index
  /// Cycles through theme colors for visual variety
  Color _getCategoryColor(int index, ColorScheme scheme) {
    final colors = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
      scheme.errorContainer,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;
    final categories = _getCategories(context);

    return Column(
      children: [
        /// Top SafeArea
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  Lo.of(context)!.companyDirectoryTitle,
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: FaIcon(
                    myCompany != null
                        ? FontAwesomeIcons.penToSquare
                        : FontAwesomeIcons.circlePlus,
                    color: scheme.onPrimaryContainer,
                    size: 24,
                  ),
                  onPressed: _handleCreateOrUpdateButton,
                  tooltip: myCompany != null
                      ? Lo.of(context)!.editMyCompany
                      : Lo.of(context)!.addMyCompany,
                ),
              ],
            ),
          ),
        ),

        /// Grid of company categories
        /// Wrapped in Expanded to provide bounded height constraint for GridView
        /// Using mainAxisExtent to allow items to display at their natural height
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(sp.s16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: sp.s16,
              mainAxisSpacing: sp.s16,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final color = _getCategoryColor(index, scheme);

              return _CategoryCard(
                categoryId: category['id'] as String,
                categoryName: category['name'] as String,
                description: category['description'] as String,
                icon: category['icon'] as IconData,
                color: color,
                onTap: () => _handleCategoryTap(
                  category['id'] as String,
                  category['name'] as String,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Category Card Widget
/// Displays a single category with icon, name, and description
class _CategoryCard extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2, // Subtle shadow for card depth
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sp.s16),
        ),
        child: Padding(
          padding: EdgeInsets.all(sp.s16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Icon Container
              SizedBox(
                width: sp.s32,
                height: sp.s32,
                child: Center(
                  child: FaIcon(icon, size: 24, color: scheme.primary),
                ),
              ),
              SizedBox(height: sp.s12),

              /// Category Name
              Text(
                categoryName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sp.s4),

              /// Description
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
