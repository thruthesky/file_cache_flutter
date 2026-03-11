# SortableJS — v7 드래그 앤 드롭 라이브러리 레퍼런스

## 목차

- [개요](#개요)
- [프로젝트 정보](#프로젝트-정보)
- [v7 프로젝트 내 파일 위치](#v7-프로젝트-내-파일-위치)
- [v7에서의 로딩 방법](#v7에서의-로딩-방법)
- [설치 방법 (일반)](#설치-방법-일반)
- [기본 사용법](#기본-사용법)
- [전체 옵션 레퍼런스](#전체-옵션-레퍼런스)
- [전체 이벤트 레퍼런스](#전체-이벤트-레퍼런스)
- [메서드 레퍼런스](#메서드-레퍼런스)
- [Group 옵션 상세](#group-옵션-상세)
- [Filter 기능](#filter-기능)
- [Store 저장 기능](#store-저장-기능)
- [플러그인](#플러그인)
- [CSS 클래스 커스터마이징](#css-클래스-커스터마이징)
- [v7 실전 사용 패턴](#v7-실전-사용-패턴)
- [프레임워크 지원](#프레임워크-지원)
- [브라우저 지원](#브라우저-지원)

---

## 개요

**SortableJS**는 현대적 브라우저와 터치 기기를 지원하는 **재정렬 가능한 드래그 앤 드롭 리스트**를 구현하는 JavaScript 라이브러리이다. jQuery나 다른 프레임워크 의존성 없이 **순수 JavaScript**로 동작한다.

### 핵심 특징

| 특징 | 설명 |
|------|------|
| **의존성 없음** | jQuery, React 등 외부 라이브러리 불필요, 순수 JavaScript |
| **터치 기기 지원** | 모바일 터치 드래그 완벽 지원 |
| **CSS 애니메이션** | `animation` 옵션으로 부드러운 전환 효과 |
| **드래그 핸들** | `handle` 옵션으로 특정 영역에서만 드래그 가능 |
| **스마트 자동 스크롤** | 드래그 시 자동으로 스크롤 |
| **리스트 간 이동** | `group` 옵션으로 서로 다른 리스트 간 아이템 이동 |
| **아이템 복제** | `pull: 'clone'` 옵션으로 아이템 복제 |
| **다중 선택 드래그** | MultiDrag 플러그인으로 여러 아이템 동시 드래그 |
| **스왑 기능** | Swap 플러그인으로 아이템 교환 |
| **HTML5 DnD 기반** | HTML5 Drag and Drop API 활용 |
| **크기** | 약 45KB (minified) |
| **라이선스** | MIT License |

---

## 프로젝트 정보

| 항목 | 내용 |
|------|------|
| **공식 홈페이지** | https://sortablejs.github.io/Sortable/ |
| **GitHub** | https://github.com/SortableJS/Sortable |
| **GitHub 별표** | 31,000+ |
| **라이선스** | MIT |
| **최신 버전** | 1.15.x (2024년 기준) |

---

## v7 프로젝트 내 파일 위치

```
v7/etc/sortable/sortable.min.js    ← v7용 SortableJS 라이브러리 (45KB)
etc/sortable/sortable.min.js       ← v6용 SortableJS 라이브러리 (45KB, 레거시)
```

> **주의**: v7 작업 시에는 반드시 `v7/etc/sortable/sortable.min.js` 경로를 사용한다. v6의 `etc/sortable/sortable.min.js`는 레거시 경로이다.

---

## v7에서의 로딩 방법

v7에서는 `load_deferred_js()` 함수를 사용하여 SortableJS를 defer 로딩한다.

```php
<?php
// v7 페이지에서 SortableJS 로딩
load_deferred_js('/v7/etc/sortable/sortable.min.js', 0);
?>
```

> **중요**: `load_deferred_js()`는 `defer` 속성으로 스크립트를 로드하므로, SortableJS 초기화 코드는 반드시 `ready()` 함수 래퍼 안에서 실행해야 한다.

---

## 설치 방법 (일반)

### NPM

```bash
npm install sortablejs --save
```

### Bower

```bash
bower install --save sortablejs
```

### CDN

```html
<script src="https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js"></script>
```

### ES Module Import

```javascript
// 기본 Sortable (AutoScroll 플러그인만 포함)
import Sortable from 'sortablejs';

// 코어 버전 (플러그인 없음, 가장 작은 크기)
import Sortable from 'sortablejs/modular/sortable.core.esm.js';

// 완전한 버전 (모든 플러그인 포함)
import Sortable from 'sortablejs/modular/sortable.complete.esm.js';
```

### 플러그인 선택적 로드

```javascript
import Sortable, { MultiDrag, Swap } from 'sortablejs';
Sortable.mount(new MultiDrag(), new Swap());
```

> **v7에서는** CDN이나 npm 대신 로컬 파일(`v7/etc/sortable/sortable.min.js`)을 `load_deferred_js()`로 로딩한다.

---

## 기본 사용법

### HTML 구조

```html
<ul id="items">
    <li>아이템 1</li>
    <li>아이템 2</li>
    <li>아이템 3</li>
</ul>
```

> `<ul>/<li>` 뿐만 아니라 `<div>` 등 모든 HTML 요소에서 동작한다.

### JavaScript 초기화

```javascript
// 방법 1: Sortable.create()
var sortable = Sortable.create(document.getElementById('items'));

// 방법 2: new Sortable()
var sortable = new Sortable(document.getElementById('items'), {
    animation: 150,
    ghostClass: 'blue-background-class'
});
```

### 옵션을 포함한 전체 초기화 예시

```javascript
var sortable = new Sortable(document.getElementById('items'), {
    group: "shared",           // 리스트 그룹 이름
    sort: true,                // 리스트 내 정렬 허용
    delay: 0,                  // 드래그 시작까지 지연 시간(ms)
    delayOnTouchOnly: false,   // 터치에서만 지연 적용
    touchStartThreshold: 0,    // 지연 시 포인터 이동 허용 거리(px)
    disabled: false,           // Sortable 비활성화
    animation: 150,            // 애니메이션 속도(ms), 0이면 비활성화
    easing: "cubic-bezier(1, 0, 0, 1)", // 애니메이션 easing
    handle: ".my-handle",      // 드래그 핸들 선택자
    filter: ".ignore-elements", // 드래그 불가 요소 선택자
    preventOnFilter: true,     // 필터 시 기본 동작 방지
    draggable: ".item",        // 드래그 가능한 아이템 선택자
    dataIdAttr: 'data-id',     // toArray()에서 사용할 속성
    ghostClass: "sortable-ghost",   // 드롭 플레이스홀더 CSS 클래스
    chosenClass: "sortable-chosen", // 선택된 아이템 CSS 클래스
    dragClass: "sortable-drag",     // 드래그 중 아이템 CSS 클래스
    swapThreshold: 1,          // 스왑 영역 임계값 (0~1)
    invertSwap: false,         // 역방향 스왑 영역
    invertedSwapThreshold: 1,  // 역방향 스왑 임계값
    direction: 'vertical',     // 정렬 방향: 'vertical' | 'horizontal'
    forceFallback: false,      // HTML5 DnD 대신 폴백 사용
    fallbackClass: "sortable-fallback", // 폴백 클론 CSS 클래스
    fallbackOnBody: false,     // 클론을 document.body에 추가
    fallbackTolerance: 0,      // 드래그 인식 최소 이동 거리(px)
    dragoverBubble: false,     // dragover 이벤트 버블링
    removeCloneOnHide: true,   // 클론 숨김 대신 제거
    emptyInsertThreshold: 5,   // 빈 Sortable에 삽입 가능 마우스 거리(px)

    // 이벤트 핸들러
    onChoose: function(evt) { },
    onUnchoose: function(evt) { },
    onStart: function(evt) { },
    onEnd: function(evt) { },
    onAdd: function(evt) { },
    onUpdate: function(evt) { },
    onSort: function(evt) { },
    onRemove: function(evt) { },
    onFilter: function(evt) { },
    onMove: function(evt, originalEvent) { },
    onClone: function(evt) { },
    onChange: function(evt) { },

    // setData 콜백
    setData: function(dataTransfer, dragEl) {
        dataTransfer.setData('Text', dragEl.textContent);
    }
});
```

---

## 전체 옵션 레퍼런스

### 기본 옵션

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `group` | `String \| Object` | `null` | 리스트 그룹 이름. 동일 그룹 간 아이템 이동 허용. 객체로 세부 설정 가능 |
| `sort` | `Boolean` | `true` | 리스트 내 정렬 허용 여부. `false`로 설정하면 정렬 비활성화 |
| `delay` | `Number` | `0` | 드래그 시작까지의 지연 시간(ms). 클릭과 드래그를 구분할 때 사용 |
| `delayOnTouchOnly` | `Boolean` | `false` | `true`이면 터치 이벤트에서만 `delay` 적용. 데스크톱은 즉시 드래그 |
| `touchStartThreshold` | `Number` | `0` | `delay` 중 드래그 취소 없이 허용되는 포인터 이동 거리(px) |
| `disabled` | `Boolean` | `false` | `true`이면 Sortable 완전 비활성화 |
| `animation` | `Number` | `0` | 정렬 애니메이션 시간(ms). `150`이 권장값. `0`이면 비활성화 |
| `easing` | `String` | `null` | CSS easing 함수. 예: `"cubic-bezier(1, 0, 0, 1)"` |

### 드래그 대상 옵션

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `handle` | `String` | `null` | 드래그 핸들 CSS 선택자. 해당 요소를 잡아야만 드래그 시작 |
| `filter` | `String \| Function` | `null` | 드래그 불가능한 요소 CSS 선택자 또는 함수 |
| `preventOnFilter` | `Boolean` | `true` | 필터된 요소에서 기본 이벤트(`event.preventDefault()`) 방지 |
| `draggable` | `String` | `>*` (자식 전체) | 드래그 가능한 아이템 CSS 선택자 |

### 외관 옵션

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `ghostClass` | `String` | `"sortable-ghost"` | 드롭 위치 표시(플레이스홀더) CSS 클래스 |
| `chosenClass` | `String` | `"sortable-chosen"` | 현재 선택(클릭)된 아이템 CSS 클래스 |
| `dragClass` | `String` | `"sortable-drag"` | 드래그 중인 아이템 CSS 클래스 |
| `fallbackClass` | `String` | `"sortable-fallback"` | 폴백 모드 시 클론 요소 CSS 클래스 |

### 스왑/정렬 옵션

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `swapThreshold` | `Number` | `1` | 스왑 영역 비율(0~1). 낮을수록 대상 요소의 중심에 가까워야 스왑 |
| `invertSwap` | `Boolean` | `false` | `true`이면 스왑 영역을 대상 요소의 양쪽 측면으로 설정 |
| `invertedSwapThreshold` | `Number` | `swapThreshold` 값 | 역방향 스왑 영역 비율 |
| `direction` | `String \| Function` | 자동 감지 | 정렬 방향: `'vertical'`, `'horizontal'`, 또는 함수 |

### 폴백/고급 옵션

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `forceFallback` | `Boolean` | `false` | HTML5 DnD를 무시하고 폴백(JS 기반) 사용. 터치에서 유용 |
| `fallbackOnBody` | `Boolean` | `false` | 클론 요소를 `document.body`에 추가. 중첩 Sortable에서 유용 |
| `fallbackTolerance` | `Number` | `0` | 드래그로 인식하기 위한 최소 마우스 이동 거리(px) |
| `dragoverBubble` | `Boolean` | `false` | `dragover` 이벤트 버블링 허용 |
| `removeCloneOnHide` | `Boolean` | `true` | 클론 요소 숨기지 않고 DOM에서 제거 |
| `emptyInsertThreshold` | `Number` | `5` | 빈 Sortable에 아이템 삽입 시 마우스 감지 거리(px) |

### 데이터 옵션

| 옵션 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `dataIdAttr` | `String` | `'data-id'` | `toArray()` 메서드에서 순서 추출에 사용할 HTML 속성명 |
| `store` | `Object` | `null` | 순서 저장/복원 설정. `get()`과 `set()` 메서드를 가진 객체 |

### setData 콜백

```javascript
setData: function(dataTransfer, dragEl) {
    dataTransfer.setData('Text', dragEl.textContent);
}
```

HTML5 DnD의 `dataTransfer` 객체에 데이터를 설정하는 콜백. 브라우저 간 드래그 앤 드롭 시 데이터 전달에 사용.

---

## 전체 이벤트 레퍼런스

### onChoose — 요소 선택 시

아이템을 클릭(터치)하여 선택했을 때 발생. 드래그 시작 전.

```javascript
onChoose: function(evt) {
    evt.oldIndex;  // 부모 컨테이너 내 요소 인덱스
}
```

### onUnchoose — 요소 선택 해제 시

선택된 아이템이 해제될 때 발생.

```javascript
onUnchoose: function(evt) {
    // onEnd와 동일한 속성 사용 가능
}
```

### onStart — 드래그 시작 시

아이템 드래그가 실제로 시작될 때 발생.

```javascript
onStart: function(evt) {
    evt.oldIndex;  // 부모 컨테이너 내 시작 인덱스
}
```

### onEnd — 드래그 종료 시 (가장 많이 사용)

드래그가 완료될 때 발생. **가장 많이 사용하는 이벤트**.

```javascript
onEnd: function(evt) {
    var itemEl = evt.item;            // 드래그된 HTMLElement
    evt.to;                           // 대상(이동된) 리스트 컨테이너
    evt.from;                         // 원래(출발) 리스트 컨테이너
    evt.oldIndex;                     // 원래 리스트에서의 인덱스
    evt.newIndex;                     // 새 리스트에서의 인덱스
    evt.oldDraggableIndex;            // 드래그 가능한 요소만 계산한 이전 인덱스
    evt.newDraggableIndex;            // 드래그 가능한 요소만 계산한 새 인덱스
    evt.clone;                        // 클론 요소 (clone 모드 시)
    evt.pullMode;                     // "clone" 또는 true/false
}
```

### onAdd — 다른 리스트에서 추가 시

다른 리스트에서 현재 리스트로 아이템이 추가될 때 발생.

```javascript
onAdd: function(evt) {
    var itemEl = evt.item;   // 추가된 HTMLElement
    evt.from;                // 출발 리스트
    evt.oldIndex;            // 출발 리스트에서의 인덱스
    evt.newIndex;            // 현재 리스트에서의 인덱스
}
```

### onUpdate — 리스트 내 순서 변경 시

같은 리스트 안에서 아이템 순서가 변경될 때 발생.

```javascript
onUpdate: function(evt) {
    var itemEl = evt.item;
    evt.oldIndex;
    evt.newIndex;
}
```

### onSort — 정렬 발생 시

`onAdd`, `onUpdate`, `onRemove` 이벤트 발생 시 함께 호출.

```javascript
onSort: function(evt) {
    // onEnd와 동일한 속성
}
```

### onRemove — 다른 리스트로 제거 시

현재 리스트에서 아이템이 다른 리스트로 이동되어 제거될 때 발생.

```javascript
onRemove: function(evt) {
    var itemEl = evt.item;
    evt.to;        // 이동된 대상 리스트
}
```

### onFilter — 필터된 요소 클릭 시

`filter` 옵션에 해당하는(드래그 불가) 요소를 클릭/터치할 때 발생.

```javascript
onFilter: function(evt) {
    var itemEl = evt.item;  // 클릭된 필터 요소
}
```

### onMove — 아이템 이동 중 (실시간)

드래그 중 아이템이 다른 위치로 이동할 때 **실시간으로** 발생. `false` 반환 시 이동 취소.

```javascript
onMove: function(evt, originalEvent) {
    evt.dragged;           // 드래그 중인 HTMLElement
    evt.draggedRect;       // DOMRect {left, top, right, bottom}
    evt.related;           // 현재 위치 기준 대상 HTMLElement
    evt.relatedRect;       // 대상의 DOMRect
    evt.willInsertAfter;   // 기본적으로 대상 뒤에 삽입할지 여부 (Boolean)
    originalEvent.clientY; // 마우스 Y 좌표

    // 반환값:
    // return false;  → 이동 취소
    // return -1;     → 대상 요소 앞에 삽입
    // return 1;      → 대상 요소 뒤에 삽입
    // return void;   → 기본 동작 (willInsertAfter에 따름)
}
```

### onClone — 클론 생성 시

`pull: 'clone'` 모드에서 아이템이 복제될 때 발생.

```javascript
onClone: function(evt) {
    var origEl = evt.item;   // 원본 요소
    var cloneEl = evt.clone; // 복제된 요소
}
```

### onChange — 드래그 중 위치 변경 시

드래그 중 아이템의 위치가 변경될 때 발생.

```javascript
onChange: function(evt) {
    evt.newIndex;  // 현재 드래그 중인 요소의 인덱스
}
```

---

## 메서드 레퍼런스

### option(name, [value]) — 옵션 조회/설정

```javascript
var sortable = Sortable.create(el);

// 옵션 조회
var isDisabled = sortable.option("disabled");  // false

// 옵션 설정
sortable.option("disabled", true);
```

### toArray() — 순서를 배열로 반환

`dataIdAttr` 속성(기본: `data-id`)을 기반으로 현재 순서를 문자열 배열로 반환.

```html
<ul id="items">
    <li data-id="1">아이템 1</li>
    <li data-id="2">아이템 2</li>
    <li data-id="3">아이템 3</li>
</ul>
```

```javascript
var sortable = Sortable.create(el, { dataIdAttr: 'data-id' });
sortable.toArray();  // ["1", "2", "3"]
```

### sort(order, useAnimation) — 배열로 순서 적용

```javascript
sortable.sort(["3", "1", "2"]);        // 애니메이션 없이 순서 적용
sortable.sort(["3", "1", "2"], true);   // 애니메이션과 함께 순서 적용
```

### save() — 저장

`store` 옵션이 설정된 경우 현재 순서를 저장.

```javascript
sortable.save();
```

### destroy() — 인스턴스 제거

Sortable 인스턴스를 완전히 제거. 이벤트 리스너 해제.

```javascript
sortable.destroy();
```

### closest(el, selector) — 가장 가까운 조상 요소 검색

```javascript
sortable.closest(evt.target, '.sortable-item');
```

### Sortable.get(element) — 요소에 연결된 Sortable 인스턴스 반환

```javascript
var sortable = Sortable.get(document.getElementById('items'));
```

### Sortable.utils

```javascript
Sortable.utils.is(el, selector);       // 요소가 선택자와 매칭되는지 확인
Sortable.utils.find(ctx, tagName, iterator); // 요소 검색
Sortable.utils.closest(el, selector);  // 가장 가까운 조상 요소
Sortable.utils.on(el, event, fn);      // 이벤트 리스너 추가
Sortable.utils.off(el, event, fn);     // 이벤트 리스너 제거
Sortable.utils.css(el, prop, value);   // CSS 속성 설정
Sortable.utils.toggleClass(el, name, state); // 클래스 토글
```

---

## Group 옵션 상세

`group` 옵션은 서로 다른 리스트 간 아이템 이동을 제어한다.

### 단순 문자열 (동일 이름끼리 이동 허용)

```javascript
// 리스트 A와 B 간 자유롭게 이동 가능
Sortable.create(listA, { group: "shared" });
Sortable.create(listB, { group: "shared" });
```

### 객체 형태 (세부 제어)

```javascript
Sortable.create(el, {
    group: {
        name: "shared",
        pull: true,            // 이 리스트에서 아이템을 빼낼 수 있는지
        put: true,             // 다른 리스트에서 아이템을 받을 수 있는지
        revertClone: false     // 이동 후 클론을 원래 위치로 되돌리는지
    }
});
```

### pull 옵션 상세

| 값 | 설명 |
|----|------|
| `true` | 아이템을 빼낼 수 있음 (기본값) |
| `false` | 아이템을 빼낼 수 없음 |
| `'clone'` | 아이템을 **복제**하여 전달 (원본 유지) |
| `["foo", "bar"]` | 지정된 그룹에만 아이템 전달 허용 |
| `function(to, from, dragEl, evt)` | 동적으로 결정하는 함수 |

### put 옵션 상세

| 값 | 설명 |
|----|------|
| `true` | 다른 리스트에서 아이템을 받을 수 있음 (기본값) |
| `false` | 아이템을 받지 않음 |
| `["baz", "qux"]` | 지정된 그룹에서만 아이템 수락 |
| `function(to, from, dragEl, evt)` | 동적으로 결정하는 함수 |

### 사용 예: 복제 전용 소스 리스트

```javascript
// 소스 리스트 (복제만 가능, 수신 불가, 정렬 불가)
Sortable.create(sourceList, {
    group: {
        name: 'shared',
        pull: 'clone',  // 복제하여 전달
        put: false       // 다른 리스트에서 받지 않음
    },
    sort: false          // 리스트 내 정렬 비활성화
});

// 타겟 리스트 (수신 가능)
Sortable.create(targetList, {
    group: {
        name: 'shared',
        put: true
    }
});
```

---

## Filter 기능

특정 요소를 드래그에서 제외한다.

### CSS 선택자 방식

```javascript
Sortable.create(el, {
    filter: ".ignore-elements",   // 이 클래스를 가진 요소는 드래그 불가
    preventOnFilter: true         // 필터된 요소에서 기본 이벤트 방지
});
```

### 함수 방식

```javascript
Sortable.create(el, {
    filter: function(evt, target, sortable) {
        return target.classList.contains('no-drag');
    }
});
```

### 여러 선택자 조합

```javascript
Sortable.create(el, {
    filter: ".ignore-elements, .static-item, .header"
});
```

---

## Store 저장 기능

아이템 순서를 자동으로 저장하고 복원한다.

### localStorage 저장 예시

```javascript
Sortable.create(el, {
    group: "localStorage-example",
    store: {
        /**
         * Sortable 초기화 시 호출되어 저장된 순서를 반환한다.
         * @param {Sortable} sortable - Sortable 인스턴스
         * @return {String[]} 저장된 순서 배열
         */
        get: function(sortable) {
            var order = localStorage.getItem(sortable.options.group.name);
            return order ? order.split('|') : [];
        },

        /**
         * 순서가 변경될 때마다 호출되어 새 순서를 저장한다.
         * @param {Sortable} sortable - Sortable 인스턴스
         */
        set: function(sortable) {
            var order = sortable.toArray();
            localStorage.setItem(sortable.options.group.name, order.join('|'));
        }
    }
});
```

---

## 플러그인

### MultiDrag — 다중 선택 드래그

여러 아이템을 동시에 선택하고 드래그할 수 있다.

```javascript
// 플러그인 마운트 (모듈 사용 시)
import Sortable, { MultiDrag } from 'sortablejs';
Sortable.mount(new MultiDrag());

// 사용
Sortable.create(el, {
    multiDrag: true,                 // 다중 드래그 활성화
    selectedClass: 'selected',       // 선택된 아이템 CSS 클래스
    fallbackTolerance: 3,            // 클릭과 드래그 구분 허용 거리
    animation: 150
});
```

- Ctrl/Cmd 클릭으로 여러 아이템 선택
- 선택된 아이템들을 한꺼번에 드래그

### Swap — 아이템 교환

아이템을 다른 아이템 위치로 교환(스왑)한다.

```javascript
// 플러그인 마운트 (모듈 사용 시)
import Sortable, { Swap } from 'sortablejs';
Sortable.mount(new Swap());

// 사용
Sortable.create(el, {
    swap: true,                      // 스왑 모드 활성화
    swapClass: 'highlight',          // 스왑 대상 하이라이트 CSS 클래스
    animation: 150
});
```

### AutoScroll — 자동 스크롤

드래그 시 컨테이너 경계에 도달하면 자동으로 스크롤한다. 기본 Sortable 빌드에 포함되어 있다.

```javascript
// 코어 버전 사용 시 별도 마운트 필요
import Sortable, { AutoScroll } from 'sortablejs/modular/sortable.core.esm.js';
Sortable.mount(new AutoScroll());
```

---

## CSS 클래스 커스터마이징

### 기본 CSS 클래스

```css
/* 드롭 위치 표시 (고스트) */
.sortable-ghost {
    opacity: 0.4;
    background-color: #c8ebfb;
}

/* 선택된(클릭된) 아이템 */
.sortable-chosen {
    background-color: #f0f0f0;
}

/* 드래그 중인 아이템 */
.sortable-drag {
    opacity: 0.8;
}

/* MultiDrag 선택된 아이템 */
.selected {
    background-color: #f9c7c8;
    border: 1px solid #e57373;
}

/* Swap 대상 하이라이트 */
.highlight {
    background-color: #ffe082;
}
```

### v7에서 Web Awesome과 함께 사용 시

```css
/* Web Awesome 스타일과 조화되는 SortableJS 스타일 */
.sortable-ghost {
    opacity: 0.4;
    background: var(--wa-color-primary-100);
    border-radius: var(--wa-border-radius-medium);
}

.sortable-chosen {
    box-shadow: var(--wa-shadow-medium);
}
```

---

## v7 실전 사용 패턴

### 패턴 1: 기본 리스트 순서 변경 + API 저장

v7에서 가장 일반적인 사용 패턴. 리스트 순서를 변경하고 `func()` API로 서버에 저장.

```php
<?php
// PHP 파일 하단에서 SortableJS 로딩
load_deferred_js('/v7/etc/sortable/sortable.min.js', 0);
?>

<!-- HTML 구조 -->
<ul id="sortable-list" class="list-group">
    <?php foreach ($items as $item): ?>
        <li class="list-group-item d-flex gap-2 align-items-center"
            data-id="<?= $item['idx'] ?>"
            style="cursor: move;">
            <i class="fa-solid fa-bars"></i>
            <span><?= htmlspecialchars($item['title']) ?></span>
        </li>
    <?php endforeach; ?>
</ul>

<script>
ready(function() {
    const sortable = new Sortable(document.getElementById('sortable-list'), {
        animation: 150,
        handle: '.fa-bars',    // 핸들 아이콘에서만 드래그 가능
        ghostClass: 'sortable-ghost',
        onEnd: async function(evt) {
            // 변경된 순서를 배열로 추출
            const order = sortable.toArray();
            console.log('새 순서:', order);

            // v7 API 호출로 서버에 순서 저장
            const re = await func("update_order", {
                order: order
            }, {
                alert_on_error: true
            });

            if (re.error) {
                console.error('순서 저장 실패:', re.error);
            }
        }
    });
});
</script>
```

### 패턴 2: 패밀리사이트 섹션 순서 변경 (v6 실제 코드 참고)

v6 `tmp/tmp-family-site/family-site-floating-button.php`에서 실제 사용 중인 패턴.

```php
<?php
load_deferred_js('/v7/etc/sortable/sortable.min.js', 0);
?>

<ul id="sortable" class="list-group bg-secondary-subtle">
    <?php for ($i = 1; $i <= 9; $i++) : ?>
        <li class="py-1 px-2 d-flex gap-2 align-items-center"
            id="section-<?= $i ?>"
            style="cursor: move;">
            <i class="fa-solid fa-bars"></i>
            <select class="form-select-sm section-select"
                    name="section_<?= $i ?>"
                    id="section-<?= $i ?>">
                <option value="">섹션 선택</option>
                <!-- 옵션 목록 -->
            </select>
        </li>
    <?php endfor; ?>
</ul>

<script>
ready(function() {
    const sortable = new Sortable(document.getElementById('sortable'), {
        animation: 150,
        onEnd: async function() {
            let updatedSections = {};

            // 새 순서에 따라 섹션 데이터 수집
            $("#sortable li").each(function(index) {
                let sectionName = "section_" + (index + 1);
                let sectionValue = $(this).find("select").val();
                updatedSections[sectionName] = sectionValue;
            });

            console.log("Updated sections:", updatedSections);

            // API 호출로 서버에 저장
            const re = await func("family-site.update", updatedSections, {
                alert_on_error: true
            });

            // 페이지 새로고침으로 변경 사항 반영
            location.href = "/?openLayoutUpdate=y";
        }
    });
});
</script>
```

### 패턴 3: 드래그 핸들 + 필터

특정 영역에서만 드래그 가능하고, 특정 요소는 드래그에서 제외.

```html
<ul id="handle-list">
    <li>
        <span class="handle"><i class="fa-solid fa-grip-vertical"></i></span>
        <span class="text">드래그 가능 아이템</span>
    </li>
    <li class="filtered">
        <span class="text">드래그 불가 아이템 (고정)</span>
    </li>
</ul>

<script>
ready(function() {
    new Sortable(document.getElementById('handle-list'), {
        handle: '.handle',       // .handle 요소에서만 드래그 시작
        filter: '.filtered',     // .filtered 요소는 드래그 불가
        animation: 150,
        ghostClass: 'sortable-ghost'
    });
});
</script>
```

### 패턴 4: 두 리스트 간 아이템 이동

```html
<div class="row">
    <div class="col">
        <h5>사용 가능</h5>
        <ul id="available-list" class="list-group"></ul>
    </div>
    <div class="col">
        <h5>선택됨</h5>
        <ul id="selected-list" class="list-group"></ul>
    </div>
</div>

<script>
ready(function() {
    // 두 리스트 모두 같은 group 이름 사용
    new Sortable(document.getElementById('available-list'), {
        group: 'shared',
        animation: 150
    });

    new Sortable(document.getElementById('selected-list'), {
        group: 'shared',
        animation: 150,
        onAdd: function(evt) {
            console.log('아이템 추가됨:', evt.item.textContent);
        },
        onRemove: function(evt) {
            console.log('아이템 제거됨:', evt.item.textContent);
        }
    });
});
</script>
```

### 패턴 5: 중첩(Nested) Sortable

```html
<div id="nested-demo">
    <div class="group-item">
        그룹 1
        <div class="nested-sortable">
            <div class="nested-item">아이템 1-1</div>
            <div class="nested-item">아이템 1-2</div>
        </div>
    </div>
    <div class="group-item">
        그룹 2
        <div class="nested-sortable">
            <div class="nested-item">아이템 2-1</div>
            <div class="nested-item">아이템 2-2</div>
        </div>
    </div>
</div>

<script>
ready(function() {
    // 모든 중첩 Sortable 초기화
    var nestedSortables = document.querySelectorAll('.nested-sortable');
    for (var i = 0; i < nestedSortables.length; i++) {
        new Sortable(nestedSortables[i], {
            group: 'nested',
            animation: 150,
            fallbackOnBody: true,     // 중첩 시 필수
            swapThreshold: 0.65       // 중첩 시 권장 임계값
        });
    }
});
</script>
```

---

## 프레임워크 지원

| 프레임워크 | 라이브러리 | GitHub |
|-----------|-----------|--------|
| **Vue.js** | Vue.Draggable | SortableJS/Vue.Draggable |
| **React** | react-sortablejs | SortableJS/react-sortablejs |
| **Angular** | ngx-sortablejs | SortableJS/angular-sortablejs |
| **jQuery** | jquery-sortablejs | SortableJS/jquery-sortablejs |
| **Knockout** | knockout-sortablejs | SortableJS/knockout-sortablejs |
| **Meteor** | meteor-sortablejs | SortableJS/meteor-sortablejs |
| **Polymer** | polymer-sortablejs | SortableJS/polymer-sortablejs |
| **Ember** | ember-sortablejs | SortableJS/ember-sortablejs |

> **v7에서는** 프레임워크 래퍼 없이 순수 SortableJS를 직접 사용한다. Vue.js CDN 환경에서는 Vue.Draggable 대신 `new Sortable()`을 직접 호출한다.

---

## 브라우저 지원

| 브라우저 | 지원 |
|---------|------|
| Chrome | ✅ |
| Firefox | ✅ |
| Safari | ✅ |
| Edge | ✅ |
| IE 9+ | ✅ (레거시) |
| iOS Safari | ✅ (터치) |
| Android Chrome | ✅ (터치) |

> **TypeScript 지원**: `npm install --save @types/sortablejs`로 타입 정의 설치 가능.
