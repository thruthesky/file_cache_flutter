# v7 AI 시스템 (웹 홈페이지) — 답변 + 챗봇

## 1. 개요

이 문서는 v7 웹 홈페이지의 AI 관련 기능 두 가지를 다룬다:

1. **AI 답변 시스템** (1~13장): qna/freetalk 게시판의 글에 AI 답변을 제공
2. **AI 챗봇** (14장~): 필리핀 전문 도우미 "필립(Philip)" 대화형 챗봇

두 기능 모두 PHP 서버에서 Gemini API를 SSE(Server-Sent Events) 스트리밍으로 호출하고,
브라우저에서 실시간으로 응답을 렌더링한다.

### 1.1. AI 답변 시스템

qna/freetalk 게시판의 글에 AI 답변을 제공하는 시스템이다.

---

## 2. 적용 대상 게시판

| post_id | 설명 |
|---------|------|
| `qna` | 질문답변 게시판 |
| `freetalk` | 자유게시판 |

- `post_id` 기반으로 게시판을 검증한다.
- 위 두 게시판 이외의 글에서는 AI 답변 기능이 동작하지 않는다.
- **info 게시글 제외**: `group_id='info'`인 게시글(여행지, 병원, 긴급연락처 등 정보 게시글)은 `freetalk` 게시판에 속하더라도 AI 답변 대상에서 제외된다. info 게시글은 자체 정보 위젯으로 별도 렌더링되므로 AI 답변이 필요하지 않다.

```php
// view.php에서 AI 답변 대상 판별
$isAiAnswerTarget = !$post->isInfoPost()
    && in_array($post->post_id, ['qna', 'freetalk'], true)
    && $post->idx_parent == 0;
```

---

## 3. 전체 아키텍처

```
브라우저 (fetch)
  → POST /ai-api.php (method=ai.answerPost, idx만 전달)
  → Nginx (location = /ai-api.php → AI FPM 풀 포트 9001)
  → AiController::answerPost()
  → AiService::generatePostAnswerStream(idx, onChunk)
    → DB에서 subject, content 조회
    → 프롬프트 자동 구성
  → GeminiClient::generateContentStream()
  → Gemini API (streamGenerateContent?alt=sse)
  → SSE 스트리밍 응답
  → cURL WRITEFUNCTION 콜백
  → PHP echo + flush (청크 즉시 전달)
  → 브라우저 (ReadableStream 파싱, 마크다운 렌더링)
  → SSE 완료 후 서버에서 AiService::saveAnswer() 자동 호출
```

- 일반 API(`/api.php`)와 완전히 분리된 `/ai-api.php` 전용 엔트리포인트를 사용한다.
- Nginx에서 AI 전용 PHP-FPM 풀(포트 9001)로 분기하여, 일반 요청과 AI 요청의 프로세스를 격리한다.
- SSE 스트리밍을 위해 `fastcgi_buffering off`, `X-Accel-Buffering: no` 헤더가 필수이다.
- **1번 통신**: 클라이언트는 SSE 요청만 보내면 된다. 스트리밍 완료 후 서버가 자동으로 `text_7`에 저장한다.

---

## 4. 데이터 저장

- AI 답변은 `sf_post_data.text_7` 필드에 저장한다.
- **서버 자동 저장**: `ai.answerPost` API에서 SSE 스트리밍 완료 후 서버가 자동으로 `text_7`에 저장한다. 클라이언트가 별도로 `ai.saveAnswer`를 호출할 필요가 없다.
- `ai.saveAnswer` API는 독립적으로도 호출 가능하지만, `ai.answerPost`를 사용하면 별도 호출이 불필요하다.
- 중복 저장 방지: `text_7`이 이미 존재하면 생성과 저장 모두 거부한다.

---

## 5. 파일 구조

