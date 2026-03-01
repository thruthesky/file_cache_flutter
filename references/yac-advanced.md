# httpYac 가이드 — 인증, 고급 요청, Hooks & Injected Languages

> 메인 문서: [yac.md](../httpYac/yac.md)

---

## 10. 인증 (Authentication)

### 10.1. Basic Authentication

사용자명과 비밀번호를 자동 Base64 인코딩한다.

```http
@user=myuser
@password=mypassword123

GET https://httpbin.org/basic-auth/{{user}}/{{password}}
Authorization: Basic {{user}} {{password}}
```

**사용자명에 공백이 있는 경우 (콜론 구분):**
```http
@user=john doe
@password=mypassword

GET https://httpbin.org/basic-auth/john/{{password}}
Authorization: Basic {{user}}:{{password}}
```

---

### 10.2. Digest Authentication

```http
@user=myuser
@password=mypassword

GET https://httpbin.org/digest-auth/auth/{{user}}/{{password}}
Authorization: Digest {{user}} {{password}}
```

---

### 10.3. OAuth2 / OpenID Connect

httpYac의 가장 강력한 인증 기능. 다양한 OAuth2 플로우를 지원한다.

#### 지원 플로우

| 플로우 | grant_type | 문법 |
|--------|-----------|------|
| Client Credentials | `client_credentials` | `Authorization: openid` |
| Authorization Code | `authorization_code` | `Authorization: oauth2 code` |
| Auth Code + PKCE | `authorization_code` + PKCE | `Authorization: oauth2 code pkce` |
| Implicit | `implicit` | `Authorization: oauth2 implicit` |
| Password | `password` | `Authorization: oauth2 password` |
| Device Code | `device_code` | `Authorization: oauth2 device_code` |

#### 환경 변수 설정 (.env)

```bash
# .env.dev
oauth2_tokenEndpoint=http://localhost:8080/realms/master/protocol/openid-connect/token
oauth2_authorizationEndpoint=http://localhost:8080/realms/master/protocol/openid-connect/auth
oauth2_clientId=my-app
oauth2_clientSecret=my-secret-key
oauth2_scope=openid profile email
oauth2_username=testuser
oauth2_password=testpass
```

#### 사용 예시

```http
### Client Credentials Flow (기본)
GET https://api.example.com/protected
Authorization: openid

### Authorization Code Flow
GET https://api.example.com/protected
Authorization: oauth2 code

### PKCE Flow
GET https://api.example.com/protected
Authorization: oauth2 code pkce

### Password Flow
GET https://api.example.com/protected
Authorization: oauth2 password

### Custom Prefix (여러 OAuth2 서버 사용 시)
GET https://api.example.com/protected
Authorization: openid client_credentials keycloak
```

**Custom Prefix 사용 시 환경 변수:**
```bash
# keycloak 접두사를 사용하면 keycloak_* 변수를 찾음
keycloak_tokenEndpoint=http://localhost:8080/auth/realms/test/protocol/openid-connect/token
keycloak_clientId=my-app
keycloak_clientSecret=my-secret
keycloak_scope=openid profile
```

---

### 10.4. AWS Signature v4

```http
@accessId=AKIAIOSFODNN7EXAMPLE
@accessKey=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
@region=ap-northeast-2
@service=execute-api

GET https://api.example.com/data
Authorization: AWS {{accessId}} {{accessKey}} region:{{region}} service:{{service}}
```

**임시 토큰 포함:**
```http
GET https://api.example.com/data
Authorization: AWS {{accessId}} {{accessKey}} token:{{sessionToken}} region:{{region}} service:{{service}}
```

---

### 10.5. SSL 클라이언트 인증서

**설정 파일로 지정:**

```json
// .httpyac.json 또는 settings.json
{
  "clientCertificates": {
    "api.example.com": {
      "cert": "./certs/client.crt",
      "key": "./certs/client.key"
    },
    "secure.example.com": {
      "pfx": "./certs/client.p12",
      "passphrase": "my-password"
    }
  }
}
```

**헤더로 직접 지정:**
```http
GET https://api.example.com/secure
ClientCert: pfx: ./certs/client.p12 passphrase: my-password
```

---

## 11. 고급 요청 타입

### 11.1. GraphQL

```http
### 기본 GraphQL 쿼리
POST https://countries.trevorblades.com/graphql
Content-Type: application/json

query Continents($code: String!) {
  continents(filter: { code: { eq: $code } }) {
    code
    name
  }
}

{
  "code": "EU"
}
```

**Fragment 사용:**
```http
fragment ContinentParts on Continent {
  code
  name
}

POST https://countries.trevorblades.com/graphql
Content-Type: application/json

query Continents {
  continents {
    ...ContinentParts
  }
}
```

**외부 .gql 파일 임포트:**
```http
POST https://countries.trevorblades.com/graphql
Content-Type: application/json

gql Continents < ./queries/continents.gql

{
  "code": "EU"
}
```

---

### 11.2. gRPC

Proto 파일을 로드하고 `GRPC` 메서드로 호출한다.

```http
### Proto 파일 로드
proto < ./protos/hello.proto

### Unary RPC
GRPC grpc.example.com/HelloService/SayHello

{
  "greeting": "world"
}
```

**형식**: `GRPC 서버주소/서비스명/메서드명`

**TLS 보안 연결:**
```http
proto < ./hello.proto

{{@request
  const grpc = require('@grpc/grpc-js');
  request.channelCredentials = grpc.ChannelCredentials.createSsl();
}}
GRPC grpc.example.com/HelloService/SayHello

{
  "greeting": "world"
}
```

