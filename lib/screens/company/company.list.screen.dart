import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

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
  bool _showHeader = true;

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

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      final currentOffset = notification.metrics.pixels;

      if (delta > 0 && currentOffset > 48) {
        if (_showHeader) setState(() => _showHeader = false);
      } else if (delta < 0) {
        if (!_showHeader) setState(() => _showHeader = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;
    final categories = _getCategories(context);

    final headerColor = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: headerColor,
      body: SafeArea(
        child: Container(
          color: headerColor,
          child: Column(
            children: [
              ClipRect(
                child: AnimatedAlign(
                  alignment: Alignment.topCenter,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  heightFactor: _showHeader ? 1.0 : 0.0,
                  child: _buildHeader(theme, sp, categories),
                ),
              ),
              Expanded(child: _buildBodyContent(theme, scheme, sp, categories)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    AppSpacing sp,
    List<CompanyCategory> categories,
  ) {
    final title = Lo.of(context)!.companyDirectoryTitle;
    final buttonLabel = myCompany != null
        ? Lo.of(context)!.editMyCompany
        : Lo.of(context)!.addMyCompany;
    final buttonIcon = myCompany != null
        ? FontAwesomeIcons.penToSquare
        : FontAwesomeIcons.circlePlus;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(sp.s16, sp.s16, sp.s16, sp.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
          //     FilledButton.icon(
          //       onPressed: _handleCreateOrUpdateButton,
          //       icon: FaIcon(buttonIcon, size: 16),
          //       label: Text(buttonLabel),
          //     ),
          //   ],
          // ),
          SizedBox(height: sp.s12),
          _buildScrollableFilters(categories, sp),
        ],
      ),
    );
  }

  double _filterGridHeight(AppSpacing sp) => (_filterChipSize * 2) + sp.s8;

  Widget _buildScrollableFilters(
    List<CompanyCategory> categories,
    AppSpacing sp,
  ) {
    final items = [
      CompanyCategory(
        id: 'all',
        name: Lo.of(context)!.allCategories,
        description: '',
        icon: FontAwesomeIcons.lightLayerGroup,
      ),
      ...categories,
    ];

    final totalHeight = _filterGridHeight(sp);

    return SizedBox(
      height: totalHeight,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(bottom: sp.s4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: sp.s8,
          crossAxisSpacing: sp.s8,
          childAspectRatio: 1,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final category = items[index];
          final isAll = category.id == 'all';
          final isSelected = isAll
              ? selectedCategoryId == null
              : selectedCategoryId == category.id;
          return Align(
            alignment: Alignment.centerLeft,
            child: CompanyCategoryFilterChip(
              isSelected: isSelected,
              label: category.name,
              icon: category.icon,
              onTap: () => _handleCategoryFilterTap(isAll ? null : category.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    List<CompanyCategory> categories,
  ) {
    if (isLoading) {
      return _wrapScrollable(
        ListView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: sp.s32),
          children: [
            Center(child: CircularProgressIndicator(color: scheme.primary)),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return _wrapScrollable(
        ListView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: sp.s24, vertical: sp.s24),
          children: [
            _buildStateMessage(
              scheme: scheme,
              theme: theme,
              sp: sp,
              icon: FontAwesomeIcons.lightTriangleExclamation,
              iconColor: scheme.error,
              title: errorMessage!,
              subtitle: T.failedToLoadCompanies,
              action: _StateAction(
                label: T.retry,
                icon: FontAwesomeIcons.lightArrowRotateRight,
                onPressed: _loadCompanies,
              ),
            ),
          ],
        ),
      );
    }

    if (companyList == null || companyList!.companies.isEmpty) {
      final categoryName = selectedCategoryId == null
          ? Lo.of(context)!.allCategories
          : categories.firstWhere((c) => c.id == selectedCategoryId).name;

      return _wrapScrollable(
        ListView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: sp.s24, vertical: sp.s24),
          children: [
            _buildStateMessage(
              scheme: scheme,
              theme: theme,
              sp: sp,
              icon: FontAwesomeIcons.lightBuildingCircleXmark,
              iconColor: scheme.onSurfaceVariant,
              title: T.noCompaniesFound,
              subtitle: selectedCategoryId == null
                  ? T.noRegisteredCompanies
                  : T.noCompaniesInCategory(categoryName),
            ),
          ],
        ),
      );
    }

    return _wrapScrollable(
      MasonryGridView.count(
        padding: EdgeInsets.fromLTRB(sp.s16, sp.s16, sp.s16, sp.s24),
        physics: const ClampingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: sp.s12,
        crossAxisSpacing: sp.s12,
        itemCount: companyList!.companies.length,
        itemBuilder: (context, index) {
          final company = companyList!.companies[index];
          final resolvedCategory = _resolveCategory(
            categories,
            company.category,
          );

          return CompanyCard(
            name: company.name,
            categoryIcon: resolvedCategory.icon,
            imageUrl: company.title_image_url.isNotEmpty
                ? company.title_image_url
                : company.logo_url,
            onTap: () => _handleCompanyTap(company),
          );
        },
      ),
    );
  }

  CompanyCategory _resolveCategory(
    List<CompanyCategory> categories,
    String id,
  ) {
    return categories.firstWhere(
      (c) => c.id == id,
      orElse: () => categories.last,
    );
  }

  Widget _buildStateMessage({
    required ColorScheme scheme,
    required ThemeData theme,
    required AppSpacing sp,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    _StateAction? action,
  }) {
    return Padding(
      padding: EdgeInsets.all(sp.s24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 48, color: iconColor),
          SizedBox(height: sp.s16),
          Text(
            title,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            SizedBox(height: sp.s16),
            FilledButton.icon(
              onPressed: action.onPressed,
              icon: FaIcon(action.icon, size: 16),
              label: Text(action.label),
            ),
          ],
        ],
      ),
    );
  }

  Widget _wrapScrollable(Widget child) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: child,
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

    final backgroundColor = isSelected ? scheme.primary : scheme.surface;
    final iconColor = isSelected ? scheme.onPrimary : scheme.onSurfaceVariant;
    final textColor = isSelected ? scheme.onPrimary : scheme.onSurface;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          width: _filterChipSize,
          height: _filterChipSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, size: 18, color: iconColor),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontSize: 11,
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

class _StateAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _StateAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

const double _filterChipSize = 68.0;
