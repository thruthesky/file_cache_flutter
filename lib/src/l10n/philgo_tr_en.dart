// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'philgo_tr.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class PhilgoTrEn extends PhilgoTr {
  PhilgoTrEn([String locale = 'en']) : super(locale);

  @override
  String get create_room => 'Create Room';

  @override
  String get create => 'Create';

  @override
  String get room_name => 'Room Name';

  @override
  String get enter_room_name => 'Enter room name';

  @override
  String get room_name_required => 'Room name is required';

  @override
  String get room_description => 'Room Description';

  @override
  String get enter_room_description => 'Enter room description';

  @override
  String get open_room => 'Open Room';

  @override
  String get open_room_description => 'Open for everyone to join';

  @override
  String get block_advertisement => 'Block Advertisement';

  @override
  String get block_advertisement_description =>
      'Block advertisement messages in this room';

  @override
  String get creating => 'Creating...';

  @override
  String failed_to_create_room(String error) {
    return 'Failed to create room: $error';
  }

  @override
  String failed_to_update_room(String error) {
    return 'Failed to update room: $error';
  }

  @override
  String get report_select_reason => 'Select report reason.';

  @override
  String get report_success => 'Report submitted successfully';

  @override
  String get report_failed => 'Report submission failed';

  @override
  String get report_message_already_reported =>
      'This message has already been reported';

  @override
  String get report_room_already_reported =>
      'This room has already been reported';

  @override
  String get report_submission_failed => 'Report submission failed';

  @override
  String get report_chat_room => 'Report Chat Room';

  @override
  String get report_chat_message => 'Report Chat Message';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get report_submit => 'Submit';

  @override
  String get_report_reason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'spam': 'Spam',
      'abusive': 'Abusive',
      'violence': 'Violence',
      'hate_speech': 'Hate Speech',
      'inappropriate_content': 'Inappropriate Content',
      'other': 'reason',
    });
    return '$_temp0';
  }

  @override
  String get save => 'Save';

  @override
  String get edit_chat_room_success => 'Success';

  @override
  String get edit_chat_room => 'Edit Chat Room';

  @override
  String get profile_photo_updated => 'Profile photo updated';

  @override
  String upload_photo_failed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get profile_photo_removed => 'Profile photo removed';

  @override
  String failed_to_remove_profile_photo(String error) {
    return 'Failed to remove profile photo: $error';
  }

  @override
  String members_count(int count) {
    return '$count members';
  }

  @override
  String get menu => 'Menu';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get delete_comment_confirmation =>
      'Are you sure you want to delete this comment?';

  @override
  String get successfully_deleted => 'Comment deleted successfully';

  @override
  String get enterComment => 'Enter your comment';

  @override
  String get profile => 'Profile';

  @override
  String get recent_post => 'Recent Post';

  @override
  String get admin_chat_notice => 'This is a chat with our admin team.';

  @override
  String get report => 'Report';

  @override
  String get unblock_user => 'Unblock User';

  @override
  String get block_user => 'Block User';

  @override
  String get leave => 'Leave';

  @override
  String get leave_room => 'Leave Room';

  @override
  String get leave_room_confirmation =>
      'Are you sure you want to leave this room?';

  @override
  String get chat_room => 'Chat Room';

  @override
  String get protocol_create => 'Room has been created';

  @override
  String protocol_join(String name) {
    return '$name has joined the room';
  }

  @override
  String get protocol_invitation_not_sent => 'Invitation not sent';

  @override
  String protocol_left(String name) {
    return '$name left the room';
  }

  @override
  String protocol_removed(String name) {
    return '$name has been removed from the room';
  }

  @override
  String error_with_message(String message) {
    return 'Error: $message';
  }

  @override
  String get send_message_to_start_conversation =>
      'Send a message to start a conversation';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get want_to_delete => 'Do you want to delete?';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get no_posts_in_category => 'There are no posts in this category';

  @override
  String get be_first_to_post => 'Be the first to post';

  @override
  String get create_post => 'Create Post';

  @override
  String get leftroom_successfully => 'Left the room successfully';

  @override
  String get login_required => 'Login required';

  @override
  String get please_log_in_to_continue => 'Please log in to continue';

  @override
  String get message_moderated_by_ai =>
      'This message was blocked by AI moderation.';

  @override
  String get message_moderated_as_advertisement =>
      'This advertisement was blocked.';

  @override
  String get blocked_message_tap_to_unblock =>
      'Message from blocked user (tap to unblock)';

  @override
  String get blocked_user_options => 'Blocked User Options';

  @override
  String get blocked_user_subtitle => 'This user is currently blocked';

  @override
  String get unblock_user_description =>
      'Allow this user to send you messages again';

  @override
  String get block_user_confirmation =>
      'Are you sure you want to block this user?';

  @override
  String get block_user_warning =>
      'Blocking this user will prevent them from sending you messages.';

  @override
  String get unblock_user_confirmation =>
      'Are you sure you want to unblock this user?';

  @override
  String get user_unblocked => 'User has been unblocked';

  @override
  String get uploading_images => 'Uploading images';

  @override
  String max_files_reached(int max) {
    return 'You can select up to $max files.';
  }

  @override
  String failed_to_send_message(String error) {
    return 'Failed to send message: $error';
  }

  @override
  String get attach_files => 'Attach files';

  @override
  String get type_message => 'Type a message...';

  @override
  String get select_files => 'Select Files';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String failed_to_start_chat(String error) {
    return 'Failed to start chat: $error';
  }

  @override
  String get search_friends => 'Search Friends';

  @override
  String get search_by_nickname => 'Search by nickname';

  @override
  String get no_users_found => 'No users found';

  @override
  String get chat => 'Chat';

  @override
  String empty_chat_list(String order) {
    String _temp0 = intl.Intl.selectLogic(order, {
      'order': 'Empty Chat Room',
      'single_order': 'Empty Friends List',
      'group_order': 'Empty Group Chat',
      'open_order': 'Empty Open Chat',
      'other': 'Chatroom list is empty',
    });
    return '$_temp0';
  }

  @override
  String get turn_off_notifications => 'Turn off notifications';

  @override
  String get turn_on_notifications => 'Turn on notifications';

  @override
  String get you => 'You';

  @override
  String get no_recent_posts => 'No recent posts';

  @override
  String get block => 'Block';

  @override
  String get unblock => 'Unblock';

  @override
  String get success_user_blocked => 'User successfully blocked.';

  @override
  String get blocked_message => 'Message from blocked user';

  @override
  String time_days_ago(int count) {
    return '${count}d ago';
  }

  @override
  String time_hours_ago(int count) {
    return '${count}h ago';
  }

  @override
  String time_minutes_ago(int count) {
    return '${count}m ago';
  }

  @override
  String get time_just_now => 'Just now';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get now => 'Now';

  @override
  String member_count_formatted(int count) {
    return '$count members';
  }

  @override
  String get take_photo_with_camera => 'Take Photo with Camera';

  @override
  String get record_video_with_camera => 'Record Video with Camera';

  @override
  String get select_from_gallery => 'Select from Gallery';

  @override
  String get upload_file => 'Upload File';

  @override
  String get select_upload_option => 'Select Upload Option';

  @override
  String get reply => 'Reply';

  @override
  String get like => 'Like';

  @override
  String get comment => 'Comment';

  @override
  String get share => 'Share';

  @override
  String get beTheFirstToComment => 'Be the first to comment';

  @override
  String get update => 'Update';

  @override
  String get updateComment => 'Update Comment';

  @override
  String get join_url => 'Invite url';

  @override
  String get copied_to_clipboard => 'Copied to clipboard';

  @override
  String get receive_share_choose_post_or_chat =>
      '1. Choose `create a post` or `send to chat`';

  @override
  String get receive_share_choose_chat => '1. Choose `send to chat friend`';

  @override
  String get receive_share_create_post => 'Create a new post';

  @override
  String get receive_share_image_and_text_chat =>
      'Only image or text can be sent to chat';

  @override
  String get receive_share_send_chat => 'Send to chat friend';

  @override
  String get receive_share_choose_friend => '2. Select a friend to send';

  @override
  String get receive_share_select_category => '2. Select a category to post';

  @override
  String get receive_share_open => 'Open';

  @override
  String get receive_share_send => 'Send';

  @override
  String get receive_share => 'Receive Share';

  @override
  String get view_profile => 'View';

  @override
  String get confirmDiscard => 'Are you sure you want to discard your changes?';

  @override
  String get confirm_delete_comment_image =>
      'Are you sure you want to delete this image?';

  @override
  String get bookmarked_folders => 'Bookmarked Folders';

  @override
  String get no_bookmarked_folders => 'No bookmarked folders';

  @override
  String get bookmarked_chats => 'Bookmarked Chats';

  @override
  String get no_bookmarked_chats => 'No bookmarked chats in this folder';

  @override
  String get unpin_chat_room_title => 'Unpin Chat Room';

  @override
  String get unpin_chat_room_message =>
      'Are you sure you want to unpin this chat room?';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get chat_room_unpinned => 'Chat room unpinned successfully';

  @override
  String get add_to_favorites => 'Add to Favorites';

  @override
  String added_to_folder(String folderName) {
    return 'Added to $folderName';
  }

  @override
  String removed_from_folder(String folderName) {
    return 'Removed from $folderName';
  }

  @override
  String failed_to_update_favorite(String error) {
    return 'Failed to update favorite: $error';
  }

  @override
  String get create_new_folder => 'Create New Folder';

  @override
  String get folder_name => 'Folder Name';

  @override
  String get enter_folder_name => 'Enter folder name';

  @override
  String chats_count(int count) {
    return '$count chats';
  }

  @override
  String get no_name => 'No Name';

  @override
  String get post_from_blocked_user => 'Post from blocked User';

  @override
  String get something_went_wrong => 'Something went wrong';

  @override
  String get enter_your_comment => 'Enter your comment...';

  @override
  String get comments => 'Comments';

  @override
  String get this_post_has_comments => 'This post has comments';

  @override
  String get be_the_first_to_comment => 'Be the first to comment!';

  @override
  String get comment_blocked_message => 'Comment from blocked user';

  @override
  String get pinned_chats => 'Pinned Chats';

  @override
  String get report_reason_category_error =>
      'Category classification error (advertisement)';

  @override
  String get report_reason_abuse => 'Harassment/Insult/Profanity';

  @override
  String get report_reason_spam => 'Spam/Flooding and inappropriate content';

  @override
  String get report_reason_other => 'Other';

  @override
  String get categoryFreetalk => 'FreeTalk';

  @override
  String get categoryQna => 'Q&A';

  @override
  String get categoryBuyandsell => 'Selling';

  @override
  String get categoryBlog => 'Blog';

  @override
  String get categoryBoardingHouse => 'Boarding House';

  @override
  String get categoryCaution => 'Caution';

  @override
  String get categoryLookfor => 'Looking For';

  @override
  String get categoryFoodDelivery => 'Food Delivery';

  @override
  String get categoryGreeting => 'Greetings';

  @override
  String get categoryWanted => 'Jobs';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryMassage => 'Massage';

  @override
  String get categoryRest => 'Restaurant';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryStudy => 'Study';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryYoutube => 'YouTube';

  @override
  String get categoryMomcafe => 'Mom Cafe';

  @override
  String get categoryNews => 'News';

  @override
  String get categoryNewcomer => 'Newcomer';

  @override
  String get categoryNature => 'Nature';

  @override
  String get categoryCompanyInfo => 'Company Info';

  @override
  String get categoryEnglishBiz => 'English Business';

  @override
  String get categoryTemp => 'Temporary';

  @override
  String get categoryTravelGood => 'Travel Recommendations';

  @override
  String get subCategoryDiscussion => 'Discussion';

  @override
  String get subCategoryEncyclopedia => 'Encyclopedia';

  @override
  String get subCategoryHobby => 'Hobby';

  @override
  String get subCategoryInfo => 'Info';

  @override
  String get subCategoryKoPhCouple => 'Couple';

  @override
  String get subCategoryKopino => 'Kopino';

  @override
  String get subCategoryImmigration => 'Immigration';

  @override
  String get subCategoryPhoto => 'Photo';

  @override
  String get subCategoryLifeTips => 'Life Tips';

  @override
  String get subCategoryMissing => 'Missing';

  @override
  String get subCategoryIntlMarriage => 'Marriage';

  @override
  String get subCategoryMeeting => 'Meetup';

  @override
  String get subCategoryColumn => 'Column';

  @override
  String get subCategoryMukbang => 'Mukbang';

  @override
  String get subCategoryNotice => 'Notice';

  @override
  String get subCategoryExperience => 'Knowhow';

  @override
  String get subCategoryStudyLearn => 'Study';

  @override
  String get subCategoryTyphoon => 'Typhoon';

  @override
  String get subCategoryBusinessPartner => 'Business Partner';

  @override
  String get subCategoryComputer => 'Computer/Internet';

  @override
  String get subCategoryExchange => 'Peso Exchange';

  @override
  String get subCategoryPhone => 'Phone Selling';

  @override
  String get subCategoryHotel => 'Hotel';

  @override
  String get subCategoryAppliances => 'Appliances';

  @override
  String get subCategoryGolf => 'Golf';

  @override
  String get subCategoryPromotion => 'Promotion';

  @override
  String get subCategoryPersonalMarket => 'Personal Market';

  @override
  String get subCategoryRealEstate => 'Realty';

  @override
  String get subCategoryHouseRental => 'House Rental';

  @override
  String get subCategoryCarRental => 'Rent-car';

  @override
  String get subCategoryUsedCar => 'Used Car';

  @override
  String get subCategoryManila => 'Manila';

  @override
  String get subCategoryCebu => 'Cebu';

  @override
  String get subCategoryAngeles => 'Angeles';

  @override
  String get categoryAll => 'All';

  @override
  String get currentPointBalance => 'Current Point Balance';

  @override
  String get pointAdvertisement => 'Point Advertisement';

  @override
  String pointAdvertisementWithDays(int days) {
    return 'Point Ad: $days days';
  }

  @override
  String pointAdvertisementAddDays(int days) {
    return 'Point Ad: +$days days';
  }

  @override
  String get pointAdvertisementDescription =>
      'Promote your post to the top of the list';

  @override
  String get days => 'days';

  @override
  String get points => 'Points';

  @override
  String daysAdvertisementCost(int days) {
    return ' days advertisement costs';
  }

  @override
  String get confirmSelection => 'Confirm Selection';

  @override
  String get selectAdvertisementDays => 'Select advertisement days';
}
