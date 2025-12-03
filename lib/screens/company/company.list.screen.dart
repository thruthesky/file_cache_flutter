import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Category Model
/// Represents a company category with id, name, description, and icon
class CompanyCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const CompanyCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// Get icon for company category
/// Returns appropriate FontAwesome icon based on category ID
IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'public-office':
      return FontAwesomeIcons.lightBuilding;
    case 'education':
      return FontAwesomeIcons.lightGraduationCap;
    case 'food':
      return FontAwesomeIcons.lightUtensils;
    case 'transport':
      return FontAwesomeIcons.lightBus;
    case 'hospital':
      return FontAwesomeIcons.lightHospital;
    case 'mart':
      return FontAwesomeIcons.lightCartShopping;
    case 'bank':
      return FontAwesomeIcons.lightBuildingColumns;
    case 'gadget':
      return FontAwesomeIcons.lightMobileScreen;
    case 'travel-agency':
      return FontAwesomeIcons.lightPlaneDeparture;
    case 'hotel':
      return FontAwesomeIcons.lightHotel;
    case 'rentcar':
      return FontAwesomeIcons.lightCar;
    case 'beauty':
      return FontAwesomeIcons.lightScissors;
    case 'real-estate':
      return FontAwesomeIcons.lightHouseChimney;
    case 'ktv':
      return FontAwesomeIcons.lightMicrophone;
    case 'spa':
      return FontAwesomeIcons.lightSpa;
    case 'etc':
    default:
      return FontAwesomeIcons.lightEllipsis;
  }
}

/// Company List Screen with Category Filters
/// Displays all companies with filter chips to filter by category
class CompanyListScreen extends StatefulWidget {
  static const String routeName = '/company-list';

  const CompanyListScreen({super.key});

  /// Navigation helper to push this screen
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  Company? myCompany;
  bool isLoadingMyCompany = true;
  CompanyList? companyList;
  bool isLoading = true;
  String? errorMessage;

  /// Currently selected category filter
  /// null means "All" categories
  String? selectedCategoryId;

  /// Get list of all available categories with localized names
  List<CompanyCategory> _getCategories(BuildContext context) {
    return [
      CompanyCategory(
        id: 'public-office',
        name: Lo.of(context)!.publicOffice,
        description: Lo.of(context)!.publicOfficeDesc,
        icon: FontAwesomeIcons.lightBuilding,
      ),
      CompanyCategory(
        id: 'education',
        name: Lo.of(context)!.education,
        description: Lo.of(context)!.educationDesc,
        icon: FontAwesomeIcons.lightGraduationCap,
      ),
      CompanyCategory(
        id: 'food',
        name: Lo.of(context)!.foodAndDrink,
        description: Lo.of(context)!.foodAndDrinkDesc,
        icon: FontAwesomeIcons.lightUtensils,
      ),
      CompanyCategory(
        id: 'transport',
        name: Lo.of(context)!.transportation,
        description: Lo.of(context)!.transportationDesc,
        icon: FontAwesomeIcons.lightBus,
      ),
      CompanyCategory(
        id: 'hospital',
        name: Lo.of(context)!.healthAndHospitals,
        description: Lo.of(context)!.healthAndHospitalsDesc,
        icon: FontAwesomeIcons.lightHospital,
      ),
      CompanyCategory(
        id: 'mart',
        name: Lo.of(context)!.shoppingAndMarts,
        description: Lo.of(context)!.shoppingAndMartsDesc,
        icon: FontAwesomeIcons.lightCartShopping,
      ),
      CompanyCategory(
        id: 'bank',
        name: Lo.of(context)!.bankingAndFinance,
        description: Lo.of(context)!.bankingAndFinanceDesc,
        icon: FontAwesomeIcons.lightBuildingColumns,
      ),
      CompanyCategory(
        id: 'gadget',
        name: Lo.of(context)!.gadgets,
        description: Lo.of(context)!.gadgetsDesc,
        icon: FontAwesomeIcons.lightMobileScreen,
      ),
      CompanyCategory(
        id: 'travel-agency',
        name: Lo.of(context)!.travelAndTourism,
        description: Lo.of(context)!.travelAndTourismDesc,
        icon: FontAwesomeIcons.lightPlaneDeparture,
      ),
      CompanyCategory(
        id: 'hotel',
        name: Lo.of(context)!.hotels,
        description: Lo.of(context)!.hotelsDesc,
        icon: FontAwesomeIcons.lightHotel,
      ),
      CompanyCategory(
        id: 'rentcar',
        name: Lo.of(context)!.carRental,
        description: Lo.of(context)!.carRentalDesc,
        icon: FontAwesomeIcons.lightCar,
      ),
      CompanyCategory(
        id: 'beauty',
        name: Lo.of(context)!.beautyAndWellness,
        description: Lo.of(context)!.beautyAndWellnessDesc,
        icon: FontAwesomeIcons.lightScissors,
      ),
      CompanyCategory(
        id: 'real-estate',
        name: Lo.of(context)!.realEstate,
        description: Lo.of(context)!.realEstateDesc,
        icon: FontAwesomeIcons.lightHouseChimney,
      ),
      CompanyCategory(
        id: 'ktv',
        name: Lo.of(context)!.entertainment,
        description: Lo.of(context)!.entertainmentDesc,
        icon: FontAwesomeIcons.lightMicrophone,
      ),
      CompanyCategory(
        id: 'spa',
        name: Lo.of(context)!.spaAndRelaxation,
        description: Lo.of(context)!.spaAndRelaxationDesc,
        icon: FontAwesomeIcons.lightSpa,
      ),
      CompanyCategory(
        id: 'etc',
        name: Lo.of(context)!.otherServices,
        description: Lo.of(context)!.otherServicesDesc,
        icon: FontAwesomeIcons.lightEllipsis,
      ),
    ];
  }

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

