# 필고 v7 프로덕션 서버 환경 설정 (philgo.com)

## 목차

- [1. 개요](#1-개요)
- [2. 서버 환경 구분](#2-서버-환경-구분)
- [3. 서버 시스템 정보](#3-서버-시스템-정보)
- [4. 소스코드 경로](#4-소스코드-경로)
- [5. PHP 설정](#5-php-설정)
- [6. Nginx 설정](#6-nginx-설정)
- [7. 전체 환경 비교표](#7-전체-환경-비교표)

---

## 1. 개요

### 핵심 개념

이 문서는 **`https://philgo.com`** 라이브 프로덕션 서버의 환경 설정을 다룬다.
**네이티브 Ubuntu Linux** 환경에서 Nginx + PHP-FPM + MariaDB를 직접 설치하여 운영한다.

### 설계 의도

- 프로덕션 환경에서 Docker 오버헤드 없이 네이티브 성능 확보
- Ubuntu 패키지 관리자(apt)를 통한 안정적인 PHP/Nginx/MariaDB 업데이트
- 서버에 직접 접속(SSH)하여 설정 변경 및 디버깅 가능

---

## 2. 서버 환경 구분

필고 v7은 3개의 서버 환경으로 운영된다.

| # | 환경 | URL | 방식 | 문서 |
|---|------|-----|------|------|
| 1 | **로컬 개발** | `https://local.philgo.com` | Docker Compose (Nginx + PHP-FPM + MariaDB) | [v7-docker.md](v7-docker.md) |
| 2 | **원격 테스트** | `https://philgo.net` | Dokploy (Docker Compose 기반 자동 배포) | [v7-dokploy.md](v7-dokploy.md) |
| 3 | **라이브 프로덕션** | **`https://philgo.com`** | **네이티브 Ubuntu** (Nginx + PHP-FPM 직접 설치) | **이 문서** |

> **주의:** `philgo.net`은 테스트 서버이며, 프로덕션 서비스가 아니다. 실제 사용자에게 서비스되는 라이브 프로덕션은 `philgo.com`뿐이다.

---

## 3. 서버 시스템 정보

| 항목 | 값 |
|------|-----|
| **서비스 URL** | `https://philgo.com` |
| 호스트명 | `philgo-db` |
| OS | Linux (Ubuntu) |
| 커널 | `6.8.0-90-generic #91-Ubuntu SMP PREEMPT_DYNAMIC` |
| 아키텍처 | `x86_64` |

---

## 4. 소스코드 경로

| 항목 | 경로 |
|------|------|
| **v7 홈페이지 소스코드 (프로덕션)** | `/home/thruthesky/v7/withcenter/philgo/www` |
| **로컬 개발 소스코드** | `/Users/thruthesky/apps/withcenter/philgo/www` |

> **참고:** 프로덕션 서버의 소스코드 경로(`/home/thruthesky/v7/withcenter/philgo/www`)는 로컬 개발 경로(`/Users/thruthesky/apps/withcenter/philgo/www`)와 다르다. 배포 시 Git pull 또는 Dokploy를 통해 프로덕션 서버에 반영된다.

---

## 5. PHP 설정

### PHP 버전 및 기본 정보

| 항목 | 값 |
|------|-----|
| PHP 버전 | **8.3** |
| 빌드 날짜 | 2026년 1월 7일 (Jan 7 2026 08:40:32) |
| 빌드 시스템 | Linux |
| Server API | **FPM/FastCGI** |
| Virtual Directory Support | disabled |

### PHP 설정 파일 경로

| 항목 | 경로 |
|------|------|
| php.ini 검색 경로 | `/etc/php/8.3/fpm` |
| **메인 설정 파일 (php.ini)** | `/etc/php/8.3/fpm/php.ini` |
| **추가 설정 디렉토리** | `/etc/php/8.3/fpm/conf.d` |

### 핵심 로직

- PHP-FPM은 시스템 서비스로 실행됨 (`systemctl` 또는 `service`로 관리)
- Nginx가 `fastcgi_pass`로 PHP-FPM 소켓/포트에 연결
- 추가 PHP 모듈 설정은 `/etc/php/8.3/fpm/conf.d/` 디렉토리에 `.ini` 파일로 관리

### PHP-FPM 서비스 관리 명령어

```bash
# PHP-FPM 상태 확인
systemctl status php8.3-fpm

# PHP-FPM 재시작
systemctl restart php8.3-fpm

# PHP-FPM 설정 리로드 (다운타임 없이)
systemctl reload php8.3-fpm

# PHP 설정 확인
php -i | grep "php.ini"
```

---

## 6. Nginx 설정

### 설정 파일 경로

| 항목 | 경로 |
|------|------|
| **메인 설정 파일** | `/etc/nginx/nginx.conf` |
| **사이트별 설정** | `/home/thruthesky/withcenter/philgo/www/etc/nginx/sites-enabled/*` |
| **Cloudflare Real IP 설정** | `/etc/nginx/conf.d/cloudflare-realip.conf` |
| **추가 설정 디렉토리** | `/etc/nginx/conf.d/*.conf` |
| **에러 로그** | `/var/log/nginx/error.log` |
| **접근 로그** | `/var/log/nginx/access.log` |

### 핵심 설정 요약

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log notice;
```

- **실행 사용자**: `www-data` (Ubuntu 기본 웹 서버 사용자)
- **워커 프로세스**: `auto` (CPU 코어 수에 맞게 자동 설정)
- **최대 업로드 크기**: `client_max_body_size 33M`
- **gzip 압축**: 활성화

### Cloudflare 통합

프로덕션 서버는 **Cloudflare CDN** 뒤에서 운영되며, Cloudflare가 전달하는 실제 방문자 IP를 복원한다.

```nginx
# Cloudflare가 전달하는 실제 방문자 IP 복원
real_ip_header CF-Connecting-IP;
real_ip_recursive on;
include /etc/nginx/conf.d/cloudflare-realip.conf;
```

### 로그 포맷

Cloudflare 관련 헤더를 포함하는 커스텀 로그 포맷(`cf_log`)을 사용한다.

```nginx
log_format cf_log '$remote_addr - $remote_user [$time_local] '
    '"$request" $status $body_bytes_sent '
    '"$http_referer" "$http_user_agent" '
    'cf_connecting_ip=$http_cf_connecting_ip '
    'cf_ray=$http_cf_ray '
    'x_forwarded_for=$http_x_forwarded_for '
    'via=$http_via '
    'host=$http_host';

access_log /var/log/nginx/access.log cf_log;
```

로그에 포함되는 Cloudflare 헤더:
- `CF-Connecting-IP`: 실제 방문자 IP
- `CF-Ray`: Cloudflare 요청 추적 ID
- `X-Forwarded-For`: 프록시 경유 IP 체인

### SQL Injection 방어 (Nginx 레벨)

쿼리스트링에서 SQL Injection 패턴을 감지하여 차단하는 `map` 규칙이 설정되어 있다.

```nginx
# 1) 키워드 검사: select 여부
map $args $has_select {
    default 0;
    ~*select 1;
}

# 2) 키워드 검사: 다른 SQL 키워드 여부
map $args $has_other {
    default 0;
    ~*(union|concat|group|having|insert|update|delete|sleep|information_schema) 1;
}

# 3) 둘 다 있으면 차단
map "$has_select$has_other" $block_sql {
    default 0;
    ~^11$ 1;
}
```

**핵심 로직**: `select` 키워드와 `union`, `concat`, `sleep` 등 SQL 키워드가 쿼리스트링에 **동시에** 존재할 때만 차단한다. 단일 키워드만으로는 차단하지 않아 정상 요청에 영향을 최소화한다.

### 사이트 설정 include 경로

```nginx
# 기본 sites-enabled 대신 프로젝트 내부 설정 사용
include /home/thruthesky/withcenter/philgo/www/etc/nginx/sites-enabled/*;
```

> **참고:** Nginx 사이트별 설정 파일은 프로젝트 소스코드 내(`etc/nginx/sites-enabled/`)에 위치하여 Git으로 관리된다.

### Nginx 서비스 관리 명령어

```bash
# Nginx 상태 확인
systemctl status nginx

# Nginx 재시작
systemctl restart nginx

# Nginx 설정 리로드 (다운타임 없이)
systemctl reload nginx

# Nginx 설정 문법 검사
nginx -t
```

---

## 7. 전체 환경 비교표

| 항목 | 로컬 개발 (Docker) | 테스트 (Dokploy) | 프로덕션 (네이티브) |
|------|-------------------|-----------------|-------------------|
| **URL** | `https://local.philgo.com` | `https://philgo.net` | **`https://philgo.com`** |
| **PHP 설치** | Docker (`php:8.3.6-fpm`) | Docker (`php:8.3.6-fpm`) | Ubuntu 패키지 (`php8.3-fpm`) |
| **php.ini 경로** | `docker/etc/php.ini` | Dockerfile 내장 | `/etc/php/8.3/fpm/php.ini` |
| **PHP-FPM 관리** | `docker compose restart php` | Dokploy 자동 | `systemctl restart php8.3-fpm` |
| **소스코드 경로** | `/Users/thruthesky/apps/withcenter/philgo/www` | Git 자동 배포 | `/home/thruthesky/v7/withcenter/philgo/www` |
| **Nginx 연결** | `fastcgi_pass php:9000` | `fastcgi_pass 127.0.0.1:9000` | `fastcgi_pass` Unix 소켓 또는 `127.0.0.1:9000` |
| **Nginx 설정** | `docker/etc/nginx/nginx.conf` | Dockerfile 내장 | `/etc/nginx/nginx.conf` + `sites-enabled/*` |
| **CDN** | 없음 | Cloudflare | Cloudflare |
| **최대 업로드** | 22M | 22M | 33M |
| **SSL/TLS** | 자체 서명 인증서 | Traefik 자동 | Cloudflare SSL |
| **문서** | [v7-docker.md](v7-docker.md) | [v7-dokploy.md](v7-dokploy.md) | **이 문서** |
