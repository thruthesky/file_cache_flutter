# 필고 v7 웹 홈페이지 개발 개요

## 목차

1. [개요](#1-개요)
2. [아키텍처](#2-아키텍처)
3. [접속 URL 및 도메인 설정](#3-접속-url-및-도메인-설정)
4. [SSL 인증서 (mkcert)](#4-ssl-인증서-mkcert)
5. [Docker / Nginx 설정](#5-docker--nginx-설정)
6. [프론트 컨트롤러 (v7-layout.php)](#6-프론트-컨트롤러-v7-layoutphp)
7. [v7/ 폴더 구조](#7-v7-폴더-구조)
8. [UI 컴포넌트 (Web Awesome Pro)](#8-ui-컴포넌트-web-awesome-pro)
9. [아이콘 (Font Awesome 7.2.0)](#9-아이콘-font-awesome-720)
10. [Vue.js CDN 연동](#10-vuejs-cdn-연동)
11. [기존 v7 API 연동](#11-기존-v7-api-연동)
12. [SSR/SEO 전략](#12-ssrseo-전략)
13. [페이지 개발 가이드](#13-페이지-개발-가이드)
14. [개발 환경 설정 절차](#14-개발-환경-설정-절차)

---

## 1. 개요

필고 v7 웹 홈페이지는 **기존 v7 API(Controller/Service/Entity)를 그대로 활용**하면서,
웹 브라우저에 표시되는 **뷰(View) 레이어만 완전히 새로 작성**하는 프로젝트이다.

| 항목 | 내용 |
|------|------|
| **프로젝트 목표** | v7 시스템 기반 새 웹 프론트엔드 구축 |
| **진입점** | `v7-layout.php` (프론트 컨트롤러) |
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
- **기존 인프라 활용**: `boot.php`를 통해 DB, 인증, 세션, 다국어 등 기존 인프라 사용

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
    └─ 파일 없음? → /v7-layout.php로 내부 rewrite
                        │
                        ├─ boot.php (DB, 인증, 세션 초기화)
                        ├─ vendor/autoload.php (PSR-4)
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
3. `index v7-layout.php` + `try_files $uri /v7-layout.php?$query_string`
   - `/` 요청 시 `index` 지시어에 의해 `v7-layout.php` 실행
   - `/user/login` 등 파일이 존재하지 않는 경로 → `/v7-layout.php`로 내부 rewrite
4. `v7-layout.php`에서 URL 경로 `/user/login` 파싱
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
| `https://v7-local.philgo.com` | **v7 홈페이지 (신규)** | Nginx → v7-layout.php |
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
cd /Users/thruthesky/apps/withcenter/philgo/docker/certs/

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

    # / 루트 요청 시 index.html 대신 v7-layout.php가 실행되도록 설정.
    # 기본값 index.html이 try_files보다 먼저 처리되므로 반드시 재정의 필요.
    index v7-layout.php;

    # 존재하는 정적 파일(CSS, JS, 이미지 등)은 직접 서빙,
    # 그 외 모든 요청은 /v7-layout.php로 내부 rewrite
    location / {
        try_files $uri /v7-layout.php?$query_string;
    }
}
```

### `index` 지시어와 `try_files` 관계

Nginx의 `index` 지시어는 URI가 `/`로 끝날 때 `try_files`보다 **먼저** 처리된다.
기본값은 `index index.html`이므로, `/www/index.html`이 존재하면 v7-layout.php 대신
index.html이 서빙되는 문제가 발생한다.

이를 방지하기 위해 `index v7-layout.php;`를 명시적으로 선언하여,
루트 요청(`/`) 시 v7-layout.php가 실행되도록 한다.

| 설정 | `/` 요청 시 동작 |
|------|------------------|
| `index index.html` (기본값) | `/www/index.html` 서빙 (v7 무시) |
| `index v7-layout.php` (v7 설정) | `v7-layout.php` 실행 → `v7/index.php` include |

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

## 6. 프론트 컨트롤러 (v7-layout.php)

### 파일 위치

```
./v7-layout.php (프로젝트 루트)
```

### 역할

1. `boot.php` include → 기존 인프라(DB, 인증, 세션, 다국어) 초기화
2. `vendor/autoload.php` require → v7 Controller/Service 클래스 사용 가능
3. URL 경로 파싱 → `./v7/` 폴더의 해당 PHP 파일 include
4. 파일 미존재 시 404 처리

### 라우팅 규칙

| URL 경로 | 파싱 결과 | include 파일 |
|----------|----------|-------------|
| `/` | `/index` | `./v7/index.php` |
| `/user/login` | `/user/login` | `./v7/user/login.php` |
| `/post/list` | `/post/list` | `./v7/post/list.php` |
| `/post/view` | `/post/view` | `./v7/post/view.php` |
| `/company/list` | `/company/list` | `./v7/company/list.php` |
| `/없는경로` | `/없는경로` | 404 (v7/404.php 또는 기본 메시지) |

### 코드 구조

```php
<?php
// 1. 기존 필고 인프라 부팅
include_once __DIR__ . '/boot.php';

// 2. PSR-4 오토로더
require_once ROOT_DIR . '/vendor/autoload.php';

// 3. URL 파싱
$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
$path = rtrim($path, '/') ?: '/index';

// 4. v7/ 파일 include 또는 404
$v7File = ROOT_DIR . '/v7' . $path . '.php';
if (file_exists($v7File)) {
    include $v7File;
} else {
    http_response_code(404);
    // 404 처리
}
```

### 주의사항

- `v7-layout.php`는 **레이아웃을 포함하지 않는 순수 라우터**이다
- 각 v7/ 파일이 전체 HTML(<!DOCTYPE html>부터 </html>까지)을 직접 출력한다
- 공통 레이아웃이 필요하면 `v7/layouts/` 폴더에서 별도 관리할 수 있다
- `boot.php`가 이미 로드되므로, `pdo()`, `login()`, `t()` 등 기존 함수 사용 가능
- `vendor/autoload.php`가 이미 로드되므로, v7 Service 클래스 직접 사용 가능

---

## 7. v7/ 폴더 구조

`./v7/` 폴더에는 웹 브라우저에 표현되는 **모든 파일**이 저장된다.

```
v7/
├── index.php                    # 홈페이지
├── 404.php                      # 404 에러 페이지 (선택)
├── user/
│   ├── login.php                # 로그인 페이지
│   ├── profile.php              # 프로필 페이지
│   └── register.php             # 회원가입 페이지
├── post/
│   ├── list.php                 # 게시판 목록 (SSR)
│   ├── view.php                 # 글 읽기 (SSR)
│   └── create.php               # 글 작성
├── company/
│   ├── list.php                 # 업소록 목록
│   └── view.php                 # 업소록 상세
├── etc/                         # 외부 라이브러리 (변경 금지)
│   ├── dist-cdn/                # Web Awesome Pro (UI 컴포넌트)
│   │   ├── styles/
│   │   │   └── webawesome.css
│   │   ├── components/
│   │   ├── webawesome.loader.js
│   │   └── ...
│   └── font-awesome/            # Font Awesome 7.2.0 (아이콘)
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
                // v7 API 호출
                const res = await fetch('/api.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ method: 'user.login', email: this.email })
                });
                const data = await res.json();
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

```javascript
// v7 API 호출 (api.php)
async function v7api(method, params = {}) {
    const res = await fetch('/api.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ method, ...params })
    });
    return res.json();
}

// 사용 예시
const result = await v7api('user.count');
const posts = await v7api('post.list', { post_id: 'freetalk', limit: 10 });
```

### PHP에서 v7 Service 직접 사용

`v7-layout.php`에서 `boot.php`와 `autoload.php`가 이미 로드되므로,
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
 * v7-layout.php에서 include. boot.php, autoload 이미 로드됨.
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
</head>
<body>
    <div class="wa-stack" style="--wa-stack-gap: var(--wa-space-xl); padding: var(--wa-space-xl); max-width: 1200px; margin: 0 auto;">
        <!-- 페이지 콘텐츠 -->
    </div>
</body>
</html>
```

---

## 14. 개발 환경 설정 절차

### 최초 설정 (1회)

```bash
# 1. /etc/hosts에 v7 도메인 추가
echo "127.0.0.1 v7-local.philgo.com" | sudo tee -a /etc/hosts

# 2. mkcert Root CA 설치 (이미 완료된 경우 생략)
mkcert -install

# 3. Docker 컨테이너 시작
cd /Users/thruthesky/apps/withcenter/philgo/docker
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
