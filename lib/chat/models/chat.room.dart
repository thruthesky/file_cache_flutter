import 'package:firebase_database/firebase_database.dart';

class ChatRoom {
  final String id;
  final String name;
  final String nickname;
  final String description;
  final String? imageUrl;
  final bool open;
  final int? openOrder;
  final int createdAt;
  final int? lastMessageAt;
  final String? lastMessageUid;
  final bool? blockAdvertisement;
  final bool test;
  final Map<String, bool> masterUsers;
  final Map<String, bool> users;
  final Map<String, bool> invitedUsers;

  ChatRoom({
    required this.id,
    required this.name,
    required this.nickname,
    required this.description,
    this.imageUrl,
    required this.open,
    this.openOrder,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessageUid,
    this.blockAdvertisement,
    this.test = false,
    this.masterUsers = const {},
    this.users = const {},
    this.invitedUsers = const {},
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      open: json['open'] ?? false,
      openOrder: json['open_order'],
      createdAt: json['created_at'] ?? 0,
      lastMessageAt: json['last_message_at'],
      lastMessageUid: json['last_message_uid'],
      blockAdvertisement: json['block_advertisement'],
      test: json['test'] ?? false,
      masterUsers: Map<String, bool>.from(json['master_users'] ?? {}),
      users: Map<String, bool>.from(json['users'] ?? {}),
      invitedUsers: Map<String, bool>.from(json['invited_users'] ?? {}),
    );
  }

  factory ChatRoom.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return ChatRoom(
      id: snapshot.key!,
      name: data['name'] ?? '',
      nickname: data['nickname'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'],
      open: data['open'] ?? false,
      openOrder: data['open_order'],
      createdAt: data['created_at'] ?? 0,
      lastMessageAt: data['last_message_at'],
      lastMessageUid: data['last_message_uid'],
      blockAdvertisement: data['block_advertisement'],
      test: data['test'] ?? false,
      masterUsers: Map<String, bool>.from(data['master_users'] ?? {}),
      users: Map<String, bool>.from(data['users'] ?? {}),
      invitedUsers: Map<String, bool>.from(data['invited_users'] ?? {}),
    );
  }
}
