// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class LibTrKo extends LibTr {
  LibTrKo([String locale = 'ko']) : super(locale);

  @override
  String get create_room => '내 애플리케이션';

  @override
  String get create => '만들기';

  @override
  String get room_name => '방 이름';

  @override
  String get enter_room_name => '방 이름을 입력하세요';

  @override
  String get room_name_required => '방 이름은 필수입니다';

  @override
  String get room_description => '방 설명';

  @override
  String get enter_room_description => '방 설명을 입력하세요';

  @override
  String get open_room => '오픈 방';

  @override
  String get open_room_description => '모두가 참여할 수 있도록 오픈';

  @override
  String get block_advertisement => '광고 차단';

  @override
  String get block_advertisement_description => '이 방에서 광고 메시지를 차단합니다';

  @override
  String get creating => '만드는 중...';

  @override
  String failed_to_create_room(String error) {
    return '방 생성 실패: $error';
  }

  @override
  String failed_to_update_room(String error) {
    return '방 업데이트 실패: $error';
  }

  @override
  String get report_select_reason => '신고 사유를 선택하세요';

  @override
  String get report_success => '신고가 성공적으로 제출되었습니다';

  @override
  String get report_failed => '신고 제출에 실패했습니다';

  @override
  String get report_message_already_reported => '이 메시지는 이미 신고되었습니다';

  @override
  String get report_room_already_reported => '이 방은 이미 신고되었습니다';

  @override
  String get report_submission_failed => '신고 제출에 실패했습니다';

  @override
  String get report_chat_room => '채팅 방 신고';

  @override
  String get report_chat_message => '채팅 메시지 신고';

  @override
  String get close => '닫기';

  @override
  String get cancel => '취소';

  @override
  String get report_submit => '제출';

  @override
  String get_report_reason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'spam': '스팸',
      'abusive': '모욕적인',
      'violence': '폭력',
      'hate_speech': '증오 발언',
      'inappropriate_content': '부적절한 콘텐츠',
      'other': 'reason',
    });
    return '$_temp0';
  }

  @override
  String get save => '저장';

  @override
  String get edit_chat_room_success => '채팅방 편집 성공';

  @override
  String get edit_chat_room => '채팅방 편집';

  @override
  String get profile_photo_updated => '프로필 사진이 업데이트되었습니다';

  @override
  String upload_photo_failed(String error) {
    return '업로드 실패: $error';
  }

  @override
  String get profile_photo_removed => '프로필 사진이 제거되었습니다';

  @override
  String failed_to_remove_profile_photo(String error) {
    return '프로필 사진 제거 실패: $error';
  }

  @override
  String members_count(int count) {
    return '$count 멤버';
  }

  @override
  String get menu => '메뉴';

  @override
  String get edit => '수정';

  @override
  String get delete => '삭제';

  @override
  String get delete_comment_confirmation => '이 댓글을 삭제하시겠습니까?';

  @override
  String get successfully_deleted => '댓글이 성공적으로 삭제되었습니다';

  @override
  String get enterComment => '댓글을 입력하세요';

  @override
  String get profile => '프로필';

  @override
  String get recent_post => '최근 게시물';

  @override
  String get admin_chat_notice => '이것은 관리자 팀과의 채팅입니다.';

  @override
  String get report => '신고';

  @override
  String get unblock_user => '사용자 차단 해제';

  @override
  String get block_user => '사용자 차단';

  @override
  String get leave => '나가기';

  @override
  String get leave_room => '방 나가기';

  @override
  String get leave_room_confirmation => '이 방을 나가시겠습니까?';

  @override
  String get chat_room => '채팅방';

  @override
  String get protocol_create => '방이 생성되었습니다';

  @override
  String protocol_join(String name) {
    return '$name님이 방에 참여했습니다';
  }

  @override
  String get protocol_invitation_not_sent => '초대장을 보내지 못했습니다';

  @override
  String protocol_left(String name) {
    return '$name님이 방을 나갔습니다';
  }

  @override
  String protocol_removed(String name) {
    return '$name님이 방에서 제거되었습니다';
  }

  @override
  String error_with_message(String message) {
    return '오류: $message';
  }

  @override
  String get send_message_to_start_conversation => '대화를 시작하려면 메시지를 보내세요';

  @override
  String get error => '오류';

  @override
  String get ok => '확인';

  @override
  String get want_to_delete => '삭제하시겠습니까?';

  @override
  String get confirm => '확인';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get no_posts_in_category => '이 카테고리에 게시글이 없습니다';

  @override
  String get be_first_to_post => '첫 게시글을 작성해보세요';

  @override
  String get create_post => '게시글 작성';

  @override
  String get leftroom_successfully => '방을 나갔습니다';

  @override
  String get login_required => '로그인이 필요합니다';

  @override
  String get please_log_in_to_continue => '계속하려면 로그인하세요';

  @override
  String get message_moderated_by_ai => '이 메시지는 AI 검열에 의해 차단되었습니다.';

  @override
  String get message_moderated_as_advertisement => '이 광고는 차단되었습니다.';

  @override
  String get blocked_message_tap_to_unblock => '차단된 사용자로부터의 메시지 (탭하여 차단 해제)';

  @override
  String get blocked_user_options => '차단된 사용자 옵션';

  @override
  String get blocked_user_subtitle => '이 사용자는 현재 차단되었습니다.';

  @override
  String get unblock_user_description => '이 사용자가 다시 메시지를 보낼 수 있도록 허용합니다.';

  @override
  String get block_user_confirmation => '이 사용자를 차단하시겠습니까?';

  @override
  String get block_user_warning => '이 사용자를 차단하면 메시지를 보낼 수 없습니다.';

  @override
  String get unblock_user_confirmation => '이 사용자의 차단을 해제하시겠습니까?';

  @override
  String get user_unblocked => '사용자가 성공적으로 차단 해제되었습니다.';

  @override
  String get uploading_images => '이미지를 업로드하는 중입니다';

  @override
  String max_files_reached(int max) {
    return '최대 $max개의 파일을 선택할 수 있습니다.';
  }

  @override
  String failed_to_send_message(String error) {
    return '메시지 전송 실패: $error';
  }

  @override
  String get attach_files => '파일 첨부';

  @override
  String get type_message => '메시지를 입력하세요...';

  @override
  String get select_files => '파일 선택';

  @override
  String get camera => '카메라';

  @override
  String get gallery => '갤러리';

  @override
  String failed_to_start_chat(String error) {
    return '채팅 시작 실패: $error';
  }

  @override
  String get search_friends => '친구 검색';

  @override
  String get search_by_nickname => '닉네임으로 검색';

  @override
  String get no_users_found => '사용자를 찾을 수 없습니다';

  @override
  String get chat => '채팅';

  @override
  String empty_chat_list(String order) {
    String _temp0 = intl.Intl.selectLogic(order, {
      'order': '빈 채팅방',
      'single_order': '빈 친구 목록',
      'group_order': '빈 그룹 채팅',
      'open_order': '빈 오픈 채팅',
      'other': '채팅방 목록이 비어 있습니다',
    });
    return '$_temp0';
  }

  @override
  String get turn_off_notifications => '알림 끄기';

  @override
  String get turn_on_notifications => '알림 켜기';

  @override
  String get you => '당신';

  @override
  String get no_recent_posts => '최근 게시물이 없습니다';

  @override
  String get block => '차단';

  @override
  String get unblock => '차단 해제';

  @override
  String get success_user_blocked => '사용자가 성공적으로 차단되었습니다.';

  @override
  String get blocked_message => '차단된 사용자로부터의 메시지';

  @override
  String time_days_ago(int count) {
    return '$count일 전';
  }

  @override
  String time_hours_ago(int count) {
    return '$count시간 전';
  }

  @override
  String time_minutes_ago(int count) {
    return '$count분 전';
  }

  @override
  String get time_just_now => '방금 전';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get now => '지금';

  @override
  String member_count_formatted(int count) {
    return '$count명';
  }

  @override
  String get take_photo_with_camera => '카메라로 사진 촬영';

  @override
  String get record_video_with_camera => '카메라로 동영상 촬영';

  @override
  String get select_from_gallery => '갤러리에서 선택';

  @override
  String get upload_file => '파일 업로드';

  @override
  String get select_upload_option => '업로드 옵션 선택';

  @override
  String get reply => '답글';

  @override
  String get like => '좋아요';

  @override
  String get comment => '댓글';

  @override
  String get share => '공유';

  @override
  String get beTheFirstToComment => '첫 댓글을 남겨보세요';

  @override
  String get update => '수정';

  @override
  String get updateComment => '댓글 수정';

  @override
  String get join_url => '초대 URL';

  @override
  String get copied_to_clipboard => '클립보드에 복사되었습니다';

  @override
  String get receive_share_choose_post_or_chat =>
      '1. `게시물 작성` 또는 `채팅으로 전송`을 선택하세요';

  @override
  String get receive_share_choose_chat => '1. `채팅으로 전송`을 선택하세요';

  @override
  String get receive_share_create_post => '1. `새 게시물 작성`을 선택하세요';

  @override
  String get receive_share_image_and_text_chat =>
      '1. `이미지 또는 텍스트`만 채팅으로 전송할 수 있습니다';

  @override
  String get receive_share_send_chat => '1. `채팅 친구에게 전송`을 선택하세요';

  @override
  String get receive_share_choose_friend => '2. 전송할 친구를 선택하세요';

  @override
  String get receive_share_select_category => '2. 게시할 카테고리를 선택하세요';

  @override
  String get receive_share_open => '오픈';

  @override
  String get receive_share_send => '전송';

  @override
  String get receive_share => '공유 받기';

  @override
  String get view_profile => '보기';

  @override
  String get confirmDiscard => '작성 중인 내용을 버리시겠습니까?';

  @override
  String get confirm_delete_comment_image => '이 이미지를 삭제하시겠습니까?';

  @override
  String get bookmarked_folders => '북마크 폴더';

  @override
  String get no_bookmarked_folders => '북마크된 폴더가 없습니다';

  @override
  String get bookmarked_chats => '북마크된 채팅';

  @override
  String get no_bookmarked_chats => '이 폴더에 북마크된 채팅이 없습니다';

  @override
  String get unpin_chat_room_title => '채팅방 고정 해제';

  @override
  String get unpin_chat_room_message => '이 채팅방의 고정을 해제하시겠습니까?';

  @override
  String get unpin => '고정 해제';

  @override
  String get chat_room_unpinned => '채팅방 고정이 해제되었습니다';

  @override
  String get add_to_favorites => '즐겨찾기에 추가';

  @override
  String get no_name => '이름 없음';

  @override
  String added_to_folder(String folderName) {
    return '$folderName에 추가되었습니다';
  }

  @override
  String removed_from_folder(String folderName) {
    return '$folderName에서 제거되었습니다';
  }

  @override
  String failed_to_update_favorite(String error) {
    return '즐겨찾기 업데이트 실패: $error';
  }

  @override
  String get create_new_folder => '새 폴더 만들기';

  @override
  String get folder_name => '폴더 이름';

  @override
  String get enter_folder_name => '폴더 이름을 입력하세요';

  @override
  String chats_count(int count) {
    return '$count개의 채팅';
  }

  @override
  String get post_from_blocked_user => '차단된 사용자의 게시물';

  @override
  String get something_went_wrong => '문제가 발생했습니다';

  @override
  String get enter_your_comment => '댓글을 입력하세요...';

  @override
  String get comments => '댓글';

  @override
  String get this_post_has_comments => '이 게시물에 댓글이 있습니다';

  @override
  String get be_the_first_to_comment => '첫 댓글을 남겨보세요!';

  @override
  String get comment_blocked_message => '차단된 사용자의 댓글';
}
