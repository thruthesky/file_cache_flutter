import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/list/chat.room_list_tile.dart';
import 'package:philgo/chat/models/chat.join.dart';

class ChatRoomListView extends StatelessWidget {
  final void Function(String roomId) onTap;

  const ChatRoomListView({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      reverseQuery: true,
      query: singleChatRoomListQuery(),
      pageSize: 20,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          return Center(
            // "Error: {}"
            child: Text('오류: {}'.tr(args: [snapshot.error.toString()])),
          );
        }

        if (snapshot.docs.isEmpty) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Center(
            child: Padding(
              padding: emptyStatePadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Comic design - empty state container with 2.0px border
                  Container(
                    padding: emptyStateContainerPadding,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.1,
                      ),
                      // Comic design - rounded corners 12 for large elements
                      borderRadius: BorderRadius.circular(
                        emptyStateBorderRadius,
                      ),
                      // Comic design - 2.0px outline border
                      border: Border.all(
                        color: colorScheme.outline,
                        width: emptyStateBorderWidth,
                      ),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.lightComments,
                      size: emptyStateIconSize,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: emptyStateSpacing),
                  Text(
                    // "Your friends list is empty"
                    '친구 목록이 비어있습니다'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: dialogButtonSpacing),
                  Text(
                    // "Start a conversation to see it here"
                    '대화를 시작하면 여기에 표시됩니다'.tr(),
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
          padding: roomListPadding,
          itemCount: snapshot.docs.length + (snapshot.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= snapshot.docs.length) {
              return Padding(
                padding: roomListLoadingPadding,
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
