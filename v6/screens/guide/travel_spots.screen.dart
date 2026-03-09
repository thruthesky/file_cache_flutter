import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/models/travel_spot.model.dart';
import 'package:philgo/screens/guide/travel_spot.view.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/services/travel/travel_spot.service.dart';
import 'package:philgo/state/navigation.state.dart';

/// 필리핀 여행 명소 화면 (Philippine Travel Spots Screen)
///
/// 필리핀의 여행 명소를 보여주는 화면입니다.
/// JSON 데이터를 로드하여 검색 가능한 여행 명소 목록을 표시합니다.
///
/// Screen showing Philippine travel spots.
/// Loads JSON data and displays searchable travel spots list.
class TravelSpotsScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/TravelSpots';

  /// push 네비게이션 (Push navigation)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 (Go navigation)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const TravelSpotsScreen({super.key});

  @override
  State<TravelSpotsScreen> createState() => _TravelSpotsScreenState();
}

class _TravelSpotsScreenState extends State<TravelSpotsScreen> {
  /// 검색어 컨트롤러 (Search query controller)
  final TextEditingController _searchController = TextEditingController();

  /// 현재 검색어 (Current search query)
  String _searchQuery = '';

  /// 여행 명소 목록 (Travel spots list)
  List<TravelSpot> _allSpots = [];

  /// 로딩 상태 (Loading state)
  bool _isLoading = true;

  /// 에러 메시지 (Error message)
  String? _errorMessage;

  /// 선택된 주(Province) 필터 (Selected province filter)
  String? _selectedProvince;

  /// 선택된 도시(City) 필터 (Selected city filter)
  String? _selectedCity;

  /// 선택된 분류(Category) 필터 (Selected category filter)
  String? _selectedCategory;

  /// 모든 주(Province) 목록 (All provinces list)
  List<String> get _allProvinces {
    final provinces = _allSpots.map((s) => s.province).toSet().toList();
    provinces.sort();
    return provinces;
  }

  /// 필터링된 도시 목록 - 선택된 주에 따라 필터링 (Filtered cities based on selected province)
  List<String> get _availableCities {
    var spots = _allSpots;
    if (_selectedProvince != null) {
      spots = spots.where((s) => s.province == _selectedProvince).toList();
    }
    final cities = spots.map((s) => s.city).toSet().toList();
    cities.sort();
    return cities;
  }

  /// 모든 분류(Category) 목록 (All categories list)
  List<String> get _allCategories {
    final categories = _allSpots.map((s) => s.category).toSet().toList();
    categories.sort();
    return categories;
  }

  @override
  void initState() {
    super.initState();
    _loadTravelSpots();
  }

  /// 여행 명소 데이터 로드 (Load travel spots data)
  ///
  /// TravelSpotService를 사용하여 데이터를 로드합니다.
  /// 1. 캐시 확인 → 유효한 캐시 사용
  /// 2. 캐시 없음 → 번들 파일 먼저 사용
  /// 3. 백그라운드에서 원격 다운로드
  /// 4. 다운로드 완료 시 화면 업데이트
  ///
  /// Uses TravelSpotService to load data.
  /// 1. Check cache → use if valid
  /// 2. No cache → use bundle first
  /// 3. Background remote download
  /// 4. Update UI on download completion
  Future<void> _loadTravelSpots() async {
    try {
      final spots = await TravelSpotService.instance.loadTravelSpots(
        /// 원격 데이터 다운로드 완료 시 화면 업데이트
        /// (Update UI when remote data download is complete)
        onRemoteDataUpdated: _onRemoteDataUpdated,
      );

      /// 가나다순 정렬 (Sort alphabetically)
      spots.sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _allSpots = spots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 원격 데이터 업데이트 콜백 (Remote data update callback)
  ///
  /// 백그라운드에서 원격 데이터 다운로드 완료 시 호출됩니다.
  /// 위젯이 마운트된 상태에서만 setState를 호출합니다.
  /// Called when remote data download is complete in background.
  /// Only calls setState if widget is still mounted.
  void _onRemoteDataUpdated(List<TravelSpot> spots) {
    if (!mounted) return;

    /// 가나다순 정렬 (Sort alphabetically)
    spots.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _allSpots = spots;
    });
  }

