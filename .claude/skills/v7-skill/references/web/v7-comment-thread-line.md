# Reddit 스타일 코멘트 스레드 세로선 — 완전 구현 가이드

## 목차

- [1. 개요](#1-개요)
- [2. 설계 원리 (CoT — 단계별 사고)](#2-설계-원리-cot--단계별-사고)
- [3. 문제 분해 (ToT — 트리 사고)](#3-문제-분해-tot--트리-사고)
- [4. 파일 구조](#4-파일-구조)
- [5. HTML 구조 — PHP 재귀 렌더링](#5-html-구조--php-재귀-렌더링)
  - [5.1 코멘트 트리 맵 구성](#51-코멘트-트리-맵-구성)
  - [5.2 재귀 렌더링 함수 renderCommentThread()](#52-재귀-렌더링-함수-rendercommentthread)
  - [5.3 렌더링된 HTML DOM 구조](#53-렌더링된-html-dom-구조)
- [6. CSS 전체 코드 — 세로선 + 곡선 연결선](#6-css-전체-코드--세로선--곡선-연결선)
  - [6.1 데스크탑 CSS](#61-데스크탑-css)
  - [6.2 모바일 반응형 CSS](#62-모바일-반응형-css)
  - [6.3 CSS 핵심 수치 계산 근거](#63-css-핵심-수치-계산-근거)
- [7. JavaScript 전체 코드 — 세로선 높이 동적 계산 + 접기/펼치기](#7-javascript-전체-코드--세로선-높이-동적-계산--접기펼치기)
  - [7.1 adjustThreadLines() 함수](#71-adjustthreadlines-함수)
  - [7.2 접기/펼치기 이벤트 핸들러](#72-접기펼치기-이벤트-핸들러)
  - [7.3 JS 핵심 수치 계산 근거](#73-js-핵심-수치-계산-근거)
- [8. 접기/펼치기 동작 방식](#8-접기펼치기-동작-방식)
- [9. 좌표 계산 다이어그램](#9-좌표-계산-다이어그램)
- [10. 트러블슈팅 및 주의사항](#10-트러블슈팅-및-주의사항)
- [11. 완전 복구 체크리스트](#11-완전-복구-체크리스트)

---

## 1. 개요

Reddit 스타일 코멘트 스레드 세로선은 부모-자식 관계를 시각적으로 표현하는 기능이다.

**핵심 특징:**

| 항목 | 설명 |
|------|------|
| 세로선 시작 위치 | 부모 아바타 바로 아래 |
| 세로선 끝 위치 | 마지막 직접 자식의 상단 (JS 동적 계산) |
| 곡선 연결선 | 모든 직접 자식에 L자 곡선으로 연결 (`::before`) |
| 접기/펼치기 | 세로선 클릭 또는 "[+N개 답글]" 텍스트 클릭 |
| 세로선 두께 | 1px (hover 시 3px) |
| 세로선 색상 | `#94a3b8` (hover 시 `#3b82f6`) |

**관련 파일:**

| 파일 | 역할 |
|------|------|
| `v7/post/view.php` | PHP 재귀 렌더링 (HTML 트리 생성) |
| `v7/post/view.css` | 세로선/곡선/접기/반응형 CSS |
| `v7/js/comment.js` | 세로선 높이 동적 계산 + 접기/펼치기 JS |

---

## 2. 설계 원리 (CoT — 단계별 사고)

### 왜 이 구현이 어려운가?

1. **세로선 높이를 CSS만으로 계산 불가** — 부모 `.comment-node`의 `position: relative` 안에서 세로선이 절대 위치로 배치되지만, 자식 코멘트의 위치는 내용 길이에 따라 가변적이므로 CSS `bottom: 0`으로 하면 손자까지 관통한다.

2. **Web Component(`wa-avatar`) 렌더링 지연** — `wa-avatar`는 Shadow DOM으로 렌더링되므로 `DOMContentLoaded` 시점에 `getBoundingClientRect()`로 아바타 크기를 측정하면 잘못된 값이 나온다. → 고정값 기반 계산으로 해결.

3. **중첩된 재귀 트리 구조** — 깊이 제한 없는 재귀 트리에서 각 레벨마다 독립적인 세로선과 들여쓰기가 필요하다.

### 해결 전략 (단계별)

```
Step 1: PHP SSR로 재귀 트리 HTML 생성
  └─ renderCommentThread() 재귀 함수로 .comment-node 트리 생성
  └─ has-children 클래스와 .thread-line 요소를 조건부 렌더링

Step 2: CSS로 기본 레이아웃 + 곡선 연결선
  └─ .thread-line: 절대 위치, 아바타 중앙(left: 17px)
  └─ .thread-children: margin-left + padding-left로 들여쓰기
  └─ ::before 의사 요소로 모든 자식에 곡선 연결

Step 3: JS로 세로선 높이 동적 계산
  └─ adjustThreadLines(): 부모 아바타 하단 → 마지막 자식 상단까지
  └─ Web Component 렌더링 지연 대응: setTimeout + load 이벤트

Step 4: JS로 접기/펼치기 인터랙션
  └─ 세로선 클릭 → .collapsed 토글
  └─ "[+N개 답글]" 클릭 → .collapsed 제거
```

---

## 3. 문제 분해 (ToT — 트리 사고)

```
Reddit 스타일 코멘트 세로선
├── Branch A: HTML 구조
│   ├── 재귀 렌더링 함수 (PHP)
│   ├── .comment-node > .thread-line + .comment-row + .thread-children
│   └── .comment-row > .comment-avatar-col + .comment-body-col
│
├── Branch B: CSS 스타일
│   ├── .thread-line: 절대 위치, 1px, 아바타 중앙
│   ├── .thread-children: 들여쓰기 (margin + padding)
│   ├── ::before 곡선: 모든 직접 자식에 border-radius 곡선
│   ├── .collapsed: 접힌 상태 (세로선 숨김, 자식 숨김)
│   └── 반응형: 640px 이하에서 크기 축소
│
├── Branch C: JavaScript 동적 계산
│   ├── adjustThreadLines(): 세로선 top/height 계산
│   │   ├── lineTop = padding(6) + avatarSize + gap(2)
│   │   └── height = lastChild.top - nodeRect.top - lineTop
│   ├── 실행 시점: DOMContentLoaded + 200ms + load + resize
│   └── 글로벌 노출: window.adjustThreadLines
│
└── Branch D: 접기/펼치기 인터랙션
    ├── .thread-line 클릭 → .collapsed 토글
    ├── .thread-collapsed-info 클릭 → .collapsed 제거
    └── requestAnimationFrame(adjustThreadLines) 재계산
```

---

## 4. 파일 구조

```
v7/
├── post/
│   ├── view.php          ← 코멘트 HTML 재귀 렌더링 (289-363행)
│   └── view.css           ← 세로선/곡선/접기 CSS (679-846행)
└── js/
    └── comment.js         ← adjustThreadLines() + 접기/펼치기 (14-81행)
```

---

## 5. HTML 구조 — PHP 재귀 렌더링

### 5.1 코멘트 트리 맵 구성

코멘트를 `idx_parent` 기준으로 부모→자식 맵으로 구성한다 (view.php 상단):

```php
// $comments: DB에서 가져온 코멘트 배열 (idx_parent 순서로 정렬)
$childrenMap = [];
foreach ($comments as $c) {
    $parentIdx = (int)($c['idx_parent'] ?: $c['idx_root']);
    $childrenMap[$parentIdx][] = $c;
}
```

### 5.2 재귀 렌더링 함수 renderCommentThread()

> **파일**: `v7/post/view.php` (289-363행)

```php
/**
 * 코멘트 후손 수 계산 (재귀)
 */
function countDescendants(int $parentIdx, array &$childrenMap): int {
    $children = $childrenMap[$parentIdx] ?? [];
    $count = count($children);
    foreach ($children as $child) {
        $count += countDescendants((int)$child['idx'], $childrenMap);
    }
    return $count;
}

/**
 * Reddit 스타일 코멘트 스레드 재귀 렌더링
 *
 * @param array $commentArr 코멘트 데이터 배열
 * @param array $childrenMap 부모 idx → 자식 배열 맵 (참조)
 * @param int $depth 현재 깊이 (0 = 최상위 코멘트)
 */
function renderCommentThread(array $commentArr, array &$childrenMap, int $depth = 0): void {
    $c = PostEntity::fromArray($commentArr);
    $children = $childrenMap[$c->idx] ?? [];
    $hasChildren = !empty($children);
    $totalDescendants = $hasChildren ? countDescendants($c->idx, $childrenMap) : 0;

    $nodeClasses = 'comment-node';
    if ($hasChildren) $nodeClasses .= ' has-children';
    ?>
    <div class="<?= $nodeClasses ?>" data-idx="<?= $c->idx ?>" data-depth="<?= $depth ?>">
        <?php if ($hasChildren): ?>
            <div class="thread-line" title="클릭하여 스레드 접기/펼치기"></div>
        <?php endif; ?>
        <div class="comment-row">
            <!-- 아바타 컬럼 -->
            <div class="comment-avatar-col">
                <wa-avatar initials="<?= htmlspecialchars(mb_substr($c->user_name ?: '?', 0, 1)) ?>"
                           label="<?= htmlspecialchars($c->user_name ?: '익명') ?>"
                           shape="circle"></wa-avatar>
            </div>

            <!-- 코멘트 본문 -->
            <div class="comment-body-col">
                <div class="post-comment-header">
                    <strong class="comment-author"><?= htmlspecialchars($c->user_name ?: '익명') ?></strong>
                    <span class="comment-date">
                        <?php if ($c->stamp > 0): ?>
                            <wa-relative-time date="<?= date('c', $c->stamp) ?>" lang="ko"></wa-relative-time>
                        <?php endif; ?>
                    </span>
                    <?php if ($hasChildren): ?>
                        <span class="thread-collapsed-info" role="button">[+<?= $totalDescendants ?>개 답글]</span>
                    <?php else: ?>
                        <span class="thread-collapsed-info" role="button">[접힌 댓글]</span>
                    <?php endif; ?>
                </div>

                <div class="post-comment-body">
                    <?php if ($c->isBlockedOrBlinded()): ?>
                        <span class="comment-blocked"><i class="fa-solid fa-ban"></i> 차단된 댓글입니다.</span>
                    <?php else: ?>
                        <?= nl2br(htmlspecialchars($c->content ?: '')) ?>
                    <?php endif; ?>
                </div>

                <?php if (!empty($c->files) && !$c->isBlockedOrBlinded()): ?>
                    <div class="comment-files">
                        <?php foreach (explode(',', $c->files) as $cf): ?>
                            <?php $cf = trim($cf); if (empty($cf)) continue; ?>
                            <?php if (isImageUrl($cf)): ?>
                                <img src="<?= htmlspecialchars($cf) ?>" alt="" loading="lazy" class="comment-image">
                            <?php endif; ?>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>

                <div class="post-comment-actions"
                     data-idx="<?= $c->idx ?>"
                     data-idx-root="<?= $c->idx_root ?>"
                     data-depth="<?= $c->depth ?>">
                </div>
            </div>
        </div>

        <?php if ($hasChildren): ?>
            <div class="thread-children">
                <?php foreach ($children as $child):
                    renderCommentThread($child, $childrenMap, $depth + 1);
                endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
    <?php
}
```

### 5.3 렌더링된 HTML DOM 구조

```
.reddit-threads
├── .comment-node[data-depth=0].has-children     ← 부모 코멘트
│   ├── .thread-line                              ← 세로선 (절대 위치, JS가 높이 계산)
│   ├── .comment-row                              ← flex 행
│   │   ├── .comment-avatar-col                   ← 아바타 컬럼 (36px 고정)
│   │   │   └── wa-avatar                         ← Web Component 아바타
│   │   └── .comment-body-col                     ← 본문 컬럼 (flex: 1)
│   │       ├── .post-comment-header              ← 작성자 + 날짜 + [+N개 답글]
│   │       ├── .post-comment-body                ← 내용
│   │       └── .post-comment-actions             ← 답글/수정/삭제 (Vue.js 마운트)
│   └── .thread-children                          ← 자식 영역 (margin-left + padding-left)
│       ├── .comment-node[data-depth=1]::before   ← 곡선 연결선 (CSS)
│       │   ├── .comment-row
│       │   │   ├── .comment-avatar-col
│       │   │   └── .comment-body-col
│       │   └── (자식이 있으면 .thread-children 재귀)
│       └── .comment-node[data-depth=1]::before   ← 마지막 자식도 곡선
│           └── ...
└── .comment-node[data-depth=0]                   ← 자식 없는 코멘트 (세로선 없음)
    └── .comment-row
        ├── .comment-avatar-col
        └── .comment-body-col
```

**핵심 포인트:**

- `.thread-line`은 `has-children` 클래스가 있는 노드에만 렌더링
- `.thread-children` 내의 모든 `.comment-node`에 `::before` 곡선 연결선 적용
- `data-depth` 속성으로 깊이 구분 (아바타 크기 차등 적용)

---

## 6. CSS 전체 코드 — 세로선 + 곡선 연결선

> **파일**: `v7/post/view.css` (679-846행)

### 6.1 데스크탑 CSS

```css
/* ============================================
   Reddit 스타일 코멘트 스레드

   핵심: 아바타 바로 아래에서 세로선이 시작하며,
   마지막 직접 자식의 아바타 중앙까지만 세로선 표시.
   세로선 높이는 JS(adjustThreadLines)로 동적 계산.
   ============================================ */

/* 코멘트 노드: 절대위치 thread-line의 기준 */
.comment-node {
    position: relative;
}

/* 코멘트 행: avatar-col + body-col */
.comment-row {
    display: flex;
    align-items: flex-start;
    position: relative;
}

/* 최상위 코멘트 간 구분선 */
.reddit-threads > .comment-node + .comment-node {
    border-top: 1px solid var(--wa-color-neutral-200, #e2e8f0);
    margin-top: 0.25rem;
    padding-top: 0.25rem;
}

/* === 아바타 컬럼: 아바타 + 세로선 시작점 === */
.comment-avatar-col {
    width: 36px;
    flex: 0 0 36px;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding-top: 6px;
}

/* 아바타 크기 */
.comment-avatar-col wa-avatar {
    --size: 1.75rem;     /* 28px — depth >= 1 */
    font-size: 0.7rem;
}

/* 최상위 코멘트 아바타 (약간 더 크게) */
.reddit-threads > .comment-node > .comment-row > .comment-avatar-col wa-avatar {
    --size: 2rem;        /* 32px — depth == 0 */
    font-size: 0.75rem;
}

/* === 절대 위치 세로선: 아바타 바로 아래에서 시작 === */
/* height는 JS adjustThreadLines()로 동적 계산 */
.thread-line {
    position: absolute;
    left: 17px;       /* 아바타 컬럼 중앙 (36px/2 - 1px) */
    top: 40px;        /* 초기값, JS adjustThreadLines()에서 재계산 */
    width: 1px;
    background-color: #94a3b8;
    cursor: pointer;
    z-index: 10;
    transition: background-color 0.15s, width 0.15s;
}

.thread-line:hover {
    background-color: #3b82f6;
    width: 3px;
    left: 16px;       /* 중앙 유지: (3px width) → left = 17 - 1 = 16 */
}

/* 접힌 상태에서 세로선 숨김 */
.comment-node.collapsed > .thread-line {
    display: none;
}

/* === 코멘트 본문 컬럼 === */
.comment-body-col {
    flex: 1;
    min-width: 0;
    padding: 4px 0 6px 4px;
}

/* === 접힌 상태 처리 === */
.comment-node.collapsed > .comment-row .post-comment-body,
.comment-node.collapsed > .comment-row .comment-files,
.comment-node.collapsed > .comment-row .post-comment-actions,
.comment-node.collapsed > .thread-children {
    display: none;
}

/* 접힌 상태 알림 텍스트 (기본 숨김) */
.thread-collapsed-info {
    display: none;
    font-size: 0.75rem;
    color: var(--wa-color-brand-600, #2563eb);
    cursor: pointer;
    font-weight: 500;
    margin-left: 0.25rem;
}

/* 접힌 상태: "[+N개 답글]" 텍스트 표시 */
.comment-node.collapsed .thread-collapsed-info {
    display: inline;
}

/* === 자식 코멘트 영역: 아바타 중앙 기준 들여쓰기 === */
.thread-children {
    margin-left: 18px;     /* 아바타 중앙(17px)에서 1px 오른쪽 */
    padding-left: 18px;    /* 곡선 연결선 공간 확보 */
}

/* === 곡선 연결선: 모든 직접 자식에 L자 곡선 (Reddit 동일) === */
.thread-children > .comment-node::before {
    content: '';
    position: absolute;
    left: -19px;       /* 부모 세로선 위치와 정렬 */
    top: 0;
    width: 15px;
    height: 20px;      /* 아바타 중앙까지 (padding 6px + avatar/2 14px) */
    border-left: 1px solid #94a3b8;
    border-bottom: 1px solid #94a3b8;
    border-bottom-left-radius: 10px;
    border-right: none;
    border-top: none;
    z-index: 5;
}
```

### 6.2 모바일 반응형 CSS

```css
/* === 모바일 반응형 (640px 이하) === */
@media (max-width: 640px) {
    .comment-avatar-col {
        width: 30px;
        flex: 0 0 30px;
        padding-top: 4px;
    }

    .comment-avatar-col wa-avatar {
        --size: 1.5rem;      /* 24px */
        font-size: 0.65rem;
    }

    .reddit-threads > .comment-node > .comment-row > .comment-avatar-col wa-avatar {
        --size: 1.75rem;     /* 28px */
        font-size: 0.7rem;
    }

    .thread-line {
        left: 14px;          /* 30px/2 - 1px */
    }

    .thread-line:hover {
        left: 13px;
    }

    .comment-body-col {
        padding-left: 2px;
    }

    .thread-children {
        margin-left: 15px;
        padding-left: 15px;
    }

    .thread-children > .comment-node::before {
        left: -16px;
        width: 12px;
        height: 16px;
        border-bottom-left-radius: 8px;
    }
}
```

### 6.3 CSS 핵심 수치 계산 근거

#### 세로선 left 위치

```
데스크탑:
  .comment-avatar-col 너비 = 36px
  세로선 중앙 = 36px / 2 = 18px
  1px 선 보정 = 18 - 1 = 17px → left: 17px

모바일 (640px 이하):
  .comment-avatar-col 너비 = 30px
  세로선 중앙 = 30px / 2 = 15px
  1px 선 보정 = 15 - 1 = 14px → left: 14px
```

#### 들여쓰기 (thread-children)

```
데스크탑:
  margin-left: 18px  ← 세로선 중앙(17px) + 1px
  padding-left: 18px ← 곡선 연결선 너비(15px) + 여유(3px)

모바일:
  margin-left: 15px  ← 세로선 중앙(14px) + 1px
  padding-left: 15px ← 곡선 연결선 너비(12px) + 여유(3px)
```

#### 곡선 연결선 (::before)

```
데스크탑:
  left: -19px   ← -(padding-left 18px + 1px)
  width: 15px   ← 수평 길이
  height: 20px  ← padding-top(6px) + avatar(28px)/2 = 6 + 14 = 20px
  border-bottom-left-radius: 10px ← 곡선 반경

모바일:
  left: -16px
  width: 12px
  height: 16px  ← padding-top(4px) + avatar(24px)/2 = 4 + 12 = 16px
  border-bottom-left-radius: 8px
```

---

## 7. JavaScript 전체 코드 — 세로선 높이 동적 계산 + 접기/펼치기

> **파일**: `v7/js/comment.js` (14-81행)

### 7.1 adjustThreadLines() 함수

```javascript
/**
 * 세로선 높이 동적 계산: 마지막 직접 자식의 상단까지만
 *
 * 왜 JS로 계산해야 하는가?
 * - .thread-line은 .comment-node(position: relative) 내의 절대 위치 요소
 * - CSS bottom: 0으로 하면 손자/증손자까지 관통하는 문제 발생
 * - 마지막 "직접 자식"의 상단까지만 세로선을 제한해야 함
 * - 각 자식 코멘트의 내용 길이가 가변적이므로 런타임 계산 필수
 *
 * 왜 고정값으로 아바타 크기를 계산하는가?
 * - wa-avatar Web Component는 Shadow DOM으로 렌더링됨
 * - DOMContentLoaded 시점에 getBoundingClientRect()가 부정확한 값 반환
 * - data-depth 속성 기반 고정값으로 안정적 계산
 */
function adjustThreadLines() {
    document.querySelectorAll('.comment-node.has-children').forEach(function(node) {
        var threadLine = node.querySelector(':scope > .thread-line');
        if (!threadLine) return;

        // 접힌 상태면 스킵
        if (node.classList.contains('collapsed')) return;

        var threadChildren = node.querySelector(':scope > .thread-children');
        if (!threadChildren) return;

        var lastChild = threadChildren.querySelector(':scope > .comment-node:last-child');
        if (!lastChild) return;

        var nodeRect = node.getBoundingClientRect();

        // 세로선 시작: 부모 아바타 하단 (고정값 기반)
        var depth = parseInt(node.getAttribute('data-depth')) || 0;
        var avatarSize = depth === 0 ? 32 : 28; // 2rem(32px) vs 1.75rem(28px)
        var lineTop = 6 + avatarSize + 2; // padding-top(6px) + avatar + gap(2px)

        // 세로선 끝: 마지막 직접 자식의 상단까지 (곡선 ::before가 이어받음)
        var lastChildRect = lastChild.getBoundingClientRect();
        var lastChildTopY = lastChildRect.top - nodeRect.top;

        // 세로선 위치/높이 설정
        threadLine.style.top = lineTop + 'px';
        threadLine.style.height = Math.max(0, lastChildTopY - lineTop) + 'px';
    });
}

// 글로벌 노출: Vue 앱에서 코멘트 추가/삭제 시 재계산 가능
window.adjustThreadLines = adjustThreadLines;

// Web Component(wa-avatar) 렌더링 후 세로선 계산
adjustThreadLines();
setTimeout(adjustThreadLines, 200);      // Shadow DOM 렌더링 대기
window.addEventListener('load', adjustThreadLines);   // 모든 리소스 로드 후
window.addEventListener('resize', adjustThreadLines); // 뷰포트 변경 시
```

### 7.2 접기/펼치기 이벤트 핸들러

```javascript
// === Reddit 스타일 스레드 접기/펼치기 (이벤트 위임) ===
document.addEventListener('click', function (e) {
    // 세로선 클릭: 해당 스레드 접기/펼치기
    var line = e.target.closest('.thread-line');
    if (line) {
        var node = line.closest('.comment-node');
        if (node) {
            node.classList.toggle('collapsed');
            // 접기/펼치기 후 세로선 높이 재계산
            requestAnimationFrame(adjustThreadLines);
        }
        return;
    }

    // "[+N개 답글]" 클릭: 펼치기
    var collapsedInfo = e.target.closest('.thread-collapsed-info');
    if (collapsedInfo) {
        var node = collapsedInfo.closest('.comment-node');
        if (node && node.classList.contains('collapsed')) {
            node.classList.remove('collapsed');
            requestAnimationFrame(adjustThreadLines);
        }
        return;
    }
});
```

### 7.3 JS 핵심 수치 계산 근거

```
lineTop 계산:
  depth 0: lineTop = 6 + 32 + 2 = 40px
           (padding-top 6px + avatar 2rem=32px + gap 2px)
  depth 1+: lineTop = 6 + 28 + 2 = 36px
            (padding-top 6px + avatar 1.75rem=28px + gap 2px)

height 계산:
  height = lastChildRect.top - nodeRect.top - lineTop
  = 마지막 직접 자식의 상단 Y좌표 (부모 기준) - 세로선 시작 Y좌표

  주의: Math.max(0, ...) 으로 음수 방지
```

---

## 8. 접기/펼치기 동작 방식

| 상태 | 세로선 | 본문/자식 | "[+N개 답글]" |
|------|--------|-----------|-------------|
| 펼침 (기본) | 표시 | 표시 | 숨김 |
| 접힘 (`.collapsed`) | `display: none` | `display: none` | `display: inline` |

**접기 트리거:**

1. `.thread-line` 클릭 → `.comment-node.classList.toggle('collapsed')`
2. `.thread-collapsed-info` 클릭 → `.comment-node.classList.remove('collapsed')`

**접기 후 숨겨지는 요소:**

```css
.comment-node.collapsed > .comment-row .post-comment-body   { display: none; }
.comment-node.collapsed > .comment-row .comment-files        { display: none; }
.comment-node.collapsed > .comment-row .post-comment-actions { display: none; }
.comment-node.collapsed > .thread-children                   { display: none; }
.comment-node.collapsed > .thread-line                       { display: none; }
```

**접기 후 표시되는 요소:**

```css
.comment-node.collapsed .thread-collapsed-info { display: inline; }
```

---

## 9. 좌표 계산 다이어그램

```
.comment-node (position: relative)
┌─────────────────────────────────────────────────┐
│ ┌──────────┐                                     │
│ │ avatar   │  ← .comment-avatar-col (36px)       │
│ │  32px    │     padding-top: 6px                │
│ └──────────┘                                     │
│  │ ← left: 17px (세로선)                          │
│  │                                               │
│  │  lineTop = 6 + 32 + 2 = 40px ← 세로선 시작    │
│  │                                               │
│  │  .thread-line                                 │
│  │  (width: 1px, bg: #94a3b8)                    │
│  │                                               │
│  │                                               │
│  │  ← height = lastChildTopY - lineTop           │
│  │                                               │
│  ↓                                               │
│  └── lastChild.top ← 세로선 끝                    │
│                                                   │
│      .thread-children (margin-left: 18px, padding-left: 18px)
│      ┌──────────────────────────────────────┐     │
│      │ ╭── ::before 곡선                     │     │
│      │ │   (border-left + border-bottom     │     │
│      │ ╰──→ + border-bottom-left-radius)    │     │
│      │     ┌──────────┐                      │     │
│      │     │ avatar   │ ← 자식 1             │     │
│      │     └──────────┘                      │     │
│      │ ╭── ::before 곡선                     │     │
│      │ ╰──→                                  │     │
│      │     ┌──────────┐                      │     │
│      │     │ avatar   │ ← 자식 2 (마지막)    │     │
│      │     └──────────┘                      │     │
│      └──────────────────────────────────────┘     │
└─────────────────────────────────────────────────┘
```

---

## 10. 트러블슈팅 및 주의사항

### 세로선이 보이지 않는 경우

1. **JS 미실행**: `adjustThreadLines()` 호출 확인. 콘솔에서 `window.adjustThreadLines()` 직접 호출.
2. **Web Component 미렌더링**: `setTimeout(adjustThreadLines, 500)` 으로 지연 증가.
3. **height가 0**: `lastChildRect.top - nodeRect.top`이 `lineTop`보다 작으면 `Math.max(0, ...)`로 0이 됨. 자식 요소가 올바르게 렌더링되었는지 확인.

### 세로선이 손자까지 관통하는 경우

- `:scope > .thread-children > .comment-node:last-child` 선택자를 사용해야 함.
- `.querySelectorAll('.comment-node:last-child')`로 하면 모든 후손의 마지막 자식까지 선택됨.
- 반드시 `:scope >` 직접 자식 선택자 사용.

### 곡선 연결선 위치가 어긋나는 경우

- `::before`의 `left` 값이 `-(padding-left + 1px)`인지 확인.
- 부모 `.thread-children`의 `margin-left + padding-left`과 동기화 필요.

### hover 시 세로선 중앙 정렬

```
1px → left: 17px → center: 17.5px
3px → left: 16px → center: 17.5px ← 동일 중앙
```

---

## 11. 완전 복구 체크리스트

이 문서만으로 전체 기능을 100% 복구할 수 있도록, 다음 체크리스트를 따른다:

- [ ] **PHP**: `renderCommentThread()` 재귀 함수 구현 (5.2절 코드)
- [ ] **PHP**: `countDescendants()` 후손 수 계산 함수 구현 (5.2절 코드)
- [ ] **PHP**: 최상위 컨테이너에 `.reddit-threads` 클래스 적용
- [ ] **PHP**: `.comment-node`에 `data-idx`, `data-depth` 속성 필수
- [ ] **PHP**: `has-children` 클래스 + `.thread-line` 조건부 렌더링
- [ ] **PHP**: `.thread-collapsed-info`에 `[+N개 답글]` 텍스트
- [ ] **CSS**: `.thread-line` 절대 위치 (`left: 17px`, `width: 1px`, `#94a3b8`)
- [ ] **CSS**: `.thread-children` 들여쓰기 (`margin-left: 18px`, `padding-left: 18px`)
- [ ] **CSS**: `::before` 곡선 연결선 (모든 `.thread-children > .comment-node`)
- [ ] **CSS**: `.collapsed` 상태 처리 (세로선 숨김, 자식 숨김, 알림 표시)
- [ ] **CSS**: 모바일 반응형 (640px 이하)
- [ ] **JS**: `adjustThreadLines()` 함수 (세로선 top/height 동적 계산)
- [ ] **JS**: `window.adjustThreadLines` 글로벌 노출
- [ ] **JS**: 실행 시점 4가지 (즉시 + 200ms + load + resize)
- [ ] **JS**: 세로선 클릭 → `.collapsed` 토글
- [ ] **JS**: "[+N개 답글]" 클릭 → `.collapsed` 제거
- [ ] **JS**: `requestAnimationFrame(adjustThreadLines)` 재계산
