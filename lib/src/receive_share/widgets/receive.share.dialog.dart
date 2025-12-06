import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
                  LibTr.of(context)!.receive_share,
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
                    PhilgoConfig.categories.isNotEmpty
                        ? LibTr.of(context)!.receive_share_choose_post_or_chat
                        : LibTr.of(context)!.receive_share_choose_chat,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    spacing: 16,
                    children: [
                      if (PhilgoConfig.categories.isNotEmpty)
                        Expanded(
                          child: ShareWhereButton(
                            onTap: () => setState(() => tab = 'post'),
                            text: LibTr.of(context)!.receive_share_create_post,
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
                        child: FutureBuilder(
                          future: canShareToChat(widget.data),
                          builder: (context, snapshot) {
                            final sharable = snapshot.data == true;
                            return ShareWhereButton(
                              onTap: () {
                                if (sharable) {
                                  setState(() => tab = 'chat');
                                } else {
                                  showErrorDialog(
                                    context,
                                    LibTr.of(
                                      context,
                                    )!.receive_share_image_and_text_chat,
                                  );
                                }
                              },
                              text: LibTr.of(context)!.receive_share_send_chat,
                              color: sharable
                                  ? Colors.orange
                                  : Colors.grey[300]!,
                              icon: FaIcon(
                                size: 64,
                                FontAwesomeIcons.thinComments,
                                // color: sharable
                                //     ? Colors.orange.shade800
                                //     : Colors.grey[300]!,
                              ),
                              primaryColor: Colors.blue.shade50,
                              secondaryColor: Colors.orangeAccent.shade100,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (tab == 'chat') ...[
              Row(
                children: [
                  Text(LibTr.of(context)!.receive_share_choose_friend),
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
                                  if (PhilgoConfig.globalContext.mounted) {
                                    ChatRoomScreen.push(
                                      PhilgoConfig.globalContext,
                                      join.id,
                                    );
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
                            ? Text(LibTr.of(context)!.receive_share_open)
                            : Text(LibTr.of(context)!.receive_share_send),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (tab == 'post') ...[
              Row(
                children: [
                  Text(LibTr.of(context)!.receive_share_select_category),
                  IconButton(
                    onPressed: () => setState(() => tab = ''),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: CategoryList(
                    onTap: (PostCategoryItem category) {
                      ReceiveShareService.instance.onCategorySelect?.call(
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