  /// Fetch all companies
  /// If selectedCategoryId is not null, filter by category
  Future<void> _loadCompanies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load all companies or filtered by category
      final result = await getCompanies(category: selectedCategoryId);
      companyList = result;
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = T.failedToLoadCompanies;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Handle category filter chip tap
  /// Reload companies when category changes
  void _handleCategoryFilterTap(String? categoryId) {
    if (selectedCategoryId == categoryId) return;

    setState(() {
      selectedCategoryId = categoryId;
    });
    _loadCompanies();
  }

  /// Navigate to company detail screen
  void _handleCompanyTap(Company company) {
    CompanyViewScreen.push(context, company.idx);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;
    final categories = _getCategories(context);

    return Column(
      children: [
        /// Header with title and action button
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Comic design: 2.0px border with outline color
              border: Border(
                bottom: BorderSide(color: scheme.outline, width: 2.0),
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

        /// Category filter chips
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s8),

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                /// "All" filter chip
                CompanyCategoryFilterChip(
                  isSelected: selectedCategoryId == null,
                  label: Lo.of(context)!.allCategories,
                  icon: FontAwesomeIcons.lightLayerGroup,
                  onTap: () => _handleCategoryFilterTap(null),
                  padding: EdgeInsets.symmetric(horizontal: sp.s4),
                ),

                /// Category filter chips
                ...categories.map((category) {
                  final isSelected = selectedCategoryId == category.id;
                  return CompanyCategoryFilterChip(
                    isSelected: isSelected,
                    label: category.name,
                    icon: category.icon,
                    onTap: () => _handleCategoryFilterTap(category.id),
                    padding: EdgeInsets.symmetric(horizontal: sp.s4),
                  );
                }),
              ],
            ),
          ),
        ),

        /// Company list
        Expanded(child: _buildBody(scheme, theme, sp)),
      ],
    );
  }

  /// Build body content based on loading state
  Widget _buildBody(ColorScheme scheme, ThemeData theme, AppSpacing sp) {
    // Loading state
    if (isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: CircularProgressIndicator())],
      );
    }

    // Error state
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(sp.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.lightTriangleExclamation,
                size: 48,
                color: scheme.error,
              ),
              SizedBox(height: sp.s16),
              Text(
                errorMessage!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sp.s16),
              FilledButton.icon(
                onPressed: _loadCompanies,
                icon: const FaIcon(
                  FontAwesomeIcons.lightArrowRotateRight,
                  size: 16,
                ),
                label: Text(T.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (companyList == null || companyList!.companies.isEmpty) {
      final categoryName = selectedCategoryId == null
          ? Lo.of(context)!.allCategories
          : _getCategories(
              context,
            ).firstWhere((c) => c.id == selectedCategoryId).name;

      return Center(
        child: Padding(
          padding: EdgeInsets.all(sp.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.lightBuildingCircleXmark,
                size: 48,
                color: scheme.onSurfaceVariant,
              ),
              SizedBox(height: sp.s16),
              Text(T.noCompaniesFound, style: theme.textTheme.titleMedium),
              SizedBox(height: sp.s8),
              Text(
                selectedCategoryId == null
                    ? T.noRegisteredCompanies
                    : T.noCompaniesInCategory(categoryName),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Company grid with responsive aspect ratio
    // Calculate appropriate aspect ratio based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = 2;
    final horizontalPadding = sp.s16 * 2; // Left and right padding
    final crossAxisSpacing = sp.s16;

    // Calculate available width per card
    final availableWidth = screenWidth - horizontalPadding - crossAxisSpacing;
    final cardWidth = availableWidth / crossAxisCount;

    // Card height calculation:
    // - Image with 16:9 aspect ratio: cardWidth * (9/16)
    // - Text section with padding: 12 (top) + 12 (bottom) + text height (~20)
    final imageHeight = cardWidth * (9 / 16);
    final textSectionHeight = 44.0; // 12 + 20 + 12
    final cardHeight = imageHeight + textSectionHeight;

    // Calculate childAspectRatio: width / height
    final childAspectRatio = cardWidth / cardHeight;

    return RefreshIndicator(
      onRefresh: _loadCompanies,
      child: GridView.builder(
        padding: EdgeInsets.all(sp.s16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: sp.s16,
          mainAxisSpacing: sp.s16,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: companyList!.companies.length,
        itemBuilder: (context, index) {
          final company = companyList!.companies[index];

          /// Get category name by matching category ID
          final categoryName = _getCategories(context)
              .firstWhere(
                (c) => c.id == company.category,
                orElse: () => _getCategories(context).last,
              )
              .name;

          return CompanyCard(
            name: company.name,
            categoryName: categoryName,
            categoryIcon: _getCategoryIcon(company.category),
            imageUrl: company.title_image_url.isNotEmpty
                ? company.title_image_url
                : company.logo_url,
            onTap: () => _handleCompanyTap(company),
          );
        },
      ),
    );
  }
}

/// Company Category Filter Chip
/// Custom flat design filter component with icon and label
class CompanyCategoryFilterChip extends StatelessWidget {
  final bool isSelected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  const CompanyCategoryFilterChip({
    super.key,
    required this.isSelected,
    required this.label,
    required this.icon,
    required this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Comic design: Define colors based on selection state
    final backgroundColor = isSelected
        ? scheme.secondaryContainer
        : scheme.surface;
    final iconColor = isSelected
        ? scheme.onSecondaryContainer
        : scheme.onSurfaceVariant;
    final textColor = isSelected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    // Comic design: Border color (primary when selected, outline when not)
    final borderColor = isSelected
        ? scheme.primary
        : scheme.outline;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        // Comic design: Border radius 8 for small elements
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            // Comic design: Border radius 8 for small elements
            borderRadius: BorderRadius.circular(8),
            // Comic design: 2.0px border
            border: Border.all(
              color: borderColor,
              width: 2.0,
            ),
          ),
          width: 80,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(icon, size: 20, color: iconColor),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
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
