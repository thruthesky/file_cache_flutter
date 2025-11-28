import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 게시물 및 댓글 신고 버튼 위젯
///
/// 사용자가 부적절한 게시물이나 댓글을 신고할 수 있는 기능을 제공
/// - 버튼 클릭 시 바텀 시트 모달을 통해 신고 사유 선택
/// - 타입(post/comment)에 따라 다른 신고 사유 목록 표시
/// - 신고 완료 시 성공 메시지 표시
class PostReportButton extends StatefulWidget {
  const PostReportButton({
    super.key,
    required this.type,
    required this.idx,
    this.post,
    this.comment,
  });

  /// 신고 대상 타입 ('post' 또는 'comment')
  final String type;

  /// 신고 대상의 고유 ID
  final int idx;
  final Post? post;
  final Comment? comment;

  @override
  State<PostReportButton> createState() => _PostReportButtonState();
}

class _PostReportButtonState extends State<PostReportButton> {
  int currentReportCounter = 0;

  @override
  void initState() {
    super.initState();
    currentReportCounter = getReportCounter();
  }

  /// 타입에 따른 신고 사유 목록을 반환하는 메서드
  ///
  /// [type] 신고 대상 타입
  /// - 'post': 게시물 신고 사유 (카테고리 오류, 시비/욕설, 스팸, 기타)
  /// - 'comment': 댓글 신고 사유 (시비/욕설, 스팸, 기타)
  /// - 기타: 기본 사유 (기타)
  List<String> getReportReason(BuildContext context, String type) {
    final tr = LibTr.of(context)!;
    if (type == 'post') {
      return [
        tr.report_reason_category_error,
        tr.report_reason_abuse,
        tr.report_reason_spam,
        tr.report_reason_other
      ];
    } else if (type == 'comment') {
      return [tr.report_reason_abuse, tr.report_reason_spam, tr.report_reason_other];
    }
    return [tr.report_reason_other];
  }

  /// 신고를 처리하는 메서드
  /// [reason] 신고 사유
  /// 성공 시 성공 메시지를 표시하고, 에러는 reportPost 함수에서 자동으로 처리됨
  Future<void> handleReport(String reason) async {
    try {
      final res = await reportPost(
        type: widget.type,
        idx: widget.idx,
        reason: reason,
      );
      if (mounted && res['error'] != null && res['message'] != null) {
        showErrorSnackBar(context, res['message']);
        return;
      }
      if (mounted && res['message'] != null && res['message']!.isNotEmpty) {
        showSuccessSnackBar(context, LibTr.of(context)!.report_success);
        increaseCounter();
        return;
      }
    } catch (e) {
      log('신고 처리 중 에러 발생: $e', name: 'PostReportButton::handleReport');
      if (mounted) {
        showErrorSnackBar(context, LibTr.of(context)!.report_failed);
      }
    }
  }

  void increaseCounter() {
    currentReportCounter++;
    setState(() {});
  }

  int getReportCounter() {
    if (widget.type == 'post' && widget.post != null) {
      return widget.post!.reportCounter;
    } else if (widget.type == 'comment' && widget.comment != null) {
      return widget.comment!.reportCounter;
    }
    return 0;
  }

  /// 신고 사유 선택 바텀 시트 모달을 표시하는 메서드
  ///
  /// 하단에서 올라오는 모달 창을 표시하여 사용자가 신고 사유를 선택할 수 있도록 함
  /// - 게시물 타입(post/comment)에 따라 다른 신고 사유 목록 표시
  /// - 사유 선택 시 handleReport() 호출 후 모달 자동 닫힘
  /// - Theme 기반 스타일링으로 다크모드/라이트모드 자동 대응
  void _showReportReasonBottomSheet() {
    final scheme = Theme.of(context).colorScheme;
    final reasons = getReportReason(context, widget.type);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들 바
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더: 제목과 닫기 버튼
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LibTr.of(context)!.report_select_reason,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 신고 사유 목록
              ...reasons.map(
                (reason) => ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.hexagonExclamation,
                    size: 20,
                    color: scheme.onSurface,
                  ),
                  title: Text(reason),
                  onTap: () {
                    Navigator.of(context).pop();
                    handleReport(reason);
                  },
                ),
              ),

              // 하단 여백 (안전 영역 확보)
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
      // style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 8)),
      onPressed: _showReportReasonBottomSheet,
      icon: const FaIcon(FontAwesomeIcons.hexagonExclamation, size: 16),
      label: Text(
        "${LibTr.of(context)!.report} ${currentReportCounter > 0 ? currentReportCounter : ''}",
      ),
    );
  }
}
