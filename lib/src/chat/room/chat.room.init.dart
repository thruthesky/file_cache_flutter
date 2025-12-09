import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

class ChatRoomInit extends StatefulWidget {
  const ChatRoomInit({
    super.key,
    required this.id,
    required this.loading,
    required this.onRoomReady,
  });

  final String id;
  final Widget loading;
  final Function(ChatRoomInitState) onRoomReady;

  @override
  State<ChatRoomInit> createState() => ChatRoomInitState();
}

class ChatRoomInitState extends State<ChatRoomInit> {
  late final String roomId;
  String? otherUserUid;
  bool isSingleChat = false;
  late ChatRoom? _room;
  ChatRoom get room => _room!;
  User? otherUser;

  //
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

  @override
  Widget build(BuildContext context) {
    return isChatRoomLoading ? widget.loading : widget.onRoomReady(this);
  }

  Future<void> initializeChatRoom() async {
    try {
      // Get roomId and determine if it's single chat
      roomId = convertUidToSingleChatRoomId(widget.id);
      otherUserUid = getOtherUserUidFromChatRoomId(roomId);
      isSingleChat = isSingleChatRoom(widget.id) || isFirebaseUid(widget.id);

      // Get room information
      _room = await getChatRoom(roomId);
      if (_room == null) {
        log('--> room is null');
        // If single chat and no room exists, create it
        if (isSingleChat) {
          log(
            '--> It is single chat and room is null. Creating new chat room, otherUserUid: $otherUserUid',
          );
          final id = await createChatRoom(otherUserUid: otherUserUid!);
          log('--> id: $id');
          if (id == null) {
            if (mounted) {
              showErrorSnackBar(context, 'error_creating_chatroom');
            }
            return;
          }
          _room = await getChatRoom(roomId);
          log('--> _room: $_room');
        } else {
          log(
            '--> It is a group chat and room is null. It is a critical error and simply return with warning',
          );
          // Group chat room doesn't exist
          if (mounted) {
            showErrorSnackBar(context, 'group_chatroom_does_not_exist');
          }
          return;
        } // Join the room
      }

      if (_room != null) {
        await joinChatRoom(_room!);
        setupNewMessageListener();
      }

      // Load other user data for single chat
      if (isSingleChat && otherUserUid != null) {
        otherUserSubscription = FirebaseDatabase.instance
            .ref('users/$otherUserUid')
            .onValue
            .listen((event) {
              if (event.snapshot.exists) {
                setState(() {
                  otherUser = User.fromSnapshot(event.snapshot);
                });
                updateJoinRoomNickname(room, otherUser!.nickname);
                updateJoinRoomPhotoUrl(room, otherUser!.photoUrl);
              }
            });
      } // Reset unread message counter when user enters the room

      resetUnreadMessageCounter(roomId);
      setState(() => isChatRoomLoading = false);
    } catch (e, stack) {
      debugPrint('Error initializing chat room: $e');
      debugPrintStack(stackTrace: stack);
      if (mounted) {
        showErrorSnackBar(context, 'error_loading_chatroom');
        setState(() => isChatRoomLoading = false);
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
}
