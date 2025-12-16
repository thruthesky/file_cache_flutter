// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'philgo_tr.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class PhilgoTrZh extends PhilgoTr {
  PhilgoTrZh([String locale = 'zh']) : super(locale);

  @override
  String get create_room => '创建房间';

  @override
  String get create => '创建';

  @override
  String get room_name => '房间名称';

  @override
  String get enter_room_name => '请输入房间名称';

  @override
  String get room_name_required => '房间名称是必填项';

  @override
  String get room_description => '房间描述';

  @override
  String get enter_room_description => '请输入房间描述';

  @override
  String get open_room => '开放房间';

  @override
  String get open_room_description => '对所有人开放加入';

  @override
  String get block_advertisement => '屏蔽广告';

  @override
  String get block_advertisement_description => '在此房间中屏蔽广告消息';

  @override
  String get creating => '正在创建...';

  @override
  String failed_to_create_room(String error) {
    return '创建房间失败：$error';
  }

  @override
  String failed_to_update_room(String error) {
    return '更新房间失败：$error';
  }

  @override
  String get report_select_reason => '请选择举报原因';

  @override
  String get report_success => '举报已成功提交';

  @override
  String get report_failed => '举报提交失败';

  @override
  String get report_message_already_reported => '此消息已被举报';

  @override
  String get report_room_already_reported => '此房间已被举报';

  @override
  String get report_submission_failed => '举报提交失败';

  @override
  String get report_chat_room => '举报聊天室';

  @override
  String get report_chat_message => '举报聊天消息';

  @override
  String get close => '关闭';

  @override
  String get cancel => '取消';

  @override
  String get report_submit => '提交';

  @override
  String get_report_reason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'spam': '垃圾信息',
      'abusive': '辱骂',
      'violence': '暴力',
      'hate_speech': '仇恨言论',
      'inappropriate_content': '不当内容',
      'other': 'reason',
    });
    return '$_temp0';
  }

  @override
  String get save => '保存';

  @override
  String get edit_chat_room_success => '成功';

  @override
  String get edit_chat_room => '编辑聊天室';

  @override
  String get profile_photo_updated => '个人资料照片已更新';

  @override
  String upload_photo_failed(String error) {
    return '上传失败：$error';
  }

  @override
  String get profile_photo_removed => '个人资料照片已删除';

  @override
  String failed_to_remove_profile_photo(String error) {
    return '删除个人资料照片失败：$error';
  }

  @override
  String members_count(int count) {
    return '$count 位成员';
  }

  @override
  String get menu => '菜单';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get delete_comment_confirmation => '您确定要删除此评论吗？';

  @override
  String get successfully_deleted => '评论已成功删除';

  @override
  String get enterComment => '输入您的评论';

  @override
  String get profile => '个人资料';

  @override
  String get recent_post => '最近的帖子';

  @override
  String get admin_chat_notice => '这是与我们管理团队的聊天。';

  @override
  String get report => '举报';

  @override
  String get unblock_user => '解除屏蔽用户';

  @override
  String get block_user => '屏蔽用户';

  @override
  String get leave => '离开';

  @override
  String get leave_room => '离开房间';

  @override
  String get leave_room_confirmation => '您确定要离开这个房间吗？';

  @override
  String get chat_room => '聊天室';

  @override
  String get protocol_create => '房间已创建';

  @override
  String protocol_join(String name) {
    return '$name 已加入房间';
  }

  @override
  String get protocol_invitation_not_sent => '邀请未发送';

  @override
  String protocol_left(String name) {
    return '$name 离开了房间';
  }

  @override
  String protocol_removed(String name) {
    return '$name 已被移出房间';
  }

  @override
  String error_with_message(String message) {
    return '错误：$message';
  }

  @override
  String get send_message_to_start_conversation => '发送消息开始对话';

  @override
  String get error => '错误';

  @override
  String get ok => '确定';

  @override
  String get want_to_delete => '您要删除吗？';

  @override
  String get confirm => '确认';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get no_posts_in_category => '此分类中没有帖子';

  @override
  String get be_first_to_post => '成为第一个发帖者';

  @override
  String get create_post => '创建帖子';

  @override
  String get leftroom_successfully => '成功离开房间';

  @override
  String get login_required => '需要登录';

  @override
  String get please_log_in_to_continue => '请登录以继续';

  @override
  String get message_moderated_by_ai => '此消息已被AI审核屏蔽。';

  @override
  String get message_moderated_as_advertisement => '此广告已被屏蔽。';

  @override
  String get blocked_message_tap_to_unblock => '来自被屏蔽用户的消息（点击解除屏蔽）';

  @override
  String get blocked_user_options => '被屏蔽用户选项';

  @override
  String get blocked_user_subtitle => '此用户目前已被屏蔽';

  @override
  String get unblock_user_description => '允许此用户再次向您发送消息';

  @override
  String get block_user_confirmation => '您确定要屏蔽此用户吗？';

  @override
  String get block_user_warning => '屏蔽此用户将阻止他们向您发送消息。';

  @override
  String get unblock_user_confirmation => '您确定要解除屏蔽此用户吗？';

  @override
  String get user_unblocked => '用户已被解除屏蔽';

  @override
  String get uploading_images => '正在上传图片';

  @override
  String max_files_reached(int max) {
    return '您最多可以选择 $max 个文件。';
  }

  @override
  String failed_to_send_message(String error) {
    return '发送消息失败：$error';
  }

  @override
  String get attach_files => '附加文件';

  @override
  String get type_message => '输入消息...';

  @override
  String get select_files => '选择文件';

  @override
  String get camera => '相机';

  @override
  String get gallery => '图库';

  @override
  String failed_to_start_chat(String error) {
    return '启动聊天失败：$error';
  }

  @override
  String get search_friends => '搜索好友';

  @override
  String get search_by_nickname => '按昵称搜索';

  @override
  String get no_users_found => '未找到用户';

  @override
  String get chat => '聊天';

  @override
  String empty_chat_list(String order) {
    String _temp0 = intl.Intl.selectLogic(order, {
      'order': '空聊天室',
      'single_order': '空好友列表',
      'group_order': '空群聊',
      'open_order': '空开放聊天',
      'other': '聊天室列表为空',
    });
    return '$_temp0';
  }

  @override
  String get turn_off_notifications => '关闭通知';

  @override
  String get turn_on_notifications => '开启通知';

  @override
  String get you => '您';

  @override
  String get no_recent_posts => '没有最近的帖子';

  @override
  String get block => '屏蔽';

  @override
  String get unblock => '解除屏蔽';

  @override
  String get success_user_blocked => '用户已成功屏蔽。';

  @override
  String get blocked_message => '来自被屏蔽用户的消息';

  @override
  String time_days_ago(int count) {
    return '$count天前';
  }

  @override
  String time_hours_ago(int count) {
    return '$count小时前';
  }

  @override
  String time_minutes_ago(int count) {
    return '$count分钟前';
  }

  @override
  String get time_just_now => '刚刚';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get now => '现在';

  @override
  String member_count_formatted(int count) {
    return '$count名成员';
  }

  @override
  String get take_photo_with_camera => '相机拍照';

  @override
  String get record_video_with_camera => '相机录像';

  @override
  String get select_from_gallery => '从相册选择';

  @override
  String get upload_file => '上传文件';

  @override
  String get select_upload_option => '选择上传选项';

  @override
  String get reply => '回复';

  @override
  String get like => '点赞';

  @override
  String get comment => '评论';

  @override
  String get share => '分享';

  @override
  String get beTheFirstToComment => '成为第一个评论的人';

  @override
  String get update => '更新';

  @override
  String get updateComment => '更新评论';

  @override
  String get join_url => '邀请链接';

  @override
  String get copied_to_clipboard => '已复制到剪贴板';

  @override
  String get receive_share_choose_post_or_chat => '1. 选择 `创建帖子` 或 `发送到聊天`';

  @override
  String get receive_share_choose_chat => '1. 选择 `发送到聊天好友`';

  @override
  String get receive_share_create_post => '创建新帖子';

  @override
  String get receive_share_image_and_text_chat => '仅图像或文本可以发送到聊天';

  @override
  String get receive_share_send_chat => '发送到聊天好友';

  @override
  String get receive_share_choose_friend => '2. 选择要发送的好友';

  @override
  String get receive_share_select_category => '2. 选择要发布的类别';

  @override
  String get receive_share_open => '打开';

  @override
  String get receive_share_send => '发送';

  @override
  String get receive_share => '接收分享';

  @override
  String get view_profile => '查看个人资料';

  @override
  String get confirmDiscard => '确定要丢弃正在编写的内容吗？';

  @override
  String get confirm_delete_comment_image => '确定要删除此图片吗？';

  @override
  String get bookmarked_folders => '书签文件夹';

  @override
  String get no_bookmarked_folders => '没有书签文件夹';

  @override
  String get bookmarked_chats => '书签聊天';

  @override
  String get no_bookmarked_chats => '此文件夹中没有书签聊天';

  @override
  String get unpin_chat_room_title => '取消固定聊天室';

  @override
  String get unpin_chat_room_message => '您确定要取消固定此聊天室吗？';

  @override
  String get pin => '固定';

  @override
  String get unpin => '取消固定';

  @override
  String get chat_room_unpinned => '聊天室已取消固定';

  @override
  String get add_to_favorites => '添加到收藏夹';

  @override
  String added_to_folder(String folderName) {
    return '已添加到 $folderName';
  }

  @override
  String removed_from_folder(String folderName) {
    return '已从 $folderName 移除';
  }

  @override
  String failed_to_update_favorite(String error) {
    return '更新收藏夹失败：$error';
  }

  @override
  String get create_new_folder => '创建新文件夹';

  @override
  String get folder_name => '文件夹名称';

  @override
  String get enter_folder_name => '输入文件夹名称';

  @override
  String chats_count(int count) {
    return '$count 个聊天';
  }

  @override
  String get no_name => '无名称';

  @override
  String get post_from_blocked_user => '来自被屏蔽用户的帖子';

  @override
  String get something_went_wrong => '出了点问题';

  @override
  String get enter_your_comment => '输入您的评论...';

  @override
  String get comments => '评论';

  @override
  String get this_post_has_comments => '这篇帖子有评论';

  @override
  String get be_the_first_to_comment => '成为第一个评论的人！';

  @override
  String get comment_blocked_message => '来自被屏蔽用户的评论';

  @override
  String get pinned_chats => '固定的聊天';

  @override
  String get report_reason_category_error => '分类错误（广告）';

  @override
  String get report_reason_abuse => '骚扰/侮辱/脏话';

  @override
  String get report_reason_spam => '垃圾信息/灌水及不当内容';

  @override
  String get report_reason_other => '其他';

  @override
  String get categoryFreetalk => '自由论坛';

  @override
  String get categoryQna => '问答';

  @override
  String get categoryBuyandsell => '买卖';

  @override
  String get categoryBlog => '博客';

  @override
  String get categoryBoardingHouse => '寄宿舍';

  @override
  String get categoryCaution => '注意/警告';

  @override
  String get categoryLookfor => '寻人';

  @override
  String get categoryFoodDelivery => '外卖';

  @override
  String get categoryGreeting => '问候';

  @override
  String get categoryWanted => '招聘求职';

  @override
  String get categoryBusiness => '商务';

  @override
  String get categoryMassage => '按摩';

  @override
  String get categoryRest => '餐厅';

  @override
  String get categorySchool => '学校';

  @override
  String get categoryStudy => '语言研修';

  @override
  String get categoryTravel => '旅行';

  @override
  String get categoryYoutube => 'YouTube';

  @override
  String get categoryMomcafe => '妈妈咖啡';

  @override
  String get categoryNews => '新闻';

  @override
  String get categoryNewcomer => '新人';

  @override
  String get categoryNature => '自然';

  @override
  String get categoryCompanyInfo => '公司信息';

  @override
  String get categoryEnglishBiz => '英语商务';

  @override
  String get categoryTemp => '临时';

  @override
  String get categoryTravelGood => '推荐旅游地';

  @override
  String get subCategoryDiscussion => '讨论';

  @override
  String get subCategoryEncyclopedia => '百科';

  @override
  String get subCategoryHobby => '爱好';

  @override
  String get subCategoryInfo => '信息';

  @override
  String get subCategoryKoPhCouple => '韩菲情侣';

  @override
  String get subCategoryKopino => 'Kopino';

  @override
  String get subCategoryImmigration => '移民';

  @override
  String get subCategoryPhoto => '照片';

  @override
  String get subCategoryLifeTips => '生活小贴士';

  @override
  String get subCategoryMissing => '失踪';

  @override
  String get subCategoryIntlMarriage => '国际婚姻';

  @override
  String get subCategoryMeeting => '聚会';

  @override
  String get subCategoryColumn => '专栏';

  @override
  String get subCategoryMukbang => '吃播';

  @override
  String get subCategoryNotice => '公告';

  @override
  String get subCategoryExperience => '经验分享';

  @override
  String get subCategoryStudyLearn => '学习';

  @override
  String get subCategoryTyphoon => '台风';

  @override
  String get subCategoryBusinessPartner => '商业伙伴';

  @override
  String get subCategoryComputer => '电脑/网络';

  @override
  String get subCategoryExchange => '比索兑换';

  @override
  String get subCategoryPhone => '手机';

  @override
  String get subCategoryHotel => '酒店';

  @override
  String get subCategoryAppliances => '家电/生活用品';

  @override
  String get subCategoryGolf => '高尔夫';

  @override
  String get subCategoryPromotion => '促销';

  @override
  String get subCategoryPersonalMarket => '个人交易';

  @override
  String get subCategoryRealEstate => '房地产';

  @override
  String get subCategoryHouseRental => '房屋出租';

  @override
  String get subCategoryCarRental => '租车';

  @override
  String get subCategoryUsedCar => '二手车';

  @override
  String get subCategoryManila => 'Manila';

  @override
  String get subCategoryCebu => 'Cebu';

  @override
  String get subCategoryAngeles => 'Angeles';

  @override
  String get categoryAll => '全部';
}
