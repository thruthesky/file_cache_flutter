# Upload API - v7 시스템 (PSR-4)

## 목차

- [1. 개요](#1-개요)
- [2. CoT 분석: 단계별 설계](#2-cot-분석-단계별-설계)
- [3. ToT 분석: 설계 결정 트리](#3-tot-분석-설계-결정-트리)
- [4. DB 스키마](#4-db-스키마)
- [5. 아키텍처](#5-아키텍처)
- [6. 파일 구조](#6-파일-구조)
- [7. Entity 클래스](#7-entity-클래스)
- [8. Repository 클래스](#8-repository-클래스)
- [9. Service 클래스](#9-service-클래스)
- [10. Controller 클래스](#10-controller-클래스)
- [11. API 엔드포인트](#11-api-엔드포인트)
- [12. PSR-4 Autoload 설정](#12-psr-4-autoload-설정)
- [13. 보안 및 검증](#13-보안-및-검증)
- [14. 테스트 계획](#14-테스트-계획)
- [15. 기존 시스템과의 차이점](#15-기존-시스템과의-차이점)

---

## 1. 개요

### 1.1 배경

기존 필고 파일 업로드는 **외부 파일 서버**(`file.philgo.com`)를 통해 처리된다. v7 시스템에서는 **로컬 파일 시스템**(`./uploads/`)에 직접 저장하는 새로운 독립적인 업로드 시스템을 구축한다.

### 1.2 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **로컬 저장** | `./uploads/{sf_member.idx}/` 폴더에 파일 저장 (외부 서버 불필요) |
| **소유자 기반 접근제어** | 파일은 업로더의 `sf_member.idx` 폴더에 저장, 수정/삭제 시 소유자 검증 |
| **DB 메타데이터** | `uploads` 테이블에 파일 메타정보 저장 (원본명, 크기, MIME, 모듈, 코드 등) |
| **모듈 연동** | `module` + `code` 필드로 어느 기능에서 사용되는지 추적 |
| **attached 상태** | 실제 사용 여부를 0/1로 관리, 미사용 파일 정리 가능 |
| **기존 코드 공존** | 기존 외부 파일 서버 업로드 시스템과 완벽 공존 |

### 1.3 관련 테이블

- **uploads**: 새로운 v7 업로드 메타데이터 테이블
- **sf_member**: 회원 정보 (idx: `int(10) UNSIGNED`)

---

## 2. CoT 분석: 단계별 설계

### Step 1: 문제 핵심 파악

기존 시스템은 외부 파일 서버(`file.philgo.com`)에 의존하며, Firebase UID로 인증한다.
v7 시스템은 **자체 로컬 저장소**를 사용하고, **DB 테이블**로 메타데이터를 관리해야 한다.

핵심 질문:
- 파일을 어디에 저장할 것인가? → `./uploads/{회원번호}/`
- 소유권을 어떻게 검증할 것인가? → 폴더 경로의 회원번호로 검증
- 파일 메타정보는 어떻게 관리할 것인가? → `uploads` DB 테이블
- API는 어떤 구조로 제공할 것인가? → v7 Controller/Service 패턴

### Step 2: 계층 구조 설계

```
클라이언트 (JavaScript FormData)
    ↓ POST /api.php (method=upload.upload, multipart/form-data)
UploadController
    ↓ 입력 검증 + 파일 수신
UploadService
    ↓ 파일 저장 로직 + 비즈니스 규칙
UploadRepository
    ↓ DB CRUD (uploads 테이블)
Db::pdo()
    ↓
MariaDB (uploads 테이블)

동시에:
UploadService → 파일 시스템 (./uploads/{idx}/)
```

### Step 3: 파일 저장 전략

```
프로젝트 루트/
├── uploads/                    ← .gitignore에 추가
│   ├── 123/                   ← sf_member.idx = 123
│   │   ├── abc123def456.jpg   ← 유니크 파일명 (충돌 방지)
│   │   ├── xyz789ghi012.pdf
│   │   └── ...
│   ├── 456/                   ← sf_member.idx = 456
│   │   └── ...
│   └── ...
```

파일명 생성 규칙: `uniqid() . '_' . time() . '.' . 확장자`
→ 예: `67a1b2c3d4e5f_1709876543.jpg`

### Step 4: URL 설계

저장된 파일의 접근 URL (상대경로):
```
/uploads/{회원번호}/{파일명}
```
예: `/uploads/123/67a1b2c3d4e5f_1709876543.jpg`

DB의 `url` 컬럼에 이 상대경로를 저장한다.

### Step 5: 소유권 검증 로직

```
수정/삭제 요청 시:
1. uploads 테이블에서 idx로 레코드 조회
2. 레코드의 idx_member와 요청자의 sf_member.idx 비교
3. 불일치 시 RuntimeException throw
4. 일치 시 파일 시스템 + DB에서 삭제
```

---

## 3. ToT 분석: 설계 결정 트리

### Branch 1: 파일명 생성 전략

| 방안 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| A. 원본 파일명 유지 | 직관적 | 동일 파일명 충돌, 한글/특수문자 문제 | |
| B. UUID 기반 | 충돌 없음 | 길이가 김 | |
| **C. uniqid + timestamp** | **충돌 없음, 적당한 길이, 시간순 정렬 가능** | | **✅ 선택** |

### Branch 2: Repository 패턴 도입 여부

| 방안 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| A. Service에서 직접 DB 접근 | 단순, User 모듈과 동일 | DB 로직과 비즈니스 로직 혼재 | |
| **B. Repository 분리** | **DB 로직 분리, 테스트 용이, CRUD 재사용** | 파일 1개 추가 | **✅ 선택** |

> 파일 업로드는 CRUD가 명확하고, 파일 시스템 + DB 동시 처리가 필요하므로 Repository 분리가 적합하다.

### Branch 3: 인증 방식

| 방안 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| A. Firebase UID (기존 방식) | 기존 호환 | v7은 boot.php 미포함, Firebase 연동 복잡 | |
| **B. sf_member.idx 직접 전달** | **단순, v7 독립적** | 클라이언트에서 idx 전달 필요 | **✅ 선택** |
| C. JWT 토큰 | 보안 강화 | 구현 복잡, 과도한 설계 | |

> v7 API에서는 `idx_member` 파라미터로 회원번호를 직접 전달받아 사용한다.
> 추후 인증 미들웨어가 추가되면 자동으로 현재 사용자를 주입할 수 있다.

### Branch 4: MIME 타입 처리

| 방안 | 장점 | 단점 | **선택** |
|------|------|------|----------|
| A. 클라이언트 전달값 사용 | 단순 | 위변조 가능 | |
| **B. 서버에서 확장자 기반 판별** | **신뢰성, 간편** | 확장자 변조 가능 | **✅ 선택** |
| C. finfo_file() 사용 | 가장 정확 | 서버 부하 | (필요 시 추가) |

---

## 4. DB 스키마

### uploads 테이블

```sql
CREATE TABLE `uploads` (
    `idx` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `idx_member` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '회원번호 (sf_member.idx)',
    `created_at` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '생성 시간 (Unix timestamp)',
    `updated_at` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '수정 시간 (Unix timestamp)',
    `name` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '원본 파일 이름',
    `size` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '원본 파일 크기 (bytes)',
    `type` VARCHAR(100) NOT NULL DEFAULT '' COMMENT 'MIME 타입 (예: image/jpeg)',
    `module` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '사용 모듈 (예: user, post, comment, company)',
    `code` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '모듈 내 용도 (예: profile_photo, cover_photo, content)',
    `url` VARCHAR(500) NOT NULL DEFAULT '' COMMENT '다운로드 URL (상대경로, 예: /uploads/123/abc.jpg)',
    `attached` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '사용 여부 (0=미사용, 1=사용중)',
    PRIMARY KEY (`idx`),
    KEY `idx_member` (`idx_member`),
    KEY `module_code` (`module`, `code`),
    KEY `attached` (`attached`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='v7 파일 업로드 메타데이터';
```

### 컬럼 상세 설명

| 컬럼 | 타입 | 설명 | 예시 |
|------|------|------|------|
| `idx` | INT UNSIGNED AUTO_INCREMENT | 고유 식별자 | 1, 2, 3 |
| `idx_member` | INT UNSIGNED | 업로더 회원번호 | 123 (sf_member.idx) |
| `created_at` | INT UNSIGNED | 생성 시간 (Unix timestamp) | 1709876543 |
| `updated_at` | INT UNSIGNED | 수정 시간 (Unix timestamp) | 1709876543 |
| `name` | VARCHAR(255) | 원본 파일명 | `my_photo.jpg` |
| `size` | INT UNSIGNED | 파일 크기 (bytes) | 1048576 (1MB) |
| `type` | VARCHAR(100) | MIME 타입 | `image/jpeg` |
| `module` | VARCHAR(50) | 사용 모듈 | `user`, `post`, `comment`, `company` |
| `code` | VARCHAR(50) | 모듈 내 용도 | `profile_photo`, `cover_photo`, `content` |
| `url` | VARCHAR(500) | 다운로드 상대경로 | `/uploads/123/67a1b2c3_1709876543.jpg` |
| `attached` | TINYINT(1) | 사용 여부 | 0=미사용, 1=사용중 |

### 인덱스 설계

| 인덱스 | 컬럼 | 용도 |
|--------|------|------|
| PRIMARY | `idx` | 기본키 |
| `idx_member` | `idx_member` | 회원별 파일 조회 |
| `module_code` | `module`, `code` | 모듈+용도별 파일 조회 |
| `attached` | `attached` | 미사용 파일 정리 |

---

## 5. 아키텍처

### 호출 흐름도

```
JavaScript: func('upload.upload', FormData)
    │
    ▼ POST /api.php (multipart/form-data + method=upload.upload)
    │
    ▼ api.php (PSR-4 Autoloading)
    │  ├─ require vendor/autoload.php
    │  ├─ RequestUtils::parseMethod() → ["upload", "upload"]
    │  ├─ FQCN 생성: "Philgo\Upload\UploadController"
    │  └─ new UploadController() → upload($input)
    │
    ▼ Philgo\Upload\UploadController::upload()
    │  ├─ 입력 검증 (idx_member, $_FILES)
    │  └─ UploadService::store($input)
    │
    ▼ Philgo\Upload\UploadService::store()
    │  ├─ 파일 시스템에 저장: ./uploads/{idx_member}/{유니크파일명}
    │  ├─ MIME 타입 판별
    │  └─ UploadRepository::create($data)
    │
    ▼ Philgo\Upload\UploadRepository::create()
    │  └─ Db::pdo() → INSERT INTO uploads ...
    │
    ▼ JSON 응답: {"idx": 1, "url": "/uploads/123/abc.jpg", ...}
```

### 삭제 흐름도

```
JavaScript: func('upload.delete', {idx: 1, idx_member: 123})
    │
    ▼ UploadController::delete($input)
    │  └─ UploadService::remove($input)
    │
    ▼ UploadService::remove()
    │  ├─ UploadRepository::findByIdx($idx)
    │  ├─ 소유자 검증: record.idx_member === input.idx_member
    │  ├─ 파일 시스템에서 삭제: unlink(./uploads/123/abc.jpg)
    │  └─ UploadRepository::deleteByIdx($idx)
    │
    ▼ JSON 응답: {"data": true}
```

---

## 6. 파일 구조

```
lib/upload/
├── UploadController.php      # Philgo\Upload\UploadController (API 엔드포인트)
├── UploadService.php          # Philgo\Upload\UploadService (비즈니스 로직 + 파일 I/O)
├── UploadRepository.php       # Philgo\Upload\UploadRepository (DB CRUD)
└── UploadEntity.php           # Philgo\Upload\UploadEntity (데이터 구조체, POPO)
```

### PSR-4 매핑 (composer.json에 추가)

```json
"autoload": {
    "psr-4": {
        "Philgo\\Utils\\": "lib/utils/",
        "Philgo\\User\\": "lib/user/",
        "Philgo\\Upload\\": "lib/upload/"
    }
}
```

---

## 7. Entity 클래스

```php
<?php
/**
 * @file lib/upload/UploadEntity.php
 * @brief 업로드 파일 데이터 구조체 (POPO)
 *
 * uploads 테이블의 한 행을 나타내는 Entity 클래스이다.
 * DB 조회 결과를 객체로 변환하거나, 객체를 배열로 변환할 때 사용한다.
 *
 * PSR-4: Philgo\Upload\UploadEntity
 */

namespace Philgo\Upload;

class UploadEntity
{
    public int $idx = 0;
    public int $idx_member = 0;
    public int $created_at = 0;
    public int $updated_at = 0;
    public string $name = '';
    public int $size = 0;
    public string $type = '';
    public string $module = '';
    public string $code = '';
    public string $url = '';
    public int $attached = 0;

    /**
     * 배열(DB 행)을 UploadEntity 객체로 변환한다.
     *
     * @param array $data DB 행 데이터
     * @return self UploadEntity 객체
     */
    public static function fromArray(array $data): self
    {
        $entity = new self();
        $entity->idx = (int)($data['idx'] ?? 0);
        $entity->idx_member = (int)($data['idx_member'] ?? 0);
        $entity->created_at = (int)($data['created_at'] ?? 0);
        $entity->updated_at = (int)($data['updated_at'] ?? 0);
        $entity->name = (string)($data['name'] ?? '');
        $entity->size = (int)($data['size'] ?? 0);
        $entity->type = (string)($data['type'] ?? '');
        $entity->module = (string)($data['module'] ?? '');
        $entity->code = (string)($data['code'] ?? '');
        $entity->url = (string)($data['url'] ?? '');
        $entity->attached = (int)($data['attached'] ?? 0);
        return $entity;
    }

    /**
     * UploadEntity 객체를 배열로 변환한다.
     *
     * @return array 배열 데이터
     */
    public function toArray(): array
    {
        return [
            'idx' => $this->idx,
            'idx_member' => $this->idx_member,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'name' => $this->name,
            'size' => $this->size,
            'type' => $this->type,
            'module' => $this->module,
            'code' => $this->code,
            'url' => $this->url,
            'attached' => $this->attached,
        ];
    }
}
```

---

## 8. Repository 클래스

```php
<?php
/**
 * @file lib/upload/UploadRepository.php
 * @brief 업로드 파일 DB CRUD Repository
 *
 * uploads 테이블에 대한 모든 DB 쿼리를 담당한다.
 * Service 계층에서 호출하며, Db::pdo()를 사용한다.
 *
 * PSR-4: Philgo\Upload\UploadRepository
 */

namespace Philgo\Upload;

use Philgo\Utils\Db;
use PDO;
use RuntimeException;

class UploadRepository
{
    /**
     * 새 업로드 레코드를 생성한다.
     *
     * @param array $data 삽입할 데이터
     * @return int 생성된 레코드의 idx
     * @throws RuntimeException 삽입 실패 시
     */
    public static function create(array $data): int
    {
        $sql = "INSERT INTO uploads (idx_member, created_at, updated_at, name, size, type, module, code, url, attached)
                VALUES (:idx_member, :created_at, :updated_at, :name, :size, :type, :module, :code, :url, :attached)";
        $stmt = Db::pdo()->prepare($sql);
        $stmt->execute([
            'idx_member' => $data['idx_member'],
            'created_at' => $data['created_at'],
            'updated_at' => $data['updated_at'],
            'name' => $data['name'],
            'size' => $data['size'],
            'type' => $data['type'],
            'module' => $data['module'] ?? '',
            'code' => $data['code'] ?? '',
            'url' => $data['url'],
            'attached' => $data['attached'] ?? 0,
        ]);
        $idx = (int)Db::pdo()->lastInsertId();
        if ($idx === 0) {
            throw new RuntimeException('업로드 레코드 생성에 실패했습니다.');
        }
        return $idx;
    }

    /**
     * idx로 업로드 레코드를 조회한다.
     *
     * @param int $idx 업로드 레코드 idx
     * @return UploadEntity|null 존재하면 Entity, 없으면 null
     */
    public static function findByIdx(int $idx): ?UploadEntity
    {
        $stmt = Db::pdo()->prepare("SELECT * FROM uploads WHERE idx = :idx");
        $stmt->execute(['idx' => $idx]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row === false) {
            return null;
        }
        return UploadEntity::fromArray($row);
    }

    /**
     * 회원번호로 업로드 목록을 조회한다.
     *
     * @param int $idxMember 회원번호
     * @param int $limit 최대 조회 수
     * @param int $offset 오프셋
     * @return UploadEntity[] 업로드 Entity 배열
     */
    public static function findByMember(int $idxMember, int $limit = 100, int $offset = 0): array
    {
        $stmt = Db::pdo()->prepare(
            "SELECT * FROM uploads WHERE idx_member = :idx_member ORDER BY idx DESC LIMIT :limit OFFSET :offset"
        );
        $stmt->bindValue('idx_member', $idxMember, PDO::PARAM_INT);
        $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue('offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return array_map(fn($row) => UploadEntity::fromArray($row), $rows);
    }

    /**
     * module, code로 업로드 목록을 조회한다.
     *
     * @param string $module 모듈명
     * @param string $code 용도 코드
     * @param int $limit 최대 조회 수
     * @return UploadEntity[] 업로드 Entity 배열
     */
    public static function findByModuleCode(string $module, string $code = '', int $limit = 100): array
    {
        $sql = "SELECT * FROM uploads WHERE module = :module";
        $params = ['module' => $module];
        if (!empty($code)) {
            $sql .= " AND code = :code";
            $params['code'] = $code;
        }
        $sql .= " ORDER BY idx DESC LIMIT {$limit}";
        $stmt = Db::pdo()->prepare($sql);
        $stmt->execute($params);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return array_map(fn($row) => UploadEntity::fromArray($row), $rows);
    }

    /**
     * attached 상태를 업데이트한다.
     *
     * @param int $idx 업로드 idx
     * @param int $attached 사용 여부 (0 또는 1)
     * @return bool 성공 여부
     */
    public static function updateAttached(int $idx, int $attached): bool
    {
        $stmt = Db::pdo()->prepare(
            "UPDATE uploads SET attached = :attached, updated_at = :updated_at WHERE idx = :idx"
        );
        return $stmt->execute([
            'attached' => $attached,
            'updated_at' => time(),
            'idx' => $idx,
        ]);
    }

    /**
     * idx로 업로드 레코드를 삭제한다.
     *
     * @param int $idx 업로드 idx
     * @return bool 성공 여부
     */
    public static function deleteByIdx(int $idx): bool
    {
        $stmt = Db::pdo()->prepare("DELETE FROM uploads WHERE idx = :idx");
        return $stmt->execute(['idx' => $idx]);
    }

    /**
     * 미사용(attached=0) 파일 중 특정 시간 이전에 생성된 레코드를 조회한다.
     * 정리(cleanup) 작업용이다.
     *
     * @param int $beforeTimestamp 이 시간 이전에 생성된 레코드
     * @param int $limit 최대 조회 수
     * @return UploadEntity[] 미사용 업로드 Entity 배열
     */
    public static function findUnattachedBefore(int $beforeTimestamp, int $limit = 100): array
    {
        $stmt = Db::pdo()->prepare(
            "SELECT * FROM uploads WHERE attached = 0 AND created_at < :before ORDER BY idx ASC LIMIT :limit"
        );
        $stmt->bindValue('before', $beforeTimestamp, PDO::PARAM_INT);
        $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return array_map(fn($row) => UploadEntity::fromArray($row), $rows);
    }
}
```

---

## 9. Service 클래스

```php
<?php
/**
 * @file lib/upload/UploadService.php
 * @brief 업로드 파일 비즈니스 로직 + 파일 I/O
 *
 * 파일 시스템 저장/삭제와 DB 메타데이터 관리를 담당한다.
 * Controller에서 호출하며, Repository를 통해 DB에 접근한다.
 *
 * PSR-4: Philgo\Upload\UploadService
 */

namespace Philgo\Upload;

use RuntimeException;

class UploadService
{
    /**
     * 업로드 파일 저장 디렉토리의 베이스 경로를 반환한다.
     *
     * @return string 절대경로 (예: /var/www/html/uploads)
     */
    private static function getUploadBasePath(): string
    {
        return (defined('ROOT_DIR') ? ROOT_DIR : dirname(__DIR__, 2)) . '/uploads';
    }

    /**
     * 파일을 업로드하고 DB에 메타데이터를 저장한다.
     *
     * @param array $input 입력 파라미터 (idx_member 필수, module/code 선택)
     * @return UploadEntity 생성된 업로드 Entity
     * @throws RuntimeException 업로드 실패 시
     */
    public static function store(array $input): UploadEntity
    {
        // 필수 파라미터 검증
        $idxMember = (int)($input['idx_member'] ?? 0);
        if ($idxMember <= 0) {
            throw new RuntimeException('idx_member가 필요합니다.');
        }

        // $_FILES 검증
        if (empty($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
            $errorCode = $_FILES['file']['error'] ?? -1;
            throw new RuntimeException("파일 업로드에 실패했습니다. (error: {$errorCode})");
        }

        $file = $_FILES['file'];
        $originalName = $file['name'];
        $fileSize = $file['size'];
        $tmpPath = $file['tmp_name'];

        // 확장자 추출 및 MIME 타입 판별
        $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
        $mimeType = self::getMimeType($extension);

        // 유니크 파일명 생성
        $uniqueName = uniqid() . '_' . time() . '.' . $extension;

        // 저장 디렉토리 생성
        $uploadDir = self::getUploadBasePath() . '/' . $idxMember;
        if (!is_dir($uploadDir)) {
            if (!mkdir($uploadDir, 0755, true)) {
                throw new RuntimeException("업로드 디렉토리를 생성할 수 없습니다: {$uploadDir}");
            }
        }

        // 파일 이동
        $destPath = $uploadDir . '/' . $uniqueName;
        if (!move_uploaded_file($tmpPath, $destPath)) {
            throw new RuntimeException('파일 저장에 실패했습니다.');
        }

        // URL (상대경로)
        $url = '/uploads/' . $idxMember . '/' . $uniqueName;

        // DB 저장
        $now = time();
        $idx = UploadRepository::create([
            'idx_member' => $idxMember,
            'created_at' => $now,
            'updated_at' => $now,
            'name' => $originalName,
            'size' => $fileSize,
            'type' => $mimeType,
            'module' => $input['module'] ?? '',
            'code' => $input['code'] ?? '',
            'url' => $url,
            'attached' => (int)($input['attached'] ?? 0),
        ]);

        // 생성된 Entity 반환
        $entity = UploadRepository::findByIdx($idx);
        if ($entity === null) {
            throw new RuntimeException('업로드 레코드 조회에 실패했습니다.');
        }
        return $entity;
    }

    /**
     * 업로드 파일을 삭제한다 (파일 시스템 + DB).
     *
     * @param array $input 입력 파라미터 (idx, idx_member 필수)
     * @return bool 삭제 성공 여부
     * @throws RuntimeException 삭제 실패 또는 권한 없음
     */
    public static function remove(array $input): bool
    {
        $idx = (int)($input['idx'] ?? 0);
        $idxMember = (int)($input['idx_member'] ?? 0);

        if ($idx <= 0) {
            throw new RuntimeException('삭제할 파일의 idx가 필요합니다.');
        }
        if ($idxMember <= 0) {
            throw new RuntimeException('idx_member가 필요합니다.');
        }

        // DB에서 레코드 조회
        $entity = UploadRepository::findByIdx($idx);
        if ($entity === null) {
            throw new RuntimeException('해당 업로드 파일을 찾을 수 없습니다.');
        }

        // 소유자 검증
        if ($entity->idx_member !== $idxMember) {
            throw new RuntimeException('파일 삭제 권한이 없습니다.');
        }

        // 파일 시스템에서 삭제
        $filePath = (defined('ROOT_DIR') ? ROOT_DIR : dirname(__DIR__, 2)) . $entity->url;
        if (file_exists($filePath)) {
            unlink($filePath);
        }

        // DB에서 삭제
        return UploadRepository::deleteByIdx($idx);
    }

    /**
     * 업로드 파일 정보를 조회한다.
     *
     * @param array $input 입력 파라미터 (idx 필수)
     * @return UploadEntity 업로드 Entity
     * @throws RuntimeException 조회 실패 시
     */
    public static function get(array $input): UploadEntity
    {
        $idx = (int)($input['idx'] ?? 0);
        if ($idx <= 0) {
            throw new RuntimeException('조회할 파일의 idx가 필요합니다.');
        }
        $entity = UploadRepository::findByIdx($idx);
        if ($entity === null) {
            throw new RuntimeException('해당 업로드 파일을 찾을 수 없습니다.');
        }
        return $entity;
    }

    /**
     * 회원의 업로드 파일 목록을 조회한다.
     *
     * @param array $input 입력 파라미터 (idx_member 필수, limit/offset 선택)
     * @return array ['items' => UploadEntity[]]
     * @throws RuntimeException 조회 실패 시
     */
    public static function listByMember(array $input): array
    {
        $idxMember = (int)($input['idx_member'] ?? 0);
        if ($idxMember <= 0) {
            throw new RuntimeException('idx_member가 필요합니다.');
        }
        $limit = (int)($input['limit'] ?? 100);
        $offset = (int)($input['offset'] ?? 0);
        $entities = UploadRepository::findByMember($idxMember, $limit, $offset);
        return ['items' => array_map(fn($e) => $e->toArray(), $entities)];
    }

    /**
     * attached 상태를 업데이트한다.
     *
     * @param array $input 입력 파라미터 (idx, idx_member, attached 필수)
     * @return bool 성공 여부
     * @throws RuntimeException 권한 없음 또는 실패 시
     */
    public static function updateAttached(array $input): bool
    {
        $idx = (int)($input['idx'] ?? 0);
        $idxMember = (int)($input['idx_member'] ?? 0);
        $attached = (int)($input['attached'] ?? 0);

        if ($idx <= 0) throw new RuntimeException('idx가 필요합니다.');
        if ($idxMember <= 0) throw new RuntimeException('idx_member가 필요합니다.');

        // 소유자 검증
        $entity = UploadRepository::findByIdx($idx);
        if ($entity === null) throw new RuntimeException('해당 업로드 파일을 찾을 수 없습니다.');
        if ($entity->idx_member !== $idxMember) throw new RuntimeException('권한이 없습니다.');

        return UploadRepository::updateAttached($idx, $attached);
    }

    /**
     * 확장자 기반 MIME 타입을 반환한다.
     *
     * @param string $extension 파일 확장자 (소문자)
     * @return string MIME 타입
     */
    private static function getMimeType(string $extension): string
    {
        $mimeTypes = [
            'jpg' => 'image/jpeg', 'jpeg' => 'image/jpeg', 'png' => 'image/png',
            'gif' => 'image/gif', 'webp' => 'image/webp', 'svg' => 'image/svg+xml',
            'bmp' => 'image/bmp', 'ico' => 'image/x-icon',
            'mp4' => 'video/mp4', 'webm' => 'video/webm', 'avi' => 'video/x-msvideo',
            'mov' => 'video/quicktime', 'mkv' => 'video/x-matroska',
            'mp3' => 'audio/mpeg', 'wav' => 'audio/wav', 'ogg' => 'audio/ogg',
            'pdf' => 'application/pdf',
            'doc' => 'application/msword', 'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'xls' => 'application/vnd.ms-excel', 'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'ppt' => 'application/vnd.ms-powerpoint', 'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            'zip' => 'application/zip', 'rar' => 'application/x-rar-compressed',
            'gz' => 'application/gzip', 'tar' => 'application/x-tar',
            'txt' => 'text/plain', 'csv' => 'text/csv',
            'html' => 'text/html', 'css' => 'text/css', 'js' => 'application/javascript',
            'json' => 'application/json', 'xml' => 'application/xml',
        ];
        return $mimeTypes[$extension] ?? 'application/octet-stream';
    }
}
```

---

## 10. Controller 클래스

```php
<?php
/**
 * @file lib/upload/UploadController.php
 * @brief 업로드 Controller 클래스 - API 엔드포인트
 *
 * API method 접두사: "upload.*"
 * 예: upload.upload, upload.delete, upload.get, upload.list, upload.updateAttached
 *
 * PSR-4: Philgo\Upload\UploadController
 */

namespace Philgo\Upload;

class UploadController
{
    /**
     * 파일 업로드
     * API: method=upload.upload
     *
     * GET 호출 예시 (테스트용, 실제로는 POST multipart/form-data):
     *   https://local.philgo.com:444/api.php?method=upload.upload
     *
     * @param array $input 입력 파라미터 (idx_member 필수, module/code/attached 선택)
     * @return array UploadEntity 배열
     * @throws \RuntimeException 업로드 실패 시
     */
    public function upload(array $input): array
    {
        $entity = UploadService::store($input);
        return $entity->toArray();
    }

    /**
     * 파일 삭제
     * API: method=upload.delete
     *
     * GET 호출 예시:
     *   https://local.philgo.com:444/api.php?method=upload.delete&idx=1&idx_member=123
     *
     * @param array $input 입력 파라미터 (idx, idx_member 필수)
     * @return bool 삭제 성공 여부
     * @throws \RuntimeException 삭제 실패 시
     */
    public function delete(array $input): bool
    {
        return UploadService::remove($input);
    }

    /**
     * 파일 정보 조회
     * API: method=upload.get
     *
     * GET 호출 예시:
     *   https://local.philgo.com:444/api.php?method=upload.get&idx=1
     *
     * @param array $input 입력 파라미터 (idx 필수)
     * @return array UploadEntity 배열
     * @throws \RuntimeException 조회 실패 시
     */
    public function get(array $input): array
    {
        $entity = UploadService::get($input);
        return $entity->toArray();
    }

    /**
     * 회원별 파일 목록 조회
     * API: method=upload.list
     *
     * GET 호출 예시:
     *   https://local.philgo.com:444/api.php?method=upload.list&idx_member=123&limit=20
     *
     * @param array $input 입력 파라미터 (idx_member 필수, limit/offset 선택)
     * @return array ['items' => [...]]
     * @throws \RuntimeException 조회 실패 시
     */
    public function list(array $input): array
    {
        return UploadService::listByMember($input);
    }

    /**
     * attached 상태 변경
     * API: method=upload.updateAttached
     *
     * GET 호출 예시:
     *   https://local.philgo.com:444/api.php?method=upload.updateAttached&idx=1&idx_member=123&attached=1
     *
     * @param array $input 입력 파라미터 (idx, idx_member, attached 필수)
     * @return bool 성공 여부
     * @throws \RuntimeException 실패 시
     */
    public function updateAttached(array $input): bool
    {
        return UploadService::updateAttached($input);
    }
}
```

---

## 11. API 엔드포인트

### 11.1 upload.upload - 파일 업로드

| 항목 | 값 |
|------|-----|
| **method** | `upload.upload` |
| **HTTP** | `POST /api.php` (multipart/form-data) |
| **파라미터** | `idx_member` (필수), `file` (필수, $_FILES), `module`, `code`, `attached` (선택) |
| **응답** | `{"idx": 1, "url": "/uploads/123/abc.jpg", ...}` |

**curl 예시:**
```bash
curl -s -X POST "https://local.philgo.com:444/api.php" \
  -F "method=upload.upload" \
  -F "idx_member=123" \
  -F "module=post" \
  -F "code=content" \
  -F "file=@/path/to/photo.jpg"
```

**JavaScript 호출 예시:**
```javascript
const formData = new FormData();
formData.append('method', 'upload.upload');
formData.append('idx_member', 123);
formData.append('module', 'post');
formData.append('code', 'content');
formData.append('file', fileInput.files[0]);

const res = await axios.post('/api.php', formData);
console.log(res.data.url); // /uploads/123/67a1b2c3_1709876543.jpg
```

### 11.2 upload.delete - 파일 삭제

| 항목 | 값 |
|------|-----|
| **method** | `upload.delete` |
| **HTTP** | `GET /api.php?method=upload.delete&idx=1&idx_member=123` 또는 POST |
| **파라미터** | `idx` (필수), `idx_member` (필수) |
| **응답** | `{"data": true}` |

### 11.3 upload.get - 파일 정보 조회

| 항목 | 값 |
|------|-----|
| **method** | `upload.get` |
| **HTTP** | `GET /api.php?method=upload.get&idx=1` |
| **파라미터** | `idx` (필수) |
| **응답** | `{"idx": 1, "url": "/uploads/123/abc.jpg", "name": "photo.jpg", ...}` |

### 11.4 upload.list - 회원별 목록 조회

| 항목 | 값 |
|------|-----|
| **method** | `upload.list` |
| **HTTP** | `GET /api.php?method=upload.list&idx_member=123&limit=20` |
| **파라미터** | `idx_member` (필수), `limit`, `offset` (선택) |
| **응답** | `{"items": [{...}, {...}]}` |

### 11.5 upload.updateAttached - 사용 상태 변경

| 항목 | 값 |
|------|-----|
| **method** | `upload.updateAttached` |
| **HTTP** | `POST /api.php` |
| **파라미터** | `idx` (필수), `idx_member` (필수), `attached` (필수, 0 또는 1) |
| **응답** | `{"data": true}` |

---

## 12. PSR-4 Autoload 설정

### composer.json 변경사항

```json
{
    "autoload": {
        "psr-4": {
            "Philgo\\Utils\\": "lib/utils/",
            "Philgo\\User\\": "lib/user/",
            "Philgo\\Upload\\": "lib/upload/"
        }
    }
}
```

### 적용 명령

```bash
composer dump-autoload
```

### .gitignore 추가

```
/uploads/
```

---

## 13. 보안 및 검증

### 13.1 파일 검증 규칙

| 항목 | 규칙 |
|------|------|
| **파일 크기** | 서버 `upload_max_filesize` 설정에 의존 (기본 PHP 설정) |
| **파일명** | 원본 파일명은 DB에만 저장, 실제 저장 시 유니크 파일명 사용 |
| **확장자** | 허용/차단 목록 없이 모든 확장자 허용 (추후 화이트리스트 추가 가능) |
| **MIME 타입** | 확장자 기반 판별 후 DB 저장 |

### 13.2 소유자 검증

```
모든 수정/삭제 요청 시:
1. DB에서 해당 레코드의 idx_member 조회
2. 요청자의 idx_member와 비교
3. 불일치 시 RuntimeException("권한이 없습니다.") throw
```

### 13.3 파일명 보안

```
원본: "../../etc/passwd" 또는 "<script>.jpg"
처리: pathinfo()로 확장자만 추출 → uniqid() + time()으로 완전히 새 파일명 생성
결과: "67a1b2c3d4e5f_1709876543.jpg" (원본 파일명 무시)
```

---

## 14. 테스트 계획

### 14.1 PEST Unit Test

**파일**: `tests/Unit/UploadControllerTest.php`

```php
use Philgo\Upload\UploadController;
use Philgo\Upload\UploadService;
use Philgo\Upload\UploadRepository;
use Philgo\Upload\UploadEntity;

describe('UploadEntity', function () {
    it('fromArray() - 배열을 Entity로 변환한다', function () { ... });
    it('toArray() - Entity를 배열로 변환한다', function () { ... });
    it('기본값이 올바르게 설정된다', function () { ... });
});

describe('UploadRepository', function () {
    it('create() - 레코드를 생성하고 idx를 반환한다', function () { ... });
    it('findByIdx() - idx로 레코드를 조회한다', function () { ... });
    it('findByMember() - 회원번호로 목록을 조회한다', function () { ... });
    it('deleteByIdx() - 레코드를 삭제한다', function () { ... });
    it('updateAttached() - attached 상태를 변경한다', function () { ... });
});

describe('UploadService', function () {
    it('remove() - 소유자 불일치 시 예외를 던진다', function () { ... });
    it('get() - 존재하지 않는 idx 시 예외를 던진다', function () { ... });
});
```

### 14.2 curl 테스트

```bash
# 파일 업로드
curl -s -X POST "https://local.philgo.com:444/api.php" \
  -F "method=upload.upload" \
  -F "idx_member=123" \
  -F "module=post" \
  -F "code=content" \
  -F "file=@test.jpg"

# 파일 조회
curl -s "https://local.philgo.com:444/api.php?method=upload.get&idx=1"

# 파일 목록
curl -s "https://local.philgo.com:444/api.php?method=upload.list&idx_member=123"

# 파일 삭제
curl -s "https://local.philgo.com:444/api.php?method=upload.delete&idx=1&idx_member=123"
```

---

## 15. 기존 시스템과의 차이점

| 항목 | 기존 시스템 (v6) | v7 시스템 |
|------|-----------------|-----------|
| **저장 위치** | 외부 파일 서버 (`file.philgo.com`) | 로컬 `./uploads/{idx}/` |
| **인증** | Firebase UID | sf_member.idx |
| **메타데이터** | 글/코멘트의 `files` 컬럼 (JSON 문자열) | `uploads` 테이블 (정규화) |
| **API** | 외부 서버 API (`upload.php`, `delete.php`) | `api.php?method=upload.*` |
| **소유권** | Firebase UID 비교 | idx_member 비교 (폴더 기반) |
| **썸네일** | 외부 서버 `thumbnail.php` | 추후 구현 (v7 확장) |
| **아키텍처** | 함수 기반 (`file.functions.php`) | Controller/Service/Repository (PSR-4) |
| **공존** | 기존 시스템 유지 | 기존 시스템과 100% 공존 |
