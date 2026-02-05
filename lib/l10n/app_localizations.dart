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

  /// My page navigation item label
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get my;

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
  /// **'Input your phone number'**
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

  /// Verification failed
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

  /// Label shown when replying to a specific user
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get replying_to;

  /// Label shown when editing a comment
  ///
  /// In en, this message translates to:
  /// **'Editing comment'**
  String get editing_comment;

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

  /// Alert dialog title
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// Error message when trying to delete a post that has comments
  ///
  /// In en, this message translates to:
  /// **'Posts with comments cannot be deleted'**
  String get postWithCommentsCannotBeDeleted;

  /// Error message when trying to edit a post that has comments
  ///
  /// In en, this message translates to:
  /// **'Posts with comments cannot be edited'**
  String get postWithCommentsCannotBeEdited;

  /// Title for company directory screen
  ///
  /// In en, this message translates to:
  /// **'Company Directory'**
  String get companyDirectoryTitle;

  /// Button text for adding a new company
  ///
  /// In en, this message translates to:
  /// **'Add Company'**
  String get addCompany;

  /// Description text for company directory
  ///
  /// In en, this message translates to:
  /// **'When you register a company, it will be displayed in the navigation bar and other locations, making it visible to more users.'**
  String get companyDirectoryDescription;

  /// Button text for registering a company
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerCompany;

  /// Button text for updating a company
  ///
  /// In en, this message translates to:
  /// **'Update Company'**
  String get updateCompany;

  /// Text showing number of companies registered
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Total 0 companies registered.} =1{Total 1 company registered.} other{Total {count} companies registered.}}'**
  String companiesRegistered(int count);

  /// Button text to view more items
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get viewMore;

  /// Button text to hide/collapse items
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get showLess;

  /// Empty state message when no companies are registered
  ///
  /// In en, this message translates to:
  /// **'No registered companies.'**
  String get noRegisteredCompanies;

  /// Prompt text encouraging users to register a company
  ///
  /// In en, this message translates to:
  /// **'Be the first to register a company in this category!'**
  String get registerCompanyPrompt;

  /// Label for location information
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Section title for contact information
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// Label for mobile number
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// Label for description section
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for family site section
  ///
  /// In en, this message translates to:
  /// **'Family Site'**
  String get familySite;

  /// Section title for basic information
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Label for company name field
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// Hint text for company name field
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enterCompanyName;

  /// Label for company title field
  ///
  /// In en, this message translates to:
  /// **'Company Title'**
  String get companyTitle;

  /// Hint text for company title field
  ///
  /// In en, this message translates to:
  /// **'Enter company title or slogan'**
  String get enterCompanyTitle;

  /// Label for category field
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Hint text for category dropdown
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// Error message for category selection
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// Hint text for description field
  ///
  /// In en, this message translates to:
  /// **'Enter company description'**
  String get enterDescription;

  /// Section title for location information
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get locationInformation;

  /// Hint text for location field
  ///
  /// In en, this message translates to:
  /// **'Enter location (e.g., Manila, Cebu)'**
  String get enterLocation;

  /// Label for address field
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Hint text for address field
  ///
  /// In en, this message translates to:
  /// **'Enter detailed address'**
  String get enterAddress;

  /// Hint text for mobile number field
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get enterMobileNumber;

  /// Section title for images
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// Label for logo image field
  ///
  /// In en, this message translates to:
  /// **'Logo Image'**
  String get logoImage;

  /// Label for title image field
  ///
  /// In en, this message translates to:
  /// **'Title Image'**
  String get titleImage;

  /// Label for business license field
  ///
  /// In en, this message translates to:
  /// **'Business License'**
  String get businessLicense;

  /// Hint text for image upload
  ///
  /// In en, this message translates to:
  /// **'Tap to upload image'**
  String get tapToUploadImage;

  /// Success message for company registration
  ///
  /// In en, this message translates to:
  /// **'Company registered successfully'**
  String get companyRegistered;

  /// Success message for company update
  ///
  /// In en, this message translates to:
  /// **'Company updated successfully'**
  String get companyUpdated;

  /// Label for mobile contact method selection
  ///
  /// In en, this message translates to:
  /// **'Mobile Contact Method'**
  String get mobileContactMethod;

  /// Option for text message contact method
  ///
  /// In en, this message translates to:
  /// **'Send Text'**
  String get sendText;

  /// Option for phone call contact method
  ///
  /// In en, this message translates to:
  /// **'Make Call'**
  String get makeCall;

  /// Welcome title in app guide
  ///
  /// In en, this message translates to:
  /// **'Welcome to PhilGo!'**
  String get guideWelcomeTitle;

  /// Welcome subtitle in app guide
  ///
  /// In en, this message translates to:
  /// **'Share and communicate various information\nin the Philippines\' largest Korean community'**
  String get guideWelcomeSubtitle;

  /// Features section title in app guide
  ///
  /// In en, this message translates to:
  /// **'App Features'**
  String get guideFeaturesTitle;

  /// Community feature title
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get guideFeatureCommunityTitle;

  /// Community feature description
  ///
  /// In en, this message translates to:
  /// **'Share and communicate information on various boards'**
  String get guideFeatureCommunityDesc;

  /// Chat feature title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get guideFeatureChatTitle;

  /// Chat feature description
  ///
  /// In en, this message translates to:
  /// **'Connect quickly through real-time chat'**
  String get guideFeatureChatDesc;

  /// Business directory feature title
  ///
  /// In en, this message translates to:
  /// **'Business Directory'**
  String get guideFeatureDirectoryTitle;

  /// Business directory feature description
  ///
  /// In en, this message translates to:
  /// **'Find Korean business information in the Philippines'**
  String get guideFeatureDirectoryDesc;

  /// Write feature title
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get guideFeatureWriteTitle;

  /// Write feature description
  ///
  /// In en, this message translates to:
  /// **'Write and share your posts freely'**
  String get guideFeatureWriteDesc;

  /// Tips section title in app guide
  ///
  /// In en, this message translates to:
  /// **'Usage Tips'**
  String get guideTipsTitle;

  /// First tip in app guide
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to connect with more people'**
  String get guideTip1;

  /// Second tip in app guide
  ///
  /// In en, this message translates to:
  /// **'Enable notifications so you don\'t miss important news'**
  String get guideTip2;

  /// Third tip in app guide
  ///
  /// In en, this message translates to:
  /// **'Like posts you enjoy'**
  String get guideTip3;

  /// Fourth tip in app guide
  ///
  /// In en, this message translates to:
  /// **'You can bookmark frequently visited boards'**
  String get guideTip4;

  /// FAQ section title in app guide
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get guideFaqTitle;

  /// First FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I write a post?'**
  String get guideFaqQ1;

  /// First FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Tap the \"Write\" tab at the bottom, select a board, and write your post.'**
  String get guideFaqA1;

  /// Second FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I create a chat room?'**
  String get guideFaqQ2;

  /// Second FAQ answer
  ///
  /// In en, this message translates to:
  /// **'In the \"Chat\" tab, tap the + button to create a new chat room.'**
  String get guideFaqA2;

  /// Third FAQ question
  ///
  /// In en, this message translates to:
  /// **'How do I register a business?'**
  String get guideFaqQ3;

  /// Third FAQ answer
  ///
  /// In en, this message translates to:
  /// **'In the \"Directory\" tab, tap the \"Add Company\" button to register business information.'**
  String get guideFaqA3;

  /// Fourth FAQ question
  ///
  /// In en, this message translates to:
  /// **'Where can I edit my profile?'**
  String get guideFaqQ4;

  /// Fourth FAQ answer
  ///
  /// In en, this message translates to:
  /// **'Go to the \"Menu\" tab and select \"Edit Profile\" to change your information.'**
  String get guideFaqA4;

  /// Account withdrawal screen title
  ///
  /// In en, this message translates to:
  /// **'Account Withdrawal'**
  String get accountWithdrawalTitle;

  /// Withdrawal intro section title
  ///
  /// In en, this message translates to:
  /// **'Data Delete Request'**
  String get withdrawalIntroTitle;

  /// Withdrawal intro section subtitle
  ///
  /// In en, this message translates to:
  /// **'PhilGo Network provides you the right to permanently delete all personal information related to your account at any time.'**
  String get withdrawalIntroSubtitle;

  /// Step 1 title for data deletion
  ///
  /// In en, this message translates to:
  /// **'Data to be Deleted'**
  String get withdrawalStep1Title;

  /// Account information section title
  ///
  /// In en, this message translates to:
  /// **'Account Identity Information'**
  String get withdrawalAccountInfoTitle;

  /// Account information description
  ///
  /// In en, this message translates to:
  /// **'Email, nickname, profile image'**
  String get withdrawalAccountInfoDesc;

  /// Usage history section title
  ///
  /// In en, this message translates to:
  /// **'App Usage History'**
  String get withdrawalUsageHistoryTitle;

  /// Usage history description
  ///
  /// In en, this message translates to:
  /// **'Chats, posts, activity logs, notification tokens'**
  String get withdrawalUsageHistoryDesc;

  /// Additional data section title
  ///
  /// In en, this message translates to:
  /// **'Connected Additional Data'**
  String get withdrawalAdditionalDataTitle;

  /// Additional data description
  ///
  /// In en, this message translates to:
  /// **'Cloud backups, user settings, etc.'**
  String get withdrawalAdditionalDataDesc;

  /// Note about payment data retention
  ///
  /// In en, this message translates to:
  /// **'Payment and tax documentation will be retained separately for up to 5 years as required by relevant laws before destruction.'**
  String get withdrawalPaymentNote;

  /// Step 2 title for deletion method
  ///
  /// In en, this message translates to:
  /// **'Deletion Method'**
  String get withdrawalStep2Title;

  /// Email request method
  ///
  /// In en, this message translates to:
  /// **'Email Request'**
  String get withdrawalEmailRequest;

  /// Step 3 title for processing timeline
  ///
  /// In en, this message translates to:
  /// **'Processing & Timeline'**
  String get withdrawalStep3Title;

  /// Processing timeline description
  ///
  /// In en, this message translates to:
  /// **'After confirming your request, all data will be completely deleted within 7 business days, and you will receive a completion notification email.'**
  String get withdrawalProcessingDesc;

  /// Warning about irreversible deletion
  ///
  /// In en, this message translates to:
  /// **'Once deletion is complete, recovery is impossible, and all remaining points and subscriptions will be forfeited.'**
  String get withdrawalIrreversibleNote;

  /// Step 4 title for data retention exceptions
  ///
  /// In en, this message translates to:
  /// **'Data Retention Exceptions'**
  String get withdrawalStep4Title;

  /// Data retention exception description
  ///
  /// In en, this message translates to:
  /// **'Only information necessary for fraud prevention, accounting audits, and legal compliance will be retained in a minimized form for the period prescribed by relevant laws before immediate destruction.'**
  String get withdrawalRetentionDesc;

  /// Step 5 title for contact information
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get withdrawalStep5Title;

  /// Contact information description
  ///
  /// In en, this message translates to:
  /// **'For additional inquiries, please contact us at philgohelp@gmail.com anytime.'**
  String get withdrawalContactDesc;

  /// Button text to request account withdrawal
  ///
  /// In en, this message translates to:
  /// **'Request Withdrawal'**
  String get requestWithdrawal;

  /// Getting started section title
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get guideGettingStartedTitle;

  /// Step 1 title
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get guideStep1Title;

  /// Step 1 description
  ///
  /// In en, this message translates to:
  /// **'Sign up with your email or social accounts to get started.'**
  String get guideStep1Desc;

  /// Step 2 title
  ///
  /// In en, this message translates to:
  /// **'Explore the Community'**
  String get guideStep2Title;

  /// Step 2 description
  ///
  /// In en, this message translates to:
  /// **'Browse through posts, companies, and connect with Korean community in the Philippines.'**
  String get guideStep2Desc;

  /// Step 3 title
  ///
  /// In en, this message translates to:
  /// **'Share Your Story'**
  String get guideStep3Title;

  /// Step 3 description
  ///
  /// In en, this message translates to:
  /// **'Write posts, share experiences, and contribute to the community.'**
  String get guideStep3Desc;

  /// Step 4 title
  ///
  /// In en, this message translates to:
  /// **'Connect with Others'**
  String get guideStep4Title;

  /// Step 4 description
  ///
  /// In en, this message translates to:
  /// **'Chat with members, join discussions, and build your network.'**
  String get guideStep4Desc;

  /// Title for bookmarked folders dialog
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Folders'**
  String get bookmarked_folders;

  /// Message when there are no bookmarked folders
  ///
  /// In en, this message translates to:
  /// **'No bookmarked folders'**
  String get no_bookmarked_folders;

  /// Title for bookmarked chats dialog
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Chats'**
  String get bookmarked_chats;

  /// Message when there are no bookmarked chats in a folder
  ///
  /// In en, this message translates to:
  /// **'No bookmarked chats in this folder'**
  String get no_bookmarked_chats;

  /// Title for unpin chat room confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Unpin Chat Room'**
  String get unpin_chat_room_title;

  /// Message for unpin chat room confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unpin this chat room?'**
  String get unpin_chat_room_message;

  /// Pin button text
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// Unpin button text
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// Success message after unpinning chat room
  ///
  /// In en, this message translates to:
  /// **'Chat room unpinned successfully'**
  String get chat_room_unpinned;

  /// Title for my activity screen
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get myActivity;

  /// Tab label for my posts
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// Tab label for my comments
  ///
  /// In en, this message translates to:
  /// **'My Comments'**
  String get myComments;

  /// Label for posts
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// Empty state message when user has no posts
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// Empty state message when user has no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// Label for view count
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// Suffix for time ago
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get ago;

  /// Text for very recent time
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// Minutes ago format
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// Hours ago format
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// Days ago format
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// Weeks ago format
  ///
  /// In en, this message translates to:
  /// **'{weeks}w ago'**
  String weeksAgo(int weeks);

  /// Months ago format
  ///
  /// In en, this message translates to:
  /// **'{months}mo ago'**
  String monthsAgo(int months);

  /// Years ago format
  ///
  /// In en, this message translates to:
  /// **'{years}y ago'**
  String yearsAgo(int years);

  /// Title for latest posts section
  ///
  /// In en, this message translates to:
  /// **'Latest Posts'**
  String get latestPosts;

  /// Title for latest comments section
  ///
  /// In en, this message translates to:
  /// **'Latest Comments'**
  String get latestComments;

  /// Button text to view all items
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Placeholder text for advertisement banner
  ///
  /// In en, this message translates to:
  /// **'Advertisement Space'**
  String get advertisementSpace;

  /// Abbreviation for level
  ///
  /// In en, this message translates to:
  /// **'Lv'**
  String get lv;

  /// Settings button tooltip and menu label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language settings screen title
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// Language dropdown hint text
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Save language button text
  ///
  /// In en, this message translates to:
  /// **'Save Language'**
  String get saveLanguage;

  /// Success message after changing language
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// Language menu item title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// Language menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Change app language preference'**
  String get languageSubtitle;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// Error message when company name is empty
  ///
  /// In en, this message translates to:
  /// **'Company name is required'**
  String get companyNameRequired;

  /// Error message when company title is empty
  ///
  /// In en, this message translates to:
  /// **'Company title is required'**
  String get companyTitleRequired;

  /// Error message when location is empty
  ///
  /// In en, this message translates to:
  /// **'Location is required'**
  String get locationRequired;

  /// Error message when address is empty
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// Error message when description is empty
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// Error message when landline is empty
  ///
  /// In en, this message translates to:
  /// **'Landline number is required'**
  String get landlineRequired;

  /// Error message when mobile number is empty
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get mobileNumberRequired;

  /// Error message when logo is not uploaded
  ///
  /// In en, this message translates to:
  /// **'Company logo is required'**
  String get logoRequired;

  /// Step title for detailed information
  ///
  /// In en, this message translates to:
  /// **'Detailed Information'**
  String get detailedInformation;

  /// Step title for image upload
  ///
  /// In en, this message translates to:
  /// **'Image Upload'**
  String get imageUpload;

  /// Success message after deleting Kakao QR code
  ///
  /// In en, this message translates to:
  /// **'Kakao QR Code deleted'**
  String get kakaoQrCodeDeleted;

  /// Error message when deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// Success message after deleting company logo
  ///
  /// In en, this message translates to:
  /// **'Company logo deleted'**
  String get companyLogoDeleted;

  /// Error message when photo deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete photo'**
  String get failedToDeletePhoto;

  /// Success message after deleting business license
  ///
  /// In en, this message translates to:
  /// **'Business license deleted'**
  String get businessLicenseDeleted;

  /// Error message when license deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete license'**
  String get failedToDeleteLicense;

  /// Success message after deleting company intro image
  ///
  /// In en, this message translates to:
  /// **'Company introduction image deleted'**
  String get companyIntroImageDeleted;

  /// Error message when image deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete image'**
  String get failedToDeleteImage;

  /// Success message after deleting office interior photo
  ///
  /// In en, this message translates to:
  /// **'Office interior photo deleted'**
  String get officeInteriorDeleted;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Error message when companies fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load companies'**
  String get failedToLoadCompanies;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Empty state title when no companies are found
  ///
  /// In en, this message translates to:
  /// **'No companies found'**
  String get noCompaniesFound;

  /// Empty state message for companies in a specific category
  ///
  /// In en, this message translates to:
  /// **'There are no companies in {categoryName} category yet.'**
  String noCompaniesInCategory(String categoryName);

  /// Tooltip for edit company button
  ///
  /// In en, this message translates to:
  /// **'Edit my company'**
  String get editMyCompany;

  /// Tooltip for add company button
  ///
  /// In en, this message translates to:
  /// **'Add my company'**
  String get addMyCompany;

  /// Filter chip label to show all categories
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// Public office category name
  ///
  /// In en, this message translates to:
  /// **'Public Office'**
  String get publicOffice;

  /// Public office category description
  ///
  /// In en, this message translates to:
  /// **'Government services'**
  String get publicOfficeDesc;

  /// Education category name
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// Education category description
  ///
  /// In en, this message translates to:
  /// **'Schools and learning'**
  String get educationDesc;

  /// Food and drink category name
  ///
  /// In en, this message translates to:
  /// **'Food & Drink'**
  String get foodAndDrink;

  /// Food and drink category description
  ///
  /// In en, this message translates to:
  /// **'Restaurants and cafes'**
  String get foodAndDrinkDesc;

  /// Transportation category name
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// Transportation category description
  ///
  /// In en, this message translates to:
  /// **'Public and private transit'**
  String get transportationDesc;

  /// Health category name
  ///
  /// In en, this message translates to:
  /// **'Health & Hospitals'**
  String get healthAndHospitals;

  /// Health category description
  ///
  /// In en, this message translates to:
  /// **'Clinics and care'**
  String get healthAndHospitalsDesc;

  /// Shopping category name
  ///
  /// In en, this message translates to:
  /// **'Shopping & Marts'**
  String get shoppingAndMarts;

  /// Shopping category description
  ///
  /// In en, this message translates to:
  /// **'Retail and groceries'**
  String get shoppingAndMartsDesc;

  /// Banking category name
  ///
  /// In en, this message translates to:
  /// **'Banking & Finance'**
  String get bankingAndFinance;

  /// Banking category description
  ///
  /// In en, this message translates to:
  /// **'Financial institutions'**
  String get bankingAndFinanceDesc;

  /// Gadgets category name
  ///
  /// In en, this message translates to:
  /// **'Gadgets'**
  String get gadgets;

  /// Gadgets category description
  ///
  /// In en, this message translates to:
  /// **'Tech and devices'**
  String get gadgetsDesc;

  /// Travel category name
  ///
  /// In en, this message translates to:
  /// **'Travel & Tourism'**
  String get travelAndTourism;

  /// Travel category description
  ///
  /// In en, this message translates to:
  /// **'Destinations and booking'**
  String get travelAndTourismDesc;

  /// Hotels category name
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get hotels;

  /// Hotels category description
  ///
  /// In en, this message translates to:
  /// **'Places to stay'**
  String get hotelsDesc;

  /// Car rental category name
  ///
  /// In en, this message translates to:
  /// **'Car Rent'**
  String get carRental;

  /// Car rental category description
  ///
  /// In en, this message translates to:
  /// **'Vehicle hire services'**
  String get carRentalDesc;

  /// Beauty category name
  ///
  /// In en, this message translates to:
  /// **'Beauty & Wellness'**
  String get beautyAndWellness;

  /// Beauty category description
  ///
  /// In en, this message translates to:
  /// **'Salons and self-care'**
  String get beautyAndWellnessDesc;

  /// Real estate category name
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get realEstate;

  /// Real estate category description
  ///
  /// In en, this message translates to:
  /// **'Property and housing'**
  String get realEstateDesc;

  /// Entertainment category name
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// Entertainment category description
  ///
  /// In en, this message translates to:
  /// **'Karaoke and fun'**
  String get entertainmentDesc;

  /// Spa category name
  ///
  /// In en, this message translates to:
  /// **'Spa & Relaxation'**
  String get spaAndRelaxation;

  /// Spa category description
  ///
  /// In en, this message translates to:
  /// **'Massage and retreats'**
  String get spaAndRelaxationDesc;

  /// Other services category name
  ///
  /// In en, this message translates to:
  /// **'Other Services'**
  String get otherServices;

  /// Other services category description
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous services'**
  String get otherServicesDesc;

  /// Account section title in menu
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Advertising section title in menu
  ///
  /// In en, this message translates to:
  /// **'Advertising'**
  String get advertising;

  /// Support section title in menu
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Account actions section title in menu
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// Blocked users menu item
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// Writing guide section title
  ///
  /// In en, this message translates to:
  /// **'Writing Guide'**
  String get writingGuide;

  /// Warning about defamation in posts
  ///
  /// In en, this message translates to:
  /// **'Posts that defame others may be deleted'**
  String get postDefamationWarning;

  /// Warning about spam in posts
  ///
  /// In en, this message translates to:
  /// **'Advertisements and spam will be deleted immediately'**
  String get postSpamWarning;

  /// Warning about personal information in posts
  ///
  /// In en, this message translates to:
  /// **'Do not include personal information'**
  String get postPersonalInfoWarning;

  /// Warning about copyright in posts
  ///
  /// In en, this message translates to:
  /// **'Copyright infringing content cannot be posted'**
  String get postCopyrightWarning;

  /// Prefix for update screen title
  ///
  /// In en, this message translates to:
  /// **'Update:'**
  String get updatePrefix;

  /// Error message when trying to submit while upload is in progress
  ///
  /// In en, this message translates to:
  /// **'Image upload is in progress, please try again in a moment.'**
  String get uploadInProgress;

  /// About screen title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Welcome message on about screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to About Screen'**
  String get welcomeToAboutScreen;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Hint text for KakaoTalk ID field
  ///
  /// In en, this message translates to:
  /// **'Enter KakaoTalk ID'**
  String get enterKakaotalkId;

  /// Placeholder for Kakao channel URL field
  ///
  /// In en, this message translates to:
  /// **'https://pf.kakao.com/...'**
  String get kakaoChannelUrlPlaceholder;

  /// Hint text for Telegram ID field
  ///
  /// In en, this message translates to:
  /// **'Enter Telegram ID'**
  String get enterTelegramId;

  /// Example text for company name field
  ///
  /// In en, this message translates to:
  /// **'e.g.) mycompany'**
  String get companyNameExample;

  /// Hint text for family site name field
  ///
  /// In en, this message translates to:
  /// **'Enter your family site name'**
  String get enterFamilySiteName;

  /// Hint text for family site description field
  ///
  /// In en, this message translates to:
  /// **'Enter your family site description'**
  String get enterFamilySiteDescription;

  /// Error message when email app cannot be launched
  ///
  /// In en, this message translates to:
  /// **'Could not launch email app'**
  String get couldNotLaunchEmailApp;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Checkbox label for using company domain
  ///
  /// In en, this message translates to:
  /// **'Use Company Domain'**
  String get useCompanyDomain;

  /// Information about SEO features
  ///
  /// In en, this message translates to:
  /// **'SEO features help expose your directory listing more on Google, Naver, and other search engines.'**
  String get seoFeaturesMessage;

  /// Label for family site domain field
  ///
  /// In en, this message translates to:
  /// **'Family Site Domain'**
  String get familySiteDomain;

  /// Label for family site name field
  ///
  /// In en, this message translates to:
  /// **'Family Site Name'**
  String get familySiteName;

  /// Label for family site description field
  ///
  /// In en, this message translates to:
  /// **'Family Site Description'**
  String get familySiteDescription;

  /// Label for KakaoTalk ID field
  ///
  /// In en, this message translates to:
  /// **'KakaoID'**
  String get kakaoId;

  /// Label for Kakao QR code upload
  ///
  /// In en, this message translates to:
  /// **'Upload Kakao QR Code'**
  String get uploadKakaoQrCode;

  /// Label for Kakao channel URL field
  ///
  /// In en, this message translates to:
  /// **'Kakao Channel URL'**
  String get kakaoChannelUrl;

  /// Label for Telegram ID field
  ///
  /// In en, this message translates to:
  /// **'Telegram ID'**
  String get telegramId;

  /// Label for business type field
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get businessType;

  /// Label for company logo upload
  ///
  /// In en, this message translates to:
  /// **'Company Logo'**
  String get companyLogo;

  /// Label for company introduction image upload
  ///
  /// In en, this message translates to:
  /// **'Company Introduction Image'**
  String get companyIntroImage;

  /// Guideline text for company introduction image
  ///
  /// In en, this message translates to:
  /// **'Image briefly representing company introduction. Include logo and main service items. Text limited to around 100 characters (20 words).'**
  String get companyIntroImageGuideline;

  /// Label for office/store interior photo upload
  ///
  /// In en, this message translates to:
  /// **'Office/Store Interior Photo'**
  String get officeInteriorPhoto;

  /// Guideline text for office interior photo
  ///
  /// In en, this message translates to:
  /// **'Office/Store Interior full view photo'**
  String get officeInteriorGuideline;

  /// Text prompting user to login to view their profile
  ///
  /// In en, this message translates to:
  /// **'Login to see your profile'**
  String get loginToSeeProfile;

  /// Description of what user can see after logging in
  ///
  /// In en, this message translates to:
  /// **'View your posts, comments, and points'**
  String get viewPostsCommentsPoints;

  /// Placeholder text when user has no nickname
  ///
  /// In en, this message translates to:
  /// **'Update your nickname'**
  String get updateYourNickname;

  /// Label for user points/score
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// Title for phone number login
  ///
  /// In en, this message translates to:
  /// **'Phone Login'**
  String get philgoPhoneLogin;

  /// Example text for phone number input format
  ///
  /// In en, this message translates to:
  /// **'e.g.: 09123456789 or 01012345678'**
  String get phoneNumberExample;

  /// App name displayed on entry screen
  ///
  /// In en, this message translates to:
  /// **'PhilGo'**
  String get appName;

  /// App slogan displayed on entry screen
  ///
  /// In en, this message translates to:
  /// **'Everything about the Philippines'**
  String get appSlogan;

  /// Free talk category name
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get categoryFreetalk;

  /// Q&A category name
  ///
  /// In en, this message translates to:
  /// **'Q&A'**
  String get categoryQna;

  /// Buy and sell category name
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get categoryBuyandsell;

  /// Blog category name
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get categoryBlog;

  /// Boarding house category name
  ///
  /// In en, this message translates to:
  /// **'Boarding House'**
  String get categoryBoardingHouse;

  /// Caution category name
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get categoryCaution;

  /// Looking for category name
  ///
  /// In en, this message translates to:
  /// **'Looking For'**
  String get categoryLookfor;

  /// Food delivery category name
  ///
  /// In en, this message translates to:
  /// **'Food Delivery'**
  String get categoryFoodDelivery;

  /// Greetings category name
  ///
  /// In en, this message translates to:
  /// **'Greetings'**
  String get categoryGreeting;

  /// Jobs/wanted category name
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get categoryWanted;

  /// Business category name
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// Massage category name
  ///
  /// In en, this message translates to:
  /// **'Massage'**
  String get categoryMassage;

  /// Restaurant category name
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get categoryRest;

  /// School category name
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get categorySchool;

  /// Study category name
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get categoryStudy;

  /// Travel category name
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// YouTube category name
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get categoryYoutube;

  /// Mom cafe category name
  ///
  /// In en, this message translates to:
  /// **'Mom Cafe'**
  String get categoryMomcafe;

  /// News category name
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get categoryNews;

  /// Newcomer category name
  ///
  /// In en, this message translates to:
  /// **'Newcomer'**
  String get categoryNewcomer;

  /// Nature category name
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get categoryNature;

  /// Company info category name
  ///
  /// In en, this message translates to:
  /// **'Company Info'**
  String get categoryCompanyInfo;

  /// English business category name
  ///
  /// In en, this message translates to:
  /// **'English Business'**
  String get categoryEnglishBiz;

  /// Temporary category name
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get categoryTemp;

  /// Travel recommendations category name
  ///
  /// In en, this message translates to:
  /// **'Travel Recommendations'**
  String get categoryTravelGood;

  /// Discussion subcategory name
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get subCategoryDiscussion;

  /// Encyclopedia subcategory name
  ///
  /// In en, this message translates to:
  /// **'Encyclopedia'**
  String get subCategoryEncyclopedia;

  /// Hobby subcategory name
  ///
  /// In en, this message translates to:
  /// **'Hobby'**
  String get subCategoryHobby;

  /// Info subcategory name
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get subCategoryInfo;

  /// Korean-Filipino couple subcategory name
  ///
  /// In en, this message translates to:
  /// **'KoPhil Couple'**
  String get subCategoryKoPhCouple;

  /// Kopino subcategory name
  ///
  /// In en, this message translates to:
  /// **'Kopino'**
  String get subCategoryKopino;

  /// Immigration subcategory name
  ///
  /// In en, this message translates to:
  /// **'Immigration'**
  String get subCategoryImmigration;

  /// Photo subcategory name
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get subCategoryPhoto;

  /// Life tips subcategory name
  ///
  /// In en, this message translates to:
  /// **'Life Tips'**
  String get subCategoryLifeTips;

  /// Missing subcategory name
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get subCategoryMissing;

  /// International marriage subcategory name
  ///
  /// In en, this message translates to:
  /// **'Marriage'**
  String get subCategoryIntlMarriage;

  /// Meetup subcategory name
  ///
  /// In en, this message translates to:
  /// **'Meetup'**
  String get subCategoryMeeting;

  /// Column subcategory name
  ///
  /// In en, this message translates to:
  /// **'Column'**
  String get subCategoryColumn;

  /// Mukbang subcategory name
  ///
  /// In en, this message translates to:
  /// **'Mukbang'**
  String get subCategoryMukbang;

  /// Notice subcategory name
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get subCategoryNotice;

  /// Experience subcategory name
  ///
  /// In en, this message translates to:
  /// **'Knowhow'**
  String get subCategoryExperience;

  /// Study/learn subcategory name
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get subCategoryStudyLearn;

  /// Typhoon subcategory name
  ///
  /// In en, this message translates to:
  /// **'Typhoon'**
  String get subCategoryTyphoon;

  /// Business partner subcategory name
  ///
  /// In en, this message translates to:
  /// **'Business Partner'**
  String get subCategoryBusinessPartner;

  /// Computer/internet subcategory name
  ///
  /// In en, this message translates to:
  /// **'Computer/Internet'**
  String get subCategoryComputer;

  /// Peso exchange subcategory name
  ///
  /// In en, this message translates to:
  /// **'Peso Exchange'**
  String get subCategoryExchange;

  /// Mobile phone subcategory name
  ///
  /// In en, this message translates to:
  /// **'Phone Selling'**
  String get subCategoryPhone;

  /// Hotel subcategory name
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get subCategoryHotel;

  /// Appliances subcategory name
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get subCategoryAppliances;

  /// Golf subcategory name
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get subCategoryGolf;

  /// Promotion subcategory name
  ///
  /// In en, this message translates to:
  /// **'Promotion'**
  String get subCategoryPromotion;

  /// Personal market subcategory name
  ///
  /// In en, this message translates to:
  /// **'Personal Market'**
  String get subCategoryPersonalMarket;

  /// Real estate subcategory name
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get subCategoryRealEstate;

  /// House rental subcategory name
  ///
  /// In en, this message translates to:
  /// **'House Rental'**
  String get subCategoryHouseRental;

  /// Car rental subcategory name
  ///
  /// In en, this message translates to:
  /// **'Car Rent'**
  String get subCategoryCarRental;

  /// Used car subcategory name
  ///
  /// In en, this message translates to:
  /// **'Used Car'**
  String get subCategoryUsedCar;

  /// Success message when user likes a post
  ///
  /// In en, this message translates to:
  /// **'Post liked'**
  String get postLiked;

  /// Error message when user tries to like an already liked post
  ///
  /// In en, this message translates to:
  /// **'You have already liked this post'**
  String get alreadyLikedPost;

  /// Success message when comment reply is created
  ///
  /// In en, this message translates to:
  /// **'Reply added successfully'**
  String get commentReplied;

  /// Success message when comment is updated
  ///
  /// In en, this message translates to:
  /// **'Comment updated successfully'**
  String get commentUpdated;

  /// Success message when comment is created
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully'**
  String get commentCreated;

  /// Shorebird update dialog title
  ///
  /// In en, this message translates to:
  /// **'Update Complete'**
  String get shorebirdUpdateTitle;

  /// Shorebird update dialog message - first line
  ///
  /// In en, this message translates to:
  /// **'PhilGo app has been updated.'**
  String get shorebirdUpdateMessage;

  /// Shorebird update dialog restart message - emphasized second line
  ///
  /// In en, this message translates to:
  /// **'Please restart the app.'**
  String get shorebirdRestartMessage;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get confirm;

  /// No description provided for @appInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfoTitle;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version Info'**
  String get versionTitle;

  /// No description provided for @packageName.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get packageName;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @deviceBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get deviceBasicInfo;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @deviceModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get deviceModel;

  /// No description provided for @deviceBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get deviceBrand;

  /// No description provided for @deviceManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get deviceManufacturer;

  /// No description provided for @deviceProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get deviceProduct;

  /// No description provided for @deviceDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceDevice;

  /// No description provided for @deviceHardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get deviceHardware;

  /// No description provided for @deviceBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get deviceBoard;

  /// No description provided for @isPhysicalDevice.
  ///
  /// In en, this message translates to:
  /// **'Physical Device'**
  String get isPhysicalDevice;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @systemInfo.
  ///
  /// In en, this message translates to:
  /// **'System Info'**
  String get systemInfo;

  /// No description provided for @androidVersion.
  ///
  /// In en, this message translates to:
  /// **'Android Version'**
  String get androidVersion;

  /// No description provided for @sdkInt.
  ///
  /// In en, this message translates to:
  /// **'SDK Version'**
  String get sdkInt;

  /// No description provided for @securityPatch.
  ///
  /// In en, this message translates to:
  /// **'Security Patch'**
  String get securityPatch;

  /// No description provided for @deviceDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get deviceDisplay;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @deviceFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get deviceFingerprint;

  /// No description provided for @deviceHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get deviceHost;

  /// No description provided for @deviceBootloader.
  ///
  /// In en, this message translates to:
  /// **'Bootloader'**
  String get deviceBootloader;

  /// No description provided for @deviceType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get deviceType;

  /// No description provided for @deviceTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get deviceTags;

  /// No description provided for @memoryAndStorage.
  ///
  /// In en, this message translates to:
  /// **'Memory & Storage'**
  String get memoryAndStorage;

  /// No description provided for @physicalRam.
  ///
  /// In en, this message translates to:
  /// **'Physical RAM'**
  String get physicalRam;

  /// No description provided for @availableRam.
  ///
  /// In en, this message translates to:
  /// **'Available RAM'**
  String get availableRam;

  /// No description provided for @isLowRamDevice.
  ///
  /// In en, this message translates to:
  /// **'Low RAM Device'**
  String get isLowRamDevice;

  /// No description provided for @totalDisk.
  ///
  /// In en, this message translates to:
  /// **'Total Storage'**
  String get totalDisk;

  /// No description provided for @freeDisk.
  ///
  /// In en, this message translates to:
  /// **'Free Storage'**
  String get freeDisk;

  /// No description provided for @supportedAbis.
  ///
  /// In en, this message translates to:
  /// **'Supported ABIs'**
  String get supportedAbis;

  /// No description provided for @supported32BitAbis.
  ///
  /// In en, this message translates to:
  /// **'32-bit ABIs'**
  String get supported32BitAbis;

  /// No description provided for @supported64BitAbis.
  ///
  /// In en, this message translates to:
  /// **'64-bit ABIs'**
  String get supported64BitAbis;

  /// No description provided for @systemFeatures.
  ///
  /// In en, this message translates to:
  /// **'System Features'**
  String get systemFeatures;

  /// No description provided for @modelName.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelName;

  /// No description provided for @localizedModel.
  ///
  /// In en, this message translates to:
  /// **'Localized Model'**
  String get localizedModel;

  /// No description provided for @isiOSAppOnMac.
  ///
  /// In en, this message translates to:
  /// **'Running on Mac'**
  String get isiOSAppOnMac;

  /// No description provided for @systemName.
  ///
  /// In en, this message translates to:
  /// **'System Name'**
  String get systemName;

  /// No description provided for @systemVersion.
  ///
  /// In en, this message translates to:
  /// **'System Version'**
  String get systemVersion;

  /// No description provided for @identifierForVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor ID'**
  String get identifierForVendor;

  /// No description provided for @utsnameInfo.
  ///
  /// In en, this message translates to:
  /// **'UTSNAME Info'**
  String get utsnameInfo;

  /// No description provided for @sysname.
  ///
  /// In en, this message translates to:
  /// **'Sysname'**
  String get sysname;

  /// No description provided for @nodename.
  ///
  /// In en, this message translates to:
  /// **'Nodename'**
  String get nodename;

  /// No description provided for @release.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get release;

  /// No description provided for @utsnameVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get utsnameVersion;

  /// No description provided for @machine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get machine;

  /// First message in upgrade dialog - new version announcement
  ///
  /// In en, this message translates to:
  /// **'A new version has been released.'**
  String get upgradeNewVersion;

  /// Second message in upgrade dialog - update request
  ///
  /// In en, this message translates to:
  /// **'Please update the app for better service.'**
  String get upgradeForBetterService;

  /// Exit app button text
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitApp;

  /// Popular posts section title on home screen
  ///
  /// In en, this message translates to:
  /// **'Popular Posts'**
  String get homePopularPosts;

  /// Recent photos section title on home screen
  ///
  /// In en, this message translates to:
  /// **'Recent Photos'**
  String get homeRecentPhotos;

  /// More button text on home section headers
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeMore;

  /// Notification label for notification icon button
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// Quick menu notice label
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get quickMenuNotice;

  /// Major forums section title on home screen
  ///
  /// In en, this message translates to:
  /// **'Major Forums'**
  String get majorForums;

  /// Quick menu exchange rate label
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get quickMenuExchangeRate;

  /// Quick menu weather label
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get quickMenuWeather;

  /// Quick menu emergency contacts label
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get quickMenuEmergency;

  /// Quick menu essential info label
  ///
  /// In en, this message translates to:
  /// **'Must Read'**
  String get quickMenuEssentialInfo;

  /// Quick menu monthly living label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get quickMenuMonthlyLiving;

  /// Quick menu travel label
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get quickMenuTravel;

  /// Quick menu holiday label
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get quickMenuHoliday;

  /// Quick menu food delivery label
  ///
  /// In en, this message translates to:
  /// **'Food Delivery'**
  String get quickMenuFoodDelivery;

  /// Quick menu Baedal K (Korean food delivery) label
  ///
  /// In en, this message translates to:
  /// **'Baedal K'**
  String get quickMenuBaedalK;

  /// Quick menu my info label
  ///
  /// In en, this message translates to:
  /// **'My Info'**
  String get quickMenuMyInfo;

  /// Quick menu all menu label
  ///
  /// In en, this message translates to:
  /// **'All Menu'**
  String get quickMenuAllMenu;

  /// Quick menu essential information label
  ///
  /// In en, this message translates to:
  /// **'Essential Info'**
  String get quickMenuMustReadInfo;

  /// Quick menu travel spots label
  ///
  /// In en, this message translates to:
  /// **'Travel Spots'**
  String get quickMenuTravelSpots;

  /// Travel spots screen title
  ///
  /// In en, this message translates to:
  /// **'Philippine Travel Spots'**
  String get travelSpotsScreenTitle;

  /// Philippine life information section title in menu
  ///
  /// In en, this message translates to:
  /// **'Philippine Life Info'**
  String get philippineLifeInfo;

  /// Immigration and visa passport section title
  ///
  /// In en, this message translates to:
  /// **'Immigration & Visa'**
  String get immigrationSection;

  /// E-Travel registration menu item
  ///
  /// In en, this message translates to:
  /// **'e-Travel'**
  String get immigrationETravel;

  /// Travel/Tourist visa menu item
  ///
  /// In en, this message translates to:
  /// **'Travel Visa'**
  String get immigrationTravelVisa;

  /// Working visa menu item
  ///
  /// In en, this message translates to:
  /// **'Working Visa'**
  String get immigrationWorkingVisa;

  /// Retirement visa (SRRV) menu item
  ///
  /// In en, this message translates to:
  /// **'Retirement Visa'**
  String get immigrationRetirementVisa;

  /// Transportation section title
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportationSection;

  /// Grab taxi menu item
  ///
  /// In en, this message translates to:
  /// **'Grab Taxi'**
  String get transportationGrabTaxi;

  /// Regular taxi menu item
  ///
  /// In en, this message translates to:
  /// **'Regular Taxi'**
  String get transportationRegularTaxi;

  /// Express bus menu item
  ///
  /// In en, this message translates to:
  /// **'Express Bus'**
  String get transportationExpressBus;

  /// Housing rental section title
  ///
  /// In en, this message translates to:
  /// **'Housing Rental'**
  String get housingSection;

  /// Monthly rent menu item
  ///
  /// In en, this message translates to:
  /// **'Monthly Rent'**
  String get housingMonthlyRent;

  /// Airbnb menu item
  ///
  /// In en, this message translates to:
  /// **'Airbnb'**
  String get housingAirbnb;

  /// Hotel menu item
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get housingHotel;

  /// Car section title
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get carSection;

  /// Car purchase menu item
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get carPurchase;

  /// Car insurance menu item
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get carInsurance;

  /// OR renewal menu item
  ///
  /// In en, this message translates to:
  /// **'OR Renewal'**
  String get carOrRenewal;

  /// Today's exchange rate label on entry screen
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get entryTodayExchangeRate;

  /// Today's weather label on entry screen
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get entryTodayWeather;

  /// Member count label on entry screen
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get entryMemberCount;

  /// Post count label on entry screen
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get entryPostCount;

  /// Sunny weather status
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get weatherSunny;

  /// Label for profile photo section in edit profile
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// Success message when profile photo is updated
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully'**
  String get profilePhotoUpdated;

  /// Success message when profile photo is deleted
  ///
  /// In en, this message translates to:
  /// **'Profile photo deleted'**
  String get profilePhotoDeleted;

  /// Section title for basic user information
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// Section title for personal user information
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// Contact admin menu item title
  ///
  /// In en, this message translates to:
  /// **'Contact Admin'**
  String get contactAdmin;

  /// Forum community subcategory title
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get forumCommunity;

  /// Forum member market subcategory title
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get forumMarket;

  /// Forum other subcategory title
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get forumOther;

  /// Error message when YouTube video cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get videoUnavailable;

  /// Quick menu embassy label
  ///
  /// In en, this message translates to:
  /// **'Embassy'**
  String get quickMenuEmbassy;

  /// Quick menu police station label
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get quickMenuPoliceStation;

  /// Quick menu hospital label
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get quickMenuHospital;

  /// Quick menu Korean association label
  ///
  /// In en, this message translates to:
  /// **'Korean Association'**
  String get quickMenuKoreanAssociation;

  /// Helper menu section title in home screen
  ///
  /// In en, this message translates to:
  /// **'Quick Menu'**
  String get helperMenuTitle;

  /// Emergency contacts section title
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyContactsSection;

  /// Recommended residence area section title
  ///
  /// In en, this message translates to:
  /// **'Recommended Areas'**
  String get residenceSection;

  /// BGC (Bonifacio Global City) menu item
  ///
  /// In en, this message translates to:
  /// **'BGC'**
  String get residenceBgc;

  /// Ortigas menu item
  ///
  /// In en, this message translates to:
  /// **'Ortigas'**
  String get residenceOrtigas;

  /// Alabang menu item
  ///
  /// In en, this message translates to:
  /// **'Alabang'**
  String get residenceAlabang;

  /// Calendar/Holiday section title
  ///
  /// In en, this message translates to:
  /// **'Calendar/Holidays'**
  String get calendarSection;

  /// Regular holiday menu item
  ///
  /// In en, this message translates to:
  /// **'Regular Holiday'**
  String get calendarRegularHoliday;

  /// Special working day menu item
  ///
  /// In en, this message translates to:
  /// **'Special Working Day'**
  String get calendarSpecialWorkingDay;

  /// Philippine travel destination section title
  ///
  /// In en, this message translates to:
  /// **'Travel Destinations'**
  String get travelDestinationSection;

  /// Manila travel destination menu item
  ///
  /// In en, this message translates to:
  /// **'Manila'**
  String get travelDestinationManila;

  /// Cebu travel destination menu item
  ///
  /// In en, this message translates to:
  /// **'Cebu'**
  String get travelDestinationCebu;

  /// Subic travel destination menu item
  ///
  /// In en, this message translates to:
  /// **'Subic'**
  String get travelDestinationSubic;

  /// Bohol travel destination menu item
  ///
  /// In en, this message translates to:
  /// **'Bohol'**
  String get travelDestinationBohol;

  /// Boracay travel destination menu item
  ///
  /// In en, this message translates to:
  /// **'Boracay'**
  String get travelDestinationBoracay;

  /// Palawan travel destination menu item
  ///
  /// In en, this message translates to:
  /// **'Palawan'**
  String get travelDestinationPalawan;

  /// El Nido travel destination menu item
  ///
  /// In en, this message translates to:
  /// **'El Nido'**
  String get travelDestinationElNido;

  /// El Nido travel destination description for featured card
  ///
  /// In en, this message translates to:
  /// **'Palawan\'s gem famous for lagoons and karst cliffs'**
  String get travelDestinationElNidoDescription;

  /// 1:1 chat navigation item label in chat-specific bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'1:1 Chat'**
  String get singleChat;

  /// Admin chat navigation item label in chat-specific bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Admin Chat'**
  String get adminChat;

  /// Text shown when a field value is not registered
  ///
  /// In en, this message translates to:
  /// **'Not registered'**
  String get notRegistered;

  /// Text indicating that phone number cannot be changed
  ///
  /// In en, this message translates to:
  /// **'Cannot be changed'**
  String get phoneNumberCannotBeChanged;

  /// Helper and tutor section title
  ///
  /// In en, this message translates to:
  /// **'Helper & Tutor'**
  String get helperSection;

  /// House helper menu item
  ///
  /// In en, this message translates to:
  /// **'House Helper'**
  String get helperHouseHelper;

  /// Driver menu item
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get helperDriver;

  /// Tutor menu item
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get helperTutor;

  /// How to find manpower agency section title
  ///
  /// In en, this message translates to:
  /// **'How to Find Manpower Agency'**
  String get helperFindManpower;

  /// DOLE registration verification
  ///
  /// In en, this message translates to:
  /// **'DOLE Registration Verification'**
  String get helperDoleVerify;

  /// Web search method
  ///
  /// In en, this message translates to:
  /// **'Web Search'**
  String get helperWebSearch;

  /// Online platform method
  ///
  /// In en, this message translates to:
  /// **'Online Platform'**
  String get helperOnlinePlatform;

  /// Facebook group method
  ///
  /// In en, this message translates to:
  /// **'Facebook Group'**
  String get helperFacebookGroup;

  /// Job site method
  ///
  /// In en, this message translates to:
  /// **'Job Site'**
  String get helperJobSite;

  /// Major agency contact information
  ///
  /// In en, this message translates to:
  /// **'Major Agency Contacts'**
  String get helperAgencyContact;

  /// Agency selection checklist title
  ///
  /// In en, this message translates to:
  /// **'Agency Selection Checklist'**
  String get helperChecklistTitle;

  /// Coming soon message for empty screens
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Hiring subcategory name
  ///
  /// In en, this message translates to:
  /// **'Hiring'**
  String get subCategoryHiring;

  /// Looking for job subcategory name
  ///
  /// In en, this message translates to:
  /// **'Looking for Job'**
  String get subCategoryLooking;

  /// Hiring form title hint
  ///
  /// In en, this message translates to:
  /// **'Enter job posting title'**
  String get wantedHiringTitle;

  /// Company name field label
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get wantedCompanyName;

  /// Company name hint text
  ///
  /// In en, this message translates to:
  /// **'Enter the company name'**
  String get wantedCompanyNameHint;

  /// Company name required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the company name'**
  String get wantedCompanyNameRequired;

  /// Company introduction field label
  ///
  /// In en, this message translates to:
  /// **'Company Introduction'**
  String get wantedCompanyIntro;

  /// Company introduction hint text
  ///
  /// In en, this message translates to:
  /// **'Enter company introduction (excluding job info)'**
  String get wantedCompanyIntroHint;

  /// Company introduction required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the company introduction'**
  String get wantedCompanyIntroRequired;

  /// Work range field label
  ///
  /// In en, this message translates to:
  /// **'Work Range'**
  String get wantedWorkRange;

  /// Work range hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., IT, Marketing, Sales'**
  String get wantedWorkRangeHint;

  /// Work range required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the work range'**
  String get wantedWorkRangeRequired;

  /// Address field label
  ///
  /// In en, this message translates to:
  /// **'Full Address in Philippines'**
  String get wantedAddress;

  /// Address hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., 123 Sample St., Makati City, Philippines'**
  String get wantedAddressHint;

  /// Address required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the address'**
  String get wantedAddressRequired;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get wantedPhone;

  /// Phone hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., 09171234567'**
  String get wantedPhoneHint;

  /// Phone required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the phone number'**
  String get wantedPhoneRequired;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get wantedEmail;

  /// Email hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., hr@company.com'**
  String get wantedEmailHint;

  /// Email required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the email address'**
  String get wantedEmailRequired;

  /// Salary field label
  ///
  /// In en, this message translates to:
  /// **'Salary (Peso)'**
  String get wantedSalary;

  /// Salary hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., 50000'**
  String get wantedSalaryHint;

  /// Salary required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the salary'**
  String get wantedSalaryRequired;

  /// Work type field label
  ///
  /// In en, this message translates to:
  /// **'Work Type'**
  String get wantedWorkType;

  /// Work type hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., 5 days a week, Mon-Fri'**
  String get wantedWorkTypeHint;

  /// Work type required validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter the work type'**
  String get wantedWorkTypeRequired;

  /// Entertainment section title for food, play, and sightseeing
  ///
  /// In en, this message translates to:
  /// **'Food, Fun & Sights'**
  String get entertainmentSection;

  /// Golf menu item
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get entertainmentGolf;

  /// Massage menu item
  ///
  /// In en, this message translates to:
  /// **'Massage'**
  String get entertainmentMassage;

  /// Nightlife menu item
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get entertainmentNightlife;

  /// Market tour menu item
  ///
  /// In en, this message translates to:
  /// **'Market Tour'**
  String get entertainmentMarketTour;

  /// Seafood menu item
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get entertainmentSeafood;

  /// Restaurant menu item
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get entertainmentRestaurant;

  /// Water sports menu item
  ///
  /// In en, this message translates to:
  /// **'Water Sports'**
  String get entertainmentWaterSports;

  /// Island tour menu item
  ///
  /// In en, this message translates to:
  /// **'Island Tour'**
  String get entertainmentIslandTour;

  /// Festival menu item
  ///
  /// In en, this message translates to:
  /// **'Festival'**
  String get entertainmentFestival;

  /// Message shown in quick post box during point event period
  ///
  /// In en, this message translates to:
  /// **'Point Event! Write posts and get random points~'**
  String get quickPostEventMessage;

  /// Default message shown in quick post box when not in event period
  ///
  /// In en, this message translates to:
  /// **'How is your life in the Philippines today?'**
  String get quickPostDefaultMessage;

  /// Search input field hint text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// Message shown when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// Section title for search results
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// Section title for Philippine travel spots sorted alphabetically
  ///
  /// In en, this message translates to:
  /// **'Philippine Travel Spots (A-Z)'**
  String get travelSpotsSectionAlphabetical;

  /// Intramuros travel spot
  ///
  /// In en, this message translates to:
  /// **'Intramuros'**
  String get travelSpotIntramuros;

  /// Ocean Park Manila travel spot
  ///
  /// In en, this message translates to:
  /// **'Ocean Park'**
  String get travelSpotOceanPark;

  /// Manila Bay travel spot
  ///
  /// In en, this message translates to:
  /// **'Manila Bay'**
  String get travelSpotManilaBay;

  /// Mall of Asia travel spot
  ///
  /// In en, this message translates to:
  /// **'Mall of Asia'**
  String get travelSpotMallOfAsia;

  /// Pagsanjan Falls travel spot
  ///
  /// In en, this message translates to:
  /// **'Pagsanjan Falls'**
  String get travelSpotPagsanjanFalls;

  /// Banaue Rice Terraces travel spot
  ///
  /// In en, this message translates to:
  /// **'Banaue'**
  String get travelSpotBanaue;

  /// Vigan historic city travel spot
  ///
  /// In en, this message translates to:
  /// **'Vigan'**
  String get travelSpotVigan;

  /// Mayon Volcano travel spot
  ///
  /// In en, this message translates to:
  /// **'Mayon Volcano'**
  String get travelSpotMayonVolcano;

  /// Coron travel spot
  ///
  /// In en, this message translates to:
  /// **'Coron'**
  String get travelSpotCoron;

  /// Puerto Princesa travel spot
  ///
  /// In en, this message translates to:
  /// **'Puerto Princesa'**
  String get travelSpotPuertoPrincesa;

  /// Tubbataha Reef travel spot
  ///
  /// In en, this message translates to:
  /// **'Tubbataha'**
  String get travelSpotTubbataha;

  /// Kawasan Falls travel spot
  ///
  /// In en, this message translates to:
  /// **'Kawasan Falls'**
  String get travelSpotKawasanFalls;

  /// Chocolate Hills travel spot
  ///
  /// In en, this message translates to:
  /// **'Chocolate Hills'**
  String get travelSpotChocolateHills;

  /// El Nido travel spot
  ///
  /// In en, this message translates to:
  /// **'El Nido'**
  String get travelSpotElNido;

  /// White Beach travel spot
  ///
  /// In en, this message translates to:
  /// **'White Beach'**
  String get travelSpotWhiteBeach;

  /// Puka Shell Beach travel spot
  ///
  /// In en, this message translates to:
  /// **'Puka Shell'**
  String get travelSpotPukaShellBeach;

  /// Nacpan Beach travel spot
  ///
  /// In en, this message translates to:
  /// **'Nacpan Beach'**
  String get travelSpotNacpanBeach;

  /// Entalula Beach travel spot
  ///
  /// In en, this message translates to:
  /// **'Entalula'**
  String get travelSpotEntalulaBeach;

  /// Alona Beach travel spot
  ///
  /// In en, this message translates to:
  /// **'Alona Beach'**
  String get travelSpotAlonaBeach;

  /// Seven Commandos Beach travel spot
  ///
  /// In en, this message translates to:
  /// **'7 Commandos'**
  String get travelSpotSevenCommandos;

  /// Big Lagoon travel spot
  ///
  /// In en, this message translates to:
  /// **'Big Lagoon'**
  String get travelSpotBigLagoon;

  /// Small Lagoon travel spot
  ///
  /// In en, this message translates to:
  /// **'Small Lagoon'**
  String get travelSpotSmallLagoon;

  /// Secret Lagoon travel spot
  ///
  /// In en, this message translates to:
  /// **'Secret Lagoon'**
  String get travelSpotSecretLagoon;

  /// Kayangan Lake travel spot
  ///
  /// In en, this message translates to:
  /// **'Kayangan Lake'**
  String get travelSpotKayanganLake;

  /// Twin Lagoon travel spot
  ///
  /// In en, this message translates to:
  /// **'Twin Lagoon'**
  String get travelSpotTwinLagoon;

  /// Barracuda Lake travel spot
  ///
  /// In en, this message translates to:
  /// **'Barracuda Lake'**
  String get travelSpotBarracudaLake;

  /// Moalboal Sardine Run travel spot
  ///
  /// In en, this message translates to:
  /// **'Moalboal Sardine'**
  String get travelSpotMoalboalSardine;

  /// Panagsama Beach travel spot
  ///
  /// In en, this message translates to:
  /// **'Panagsama'**
  String get travelSpotPanagsamaBeach;

  /// Cloud 9 travel spot
  ///
  /// In en, this message translates to:
  /// **'Cloud 9'**
  String get travelSpotCloudNine;

  /// Rice Terraces of the Philippine Cordilleras travel spot
  ///
  /// In en, this message translates to:
  /// **'Rice Terraces'**
  String get travelSpotRiceTerraces;

  /// Puerto-Princesa Subterranean River National Park travel spot
  ///
  /// In en, this message translates to:
  /// **'Underground River'**
  String get travelSpotSubterraneanRiver;

  /// San Agustin Church travel spot
  ///
  /// In en, this message translates to:
  /// **'San Agustin'**
  String get travelSpotSanAgustin;

  /// Paoay Church travel spot
  ///
  /// In en, this message translates to:
  /// **'Paoay Church'**
  String get travelSpotPaoayChurch;

  /// Santa Maria Church travel spot
  ///
  /// In en, this message translates to:
  /// **'Santa Maria'**
  String get travelSpotSantaMaria;

  /// Miagao Church travel spot
  ///
  /// In en, this message translates to:
  /// **'Miagao Church'**
  String get travelSpotMiagaoChurch;

  /// Fort Santiago travel spot
  ///
  /// In en, this message translates to:
  /// **'Fort Santiago'**
  String get travelSpotFortSantiago;

  /// Error message when chat room fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading chat room'**
  String get error_loading_chatroom;
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
