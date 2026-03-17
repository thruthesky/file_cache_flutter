import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/company/edit/company.edit.screen.dart';
import 'package:philgo/company/widgets/company.card.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/view/company.view.screen.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  List<CompanyModel> _companies = [];
  CompanyModel? _myCompany;
  bool _isLoading = true;
  bool _isFabLoading = false;
  String? _selectedCategoryId; // null = All
  bool _showHeader = true;

  static const _headerHideThreshold = 48.0;

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

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        CompanyService.list(category: _selectedCategoryId),
        CompanyService.mine().catchError((_) => null),
      ]);
      if (mounted) {
        final companies = results[0] as List<CompanyModel>;
        setState(() {
          _companies = companies;
          _myCompany = results[1] as CompanyModel?;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _companies = []);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);
    try {
      final companies = await CompanyService.list(
        category: _selectedCategoryId,
      );
      if (mounted) {
        setState(() => _companies = companies);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _companies = []);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _loadCompanies();
  }

  Future<void> _onFabPressed() async {
    if (_isFabLoading) return;

    // Use cached company — no extra API call needed
    if (_myCompany != null) {
      CompanyEditScreen.push(context, company: _myCompany!);
      return;
    }

    // Fallback: fetch if initState mine() failed
    setState(() => _isFabLoading = true);
    try {
      final company = await CompanyService.mine();
      if (!mounted) return;

      if (company == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업소를 가져올 수 없습니다. 다시 시도해주세요.'.tr())),
        );
        return;
      }

      setState(() => _myCompany = company);

      if (company.name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업소가 생성되었습니다. 정보를 입력해주세요.'.tr()),
            backgroundColor: const Color(0xFFFF6D00),
          ),
        );
      }

      CompanyEditScreen.push(context, company: company);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isFabLoading = false);
    }
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'company_list_fab',
        onPressed: _isFabLoading ? null : _onFabPressed,
        child: _isFabLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const FaIcon(FontAwesomeIcons.penToSquare),
      ),
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
            // Company list
            Expanded(child: _buildBody(scheme)),
          ],
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

  Widget _buildBody(ColorScheme scheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.buildingCircleXmark, size: 48),
            const SizedBox(height: 16),
            Text('등록된 업소가 없습니다'.tr()),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(8),
        physics: const ClampingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _companies.length,
        itemBuilder: (context, index) {
          final company = _companies[index];
          // Vary heights for staggered effect based on image presence
          final hasImage = company.primaryImageUrl.isNotEmpty;
          final height = hasImage ? (index.isEven ? 220.0 : 180.0) : 140.0;
          return SizedBox(
            height: height,
            child: CompanyCard(
              company: company,
              onTap: () => CompanyViewScreen.push(context, company: company),
            ),
          );
        },
      ),
    );
  }
}
