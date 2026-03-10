import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/models/chat.join.dart';
import 'package:philgo/router.dart';
import 'package:philgo/user/user.firebase_model.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/util/util.functions.dart';

class SingleChatRoomInit extends StatefulWidget {
  const SingleChatRoomInit({
    super.key,
    required this.id,
    required this.loading,
    required this.onRoomReady,
  });

  final String id;
  final Widget loading;
  final Function(SingleChatRoomInitState) onRoomReady;

  @override
  State<SingleChatRoomInit> createState() => SingleChatRoomInitState();
}

class SingleChatRoomInitState extends State<SingleChatRoomInit> {
  late String roomId;
  late String otherUserUid;
  late ChatJoin? _join;
  ChatJoin get join => _join!;
  UserFirebaseModel? otherUser;

  bool isChatRoomLoading = true;
  StreamSubscription<DatabaseEvent>? newMessageSubscription;
  StreamSubscription<DatabaseEvent>? otherUserSubscription;

  @override
  void initState() {
    super.initState();
    initializeChatRoom();
  }

  @override
  void dispose() {
    newMessageSubscription?.cancel();
    otherUserSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeChatRoom() async {
    try {
      // Get roomId and determine if it's single chat
      roomId = convertUidToSingleChatRoomId(widget.id);
      otherUserUid = getOtherUserUidFromChatRoomId(roomId)!;

      final join = await getChatJoin(roomId);
      if (join != null) {
        _join = join;
      }

      otherUser = await getUser(otherUserUid);
      if (otherUser != null) {
        _join = ChatJoin.fromJson({
          "userDisplayName": otherUser!.nickname,
          "userPhotoUrl": otherUser!.photoUrl,
        }, roomId);
      } else {
        otherUser = UserFirebaseModel.fromJson({'uid': otherUserUid});
      }

      // resetUnreadMessageCounter(roomId);
      resetChatJoin(otherUserUid);
      setupNewMessageListener();

      setState(() => isChatRoomLoading = false);
    } catch (e, stack) {
      debugPrint('Error initializing chat room: $e');
      debugPrintStack(stackTrace: stack);
      if (globalContext.mounted) {
        showErrorSnackBar(globalContext, "Error loading chat room");
        setState(() => isChatRoomLoading = false);
        if (Navigator.canPop(globalContext)) {
          Navigator.of(globalContext).pop();
        }
      }
    }
  }

  /// Sets up a listener for new messages to reset unread counter
  void setupNewMessageListener() {
    final messagesRef = FirebaseDatabase.instance
        .ref('chat/messages/$roomId')
        .orderByChild(SENT_AT)
        .limitToLast(1);

    newMessageSubscription = messagesRef.onChildAdded.listen((event) {
      // Reset unread message counter when new messages arrive while user is viewing the chat room
      // Only reset for actual user messages (without protocol)
      if (mounted) {
        final messageData = event.snapshot.value as Map<dynamic, dynamic>?;
        final protocol = messageData?['protocol'];

        // Only reset unread counter if message has no protocol (regular user message)
        if (protocol == null) {
          resetUnreadMessageCounter(roomId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isChatRoomLoading ? widget.loading : widget.onRoomReady(this);
  }
}
