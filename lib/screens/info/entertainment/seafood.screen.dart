import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 해산물 재료 데이터 클래스 (Seafood Ingredient Data Class)
///
/// 해산물의 현지명, 한국어, 특징, 조리법을 담습니다.
/// Contains local name, Korean name, characteristics, and cooking methods.
class _SeafoodItem {
  /// 현지명 (Local name)
  final String localName;

  /// 한국어 (Korean name)
  final String koreanName;

  /// 특징 (Characteristics)
  final String characteristics;

  /// 흔한 조리법 (Common cooking)
  final String cooking;

  const _SeafoodItem({
    required this.localName,
    required this.koreanName,
    required this.characteristics,
    required this.cooking,
  });
}

/// 대표 해산물 메뉴 데이터 클래스 (Popular Menu Data Class)
///
/// 메뉴명, 분류, 설명, 주문 팁을 담습니다.
/// Contains menu name, category, description, and ordering tips.
class _MenuItem {
  /// 메뉴명 (Menu name)
  final String name;

  /// 분류 (Category)
  final String category;

  /// 설명 (Description)
  final String description;

  /// 주문 팁 (Ordering tip)
  final String tip;

  const _MenuItem({
    required this.name,
    required this.category,
    required this.description,
    required this.tip,
  });
}

/// 식당 정보 데이터 클래스 (Restaurant Data Class)
///
/// 식당명, 지역, 형태, 주소, 시간, 연락처, 포인트를 담습니다.
/// Contains restaurant name, region, type, address, hours, contact, and highlights.
class _RestaurantItem {
  /// 장소/식당 (Place/Restaurant name)
  final String name;

  /// 지역 (Region)
  final String region;

  /// 형태 (Type)
  final String type;

  /// 주소(요약) (Address summary)
  final String address;

  /// 시간 (Hours)
  final String hours;

  /// 연락처 (Contact)
  final String contact;

  /// 포인트 (Highlight)
  final String highlight;

  const _RestaurantItem({
    required this.name,
    required this.region,
    required this.type,
    required this.address,
    required this.hours,
    required this.contact,
    required this.highlight,
  });
}

/// 주문 표현 데이터 클래스 (Order Expression Data Class)
///
/// 목적, 영어 표현, 의미를 담습니다.
/// Contains purpose, English expression, and meaning.
class _ExpressionItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 목적 (Purpose)
  final String purpose;

  /// 표현(영어) (English expression)
  final String expression;

  /// 의미 (Meaning)
  final String meaning;

  const _ExpressionItem({
    required this.icon,
    required this.purpose,
    required this.expression,
    required this.meaning,
  });
}

/// 참고 URL 데이터 클래스 (Reference URL Data Class)
class _ReferenceUrl {
  /// 제목 (Title)
  final String title;

  /// URL
  final String url;

  const _ReferenceUrl({
    required this.title,
    required this.url,
  });
}

/// 해산물 정보 화면 (Seafood Screen)
///
/// 필리핀 해산물 음식 가이드 및 마닐라 베이 중심 식당 정보를 제공합니다.
/// Provides seafood dining guide and Manila Bay area restaurant information.
///
/// ### 사용법 (Usage):
/// ```dart
/// SeafoodScreen.push(context);
/// ```
class SeafoodScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Seafood';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const SeafoodScreen({super.key});

  @override
  State<SeafoodScreen> createState() => _SeafoodScreenState();
}

class _SeafoodScreenState extends State<SeafoodScreen> {
  /// 인기 해산물 재료 데이터 (Popular seafood ingredients data)
  static const List<_SeafoodItem> _seafoodItems = [
    _SeafoodItem(
      localName: 'Bangus',
      koreanName: '밀크피시(방구스)',
      characteristics: '가시가 많은 편으로 "boneless(가시 제거)" 형태도 유통',
      cooking: '구이(inihaw), 튀김',
    ),
    _SeafoodItem(
      localName: 'Lapu-lapu',
      koreanName: '그루퍼(바리)',
      characteristics: '흰살 생선류로 식당 단품 메뉴에 자주 등장',
      cooking: '찜(steamed), 튀김',
    ),
    _SeafoodItem(
      localName: 'Hipon / Prawn',
      koreanName: '새우',
      characteristics: '국물요리·구이·버터조리 모두 흔함',
      cooking: '시니강(sinigang), 구이',
    ),
    _SeafoodItem(
      localName: 'Alimango / Alimasag',
      koreanName: '게',
      characteristics: '소스·버터·찜 등 선택 폭이 넓음',
      cooking: '칠리/버터, 찜',
    ),
    _SeafoodItem(
      localName: 'Tahong',
      koreanName: '홍합',
      characteristics: '전채·안주류로 매우 흔함',
      cooking: '구이/오븐(baked), 버터',
    ),
    _SeafoodItem(
      localName: 'Talaba',
      koreanName: '굴',
      characteristics: '산지·계절·수급에 따라 메뉴 구성 변동',
      cooking: '생/구이',
    ),
    _SeafoodItem(
      localName: 'Scallops',
      koreanName: '가리비',
      characteristics: '팔루토 계열에서 자주 선택되는 품목',
      cooking: '버터/치즈, 구이',
    ),
    _SeafoodItem(
      localName: 'Pusit',
      koreanName: '오징어',
      characteristics: '단품 메뉴·구이 메뉴로 빈도 높음',
      cooking: '구이(inihaw), 튀김',
    ),
  ];

