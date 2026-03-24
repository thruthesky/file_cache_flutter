import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/globals.dart';

/// 업소록 그리드 카드 위젯
///
/// 이미지가 있으면 전체 카드에 이미지를 채우고, 하단에 반투명 오버레이로 업소명을 표시한다.
/// 이미지가 없으면 그라디언트 플레이스홀더와 카테고리 아이콘을 표시한다.
class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback? onTap;

  const CompanyCard({super.key, required this.company, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [_buildBackground(context), _buildBottomOverlay(context)],
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    final imageUrl = company.primaryImageUrl;
    if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildGradientPlaceholder(context),
        errorWidget: (context, url, error) =>
            _buildGradientPlaceholder(context),
      );
    }
    return _buildGradientPlaceholder(context);
  }

  Widget _buildGradientPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.primaryContainer,
            color.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: FaIcon(
          _categoryIcon(),
          size: 48,
          color: color.onPrimaryContainer.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  IconData _categoryIcon() {
    switch (company.category) {
      case 'public_services':
        return FontAwesomeIcons.buildingColumns;
      case 'education':
        return FontAwesomeIcons.graduationCap;
      case 'food':
        return FontAwesomeIcons.utensils;
      case 'transportation':
        return FontAwesomeIcons.bus;
      case 'health':
        return FontAwesomeIcons.heartPulse;
      case 'shopping':
        return FontAwesomeIcons.cartShopping;
      case 'banking':
        return FontAwesomeIcons.landmark;
      case 'gadgets':
        return FontAwesomeIcons.mobileScreen;
      case 'travel':
        return FontAwesomeIcons.planeDeparture;
      case 'hotels':
        return FontAwesomeIcons.hotel;
      case 'car_rental':
        return FontAwesomeIcons.car;
      case 'beauty':
        return FontAwesomeIcons.scissors;
      case 'real_estate':
        return FontAwesomeIcons.houseChimney;
      case 'entertainment':
        return FontAwesomeIcons.microphone;
      case 'spa':
        return FontAwesomeIcons.spa;
      default:
        return FontAwesomeIcons.buildingColumns;
    }
  }

  Widget _buildBottomOverlay(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 24, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                company.name.isNotEmpty ? company.name : '(이름 없음)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.ellipsis,
                color: Colors.white,
                size: 16,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
