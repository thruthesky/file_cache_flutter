import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';

/// 업소 상세 화면
///
/// SliverAppBar로 업소 대표 이미지를 펼쳐 보여주고,
/// 그 아래에 업소 기본 정보와 연락처 정보를 카드 형태로 표시한다.
/// API를 통해 최신 업소 정보를 로드한다.
class CompanyViewScreen extends StatefulWidget {
  final CompanyModel company;

  const CompanyViewScreen({super.key, required this.company});

  @override
  State<CompanyViewScreen> createState() => _CompanyViewScreenState();
}

class _CompanyViewScreenState extends State<CompanyViewScreen> {
  late CompanyModel _company;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _company = widget.company;
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    setState(() => _isLoading = true);
    try {
      final updated = await CompanyService.get(_company.idx);
      if (mounted && updated != null) {
        setState(() => _company = updated);
      }
    } catch (_) {
      // keep existing data on error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        context,
                        icon: FontAwesomeIcons.buildingColumns,
                        label: 'Business Directory',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(context),
                      const SizedBox(height: 20),
                      _buildSectionHeader(
                        context,
                        icon: FontAwesomeIcons.addressCard,
                        label: 'Contact Information',
                      ),
                      const SizedBox(height: 12),
                      _buildContactCard(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(context),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    final imageUrl = _company.primaryImageUrl;
    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(context),
        errorWidget: (context, url, error) =>
            _buildImagePlaceholder(context),
      );
    }
    return _buildImagePlaceholder(context);
  }

  Widget _buildImagePlaceholder(BuildContext context) {
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        FaIcon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _company.name.isNotEmpty ? _company.name : '(이름 없음)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_company.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _company.title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (_company.category.isNotEmpty) ...[
              const SizedBox(height: 10),
              Chip(
                label: Text(_company.category),
                visualDensity: VisualDensity.compact,
              ),
            ],
            const Divider(height: 24),
            if (_company.address.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _company.address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final hasPhone = _company.phoneNumber.isNotEmpty;
    final hasMobile = _company.mobileNumber.isNotEmpty;
    final hasKakao = _company.kakaotalkId.isNotEmpty;
    final hasTelegram = _company.telegramId.isNotEmpty;

    if (!hasPhone && !hasMobile && !hasKakao && !hasTelegram) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '등록된 연락처 정보가 없습니다.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Column(
        children: [
          if (hasPhone)
            _buildContactTile(
              icon: FontAwesomeIcons.phone,
              title: 'Phone number',
              value: _company.phoneNumber,
            ),
          if (hasMobile)
            _buildContactTile(
              icon: FontAwesomeIcons.mobileScreen,
              title: 'Mobile Number',
              value: _company.mobileNumber,
            ),
          if (hasKakao)
            _buildContactTile(
              icon: FontAwesomeIcons.comment,
              title: 'KakaoTalk',
              value: _company.kakaotalkId,
            ),
          if (hasTelegram)
            _buildContactTile(
              icon: FontAwesomeIcons.paperPlane,
              title: 'Telegram',
              value: _company.telegramId,
            ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: FaIcon(icon, size: 18, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const FaIcon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: Colors.grey,
      ),
      isThreeLine: false,
      dense: true,
    );
  }
}
