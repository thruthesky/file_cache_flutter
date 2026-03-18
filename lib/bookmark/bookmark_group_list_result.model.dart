import 'package:philgo/bookmark/bookmark_group.model.dart';

/// bookmark.listGroups API 응답 모델
class BookmarkGroupListResult {
  final List<BookmarkGroupModel> groups;

  const BookmarkGroupListResult({required this.groups});

  factory BookmarkGroupListResult.fromJson(Map<String, dynamic> json) {
    final raw = json['groups'] ?? [];
    final items = raw is List ? raw : [];
    return BookmarkGroupListResult(
      groups: items
          .whereType<Map<String, dynamic>>()
          .map(BookmarkGroupModel.fromJson)
          .toList(),
    );
  }
}
