import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// 광고 연락처 카드의 타입을 정의하는 열거형
///
/// 각 타입은 고유한 배경색, 아이콘, 클릭 동작을 가집니다.
enum ContactType {
  kakaotalk, // 카카오톡
  telegram, // 텔레그램
  phone, // 전화번호 (SMS)
  wechat, // 위챗
  line, // 라인
  messenger, // 페이스북 메신저
}

/// 광고 연락처 카드 위젯
///
/// 각 연락처 타입에 맞는 스타일과 클릭 동작을 제공합니다.
/// Flat Design을 적용하여 border와 shadow 없이 색상으로만 구분합니다.
///
/// ### 사용법:
/// ```dart
/// AdvertisementContactCard(
///   type: ContactType.kakaotalk,
///   id: 'myKakaoId',
///   url: 'https://open.kakao.com/...',
/// )
/// ```
class AdvertisementContactCard extends StatelessWidget {
  /// 연락처 타입 (카카오톡, 텔레그램, 전화번호 등)
  final ContactType type;

  /// 연락처 ID 또는 번호 (화면에 표시됨)
  final String id;

  /// 클릭 시 이동할 URL (없으면 기본 동작 수행)
  final String? url;

  /// QR 코드 이미지 URL (위챗 등에서 사용)
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
          // Flat Design: 배경색만 사용, border/shadow 없음
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // 아이콘 영역
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
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 타이틀 (연락처 종류)
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ID/번호 (굵은 글씨)
                  Text(
                    id,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // 설명 텍스트
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
            // QR 이미지 영역 (위챗 등에서 사용)
            if (qrImage != null && qrImage!.isNotEmpty) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  qrImage!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
            // 화살표 아이콘 (QR 이미지가 없을 때만)
            if (qrImage == null || qrImage!.isEmpty) ...[
              FaIcon(
                FontAwesomeIcons.chevronRight,
                color: _textColor.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 카드 클릭 시 동작 처리
  Future<void> _handleTap(BuildContext context) async {
    print('=== [AdvertisementContactCard] _handleTap 시작 ===');
    print('[DEBUG] type: $type');
    print('[DEBUG] id: $id');
    print('[DEBUG] url: $url');
    print('[DEBUG] qrImage: $qrImage');

    String? targetUrl;

    switch (type) {
      case ContactType.kakaotalk:
        print('[DEBUG] 카카오톡 처리 시작');
        // 카카오톡: 직접 launchUrl()로 열지 않고, 웹 브라우저를 통해 중간 페이지를 열어서
        // 사용자가 클릭하여 카카오톡 앱을 열도록 함 (앱에서 직접 열기가 불안정하기 때문)
        // link.philgo.com 서브도메인 사용 - philgo.com은 앱 deep link로 처리되므로 피함
        if (url != null && url!.isNotEmpty) {
          // 카카오톡 프로필 QR 링크를 URL 인코딩하여 파라미터로 전달
          targetUrl = url;
        }
        break;
      case ContactType.telegram:
        print('[DEBUG] 텔레그램 처리 시작');
        // 텔레그램: https://t.me/{id} 형식으로 열기
        final telegramId = id.replaceAll('@', '');
        targetUrl = url ?? 'https://t.me/$telegramId';
        print('[DEBUG] 텔레그램 targetUrl: $targetUrl');
        break;
      case ContactType.phone:
        print('[DEBUG] 전화 처리 시작');
        // 전화번호: SMS 앱 열기
        targetUrl = 'sms:$id';
        print('[DEBUG] 전화 targetUrl: $targetUrl');
        break;
      case ContactType.wechat:
        print('[DEBUG] 위챗 처리 시작');
        // 위챗: QR 이미지가 있으면 클릭 무시 (이미지만 표시)
        if (qrImage == null || qrImage!.isEmpty) {
          print('[DEBUG] 위챗 QR 이미지 없음 - 스낵바 표시');
          // QR 이미지가 없으면 스낵바로 안내
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('WeChat ID: $id'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          print('[DEBUG] 위챗 QR 이미지 있음 - 클릭 무시');
        }
        print('[DEBUG] 위챗 처리 종료 (return)');
        return;
      case ContactType.line:
        print('[DEBUG] 라인 처리 시작');
        // 라인: QR URL이 있으면 해당 URL 열기, 없으면 기본 형식
        targetUrl = url ?? 'https://line.me/ti/p/~$id';
        print('[DEBUG] 라인 targetUrl: $targetUrl');
        break;
      case ContactType.messenger:
        print('[DEBUG] 메신저 처리 시작');
        // 페이스북 메신저: URL 열기
        targetUrl = url;
        print('[DEBUG] 메신저 targetUrl: $targetUrl');
        break;
    }

    print('[DEBUG] switch 완료, targetUrl: $targetUrl');

    if (targetUrl != null && targetUrl.isNotEmpty) {
      print('[DEBUG] targetUrl이 유효함, Uri.parse 시도');
      final uri = Uri.parse(targetUrl);
      print('[DEBUG] Uri.parse 완료: $uri');
      print('[DEBUG] uri.scheme: ${uri.scheme}');
      print('[DEBUG] uri.host: ${uri.host}');
      print('[DEBUG] uri.path: ${uri.path}');
      print('[DEBUG] uri.queryParameters: ${uri.queryParameters}');

      // canLaunchUrl 체크도 로그로 확인
      final canLaunch = await canLaunchUrl(uri);
      print('[DEBUG] canLaunchUrl 결과: $canLaunch');

      // 외부 브라우저에서 URL 열기
      // link.philgo.com 서브도메인을 사용하여 앱 deep link 문제 피함
      print('[DEBUG] launchUrl 시도 (LaunchMode.externalApplication)');
      try {
        final result = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('[DEBUG] launchUrl 결과: $result');
      } catch (e, stackTrace) {
        print('[ERROR] launchUrl 에러: $e');
        print('[ERROR] stackTrace: $stackTrace');
      }
    } else {
      print('[DEBUG] targetUrl이 null이거나 비어있음');
    }

    print('=== [AdvertisementContactCard] _handleTap 종료 ===');
  }

  /// 배경색 반환
  Color get _backgroundColor {
    switch (type) {
      case ContactType.kakaotalk:
        return const Color(0xFFF7C815); // 노란색
      case ContactType.telegram:
        return const Color(0xFF0077B5); // 파란색
      case ContactType.phone:
        return const Color(0xFFE9ECEF); // 회색
      case ContactType.wechat:
        return const Color(0xFF07C160); // 초록색
      case ContactType.line:
        return const Color(0xFF00B900); // 초록색
      case ContactType.messenger:
        return const Color(0xFF0084FF); // 파란색
    }
  }

  /// 아이콘 배경색 반환
  Color get _iconBackgroundColor {
    switch (type) {
      case ContactType.kakaotalk:
        return const Color(0xFF3C1E1E).withValues(alpha: 0.1);
      case ContactType.telegram:
        return Colors.white.withValues(alpha: 0.2);
      case ContactType.phone:
        return const Color(0xFF343A40).withValues(alpha: 0.1);
      case ContactType.wechat:
        return Colors.white.withValues(alpha: 0.2);
      case ContactType.line:
        return Colors.white.withValues(alpha: 0.2);
      case ContactType.messenger:
        return Colors.white.withValues(alpha: 0.2);
    }
  }

  /// 아이콘 반환 (Font Awesome Light 우선)
  IconData get _icon {
    switch (type) {
      case ContactType.kakaotalk:
        return FontAwesomeIcons.comment; // 카카오톡 아이콘
      case ContactType.telegram:
        return FontAwesomeIcons.telegram; // 텔레그램 브랜드 아이콘
      case ContactType.phone:
        return FontAwesomeIcons.phone; // 전화 아이콘
      case ContactType.wechat:
        return FontAwesomeIcons.weixin; // 위챗 브랜드 아이콘
      case ContactType.line:
        return FontAwesomeIcons.line; // 라인 브랜드 아이콘
      case ContactType.messenger:
        return FontAwesomeIcons.facebookMessenger; // 메신저 브랜드 아이콘
    }
  }

  /// 아이콘 색상 반환
  Color get _iconColor {
    switch (type) {
      case ContactType.kakaotalk:
        return const Color(0xFF3C1E1E); // 갈색
      case ContactType.telegram:
        return Colors.white;
      case ContactType.phone:
        return const Color(0xFF343A40); // 진한 회색
      case ContactType.wechat:
        return Colors.white;
      case ContactType.line:
        return Colors.white;
      case ContactType.messenger:
        return Colors.white;
    }
  }

  /// 텍스트 색상 반환
  Color get _textColor {
    switch (type) {
      case ContactType.kakaotalk:
        return const Color(0xFF3C1E1E); // 갈색
      case ContactType.telegram:
        return Colors.white;
      case ContactType.phone:
        return const Color(0xFF343A40); // 진한 회색
      case ContactType.wechat:
        return Colors.white;
      case ContactType.line:
        return Colors.white;
      case ContactType.messenger:
        return Colors.white;
    }
  }

  /// 타이틀 반환
  String get _title {
    switch (type) {
      case ContactType.kakaotalk:
        return '카카오톡';
      case ContactType.telegram:
        return '텔레그램';
      case ContactType.phone:
        return '전화/문자';
      case ContactType.wechat:
        return 'WeChat';
      case ContactType.line:
        return 'LINE';
      case ContactType.messenger:
        return '페이스북 메신저';
    }
  }

  /// 설명 텍스트 반환
  String get _description {
    switch (type) {
      case ContactType.kakaotalk:
        return '터치하여 카카오톡 친구 추가';
      case ContactType.telegram:
        return '터치하여 텔레그램 대화 시작';
      case ContactType.phone:
        return '터치하여 문자 보내기';
      case ContactType.wechat:
        return 'QR 코드를 스캔하세요';
      case ContactType.line:
        return '터치하여 라인 친구 추가';
      case ContactType.messenger:
        return '터치하여 메신저 대화 시작';
    }
  }
}
