필고 v7 개발 및 글 관리를 할 때에 사용하는 계정

## 로컬 개발 환경의 관리자 session_id

아래의 세션 아이디로 로그인하면 로컬 개발 환경에서 관리자 권한으로 작업할 수 있습니다. 이 계정은 개발 및 테스트 목적으로만 사용해야 합니다.

- 로컬 개발 관리자 session_id: `090e2895f9280a7d7d6ec11d3f0ce483-186619`
- 관리자 대시보드에서 Config.php 파일의 `adminDashboardId()`와 `adminDashboardPassword()` 메서드에서 ID와 비밀번호를 확인할 수 있으며, md5 해시 값으로 키와 값을 쿠키에 저장해야 관리자 대시 보드를 사용할 수 있습니다.


## Durian 개발 테스트 계정

이 Durian 계정은 테스트 전용입니다.  각종 테스트를 할 때 사용하면 됩니다. 

- 닉네임: Durian
- Email: `apple@test.com`
- Password: `12345a,*`
- session_id: `2278018daa75e0ab879d8791fb0e2b2d-190076`
- sf_member.idx: `190076`



## 필고 글 쓰기 계정

이 계정은 실제 필고에 뉴스 또는 정보 글을 작성할 때 사용하는 실제 사용자 정보입니다. 인공지능이나 API 로 글 쓰기 할 때 주로 사용하는 계정입니다.

- 로그인: `poster@philgo.com:12345a,*`
- session_id: `d87e7374e22f1bf1aaebbbb97d280115-193824`
- sf_member.idx: `193824`



## 필고 게정 목록

### 관리자 thruthesky@gmail.com

- 웹브라우저: 크롬
- v6 로그인 전화번호: `+82 10 8693 4225`
- v7 구글 로그인: thruthesky@gmail.com 로 로그인. 내 메일 주소



### 사파님 - 내 활동 계정

- 웹브라우저: 사파리
- 사파님 v6 계정; `+14444-44-4444` 인증코드: `44444`
- 사파님 v7 계정; withcenter.dev4@gmail.com (Noe 계정) 으로 로그인해서 사용 가능


### 글 등록 전문 계정

- 웹브라우저: 카나리
- v6 게정: `+63 917 467 8603` 내 필리핀 전화번호
- v7 계정: `구글 로그인: thruthesky.dev@gmail.com`
- 용도: 정보 글 등록 전문 계정. 인공지능을 글 등록 할 때 등.


### 뉴스 등록 계정

- 웹브라우저: 파이어폭스
- v7 계정: `구글 로그인: withcenter.dev11@gmail.com`


## 글 쓰기 테스트 할 때 사용하는 이미지 목록

- ./tmp/sample-files/receipt-{n}.jpeg 는 영수증 이미지 파일들입니다.
- ./tmp/sample-files/[사과|바나나|체리|두리안].jpg 는 테스트용 업로드 과일 이미지 파일들입니다.

