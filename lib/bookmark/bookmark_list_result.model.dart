import 'package:philgo/bookmark/bookmark.model.dart';

/// bookmark.listByGroup API 응답 모델
class BookmarkListResult {
  final List<BookmarkModel> bookmarks;

  const BookmarkListResult({required this.bookmarks});

  factory BookmarkListResult.fromJson(Map<String, dynamic> json) {
    final raw = json['bookmarks'] ?? [];
    final items = raw is List ? raw : [];
    return BookmarkListResult(
      bookmarks: items
          .whereType<Map<String, dynamic>>()
          .map(BookmarkModel.fromJson)
          .toList(),
    );
  }
}