  /// 대표 해산물 메뉴 데이터 (Popular seafood menu data)
  static const List<_MenuItem> _menuItems = [
    _MenuItem(
      name: 'Sinigang na Hipon',
      category: '국물',
      description: '새우를 넣은 신맛(주로 타마린드) 국물 요리',
      tip: '"not too sour" 등 산미 강도 요청 가능',
    ),
    _MenuItem(
      name: 'Kinilaw',
      category: '전채',
      description: '생선/해산물을 식초·칼라만시 등 산으로 절여 먹는 방식',
      tip: '알레르기·생식 주의(체질/컨디션 고려)',
    ),
    _MenuItem(
      name: 'Inihaw na Isda / Pusit',
      category: '구이',
      description: '생선/오징어 숯불·그릴 구이',
      tip: '소스(간장·칼라만시 등) 함께 요청',
    ),
    _MenuItem(
      name: 'Garlic Butter Tahong',
      category: '전채',
      description: '홍합을 마늘버터(치즈 포함)로 조리하는 메뉴 유형',
      tip: '공유 메뉴로 적합',
    ),
    _MenuItem(
      name: 'Steamed Fish (예: Lapu-lapu)',
      category: '생선',
      description: '찜 형태로 제공되는 흰살 생선류 단품',
      tip: '"steamed" 지정 시 실패 확률 낮음',
    ),
    _MenuItem(
      name: 'Seafood Paluto (Cook-to-order)',
      category: '시장형',
      description: '해산물을 고른 뒤 인근 식당에서 원하는 방식으로 조리',
      tip: '재료값 + 조리비 구조를 이해해야 함',
    ),
  ];

  /// 마닐라 베이 인근 식당 데이터 (Manila Bay area restaurants data)
  static const List<_RestaurantItem> _restaurants = [
    _RestaurantItem(
      name: 'Harbor View Restaurant',
      region: '마닐라(리잘 파크)',
      type: '단품',
      address: 'Rizal Park 인근',
      hours: '11:00~22:00',
      contact: '(02) 8710-0060',
      highlight: '마닐라 베이 인접 단품 해산물',
    ),
    _RestaurantItem(
      name: 'Dampa Seaside',
      region: '파사이(마카파갈)',
      type: '팔루토',
      address: 'Diosdado Macapagal Blvd',
      hours: '09:00~24:00',
      contact: '(02) 556-1779',
      highlight: '해산물 선택→조리(팔루토)',
    ),
    _RestaurantItem(
      name: 'Seascape Village',
      region: '파사이(CCP)',
      type: '복합',
      address: 'CCP Complex',
      hours: '매장별 상이(11:00~)',
      contact: '(02) 8640-9955',
      highlight: '베이프런트 복합 식음',
    ),
    _RestaurantItem(
      name: 'Café Ilang-Ilang',
      region: '마닐라(원 리잘)',
      type: '뷔페',
      address: 'One Rizal Park (Manila Hotel)',
      hours: '06:00~ / 11:30~ / 18:00~',
      contact: '호텔 대표번호',
      highlight: '해산물 포함 국제 뷔페',
    ),
    _RestaurantItem(
      name: 'Corniche (Diamond Hotel)',
      region: '마닐라(로하스)',
      type: '호텔식',
      address: 'Roxas Blvd',
      hours: '공식 채널 확인',
      contact: '(632) 5305-3000',
      highlight: '예약 안내·공식 채널 명확',
    ),
  ];

