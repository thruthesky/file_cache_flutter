import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// 광고 연락처 카드 타입
enum ContactType {
  kakaotalk,
  telegram,
  phone,
  wechat,
  line,
  messenger,
}

/// 광고 연락처 카드 위젯
///
/// 각 연락처 타입에 맞는 스타일과 클릭 동작을 제공한다.
/// Flat Design — border/shadow 없이 배경색으로 구분.
class AdvertisementContactCard extends StatelessWidget {
  final ContactType type;
  final String id;
  final String? url;
  final String? qrImage;

  const AdvertisementContactCard({
    super.key,
    required this.type,
    required this.id,
    this.url,
    this.qrImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: FaIcon(_icon, color: _iconColor, size: 32)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    id,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _description,
                    style: TextStyle(
                      fontSize: 12,
                      color: _textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (qrImage != null && qrImage!.isNotEmpty) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  qrImage!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            if (qrImage == null || qrImage!.isEmpty)
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: _textColor.withValues(alpha: 0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    String? targetUrl;

    switch (type) {
      case ContactType.kakaotalk:
        if (url != null && url!.isNotEmpty) targetUrl = url;
      case ContactType.telegram:
        final telegramId = id.replaceAll('@', '');
        targetUrl = url ?? 'https://t.me/$telegramId';
      case ContactType.phone:
        targetUrl = 'sms:$id';
      case ContactType.wechat:
        if (qrImage == null || qrImage!.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('WeChat ID: $id'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
        return;
      case ContactType.line:
        targetUrl = url ?? 'https://line.me/ti/p/~$id';
      case ContactType.messenger:
        targetUrl = url;
    }

    if (targetUrl != null && targetUrl.isNotEmpty) {
      final uri = Uri.parse(targetUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color get _backgroundColor => switch (type) {
        ContactType.kakaotalk => const Color(0xFFF7C815),
        ContactType.telegram => const Color(0xFF0077B5),
        ContactType.phone => const Color(0xFFE9ECEF),
        ContactType.wechat => const Color(0xFF07C160),
        ContactType.line => const Color(0xFF00B900),
        ContactType.messenger => const Color(0xFF0084FF),
      };

  Color get _iconBackgroundColor => switch (type) {
        ContactType.kakaotalk => const Color(0xFF3C1E1E).withValues(alpha: 0.1),
        ContactType.phone => const Color(0xFF343A40).withValues(alpha: 0.1),
        _ => Colors.white.withValues(alpha: 0.2),
      };

  IconData get _icon => switch (type) {
        ContactType.kakaotalk => FontAwesomeIcons.comment,
        ContactType.telegram => FontAwesomeIcons.telegram,
        ContactType.phone => FontAwesomeIcons.phone,
        ContactType.wechat => FontAwesomeIcons.weixin,
        ContactType.line => FontAwesomeIcons.line,
        ContactType.messenger => FontAwesomeIcons.facebookMessenger,
      };

  Color get _iconColor => switch (type) {
        ContactType.kakaotalk => const Color(0xFF3C1E1E),
        ContactType.phone => const Color(0xFF343A40),
        _ => Colors.white,
      };

  Color get _textColor => switch (type) {
        ContactType.kakaotalk => const Color(0xFF3C1E1E),
        ContactType.phone => const Color(0xFF343A40),
        _ => Colors.white,
      };

  String get _title => switch (type) {
        ContactType.kakaotalk => '카카오톡'.tr(),
        ContactType.telegram => '텔레그램'.tr(),
        ContactType.phone => '전화/문자'.tr(),
        ContactType.wechat => 'WeChat',
        ContactType.line => 'LINE',
        ContactType.messenger => '페이스북 메신저'.tr(),
      };

  String get _description => switch (type) {
        ContactType.kakaotalk => '터치하여 카카오톡 친구 추가'.tr(),
        ContactType.telegram => '터치하여 텔레그램 대화 시작'.tr(),
        ContactType.phone => '터치하여 문자 보내기'.tr(),
        ContactType.wechat => 'QR 코드를 스캔하세요'.tr(),
        ContactType.line => '터치하여 라인 친구 추가'.tr(),
        ContactType.messenger => '터치하여 메신저 대화 시작'.tr(),
      };
}