**Server Streaming:**
```http
proto < ./hello.proto

GRPC grpc.example.com/HelloService/LotsOfReplies

{
  "greeting": "world"
}
```

**Client Streaming:**
```http
proto < ./hello.proto

GRPC grpc.example.com/HelloService/LotsOfGreetings

{
  "greeting": "첫 번째"
}

{{@streaming
  async function writeStream() {
    await sleep(1000);
    await $requestClient.send({ greeting: '두 번째' });
    await sleep(1000);
    await $requestClient.send({ greeting: '세 번째' });
  }
  exports.waitPromise = writeStream();
}}
```

**Bidirectional Streaming:**
```http
proto < ./hello.proto

GRPC grpc.example.com/HelloService/BidiHello

{
  "greeting": "시작"
}
===
{
  "greeting": "두 번째"
}
=== wait-for-server
=== wait-for-server
{
  "greeting": "마지막"
}
```

**gRPC Reflection (proto 파일 없이):**
```http
# @grpc-reflection
GRPC grpc.example.com/HelloService/SayHello

{
  "greeting": "world"
}
```

---

### 11.3. WebSocket

`WS` 메서드로 WebSocket 연결을 열고 메시지를 주고받는다.

```http
WS wss://echo.websocket.org/

{
  "type": "hello",
  "message": "httpYac에서 보냅니다"
}

{{@streaming
  async function communicate() {
    // 서버 응답 대기
    await sleep(2000);

    // 추가 메시지 전송
    $requestClient.send({
      type: "ping",
      timestamp: Date.now()
    });

    await sleep(3000);

    $requestClient.send({
      type: "goodbye",
      message: "종료합니다"
    });

    await sleep(1000);
  }
  exports.waitPromise = communicate();
}}
```

**연결 유지:**
```http
# @keepStreaming
WS wss://echo.websocket.org/

{
  "type": "subscribe",
  "channel": "updates"
}
```

---

### 11.4. Server-Sent Events (SSE)

서버에서 이벤트를 지속적으로 수신한다.

```http
SSE https://example.com/events
Event: message

{{@streaming
  async function listenEvents() {
    await sleep(30000);  // 30초 동안 이벤트 수신
  }
  exports.waitPromise = listenEvents();
}}
```

**지속 연결:**
```http
# @keepStreaming
SSE https://example.com/events
```

---

### 11.5. MQTT

**메시지 발행 (Publish):**
```http
MQTT tcp://broker.hivemq.com
Topic: my-app/notifications

{
  "type": "alert",
  "message": "새 알림이 있습니다"
}
```

**토픽 구독 (Subscribe):**
```http
# @keepStreaming
MQTT tcp://broker.hivemq.com
subscribe: my-app/notifications
```

**인증 옵션:**
```http
MQTT tcp://broker.example.com
Topic: secure-topic
Qos: 1
username: mqttuser
password: mqttpass
retain: true
keepAlive: 60

{
  "data": "secure message"
}
```

---

### 11.6. AMQP / RabbitMQ

**메시지 발행:**
```http
AMQP amqp://guest:guest@localhost
amqp_exchange: my_exchange
amqp_routing_key: my.route

{
  "order_id": "{{$uuid}}",
  "status": "created"
}
```

**큐 직접 발행:**
```http
AMQP amqp://guest:guest@localhost
amqp_queue: my_queue

{
  "task": "process_order"
}
```

**메시지 소비 (구독):**
```http
# @keepStreaming
AMQP amqp://guest:guest@localhost
amqp_method: consume
amqp_queue: my_queue
```

**Exchange/Queue 선언:**
```http
### Exchange 선언
AMQP amqp://guest:guest@localhost
amqp_method: declare
amqp_exchange: my_exchange

### Queue 선언 및 바인딩
AMQP amqp://guest:guest@localhost
amqp_method: declare
amqp_queue: my_queue

###
AMQP amqp://guest:guest@localhost
amqp_method: bind
amqp_exchange: my_exchange
amqp_queue: my_queue
amqp_routing_key: my.route
```

---

## 12. Hooks (플러그인)

httpYac은 플러그인 기반 아키텍처를 사용한다. `httpyac.config.js` 파일에서 Hook을 설정할 수 있다.

```javascript
// httpyac.config.js (프로젝트 루트)
module.exports = {
  configureHooks: function(api) {
    // 응답 로깅 시 민감한 헤더 제거
    api.hooks.responseLogging.addHook('removeSensitiveData', function(response) {
      if (response.request) {
        delete response.request.headers['authorization'];
        delete response.request.headers['cookie'];
      }
    });

    // 모든 요청에 커스텀 헤더 추가
    api.hooks.onRequest.addHook('addTraceId', function(request) {
      const { v4: uuidv4 } = require('uuid');
      request.headers['X-Trace-Id'] = uuidv4();
    });
  }
};
```

---

## 13. Injected Languages

httpYac는 `.http` 파일 외에도 다른 파일 형식에서 HTTP 요청 블록을 인식할 수 있다.

### Markdown

````markdown
# API 문서

아래 요청으로 사용자 목록을 가져올 수 있습니다:

```http
GET https://api.example.com/users
Authorization: Bearer {{token}}
```
````

### Asciidoctor

```asciidoc
[source,http]
----
GET https://api.example.com/users
Authorization: Bearer {{token}}
----
```

---