  /// 주문 표현 데이터 (Order expressions data)
  static const List<_ExpressionItem> _expressions = [
    _ExpressionItem(
      icon: FontAwesomeIcons.lightCircleQuestion,
      purpose: '추천 요청',
      expression: 'What seafood is available today?',
      meaning: '오늘 가능한 해산물 확인',
    ),
    _ExpressionItem(
      icon: FontAwesomeIcons.lightFire,
      purpose: '조리 지정',
      expression: 'Steamed / Grilled, please.',
      meaning: '찜/구이로 조리 지정',
    ),
    _ExpressionItem(
      icon: FontAwesomeIcons.lightPepperHot,
      purpose: '매운맛 조절',
      expression: 'Not spicy / Less spicy.',
      meaning: '맵기 조절',
    ),
    _ExpressionItem(
      icon: FontAwesomeIcons.lightBowlFood,
      purpose: '시니강 주문',
      expression: 'Sinigang na hipon.',
      meaning: '새우 시니강',
    ),
    _ExpressionItem(
      icon: FontAwesomeIcons.lightReceipt,
      purpose: '계산 확인',
      expression: 'Is service charge included?',
      meaning: '봉사료 포함 여부 확인',
    ),
    _ExpressionItem(
      icon: FontAwesomeIcons.lightFileInvoice,
      purpose: '영수증',
      expression: 'Official receipt, please.',
      meaning: '공식 영수증 요청',
    ),
  ];

  /// 참고 URL 데이터 (Reference URLs data)
  static const List<_ReferenceUrl> _referenceUrls = [
    _ReferenceUrl(
      title: 'Dampa Seaside 정보',
      url: 'https://primer.com.ph/food/location/philippines/pasay/dampa-seaside/',
    ),
    _ReferenceUrl(
      title: 'Seascape Village Dining',
      url: 'https://www.seascapevillage.com.ph/dining/',
    ),
    _ReferenceUrl(
      title: 'Café Ilang-Ilang (Manila Hotel)',
      url: 'https://www.manila-hotel.com.ph/dining/cafe-ilang-ilang/',
    ),
    _ReferenceUrl(
      title: 'Corniche (Diamond Hotel)',
      url: 'https://diamondhotel.com/dining/corniche/',
    ),
    _ReferenceUrl(
      title: 'Harbor View Restaurant',
      url: 'https://autoreserve.com/en/restaurants/kt8RydL2eKxGb3g4oAcE',
    ),
    _ReferenceUrl(
      title: 'Sinigang na Hipon 레시피',
      url: 'https://panlasangpinoy.org/sinigang-na-hipon/',
    ),
    _ReferenceUrl(
      title: 'Milkfish (Bangus) 정보',
      url: 'https://en.wikipedia.org/wiki/Milkfish',
    ),
  ];

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
              FontAwesomeIcons.lightShrimp,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentSeafood,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [헤더 배너] 해산물 가이드 개요
            _buildHeaderBanner(context),
            SizedBox(height: sp.s24),

