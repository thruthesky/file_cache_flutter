import 'package:philgo/api/api.service.dart';

/// 북마크 그룹 모델
///
/// `bookmark.listGroups`, `bookmark.createGroup` API 응답을 나타낸다.
class BookmarkGroupModel {
  final int idx;
  final int idxMember;
  final String name;
  final int sortOrder;
  final int createdAt;
  final int count;

  const BookmarkGroupModel({
    required this.idx,
    required this.idxMember,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    required this.count,
  });

  factory BookmarkGroupModel.fromJson(Map<String, dynamic> json) {
    return BookmarkGroupModel(
      idx: ApiService.toInt(json['idx']),
      idxMember: ApiService.toInt(json['idx_member']),
      name: json['name']?.toString() ?? '',
      sortOrder: ApiService.toInt(json['sort_order']),
      createdAt: ApiService.toInt(json['created_at']),
      count: ApiService.toInt(json['count']),
    );
  }
}
