import 'package:firebase_database/firebase_database.dart';

class ChatMessage {
  final String? id;
  final String senderUid;
  final String? text;
  final List<String>? urls; // New field for multiple file URLs
  final int sentAt;
  final String? protocol;
  final String? moderated; // M = moderated by AI, A = advertisement
  final bool isDeleted;
  final bool isEdited;
  final int? editedAt;
  final int? deletedAt;
  final String? deletedBy;

  ChatMessage({
    this.id,
    required this.senderUid,
    this.text,
    this.urls,
    required this.sentAt,
    this.protocol,
    this.moderated,
    this.isDeleted = false,
    this.isEdited = false,
    this.editedAt,
    this.deletedAt,
    this.deletedBy,
  });
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderUid: json['senderUid'] ?? '',
      text: json['text'],
      urls: json['urls'] != null ? List<String>.from(json['urls']) : null,
      sentAt: json['sentAt'] ?? 0,
      protocol: json['protocol'],
      moderated: json['moderated'],
      isDeleted: json['isDeleted'] == true,
      isEdited: json['isEdited'] == true,
      editedAt: json['editedAt'],
      deletedAt: json['deletedAt'],
      deletedBy: json['deletedBy'],
    );
  }
  factory ChatMessage.fromDataSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) {
      throw Exception('Invalid data snapshot for ChatMessage');
    }

    return ChatMessage(
      id: snapshot.key,
      senderUid: data['senderUid'] ?? '',
      text: data['text'],
      urls: data['urls'] != null ? List<String>.from(data['urls']) : null,
      sentAt: data['sentAt'] ?? 0,
      protocol: data['protocol'],
      moderated: data['moderated'],
      isDeleted: data['isDeleted'] == true,
      isEdited: data['isEdited'] == true,
      editedAt: data['editedAt'],
      deletedAt: data['deletedAt'],
      deletedBy: data['deletedBy']?.toString(),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'senderUid': senderUid,
      'sentAt': sentAt,
    };

    if (id != null) data['id'] = id;
    if (text != null) data['text'] = text;
    if (urls != null && urls!.isNotEmpty) data['urls'] = urls;
    if (protocol != null) data['protocol'] = protocol;
    if (moderated != null) data['moderated'] = moderated;

    return data;
  }

  ChatMessage copyWith({
    String? id,
    String? senderUid,
    String? text,
    List<String>? urls,
    int? sentAt,
    String? protocol,
    String? moderated,
    bool? isDeleted,
    bool? isEdited,
    int? editedAt,
    int? deletedAt,
    String? deletedBy,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderUid: senderUid ?? this.senderUid,
      text: text ?? this.text,
      urls: urls ?? this.urls,
      sentAt: sentAt ?? this.sentAt,
      protocol: protocol ?? this.protocol,
      moderated: moderated ?? this.moderated,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderUid: $senderUid, text: $text, urls: $urls, sentAt: $sentAt, protocol: $protocol, moderated: $moderated, isDeleted: $isDeleted, isEdited: $isEdited)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.senderUid == senderUid &&
        other.text == text &&
        _listEquals(other.urls, urls) &&
        other.sentAt == sentAt &&
        other.protocol == protocol &&
        other.moderated == moderated &&
        other.isDeleted == isDeleted &&
        other.isEdited == isEdited;
  }

  @override
  int get hashCode {
    return Object.hash(id, senderUid, text, urls, sentAt, protocol, moderated, isDeleted, isEdited);
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? list1, List<T>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
