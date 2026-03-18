import 'package:flutter/foundation.dart';
import 'package:philgo/api/api.service.dart';
import 'bookmark.model.dart';
import 'bookmark_group.model.dart';
import 'bookmark_group_list_result.model.dart';
import 'bookmark_list_result.model.dart';

/// v7 Bookmark API 서비스 (싱글톤)
///
/// 앱 초기화 시 [loadMyFolderBookmarks]를 호출하여 그룹 목록과
/// 전체 북마크 entity_idx 캐시를 로드한다.
/// 이후 [isBookmarked]로 즉시 북마크 여부를 판별할 수 있다.
class BookmarkService {
  static final BookmarkService instance = BookmarkService._();
  BookmarkService._();

  /// 북마크 그룹 목록 (ValueNotifier)
  final ValueNotifier<List<BookmarkGroupModel>> _groupsNotifier =
      ValueNotifier([]);

  /// 북마크 그룹 목록 getter
  ValueNotifier<List<BookmarkGroupModel>> get bookmarkGroups => _groupsNotifier;

  /// entity_type별 북마크된 entity_idx 캐시
  final Set<int> _bookmarkedPostIdxs = {};
  final Set<int> _bookmarkedCommentIdxs = {};
  final Set<int> _bookmarkedUserIdxs = {};

  // ── 초기화 / 캐시 ──────────────────────────────────────

  /// 내 그룹 목록 로드 + 전체 북마크 캐시 구축
  ///
  /// 앱 초기화 시 UserService.initialize()에서 호출된다.
  /// 그룹 목록을 가져온 뒤, 각 그룹의 북마크를 로드하여 캐시를 구축한다.
  Future<void> loadMyFolderBookmarks() async {
    final result = await ApiService.instance.v7api('bookmark.listGroups');
    final groupListResult = BookmarkGroupListResult.fromJson(result);
    _groupsNotifier.value = groupListResult.groups;

    // 캐시 리빌드: 모든 그룹의 북마크를 로드하여 entity_idx 캐시에 추가
    _bookmarkedPostIdxs.clear();
    _bookmarkedCommentIdxs.clear();
    _bookmarkedUserIdxs.clear();

    await Future.wait(
      groupListResult.groups.map((group) async {
        final res = await ApiService.instance.v7api(
          'bookmark.listByGroup',
          data: {'idx_group': group.idx},
        );
        final listResult = BookmarkListResult.fromJson(res);
        for (final bm in listResult.bookmarks) {
          _addToCache(bm.entityType, bm.entityIdx);
        }
      }),
    );
  }

  /// 상태 초기화 (로그아웃 시)
  void clear() {
    _groupsNotifier.value = [];
    _bookmarkedPostIdxs.clear();
    _bookmarkedCommentIdxs.clear();
    _bookmarkedUserIdxs.clear();
  }

  /// 엔티티가 북마크되어 있는지 캐시에서 확인
  bool isBookmarked(String entityType, int entityIdx) {
    return _cacheFor(entityType).contains(entityIdx);
  }

  Set<int> _cacheFor(String entityType) {
    switch (entityType) {
      case 'post':
        return _bookmarkedPostIdxs;
      case 'comment':
        return _bookmarkedCommentIdxs;
      case 'user':
        return _bookmarkedUserIdxs;
      default:
        return {};
    }
  }

  void _addToCache(String entityType, int entityIdx) {
    switch (entityType) {
      case 'post':
        _bookmarkedPostIdxs.add(entityIdx);
      case 'comment':
        _bookmarkedCommentIdxs.add(entityIdx);
      case 'user':
        _bookmarkedUserIdxs.add(entityIdx);
    }
  }

  void _removeFromCache(String entityType, int entityIdx) {
    switch (entityType) {
      case 'post':
        _bookmarkedPostIdxs.remove(entityIdx);
      case 'comment':
        _bookmarkedCommentIdxs.remove(entityIdx);
      case 'user':
        _bookmarkedUserIdxs.remove(entityIdx);
    }
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
    if (entityIdx != null) _addToCache(entityType, entityIdx);
    // 그룹 목록 리프레시
    loadMyFolderBookmarks();
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
    final removed = result['removed'] == true;
    if (removed && entityIdx != null) {
      _removeFromCache(entityType, entityIdx);
    }
    // 그룹 목록 리프레시
    loadMyFolderBookmarks();
    return removed;
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
    // 그룹 목록 리프레시
    loadMyFolderBookmarks();
    return group;
  }

  /// 그룹 삭제 (하위 북마크 함께 삭제)
  Future<bool> deleteGroup({required int idxGroup}) async {
    final result = await ApiService.instance.v7api(
      'bookmark.deleteGroup',
      data: {'idx_group': idxGroup},
    );
    final deleted = result['deleted'] == true;
    if (deleted) {
      // 캐시 리빌드 (삭제된 그룹의 북마크가 캐시에서 제거되어야 함)
      loadMyFolderBookmarks();
    }
    return deleted;
  }
}
