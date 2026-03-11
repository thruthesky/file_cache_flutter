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
| 세로선 시작 위치 | 부모 아바타 바로 아래 (2px gap) |
| 세로선 끝 위치 | 부모 코멘트의 내용/액션바 하단까지 (IntrinsicHeight로 자동 계산) |
| 곡선 연결선 | 모든 직접 자식에 L자 곡선으로 연결 (CustomPainter) |
| 마지막 자식 처리 | 곡선 연결점까지만 세로선 표시 |
| 세로선 두께 | 1px |
| 세로선 색상 | `#94A3B8` (slate-400) |
| 아바타 크기 | radius 16 (직경 32px) |
| 데이터 구조 | 서버 플랫 리스트 → 클라이언트 트리 변환 |

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

### 해결 전략 (단계별)

```
Step 1: 플랫 리스트 → 트리 구조 변환
  └─ buildCommentTree()로 CommentNode 트리 생성
  └─ depth == 1인 코멘트를 루트로, idxParent 기준 자식 매핑

Step 2: 재귀적 위젯 렌더링
  └─ _buildCommentNode(node): CommentTile + 자식 영역
  └─ _buildChildrenArea(node): IntrinsicHeight > Row > [커넥터 | 자식(재귀)]

Step 3: 부모 아바타 아래 세로선 (CommentTile)
  └─ showThreadLine=true: IntrinsicHeight > Row > [아바타+세로선 Column | 내용]
  └─ showThreadLine=false: 기본 Row > [아바타 | 내용]

Step 4: 자식 영역 커넥터 (ThreadConnectorPainter)
  └─ 마지막 아닌 자식: 전체 높이 세로선 + L곡선
  └─ 마지막 자식: 곡선까지만 세로선 + L곡선
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
        └─ buildCommentTree(flatList) → List<CommentNode> (트리)
           └─ _buildCommentNode(node) (재귀 렌더링)
              ├─ CommentTile(showThreadLine: hasChildren)
              └─ _buildChildrenArea(node)
                 └─ IntrinsicHeight > Row > [커넥터 | _buildCommentNode(child)]
```

---

## 5. 트리 구조 변환

> **파일**: `lib/post/view/widgets/comment_thread_painter.dart`

### 5.1 CommentNode 클래스

```dart
/// 코멘트 트리 노드
class CommentNode {
  final Post comment;
  final List<CommentNode> children;

  CommentNode({required this.comment, List<CommentNode>? children})
      : children = children ?? [];
}
```

### 5.2 buildCommentTree() 함수

```dart
/// 플랫 코멘트 리스트를 트리 구조로 변환
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

  CommentNode buildNode(Post comment) {
    final children = childrenMap[comment.idx] ?? [];
    return CommentNode(
      comment: comment,
      children: children.map(buildNode).toList(),
    );
  }

  return roots.map(buildNode).toList();
}
```

**동작 원리:**
1. `depth == 1`인 코멘트 → 루트 노드 (최상위 댓글)
2. `depth >= 2`인 코멘트 → `idxParent` 기준으로 `childrenMap`에 추가
3. 재귀적으로 각 노드의 자식을 매핑하여 트리 구성

---

## 6. CustomPainter — 세로선 + L곡선

> **파일**: `lib/post/view/widgets/comment_thread_painter.dart`

### 6.1 ThreadConnectorPainter 전체 코드

```dart
/// Reddit 스타일 세로선 + L곡선 커넥터 페인터
class ThreadConnectorPainter extends CustomPainter {
  final bool isLast;
  final Color lineColor;
  final double lineWidth;
  final double curveTargetY;  // 곡선 연결 Y (자식 아바타 중앙)
  final double curveRadius;   // 곡선 반경

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
```

### 6.2 그리기 동작

**마지막이 아닌 자식 (isLast=false):**
```
│  ← 세로선: (0,0) → (0, size.height) 전체 높이
│
├──  ← L곡선: (0, curveTargetY-r) → 곡선 → (width, curveTargetY)
│
│  ← 세로선 계속
```

