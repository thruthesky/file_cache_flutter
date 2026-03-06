# v7 폰트 로딩 및 적용

## 목차

1. [개요](#1-개요)
2. [OS별 폰트 적용 전략](#2-os별-폰트-적용-전략)
3. [CSS font-family 스택](#3-css-font-family-스택)
4. [Google Fonts 조건부 로딩](#4-google-fonts-조건부-로딩)
5. [핵심 소스코드](#5-핵심-소스코드)
6. [동작 원리](#6-동작-원리)

---

## 1. 개요

v7 홈페이지는 **OS별로 최적의 폰트를 자동 선택**하는 전략을 사용한다.

| OS | 적용 폰트 | Google Fonts 로딩 |
|----|-----------|-------------------|
| **Apple (macOS, iOS)** | `-apple-system`, `BlinkMacSystemFont` (시스템 폰트) | ❌ 로딩하지 않음 |
| **Windows** | `Noto Sans KR` (Google Fonts 웹폰트) | ✅ 로딩함 |
| **Android/Linux** | `Noto Sans KR` 또는 `Roboto` | ✅ 로딩함 |

---

## 2. OS별 폰트 적용 전략

### 핵심 아이디어

CSS `font-family` 스택에서 **Apple 전용 키워드(`-apple-system`, `BlinkMacSystemFont`)를 먼저 배치**하면,
Apple 기기는 시스템 폰트(San Francisco)를 사용하고 비-Apple 기기는 무시하고 다음 폰트(`Noto Sans KR`)를 사용한다.

### 왜 이 방식을 사용하는가

1. **Apple 시스템 폰트가 한글을 완벽 지원**: macOS/iOS는 Apple SD Gothic Neo를 포함하여 별도 웹폰트 불필요
2. **Google Fonts 로딩 절약**: Apple 기기에서 Noto Sans KR woff2 파일을 다운로드하지 않아 성능 향상
3. **JavaScript 불필요**: CSS font-family 스택 순서만으로 OS별 자동 분기 — JS 감지 코드 없음

---

## 3. CSS font-family 스택

### 파일: `v7/css/layout.css`

```css
body {
    font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', 'Segoe UI', Roboto, sans-serif;
}
```

| 순서 | 폰트 | 인식하는 OS |
|------|------|------------|
| 1 | `-apple-system` | macOS Safari, iOS Safari |
| 2 | `BlinkMacSystemFont` | macOS Chrome/Edge (Blink 엔진) |
| 3 | `Noto Sans KR` | Windows, Android, Linux (Google Fonts로 로드) |
| 4 | `Segoe UI` | Windows 시스템 폰트 (Noto Sans KR 로드 전 폴백) |
| 5 | `Roboto` | Android 시스템 폰트 |
| 6 | `sans-serif` | 최종 폴백 |

> **핵심**: `-apple-system`과 `BlinkMacSystemFont`는 **Apple 기기에서만 인식**되는 특수 키워드이다.
> 비-Apple 기기에서는 이 키워드를 무시하고 `Noto Sans KR`으로 넘어간다.

---

## 4. Google Fonts 조건부 로딩

### 파일: `v7/layout.php`

Apple 기기에서는 Google Fonts `<link>` 태그 자체를 출력하지 않아 HTTP 요청을 완전히 차단한다.

```php
<!-- Google Fonts: Apple 기기가 아닌 경우에만 Noto Sans KR 로드 -->
<?php if (!preg_match('/Mac|iPhone|iPad|iPod/', $_SERVER['HTTP_USER_AGENT'] ?? '')): ?>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@100;300;400;500;700;900&display=swap" rel="stylesheet">
<?php endif; ?>
```

### User-Agent 감지 패턴

| 패턴 | 매칭 대상 |
|------|----------|
| `Mac` | macOS (Safari, Chrome 등) |
| `iPhone` | iOS iPhone |
| `iPad` | iOS/iPadOS iPad |
| `iPod` | iPod Touch |

> **참고**: `$_SERVER['HTTP_USER_AGENT'] ?? ''`로 User-Agent 헤더가 없는 경우 빈 문자열로 처리하여
> `preg_match()` 경고를 방지한다.

---

## 5. 핵심 소스코드

### `v7/css/layout.css` (23~31행)

```css
body {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', 'Segoe UI', Roboto, sans-serif;
    font-size: 16px;
    line-height: 1.5;
    color: var(--wa-color-text, #212529);
    background-color: var(--wa-color-surface-default, #fff);
}
```

### `v7/layout.php` (62~67행)

```php
<?php if (!preg_match('/Mac|iPhone|iPad|iPod/', $_SERVER['HTTP_USER_AGENT'] ?? '')): ?>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@100;300;400;500;700;900&display=swap" rel="stylesheet">
<?php endif; ?>
```

---

## 6. 동작 원리

### Apple 기기 (macOS/iOS)

```
1. PHP: User-Agent에 "Mac"/"iPhone" 포함 → Google Fonts <link> 미출력
2. CSS: font-family에서 `-apple-system` 인식 → San Francisco 시스템 폰트 사용
3. 결과: 웹폰트 다운로드 0건, 시스템 폰트로 즉시 렌더링
```

### Windows 기기

```
1. PHP: User-Agent에 Apple 키워드 없음 → Google Fonts <link> 출력
2. CSS: font-family에서 `-apple-system` 무시 → `Noto Sans KR` 매칭
3. 브라우저: Google Fonts에서 Noto Sans KR woff2 다운로드
4. 결과: Noto Sans KR 웹폰트로 한글 렌더링
```

### `@font-face` 다운로드 최적화

브라우저는 `@font-face`로 선언된 폰트를 **실제로 사용할 때만** 다운로드한다.
Apple 기기에서 `-apple-system`이 먼저 매칭되면 `Noto Sans KR`은 사용되지 않으므로,
설령 Google Fonts `<link>`가 로드되더라도 woff2 파일은 다운로드하지 않는다.
PHP User-Agent 감지는 이중 안전장치로, `<link>` 태그 자체를 제거하여 CSS 파싱 비용까지 절약한다.
