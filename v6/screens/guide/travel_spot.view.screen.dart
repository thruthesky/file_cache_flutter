import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:philgo/models/travel_spot.model.dart';
import 'package:philgo/services/travel/travel_spot.service.dart';
import 'package:url_launcher/url_launcher.dart';

/// 여행 명소 상세 보기 화면 (Travel Spot View Screen)
///
/// 여행 명소의 상세 정보를 표시하는 화면입니다.
/// CompanyViewScreen의 Best Practice 패턴을 따라 구현되었습니다.
///
/// ### 디자인 특징:
/// - SliverAppBar with Hero animation (이미지 또는 아이콘)
/// - 섹션 인디케이터 바 + 아이콘 + 타이틀 헤더 패턴
/// - surfaceContainerLowest 배경, outlineVariant 테두리
/// - flutter_animate를 사용한 순차적 애니메이션
/// - markdown_widget을 사용한 마크다운 렌더링
/// - 28px 섹션 간 간격
class TravelSpotViewScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/travel-spot-view';

  /// push 네비게이션 (Push navigation)
  static Future<void> Function(BuildContext ctx, TravelSpot spot) push =
      (ctx, spot) => ctx.push(routeName, extra: spot);

  /// go 네비게이션 (Go navigation)
  static void Function(BuildContext ctx, TravelSpot spot) go =
      (ctx, spot) => ctx.go(routeName, extra: spot);

  const TravelSpotViewScreen({super.key, required this.spot});

  /// 여행 명소 데이터 (Travel spot data)
  final TravelSpot spot;

  @override
  State<TravelSpotViewScreen> createState() => _TravelSpotViewScreenState();
}

class _TravelSpotViewScreenState extends State<TravelSpotViewScreen> {
  final ScrollController _scrollController = ScrollController();

  /// AppBar 접힘 상태 (AppBar collapsed state)
  bool _isCollapsed = false;

  /// 상세 데이터가 로드된 spot (texts 포함)
  /// 목록에서 전달받은 spot에 texts가 없으면 API로 로드하여 여기에 저장
  late TravelSpot _spot;

  /// texts 로딩 중 상태
  bool _isLoadingTexts = false;

  @override
  void initState() {
    super.initState();
    _spot = _spot;
    _scrollController.addListener(_onScroll);

    /// texts가 없으면 v7 API로 상세 데이터 로드
    if (!_spot.hasTexts) {
      _loadTextsFromApi();
    }
  }

  /// v7 travel.get API로 texts(마크다운 상세 콘텐츠)를 로드
  Future<void> _loadTextsFromApi() async {
    setState(() => _isLoadingTexts = true);
    try {
      final detailSpot = await TravelSpotService.instance.getSpotDetail(
        _spot.index,
      );
      if (mounted) {
        setState(() {
          _spot = detailSpot;
          _isLoadingTexts = false;
        });
      }
    } catch (e) {
      debugPrint('TravelSpotViewScreen: texts 로드 실패 - $e');
      if (mounted) {
        setState(() => _isLoadingTexts = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 스크롤 이벤트 핸들러 (Scroll event handler)
  /// AppBar 접힘/펼침 상태를 추적합니다.
  void _onScroll() {
    final isCollapsed =
        _scrollController.hasClients &&
        _scrollController.offset > (240 - kToolbarHeight);

    if (isCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = isCollapsed;
      });
    }
  }

  /// Hero 태그 생성 (Generate Hero tag)
  /// 이미지 유무에 따라 다른 태그 사용
  String get _heroTag =>
      _spot.hasImage
          ? 'travel-spot-${_spot.name}-image'
          : 'travel-spot-${_spot.name}-icon';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// 헤더 이미지를 포함한 SliverAppBar (SliverAppBar with header image)
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            foregroundColor: scheme.onPrimaryContainer,
            backgroundColor: scheme.surfaceContainerLow,

            /// Best Practice: 1px 하단 테두리 (outlineVariant 색상)
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(height: 1.0, color: scheme.outlineVariant),
            ),
            title: _isCollapsed
                ? Text(_spot.name, style: theme.textTheme.titleLarge)
                : null,
            leading: _isCollapsed
                ? null
                : IconButton(
                    /// 펼쳐졌을 때는 반투명 배경의 커스텀 back button
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(scheme),
            ),
          ),