**마지막 자식 (isLast=true):**
```
│  ← 세로선: (0,0) → (0, curveTargetY-r) 곡선 시작점까지만
│
└──  ← L곡선: (0, curveTargetY-r) → 곡선 → (width, curveTargetY)
```

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
      CommentTile(
        comment: node.comment,
        allComments: widget.comments,
        hasChildren: hasChildren,
        showThreadLine: hasChildren,
        onReply: () { /* 답글 토글 */ },
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

### 7.4 _buildChildrenArea() — 세로선 + 곡선 커넥터

```dart
Widget _buildChildrenArea(CommentNode parentNode) {
  final children = parentNode.children;

  return Padding(
    // 부모 아바타 중앙 기준 들여쓰기
    padding: const EdgeInsets.only(left: _avatarRadius),  // 16px
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 세로선 + L곡선 커넥터
                SizedBox(
                  width: _connectorWidth,  // 16px
                  child: CustomPaint(
                    painter: ThreadConnectorPainter(
                      isLast: i == children.length - 1,
                      lineColor: _lineColor,
                      curveTargetY: _curveTargetY,  // 24.0
                      curveRadius: 8.0,
                    ),
                  ),
                ),

                // 자식 코멘트 노드 (재귀)
                Expanded(
                  child: _buildCommentNode(children[i]),
                ),
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
- `padding: EdgeInsets.only(left: _avatarRadius)` — 부모 아바타 중앙 기준 들여쓰기

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
        // 아바타 + 세로선 컬럼
        Column(
          children: [
            const SizedBox(height: 8),              // 상단 패딩
            CircleAvatar(radius: 16, ...),           // 아바타
            const SizedBox(height: 2),               // 아바타-세로선 간격
            Expanded(                                // 세로선
              child: Center(
                child: Container(width: 1, color: kThreadLineColor),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),                   // 아바타-내용 간격
        Expanded(child: _buildContentColumn(...)),   // 내용
      ],
    ),
  );
}
```

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

### 8.5 IntrinsicHeight 동작 원리

```
IntrinsicHeight가 Row의 intrinsic height를 계산:
  Column(아바타+세로선) intrinsic height = 8 + 32 + 2 = 42 (Expanded는 0)
  Expanded(내용) intrinsic height = 내용 높이 (보통 60~100+)
  → Row height = max(42, 내용 높이) = 내용 높이

Column with Expanded:
  비-flex 자식: 42px
  Expanded(세로선): 내용 높이 - 42 = 세로선 길이
  → 세로선이 아바타 하단에서 코멘트 하단까지 자동 확장
```

---

## 9. 핵심 수치 계산 근거

### 아바타 관련

```
아바타 반지름: 16px (직경 32px)
아바타 상단 패딩: 8px
아바타 중앙 Y: 8 + 16 = 24px
아바타 하단 Y: 8 + 32 = 40px
세로선 시작 Y: 40 + 2(gap) = 42px
```

### 세로선 x좌표 일치 검증

```
부모 CommentTile (showThreadLine=true):
  아바타 Column 너비 = CircleAvatar 직경 = 32px
  Center > Container(w:1) → Column 중앙 = x=16
  → 세로선 x = 16 (CommentTile 좌표계)

자식 영역:
  padding-left = _avatarRadius = 16px
  커넥터 세로선 x = 0 (커넥터 좌표계)
  → 전체 좌표: 16(padding) + 0 = 16
  → 부모 세로선 x와 일치 ✓
```

### 곡선 타겟 Y 일치 검증

```
커넥터 curveTargetY = 24 (commentTopPadding 8 + avatarRadius 16)

자식 CommentTile의 아바타 중앙 Y:
  showThreadLine=true: SizedBox(h:8) + CircleAvatar 중앙(16) = 24 ✓
  showThreadLine=false: Padding(top:8) + CircleAvatar 중앙(16) = 24 ✓
```

### 들여쓰기 계산

```
Level 0 아바타 중앙: 16(외부 패딩) + 16(아바타 중앙) = 32px
Level 1 아바타 중앙: 32 + 16(children padding) + 16(connector) + 16(아바타 중앙) = 80px
Level 2 아바타 중앙: 80 + 16 + 16 + 16 = 128px
→ 각 레벨 차이: 48px (= avatarRadius + connectorWidth + avatarRadius)
```

---

## 10. 좌표 계산 다이어그램

```
_buildCommentNode(root)
┌────────────────────────────────────────────────────┐
│ CommentTile (showThreadLine=true)                  │
│ IntrinsicHeight                                    │
│ ┌──────────┐                                       │
│ │ SizedBox  │ h:8                                  │
│ │ ┌──────┐ │                                       │
│ │ │avatar│ │ CircleAvatar(r:16) → 직경 32px        │
│ │ └──────┘ │                                       │
│ │ SizedBox  │ h:2                                  │
│ │ │        │                                       │
│ │ │ 세로선 │ Container(w:1, color:#94A3B8)          │
│ │ │        │ Expanded → 내용 높이까지 확장          │
│ │ │        │                                       │
│ │ ↓        │                                       │
│ └──────────┘                                       │
│                                                    │
│  _buildChildrenArea                                │
│  Padding(left: 16)  ← 아바타 중앙 기준             │
│  ┌──────────────────────────────────────┐          │
│  │ IntrinsicHeight > Row(stretch)      │          │
│  │ ┌──────────┬─────────────────┐      │          │
│  │ │커넥터    │ 자식1 노드       │      │          │
│  │ │w:16      │ (재귀)          │      │          │
│  │ │          │                 │      │          │
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
│  │ │          │ ┌────────────┐  │      │          │
│  │ │ └──→     │ │avatar 자식2│  │      │          │
│  │ │          │ └────────────┘  │      │          │
│  │ │          │ 내용...         │      │          │
│  │ └──────────┴─────────────────┘      │          │
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

1. **부모 세로선 ↔ 커넥터 세로선 연결**: 부모 CommentTile의 세로선 x좌표와 커넥터 세로선 x좌표가 일치해야 함. `padding-left: _avatarRadius`가 아바타 Column 중앙과 같은지 확인.
2. **대댓글 입력 폼**: 대댓글 폼이 부모 CommentTile과 자식 영역 사이에 위치하면 세로선 끊김 발생 (알려진 제한사항, 입력 폼은 임시 표시이므로 수용 가능).

### 곡선 위치가 어긋나는 경우

- `curveTargetY`가 자식 아바타의 중앙 Y와 일치하는지 확인
- `curveTargetY = commentTopPadding(8) + avatarRadius(16) = 24`

### 세로선이 손자까지 관통하는 경우

- 마지막 자식에서 `isLast: true`가 올바르게 전달되는지 확인
- `isLast: i == children.length - 1` 조건 검증

### 깊은 중첩에서 공간 부족

- 각 레벨 들여쓰기 = 48px (avatarRadius + connectorWidth + avatarRadius)
- 360px 화면에서 Level 5까지 약 240px 사용, 나머지 120px 가용
- 필요시 `_connectorWidth`를 줄이거나 `clamp`로 최대 깊이 제한

---

## 12. 완전 복구 체크리스트

이 문서만으로 전체 기능을 100% 복구할 수 있도록, 다음 체크리스트를 따른다:

### comment_thread_painter.dart

- [ ] `CommentNode` 클래스 (comment + children 필드)
- [ ] `buildCommentTree()` 함수 (depth==1 루트, idxParent 기준 자식 매핑)
- [ ] `ThreadConnectorPainter` CustomPainter
  - [ ] `isLast` 파라미터로 마지막 자식 구분
  - [ ] 세로선: `canvas.drawLine()` — isLast에 따라 높이 제한
  - [ ] L곡선: `quadraticBezierTo()` — curveRadius 기반 둥근 모서리
  - [ ] 수평선: `lineTo(size.width, curveTargetY)`

### comment.list.view.dart

- [ ] 상수: `_lineColor(#94A3B8)`, `_avatarRadius(16)`, `_connectorWidth(16)`, `_curveTargetY(24)`
- [ ] `_buildCommentTree()`: `buildCommentTree()` 호출 → 루트 노드 순회
- [ ] `_buildCommentNode(node)`: CommentTile + 자식 영역 재귀 렌더링
  - [ ] `CommentTile(showThreadLine: hasChildren, hasChildren: hasChildren)`
  - [ ] 대댓글 입력 폼 (선택적)
  - [ ] `_buildChildrenArea(node)` (hasChildren일 때)
- [ ] `_buildChildrenArea(parentNode)`:
  - [ ] `Padding(left: _avatarRadius)` 들여쓰기
  - [ ] 각 자식: `IntrinsicHeight > Row(stretch)` 필수
  - [ ] `SizedBox(width: _connectorWidth) > CustomPaint(ThreadConnectorPainter)`
  - [ ] `Expanded > _buildCommentNode(child)` 재귀

### comment.tile.dart

- [ ] `kThreadLineColor = Color(0xFF94A3B8)` 상수
- [ ] `showThreadLine` 파라미터 (기본 false)
- [ ] `hasChildren` 파라미터 (기본 false)
- [ ] `showThreadLine=true`: `_buildWithThreadLine()` — IntrinsicHeight > Row
  - [ ] 아바타 Column: SizedBox(h:8) + CircleAvatar(r:16) + SizedBox(h:2) + Expanded(세로선)
  - [ ] 내용 Column: _buildContentColumn()
- [ ] `showThreadLine=false`: `_buildNormal()` — Padding(top:8) > Row
- [ ] `_buildContentColumn()`: 작성자/날짜 + 내용 + 첨부파일 + 액션바
- [ ] 작성자명 Row에 `Flexible` + `TextOverflow.ellipsis` (오버플로우 방지)
