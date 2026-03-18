import 'package:philgo/api/api.service.dart';

/// 북마크 모델
///
/// `bookmark.add`, `bookmark.listByGroup` API 응답을 나타낸다.
/// `listByGroup` 응답에는 entity_type에 따라 enrichment 필드가 추가된다.
class BookmarkModel {
  final int idx;
  final int idxMember;
  final int idxGroup;
  final String entityType;
  final int entityIdx;
  final String entityId;
  final String memo;
  final int createdAt;
  final String groupName;

  // enrichment fields (entity_type에 따라 선택적 포함)
  final String? subject; // post
  final String? postId; // post
  final int? parentIdx; // comment (idx_root)
  final String? contentPreview; // comment (80자)
  final String? nickname; // user
  final String? photoUrl; // user

  const BookmarkModel({
    required this.idx,
    required this.idxMember,
    required this.idxGroup,
    required this.entityType,
    required this.entityIdx,
    required this.entityId,
    required this.memo,
    required this.createdAt,
    required this.groupName,
    this.subject,
    this.postId,
    this.parentIdx,
    this.contentPreview,
    this.nickname,
    this.photoUrl,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      idx: ApiService.toInt(json['idx']),
      idxMember: ApiService.toInt(json['idx_member']),
      idxGroup: ApiService.toInt(json['idx_group']),
      entityType: json['entity_type']?.toString() ?? '',
      entityIdx: ApiService.toInt(json['entity_idx']),
      entityId: json['entity_id']?.toString() ?? '',
      memo: json['memo']?.toString() ?? '',
      createdAt: ApiService.toInt(json['created_at']),
      groupName: json['group_name']?.toString() ?? '',
      subject: json['subject']?.toString(),
      postId: json['post_id']?.toString(),
      parentIdx: json['parent_idx'] != null
          ? ApiService.toInt(json['parent_idx'])
          : null,
      contentPreview: json['content_preview']?.toString(),
      nickname: json['nickname']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}
