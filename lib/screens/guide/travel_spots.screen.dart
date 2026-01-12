import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/data/travel_destination_menu.data.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/info/travel_destination/el_nido.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/widgets/home/menu/menu.grid_item.dart';
import 'package:philgo/widgets/home/menu/menu.grid_section.dart';

/// 필리핀 여행 명소 인기순 화면 (Philippine Travel Spots by Popularity Screen)
///
/// 필리핀의 인기 여행 명소를 인기순으로 보여주는 화면입니다.
/// TravelDestinationMenuData를 사용하여 여행지 목록을 표시합니다.
///
/// Screen showing popular Philippine travel spots sorted by popularity.
/// Uses TravelDestinationMenuData to display travel destination list.
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

  /// 메뉴 화면으로 이동 (Navigate to Menu Screen)
  ///
  /// 현재 화면을 닫고 홈으로 돌아간 후 메뉴 탭으로 이동합니다.
  /// Closes current screen, returns to home, and navigates to menu tab.
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

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 필터링된 아이템 목록 (Filtered items list)
    final filteredItems = _getFilteredItems(l10n);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 검색 창 (Search Field)
            /// 사용자가 여행지를 검색할 수 있는 입력 필드입니다.
            /// Input field for users to search travel destinations.
            TextField(
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
            ),

            const SizedBox(height: 16),

            /// 검색 결과가 없을 때 (When no search results)
            if (_searchQuery.isNotEmpty && filteredItems.isEmpty)
              Container(
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
              )
            else ...[
              /// 검색어가 없을 때만 안내 박스와 엘니도 카드 표시
              /// Show guide box and El Nido card only when no search query
              if (_searchQuery.isEmpty) ...[
                /// 인기순 안내 텍스트 (Popularity ranking guide text)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    /// 배경색: secondaryContainer (Theme 기반)
                    /// Background color: secondaryContainer (Theme-based)
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      /// 트로피 아이콘 (Trophy icon)
                      FaIcon(
                        FontAwesomeIcons.lightTrophy,
                        size: 20,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 12),

                      /// 안내 텍스트 (Guide text)
                      Expanded(
                        child: Text(
                          l10n.travelSpotsScreenTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// 엘니도 추천 카드 (El Nido Featured Card)
                /// 상단에 엘니도를 강조하여 표시하는 클릭 가능한 카드
                /// Clickable card featuring El Nido at the top
                InkWell(
                  onTap: () => ElNidoScreen.push(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      /// 배경색: surfaceContainerHighest (Theme 기반)
                      /// Background color: surfaceContainerHighest (Theme-based)
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        /// 엘니도 아이콘 (El Nido icon)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.lightIslandTropical,
                              size: 24,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        /// 엘니도 텍스트 정보 (El Nido text info)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 엘니도 제목 (El Nido title)
                              Text(
                                l10n.travelDestinationElNido,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),

                              /// 엘니도 설명 (El Nido description)
                              Text(
                                l10n.travelDestinationElNidoDescription,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        /// 화살표 아이콘 (Arrow icon)
                        FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],

              /// 필리핀 추천 여행지 섹션 (Philippine Travel Destination Section)
              /// TravelDestinationMenuData를 사용하여 메뉴 아이템 생성
              /// 인기순으로 정렬되어 있음 (보라카이, 세부, 팔라완, 보홀, 마닐라, 수빅)
              ///
              /// Uses TravelDestinationMenuData to create menu items
              /// Sorted by popularity (Boracay, Cebu, Palawan, Bohol, Manila, Subic)
              MenuGridSection(
                title: _searchQuery.isNotEmpty
                    ? l10n.searchResults
                    : l10n.travelDestinationSection,
                children: filteredItems.isEmpty
                    ? _getPopularitySortedItems(l10n)
                    : filteredItems,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 검색어로 필터링된 여행지 아이템 목록 반환
  /// Returns travel destination items filtered by search query
  List<Widget> _getFilteredItems(Lo l10n) {
    if (_searchQuery.isEmpty) {
      return [];
    }

    /// 인기 순서대로 라벨을 정의 (Define labels in popularity order)
    final popularityOrder = [
      l10n.travelDestinationBoracay,
      l10n.travelDestinationCebu,
      l10n.travelDestinationElNido,
      l10n.travelDestinationPalawan,
      l10n.travelDestinationBohol,
      l10n.travelDestinationManila,
      l10n.travelDestinationSubic,
    ];

    /// 검색어로 필터링 (Filter by search query)
    final filteredItems = TravelDestinationMenuData.items.where((item) {
      final label = item.getLabel(l10n).toLowerCase();
      return label.contains(_searchQuery);
    }).toList();

    /// 인기순으로 정렬 (Sort by popularity)
    filteredItems.sort((a, b) {
      final aIndex = popularityOrder.indexOf(a.getLabel(l10n));
      final bIndex = popularityOrder.indexOf(b.getLabel(l10n));
      return aIndex.compareTo(bIndex);
    });

    /// 필터링된 아이템들을 위젯으로 변환 (Convert filtered items to widgets)
    return filteredItems
        .map(
          (item) => MenuGridItem(
            icon: item.icon,
            title: item.getLabel(l10n),
            onTap: () => item.push(context),
          ),
        )
        .toList();
  }

  /// 인기순으로 정렬된 여행지 아이템 목록 반환
  /// Returns travel destination items sorted by popularity
  ///
  /// 인기 순위 (Popularity ranking):
  /// 1. 보라카이 (Boracay) - 세계적으로 유명한 화이트 비치
  /// 2. 세부 (Cebu) - 한국인에게 가장 인기 있는 여행지
  /// 3. 엘니도 (El Nido) - 라군과 카르스트 절벽으로 유명
  /// 4. 팔라완 (Palawan) - 세계에서 가장 아름다운 섬
  /// 5. 보홀 (Bohol) - 초콜릿 힐과 안경원숭이로 유명
  /// 6. 마닐라 (Manila) - 수도이자 관문 도시
  /// 7. 수빅 (Subic) - 해양 스포츠와 면세 쇼핑
  List<Widget> _getPopularitySortedItems(Lo l10n) {
    /// 인기 순서대로 라벨을 정의 (Define labels in popularity order)
    final popularityOrder = [
      l10n.travelDestinationBoracay,
      l10n.travelDestinationCebu,
      l10n.travelDestinationElNido,
      l10n.travelDestinationPalawan,
      l10n.travelDestinationBohol,
      l10n.travelDestinationManila,
      l10n.travelDestinationSubic,
    ];

    /// 기존 아이템들을 인기순으로 정렬 (Sort existing items by popularity)
    final sortedItems = [...TravelDestinationMenuData.items];
    sortedItems.sort((a, b) {
      final aIndex = popularityOrder.indexOf(a.getLabel(l10n));
      final bIndex = popularityOrder.indexOf(b.getLabel(l10n));
      return aIndex.compareTo(bIndex);
    });

    /// 정렬된 아이템들을 위젯으로 변환 (Convert sorted items to widgets)
    return sortedItems
        .map(
          (item) => MenuGridItem(
            icon: item.icon,
            title: item.getLabel(l10n),
            onTap: () => item.push(context),
          ),
        )
        .toList();
  }
}
