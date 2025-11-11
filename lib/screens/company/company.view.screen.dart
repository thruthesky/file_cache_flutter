import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyViewScreen extends StatefulWidget {
  static const String routeName = '/company-view';

  static Future<Company?> Function(BuildContext ctx, int companyIdx) push =
      (ctx, companyIdx) => ctx.push(routeName, extra: companyIdx);

  const CompanyViewScreen({super.key, required this.companyIdx});

  final int companyIdx;

  @override
  State<CompanyViewScreen> createState() => _CompanyViewScreenState();
}

class _CompanyViewScreenState extends State<CompanyViewScreen> {
  final ScrollController _scrollController = ScrollController();
  Company? company;
  bool _isCollapsed = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    loadCompany();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadCompany() async {
    try {
      final details = await getCompany(widget.companyIdx);

      debugLog('------> LOADED COMPANY: $details');

      setState(() {
        company = details;
        isLoading = false;
      });
    } catch (e) {
      d('Error fetching company details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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

  // Getters to safely access company data
  String get titleImageUrl => company?.title_image_url ?? '';
  String get logoUrl => company?.logo_url ?? '';
  String get name => company?.name ?? '';
  String get title => company?.title ?? '';
  String get category => company?.category ?? '';
  String get location => company?.location ?? '';
  String get address => company?.address ?? '';
  String get phoneNumber => company?.phone_number ?? '';
  String get mobileNumber => company?.mobile_number ?? '';
  String get kakaotalkId => company?.kakaotalk_id ?? '';
  String get telegramId => company?.telegram_id ?? '';
  String get description => company?.description ?? '';

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// 타이틀 이미지를 포함한 SliverAppBar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            leading: _isCollapsed
                ? null // 접혔을 때는 기본 back button 사용
                : IconButton(
                    /// 펼쳐졌을 때는 shadow가 있는 커스텀 back button
                    icon: Container(
                      padding: EdgeInsets.all(sp.s8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
            flexibleSpace: FlexibleSpaceBar(
              background: CompanyHeaderImage(titleImageUrl: titleImageUrl),
            ),
          ),

          /// 로딩 중이면 로딩 인디케이터 표시
          if (isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            /// 기업 기본 정보 섹션
            if (company != null)
              SliverToBoxAdapter(
                child: CompanyBasicInfoSection(company: company!),
              ),

            /// 연락처 섹션
            if (company != null)
              SliverToBoxAdapter(
                child: CompanyContactSection(company: company!),
              ),

            /// 설명 섹션
            if (description.isNotEmpty && company != null)
              SliverToBoxAdapter(
                child: CompanyDescriptionSection(company: company!),
              ),

            /// 하단 여백
            SliverToBoxAdapter(child: SizedBox(height: sp.s32)),
          ],
        ],
      ),
    );
  }
}

class CompanyHeaderImage extends StatelessWidget {
  const CompanyHeaderImage({super.key, required this.titleImageUrl});
  final String titleImageUrl;

  @override
  Widget build(BuildContext context) {
    if (titleImageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            titleImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _PlaceholderImage();
            },
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _PlaceholderImage();
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.building,
          size: 64,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class CompanyBasicInfoSection extends StatelessWidget {
  final Company company;

  const CompanyBasicInfoSection({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(sp.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 로고와 기본 정보
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 로고 이미지
              if (company.logo_url.isNotEmpty) CompanyLogo(company: company),

              /// 기업명과 카테고리
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 기업명
                    Text(company.name, style: theme.textTheme.headlineSmall),
                    SizedBox(height: sp.s8),

                    /// 타이틀
                    if (company.title.isNotEmpty)
                      Text(
                        company.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),

                    SizedBox(height: sp.s8),

                    /// 카테고리 태그
                    CompanyCategoryTag(category: company.category),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: sp.s24),

          /// 위치 정보
          if (company.location.isNotEmpty || company.address.isNotEmpty)
            CompanyInfoRow(
              icon: FontAwesomeIcons.lightLocationDot,
              title: T.location,
              content: company.location.isNotEmpty
                  ? company.location
                  : company.address,
            ),
        ],
      ),
    );
  }
}

/// 로고 이미지
class CompanyLogo extends StatelessWidget {
  final Company company;

