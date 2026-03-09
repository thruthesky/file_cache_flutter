import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/models/festival.model.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 축제 정보 화면 (Festival Screen)
///
/// 필리핀 축제 관련 정보를 제공합니다.
/// 마닐라, 세부, 팜팡가 중심의 축제 정보를 월별/지역별로 검색할 수 있습니다.
///
/// Provides information about festivals in the Philippines.
/// Search festivals in Manila, Cebu, Pampanga by month or region.
///
/// ### 사용법 (Usage):
/// ```dart
/// FestivalScreen.push(context);
/// ```
class FestivalScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Festival';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const FestivalScreen({super.key});

  @override
  State<FestivalScreen> createState() => _FestivalScreenState();
}

class _FestivalScreenState extends State<FestivalScreen> {
  /// 검색어 컨트롤러 (Search query controller)
  final TextEditingController _searchController = TextEditingController();

  /// 현재 검색어 (Current search query)
  String _searchQuery = '';

  /// 축제 목록 (Festival list)
  List<Festival> _allFestivals = [];

  /// 로딩 상태 (Loading state)
  bool _isLoading = true;

  /// 에러 메시지 (Error message)
  String? _errorMessage;

  /// 선택된 지역 필터 (Selected region filter)
  String? _selectedRegion;

  /// 선택된 월 필터 (Selected month filter)
  int? _selectedMonth;

  /// 선택된 카테고리 필터 (Selected category filter)
  String? _selectedCategory;

  /// 참고 URL 목록 (Reference URLs)
  static const List<Map<String, String>> _referenceUrls = [
    {
      'title': 'Annual events in Metro Manila',
      'url': 'https://en.wikipedia.org/wiki/Annual_events_in_Metro_Manila',
    },
    {
      'title': 'List of festivals in the Philippines',
      'url': 'https://en.wikipedia.org/wiki/List_of_festivals_in_the_Philippines',
    },
    {
      'title': 'Sinulog Festival',
      'url': 'https://sinulogfestival.com/',
    },
    {
      'title': 'Giant Lantern Festival',
      'url': 'https://en.wikipedia.org/wiki/Giant_Lantern_Festival',
    },
    {
      'title': 'Festivals of Cebu',
      'url': 'https://en.wikipedia.org/wiki/Festivals_of_Cebu',
    },
  ];

  /// 모든 지역 목록 (All regions list)
  List<String> get _allRegions {
    final regions = _allFestivals.map((f) => f.region).toSet().toList();
    regions.sort();
    return regions;
  }

  /// 모든 카테고리 목록 (All categories list)
  List<String> get _allCategories {
    final categories = _allFestivals.map((f) => f.category).toSet().toList();
    categories.sort();
    return categories;
  }

  @override
  void initState() {
    super.initState();
    _loadFestivals();
  }

