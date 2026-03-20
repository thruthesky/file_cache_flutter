// ignore_for_file: constant_identifier_names
class MessagingConfig {
  const MessagingConfig();

  static const String allUsersTopic = 'all_users';
  static const String tokenPath = "fcm-tokens";
  static const String subscribePath = "fcm-subscriptions";

  // v7 API to save FCM token to database
  static const String messagingSaveTokenApi = "fcm_token.save";
}

const String DEVICE = "device";
const String TOKEN = "fcm_token";
const String DOMAIN = "domain";
