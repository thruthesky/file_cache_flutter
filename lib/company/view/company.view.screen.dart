import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/edit/company.edit.screen.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 업소 상세 화면
///
/// SliverAppBar로 업소 대표 이미지를 펼쳐 보여주고,
/// 스크롤에 따라 AppBar가 축소되며 업소명이 타이틀로 표시된다.
/// 내 업소인 경우 수정 버튼이 표시된다.
class CompanyViewScreen extends StatefulWidget {
  final CompanyModel company;

  const CompanyViewScreen({super.key, required this.company});

  @override
  State<CompanyViewScreen> createState() => _CompanyViewScreenState();
}

class _CompanyViewScreenState extends State<CompanyViewScreen> {
  final ScrollController _scrollController = ScrollController();
  late CompanyModel _company;
  bool _isLoading = true;
  bool _isCollapsed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _company = widget.company;
    _scrollController.addListener(_onScroll);
    _loadCompany();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final collapsed =
        _scrollController.hasClients &&
        _scrollController.offset > (240 - kToolbarHeight);
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  }

  Future<void> _loadCompany() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final updated = await CompanyService.get(_company.idx);
      if (mounted && updated != null) {
        setState(() => _company = updated);
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isMyCompany {
    final user = context.read<UserState>().user;
    if (user == null) return false;
    return _company.idxMember == user.idx;
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CompanyEditScreen(company: _company)),
    );
    if (result == true && mounted) {
      _loadCompany();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getCategoryDisplayName(String categoryId) {
    const map = {
      'public-office': 'Public Office',
      'education': 'Education',
      'food': 'Food & Drink',
      'transport': 'Transportation',
      'hospital': 'Health & Hospitals',
      'mart': 'Shopping & Marts',
      'bank': 'Banking & Finance',
      'gadget': 'Gadgets',
      'travel-agency': 'Travel & Tourism',
      'hotel': 'Hotels',
      'rentcar': 'Car Rental',
      'beauty': 'Beauty & Wellness',
      'real-estate': 'Real Estate',
      'ktv': 'Entertainment',
      'spa': 'Spa & Relaxation',
      'etc': 'Other Services',
    };
    return map[categoryId.toLowerCase()] ?? categoryId;
  }

  bool _isUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  bool _hasValidLocation() {
    final loc = _company.location;
    final addr = _company.address;
    return (loc.isNotEmpty && !_isUrl(loc)) ||
        (addr.isNotEmpty && !_isUrl(addr));
  }

  String _getValidLocation() {
    final loc = _company.location;
    final addr = _company.address;
    if (loc.isNotEmpty && !_isUrl(loc)) return loc;
    if (addr.isNotEmpty && !_isUrl(addr)) return addr;
    return '';
  }

  bool _hasContactInfo() =>
      _company.phoneNumber.isNotEmpty ||
      _company.mobileNumber.isNotEmpty ||
      _company.kakaotalkId.isNotEmpty ||
      _company.telegramId.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: scheme.surfaceContainerLow,
            foregroundColor: scheme.onPrimaryContainer,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(height: 1.0, color: scheme.outlineVariant),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _isCollapsed ? null : Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: _isCollapsed
                ? Text(_company.name, style: theme.textTheme.titleLarge)
                : null,
            actions: [
              if (_isMyCompany)
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: _isCollapsed ? null : Colors.white,
                  ),
                  onPressed: _navigateToEdit,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(background: _buildHeaderImage()),
          ),

          // ── Body ──────────────────────────────────────────────────────
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              ),
            )
          else if (_errorMessage != null)
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
                        '업소 정보를 불러오지 못했습니다.',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadCompany,
                        icon: const FaIcon(
                          FontAwesomeIcons.arrowRotateRight,
                          size: 16,
                        ),
                        label: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 1. 기본 정보
                    _buildSection(
                      title: '업소 정보',
                      icon: FontAwesomeIcons.building,
                      child: _buildCompanyInfoContent(),
                    ),
                    const SizedBox(height: 28),

                    // 2. 연락처
                    if (_hasContactInfo()) ...[
                      _buildSection(
                        title: '연락처',
                        icon: FontAwesomeIcons.addressBook,
                        child: _buildContactContent(),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // 3. 설명
                    if (_company.description.isNotEmpty) ...[
                      _buildSection(
                        title: '상세 설명',
                        icon: FontAwesomeIcons.alignLeft,
                        child: _buildDescriptionContent(),
                      ),
                      const SizedBox(height: 28),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    final url = _company.primaryImageUrl;
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (ctx, u) => _buildImagePlaceholder(),
        errorWidget: (ctx, u, e) => _buildImagePlaceholder(),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: FaIcon(
          FontAwesomeIcons.buildingColumns,
          size: 64,
          color: Colors.white54,
        ),
      ),
    );
  }

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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              FaIcon(icon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
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

  Widget _buildCompanyInfoContent() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로고
            if (_company.logoUrl.isNotEmpty) ...[
              _CompanyLogo(logoUrl: _company.logoUrl),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _company.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_company.title.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _company.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (_company.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getCategoryDisplayName(_company.category),
                        style: theme.textTheme.labelMedium?.copyWith(
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

        if (_hasValidLocation()) ...[
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: FontAwesomeIcons.locationDot,
            label: '위치',
            value: _getValidLocation(),
          ),
        ],
      ],
    );
  }

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

  Widget _buildContactContent() {
    return Column(
      children: [
        if (_company.phoneNumber.isNotEmpty)
          _buildContactItem(
            icon: FontAwesomeIcons.phone,
            label: '전화번호',
            value: _company.phoneNumber,
            onTap: () => _launchUrl('tel:${_company.phoneNumber}'),
          ),
        if (_company.mobileNumber.isNotEmpty)
          _buildContactItem(
            icon: FontAwesomeIcons.mobileScreen,
            label: '휴대폰',
            value: _company.mobileNumber,
            onTap: () => _launchUrl('tel:${_company.mobileNumber}'),
          ),
        if (_company.kakaotalkId.isNotEmpty)
          _buildContactItem(
            icon: FontAwesomeIcons.comment,
            label: '카카오톡',
            value: _company.kakaotalkId,
            onTap: () =>
                _launchUrl('https://open.kakao.com/o/${_company.kakaotalkId}'),
          ),
        if (_company.telegramId.isNotEmpty)
          _buildContactItem(
            icon: FontAwesomeIcons.telegram,
            label: '텔레그램',
            value: _company.telegramId,
            onTap: () => _launchUrl('https://t.me/${_company.telegramId}'),
            isLast: true,
          ),
      ],
    );
  }

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
                FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 14,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 56),
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }

  Widget _buildDescriptionContent() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      _company.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
        height: 1.6,
      ),
    );
  }
}

/// 업체 로고 위젯
class _CompanyLogo extends StatelessWidget {
  final String logoUrl;

  const _CompanyLogo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        fit: BoxFit.cover,
        placeholder: (ctx, u) => const SizedBox(),
        errorWidget: (ctx, u, e) => Center(
          child: FaIcon(
            FontAwesomeIcons.building,
            color: scheme.onSurfaceVariant,
            size: 32,
          ),
        ),
      ),
    );
  }
}
