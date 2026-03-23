# v7 포인트 이벤트 시스템 — 전체 흐름 및 플로차트

> **최종 업데이트**: 2026-03-14
> **관련 문서**: [v7-point.md](../v7-point.md) | [v7-event-overview.md](v7-event-overview.md) | [v7-event-coupon.md](v7-event-coupon.md) | [v7-event.md](../api/v7-event.md)

---

## 목차

1. [시스템 개요](#1-시스템-개요)
2. [전체 아키텍처 플로차트](#2-전체-아키텍처-플로차트)
3. [글/코멘트 포인트 이벤트](#3-글코멘트-포인트-이벤트)
4. [스피닝 휠 이벤트](#4-스피닝-휠-이벤트)
5. [QR 코드 삼단콤보](#5-qr-코드-삼단콤보)
6. [쿠폰 관리 시스템](#6-쿠폰-관리-시스템)
7. [포인트 레벨 시스템](#7-포인트-레벨-시스템)
8. [DB 테이블 관계도](#8-db-테이블-관계도)
9. [API 엔드포인트 매트릭스](#9-api-엔드포인트-매트릭스)
10. [관리자/사용자 페이지 맵](#10-관리자사용자-페이지-맵)
11. [안티치트 및 보안](#11-안티치트-및-보안)

---

## 1. 시스템 개요

필고 포인트 이벤트 시스템은 **3개의 독립적인 서브시스템**으로 구성된다:

| 서브시스템 | 설명 | 포인트 범위 | 트리거 |
|-----------|------|------------|--------|
| **글/코멘트 포인트 이벤트** | 이벤트 기간에 글/코멘트 작성 시 랜덤 배율 포인트 지급 | 15P ~ 200배 | 글/코멘트 생성 |
| **스피닝 휠 이벤트** | 200P 소비 → 10개 섹션 가중치 기반 확률 보상 | 0P ~ 2,000P + 쿠폰 | 사용자 직접 참여 |
| **QR 코드 삼단콤보** | QR 스캔 → 재방문 추첨 → 후기 작성 → 포인트 적립 | 기본 + 2,000~3,000P | QR 코드 스캔 |

---

## 2. 전체 아키텍처 플로차트

```mermaid
flowchart TB
    subgraph USER["사용자 액션"]
        A1["글/코멘트 작성"]
        A2["스피닝 휠 참여<br/>(200P 소비)"]
        A3["QR 코드 스캔"]
    end

    subgraph EVENT1["글/코멘트 포인트 이벤트"]
        B1{"이벤트 기간?"}
        B2{"이벤트 게시판?"}
        B3["쓰로틀링 체크<br/>(5분/3회)"]
        B4["랜덤 배율 계산<br/>(3배~200배)"]
        B5["기본 포인트 지급<br/>(point_write)"]
        B6["이벤트 포인트 지급<br/>(랜덤 계산값)"]
    end

    subgraph EVENT2["스피닝 휠 이벤트"]
        C1["잔액 확인<br/>(≥200P)"]
        C2["쿠폰 재고 확인"]
        C3["200P 차감"]
        C4["확률 계산<br/>(weight 1000)"]
        C5{"당첨 결과?"}
        C6["포인트 보상<br/>(50~2000P)"]
        C7["스타벅스 쿠폰<br/>배정"]
        C8["꽝<br/>(보상 없음)"]
    end

    subgraph EVENT3["QR 코드 삼단콤보"]
        D1["QR 코드 발행<br/>(업소 소유자)"]
        D2["QR 스캔<br/>(사용자)"]
        D3["기본 포인트 적립"]
        D4{"24시간<br/>경과?"}
        D5["재방문 포인트 추첨<br/>(2,000~3,000P)"]
        D6["방문 후기 작성<br/>(사진+텍스트)"]
        D7["후기 포인트 적립<br/>(2,000~3,000P)"]
    end

    subgraph DB["데이터 저장"]
        E1[("sf_point_log<br/>포인트 이력")]
        E2[("sf_member<br/>회원 포인트")]
        E3[("event_spin_history<br/>스핀 기록")]
        E4[("event_coupons<br/>쿠폰 관리")]
        E5[("sf_post_data<br/>글/코멘트")]
        E6[("company_qr_code_usages<br/>QR 사용 기록")]
    end

    A1 --> B1
    B1 -- 예 --> B2
    B1 -- 아니오 --> B5
    B2 -- 예 --> B3
    B2 -- 아니오 --> B5
    B3 --> B4
    B4 --> B6
    B5 --> E1
    B5 --> E2
    B6 --> E1
    B6 --> E2
    B6 --> E5

    A2 --> C1
    C1 --> C2
    C2 --> C3
    C3 --> C4
    C4 --> C5
    C5 -- 포인트 --> C6
    C5 -- 스타벅스 --> C7
    C5 -- 꽝 --> C8
    C6 --> E1
    C6 --> E2
    C6 --> E3
    C7 --> E4
    C7 --> E3
    C8 --> E3

    A3 --> D2
    D1 --> D2
    D2 --> D3
    D3 --> D4
    D4 -- 예 --> D5
    D5 --> D6
    D6 --> D7
    D4 -- 아니오 --> D6
    D3 --> E6
    D5 --> E1
    D7 --> E1

    style USER fill:#e3f2fd,stroke:#1565c0
    style EVENT1 fill:#e8f5e9,stroke:#2e7d32
    style EVENT2 fill:#fff3e0,stroke:#ef6c00
    style EVENT3 fill:#f3e5f5,stroke:#7b1fa2
    style DB fill:#fce4ec,stroke:#c62828
```

---

## 3. 글/코멘트 포인트 이벤트

### 3.1 전체 흐름

```mermaid
flowchart TD
    START(["글/코멘트 작성 요청"]) --> CHK1{"검열/블라인드<br/>체크"}
    CHK1 -- 검열됨 --> SKIP(["포인트 미지급"])
    CHK1 -- 통과 --> CHK2{"이벤트 기간?<br/>(sf_config)"}

    CHK2 -- 아니오 --> NORMAL["기본 포인트 결정<br/>point_write / point_comment"]
    CHK2 -- 예 --> CHK3{"이벤트 게시판?<br/>(PostService)"}

    CHK3 -- 아니오 --> NORMAL
    CHK3 -- 예 --> THROTTLE{"쓰로틀링 체크<br/>5분 내 3회 이상?"}

    THROTTLE -- 예 --> LIMIT["기본 8P만 지급"]
    THROTTLE -- 아니오 --> MINSCORE["최소 점수 보정<br/>(5점 미만 → 5점)"]

    MINSCORE --> RANDOM["랜덤 배율 계산<br/>rand(1, 100)"]

    RANDOM --> TIER{"확률 구간 판별"}
    TIER -- "1~50<br/>(50%)" --> M3["3배"]
    TIER -- "51~90<br/>(40%)" --> M10["10배"]
    TIER -- "91~95<br/>(5%)" --> M20["20배"]
    TIER -- "96~99<br/>(4%)" --> M40["40배"]
    TIER -- "100<br/>(1%)" --> M200["200배"]

    M3 --> CALC["최종 = 기본점수 × 배율"]
    M10 --> CALC
    M20 --> CALC
    M40 --> CALC
    M200 --> CALC

    CALC --> COMPARE{"랜덤값 > 기본값?"}
    COMPARE -- 예 --> EVENT_PT["이벤트 포인트 지급<br/>etc='point_event_write'"]
    COMPARE -- 아니오 --> NORMAL

    NORMAL --> CHANGE["PointLogService::changePoints()"]
    EVENT_PT --> CHANGE
    LIMIT --> CHANGE

    CHANGE --> LOG1["sf_point_log 기록"]
    CHANGE --> LOG2["sf_member.point 업데이트"]
    CHANGE --> LOG3["sf_post_data.int_10 저장"]
    CHANGE --> DONE(["포인트 지급 완료"])

    style START fill:#4caf50,color:#fff
    style DONE fill:#4caf50,color:#fff
    style SKIP fill:#f44336,color:#fff
    style LIMIT fill:#ff9800,color:#fff
    style EVENT_PT fill:#2196f3,color:#fff
```

### 3.2 배율 확률표

| 확률 구간 | 확률 | 배율 | 예시 (기본 70P) |
|----------|------|------|-----------------|
| 1~50 | 50% | 3배 | 210P |
| 51~90 | 40% | 10배 | 700P |
| 91~95 | 5% | 20배 | 1,400P |
| 96~99 | 4% | 40배 | 2,800P |
| 100 | 1% | 200배 | 14,000P |

### 3.3 핵심 코드 호출 체인

```
PostService::create()
  → increasePointsForCreate($post, $member)
    → getEventPoints($config, $post)
      → SettingsService::isInPointEventDate()     // 이벤트 기간 확인
      → PostService::getEventPostIdsPublic()      // 이벤트 게시판 확인
      → PointLogService::getRecentActionCount()   // 쓰로틀링 체크
      → randomizeEventPoint($score)               // 랜덤 배율 계산
    → changeUserPoints()
      → PointLogService::changePoints()           // 포인트 변경 + 로그 기록
```

### 3.4 이벤트 기간 관리

```mermaid
flowchart LR
    ADMIN["관리자<br/>/admin/point-event"] --> ADD["기간 추가<br/>(시작일~종료일)"]
    ADMIN --> DEL["기간 삭제<br/>(인덱스)"]
    ADD --> DB[("sf_config<br/>key: point_event_dates<br/>JSON 배열")]
    DEL --> DB
    DB --> CHECK{"오늘이<br/>이벤트 기간?"}
    CHECK -- 예 --> ACTIVE["이벤트 포인트 활성"]
    CHECK -- 아니오 --> INACTIVE["기본 포인트만"]

    style DB fill:#fff3e0,stroke:#ef6c00
```

**sf_config 저장 형식:**
```json
[
  {"start": 20260315, "end": 20260320},
  {"start": 20260401, "end": 20260410}
]
```

### 3.5 삭제 시 포인트 회수

```mermaid
flowchart TD
    DELETE(["글/코멘트 삭제"]) --> CHK{"int_10 값<br/>확인"}
    CHK -- "int_10 ≠ 0" --> RECOVER["int_10 × -1 포인트 차감<br/>(이벤트 포인트 전액 회수)"]
    CHK -- "int_10 = 0" --> CONFIG["게시판 설정<br/>point_write_delete 조회"]
    CONFIG --> DEDUCT["설정값만큼 차감"]
    RECOVER --> LOG["sf_point_log 기록"]
    DEDUCT --> LOG
    LOG --> DONE(["회수 완료"])

    style DELETE fill:#f44336,color:#fff
    style RECOVER fill:#ff9800,color:#fff
```

---

## 4. 스피닝 휠 이벤트

### 4.1 전체 흐름

```mermaid
flowchart TD
    START(["사용자: 스핀 버튼 클릭"]) --> AUTH{"로그인<br/>확인?"}
    AUTH -- 아니오 --> ERR1(["에러: 로그인 필요"])
    AUTH -- 예 --> BAL{"잔액 ≥ 200P?"}
    BAL -- 아니오 --> ERR2(["에러: 포인트 부족"])
    BAL -- 예 --> COUPON{"스타벅스 쿠폰<br/>재고 있음?"}
    COUPON -- 아니오 --> ERR3(["에러: 쿠폰 재고 없음"])

    COUPON -- 예 --> TX_START["트랜잭션 시작<br/>BEGIN"]

    TX_START --> COST["200P 차감<br/>(sf_member + sf_point_log)"]
    COST --> CALC["확률 계산<br/>random_int(1, 1000)"]

    CALC --> WEIGHT{"가중치<br/>누적합 판별"}

    WEIGHT -- "1~379" --> SEC0["섹션0: 50P<br/>(37.9%)"]
    WEIGHT -- "380~459" --> SEC1["섹션1: 100P<br/>(8.0%)"]
    WEIGHT -- "460~529" --> SEC2["섹션2: 200P<br/>(7.0%)"]
    WEIGHT -- "530~589" --> SEC3["섹션3: 300P<br/>(6.0%)"]
    WEIGHT -- "590~639" --> SEC4["섹션4: 400P<br/>(5.0%)"]
    WEIGHT -- "640~679" --> SEC5["섹션5: 500P<br/>(4.0%)"]
    WEIGHT -- "680~694" --> SEC6["섹션6: 1,000P<br/>(1.5%)"]
    WEIGHT -- "695~698" --> SEC7["섹션7: 2,000P<br/>(0.4%)"]
    WEIGHT -- "699~700" --> SEC8["섹션8: 스타벅스<br/>(0.2%)"]
    WEIGHT -- "701~1000" --> SEC9["섹션9: 꽝<br/>(30.0%)"]

    SEC0 --> REWARD
    SEC1 --> REWARD
    SEC2 --> REWARD
    SEC3 --> REWARD
    SEC4 --> REWARD
    SEC5 --> REWARD
    SEC6 --> REWARD
    SEC7 --> REWARD

    REWARD["포인트 보상 지급<br/>(sf_member + sf_point_log)"]

    SEC8 --> COUPON_ASSIGN["쿠폰 배정<br/>SELECT...FOR UPDATE"]
    COUPON_ASSIGN --> COUPON_UPDATE["event_coupons 업데이트<br/>status: won"]

    SEC9 --> MISS["보상 없음"]

    REWARD --> HISTORY["event_spin_history<br/>기록 저장"]
    COUPON_UPDATE --> HISTORY
    MISS --> HISTORY

    HISTORY --> TX_COMMIT["트랜잭션 커밋<br/>COMMIT"]

    TX_COMMIT --> POST{"스타벅스<br/>당첨?"}
    POST -- 예 --> AUTO_POST["freetalk 게시판<br/>당첨 글 자동 작성"]
    POST -- 아니오 --> RESPONSE

    AUTO_POST --> RESPONSE["API 응답 반환<br/>{section_index, points,<br/>prize_type, coupon}"]

    RESPONSE --> CLIENT["클라이언트:<br/>원판 회전 애니메이션<br/>(section_index에 맞춰)"]

    CLIENT --> DONE(["완료"])

    style START fill:#ff9800,color:#fff
    style DONE fill:#4caf50,color:#fff
    style ERR1 fill:#f44336,color:#fff
    style ERR2 fill:#f44336,color:#fff
    style ERR3 fill:#f44336,color:#fff
    style TX_START fill:#2196f3,color:#fff
    style TX_COMMIT fill:#2196f3,color:#fff
    style SEC8 fill:#7b1fa2,color:#fff
    style COUPON_ASSIGN fill:#7b1fa2,color:#fff
```

### 4.2 확률 분포표

| 섹션 | 보상 | Weight | 확률 | 쿠폰 소진 시 |
|------|------|--------|------|-------------|
| 0 | 50P | 379 | 37.9% | **381** (37.9% + 0.2%) |
| 1 | 100P | 80 | 8.0% | 80 |
| 2 | 200P | 70 | 7.0% | 70 |
| 3 | 300P | 60 | 6.0% | 60 |
| 4 | 400P | 50 | 5.0% | 50 |
| 5 | 500P | 40 | 4.0% | 40 |
| 6 | 1,000P | 15 | 1.5% | 15 |
| 7 | 2,000P | 4 | 0.4% | 4 |
| 8 | **스타벅스** | **2** | **0.2%** | **0** (50P에 합산) |
| 9 | 꽝 | 300 | 30.0% | 300 |
| **합계** | | **1000** | **100%** | **1000** |

### 4.3 동적 확률 전환 흐름

```mermaid
flowchart LR
    CHECK{"스타벅스 쿠폰<br/>재고 확인"}
    CHECK -- "≥1개" --> NORMAL["기본 확률 적용<br/>스타벅스: weight 2"]
    CHECK -- "0개" --> SHIFT["확률 전환<br/>스타벅스 weight → 0<br/>50P weight += 2"]

    NORMAL --> SPIN["스핀 실행"]
    SHIFT --> SPIN

    WIN24{"24시간 내<br/>스타벅스 당첨?"}
    SPIN --> WIN24
    WIN24 -- 예 --> REDUCE["스타벅스 weight 감소<br/>(재당첨 방지)"]
    WIN24 -- 아니오 --> KEEP["weight 유지"]

    style CHECK fill:#fff3e0,stroke:#ef6c00
    style SHIFT fill:#ffcdd2,stroke:#c62828
```

### 4.4 트랜잭션 시퀀스

```mermaid
sequenceDiagram
    participant Client as 클라이언트<br/>(Flutter/Web)
    participant API as EventController
    participant Service as EventService
    participant Point as PointLogService
    participant Coupon as EventCouponService
    participant DB as MariaDB

    Client->>API: event.spin (session_id)
    API->>Service: spin($userArray)

    Note over Service,DB: === 트랜잭션 시작 ===
    Service->>DB: BEGIN TRANSACTION

    Service->>Point: changePoints(-200, ...)
    Point->>DB: UPDATE sf_member SET point
    Point->>DB: INSERT sf_point_log (spin_cost)
    Point-->>Service: PointLogEntity (point_after)

    Service->>Service: calculateSpinResult()
    Note right of Service: random_int(1, 1000)<br/>가중치 누적합 판별

    alt 포인트 당첨
        Service->>Point: changePoints(+N, ...)
        Point->>DB: UPDATE sf_member SET point
        Point->>DB: INSERT sf_point_log (spin_reward)
    else 스타벅스 당첨
        Service->>Coupon: assignCouponToWinner()
        Coupon->>DB: SELECT...FOR UPDATE (event_coupons)
        Coupon->>DB: UPDATE event_coupons SET status='won'
        Service->>Point: changePoints(0, ...) [로그만]
        Point->>DB: INSERT sf_point_log (spin_reward_coupon)
    else 꽝
        Note right of Service: 보상 없음
    end

    Service->>DB: INSERT event_spin_history
    Service->>DB: COMMIT
    Note over Service,DB: === 트랜잭션 종료 ===

    opt 스타벅스 당첨 시
        Service->>DB: INSERT sf_post_data (freetalk 당첨 글)
    end

    Service-->>API: 결과 배열
    API-->>Client: JSON 응답<br/>{section_index, points,<br/>prize_type, coupon}
    Client->>Client: 원판 회전 애니메이션<br/>(서버 결정 섹션에 맞춤)
```

---

## 5. QR 코드 삼단콤보

### 5.1 전체 흐름

```mermaid
flowchart TD
    subgraph STEP1["1단계: QR 코드 발행 & 스캔"]
        OWNER(["업소 소유자"]) --> ISSUE["QR 코드 발행<br/>/company/qr-code<br/>(3분 유효, 하루 10개)"]
        ISSUE --> QRIMG["QR 코드 이미지 생성<br/>(QRCode.js)"]
        QRIMG --> SCAN(["사용자: QR 스캔"])
        SCAN --> SCANNED["/company/qr-scanned<br/>CompanyService::scanQrCode()"]
        SCANNED --> DUP{"24시간 내<br/>중복 스캔?"}
        DUP -- 예 --> DUP_MSG["중복 안내<br/>(이전 방문시간 표시)"]
        DUP -- 아니오 --> BASIC["기본 포인트 적립"]
    end

    subgraph STEP2["2단계: 재방문 포인트 추첨"]
        BASIC --> REVISIT{"재방문<br/>(24시간 경과)?"}
        REVISIT -- 예 --> LOTTERY["/company/qr-revisit<br/>CompanyService::reVisitPoint()"]
        LOTTERY --> REWARD2["재방문 포인트<br/>2,000~3,000P 추첨"]
    end

    subgraph STEP3["3단계: 방문 후기 작성"]
        REWARD2 --> REVIEW["/company/qr-review<br/>(Vue.js 앱)"]
        REVISIT -- 아니오 --> REVIEW
        REVIEW --> PHOTO["사진 업로드<br/>(1~5장, v7apiUpload)"]
        PHOTO --> TEXT["텍스트 입력<br/>(10자 이상)"]
        TEXT --> SUBMIT["제출<br/>v7api('company.submitVisitReview')"]
        SUBMIT --> REWARD3["후기 포인트<br/>2,000~3,000P 적립"]
    end

    REWARD3 --> TOTAL(["총 포인트 획득<br/>기본 + 재방문 + 후기"])

    style STEP1 fill:#e3f2fd,stroke:#1565c0
    style STEP2 fill:#fff3e0,stroke:#ef6c00
    style STEP3 fill:#f3e5f5,stroke:#7b1fa2
    style TOTAL fill:#4caf50,color:#fff
```

### 5.2 QR 코드 생명주기

```mermaid
stateDiagram-v2
    [*] --> active: QR 코드 발행<br/>(CompanyService::issueQrCode)
    active --> used: 사용자 스캔<br/>(scanQrCode)
    active --> expired: 3분 경과<br/>(타이머 만료)
    active --> disabled: 관리자 비활성화
    used --> [*]
    expired --> [*]
    disabled --> active: 관리자 재활성화
```

---

## 6. 쿠폰 관리 시스템

### 6.1 쿠폰 상태 전환

```mermaid
stateDiagram-v2
    [*] --> available: 관리자 등록<br/>(event.createCoupon)

    available --> won: 스피닝 휠 당첨<br/>(assignCouponToWinner)<br/>SELECT...FOR UPDATE
    available --> expired: 만료 시각 도달<br/>(Lazy Expiration)
    available --> cancelled: 관리자 취소

    won --> sent: 관리자 전송 완료<br/>(updateCouponSent)
    won --> won: 사용자 QR 확인<br/>(viewCoupon → viewed_at)

    sent --> won: 전송 취소<br/>(unmarkSent)

    note right of available
        관리자가 v7 Upload API로
        QR 이미지 업로드 후 등록
    end note

    note right of won
        idx_winner, won_at 기록
        freetalk 게시판 당첨 글 자동 작성
    end note
```

### 6.2 쿠폰 등록 → 당첨 → 전송 흐름

```mermaid
sequenceDiagram
    participant Admin as 관리자
    participant API as EventController
    participant Upload as Upload API
    participant Coupon as EventCouponService
    participant DB as MariaDB

    Note over Admin,DB: === 쿠폰 등록 ===
    Admin->>Upload: QR 이미지 업로드<br/>(v7apiUpload)
    Upload-->>Admin: {idx, url, thumbnail_url}
    Admin->>API: event.createCoupon<br/>{coupon_type, title, idx_upload}
    API->>Coupon: createCoupon($input)
    Coupon->>DB: INSERT event_coupons<br/>(status='available')
    Coupon-->>Admin: 생성 완료

    Note over Admin,DB: === 스핀 당첨 시 ===
    API->>Coupon: assignCouponToWinner('starbucks', idx, spin)
    Coupon->>DB: SELECT...FOR UPDATE<br/>(가장 오래된 available 쿠폰)
    Coupon->>DB: UPDATE status='won',<br/>idx_winner, won_at

    Note over Admin,DB: === 관리자 전송 ===
    Admin->>API: event.updateCouponSent<br/>{idx, sent: true}
    API->>Coupon: toggleSentStatus($input)
    Coupon->>DB: UPDATE status='sent', sent_at

    Note over Admin,DB: === 사용자 QR 확인 ===
    API->>Coupon: markCouponViewed($input, idx_member)
    Coupon->>DB: UPDATE viewed_at<br/>(NULL → 현재시간, 최초 1회)
```

---

## 7. 포인트 레벨 시스템

```mermaid
flowchart LR
    P0["Lv.1<br/>0P"] --> P400["Lv.2<br/>400P"]
    P400 --> P1600["Lv.3<br/>1,600P"]
    P1600 --> P3600["Lv.4<br/>3,600P"]
    P3600 --> DOTS["...<br/>(130단계)"]
    DOTS --> PMAX["Lv.130<br/>최대 레벨"]

    style P0 fill:#e3f2fd
    style P400 fill:#bbdefb
    style P1600 fill:#90caf9
    style P3600 fill:#64b5f6
    style PMAX fill:#1565c0,color:#fff
```

**레벨 진행률 계산**:
```
level_progress = (현재포인트 - 현재레벨기준) / (다음레벨기준 - 현재레벨기준) × 100
```

---

## 8. DB 테이블 관계도

```mermaid
erDiagram
    sf_member ||--o{ sf_point_log : "포인트 이력"
    sf_member ||--o{ event_spin_history : "스핀 기록"
    sf_member ||--o{ event_coupons : "당첨 쿠폰"
    sf_member ||--o{ sf_post_data : "글/코멘트"
    sf_member ||--o{ company_qr_code_usages : "QR 스캔"

    event_spin_history ||--o| event_coupons : "당첨 연결"
    uploads ||--o| event_coupons : "QR 이미지"

    company ||--o{ company_qr_codes : "QR 발행"
    company_qr_codes ||--o{ company_qr_code_usages : "스캔 기록"

    sf_post_config ||--o{ sf_post_data : "게시판 설정"

    sf_member {
        int idx PK
        int point "보유 포인트"
        varchar firebase_uid "Firebase UID"
    }

    sf_point_log {
        int idx PK
        int idx_member_from "변경한 회원"
        int idx_member_to "받은 회원"
        int point_before "변경 전"
        int point "변경량"
        int point_after "변경 후"
        varchar module "post/event/adv"
        varchar action "create/spin_cost/spin_reward"
        varchar etc "point_write/point_event_write"
        int stamp "Unix timestamp"
    }

    event_spin_history {
        int idx PK
        int idx_member FK
        tinyint section_index "0~9"
        varchar prize_type "miss/point/starbucks"
        int points_cost "참가비 200"
        int points_reward "획득 포인트"
        int random_value "난수 감사추적"
        int point_before "게임 전"
        int point_after "게임 후"
        int created_at "Unix timestamp"
        varchar ip "접속 IP"
    }

    event_coupons {
        int idx PK
        varchar coupon_type "starbucks/mcdonalds"
        varchar title "쿠폰 제목"
        enum status "available/won/sent/expired/cancelled"
        int idx_upload FK "QR 이미지"
        int idx_winner FK "당첨자"
        int idx_spin_history FK "스핀 기록"
        int won_at "당첨 시각"
        int sent_at "전송 시각"
        int viewed_at "QR 확인 시각"
        int expired_at "만료 시각"
    }

    sf_post_data {
        int idx PK
        int idx_member FK
        varchar post_id "게시판 ID"
        varchar subject "제목"
        text content "내용"
        int int_10 "지급된 포인트"
    }

    company_qr_codes {
        int idx PK
        int idx_company FK
        int idx_member FK
        varchar verification_id UK "검증 ID"
        char status "a/d/e/u"
        int created_at "발행 시각"
        int expired_at "만료 시각"
    }

    company_qr_code_usages {
        int idx PK
        int idx_qr_code FK
        int idx_company FK
        int idx_member FK
        int scanned_at "스캔 시각"
        char result "s/f/r"
    }

    sf_config {
        varchar key PK "point_event_dates"
        longtext value "JSON 배열"
    }

    sf_post_config {
        varchar post_id PK
        int point_write "글 작성 포인트"
        int point_comment "코멘트 포인트"
        int point_write_delete "삭제 시 차감"
    }

    uploads {
        int idx PK
        varchar url "파일 URL"
        varchar thumbnail_400x400_url "썸네일"
    }

    company {
        int idx PK
        varchar company_name "업소명"
        tinyint show_qr_code "QR 표시"
    }
```

---

## 9. API 엔드포인트 매트릭스

### 스피닝 휠 API

| API method | HTTP | 인증 | 설명 | Service 메서드 |
|------------|------|------|------|---------------|
| `event.spin` | GET/POST | 로그인 | 스핀 실행 (200P 차감) | `EventService::spin()` |
| `event.history` | GET | 로그인 | 스핀 히스토리 | `EventService::getHistory()` |

### 쿠폰 API

| API method | HTTP | 인증 | 설명 | Service 메서드 |
|------------|------|------|------|---------------|
| `event.myCoupons` | GET | 로그인 | 내 당첨 쿠폰 | `EventCouponService::getCouponListForAdmin()` |
| `event.viewCoupon` | GET | 로그인 | 쿠폰 QR 확인 | `EventCouponService::markCouponViewed()` |
| `event.createCoupon` | POST | 관리자 | 쿠폰 생성 | `EventCouponService::createCoupon()` |
| `event.deleteCoupon` | POST | 관리자 | 쿠폰 삭제 | `EventCouponService::deleteCoupon()` |
| `event.updateCoupon` | POST | 관리자 | 쿠폰 수정 | `EventCouponService::updateCoupon()` |
| `event.updateCouponSent` | POST | 관리자 | 전송 상태 토글 | `EventCouponService::toggleSentStatus()` |
| `event.listCoupons` | GET | 관리자 | 쿠폰 목록 | `EventCouponService::getCouponListForAdmin()` |
| `event.couponStats` | GET | 관리자 | 쿠폰 통계 | `EventCouponService::getStatsSummary()` |

### 포인트 로그 API

| API method | HTTP | 인증 | 설명 | Service 메서드 |
|------------|------|------|------|---------------|
| `pointLog.history` | GET | 로그인 | 포인트 히스토리 | `PointLogService::getHistory()` |
| `pointLog.get` | GET | 로그인 | 로그 단건 조회 | `PointLogService::getLog()` |

### QR 코드 API (CompanyController 경유)

| API method | HTTP | 인증 | 설명 |
|------------|------|------|------|
| `company.issueQrCode` | POST | 업소 소유자 | QR 코드 발행 |
| `company.scanQrCode` | POST | 선택 | QR 코드 스캔 |
| `company.reVisitPoint` | POST | 로그인 | 재방문 포인트 추첨 |
| `company.submitVisitReview` | POST | 로그인 | 방문 후기 제출 |

---

## 10. 관리자/사용자 페이지 맵

```mermaid
flowchart TD
    subgraph ADMIN["관리자 페이지"]
        A1["/admin/point-event<br/>포인트 이벤트 기간 관리"]
        A2["/admin/points<br/>포인트 이력 조회"]
        A3["/admin/event-coupons<br/>이벤트 쿠폰 관리"]
        A4["/admin/qr-codes<br/>QR 코드 현황"]
    end

    subgraph USER_PAGES["사용자 페이지"]
        U1["/help/point-event<br/>이벤트 일정 안내"]
        U2["/company/qr-code<br/>QR 코드 발행 (업소)"]
        U3["/company/qr-scanned<br/>QR 스캔 결과"]
        U4["/company/qr-revisit<br/>재방문 포인트 추첨"]
        U5["/company/qr-review<br/>방문 후기 작성 (Vue.js)"]
    end

    subgraph FLUTTER["Flutter 앱"]
        F1["SpinningWheel 위젯<br/>(CustomPainter)"]
        F2["EventEntryScreen<br/>(스피닝 휠 메인)"]
        F3["UserApi.me()<br/>(프로필/포인트)"]
    end

    A1 -.->|이벤트 기간| U1
    A3 -.->|쿠폰 재고| F1
    U2 -->|QR 생성| U3
    U3 -->|재방문| U4
    U3 -->|후기| U5
    U4 -->|다음 단계| U5
    F1 -->|event.spin| A3

    style ADMIN fill:#ffebee,stroke:#c62828
    style USER_PAGES fill:#e3f2fd,stroke:#1565c0
    style FLUTTER fill:#e8f5e9,stroke:#2e7d32
```

### 페이지별 상세

| 페이지 | 파일 경로 | 렌더링 | 주요 Service 호출 |
|--------|----------|--------|------------------|
| 이벤트 기간 관리 | `v7/admin/point-event.php` | SSR | `SettingsService::addPointEventDate()` |
| 포인트 이력 | `v7/admin/points.php` | SSR | `PointLogService::getHistory()` |
| 쿠폰 관리 | `v7/admin/event-coupons.php` | SSR | `EventCouponService::getCouponListForAdmin()` |
| QR 현황 | `v7/admin/qr-codes.php` | SSR | `QrCodeRepository` |
| 이벤트 안내 | `v7/help/point-event.php` | SSR | `SettingsService::getPointEventDates()` |
| QR 발행 | `v7/company/qr-code.php` | SSR | `CompanyService::issueQrCode()` |
| QR 스캔 결과 | `v7/company/qr-scanned.php` | SSR | `CompanyService::scanQrCode()` |
| 재방문 추첨 | `v7/company/qr-revisit.php` | SSR | `CompanyService::reVisitPoint()` |
| 후기 작성 | `v7/company/qr-review.php` | SSR+CSR | `v7api('company.submitVisitReview')` |

---

## 11. 안티치트 및 보안

### 11.1 보안 메커니즘 요약

```mermaid
flowchart TD
    subgraph ANTICHEAT["안티치트 설계"]
        S1["서버 결과 선결정<br/>CSPRNG: random_int(1, 1000)"]
        S2["트랜잭션 원자성<br/>BEGIN → COMMIT/ROLLBACK"]
        S3["SELECT...FOR UPDATE<br/>쿠폰 배타적 잠금"]
        S4["포인트 음수 방지<br/>newPoints < 0 → 0"]
        S5["쓰로틀링<br/>5분 내 3회 제한"]
        S6["24시간 재당첨 제한<br/>스타벅스 weight 감소"]
        S7["감사 추적<br/>random_value + IP 기록"]
        S8["24시간 중복 스캔 방지<br/>QR 코드"]
    end

    S1 --> CLIENT["클라이언트는<br/>section_index만 수신"]
    S2 --> ATOMIC["차감→보상→기록<br/>원자적 처리"]
    S3 --> RACE["동시 쿠폰 배정<br/>100% 방지"]

    style ANTICHEAT fill:#fff3e0,stroke:#ef6c00
```

### 11.2 스피닝 휠 안티치트

| 위협 | 방어 메커니즘 |
|------|-------------|
| 클라이언트 결과 조작 | 서버에서 100% 결과 결정, 클라이언트는 애니메이션만 |
| 동시 쿠폰 이중 배정 | `SELECT...FOR UPDATE` 배타적 잠금 |
| 포인트 부족 상태 스핀 | 트랜잭션 내 잔액 체크 → RuntimeException |
| 감사 우회 | `random_value`, IP, timestamp 모두 기록 |
| 스타벅스 반복 당첨 | 24시간 내 당첨 시 weight 감소 |

### 11.3 글/코멘트 이벤트 안티치트

| 위협 | 방어 메커니즘 |
|------|-------------|
| 스팸 글 대량 작성 | 쓰로틀링: 5분 내 3회 이상 → 8P만 |
| 삭제 후 재작성 반복 | `int_10` 기반 전액 회수 |
| 검열/블라인드 글 | 포인트 미지급 (skip) |

---

## 부록: sf_point_log module/action/etc 값 매트릭스

| module | action | etc | 설명 |
|--------|--------|-----|------|
| `post` | `create` | `point_write` | 글 작성 (기본) |
| `post` | `create` | `point_event_write` | 글 작성 (이벤트) |
| `post` | `delete` | `point_write` | 글 삭제 (기본 회수) |
| `comment` | `create` | `point_comment` | 코멘트 작성 (기본) |
| `comment` | `create` | `point_event_comment` | 코멘트 작성 (이벤트) |
| `comment` | `delete` | `point_comment` | 코멘트 삭제 (기본 회수) |
| `vote` | `like` | `like` | 좋아요 (+3P) |
| `vote` | `unlike` | `like` | 좋아요 해제 (-3P) |
| `event` | `spin_cost` | `spin_cost` | 스핀 참가비 (-200P) |
| `event` | `spin_reward` | `spin_reward` | 스핀 포인트 당첨 |
| `event` | `spin_reward_coupon` | `spin` | 스핀 쿠폰 당첨 (0P 로그) |
| `admin` | `update` | `admin-point-update` | 관리자 포인트 조정 |
| `adv` | `create` | `post_on_top` | 포인트 광고 구매 |

---

> **참고 문서**:
> - 포인트 시스템 상세: [v7-point.md](../v7-point.md)
> - 이벤트 시스템 개요: [v7-event-overview.md](v7-event-overview.md)
> - 쿠폰 관리 상세: [v7-event-coupon.md](v7-event-coupon.md)
> - 스피닝 휠 API: [v7-event.md](../api/v7-event.md)
> - 스피닝 휠 Flutter: [v7-event-entry.md](../app/v7-event-entry.md)
> - DB 스키마: [philgo.sql](../../database/philgo.sql)