          /// 콘텐츠 영역 (Content area)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 기본 정보 섹션 (Basic info section)
                  _buildBasicInfoSection(theme, scheme)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 28),

                  /// 마크다운 콘텐츠 또는 설명 섹션 (Markdown content or description section)
                  /// texts가 있으면 마크다운 섹션, 로딩 중이면 스피너, 없으면 설명 섹션
                  if (_spot.hasTexts)
                    ..._buildMarkdownSections(theme, scheme)
                  else if (_isLoadingTexts)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: scheme.primary,
                        ),
                      ),
                    )
                  else
                    _buildDescriptionSection(theme, scheme)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                  /// 하단 여백 (Bottom padding)
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hero 이미지 빌드 (Build Hero image)
  Widget _buildHeroImage(ColorScheme scheme) {
    return Hero(
      tag: _heroTag,
      child: _spot.hasImage
          ? CachedNetworkImage(
              imageUrl: _spot.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: scheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => _buildIconPlaceholder(scheme),
            )
          : _buildIconPlaceholder(scheme),
    );
  }

  /// 아이콘 플레이스홀더 빌드 (Build icon placeholder)
  Widget _buildIconPlaceholder(ColorScheme scheme) {
    return Container(
      color: scheme.primaryContainer,
      child: Center(
        child: Text(
          _spot.icon,
          style: const TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  /// 기본 정보 섹션 빌드 (Build basic info section)
  Widget _buildBasicInfoSection(ThemeData theme, ColorScheme scheme) {
    return _buildSection(
      title: '기본 정보',
      icon: FontAwesomeIcons.lightCircleInfo,
      theme: theme,
      scheme: scheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 이름과 아이콘 (Name and icon)
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _spot.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _spot.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _spot.englishName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 제목/부제목 (Title/Subtitle)
          Text(
            _spot.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          /// 카테고리 태그 (Category tag)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _spot.category,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// 위치 정보 (Location info)
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightLocationDot,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_spot.city}, ${_spot.province}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 설명 섹션 빌드 (Build description section)
  /// texts가 없을 때 표시됩니다.
  Widget _buildDescriptionSection(ThemeData theme, ColorScheme scheme) {
    return _buildSection(
      title: '설명',
      icon: FontAwesomeIcons.lightAlignLeft,
      theme: theme,
      scheme: scheme,
      child: Text(
        _spot.description,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          height: 1.6,
        ),
      ),
    );
  }

  /// 마크다운 섹션들 빌드 (Build markdown sections)
  /// texts 배열의 각 항목을 별도 섹션으로 표시합니다.
  List<Widget> _buildMarkdownSections(ThemeData theme, ColorScheme scheme) {
    final sections = <Widget>[];

    for (int i = 0; i < _spot.texts!.length; i++) {
      final sectionInfo = _getSectionInfo(i);

      sections.add(
        _buildSection(
          title: sectionInfo.title,
          icon: sectionInfo.icon,
          theme: theme,
          scheme: scheme,
          child: _buildMarkdownContent(_spot.texts![i], theme, scheme),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: (100 * (i + 1)).ms)
            .slideY(begin: 0.1, end: 0),
      );

      if (i < _spot.texts!.length - 1) {
        sections.add(const SizedBox(height: 28));
      }
    }

    return sections;
  }

  /// 섹션 정보 가져오기 (Get section info)
  /// 인덱스에 따라 제목과 아이콘을 반환합니다.
  ({String title, IconData icon}) _getSectionInfo(int index) {
    switch (index) {
      case 0:
        return (title: '소개', icon: FontAwesomeIcons.lightCircleInfo);
      case 1:
        return (title: '방문 정보', icon: FontAwesomeIcons.lightMapLocationDot);
      case 2:
        return (title: '추천 포인트', icon: FontAwesomeIcons.lightLightbulb);
      default:
        return (title: '상세 정보', icon: FontAwesomeIcons.lightFileLines);
    }
  }

  /// 마크다운 콘텐츠 빌드 (Build markdown content)
  Widget _buildMarkdownContent(
    String markdownText,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    return MarkdownBlock(
      data: markdownText,
      config: MarkdownConfig(
        configs: [
          /// 링크 스타일 (Link style)
          LinkConfig(
            onTap: (url) async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            style: TextStyle(
              color: scheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),

          /// 단락 스타일 (Paragraph style)
          PConfig(
            textStyle: TextStyle(
              fontSize: 15,
              color: scheme.onSurface,
              height: 1.6,
            ),
          ),

          /// 헤더 스타일 (Header styles)
          H1Config(
            style: theme.textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          H2Config(
            style: theme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          H3Config(
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),

          /// 코드 블록 스타일 (Code block style)
          PreConfig(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          /// 인용문 스타일 (Blockquote style)
          BlockquoteConfig(
            sideColor: scheme.primary,
            textColor: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// 섹션 위젯 빌드 (Build section widget)
  /// Best Practice 패턴: 인디케이터 바 + 아이콘 + 타이틀 헤더
  Widget _buildSection({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme scheme,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 (Section header)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              /// 인디케이터 바 (Indicator bar)
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),

              /// 아이콘 (Icon)
              FaIcon(
                icon,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),

              /// 타이틀 (Title)
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        /// 섹션 콘텐츠 컨테이너 (Section content container)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ],
    );
  }
}
