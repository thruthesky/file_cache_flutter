import 'package:flutter/material.dart';
import 'package:philgo/advertisement/widgets/advertisement_contact_card.dart';
import 'package:philgo/post/post.model.dart';

/// 광고 연락처 목록 위젯
///
/// Post 객체에서 연락처 정보를 추출하여 카드 형태로 표시한다.
/// 값이 있는 연락처만 표시된다.
///
/// ### 연락처 필드 매핑:
/// - 카카오톡 QR URL: varchar13
/// - 텔레그램 ID: varchar14
/// - 전화번호: varchar15
/// - 위챗 ID: varchar16, QR 이미지: text2
/// - 라인 ID: text3, QR URL: varchar20
/// - 페이스북 메신저 URL: varchar6 (varchar_6)
class AdvertisementContactList extends StatelessWidget {
  final Post post;
  final EdgeInsetsGeometry padding;

  const AdvertisementContactList({
    super.key,
    required this.post,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    final contactCards = <Widget>[];

    // 카카오톡 (varchar13: QR URL)
    if (_hasValue(post.varchar13)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.kakaotalk,
          id: post.varchar13,
          url: post.varchar13,
        ),
      );
    }

    // 텔레그램 (varchar14: ID)
    if (_hasValue(post.varchar14)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.telegram,
          id: post.varchar14,
        ),
      );
    }

    // 전화번호 (varchar15)
    if (_hasValue(post.varchar15)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.phone,
          id: post.varchar15,
        ),
      );
    }

    // 위챗 (varchar16: ID, text2: QR 이미지)
    if (_hasValue(post.varchar16)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.wechat,
          id: post.varchar16,
          qrImage: _hasValue(post.text2) ? post.text2 : null,
        ),
      );
    }

    // 라인 (text3: ID, varchar20: QR URL)
    if (_hasValue(post.text3)) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.line,
          id: post.text3,
          url: _hasValue(post.varchar20) ? post.varchar20 : null,
        ),
      );
    }

    // 페이스북 메신저 (varchar6: URL — 광고용)
    if (_hasValue(post.varchar6) && post.varchar6.startsWith('http')) {
      contactCards.add(
        AdvertisementContactCard(
          type: ContactType.messenger,
          id: 'Messenger',
          url: post.varchar6,
        ),
      );
    }

    if (contactCards.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contactCards,
      ),
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
