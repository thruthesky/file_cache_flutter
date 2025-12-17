// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'philgo_tr.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class PhilgoTrJa extends PhilgoTr {
  PhilgoTrJa([String locale = 'ja']) : super(locale);

  @override
  String get create_room => 'ルーム作成';

  @override
  String get create => '作成';

  @override
  String get room_name => 'ルーム名';

  @override
  String get enter_room_name => 'ルーム名を入力してください';

  @override
  String get room_name_required => 'ルーム名は必須です';

  @override
  String get room_description => 'ルームの説明';

  @override
  String get enter_room_description => 'ルームの説明を入力してください';

  @override
  String get open_room => 'オープンルーム';

  @override
  String get open_room_description => '誰でも参加できるようにオープン';

  @override
  String get block_advertisement => '広告ブロック';

  @override
  String get block_advertisement_description => 'このルームで広告メッセージをブロック';

  @override
  String get creating => '作成中...';

  @override
  String failed_to_create_room(String error) {
    return 'ルーム作成に失敗しました：$error';
  }

  @override
  String failed_to_update_room(String error) {
    return 'ルーム更新に失敗しました：$error';
  }

  @override
  String get report_select_reason => '通報理由を選択してください';

  @override
  String get report_success => '通報が正常に送信されました';

  @override
  String get report_failed => '通報の送信に失敗しました';

  @override
  String get report_message_already_reported => 'このメッセージは既に通報されています';

  @override
  String get report_room_already_reported => 'このルームは既に通報されています';

  @override
  String get report_submission_failed => '通報の送信に失敗しました';

  @override
  String get report_chat_room => 'チャットルームを通報';

  @override
  String get report_chat_message => 'チャットメッセージを通報';

  @override
  String get close => '閉じる';

  @override
  String get cancel => 'キャンセル';

  @override
  String get report_submit => '送信';

  @override
  String get_report_reason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'spam': 'スパム',
      'abusive': '侮辱的',
      'violence': '暴力',
      'hate_speech': 'ヘイトスピーチ',
      'inappropriate_content': '不適切なコンテンツ',
      'other': 'reason',
    });
    return '$_temp0';
  }

  @override
  String get save => '保存';

  @override
  String get edit_chat_room_success => '成功';

  @override
  String get edit_chat_room => 'チャットルームを編集';

  @override
  String get profile_photo_updated => 'プロフィール写真が更新されました';

  @override
  String upload_photo_failed(String error) {
    return 'アップロードに失敗しました：$error';
  }

  @override
  String get profile_photo_removed => 'プロフィール写真が削除されました';

  @override
  String failed_to_remove_profile_photo(String error) {
    return 'プロフィール写真の削除に失敗しました：$error';
  }

  @override
  String members_count(int count) {
    return '$count 名のメンバー';
  }

  @override
  String get menu => 'メニュー';

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

  @override
  String get delete_comment_confirmation => '本当にこのコメントを削除しますか？';

  @override
  String get successfully_deleted => 'コメントが正常に削除されました';

  @override
  String get enterComment => 'コメントを入力してください';

  @override
  String get profile => 'プロフィール';

  @override
  String get recent_post => '最近の投稿';

  @override
  String get admin_chat_notice => 'これは管理チームとのチャットです。';

  @override
  String get report => '通報';

  @override
  String get unblock_user => 'ユーザーのブロック解除';

  @override
  String get block_user => 'ユーザーをブロック';

  @override
  String get leave => '退出';

  @override
  String get leave_room => 'ルームを退出';

  @override
  String get leave_room_confirmation => '本当にこのルームを退出しますか？';

  @override
  String get chat_room => 'チャットルーム';

  @override
  String get protocol_create => 'ルームが作成されました';

  @override
  String protocol_join(String name) {
    return '$nameさんがルームに参加しました';
  }

  @override
  String get protocol_invitation_not_sent => '招待が送信されませんでした';

  @override
  String protocol_left(String name) {
    return '$nameさんがルームを退出しました';
  }

  @override
  String protocol_removed(String name) {
    return '$nameさんがルームから削除されました';
  }

  @override
  String error_with_message(String message) {
    return 'エラー：$message';
  }

  @override
  String get send_message_to_start_conversation => 'メッセージを送信して会話を開始';

  @override
  String get error => 'エラー';

  @override
  String get ok => 'OK';

  @override
  String get want_to_delete => '削除しますか？';

  @override
  String get confirm => '確認';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get no_posts_in_category => 'このカテゴリに投稿はありません';

  @override
  String get be_first_to_post => '最初の投稿者になりましょう';

  @override
  String get create_post => '投稿を作成';

  @override
  String get leftroom_successfully => 'ルームを正常に退出しました';

  @override
  String get login_required => 'ログインが必要です';

  @override
  String get please_log_in_to_continue => '続行するにはログインしてください';

  @override
  String get message_moderated_by_ai => 'このメッセージはAIモデレーションによりブロックされました。';

  @override
  String get message_moderated_as_advertisement => 'この広告はブロックされました。';

  @override
  String get blocked_message_tap_to_unblock =>
      'ブロックされたユーザーからのメッセージ（タップしてブロック解除）';

  @override
  String get blocked_user_options => 'ブロックされたユーザーのオプション';

  @override
  String get blocked_user_subtitle => 'このユーザーは現在ブロックされています';

  @override
  String get unblock_user_description => 'このユーザーが再びメッセージを送信できるようにします';

  @override
  String get block_user_confirmation => '本当にこのユーザーをブロックしますか？';

  @override
  String get block_user_warning => 'このユーザーをブロックすると、メッセージを送信できなくなります。';

  @override
  String get unblock_user_confirmation => '本当にこのユーザーのブロックを解除しますか？';

  @override
  String get user_unblocked => 'ユーザーのブロックが解除されました';

  @override
  String get uploading_images => '画像をアップロード中';

  @override
  String max_files_reached(int max) {
    return '最大$max個のファイルを選択できます。';
  }

  @override
  String failed_to_send_message(String error) {
    return 'メッセージの送信に失敗しました：$error';
  }

  @override
  String get attach_files => 'ファイルを添付';

  @override
  String get type_message => 'メッセージを入力...';

  @override
  String get select_files => 'ファイルを選択';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String failed_to_start_chat(String error) {
    return 'チャットの開始に失敗しました：$error';
  }

  @override
  String get search_friends => '友達を検索';

  @override
  String get search_by_nickname => 'ニックネームで検索';

  @override
  String get no_users_found => 'ユーザーが見つかりません';

  @override
  String get chat => 'チャット';

  @override
  String empty_chat_list(String order) {
    String _temp0 = intl.Intl.selectLogic(order, {
      'order': '空のチャットルーム',
      'single_order': '空の友達リスト',
      'group_order': '空のグループチャット',
      'open_order': '空のオープンチャット',
      'other': 'チャットルームリストが空です',
    });
    return '$_temp0';
  }

  @override
  String get turn_off_notifications => '通知をオフにする';

  @override
  String get turn_on_notifications => '通知をオンにする';

  @override
  String get you => 'あなた';

  @override
  String get no_recent_posts => '最近の投稿はありません';

  @override
  String get block => 'ブロック';

  @override
  String get unblock => 'ブロック解除';

  @override
  String get success_user_blocked => 'ユーザーが正常にブロックされました。';

  @override
  String get blocked_message => 'ブロックされたユーザーからのメッセージ';

  @override
  String time_days_ago(int count) {
    return '$count日前';
  }

  @override
  String time_hours_ago(int count) {
    return '$count時間前';
  }

  @override
  String time_minutes_ago(int count) {
    return '$count分前';
  }

  @override
  String get time_just_now => 'たった今';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get now => '今';

  @override
  String member_count_formatted(int count) {
    return '$count名';
  }

  @override
  String get take_photo_with_camera => 'カメラで写真を撮る';

  @override
  String get record_video_with_camera => 'カメラで動画を録画';

  @override
  String get select_from_gallery => 'ギャラリーから選択';

  @override
  String get upload_file => 'ファイルアップロード';

  @override
  String get select_upload_option => 'アップロードオプションを選択';

  @override
  String get reply => '返信';

  @override
  String get like => 'いいね';

  @override
  String get comment => 'コメント';

  @override
  String get share => '共有';

  @override
  String get beTheFirstToComment => '最初のコメントを投稿しよう';

  @override
  String get update => '更新';

  @override
  String get updateComment => 'コメントを更新';

  @override
  String get join_url => '招待URL';

  @override
  String get copied_to_clipboard => 'クリップボードにコピーされました';

  @override
  String get receive_share_choose_post_or_chat =>
      '1. `投稿を作成`するか`チャットに送信`するかを選択';

  @override
  String get receive_share_choose_chat => '1. `チャットに送信`を選択';

  @override
  String get receive_share_create_post => '`新しい投稿を作成`を選択';

  @override
  String get receive_share_image_and_text_chat => '`画像またはテキスト`のみをチャットに送信できます';

  @override
  String get receive_share_send_chat => '`チャットの友達に送信`を選択';

  @override
  String get receive_share_choose_friend => '2. 送信先の友達を選択';

  @override
  String get receive_share_select_category => '2. 投稿するカテゴリを選択';

  @override
  String get receive_share_open => 'オープン';

  @override
  String get receive_share_send => '送信';

  @override
  String get receive_share => '受信共有';

  @override
  String get view_profile => 'プロフィールを見る';

  @override
  String get confirmDiscard => '作成中の内容を破棄してもよろしいですか？';

  @override
  String get confirm_delete_comment_image => 'この画像を削除してもよろしいですか？';

  @override
  String get bookmarked_folders => 'ブックマークフォルダ';

  @override
  String get no_bookmarked_folders => 'ブックマークされたフォルダがありません';

  @override
  String get bookmarked_chats => 'ブックマークされたチャット';

  @override
  String get no_bookmarked_chats => 'このフォルダにブックマークされたチャットがありません';

  @override
  String get unpin_chat_room_title => 'チャットルームの固定を解除';

  @override
  String get unpin_chat_room_message => 'このチャットルームの固定を解除してもよろしいですか？';

  @override
  String get pin => '固定';

  @override
  String get unpin => '固定解除';

  @override
  String get chat_room_unpinned => 'チャットルームの固定が解除されました';

  @override
  String get add_to_favorites => 'お気に入りに追加';

  @override
  String added_to_folder(String folderName) {
    return '$folderNameに追加されました';
  }

  @override
  String removed_from_folder(String folderName) {
    return '$folderNameから削除されました';
  }

  @override
  String failed_to_update_favorite(String error) {
    return 'お気に入りの更新に失敗しました：$error';
  }

  @override
  String get create_new_folder => '新しいフォルダを作成';

  @override
  String get folder_name => 'フォルダ名';

  @override
  String get enter_folder_name => 'フォルダ名を入力してください';

  @override
  String chats_count(int count) {
    return '$count件のチャット';
  }

  @override
  String get no_name => '名前なし';

  @override
  String get post_from_blocked_user => 'ブロックされたユーザーからの投稿';

  @override
  String get something_went_wrong => '問題が発生しました';

  @override
  String get enter_your_comment => 'コメントを入力してください...';

  @override
  String get comments => 'コメント';

  @override
  String get this_post_has_comments => 'この投稿にはコメントがあります';

  @override
  String get be_the_first_to_comment => '最初のコメントを投稿しよう！';

  @override
  String get comment_blocked_message => 'ブロックされたユーザーのコメント';

  @override
  String get pinned_chats => '固定されたチャット';

  @override
  String get report_reason_category_error => 'カテゴリー分類エラー（広告）';

  @override
  String get report_reason_abuse => '嫌がらせ/侮辱/暴言';

  @override
  String get report_reason_spam => 'スパム/荒らし及び不適切な内容';

  @override
  String get report_reason_other => 'その他';

  @override
  String get categoryFreetalk => '自由掲示板';

  @override
  String get categoryQna => '質問と回答';

  @override
  String get categoryBuyandsell => '売買';

  @override
  String get categoryBlog => 'ブログ';

  @override
  String get categoryBoardingHouse => '下宿/寮';

  @override
  String get categoryCaution => '注意/警告';

  @override
  String get categoryLookfor => '人探し';

  @override
  String get categoryFoodDelivery => 'フードデリバリー';

  @override
  String get categoryGreeting => '挨拶';

  @override
  String get categoryWanted => '求人求職';

  @override
  String get categoryBusiness => 'ビジネス';

  @override
  String get categoryMassage => 'マッサージ';

  @override
  String get categoryRest => 'レストラン';

  @override
  String get categorySchool => '学校';

  @override
  String get categoryStudy => '語学研修';

  @override
  String get categoryTravel => '旅行';

  @override
  String get categoryYoutube => 'YouTube';

  @override
  String get categoryMomcafe => 'ママカフェ';

  @override
  String get categoryNews => 'ニュース';

  @override
  String get categoryNewcomer => '新人';

  @override
  String get categoryNature => '自然';

  @override
  String get categoryCompanyInfo => '会社情報';

  @override
  String get categoryEnglishBiz => '英語ビジネス';

  @override
  String get categoryTemp => '一時';

  @override
  String get categoryTravelGood => 'おすすめ旅行先';

  @override
  String get subCategoryDiscussion => 'ディスカッション';

  @override
  String get subCategoryEncyclopedia => '百科';

  @override
  String get subCategoryHobby => '趣味';

  @override
  String get subCategoryInfo => '情報';

  @override
  String get subCategoryKoPhCouple => '韓比カップル';

  @override
  String get subCategoryKopino => 'コピノ';

  @override
  String get subCategoryImmigration => '移民';

  @override
  String get subCategoryPhoto => '写真';

  @override
  String get subCategoryLifeTips => '生活のコツ';

  @override
  String get subCategoryMissing => '行方不明';

  @override
  String get subCategoryIntlMarriage => '国際結婚';

  @override
  String get subCategoryMeeting => '集まり';

  @override
  String get subCategoryColumn => 'コラム';

  @override
  String get subCategoryMukbang => 'モッパン';

  @override
  String get subCategoryNotice => 'お知らせ';

  @override
  String get subCategoryExperience => '経験談';

  @override
  String get subCategoryStudyLearn => '勉強';

  @override
  String get subCategoryTyphoon => '台風';

  @override
  String get subCategoryBusinessPartner => 'ビジネスパートナー';

  @override
  String get subCategoryComputer => 'パソコン/インターネット';

  @override
  String get subCategoryExchange => 'ペソ両替';

  @override
  String get subCategoryPhone => '携帯電話';

  @override
  String get subCategoryHotel => 'ホテル';

  @override
  String get subCategoryAppliances => '家電/生活用品';

  @override
  String get subCategoryGolf => 'ゴルフ';

  @override
  String get subCategoryPromotion => 'プロモーション';

  @override
  String get subCategoryPersonalMarket => '個人売買';

  @override
  String get subCategoryRealEstate => '不動産';

  @override
  String get subCategoryHouseRental => '住宅賃貸';

  @override
  String get subCategoryCarRental => 'レンタカー';

  @override
  String get subCategoryUsedCar => '中古車';

  @override
  String get subCategoryManila => 'Manila';

  @override
  String get subCategoryCebu => 'Cebu';

  @override
  String get subCategoryAngeles => 'Angeles';

  @override
  String get categoryAll => 'すべて';

  @override
  String get currentPointBalance => '保有ポイント';

  @override
  String get pointAdvertisement => 'ポイント広告';

  @override
  String pointAdvertisementWithDays(int days) {
    return 'ポイント広告: $days日';
  }

  @override
  String pointAdvertisementAddDays(int days) {
    return 'ポイント広告: +$days日';
  }

  @override
  String get pointAdvertisementDescription => '投稿をリストの上部に表示';

  @override
  String get days => '日';

  @override
  String get points => 'ポイント';

  @override
  String daysAdvertisementCost(int days) {
    return '日の広告費用';
  }

  @override
  String get confirmSelection => '選択を確認';

  @override
  String get selectAdvertisementDays => '広告日数を選択してください';
}
