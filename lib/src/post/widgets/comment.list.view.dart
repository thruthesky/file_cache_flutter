import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 댓글 목록 뷰
/// 게시글의 댓글 입력란, 댓글 헤더, 댓글 목록을 표시하는 위젯
class CommentListView extends StatefulWidget {
  final Post post;

  const CommentListView({super.key, required this.post});

  @override
  State<StatefulWidget> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  @override
  Widget build(BuildContext context) {
    final hasComments = widget.post.comments.isNotEmpty;

    /// 댓글 영역 전체 컨테이너
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          /// 댓글 입력란
          /// 사용자가 댓글을 작성할 수 있는 텍스트 필드
          TextField(
            minLines: 1,
            maxLines: 2,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: PhilgoTr.of(context)!.enter_your_comment,
              /// 전송 버튼 아이콘
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const FaIcon(FontAwesomeIcons.paperPlaneTop),
              ),
            ),
          ),
          SizedBox(height: 24),

          /// 댓글 헤더
          /// 댓글 아이콘, "Comments" 텍스트, 댓글 개수 배지를 포함
          Row(
            children: [
              /// 댓글 아이콘
              FaIcon(
                FontAwesomeIcons.solidMessageDots,
                size: 18,
                color: Colors.black,
              ),
              SizedBox(width: 12),

              /// "Comments" 텍스트
              Text(
                PhilgoTr.of(context)!.comments,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 12),

              /// 댓글 개수 배지
              /// 전체 댓글 개수를 둥근 배지 형태로 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.post.no_of_comment.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          /// 댓글 표시 영역
          /// 댓글이 있으면 댓글 목록 표시, 없으면 안내 메시지 표시
          if (hasComments)
            Text(PhilgoTr.of(context)!.this_post_has_comments)
          else
            Text(PhilgoTr.of(context)!.be_the_first_to_comment),
        ],
      ),
    );
  }
}
