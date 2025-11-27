import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Company Directory Screen
/// Displays company categories and allows navigation to company creation
class CompanyGridScreen extends StatefulWidget {
  static const String routeName = '/company-list';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const CompanyGridScreen({super.key});

  @override
  State<CompanyGridScreen> createState() => _CompanyGridScreenState();
}

class _CompanyGridScreenState extends State<CompanyGridScreen> {
  CompanyList? companyList;
  Company? myCompany;
  bool isLoading = true;
  bool isLoadingMyCompany = true;
  String? errorMessage;
  String? selectedCategoryId = 'public-office'; // 기본 선택 카테고리: Public Office

  // 카테고리별 회사 목록 캐시 (categoryId -> CompanyList)
  final Map<String, CompanyList> _categoryCache = {};

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'public-office',
      'name': 'Public Office',
      'icon': FontAwesomeIcons.building,
    },
    {
      'id': 'education',
      'name': 'Education',
      'icon': FontAwesomeIcons.graduationCap,
    },
    {'id': 'food', 'name': 'Food', 'icon': FontAwesomeIcons.utensils},
    {'id': 'transport', 'name': 'Transport', 'icon': FontAwesomeIcons.bus},
    {
      'id': 'hospital',
      'name': 'Hospital',
      'icon': FontAwesomeIcons.hospitalUser,
    },
    {'id': 'mart', 'name': 'Mart', 'icon': FontAwesomeIcons.cartShopping},
    {'id': 'bank', 'name': 'Bank', 'icon': FontAwesomeIcons.buildingColumns},
    {'id': 'gadget', 'name': 'Gadget', 'icon': FontAwesomeIcons.mobileScreen},
    {
      'id': 'travel-agency',
      'name': 'Travel',
      'icon': FontAwesomeIcons.planeDeparture,
    },
    {'id': 'hotel', 'name': 'Hotel', 'icon': FontAwesomeIcons.hotel},
    {'id': 'rentcar', 'name': 'Rent Car', 'icon': FontAwesomeIcons.car},
    {'id': 'beauty', 'name': 'Beauty', 'icon': FontAwesomeIcons.scissors},
    {
      'id': 'real-estate',
      'name': 'Real Estate',
      'icon': FontAwesomeIcons.houseChimney,
    },
    {'id': 'ktv', 'name': 'KTV', 'icon': FontAwesomeIcons.microphone},
    {'id': 'spa', 'name': 'Spa', 'icon': FontAwesomeIcons.spa},
    {'id': 'etc', 'name': 'ETC', 'icon': FontAwesomeIcons.ellipsis},
  ];

  @override
  void initState() {
    super.initState();
    _loadMyCompany();
    _loadCompaniesByCategory('public-office');
  }

  /// Fetch current user's company
  Future<void> _loadMyCompany() async {
    try {
      final result = await getMyCompany();
      myCompany = result;
      // debugLog('My Company: $myCompany');
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

  Future<void> _loadCompaniesByCategory(String categoryId) async {
    if (_categoryCache.containsKey(categoryId)) {
      debugLog('Loading category $categoryId from cache');
      setState(() {
        companyList = _categoryCache[categoryId];
        isLoading = false;
      });
      return;
    }

    // 캐시에 없으면 API 호출
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      debugLog('Fetching category $categoryId from API');
      final result = await getCompanies(category: categoryId);

      // 캐시에 저장
      _categoryCache[categoryId] = result;

      companyList = result;
      debugLog(
        'Company List for category $categoryId: ${companyList?.companies.length}',
      );
    } catch (e) {
      debugLog('Error loading companies: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load companies';
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

  void _handleCategoryTap(String? categoryId) {
    if (categoryId == null || categoryId == selectedCategoryId) return;

    setState(() {
      selectedCategoryId = categoryId;
    });

    _loadCompaniesByCategory(categoryId);
  }

  void _handleCompanyTap(Company company) {
    CompanyViewScreen.push(context, company.idx);
  }

  /// Handle company button press (Register or Update)
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top SafeArea
        Container(
          color: scheme.surface,
          child: SafeArea(child: Container()),
        ),

        // Company Directory Title
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                T.companyDirectoryTitle,
                style: theme.textTheme.headlineMedium,
              ),
              Spacer(),
              IconButton(
                icon: FaIcon(
                  myCompany != null
                      ? FontAwesomeIcons.penToSquare
                      : FontAwesomeIcons.circlePlus,
                  color: scheme.onPrimaryContainer,
                  size: 24,
                ),
                onPressed: _handleCreateOrUpdateButton,
                tooltip: myCompany != null ? 'Edit Company' : 'Add Company',
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        CompanyCategoryHeader(
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          onCategoryTap: _handleCategoryTap,
        ),
        const SizedBox(height: 16),

        // // Body Content (스크롤 가능)
        // Expanded(
        //   child: LayoutBuilder(
        //     builder: (context, constraints) {
        //       return SingleChildScrollView(
        //         child: isLoading
        //             ? SkeletonCompanyCardList()
        //             : selectedCategoryId != null
        //             ? _buildCategorySection(
        //                 selectedCategoryId!,
        //                 constraints.maxHeight,
        //               )
        //             : const SizedBox.shrink(),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }

  Widget _buildCategorySection(String categoryId, double availableHeight) {
    final category = categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'id': '', 'name': '', 'icon': FontAwesomeIcons.ellipsis},
    );
    final categoryCompanies = _getCompaniesByCategory(categoryId);

    return CompanyListGrid(
      icon: category['icon'] as IconData,
      name: category['name'] as String,
      count: categoryCompanies.length,
      companies: categoryCompanies,
      onCompanyTap: _handleCompanyTap,
      availableHeight: availableHeight,
    );
  }

  List<Company> _getCompaniesByCategory(String categoryId) {
    if (companyList == null) return [];

    // Filter out incomplete companies (idx=0 or missing required fields)
    return companyList!.companies.where((company) {
      // Exclude companies with idx=0 (invalid/placeholder companies)
      if (company.idx == 0) return false;

      // Exclude companies without a name (incomplete registration)
      if (company.name.isEmpty) return false;

      return true;
    }).toList();
  }
}
