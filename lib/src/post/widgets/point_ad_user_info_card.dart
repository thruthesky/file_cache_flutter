import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

class PointAdUserInfoCard extends StatelessWidget {
  const PointAdUserInfoCard({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 56,
            width: 56,
            child: UserPhoto(
              builder: (context, user) {
                final hasPhoto = user.photoUrl?.isNotEmpty == true;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: hasPhoto
                      ? Image.network(user.photoUrl!, fit: BoxFit.cover)
                      : Container(
                          color: scheme.primary.withValues(alpha: 0.12),
                          child: Center(
                            child: FaIcon(
                              FontAwesomeIcons.user,
                              size: 18,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserNickname(
                  builder: (context, nickname) => Text(
                    nickname,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    UserLevel(
                      builder: (level) => _buildChip(
                        context,
                        icon: FontAwesomeIcons.crown,
                        label: level.isNotEmpty ? 'Lv. $level' : 'Lv. --',
                      ),
                    ),
                    UserPoint(
                      builder: (points) => _buildChip(
                        context,
                        icon: FontAwesomeIcons.lightCoins,
                        label:
                            '${_formatPoints(points)} ${PhilgoTr.of(context)!.points}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
