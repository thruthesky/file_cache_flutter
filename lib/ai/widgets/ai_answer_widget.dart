import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:philgo/ai/ai.service.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/globals.dart';
import 'package:url_launcher/url_launcher.dart';

/// AI 답변 위젯
///
/// 게시글 상세 화면에서 AI 답변을 표시하거나 생성하는 위젯.
/// - 이미 AI 답변이 있으면 마크다운으로 표시
/// - 답변이 없고 적격 게시판이면 "AI 답변 생성" 버튼 표시
/// - 스트리밍 중에는 실시간 마크다운 렌더링
class AiAnswerWidget extends StatefulWidget {
  final Post post;
  final ValueChanged<Post> onPostUpdated;

  const AiAnswerWidget({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<AiAnswerWidget> createState() => _AiAnswerWidgetState();
}

class _AiAnswerWidgetState extends State<AiAnswerWidget> {
  bool _isStreaming = false;
  String _streamedText = '';
  String? _error;

  /// AI 답변이 이미 있는지 (서버 저장 완료된 답변)
  bool get _hasExistingAnswer => widget.post.hasAiAnswer;

  /// 표시할 AI 답변 텍스트 (기존 답변 또는 스트리밍 중인 답변)
  String get _displayText =>
      _isStreaming ? _streamedText : widget.post.text7;

  Future<void> _generateAiAnswer() async {
    setState(() {
      _isStreaming = true;
      _streamedText = '';
      _error = null;
    });

    await AiService.answerPost(
      idx: widget.post.idx,
      onChunk: (chunk) {
        if (!mounted) return;
        setState(() {
          _streamedText += chunk;
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _isStreaming = false;
        });
        // 서버가 자동으로 저장했으므로 post의 text7 업데이트
        widget.onPostUpdated(widget.post.copyWith(text7: _streamedText));
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isStreaming = false;
          _error = error;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // AI 답변 대상이 아니면 아무것도 표시하지 않음
    if (!widget.post.isAiAnswerTarget) return const SizedBox.shrink();

    // AI 답변이 없고 스트리밍 중도 아닌 경우 → 생성 버튼 표시
    if (!_hasExistingAnswer && !_isStreaming && _streamedText.isEmpty) {
      return _buildGenerateButton();
    }

    // AI 답변 표시 (기존 답변 또는 스트리밍 중인 답변)
    return _buildAnswerView();
  }

  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _generateAiAnswer,
              icon: FaIcon(
                FontAwesomeIcons.lightSparkles,
                size: 16,
                color: color.primary,
              ),
              // "Generate AI Answer"
              label: Text('AI 답변 생성'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: color.primary,
                side: BorderSide(color: color.primary.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: color.error, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // AI 답변 헤더
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightSparkles,
                size: 14,
                color: color.primary,
              ),
              const SizedBox(width: 6),
              Text(
                // "AI Answer"
                'AI 답변'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.primary,
                ),
              ),
              if (_isStreaming) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // 마크다운 렌더링
          if (_displayText.isNotEmpty)
            MarkdownBlock(
              data: _displayText,
              config: MarkdownConfig(
                configs: [
                  LinkConfig(
                    onTap: (url) async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    style: TextStyle(
                      color: color.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  PConfig(
                    textStyle: TextStyle(
                      fontSize: 15,
                      color: color.onSurface,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: color.error, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
