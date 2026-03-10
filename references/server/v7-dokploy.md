# 필고 v7 Dokploy 배포 가이드

## 목차

- [1. 개요](#1-개요)
- [2. 서버 정보](#2-서버-정보)
- [3. 아키텍처](#3-아키텍처)
  - [3.1 단일 컨테이너 패턴](#31-단일-컨테이너-패턴)
  - [3.2 트래픽 흐름](#32-트래픽-흐름)
- [4. 파일 구조](#4-파일-구조)
- [5. Docker Compose 설정](#5-docker-compose-설정)
  - [5.1 web 서비스](#51-web-서비스)
  - [5.2 mariadb 서비스](#52-mariadb-서비스)
  - [5.3 볼륨](#53-볼륨)
  - [5.4 네트워크](#54-네트워크)
- [6. Dockerfile](#6-dockerfile)
  - [6.1 빌드 단계](#61-빌드-단계)
  - [6.2 설치된 PHP Extension](#62-설치된-php-extension)
  - [6.3 PHP 설정](#63-php-설정)
- [7. Nginx 설정](#7-nginx-설정)
  - [7.1 핵심 설정](#71-핵심-설정)
  - [7.2 라우팅 규칙](#72-라우팅-규칙)
- [8. Entrypoint 스크립트](#8-entrypoint-스크립트)
  - [8.1 DB 설정 자동 생성](#81-db-설정-자동-생성)
  - [8.2 실행 흐름](#82-실행-흐름)
- [9. PHP-FPM 커스텀 설정](#9-php-fpm-커스텀-설정)
- [10. Dokploy 설정 방법](#10-dokploy-설정-방법)
  - [10.1 Compose 서비스 생성](#101-compose-서비스-생성)
  - [10.2 도메인 설정](#102-도메인-설정)
- [11. 로컬 개발 환경과의 차이점](#11-로컬-개발-환경과의-차이점)
- [12. 주의사항](#12-주의사항)

---

## 1. 개요

### 핵심 개념

Dokploy는 셀프호스팅 PaaS(Platform as a Service) 도구이다. Git 레포지토리와 연동하여 Docker Compose 기반으로 자동 배포를 수행한다.

필고 v7 프로젝트는 Dokploy의 **Compose 서비스** 기능을 사용하여 배포한다.
Nginx + PHP-FPM을 **하나의 단일 컨테이너**(web)로 통합하고, MariaDB를 별도 컨테이너로 운영하는 2-서비스 구조이다.

### 설계 의도

- **단일 컨테이너 통합**: Nginx와 PHP-FPM을 하나의 이미지로 묶어 Dokploy에서 단일 포트(80) 노출만으로 서비스 가능
- **SSL은 Traefik이 처리**: Dokploy가 내장한 Traefik 리버스 프록시가 SSL/TLS 종단을 처리하므로 컨테이너는 HTTP(80)만 리슨
- **환경변수 기반 DB 설정**: Docker Compose 환경변수로 DB 접속 정보를 주입하여 `.gitignore` 대상 파일(db.config.php)을 자동 생성
- **로컬 개발과 분리**: 로컬 개발용 Docker Compose(`docker/compose.yaml`)와 Dokploy 배포용(`docker/dokploy-deploy/docker-compose.yml`)을 분리하여 독립적으로 관리

### 핵심 파일 위치

배포 관련 파일은 프로젝트 루트 및 `docker/dokploy-deploy/` 폴더에 위치한다.

```
www/                                     # 프로젝트 루트 (= philgo/www)
└── docker/
    └── dokploy-deploy/
        ├── docker-compose.yml           # Dokploy 배포용 Docker Compose
        ├── Dockerfile                   # PHP 8.3.6-fpm + Nginx 단일 컨테이너
        ├── nginx.conf                   # Dokploy용 Nginx 설정 (HTTP 80만)
        ├── entrypoint.sh                # DB 설정 자동 생성 스크립트
        └── php-fpm-custom.conf          # XML 파일 PHP 처리 허용
```

---

## 2. 서버 정보

| 항목 | 값 |
|------|-----|
| Dokploy 관리 패널 | `http://209.97.169.136:3000` |
| 프로덕션 URL | `https://philgo.net` |
| 프리뷰 URL | `http://philgo.209.97.169.136.traefik.me` |
| Git 레포지토리 | `thruthesky/withcenter` |
| Git 브랜치 | `v7` |
| Compose Path | `./philgo/www/docker/dokploy-deploy/docker-compose.yml` |
| 서버 OS | Ubuntu (DigitalOcean Droplet) |
| Traefik | Dokploy 내장 리버스 프록시 (SSL 종단 처리) |

### 모노레포 구조

`thruthesky/withcenter` 레포지토리는 모노레포 구조이다. 필고 프로젝트는 `philgo/www/` 하위 디렉토리에 위치하므로, Dokploy의 Compose Path를 `./philgo/www/docker/dokploy-deploy/docker-compose.yml`로 지정해야 한다.

```
withcenter/                   # Git 레포지토리 루트
└── philgo/
    └── www/                  # 필고 v7 프로젝트 루트
        ├── docker/
        │   └── dokploy-deploy/
        │       ├── docker-compose.yml
        │       ├── Dockerfile
        │       ├── nginx.conf
        │       ├── entrypoint.sh
        │       └── php-fpm-custom.conf
        ├── v7/
        ├── lib/
        ├── api.php
        └── ...
```

---

## 3. 아키텍처

### 3.1 단일 컨테이너 패턴

Dokploy 배포에서는 Nginx와 PHP-FPM을 **하나의 Docker 이미지**에 통합한다. 이는 로컬 개발 환경(nginx 컨테이너 + php 컨테이너 분리)과 다른 구조이다.

```
┌─────────────────────────────────────────────┐
│              Dokploy 서버                     │
│                                               │
│  ┌─────────────────────────────────────────┐ │
│  │         Traefik (리버스 프록시)            │ │
│  │    SSL 종단 처리 (Let's Encrypt)          │ │
│  │    *.traefik.me 도메인 라우팅             │ │
│  └──────────────┬──────────────────────────┘ │
│                  │ HTTP :80                    │
│  ┌──────────────▼──────────────────────────┐ │
│  │           web 컨테이너                    │ │
│  │  ┌──────────────┐  ┌──────────────────┐ │ │
│  │  │    Nginx     │  │   PHP-FPM 8.3.6  │ │ │
│  │  │  (port 80)   │──│  (port 9000)     │ │ │
│  │  │  HTTP만 리슨  │  │  127.0.0.1:9000  │ │ │
│  │  └──────────────┘  └──────────────────┘ │ │
│  └──────────────┬──────────────────────────┘ │
│                  │ TCP :3306                   │
│  ┌──────────────▼──────────────────────────┐ │
│  │        mariadb 컨테이너                   │ │
│  │        MariaDB 11.7.2                     │ │
│  │        Named Volume: mariadb-data         │ │
│  └─────────────────────────────────────────┘ │
│                                               │
└─────────────────────────────────────────────┘
```

### 3.2 트래픽 흐름

```
클라이언트 → HTTPS → Traefik (SSL 종단) → HTTP :80 → Nginx → fastcgi 127.0.0.1:9000 → PHP-FPM → MariaDB :3306
```

- 클라이언트와 Traefik 사이: HTTPS (Traefik이 SSL 인증서 관리)
- Traefik과 web 컨테이너 사이: HTTP (내부 네트워크, 암호화 불필요)
- web 컨테이너 내부: Nginx가 `127.0.0.1:9000`으로 PHP-FPM에 FastCGI 연결
- web 컨테이너와 mariadb 컨테이너: Docker 내부 네트워크를 통해 `mariadb:3306`으로 연결

---

## 4. 파일 구조

| 파일 | 경로 | 역할 |
|------|------|------|
| **Docker Compose** | `docker/dokploy-deploy/docker-compose.yml` | Dokploy 배포용 서비스 정의 (web + mariadb) |
| **Dockerfile** | `docker/dokploy-deploy/Dockerfile` | PHP 8.3.6-fpm 기반 Nginx + PHP-FPM 단일 이미지 빌드 |
| **Nginx 설정** | `docker/dokploy-deploy/nginx.conf` | HTTP 80 포트만 리슨, Traefik이 SSL 처리 |
| **Entrypoint** | `docker/dokploy-deploy/entrypoint.sh` | 컨테이너 시작 시 db.config.php 자동 생성 |
| **PHP-FPM 설정** | `docker/dokploy-deploy/php-fpm-custom.conf` | `.php`와 `.xml` 파일 PHP-FPM 처리 허용 |

---

## 5. Docker Compose 설정

### 핵심 소스코드

파일 경로: `docker/dokploy-deploy/docker-compose.yml`

```yaml
## Dokploy 배포용 Docker Compose 설정
## PhilGo v7 홈페이지 (Nginx + PHP-FPM + MariaDB)
##
## 이 파일은 Dokploy Compose 서비스에서 사용됩니다.
## 로컬 개발용 Docker Compose는 docker/compose.yaml 을 사용합니다.
##
## 주의: web과 mariadb 모두 dokploy-network에 연결해야 서비스 이름으로 통신 가능.
## Dokploy가 web을 dokploy-network에 자동 연결하지만, mariadb는 별도 지정 필요.

services:
  web:
    build:
      context: ../..
      dockerfile: docker/dokploy-deploy/Dockerfile
    ports:
      - 80
    depends_on:
      mariadb:
        condition: service_healthy
    environment:
      DB_HOST: mariadb
      DB_USER: philgo
      DB_PASSWORD: asdf
      DB_NAME: philgo
    networks:
      - dokploy-network

  mariadb:
    image: mariadb:11.7.2
    environment:
      MYSQL_DATABASE: philgo
      MYSQL_USER: philgo
      MYSQL_PASSWORD: asdf
      MYSQL_ROOT_PASSWORD: rootpwd
    volumes:
      - mariadb-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - dokploy-network

volumes:
  mariadb-data:

networks:
  dokploy-network:
    external: true
```

### 5.1 web 서비스

| 항목 | 값 | 설명 |
|------|-----|------|
| **빌드 컨텍스트** | `../..` (프로젝트 루트) | docker-compose.yml이 `docker/dokploy-deploy/` 안에 있으므로 `../..`로 프로젝트 루트를 지정. Dockerfile이 전체 소스를 COPY |
| **Dockerfile** | `docker/dokploy-deploy/Dockerfile` | Nginx + PHP-FPM 통합 이미지 |
| **포트** | `80` | Traefik이 자동으로 매핑 |
| **의존성** | `mariadb` (healthy) | MariaDB가 정상 시작된 후에만 web 시작 |
| **환경변수** | `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` | entrypoint.sh가 db.config.php 생성에 사용 |
| **네트워크** | `dokploy-network` | Dokploy의 외부 네트워크에 연결하여 Traefik 라우팅 지원 |

### 5.2 mariadb 서비스

| 항목 | 값 | 설명 |
|------|-----|------|
| **이미지** | `mariadb:11.7.2` | 로컬 개발 환경과 동일 버전 |
| **데이터 영속화** | `mariadb-data` Named Volume | 컨테이너 재생성 시에도 데이터 유지 |
| **Healthcheck** | `healthcheck.sh --connect --innodb_initialized` | InnoDB 초기화 완료까지 대기 |
| **시작 대기** | `start_period: 30s` | 첫 Healthcheck까지 30초 대기 |
| **네트워크** | `dokploy-network` | web과 동일 네트워크에 연결해야 서비스 이름(`mariadb`)으로 DB 접속 가능 |

### 5.3 볼륨

```yaml
volumes:
  mariadb-data:    # Docker Named Volume — MariaDB 데이터 영구 저장
```

Named Volume을 사용하여 `docker compose down` 후에도 DB 데이터가 유지된다. `docker compose down -v`를 실행하면 볼륨이 삭제되므로 주의해야 한다.

### 5.4 네트워크

```yaml
networks:
  dokploy-network:
    external: true
```

- `dokploy-network`는 Dokploy가 사전에 생성한 **외부(external) Docker 네트워크**이다.
- Dokploy의 Traefik 리버스 프록시가 이 네트워크를 통해 컨테이너에 접근한다.
- `web`과 `mariadb` 서비스 모두 이 네트워크에 연결해야 한다.
  - Dokploy가 `web` 서비스를 자동으로 `dokploy-network`에 연결하지만, `mariadb`는 **별도로 `networks` 항목을 명시**해야 서비스 이름(`mariadb`)으로 통신이 가능하다.
  - `mariadb`에 `dokploy-network`를 지정하지 않으면, `web` 컨테이너에서 `DB_HOST: mariadb`로 접속할 수 없다.

---

## 6. Dockerfile

### 핵심 소스코드

파일 경로: `docker/dokploy-deploy/Dockerfile`

```dockerfile
FROM php:8.3.6-fpm

# 시스템 패키지 및 PHP 확장 설치
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    libcurl4-openssl-dev \
    libonig-dev \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        mysqli \
        curl \
        mbstring \
        gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Production PHP 설정 적용
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# PHP upload/post 크기 설정 (22MB)
RUN echo "upload_max_filesize = 22M" >> "$PHP_INI_DIR/php.ini" \
    && echo "post_max_size = 22M" >> "$PHP_INI_DIR/php.ini" \
    && echo "memory_limit = 256M" >> "$PHP_INI_DIR/php.ini"

# PHP-FPM 커스텀 설정 (XML 파일 처리)
COPY docker/dokploy-deploy/php-fpm-custom.conf /usr/local/etc/php-fpm.d/custom.conf

# Nginx 설정
COPY docker/dokploy-deploy/nginx.conf /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/sites-enabled/default

# 소스 코드 복사
WORKDIR /www
COPY . /www

# entrypoint 스크립트 (CRLF -> LF 변환 포함)
COPY docker/dokploy-deploy/entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

# www-data 권한 설정
RUN chown -R www-data:www-data /www

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
```

### 6.1 빌드 단계

1. `php:8.3.6-fpm` 베이스 이미지에 `nginx` 패키지 설치
2. PHP Extension 설치 (pdo, pdo_mysql, mysqli, curl, mbstring, gd)
3. PHP production 설정 적용 및 업로드 크기/메모리 제한 조정
4. PHP-FPM 커스텀 설정 복사 (XML 파일 처리 허용)
5. Nginx 설정 복사 및 기본 사이트 제거
6. 전체 소스 코드를 `/www`에 복사
7. entrypoint 스크립트 복사 (Windows 환경 CRLF 변환 포함)
8. www-data 권한 설정

### 6.2 설치된 PHP Extension

| Extension | 용도 |
|-----------|------|
| `pdo` | 데이터베이스 추상화 계층 |
| `pdo_mysql` | MySQL/MariaDB PDO 드라이버 |
| `mysqli` | MySQL/MariaDB 개선 드라이버 |
| `curl` | HTTP/HTTPS 통신 |
| `mbstring` | 멀티바이트 문자열 (한글 처리) |
| `gd` | 이미지 생성/처리 (Freetype, JPEG, WebP) |

### 6.3 PHP 설정

| 설정 | 값 | 설명 |
|------|-----|------|
| `upload_max_filesize` | 22M | 파일 업로드 최대 크기 |
| `post_max_size` | 22M | POST 요청 최대 크기 |
| `memory_limit` | 256M | PHP 스크립트 메모리 제한 |

### 프로세스 실행 방식

`CMD` 명령에서 `php-fpm -D` (데몬 모드)로 PHP-FPM을 백그라운드 실행한 후, `nginx -g 'daemon off;'`로 Nginx를 포그라운드 실행한다. Nginx가 메인 프로세스(PID 1)로 동작하여 컨테이너 라이프사이클을 관리한다.

---

## 7. Nginx 설정

### 핵심 소스코드

파일 경로: `docker/dokploy-deploy/nginx.conf`

```nginx
user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    client_max_body_size 22M;
    gzip on;

    server {
        listen 80;
        listen [::]:80;
        server_name _;
        root /www;
        index v7.php;

        # v6 backward compatibility
        location ~ ^/post/(list|view)\.php$ {
            rewrite ^ /v7.php last;
        }

        # 정적 파일 캐싱
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires max;
            access_log off;
            add_header Cache-Control "public";
        }

        # Sitemap 처리
        location ~ ^/sitemap.*\.xml$ {
            try_files /sitemap.xml =404;
            fastcgi_pass 127.0.0.1:9000;
            ...
        }

        # Google Search Console 확인
        location ~ ^/google.*\.html$ {
            rewrite ^/google.*\.html$ /google-search-verification.php last;
        }

        # Apple Universal Links
        location = /.well-known/apple-app-site-association {
            default_type application/json;
        }

        # 기본 라우팅
        location / {
            try_files $uri $uri/ /v7.php;
        }

        # PHP/XML 처리
        location ~ \.(php|xml)$ {
            include fastcgi_params;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
}
```

### 7.1 핵심 설정

| 설정 | 값 | 설명 |
|------|-----|------|
| **리슨 포트** | `80` (HTTP만) | SSL은 Traefik이 처리하므로 HTTP만 설정 |
| **server_name** | `_` (모든 호스트) | Traefik이 호스트 기반 라우팅 처리 |
| **document root** | `/www` | Dockerfile에서 소스 코드를 복사한 경로 |
| **fastcgi_pass** | `127.0.0.1:9000` | 같은 컨테이너 내 PHP-FPM (로컬 개발과 다름) |
| **client_max_body_size** | `22M` | PHP upload_max_filesize와 동일 |

### 7.2 라우팅 규칙

| 규칙 | URL 패턴 | 처리 |
|------|----------|------|
| **v6 호환** | `/post/list.php`, `/post/view.php` | `v7.php` 프론트 컨트롤러로 rewrite |
| **정적 파일** | `*.js, *.css, *.png` 등 | `expires max` 영구 캐싱 |
| **Sitemap** | `/sitemap*.xml` | PHP-FPM으로 전달 |
| **Google 확인** | `/google*.html` | `/google-search-verification.php`로 rewrite |
| **Apple Links** | `/.well-known/apple-app-site-association` | JSON 응답 |
| **기본** | 모든 경로 | `$uri` → `$uri/` → `/index.php` 폴백 |
| **PHP/XML** | `*.php, *.xml` | PHP-FPM(`127.0.0.1:9000`)으로 전달 |

**로컬 개발과의 차이점:**
- 로컬: `fastcgi_pass php:9000` (별도 php 컨테이너)
- Dokploy: `fastcgi_pass 127.0.0.1:9000` (같은 컨테이너 내 PHP-FPM)

---

## 8. Entrypoint 스크립트

### 핵심 소스코드

파일 경로: `docker/dokploy-deploy/entrypoint.sh`

```bash
#!/bin/bash
set -e

# db.config.php 생성
if [ ! -f /www/etc/db.config.php ]; then
    if [ -n "$DB_HOST" ]; then
        # 환경 변수가 설정된 경우 환경 변수로 생성
        cat > /www/etc/db.config.php << EOF
<?php
\$db_hostname = "${DB_HOST}";
\$db_username = "${DB_USER}";
\$db_password = "${DB_PASSWORD}";
\$db_database = "${DB_NAME}";
EOF
        echo "[entrypoint] db.config.php 생성 완료 (환경 변수 사용)"
    elif [ -f /www/etc/db.config.sample.php ]; then
        # sample 파일 복사
        cp /www/etc/db.config.sample.php /www/etc/db.config.php
        echo "[entrypoint] db.config.php 생성 완료 (sample 복사)"
    else
        echo "[entrypoint] 경고: db.config.php를 생성할 수 없습니다!"
    fi
fi

# www-data 권한 설정
chown -R www-data:www-data /www/var 2>/dev/null || true

exec "$@"
```

### 8.1 DB 설정 자동 생성

`etc/db.config.php` 파일은 `.gitignore`에 포함되어 Git 레포지토리에 없다. 컨테이너가 시작될 때 entrypoint 스크립트가 다음 우선순위로 자동 생성한다:

| 우선순위 | 조건 | 동작 |
|---------|------|------|
| 1 | 환경변수 `DB_HOST`가 설정됨 | 환경변수 값으로 `db.config.php` 생성 |
| 2 | `etc/db.config.sample.php` 파일 존재 | sample 파일을 복사 |
| 3 | 위 조건 모두 불충족 | 경고 메시지 출력 |

### 8.2 실행 흐름

1. `db.config.php` 파일이 없으면 자동 생성
2. `/www/var` 디렉토리에 www-data 권한 설정 (로그/캐시 파일 쓰기용)
3. `exec "$@"`로 CMD(`php-fpm -D && nginx -g 'daemon off;'`) 실행

---

## 9. PHP-FPM 커스텀 설정

파일 경로: `docker/dokploy-deploy/php-fpm-custom.conf`

```conf
; PhilGo v7 PHP-FPM 커스텀 설정
; XML 파일도 PHP로 처리할 수 있도록 허용
[www]
security.limit_extensions = .php .xml
```

- `.php`와 `.xml` 확장자 파일만 PHP-FPM에서 실행 허용
- Sitemap(XML) 파일이 PHP로 동적 생성되기 때문에 `.xml` 허용 필수
- 로컬 개발 환경의 `docker/etc/php-fpm.d/custom.conf`와 동일한 설정

---

## 10. Dokploy 설정 방법

### 10.1 Compose 서비스 생성

1. Dokploy 관리 패널(`http://209.97.169.136:3000`) 접속
2. **Create Service** > **Compose** 선택
3. 다음 항목 설정:

| 항목 | 값 | 설명 |
|------|-----|------|
| **Source** | GitHub | Git 레포지토리 연동 |
| **Repository** | `thruthesky/withcenter` | 모노레포 |
| **Branch** | `v7` | v7 개발 브랜치 |
| **Compose Path** | `./philgo/www/docker/dokploy-deploy/docker-compose.yml` | 모노레포 내 필고 프로젝트 위치 |

4. **Deploy** 버튼으로 배포 실행

### 10.2 도메인 설정

Dokploy는 Traefik을 내장하고 있어 자동으로 `*.traefik.me` 도메인을 제공한다.

| 항목 | 값 |
|------|-----|
| 기본 프리뷰 URL | `http://philgo.209.97.169.136.traefik.me` |
| 커스텀 도메인 | Dokploy 도메인 설정에서 추가 가능 |
| SSL 인증서 | Traefik이 Let's Encrypt로 자동 발급 |

---

## 11. 로컬 개발 환경과의 차이점

| 항목 | 로컬 개발 (`docker/compose.yaml`) | Dokploy 배포 (`docker/dokploy-deploy/docker-compose.yml`) |
|------|----------------------------------|--------------------------------------|
| **Nginx/PHP 구조** | 별도 컨테이너 (nginx + php) | 단일 컨테이너 (web) |
| **fastcgi_pass** | `php:9000` (컨테이너명) | `127.0.0.1:9000` (로컬호스트) |
| **SSL 처리** | 자체 서명 인증서 (Nginx에서 직접) | Traefik (Let's Encrypt 자동 발급) |
| **Nginx HTTPS 포트** | 443 | 없음 (HTTP 80만, SSL은 Traefik) |
| **소스 코드** | 볼륨 마운트 (실시간 반영) | COPY (빌드 시 복사, 재배포 필요) |
| **DB 데이터** | Host OS 바인드 마운트 (`docker/var/lib/mysql/`) | Named Volume (`mariadb-data`) |
| **DB 설정** | `etc/db.config.php` 수동 관리 | entrypoint.sh가 환경변수로 자동 생성 |
| **Docker 네트워크** | 기본 Docker Compose 네트워크 | `dokploy-network` 외부 네트워크 (Traefik 연동) |
| **빌드 컨텍스트** | `.` (docker/ 폴더가 컨텍스트) | `../..` (docker-compose.yml이 docker/dokploy-deploy/ 안에 있으므로 프로젝트 루트 지정) |
| **v6 호환** | v6 서비스 포함 (old_philgo_nginx, old_philgo_php) | v7만 포함 (v6 없음) |
| **PHP 버전** | 8.3.6 (v7) + 7.4.1 (v6) | 8.3.6만 |
| **gd Extension** | 로컬 PHP Dockerfile에 미포함 | Freetype/JPEG/WebP 포함 |
| **Healthcheck** | 없음 | MariaDB healthcheck (service_healthy) |

---

## 12. 주의사항

### 모노레포 Compose Path

Dokploy에서 Compose Path를 `./philgo/www/docker/dokploy-deploy/docker-compose.yml`로 정확히 지정해야 한다. 레포지토리 루트(`./docker/dokploy-deploy/docker-compose.yml`)가 아니다.

### DB 비밀번호

현재 `docker/dokploy-deploy/docker-compose.yml`에 DB 비밀번호가 하드코딩되어 있다. 프로덕션 환경에서는 Dokploy의 **Environment Variables** 기능으로 비밀번호를 관리하는 것을 권장한다.

### 소스 코드 업데이트

Dokploy 배포는 빌드 시 소스 코드를 COPY하므로, 코드 변경 시 **반드시 재배포**가 필요하다. 로컬 개발처럼 볼륨 마운트로 실시간 반영되지 않는다.

### CRLF 문제

`entrypoint.sh`는 Dockerfile에서 `sed -i 's/\r$//'` 명령으로 CRLF → LF 변환을 수행한다. Windows 환경에서 Git이 `core.autocrlf=true`로 설정되어 있으면 셸 스크립트가 CRLF로 저장될 수 있기 때문이다.

### Named Volume vs Bind Mount

| 방식 | 사용처 | 특징 |
|------|--------|------|
| **Named Volume** (`mariadb-data`) | Dokploy 배포 | Docker가 관리, `docker compose down`으로 삭제되지 않음, `-v` 플래그 시 삭제 |
| **Bind Mount** (`./var/lib/mysql`) | 로컬 개발 | Host OS 경로에 직접 매핑, 파일 직접 접근 가능 |

### dokploy-network 외부 네트워크

`docker-compose.yml`에서 `dokploy-network`는 `external: true`로 선언되어 있다. 이 네트워크는 Dokploy가 서버에 설치될 때 사전에 생성한 Docker 네트워크이다. 로컬 개발 환경에서 이 `docker-compose.yml`을 직접 실행하면 `dokploy-network`가 존재하지 않아 에러가 발생한다. 이 파일은 **Dokploy 서버에서만 사용**하는 것이며, 로컬 개발 시에는 `docker/compose.yaml`을 사용한다.

### build context 경로

`docker-compose.yml`이 `docker/dokploy-deploy/` 폴더 안에 위치하므로, build context는 `../..`으로 프로젝트 루트(`www/`)를 가리킨다. Dokploy에서 이 파일을 사용할 때도 Compose Path에서 docker-compose.yml의 위치를 인식하여 상대 경로를 올바르게 해석한다.

### DB 스키마 초기화

Dokploy 첫 배포 시 MariaDB는 빈 데이터베이스(`philgo`)만 생성된다. 테이블 스키마는 별도로 import해야 한다. `database/philgo.sql` 파일을 참고한다.
