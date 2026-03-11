import 'package:flutter/material.dart';
import 'package:philgo/post/post.model.dart';

/// 코멘트 트리 노드
///
/// 플랫 리스트를 트리 구조로 변환하기 위한 헬퍼 클래스.
class CommentNode {
  final Post comment;
  final List<CommentNode> children;
  final int depth;

  CommentNode({
    required this.comment,
    List<CommentNode>? children,
    this.depth = 1,
  }) : children = children ?? [];
}

/// 플랫 코멘트 리스트를 트리 구조로 변환
///
/// 서버에서 depth, idxParent 필드와 함께 플랫 리스트로 받은 코멘트를
/// 부모-자식 관계의 트리 구조로 변환한다.
List<CommentNode> buildCommentTree(List<Post> flatComments) {
  final Map<int, List<Post>> childrenMap = {};
  final List<Post> roots = [];

  for (final comment in flatComments) {
    if (comment.depth == 1) {
      roots.add(comment);
    } else {
      final parentIdx = comment.idxParent;
      childrenMap.putIfAbsent(parentIdx, () => []).add(comment);
    }
  }

  CommentNode buildNode(Post comment, {int nodeDepth = 1}) {
    final children = childrenMap[comment.idx] ?? [];
    return CommentNode(
      comment: comment,
      children: children.map((child) => buildNode(child, nodeDepth: nodeDepth + 1)).toList(),
      depth: nodeDepth,
    );
  }

  return roots.map((root) => buildNode(root, nodeDepth: 1)).toList();
}

/// Reddit 스타일 세로선 + L곡선 커넥터 페인터
///
/// 부모 코멘트에서 자식 코멘트로 연결되는 세로선과 L곡선을 그린다.
/// - 마지막이 아닌 자식: 전체 높이 세로선 + L곡선
/// - 마지막 자식: L곡선까지만 세로선
class ThreadConnectorPainter extends CustomPainter {
  final bool isLast;
  final Color lineColor;
  final double lineWidth;

  /// 곡선이 연결되는 Y 위치 (자식 아바타의 수직 중앙)
  /// = 코멘트 행 상단 패딩(8) + 아바타 반지름(16) = 24
  final double curveTargetY;

  /// 곡선 반경
  final double curveRadius;

  ThreadConnectorPainter({
    required this.isLast,
    this.lineColor = const Color(0xFF94A3B8),
    this.lineWidth = 1.0,
    this.curveTargetY = 24.0,
    this.curveRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    // 세로선: 위(0)에서 아래로
    final lineEndY = isLast ? curveTargetY - curveRadius : size.height;
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, lineEndY),
      paint,
    );

    // L곡선: 세로선에서 수평으로 꺾어서 자식 아바타까지
    final path = Path()
      ..moveTo(0, curveTargetY - curveRadius)
      ..quadraticBezierTo(0, curveTargetY, curveRadius, curveTargetY)
      ..lineTo(size.width, curveTargetY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ThreadConnectorPainter oldDelegate) {
    return oldDelegate.isLast != isLast ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.curveTargetY != curveTargetY;
  }
}
