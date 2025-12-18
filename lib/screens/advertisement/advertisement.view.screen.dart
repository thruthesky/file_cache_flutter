import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 광고 상세 화면 (Advertisement View Screen)
///
/// idx에 해당하는 광고 글을 post_view API로 가져와서
/// 제목, 내용, 첨부 이미지를 표시합니다.
///
/// ### 사용법:
/// ```dart
/// AdvertisementViewScreen(idx: 12345);
/// ```
class AdvertisementViewScreen extends StatefulWidget {
  /// 조회할 게시글 번호
  final int idx;

  const AdvertisementViewScreen({super.key, required this.idx});

  @override
  State<AdvertisementViewScreen> createState() =>
      _AdvertisementViewScreenState();
}

class _AdvertisementViewScreenState extends State<AdvertisementViewScreen> {
  /// 게시글 로딩 Future
  late Future<Post> _postFuture;

  @override
  void initState() {
    super.initState();
    // post_view API로 게시글 가져오기
    _postFuture = getPost(widget.idx);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        elevation: 0,
        // 오른쪽 액션 버튼 - 연한 원형 닫기 버튼
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    color: scheme.onSurfaceVariant,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Post>(
        future: _postFuture,
        builder: (context, snapshot) {
          // 로딩 상태
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          // 에러 상태
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: scheme.error),
                  const SizedBox(height: 16),
                  Text('글을 불러올 수 없습니다', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _postFuture = getPost(widget.idx);
                      });
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 데이터 없음 상태
          if (!snapshot.hasData) {
            return Center(
              child: Text('글이 존재하지 않습니다', style: theme.textTheme.bodyLarge),
            );
          }

          // 성공 - 게시글 표시
          final post = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첨부 파일 (이미지/비디오) 섹션
                if (post.files.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  PostViewFiles(
                    files: post.files,
                    postIdx: post.idx,
                    enableHeroTransition: false,
                  ),
                  const SizedBox(height: 16),
                ],

                // 본문 내용 섹션
                PostViewContent(
                  isLoading: false,
                  content: post.content,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