| 파일 | 설명 |
|------|------|
| `ai-api.php` | AI 전용 엔트리포인트 (`api.php`를 require하는 래퍼) |
| `lib/ai/AiController.php` | `answerPost()`, `saveAnswer()`, `enforceAiApiEndpoint()` |
| `lib/ai/AiService.php` | `generatePostAnswerStream()`, `saveAnswer()`, `getPostAnswerSystemPrompt()` |
| `lib/ai/GeminiClient.php` | `generateContentStream()`, `callApiStream()` |
| `v7/js/ai-stream.js` | `parseGeminiSSEStream()` — SSE 스트림 파서 |
| `v7/js/ai-markdown.js` | AI 답변용 마크다운 렌더러 |
| `v7/js/post-actions.js` | `doAiAnswer()` — Vue.js 메서드 |
| `v7/post/view.php` | AI 답변 SSR 표시 영역 (`#ai-answer-result`) |
| `v7/post/view.css` | AI 답변 CSS 스타일 |
| `docker/etc/nginx/nginx.conf` | AI FPM 풀 라우팅 (`location = /ai-api.php`) |
| `docker/etc/php-fpm.d/ai.conf` | AI 전용 FPM 풀 설정 (포트 9001) |

---

## 6. SSE 스트리밍 전체 흐름

### 6.1. 클라이언트 (브라우저)

1. 사용자가 AI 답변 버튼을 클릭한다.
2. `doAiAnswer()` Vue.js 메서드가 실행된다.
3. `fetch('/ai-api.php', { method: 'POST', body: ... })`로 SSE 요청을 보낸다. **`idx`만 전달** (prompt, post_idx 제거됨).
4. `response.body.getReader()`로 ReadableStream을 획득한다.
5. `parseGeminiSSEStream()`으로 SSE 데이터를 파싱한다.
6. 각 청크에서 텍스트를 추출하여 누적한다.
7. 누적된 텍스트를 마크다운 렌더러(`ai-markdown.js`)로 변환하여 DOM에 업데이트한다.
8. 스트리밍 완료 시 클라이언트 작업 종료. **서버가 자동으로 답변을 저장하므로 별도 API 호출 불필요.**

### 6.2. 서버 (PHP)

1. `AiController::answerPost()`이 호출된다.
2. `enforceAiApiEndpoint()`로 `ai-api.php` 경로를 검증한다.
3. SSE 헤더를 설정한다: `Content-Type: text/event-stream`, `X-Accel-Buffering: no`.
4. `AiService::generatePostAnswerStream(idx, onChunk)`을 호출한다.
5. DB에서 `subject`, `content`를 조회하여 프롬프트를 자동 구성한다.
6. 모델 화이트리스트를 검증한다.
7. 게시판 검증 (qna/freetalk만 허용)한다.
8. 30일 제한 검증 (`AI_ANSWER_MAX_AGE_SECONDS = 2,592,000초`).
9. 중복 방지 (`text_7`이 이미 있으면 거부)한다.
10. 코멘트 거부 (`idx_parent > 0`이면 거부)한다.
11. `GeminiClient::generateContentStream()`을 호출한다.
12. cURL `WRITEFUNCTION` 콜백으로 Gemini API의 SSE 청크를 즉시 `echo` + `flush`한다.
13. SSE 청크에서 텍스트를 누적한다.
14. **스트리밍 완료 후 `AiService::saveAnswer()`를 자동 호출하여 `text_7`에 저장**한다.
15. `exit`으로 `api.php`의 JSON 응답을 우회한다.

---

## 7. Gemini 모델

| 용도 | 모델명 |
|------|--------|
| 기본 모델 | `gemini-3.1-flash-lite-preview` |
| 폴백 모델 | `gemini-2.5-flash-lite` |

- 모델 화이트리스트 검증을 수행하여, 허용되지 않은 모델은 거부한다.
- 클라이언트에서 `model` 파라미터로 모델을 지정할 수 있다.

---

## 8. 시스템 프롬프트

`AiService::getPostAnswerSystemPrompt()`에서 시스템 프롬프트를 생성한다.
필리핀 전문 도우미 역할로, 한국어로 답변하도록 설정되어 있다.

### 주요 규칙

- 필리핀 관련 게시글에만 답변 제공
- 한국어로만 답변
- 간단명료하고 정확한 정보 제공
- 모호한 답변 지양: 사실이 불확실하면 "모르겠습니다"라고 답변
- 필리핀 무관 주제 시 거부 메시지

