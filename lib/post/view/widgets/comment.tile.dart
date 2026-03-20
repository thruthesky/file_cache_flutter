import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/user/other_user/other_user.screen.dart';
import 'package:philgo/user/widgets/user_avatar.dart';
import 'package:philgo/point/widgets/earned_point_badge.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/widgets/post.action.button.dart';
import 'package:philgo/post/view/widgets/post.view.content.dart';
import 'package:philgo/post/view/widgets/post.view.files.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.state.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:provider/provider.dart';

/// 세로선 색상 (Reddit 스타일)
const kThreadLineColor = Color(0xFF94A3B8);

/// 댓글 단일 타일
///
/// 댓글 표시, 좋아요, 대댓글, 수정, 삭제 기능을 제공한다.
/// [showThreadLine]이 true이면 아바타 아래에서 세로선이 시작되어
/// 코멘트 하단까지 연결된다. (자식 코멘트가 있는 경우)
class CommentTile extends StatefulWidget {
  final Post comment;
  final List<Post> allComments;
  final VoidCallback onReply;

  /// 답글 탭 콜백 — 하단 고정 바에 답글 대상을 설정한다.
  final void Function(Post comment)? onReplyTap;
  final Future<void> Function(Post comment, String content) onEdit;
  final Future<void> Function(Post comment) onDelete;

  /// 자식 존재 여부 (외부에서 트리 구조 기반으로 전달)
  final bool hasChildren;

  /// 아바타 아래 세로선 표시 여부 (자식이 있는 노드에서 true)
  final bool showThreadLine;

  /// 북마크 상태
  final bool bookmarked;

  /// 북마크 토글 콜백
  final VoidCallback? onBookmark;

  const CommentTile({
    super.key,
    required this.comment,
    required this.allComments,
    required this.onReply,
    this.onReplyTap,
    required this.onEdit,
    required this.onDelete,
    this.hasChildren = false,
    this.showThreadLine = false,
    this.bookmarked = false,
    this.onBookmark,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _liked = false;
  late int _goodCount;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _liked = widget.comment.liked;
    _goodCount = widget.comment.good;
    _reported = widget.comment.reported;
  }

  void _openUserProfile(BuildContext context, int idxMember) {
    if (idxMember == 0) return;
    OtherUserScreen.pushByIdx(context, idxMember);
  }

  Future<void> _toggleLike() async {
    try {
      final result = await PostService.like(widget.comment.idx);
      if (!mounted) return;
      setState(() {
        _liked = result.liked;
        _goodCount = result.good;
      });
    } catch (_) {}
  }

  Future<void> _reportComment() async {
    if (_reported) {
      showErrorSnackBar(context, '이미 신고한 댓글입니다'.tr());
      return;
    }
    try {
      await PostService.report(idx: widget.comment.idx, type: 'comment');
      if (!mounted) return;
      setState(() => _reported = true);
      showSuccessSnackBar(context, '신고가 접수되었습니다'.tr());
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('already-reported')) {
        setState(() => _reported = true);
        showErrorSnackBar(context, '이미 신고한 댓글입니다'.tr());
      } else {
        showErrorSnackBar(context, msg);
      }
    }
  }

  Future<void> _blockCommentAuthor() async {
    final name = widget.comment.userName.isNotEmpty
        ? widget.comment.userName
        : '이름없음'.tr();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('차단'.tr()),
        content: Text(
          '${'{name}님을 차단하시겠습니까?'.tr(namedArgs: {'name': name})}\n${'차단하면 이 사용자의 글이 목록에서 숨겨집니다'.tr()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('취소'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('차단'.tr()),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final blocked = await toggleBlockUserByIdx(widget.comment.idxMember);
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        blocked ? '사용자를 차단했습니다'.tr() : '차단이 해제되었습니다'.tr(),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final userState = Provider.of<UserState>(context, listen: false);
    final isMine = userState.isLoggedIn && userState.idx == comment.idxMember;
    final hasChildren = widget.hasChildren;

    // 세로선 표시 여부에 따라 레이아웃 분기
    if (widget.showThreadLine) {
      return _buildWithThreadLine(
        context,
        comment: comment,
        theme: theme,
        scheme: scheme,
        isMine: isMine,
        hasChildren: hasChildren,
      );
    }

    return _buildNormal(
      context,
      comment: comment,
      theme: theme,
      scheme: scheme,
      isMine: isMine,
      hasChildren: hasChildren,
    );
  }

  /// 세로선 포함 레이아웃 (자식 있는 노드)
  ///
  /// IntrinsicHeight > Row 구조로 아바타 아래에서 코멘트 하단까지
  /// 세로선이 연결된다.
  Widget _buildWithThreadLine(
    BuildContext context, {
    required Post comment,
    required ThemeData theme,
    required ColorScheme scheme,
    required bool isMine,
    required bool hasChildren,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아바타 + 세로선 컬럼
          SizedBox(
            width: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openUserProfile(context, comment.idxMember),
                  child: UserAvatar(photoUrl: comment.userPhotoUrl),
                ),
                // 세로선: 아바타 하단에서 코멘트 하단까지 (중앙 정렬, 아바타와 붙어있음)
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(width: 1.5, color: kThreadLineColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 내용 컬럼
          Expanded(
            child: _buildContentColumn(
              comment: comment,
              theme: theme,
              scheme: scheme,
              isMine: isMine,
              hasChildren: hasChildren,
            ),
          ),
        ],
      ),
    );
  }

