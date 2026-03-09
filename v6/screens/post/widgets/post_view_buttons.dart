import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/post/widgets/post_view_option_menu.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:share_plus/share_plus.dart';

/// 게시글 보기 화면의 버튼 모음 위젯
/// Post view screen buttons widget
///
/// 좋아요, 답글, 수정, 삭제, 차단, 신고 등의 액션 버튼을 제공합니다.
class PostViewButtons extends StatefulWidget {
  /// 게시글 객체 (필수)
  final Post post;

  /// 좋아요 여부 (필수)
  final bool isLiked;

  /// 좋아요 토글 시 호출되는 콜백
  final void Function(bool liked)? onLikeToggled;

  /// 답글 버튼 탭 시 호출되는 콜백
  final VoidCallback onTapReply;

  /// 수정 완료 시 호출되는 콜백
  final void Function(Post updatedPost)? onEditCompleted;

  /// 삭제 완료 시 호출되는 콜백
  final void Function(BuildContext context)? onDeleteCompleted;

  final void Function(Post updated) onUpdated;

  const PostViewButtons({
    super.key,
    required this.post,
    required this.isLiked,
    this.onLikeToggled,
    required this.onTapReply,
    this.onEditCompleted,
    this.onDeleteCompleted,
    required this.onUpdated,
  });

  @override
  State<PostViewButtons> createState() => _PostViewButtonsState();
}

class _PostViewButtonsState extends State<PostViewButtons> {
  Post get post => widget.post;
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
  }

  /// Share the post URL via OS native share sheet
  /// 게시글의 필고 URL을 OS 네이티브 공유 시트로 공유합니다.
  ///
  /// URL format: https://philgo.com/post/view.php?idx={idx}&post_id={post_id}
  /// iPad에서는 sharePositionOrigin을 설정하여 팝오버 위치를 지정합니다.
  Future<void> _sharePost(BuildContext context) async {
    try {
      // Build the PhilGo post URL with idx and post_id
      final postUrl =
          'https://philgo.com/post/view.php?idx=${post.idx}&post_id=${post.post_id}';

      // Calculate share position origin for iPad popover support
      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await SharePlus.instance.share(
        ShareParams(
          text: '${post.subject}\n$postUrl',
          subject: post.subject,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      d('Error sharing post: $e');
      if (context.mounted) {
        showErrorSnackBar(context, Lo.of(context)!.share);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// 좋아요 버튼
        ComicActionButton(
          icon: widget.isLiked
              ? FontAwesomeIcons.solidThumbsUp
              : FontAwesomeIcons.thumbsUp,
          label: post.good > 0 ? '${post.good}' : null,
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            try {
              final updatedGood = await likePost(widget.post.idx);
              (widget.post).good = updatedGood;
              if (mounted) {
                setState(() {
                  isLiked = true;
                });
              }
              if (context.mounted) {
                showSuccessSnackBar(context, Lo.of(context)!.postLiked);
              }
            } catch (e) {
              d('Error liking post: $e');
              if (e.toString().contains('already-liked')) {
                if (context.mounted) {
                  showErrorSnackBar(context, Lo.of(context)!.alreadyLikedPost);
                }
              }
            }
          },
        ),

        const SizedBox(width: 8),

        /// 답글 버튼
        ComicActionButton(
          icon: FontAwesomeIcons.reply,
          onPressed: widget.onTapReply,
        ),

        const SizedBox(width: 8),

        /// Share button - share the post URL via OS native share sheet
        /// 공유 버튼 - OS 네이티브 공유 시트를 통해 게시글 URL 공유
        ComicActionButton(
          icon: FontAwesomeIcons.shareNodes,
          onPressed: () => _sharePost(context),
        ),

        const SizedBox(width: 8),

        /// 1:1 채팅 버튼 - 타인 게시글인 경우에만 표시
        UserReady(
          login: (context, user) {
            if (!post.isMine(context)) {
              return ComicActionButton(
                icon: FontAwesomeIcons.comment,
                onPressed: () {
                  // 게시글 작성자와 1:1 채팅방 열기
                  ChatRoomScreen.push(context, post.firebase_uid);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const Spacer(),

        /// 본인/타인 게시글에 따라 다른 버튼 표시
        UserReady(
          login: (context, user) {
            /// 타인 게시글인 경우: 차단, 신고 버튼
            if (!post.isMine(context)) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ComicActionButton(
                    icon: FontAwesomeIcons.userSlash,
                    onPressed: () {
                      showBlockDialog(
                        context: context,
                        otherUserUid: post.firebase_uid,
                        displayName: post.nickname,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  PostReportButton(
                    type: 'post',
                    idx: widget.post.idx,
                    post: widget.post,
                  ),
                ],
              );
            }

            /// 본인 게시글인 경우: 수정, 삭제 버튼
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ComicActionButton(
                  icon: FontAwesomeIcons.penToSquare,
                  onPressed: () async {
                    if (post.no_of_comment >= 1) {
                      showInfoDialog(
                        context,
                        Lo.of(context)!.alert,
                        Lo.of(context)!.postWithCommentsCannotBeEdited,
                      );
                      return;
                    }

                    await showPostUpdateScreen(
                      context,
                      post: post,
                      onUpdated: (updated) {
                        widget.post.subject = updated.subject;
                        widget.post.content = updated.content;

                        if (mounted) {
                          setState(() {
                            widget.onUpdated(updated);
                          });
                        }
                      },
                    );
                    if (context.mounted) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
                const SizedBox(width: 8),
                ComicActionButton(
                  icon: FontAwesomeIcons.trash,
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () async {
                    if (post.no_of_comment >= 1) {
                      showInfoDialog(
                        context,
                        Lo.of(context)!.alert,
                        Lo.of(context)!.postWithCommentsCannotBeDeleted,
                      );
                      return;
                    }

                    final confirm = await showConfirmDialog(
                      message: Lo.of(context)!.confirmDeletePost,
                    );

                    if (confirm) {
                      await deletePost(widget.post.idx);
                      if (context.mounted) {
                        /// onDeleteCompleted 콜백을 통해 삭제 결과 전달
                        /// context.pop() 직접 호출 대신 콜백 위임하여
                        /// 목록 화면에서 캐시 제거 처리 가능하도록 함
                        widget.onDeleteCompleted?.call(context);
                      }
                    }
                  },
                ),
              ],
            );
          },
        ),

        const SizedBox(width: 8),

        /// 옵션 메뉴 (수정/삭제/차단/신고) - Comic 스타일
        PostViewOptionMenu(
          post: post,
          firebaseUid: post.firebase_uid,
          onTapReply: widget.onTapReply,
          onEditCompleted: (updated) {
            widget.post.subject = updated.subject;
            widget.post.content = updated.content;
            if (mounted) {
              widget.onUpdated(updated);
            }
          },
          onDeleteCompleted: (context) {
            /// onDeleteCompleted 콜백을 통해 삭제 결과 전달
            /// context.pop() 직접 호출 대신 콜백 위임하여
            /// 목록 화면에서 캐시 제거 처리 가능하도록 함
            widget.onDeleteCompleted?.call(context);
          },
        ),
      ],
    );
  }
}