### 이모지 마크다운 포맷 규칙

시스템 프롬프트에 이모지 사용 규칙이 포함되어 있다.

| 규칙 | 설명 |
|------|------|
| **섹션 제목에 이모지 적극 사용** | 시각적으로 보기 좋게 작성 |
| **핵심 정보 볼드 처리** | `**텍스트**` 형식 |
| **리스트 사용** | 번호 리스트(1. 2. 3.) 또는 불릿 리스트(- ) |
| **주의사항 아이콘** | 중요한 주의사항은 이모지 아이콘과 함께 표시 |

사용되는 이모지 목록: 📋, 📌, ✅, 💡, ⚠️, 🔗, 📍, 🏢, 📞, 💰, 🗓️, ✈️, 🇵🇭 등

---

## 9. 마크다운 렌더링

### 9.1. JavaScript (클라이언트 — SSE 스트리밍 중 실시간 렌더링)

`v7/js/ai-markdown.js`에서 마크다운을 HTML로 변환한다.

지원 문법:
- 헤딩 (`#`, `##`, `###`)
- 리스트 (순서 있는/없는)
- 볼드 (`**텍스트**`)
- 인라인 코드 (`` `코드` ``)
- 코드 블록 (` ``` `)
- 링크 (`[텍스트](URL)`)

### 9.2. PHP SSR (서버 — 저장된 답변 표시)

`convertMarkdownToHtml()` 함수로 저장된 마크다운 답변을 HTML로 변환하여 SSR로 표시한다.
`v7/post/view.php`의 `#ai-answer-result` 영역에 렌더링된다.

---

## 10. PHP-FPM AI 풀 분리 설정

AI 요청은 일반 요청과 별도의 PHP-FPM 풀에서 처리된다.
이는 AI 요청의 긴 처리 시간이 일반 요청에 영향을 미치지 않도록 하기 위함이다.

### 3개 환경별 설정

| 환경 | FPM 풀 설정 위치 | 포트 |
|------|-----------------|------|
| 로컬 Docker | `docker/etc/php-fpm.d/ai.conf` | 9001 |
| Dokploy | `docker/dokploy-deploy/etc/php-fpm.d/ai.conf` | 9001 |
| 프로덕션 | 서버 내 FPM 설정 | 9001 |

---

## 11. Nginx SSE 스트리밍 설정

SSE 스트리밍이 정상 작동하려면 Nginx에서 버퍼링을 비활성화해야 한다.

```nginx
location = /ai-api.php {
    fastcgi_pass php:9001;       # AI 전용 FPM 풀
    fastcgi_buffering off;        # SSE 스트리밍 필수 — 버퍼링 비활성화
    fastcgi_read_timeout 120;     # AI 응답 대기 시간 (최대 120초)
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

PHP 측에서도 `X-Accel-Buffering: no` 헤더를 전송하여 Nginx 버퍼링을 명시적으로 비활성화한다.

---

## 12. 보안

| 보안 항목 | 설명 |
|-----------|------|
| `enforceAiApiEndpoint()` | `$_SERVER['SCRIPT_NAME']`이 `ai-api.php`인지 검증. `/api.php`로 직접 호출 시 RuntimeException |
| 모델 화이트리스트 | 허용된 모델(`gemini-3.1-flash-lite-preview`, `gemini-2.5-flash-lite`)만 사용 가능 |
| 게시판 검증 | `qna`, `freetalk` 게시판의 글만 AI 답변 대상 |
| 중복 방지 | `sf_post_data.text_7`이 이미 존재하면 새 답변 생성/저장을 거부 |
| 코멘트 거부 | `idx_parent > 0`인 코멘트에는 AI 답변을 생성할 수 없음 |
| 30일 제한 | `AI_ANSWER_MAX_AGE_SECONDS = 2,592,000초` (30일). 작성 후 30일 초과 글에는 AI 답변 생성 거부 |
| 서버 프롬프트 구성 | 클라이언트가 prompt를 전달하지 않음. 서버가 DB에서 제목+내용을 조회하여 프롬프트를 구성하므로 프롬프트 인젝션 위험 감소 |

---

## 13. API 파라미터 변경 이력

### ai.generateStream → ai.answerPost 마이그레이션

| 항목 | ai.generateStream (이전) | ai.answerPost (현재) |
|------|--------------------------|----------------------|
| **method** | `ai.generateStream` | `ai.answerPost` |
| **입력: prompt** | ✅ 필수 (클라이언트 전달) | ❌ 제거 (서버 자동 구성) |
| **입력: post_idx** | ❌ 선택 | ❌ 제거 (`idx`로 통합) |
| **입력: idx** | ❌ 없음 | ✅ 필수 |
| **입력: model** | ❌ 선택 | ❌ 선택 |
| **프롬프트 구성** | 클라이언트 | 서버 (DB 조회 → `strip_tags()` → 프롬프트 구성) |
| **답변 저장** | 클라이언트가 `ai.saveAnswer` 별도 호출 | 서버 자동 저장 (SSE 완료 후) |
| **통신 횟수** | 2번 (SSE + saveAnswer) | 1번 (SSE만) |
| **30일 제한** | 없음 | 있음 (`AI_ANSWER_MAX_AGE_SECONDS`) |
| **AiService 메서드** | `generateStream()` | `generatePostAnswerStream(int $idx, callable $onChunk, ?string $model)` |

### JS 변경사항

| 항목 | 이전 | 현재 |
|------|------|------|
| **API method** | `ai.generateStream` | `ai.answerPost` |
| **전달 데이터** | `prompt`, `post_idx` | `idx`만 |
| **postSubject 변수** | 사용 | 제거 |
| **data-subject 속성** | 사용 | 제거 |
| **저장 호출** | `ai.saveAnswer` 별도 호출 | 불필요 (서버 자동) |

---

## 14. AI 챗봇 — 필립(Philip) 필리핀 전문 도우미

### 14.1. 개요

v7 AI 챗봇은 필리핀 전문 도우미 "필립(Philip)"으로, 사용자와 대화형 인터페이스로 필리핀 관련 정보를 제공한다.
v6의 `widgets/ai/chatbot.php` + `page/ai/index.php`를 v7 아키텍처로 재구현한 것이다.

| 항목 | v6 (기존) | v7 (현재) |
|------|-----------|-----------|
| **AI 호출** | 클라이언트 JS에서 Vertex AI SDK 직접 호출 | PHP 서버에서 Gemini REST API + SSE 스트리밍 |
| **Enhanced Prompt** | 클라이언트 JS (`enhance-prompt.js`) | PHP `AiService::generateEnhancedPrompt()` |
| **채팅 기록** | Firebase RTDB `/ai/chatbot` | Firebase RTDB `/ai/chatbot` (동일 구조) |
| **UI** | v6 위젯 | Vue.js 3 Options API + Web Awesome Pro CSS |

### 14.2. 접속 URL

| 환경 | URL |
|------|-----|
| **로컬 개발** | `https://v7-local.philgo.com/ai` |
| **테스트 서버** | `https://philgo.net/ai` |
| **프로덕션** | `https://philgo.com/ai` |

### 14.3. 전체 아키텍처

```
사용자 입력
  → Vue.js sendMessage()
  → Firebase RTDB /ai/chatbot/{pushId} 에 사용자 메시지 저장
  → fetch('/ai-api.php', method=ai.chatbot, message=...) SSE 요청
  → PHP: AiController::chatbot()
    → AiService::chatbotStream()
      → generateEnhancedPrompt(message) — philippines-info.json 키워드 매칭
      → GeminiClient::generateContentStream(systemPrompt, enhancedPrompt)
    → SSE 청크 echo + flush
  → 클라이언트: parseGeminiSSEStream() 파싱 + markdown() 렌더링
  → 스트리밍 완료 후: Firebase RTDB /ai/chatbot/{pushId} 에 AI 응답 저장
    (sender_uid: 'ai-bot', metadata: {model, processedAt})
```

### 14.4. 파일 구조

| 파일 | 설명 |
|------|------|
| `v7/ai/index.php` | AI 챗봇 웹 페이지 (PHP SSR + Vue.js CSR) |
| `v7/ai/chatbot.css` | 챗봇 CSS 스타일 (Web Awesome Pro CSS 변수 기반) |
| `v7/ai/chatbot.js` | Vue.js 3 Options API 챗봇 컴포넌트 + Firebase RTDB 연동 |
| `lib/ai/AiController.php` | `chatbot()` 메서드 — SSE 엔드포인트 |
| `lib/ai/AiService.php` | `chatbotStream()`, `generateEnhancedPrompt()`, `getChatbotSystemPrompt()` |
| `etc/data/philippines-info.json` | Enhanced Prompt용 필리핀 정보 키워드 데이터 |
| `v7/js/ai-stream.js` | `parseGeminiSSEStream()` — SSE 스트림 파서 (AI 답변 시스템과 공유) |
| `v7/js/ai-markdown.js` | `markdown()` — 마크다운 렌더러 (AI 답변 시스템과 공유) |

### 14.5. Firebase RTDB 데이터 구조

```
/ai/chatbot/{pushId}: {
    message: string,           // 메시지 내용
    sender_uid: string,        // 사용자 Firebase UID 또는 'ai-bot'
    sender: string,            // 'user' 또는 'ai'
    created_at: timestamp,     // firebase.database.ServerValue.TIMESTAMP
    metadata?: {               // AI 응답에만 포함
        model: string,         // 예: 'gemini-2.5-flash-lite'
        processedAt: string    // ISO 8601 문자열
    }
}
```

- v6과 동일한 RTDB 경로(`/ai/chatbot`)와 데이터 구조를 사용
- 사용자 메시지: `sender_uid`에 사용자의 Firebase UID, `sender: 'user'`
- AI 응답: `sender_uid: 'ai-bot'`, `sender: 'ai'`, `metadata` 포함

### 14.6. Vue.js 챗봇 컴포넌트 (chatbot.js)

Vue.js 3 Options API로 구현된 챗봇 컴포넌트이다.

**주요 data:**

| 속성 | 타입 | 설명 |
|------|------|------|
| `inputMessage` | string | 사용자 입력 메시지 |
| `allMessages` | array | 모든 채팅 메시지 목록 |
| `chunkTexts` | string | SSE 스트리밍 중인 AI 응답 텍스트 |
| `isAiThinking` | boolean | AI 응답 대기 중 여부 |
| `isLoadingInitial` | boolean | 초기 메시지 로딩 중 여부 |
| `suggestions` | array | 추천 질문 목록 |

**주요 methods:**

| 메서드 | 설명 |
|--------|------|
| `loadInitialMessages()` | Firebase RTDB에서 최근 20개 메시지 로드 |
| `setupRealtimeListener()` | `child_added` 이벤트로 실시간 메시지 수신 |
| `loadPreviousMessages()` | 스크롤 상단 도달 시 이전 20개 메시지 로드 (무한 스크롤) |
| `sendMessage()` | 메시지 전송: Firebase RTDB 저장 + SSE 요청 |
| `requestAiResponse(message)` | `fetch('/ai-api.php')` → `parseGeminiSSEStream()` → `markdown()` 렌더링 |
| `useSuggestion(s)` | 추천 질문 클릭 시 자동 전송 |
| `renderMarkdown(text)` | 기존 `markdown()` 함수 재활용 |
| `scrollToBottom()` | 메시지 영역 맨 아래로 스크롤 |

**메시지 전송 흐름:**

1. `sendMessage()` 호출
2. Firebase RTDB에 사용자 메시지 push (`sender: 'user'`)
3. `requestAiResponse(message)` 호출
4. `fetch('/ai-api.php', {method: 'POST', body: {method: 'ai.chatbot', message}})` SSE 요청
5. `parseGeminiSSEStream(response)` — `for await` 루프로 청크 수신
6. 청크마다 `chunkTexts`에 누적 → `markdown()` 렌더링으로 실시간 표시
7. 스트리밍 완료 → Firebase RTDB에 AI 응답 push (`sender_uid: 'ai-bot'`, `metadata` 포함)
8. `chunkTexts` 초기화, `isAiThinking` 해제

### 14.7. Enhanced Prompt 시스템

v6에서는 클라이언트 JS(`enhance-prompt.js`)에서 처리하던 Enhanced Prompt를 v7에서는 PHP 서버(`AiService::generateEnhancedPrompt()`)에서 처리한다.

**`etc/data/philippines-info.json` 구조:**

```json
{
    "embassy_info": {
        "content": "주 필리핀 대한민국 대사관 주소: ...",
        "required_keywords": ["대사관", "Embassy", "영사관"],
        "optional_keywords": ["비자", "여권", "공증"]
    },
    "hospital_info": {
        "content": "마닐라 주요 병원: ...",
        "required_keywords": ["병원", "Hospital", "의원"],
        "optional_keywords": ["응급", "진료", "약국"]
    }
}
```

**키워드 매칭 알고리즘:**

1. 사용자 질문을 소문자로 변환
2. 각 카테고리의 `required_keywords`(가중치 3) + `optional_keywords`(가중치 1) 매칭
3. 점수 >= `MIN_RELEVANCE_SCORE`인 카테고리의 `content`를 컨텍스트로 추가
4. 매칭 카테고리가 없으면 사용자 질문만 전달

### 14.8. 시스템 프롬프트 (필립)

`AiService::getChatbotSystemPrompt()`에서 생성하는 시스템 프롬프트의 핵심 규칙:

- 역할: 필리핀 전문 도우미 "필립(Philip)"
- 한국어 전용 답변
- 인사말 생략, 바로 답변 시작
- 간결하고 정확한 정보 제공
- 불확실하면 "모르겠습니다" 명시
- 필리핀 무관 주제: 거부 메시지 표시
- 이모지 마크다운 포맷 적극 사용

### 14.9. 로그인 분기

- 로그인 사용자: Vue.js 챗봇 앱 마운트, 입력 폼 활성화
- 비로그인 사용자: 로그인 안내 메시지 + 로그인 링크 표시
- PHP에서 `AuthService::getLoginUser()`로 로그인 상태 확인
- Firebase UID는 PHP에서 `window.v7AiChatbot.firebaseUid`로 JS에 전달

### 14.10. 공유 모듈 재활용

AI 챗봇은 AI 답변 시스템과 다음 모듈을 공유한다:

| 공유 모듈 | 파일 | 설명 |
|-----------|------|------|
| SSE 스트림 파서 | `v7/js/ai-stream.js` | `parseGeminiSSEStream()` — Gemini SSE 응답 파싱 |
| 마크다운 렌더러 | `v7/js/ai-markdown.js` | `markdown()` — 마크다운 → HTML 변환 |
| SSE 엔트리포인트 | `ai-api.php` | AI 전용 PHP-FPM 풀 (포트 9001) |
| Gemini 클라이언트 | `lib/ai/GeminiClient.php` | `generateContentStream()` SSE 스트리밍 |

### 14.11. CSS 스타일

`v7/ai/chatbot.css` — Web Awesome Pro CSS 변수 기반, Bootstrap 미사용, 다크 모드 미적용.

- 전체 높이 채움: `height: calc(100vh - 8rem)`
- 헤더: 블루 배경 (`--wa-color-brand-600`)
- 메시지 영역: flex column + 스크롤
- 사용자 메시지: 오른쪽 정렬, 블루 배경 (`--wa-color-brand-600`)
- AI 메시지: 왼쪽 정렬, 흰 배경 + 테두리
- AI 생각중: 점 3개 바운스 애니메이션
- 추천 질문 칩: pill 형태 버튼
- 모바일 반응형: `@media (max-width: 991px)`

### 14.12. 보안

| 항목 | 설명 |
|------|------|
| `enforceAiApiEndpoint()` | `ai-api.php` 경로 강제 |
| 로그인 필수 | 비로그인 시 챗봇 입력 비활성화 (PHP SSR 분기) |
| 모델 화이트리스트 | `ALLOWED_CHATBOT_MODELS` 배열로 허용 모델 제한 |
| Enhanced Prompt 서버 처리 | 클라이언트가 프롬프트를 직접 구성하지 않음 |
| Firebase RTDB 규칙 | `/ai/chatbot` 경로에 Firebase Security Rules 적용 |