  /// 기본 레이아웃 (자식 없는 노드)
  Widget _buildNormal(
    BuildContext context, {
    required Post comment,
    required ThemeData theme,
    required ColorScheme scheme,
    required bool isMine,
    required bool hasChildren,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openUserProfile(context, comment.idxMember),
            child: UserAvatar(photoUrl: comment.userPhotoUrl),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildContentColumn(
              comment: comment,
              theme: theme,
              scheme: scheme,
              isMine: isMine,
              hasChildren: hasChildren,
            ),
          ),
        ],
      ),
    );
  }

  /// 내용 컬럼 (작성자, 날짜, 내용, 첨부파일, 액션바)
  ///
  /// primaryContainer 배경 + 둥근 모서리 8px 카드 스타일 적용
  Widget _buildContentColumn({
    required Post comment,
    required ThemeData theme,
    required ColorScheme scheme,
    required bool isMine,
    required bool hasChildren,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showThreadLine) const SizedBox(height: 2),

          // 작성자 + 날짜
          Row(
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => _openUserProfile(context, comment.idxMember),
                  child: Text(
                    comment.userName.isNotEmpty
                        ? comment.userName
                        : '이름없음'.tr(),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(comment.stamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.tertiary,
                ),
              ),
              if (comment.earnedPoint > 0) ...[
                const SizedBox(width: 8),
                EarnedPointBadge(point: comment.earnedPoint),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // 내용
          PostViewContent(post: comment, padding: EdgeInsets.zero),

          // 첨부 파일
          if (comment.imageUrl != null || comment.videoUrl != null)
            PostViewFiles(post: comment),

          // 액션 바
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 좋아요
                PostActionButton(
                  icon: _liked
                      ? FontAwesomeIcons.solidThumbsUp
                      : FontAwesomeIcons.lightThumbsUp,
                  label: '${_goodCount > 0 ? _goodCount : ''}',
                  color: _liked ? scheme.primary : scheme.tertiary,
                  onTap: _toggleLike,
                ),
                const SizedBox(width: 8),
                // 답글 (아이콘만 표시)
                PostActionButton(
                  icon: FontAwesomeIcons.lightReply,
                  label: '',
                  color: scheme.tertiary,
                  onTap: () {
                    widget.onReplyTap?.call(widget.comment);
                    widget.onReply();
                  },
                ),

                // 북마크
                if (widget.onBookmark != null) ...[
                  const SizedBox(width: 8),
                  PostActionButton(
                    icon: widget.bookmarked
                        ? FontAwesomeIcons.solidBookmark
                        : FontAwesomeIcons.lightBookmark,
                    label: '',
                    color: widget.bookmarked ? scheme.primary : scheme.tertiary,
                    onTap: widget.onBookmark!,
                  ),
                ],

                const SizedBox(width: 12),

                if (isMine) ...[
                  if (!hasChildren)
                    PostActionButton(
                      icon: FontAwesomeIcons.lightPenToSquare,
                      label: '',
                      color: scheme.tertiary,
                      onTap: () => _showEditDialog(context),
                    ),
                  if (!hasChildren) const SizedBox(width: 8),
                  if (!hasChildren)
                    PostActionButton(
                      icon: FontAwesomeIcons.lightTrashCan,
                      label: '',
                      color: scheme.error,
                      onTap: () => _confirmDelete(context),
                    ),
                ],

                // 신고/차단 (타인의 댓글에만 표시)
                if (!isMine) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 14,
                    icon: FaIcon(
                      FontAwesomeIcons.lightEllipsis,
                      size: 14,
                      color: scheme.tertiary,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'report':
                          _reportComment();
                        case 'block':
                          _blockCommentAuthor();
                      }
                    },
                    itemBuilder: (ctx) {
                      final popScheme = Theme.of(ctx).colorScheme;
                      return [
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                _reported
                                    ? FontAwesomeIcons.solidFlag
                                    : FontAwesomeIcons.lightFlag,
                                size: 14,
                                color: popScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _reported ? '신고됨'.tr() : '신고'.tr(),
                                style: TextStyle(color: popScheme.error),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'block',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.lightBan,
                                size: 14,
                                color: popScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text('차단'.tr()),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 수정 다이얼로그
  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: widget.comment.content);
    final content = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('댓글 수정'.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '댓글 내용을 입력하세요'.tr(),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('취소'.tr()),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx, text);
            },
            child: Text('수정'.tr()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (content != null) {
      await widget.onEdit(widget.comment, content);
    }
  }

  /// 삭제 확인 다이얼로그
  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('댓글 삭제'.tr()),
        content: Text('정말 이 댓글을 삭제하시겠습니까?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('취소'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('삭제'.tr()),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.onDelete(widget.comment);
    }
  }

  String _formatDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
