import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/point/point_advertisement.model.dart';

/// 포인트 광고 목록 위젯
///
/// 게시글 목록 상단에 표시되는 포인트 광고 목록.
/// 광고가 없으면 빈 위젯을 반환한다.
class PointAdvertisements extends StatelessWidget {
  final List<PointAdvertisement> advertisements;
  final void Function(PointAdvertisement ad) onTap;

  const PointAdvertisements({
    super.key,
    required this.advertisements,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (advertisements.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      color: scheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightBullhorn,
                  size: 12,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '포인트 광고'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 광고 아이템
          ...advertisements.map((ad) => _buildAdItem(context, ad)),
          Divider(height: 1, color: scheme.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildAdItem(BuildContext context, PointAdvertisement ad) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: () => onTap(ad),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            // 썸네일 이미지
            if (ad.resolvedThumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: ad.resolvedThumbnail,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) =>
                      const SizedBox(width: 56, height: 56),
                ),
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 24,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 10),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ad.subject,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '조회 ${_formatNumber(ad.noOfView)}'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      _separator(scheme),
                      Text(
                        'D-${ad.remainingDays}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (ad.noOfComment > 0) ...[
                        _separator(scheme),
                        Text(
                          '댓글 ${ad.noOfComment}'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

  Widget _separator(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: TextStyle(
          fontSize: 11,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
