// ignore_for_file: constant_identifier_names

const String ROOM = 'room';
const String MESSAGE = 'message';

const String ORDER = 'order';
const String SINGLE_ORDER = 'single_order';
const String GROUP_ORDER = 'group_order';
const String OPEN_ORDER = 'open_order';

const String JOIN_NICKNAME = 'nickname';
const String JOIN_PHOTO_URL = 'photo_url';

const String ROOM_USERS = 'users';
const String ROOM_MASTER_USERS = 'master_users';
const String ROOM_INVITED_USERS = 'invited_users';
const String ROOM_NAME = 'name';
const String ROOM_DESCRIPTION = 'description';
const String ROOM_IMAGE_URL = 'image_url';
const String ROOM_OPEN = 'open';
const String ROOM_TEST = 'test';
const String ROOM_BLOCK_ADVERTISEMENT = 'block_advertisement';

const String SENDER_UID = 'sender_uid';
const String PROTOCOL = 'protocol';

const String CREATED_AT = 'created_at';

class RoomOrder {
  static const order = ORDER;
  static const singleOrder = SINGLE_ORDER;
  static const groupOrder = GROUP_ORDER;
  static const openOrder = OPEN_ORDER;
}

const String UNREAD_MESSAGE_COUNT = 'unread_message_count';

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
const List<String> reportReasons = [
  'spam',
  'abusive',
  'violence',
  'hate_speech',
  'inappropriate_content',
];
