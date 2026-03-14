# 필고 v7 웹 홈페이지 개발 개요

## 목차

1. [개요](#1-개요)
2. [아키텍처](#2-아키텍처)
3. [접속 URL 및 도메인 설정](#3-접속-url-및-도메인-설정)
4. [SSL 인증서 (mkcert)](#4-ssl-인증서-mkcert)
5. [Docker / Nginx 설정](#5-docker--nginx-설정)
6. [프론트 컨트롤러 (v7.php)](#6-프론트-컨트롤러-v7php)
7. [v7/ 폴더 구조](#7-v7-폴더-구조)
8. [UI 컴포넌트 (Web Awesome Pro)](#8-ui-컴포넌트-web-awesome-pro)
9. [아이콘 (Font Awesome 7.2.0)](#9-아이콘-font-awesome-720)
10. [Vue.js CDN 연동](#10-vuejs-cdn-연동)
11. [기존 v7 API 연동](#11-기존-v7-api-연동)
12. [SSR/SEO 전략](#12-ssrseo-전략)
13. [페이지 개발 가이드](#13-페이지-개발-가이드) (페이지별 CSS 파일 분리 규칙 포함)
14. [CSS/JS 캐시 버스팅 (CACHE_VERSION)](#14-cssjs-캐시-버스팅-cache_version)
15. [개발 환경 설정 절차](#15-개발-환경-설정-절차)
16. [개발 환경 테스트 로그인](#16-개발-환경-테스트-로그인)
17. [URL 유틸리티 (url() 함수)](#17-url-유틸리티-url-함수)
18. [게시판 목록 페이지 (v7/post/list.php)](#18-게시판-목록-페이지-v7postlistphp)
19. [게시판 글 읽기 페이지 (v7/post/view.php)](#19-게시판-글-읽기-페이지-v7postviewphp)
20. [전체 메뉴 페이지 (v7/menu/index.php)](#20-전체-메뉴-페이지-v7menuindexphp)

---

## 1. 개요

필고 v7 웹 홈페이지는 **기존 v7 API(Controller/Service/Entity)를 그대로 활용**하면서,
웹 브라우저에 표시되는 **뷰(View) 레이어만 완전히 새로 작성**하는 프로젝트이다.

| 항목 | 내용 |
|------|------|
| **프로젝트 목표** | v7 시스템 기반 새 웹 프론트엔드 구축 |
| **진입점** | `v7.php` (프론트 컨트롤러) |
| **뷰 폴더** | `./v7/` (모든 웹 뷰 파일 저장) |
| **접속 도메인** | `https://v7-local.philgo.com` (개발) |
| **UI 라이브러리** | Web Awesome Pro (v7/etc/dist-cdn/) |
| **JavaScript** | Vue.js 3 CDN + Options API |
| **백엔드 API** | 기존 v7 API (`/api.php`, Controller/Service) 재활용 |
| **렌더링** | SSR(게시판 목록/글 읽기) + CSR(나머지 Vue.js 동적 로드) |

### 핵심 원칙

- **기존 v7 API 코드 수정 없음**: `api.php`, Controller, Service, Repository, Entity 그대로 사용
- **웹 뷰만 새로 작성**: `./v7/` 폴더에 PHP, CSS, JS, 이미지 등 모든 프론트엔드 파일 저장
- **기존 레거시(v6) 웹사이트와 공존**: `local.philgo.com`(v6)과 `v7-local.philgo.com`(v7) 동시 운영
- **v6 코드 사용 금지**: v7 전용 `v7/boot.php`만 사용. v6 `boot.php`, `page.header.php`, `widget/`, `pdo()`, `login()`, `t()` 등 v6 코드는 일체 사용하지 않는다

---

## 2. 아키텍처

```
브라우저 (https://v7-local.philgo.com/user/login)
    │
    ▼
Docker Nginx (v7-local.philgo.com server block)
    │
    ├─ 정적 파일 존재? → 직접 서빙 (CSS, JS, 이미지 등)
    │
    └─ 파일 없음? → /v7.php로 내부 rewrite
                        │
                        ├─ v7/boot.php (v7 전용 부팅: PSR-4 오토로더 + 설정 상수)
                        ├─ URL 파싱: /user/login
                        └─ include ./v7/user/login.php
                                    │
                                    ├─ Web Awesome Pro UI
                                    ├─ Vue.js CDN (동적 데이터)
                                    └─ v7 API 호출 (/api.php)
```

### 요청 흐름 상세

1. 브라우저가 `https://v7-local.philgo.com/user/login` 접속
2. Nginx `v7-local.philgo.com` server block에서 처리
3. `index v7.php` + `try_files $uri /v7.php?$query_string`
   - `/` 요청 시 `index` 지시어에 의해 `v7.php` 실행
   - `/user/login` 등 파일이 존재하지 않는 경로 → `/v7.php`로 내부 rewrite
4. `v7.php`에서 URL 경로 `/user/login` 파싱
5. `./v7/user/login.php` 파일 존재 확인 후 include
6. 해당 PHP 파일이 HTML 출력 (Web Awesome + Vue.js)

### 정적 파일 서빙

- `/v7/etc/dist-cdn/styles/webawesome.css` → Nginx가 직접 서빙 (파일 존재)
- `/v7/css/app.css` → Nginx가 직접 서빙
- `/v7/js/app.js` → Nginx가 직접 서빙
- `/api.php` → PHP-FPM이 실행 (`location ~ \.php$` 블록)

---

## 3. 접속 URL 및 도메인 설정

### 개발 환경 도메인

| 도메인 | 용도 | 비고 |
|--------|------|------|
| `https://v7-local.philgo.com` | **v7 홈페이지 (신규)** | Nginx → v7.php |
| `https://local.philgo.com` | 기존 v6 홈페이지 | Nginx → index.php |
| `https://banana.philgo.com` | 패밀리사이트 테스트 | 기존 유지 |

### /etc/hosts 설정

개발자의 Host OS에 다음 항목이 필요하다:

```
127.0.0.1 v7-local.philgo.com
```

> 기존 `local.philgo.com`, `banana.philgo.com` 등의 항목은 유지한다.

---

## 4. SSL 인증서 (mkcert)

### 현재 인증서 정보

v7-local.philgo.com은 기존 mkcert 와일드카드 인증서(`*.philgo.com`)로 커버된다.
**별도의 인증서 생성이 필요 없다.**

| 항목 | 값 |
|------|-----|
| **인증서 파일** | `docker/certs/dev.pem` |
| **개인키 파일** | `docker/certs/dev-key.pem` |
| **발급 CA** | mkcert development CA (로컬) |
| **SAN (도메인)** | `*.philgo.com`, `localhost`, `127.0.0.1`, `::1` |
| **유효기간** | 2025-10-10 ~ 2028-01-10 (약 3년) |
| **컨테이너 내부 경로** | `/docker/certs/dev.pem`, `/docker/certs/dev-key.pem` |

### mkcert 인증서 관리 방법

#### 1. mkcert 설치 및 Root CA 설치

```bash
# macOS
brew install mkcert

# Root CA를 시스템에 설치 (최초 1회)
mkcert -install
```

#### 2. 인증서 생성 (이미 완료됨)

```bash
cd /Users/thruthesky/apps/withcenter/philgo/www/docker/certs/

# 와일드카드 인증서 생성 (*.philgo.com 포함)
mkcert -cert-file ./dev.pem -key-file ./dev-key.pem \
  "*.philgo.com" "dev.localhost" "*.dev.localhost" \
  localhost 127.0.0.1 ::1
```

#### 3. 인증서 갱신이 필요한 경우

만료 시 위 명령어를 다시 실행하면 된다. 새 도메인 추가 시에도 동일하게 재생성한다.

#### 4. 팀원 간 인증서 공유

```bash
# Root CA 파일 복사
cp "$(mkcert -CAROOT)/rootCA.pem" ./docker/.mkcert/

# 팀원: rootCA.pem을 키체인에 등록 후 "항상 신뢰"로 설정
```

### 왜 v7-local.philgo.com에 별도 인증서가 필요 없는가

mkcert 인증서의 SAN에 `*.philgo.com`이 포함되어 있으므로,
`v7-local.philgo.com`은 와일드카드 매칭으로 자동 커버된다.

---

## 5. Docker / Nginx 설정

### Nginx 설정 파일 위치

```
docker/etc/nginx/nginx.conf
```

### v7-local.philgo.com Server Block

기존 `.philgo.com` 와일드카드 server block **앞에** v7 전용 server block을 추가한다.
Nginx는 exact name(`v7-local.philgo.com`)을 와일드카드(`.philgo.com`)보다 우선 매칭한다.

```nginx
# v7 홈페이지 전용 (v7-local.philgo.com)
server {
    listen 443 ssl http2;
    ssl_certificate /docker/certs/dev.pem;
    ssl_certificate_key /docker/certs/dev-key.pem;
    server_name v7-local.philgo.com;

    root /www;

    # PHP 파일 직접 실행 (api.php, func.php 등 기존 API 엔드포인트)
    location ~ \.php$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # / 루트 요청 시 index.html 대신 v7.php가 실행되도록 설정.
    # 기본값 index.html이 try_files보다 먼저 처리되므로 반드시 재정의 필요.
    index v7.php;

    # 존재하는 정적 파일(CSS, JS, 이미지 등)은 직접 서빙,
    # 그 외 모든 요청은 /v7.php로 내부 rewrite
    location / {
        try_files $uri /v7.php?$query_string;
    }
}
```

### `index` 지시어와 `try_files` 관계

Nginx의 `index` 지시어는 URI가 `/`로 끝날 때 `try_files`보다 **먼저** 처리된다.
기본값은 `index index.html`이므로, `/www/index.html`이 존재하면 v7.php 대신
index.html이 서빙되는 문제가 발생한다.

이를 방지하기 위해 `index v7.php;`를 명시적으로 선언하여,
루트 요청(`/`) 시 v7.php가 실행되도록 한다.

| 설정 | `/` 요청 시 동작 |
|------|------------------|
| `index index.html` (기본값) | `/www/index.html` 서빙 (v7 무시) |
| `index v7.php` (v7 설정) | `v7.php` 실행 → `v7/index.php` include |

### HTTP → HTTPS 리다이렉트

기존 `.philgo.com` HTTP 80 server block에서 자동 처리된다:

```nginx
server {
    listen 80;
    server_name .philgo.com;
    return 301 https://$host$request_uri;
}
```

`v7-local.philgo.com`도 `.philgo.com`에 매칭되므로, HTTP 요청은 자동으로 HTTPS로 리다이렉트된다.

### Nginx 재시작

설정 변경 후 Docker Nginx 컨테이너를 재시작해야 한다:

```bash
docker restart nginx
```

### Nginx 매칭 우선순위

| 우선순위 | 매칭 방식 | 예시 |
|---------|----------|------|
| 1 | Exact name | `v7-local.philgo.com` ✅ |
| 2 | Longest wildcard (앞) | `*.philgo.com` |
| 3 | Longest wildcard (뒤) | `philgo.*` |
| 4 | First matching regex | `~^(.+)\.philgo\.com$` |

따라서 `v7-local.philgo.com` 요청은 exact name server block에서 처리되고,
기존 `local.philgo.com`, `banana.philgo.com` 등은 `.philgo.com` server block에서 처리된다.

---

## 6. 프론트 컨트롤러 (v7.php)

### 파일 위치

```
./v7.php (프로젝트 루트)
```

### 역할

1. `v7/boot.php` include → v7 전용 부팅 (PSR-4 오토로더, 설정 상수, 타임존)
2. URL 경로 파싱 → `./v7/` 폴더의 해당 PHP 파일 include
3. 파일 미존재 시 404 처리

> **주의**: v6 `boot.php`는 사용하지 않는다. v7 전용 `v7/boot.php`만 사용한다.

### 라우팅 규칙

| URL 경로 | 파싱 결과 | include 파일 |
|----------|----------|-------------|
| `/` | `/index` | `./v7/index.php` |
| `/user/login` | `/user/login` | `./v7/user/login.php` |
| `/post/list` | `/post/list` | `./v7/post/list.php` |
| `/post/view` | `/post/view` | `./v7/post/view.php` |
| `/post/list.php` | `/post/list` | `./v7/post/list.php` (v6 호환) |
| `/post/view.php` | `/post/view` | `./v7/post/view.php` (v6 호환) |
| `/company/list` | `/company/list` | `./v7/company/list.php` |
| `/없는경로` | `/없는경로` | 404 (v7/404.php 또는 기본 메시지) |

### v6 URL Backward Compatibility (v6 URL 하위 호환)

v7 홈페이지는 v6 URL 패턴(`/post/list.php`, `/post/view.php`)을 **100% 지원**한다.
Google 검색엔진 등에서 v6 URL로 접속해도 v7 페이지가 정상적으로 표시된다.

**지원하는 v6 URL 패턴:**

| v6 URL 패턴 | v7 내부 라우팅 | 설명 |
|-------------|---------------|------|
| `/post/list.php?post_id=qna&category=여권/비자` | `v7/post/list.php` | 게시판 목록 |
| `/post/view.php?idx=797646&post_id=buyandsell&page=15674` | `v7/post/view.php` | 글 읽기 |

**구현 방법 (2단계):**

**1단계: Nginx Rewrite 규칙** (`docker/etc/nginx/nginx.conf`)

v7 서버 블록에서 `/post/list.php`와 `/post/view.php` 요청을 v7.php 프론트 컨트롤러로 전달한다.
이 규칙이 일반 `.php` 핸들러보다 **먼저** 위치해야 한다. (Nginx는 정규식 location을 순서대로 매칭한다.)

```nginx
# v6 backward compatibility: post/*.php URL을 v7.php 프론트 컨트롤러로 전달
# Google 검색엔진 등에서 v6 URL로 접속 시 v7 페이지로 라우팅한다.
# 예: /post/list.php?post_id=qna&category=여권/비자 → v7.php
# 예: /post/view.php?idx=12345&post_id=buyandsell → v7.php
# REQUEST_URI와 $_GET 파라미터는 그대로 유지된다.
location ~ ^/post/(list|view)\.php$ {
    rewrite ^ /v7.php last;
}

# 위 규칙이 이 일반 .php 핸들러보다 반드시 먼저 와야 한다
location ~ \.php$ {
    fastcgi_pass php:9000;
    ...
}
```

**2단계: Route.php `.php` 확장자 제거** (`v7/utils/Route.php`)

`parseRequest()` 메서드에서 경로의 `.php` 확장자를 자동으로 제거한다.
이를 통해 `/post/list.php` → `/post/list`, `/post/view.php` → `/post/view`로 변환되어
기존 v7 라우팅 로직이 그대로 동작한다.

```php
// .php 확장자 제거 (v6 backward compatibility)
// 예: post/view.php → post/view, post/list.php → post/list
if (str_ends_with($this->path, '.php')) {
    $this->path = substr($this->path, 0, -4);
}
```

**v6/v7 파라미터 이름 통일:**

v7에서는 v6와 동일한 쿼리 파라미터 이름을 사용한다:

| 파라미터 | 설명 | 사용 페이지 |
|----------|------|-------------|
| `idx` | 글 번호 | `/post/view`, `/post/update` |
| `post_id` | 게시판 ID | `/post/list`, `/post/view` |
| `category` | 2차 카테고리 | `/post/list`, `/post/view` |
| `page` | 페이지 번호 | `/post/list`, `/post/view` |

### 코드 구조

```php
<?php
// 1. v7 전용 부팅 (v6 boot.php 사용 금지)
include_once __DIR__ . '/v7/boot.php';

// 2. URL 파싱
$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
$path = rtrim($path, '/') ?: '/index';

// 3. v7/ 파일 include 또는 404
$v7File = ROOT_DIR . '/v7' . $path . '.php';
if (file_exists($v7File)) {
    include $v7File;
} else {
    http_response_code(404);
    // 404 처리
}
```

### 주의사항

- `v7.php`는 **레이아웃을 포함하지 않는 순수 라우터**이다
- 각 v7/ 파일이 전체 HTML(<!DOCTYPE html>부터 </html>까지)을 직접 출력한다
- 공통 레이아웃이 필요하면 `v7/layouts/` 폴더에서 별도 관리할 수 있다
- `v7/boot.php`가 이미 로드되므로, v7 Service 클래스(`Db::pdo()`, `AuthService::getLoginUser()` 등) 직접 사용 가능
- **v6 함수(`pdo()`, `login()`, `t()` 등)는 사용 불가** — v7 전용 클래스만 사용
- v6 `pdo()->prepare()` + `->execute()` + `->fetch()` 패턴은 v7 `Db::fetch()`로 교체해야 함 (예: `public-profile.php` 차단 확인 로직)

---

## 7. v7/ 폴더 구조

`./v7/` 폴더에는 웹 브라우저에 표현되는 **모든 파일**이 저장된다.

```
v7/
├── index.php                    # 홈페이지
├── 404.php                      # 404 에러 페이지 (선택)
├── user/
│   ├── login.php                # 로그인 페이지
│   ├── profile.php              # 프로필 수정 페이지
│   ├── public-profile.php       # 공개 프로필 페이지 (SSR)
│   ├── public-profile.css       # 공개 프로필 전용 CSS
│   └── register.php             # 회원가입 페이지
├── post/
│   ├── list.php                 # 게시판 목록 (SSR)
│   ├── view.php                 # 글 읽기 (SSR)
│   └── create.php               # 글 작성
├── menu/
│   ├── index.php                # 전체 메뉴 페이지
│   └── index.css                # 메뉴 페이지 전용 CSS
├── company/
│   ├── list.php                 # 업소록 목록
│   └── view.php                 # 업소록 상세
├── etc/                         # 설정 및 외부 라이브러리
│   ├── cache-version.php        # CACHE_VERSION 상수 (CSS/JS 캐시 버스팅)
│   ├── dist-cdn/                # Web Awesome Pro (UI 컴포넌트, 변경 금지)
│   │   ├── styles/
│   │   │   └── webawesome.css
│   │   ├── components/
│   │   ├── webawesome.loader.js
│   │   └── ...
│   └── font-awesome/            # Font Awesome 7.2.0 (아이콘, 변경 금지)
│       ├── css/
│       │   └── all.min.css      # FA 전체 CSS
│       └── webfonts/            # 아이콘 웹폰트 파일
├── css/                         # 커스텀 CSS
│   └── app.css
├── js/                          # 커스텀 JavaScript
│   └── app.js
├── images/                      # 이미지 애셋
├── fonts/                       # 웹 폰트
└── layouts/                     # 공통 레이아웃 (선택)
    ├── header.php
    └── footer.php
```

### 파일 저장 원칙

| 파일 종류 | 저장 위치 | 예시 |
|-----------|----------|------|
| PHP 뷰 페이지 | `v7/모듈/파일.php` | `v7/user/login.php` |
| CSS 스타일 | `v7/css/` | `v7/css/app.css` |
| JavaScript | `v7/js/` | `v7/js/app.js` |
| 이미지/아이콘 | `v7/images/` | `v7/images/logo.svg` |
| 폰트 | `v7/fonts/` | `v7/fonts/NotoSansKR.woff2` |
| JSON 데이터 | `v7/data/` | `v7/data/config.json` |
| 캐시 버전 상수 | `v7/etc/cache-version.php` | 배포 시 타임스탬프 업데이트 |
| Web Awesome | `v7/etc/dist-cdn/` | 변경 금지 (라이브러리) |
| Font Awesome | `v7/etc/font-awesome/` | 변경 금지 (라이브러리) |

---

## 8. UI 컴포넌트 (Web Awesome Pro)

### 설치 위치

Web Awesome Pro의 `dist-cdn/` 폴더가 `v7/etc/dist-cdn/`에 위치한다.
이 폴더는 **번들링 없이 브라우저에서 직접 사용**할 수 있는 CDN 배포판이다.

### 페이지에서 사용하는 방법

모든 v7 PHP 페이지의 `<head>`에 다음 2줄을 추가한다:

```html
<!-- Web Awesome Pro CSS -->
<link rel="stylesheet" href="/v7/etc/dist-cdn/styles/webawesome.css">

<!-- Web Awesome Pro JS (자동 로더) -->
<script type="module" src="/v7/etc/dist-cdn/webawesome.loader.js"
        data-webawesome="/v7/etc/dist-cdn"></script>
```

### 주요 컴포넌트 예시

```html
<!-- 버튼 -->
<wa-button variant="brand">클릭</wa-button>

<!-- 입력 필드 -->
<wa-input label="이메일" type="email" placeholder="email@example.com"></wa-input>

<!-- 카드 -->
<wa-card>
    <div slot="header"><strong>제목</strong></div>
    카드 내용
</wa-card>

<!-- 아이콘 (Font Awesome 내장) -->
<wa-icon name="house"></wa-icon>
<wa-icon name="gear"></wa-icon>

<!-- 레이아웃 유틸리티 -->
<div class="wa-stack" style="--wa-stack-gap: var(--wa-space-m);">...</div>
<div class="wa-cluster">...</div>
<div class="wa-grid">...</div>
```

### Web Awesome 핵심 개념

| 개념 | 설명 |
|------|------|
| **커스텀 엘리먼트** | `<wa-button>`, `<wa-input>` 등 HTML 커스텀 태그 |
| **슬롯(Slot)** | `<div slot="header">` 등으로 콘텐츠 삽입 |
| **이벤트** | `wa-change`, `wa-input` 등 `wa-` 접두사 이벤트 |
| **CSS 변수** | `--wa-space-m`, `--wa-color-brand-500` 등 디자인 토큰 |
| **닫는 태그 필수** | `<wa-input></wa-input>` (자체 닫힘 `<wa-input />` 불가) |

### AI(Claude, LLM)를 활용한 Web Awesome 개발 방법

v7 홈페이지에서 Web Awesome UI 컴포넌트를 사용할 때, AI(Claude Code 등)를 효과적으로 활용하는 방법이다.

#### 방법 1: llms.txt 활용

Web Awesome 배포판에 포함된 `llms.txt` 파일은 AI가 Web Awesome 컴포넌트 목록과 문서 링크를 빠르게 파악할 수 있도록 설계된 파일이다.

| 파일 위치 | 설명 |
|-----------|------|
| `v7/etc/dist-cdn/llms.txt` | Web Awesome 배포판에 포함된 llms.txt |
| `llms.txt` (프로젝트 루트) | 동일 내용 (루트 접근용) |

**프롬프트 예시:**

```
@llms.txt 를 참고해서 wa-button 컴포넌트로 로그인 버튼 코드 작성해줘

@v7/etc/dist-cdn/llms.txt 를 참고해서 wa-card와 wa-input으로 회원가입 폼 만들어줘

llms.txt에서 wa-tab-group 사용법 확인하고 게시판 탭 UI 작성해줘
```

#### 방법 2: webawesome 스킬 활용

프로젝트에 `webawesome` 스킬(`.claude/skills/webawesome/`)이 설치되어 있다.
이 스킬에는 Web Awesome의 **모든 컴포넌트에 대한 상세한 레퍼런스 문서**(속성, 이벤트, 슬롯, CSS 변수, 예제 코드)가 포함되어 있어,
AI가 정확한 코드를 작성할 수 있다.

**프롬프트 예시:**

```
webawesome 스킬을 참고해서 wa-dialog로 확인 모달 만들어줘

wa-select와 wa-option으로 카테고리 선택 드롭다운 만들어줘 (webawesome 스킬 참조)

webawesome 스킬의 wa-drawer 레퍼런스를 참고해서 모바일 네비게이션 메뉴 만들어줘
```

#### 방법 3: llms.txt + webawesome 스킬 병행

`llms.txt`로 사용할 컴포넌트를 빠르게 탐색하고, `webawesome` 스킬의 상세 레퍼런스로 정확한 구현을 하는 2단계 접근이 가능하다.

```
llms.txt에서 차트 관련 컴포넌트 확인하고, webawesome 스킬 참조해서 wa-bar-chart로 통계 페이지 만들어줘
```

#### 두 방법의 차이

| 항목 | llms.txt | webawesome 스킬 |
|------|----------|-----------------|
| **내용** | 컴포넌트 목록 + 공식 문서 URL 링크 | 각 컴포넌트별 상세 레퍼런스 (속성, 이벤트, 슬롯, CSS 변수, 예제) |
| **용도** | 어떤 컴포넌트가 있는지 빠르게 탐색 | 특정 컴포넌트의 정확한 사용법 확인 |
| **장점** | 간결, 빠른 개요 파악 | 상세한 코드 예제와 옵션 제공 |
| **위치** | `v7/etc/dist-cdn/llms.txt` | `.claude/skills/webawesome/` |

---

## 9. 아이콘 (Font Awesome 7.2.0)

### 설치 위치

Font Awesome 7.2.0 Pro가 `v7/etc/font-awesome/`에 설치되어 있다.
이 폴더에는 CSS 파일과 웹폰트 파일이 포함되어 있으며, **직접 수정하지 않는다**.

```
v7/etc/font-awesome/
├── css/
│   └── all.min.css          # Font Awesome 전체 CSS (아이콘 스타일 정의)
└── webfonts/                # 아이콘 웹폰트 파일 (woff2, ttf 등)
```

### 페이지에서 사용하는 방법

모든 v7 PHP 페이지의 `<head>`에 다음 1줄을 추가한다:

```html
<!-- Font Awesome 7.2.0 -->
<link rel="stylesheet" href="/v7/etc/font-awesome/css/all.min.css">
```

### 아이콘 사용 예시

```html
<!-- Solid 아이콘 (기본) -->
<i class="fa-solid fa-house"></i>
<i class="fa-solid fa-user"></i>
<i class="fa-solid fa-gear"></i>

<!-- Regular 아이콘 (외곽선) -->
<i class="fa-regular fa-heart"></i>
<i class="fa-regular fa-bell"></i>

<!-- Brand 아이콘 -->
<i class="fa-brands fa-google"></i>
<i class="fa-brands fa-apple"></i>

<!-- 크기 조절 -->
<i class="fa-solid fa-star fa-lg"></i>
<i class="fa-solid fa-star fa-2x"></i>
<i class="fa-solid fa-star fa-3x"></i>

<!-- 애니메이션 -->
<i class="fa-solid fa-spinner fa-spin"></i>
```

### Web Awesome의 wa-icon과의 관계

Web Awesome의 `<wa-icon>` 컴포넌트는 내부적으로 Font Awesome 아이콘을 사용한다.
Font Awesome CSS를 별도로 로드하면 `<wa-icon>` 외에도 `<i class="fa-...">` 형태로
직접 아이콘을 사용할 수 있어 더 유연한 아이콘 배치가 가능하다.

| 사용 방법 | 예시 | 특징 |
|-----------|------|------|
| `<wa-icon>` | `<wa-icon name="house"></wa-icon>` | Web Awesome 스타일 통합, 슬롯 지원 |
| `<i class="fa-...">` | `<i class="fa-solid fa-house"></i>` | 직접 사용, 크기/색상 CSS 제어 용이 |

### 주의사항

- `v7/etc/font-awesome/` 폴더의 파일은 **절대 수정 금지** (외부 라이브러리)
- Font Awesome 업그레이드 시 폴더 전체를 교체한다
- CDN 대신 로컬 파일을 사용하므로 오프라인 환경에서도 아이콘이 표시된다

---

## 10. Vue.js CDN 연동

### 로딩 방법

```html
<script defer src="https://unpkg.com/vue@3/dist/vue.global.prod.js"></script>
```

### Vue.js 사용 규칙

- **Options API 필수** (Composition API 사용 금지)
- **DOMContentLoaded 후 마운트** (Web Awesome 컴포넌트 로딩 대기)
- **컴포넌트를 함수로 작성**하여 재사용 가능하도록 구현

```html
<div id="app">
    <wa-input v-model="email" label="이메일"></wa-input>
    <wa-button @click="submit" variant="brand">로그인</wa-button>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    Vue.createApp({
        data() {
            return { email: '' };
        },
        methods: {
            async submit() {
                // v7 API 호출 — 반드시 v7api() 함수 사용 (fetch 직접 호출 금지)
                const data = await v7api('user.login', { email: this.email });
                console.log(data);
            }
        }
    }).mount('#app');
});
</script>
```

---

## 11. 기존 v7 API 연동

### API 엔드포인트

v7 API는 기존 `api.php`를 그대로 사용한다.
`v7-local.philgo.com` 도메인에서도 `/api.php`에 직접 접근 가능하다.

| 엔드포인트 | 방식 | 예시 |
|-----------|------|------|
| `/api.php` | POST (JSON) | `{ "method": "user.count" }` |
| `/api.php` | GET | `?method=user.count` |
| `/func.php` | POST | `{ "func": "get_posts", "post_id": "freetalk" }` |

### JavaScript에서 API 호출

> **🔴 절대 규칙: v7 API 호출 시 반드시 `v7api()` 함수를 사용해야 한다. `fetch()`로 직접 호출 금지. 🔴**

`v7api()` 함수는 `/v7/js/v7api.js`에 정의되어 있으며, 입력값 핸들링, 에러 감지, 사용자 알림(alert)을 자동으로 처리한다.
v7 페이지에서 이 스크립트를 로드한 후 사용한다.

```javascript
// ✅ 올바른 방법: v7api() 함수 사용 (v7/js/v7api.js에 정의됨)
const result = await v7api('user.count');
const posts = await v7api('post.list', { post_id: 'freetalk', limit: 10 });

// ✅ 에러 알림을 끄고 싶은 경우
const data = await v7api('user.me', {}, { alertOnError: false });

// ✅ 파일 업로드
const uploaded = await v7apiUpload(file, 'company', 'visit_review');
```

```javascript
// ❌ 절대 금지: fetch()로 직접 호출
const res = await fetch('/api.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ method: 'user.count' })
});
```

### PHP에서 v7 Service 직접 사용

`v7.php`에서 `v7/boot.php`가 이미 로드되므로(PSR-4 오토로더 포함),
v7 PHP 파일에서 Service 클래스를 직접 사용할 수 있다:

```php
<?php
// v7/post/list.php (SSR 예시)
use Philgo\Post\PostService;

$posts = PostService::list(['post_id' => 'freetalk', 'limit' => 10]);
?>
<html>
<!-- $posts 데이터를 서버사이드에서 직접 렌더링 (SEO) -->
</html>
```

---

## 12. SSR/SEO 전략

### SSR이 필요한 페이지

| 페이지 | 이유 | 구현 방식 |
|--------|------|----------|
| 게시판 목록 (`/post/list`) | SEO 검색 노출 | PHP에서 PostService로 데이터 로드 → HTML 렌더링 |
| 글 읽기 (`/post/view`) | SEO, Open Graph | PHP에서 글 데이터 로드 → 메타 태그 + HTML 렌더링 |

### CSR (Vue.js 동적 로드) 페이지

| 페이지 | 이유 | 구현 방식 |
|--------|------|----------|
| 로그인 (`/user/login`) | SEO 불필요 | Vue.js + API 호출 |
| 프로필 (`/user/profile`) | 로그인 필요 | Vue.js + API 호출 |
| 글 작성 (`/post/create`) | 로그인 필요 | Vue.js + API 호출 |
| 업소록 상세 (`/company/view`) | 선택적 SSR | PHP SSR + Vue.js 하이브리드 |

### 하이브리드 렌더링 패턴

SSR 페이지에서도 동적 기능(댓글, 좋아요 등)은 Vue.js로 처리한다:

```php
<?php
// SSR: PHP에서 글 데이터를 미리 로드
use Philgo\Post\PostService;
$post = PostService::get(['idx' => $_GET['idx'] ?? 0]);
?>
<html>
<head>
    <!-- SEO 메타 태그 -->
    <title><?= htmlspecialchars($post['subject'] ?? '') ?></title>
    <meta property="og:title" content="<?= htmlspecialchars($post['subject'] ?? '') ?>">
</head>
<body>
    <!-- SSR: 서버에서 렌더링된 글 내용 -->
    <h1><?= htmlspecialchars($post['subject'] ?? '') ?></h1>
    <div><?= $post['content'] ?? '' ?></div>

    <!-- CSR: 댓글은 Vue.js로 동적 로드 -->
    <div id="comments-app">
        <!-- Vue.js 댓글 컴포넌트 -->
    </div>
</body>
</html>
```

---

## 13. 페이지 개발 가이드

### 새 페이지 추가 절차

1. `v7/모듈/페이지.php` 파일 생성
2. HTML 전체 구조 작성 (<!DOCTYPE html> ~ </html>)
3. Web Awesome CSS/JS 포함
4. 필요 시 Vue.js 추가
5. `https://v7-local.philgo.com/모듈/페이지` 로 접속하여 확인

### 페이지 템플릿

```php
<?php
/**
 * v7/모듈/페이지.php - 페이지 설명
 *
 * v7.php에서 include. v7/boot.php(PSR-4 오토로더 + 설정 상수) 이미 로드됨.
 * v6 boot.php, page.header.php 등은 사용하지 않는다.
 *
 * 접속 URL: https://v7-local.philgo.com/모듈/페이지
 */

// 필요 시 v7 Service 사용
// use Philgo\Post\PostService;
// $data = PostService::list([...]);
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>페이지 제목 - 필고 v7</title>
    <!-- Web Awesome Pro -->
    <link rel="stylesheet" href="/v7/etc/dist-cdn/styles/webawesome.css">
    <script type="module" src="/v7/etc/dist-cdn/webawesome.loader.js" data-webawesome="/v7/etc/dist-cdn"></script>
    <!-- Font Awesome 7.2.0 -->
    <link rel="stylesheet" href="/v7/etc/font-awesome/css/all.min.css">
    <!-- Vue.js CDN (필요 시) -->
    <script defer src="https://unpkg.com/vue@3/dist/vue.global.prod.js"></script>
    <!-- 페이지 전용 CSS (같은 폴더에 분리) -->
    <link rel="stylesheet" href="/v7/모듈/페이지.css">
</head>
<body>
    <div class="wa-stack" style="--wa-stack-gap: var(--wa-space-xl); padding: var(--wa-space-xl); max-width: 1200px; margin: 0 auto;">
        <!-- 페이지 콘텐츠 -->
    </div>
</body>
</html>
```

### 페이지별 CSS 파일 분리 (필수 규칙)

> **🔴 각 PHP 페이지에 적용되는 CSS는 반드시 해당 PHP 파일과 같은 폴더에 별도 `.css` 파일로 분리해야 한다. 🔴**
> **PHP 파일 안에 `<style>` 태그로 CSS를 인라인 작성하는 것은 금지한다.**

이 규칙의 목적은 PHP 파일을 슬림하게 유지하고, CSS를 독립적으로 관리하기 위함이다.

**파일 명명 규칙:** PHP 파일명과 동일한 이름에 `.css` 확장자를 사용한다.

| PHP 파일 | CSS 파일 (같은 폴더) |
|----------|---------------------|
| `v7/user/login.php` | `v7/user/login.css` |
| `v7/post/list.php` | `v7/post/list.css` |
| `v7/widgets/topbar.php` | `v7/widgets/topbar.css` |
| `v7/index.php` | `v7/index.css` |

**CSS 파일 분류:**

| 분류 | 위치 | 설명 |
|------|------|------|
| **공통 CSS** | `v7/css/layout.css`, `v7/css/responsive.css`, `v7/css/utilities.css` | 전체 사이트에 적용되는 공통 스타일 |
| **페이지별 CSS** | 해당 PHP와 같은 폴더 | 해당 페이지에만 적용되는 스타일 |
| **위젯별 CSS** | `v7/widgets/` 폴더 | 해당 위젯에만 적용되는 스타일 |

**올바른 예시:**

```php
<!-- v7/user/login.php -->
<link rel="stylesheet" href="/v7/user/login.css">
<!-- ✅ CSS는 같은 폴더의 별도 파일에 작성 -->
```

**잘못된 예시 (금지):**

```php
<!-- ❌ 절대 금지: PHP 파일 안에 <style> 태그 -->
<style>
.login-form { max-width: 400px; margin: 0 auto; }
</style>
```

---

## 14. CSS/JS 캐시 버스팅 (CACHE_VERSION)

### 개요

CSS/JS 파일의 브라우저 캐시를 제어하기 위해 `CACHE_VERSION` 상수를 사용한다.
`time()` 함수를 사용하면 매 요청마다 캐시가 무효화되므로, 상수로 관리하여 **배포 시에만** 캐시를 갱신한다.

### 상수 정의 파일

**파일**: `v7/etc/cache-version.php`

```php
<?php
/**
 * v7 CSS/JS 캐시 버스팅 버전 상수
 *
 * 배포 또는 필요할 때 타임스탬프 값을 업데이트하여 캐시를 무효화합니다.
 */
const CACHE_VERSION = 1741305600;
```

### 사용 방법

`v7/layout.php` 상단에서 `require_once`로 로드한 뒤, CSS/JS 파일의 쿼리 파라미터로 사용한다.

```php
<?php
require_once __DIR__ . '/etc/cache-version.php';
?>
<link rel="stylesheet" href="/v7/css/layout.css?v=<?= CACHE_VERSION ?>">
<link rel="stylesheet" href="/v7/css/responsive.css?v=<?= CACHE_VERSION ?>">
<link rel="stylesheet" href="/v7/css/utilities.css?v=<?= CACHE_VERSION ?>">
```

### 캐시 갱신 방법

배포 시 또는 CSS/JS 변경 후 캐시를 무효화해야 할 때, `v7/etc/cache-version.php`의 타임스탬프 값을 업데이트한다.

```php
const CACHE_VERSION = 1741305600; // ← 새 타임스탬프로 변경
```

### 규칙

| 항목 | 규칙 |
|------|------|
| `time()` 사용 | 금지 (매 요청마다 캐시 무효화됨) |
| `CACHE_VERSION` 상수 | CSS/JS 캐시 버스팅에 반드시 사용 |
| 상수 업데이트 시점 | 배포 시 또는 CSS/JS 파일 변경 시 |
| 상수 파일 위치 | `v7/etc/cache-version.php` |

---

## 15. 개발 환경 설정 절차

### 최초 설정 (1회)

```bash
# 1. /etc/hosts에 v7 도메인 추가
echo "127.0.0.1 v7-local.philgo.com" | sudo tee -a /etc/hosts

# 2. mkcert Root CA 설치 (이미 완료된 경우 생략)
mkcert -install

# 3. Docker 컨테이너 시작
cd /Users/thruthesky/apps/withcenter/philgo/www/docker
docker compose up -d

# 4. Nginx 설정 변경 후 재시작
docker restart nginx
```

### 일상적인 개발

```bash
# Docker가 실행 중인지 확인
docker ps

# Nginx 재시작 (설정 변경 시)
docker restart nginx

# 브라우저에서 접속
open https://v7-local.philgo.com
```

### 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| ERR_CONNECTION_REFUSED | Docker 미실행 | `docker compose up -d` |
| SSL 인증서 경고 | mkcert Root CA 미설치 | `mkcert -install` |
| 502 Bad Gateway | PHP-FPM 미실행 | `docker restart php` |
| 404 Not Found | v7/ 파일 없음 | 해당 PHP 파일 생성 |
| 기존 v6 사이트 표시됨 | Nginx 매칭 오류 | server block 순서 확인 |

---

## 16. 개발 환경 테스트 로그인

### 개요

v7 홈페이지의 **데스크톱 모드**(화면 너비 992px 이상)에서는 상단 탑바(topbar)의 **오른쪽 영역**에
`[A]` `[B]` `[C]` `[D]` `[E]` `[F]` 테스트 로그인 버튼이 표시된다.

이 버튼은 **개발 환경(`Env::isDev()` = true)에서만** 표시되며,
프로덕션 환경에서는 자동으로 숨겨진다.

### 테스트 계정 목록

각 버튼은 Firebase email/password 인증을 사용하여 테스트 계정으로 로그인한다.
모든 계정의 비밀번호는 동일하다.

| 버튼 | 이메일 | 설명 |
|------|--------|------|
| **[A]** | `apple@test.com` | 관리자 테스트 계정 (ADMINS에 포함) |
| **[B]** | `banana@test.com` | 일반 사용자 테스트 계정 |
| **[C]** | `cherry@test.com` | 일반 사용자 테스트 계정 |
| **[D]** | `durian@test.com` | 일반 사용자 테스트 계정 |
| **[E]** | `elderberry@test.com` | 일반 사용자 테스트 계정 |
| **[F]** | `fig@test.com` | 일반 사용자 테스트 계정 |

### 로그인 방법

1. `https://v7-local.philgo.com`에 접속한다 (데스크톱 브라우저, 화면 너비 992px 이상)
2. 상단 탑바 오른쪽에 `[A]` ~ `[F]` 버튼이 보인다
3. 원하는 버튼을 클릭하면 **자동으로 로그인**된다
4. 로그인 성공 시 페이지가 자동으로 새로고침된다
5. 로그인 후에는 버튼 대신 **닉네임**과 **[로그아웃]** 버튼이 표시된다

### 로그아웃 방법

1. 로그인 상태에서 탑바 오른쪽의 **[로그아웃]** 버튼을 클릭한다
2. 세션 쿠키(`session_id`)가 삭제되고 페이지가 새로고침된다

### 로그인이 필요한 테스트 시

> **⚠️ AI(Claude Code 등)가 Chrome DevTools MCP로 v7 페이지를 테스트할 때,
> 로그인이 필요한 기능을 테스트하려면 반드시 이 테스트 로그인 버튼을 사용해야 한다.**

**Chrome DevTools MCP에서 테스트 로그인하는 방법:**

1. `https://v7-local.philgo.com`으로 이동
2. JavaScript 실행으로 테스트 로그인 수행:

```javascript
// Chrome DevTools MCP의 evaluate_script로 실행
await v7DevLogin('apple@test.com');
// → Firebase email/password 인증 → v7api('user.socialLogin') → 페이지 리로드
```

3. 페이지 리로드 후 로그인 상태가 유지되므로 로그인 필요 기능 테스트 가능

### 기술 구현 상세

| 항목 | 내용 |
|------|------|
| **위젯 파일** | `v7/widgets/layout/layout.topbar.php` |
| **CSS 파일** | `v7/widgets/layout/layout-widget.css` (`.v7-dev-login-btn`, `.v7-dev-user` 클래스) |
| **표시 조건** | `Env::isDev()` — macOS, Windows, 또는 localhost 접속 시에만 표시 |
| **로그인 상태 확인** | `AuthService::getLoginUser()` — 세션 쿠키 또는 Firebase ID Token 기반 인증 |
| **설정 클래스** | `V7\Utils\Config` — `devUsers()`, `devPassword()`, `firebaseConfigJson()` |
| **인증 흐름** | Firebase `signInWithEmailAndPassword()` → `getIdToken()` → `v7api('user.socialLogin', { id_token })` → 쿠키 저장 → 리로드 |
| **Firebase SDK** | `firebase-app-compat.js` + `firebase-auth-compat.js` (v12.3.0, 개발 환경에서만 로드) |

### 핵심 코드 흐름

```
[A] 버튼 클릭
  → v7DevLogin('apple@test.com')
  → firebase.auth().signInWithEmailAndPassword(email, password)
  → cred.user.getIdToken()
  → v7api('user.socialLogin', { id_token: idToken })
  → 서버: AuthService → FirebaseService 토큰 검증 → sf_member 조회 → 세션 쿠키 설정
  → location.reload()
  → 다음 요청부터 쿠키 기반 세션 인증
```

---

## 17. URL 유틸리티 (url() 함수)

### 개요

v7 홈페이지에서 URL을 하드코딩하지 않고 `url()` 전역 함수를 통해 관리한다.
v6의 `href()` 함수와 동일한 패턴이다.

| 항목 | 내용 |
|------|------|
| **파일** | `v7/utils/Url.php` |
| **전역 함수** | `url()` → `\V7\Utils\Url` 싱글톤 인스턴스 |
| **로딩** | `v7/boot.php`에서 `require_once` |
| **v6 대응** | `href()` → `url()` |

### URL 파라미터 구조

게시판 목록 URL은 다음 파라미터를 사용한다:

| 파라미터 | 설명 | 필수 여부 |
|----------|------|-----------|
| `post_id` | 게시판 ID (1차 카테고리) | **필수** |
| `category` | 2차 카테고리 | 옵션 |

```
/post/list?post_id=freetalk                      ← post_id만
/post/list?post_id=freetalk&category=discussion   ← post_id + category
/post/list?post_id=buyandsell&category=골프       ← post_id + 한글 category
```

### 사용법

```php
// 기본 URL
url()->home                         // '/'
url()->search                       // '/post/search'
url()->weather                      // '/weather'
url()->currency                     // '/currency'

// 게시판 목록 (프로퍼티)
url()->post->list->community        // '/post/list?post_id=freetalk'
url()->post->list->discussion       // '/post/list?post_id=freetalk&category=discussion'
url()->post->list->qna              // '/post/list?post_id=qna'
url()->post->list->buyandsell       // '/post/list?post_id=buyandsell'
url()->post->list->golf             // '/post/list?post_id=buyandsell&category=골프'

// 게시판 메서드
url()->post->view(123)              // '/post/view?idx=123'
url()->post->create('qna')          // '/post/create?post_id=qna'
url()->post->update(789)            // '/post/update?idx=789'
url()->post->popular                // '/post/popular'
url()->post->recentComments         // '/post/comments'

// 사용자
url()->user->login                  // '/user/login'
url()->user->profile                // '/user/profile'
url()->user->blocked                // '/user/blocked'
url()->user->resign                 // '/user/resign'
url()->user->accountDelete          // '/user/account-delete'

// 업소록
url()->company->home                // '/company'
url()->company->view(99)            // '/company/view?idx=99'

// 채팅
url()->chat->openChatRooms          // '/chat'

// 광고
url()->adv->banner                  // '/adv/banner'
url()->adv->point                   // '/adv/point'
url()->adv->massage                 // '/adv/massage'

// 도움말
url()->help->guideline              // '/help/guideline'
url()->help->terms                  // '/help/terms'
url()->help->pointGuideline         // '/help/point-guideline'
url()->help->pointEvent             // '/help/point-event'

// 포인트
url()->point->history               // '/point/history'

// 설정
url()->settings->notification       // '/settings/notification'

// 즐겨찾기
url()->bookmark->home               // '/bookmark'

// 메뉴
url()->menu->all                    // '/menu'
```

### HTML 템플릿 사용 예시

```php
<a href="<?= url()->post->list->community ?>">자유게시판</a>
<a href="<?= url()->user->login ?>">로그인</a>
<a href="<?= url()->company->home ?>">업소록</a>
<a href="<?= url()->bookmark->home ?>">즐겨찾기</a>
<a href="<?= url()->post->popular ?>">인기글</a>
<a href="<?= url()->post->recentComments ?>">최근 댓글</a>
<a href="<?= url()->adv->massage ?>">마사지 광고</a>
<a href="<?= url()->weather ?>">날씨</a>
<a href="<?= url()->currency ?>">환율 계산기</a>
<a href="<?= url()->menu->all ?>">전체 메뉴</a>
```

### 테스트

```bash
./vendor/bin/pest tests/Unit/UrlTest.php
```

---

## 18. 게시판 목록 페이지 (v7/post/list.php)

### 개요

게시판 목록 페이지는 `PostService::list()`를 호출하여 서버사이드 렌더링(SSR)한다.
`post_id`(1차 카테고리)와 `category`(2차 카테고리)를 모두 `PostService::list()`에 전달하여
**카테고리별 글 필터링**을 수행한다.

| 항목 | 내용 |
|------|------|
| **파일** | `v7/post/list.php` |
| **CSS** | `v7/post/list.css` (같은 폴더에 분리) |
| **접속 URL** | `https://v7-local.philgo.com/post/list?post_id=freetalk` |
| **렌더링** | SSR (PHP에서 직접 HTML 출력) |
| **데이터 소스** | `PostService::list()` → `PostRepository::findAll()` |

### URL 파라미터

| 파라미터 | 설명 | 기본값 | 예시 |
|----------|------|--------|------|
| `post_id` | 게시판 ID (1차 카테고리) | `freetalk` | `buyandsell`, `qna`, `wanted` |
| `category` | 2차 카테고리 | `null` (전체) | `페소환전`, `사업/동업구함`, `discussion` |
| `page` | 페이지 번호 | `1` | `2`, `3` |

### 카테고리 필터링 동작

`category` 파라미터가 `PostService::list()`에 전달되면, `PostRepository::findAll()`에서
SQL WHERE 절에 `category = :category` 조건이 추가되어 해당 카테고리의 글만 필터링된다.

```php
// v7/post/list.php 핵심 코드
$postId = $route->query('post_id', 'freetalk');
$category = $route->query('category');

$result = PostService::list([
    'post_id' => $postId,
    'category' => $category,    // 카테고리 필터링 (null이면 전체)
    'page' => $page,
    'limit' => $limit,
]);
```

**동작 예시:**

| URL | 결과 |
|-----|------|
| `/post/list?post_id=buyandsell` | 사고팔고 게시판 전체 글 |
| `/post/list?post_id=buyandsell&category=페소환전` | 사고팔고 > 페소환전 글만 |
| `/post/list?post_id=buyandsell&category=사업/동업구함` | 사고팔고 > 사업/동업구함 글만 |
| `/post/list?post_id=freetalk&category=discussion` | 자유게시판 > 토론 글만 |

### 브레드크럼 (Breadcrumb)

카테고리가 있으면 2단계 브레드크럼, 없으면 1단계 브레드크럼을 표시한다.

```
카테고리 없음: 홈 > 자유게시판
카테고리 있음: 홈 > 사고팔고 > 페소환전
```

### SEO 처리

- 카테고리가 있으면: `{카테고리명} - {게시판명} - 필고`
- 카테고리가 없으면: `{게시판명} - 필고`
- `Config::boardName()`으로 영문 post_id/category를 한글 이름으로 변환

### 게시판/카테고리 이름 매핑

`V7\Utils\Config::boardName()` 메서드가 post_id 또는 영문 category를 한글 이름으로 변환한다.
한글 카테고리(예: '페소환전', '사업/동업구함')는 매핑 없이 그대로 반환된다.

```php
Config::boardName('freetalk')    // → '자유게시판'
Config::boardName('discussion')  // → '토론'
Config::boardName('페소환전')     // → '페소환전' (한글은 그대로)
```

### 페이지네이션

- 페이지 범위: 현재 페이지 기준 앞뒤 5페이지
- 처음/이전/다음/마지막 링크 제공
- `Route::postList($postId, $category, $page)` 함수로 URL 생성

---

## 19. 게시판 글 읽기 페이지 (v7/post/view.php)

### 개요

게시판 글 읽기 페이지는 `PostService::get()`으로 글 데이터를 로드하고,
하단에 같은 게시판의 글 목록을 표시한다. 하단 글 목록도 카테고리 필터링을 지원한다.

| 항목 | 내용 |
|------|------|
| **파일** | `v7/post/view.php` |
| **CSS** | `v7/post/view.css` (같은 폴더에 분리) |
| **접속 URL** | `https://v7-local.philgo.com/post/view?idx=12345` |
| **v6 호환 URL** | `https://v7-local.philgo.com/post/view.php?idx=12345&post_id=buyandsell` |
| **렌더링** | SSR (PHP) + CSR (Vue.js — 좋아요, 댓글 등) |

### URL 파라미터

v6과 동일한 파라미터 이름을 사용한다.

| 파라미터 | 설명 | 기본값 |
|----------|------|--------|
| `idx` | 글 번호 | 필수 |
| `post_id` | 목록으로 돌아갈 게시판 ID | 글의 post_id |
| `category` | 목록으로 돌아갈 카테고리 | `null` |
| `page` | 목록으로 돌아갈 페이지 | `1` |

### 하단 글 목록 카테고리 필터링

글 읽기 페이지 하단에 표시되는 같은 게시판 글 목록도 `category` 파라미터를 전달하여
카테고리별 필터링을 수행한다.

```php
// v7/post/view.php 핵심 코드
$effectivePostId = !empty($listPostId) ? $listPostId : $post->post_id;
$effectiveCategory = !empty($listCategory) ? $listCategory : null;

$bottomResult = PostService::list([
    'post_id' => $effectivePostId,
    'category' => $effectiveCategory,   // 카테고리 필터링
    'page' => $listPage,
    'limit' => 20,
]);
```

### URL 생성 (Route 클래스)

| 메서드 | 시그니처 | 예시 |
|--------|----------|------|
| `Route::postList()` | `(string $postId, ?string $category, int $page)` | `/post/list?post_id=buyandsell&category=페소환전` |
| `Route::postView()` | `(int $idx, ?string $postId, ?string $category, int $page)` | `/post/view?idx=123&post_id=buyandsell&category=페소환전` |
| `Route::postCreate()` | `(string $postId, ?string $category)` | `/post/create?post_id=buyandsell&category=페소환전` |

---

## 20. 전체 메뉴 페이지 (v7/menu/index.php)

### 개요

v7 전체 메뉴 페이지는 사이트의 모든 주요 링크를 6개 섹션(커뮤니티, 광고 서비스, 내 정보, 도움말, 계정관리, 유틸리티)으로 분류하여 카드 형태의 그리드로 표시한다. v6 `page/menu/all.php`를 v7 시스템으로 이식했다.

| 항목 | 내용 |
|------|------|
| **파일** | `v7/menu/index.php` |
| **CSS** | `v7/menu/index.css` |
| **접속 URL** | `https://v7-local.philgo.com/menu` |
| **렌더링** | SSR (PHP) |

### 메뉴 섹션 구성

| 섹션 | 주요 메뉴 항목 |
|------|--------------|
| **커뮤니티** | 채팅, 업소록, 즐겨찾기, 인기글, 최근 댓글 |
| **광고 서비스** | 배너 광고, 포인트 광고, 게시판별 포인트 안내, 마사지 광고 |
| **내 정보** | 프로필 수정, 공개 프로필, 포인트 기록, 차단 사용자, 설정, 계정 관리 요청 |
| **도움말** | 이용 안내, 개인정보처리방침, 알림 설정, 포인트 이벤트 |
| **계정관리** | 로그인/로그아웃 (로그인 상태별 분기) |
| **유틸리티** | 검색, 날씨, 환율 계산기 |

> 상세 문서: [web/v7-menu.md](v7-menu.md)
