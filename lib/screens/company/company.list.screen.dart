import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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

/// Company Category Screen
/// Displays companies filtered by a specific category
class CompanyListScreen extends StatefulWidget {
  static const String routeName = '/company/category';

  final String categoryId;
  final String categoryName;

  const CompanyListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  /// Navigation helper to push this screen
  static Future<T?> push<T>(
    BuildContext context, {
    required String categoryId,
    required String categoryName,
  }) {
    return context.push<T>(
      '$routeName?categoryId=$categoryId&categoryName=$categoryName',
    );
  }

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  CompanyList? companyList;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  /// Fetch companies for the selected category
  Future<void> _loadCompanies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await getCompanies(category: widget.categoryId);
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

  /// Navigate to company detail screen
  void _handleCompanyTap(Company company) {
    CompanyViewScreen.push(context, company.idx);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
        backgroundColor: scheme.surfaceContainerLow,
        elevation: 1,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 24),
        ),
        title: Text(widget.categoryName, style: theme.textTheme.titleLarge),
      ),
      body: _buildBody(scheme, theme, sp),
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
                T.noCompaniesInCategory(widget.categoryName),
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
          return CompanyCard(
            name: company.name,
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
