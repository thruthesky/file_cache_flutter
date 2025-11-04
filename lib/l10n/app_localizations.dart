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

/// Callers can lookup localized strings with an instance of Lo
/// returned by `Lo.of(context)`.
///
/// Applications need to include `Lo.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Lo.localizationsDelegates,
///   supportedLocales: Lo.supportedLocales,
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
/// be consistent with the languages listed in the Lo.supportedLocales
/// property.
abstract class Lo {
  Lo(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Lo? of(BuildContext context) {
    return Localizations.of<Lo>(context, Lo);
  }

  static const LocalizationsDelegate<Lo> delegate = _LoDelegate();

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

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// A field label for entering a name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Title for PhilGo Korean community carousel item
  ///
  /// In en, this message translates to:
  /// **'The Largest Korean Community in the Philippines'**
  String get philgoCommunityTitle;

  /// Subtitle for PhilGo Korean community carousel item
  ///
  /// In en, this message translates to:
  /// **'Find all the information about life in the Philippines on PhilGo'**
  String get philgoCommunitySubtitle;

  /// Title for real-time information sharing carousel item
  ///
  /// In en, this message translates to:
  /// **'Real-time Information Sharing'**
  String get realTimeInfoTitle;

  /// Subtitle for real-time information sharing carousel item
  ///
  /// In en, this message translates to:
  /// **'Check local news and living information in the Philippines in real-time'**
  String get realTimeInfoSubtitle;

  /// Title for business networking carousel item
  ///
  /// In en, this message translates to:
  /// **'Business Networking'**
  String get businessNetworkingTitle;

  /// Subtitle for business networking carousel item
  ///
  /// In en, this message translates to:
  /// **'Network with Koreans doing business in the Philippines'**
  String get businessNetworkingSubtitle;

  /// Title for safe community carousel item
  ///
  /// In en, this message translates to:
  /// **'Safe Community'**
  String get safeCommunityTitle;

  /// Subtitle for safe community carousel item
  ///
  /// In en, this message translates to:
  /// **'A trusted community with verified members'**
  String get safeCommunitySubtitle;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Chat navigation item label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Forum navigation item label
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get forum;

  /// Create/Write navigation item label
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Company/Business directory navigation item label
  ///
  /// In en, this message translates to:
  /// **'Directory'**
  String get company;

  /// Menu navigation item label
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// AppBar title for phone login
  ///
  /// In en, this message translates to:
  /// **'Login with Phone'**
  String get loginWithPhoneTitle;

  /// Header text above phone sign-in
  ///
  /// In en, this message translates to:
  /// **'Sign in using your phone number.'**
  String get loginWithPhoneHeader;

  /// Notice about SMS verification
  ///
  /// In en, this message translates to:
  /// **'We will send an SMS to verify your phone number.'**
  String get loginPhoneSmsNotice;

  /// Label/hint for phone number field
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// Short label for phone number
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// Label/hint for SMS code field
  ///
  /// In en, this message translates to:
  /// **'Enter SMS code'**
  String get enterSmsCode;

  /// Resend SMS button label
  ///
  /// In en, this message translates to:
  /// **'Resend SMS'**
  String get resendSms;

  /// Verify SMS code button label
  ///
  /// In en, this message translates to:
  /// **'Verify SMS code'**
  String get verifySmsCode;

  /// Verify phone number button label
  ///
  /// In en, this message translates to:
  /// **'Verify phone number'**
  String get verifyPhoneNumber;

  /// Button label to send an SMS verification code
  ///
  /// In en, this message translates to:
  /// **'Send SMS code'**
  String get sendSmsCode;

  /// Terms link label and dialog title
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Terms content placeholder
  ///
  /// In en, this message translates to:
  /// **'Terms of Service content'**
  String get termsContent;

  /// Privacy policy link label and dialog title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @phoneAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Phone number verification failed'**
  String get phoneAuthFailed;

  /// Community category label
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// Questions and Answers category label
  ///
  /// In en, this message translates to:
  /// **'Q&A'**
  String get qna;

  /// Discussion category label
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// Business category label
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// Buy and Sell category label
  ///
  /// In en, this message translates to:
  /// **'Buy & Sell'**
  String get buyAndSell;

  /// Hotel category label
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get hotel;

  /// Jobs category label
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// Number of posts in a category
  ///
  /// In en, this message translates to:
  /// **'{count} posts'**
  String noOfPosts(int count);

  /// Button label to write a new post
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get writePost;

  /// Like button label for posts
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// Comment button label for posts
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// Share button label for posts
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Edit Profile app bar label
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Comments text field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your comment'**
  String get enterComment;

  /// Comments section header label
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// Label posts with no comments under it
  ///
  /// In en, this message translates to:
  /// **'Be the first one to comment'**
  String get beTheFirstToComment;

  /// Button text to reply to a comment
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Label for nickname field
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// Hint text for nickname field
  ///
  /// In en, this message translates to:
  /// **'Enter your nickname'**
  String get nicknameHint;

  /// Label for full name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fullName;

  /// Hint text for full name field
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get fullNameHint;

  /// Label for birth date field
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// Label for gender field
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Label for male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Label for female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Error message when nickname is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname'**
  String get nicknameRequired;

  /// Success message after profile update
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdateSuccess;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Post title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Hint text for post title field
  ///
  /// In en, this message translates to:
  /// **'Enter your post title'**
  String get postTitleHint;

  /// Post content field label
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// Hint text for post content field
  ///
  /// In en, this message translates to:
  /// **'Write your post content here...'**
  String get postContentHint;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Error message when title is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// Error message when content is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter content for your post'**
  String get contentRequired;

  /// Text for write in category title (e.g., 'Write in Community')
  ///
  /// In en, this message translates to:
  /// **'Write in'**
  String get writeIn;

  /// Text instruction for changing profile photo
  ///
  /// In en, this message translates to:
  /// **'Tap photo to change'**
  String get tapPhotoChange;

  /// Hint text explaining nickname visibility
  ///
  /// In en, this message translates to:
  /// **'This name will be displayed to other users'**
  String get nicknameDisplayHint;

  /// Hint text for entering real name
  ///
  /// In en, this message translates to:
  /// **'Please enter your real name'**
  String get enterRealNameHint;

  /// Hint text for selecting birth date
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get selectBirthDateHint;

  /// Notice explaining why name, gender, and birth date are required for identity verification
  ///
  /// In en, this message translates to:
  /// **'Name, birth date, and gender are required\nfor identity verification when login fails.'**
  String get profileRequiredFieldsNotice;

  /// Main menu section title
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// Main menu section subtitle
  ///
  /// In en, this message translates to:
  /// **'View all PhilGo services'**
  String get menuSubtitle;

  /// Edit profile menu item title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// Edit profile menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage my information'**
  String get editProfileSubtitle;

  /// Open chat menu item title
  ///
  /// In en, this message translates to:
  /// **'Open Chat Room'**
  String get openChatTitle;

  /// Open chat menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Connect with people'**
  String get openChatSubtitle;

  /// Banner ad menu item title
  ///
  /// In en, this message translates to:
  /// **'Banner Ads'**
  String get bannerAdTitle;

  /// Banner ad menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Home screen advertisements'**
  String get bannerAdSubtitle;

  /// Point ad menu item title
  ///
  /// In en, this message translates to:
  /// **'Point Ads'**
  String get pointAdTitle;

  /// Point ad menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Earn and use points'**
  String get pointAdSubtitle;

  /// Business directory menu item title
  ///
  /// In en, this message translates to:
  /// **'Business Directory'**
  String get businessDirectoryTitle;

  /// Business directory menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Business information'**
  String get businessDirectorySubtitle;

  /// Family site menu item title
  ///
  /// In en, this message translates to:
  /// **'Family Sites'**
  String get familySiteTitle;

  /// Family site menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Connected services'**
  String get familySiteSubtitle;

  /// App guide menu item title
  ///
  /// In en, this message translates to:
  /// **'App Guide'**
  String get appGuideTitle;

  /// App guide menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get appGuideSubtitle;

  /// Terms of service menu item title
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// Terms of service menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Service terms'**
  String get termsOfServiceSubtitle;

  /// Privacy policy menu item title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// Privacy policy menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Privacy protection'**
  String get privacyPolicySubtitle;

  /// Account withdrawal menu item title
  ///
  /// In en, this message translates to:
  /// **'Account Withdrawal'**
  String get withdrawTitle;

  /// Account withdrawal menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get withdrawSubtitle;

  /// Logout menu item title
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// Logout menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign out safely'**
  String get logoutSubtitle;

  /// Year label for date selector
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Month label for date selector
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Day label for date selector
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// Year unit suffix (empty for English)
  ///
  /// In en, this message translates to:
  /// **''**
  String get yearUnit;

  /// Month unit suffix (empty for English)
  ///
  /// In en, this message translates to:
  /// **''**
  String get monthUnit;

  /// Day unit suffix (empty for English)
  ///
  /// In en, this message translates to:
  /// **''**
  String get dayUnit;

  /// Error message when trying to select day without year and month
  ///
  /// In en, this message translates to:
  /// **'Please select year and month first'**
  String get selectYearAndMonthFirst;

  /// Error message when trying to select day without year
  ///
  /// In en, this message translates to:
  /// **'Please select year first'**
  String get selectYearFirst;

  /// Error message when trying to select day without month
  ///
  /// In en, this message translates to:
  /// **'Please select month first'**
  String get selectMonthFirst;

  /// Gender option for users who prefer not to disclose their gender
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// Title for user profile screen
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// Default text when user nickname is not available
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// Section title for user profile information
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// Message shown when no additional user information is available
  ///
  /// In en, this message translates to:
  /// **'Additional information is not available'**
  String get additionalInfoNotAvailable;

  /// Confirmation message for deleting a post
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get confirmDeletePost;

  /// Success message after deleting a post
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully'**
  String get postDeletedSuccess;

  /// Confirmation message for deleting an image
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get confirmDeleteImage;

  /// Success message after deleting an image
  ///
  /// In en, this message translates to:
  /// **'Image deleted successfully'**
  String get imageDeletedSuccess;
}

class _LoDelegate extends LocalizationsDelegate<Lo> {
  const _LoDelegate();

  @override
  Future<Lo> load(Locale locale) {
    return SynchronousFuture<Lo>(lookupLo(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_LoDelegate old) => false;
}

Lo lookupLo(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LoEn();
    case 'ja':
      return LoJa();
    case 'ko':
      return LoKo();
    case 'zh':
      return LoZh();
  }

  throw FlutterError(
    'Lo.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