            /// [1. 인기 해산물 재료]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightFish,
              title: '필리핀에서 인기 있는 해산물(재료)',
              emoji: '🦐🐟',
            ),
            SizedBox(height: sp.s12),
            _buildSeafoodSection(context),
            SizedBox(height: sp.s24),

            /// [2. 대표 해산물 메뉴]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightUtensils,
              title: '한국인이 많이 찾는 대표 메뉴',
              emoji: '🧾',
            ),
            SizedBox(height: sp.s12),
            _buildMenuSection(context),
            SizedBox(height: sp.s24),

            /// [3. 마닐라 베이 인근 식당]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: '마닐라 베이 인근 유명 식당 4선',
              emoji: '🌊',
            ),
            SizedBox(height: sp.s12),
            _buildRestaurantSection(context),
            SizedBox(height: sp.s24),

            /// [4. 이용 절차]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightClipboardList,
              title: '당일 1회 이용 절차',
              emoji: '✅',
            ),
            SizedBox(height: sp.s12),
            _buildProcedureSection(context),
            SizedBox(height: sp.s24),

            /// [5. 주문 표현]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightComment,
              title: '즉시 사용 주문 표현',
              emoji: '🗣️',
            ),
            SizedBox(height: sp.s12),
            _buildExpressionSection(context),
            SizedBox(height: sp.s24),

            /// [6. 핵심 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightListCheck,
              title: '쉽게 이용하기 위한 핵심 정리',
              emoji: '📌',
            ),
            SizedBox(height: sp.s12),
            _buildChecklistSection(context),
            SizedBox(height: sp.s24),

            /// [7. 참고 URL]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLink,
              title: '참고 URL',
              emoji: '🔗',
            ),
            SizedBox(height: sp.s12),
            _buildReferenceUrls(context),
            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 헤더 배너 빌드 (Header banner build)
  ///
  /// 해산물 가이드의 개요와 목적을 설명하는 상단 배너입니다.
  /// Top banner explaining the overview and purpose of seafood guide.
  Widget _buildHeaderBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.2),
            Colors.cyan.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 제목 행 (Title row)
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightShrimp,
                size: 24,
                color: Colors.blue,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 해산물 음식 가이드',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),

          /// 부제목 (Subtitle)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '마닐라 베이 중심 "식당에서 주문해 먹는" 방법',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: sp.s12),

          /// 설명 (Description)
          Text(
            '필리핀 내(마닐라·파사이·에르미타 등)에서 당일 방문 1회 이용으로 해산물 식사를 진행하는 절차와, '
            '한국인이 현장에서 바로 활용할 수 있는 대표 해산물·인기 메뉴·유명 식당 정보를 정리한 가이드입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),

          /// 안내 박스 (Info box)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 14,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '직접 장을 보거나 요리하지 않고, 식당에서 주문하여 식사하는 방식만 다룹니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
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

  /// 섹션 헤더 빌드 (Section header build)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? emoji,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: scheme.onPrimaryContainer),
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Text(
            emoji != null ? '$emoji $title' : title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 해산물 재료 섹션 빌드 (Seafood section build)
  Widget _buildSeafoodSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        ..._seafoodItems.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: sp.s8),
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 현지명 및 한국어 (Local and Korean name)
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightFish,
                      size: 14,
                      color: Colors.blue,
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: item.localName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: '  ',
                              style: theme.textTheme.bodySmall,
                            ),
                            TextSpan(
                              text: item.koreanName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),

                /// 특징 (Characteristics)
                Text(
                  item.characteristics,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: sp.s8),

                /// 조리법 (Cooking method)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s8,
                    vertical: sp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightFire,
                        size: 12,
                        color: Colors.orange,
                      ),
                      SizedBox(width: sp.s4),
                      Text(
                        item.cooking,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        /// 현장 팁 박스 (Field tip box)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                FontAwesomeIcons.lightLightbulb,
                size: 16,
                color: Colors.green,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  '현장 팁: 해산물 이름을 몰라도 "seafood / fish / shrimp / crab"로 주문이 가능하며, '
                  '팔루토 계열은 "찜·구이·버터·칠리·시니강" 등 조리법 선택이 핵심입니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 대표 메뉴 섹션 빌드 (Menu section build)
  Widget _buildMenuSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _menuItems.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 메뉴명 및 분류 (Menu name and category)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s8,
                      vertical: sp.s4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),

              /// 설명 (Description)
              Text(
                item.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: sp.s8),

              /// 주문 팁 (Ordering tip)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightLightbulb,
                    size: 12,
                    color: Colors.amber.shade700,
                  ),
                  SizedBox(width: sp.s4),
                  Expanded(
                    child: Text(
                      item.tip,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.amber.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 식당 섹션 빌드 (Restaurant section build)
  Widget _buildRestaurantSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 주의사항 박스 (Caution box)
        Container(
          padding: EdgeInsets.all(sp.s12),
          margin: EdgeInsets.only(bottom: sp.s12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                FontAwesomeIcons.lightTriangleExclamation,
                size: 16,
                color: Colors.amber.shade700,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  '영업시간·연락처·프로모션은 변경될 수 있으므로 공식 예약/연락 채널에서 당일 재확인하는 방식이 안전합니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// 식당 목록 (Restaurant list)
        ..._restaurants.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: sp.s12),
            padding: EdgeInsets.all(sp.s16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 식당명 및 형태 (Restaurant name and type)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sp.s8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightUtensils,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: sp.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          SizedBox(height: sp.s4),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: sp.s8,
                                  vertical: sp.s4,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.type,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: sp.s8),
                              Text(
                                item.region,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s12),

                /// 상세 정보 (Detail info)
                _buildDetailRow(
                  context,
                  icon: FontAwesomeIcons.lightLocationDot,
                  label: '주소',
                  value: item.address,
                ),
                SizedBox(height: sp.s4),
                _buildDetailRow(
                  context,
                  icon: FontAwesomeIcons.lightClock,
                  label: '시간',
                  value: item.hours,
                ),
                SizedBox(height: sp.s4),
                _buildDetailRow(
                  context,
                  icon: FontAwesomeIcons.lightPhone,
                  label: '연락처',
                  value: item.contact,
                ),
                SizedBox(height: sp.s8),

                /// 포인트 (Highlight)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s12,
                    vertical: sp.s8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightStar,
                        size: 14,
                        color: Colors.blue,
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          item.highlight,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 상세 정보 행 빌드 (Detail row build)
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FaIcon(icon, size: 12, color: scheme.onSurfaceVariant),
        SizedBox(width: sp.s8),
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 이용 절차 섹션 빌드 (Procedure section build)
  Widget _buildProcedureSection(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 일반 해산물 식당 절차 (Regular restaurant procedure)
        _buildProcedureCard(
          context,
          title: '일반 해산물 식당(단품) 이용 절차',
          icon: FontAwesomeIcons.lightUtensils,
          iconColor: Colors.teal,
          steps: [
            '도착 후 좌석/웨이팅 확인',
            '메뉴에서 Seafood / Fish / Shrimp / Crab 카테고리 우선 확인',
            '조리법은 steamed / grilled(inihaw) / garlic butter / chili 중심으로 선택',
            '결제는 현금·카드 가능 여부를 계산 전 확인',
            '영수증 필요 시 "Official receipt" 요청',
          ],
        ),
        SizedBox(height: sp.s12),

        /// 팔루토 방식 절차 (Paluto procedure)
        _buildProcedureCard(
          context,
          title: '팔루토(Paluto) 방식 이용 절차',
          subtitle: '담파/씨스케이프 계열',
          icon: FontAwesomeIcons.lightStore,
          iconColor: Colors.orange,
          steps: [
            '시장 구역(해산물 판매) → 식당 구역(조리) 구조를 먼저 확인',
            '해산물을 중량 기준으로 구매 (kg 단위가 일반적)',
            '선택한 식당에 가져가 조리법을 지정 (예: steamed, butter, sinigang)',
            '조리비(요리비) + 밥/음료 별도가 되는지 확인',
            '혼잡 시간대는 주문→서빙까지 시간이 길 수 있어 여유 있는 일정이 유리',
          ],
        ),
      ],
    );
  }

  /// 절차 카드 빌드 (Procedure card build)
  Widget _buildProcedureCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required List<String> steps,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 헤더 (Header)
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(icon, size: 16, color: iconColor),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: sp.s4),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),

          /// 단계 목록 (Steps list)
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;

            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      step,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 주문 표현 섹션 빌드 (Expression section build)
  Widget _buildExpressionSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _expressions.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: sp.s8),
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(
                      item.icon,
                      size: 18,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sp.s8,
                              vertical: sp.s4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.purpose,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        item.expression,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        item.meaning,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 체크리스트 섹션 빌드 (Checklist section build)
  Widget _buildChecklistSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final checklistItems = [
      '목적 선택: 단품 식당(편함) vs 팔루토(선택 폭 큼)',
      '장소 선택: 마닐라 베이 인근(이동 단순)',
      '대표 메뉴 2개만 고정: Sinigang na Hipon + Grilled/Steamed Fish',
      '팔루토라면: "재료값 + 조리비" 구조 먼저 확인',
      '결제 전 확인: 현금/카드, 봉사료 포함 여부',
    ];

    return Column(
      children: [
        /// 체크리스트 (Checklist)
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘 바로 실행 체크리스트',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              SizedBox(height: sp.s12),
              ...checklistItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Padding(
                  padding: EdgeInsets.only(bottom: sp.s8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.lightSquareCheck,
                        size: 16,
                        color: Colors.green,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 추천 조합 (Recommended combinations)
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.1),
                Colors.pink.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightWandMagicSparkles,
                    size: 16,
                    color: Colors.purple,
                  ),
                  SizedBox(width: sp.s8),
                  Text(
                    '실패 확률을 낮추는 주문 조합',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),

              /// 2인 기준 (For 2 people)
              Container(
                padding: EdgeInsets.all(sp.s12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s8,
                        vertical: sp.s4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '2인 기준',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: sp.s8),
                    Text(
                      'Sinigang na Hipon(국물) + Inihaw na Pusit(오징어 구이) + 밥',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sp.s8),

              /// 3~4인 기준 (For 3-4 people)
              Container(
                padding: EdgeInsets.all(sp.s12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s8,
                        vertical: sp.s4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '3~4인 기준 (팔루토)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.pink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: sp.s8),
                    Text(
                      '게 1종 + 새우 1종 + 찜 생선 1종을 각각 다른 조리로 분산',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 참고 URL 빌드 (Reference URLs build)
  Widget _buildReferenceUrls(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _referenceUrls.map((ref) {
          return InkWell(
            onTap: () => _launchUrl(ref.url),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sp.s8),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightArrowUpRightFromSquare,
                    size: 14,
                    color: scheme.primary,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      ref.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// URL 실행 함수 (Launch URL function)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
