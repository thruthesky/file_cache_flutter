# 필고 v7 데이터베이스 관리 가이드

## 목차

- [1. 개요](#1-개요)
- [2. MariaDB 접속 정보](#2-mariadb-접속-정보)
  - [2.1 설정 파일](#21-설정-파일)
  - [2.2 Docker 컨테이너 접속](#22-docker-컨테이너-접속)
  - [2.3 호스트에서 CLI 접속](#23-호스트에서-cli-접속)
- [3. v7 Db 클래스 (Philgo\Utils\Db)](#3-v7-db-클래스-philgoutilsdb)
  - [3.1 클래스 개요](#31-클래스-개요)
  - [3.2 메서드 레퍼런스](#32-메서드-레퍼런스)
  - [3.3 사용 예제](#33-사용-예제)
  - [3.4 타입 안전성 규칙](#34-타입-안전성-규칙)
- [4. 레거시 pdo() 함수](#4-레거시-pdo-함수)
  - [4.1 함수 위치 및 구현](#41-함수-위치-및-구현)
  - [4.2 레거시 DB 헬퍼 함수](#42-레거시-db-헬퍼-함수)
- [5. v7 아키텍처에서 DB 접근 패턴](#5-v7-아키텍처에서-db-접근-패턴)
  - [5.1 3계층 구조](#51-3계층-구조)
  - [5.2 위젯에서 DB 접근 금지](#52-위젯에서-db-접근-금지)
- [6. DB 스키마](#6-db-스키마)
  - [6.1 스키마 파일 위치](#61-스키마-파일-위치)
  - [6.2 주요 테이블](#62-주요-테이블)
- [7. 테스트 환경 DB 설정](#7-테스트-환경-db-설정)
- [8. v7 vs 레거시 비교](#8-v7-vs-레거시-비교)
- [9. 프로덕션 DB 백업 및 로컬 복원](#9-프로덕션-db-백업-및-로컬-복원)
  - [9.1 서버 환경 구분](#91-서버-환경-구분)
  - [9.2 프로덕션 백업 구조](#92-프로덕션-백업-구조)
  - [9.3 백업 파일명 규칙](#93-백업-파일명-규칙)
  - [9.4 로컬로 백업 파일 다운로드](#94-로컬로-백업-파일-다운로드)
  - [9.5 로컬 Docker에 복원](#95-로컬-docker에-복원)
  - [9.6 테스트 서버(philgo.net) DB 백업](#96-테스트-서버philgonet-db-백업)
  - [9.7 특정 테이블만 백업/복원](#97-특정-테이블만-백업복원)
- [10. 개발 환경 DB 설치/백업/복원 (backup.sh / restore.sh)](#10-개발-환경-db-설치백업복원-backupsh--restoresh)
  - [10.1 개요](#101-개요)
  - [10.2 백업 스크립트 (backup.sh)](#102-백업-스크립트-backupsh)
  - [10.3 복원 스크립트 (restore.sh)](#103-복원-스크립트-restoresh)
  - [10.4 전체 워크플로우 예시](#104-전체-워크플로우-예시)
  - [10.5 주의사항](#105-주의사항)

---

## 1. 개요

### 핵심 개념

필고 v7은 **MariaDB 11.7.2** 를 데이터베이스로 사용한다. Docker 컨테이너 `mariadb`에서 실행되며, v6(레거시)과 v7(신규) 시스템이 **동일한 데이터베이스를 공유**한다.

### 설계 의도

- v6과 v7이 같은 DB/테이블을 사용하여 데이터 일관성 유지
- v7은 `Philgo\Utils\Db` 클래스로 PDO 접근을 캡슐화
- 레거시 `pdo()` 전역 함수와 100% 호환

### 핵심 파일

| 파일 | 용도 |
|------|------|
| `etc/db.config.php` | DB 접속 정보 (Docker 내부용, 호스트: `mariadb`) |
| `etc/db.config.dev.php` | DB 접속 정보 (호스트 직접 접속용, 호스트: `127.0.0.1`) |
| `etc/db.php` | 레거시 `pdo()` 함수 및 `db_*()` 헬퍼 함수 정의 |
| `lib/utils/Db.php` | v7 `Philgo\Utils\Db` 클래스 (PSR-4) |
| `.claude/skills/v7-skill/database/philgo.sql` | 전체 DB 스키마 덤프 |

---

## 2. MariaDB 접속 정보

### 2.1 설정 파일

**Docker 내부용** (`etc/db.config.php`):

```php
<?php
$db_hostname = "mariadb";      // Docker 컨테이너 이름
$db_username = "philgo";
$db_password = "asdf";
$db_database = "philgo";
```

**호스트 직접 접속용** (`etc/db.config.dev.php`):

```php
<?php
$db_hostname = "127.0.0.1";    // 호스트에서 직접 접속
$db_username = "philgo";
$db_password = "asdf";
$db_database = "philgo";
```

| 항목 | Docker 내부 | 호스트에서 접속 |
|------|------------|---------------|
| 호스트 | `mariadb` | `127.0.0.1` |
| 포트 | `3306` | `3306` |
| 데이터베이스 | `philgo` | `philgo` |
| 사용자 | `philgo` | `philgo` |
| 비밀번호 | `asdf` | `asdf` |
| Root 비밀번호 | `asdf` | `asdf` |

### 2.2 Docker 컨테이너 접속

Docker 컨테이너 내부에서 MariaDB에 직접 접속하는 방법:

```bash
# MariaDB 컨테이너에 접속하여 mysql 클라이언트 실행
docker exec -it mariadb mysql -u philgo -pasdf philgo

# Root 계정으로 접속
docker exec -it mariadb mysql -u root -pasdf philgo

# 단일 쿼리 실행
docker exec -it mariadb mysql -u philgo -pasdf philgo -e "SELECT COUNT(*) FROM sf_member;"

# SQL 파일 실행
docker exec -i mariadb mysql -u philgo -pasdf philgo < /path/to/query.sql
```

### 2.3 호스트에서 CLI 접속

호스트 OS(Mac/Windows)에서 MariaDB에 접속하는 방법:

```bash
# mysql 클라이언트로 접속 (MariaDB/MySQL 클라이언트 필요)
mysql -u philgo -pasdf -h 127.0.0.1 -P 3306 philgo

# 단일 쿼리 실행
mysql -u philgo -pasdf -h 127.0.0.1 -P 3306 philgo -e "SHOW TABLES;"

# 테이블 구조 확인
mysql -u philgo -pasdf -h 127.0.0.1 -P 3306 philgo -e "DESCRIBE sf_member;"

# DB 덤프 (백업)
mysqldump -u philgo -pasdf -h 127.0.0.1 -P 3306 philgo > backup.sql

# 특정 테이블만 덤프
mysqldump -u philgo -pasdf -h 127.0.0.1 -P 3306 philgo sf_member sf_post_data > tables.sql
```

> **참고:** 호스트에서 접속 시 Docker가 포트 3306을 호스트에 매핑하고 있어야 한다. Docker Compose 설정에서 `ports: - "3306:3306"`으로 매핑되어 있다.

> **참고:** 개발 환경 DB 초기 설치 및 경량 백업/복원은 [10장](#10-개발-환경-db-설치백업복원-backupsh--restoresh) 참조.

---

## 3. v7 Db 클래스 (Philgo\Utils\Db)

### 3.1 클래스 개요

**파일**: `lib/utils/Db.php`
**네임스페이스**: `Philgo\Utils\Db`
**로딩**: PSR-4 Autoloading (Composer)

v7 시스템에서 DB 접근은 반드시 `Db` 클래스를 통해서 한다. 싱글톤 패턴으로 PDO 인스턴스를 관리하며, prepared statement 기반으로 SQL 인젝션을 방지한다.

### 3.2 메서드 레퍼런스

```php
<?php
namespace Philgo\Utils;

class Db
{
    // PDO 인스턴스 반환 (싱글톤)
    public static function pdo(): PDO

    // Prepared Statement 생성 (Intelephense 타입 경고 제거용 래퍼)
    public static function prepare(string $sql): PDOStatement

    // 단일 행 조회 (prepare → execute → fetch 를 1줄로)
    // ⚠️ 반환값: array|false — false 체크 필수!
    public static function fetch(string $sql, array $params = [], int $fetchMode = PDO::FETCH_ASSOC): array|false

    // 다중 행 조회 (결과 없으면 빈 배열)
    public static function fetchAll(string $sql, array $params = [], int $fetchMode = PDO::FETCH_ASSOC): array

    // 단일 컬럼 값 (COUNT, MAX, MIN 등 스칼라 쿼리용)
    public static function fetchColumn(string $sql, array $params = [], int $column = 0): mixed

    // INSERT/UPDATE/DELETE 실행 (PDOStatement 반환 → rowCount() 접근 가능)
    public static function execute(string $sql, array $params = []): PDOStatement

    // INSERT 후 lastInsertId 정수 반환
    public static function insert(string $sql, array $params = []): int

    // DB 설정 파일 경로 수동 설정 (테스트용)
    public static function setConfigPath(string $path): void

    // PDO 연결 초기화 (테스트용)
    public static function reset(): void
}
```

### 3.3 사용 예제

```php
<?php
use Philgo\Utils\Db;

// ── 단일 행 조회 ──
$user = Db::fetch("SELECT * FROM sf_member WHERE idx = ?", [123]);
if ($user === false) {
    throw new RuntimeException("사용자를 찾을 수 없습니다");
}
// 이 시점에서 $user는 array 타입 확정

// Named parameter 사용
$user = Db::fetch("SELECT * FROM sf_member WHERE firebase_uid = :uid", ['uid' => 'abc123']);

// ── 다중 행 조회 ──
$posts = Db::fetchAll("SELECT * FROM sf_post_data WHERE post_id = ? LIMIT 10", ['freetalk']);
foreach ($posts as $post) {
    echo $post['subject'];
}

// ── 단일 컬럼 값 (COUNT, MAX 등) ──
$count = Db::fetchColumn("SELECT COUNT(*) FROM sf_member");
$name = Db::fetchColumn("SELECT name FROM sf_member WHERE idx = ?", [123]);

// ── UPDATE ──
Db::execute("UPDATE sf_member SET name = ? WHERE idx = ?", ['홍길동', 123]);

// ── DELETE (영향받은 행 수 확인) ──
$stmt = Db::execute("DELETE FROM sf_member WHERE idx = ?", [999]);
$affected = $stmt->rowCount();

// ── INSERT (AUTO_INCREMENT ID 반환) ──
$newIdx = Db::insert(
    "INSERT INTO sf_member (name, phone_number) VALUES (?, ?)",
    ['홍길동', '01012345678']
);

// ── PDO 인스턴스 직접 사용 ──
$pdo = Db::pdo();
$stmt = $pdo->prepare("SELECT * FROM sf_member WHERE idx = ?");
$stmt->execute([123]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);
```

### 3.4 타입 안전성 규칙

`Db::fetch()` 반환값은 `array|false`이다. `array` 타입이 필요한 곳에 바로 전달하면 **Intelephense P1006** 에러가 발생한다.

```php
// ✅ 올바른 사용법: false 체크 후 사용
$user = Db::fetch("SELECT * FROM sf_member WHERE idx = ?", [123]);
if ($user === false) {
    throw new RuntimeException("사용자를 찾을 수 없습니다");
}
// 이 시점에서 $user는 array 타입으로 확정
AuthService::loginUser($user);

// ❌ 잘못된 사용법: false 체크 없이 array 기대 함수에 전달
$user = Db::fetch("SELECT * FROM sf_member WHERE idx = ?", [123]);
AuthService::loginUser($user); // array|false를 array로 전달 → P1006 에러!
```

**nullable 타입 반환 시 캐스팅 필수:**

```php
// ✅ 올바른 사용법
public function isActive(): bool {
    return (bool) $this->active; // ?bool → bool 캐스팅
}

// ❌ 잘못된 사용법
public function isActive(): bool {
    return $this->active; // ?bool을 bool로 반환 → P1006!
}
```

---

## 4. 레거시 pdo() 함수

### 4.1 함수 위치 및 구현

**파일**: `etc/db.php` (boot.php에 의해 자동 로드)

```php
<?php
/**
 * PDO 인스턴스 반환 (싱글톤)
 */
function pdo(): PDO
{
    global $db_hostname, $db_database, $db_username, $db_password;
    static $pdo = null;

    if (isset($pdo) && $pdo instanceof PDO) {
        return $pdo;
    }

    try {
        $dsn = "mysql:host=$db_hostname;dbname=$db_database;charset=utf8mb4";
        $pdo = new PDO($dsn, $db_username, $db_password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        echo "DB Connection failed: " . $e->getMessage();
        throw new Exception("DB Connection failed");
    }

    return $pdo;
}

// 별칭
function get_db(): PDO {
    return pdo();
}
```

**핵심 로직:**
- 싱글톤 패턴: `static $pdo`로 한 번만 연결 생성
- 전역변수 `$db_hostname` 등을 `etc/db.config.php`에서 로드
- `charset=utf8mb4`로 한글/이모지 지원
- `ERRMODE_EXCEPTION`으로 에러 시 예외 발생

### 4.2 레거시 DB 헬퍼 함수

**파일**: `etc/db.php`

> ⚠️ **v7에서는 레거시 `db_*()` 함수 사용 금지.** 반드시 `Db` 클래스 사용.

| 레거시 함수 | 용도 | 반환값 | v7 대체 |
|------------|------|--------|---------|
| `db_select($query, $params)` | SELECT 다중 행 | `array` | `Db::fetchAll()` |
| `db_select_row($query, $params)` | SELECT 단일 행 | `array` (빈배열 가능) | `Db::fetch()` |
| `db_select_col($query, $params)` | SELECT 첫 컬럼 값 | `mixed\|null` | `Db::fetchColumn()` |
| `db_count($table, $where, $params)` | COUNT 조회 | `int` | `Db::fetchColumn()` |
| `db_insert($table, $data)` | INSERT | `int` (lastInsertId) | `Db::insert()` |
| `db_update($table, $data, $where, $params)` | UPDATE | `bool` | `Db::execute()` |
| `db_delete($table, $where, $params)` | DELETE | `bool` | `Db::execute()` |

**레거시 `db_select()` 제한사항:**
- `LIMIT` 필수 (없으면 에러)
- 최대 LIMIT 2,000개
- SELECT 쿼리만 허용

---

## 5. v7 아키텍처에서 DB 접근 패턴

### 5.1 3계층 구조

v7 시스템에서 DB 접근은 Controller → Service → Repository → Db 3계층 구조를 따른다.

```
JavaScript (func() 호출)
    ↓
api.php (API 게이트웨이)
    ↓
Controller (Philgo\<Module>\<Module>Controller)
    ↓
Service (Philgo\<Module>\<Module>Service)
    ↓
Repository (Philgo\<Module>\<Module>Repository)  [선택]
    ↓
Db::fetch(), Db::fetchAll(), Db::execute(), Db::insert()
    ↓
MariaDB
```

**Controller에서 직접 Db 사용 예제:**

```php
<?php
namespace Philgo\Post;

use Philgo\Utils\Db;

class PostController
{
    public function create(array $input): array
    {
        // 입력값 검증 ...

        $sql = "INSERT INTO sf_post_data (post_id, subject, content) VALUES (?, ?, ?)";
        $newIdx = Db::insert($sql, [
            $input['post_id'],
            $input['subject'],
            $input['content']
        ]);

        return ['idx' => $newIdx];
    }
}
```

### 5.2 위젯에서 DB 접근 금지

v7 위젯(`v7/widgets/**/*.php`)에서는 **Db 클래스를 직접 사용하지 않는다**. Service/Repository 계층을 통해 접근한다.

```php
// ❌ 잘못된 방법 (위젯에서 직접 DB 접근)
<?php
use Philgo\Utils\Db;
$posts = Db::fetchAll("SELECT * FROM sf_post_data LIMIT 10");
?>

// ✅ 올바른 방법 (Service 계층 사용)
<?php
use Philgo\Post\PostService;
$posts = (new PostService())->latestPosts(10);
?>
```

**이유:** Service → Repository → Db 캡슐화로 DB 변경 시 위젯 코드를 수정하지 않아도 된다.

---

## 6. DB 스키마

### 6.1 스키마 파일 위치

| 파일 | 용도 |
|------|------|
| `.claude/skills/v7-skill/database/philgo.sql` | 전체 DB 스키마 (최신 버전) |

스키마 파일에는 모든 테이블의 CREATE TABLE 문이 포함되어 있다. 테이블 구조, 컬럼명, 데이터 타입, 인덱스 등을 확인할 때 이 파일을 참조한다.

### 6.2 주요 테이블

| 테이블 | 용도 | 주요 컬럼 |
|--------|------|----------|
| `sf_member` | 회원 정보 | `idx`, `id`, `name`, `nickname`, `phone_number`, `firebase_uid` |
| `sf_post_data` | 게시글 | `idx`, `post_id`, `category`, `subject`, `content`, `idx_member` |
| `sf_post_config` | 게시판 설정 | `id`, `name`, `description` |
| `sf_comment_data` | 댓글 | `idx`, `idx_parent`, `idx_member`, `content` |
| `company` | 업소록 | `idx`, `company_name`, `address`, `phone` |
| `api_chat_message` | 채팅 메시지 | `idx`, `idx_chat_room`, `idx_member`, `message` |
| `api_chat_my_room` | 내 채팅방 | `idx`, `idx_member`, `idx_chat_room` |
| `sf_point_log` | 포인트 로그 | `idx`, `idx_member`, `point`, `reason` |

**테이블 구조 확인 명령:**

```bash
# Docker 컨테이너에서 테이블 구조 확인
docker exec -it mariadb mysql -u philgo -pasdf philgo -e "DESCRIBE sf_member;"

# 호스트에서 테이블 구조 확인
mysql -u philgo -pasdf -h 127.0.0.1 -P 3306 philgo -e "DESCRIBE sf_post_data;"

# 테이블 목록 확인
docker exec -it mariadb mysql -u philgo -pasdf philgo -e "SHOW TABLES;"

# 테이블 생성 SQL 확인
docker exec -it mariadb mysql -u philgo -pasdf philgo -e "SHOW CREATE TABLE sf_member\G"
```

---

## 7. 테스트 환경 DB 설정

### PHP 테스트에서 DB 접속

호스트에서 PHP 테스트를 직접 실행할 때는 `etc/db.config.dev.php` 설정 파일을 사용한다 (호스트: `127.0.0.1`).

```bash
# 테스트 실행 (호스트에서 직접)
php tests/db/db.test.php --db-config=etc/db.config.dev.php
```

### v7 Db 클래스 테스트 설정

```php
<?php
use Philgo\Utils\Db;

// 테스트용 DB 설정 파일 지정
Db::setConfigPath(__DIR__ . '/../../etc/db.config.dev.php');

// 쿼리 실행
$result = Db::fetch("SELECT 1 AS test");
assert($result['test'] === '1');

// 테스트 후 연결 초기화
Db::reset();
```

### 설정 파일 로드 우선순위 (Db 클래스)

1. `Db::setConfigPath()`로 설정된 경로
2. `ROOT_DIR` 상수가 정의된 경우: `ROOT_DIR . '/etc/db.config.php'`
3. 기본값: `lib/utils/../../etc/db.config.php` (= `etc/db.config.php`)

---

## 8. v7 vs 레거시 비교

| 항목 | 레거시 (`pdo()`, `db_*()`) | v7 (`Db` 클래스) |
|------|--------------------------|-----------------|
| **파일** | `etc/db.php` | `lib/utils/Db.php` |
| **네임스페이스** | 없음 (전역 함수) | `Philgo\Utils\Db` |
| **로딩** | `boot.php` → `etc/includes.php` | PSR-4 Autoloading |
| **단일 행 조회** | `db_select_row()` → `array` (빈배열) | `Db::fetch()` → `array\|false` |
| **다중 행 조회** | `db_select()` → `array` (LIMIT 필수) | `Db::fetchAll()` → `array` |
| **단일 값 조회** | `db_select_col()` → `mixed\|null` | `Db::fetchColumn()` → `mixed` |
| **INSERT** | `db_insert($table, $data)` → `int` | `Db::insert($sql, $params)` → `int` |
| **UPDATE** | `db_update($table, $data, $where, $params)` | `Db::execute($sql, $params)` |
| **DELETE** | `db_delete($table, $where, $params)` | `Db::execute($sql, $params)` |
| **LIMIT 제한** | 필수 (최대 2,000) | 없음 |
| **에러 처리** | `error()` 함수 호출 | `RuntimeException` 예외 |
| **사용 위치** | `page/`, `widget/` (레거시 페이지) | v7 Controller, Service, Repository |

### 선택 기준

- **v7 Controller/Service 개발**: `Db` 클래스 사용 (필수)
- **레거시 페이지 유지보수**: 기존 `pdo()`, `db_*()` 함수 유지
- **혼용**: 가능하지만 일관성 유지 권장 (같은 파일 내에서 하나만 사용)

---

## 9. 프로덕션 DB 백업 및 로컬 복원

### 9.1 서버 환경 구분

| # | 환경 | URL | DB 서버 |
|---|------|-----|---------|
| 1 | **로컬 개발** | `https://local.philgo.com` | Docker `mariadb` 컨테이너 (127.0.0.1:3306) |
| 2 | **테스트 서버** | `https://philgo.net` | Dokploy Docker `mariadb` 컨테이너 |
| 3 | **프로덕션** | **`https://philgo.com`** | 네이티브 MariaDB (`thruthesky@db`) |

> **⚠️ 주의:** `philgo.net`은 테스트 서버이다. 프로덕션은 `philgo.com`이다.

### 9.2 프로덕션 백업 구조

| 항목 | 내용 |
|------|------|
| **DB 서버 SSH** | `thruthesky@db` |
| **백업 저장 경로** | `/mnt/volume_sgp1_03` |
| **백업 스크립트** | `/home/thruthesky/backup.sh` |
| **백업 도구** | `mariadb-dump` |
| **백업 주기** | 매일 1회 (UTC 1:10 = KST 10:10) |
| **보존 방식** | 1주일 요일별 순환 |

### 9.3 백업 파일명 규칙

```
일반: 요일.sql.gz (예: Monday.sql.gz, Sunday.sql.gz)
매월 2일: 월.2nd.sql.gz (예: January.2nd.sql.gz)
```

**백업 파일 목록 확인:**

```bash
ssh thruthesky@db ls -lh /mnt/volume_sgp1_03
```

### 9.4 로컬로 백업 파일 다운로드

```bash
# 특정 요일 백업 다운로드
scp thruthesky@db:/mnt/volume_sgp1_03/Monday.sql.gz .

# 지정 폴더에 다운로드
scp thruthesky@db:/mnt/volume_sgp1_03/Monday.sql.gz ~/Data/philgo
```

> **팁:** 화요일에 작업하면 월요일 백업(`Monday.sql.gz`)을 다운로드한다.

### 9.5 로컬 Docker에 복원

**방법 1: 직접 복원 (⚠️ 5시간 이상 소요, 작업 중단됨)**

```bash
# 1. gzip 압축 해제
gunzip Monday.sql.gz

# 2. 로컬 MariaDB에 복원
mariadb -uphilgo -pasdf -h127.0.0.1 philgo < Monday.sql
```

**방법 2: 새 컨테이너 생성 후 교체 (권장 — 작업 중단 없음)**

1. 새 MariaDB 컨테이너 생성
2. 새 컨테이너에 백업 데이터 복구 (기존 컨테이너는 정상 작동)
3. 복구 완료 후 기존 컨테이너 중지
4. 새 컨테이너를 기존 이름으로 변경하여 교체

### 9.6 테스트 서버(philgo.net) DB 백업

테스트 서버는 Dokploy Docker 컨테이너로 운영된다.

```bash
# 서버 접속
ssh root@philgo.net

# Docker 컨테이너에서 덤프
docker exec <mariadb-컨테이너명> mysqldump -u philgo -pasdf philgo > /root/backup.sql

# 로컬로 다운로드
scp root@philgo.net:/root/backup.sql .
```

> Dokploy 환경에서는 컨테이너 이름이 자동 생성되므로 `docker ps | grep mariadb`로 확인 필요.

### 9.7 특정 테이블만 백업/복원

```bash
# 프로덕션에서 특정 테이블만 덤프
ssh thruthesky@db "mariadb-dump -uphilgo -pasdf philgo sf_post_data sf_member | gzip" > tables.sql.gz

# 로컬에 복원
gunzip tables.sql.gz
mariadb -uphilgo -pasdf -h127.0.0.1 philgo < tables.sql
```

---

## 10. 개발 환경 DB 설치/백업/복원 (backup.sh / restore.sh)

### 10.1 개요

새로운 개발 환경을 세팅하거나 DB를 초기화할 때 사용하는 **경량 백업/복원** 시스템이다. 프로덕션 전체 백업(9장)과 달리, **모든 테이블의 스키마 + 각 테이블의 최근 1,000개 레코드**만 추출하여 빠르게 개발 환경을 구축할 수 있다.

| 항목 | 내용 |
|------|------|
| **백업 스크립트** | `etc/install/backup.sh` |
| **복원 스크립트** | `etc/install/restore.sh` |
| **출력 파일** | `etc/install/philgo_install.sql.gz` (gzip 압축) |
| **추출 데이터** | 전체 테이블 스키마 + 각 테이블 최근 1,000개 레코드 |
| **용도** | 새 개발 환경 초기 세팅, DB 초기화, 팀원 간 DB 동기화 |

### 10.2 백업 스크립트 (backup.sh)

#### 실행 방법

```bash
# 프로젝트 루트에서 실행
cd /Users/thruthesky/apps/withcenter/philgo/www
bash etc/install/backup.sh
```

#### 동작 순서

1. Docker 컨테이너 `mariadb` 실행 여부 확인
2. **스키마 덤프**: `mariadb-dump --no-data`로 전체 테이블 구조 추출
3. **테이블 목록 조회**: `INFORMATION_SCHEMA`에서 모든 테이블과 PRIMARY KEY 정보 조회
4. **데이터 덤프**: 각 테이블에서 PK 기준 내림차순으로 최근 1,000개 레코드 추출
   - PK가 있는 테이블: `ORDER BY PK_COL DESC LIMIT 1000`
   - PK가 없는 테이블: `LIMIT 1000`
   - 빈 테이블: 건너뜀
5. **SQL 파일 생성**: `etc/install/philgo_install.sql`
6. **gzip 압축**: `etc/install/philgo_install.sql.gz` 생성 (원본 .sql 삭제)

#### 옵션

```bash
# 기본 실행 (etc/install/philgo_install.sql.gz 생성)
bash etc/install/backup.sh

# 출력 경로 지정 (지정된 경로.gz로 압축 저장)
bash etc/install/backup.sh --output /tmp/my_backup.sql

# 테이블당 추출 레코드 수 변경
bash etc/install/backup.sh --records 500

# 도움말
bash etc/install/backup.sh --help
```

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| `--output <경로>` | `etc/install/philgo_install.sql` | 출력 SQL 파일 경로 (최종적으로 .gz로 압축) |
| `--records <숫자>` | `1000` | 테이블당 추출할 최대 레코드 수 |

### 10.3 복원 스크립트 (restore.sh)

#### 실행 방법

```bash
# 기본 실행 (etc/install/philgo_install.sql.gz 복원)
bash etc/install/restore.sh
```

#### 동작 순서

1. Docker 컨테이너 `mariadb` 실행 여부 확인
2. 입력 파일(`.sql.gz` 또는 `.sql`) 존재 확인
3. 데이터베이스 생성 (없는 경우) 및 사용자 권한 설정
4. (선택) `--drop-existing` 옵션 시 기존 테이블 전부 삭제
5. SQL 주입:
   - `.gz` 파일: `gunzip -c`로 해제하며 파이프로 전달
   - `.sql` 파일: 직접 파이프로 전달
6. 복원 결과 확인 (테이블 수 표시)

#### 옵션

```bash
# 기본 실행
bash etc/install/restore.sh

# 특정 SQL 파일 복원
bash etc/install/restore.sh --input /path/to/backup.sql.gz

# 기존 테이블 삭제 후 복원 (클린 설치)
bash etc/install/restore.sh --drop-existing

# 다른 데이터베이스에 복원
bash etc/install/restore.sh --db-name new_philgo

# 도움말
bash etc/install/restore.sh --help
```

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| `--input <경로>` | `etc/install/philgo_install.sql.gz` | 입력 파일 (.sql.gz 또는 .sql) |
| `--db-name <이름>` | `philgo` | 대상 데이터베이스 이름 |
| `--db-user <사용자>` | `philgo` | DB 사용자 |
| `--db-pass <비밀번호>` | `asdf` | DB 비밀번호 |
| `--container <이름>` | `mariadb` | Docker 컨테이너 이름 |
| `--drop-existing` | - | 기존 테이블 삭제 후 복원 |

### 10.4 전체 워크플로우 예시

#### 새 개발 환경 초기 세팅

```bash
# 1. Docker 컨테이너 시작
docker compose up -d

# 2. DB 복원 (기존 테이블 삭제 후 클린 설치)
bash etc/install/restore.sh --drop-existing

# 3. 웹사이트 접속 확인
# https://local.philgo.com
```

#### DB 백업 후 팀원에게 공유

```bash
# 1. 현재 DB에서 백업 생성
bash etc/install/backup.sh

# 2. 생성된 파일: etc/install/philgo_install.sql.gz
# 이 파일을 Git에 커밋하여 팀원과 공유

# 3. 팀원은 아래 명령으로 복원
bash etc/install/restore.sh --drop-existing
```

#### DB 초기화 (데이터 리셋)

```bash
# 기존 테이블 전부 삭제 후 백업 데이터로 복원
bash etc/install/restore.sh --drop-existing
```

### 10.5 주의사항

| 항목 | 내용 |
|------|------|
| **Docker 필수** | `mariadb` 컨테이너가 실행 중이어야 한다 |
| **MariaDB 11.7+** | `mariadb`/`mariadb-dump` 명령 사용 (mysql/mysqldump 아님) |
| **경량 백업** | 프로덕션 전체 데이터가 아닌 테이블당 최근 1,000개만 포함 |
| **비밀번호 평문** | 개발 환경 전용. 프로덕션 비밀번호를 하드코딩하지 말 것 |
| **gzip 압축** | backup.sh는 항상 `.sql.gz`로 압축 저장. restore.sh는 `.gz`와 `.sql` 모두 지원 |
