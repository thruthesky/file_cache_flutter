import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/theme/comic_fab.dart';
import 'package:philgo/v7_api/company_api.dart';
import 'package:philgo_api/philgo_api.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

/// 카테고리 모델
/// 업소 카테고리의 id, 이름, 설명, 아이콘을 보유
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

/// 업소 목록 화면 (카테고리 필터 포함)
/// Best Practice 패턴 AppBar + 필터 칩 + 순차 애니메이션 + 내 업소 섹션
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

  /// 현재 선택된 카테고리 필터
  /// null이면 "전체" 카테고리
  String? selectedCategoryId;
  bool _showHeader = true;

  /// 사용 가능한 모든 카테고리 목록 (로컬라이즈된 이름)
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

  /// 현재 사용자의 업소 조회
  Future<void> _loadMyCompany() async {
    try {
      final result = await CompanyApi.mine();

      /// 빈 업소(서버 자동 생성)는 null 처리하여 기존 null 체크 로직 유지
      myCompany = result.name.isNotEmpty ? result : null;
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

  /// 업소 등록/수정 버튼 핸들러
  Future<void> _handleCreateOrUpdateButton() async {
    if (isLoadingMyCompany) return;

    // 기존 업소 수정
    if (myCompany != null) {
      final result = await CompanyFormScreen.push(context, company: myCompany);
      if (result != null) setState(() => myCompany = result);
      return;
    }

    // 새 업소 생성 후 수정 폼으로 이동
    setState(() => isLoadingMyCompany = true);
    try {
      myCompany = await CompanyApi.create();
      if (mounted && myCompany != null) {
        final result = await CompanyFormScreen.push(context, company: myCompany);
        if (result != null) setState(() => myCompany = result);
      }
    } catch (e) {
      debugLog('Error creating company: $e');
      if (mounted) {
        showSuccessSnackBar(context, T.errorWithMessage(e.toString()));
      }
    } finally {
      if (mounted) setState(() => isLoadingMyCompany = false);
    }
  }

  /// 모든 업소 목록 조회
  /// selectedCategoryId가 null이 아니면 카테고리별 필터링
  Future<void> _loadCompanies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load all companies or filtered by category
      final result = await CompanyApi.list(category: selectedCategoryId);
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

  /// 카테고리 필터 칩 탭 핸들러
  void _handleCategoryFilterTap(String? categoryId) {
    if (selectedCategoryId == categoryId) return;
    FirebaseAnalytics.instance.logScreenView(screenName: categoryId);
    setState(() {
      selectedCategoryId = categoryId;
    });
    _loadCompanies();
  }

  /// 업소 상세 화면으로 이동
  void _handleCompanyTap(Company company) {
    CompanyViewScreen.push(context, company.idx);
  }

  /// 스크롤 시 헤더 숨김/표시 임계값
  static const double _headerHideThreshold = 48.0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      final currentOffset = notification.metrics.pixels;

      if (delta > 0 && currentOffset > _headerHideThreshold) {
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: ComicFab(
        onPressed: _handleCreateOrUpdateButton,
        tooltip: myCompany != null
            ? Lo.of(context)!.editMyCompany
            : Lo.of(context)!.addMyCompany,
        child: FaIcon(
          myCompany != null
              ? FontAwesomeIcons.penToSquare
              : FontAwesomeIcons.plus,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 카테고리 필터 칩 영역 (스크롤 시 접힘/펼침)
            ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              heightFactor: _showHeader ? 1.0 : 0.0,
              child: _buildHeader(theme, sp, categories),
            ),
          ),

          /// 내 업소 하이라이트 카드 (전체 필터 + 내 업소 존재 시)
          _buildMyCompanySection(theme, scheme, sp, categories),

          /// 업소 목록 (로딩/에러/빈/목록)
          Expanded(child: _buildBodyContent(theme, scheme, sp, categories)),
          ],
        ),
      ),
    );
  }

  /// 필터 칩 헤더 영역
  Widget _buildHeader(
    ThemeData theme,
    AppSpacing sp,
    List<CompanyCategory> categories,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(sp.s12, sp.s4, sp.s12, sp.s4),
      child: _buildWrappedFilters(categories, sp),
    );
  }

  /// 모든 카테고리를 Wrap으로 배치하는 필터 칩 영역
  Widget _buildWrappedFilters(List<CompanyCategory> categories, AppSpacing sp) {
    final items = [
      CompanyCategory(
        id: 'all',
        name: Lo.of(context)!.allCategories,
        description: '',
        icon: FontAwesomeIcons.lightLayerGroup,
      ),
      ...categories,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final spacing = sp.s4;

        // 한 줄에 6개 칩 배치 시도
        int chipsPerRow = 6;
        double chipSize =
            (availableWidth - (spacing * (chipsPerRow - 1))) / chipsPerRow;
        const minChipSize = 44.0;

        // 칩 크기가 너무 작으면 5개로 축소
        if (chipSize < minChipSize) {
          chipsPerRow = 5;
          chipSize =
              (availableWidth - (spacing * (chipsPerRow - 1))) / chipsPerRow;
        }

        // 그래도 작으면 4개로 축소
        if (chipSize < minChipSize) {
          chipsPerRow = 4;
          chipSize =
              (availableWidth - (spacing * (chipsPerRow - 1))) / chipsPerRow;
        }

        return Wrap(
          spacing: sp.s4,
          runSpacing: sp.s4,
          children: items.map((category) {
            final isAll = category.id == 'all';
            final isSelected = isAll
                ? selectedCategoryId == null
                : selectedCategoryId == category.id;

            return CompanyCategoryFilterChip(
              isSelected: isSelected,
              label: category.name,
              icon: category.icon,
              chipSize: chipSize,
              onTap: () =>
                  _handleCategoryFilterTap(isAll ? null : category.id),
            );
          }).toList(),
        );
      },
    );
  }

  /// 내 업소 하이라이트 섹션 (Best Practice 섹션 패턴)
  /// 전체 카테고리 필터 + 내 업소가 있을 때만 표시
  Widget _buildMyCompanySection(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    List<CompanyCategory> categories,
  ) {
    if (myCompany == null || selectedCategoryId != null) {
      return const SizedBox.shrink();
    }

    final category = _resolveCategory(categories, myCompany!.category);

    return Padding(
      padding: EdgeInsets.fromLTRB(sp.s16, sp.s16, sp.s16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 — 인디케이터 바 + 아이콘 + 타이틀
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                /// 인디케이터 바
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                FaIcon(
                  FontAwesomeIcons.lightBuilding,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  Lo.of(context)!.myCompanySection,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          /// 섹션 콘텐츠 컨테이너
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                /// 업소 정보 (이름 + 카테고리 태그)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myCompany!.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      /// 카테고리 태그
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              category.icon,
                              size: 10,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category.name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// 액션 버튼 (보기 + 수정)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 보기 버튼
                    IconButton(
                      onPressed: () =>
                          CompanyViewScreen.push(context, myCompany!.idx),
                      icon: FaIcon(
                        FontAwesomeIcons.lightEye,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      style: IconButton.styleFrom(
                        side: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// 수정 버튼
                    IconButton(
                      onPressed: _handleCreateOrUpdateButton,
                      icon: FaIcon(
                        FontAwesomeIcons.lightPenToSquare,
                        size: 16,
                        color: scheme.onPrimary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: scheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// 본문 콘텐츠 (로딩/에러/빈/목록 상태별 표시)
  Widget _buildBodyContent(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    List<CompanyCategory> categories,
  ) {
    /// 로딩 상태 — 스켈레톤 카드 + shimmer 이펙트
    if (isLoading) {
      return _buildSkeletonLoading(sp, scheme);
    }

    /// 에러 상태
    if (errorMessage != null) {
      return _wrapScrollable(
        ListView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: sp.s24,
            vertical: sp.s24,
          ),
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
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      );
    }

    /// 빈 상태
    if (companyList == null || companyList!.companies.isEmpty) {
      final categoryName = selectedCategoryId == null
          ? Lo.of(context)!.allCategories
          : categories
              .firstWhere((c) => c.id == selectedCategoryId)
              .name;

      return _wrapScrollable(
        Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: sp.s24,
              vertical: sp.s24,
            ),
            child: _buildStateMessage(
              scheme: scheme,
              theme: theme,
              sp: sp,
              icon: FontAwesomeIcons.lightBuildingCircleXmark,
              iconColor: scheme.onSurfaceVariant,
              title: T.noCompaniesFound,
              subtitle: selectedCategoryId == null
                  ? T.noRegisteredCompanies
                  : T.noCompaniesInCategory(categoryName),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),
        ),
      );
    }

    /// 업소 목록 — MasonryGrid + 순차 fadeIn 애니메이션
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
          )
              .animate()
              .fadeIn(
                duration: 400.ms,
                delay: (index.clamp(0, 8) * 80).ms,
              )
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  /// 스켈레톤 로딩 — 2컬럼 카드 6개 + shimmer 이펙트
  Widget _buildSkeletonLoading(AppSpacing sp, ColorScheme scheme) {
    /// 매이슨리 레이아웃 효과를 위한 다양한 높이
    const heights = [160.0, 200.0, 140.0, 180.0, 200.0, 160.0];

    return MasonryGridView.count(
      padding: EdgeInsets.fromLTRB(sp.s16, sp.s16, sp.s16, sp.s24),
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: sp.s12,
      crossAxisSpacing: sp.s12,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          height: heights[index],
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: 1200.ms,
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            );
      },
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

/// 카테고리 필터 칩 (Custom flat design)
/// 선택/미선택 상태에 따라 테두리+색상 변경
class CompanyCategoryFilterChip extends StatelessWidget {
  final bool isSelected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double chipSize;
  final EdgeInsetsGeometry? padding;

  const CompanyCategoryFilterChip({
    super.key,
    required this.isSelected,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.chipSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 선택 상태: 배경 없음, 오렌지 bold 아이콘/텍스트
    /// 미선택 상태: 배경 없음, 기본 색상
    const orangeColor = Color(0xFFFF6D00);
    final iconColor = isSelected ? orangeColor : scheme.onSurfaceVariant;
    final textColor = isSelected ? orangeColor : scheme.onSurface;
    final fontWeight = isSelected ? FontWeight.w700 : FontWeight.normal;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: chipSize,
          height: chipSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, size: 15, color: iconColor),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: fontWeight,
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
