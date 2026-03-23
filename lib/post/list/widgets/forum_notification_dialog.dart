import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/messaging/messaging.defines.dart';

/// 포럼 카테고리별 알림 구독 관리 다이얼로그
class ForumNotificationDialog extends StatelessWidget {
  const ForumNotificationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ForumNotificationDialog(),
    );
  }

  /// 카테고리의 구독 ID 생성 (postId 또는 postId-category)
  static String _subscriptionId(String postId, String? category) {
    if (category != null && category.isNotEmpty) {
      return 'forum-$postId-$category';
    }
    return 'forum-$postId';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return AlertDialog(
      title: Row(
        children: [
          FaIcon(FontAwesomeIcons.lightBell, size: 20, color: color.primary),
          const SizedBox(width: 8),
          // "Notification Settings"
          Text('알림 설정'.tr(), style: text.titleMedium),
        ],
      ),
      contentPadding: const EdgeInsets.only(top: 12, bottom: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: uid == null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  // "Login required"
                  '로그인이 필요합니다'.tr(),
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              )
            : _NotificationList(uid: uid),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          // "Close"
          child: Text('닫기'.tr()),
        ),
      ],
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    // 주요 게시판만 표시 (중복 postId 제거)
    final majorIds = Config.majorForumCategories();
    final categories = <(String, String?, String)>[];
    for (final cat in Config.forumCategories) {
      if (majorIds.contains(cat.$1) && cat.$2 == null) {
        categories.add(cat);
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final (postId, category, labelKey) = categories[index];
        final subId = ForumNotificationDialog._subscriptionId(
          postId,
          category,
        );
        return _NotificationItem(
          uid: uid,
          subscriptionId: subId,
          label: labelKey.tr(),
        );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.uid,
    required this.subscriptionId,
    required this.label,
  });

  final String uid;
  final String subscriptionId;
  final String label;

  Future<void> _toggle(bool isSubscribed) async {
    final ref = FirebaseDatabase.instance.ref(
      '${MessagingConfig.subscribePath}/$subscriptionId/$uid',
    );
    if (isSubscribed) {
      await ref.remove();
    } else {
      await ref.set(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref(
      '${MessagingConfig.subscribePath}/$subscriptionId/$uid',
    );

    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue,
      builder: (context, snapshot) {
        final isSubscribed =
            snapshot.hasData && snapshot.data!.snapshot.value == true;

        return ListTile(
          dense: true,
          leading: FaIcon(
            isSubscribed
                ? FontAwesomeIcons.solidBell
                : FontAwesomeIcons.lightBell,
            size: 18,
            color: isSubscribed ? color.primary : color.onSurfaceVariant,
          ),
          title: Text(label, style: text.bodyMedium),
          trailing: Switch.adaptive(
            value: isSubscribed,
            onChanged: (_) => _toggle(isSubscribed),
          ),
          onTap: () => _toggle(isSubscribed),
        );
      },
    );
  }
}
