/// PhilGo API 패키지
/// 필고 서비스의 핵심 기능을 제공하는 라이브러리입니다.
library;

// =============================================================================
// Banners - 배너 위젯 및 API
// 앱 내 다양한 형태의 배너를 표시하는 위젯들
// =============================================================================
export 'src/banners/banner.api.dart';
export 'src/banners/banner.model.dart';
export 'src/banners/wing/carousel_wing_banners.dart';
export 'src/banners/small_banners.dart';
export 'src/banners/square_banners.dart';
export 'src/banners/top_banners.dart';
export 'src/banners/wing/wing_banners.dart';

// =============================================================================
// Cache - 캐시
// 데이터 캐싱을 위한 유틸리티
// =============================================================================
export 'src/cache/post_cache.dart';

// =============================================================================
// Chat - 채팅
// 실시간 채팅 기능 (1:1 채팅, 그룹 채팅, 채팅방 관리)
// =============================================================================
export 'src/chat/chat.defines.dart';
export 'src/chat/chat.functions.dart';
export 'src/chat/chat.service.dart';
// Chat - List (채팅방 목록)
export 'src/chat/list/chat.room_join_list.builder.dart';
export 'src/chat/list/chat.room_list_tile.dart';
export 'src/chat/list/chat.room_list_view.dart';
// Chat - Models (채팅 데이터 모델)
export 'src/chat/models/chat.join.dart';
export 'src/chat/models/chat.last_message.dart';
export 'src/chat/models/chat.message.dart';
export 'src/chat/models/chat.room.dart';
// Chat - Report (채팅 신고)
export 'src/chat/report/chat.report.dart';
// Chat - Room (채팅방 UI 컴포넌트)
export 'src/chat/room/chat.create_room_screen.dart';
export 'src/chat/room/chat.room.header.dart';
export 'src/chat/room/chat.room.init.dart';
export 'src/chat/room/chat.room.message_bubble.dart';
export 'src/chat/room/chat.room.message_input.dart';
export 'src/chat/room/chat.room.message_list.dart';
export 'src/chat/room/chat.room_edit.dart';
export 'src/chat/room/chat.room_screen.dart';
// Chat - Single Room (1:1 채팅방)
export 'src/chat/room/single.chat_room.dart';
export 'src/chat/room/single.chat_room.header.dart';
export 'src/chat/room/single.chat_room.init.dart';
export 'src/chat/room/single.chat_room.message_list.dart';
// Chat - Widgets (채팅 관련 위젯)
export 'src/chat/widgets/chat.join.builder.dart';
export 'src/chat/widgets/chat.room.builder.dart';
export 'src/chat/widgets/pinned_chat_rooms_list.dart';
export 'src/chat/widgets/search_friends_dialog.dart';

// =============================================================================
// Comment - 댓글
// 게시글 댓글 작성 및 수정 기능
// =============================================================================
export 'src/comment/comment.create.form.dart';
export 'src/comment/comment.update.dart';
export 'src/comment/reply_to_comment.dart';

// =============================================================================
// Company - 업체
// 업체 등록, 목록, 카테고리 관련 기능
// =============================================================================
export 'src/company/company.functions.dart';
export 'src/company/models/company.list.model.dart';
export 'src/company/models/company.model.dart';
export 'src/company/widgets/company.card.dart';
export 'src/company/widgets/company.category.dropdown.dart';
export 'src/company/widgets/company.category.empty.dart';
export 'src/company/widgets/company.category.header.dart';
export 'src/company/widgets/company.category.tag.dart';
export 'src/company/widgets/company.contact.button.dart';
export 'src/company/widgets/company.image.placeholder.dart';
export 'src/company/widgets/company.list.grid.dart';
export 'src/company/widgets/company.select.location.dart';

// =============================================================================
// Config - 설정
// PhilGo 앱 설정 및 카테고리 정의
// =============================================================================
export 'src/philgo.category.dart';
export 'src/philgo.config.dart';

// =============================================================================
// Constants - 상수
// 앱 전역에서 사용되는 상수값 정의
// =============================================================================
export 'src/constants.dart';
export 'src/locations.dart';

// =============================================================================
// Functions - 유틸리티 함수
// 공통으로 사용되는 헬퍼 함수들
// =============================================================================
export 'src/functions/common.functions.dart';
export 'src/functions/file.functions.dart';
export 'src/functions/functions.dart';
export 'src/functions/url.functions.dart';
export 'src/philgo.functions.dart';

