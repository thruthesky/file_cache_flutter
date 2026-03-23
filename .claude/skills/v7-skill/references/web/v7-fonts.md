# v7 폰트 로딩 및 적용

## 목차

1. [개요](#1-개요)
2. [폰트 적용 전략](#2-폰트-적용-전략)
3. [CSS font-family 스택](#3-css-font-family-스택)
4. [Google Fonts 로딩](#4-google-fonts-로딩)
5. [핵심 소스코드](#5-핵심-소스코드)

---

## 1. 개요

v7 홈페이지는 **모든 OS에서 Noto Sans KR** 웹폰트를 사용한다.

| OS | 적용 폰트 | Google Fonts 로딩 |
|----|-----------|-------------------|
| **Apple (macOS, iOS)** | `Noto Sans KR` (Google Fonts 웹폰트) | ✅ 로딩함 |
| **Windows** | `Noto Sans KR` (Google Fonts 웹폰트) | ✅ 로딩함 |
| **Android/Linux** | `Noto Sans KR` (Google Fonts 웹폰트) | ✅ 로딩함 |

---

## 2. 폰트 적용 전략

### 핵심 아이디어

**모든 기기에서 동일한 Noto Sans KR 웹폰트를 사용**하여 크로스 플랫폼 일관성을 보장한다.
CSS `font-family` 스택에서 `'Noto Sans KR'`을 최우선으로 배치하고, 나머지는 폴백용으로 둔다.

### 왜 이 방식을 사용하는가

1. **일관된 렌더링**: Mac, Windows, Android 어디서든 동일한 글꼴로 표시
2. **디자인 통일성**: OS별 시스템 폰트 차이로 인한 레이아웃 깨짐 방지
3. **단순한 구현**: 조건 분기 없이 모든 기기에 Google Fonts 로드

---

## 3. CSS font-family 스택

### 파일: `v7/css/layout.css`

```css
body {
    font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
```

| 순서 | 폰트 | 역할 |
|------|------|------|
| 1 | `Noto Sans KR` | **주 폰트** — 모든 OS에서 사용 (Google Fonts 웹폰트) |
| 2 | `-apple-system` | 폴백 — Noto Sans KR 로드 실패 시 Apple 시스템 폰트 |
| 3 | `BlinkMacSystemFont` | 폴백 — macOS Chrome/Edge (Blink 엔진) |
| 4 | `Segoe UI` | 폴백 — Windows 시스템 폰트 |
| 5 | `Roboto` | 폴백 — Android 시스템 폰트 |
| 6 | `sans-serif` | 최종 폴백 |

> **핵심**: `Noto Sans KR`이 최우선이므로 모든 기기에서 웹폰트가 로드되면 동일하게 표시된다.
> 나머지 폰트는 네트워크 장애 등으로 웹폰트 로드에 실패했을 때의 폴백이다.

---

## 4. Google Fonts 로딩

### 파일: `v7/layout.php`

모든 기기에서 조건 없이 Google Fonts를 로드한다.

```php
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@100;300;400;500;700;900&display=swap" rel="stylesheet">
```

### 로드하는 폰트 굵기

| 굵기 | 용도 |
|------|------|
| 100 (Thin) | 장식용 |
| 300 (Light) | 보조 텍스트 |
| 400 (Regular) | 본문 기본 |
| 500 (Medium) | 강조 텍스트 |
| 700 (Bold) | 제목, 버튼 |
| 900 (Black) | 대제목, 히어로 |

---

## 5. 핵심 소스코드

### `v7/css/layout.css` (23~31행)

```css
body {
    margin: 0;
    padding: 0;
    font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    font-size: 16px;
    line-height: 1.5;
    color: var(--wa-color-text, #212529);
    background-color: var(--wa-color-surface-default, #fff);
}
```

### `v7/layout.php` (63~67행)

```php
<!-- Google Fonts: 모든 기기에서 Noto Sans KR 로드 -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@100;300;400;500;700;900&display=swap" rel="stylesheet">
```
