# 필고 Docker 인프라 설정 가이드

## 목차

- [1. 개요](#1-개요)
- [2. 서비스 아키텍처](#2-서비스-아키텍처)
- [3. Docker Compose 설정](#3-docker-compose-설정)
  - [3.1 신규 필고 서비스 (nginx + php)](#31-신규-필고-서비스-nginx--php)
  - [3.2 기존 필고 서비스 (old_philgo_nginx + old_philgo_php)](#32-기존-필고-서비스-old_philgo_nginx--old_philgo_php)
  - [3.3 MariaDB 서비스](#33-mariadb-서비스)
- [4. 포트 매핑](#4-포트-매핑)
- [5. Nginx 설정](#5-nginx-설정)
  - [5.1 신규 필고 Nginx](#51-신규-필고-nginx)
  - [5.2 기존 필고 Nginx](#52-기존-필고-nginx)
- [6. PHP 설정](#6-php-설정)
  - [6.1 신규 PHP (8.3.6)](#61-신규-php-836)
  - [6.2 기존 PHP (7.4.1)](#62-기존-php-741)
- [7. MariaDB 설정](#7-mariadb-설정)
- [8. SSL/TLS 인증서](#8-ssltls-인증서)
- [9. 볼륨 매핑](#9-볼륨-매핑)
- [10. 개발 환경 접속 방법](#10-개발-환경-접속-방법)
  - [Cloudflare 터널을 통한 외부 접속](#cloudflare-터널을-통한-외부-접속-에뮬레이터시뮬레이터)
- [11. Docker 운영 명령어](#11-docker-운영-명령어)
- [12. Windows 환경 설정](#12-windows-환경-설정)
- [13. 주의사항](#13-주의사항)
- [14. Dokploy 배포 (프로덕션)](#14-dokploy-배포-프로덕션)

---

## 1. 개요

### 핵심 개념

필고 프로젝트는 **기존 필고(v6, PHP 7.4) + 신규 필고(v7, PHP 8.3)** 2개 사이트를 하나의 Docker Compose 환경에서 동시 운영하는 이중 구조이다.

### 설계 의도

- 기존 사이트 운영 중단 없이 신규 기술스택 개발 가능
- 동일한 MariaDB를 공유하여 데이터 일관성 유지
- 포트 분리로 두 사이트를 독립적으로 접속/테스트 가능

### 핵심 파일 위치

모든 도커 설정 파일은 `/Users/thruthesky/apps/withcenter/philgo/www/docker/` 폴더에 위치한다. (docker 폴더가 프로젝트 루트 `philgo/www/` 내부에 존재)

```
docker/
├── compose.yaml                     # Docker Compose 메인 설정
├── compose.windows.yaml             # Windows용 설정
├── php.dockerfile                   # 신규 PHP 8.3.6 이미지
├── old-philgo-php.dockerfile        # 기존 PHP 7.4.1 이미지
├── certs/                           # SSL 인증서
│   ├── dev.pem                      # 개발용 공개키
│   └── dev-key.pem                  # 개발용 개인키
├── etc/                             # 신규 필고 설정
│   ├── nginx/nginx.conf             # 신규 Nginx 설정
│   ├── php.ini                      # 신규 PHP 설정
│   ├── php-fpm.d/custom.conf        # 신규 PHP-FPM 설정
│   └── mysql/mariadb.conf.d/
│       └── 50-server.cnf            # MariaDB 서버 설정
├── old-philgo-etc/                  # 기존 필고 설정
│   ├── nginx/
│   │   ├── nginx.conf               # 기존 Nginx 설정
│   │   └── common.conf              # 기존 Nginx 공통 설정
│   ├── php.ini                      # 기존 PHP 설정
│   ├── php-fpm.d/www.conf           # 기존 PHP-FPM 설정
│   └── mysql/my.cnf                 # 기존 MySQL 설정
└── var/                             # 런타임 데이터
    ├── lib/mysql/                   # MariaDB 데이터 (영구 저장)
    ├── log/nginx/                   # Nginx 로그
    └── logs/php/                    # PHP 로그
```

---

## 2. 서비스 아키텍처

### 전체 구성도

```
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Compose 환경                           │
│                                                                  │
│  ┌────────────────────┐       ┌────────────────────┐            │
│  │  old_philgo_nginx  │       │       nginx        │            │
│  │  (포트 81, 444)    │       │   (포트 80, 443)   │            │
│  │  기존 필고 v6      │       │   신규 필고 v7     │            │
│  └─────────┬──────────┘       └─────────┬──────────┘            │
│            │ fastcgi_pass               │ fastcgi_pass           │
│            ▼                            ▼                       │
│  ┌────────────────────┐       ┌────────────────────┐            │
│  │  old_philgo_php    │       │       php          │            │
│  │  PHP 7.4.1-fpm     │       │   PHP 8.3.6-fpm   │            │
│  │  (내부 포트 9000)  │       │   (내부 포트 9000) │            │
│  └─────────┬──────────┘       └─────────┬──────────┘            │
│            │                            │                       │
│            └────────────┬───────────────┘                       │
│                         ▼                                       │
│              ┌────────────────────┐                              │
│              │      mariadb       │                              │
│              │  MariaDB 11.7.2    │                              │
│              │  (포트 3306)       │                              │
│              └────────────────────┘                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 서비스 요약

| 서비스 | 컨테이너명 | 이미지 | 역할 | 호스트 포트 |
|--------|-----------|--------|------|-----------|
| `nginx` | `nginx` | `nginx:latest` | 신규 필고 웹서버 | 80, 443 |
| `php` | `php` | `php:8.3.6-fpm` (빌드) | 신규 필고 PHP | 내부 9000 |
| `old_philgo_nginx` | `philgo_nginx` | `nginx:1.19.7-alpine` | 기존 필고 웹서버 | 81, 444 |
| `old_philgo_php` | `philgo_php` | `php:7.4.1-fpm-alpine` (빌드) | 기존 필고 PHP | 내부 9000 |
| `mariadb` | `mariadb` | `mariadb:11.7.2` | 데이터베이스 (공유) | 3306 |

---

## 3. Docker Compose 설정

### 핵심 소스코드

파일 경로: `docker/compose.yaml`

### 3.1 신규 필고 서비스 (nginx + php)

```yaml
# 신규 필고 웹서버
nginx:
  container_name: nginx
  image: nginx
  ports:
    - "80:80"       # HTTP
    - "443:443"     # HTTPS
  volumes:
    - .:/docker
    - ~/www/philgo:/philgo
    - ..:/www                                              # 신규 필고 소스코드 (프로젝트 루트)
    - ./etc/nginx/nginx.conf:/etc/nginx/nginx.conf
    - ./var/log/nginx:/var/log/nginx
    - ~/apps/withcenter/philgo/www:/withcenter/philgo/www  # 개발 환경 소스코드
  command: [nginx-debug, "-g", "daemon off;"]

# 신규 필고 PHP
php:
  container_name: php
  build:
    context: .
    dockerfile: php.dockerfile    # PHP 8.3.6-fpm
  volumes:
    - .:/docker
    - ..:/www                     # 신규 필고 소스코드 (프로젝트 루트)
    - ./etc/php.ini:/usr/local/etc/php/php.ini
    - ./var/logs/php:/var/logs/php
```

### 3.2 기존 필고 서비스 (old_philgo_nginx + old_philgo_php)

```yaml
# 기존 필고 웹서버
old_philgo_nginx:
  image: nginx:1.19.7-alpine
  container_name: philgo_nginx
  volumes:
    - .:/docker
    - ..:/v6
    - ~/www/philgo:/philgo                                # 기존 필고 소스코드
    - ./old-philgo-etc:/docker/etc
    - ./old-philgo-etc/nginx/nginx.conf:/etc/nginx/nginx.conf
    - ./var/log/nginx:/etc/nginx/logs
  ports:
    - "81:81"       # HTTP
    - "444:444"     # HTTPS
  extra_hosts:
    - "host.docker.internal:host-gateway"
  command: [nginx-debug, "-g", "daemon off;"]

# 기존 필고 PHP
old_philgo_php:
  container_name: philgo_php
  build:
    context: .
    dockerfile: old-philgo-php.dockerfile    # PHP 7.4.1-fpm-alpine
  volumes:
    - .:/docker
    - ~/www/philgo:/philgo
    - ./old-philgo-etc/php.ini:/usr/local/etc/php/php.ini
    - ./old-philgo-etc/php-fpm.d/www.conf:/usr/local/etc/php-fpm.d/www.conf
```

### 3.3 MariaDB 서비스

```yaml
mariadb:
  container_name: mariadb
  image: mariadb:11.7.2     # 프로덕션 서버와 동일 버전
  ports:
    - "3306:3306"
  environment:
    MYSQL_DATABASE: philgo
    MYSQL_USER: philgo
    MYSQL_PASSWORD: asdf
    MYSQL_ROOT_PASSWORD: asdf
  volumes:
    - .:/docker
    - ..:/www                                                               # 신규 필고 소스코드 (프로젝트 루트)
    - ./var/lib/mysql:/var/lib/mysql                                       # DB 데이터 영구 저장
    - ./etc/mysql/mariadb.conf.d/50-server.cnf:/etc/mysql/mariadb.conf.d/50-server.cnf
```

---

## 4. 포트 매핑

### MacOS 호스트 포트 (현재 설정)

| 서비스 | HTTP 포트 | HTTPS 포트 | 접속 URL |
|--------|----------|-----------|----------|
| **신규 필고** (nginx) | 80 | **443** | `https://local.philgo.com` |
| **기존 필고** (old_philgo_nginx) | 81 | **444** | `https://local.philgo.com` |
| **MariaDB** | - | - | `127.0.0.1:3306` |

### Docker 내부 포트 (컨테이너 간 통신)

| 서비스 | 내부 포트 | 통신 방법 |
|--------|----------|----------|
| `php` (신규) | 9000 | `fastcgi_pass php:9000` |
| `old_philgo_php` (기존) | 9000 | `fastcgi_pass old_philgo_php:9000` |
| `mariadb` | 3306 | `host: mariadb` |

### 트래픽 흐름

```
HTTP 요청 (포트 80/443) → nginx → php:9000 → mariadb:3306
HTTP 요청 (포트 81/444) → old_philgo_nginx → old_philgo_php:9000 → mariadb:3306
```

---

## 5. Nginx 설정

### 5.1 신규 필고 Nginx

파일 경로: `docker/etc/nginx/nginx.conf`

```nginx
user nginx;
worker_processes auto;
error_log stderr debug;

http {
    client_max_body_size 22M;
    gzip on;

    # Localhost 테스트용 서버
    server {
        listen 80;
        listen [::]:80;
        server_name _ localhost;
        root /www;

        location ~ \.php$ {
            fastcgi_pass php:9000;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }

    # HTTP → HTTPS 리다이렉트 (*.philgo.com)
    server {
        listen 80;
        server_name .philgo.com;
        return 301 https://$host$request_uri;
    }

    # HTTPS 메인 서버 (*.philgo.com)
    server {
        listen 443 ssl http2;
        ssl_certificate /docker/certs/dev.pem;
        ssl_certificate_key /docker/certs/dev-key.pem;
        server_name .philgo.com;
        root /www;

        # Sitemap 처리: /sitemap*.xml → /sitemap.xml (PHP 내부에서 URI 파싱)
        location ~ ^/sitemap.*\.xml$ {
            try_files /sitemap.xml =404;
            fastcgi_pass php:9000;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }

        # Google Search Console 확인: /google*.html → /google-search-verification.php
        location ~ ^/google.*\.html$ {
            rewrite ^/google.*\.html$ /google-search-verification.php last;
        }

        # PHP/XML 처리
        location ~ \.(php|xml)$ {
            fastcgi_pass php:9000;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
```

**핵심 로직:**
- 포트 80에서 `*.philgo.com` 요청을 HTTPS(443)로 301 리다이렉트
- 포트 443에서 SSL/TLS로 서비스 (개발용 자체 서명 인증서)
- `fastcgi_pass php:9000`으로 PHP-FPM에 연결
- Sitemap, Google Search Console 확인 파일은 rewrite 규칙으로 PHP에서 동적 처리

### 5.2 기존 필고 Nginx

파일 경로: `docker/old-philgo-etc/nginx/nginx.conf`

```nginx
worker_processes 1;
error_log logs/error.log debug;

http {
    client_max_body_size 500M;
    fastcgi_read_timeout 600;
    gzip on;

    # 기본 서버 (포트 81)
    server {
        listen 81;
        server_name _;
        root /docker/home/default;
        include /docker/etc/nginx/common.conf;
    }

    # *.philgo.com 서버 (포트 81, 444 SSL)
    server {
        listen 444 ssl http2;
        listen 81;
        ssl_certificate /v6/etc/nginx/ssl/local.philgo.com/gogetssl/local.philgo.com.cert.ca-bundle;
        ssl_certificate_key /v6/etc/nginx/ssl/local.philgo.com/gogetssl/local.philgo.com.private.key;
        server_name .philgo.com;
        root /philgo;
        index index.php index.html;

        location ~ /\. { deny all; }
        location / { try_files $uri /index.php?$args; }
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ { expires max; log_not_found off; }

        location ~ \.php$ {
            fastcgi_pass old_philgo_php:9000;
            fastcgi_read_timeout 300;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
```

**핵심 로직:**
- 포트 81(HTTP)과 444(HTTPS SSL)에서 서비스
- `fastcgi_pass old_philgo_php:9000`으로 기존 PHP 7.4에 연결
- `root /philgo` → 기존 필고 소스코드 (`~/www/philgo`)
- 정적 파일 캐싱: `expires max`
- `.` 으로 시작하는 숨김 파일 접근 차단

---

## 6. PHP 설정

### 6.1 신규 PHP (8.3.6)

파일 경로: `docker/php.dockerfile`

```dockerfile
FROM php:8.3.6-fpm

# PHP Extension 설치
RUN apt-get update && apt-get install -y \
    curl libcurl4-openssl-dev libonig-dev \
    && docker-php-ext-install pdo pdo_mysql mysqli curl mbstring

# Production php.ini 사용
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
```

**설치된 Extension:**

| Extension | 용도 |
|-----------|------|
| `pdo` | 데이터베이스 추상화 계층 |
| `pdo_mysql` | MySQL/MariaDB PDO 드라이버 |
| `mysqli` | MySQL/MariaDB 개선 드라이버 |
| `curl` | HTTP/HTTPS 통신 |
| `mbstring` | 멀티바이트 문자열 (한글 처리) |

**PHP-FPM 설정** (`docker/etc/php-fpm.d/custom.conf`):

```conf
[www]
security.limit_extensions = .php .xml
```
- `.php`와 `.xml` 파일만 PHP-FPM에서 처리

### 6.2 기존 PHP (7.4.1)

파일 경로: `docker/old-philgo-php.dockerfile`

```dockerfile
FROM php:7.4.1-fpm-alpine

# PHP Extension 설치
RUN docker-php-ext-install pdo pdo_mysql mysqli exif
RUN docker-php-ext-configure gd --with-jpeg --with-webp
RUN docker-php-ext-install gd
```

**설치된 Extension:**

| Extension | 용도 |
|-----------|------|
| `pdo`, `pdo_mysql`, `mysqli` | 데이터베이스 |
| `exif` | 사진 EXIF 메타데이터 |
| `gd` | 이미지 생성/처리 (JPEG, PNG, WebP) |

**PHP-FPM 프로세스 관리** (`old-philgo-etc/php-fpm.d/www.conf`):

```conf
pm = dynamic
pm.max_children = 10
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
```

---

## 7. MariaDB 설정

### 접속 정보

| 항목 | 값 |
|------|-----|
| 호스트 (Docker 내부) | `mariadb` |
| 호스트 (Host OS) | `127.0.0.1` |
| 포트 | `3306` |
| 데이터베이스명 | `philgo` |
| 사용자 | `philgo` |
| 비밀번호 | `asdf` |
| Root 비밀번호 | `asdf` |
| MariaDB 버전 | `11.7.2` (프로덕션 서버와 동일) |

### PHP에서 접속

```php
// v7 시스템 (Db 클래스 사용)
$pdo = Philgo\Utils\Db::pdo();

// 레거시 시스템 (pdo() 함수 사용)
$pdo = pdo();
```

### CLI 접속

```bash
mysql -u philgo -pasdf -h 127.0.0.1 -P 3306 philgo
```

### MariaDB 서버 설정

파일 경로: `docker/etc/mysql/mariadb.conf.d/50-server.cnf`

- InnoDB 버퍼 풀 크기: 기본값 (주석 처리)
- Slow Query 로그: 비활성화 (필요시 활성화)
- Binlog 만료: 10일
- 데이터는 Host OS의 `docker/var/lib/mysql/`에 영구 저장

---

## 8. SSL/TLS 인증서

### 신규 필고 (개발용 자체 서명)

| 항목 | 경로 (컨테이너 내부) | Host OS 경로 |
|------|---------------------|-------------|
| 공개키 | `/docker/certs/dev.pem` | `docker/certs/dev.pem` |
| 개인키 | `/docker/certs/dev-key.pem` | `docker/certs/dev-key.pem` |

- `*.philgo.com` 와일드카드 도메인 지원
- 브라우저에서 자체 서명 경고가 표시될 수 있음

### 기존 필고 (GoGetSSL 인증서)

| 항목 | 경로 (컨테이너 내부) |
|------|---------------------|
| 공개키 (CA Bundle) | `/v6/etc/nginx/ssl/local.philgo.com/gogetssl/local.philgo.com.cert.ca-bundle` |
| 개인키 | `/v6/etc/nginx/ssl/local.philgo.com/gogetssl/local.philgo.com.private.key` |

- `local.philgo.com` 도메인 전용

---

## 9. 볼륨 매핑

### 신규 필고 (nginx + php)

| Host OS 경로 | 컨테이너 경로 | 용도 |
|-------------|-------------|------|
| `docker/` (`.`) | `/docker` | 도커 설정 파일 |
| `~/www/philgo` | `/philgo` | 기존 필고 소스 |
| `docker/..` (프로젝트 루트) | `/www` | **신규 필고 소스코드 (document root)** |
| `~/apps/withcenter/philgo/www` | `/withcenter/philgo/www` | 개발 환경 소스코드 |
| `docker/etc/nginx/nginx.conf` | `/etc/nginx/nginx.conf` | Nginx 설정 |
| `docker/etc/php.ini` | `/usr/local/etc/php/php.ini` | PHP 설정 |
| `docker/var/log/nginx` | `/var/log/nginx` | Nginx 로그 |
| `docker/var/logs/php` | `/var/logs/php` | PHP 로그 |

### 기존 필고 (old_philgo_nginx + old_philgo_php)

| Host OS 경로 | 컨테이너 경로 | 용도 |
|-------------|-------------|------|
| `docker/` (`.`) | `/docker` | 도커 설정 파일 |
| `docker/..` (프로젝트 루트) | `/v6` | 신규 필고 소스 (참조) |
| `~/www/philgo` | `/philgo` | **기존 필고 소스코드 (document root)** |
| `docker/old-philgo-etc` | `/docker/etc` | 기존 Nginx/PHP 설정 |
| `docker/old-philgo-etc/nginx/nginx.conf` | `/etc/nginx/nginx.conf` | Nginx 설정 |
| `docker/var/log/nginx` | `/etc/nginx/logs` | Nginx 로그 |

### MariaDB

| Host OS 경로 | 컨테이너 경로 | 용도 |
|-------------|-------------|------|
| `docker/var/lib/mysql` | `/var/lib/mysql` | DB 데이터 영구 저장 |
| `docker/etc/mysql/mariadb.conf.d/50-server.cnf` | `/etc/mysql/mariadb.conf.d/50-server.cnf` | 서버 설정 |

---

## 10. 개발 환경 접속 방법

### /etc/hosts 설정 (필수)

```
127.0.0.1 local.philgo.com
127.0.0.1 banana.philgo.com
```

### 신규 필고 접속 URL

| 프로토콜 | URL | 비고 |
|---------|-----|------|
| HTTPS | `https://local.philgo.com` | 포트 443 (기본, 생략 가능) |
| HTTPS | `https://local.philgo.com/api.php?method=user.profile` | v7 API 호출 |
| HTTP | `http://localhost` | localhost 테스트 |

### 기존 필고 접속 URL

| 프로토콜 | URL | 비고 |
|---------|-----|------|
| HTTPS | `https://local.philgo.com` | 포트 444 명시 필수 |
| HTTP | `http://local.philgo.com:81` | 포트 81 명시 필수 |

### 패밀리사이트 접속 URL

| 프로토콜 | URL | 비고 |
|---------|-----|------|
| HTTPS | `https://banana.philgo.com` | 신규 필고 기반 |
| HTTPS | `https://banana.philgo.com` | 기존 필고 기반 |

### Chrome DevTools MCP 테스트 URL

- **신규 필고**: `https://local.philgo.com` (포트 443)
- **기존 필고**: `https://local.philgo.com` (포트 444)
- **패밀리사이트**: `https://banana.philgo.com` (신규 필고 기반)

### Cloudflare 터널을 통한 외부 접속

로컬 개발 컴퓨터에서 실행 중인 Docker 환경에 **Cloudflare 터널**을 통해 외부에서 접속할 수 있다.

| 접속 URL | 용도 |
|----------|------|
| `https://local.philgo.com` | 브라우저, 안드로이드 에뮬레이터, iOS 시뮬레이터, 외부 기기에서 로컬 개발 서버 접속 |

**Cloudflare 터널 구조:**

Cloudflare DNS에서 `local` 서브도메인을 **Tunnel 타입** 레코드로 등록하고, **Proxied** 상태로 설정한다.
Cloudflare 터널(`cloudflared`)이 로컬 Docker Nginx의 HTTP 80번 포트로 트래픽을 전달한다.

```
브라우저 → (HTTPS) → Cloudflare (IUAM 챌린지) → Tunnel → http://127.0.0.1:80 → Docker Nginx → PHP
```

**IUAM 모드와의 호환:**

`*.philgo.com` 도메인은 Cloudflare의 **IUAM(I'm Under Attack Mode)** 모드가 활성화되어 있다.
IUAM 모드에서는 Cloudflare가 모든 요청에 JavaScript 챌린지를 삽입하여 봇/자동화 요청을 차단한다.

- **브라우저 접속**: 챌린지 통과 후 정상 이용 가능
- **안드로이드 에뮬레이터/iOS 시뮬레이터**: Flutter 앱의 WebView 또는 HTTP 클라이언트에서는 챌린지 통과가 불가능하므로, 앱 개발 시에는 IUAM 모드를 일시적으로 비활성화하거나 별도 도메인을 사용해야 한다.

**Nginx 설정 (무한 리다이렉트 방지):**

Cloudflare 터널은 HTTP(80번 포트)로 Nginx에 요청을 전달하므로, Nginx의 HTTP→HTTPS 301 리다이렉트가 무한 루프를 발생시킬 수 있다.
이를 방지하기 위해 `X-Forwarded-Proto` 헤더를 확인하여 Cloudflare 터널 경유 요청은 리다이렉트하지 않고 직접 처리한다.

```nginx
# docker/etc/nginx/nginx.conf - .philgo.com 80번 포트 서버 블록
server {
    listen 80;
    server_name .philgo.com;

    # Cloudflare Tunnel 경유 시 X-Forwarded-Proto 가 https 이면 직접 처리
    set $redirect_to_https 1;
    if ($http_x_forwarded_proto = "https") {
        set $redirect_to_https 0;
    }
    if ($redirect_to_https = 1) {
        return 301 https://$host$request_uri;
    }

    # Cloudflare Tunnel 경유 요청은 여기서 직접 처리 (443 서버 블록과 동일)
    root /www;

    location / {
        index index.php;
    }

    location ~ \.(php|xml)$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTPS on;  # PHP에서 $_SERVER['HTTPS'] 설정 → URL 생성 시 https:// 사용
        include fastcgi_params;
    }
}
```

핵심 포인트:
- `$http_x_forwarded_proto = "https"` 조건으로 Cloudflare Tunnel 경유 여부 판별
- `fastcgi_param HTTPS on` 으로 PHP에서 `$_SERVER['HTTPS']`가 설정되어 `current_url()`, `base_url()` 등의 함수가 `https://`로 올바르게 URL 생성
- 직접 HTTP 접속(Tunnel 경유가 아닌 경우)은 기존처럼 HTTPS로 301 리다이렉트

**사용 시나리오:**

- 브라우저에서 `https://local.philgo.com` 접속하여 로컬 개발 서버 테스트
- Flutter 앱 개발 시 안드로이드 에뮬레이터에서 로컬 API 서버 접속
- Flutter 앱 개발 시 iOS 시뮬레이터에서 로컬 API 서버 접속
- 실제 기기(USB 디버깅)에서 로컬 개발 서버 테스트
- `--dart-define=V7_API_ENDPOINT=https://local.philgo.com/api.php` 형태로 엔드포인트 지정

**wget / curl 로 로컬 서버 페이지 가져오기:**

Cloudflare 터널을 통해 로컬 서버의 PHP 페이지를 커맨드라인에서 직접 가져올 수 있다.

```bash
# wget 으로 게시판 목록 페이지 가져오기 (한글 파라미터는 URL 인코딩)
wget "https://local.philgo.com/post/list.php?post_id=buyandsell&category=%EA%B3%A8%ED%94%84"

# curl 로 동일한 페이지 가져오기
curl "https://local.philgo.com/post/list.php?post_id=buyandsell&category=%EA%B3%A8%ED%94%84"

# v7 API 호출 예시
curl "https://local.philgo.com/api.php?method=user.profile"
```

> **참고:** 쉘에서 `?`, `&` 등 특수문자가 포함된 URL은 반드시 따옴표(`"..."`)로 감싸야 한다.
> 한글 파라미터(예: `골프`)는 URL 인코딩(`%EA%B3%A8%ED%94%84`)으로 변환하여 전달한다.
> IUAM 모드가 활성화된 상태에서 curl/wget은 JavaScript 챌린지를 통과할 수 없어 403 응답을 받는다.

---

## 11. Docker 운영 명령어

### 기본 명령어

```bash
cd /Users/thruthesky/apps/withcenter/philgo/www/docker

# 전체 서비스 시작
docker compose up -d

# 전체 서비스 중지
docker compose down

# 서비스 상태 확인
docker compose ps

# 로그 확인
docker compose logs -f nginx
docker compose logs -f php
docker compose logs -f mariadb
```

### 개별 서비스 재시작

```bash
# Nginx 설정 변경 후 재시작
docker compose restart nginx
docker compose restart old_philgo_nginx

# PHP Dockerfile 변경 후 재빌드
docker compose up -d --build php
docker compose up -d --build old_philgo_php
```

### 컨테이너 내부 접속

```bash
# 신규 PHP 컨테이너
docker exec -it php bash

# 기존 PHP 컨테이너 (Alpine)
docker exec -it philgo_php sh

# MariaDB
docker exec -it mariadb mysql -u philgo -pasdf philgo
```

---

## 12. Windows 환경 설정

파일 경로: `docker/compose.windows.yaml`

### MacOS와의 차이점

| 항목 | MacOS (compose.yaml) | Windows (compose.windows.yaml) |
|------|---------------------|-------------------------------|
| 소스 경로 | `~/www/philgo` | `C:/www/philgo` |
| 신규 포트 | **80, 443** | **81, 444** |
| 기존 포트 | **81, 444** | **80, 443** |

Windows에서는 기존 필고가 기본 포트(80, 443)를 사용하고, 신규 필고가 보조 포트(81, 444)를 사용한다.

### Windows 실행 명령

```bash
cd /Users/thruthesky/apps/withcenter/philgo/www/docker
docker compose -f compose.windows.yaml up -d
```

---

## 13. 주의사항

### Docker 컨테이너 관리

- **컨테이너는 항상 실행 중**이라고 가정한다. 직접 시작/중지하지 않는다.
- Docker 상태를 확인하거나 웹서버 실행 여부를 점검할 필요 없다.
- 문제 발생 시 개발자가 직접 처리한다.

### 포트 충돌 방지

- 두 Nginx 서비스는 서로 다른 포트를 사용해야 한다.
- 포트 변경 시 반드시 **모든 컨테이너를 먼저 중지**한 후 변경한다.
- 변경할 파일: `compose.yaml` (포트 매핑) + Nginx 설정 (listen 포트)

### DB 계정 변경 주의

- 환경 변수에서 계정을 변경하면 DB에 기록된다.
- 이미 초기화된 DB에서는 환경변수 변경만으로 적용되지 않는다.
- 필요시 DB 내에서 직접 변경해야 한다.

### 데이터 영속성

- MariaDB 데이터는 Host OS의 `docker/var/lib/mysql/`에 영구 저장된다.
- 컨테이너나 이미지를 삭제해도 데이터는 유지된다.
- 단, 이 경로는 최초 `docker compose up` 전에 지정해야 한다.

---

## 14. Dokploy 배포 (프로덕션)

> **⚠️ Dokploy 배포에 대한 상세 내용은 별도 문서를 참조한다.**

### Dokploy 배포 → [v7-dokploy.md](v7-dokploy.md)

필고 v7 프로젝트의 Dokploy 기반 프로덕션 배포 구성 전체를 다룹니다.
Dokploy는 셀프호스팅 PaaS 도구로, Git 레포지토리(thruthesky/withcenter, 브랜치 v7)와 연동하여
Docker Compose 기반 자동 배포를 수행합니다. Nginx + PHP-FPM 8.3.6을 하나의 단일 컨테이너(web)로
통합하고 MariaDB 11.7.2를 별도 컨테이너로 운영하는 2-서비스 구조입니다. SSL/TLS 종단은
Dokploy 내장 Traefik 리버스 프록시가 처리하므로 컨테이너는 HTTP(80)만 리슨합니다.
모노레포 내 Compose Path(`./philgo/www/docker/dokploy-deploy/docker-compose.yml`), 환경변수 기반 DB 설정 자동 생성
(entrypoint.sh), `dokploy-network` 외부 네트워크 설정, 로컬 개발 환경과의 차이점(fastcgi_pass, SSL, 볼륨 방식)을 상세히 기술합니다.
서버 접속 정보: Dokploy 관리 패널 `http://209.97.169.136:3000`,
프리뷰 URL `http://philgo.209.97.169.136.traefik.me`.
