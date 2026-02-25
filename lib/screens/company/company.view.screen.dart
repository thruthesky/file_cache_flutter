import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.qr_code.screen.dart';
import 'package:philgo_api/philgo_api.dart';

/// 업체 상세 보기 화면 (Company View Screen)
///
/// 업체의 상세 정보를 표시하는 화면입니다.
/// Best Practice 패턴을 따라 섹션 구조와 스타일을 적용합니다.
///
/// ### 디자인 특징:
/// - 섹션 인디케이터 바 + 아이콘 + 타이틀 헤더 패턴
/// - surfaceContainerLowest 배경, outlineVariant 테두리
/// - flutter_animate를 사용한 순차적 애니메이션
/// - 28px 섹션 간 간격
class CompanyViewScreen extends StatefulWidget {
  static const String routeName = '/company/view.php';

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

  /// Error message when company loading fails
  String? errorMessage;

  /// 업체 정보 로드 (Load company information)
  Future<void> loadCompany() async {
    try {
      final details = await getCompany(widget.companyIdx);

      if (!mounted) return;
      setState(() {
        company = details;
        isLoading = false;
      });
    } catch (e) {
      debugLog('Error fetching company details: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
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

  /// 업소록 수정 화면으로 이동 (Navigate to company edit form)
  Future<void> _navigateToEdit() async {
    if (company == null) return;
    final result = await CompanyFormScreen.push(context, company: company);
    if (result is Company && mounted) {
      setState(() {
        company = result;
      });
    } else if (mounted) {
      /// 수정 화면에서 저장 후 돌아왔을 때 데이터를 다시 로드
      loadCompany();
    }
  }

  /// 안전한 데이터 접근을 위한 getter들 (Getters for safe data access)
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

  /// 나의 업소록인지 확인 (Check if this company belongs to the current user)
  bool get _isMyCompany {
    final user = PhilgoState.of(context).user;
    if (user == null || company == null) return false;
    return company!.idx_member == user.idx;
  }

  /// Check if the QR code is enabled/approved by admin for this company.
  /// The `qr_code_enabled` field is returned by the get_company API.
  /// When true, the QR code button is visible to all users on the company view screen.
  bool get _isQrCodeEnabled {
    if (company == null) return false;
    return company!.qr_code_enabled;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// 타이틀 이미지를 포함한 SliverAppBar (SliverAppBar with title image)
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

            /// QR code button: visible to all users, but only when qr_code_enabled is true (admin-approved)
            /// Edit button: only visible to the company owner (_isMyCompany)
            actions: [
              /// QR code view button - accessible to all users when qr_code_enabled is true
              if (_isQrCodeEnabled) ...[
                _isCollapsed
                    ? IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.lightQrcode,
                          size: 20,
                        ),
                        onPressed: () => CompanyQrCodeScreen.push(
                          context,
                          widget.companyIdx,
                        ),
                      )
                    : IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.lightQrcode,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () => CompanyQrCodeScreen.push(
                          context,
                          widget.companyIdx,
                        ),
                      ),
              ],

              /// Edit button - only visible to the company owner
              if (_isMyCompany) ...[
                _isCollapsed
                    ? IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.lightPenToSquare,
                          size: 20,
                        ),
                        onPressed: () => _navigateToEdit(),
                      )
                    : IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () => _navigateToEdit(),
                      ),
              ],
            ],
            title: _isCollapsed && company != null
                ? Text(company!.name, style: theme.textTheme.titleLarge)
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
              background: CompanyHeaderImage(titleImageUrl: titleImageUrl),
            ),
          ),

          /// 로딩 중이면 로딩 인디케이터 표시 (Show loading indicator while loading)
          if (isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      T.loading,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (errorMessage != null)
            /// Error state display when company loading fails
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.triangleExclamation,
                        size: 48,
                        color: scheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        T.failedToLoadCompanies,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          loadCompany();
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.arrowRotateRight,
                          size: 16,
                        ),
                        label: Text(T.retry),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            /// 메인 콘텐츠 영역 (Main content area)
            if (company != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 28,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      /// [1. 기업 기본 정보 섹션] - Company Basic Info Section
                      _buildSection(
                            title: T.businessDirectoryTitle,
                            icon: FontAwesomeIcons.building,
                            child: _buildCompanyInfoContent(),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      /// [2. 연락처 섹션] - Contact Information Section
                      if (_hasContactInfo())
                        _buildSection(
                              title: T.contactInformation,
                              icon: FontAwesomeIcons.addressBook,
                              child: _buildContactContent(),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 100.ms)
                            .slideY(begin: 0.1, end: 0),

                      /// [3. 설명 섹션] - Description Section
                      if (description.isNotEmpty)
                        _buildSection(
                              title: T.description,
                              icon: FontAwesomeIcons.alignLeft,
                              child: _buildDescriptionContent(),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// 섹션 컨테이너 빌드 (Build section container)
  ///
  /// Best Practice 패턴: 인디케이터 바 + 아이콘 + 타이틀 헤더
  /// surfaceContainerLowest 배경, outlineVariant 테두리 적용
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 - 인디케이터 바 + 아이콘 + 타이틀
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              /// 섹션 인디케이터 바 (Section indicator bar)
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),

              /// 섹션 아이콘 (Section icon)
              FaIcon(icon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),

              /// 섹션 타이틀 (Section title)
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        /// 섹션 콘텐츠 컨테이너 (Section content container)
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
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ],
    );
  }

  /// 기업 기본 정보 콘텐츠 빌드 (Build company info content)
  Widget _buildCompanyInfoContent() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 로고와 기본 정보 (Logo and basic info)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 로고 이미지 (Logo image)
            if (company!.logo_url.isNotEmpty) ...[
              CompanyLogo(company: company!),
              const SizedBox(width: 16),
            ],

            /// 기업명과 카테고리 (Company name and category)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 기업명 (Company name)
                  Text(
                    company!.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// 타이틀 (Title/Slogan)
                  if (company!.title.isNotEmpty)
                    Text(
                      company!.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                  const SizedBox(height: 12),

                  /// 카테고리 태그 (Category tag) - localized display name
                  CompanyCategoryTag(
                    category: company!.category,
                    displayName: _getCategoryDisplayName(company!.category),
                  ),
                ],
              ),
            ),
          ],
        ),

        /// 위치 정보 (Location info)
        /// URL 형태의 값은 실제 주소가 아니므로 필터링하여 표시하지 않음
        if (_hasValidLocation()) ...[
          const SizedBox(height: 20),

          /// 구분선 (Divider)
          Container(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),

          /// 위치 라벨 및 값 (Location label and value)
          _buildInfoRow(
            icon: FontAwesomeIcons.locationDot,
            label: T.location,
            value: _getValidLocation(),
          ),
        ],
      ],
    );
  }

  /// Check if a string value is a URL (not a real address/location)
  bool _isUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  /// Check if the company has a valid (non-URL) location or address
  bool _hasValidLocation() {
    final loc = company!.location;
    final addr = company!.address;
    return (loc.isNotEmpty && !_isUrl(loc)) ||
        (addr.isNotEmpty && !_isUrl(addr));
  }

  /// Get the first valid (non-URL) location or address string
  String _getValidLocation() {
    final loc = company!.location;
    final addr = company!.address;
    if (loc.isNotEmpty && !_isUrl(loc)) return loc;
    if (addr.isNotEmpty && !_isUrl(addr)) return addr;
    return '';
  }

  /// 연락처 정보가 있는지 확인 (Check if contact info exists)
  bool _hasContactInfo() {
    return company!.phone_number.isNotEmpty ||
        company!.mobile_number.isNotEmpty ||
        company!.kakaotalk_id.isNotEmpty ||
        company!.telegram_id.isNotEmpty;
  }

  /// 연락처 콘텐츠 빌드 (Build contact content)
  Widget _buildContactContent() {
    return Column(
      children: [
        /// 전화번호 (Phone number)
        if (company!.phone_number.isNotEmpty)
          _buildContactItem(
            icon: FontAwesomeIcons.phone,
            label: T.phoneNumber,
            value: company!.phone_number,
            onTap: () => launchApp('tel:${company!.phone_number}', false),
          ),

        /// 모바일 번호 (Mobile number)
        if (company!.mobile_number.isNotEmpty)
          _buildContactItem(
            icon: FontAwesomeIcons.mobileScreen,
            label: T.mobileNumber,
            value: company!.mobile_number,
            onTap: () => launchApp('tel:${company!.mobile_number}', false),
          ),

        /// 카카오톡 ID (KakaoTalk ID)
        if (company!.kakaotalk_id.isNotEmpty)
          _buildContactItem(
            icon: FontAwesomeIcons.comment,
            label: T.kakaoId,
            value: company!.kakaotalk_id,
            onTap: () => launchApp(
              'https://open.kakao.com/o/${company!.kakaotalk_id}',
              true,
            ),
          ),

        /// 텔레그램 ID (Telegram ID)
        if (company!.telegram_id.isNotEmpty)
          _buildContactItem(
            icon: FontAwesomeIcons.telegram,
            label: T.telegramId,
            value: company!.telegram_id,
            onTap: () =>
                launchApp('https://t.me/${company!.telegram_id}', true),
            isLast: true,
          ),
      ],
    );
  }

  /// 연락처 아이템 빌드 (Build contact item)
  ///
  /// 각 연락처 정보를 터치 가능한 행으로 표시합니다.
  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                /// 아이콘 컨테이너 (Icon container)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(icon, size: 18, color: scheme.primary),
                  ),
                ),
                const SizedBox(width: 16),

                /// 라벨과 값 (Label and value)
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
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 화살표 아이콘 (Arrow icon)
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 14,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),

        /// 구분선 (마지막 아이템 제외)
        if (!isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 56),
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }

  /// Maps a category ID to a localized display name using i18n.
  /// Returns the raw category ID if no matching translation is found.
  String _getCategoryDisplayName(String categoryId) {
    final categoryMap = {
      'public-office': T.publicOffice,
      'education': T.education,
      'food': T.foodAndDrink,
      'transport': T.transportation,
      'hospital': T.healthAndHospitals,
      'mart': T.shoppingAndMarts,
      'bank': T.bankingAndFinance,
      'gadget': T.gadgets,
      'travel-agency': T.travelAndTourism,
      'hotel': T.hotels,
      'rentcar': T.carRental,
      'beauty': T.beautyAndWellness,
      'real-estate': T.realEstate,
      'ktv': T.entertainment,
      'spa': T.spaAndRelaxation,
      'etc': T.otherServices,
    };

    return categoryMap[categoryId.toLowerCase()] ?? categoryId;
  }

  /// 설명 콘텐츠 빌드 (Build description content)
  Widget _buildDescriptionContent() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      company!.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
        height: 1.6,
      ),
    );
  }

  /// 정보 행 빌드 (Build info row)
  ///
  /// 아이콘, 라벨, 값을 포함하는 행을 생성합니다.
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FaIcon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
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
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// 업체 헤더 이미지 위젯 (Company Header Image Widget)
///
/// SliverAppBar의 배경으로 표시되는 업체 타이틀 이미지입니다.
class CompanyHeaderImage extends StatelessWidget {
  const CompanyHeaderImage({super.key, required this.titleImageUrl});
  final String titleImageUrl;

  @override
  Widget build(BuildContext context) {
    if (titleImageUrl.isNotEmpty) {
      return Image.network(
        titleImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const CompanyImagePlaceholder(iconOpacity: 0.5);
        },
      );
    }

    return const CompanyImagePlaceholder(iconOpacity: 0.5);
  }
}

/// 업체 로고 위젯 (Company Logo Widget)
///
/// 업체 로고를 표시하는 둥근 컨테이너입니다.
/// Best Practice: surfaceContainerLowest 배경, outlineVariant 테두리
class CompanyLogo extends StatelessWidget {
  final Company company;

  const CompanyLogo({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
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
