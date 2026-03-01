# httpYac 가이드 — Assert & 응답 처리

> 메인 문서: [yac.md](yac.md)

---

## 8. Assert — 응답 검증

httpYac의 Assert 기능은 API 테스트 자동화의 핵심이다. `??` 기호로 시작한다.

### 8.1. 기본 문법 (??)

```
?? [대상] [조건] [예상값]
```

```http
GET https://httpbin.org/json

### 응답 검증
?? status == 200
?? header content-type includes json
?? body includes slideshow
?? duration < 5000
```

---

### 8.2. 조건 연산자 전체 목록

| 조건 | 별칭 | 설명 | 예시 |
|------|------|------|------|
| `==` | `equals` | 값이 동일 | `?? status == 200` |
| `!=` | | 값이 다름 | `?? status != 404` |
| `>` | | 초과 | `?? status > 199` |
| `>=` | | 이상 | `?? status >= 200` |
| `<` | | 미만 | `?? status < 300` |
| `<=` | | 이하 | `?? status <= 299` |
| `startsWith` | | ~로 시작 | `?? status startsWith 20` |
| `endsWith` | | ~로 끝남 | `?? status endsWith 00` |
| `includes` | `contains` | 포함 | `?? body includes "hello"` |
| `exists` | `isTrue` | 존재/참 | `?? header content-type exists` |
| `isFalse` | | 거짓 | `?? body error isFalse` |
| `isNumber` | | 숫자 타입 | `?? body count isNumber` |
| `isBoolean` | | 불린 타입 | `?? body active isBoolean` |
| `isString` | | 문자열 타입 | `?? header content-type isString` |
| `isArray` | | 배열 타입 | `?? body items isArray` |
| `matches` | | 정규표현식 | `?? status matches ^2\\d{2}` |
| `sha256` | | SHA256 해시 | `?? body sha256 abc123...` |
| `sha512` | | SHA512 해시 | `?? body sha512 def456...` |
| `md5` | | MD5 해시 | `?? body md5 789abc...` |

---

### 8.3. Status Assert

```http
GET https://httpbin.org/status/200

?? status == 200
?? status >= 200
?? status < 300
?? status matches ^2\\d{2}
?? status isNumber
```

---

### 8.4. Header Assert

```http
GET https://httpbin.org/json

?? header content-type == application/json
?? header content-type includes json
?? header content-type isString
?? header content-type exists
?? header x-custom-header isFalse
```

---

### 8.5. Body Assert (JSON 경로)

JSON 응답의 특정 필드를 검증할 수 있다.

```http
GET https://httpbin.org/json

# 전체 바디 검증
?? body includes slideshow

# JSON 필드 경로로 접근
?? body slideshow.author == Yours Truly
?? body slideshow.slides isArray
?? body slideshow.slides[0].title exists
?? body slideshow.date == date of publication
```

---

### 8.6. Duration Assert

응답 시간을 검증한다 (밀리초 단위).

```http
GET https://httpbin.org/json

?? duration < 2000
?? duration < 500
```

---

### 8.7. JavaScript Assert

복잡한 검증 로직을 JavaScript로 작성한다.

```http
GET https://httpbin.org/json

?? js response.parsedBody.slideshow.slides.length == 2
?? js response.parsedBody.slideshow.slides[0].title == Wake up to WonderWidgets!
?? js response.statusCode >= 200 && response.statusCode < 300
```

---

### 8.8. XPath Assert

XML 응답을 XPath로 검증한다.

```http
GET https://httpbin.org/xml

?? xpath /slideshow/@title == Sample Slide Show
?? xpath /slideshow/@author == Yours Truly
?? xpath //item/@id exists
```

---

### 8.9. 스크립트 기반 테스트 (test 함수)

더 복잡한 테스트를 `test()` 함수로 작성한다.

```http
GET https://httpbin.org/json

{{
  const { equal, ok } = require('assert');

  test('상태 코드가 200이어야 한다', () => {
    equal(response.statusCode, 200);
  });

  test('응답 바디에 slideshow가 있어야 한다', () => {
    ok(response.parsedBody.slideshow);
  });

  test('슬라이드가 2개여야 한다', () => {
    equal(response.parsedBody.slideshow.slides.length, 2);
  });
}}
```

**Chai 라이브러리 사용:**
```http
GET https://httpbin.org/json

{{
  const { expect } = require('chai');

  test('상태 코드 200', () => {
    expect(response.statusCode).to.equal(200);
  });

  test('JSON 응답 구조 검증', () => {
    expect(response.parsedBody).to.have.property('slideshow');
    expect(response.parsedBody.slideshow.slides).to.be.an('array');
    expect(response.parsedBody.slideshow.slides).to.have.lengthOf(2);
  });
}}
```

> **참고**: Chai를 사용하려면 `npm install chai` 필요.

---

### 8.10. 보조 테스트 메서드

빠른 검증을 위한 내장 헬퍼 메서드:

```http
GET https://httpbin.org/json

{{
  test.status(200);                                    // 상태 코드 검증
  test.totalTime(3000);                                // 응답 시간 상한
  test.header("content-type", "application/json");     // 헤더 정확히 일치
  test.headerContains("content-type", "json");         // 헤더 포함
  test.hasResponseBody();                              // 응답 바디 존재
  // test.hasNoResponseBody();                         // 응답 바디 없음
  // test.responseBody('{"exact": "match"}');           // 바디 정확히 일치
}}
```

---

## 9. 응답 처리 (Response)

### 9.1. 응답 문서화

HTTP 파일 내에서 예상 응답을 문서화할 수 있다. `HTTP/버전`으로 시작하면 응답으로 해석된다.

```http
GET https://httpbin.org/json

HTTP/1.1 200 OK
date: Mon, 21 Jun 2021 19:38:05 GMT
content-type: application/json

{
  "slideshow": {
    "author": "Yours Truly",
    "title": "Sample Slide Show"
  }
}
```

> **참고**: 이 응답 문서는 httpBook 표시 용도로만 사용되며, 실제 실행에는 영향 없다.

---

### 9.2. 출력 리다이렉트 (파일 저장)

응답 본문을 파일로 저장할 수 있다.

```http
### 새 파일로 저장 (파일 존재 시 -1, -2 등 접미사 추가)
GET https://httpbin.org/json

>> ./responses/output.json

### 기존 파일 덮어쓰기
GET https://httpbin.org/json

>>! ./responses/output.json
```

| 연산자 | 동작 |
|--------|------|
| `>>` | 새 파일 생성, 기존 파일 있으면 `-n` 접미사 추가 |
| `>>!` | 기존 파일 덮어쓰기 |

---