// =============================================================================
// L10n - 다국어 지원
// 필고 API 패키지 내 다국어 번역
// =============================================================================
export 'src/l10n/philgo_tr.dart';
export 'src/l10n/philgo_tr_helper.dart';

// =============================================================================
// Messaging - 푸시 알림
// Firebase Cloud Messaging 기반 푸시 알림 서비스
// =============================================================================
export 'src/messaging/messaging.defines.dart';
export 'src/messaging/messaging.functions.dart';
export 'src/messaging/messaging.service.dart';
export 'src/messaging/widget/push_notification_icon.dart';

// =============================================================================
// Models - 공통 모델
// 여러 모듈에서 공유하는 데이터 모델
// =============================================================================
export 'src/models/common.models.dart';

// =============================================================================
// PhilGo - PhilGo API
// PhilGo 서버와 통신하는 핵심 API 함수
// =============================================================================
export 'src/philgo/file_upload_response.model.dart';
export 'src/philgo/philgo.api.functions.dart';

// =============================================================================
// Post - 게시글/포럼
// 게시판 기능 (게시글 CRUD, 댓글, 카테고리)
// =============================================================================
// Post - Models (게시글 데이터 모델)
export 'src/post/models/comment.model.dart';
export 'src/post/models/post.list.model.dart';
export 'src/post/models/post.model.dart';
export 'src/post/post.functions.dart';
// Post - Widgets (게시글 UI 컴포넌트)
export 'src/post/widgets/category.list.dart';
export 'src/post/widgets/comment.detail.dart';
export 'src/post/widgets/comment.detail.list_view.dart';
export 'src/post/widgets/comment.list.view.dart';
export 'src/post/widgets/post.create.form.dart';
export 'src/post/widgets/post_list_tile/post_list_tile.dart';
export 'src/post/widgets/post_list_tile/post_list_tile.item.dart';
export 'src/post/widgets/post_list_tile/post_list_tile.meta.dart';
export 'src/post/widgets/post_list_tile/post_list_tile.upload_preview.dart';
export 'src/post/widgets/post.list.view.dart';
export 'src/post/widgets/post.masonry.view.dart';
export 'src/post/widgets/post.report.button.dart';
export 'src/post/widgets/post.subject.dart';
export 'src/post/widgets/post.update.form.dart';
export 'src/post/widgets/post.view.buttons.dart';
export 'src/post/widgets/post.view.content.dart';
export 'src/post/widgets/post.view.files.dart';
export 'src/post/widgets/post.view.header.dart';
export 'src/post/widgets/post.view.images.dart';

// =============================================================================
// Receive Share - 공유 받기
// 다른 앱에서 공유된 콘텐츠 수신 처리
// =============================================================================
export 'src/receive_share/receive.share.functions.dart';
export 'src/receive_share/receive.share.service.dart';
export 'src/receive_share/widgets/receive.share.dialog.dart';
export 'src/receive_share/widgets/share.where.button.dart';

// =============================================================================
// Storage - 저장소
// 로컬 저장소 및 Firebase Storage 관련 함수
// =============================================================================
export 'src/storage/storage.functions.dart';

// =============================================================================
// User - 사용자
// 사용자 인증, 프로필, 차단 기능
// =============================================================================
export 'src/user/models/user.dart';
export 'src/user/user.defines.dart';
export 'src/user/user.function.dart';
export 'src/user/user.service.dart';
// User - Widgets (사용자 관련 위젯)
export 'src/user/widgets/block.dart';
export 'src/user/widgets/block_user_dialog.dart';
export 'src/user/widgets/blocked.user_list.dart';
export 'src/user/widgets/login.dart';
export 'src/user/widgets/online.status.dart';
export 'src/user/widgets/user_avatar.dart';
export 'src/user/widgets/user_avatar_with_upload_icon.dart';

// =============================================================================
// Widgets - 공통 위젯
// 앱 전역에서 재사용 가능한 UI 컴포넌트
// =============================================================================
export 'src/widgets/avatar.dart';
export 'src/widgets/date_selector.dart';
export 'src/widgets/file_upload.dart';
export 'src/widgets/full_screen_image_viewer.dart';
export 'src/widgets/icon.container.dart';
export 'src/widgets/loading.box.dart';
export 'src/widgets/submit_button.dart';
export 'src/widgets/text_field_set.dart';
// Widgets - Upload (업로드 관련 위젯)
export 'src/widgets/upload/display.upload.dart';
export 'src/widgets/upload/upload.preview.dart';
export 'src/widgets/upload/uploaded.video_player.dart';
export 'src/widgets/upload/video.thumbnail.dart';
