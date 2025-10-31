import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LibTr
/// returned by `LibTr.of(context)`.
///
/// Applications need to include `LibTr.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LibTr.localizationsDelegates,
///   supportedLocales: LibTr.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the LibTr.supportedLocales
/// property.
abstract class LibTr {
  LibTr(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LibTr? of(BuildContext context) {
    return Localizations.of<LibTr>(context, LibTr);
  }

  static const LocalizationsDelegate<LibTr> delegate = _LibTrDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get create_room;

  /// Button to create a new room
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// The name of the chat room
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get room_name;

  /// Prompt to enter the room name
  ///
  /// In en, this message translates to:
  /// **'Enter room name'**
  String get enter_room_name;

  /// Error message when room name is not provided
  ///
  /// In en, this message translates to:
  /// **'Room name is required'**
  String get room_name_required;

  /// Description of the chat room
  ///
  /// In en, this message translates to:
  /// **'Room Description'**
  String get room_description;

  /// Prompt to enter the room description
  ///
  /// In en, this message translates to:
  /// **'Enter room description'**
  String get enter_room_description;

  /// Toggle to open the room for everyone
  ///
  /// In en, this message translates to:
  /// **'Open Room'**
  String get open_room;

  /// Description of the open room toggle
  ///
  /// In en, this message translates to:
  /// **'Open for everyone to join'**
  String get open_room_description;

  /// Toggle to block advertisement messages in this room
  ///
  /// In en, this message translates to:
  /// **'Block Advertisement'**
  String get block_advertisement;

  /// Description of the block advertisement toggle
  ///
  /// In en, this message translates to:
  /// **'Block advertisement messages in this room'**
  String get block_advertisement_description;

  /// Indicates that a room is being created
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// Error message when room creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create room: {error}'**
  String failed_to_create_room(String error);

  /// Error message when room update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update room: {error}'**
  String failed_to_update_room(String error);

  /// Prompt to select a reason for reporting
  ///
  /// In en, this message translates to:
  /// **'Select report reason.'**
  String get report_select_reason;

  /// Message displayed when a report is submitted successfully
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get report_success;

  /// Message displayed when a message is already reported
  ///
  /// In en, this message translates to:
  /// **'This message has already been reported'**
  String get report_message_already_reported;

  /// Message displayed when a room is already reported
  ///
  /// In en, this message translates to:
  /// **'This room has already been reported'**
  String get report_room_already_reported;

  /// Message displayed when report submission fails
  ///
  /// In en, this message translates to:
  /// **'Report submission failed'**
  String get report_submission_failed;

  /// Message displayed when reporting a chat room
  ///
  /// In en, this message translates to:
  /// **'Report Chat Room'**
  String get report_chat_room;

  /// Message displayed when reporting a chat message
  ///
  /// In en, this message translates to:
  /// **'Report Chat Message'**
  String get report_chat_message;

  /// Button to close the report dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button to cancel the report
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button to submit the report
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get report_submit;

  /// Get localized text for report reason
  ///
  /// In en, this message translates to:
  /// **'{reason, select, spam {Spam} abusive {Abusive} violence {Violence} hate_speech {Hate Speech} inappropriate_content {Inappropriate Content} other {reason}}'**
  String get_report_reason(String reason);

  /// Button to save changes in the chat room
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Message displayed when editing a chat room is successful
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get edit_chat_room_success;

  /// Title of the edit chat room dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Chat Room'**
  String get edit_chat_room;

  /// Message displayed when profile photo is updated
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profile_photo_updated;

  /// Message displayed when upload fails
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String upload_photo_failed(String error);

  /// Message displayed when profile photo is removed
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed'**
  String get profile_photo_removed;

  /// Error message when failing to remove profile photo
  ///
  /// In en, this message translates to:
  /// **'Failed to remove profile photo: {error}'**
  String failed_to_remove_profile_photo(String error);

  /// Message displayed to show the number of members in a room
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String members_count(int count);

  /// Label for the menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Label for the edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Placeholder text for comment input field
  ///
  /// In en, this message translates to:
  /// **'Enter your comment'**
  String get enterComment;

  /// Label for the profile action
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Label for the recent post action
  ///
  /// In en, this message translates to:
  /// **'Recent Post'**
  String get recent_post;

  /// Label for the admin chat notice
  ///
  /// In en, this message translates to:
  /// **'This is a chat with our admin team.'**
  String get admin_chat_notice;

  /// Label for the report action
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// Label for the unblock user action
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblock_user;

  /// Label for the block user action
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get block_user;

  /// Label for the leave action
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// Label for the leave room action
  ///
  /// In en, this message translates to:
  /// **'Leave Room'**
  String get leave_room;

  /// Confirmation message displayed when a user tries to leave a room
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this room?'**
  String get leave_room_confirmation;

  /// Label for the chat room
  ///
  /// In en, this message translates to:
  /// **'Chat Room'**
  String get chat_room;

  /// Message displayed when a room is successfully created
  ///
  /// In en, this message translates to:
  /// **'Room has been created'**
  String get protocol_create;

  /// Message displayed when a user joins the room
  ///
  /// In en, this message translates to:
  /// **'{name} has joined the room'**
  String protocol_join(String name);

  /// Message displayed when an invitation is not sent
  ///
  /// In en, this message translates to:
  /// **'Invitation not sent'**
  String get protocol_invitation_not_sent;

  /// Message displayed when a user leaves the room
  ///
  /// In en, this message translates to:
  /// **'{name} left the room'**
  String protocol_left(String name);

  /// Message displayed when a user is removed from the room
  ///
  /// In en, this message translates to:
  /// **'{name} has been removed from the room'**
  String protocol_removed(String name);

  /// Message displayed when there is an error
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error_with_message(String message);

  /// Message displayed to prompt the user to send a message
  ///
  /// In en, this message translates to:
  /// **'Send a message to start a conversation'**
  String get send_message_to_start_conversation;

  /// Label for the error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Label for the OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Confirmation message for deletion
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete?'**
  String get want_to_delete;

  /// Confirm dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Message when no posts exist in a category
  ///
  /// In en, this message translates to:
  /// **'There are no posts in this category'**
  String get no_posts_in_category;

  /// Encouragement to create the first post
  ///
  /// In en, this message translates to:
  /// **'Be the first to post'**
  String get be_first_to_post;

  /// Button text to create a new post
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get create_post;

  /// Message displayed when the user leaves the room successfully
  ///
  /// In en, this message translates to:
  /// **'Left the room successfully'**
  String get leftroom_successfully;

  /// Message displayed when login is required
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get login_required;

  /// Message displayed to prompt the user to log in
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get please_log_in_to_continue;

  /// Message displayed when a message is moderated by AI
  ///
  /// In en, this message translates to:
  /// **'This message was blocked by AI moderation.'**
  String get message_moderated_by_ai;

  /// Message displayed when a message is moderated as an advertisement
  ///
  /// In en, this message translates to:
  /// **'This advertisement was blocked.'**
  String get message_moderated_as_advertisement;

  /// Message displayed for a blocked user
  ///
  /// In en, this message translates to:
  /// **'Message from blocked user (tap to unblock)'**
  String get blocked_message_tap_to_unblock;

  /// Label for the blocked user options
  ///
  /// In en, this message translates to:
  /// **'Blocked User Options'**
  String get blocked_user_options;

  /// Subtitle displayed for a blocked user
  ///
  /// In en, this message translates to:
  /// **'This user is currently blocked'**
  String get blocked_user_subtitle;

  /// Description displayed for the unblock user option
  ///
  /// In en, this message translates to:
  /// **'Allow this user to send you messages again'**
  String get unblock_user_description;

  /// Confirmation message displayed when blocking a user
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get block_user_confirmation;

  /// Warning message displayed when blocking a user
  ///
  /// In en, this message translates to:
  /// **'Blocking this user will prevent them from sending you messages.'**
  String get block_user_warning;

  /// Confirmation message displayed when unblocking a user
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock this user?'**
  String get unblock_user_confirmation;

  /// Message displayed when a user is unblocked
  ///
  /// In en, this message translates to:
  /// **'User has been unblocked'**
  String get user_unblocked;

  /// Message displayed when images are being uploaded
  ///
  /// In en, this message translates to:
  /// **'Uploading images'**
  String get uploading_images;

  /// Message displayed when the user reaches the maximum file selection limit
  ///
  /// In en, this message translates to:
  /// **'You can select up to {max} files.'**
  String max_files_reached(int max);

  /// Message displayed when a message fails to send
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String failed_to_send_message(String error);

  /// Label for the attach files button
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get attach_files;

  /// Placeholder text for the message input field
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get type_message;

  /// Select files
  ///
  /// In en, this message translates to:
  /// **'Select Files'**
  String get select_files;

  /// Camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Gallery
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Message displayed when failing to start a chat
  ///
  /// In en, this message translates to:
  /// **'Failed to start chat: {error}'**
  String failed_to_start_chat(String error);

  /// Label for the search friends dialog
  ///
  /// In en, this message translates to:
  /// **'Search Friends'**
  String get search_friends;

  /// Label for the search by nickname input field
  ///
  /// In en, this message translates to:
  /// **'닉네임으로 검색'**
  String get search_by_nickname;

  /// Message displayed when no users are found in the search
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get no_users_found;

  /// Label for the chat button
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Get localized text for empty chat list
  ///
  /// In en, this message translates to:
  /// **'{order, select, order {Empty Chat Room} single_order {Empty Friends List} group_order {Empty Group Chat} open_order {Empty Open Chat} other {Chatroom list is empty}}'**
  String empty_chat_list(String order);

  /// Label for the turn off notifications button
  ///
  /// In en, this message translates to:
  /// **'Turn off notifications'**
  String get turn_off_notifications;

  /// Label for the turn on notifications button
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get turn_on_notifications;

  /// Label for the current user
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Message displayed when there are no recent posts
  ///
  /// In en, this message translates to:
  /// **'No recent posts'**
  String get no_recent_posts;

  /// Label for the block button
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// Label for the unblock button
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// Message displayed when a user is successfully blocked
  ///
  /// In en, this message translates to:
  /// **'User successfully blocked.'**
  String get success_user_blocked;

  /// Message displayed when a user sends a message while blocked
  ///
  /// In en, this message translates to:
  /// **'Message from blocked user'**
  String get blocked_message;

  /// Time ago format for days
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String time_days_ago(int count);

  /// Time ago format for hours
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String time_hours_ago(int count);

  /// Time ago format for minutes
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String time_minutes_ago(int count);

  /// Time ago format for just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get time_just_now;

  /// Label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Label for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Label for now
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// Format for member count
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String member_count_formatted(int count);

  /// Option to take a photo using the camera
  ///
  /// In en, this message translates to:
  /// **'Take Photo with Camera'**
  String get take_photo_with_camera;

  /// Option to record a video using the camera
  ///
  /// In en, this message translates to:
  /// **'Record Video with Camera'**
  String get record_video_with_camera;

  /// Option to select media from the gallery
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get select_from_gallery;

  /// Option to upload a file from device storage
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get upload_file;

  /// Title for the upload option bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Select Upload Option'**
  String get select_upload_option;

  /// Button text to reply to a comment
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Button text for liking a post
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// Button text for commenting on a post
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// Button text for sharing a post
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Prompt to add the first comment to a post
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment'**
  String get beTheFirstToComment;

  /// Button text for updating a post or comment
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Title for updating a comment
  ///
  /// In en, this message translates to:
  /// **'Update Comment'**
  String get updateComment;

  /// Invite url
  ///
  /// In en, this message translates to:
  /// **'Invite url'**
  String get join_url;

  /// Message displayed when text is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied_to_clipboard;

  /// 1. Choose `create a post` or `send to chat`
  ///
  /// In en, this message translates to:
  /// **'1. Choose `create a post` or `send to chat`'**
  String get receive_share_choose_post_or_chat;

  /// 1. Choose `send to chat friend`
  ///
  /// In en, this message translates to:
  /// **'1. Choose `send to chat friend`'**
  String get receive_share_choose_chat;

  /// Choose `create a new post`
  ///
  /// In en, this message translates to:
  /// **'Create a new post'**
  String get receive_share_create_post;

  /// Only image or text can be sent to chat
  ///
  /// In en, this message translates to:
  /// **'Only image or text can be sent to chat'**
  String get receive_share_image_and_text_chat;

  /// Choose `send to chat friend`
  ///
  /// In en, this message translates to:
  /// **'Send to chat friend'**
  String get receive_share_send_chat;

  /// 2. Select a friend to send
  ///
  /// In en, this message translates to:
  /// **'2. Select a friend to send'**
  String get receive_share_choose_friend;

  /// 2. Select a category to post
  ///
  /// In en, this message translates to:
  /// **'2. Select a category to post'**
  String get receive_share_select_category;

  /// Label for the open button
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get receive_share_open;

  /// Label for the send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get receive_share_send;

  /// Label for the receive share dialog
  ///
  /// In en, this message translates to:
  /// **'Receive Share'**
  String get receive_share;

  /// Label for the view  button
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view_profile;
}

class _LibTrDelegate extends LocalizationsDelegate<LibTr> {
  const _LibTrDelegate();

  @override
  Future<LibTr> load(Locale locale) {
    return SynchronousFuture<LibTr>(lookupLibTr(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_LibTrDelegate old) => false;
}

LibTr lookupLibTr(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LibTrEn();
    case 'ja':
      return LibTrJa();
    case 'ko':
      return LibTrKo();
    case 'zh':
      return LibTrZh();
  }

  throw FlutterError(
    'LibTr.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
