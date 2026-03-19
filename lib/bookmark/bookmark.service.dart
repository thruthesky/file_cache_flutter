import 'package:flutter/foundation.dart';
import 'package:philgo/api/api.service.dart';
import 'bookmark.model.dart';
import 'bookmark_group.model.dart';
import 'bookmark_group_list_result.model.dart';
import 'bookmark_list_result.model.dart';

/// v7 Bookmark API 서비스 (싱글톤)
///
/// 앱 초기화 시 [loadMyFolderBookmarks]를 호출하여 그룹 목록을 로드한다.
/// 그룹 목록은 [bookmarkGroups] ValueNotifier를 통해 접근 가능.
class BookmarkService {
  static final BookmarkService instance = BookmarkService._();
  BookmarkService._();

  /// 북마크 그룹 목록 (ValueNotifier)
  final ValueNotifier<List<BookmarkGroupModel>> _bookmarkNotifier =
      ValueNotifier([]);

  /// 북마크 그룹 목록 getter
  ValueNotifier<List<BookmarkGroupModel>> get bookmarkGroups =>
      _bookmarkNotifier;

  // ── 초기화 ──────────────────────────────────────

  /// 내 그룹 목록 로드
  ///
  /// 앱 초기화 시 UserService.initialize()에서 호출된다.
  Future<void> loadMyFolderBookmarks() async {
    final result = await ApiService.instance.v7api(
      'bookmark.listGroups',
      debug: true,
    );
    final groupListResult = BookmarkGroupListResult.fromJson(result);
    _bookmarkNotifier.value = groupListResult.groups;
  }

  /// 상태 초기화 (로그아웃 시)
  void clear() {
    _bookmarkNotifier.value = [];
  }

  /// 그룹 count를 delta만큼 조정
  void _updateGroupCount(int idxGroup, int delta) {
    _bookmarkNotifier.value = _bookmarkNotifier.value.map((g) {
      if (g.idx == idxGroup) return g.copyWith(count: g.count + delta);
      return g;
    }).toList();
  }

  // ── API 호출 ──────────────────────────────────────

  /// 북마크 추가
  Future<BookmarkModel> add({
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
    final bm = BookmarkModel.fromJson(result);
    _updateGroupCount(bm.idxGroup, 1);
    return bm;
  }

  /// 북마크 제거
  Future<bool> remove({
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

  /// 그룹별 북마크 목록 조회
  Future<BookmarkListResult> listByGroup({
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
    return BookmarkListResult.fromJson(result);
  }

  /// 그룹 생성
  Future<BookmarkGroupModel> createGroup({required String name}) async {
    final result = await ApiService.instance.v7api(
      'bookmark.createGroup',
      data: {'name': name},
    );
    final group = BookmarkGroupModel.fromJson(result);
    _bookmarkNotifier.value = [..._bookmarkNotifier.value, group];
    return group;
  }

  /// 내 특정 타입의 모든 즐겨찾기 ID 목록
  ///
  /// 서버의 `bookmark.myBookmarkedIds` API를 호출하여,
  /// 해당 entity_type에 대해 즐겨찾기된 entity_id 문자열 목록을 반환한다.
  ///
  /// 참고: 현재 백엔드는 `entity_id`(문자열)만 반환하므로,
  /// `chat_room` 타입에만 정상 동작한다.
  /// `user`/`post`/`comment`는 `entity_idx`(정수)를 사용하므로 빈 문자열이 반환된다.
  Future<List<String>> myBookmarkedIds({
    required String entityType,
  }) async {
    final result = await ApiService.instance.v7api(
      'bookmark.myBookmarkedIds',
      data: {'entity_type': entityType},
    );
    final List<dynamic> ids = result['ids'] ?? [];
    return ids.map((e) => e.toString()).toList();
  }

  /// 그룹 삭제 (하위 북마크 함께 삭제)
  Future<bool> deleteGroup({required int idxGroup}) async {
    final result = await ApiService.instance.v7api(
      'bookmark.deleteGroup',
      data: {'idx_group': idxGroup},
    );
    final deleted = result['deleted'] == true;
    if (deleted) {
      _bookmarkNotifier.value = _bookmarkNotifier.value
          .where((g) => g.idx != idxGroup)
          .toList();
    }
    return deleted;
  }
}
