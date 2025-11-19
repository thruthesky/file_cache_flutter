import 'package:firebase_database/firebase_database.dart';

class ChatMessage {
  final String? id;
  final String senderUid;
  final String? text;
  final List<String>? urls; // New field for multiple file URLs
  final int sentAt;
  final String? protocol;
  final String? moderated; // M = moderated by AI, A = advertisement

  ChatMessage({
    this.id,
    required this.senderUid,
    this.text,
    this.urls,
    required this.sentAt,
    this.protocol,
    this.moderated,
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
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderUid: senderUid ?? this.senderUid,
      text: text ?? this.text,
      urls: urls ?? this.urls,
      sentAt: sentAt ?? this.sentAt,
      protocol: protocol ?? this.protocol,
      moderated: moderated ?? this.moderated,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderUid: $senderUid, text: $text, urls: $urls, sentAt: $sentAt, protocol: $protocol, moderated: $moderated)';
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
        other.moderated == moderated;
  }

  @override
  int get hashCode {
    return Object.hash(id, senderUid, text, urls, sentAt, protocol, moderated);
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
