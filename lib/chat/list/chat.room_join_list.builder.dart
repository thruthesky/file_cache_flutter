import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/models/chat.join.dart';
import 'package:philgo/user/widgets/login.dart';

class ChatRoomJoinListBuilder extends StatelessWidget {
  const ChatRoomJoinListBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ChatJoin room) builder;

  @override
  Widget build(BuildContext context) {
    return Login(
      builder: (uid) => buildChatRoomList(uid),
      notLoggedIn: Center(
        child: Text(
          // "Login required"
          '로그인이 필요합니다'.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget buildChatRoomList(String uid) {
    return FirebaseDatabaseQueryBuilder(
      reverseQuery: true,
      query: singleChatRoomListQuery(),
      pageSize: 20,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          // "Error: {}"
          return Center(child: Text('오류: {}'.tr(args: [snapshot.error.toString()])));
        }

        if (snapshot.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info,
                  size: 80,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  // "Your friends list is empty"
                  '친구 목록이 비어있습니다'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.docs.length + (snapshot.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= snapshot.docs.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }

            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }

            final doc = snapshot.docs[index];
            if (doc.key == null || doc.value == null) {
              return const SizedBox.shrink();
            }

            return builder(context, ChatJoin.fromSnapshot(doc));
          },
        );
      },
    );
  }
}
