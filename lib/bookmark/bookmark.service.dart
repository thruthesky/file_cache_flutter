import 'package:philgo/api/api.service.dart';
import 'bookmark.model.dart';
import 'bookmark_group.model.dart';

/// v7 Bookmark API 서비스
///
/// 북마크 관련 모든 v7 API 호출을 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
class BookmarkService {
  BookmarkService._();

  /// 북마크 추가
  ///
  /// API: bookmark.add (인증 필수)
  ///
  /// [entityType] 대상 타입 ('post', 'comment', 'user', 'chat_room')
  /// [entityIdx] 대상 정수 idx (post, comment, user)
  /// [entityId] 대상 문자열 ID (chat_room)
  /// [groupName] 그룹명 (빈 문자열이면 'default' 그룹 자동 사용)
  /// [memo] 사용자 메모 (선택)
  static Future<BookmarkModel> add({
    required String entityType,
    int? entityIdx,
    String? entityId,
    String groupName = '',
    String? memo,
  }) async {
    final result = await ApiService.instance.v7api(
      'bookmark.add',
      data: {
        'entity_type': entityType,
        if (entityIdx != null) 'entity_idx': entityIdx,
        if (entityId != null) 'entity_id': entityId,
        'group_name': groupName,
        if (memo != null) 'memo': memo,
      },
    );
    return BookmarkModel.fromJson(result);
  }

  /// 북마크 제거
  ///
  /// API: bookmark.remove (인증 필수)
  ///
  /// [entityType] 대상 타입
  /// [entityIdx] 대상 정수 idx
  /// [entityId] 대상 문자열 ID
  static Future<bool> remove({
    required String entityType,
    int? entityIdx,
    String? entityId,
  }) async {
    final result = await ApiService.instance.v7api(
      'bookmark.remove',
      data: {
        'entity_type': entityType,
        if (entityIdx != null) 'entity_idx': entityIdx,
        if (entityId != null) 'entity_id': entityId,
      },
    );
    return result['removed'] == true;
  }

  /// 내 그룹 목록 조회
  ///
  /// API: bookmark.listGroups (인증 필수)
  ///
  /// [entityType] 타입 필터 (선택, 생략 시 전체 합산 count)
  static Future<List<BookmarkGroupModel>> listGroups({
    String? entityType,
  }) async {
    final result = await ApiService.instance.v7api(
      'bookmark.listGroups',
      data: {
        if (entityType != null) 'entity_type': entityType,
      },
    );
    final raw = result['groups'] ?? [];
    final items = raw is List ? raw : [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookmarkGroupModel.fromJson)
        .toList();
  }

  /// 그룹별 북마크 목록 조회
  ///
  /// API: bookmark.listByGroup (인증 필수)
  /// entity_type에 따라 enrichment 필드가 자동 포함된다.
  ///
  /// [idxGroup] 그룹 idx
  /// [entityType] 타입 필터 (선택)
  static Future<List<BookmarkModel>> listByGroup({
    required int idxGroup,
    String? entityType,
  }) async {
    final result = await ApiService.instance.v7api(
      'bookmark.listByGroup',
      data: {
        'idx_group': idxGroup,
        if (entityType != null) 'entity_type': entityType,
      },
    );
    final raw = result['bookmarks'] ?? [];
    final items = raw is List ? raw : [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(BookmarkModel.fromJson)
        .toList();
  }

  /// 그룹 생성
  ///
  /// API: bookmark.createGroup (인증 필수)
  ///
  /// [name] 그룹명
  static Future<BookmarkGroupModel> createGroup({
    required String name,
  }) async {
    final result = await ApiService.instance.v7api(
      'bookmark.createGroup',
      data: {'name': name},
    );
    return BookmarkGroupModel.fromJson(result);
  }

  /// 그룹 삭제 (하위 북마크 함께 삭제)
  ///
  /// API: bookmark.deleteGroup (인증 필수)
  ///
  /// [idxGroup] 그룹 idx
  static Future<bool> deleteGroup({required int idxGroup}) async {
    final result = await ApiService.instance.v7api(
      'bookmark.deleteGroup',
      data: {'idx_group': idxGroup},
    );
    return result['deleted'] == true;
  }

  /// 내 북마크 ID 목록 (entity_id 기반)
  ///
  /// API: bookmark.myBookmarkedIds (인증 필수)
  /// chat_room 타입에서만 유용 (entity_id가 roomId).
  /// post/comment/user 타입에서는 entity_id가 비어있어 사용 불가.
  ///
  /// [entityType] 대상 타입
  static Future<List<String>> myBookmarkedIds({
    required String entityType,
  }) async {
    final result = await ApiService.instance.v7api(
      'bookmark.myBookmarkedIds',
      data: {'entity_type': entityType},
    );
    final raw = result['ids'] ?? [];
    final items = raw is List ? raw : [];
    return items.map((e) => e.toString()).toList();
  }

  /// 북마크 토글 (추가/제거)
  ///
  /// [entityType] 대상 타입
  /// [entityIdx] 대상 정수 idx
  /// [isCurrentlyBookmarked] 현재 북마크 상태
  /// 반환: 토글 후 새로운 북마크 상태 (true = 북마크됨)
  static Future<bool> toggle({
    required String entityType,
    required int entityIdx,
    required bool isCurrentlyBookmarked,
  }) async {
    if (isCurrentlyBookmarked) {
      await remove(entityType: entityType, entityIdx: entityIdx);
      return false;
    } else {
      await add(entityType: entityType, entityIdx: entityIdx);
      return true;
    }
  }
}
