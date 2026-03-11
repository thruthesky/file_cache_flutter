# Flutter 앱 코멘트 스레드 세로선 — 완전 구현 가이드

## 목차

- [1. 개요](#1-개요)
- [2. 설계 원리](#2-설계-원리)
- [3. 파일 구조](#3-파일-구조)
- [4. 데이터 흐름](#4-데이터-흐름)
- [5. 트리 구조 변환](#5-트리-구조-변환)
- [6. CustomPainter — 세로선 + L곡선](#6-custompainter--세로선--l곡선)
- [7. CommentListView — 트리 기반 렌더링](#7-commentlistview--트리-기반-렌더링)
- [8. CommentTile — 아바타 아래 세로선](#8-commenttile--아바타-아래-세로선)
- [9. 핵심 수치 계산 근거](#9-핵심-수치-계산-근거)
- [10. 좌표 계산 다이어그램](#10-좌표-계산-다이어그램)
- [11. 트러블슈팅](#11-트러블슈팅)
- [12. 완전 복구 체크리스트](#12-완전-복구-체크리스트)

---

## 1. 개요

Reddit 스타일 코멘트 스레드 세로선은 부모-자식 관계를 시각적으로 표현하는 기능이다.
v7 웹 홈페이지의 세로선 구현(`v7-comment-thread-line.md`)을 Flutter 앱에 동일하게 적용한다.

**핵심 특징:**

| 항목 | 설명 |
|------|------|
| 세로선 시작 위치 | 부모 아바타 바로 아래 (갭 없음, Align topCenter) |
| 세로선 끝 위치 | 부모 코멘트의 내용/액션바 하단까지 (IntrinsicHeight로 자동 계산) |
| 곡선 연결선 | 모든 직접 자식에 L자 곡선으로 연결 (CustomPainter) |
| 마지막 자식 처리 | 곡선 연결점까지만 세로선 표시 |
| 세로선 두께 | 1.5px |
| 세로선 색상 | `#94A3B8` (slate-400) |
| 아바타 크기 | radius 16 (직경 32px) |
| 깊이별 패딩 | depth < 3: 16px, depth >= 3: 6px (lineXOffset으로 보정) |
| 데이터 구조 | 서버 플랫 리스트 → 클라이언트 트리 변환 (depth 필드 포함) |

**관련 파일:**

| 파일 | 역할 |
|------|------|
| `lib/post/view/widgets/comment_thread_painter.dart` | 트리 구조 + CustomPainter |
| `lib/post/view/widgets/comment.list.view.dart` | 트리 기반 재귀 렌더링 |
| `lib/post/view/widgets/comment.tile.dart` | 개별 코멘트 (아바타 아래 세로선 포함) |

---

## 2. 설계 원리

### 왜 트리 변환이 필요한가?

서버는 코멘트를 `depth`/`idxParent` 필드와 함께 **플랫 리스트**로 반환한다.
세로선을 그리려면 부모-자식 관계를 파악해야 하므로 **트리 구조로 변환**한다.

### 왜 IntrinsicHeight를 사용하는가?

- 세로선은 부모 아바타 아래에서 코멘트 하단까지 연결되어야 한다
- 코멘트 내용 길이가 가변적이므로 CSS `height: auto`처럼 동적 계산 필요
- Flutter의 `IntrinsicHeight`가 자식의 intrinsic height를 계산하여 Row의 모든 자식에게 같은 높이를 강제
- 이를 통해 아바타 Column의 `Expanded`가 내용 높이에 맞춰 세로선을 확장

### 왜 lineXOffset이 필요한가?

- 깊은 중첩(depth >= 3)에서 paddingLeft를 줄여 화면 공간을 절약한다
- paddingLeft가 avatarRadius(16)보다 작아지면 세로선의 X좌표가 부모 아바타 세로선과 어긋난다
- `lineXOffset = avatarRadius - paddingLeft`로 보정하여 부모 세로선과 정확히 정렬한다

### 해결 전략 (단계별)

```
Step 1: 플랫 리스트 → 트리 구조 변환
  └─ buildCommentTree()로 CommentNode 트리 생성
  └─ depth == 1인 코멘트를 루트로, idxParent 기준 자식 매핑
  └─ 각 노드에 nodeDepth 값 할당 (깊이별 패딩 계산에 사용)

Step 2: 재귀적 위젯 렌더링
  └─ _buildCommentNode(node): CommentTile + 자식 영역
  └─ _buildChildrenArea(node): IntrinsicHeight > Row > [커넥터 | 자식(재귀)]
  └─ 깊이별 동적 패딩 + lineXOffset 보정

Step 3: 부모 아바타 아래 세로선 (CommentTile)
  └─ showThreadLine=true: IntrinsicHeight > Row > [아바타+세로선 Column | 내용]
  └─ showThreadLine=false: 기본 Row > [아바타 | 내용]

Step 4: 자식 영역 커넥터 (ThreadConnectorPainter)
  └─ 마지막 아닌 자식: 전체 높이 세로선 + L곡선
  └─ 마지막 자식: 곡선까지만 세로선 + L곡선
  └─ lineXOffset으로 세로선 X 좌표 보정
```

---

## 3. 파일 구조

```
lib/post/view/widgets/
├── comment_thread_painter.dart  ← 트리 구조 + CustomPainter
├── comment.list.view.dart       ← 트리 기반 재귀 렌더링
├── comment.tile.dart            ← 개별 코멘트 (세로선 포함)
├── comment.input.dart           ← 댓글 입력 폼 (변경 없음)
└── comment.edit.dialog.dart     ← 댓글 수정 다이얼로그 (변경 없음)
```

---

## 4. 데이터 흐름

```
PostViewScreen
  └─ PostService.listComments(idxRoot) → List<Post> (플랫 리스트)
     └─ CommentListView(comments: flatList)
        └─ buildCommentTree(flatList) → List<CommentNode> (트리, depth 포함)
           └─ _buildCommentNode(node) (재귀 렌더링)
              ├─ CommentTile(showThreadLine: hasChildren)
              └─ _buildChildrenArea(node)
                 └─ 깊이별 paddingLeft + lineXOffset 계산
                 └─ IntrinsicHeight > Row > [커넥터(lineXOffset) | _buildCommentNode(child)]
```

---

## 5. 트리 구조 변환

> **파일**: `lib/post/view/widgets/comment_thread_painter.dart`

### 5.1 CommentNode 클래스

```dart
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
```

**depth 필드**: 트리 내 노드의 깊이를 저장한다. `_buildChildrenArea()`에서 깊이별 동적 패딩을 계산할 때 사용한다.

### 5.2 buildCommentTree() 함수

```dart
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
```

**동작 원리:**
1. `depth == 1`인 코멘트 → 루트 노드 (최상위 댓글)
2. `depth >= 2`인 코멘트 → `idxParent` 기준으로 `childrenMap`에 추가
3. 재귀적으로 각 노드의 자식을 매핑하며 `nodeDepth`를 증가시켜 트리 내 깊이를 추적

---

## 6. CustomPainter — 세로선 + L곡선

> **파일**: `lib/post/view/widgets/comment_thread_painter.dart`

### 6.1 ThreadConnectorPainter 전체 코드

```dart
/// Reddit 스타일 세로선 + L곡선 커넥터 페인터
///
/// 부모 코멘트에서 자식 코멘트로 연결되는 세로선과 L곡선을 그린다.
/// - 마지막이 아닌 자식: 전체 높이 세로선 + L곡선
/// - 마지막 자식: L곡선까지만 세로선
///
/// [lineXOffset]을 사용하여 세로선의 X 좌표를 조정할 수 있다.
/// paddingLeft가 아바타 중앙(avatarRadius)보다 작을 때,
/// lineXOffset = avatarRadius - paddingLeft 로 설정하면
/// 부모 아바타 세로선과 정확히 정렬된다.
class ThreadConnectorPainter extends CustomPainter {
  final bool isLast;
  final Color lineColor;
  final double lineWidth;

  /// 곡선이 연결되는 Y 위치 (자식 아바타의 수직 중앙)
  /// = 코멘트 행 상단 패딩(8) + 아바타 반지름(16) = 24
  final double curveTargetY;

  /// 곡선 반경
  final double curveRadius;

  /// 세로선 X 오프셋 (부모 아바타 세로선과 정렬하기 위한 보정값)
  final double lineXOffset;

  ThreadConnectorPainter({
    required this.isLast,
    this.lineColor = const Color(0xFF94A3B8),
    this.lineWidth = 1.0,
    this.curveTargetY = 24.0,
    this.curveRadius = 8.0,
    this.lineXOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final lx = lineXOffset;

    // 세로선: 위(0)에서 아래로 (X 오프셋 적용)
    final lineEndY = isLast ? curveTargetY - curveRadius : size.height;
    canvas.drawLine(
      Offset(lx, 0),
      Offset(lx, lineEndY),
      paint,
    );

    // L곡선: 세로선에서 수평으로 꺾어서 자식 아바타까지
    final path = Path()
      ..moveTo(lx, curveTargetY - curveRadius)
      ..quadraticBezierTo(lx, curveTargetY, lx + curveRadius, curveTargetY)
      ..lineTo(size.width, curveTargetY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ThreadConnectorPainter oldDelegate) {
    return oldDelegate.isLast != isLast ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.lineXOffset != lineXOffset ||
        oldDelegate.curveTargetY != curveTargetY;
  }
}
```

### 6.2 그리기 동작

**마지막이 아닌 자식 (isLast=false):**
```
│  ← 세로선: (lx, 0) → (lx, size.height) 전체 높이
│
├──  ← L곡선: (lx, curveTargetY-r) → 곡선 → (width, curveTargetY)
│
│  ← 세로선 계속
```

**마지막 자식 (isLast=true):**
```
│  ← 세로선: (lx, 0) → (lx, curveTargetY-r) 곡선 시작점까지만
│
└──  ← L곡선: (lx, curveTargetY-r) → 곡선 → (width, curveTargetY)
```

**lineXOffset 효과:**
- `lineXOffset = 0`: 세로선이 커넥터 영역 왼쪽 끝에서 시작 (paddingLeft == avatarRadius일 때)
- `lineXOffset > 0`: 세로선이 오른쪽으로 이동 (paddingLeft < avatarRadius일 때 보정)

---

## 7. CommentListView — 트리 기반 렌더링

> **파일**: `lib/post/view/widgets/comment.list.view.dart`

### 7.1 상수 정의

```dart
static const _lineColor = Color(0xFF94A3B8);      // 세로선 색상
static const _avatarRadius = 16.0;                  // 아바타 반지름
static const _commentTopPadding = 8.0;              // 코멘트 행 상단 패딩
static const _connectorWidth = 16.0;                // 커넥터 너비
static const _curveTargetY = _commentTopPadding + _avatarRadius;  // 24.0
```

### 7.2 _buildCommentTree() — 전체 트리 렌더링

```dart
Widget _buildCommentTree() {
  final treeRoots = buildCommentTree(widget.comments);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < treeRoots.length; i++) ...[
          // 최상위 코멘트 간 구분선
          if (i > 0)
            Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              height: 8,
            ),
          _buildCommentNode(treeRoots[i]),
        ],
      ],
    ),
  );
}
```

### 7.3 _buildCommentNode() — 재귀 노드 렌더링

```dart
Widget _buildCommentNode(CommentNode node) {
  final hasChildren = node.children.isNotEmpty;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 코멘트 타일
      CommentTile(
        comment: node.comment,
        allComments: widget.comments,
        hasChildren: hasChildren,
        showThreadLine: hasChildren,
        onReply: () {
          setState(() {
            _replyToIdx = _replyToIdx == node.comment.idx
                ? null
                : node.comment.idx;
          });
        },
        onEdit: widget.onEditComment,
        onDelete: widget.onDeleteComment,
      ),

      // 대댓글 입력 폼
      if (_replyToIdx == node.comment.idx)
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: _buildReplyInput(node.comment),
        ),

      // 자식 영역 (세로선 포함)
      if (hasChildren) _buildChildrenArea(node),
    ],
  );
}
```

### 7.4 _buildChildrenArea() — 세로선 + 곡선 커넥터 (깊이별 동적 패딩)

```dart
/// 자식 코멘트 영역 (세로선 + 곡선 연결선 포함)
///
/// 부모 아바타 중앙에서 세로선이 시작되어 마지막 직접 자식까지 연결된다.
/// paddingLeft를 줄이되, lineXOffset으로 세로선 X 좌표를 보정하여
/// 부모 아바타 세로선과 정확하게 정렬한다.
Widget _buildChildrenArea(CommentNode parentNode) {
  final children = parentNode.children;

  // 깊이 1-2: 정상 넓이 (paddingLeft = avatarRadius = 16)
  // 깊이 3+: 좁은 넓이 (paddingLeft = 6) + lineXOffset 보정으로 세로선 정렬 유지
  final paddingLeft = parentNode.depth >= 3 ? 6.0 : _avatarRadius;
  final lineXOffset = _avatarRadius - paddingLeft;

  return Padding(
    padding: EdgeInsets.only(left: paddingLeft),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 세로선 + L곡선 커넥터 (lineXOffset으로 부모 세로선과 정렬)
                SizedBox(
                  width: _connectorWidth,
                  child: CustomPaint(
                    painter: ThreadConnectorPainter(
                      isLast: i == children.length - 1,
                      lineColor: _lineColor,
                      lineWidth: 1.5,
                      curveTargetY: _curveTargetY,
                      curveRadius: 8.0,
                      lineXOffset: lineXOffset,
                    ),
                  ),
                ),

                // 자식 코멘트 노드 (재귀)
                Expanded(child: _buildCommentNode(children[i])),
              ],
            ),
          ),
      ],
    ),
  );
}
```

**핵심 포인트:**
- `crossAxisAlignment: CrossAxisAlignment.stretch` — CustomPaint가 Row의 전체 높이를 받도록 필수
- `IntrinsicHeight` — 자식 코멘트의 전체 높이(손자 포함)를 자동 계산
- **깊이별 동적 패딩**: `parentNode.depth >= 3`이면 paddingLeft를 6px로 줄여 깊은 중첩에서 공간 절약
- **lineXOffset 보정**: `_avatarRadius - paddingLeft`로 세로선 X좌표를 보정하여 부모 아바타 세로선과 정렬
- **lineWidth: 1.5** — 모든 세로선과 L곡선의 두께

---

## 8. CommentTile — 아바타 아래 세로선

> **파일**: `lib/post/view/widgets/comment.tile.dart`

### 8.1 세로선 색상 상수

```dart
const kThreadLineColor = Color(0xFF94A3B8);
```

### 8.2 핵심 파라미터

```dart
class CommentTile extends StatefulWidget {
  final bool hasChildren;       // 자식 존재 여부 (수정/삭제 버튼 제어)
  final bool showThreadLine;    // 아바타 아래 세로선 표시 여부
  // ...
}
```

### 8.3 세로선 포함 레이아웃 (_buildWithThreadLine)

자식이 있는 코멘트에서 사용. `IntrinsicHeight > Row` 구조로 아바타 아래에서 코멘트 하단까지 세로선 연결.

```dart
Widget _buildWithThreadLine(...) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 아바타 + 세로선 컬럼 (SizedBox로 너비 32 고정)
        SizedBox(
          width: 32,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),              // 상단 패딩
              CircleAvatar(radius: 16, ...),           // 아바타
              // 세로선: 아바타 하단에서 코멘트 하단까지 (중앙 정렬, 아바타와 붙어있음)
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 1.5,
                    color: kThreadLineColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),                   // 아바타-내용 간격
        Expanded(child: _buildContentColumn(...)),   // 내용
      ],
    ),
  );
}
```

**이전 버전과의 차이:**
- `SizedBox(width: 32)` 래퍼로 아바타+세로선 Column의 너비를 아바타 직경과 동일하게 고정
- `mainAxisAlignment: MainAxisAlignment.start`, `mainAxisSize: MainAxisSize.min` 설정
- `SizedBox(height: 2)` 제거 — 아바타와 세로선 사이에 갭 없음
- `Center` 대신 `Align(alignment: Alignment.topCenter)` 사용 — 세로선이 아바타 바로 아래에서 시작
- 세로선 두께: `Container(width: 1.5)` (1px에서 1.5px로 변경)

### 8.4 기본 레이아웃 (_buildNormal)

자식이 없는 코멘트에서 사용. 세로선 없이 아바타 + 내용만 표시.

```dart
Widget _buildNormal(...) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 16, ...),
        const SizedBox(width: 8),
        Expanded(child: _buildContentColumn(...)),
      ],
    ),
  );
}
```

### 8.5 액션 바 — SingleChildScrollView 래핑

깊은 중첩에서 액션 버튼들이 오버플로우되지 않도록 수평 스크롤로 감싼다.

```dart
// 액션 바
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      // 좋아요
      PostActionButton(...),
      const SizedBox(width: 8),
      // 답글
      PostActionButton(...),
      const SizedBox(width: 12),
      if (isMine) ...[
        if (!hasChildren) PostActionButton(/* 수정 */),
        if (!hasChildren) const SizedBox(width: 8),
        if (!hasChildren) PostActionButton(/* 삭제 */),
      ],
    ],
  ),
),
```

### 8.6 IntrinsicHeight 동작 원리

```
IntrinsicHeight가 Row의 intrinsic height를 계산:
  SizedBox(w:32) > Column(아바타+세로선) intrinsic height = 8 + 32 = 40 (Expanded는 0)
  Expanded(내용) intrinsic height = 내용 높이 (보통 60~100+)
  → Row height = max(40, 내용 높이) = 내용 높이

Column with Expanded:
  비-flex 자식: 40px (8 + 32, 갭 없음)
  Expanded(세로선): 내용 높이 - 40 = 세로선 길이
  → 세로선이 아바타 바로 아래에서 코멘트 하단까지 자동 확장
```

---

## 9. 핵심 수치 계산 근거

### 아바타 관련

```
아바타 반지름: 16px (직경 32px)
아바타 상단 패딩: 8px
아바타 중앙 Y: 8 + 16 = 24px
아바타 하단 Y: 8 + 32 = 40px
세로선 시작 Y: 40px (아바타 바로 아래, 갭 없음)
```

### 세로선 x좌표 일치 검증 — 얕은 깊이 (depth < 3)

```
부모 CommentTile (showThreadLine=true):
  SizedBox(width: 32) 안의 Column
  Align(topCenter) > Container(w:1.5)
  → 세로선 x = 16 (SizedBox 중앙, CommentTile 좌표계)

자식 영역 (paddingLeft = _avatarRadius = 16):
  lineXOffset = _avatarRadius - paddingLeft = 16 - 16 = 0
  커넥터 세로선 x = lineXOffset = 0 (커넥터 좌표계)
  → 전체 좌표: 16(padding) + 0 = 16
  → 부모 세로선 x와 일치 ✓
```

### 세로선 x좌표 일치 검증 — 깊은 깊이 (depth >= 3)

```
부모 CommentTile (showThreadLine=true):
  SizedBox(width: 32) 안의 Column
  Align(topCenter) > Container(w:1.5)
  → 세로선 x = 16 (SizedBox 중앙, CommentTile 좌표계)

자식 영역 (paddingLeft = 6):
  lineXOffset = _avatarRadius - paddingLeft = 16 - 6 = 10
  커넥터 세로선 x = lineXOffset = 10 (커넥터 좌표계)
  → 전체 좌표: 6(padding) + 10 = 16
  → 부모 세로선 x와 일치 ✓
```

### 곡선 타겟 Y 일치 검증

```
커넥터 curveTargetY = 24 (commentTopPadding 8 + avatarRadius 16)

자식 CommentTile의 아바타 중앙 Y:
  showThreadLine=true: SizedBox(h:8) + CircleAvatar 중앙(16) = 24 ✓
  showThreadLine=false: Padding(top:8) + CircleAvatar 중앙(16) = 24 ✓
```

### 들여쓰기 계산 — 깊이별

```
depth < 3 (paddingLeft = 16):
  Level 0 아바타 중앙: 16(외부 패딩) + 16(아바타 중앙) = 32px
  Level 1 아바타 중앙: 32 + 16(children padding) + 16(connector) + 16(아바타 중앙) = 80px
  Level 2 아바타 중앙: 80 + 16 + 16 + 16 = 128px
  → 각 레벨 차이: 48px (= avatarRadius + connectorWidth + avatarRadius)

depth >= 3 (paddingLeft = 6):
  Level 3 아바타 중앙: 128 + 6(children padding) + 16(connector) + 16(아바타 중앙) = 166px
  Level 4 아바타 중앙: 166 + 6 + 16 + 16 = 204px
  → 각 레벨 차이: 38px (= 6 + connectorWidth + avatarRadius)
  → 깊은 중첩에서 레벨당 10px 절약
```

---

## 10. 좌표 계산 다이어그램

```
_buildCommentNode(root)
┌────────────────────────────────────────────────────┐
│ CommentTile (showThreadLine=true)                  │
│ IntrinsicHeight                                    │
│ ┌──────────┐                                       │
│ │SizedBox  │ w:32                                  │
│ │ Column   │ mainAxisSize:min                      │
│ │ SizedBox │ h:8                                   │
│ │ ┌──────┐ │                                       │
│ │ │avatar│ │ CircleAvatar(r:16) → 직경 32px        │
│ │ └──────┘ │                                       │
│ │ │        │ (갭 없음, 아바타 바로 아래)            │
│ │ │ 세로선 │ Container(w:1.5, color:#94A3B8)       │
│ │ │        │ Expanded > Align(topCenter)            │
│ │ │        │                                       │
│ │ ↓        │                                       │
│ └──────────┘                                       │
│                                                    │
│  _buildChildrenArea (depth < 3: paddingLeft=16)    │
│  Padding(left: paddingLeft)                        │
│  ┌──────────────────────────────────────┐          │
│  │ IntrinsicHeight > Row(stretch)      │          │
│  │ ┌──────────┬─────────────────┐      │          │
│  │ │커넥터    │ 자식1 노드       │      │          │
│  │ │w:16      │ (재귀)          │      │          │
│  │ │lx=0     │                 │      │          │
│  │ │ │        │ ┌────────────┐  │      │          │
│  │ │ │        │ │avatar 자식1│  │      │          │
│  │ │ ├──→     │ └────────────┘  │      │          │
│  │ │ │        │ 내용...         │      │          │
│  │ │ │        │ 액션바          │      │          │
│  │ │ │        │                 │      │          │
│  │ └──────────┴─────────────────┘      │          │
│  │                                      │          │
│  │ IntrinsicHeight > Row(stretch)      │          │
│  │ ┌──────────┬─────────────────┐      │          │
│  │ │커넥터    │ 자식2 노드       │      │          │
│  │ │w:16      │ (마지막)        │      │          │
│  │ │lx=0     │ ┌────────────┐  │      │          │
│  │ │ └──→     │ │avatar 자식2│  │      │          │
│  │ │          │ └────────────┘  │      │          │
│  │ │          │ 내용...         │      │          │
│  │ └──────────┴─────────────────┘      │          │
│  └──────────────────────────────────────┘          │
│                                                    │
│  _buildChildrenArea (depth >= 3: paddingLeft=6)    │
│  Padding(left: 6)                                  │
│  ┌──────────────────────────────────────┐          │
│  │ 커넥터의 lineXOffset = 10            │          │
│  │ → 세로선 실제 x = 6 + 10 = 16       │          │
│  │ → 부모 아바타 중앙(16)과 정렬 ✓      │          │
│  └──────────────────────────────────────┘          │
└────────────────────────────────────────────────────┘
```

---

## 11. 트러블슈팅

### 세로선이 보이지 않는 경우

1. **CustomPaint 높이가 0**: `crossAxisAlignment: CrossAxisAlignment.stretch` 확인. `start`이면 SizedBox(width:16)에 height가 없어 0이 됨.
2. **IntrinsicHeight 누락**: `_buildChildrenArea`의 각 자식이 `IntrinsicHeight`로 감싸져야 함.
3. **트리 변환 실패**: `buildCommentTree`에서 `depth == 1` 조건 확인. 서버 데이터의 depth가 0부터 시작하면 조건 수정 필요.

### 세로선이 끊기는 경우

1. **부모 세로선 ↔ 커넥터 세로선 연결**: 부모 CommentTile의 세로선 x좌표와 커넥터 세로선 x좌표가 일치해야 함. `padding-left + lineXOffset`이 아바타 Column 중앙(16)과 같은지 확인.
2. **lineXOffset 계산 오류**: `lineXOffset = _avatarRadius - paddingLeft`가 정확한지 확인. paddingLeft가 avatarRadius보다 큰 경우 lineXOffset이 음수가 되어 세로선이 왼쪽 밖으로 나갈 수 있음.
3. **대댓글 입력 폼**: 대댓글 폼이 부모 CommentTile과 자식 영역 사이에 위치하면 세로선 끊김 발생 (알려진 제한사항, 입력 폼은 임시 표시이므로 수용 가능).

### 곡선 위치가 어긋나는 경우

- `curveTargetY`가 자식 아바타의 중앙 Y와 일치하는지 확인
- `curveTargetY = commentTopPadding(8) + avatarRadius(16) = 24`
- 곡선의 시작점이 `(lx, curveTargetY - curveRadius)`인지 확인 (lineXOffset 적용)

### 세로선이 손자까지 관통하는 경우

- 마지막 자식에서 `isLast: true`가 올바르게 전달되는지 확인
- `isLast: i == children.length - 1` 조건 검증

### 깊은 중첩에서 공간 부족

- depth < 3: 각 레벨 들여쓰기 = 48px (avatarRadius + connectorWidth + avatarRadius)
- depth >= 3: 각 레벨 들여쓰기 = 38px (6 + connectorWidth + avatarRadius)
- 360px 화면에서도 깊은 중첩 가능하도록 paddingLeft를 6px로 축소
- 액션 바가 오버플로우되면 `SingleChildScrollView(scrollDirection: Axis.horizontal)`로 수평 스크롤 처리됨

### lineXOffset 관련 문제

1. **세로선이 부모 아바타와 어긋남**: `paddingLeft + lineXOffset == _avatarRadius(16)`인지 확인
2. **깊이 조건 변경 시**: `parentNode.depth >= 3` 조건을 변경하면 해당 깊이의 paddingLeft와 lineXOffset도 함께 업데이트해야 함
3. **shouldRepaint에서 lineXOffset 비교 누락**: `oldDelegate.lineXOffset != lineXOffset` 비교가 `shouldRepaint`에 포함되어 있는지 확인 (누락 시 lineXOffset 변경이 반영되지 않음)

---

## 12. 완전 복구 체크리스트

이 문서만으로 전체 기능을 100% 복구할 수 있도록, 다음 체크리스트를 따른다:

### comment_thread_painter.dart

- [ ] `CommentNode` 클래스 (comment + children + depth 필드)
  - [ ] `depth` 기본값 1
- [ ] `buildCommentTree()` 함수 (depth==1 루트, idxParent 기준 자식 매핑)
  - [ ] `buildNode()` 내부 함수에 `nodeDepth` 파라미터
  - [ ] 재귀 호출 시 `nodeDepth: nodeDepth + 1`로 depth 전달
  - [ ] `CommentNode(depth: nodeDepth)`로 depth 설정
- [ ] `ThreadConnectorPainter` CustomPainter
  - [ ] `isLast` 파라미터로 마지막 자식 구분
  - [ ] `lineXOffset` 파라미터 (기본값 0.0) — 세로선 X좌표 보정
  - [ ] 세로선: `canvas.drawLine(Offset(lx, 0), Offset(lx, lineEndY))` — lineXOffset 적용
  - [ ] L곡선: `quadraticBezierTo(lx, curveTargetY, lx + curveRadius, curveTargetY)` — lineXOffset 적용
  - [ ] 수평선: `lineTo(size.width, curveTargetY)`
  - [ ] `shouldRepaint`: isLast, lineColor, lineXOffset, curveTargetY 비교

### comment.list.view.dart

- [ ] 상수: `_lineColor(#94A3B8)`, `_avatarRadius(16)`, `_connectorWidth(16)`, `_curveTargetY(24)`
- [ ] `_buildCommentTree()`: `buildCommentTree()` 호출 → 루트 노드 순회
- [ ] `_buildCommentNode(node)`: CommentTile + 자식 영역 재귀 렌더링
  - [ ] `CommentTile(showThreadLine: hasChildren, hasChildren: hasChildren)`
  - [ ] 대댓글 입력 폼 (선택적)
  - [ ] `_buildChildrenArea(node)` (hasChildren일 때)
- [ ] `_buildChildrenArea(parentNode)`:
  - [ ] 깊이별 동적 패딩: `parentNode.depth >= 3 ? 6.0 : _avatarRadius`
  - [ ] lineXOffset 계산: `_avatarRadius - paddingLeft`
  - [ ] `Padding(left: paddingLeft)` 들여쓰기
  - [ ] 각 자식: `IntrinsicHeight > Row(stretch)` 필수
  - [ ] `SizedBox(width: _connectorWidth) > CustomPaint(ThreadConnectorPainter)`
  - [ ] ThreadConnectorPainter에 `lineWidth: 1.5`, `lineXOffset: lineXOffset` 전달
  - [ ] `Expanded > _buildCommentNode(child)` 재귀

### comment.tile.dart

- [ ] `kThreadLineColor = Color(0xFF94A3B8)` 상수
- [ ] `showThreadLine` 파라미터 (기본 false)
- [ ] `hasChildren` 파라미터 (기본 false)
- [ ] `showThreadLine=true`: `_buildWithThreadLine()` — IntrinsicHeight > Row
  - [ ] `SizedBox(width: 32)` 래퍼로 Column 감싸기
  - [ ] Column: `mainAxisAlignment: MainAxisAlignment.start`, `mainAxisSize: MainAxisSize.min`
  - [ ] 아바타 Column: SizedBox(h:8) + CircleAvatar(r:16) + Expanded(세로선)
  - [ ] 세로선: `Expanded > Align(alignment: Alignment.topCenter) > Container(width: 1.5)`
  - [ ] 아바타와 세로선 사이 갭 없음 (SizedBox(height:2) 없음)
  - [ ] 내용 Column: _buildContentColumn()
- [ ] `showThreadLine=false`: `_buildNormal()` — Padding(top:8) > Row
- [ ] `_buildContentColumn()`: 작성자/날짜 + 내용 + 첨부파일 + 액션바
- [ ] 작성자명 Row에 `Flexible` + `TextOverflow.ellipsis` (오버플로우 방지)
- [ ] 액션 바: `SingleChildScrollView(scrollDirection: Axis.horizontal)` > Row (오버플로우 방지)