  /// 메뉴 화면으로 이동 (Navigate to Menu Screen)
  void _navigateToMenu() {
    context.pop();
    NavigationState.of(
      context,
      listen: false,
    ).setHomeNavigation(HomeNavigationItem.menu);
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

  /// 검색 및 필터링된 명소 목록 반환 (Returns filtered spots list)
  List<TravelSpot> get _filteredSpots {
    var spots = _allSpots;

    /// 주(Province) 필터 적용 (Apply province filter)
    if (_selectedProvince != null) {
      spots = spots.where((s) => s.province == _selectedProvince).toList();
    }

    /// 도시(City) 필터 적용 (Apply city filter)
    if (_selectedCity != null) {
      spots = spots.where((s) => s.city == _selectedCity).toList();
    }

    /// 분류(Category) 필터 적용 (Apply category filter)
    if (_selectedCategory != null) {
      spots = spots.where((s) => s.category == _selectedCategory).toList();
    }

    /// 검색어 필터 적용 (Apply search query filter)
    if (_searchQuery.isNotEmpty) {
      spots = spots.where((spot) => spot.matchesSearch(_searchQuery)).toList();
    }

    return spots;
  }

  /// 필터가 활성화되어 있는지 확인 (Check if any filter is active)
  bool get _hasActiveFilter =>
      _selectedProvince != null ||
      _selectedCity != null ||
      _selectedCategory != null;

  /// 모든 필터 초기화 (Clear all filters)
  void _clearAllFilters() {
    setState(() {
      _selectedProvince = null;
      _selectedCity = null;
      _selectedCategory = null;
    });
  }

  /// 카테고리별로 그룹화된 명소 반환 (Returns spots grouped by category)
  Map<String, List<TravelSpot>> get _spotsByCategory {
    final Map<String, List<TravelSpot>> grouped = {};
    for (final spot in _filteredSpots) {
      if (!grouped.containsKey(spot.category)) {
        grouped[spot.category] = [];
      }
      grouped[spot.category]!.add(spot);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.travelSpotsScreenTitle),
        actions: [
          /// 메뉴 아이콘 버튼 (Menu Icon Button)
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bars, size: 20),
            onPressed: _navigateToMenu,
            tooltip: l10n.menu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : _buildContent(l10n, theme, scheme),
    );
  }

