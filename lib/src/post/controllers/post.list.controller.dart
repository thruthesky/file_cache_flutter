import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo_api/philgo_api.dart';

/// Controller for PostSimpleListView
/// PostSimpleListView용 컨트롤러
///
/// Provides access to the PagingController to allow external widgets
/// to trigger refresh and other operations without using GlobalKey
/// 외부 위젯에서 GlobalKey 없이도 새로고침 등의 작업을 수행할 수 있도록
/// PagingController에 대한 접근을 제공합니다
class PostListController {
  /// PagingController for managing pagination state
  /// 페이지네이션 상태를 관리하는 PagingController
  PagingController<int, Post>? _pagingController;

  /// Register the PagingController
  /// PagingController 등록
  void attach(PagingController<int, Post> controller) {
    _pagingController = controller;
  }

  /// Unregister the PagingController
  /// PagingController 등록 해제
  void detach() {
    _pagingController = null;
  }

  /// Refresh the list
  /// 목록 새로고침
  void refresh() {
    _pagingController?.refresh();
  }

  /// Get the current PagingController
  /// 현재 PagingController 가져오기
  PagingController<int, Post>? get pagingController => _pagingController;

  /// Check if controller is attached
  /// 컨트롤러가 연결되어 있는지 확인
  bool get isAttached => _pagingController != null;
}
