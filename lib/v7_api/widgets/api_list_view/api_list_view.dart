import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// v7 API 무한 스크롤 리스트 뷰
///
/// [infinite_scroll_pagination] 패키지를 encapsulation하여
/// 재사용 가능한 페이지네이션 리스트 위젯을 제공한다.
///
/// 사용 예시:
/// ```dart
/// ApiListView<Map<String, dynamic>>(
///   fetchPage: (page) async {
///     final result = await PointLogApi.history(page: page, limit: 20);
///     return (result['items'] as List).cast<Map<String, dynamic>>();
///   },
///   itemBuilder: (context, item, index) => ListTile(title: Text(item['name'])),
/// )
/// ```
class ApiListView<T> extends StatefulWidget {
  /// 페이지 번호(1부터 시작)를 받아 해당 페이지의 아이템 리스트를 반환하는 콜백
  final Future<List<T>> Function(int page) fetchPage;

  /// 각 아이템을 위젯으로 빌드하는 콜백
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 아이템 사이 구분자 위젯 빌더 (null이면 구분자 없음)
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// 아이템이 없을 때 표시할 위젯 빌더
  final WidgetBuilder? noItemsBuilder;

  /// 첫 페이지 에러 시 표시할 위젯 빌더
  final Widget Function(BuildContext context, String error, VoidCallback retry)?
      errorBuilder;

  /// 첫 페이지 로딩 인디케이터 빌더
  final WidgetBuilder? firstPageProgressBuilder;

  /// 다음 페이지 로딩 인디케이터 빌더
  final WidgetBuilder? newPageProgressBuilder;

  /// 리스트 패딩
  final EdgeInsetsGeometry? padding;

  const ApiListView({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    this.separatorBuilder,
    this.noItemsBuilder,
    this.errorBuilder,
    this.firstPageProgressBuilder,
    this.newPageProgressBuilder,
    this.padding,
  });

  @override
  State<ApiListView<T>> createState() => ApiListViewState<T>();
}

class ApiListViewState<T> extends State<ApiListView<T>> {
  late final pagingController = PagingController<int, T>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => widget.fetchPage(pageKey),
  );

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  /// 외부에서 리스트 새로고침
  void refresh() => pagingController.refresh();

  @override
  Widget build(BuildContext context) {
    return PagingListener<int, T>(
      controller: pagingController,
      builder: (context, state, fetchNextPage) {
        final delegate = _buildDelegate(state);
        if (widget.separatorBuilder != null) {
          return PagedListView.separated(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: widget.padding,
            separatorBuilder: widget.separatorBuilder!,
            builderDelegate: delegate,
          );
        }
        return PagedListView<int, T>(
          state: state,
          fetchNextPage: fetchNextPage,
          padding: widget.padding,
          builderDelegate: delegate,
        );
      },
    );
  }

  PagedChildBuilderDelegate<T> _buildDelegate(PagingState<int, T> state) {
    return PagedChildBuilderDelegate<T>(
      itemBuilder: widget.itemBuilder,
      noItemsFoundIndicatorBuilder: widget.noItemsBuilder,
      firstPageErrorIndicatorBuilder: widget.errorBuilder != null
          ? (context) => widget.errorBuilder!(
                context,
                state.error?.toString() ?? '',
                () => pagingController.refresh(),
              )
          : null,
      firstPageProgressIndicatorBuilder: widget.firstPageProgressBuilder ??
          (context) => const Center(child: CircularProgressIndicator()),
      newPageProgressIndicatorBuilder: widget.newPageProgressBuilder ??
          (context) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
    );
  }
}