  /// JSON 파일에서 축제 데이터 로드 (Load festival data from JSON file)
  Future<void> _loadFestivals() async {
    try {
      final jsonString = await rootBundle.loadString(
        'lib/philgo_files/festival/festivals.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      final festivals =
          jsonList.map((json) => Festival.fromJson(json)).toList();

      /// 월별, 이름순 정렬 (Sort by month, then name)
      festivals.sort((a, b) {
        final monthCompare = a.month.compareTo(b.month);
        if (monthCompare != 0) return monthCompare;
        return a.name.compareTo(b.name);
      });

      setState(() {
        _allFestivals = festivals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 검색어 변경 핸들러 (Search query change handler)
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
  }

  /// 검색어 초기화 (Clear search query)
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  /// 검색 및 필터링된 축제 목록 반환 (Returns filtered festivals list)
  List<Festival> get _filteredFestivals {
    var festivals = _allFestivals;

    /// 지역 필터 적용 (Apply region filter)
    if (_selectedRegion != null) {
      festivals = festivals.where((f) => f.region == _selectedRegion).toList();
    }

    /// 월 필터 적용 (Apply month filter)
    if (_selectedMonth != null) {
      festivals = festivals.where((f) => f.month == _selectedMonth).toList();
    }

    /// 카테고리 필터 적용 (Apply category filter)
    if (_selectedCategory != null) {
      festivals =
          festivals.where((f) => f.category == _selectedCategory).toList();
    }

    /// 검색어 필터 적용 (Apply search query filter)
    if (_searchQuery.isNotEmpty) {
      festivals =
          festivals.where((f) => f.matchesSearch(_searchQuery)).toList();
    }

    return festivals;
  }

  /// 필터가 활성화되어 있는지 확인 (Check if any filter is active)
  bool get _hasActiveFilter =>
      _selectedRegion != null ||
      _selectedMonth != null ||
      _selectedCategory != null;

  /// 모든 필터 초기화 (Clear all filters)
  void _clearAllFilters() {
    setState(() {
      _selectedRegion = null;
      _selectedMonth = null;
      _selectedCategory = null;
    });
  }

  /// URL 열기 (Open URL)
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightPartyHorn,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentFestival,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _buildContent(l10n, theme, scheme, sp),
    );
  }

  /// 콘텐츠 빌드 (Build content)
  Widget _buildContent(
    Lo l10n,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return CustomScrollView(
      slivers: [
        /// 축제 문화 소개 섹션 (Festival Culture Introduction Section)
        SliverToBoxAdapter(
          child: _buildIntroSection(theme, scheme, sp),
        ),

        /// 이용 안내 섹션 (Usage Guide Section)
        SliverToBoxAdapter(
          child: _buildUsageGuideSection(theme, scheme, sp),
        ),

        /// 검색 창 (Search Field)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(sp.s16, sp.s16, sp.s16, sp.s8),
            child: _buildSearchField(l10n, scheme),
          ),
        ),

        /// 필터 옵션 섹션 (Filter Options Section)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(sp.s16, 0, sp.s16, sp.s8),
            child: _buildFilters(theme, scheme),
          ),
        ),

        /// 검색 통계 표시 (Search statistics display)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(sp.s16, 0, sp.s16, sp.s8),
            child: Text(
              '총 ${_filteredFestivals.length}개의 축제',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),

        /// 축제 목록 (Festival List)
        if (_filteredFestivals.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sp.s16),
              child: _buildNoResults(l10n, theme, scheme),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final festival = _filteredFestivals[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: sp.s16),
                  child: _buildFestivalCard(festival, theme, scheme, sp),
                );
              },
              childCount: _filteredFestivals.length,
            ),
          ),

        /// 참고 URL 섹션 (Reference URLs Section)
        SliverToBoxAdapter(
          child: _buildReferenceSection(theme, scheme, sp),
        ),

        /// 하단 여백 (Bottom padding)
        SliverToBoxAdapter(
          child: SizedBox(height: sp.s32),
        ),
      ],
    );
  }

  /// 축제 문화 소개 섹션 빌드 (Build festival culture intro section)
  Widget _buildIntroSection(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return Container(
      margin: EdgeInsets.all(sp.s16),
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 제목 (Section Title)
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightBookOpen,
                size: 18,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '필리핀 축제 문화',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),

          /// 설명 텍스트 (Description text)
          Text(
            '필리핀의 축제는 통상 피에스타(Fiesta)로 불리며, 스페인 식민지기 이후 '
            '가톨릭 성인(수호성인) 축일과 지역 공동체 행사가 결합된 형태가 널리 확산되어 왔습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '지역 역사 기념, 수확·특산물 홍보, 전통공연·퍼레이드, 미사·행렬, 장터(바자) 등이 함께 운영됩니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),

          /// 주의 사항 (Notice)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 16,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '행사 일정은 해마다 지방정부(LGU), 성당·성지 공지, 축제 운영재단 공지에 따라 '
                    '세부 일정이 조정될 수 있으므로 참여 전 확인이 필요합니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 이용 안내 섹션 빌드 (Build usage guide section)
  Widget _buildUsageGuideSection(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sp.s16),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.lightMapLocationDot,
              size: 18,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ),
        title: Text(
          '당일/1회 이용 안내',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '필리핀 체류 중 축제 참여 방법',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        children: [
          Container(
            padding: EdgeInsets.all(sp.s16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 일정 확인 (Schedule check)
                _buildGuideItem(
                  theme,
                  scheme,
                  sp,
                  FontAwesomeIcons.lightCalendarCheck,
                  '일정 확인',
                  '도시/주 공식 홈페이지·SNS, 축제 운영 재단 페이지, '
                      '대성당/성지 공지, 관광안내소·시청 안내부스 확인',
                ),
                SizedBox(height: sp.s12),

                /// 이동 (Transportation)
                _buildGuideItem(
                  theme,
                  scheme,
                  sp,
                  FontAwesomeIcons.lightCarSide,
                  '이동',
                  '메트로 마닐라: 철도(MRT/LRT)+도보 권장 (도로 통제 잦음)\n'
                      '세부: 시내 도로 통제 빈번, 외곽 하차 후 도보 접근\n'
                      '팜팡가: 도시 간 차량 이동 필요',
                ),
                SizedBox(height: sp.s12),

                /// 비용 (Cost)
                _buildGuideItem(
                  theme,
                  scheme,
                  sp,
                  FontAwesomeIcons.lightMoneyBill,
                  '비용',
                  '거리 퍼레이드·피에스타: 대부분 무료 관람 (교통·식음료 비용)\n'
                      '유료 관람석/행사장: 티켓/좌석권 구매 필요\n'
                      '야시장·바자: 현금·전자결제 혼용',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 이용 안내 항목 빌드 (Build guide item)
  Widget _buildGuideItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: FaIcon(icon, size: 14, color: scheme.onPrimaryContainer),
          ),
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: sp.s4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 검색 필드 빌드 (Build search field)
  Widget _buildSearchField(Lo l10n, ColorScheme scheme) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: '축제명, 지역, 카테고리 검색',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: FaIcon(
            FontAwesomeIcons.lightMagnifyingGlass,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.lightXmark,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                onPressed: _clearSearch,
              )
            : null,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// 필터 옵션 빌드 (Build filter options)
  Widget _buildFilters(ThemeData theme, ColorScheme scheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        /// 지역 필터 (Region filter)
        _buildFilterDropdown(
          label: '지역',
          value: _selectedRegion,
          items: _allRegions,
          onChanged: (value) {
            setState(() {
              _selectedRegion = value;
            });
          },
          theme: theme,
          scheme: scheme,
        ),

        /// 월 필터 (Month filter)
        _buildMonthFilterDropdown(theme, scheme),

        /// 카테고리 필터 (Category filter)
        _buildFilterDropdown(
          label: '분류',
          value: _selectedCategory,
          items: _allCategories,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          theme: theme,
          scheme: scheme,
        ),

        /// 필터 초기화 버튼 (Clear filters button)
        if (_hasActiveFilter)
          ActionChip(
            avatar: FaIcon(
              FontAwesomeIcons.lightXmark,
              size: 12,
              color: scheme.error,
            ),
            label: Text(
              '초기화',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.error,
              ),
            ),
            backgroundColor: scheme.errorContainer.withValues(alpha: 0.3),
            side: BorderSide.none,
            onPressed: _clearAllFilters,
          ),
      ],
    );
  }

  /// 문자열 필터 드롭다운 빌드 (Build string filter dropdown)
  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: value != null
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          icon: FaIcon(
            FontAwesomeIcons.lightChevronDown,
            size: 12,
            color: value != null
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
          isDense: true,
          style: theme.textTheme.labelMedium?.copyWith(
            color: value != null ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
          dropdownColor: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                '$label 전체',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// 월 필터 드롭다운 빌드 (Build month filter dropdown)
  Widget _buildMonthFilterDropdown(ThemeData theme, ColorScheme scheme) {
    final monthNames = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _selectedMonth != null
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMonth,
          hint: Text(
            '월',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          icon: FaIcon(
            FontAwesomeIcons.lightChevronDown,
            size: 12,
            color: _selectedMonth != null
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
          isDense: true,
          style: theme.textTheme.labelMedium?.copyWith(
            color: _selectedMonth != null
                ? scheme.onPrimaryContainer
                : scheme.onSurface,
          ),
          dropdownColor: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text(
                '월 전체',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            ...List.generate(
              12,
              (index) => DropdownMenuItem<int>(
                value: index + 1,
                child: Text(
                  monthNames[index],
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedMonth = value;
            });
          },
        ),
      ),
    );
  }

  /// 검색 결과 없음 UI (No search results UI)
  Widget _buildNoResults(Lo l10n, ThemeData theme, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.lightMagnifyingGlass,
            size: 32,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.searchNoResults,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 축제 카드 빌드 (Build festival card)
  Widget _buildFestivalCard(
    Festival festival,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    /// 카테고리별 아이콘 매핑 (Category icon mapping)
    IconData getCategoryIcon() {
      switch (festival.category) {
        case '종교':
          return FontAwesomeIcons.lightChurch;
        case '문화':
          return FontAwesomeIcons.lightMasksTheater;
        case '음악':
          return FontAwesomeIcons.lightMusic;
        case '음식':
          return FontAwesomeIcons.lightUtensils;
        case '영화':
          return FontAwesomeIcons.lightFilm;
        case '역사':
          return FontAwesomeIcons.lightLandmarkDome;
        case '기념일':
          return FontAwesomeIcons.lightFlag;
        case '성탄':
          return FontAwesomeIcons.lightGift;
        case '박람회':
          return FontAwesomeIcons.lightStore;
        default:
          return FontAwesomeIcons.lightPartyHorn;
      }
    }

    /// 카테고리별 색상 (Category color)
    Color getCategoryColor() {
      switch (festival.category) {
        case '종교':
          return Colors.purple;
        case '문화':
          return Colors.orange;
        case '음악':
          return Colors.pink;
        case '음식':
          return Colors.green;
        case '영화':
          return Colors.red;
        case '역사':
          return Colors.brown;
        case '기념일':
          return Colors.blue;
        case '성탄':
          return Colors.red;
        case '박람회':
          return Colors.teal;
        default:
          return scheme.primary;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: sp.s8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(sp.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 월 표시 (Month badge)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    festival.month == 0 ? '연중' : '${festival.month}월',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sp.s12),

            /// 축제 정보 (Festival info)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 축제명 (Festival name)
                  Text(
                    festival.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  /// 영문명 (English name)
                  if (festival.englishName.isNotEmpty &&
                      festival.englishName != festival.name)
                    Text(
                      festival.englishName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                  SizedBox(height: sp.s4),

                  /// 위치 정보 (Location info)
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightLocationDot,
                        size: 10,
                        color: scheme.onSurfaceVariant,
                      ),
                      SizedBox(width: sp.s4),
                      Expanded(
                        child: Text(
                          '${festival.location} (${festival.region})',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: sp.s4),

                  /// 비고 및 카테고리 (Note and category)
                  Row(
                    children: [
                      /// 카테고리 뱃지 (Category badge)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s8,
                          vertical: sp.s4,
                        ),
                        decoration: BoxDecoration(
                          color: getCategoryColor().withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              getCategoryIcon(),
                              size: 10,
                              color: getCategoryColor(),
                            ),
                            SizedBox(width: sp.s4),
                            Text(
                              festival.category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: getCategoryColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: sp.s8),

                      /// 비고 (Note)
                      if (festival.note.isNotEmpty)
                        Expanded(
                          child: Text(
                            festival.note,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 참고 URL 섹션 빌드 (Build reference URLs section)
  Widget _buildReferenceSection(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(sp.s16, sp.s24, sp.s16, 0),
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 제목 (Section title)
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightLink,
                size: 16,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '참고 자료',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),

          /// URL 목록 (URL list)
          ...List.generate(
            _referenceUrls.length,
            (index) => InkWell(
              onTap: () => _openUrl(_referenceUrls[index]['url']!),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: sp.s4),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightArrowUpRightFromSquare,
                      size: 12,
                      color: scheme.primary,
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        _referenceUrls[index]['title']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
