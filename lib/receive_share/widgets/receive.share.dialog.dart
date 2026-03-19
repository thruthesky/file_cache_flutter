import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/category/category.list.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/list/chat.room_join_list.builder.dart';
import 'package:philgo/chat/models/chat.join.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/receive_share/receive.share.functions.dart';
import 'package:philgo/receive_share/receive.share.service.dart';
import 'package:philgo/receive_share/widgets/share.where.button.dart';
import 'package:philgo/router.dart';
import 'package:philgo/user/widgets/avatar.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ReceiveShareDialog extends StatefulWidget {
  const ReceiveShareDialog({super.key, required this.data});

  final List<SharedMediaFile> data;

  @override
  State<ReceiveShareDialog> createState() => _ReceiveShareDialogState();
}

class _ReceiveShareDialogState extends State<ReceiveShareDialog> {
  String tab = '';

  Map<String, String> status = {};

  String getRoomName(ChatJoin join) {
    if (join.customName.isNotEmpty) {
      return join.customName;
    }

    if (isSingleChatRoom(join.id)) {
      return join.userDisplayName.isNotEmpty ? join.userDisplayName : 'no name';
    } else {
      return join.roomName.isNotEmpty ? join.roomName : 'No room name';
    }
  }

  Future<void> sendToChat(ChatJoin room) async {
    status[room.id] = 'sending';
    setState(() {});
    try {
      await sendReceiveShareToChat(room.id, widget.data);
      status[room.id] = 'sent';
      setState(() {});
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, e.toString());
        status[room.id] = '';
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  "Receive Share",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (tab.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Text(
                    forumCategories.isNotEmpty
                        ? "Choose Post or Chat"
                        : "Choose Chat",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 16,
                    children: [
                      if (forumCategories.isNotEmpty)
                        Expanded(
                          child: ShareWhereButton(
                            onTap: () => setState(() => tab = 'post'),
                            text: "Create Post",
                            color: Colors.blue,
                            icon: FaIcon(
                              FontAwesomeIcons.thinSquarePlus,
                              size: 64,
                            ),
                            primaryColor: Colors.blue.shade800,
                            secondaryColor: Colors.white,
                          ),
                        ),
                      Expanded(
                        child: ShareWhereButton(
                          onTap: () {
                            setState(() => tab = 'chat');
                          },
                          text: "Send to chat friend",
                          color: Colors.orange,
                          icon: FaIcon(size: 64, FontAwesomeIcons.thinComments),
                          primaryColor: Colors.blue.shade50,
                          secondaryColor: Colors.orangeAccent.shade100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (tab == 'chat') ...[
              Row(
                children: [
                  Text("2. Select a friend to send"),
                  IconButton(
                    onPressed: () => setState(() => tab = ''),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: ChatRoomJoinListBuilder(
                  builder: (context, join) => Card(
                    key: Key(join.id),
                    child: ListTile(
                      leading: Avatar(photoUrl: join.userPhotoUrl),
                      title: Text(getRoomName(join)),
                      trailing: OutlinedButton(
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: status[join.id] == 'sending'
                            ? null
                            : () async {
                                if (status[join.id] == 'sent') {
                                  if (globalContext.mounted) {
                                    ChatRoomScreen.push(globalContext, join.id);
                                  }
                                  return;
                                }
                                sendToChat(join);
                              },
                        child: status[join.id] == 'sending'
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : status[join.id] == 'sent'
                            ? Text("Open")
                            : Text("Send"),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (tab == 'post') ...[
              Row(
                children: [
                  Text("2. Select a category to post"),
                  IconButton(
                    onPressed: () => setState(() => tab = ''),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: CategoryList(
                    /// 카테고리 선택 시 콜백 호출
                    /// Call callback when category is selected
                    onTap: (String postId, String? category) {
                      ReceiveShareService.instance.onCategorySelect?.call(
                        postId,
                        category,
                        widget.data,
                      );
                    },
                  ),
                ),
              ),
            ],
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
