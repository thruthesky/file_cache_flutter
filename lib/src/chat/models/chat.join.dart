import 'package:firebase_database/firebase_database.dart';

class ChatJoin {
  final String? id;

  // Room information
  final String name;
  final String imageUrl;

  // User joined
  final int joinedAt;

  // User information of the last message
  final String nickname;
  final String photoUrl;

  // Last message information
  final String lastText;
  final String lastUrl;
  final String lastMessageUid;
  final int lastMessageAt;

  // Order information
  final int singleOrder;
  final int groupOrder;
  final int openOrder;
  final int order;

  // Unread message count
  final int unreadMessageCount;

  // Supabase user id (single user for navigation)
  final int otherUserId;

  const ChatJoin({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.joinedAt,
    required this.nickname,
    required this.photoUrl,
    required this.lastText,
    required this.lastUrl,
    required this.lastMessageUid,
    required this.lastMessageAt,
    required this.singleOrder,
    required this.groupOrder,
    required this.openOrder,
    required this.order,
    required this.unreadMessageCount,
    required this.otherUserId,
  });

  factory ChatJoin.fromSnapshot(DataSnapshot snapshot) {
    return ChatJoin.fromJson(snapshot.value as Map, snapshot.key!);
  }

  factory ChatJoin.fromJson(Map<dynamic, dynamic> json, String roomId) {
    return ChatJoin(
      id: roomId,
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      joinedAt: json['joined_at'] as int? ?? 0,
      nickname: json['nickname'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      lastText: json['last_text'] as String? ?? '',
      lastUrl: json['last_url'] as String? ?? '',
      lastMessageUid: json['last_message_uid'] as String? ?? '',
      lastMessageAt: json['last_message_at'] as int? ?? 0,
      singleOrder: json['single_order'] as int? ?? 0,
      groupOrder: json['group_order'] as int? ?? 0,
      openOrder: json['open_order'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
      unreadMessageCount: json['unread_message_count'] as int? ?? 0,
      otherUserId: json['other_user_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'joined_at': joinedAt,
      'nickname': nickname,
      'photo_url': photoUrl,
      'last_text': lastText,
      'last_url': lastUrl,
      'last_message_uid': lastMessageUid,
      'last_message_at': lastMessageAt,
      'single_order': singleOrder,
      'group_order': groupOrder,
      'open_order': openOrder,
      'order': order,
      'unread_message_count': unreadMessageCount,
      'other_user_id': otherUserId,
    };
  }

  @override
  String toString() {
    return 'ChatJoin(id: $id, name: $name, imageUrl: $imageUrl, joinedAt: $joinedAt, nickname: $nickname, photoUrl: $photoUrl, lastText: $lastText, lastUrl: $lastUrl, lastMessageUid: $lastMessageUid, lastMessageAt: $lastMessageAt, singleOrder: $singleOrder, groupOrder: $groupOrder, openOrder: $openOrder, order: $order, unreadMessageCount: $unreadMessageCount, otherUserId: $otherUserId)';
  }
}
