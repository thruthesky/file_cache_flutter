# 필고 파일 업로드 스킬 가이드

## 목차

- [개요](#개요)
- [주요 기능](#주요-기능)
- [설치 및 설정](#설치-및-설정)
- [컴포넌트 위치](#컴포넌트-위치)
- [Props 목록](#props-목록)
- [Events 이벤트](#events-이벤트)
- [사용 예제](#사용-예제)
  - [기본 사용법](#기본-사용법)
  - [단일 이미지 업로드](#단일-이미지-업로드-프로필-사진)
  - [다중 파일 업로드](#다중-파일-업로드-갤러리)
  - [QR 코드 디코딩](#qr-코드-디코딩)
  - [v-model 사용](#v-model-사용-예제)
- [실용적 시나리오](#실용적-시나리오)
  - [프로필 사진 업로드](#프로필-사진-업로드)
  - [게시글 파일 첨부](#게시글-파일-첨부)
- [고급 사용법](#고급-사용법)
- [CSS 커스터마이징](#css-커스터마이징)
- [폼과 함께 사용하기](#폼과-함께-사용하기)
- [내부 동작 원리](#내부-동작-원리)
- [다국어 번역 지원](#다국어-번역-지원)
- [파일 타입 감지 및 아이콘](#파일-타입-감지-및-아이콘)
- [API 연동](#api-연동)
- [접근성 및 브라우저 지원](#접근성-및-브라우저-지원)
- [주요 특징](#주요-특징)
- [DisplayFileComponent](#displayfilecomponent)
- [문제 해결](#문제-해결)
- [마이그레이션 가이드](#마이그레이션-가이드)

---

## 개요

이 스킬은 필고 홈페이지에서 사용하는 **Vue.js 기반 파일 업로드 컴포넌트**를 개발하고 사용하는 방법을 안내한다.

- **컴포넌트 파일**: `js/vue-components/file-upload.component.js`
- **전역 객체**: `window.FileUploadComponent`
- **Vue.js 버전**: 3.x (Options API)
- **적용 범위**: 프로필 사진, 게시글 첨부 파일, 갤러리, 업소록 이미지 등 모든 파일 업로드 시나리오

---

## 주요 기능

### 1. 단일/다중 파일 업로드

- **Single 모드** (`single: true`): 하나의 파일만 업로드, 새 파일 선택 시 기존 파일 자동 교체
- **Multiple 모드** (`single: false`): 여러 파일 동시 업로드 가능

### 2. 파일 타입별 미리보기

- **이미지**: `<img>` 태그로 표시 (jpg, png, gif, webp 등)
- **비디오**: `<video>` 태그로 재생 가능 (mp4, webm, mov 등)
- **기타 파일**: 확장자 아이콘 표시 (PDF, DOC, ZIP 등)

### 3. 업로드 진행률 표시

- Progress Bar로 실시간 업로드 진행 상황 표시
- Axios의 `onUploadProgress` 이벤트 활용

### 4. QR 코드 디코딩

- `decode-qr-code` prop 활성화 시 이미지의 QR 코드 자동 디코딩
- 서버 응답에 `qr_code` 데이터 포함

### 5. v-model 양방향 바인딩 지원

- 업로드된 파일 URL 배열을 v-model로 관리 가능

### 6. 다국어 지원

- 4개 국어(ko, en, ja, zh) 자동 번역

---

## 설치 및 설정

### 1단계: 컴포넌트 로드

```php
<?php
// PHP 페이지 상단에서 컴포넌트 로드
load_deferred_js('vue-components/file-upload.component');
?>
```

### 2단계: Vue 앱에서 컴포넌트 등록

```javascript
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        data() {
            return {
                uploadedFiles: []
            };
        }
    }).mount('#app');
});
```

---

## 컴포넌트 위치

- **파일 경로**: `js/vue-components/file-upload.component.js`
- **전역 객체**: `window.FileUploadComponent`
- **로드 방법**:
  ```php
  <?php load_deferred_js('vue-components/file-upload.component'); ?>
  ```

---

## Props 목록

| Props | 타입 | 기본값 | 설명 |
|-------|------|--------|------|
| `single` | Boolean | `false` | 단일 파일 모드 (기존 파일 자동 교체) |
| `input-name` | String | `''` | Hidden input의 name 속성 |
| `show-upload-button` | Boolean | `true` | 업로드 버튼 표시 여부 |
| `upload-button-type` | String | `'default'` | 업로드 버튼 타입 (`"default"` 또는 `"camera-icon"`) |
| `show-uploaded-files` | Boolean | `true` | 업로드된 파일 미리보기 표시 여부 |
| `show-delete-icon` | Boolean | `false` | 삭제 아이콘 표시 여부 |
| `show-progress-bar` | Boolean | `true` | Progress bar 표시 여부 |
| `decode-qr-code` | Boolean | `false` | QR 코드 디코딩 활성화 |
| `accept` | String | `'*'` | 파일 타입 제한 (예: `"image/*"`) |
| `default-files` | String | `''` | 기본 파일 URL (쉼표로 구분된 문자열) |

### Props 상세 설명

- **`single`**: `true`로 설정 시 단일 파일만 업로드되며, 새 파일 선택 시 기존 파일이 자동으로 교체된다.

- **`input-name`**: 서버로 전송할 때 사용할 hidden input의 name 속성. 예: `"profile_photo"`, `"gallery[]"`

- **`show-upload-button`**: `false`로 설정 시 업로드 버튼이 숨겨진다. Single 모드에서 이미지를 클릭하여 업로드하는 경우 유용.

- **`upload-button-type`**: 업로드 버튼의 스타일을 지정.
  - `"default"`: 기본 버튼 스타일 (텍스트 + 아이콘)
  - `"camera-icon"`: 카메라 아이콘만 표시 (Modal이나 채팅 UI에 적합)

- **`show-delete-icon`**: `true`로 설정 시 업로드된 파일에 삭제 아이콘(X 버튼)이 표시.

- **`decode-qr-code`**: `true`로 설정 시 업로드된 이미지에서 QR 코드를 자동으로 디코딩.

- **`accept`**: HTML5 input accept 속성과 동일. 예: `"image/*"` (이미지만), `"image/*,video/*"` (이미지와 비디오)

- **`default-files`**: 초기 로드 시 표시할 파일 URL을 쉼표로 구분된 문자열로 전달.

---

## Events 이벤트

| Event | Payload | 설명 |
|-------|---------|------|
| `@uploaded` | `{ url: string, qr_code: string }` | 파일 업로드 완료 시 발생 |
| `@deleted` | `response.data` | 파일 삭제 완료 시 발생 |
| `@update:modelValue` | `string[]` | v-model 업데이트 (파일 URL 배열) |
| `@uploading-progress` | `{ progress: number, uploading: boolean }` | 업로드 진행률 변경 시 발생 |

### Events 상세 설명

- **`@uploaded`**: 파일이 성공적으로 업로드된 후 즉시 발생.
  - `url`: 업로드된 파일의 URL
  - `qr_code`: QR 코드 디코딩 결과 (활성화된 경우)

- **`@deleted`**: 파일이 성공적으로 삭제된 후 발생. 서버의 삭제 API 응답 데이터가 전달.

- **`@update:modelValue`**: v-model 사용 시 파일 목록이 변경될 때마다 발생.

- **`@uploading-progress`**: 업로드 진행률이 변경될 때마다 발생. 커스텀 progress bar를 구현할 때 사용.

---

## 사용 예제

### 기본 사용법

```html
<div id="app">
    <file-upload
        input-name="attachments"
        @uploaded="handleUpload">
    </file-upload>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        methods: {
            handleUpload(data) {
                console.log('파일 업로드 완료:', data.url);
            }
        }
    }).mount('#app');
});
</script>
```

### 단일 이미지 업로드 (프로필 사진)

```html
<?php load_deferred_js('vue-components/file-upload.component'); ?>

<div id="profile-app">
    <file-upload
        :single="true"
        input-name="profile_photo"
        :show-delete-icon="true"
        accept="image/*"
        :default-files="profilePhotoUrl"
        @uploaded="handleUpload">
    </file-upload>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        data() {
            return {
                profilePhotoUrl: '/uploads/default-avatar.jpg'
            };
        },
        methods: {
            handleUpload(data) {
                console.log('업로드 완료:', data.url);
                this.profilePhotoUrl = data.url;
            }
        }
    }).mount('#profile-app');
});
</script>
```

### 다중 파일 업로드 (갤러리)

```html
<div id="gallery-app">
    <file-upload
        :single="false"
        input-name="gallery[]"
        :show-delete-icon="true"
        accept="image/*,video/*"
        :default-files="galleryFiles"
        @uploaded="handleGalleryUpload"
        @deleted="handleGalleryDelete">
    </file-upload>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        data() {
            return {
                // 쉼표로 구분된 문자열
                galleryFiles: '/uploads/photo1.jpg,/uploads/photo2.jpg'
            };
        },
        methods: {
            handleGalleryUpload(data) {
                console.log('갤러리 사진 추가:', data.url);
            },
            handleGalleryDelete(data) {
                console.log('갤러리 사진 삭제:', data);
            }
        }
    }).mount('#gallery-app');
});
</script>
```

### QR 코드 디코딩

```html
<file-upload
    :single="true"
    :decode-qr-code="true"
    input-name="qr_image"
    @uploaded="handleQrUpload">
</file-upload>

<script>
methods: {
    handleQrUpload(data) {
        console.log('QR 코드 내용:', data.qr_code);
        console.log('이미지 URL:', data.url);
    }
}
</script>
```

### v-model 사용 예제

```html
<div id="app">
    <file-upload
        v-model="uploadedFiles"
        :single="false"
        input-name="files[]"
        :default-files="initialFiles"
        :show-delete-icon="true">
    </file-upload>

    <!-- 업로드된 파일 목록 표시 -->
    <ul>
        <li v-for="url in uploadedFiles" :key="url">{{ url }}</li>
    </ul>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        data() {
            return {
                // v-model로 파일 URL 목록 관리 (배열)
                uploadedFiles: [],
                // default-files는 쉼표로 구분된 문자열
                initialFiles: '/uploads/file1.jpg,/uploads/file2.pdf'
            };
        }
    }).mount('#app');
});
</script>
```

---

## 실용적 시나리오

### 프로필 사진 업로드

```php
<div id="profile-app">
    <h3>프로필 사진</h3>

    <file-upload
        :single="true"
        input-name="profile_photo"
        :show-delete-icon="true"
        accept="image/*"
        :default-files="profilePhoto"
        @uploaded="handleProfileUpload"
        @deleted="handleProfileDelete">
    </file-upload>

    <div v-if="profilePhoto" class="mt-3">
        <p>현재 프로필: {{ profilePhoto }}</p>
    </div>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        data() {
            return {
                profilePhoto: '<?= login()->profile_photo_url ?? '' ?>'
            };
        },
        methods: {
            async handleProfileUpload(data) {
                console.log('프로필 사진 업로드:', data.url);
                this.profilePhoto = data.url;

                try {
                    await func('update_my_profile', {
                        photo_url: data.url
                    });
                    alert('프로필 사진이 업데이트되었습니다.');
                } catch (error) {
                    console.error('프로필 업데이트 실패:', error);
                }
            },
            handleProfileDelete(data) {
                console.log('프로필 사진 삭제됨');
                this.profilePhoto = '';
            }
        }
    }).mount('#profile-app');
});
</script>
```

### 게시글 파일 첨부

```php
<div id="post-create-app">
    <form @submit.prevent="submitPost">
        <div class="mb-3">
            <label class="form-label">제목</label>
            <input type="text" v-model="title" class="form-control" required>
        </div>

        <div class="mb-3">
            <label class="form-label">내용</label>
            <textarea v-model="content" class="form-control" rows="5" required></textarea>
        </div>

        <div class="mb-3">
            <label class="form-label">파일 첨부</label>

            <file-upload
                ref="fileUpload"
                :single="false"
                input-name="attachments[]"
                :show-upload-button="false"
                :show-delete-icon="true"
                accept="image/*,video/*,.pdf,.doc,.docx"
                v-model="attachments">
            </file-upload>

            <button type="button" class="btn btn-outline-primary" @click="selectFiles">
                <i class="bi bi-paperclip"></i> 파일 첨부
            </button>

            <span v-if="attachments.length > 0" class="ms-2 text-muted">
                {{ attachments.length }}개 파일 첨부됨
            </span>
        </div>

        <button type="submit" class="btn btn-primary" :disabled="submitting">
            <span v-if="submitting">
                <span class="spinner-border spinner-border-sm me-2"></span>
                전송 중...
            </span>
            <span v-else>게시글 작성</span>
        </button>
    </form>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        data() {
            return {
                title: '',
                content: '',
                attachments: [],
                submitting: false
            };
        },
        methods: {
            selectFiles() {
                this.$refs.fileUpload.openFileSelector();
            },

            async submitPost() {
                this.submitting = true;
                try {
                    const result = await func('create_post_func', {
                        title: this.title,
                        content: this.content,
                        attachments: this.attachments
                    });
                    alert('게시글이 작성되었습니다.');
                    window.location.href = '<?= href()->post->view ?>?idx=' + result.idx;
                } catch (error) {
                    console.error('게시글 작성 실패:', error);
                    alert('게시글 작성에 실패했습니다.');
                } finally {
                    this.submitting = false;
                }
            }
        }
    }).mount('#post-create-app');
});
</script>
```

---

## 고급 사용법

### ref를 통한 메서드 호출

```html
<div id="advanced-app">
    <file-upload
        ref="uploader"
        :single="false"
        input-name="files[]"
        :show-upload-button="false">
    </file-upload>

    <button @click="openFileDialog" class="btn btn-primary">
        <i class="bi bi-folder-open"></i> 파일 선택
    </button>

    <button @click="addDefaultFile" class="btn btn-secondary">
        기본 이미지 추가
    </button>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        methods: {
            openFileDialog() {
                this.$refs.uploader.openFileSelector();
            },
            addDefaultFile() {
                this.$refs.uploader.uploadedFiles.push('/images/default.jpg');
            }
        }
    }).mount('#advanced-app');
});
</script>
```

### 동적 Props

```html
<div id="dynamic-app">
    <select v-model="fileType" class="form-select mb-3">
        <option value="image/*">이미지만</option>
        <option value="video/*">비디오만</option>
        <option value=".pdf">PDF만</option>
        <option value="*">모든 파일</option>
    </select>

    <div class="form-check mb-3">
        <input type="checkbox" v-model="singleMode" class="form-check-input">
        <label class="form-check-label">단일 파일 모드</label>
    </div>

    <file-upload
        :single="singleMode"
        :accept="fileType"
        :show-delete-icon="true"
        input-name="dynamic_files">
    </file-upload>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        data() {
            return {
                fileType: 'image/*',
                singleMode: false
            };
        }
    }).mount('#dynamic-app');
});
</script>
```

---

## CSS 커스터마이징

### 원형 프로필 사진

```css
.profile-upload img {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    object-fit: cover;
    border: 3px solid var(--bs-border-color);
}

.profile-upload {
    display: inline-block;
    position: relative;
}

.profile-upload .btn-danger {
    border-radius: 50%;
    width: 30px;
    height: 30px;
    padding: 0;
    display: flex;
    align-items: center;
    justify-content: center;
}
```

### 배너 이미지 (16:9 비율)

```css
.banner-upload-container img {
    width: 100%;
    height: auto;
    aspect-ratio: 16/9;
    object-fit: cover;
}
```

### 업로드 버튼 스타일링

```css
.file-upload-wrapper .btn-outline-secondary {
    border-style: dashed;
    border-width: 2px;
    padding: 1rem 2rem;
    color: var(--bs-secondary);
    transition: all 0.3s;
}

.file-upload-wrapper .btn-outline-secondary:hover {
    background-color: var(--bs-primary);
    border-color: var(--bs-primary);
    color: white;
}
```

---

## 폼과 함께 사용하기

### Hidden Input 활용

```html
<form id="traditional-form" method="POST" action="/submit">
    <input type="text" name="title" placeholder="제목">

    <div id="form-upload">
        <file-upload
            :single="false"
            input-name="uploaded_files[]"
            :show-delete-icon="true"
            v-model="uploadedFiles">
        </file-upload>
    </div>

    <button type="submit">전송</button>
</form>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        },
        data() {
            return {
                uploadedFiles: []
            };
        }
    }).mount('#form-upload');
});
</script>
```

### PHP에서 받기

```php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = $_POST['title'] ?? '';
    $files = $_POST['uploaded_files'] ?? [];

    // 쉼표로 구분된 URL을 배열로 변환
    if (is_string($files)) {
        $files = explode(',', $files);
    }

    foreach ($files as $fileUrl) {
        echo "업로드된 파일: " . htmlspecialchars($fileUrl) . "<br>";
    }
}
```

---

## 내부 동작 원리

### 1. 파일 업로드 프로세스

파일 업로드는 `uploadFile()` 메서드에서 처리된다.

**동작 과정**:
1. `FormData` 객체 생성 및 파일 추가
2. Single 모드인 경우 기존 파일 삭제 요청 추가
3. QR 코드 디코딩 옵션 추가
4. Axios로 서버에 POST 요청
5. `onUploadProgress`로 진행률 실시간 업데이트
6. 응답 받은 URL을 `uploadedFiles` 배열에 추가
7. `uploaded` 이벤트 발생

### 2. 파일 삭제 프로세스

**동작 과정**:
1. 사용자에게 삭제 확인 메시지 표시
2. 서버의 삭제 API 호출 (GET 방식, URL 파라미터 전달)
3. `uploadedFiles` 배열에서 해당 URL 제거
4. `deleted` 이벤트 발생
5. v-model 업데이트 이벤트 발생

### 3. Hidden Input 값 관리

**특징**:
- `uploadedFiles` 배열을 쉼표로 구분된 문자열로 변환
- `inputName` prop이 없으면 자동으로 고유한 name 생성
- 서버에서 `$_POST[$inputName]` 또는 `$_GET[$inputName]`으로 받을 수 있음

---

## 다국어 번역 지원

컴포넌트는 4개 국어 번역을 지원한다.

**지원 언어**:
- 한국어 (ko)
- 영어 (en)
- 일본어 (ja)
- 중국어 (zh)

---

## 파일 타입 감지 및 아이콘

### 이미지 파일 감지

`isImageFile()` 메서드로 이미지 파일 여부를 확인.

지원 확장자: `jpg`, `jpeg`, `png`, `gif`, `webp`, `bmp`, `svg`

### 비디오 파일 감지

`isVideoFile()` 메서드로 비디오 파일 여부를 확인.

지원 확장자: `mp4`, `webm`, `ogg`, `mov`, `avi`, `wmv`, `flv`, `mkv`

### 파일 아이콘

`getFileIcon()` 메서드로 파일 타입별 Bootstrap Icons 클래스를 반환.

**아이콘 매핑**:
- **PDF**: `bi bi-file-pdf text-danger`
- **Word**: `bi bi-file-word text-primary`
- **Excel**: `bi bi-file-excel text-success`
- **PowerPoint**: `bi bi-file-ppt text-warning`
- **텍스트**: `bi bi-file-text`
- **ZIP**: `bi bi-file-zip text-info`
- **오디오**: `bi bi-file-music text-purple`
- **기본**: `bi bi-file-earmark`

---

## API 연동

### 업로드 API

- **URL**: `appConfig.api.file_upload`
- **Method**: `POST`
- **FormData**:
  - `userfile`: 업로드할 파일 객체
  - `deleteFile`: (Optional) 삭제할 파일 URL (Single 모드)
  - `decodeQrCode`: (Optional) `'Y'` (QR 코드 디코딩 활성화 시)
- **응답**:
  ```json
  {
    "url": "https://example.com/uploads/file.jpg",
    "qr_code": "decoded QR code content"
  }
  ```

### 삭제 API

- **URL**: `appConfig.api.file_delete`
- **Method**: `GET`
- **Params**:
  - `url`: 삭제할 파일의 URL
- **응답**:
  ```json
  {
    "success": true,
    "message": "File deleted successfully"
  }
  ```

---

## 접근성 및 브라우저 지원

### ARIA 속성

컴포넌트는 기본적으로 ARIA 속성을 포함:
- `role="progressbar"` - 진행률 표시
- `aria-label` - 스크린 리더를 위한 레이블
- `aria-valuenow`, `aria-valuemin`, `aria-valuemax` - 진행률 값

### 키보드 네비게이션

- `Tab` - 업로드 버튼으로 이동
- `Enter` / `Space` - 파일 선택 대화상자 열기
- `Delete` - 선택된 파일 삭제 (포커스가 있을 때)

### 브라우저 지원

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

---

## 주요 특징

### ✅ 장점

1. **재사용 가능**: 전역 컴포넌트로 어디서든 사용 가능
2. **Options API**: Vue.js Options API로 작성되어 읽기 쉬움
3. **자동 정리**: MPA 방식으로 페이지 이동 시 자동 정리
4. **다국어 지원**: 4개 국어 자동 번역
5. **Bootstrap 통합**: Bootstrap UI와 자연스럽게 통합
6. **실시간 진행률**: Axios Progress Bar로 업로드 상태 표시
7. **파일 타입 자동 감지**: 이미지, 비디오, 문서 등 자동 구분
8. **v-model 지원**: 양방향 데이터 바인딩 가능

### ⚠️ 주의사항

1. **defaultFiles prop**: 쉼표로 구분된 **문자열** 형식으로 전달

2. **v-model**: 내부적으로 **배열**로 관리됨

3. **인스턴스 ID**: 여러 컴포넌트 동시 사용 시 자동으로 고유 ID 부여

4. **Single 모드에서 이미지 클릭 업로드**: Single 모드에서 이미지가 있으면 이미지를 클릭하여 새 파일 선택 가능

5. **서버 API 의존성**: `appConfig.api.file_upload`와 `appConfig.api.file_delete` API가 정상 작동해야 함

6. **UTF-8 인코딩**: 모든 파일은 UTF-8 인코딩으로 저장

---

## DisplayFileComponent

`DisplayFileComponent`는 업로드된 파일(이미지/비디오/기타)을 표시하는 재사용 가능한 Vue.js 컴포넌트이다.

### 컴포넌트 위치

- **파일 경로**: `js/vue-components/file-upload.component.js`
- **전역 객체**: `window.DisplayFileComponent`

### Props 목록

| Props | 타입 | 필수 | 기본값 | 설명 |
|-------|------|------|--------|------|
| `url` | String | ✅ | - | 파일 URL (필수) |
| `hideInjectButton` | Boolean | ❌ | `false` | 삽입 버튼 숨김 여부 |
| `showDeleteButton` | Boolean | ❌ | `true` | 삭제 버튼 표시 여부 |
| `class` | Array/String | ❌ | `[]` | 동적 클래스 바인딩 |

### Events 목록

| Event | Payload | 설명 |
|-------|---------|------|
| `@deleted` | `url: string` | 삭제 버튼 클릭 후 **실제로 파일을 삭제한 후** 발생 |
| `@inject` | `url: string` | 삽입 버튼 클릭 시 발생 |

### 사용 예제

```html
<div id="app">
    <display-file
        :url="file"
        @deleted="handleDeleted"
        @inject="handleInject">
    </display-file>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'display-file': window.DisplayFileComponent
        },
        data() {
            return {
                file: 'https://example.com/uploads/photo.jpg'
            };
        },
        methods: {
            handleDeleted(url) {
                // DisplayFileComponent가 이미 서버에서 파일을 삭제했으므로
                // UI 업데이트만 하면 됨
                this.file = '';
            },
            handleInject(url) {
                console.log('파일 삽입:', url);
            }
        }
    }).mount('#app');
});
</script>
```

### ⚠️ 중요: @deleted 이벤트

**DisplayFileComponent의 `@deleted` 이벤트는 실제로 파일을 삭제한 후 발생한다.**

```javascript
// ✅ 올바른 사용
handleFileDeleted(index) {
    // DisplayFileComponent가 이미 삭제했으므로 UI만 업데이트
    this.uploadedFiles.splice(index, 1);
}

// ❌ 잘못된 사용 (중복 삭제)
async handleFileDeleted(url) {
    await func('file_delete', { url }); // 이미 삭제됨!
    this.uploadedFiles = this.uploadedFiles.filter(f => f !== url);
}
```

---

## 문제 해결

### 파일이 업로드되지 않을 때

1. **네트워크 확인**: 브라우저 개발자 도구에서 네트워크 오류 확인
2. **파일 크기 제한**: PHP `upload_max_filesize` 및 `post_max_size` 설정 확인
3. **파일 타입**: `accept` 속성과 실제 파일 타입이 일치하는지 확인

### 이미지가 표시되지 않을 때

```javascript
methods: {
    handleUpload(data) {
        console.log('업로드된 URL:', data.url);

        if (!data.url.startsWith('http') && !data.url.startsWith('/')) {
            console.warn('상대 경로 URL:', data.url);
        }
    }
}
```

### v-model이 동작하지 않을 때

```javascript
watch: {
    uploadedFiles: {
        handler(newVal) {
            console.log('v-model 변경:', newVal);
        },
        deep: true,
        immediate: true
    }
}
```

### 서버 측 파일 타입 검증

```php
function validateFile($file) {
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mimeType, $allowedTypes)) {
        throw new Exception('허용되지 않은 파일 타입입니다.');
    }

    return true;
}
```

---

## 마이그레이션 가이드

### 기존 file-upload.js에서 마이그레이션

#### 기존 코드

```html
<input type="file"
       onchange="handle_file_change(event, {id: 'display-area'})"
       accept="image/*">
<div id="display-area"
     data-single="true"
     data-input-name="photo"></div>
```

#### 새 코드

```html
<div id="app">
    <file-upload
        :single="true"
        input-name="photo"
        accept="image/*">
    </file-upload>
</div>

<script>
ready(() => {
    Vue.createApp({
        components: {
            'file-upload': window.FileUploadComponent
        }
    }).mount('#app');
});
</script>
```

### data 속성 매핑

| 기존 (data-*) | 새로운 (Props) |
|---------------|----------------|
| `data-single="true"` | `:single="true"` |
| `data-input-name="files"` | `input-name="files"` |
| `data-delete-icon="show"` | `:show-delete-icon="true"` |
| `data-decode-qr-code="true"` | `:decode-qr-code="true"` |
| `data-default-files="url1,url2"` | `:default-files="'url1,url2'"` |

---

## 요약

`FileUploadComponent`는 Vue.js 기반의 강력하고 유연한 파일 업로드 솔루션이다.

### 핵심 기능

- ✅ Vue.js 3.x Options API
- ✅ 단일/다중 파일 업로드
- ✅ 실시간 진행률 표시
- ✅ 파일 미리보기
- ✅ v-model 양방향 바인딩
- ✅ 이벤트 기반 통신
- ✅ Bootstrap 5 스타일링

### 시작하기

1. 컴포넌트 로드: `load_deferred_js('vue-components/file-upload.component')`
2. Vue 앱에 등록: `components: { 'file-upload': window.FileUploadComponent }`
3. 템플릿에서 사용: `<file-upload :single="true" @uploaded="handleUpload"></file-upload>`