  const CompanyLogo({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      height: 80,
      margin: EdgeInsets.only(right: sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        company.logo_url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: FaIcon(
              FontAwesomeIcons.building,
              color: scheme.onSurfaceVariant,
              size: 32,
            ),
          );
        },
      ),
    );
  }
}

/// 카테고리 태그
class CompanyCategoryTag extends StatelessWidget {
  final String category;

  const CompanyCategoryTag({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getCategoryDisplayName(category),
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    final categoryMap = {
      'public-office': 'Public Office',
      'education': 'Education',
      'food': 'Food',
      'transport': 'Transport',
      'hospital': 'Hospital',
      'mart': 'Mart',
      'bank': 'Bank',
      'gadget': 'Gadget',
      'travel-agency': 'Travel Agency',
      'hotel': 'Hotel',
      'rentcar': 'Rent Car',
      'beauty': 'Beauty',
      'real-estate': 'Real Estate',
      'ktv': 'KTV',
      'spa': 'Spa',
      'etc': 'ETC',
    };

    return categoryMap[category.toLowerCase()] ?? category;
  }
}

/// 정보 행 위젯
class CompanyInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const CompanyInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(icon, color: scheme.primary, size: 20),
          ),
          SizedBox(width: sp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(content, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 연락처 섹션
class CompanyContactSection extends StatelessWidget {
  final Company company;

  const CompanyContactSection({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 제목
          Text(T.contactInformation, style: theme.textTheme.titleLarge),
          SizedBox(height: sp.s16),

          /// 전화번호
          if (company.phone_number.isNotEmpty)
            CompanyContactButton(
              icon: FontAwesomeIcons.lightPhone,
              label: T.phoneNumber,
              value: company.phone_number,
              onTap: () => _launchPhone(company.phone_number),
            ),

          /// 모바일 번호
          if (company.mobile_number.isNotEmpty)
            CompanyContactButton(
              icon: FontAwesomeIcons.lightMobileScreen,
              label: T.mobileNumber,
              value: company.mobile_number,
              onTap: () => _launchPhone(company.mobile_number),
            ),

          /// 카카오톡 ID
          if (company.kakaotalk_id.isNotEmpty)
            CompanyContactButton(
              icon: FontAwesomeIcons.comment,
              label: 'KakaoTalk',
              value: company.kakaotalk_id,
              onTap: () => _launchKakaoTalk(company.kakaotalk_id),
            ),

          /// 텔레그램 ID
          if (company.telegram_id.isNotEmpty)
            CompanyContactButton(
              icon: FontAwesomeIcons.telegram,
              label: 'Telegram',
              value: company.telegram_id,
              onTap: () => _launchTelegram(company.telegram_id),
            ),

          SizedBox(height: sp.s16),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchKakaoTalk(String kakaoId) async {
    final uri = Uri.parse('https://open.kakao.com/o/$kakaoId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 텔레그램 실행
  Future<void> _launchTelegram(String telegramId) async {
    final uri = Uri.parse('https://t.me/$telegramId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class CompanyContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const CompanyContactButton({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(icon, color: scheme.primary, size: 20),
              ),
              SizedBox(width: sp.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(value, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.lightChevronRight,
                color: scheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 설명 섹션
class CompanyDescriptionSection extends StatelessWidget {
  final Company company;

  const CompanyDescriptionSection({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(sp.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 제목
          Text(T.description, style: theme.textTheme.titleLarge),
          SizedBox(height: sp.s16),

          /// 설명 내용
          Container(
            padding: EdgeInsets.all(sp.s16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              company.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
