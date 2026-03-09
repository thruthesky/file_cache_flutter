import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

import 'advertisement_contact_card.dart';

/// 광고 연락처 목록 위젯
///
/// Post 객체에서 연락처 정보를 추출하여 카드 형태로 표시합니다.
/// 값이 있는 연락처만 표시됩니다.
///
/// ### 연락처 필드 매핑:
/// - 카카오톡 ID: varchar11, QR URL: varchar13
/// - 텔레그램 ID: varchar14
/// - 전화번호: varchar15
/// - 위챗 ID: varchar16, QR 이미지: text2
/// - 라인 ID: text3, QR URL: varchar20
/// - 페이스북 메신저 URL: varchar10
///
/// ### 사용법:
/// ```dart
/// AdvertisementContactList(post: post)
/// ```
class AdvertisementContactList extends StatelessWidget {
  /// 연락처 정보를 담고 있는 Post 객체
  final Post post;

  /// 패딩 (기본값: 좌우 16)
  final EdgeInsetsGeometry padding;

  const AdvertisementContactList({
    super.key,
    required this.post,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    // 연락처 카드 목록 생성
    final contactCards = <Widget>[];

    // 카카오톡 (varchar11: ID, varchar13: QR URL)
    if (_hasValue(post.varchar11)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.kakaotalk,
          id: post.varchar11!,
          url: post.varchar13,
        ),
      );
    }

    // 텔레그램 (varchar14: ID)
    if (_hasValue(post.varchar14)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.telegram,
          id: post.varchar14!,
        ),
      );
    }

    // 전화번호 (varchar15: 번호)
    if (_hasValue(post.varchar15)) {
      contactCards.add(
        AdvertisementContactCard(type: ContactType.phone, id: post.varchar15!),
      );
    }

    // 위챗 (varchar16: ID, text2: QR 이미지)
    if (_hasValue(post.varchar16)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.wechat,
          id: post.varchar16!,
          qrImage: post.text2,
        ),
      );
    }

    // 라인 (text3: ID, varchar20: QR URL)
    if (_hasValue(post.text3)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.line,
          id: post.text3!,
          url: post.varchar20,
        ),
      );
    }

    // 페이스북 메신저 (varchar10: URL)
    if (_hasValue(post.varchar10)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.messenger,
          id: 'Messenger',
          url: post.varchar10,
        ),
      );
    }

    // 연락처가 없으면 빈 위젯 반환
    if (contactCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contactCards,
      ),
    );
  }

  /// 문자열이 null이 아니고 비어있지 않은지 확인
  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
