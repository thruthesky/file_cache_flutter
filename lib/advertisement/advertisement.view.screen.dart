import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/advertisement/widgets/advertisement_contact_list.dart';
import 'package:philgo/common_widgets/youtube_player_list.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/widgets/post.view.content.dart';
import 'package:philgo/post/view/widgets/post.view.files.dart';
import 'package:philgo/globals.dart';

/// 광고 상세 화면
///
/// idx에 해당하는 광고 글을 post.get API로 가져와서
/// 제목, 내용, 첨부 이미지, 연락처 카드를 표시한다.
///
/// ```dart
/// AdvertisementViewScreen.push(context, idx: 12345);
/// ```
class AdvertisementViewScreen extends StatefulWidget {
  static const String routeName = '/advertisement-view';

  static Future<void> push(BuildContext ctx, {required int idx}) =>
      ctx.push(routeName, extra: idx);

  final int idx;

  const AdvertisementViewScreen({super.key, required this.idx});

  @override
  State<AdvertisementViewScreen> createState() =>
      _AdvertisementViewScreenState();
}

class _AdvertisementViewScreenState extends State<AdvertisementViewScreen> {
  late Future<Post> _postFuture;

  @override
  void initState() {
    super.initState();
    _postFuture = PostService.get(widget.idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 120,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.chevronLeft,
                    color: color.onSurface, size: 18),
                const SizedBox(width: 4),
                Text(
                  '돌아가기'.tr(),
                  style: text.bodyMedium?.copyWith(color: color.onSurface),
                ),
              ],
            ),
          ),
        ),
        title: const SizedBox.shrink(),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.surfaceDim,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(FontAwesomeIcons.xmark,
                      color: color.scrim, size: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Post>(
        future: _postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.lightCircleExclamation,
                      size: 48, color: color.error),
                  const SizedBox(height: 16),
                  Text('글을 불러올 수 없습니다'.tr(), style: text.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: text.bodySmall
                        ?.copyWith(color: color.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _postFuture = PostService.get(widget.idx);
                      });
                    },
                    child: Text('다시 시도'.tr()),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text('글이 존재하지 않습니다'.tr(), style: text.bodyLarge),
            );
          }

          final post = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첨부 파일 (이미지/비디오) 섹션
                if (!post.isHtml && !post.isMarkdown && post.files.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: PostViewFiles(post: post),
                  ),

                // 본문 내용 섹션
                PostViewContent(
                  post: post,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                ),

                // 유튜브 영상
                if (post.isYoutube)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: YoutubePlayerList(
                      youtubeInfos: post.getAllYoutubeUrlInfos(),
                    ),
                  ),

                // 연락처 목록 섹션
                AdvertisementContactList(post: post),

                const SafeArea(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
