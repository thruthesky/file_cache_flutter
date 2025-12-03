import 'package:flutter/material.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ChatRoomListView extends StatelessWidget {
  // singleOrder - returns a list of single chat rooms for the user
  // groupOrder - returns a list of group chat rooms for the user
  // openOrder - returns a list of open chat rooms
  // order - returns a list of chat rooms based on the user's order
  final String order;
  final void Function(String roomId) onTap;

  const ChatRoomListView({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Login(
      builder: (uid) => buildChatRoomList(uid: uid),
      notLoggedIn: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget buildChatRoomList({String? uid}) {
    return FirebaseDatabaseQueryBuilder(
      reverseQuery: true,
      query: uid != null
          ? roomQuery(order, uid)
          : roomQuery(RoomOrder.openOrder, ''),
      pageSize: 20,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              LibTr.of(context)!.error_with_message(snapshot.error.toString()),
            ),
          );
        }

        if (snapshot.docs.isEmpty) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Comic design - empty state container with 2.0px border
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.1,
                      ),
                      // Comic design - rounded corners 12 for large elements
                      borderRadius: BorderRadius.circular(12),
                      // Comic design - 2.0px outline border
                      border: Border.all(
                        color: colorScheme.outline,
                        width: 2.0,
                      ),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.lightComments,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    LibTr.of(context)!.empty_chat_list(order),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation to see it here',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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

            if (RoomOrder.openOrder == order || uid == null) {
              return ChatRoomListTile(
                key: ValueKey(doc.key),
                room: ChatRoom.fromSnapshot(doc),
                onTap: onTap,
              );
            }
            return ChatRoomListTile(
              key: ValueKey(doc.key),
              join: ChatJoin.fromSnapshot(doc),
              onTap: onTap,
            );
          },
        );
      },
    );
  }
}
