import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/common_widgets/app_masonry_grid.dart';
import 'package:philgo/common_widgets/masonry_card.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/view/company.view.screen.dart';
class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  String? _selectedCategoryId; // null = All
  bool _showHeader = true;

  static const _headerHideThreshold = 48.0;
  static const _pageSize = 20;

  static const _categories = [
    ('public-office', '관공서', FontAwesomeIcons.building),
    ('education', '교육', FontAwesomeIcons.graduationCap),
    ('food', '음식', FontAwesomeIcons.utensils),
    ('transport', '교통', FontAwesomeIcons.bus),
    ('hospital', '병원', FontAwesomeIcons.hospital),
    ('mart', '마트', FontAwesomeIcons.cartShopping),
    ('bank', '은행', FontAwesomeIcons.buildingColumns),
    ('gadget', '전자기기', FontAwesomeIcons.mobileScreen),
    ('travel-agency', '여행사', FontAwesomeIcons.planeDeparture),
    ('hotel', '호텔', FontAwesomeIcons.hotel),
    ('rentcar', '렌터카', FontAwesomeIcons.car),
    ('beauty', '뷰티', FontAwesomeIcons.scissors),
    ('real-estate', '부동산', FontAwesomeIcons.houseChimney),
    ('ktv', '유흥', FontAwesomeIcons.microphone),
    ('spa', '스파', FontAwesomeIcons.spa),
    ('etc', '기타', FontAwesomeIcons.ellipsis),
  ];

  late final PagingController<int, CompanyModel> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, CompanyModel>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        final keys = state.keys;
        if (keys == null || keys.isEmpty) return 1;
        return keys.last + 1;
      },
      fetchPage: _fetchPage,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<CompanyModel>> _fetchPage(int page) async {
    final result = await CompanyService.list(
      category: _selectedCategoryId,
      status: 'a',
      page: page,
      limit: _pageSize,
    );
    if (page > 1 && result.items.isEmpty) return [];
    return result.items;
  }

  void _onCategorySelected(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _pagingController.refresh();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      final offset = notification.metrics.pixels;
      if (delta > 0 && offset > _headerHideThreshold) {
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

    return Scaffold(
      backgroundColor: scheme.surface,
      // FAB는 AppScreen에서 통합 관리
      body: SafeArea(
        child: Column(
          children: [
            // Category filter header — hides on scroll down
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                heightFactor: _showHeader ? 1.0 : 0.0,
                child: _buildHeader(scheme),
              ),
            ),
            const Divider(height: 1),
            // 업소 목록
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: AppMasonryGrid<CompanyModel>(
                  pagingController: _pagingController,
                  itemBuilder: (context, company, index) {
                    return MasonryCard(
                      imageUrl: company.primaryImageUrl.isNotEmpty
                          ? company.primaryImageUrl
                          : null,
                      title: company.name.isNotEmpty
                          ? company.name
                          : '(이름 없음)'.tr(),
                      onTap: () => CompanyViewScreen.push(
                        context,
                        company: company,
                      ),
                      placeholder: _buildCompanyPlaceholder(company),
                      defaultHeight:
                          company.primaryImageUrl.isNotEmpty ? 200 : 140,
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (index.clamp(0, 8) * 80).ms,
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 400.ms,
                          delay: (index.clamp(0, 8) * 80).ms,
                        );
                  },
                  emptyBuilder: (_) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.buildingCircleXmark,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text('등록된 업소가 없습니다'.tr()),
                      ],
                    ),
                  ),
                  errorBuilder: (_) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('업소를 가져올 수 없습니다. 다시 시도해주세요.'.tr()),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _pagingController.refresh(),
                          child: Text('다시 시도'.tr()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지가 없는 업소 카드의 플레이스홀더 (그라디언트 + 카테고리 아이콘)
  Widget _buildCompanyPlaceholder(CompanyModel company) {
    final scheme = Theme.of(context).colorScheme;
    final icon = _categories
            .where((c) => c.$1 == company.category)
            .map((c) => c.$3)
            .firstOrNull ??
        FontAwesomeIcons.buildingColumns;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: FaIcon(
          icon,
          size: 48,
          color: scheme.onPrimaryContainer.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 2.0;
          const chipsPerRow = 6;
          final chipSize =
              (constraints.maxWidth - spacing * (chipsPerRow - 1)) /
              chipsPerRow;

          // All + 16 categories = 17 items
          final items = <(String?, String, IconData)>[
            (null, '전체'.tr(), FontAwesomeIcons.layerGroup),
            ..._categories.map((c) => (c.$1, c.$2.tr(), c.$3)),
          ];

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: items.map((item) {
              final (id, label, icon) = item;
              final isSelected = _selectedCategoryId == id;
              const selectedColor = Color(0xFFFF6D00);

              return InkWell(
                onTap: () => _onCategorySelected(id),
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: chipSize,
                  height: chipSize,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        icon,
                        size: 15,
                        color: isSelected
                            ? selectedColor
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? selectedColor
                                : scheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
