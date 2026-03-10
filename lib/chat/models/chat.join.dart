import 'package:firebase_database/firebase_database.dart';
import 'package:philgo/chat/models/chat.last_message.dart';

class ChatJoin {
  final String id;

  // Room information
  final String roomName;

  final String customName;

  // User information of the last message
  final String userDisplayName;
  final String userDisplayNameLowerCase;
  final String userPhotoUrl;

  // Last message information
  final LastMessage lastMessage;

  // Order information
  final int singleOrder;
  final int groupOrder;
  final int openOrder;
  final int order;

  // Unread message count
  final int unread;

  const ChatJoin({
    required this.id,
    required this.roomName,
    required this.customName,
    required this.userDisplayName,
    required this.userDisplayNameLowerCase,
    required this.userPhotoUrl,
    required this.lastMessage,
    required this.singleOrder,
    required this.groupOrder,
    required this.openOrder,
    required this.order,
    required this.unread,
  });

  factory ChatJoin.fromSnapshot(DataSnapshot snapshot) {
    return ChatJoin.fromJson(snapshot.value as Map, snapshot.key!);
  }

  factory ChatJoin.fromJson(Map<dynamic, dynamic> json, String roomId) {
    return ChatJoin(
      id: roomId,
      roomName: json['roomName'] as String? ?? '',
      customName: json['customName'] as String? ?? '',
      userDisplayName: json['userDisplayName'] as String? ?? '',
      userDisplayNameLowerCase:
          json['userDisplayNameLowerCase'] as String? ?? '',
      userPhotoUrl: json['userPhotoUrl'] as String? ?? '',
      lastMessage: LastMessage.fromJson(json['lastMessage'] ?? {}),
      singleOrder: json['singleOrder'] as int? ?? 0,
      groupOrder: json['groupOrder'] as int? ?? 0,
      openOrder: json['openOrder'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      unread: json['unread'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomName': roomName,
      'customName': customName,
      'userDisplayName': userDisplayName,
      'userDisplayNameLowerCase': userDisplayNameLowerCase,
      'userPhotoUrl': userPhotoUrl,
      'singleOrder': singleOrder,
      'groupOrder': groupOrder,
      'openOrder': openOrder,
      'order': order,
      'unread': unread,
    };
  }

  @override
  String toString() {
    return 'ChatJoin(id: $id, roomName: $roomName, customName: $customName userDisplayName: $userDisplayName, userDisplayNameLowerCase: $userDisplayNameLowerCase, userPhotoUrl: $userPhotoUrl, lastMessage: ${lastMessage.senderUid}, ${lastMessage.sentAt}, ${lastMessage.text}, singleOrder: $singleOrder, groupOrder: $groupOrder, openOrder: $openOrder, order: $order, unread: $unread)';
  }
}
