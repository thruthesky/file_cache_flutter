// ignore_for_file: constant_identifier_names

const String NICKNAME = 'nickname';
const String NICKNAME_LOWER_CASE = 'nicknameLowerCase';

const String USERS = 'users';
const String DISPLAY_NAME = 'display_name';
const String PHOTO_URL = 'photoUrl';

const String ROOM = 'room';
const String MESSAGE = 'message';

const String ORDER = 'order';
const String SINGLE_ORDER = 'singleOrder';
const String GROUP_ORDER = 'groupOrder';
const String OPEN_ORDER = 'openOrder';

const String JOIN_NICKNAME = 'nickname';
const String JOIN_PHOTO_URL = 'photoUrl';

const String ROOM_USERS = 'users';
const String ROOM_MASTER_USERS = 'masterUsers';
const String ROOM_INVITED_USERS = 'invitedUsers';
const String ROOM_NAME = 'name';
const String ROOM_DESCRIPTION = 'description';
const String ROOM_IMAGE_URL = 'imageUrl';
const String ROOM_OPEN = 'open';
const String ROOM_TEST = 'test';
const String ROOM_BLOCK_ADVERTISEMENT = 'block_advertisement';

const String SENDER_UID = 'senderUid';
const String PROTOCOL = 'protocol';

const String SENT_AT = 'sentAt';

class RoomOrder {
  static const order = ORDER;
  static const singleOrder = SINGLE_ORDER;
  static const groupOrder = GROUP_ORDER;
  static const openOrder = OPEN_ORDER;
}

const String UNREAD = 'unread';
const String LAST_READ_AT = 'lastReadAt';

const String SINGLE_CHATROOM_JOIN_SEPARATOR = '---';

class ChatRoomApi {
  static String moderate = "moderate.chat";
}

/// Chat protocol constants for different message types
class ChatProtocol {
  static const String create = "protocol.create";
  static const String join = "protocol.join";
  static const String invitationNotSent = "protocol.invitationNotSent";
  static const String left = "protocol.left";
  static const String removed = "protocol.removed";

  /// Check if a protocol is a system protocol message
  static bool isProtocolMessage(String? protocol) {
    if (protocol == null) return false;
    return protocol.startsWith('protocol.');
  }

  /// Get all protocol constants
  static List<String> get allProtocols => [
    create,
    join,
    invitationNotSent,
    left,
    removed,
  ];
}

/// Available report reasons
const Map<String, String> reportReasons = {
  'spam': "Spam",
  'abusive': 'Abusive',
  'violence': 'Violence',
  'hate_speech': 'Hate Speech',
  'inappropriate_content': 'Inappropriate Content',
};

const String REPORT_PATH = 'path';
const String REPORT_REPORTER = 'reporter';
const String REPORT_REASON = 'reason';
const String REPORT_REPORTEE = 'reportee';
const String REPORT_CREATED_AT = 'created_at';

const String POST = 'post';
const String COMMENT = 'comment';
const String DEFAULT = 'default';

/// Chat configuration for global callbacks
/// 채팅 관련 전역 콜백 설정 클래스
///
/// Usage - 사용법:
/// ```dart
/// // Set callback in main app initialization
/// // 메인 앱 초기화 시 콜백 설정
/// ChatConfig.onMessageSent = () {
///   ChatSoundService.instance.playSendSound();
/// };
/// ```
class ChatConfig {
  /// Callback to be called when a message is successfully sent
  /// 메시지 전송 성공 시 호출될 콜백
  ///
  /// This is called after the message is saved to Firebase.
  /// Firebase에 메시지가 저장된 후 호출됩니다.
  static void Function()? onMessageSent;
}
