import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../l10n/philgo_tr.dart';

/// Displays an advertisement expiration row with calendar icon.
class PostAdExpiryBadge extends StatelessWidget {
  const PostAdExpiryBadge({super.key, required this.expiryTimestamp});

  /// Unix timestamp (seconds) when the advertisement expires.
  final int expiryTimestamp;

  String _formatTimestamp() {
    final date = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);
    return DateFormat('yyyy.MM.dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(
          FontAwesomeIcons.calendarDays,
          size: 14,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '${PhilgoTr.of(context)!.adExpiresLabel}: ${_formatTimestamp()}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