  /// 콘텐츠 빌드 (Build content)
  /// CustomScrollView를 사용하여 효율적인 스크롤 성능 제공
  Widget _buildContent(Lo l10n, ThemeData theme, ColorScheme scheme) {
    return CustomScrollView(
      slivers: [
        /// 검색 창 (Search Field)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildSearchField(l10n, scheme),
          ),
        ),

        /// 검색 통계 표시 (Search statistics display)
        if (_searchQuery.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '${NumberFormat('#,###').format(_filteredSpots.length)}개 결과',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

        /// 검색 결과가 없을 때 (When no search results)
        if (_searchQuery.isNotEmpty && _filteredSpots.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildNoResults(l10n, theme, scheme),
            ),
          )
        else if (_searchQuery.isNotEmpty)
          /// 검색 중일 때 카테고리별로 분류 표시 (Show categorized results when searching)
          ..._buildSearchResultsSlivers(l10n, theme, scheme)
        else
          /// 기본 목록: 가나다순 명소 리스트 (Default: Alphabetical spots list)
          ..._buildAlphabeticalSpotsSlivers(l10n, theme, scheme),

        /// 하단 여백 (Bottom padding)
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
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
        hintText: l10n.searchHint,
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

  /// 검색 결과 Sliver 리스트 빌드 - 카테고리별 분류 (Build search results slivers - categorized)
  List<Widget> _buildSearchResultsSlivers(
    Lo l10n,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    final spotsByCategory = _spotsByCategory;
    final categories = spotsByCategory.keys.toList()..sort();
    final List<Widget> slivers = [];

    for (final category in categories) {
      /// 카테고리 헤더 (Category header)
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${spotsByCategory[category]!.length})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      /// 해당 카테고리의 명소들 (Spots in this category)
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final spot = spotsByCategory[category]![index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSpotCard(spot, theme, scheme),
              );
            },
            childCount: spotsByCategory[category]!.length,
          ),
        ),
      );
    }

    return slivers;
  }

  /// 명소 썸네일 빌드 (Build spot thumbnail)
  /// 이미지가 있으면 이미지를, 없으면 아이콘을 표시합니다.
  Widget _buildSpotThumbnail(TravelSpot spot, ColorScheme scheme) {
    if (spot.hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: spot.imageUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(spot.icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
        ),
      );
    }

    /// 이미지가 없으면 아이콘 표시 (Show icon if no image)
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(spot.icon, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  /// 명소 카드 빌드 (Build spot card)
  Widget _buildSpotCard(TravelSpot spot, ThemeData theme, ColorScheme scheme) {
    /// 매칭된 필드 가져오기 (Get matched fields)
    final matchedFields = spot.getMatchedFields(_searchQuery);

    /// Hero 태그 생성 (Generate Hero tag)
    final heroTag =
        spot.hasImage
            ? 'travel-spot-${spot.name}-image'
            : 'travel-spot-${spot.name}-icon';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            /// 명소 상세 화면으로 이동 (Navigate to spot detail screen)
            TravelSpotViewScreen.push(context, spot);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 썸네일 이미지 또는 아이콘 with Hero (Thumbnail image or icon with Hero)
                Hero(
                  tag: heroTag,
                  child: _buildSpotThumbnail(spot, scheme),
                ),

                const SizedBox(width: 12),

                /// 정보 (Information)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 이름 (Name)
                      Text(
                        spot.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      /// 영문 이름 (English name)
                      Text(
                        spot.englishName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// 제목/부제목 (Title)
                      Text(
                        spot.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// 위치 정보 (Location info)
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightLocationDot,
                            size: 10,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${spot.city}, ${spot.province}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      /// 매칭된 필드 표시 (Show matched fields)
                      if (_searchQuery.isNotEmpty &&
                          matchedFields.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: matchedFields.map((field) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getFieldDisplayName(field),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onTertiaryContainer,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                /// 화살표 아이콘 (Arrow icon)
                FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 카테고리별 이모지 반환 (Return emoji for category)
  ///
  /// 각 카테고리에 맞는 이모지를 반환합니다.
  /// contains를 사용하여 복합 카테고리도 매칭합니다.
  /// 매칭되지 않는 카테고리는 기본 이모지(📍)를 반환합니다.
  String _getCategoryEmoji(String category) {
    final lowerCategory = category.toLowerCase();

    /// 해변/섬 관련 (Beach/Island related)
    if (lowerCategory.contains('해변') || lowerCategory.contains('섬')) {
      return '🏝️';
    }

    /// 호수/강 관련 (Lake/River related)
    if (lowerCategory.contains('호수') || lowerCategory.contains('강')) {
      return '💧';
    }

    /// 산/화산 관련 (Mountain/Volcano related)
    if (lowerCategory.contains('산') || lowerCategory.contains('화산')) {
      return '🏔️';
    }

    /// 폭포 관련 (Waterfall related)
    if (lowerCategory.contains('폭포')) {
      return '💦';
    }

    /// 동굴 관련 (Cave related)
    if (lowerCategory.contains('동굴')) {
      return '🕳️';
    }

    /// 다이빙/스노클링 관련 (Diving/Snorkeling related)
    if (lowerCategory.contains('다이빙') || lowerCategory.contains('스노클링')) {
      return '🤿';
    }

    /// 서핑 관련 (Surfing related)
    if (lowerCategory.contains('서핑')) {
      return '🏄';
    }

    /// 동물원/사파리 관련 (Zoo/Safari related)
    if (lowerCategory.contains('동물원') || lowerCategory.contains('사파리')) {
      return '🦁';
    }

    /// 박물관/미술관 관련 (Museum/Art gallery related)
    if (lowerCategory.contains('박물관') || lowerCategory.contains('미술관')) {
      return '🖼️';
    }

    /// 역사 유적 관련 (Historical site related)
    if (lowerCategory.contains('역사') || lowerCategory.contains('유적')) {
      return '🏛️';
    }

    /// 교회/성당 관련 (Church/Cathedral related)
    if (lowerCategory.contains('교회') || lowerCategory.contains('성당')) {
      return '⛪';
    }

    /// 사원/절 관련 (Temple related)
    if (lowerCategory.contains('사원') || lowerCategory.contains('절')) {
      return '🛕';
    }

    /// 테마파크/놀이공원 관련 (Theme park related)
    if (lowerCategory.contains('테마파크') || lowerCategory.contains('놀이공원')) {
      return '🎢';
    }

    /// 쇼핑몰/쇼핑 관련 (Shopping mall related)
    if (lowerCategory.contains('쇼핑')) {
      return '🛍️';
    }

    /// 꽃 정원 관련 (Flower garden related)
    if (lowerCategory.contains('꽃') || lowerCategory.contains('정원')) {
      return '🌺';
    }

    /// 공원 관련 (Park related)
    if (lowerCategory.contains('공원')) {
      return '🌳';
    }

    /// 농장 관련 (Farm related)
    if (lowerCategory.contains('농장')) {
      return '🌾';
    }

    /// 온천/스파 관련 (Hot spring/Spa related)
    if (lowerCategory.contains('온천') || lowerCategory.contains('스파')) {
      return '♨️';
    }

    /// 전망대/뷰포인트 관련 (Viewpoint related)
    if (lowerCategory.contains('전망대') || lowerCategory.contains('뷰포인트')) {
      return '🔭';
    }

    /// 리조트/숙소 관련 (Resort/Accommodation related)
    if (lowerCategory.contains('리조트') || lowerCategory.contains('호텔')) {
      return '🏨';
    }

    /// 음식/맛집 관련 (Food related)
    if (lowerCategory.contains('음식') || lowerCategory.contains('맛집')) {
      return '🍽️';
    }

    /// 나이트라이프/바/클럽 관련 (Nightlife related)
    if (lowerCategory.contains('나이트') ||
        lowerCategory.contains('바') ||
        lowerCategory.contains('클럽')) {
      return '🌃';
    }

    /// 골프 관련 (Golf related)
    if (lowerCategory.contains('골프')) {
      return '⛳';
    }

    /// 카지노 관련 (Casino related)
    if (lowerCategory.contains('카지노')) {
      return '🎰';
    }

    /// 마사지 관련 (Massage related)
    if (lowerCategory.contains('마사지')) {
      return '💆';
    }

    /// 크루즈/보트 관련 (Cruise/Boat related)
    if (lowerCategory.contains('크루즈') || lowerCategory.contains('보트')) {
      return '🚢';
    }

    /// 자연/생태 관련 (Nature/Ecology related)
    if (lowerCategory.contains('자연') || lowerCategory.contains('생태')) {
      return '🌿';
    }

    /// 기본 이모지 (Default emoji)
    return '📍';
  }

  /// 필드 이름을 한글로 변환 (Convert field name to Korean)
  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'name':
        return '이름';
      case 'englishName':
        return '영문명';
      case 'title':
        return '제목';
      case 'description':
        return '설명';
      case 'city':
        return '도시';
      case 'province':
        return '지역';
      case 'category':
        return '카테고리';
      default:
        return field;
    }
  }

  /// 가나다순 명소 Sliver 리스트 빌드 (Build alphabetical spots sliver list)
  List<Widget> _buildAlphabeticalSpotsSlivers(
    Lo l10n,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    final spots = _filteredSpots;

    return [
      /// 필터 옵션 섹션 (Filter options section)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 필터 드롭다운들 (Filter dropdowns)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  /// 주(Province) 필터 (Province filter)
                  _buildFilterDropdown(
                    label: '주(Province)',
                    value: _selectedProvince,
                    items: _allProvinces,
                    onChanged: (value) {
                      setState(() {
                        _selectedProvince = value;
                        /// 주가 변경되면 도시 필터 초기화 (Reset city when province changes)
                        _selectedCity = null;
                      });
                    },
                    theme: theme,
                    scheme: scheme,
                  ),

                  /// 도시(City) 필터 (City filter)
                  _buildFilterDropdown(
                    label: '도시(City)',
                    value: _selectedCity,
                    items: _availableCities,
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    theme: theme,
                    scheme: scheme,
                  ),

                  /// 분류(Category) 필터 (Category filter)
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
                    emojiGetter: _getCategoryEmoji,
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
              ),

              const SizedBox(height: 8),

              /// 명소 개수 표시 (Show spot count)
              Text(
                '총 ${NumberFormat('#,###').format(spots.length)}개의 여행 명소',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),

      /// 가나다순 여행 명소 리스트 (Alphabetical Travel Spots List)
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final spot = spots[index];

            /// Hero 태그 생성 (Generate Hero tag)
            final heroTag =
                spot.hasImage
                    ? 'travel-spot-${spot.name}-image'
                    : 'travel-spot-${spot.name}-icon';

            return ListTile(
              /// 썸네일 이미지 또는 아이콘 with Hero (Thumbnail image or icon with Hero)
              leading: Hero(
                tag: heroTag,
                child: _buildSpotThumbnail(spot, scheme),
              ),

              /// 제목: 명소 이름 (Title: Spot name)
              title: Text(
                spot.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

              /// 설명과 지역/도시 (Subtitle: Description and Province/City)
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 설명 (Description)
                  Text(
                    spot.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  /// 지역과 도시 (Province and City)
                  Text(
                    '${spot.province}, ${spot.city}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                    ),
                  ),
                ],
              ),

              /// 오른쪽 화살표 아이콘 (Trailing arrow icon)
              trailing: FaIcon(
                FontAwesomeIcons.lightChevronRight,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),

              /// 탭 시 상세 화면으로 이동 (Navigate to detail screen on tap)
              onTap: () {
                TravelSpotViewScreen.push(context, spot);
              },

              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            );
          },
          childCount: spots.length,
        ),
      ),
    ];
  }

  /// 필터 드롭다운 위젯 빌드 (Build filter dropdown widget)
  ///
  /// [emojiGetter] 파라미터가 제공되면 각 아이템 앞에 이모지를 표시합니다.
  /// If [emojiGetter] is provided, displays emoji before each item.
  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
    required ColorScheme scheme,
    String Function(String)? emojiGetter,
  }) {
    /// 이모지 크기 (Emoji size)
    const double emojiSize = 18;

    /// 이모지가 포함된 텍스트 위젯 생성 (Build text widget with emoji)
    Widget buildItemWithEmoji(String item, Color textColor) {
      if (emojiGetter != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emojiGetter(item),
              style: const TextStyle(fontSize: emojiSize),
            ),
            const SizedBox(width: 6),
            Text(
              item,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
              ),
            ),
          ],
        );
      }
      return Text(
        item,
        style: theme.textTheme.labelMedium?.copyWith(
          color: textColor,
        ),
      );
    }

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
          /// 선택된 값 표시 (Display selected value)
          selectedItemBuilder: emojiGetter != null
              ? (context) {
                  return [
                    /// 전체 옵션 (All option)
                    Text(
                      '$label 전체',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    /// 각 아이템 (Each item)
                    ...items.map(
                      (item) => buildItemWithEmoji(
                        item,
                        scheme.onPrimaryContainer,
                      ),
                    ),
                  ];
                }
              : null,
          icon: FaIcon(
            FontAwesomeIcons.lightChevronDown,
            size: 12,
            color: value != null
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
          isDense: true,
          style: theme.textTheme.labelMedium?.copyWith(
            color: value != null
                ? scheme.onPrimaryContainer
                : scheme.onSurface,
          ),
          dropdownColor: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          items: [
            /// 전체 옵션 (All option)
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                '$label 전체',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            /// 각 아이템 (Each item)
            ...items.map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: buildItemWithEmoji(item, scheme.onSurface),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
