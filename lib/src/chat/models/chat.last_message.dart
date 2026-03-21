class LastMessage {
  final String senderUid;
  final int sentAt;
  final String text;

  const LastMessage({
    required this.senderUid,
    required this.sentAt,
    required this.text,
  });

  factory LastMessage.fromJson(Map<dynamic, dynamic> json) {
    return LastMessage(
      senderUid: json['senderUid'] ?? '',
      sentAt: json['sentAt'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}
