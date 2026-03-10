# 카카오톡 소셜 로그인 (Flutter 앱)

Flutter 앱(iOS, Android)에서 카카오톡 소셜 로그인을 구현하는 가이드입니다.
카카오 공식 문서([Getting Started](https://developers.kakao.com/docs/latest/en/flutter/getting-started), [Kakao Login](https://developers.kakao.com/docs/latest/en/kakaologin/flutter)) 기반으로 작성되었습니다.

---

## 목차

1. [핵심 원리: 카카오 Flutter SDK → Firebase Custom Token 방식](#1-핵심-원리-카카오-flutter-sdk--firebase-custom-token-방식)
2. [카카오톡 앱 (프로젝트) 정보](#2-카카오톡-앱-프로젝트-정보)
3. [Flutter 패키지 설치](#3-flutter-패키지-설치)
4. [Android 플랫폼 설정](#4-android-플랫폼-설정)
5. [iOS 플랫폼 설정](#5-ios-플랫폼-설정)
6. [SDK 초기화](#6-sdk-초기화)
7. [전체 동작 흐름 (Flutter 앱)](#7-전체-동작-흐름-flutter-앱)
8. [센터 프로젝트 파일 구조](#8-센터-프로젝트-파일-구조)
9. [카카오 로그인 구현 (UserService)](#9-카카오-로그인-구현-userservice)
10. [Firebase Custom Token 서버 연동 (PHP)](#10-firebase-custom-token-서버-연동-php)
11. [로그인 UI 구현](#11-로그인-ui-구현)
12. [에러 처리](#12-에러-처리)
13. [로그아웃 / 연결끊기 (탈퇴)](#13-로그아웃--연결끊기-탈퇴)
14. [카카오 SDK 주요 API 레퍼런스](#14-카카오-sdk-주요-api-레퍼런스)
15. [실전 트러블슈팅](#15-실전-트러블슈팅)
16. [관련 파일 목록](#16-관련-파일-목록)

---

## 1. 핵심 원리: 카카오 Flutter SDK → Firebase Custom Token 방식

### 1.1 최종 목표

**카카오 Flutter SDK로 로그인** → **서버에서 Firebase Custom Token 발급** → **Firebase Auth에 로그인** → **PostgreSQL 동기화**

- 카카오 Flutter SDK가 네이티브(Android/iOS)에서 직접 카카오톡 로그인 처리
- 카카오 access_token을 PHP 서버에 전송하여 Firebase Custom Token 발급
- Firebase signInWithCustomToken()으로 Firebase Auth 로그인
- apiUserMy()로 PostgreSQL 사용자 동기화 (Google 로그인과 동일 패턴)

### 1.2 왜 Firebase Custom Token이 필요한가?

**Firebase Auth는 카카오를 직접 지원하지 않습니다.** Firebase가 직접 지원하는 소셜 로그인 프로바이더는 Google, Apple, Facebook, Twitter 등입니다. 카카오는 이 목록에 없으므로, 다음 두 가지 이유로 서버를 통한 Custom Token 방식이 필수입니다:

1. **Firebase에 카카오 credential을 직접 전달할 수 없음**: `signInWithCredential()`은 Firebase가 지원하는 프로바이더만 사용 가능
2. **보안**: 클라이언트에서 사용자 ID를 직접 만들어 Firebase에 로그인하면 누구나 위조 가능 → 서버에서 카카오 API로 access_token을 검증한 후 Custom Token을 발급해야 안전

### 1.3 Google 로그인과의 차이

| 구분 | Google 로그인 | 카카오톡 로그인 (Flutter) |
|------|-------------|------------------------|
| **Firebase 지원** | 직접 지원 (`signInWithCredential`) | 직접 지원 안 함 → Custom Token 필요 |
| **인증 흐름** | GoogleSignIn SDK → Firebase credential | 카카오 SDK → 서버 → Custom Token → Firebase |
| **서버 역할** | 없음 (클라이언트 직접 처리) | **필수** (access_token 검증 + Custom Token 발급) |
| **토큰 처리** | Firebase SDK 자동 | 카카오 SDK + PHP 서버 협력 |
| **패키지** | `google_sign_in` | `kakao_flutter_sdk_user` |

### 1.4 웹 버전과의 차이

| 구분 | 웹 (PHP redirect) | Flutter 앱 (SDK) |
|------|-------------------|------------------|
| **인증 방식** | OAuth redirect (start→callback→complete) | 카카오 Flutter SDK 직접 호출 |
| **토큰 교환** | PHP 서버에서 code→token 교환 | Flutter SDK가 직접 token 획득 |
| **사용자 ID 확보** | PHP에서 카카오 API 호출 | PHP에서 access_token 검증 후 확보 |
| **앱 키** | REST API 키 | **네이티브 앱 키** |
| **플랫폼 설정** | 없음 | AndroidManifest.xml, Info.plist 설정 필요 |

> **참고:** 웹 버전 가이드는 [web-kakoatalk-social-login.md](../web/web-kakoatalk-social-login.md)를 참조하세요.

### 1.5 다중 가맹사 로그인 동작

**동일한 카카오톡 계정으로 여러 가맹사 앱에서 로그인해도 동일한 사용자로 로그인됩니다.**

| 항목 | 동작 |
|------|------|
| **Firebase UID** | 카카오 사용자 ID 기반 (`kakao:454835416`) → **모든 가맹사에서 동일** |
| **가맹사 구분** | `apiUserMy()`에서 `branch_id` 파라미터로 처리 |
| **PostgreSQL 사용자** | `branch_id`가 다르더라도 Firebase UID 기준으로 동일 사용자 |

### 1.6 보안 원칙

- **카카오 access_token은 서버에서만 검증** (클라이언트에서 사용자 ID를 직접 전달하지 않음)
- **서버에서 카카오 API(`/v2/user/me`)를 호출하여 사용자 ID를 직접 확인**
- **Firebase Custom Token은 1시간 유효, 1회용**
- **네이티브 앱 키는 config.dart에 저장** (AndroidManifest.xml/Info.plist에는 URL Scheme으로만 사용)

---

## 2. 카카오톡 앱 (프로젝트) 정보

| 항목 | 값 |
|------|------|
| 카카오 디벨로퍼스 콘솔 | `https://developers.kakao.com/console/app/136610` |
| 앱 이름 | `SONUB` |
| 특징 | 비즈앱 |
| **네이티브 앱 키** | Flutter 앱에서 사용 → `branch_meta` 테이블의 `kakao_native_key` |
| REST API 키 | PHP 서버에서 사용 (웹 버전과 동일) |

> **Flutter 앱에서는 네이티브 앱 키(Native App Key)를 사용합니다.** REST API 키는 서버 측에서만 사용합니다.

---

## 3. Flutter 패키지 설치

### 3.1 설치 위치: 센터 프로젝트 라이브러리 (center_apps)

**`kakao_flutter_sdk_user` 패키지는 센터 프로젝트 라이브러리(`center_apps`)에 설치합니다.**
이렇게 하면 모든 가맹사 앱(`apps/singapore`, `apps/usa` 등)에서 공용으로 사용할 수 있습니다.

```bash
# center_apps 루트에서 실행
cd /Users/thruthesky/apps/flutter/center_apps
flutter pub add kakao_flutter_sdk_user
```

**파일:** `center_apps/pubspec.yaml`

```yaml
dependencies:
  # 카카오 Flutter SDK (로그인 + 사용자 API)
  kakao_flutter_sdk_user: ^1.9.5
```

### 3.2 패키지 선택 가이드

카카오 Flutter SDK는 기능별로 세분화된 패키지를 제공합니다:

| 패키지 | 기능 | 센터 프로젝트 사용 |
|--------|------|-------------------|
| `kakao_flutter_sdk_user` | 로그인 + 사용자 정보 | **사용 (권장)** |
| `kakao_flutter_sdk_share` | 카카오톡 공유 | 미사용 |
| `kakao_flutter_sdk_talk` | 카카오톡 채널/메시지 | 미사용 |
| `kakao_flutter_sdk_friend` | 친구 선택기 | 미사용 |
| `kakao_flutter_sdk_navi` | 카카오 네비 | 미사용 |
| `kakao_flutter_sdk` | **모든 기능 포함** | 비권장 (불필요한 의존성) |

> **⚠️ 각 가맹사 앱(`apps/`)에는 별도 설치 불필요** — center_apps 라이브러리 의존성을 통해 자동 포함

### 3.3 최소 요구사항

| 항목 | 최소 버전 |
|------|----------|
| Flutter | 3.22.0+ |
| Dart | 3.4.0+ |
| Android API | 21+ (Android 5.0) |
| iOS | 13.0+ |
| Xcode | 11.0+ |

---

## 4. Android 플랫폼 설정

### 4.1 AndroidManifest.xml — `<application>` 내부 설정

**파일:** `apps/{앱이름}/android/app/src/main/AndroidManifest.xml`

`<application>` 태그 안에 카카오 로그인용 **AuthCodeCustomTabsActivity**를 추가합니다:

```xml
<application
    ...>

    <!-- 기존 MainActivity (수정 불필요) -->
    <activity
        android:name=".MainActivity"
        android:exported="true"
        android:launchMode="singleTop"
        ...>
        <!-- 기존 intent-filter 유지 -->
    </activity>

    <!-- ★ 카카오 로그인 Custom URI Scheme (추가) ★ -->
    <activity
        android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
        android:exported="true">
        <intent-filter android:label="flutter_web_auth">
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <!-- kakao{NATIVE_APP_KEY} 형식 -->
            <!-- 예: 네이티브 앱 키가 "74e192bb5d6b531e64ae1ac8a9135838"이면 -->
            <data android:scheme="kakao74e192bb5d6b531e64ae1ac8a9135838"
                  android:host="oauth" />
        </intent-filter>
    </activity>

</application>
```

> **⚠️ 중요:**
> - `scheme`에 반드시 `kakao` 접두사 + 네이티브 앱 키 형태여야 합니다
> - `host`는 반드시 `"oauth"`
> - Android 12 이상 타겟팅 시 `android:exported="true"` 필수
> - 이 Activity가 없으면 카카오 계정(웹) 로그인 후 앱으로 돌아오지 않습니다

### 4.2 AndroidManifest.xml — `<queries>` 태그 (패키지 가시성 정책)

**Android 11(API 30) 이상**에서는 **패키지 가시성 정책**으로 인해 다른 앱의 설치 여부를 확인하려면 `<queries>` 태그에 해당 패키지를 명시해야 합니다.

**`isKakaoTalkInstalled()`가 정상 동작하려면 반드시 아래 설정이 필요합니다:**

```xml
<manifest ...>
    <!-- ... -->

    <queries>
        <!-- ★ 카카오톡 앱 설치 여부 확인용 (Android 11+ 패키지 가시성 정책) ★ -->
        <package android:name="com.kakao.talk" />

        <!-- 기존 다른 queries 항목들 유지 -->
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
        <!-- ... -->
    </queries>
</manifest>
```

> **⚠️ 이 설정이 없으면:**
> - `isKakaoTalkInstalled()`가 항상 `false`를 반환합니다
> - 카카오톡이 설치되어 있어도 앱 로그인 대신 웹(아이디/비밀번호) 로그인 화면이 표시됩니다
> - 이것은 Android 11+ 보안 정책에 의한 것이며, `<queries>`에 패키지를 선언해야만 해당 앱의 존재 확인 가능

### 4.3 실제 Singapore 앱 AndroidManifest.xml 전체 예시

**파일:** `apps/singapore/android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <!-- 기타 퍼미션들 -->

    <application
        android:label="싱가"
        android:name="${applicationName}"
        android:icon="@mipmap/launcher_icon">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            ...>
            <!-- 기존 intent-filter 유지 -->
        </activity>

        <!-- ★ 카카오 로그인 Custom URI Scheme ★ -->
        <activity
            android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
            android:exported="true">
            <intent-filter android:label="flutter_web_auth">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="kakao74e192bb5d6b531e64ae1ac8a9135838"
                      android:host="oauth" />
            </intent-filter>
        </activity>

    </application>

    <queries>
        <!-- ★ 카카오톡 앱 설치 여부 확인 (Android 11+ 필수) ★ -->
        <package android:name="com.kakao.talk" />

        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
        <!-- 기타 queries 항목들 -->
    </queries>
</manifest>
```

### 4.4 build.gradle 설정

**파일:** `android/app/build.gradle`

```groovy
android {
    defaultConfig {
        minSdkVersion 21  // 최소 API 21 필요
    }
}
```

### 4.5 키 해시 등록 (⚠️ 디버그 + 릴리스 모두 필수)

카카오 디벨로퍼스 콘솔에 Android 키 해시를 등록해야 합니다.
**디버그 키 해시**와 **릴리스(프로덕션) 키 해시** 두 가지 **모두** 등록해야 합니다.

> **⚠️⚠️⚠️ 핵심 주의사항 ⚠️⚠️⚠️**
>
> **디버그 키 해시를 등록하지 않으면 디버그 빌드에서 카카오톡 앱 로그인이 실패합니다!**
>
> - `loginWithKakaoTalk()` 호출 시 `{error: invalid_request, error_description: Android keyHash validation failed.}` 에러 발생
> - 카카오톡 앱이 감지되고(`isKakaoTalkInstalled()` = `true`) 앱이 열리지만, 키 해시 검증에 실패하여 자동으로 `loginWithKakaoAccount()`(웹 로그인)로 폴백됨
> - **증상**: 카카오톡이 설치되어 있는데도 아이디/비밀번호 입력 화면이 표시됨
> - **해결**: 카카오 디벨로퍼스 콘솔에 디버그 키 해시를 등록하면 즉시 해결

#### 4.5.1 디버그 키 해시 확인

**방법 1: Flutter 코드에서 확인 (권장)**

```dart
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

// 앱 실행 중 키 해시 확인 (디버그용)
var keyHash = await KakaoSdk.origin;
print('키 해시: $keyHash');
```

**방법 2: 터미널에서 확인**

```bash
# macOS/Linux
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64

# Windows
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
```

#### 4.5.2 릴리스(프로덕션) 키 해시 확인 — Google Play Store App Signing Key

Google Play Console에서 앱을 배포하면 Google이 **App Signing Key**로 APK를 재서명합니다.
따라서 **Play Console의 App Signing Key SHA-1 값**을 카카오 키 해시로 변환하여 등록해야 합니다.

**Step 1: Google Play Console에서 SHA-1 확인**

1. [Google Play Console](https://play.google.com/console) 접속
2. 해당 앱 선택
3. **[설정] → [앱 서명]** (또는 [Setup] → [App signing])
4. **"앱 서명 키 인증서"** 섹션에서 **SHA-1** 값 복사

**Step 2: SHA-1을 카카오 키 해시로 변환**

```bash
# SHA-1 값에서 콜론(:)을 제거한 후 변환
echo "A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6E7F8A9B0" | xxd -r -p | openssl base64
```

#### 4.5.3 카카오 콘솔에서 키 해시 등록

1. [카카오 디벨로퍼스](https://developers.kakao.com) → [내 애플리케이션] → 해당 앱 선택
2. [앱] → [일반] → [플랫폼 키] → **Android** → 수정
3. **패키지명** 입력 (예: `com.example.singapore`)
4. **키 해시** 항목에 디버그 키 해시 + 릴리스 키 해시 **둘 다 등록**

> **⚠️ 중요:**
> - SHA-1 값의 콜론(`:`)을 **모두 제거**한 후 변환 명령어 실행
> - 디버그 키 해시와 릴리스 키 해시는 **다릅니다** — 둘 다 등록해야 합니다
> - Google Play Console의 "업로드 키"가 아닌 **"앱 서명 키"**의 SHA-1을 사용

---

## 5. iOS 플랫폼 설정

### 5.1 Info.plist — URL Scheme 및 허용 목록

**파일:** `apps/{앱이름}/ios/Runner/Info.plist`

Info.plist에서 `CFBundleURLTypes`와 `LSApplicationQueriesSchemes`는 **배열 형태의 단일 키**입니다.
기존에 Google 로그인 등 다른 URL Scheme이 있는 경우, **동일한 배열 안에 카카오 항목을 추가**해야 합니다.

> **⚠️ 중요: plist 파일에서 같은 키를 두 번 선언하면 마지막 것만 적용됩니다!**
> `CFBundleURLTypes`와 `LSApplicationQueriesSchemes`를 중복 선언하지 마세요.

```xml
<dict>
    <!-- ★ URL Scheme (Google + 카카오를 하나의 배열에) ★ -->
    <key>CFBundleURLTypes</key>
    <array>
        <!-- Google 로그인 URL Scheme -->
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.XXX-YYY</string>
            </array>
        </dict>
        <!-- ★ 카카오 로그인 URL Scheme ★ -->
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <!-- kakao{NATIVE_APP_KEY} 형식 -->
                <string>kakao74e192bb5d6b531e64ae1ac8a9135838</string>
            </array>
        </dict>
    </array>

    <!-- ★ 앱 허용 목록 (기존 + 카카오를 하나의 배열에) ★ -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>sms</string>
        <string>tel</string>
        <!-- ★ 카카오톡 관련 (추가) ★ -->
        <string>kakaokompassauth</string>  <!-- 카카오톡 로그인 (필수) -->
        <string>kakaolink</string>          <!-- 카카오톡 공유 -->
        <string>kakaoplus</string>          <!-- 카카오톡 채널 -->
    </array>

    <!-- 기존 항목들 유지 -->
</dict>
```

> **⚠️ 핵심 주의사항:**
> - `kakaokompassauth`는 **필수** — 이것이 없으면 `isKakaoTalkInstalled()`가 iOS에서 카카오톡을 감지하지 못합니다
> - `CFBundleURLTypes`에 Google과 카카오 URL Scheme을 **같은 배열 안에** 넣어야 합니다
> - `LSApplicationQueriesSchemes`도 **하나의 배열**에 모든 항목을 넣어야 합니다

### 5.2 실제 Singapore 앱 Info.plist 예시 (관련 부분)

**파일:** `apps/singapore/ios/Runner/Info.plist`

```xml
<!-- Google Sign-In Client ID -->
<key>GIDClientID</key>
<string>927049984120-6erp6lebn5gaahi2r7ol5n5aghmehuj9.apps.googleusercontent.com</string>

<!-- URL Scheme (Google + 카카오) -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.927049984120-6erp6lebn5gaahi2r7ol5n5aghmehuj9</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakao74e192bb5d6b531e64ae1ac8a9135838</string>
        </array>
    </dict>
</array>

<!-- 앱 허용 목록 -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>sms</string>
    <string>tel</string>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
    <string>kakaoplus</string>
</array>
```

### 5.3 번들 ID 등록

카카오 디벨로퍼스 콘솔에 iOS 번들 ID를 등록해야 합니다.

**번들 ID 확인:**
- Xcode → TARGET → General → Bundle Identifier
- 또는 `ios/Runner.xcodeproj/project.pbxproj`에서 `PRODUCT_BUNDLE_IDENTIFIER` 확인

**카카오 콘솔에서 등록:**
1. [내 애플리케이션] → 해당 앱 선택
2. [앱] → [일반] → [플랫폼 키] → iOS
3. 번들 ID 등록

### 5.4 Podfile 최소 버전

**파일:** `ios/Podfile`

```ruby
platform :ios, '13.0'  # 최소 iOS 13.0 필요
```

---

## 6. SDK 초기화

### 6.1 네이티브 앱 키를 config.dart에 저장

각 가맹사 앱의 `xxx.config.dart` 파일에 카카오 네이티브 앱 키를 저장합니다.

**파일 예시:** `apps/singapore/lib/singapore.config.dart`

```dart
class SingaporeConfig {
  static const String countryName = 'Singapore';
  static const String countryCode = 'SG';
  static const String currency = 'SGD';
  static const String timeZone = 'Asia/Singapore';

  // Branch configuration
  static const int branchId = 11176;
  static const String defaultDomain = 'mysingapo.sonub.com';

  // ★ 카카오 네이티브 앱 키 ★
  static const String kakaoNativeAppKey = '74e192bb5d6b531e64ae1ac8a9135838';
}
```

> **⚠️ 중요:**
> - 카카오 디벨로퍼스 콘솔에서 **네이티브 앱 키**를 복사 (REST API 키가 아님!)
> - 이 키는 SDK 초기화, AndroidManifest.xml URL Scheme, Info.plist URL Scheme에서 동일하게 사용

### 6.2 KakaotalkService — 센터 라이브러리 공용 서비스

**파일:** `center_apps/lib/user/services/kakaotalk.service.dart`

```dart
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오톡 소셜 로그인 서비스
///
/// 센터 프로젝트 라이브러리(center_apps)에서 공용으로 제공하며,
/// 각 가맹사 앱의 main.dart에서 초기화를 호출합니다.
///
/// 사용 흐름:
/// 1. 앱 시작 시: KakaotalkService.init(nativeAppKey) 호출
/// 2. 로그인 시: UserService.instance.signInWithKakao() 호출
class KakaotalkService {
  static final instance = KakaotalkService._();
  KakaotalkService._();

  /// 카카오 SDK 초기화
  ///
  /// 각 가맹사 앱의 main.dart에서 runApp() 전에 호출해야 합니다.
  /// [nativeAppKey]는 각 앱의 xxx.config.dart에서 가져옵니다.
  static void init(String nativeAppKey) {
    KakaoSdk.init(nativeAppKey: nativeAppKey);
  }
}
```

### 6.3 각 가맹사 앱의 main.dart에서 초기화

**파일 예시:** `apps/singapore/lib/main.dart`

```dart
import 'package:center/center.dart';
import 'package:singapore/singapore.config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // ★ 카카오 SDK 초기화 ★
  KakaotalkService.init(SingaporeConfig.kakaoNativeAppKey);

  runApp(MyApp());
}
```

> **⚠️ 초기화 순서:**
> 1. `WidgetsFlutterBinding.ensureInitialized()` — 바인딩 초기화
> 2. `Firebase.initializeApp()` — Firebase 초기화
> 3. `KakaotalkService.init()` — 카카오 SDK 초기화 (`runApp()` 전에 호출)

---

## 7. 전체 동작 흐름 (Flutter 앱)

### 7.1 흐름 다이어그램

```
┌─────────────────────────────────────────────────────────────────────┐
│              카카오톡 소셜 로그인 전체 흐름 (Flutter 앱)               │
└─────────────────────────────────────────────────────────────────────┘

[1] 로그인 화면에서 "카카오 로그인" 버튼 클릭
        │
        ▼
[2] isKakaoTalkInstalled() → 카카오톡 앱 설치 여부 확인
        │
        ├── 설치됨 → loginWithKakaoTalk()  (카카오톡 앱으로 로그인)
        │       │
        │       ├── 성공 → OAuthToken 반환
        │       └── 실패 → loginWithKakaoAccount()로 폴백
        │
        └── 미설치 → loginWithKakaoAccount()  (카카오 계정 웹페이지 로그인)
                │
                ▼
[3] 카카오 SDK가 OAuthToken 반환 (access_token 포함)
        │
        ▼
[4] PHP 서버에 access_token 전송
        │  api('kakao_firebase_token', data: {'kakao_access_token': accessToken})
        │
        ▼
[5] PHP 서버 처리 ★ 핵심 ★
        │
        ├── (a) 카카오 access_token으로 사용자 정보 조회
        │       GET https://kapi.kakao.com/v2/user/me
        │       → 카카오 고유 사용자 ID 확보
        │
        ├── (b) Firebase Custom Token 발급
        │       firebase_auth_admin()->createCustomToken('kakao:' . $kakaoId)
        │
        └── (c) Custom Token + kakao_user_id + firebase_uid 반환
                │
                ▼
[6] Flutter 앱에서 Firebase 로그인
        │
        ├── FirebaseAuth.instance.signInWithCustomToken(customToken)
        │   → Firebase Auth에 로그인 완료
        │
        └── apiUserMy(additionalData: {'branch_id': branchId})
            → PostgreSQL 사용자 생성/업데이트
            → UserModel 반환
                │
                ▼
[7] 로그인 완료 → 홈 화면으로 이동
```

### 7.2 단계별 요약

| 단계 | 위치 | 동작 | 사용 API |
|------|------|------|---------|
| **Step 1** | Flutter 앱 | 카카오톡 설치 확인 | `isKakaoTalkInstalled()` |
| **Step 2** | Flutter → 카카오 | 카카오 로그인 (앱 또는 웹) | `loginWithKakaoTalk()` / `loginWithKakaoAccount()` |
| **Step 3** | Flutter → PHP 서버 | access_token 전송 | `api('kakao_firebase_token')` |
| **Step 4** | PHP 서버 → 카카오 | access_token 검증 + 사용자 ID 확보 | `kapi.kakao.com/v2/user/me` |
| **Step 5** | PHP 서버 | Firebase Custom Token 발급 | `firebase_auth_admin()->createCustomToken()` |
| **Step 6** | Flutter 앱 | Firebase 로그인 + DB 동기화 | `signInWithCustomToken()` + `apiUserMy()` |

---

## 8. 센터 프로젝트 파일 구조

### 8.1 Flutter 앱 (center_apps)

```
lib/
├── user/
│   ├── services/
│   │   ├── user.service.dart          # signInWithKakao() 메서드 (구현 완료)
│   │   └── kakaotalk.service.dart     # KakaotalkService.init() (구현 완료)
│   ├── widgets/
│   │   └── user_login_form.dart       # 카카오 로그인 버튼 UI (구현 완료)
│   └── screens/
│       └── login.screen.dart          # 로그인 화면
├── functions/
│   └── api.functions.dart             # api() 함수, apiUserMy()
├── l10n/
│   ├── app_en.arb                     # signInWithKakao 번역 (구현 완료)
│   ├── app_ko.arb
│   ├── app_ja.arb
│   └── app_zh.arb
└── center.dart                        # 패키지 export
```

### 8.2 각 가맹사 앱 (apps/)

```
apps/
├── singapore/
│   ├── lib/
│   │   ├── main.dart                  # KakaotalkService.init() 호출 (구현 완료)
│   │   └── singapore.config.dart      # kakaoNativeAppKey 저장 (구현 완료)
│   ├── android/app/src/main/
│   │   └── AndroidManifest.xml        # AuthCodeCustomTabsActivity + queries (구현 완료)
│   └── ios/Runner/
│       └── Info.plist                 # URL Scheme + LSApplicationQueriesSchemes (구현 완료)
└── ...
```

### 8.3 PHP 서버 (센터 프로젝트)

```
/Users/thruthesky/apps/center/
├── lib/
│   └── api/
│       └── api.allowed_functions.php  # kakao_firebase_token() 함수 (구현 완료)
├── lib/firebase/
│   └── firebase.functions.php         # firebase_auth_admin() → Custom Token 발급
└── etc/config/
    └── withcenter-firebase-adminsdk.json  # Firebase 서비스 계정 키
```

---

## 9. 카카오 로그인 구현 (UserService)

### 9.1 signInWithKakao() 메서드 — 실제 구현 코드

**파일:** `lib/user/services/user.service.dart`

```dart
import 'package:center/center.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

/// 카카오 로그인
///
/// 1. 카카오톡 설치 여부 확인 → 카카오톡 앱 또는 카카오 계정으로 로그인
/// 2. 서버에 카카오 access_token 전송 → Firebase Custom Token 발급 요청
/// 3. Firebase signInWithCustomToken()으로 로그인
/// 4. apiUserMy()로 PostgreSQL 동기화
///
/// 카카오톡 로그인은 Firebase가 직접 지원하지 않으므로
/// 서버(PHP)를 거쳐 Firebase Custom Token을 발급받아야 합니다.
Future<UserModel> signInWithKakao() async {
  debugPrint('[카카오 로그인] ========== 카카오 로그인 시작 ==========');
  kakao.OAuthToken kakaoToken;

  // ────────────────────────────────────────
  // Step 1: 카카오톡 설치 여부에 따라 앱/웹 로그인
  // ────────────────────────────────────────
  final isInstalled = await kakao.isKakaoTalkInstalled();
  debugPrint('[카카오 로그인] Step 1: 카카오톡 앱 설치 여부: $isInstalled');

  if (isInstalled) {
    try {
      debugPrint('[카카오 로그인] Step 1: 카카오톡 앱으로 로그인 시도...');
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
      debugPrint('[카카오 로그인] Step 1: 카카오톡 앱 로그인 성공');
    } catch (e) {
      debugPrint('[카카오 로그인] Step 1: 카카오톡 앱 로그인 실패: $e');
      debugPrint('[카카오 로그인] Step 1: 카카오 계정(웹) 로그인으로 폴백...');
      try {
        kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
        debugPrint('[카카오 로그인] Step 1: 카카오 계정(웹) 로그인 성공');
      } catch (e2) {
        debugPrint('[카카오 로그인] Step 1: 카카오 계정(웹) 로그인도 실패: $e2');
        rethrow;
      }
    }
  } else {
    debugPrint('[카카오 로그인] Step 1: 카카오톡 미설치 → 카카오 계정(웹) 로그인 시도...');
    try {
      kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
      debugPrint('[카카오 로그인] Step 1: 카카오 계정(웹) 로그인 성공');
    } catch (e) {
      debugPrint('[카카오 로그인] Step 1: 카카오 계정(웹) 로그인 실패: $e');
      rethrow;
    }
  }

  // ────────────────────────────────────────
  // Step 2: 서버에서 Firebase Custom Token 발급
  // ────────────────────────────────────────
  // ⚠️ 파라미터 이름: 'kakao_access_token' (서버가 이 이름을 기대)
  debugPrint('[카카오 로그인] Step 2: 서버에 kakao_firebase_token API 호출...');

  final Map<String, dynamic> tokenResponse;
  try {
    tokenResponse = await api(
      'kakao_firebase_token',
      data: {'kakao_access_token': kakaoToken.accessToken},
    );
    debugPrint('[카카오 로그인] Step 2: 서버 응답 수신: $tokenResponse');
  } catch (e) {
    debugPrint('[카카오 로그인] Step 2: 서버 API 호출 실패: $e');
    rethrow;
  }

  final customToken = tokenResponse['custom_token'] as String?;
  if (customToken == null || customToken.isEmpty) {
    throw CenterException(
      'kakao-custom-token-failed',
      'Firebase Custom Token 발급에 실패했습니다.',
    );
  }

  // ────────────────────────────────────────
  // Step 3: Firebase Custom Token으로 로그인
  // ────────────────────────────────────────
  debugPrint('[카카오 로그인] Step 3: Firebase signInWithCustomToken 호출...');
  try {
    final userCredential =
        await FirebaseAuth.instance.signInWithCustomToken(customToken);
    debugPrint('[카카오 로그인] Step 3: Firebase 로그인 성공!');
    debugPrint('[카카오 로그인] Step 3: Firebase UID=${userCredential.user?.uid}');
  } catch (e) {
    debugPrint('[카카오 로그인] Step 3: Firebase signInWithCustomToken 실패: $e');
    rethrow;
  }

  // ────────────────────────────────────────
  // Step 4: PostgreSQL 동기화 - branch_id 포함
  // ────────────────────────────────────────
  debugPrint('[카카오 로그인] Step 4: apiUserMy() 호출...');
  try {
    final userModel = await apiUserMy(
      additionalData: {'branch_id': CenterService.instance.branchId},
    );
    debugPrint('[카카오 로그인] Step 4: PostgreSQL 동기화 성공!');
    debugPrint('[카카오 로그인] ========== 카카오 로그인 완료 ==========');
    return userModel;
  } catch (e) {
    debugPrint('[카카오 로그인] Step 4: apiUserMy() 실패: $e');
    rethrow;
  }
}
```

### 9.2 핵심 구현 포인트

1. **`as kakao` alias 사용**: `kakao_flutter_sdk_user` 패키지를 `as kakao`로 import하여 다른 패키지와의 클래스 이름 충돌 방지
2. **파라미터 이름 `kakao_access_token`**: PHP 서버의 `$input['kakao_access_token']`과 정확히 일치해야 합니다 (⚠️ `kakao_token`이 아님!)
3. **폴백 패턴**: 카카오톡 앱 로그인 실패 시 → 카카오 계정(웹) 로그인으로 자동 폴백
4. **`debugPrint`**: 프로덕션에서도 안전한 디버그 로깅 (`print` 대신 사용)

### 9.3 Google 로그인과의 코드 비교

```
┌──────────────────────────────────────────────────────────────┐
│  Google 로그인 (signInWithGoogle)                             │
│  ──────────────────────────────────────────                   │
│  1. GoogleSignIn().signIn()     → GoogleSignInAccount        │
│  2. googleUser.authentication   → GoogleSignInAuthentication │
│  3. GoogleAuthProvider.credential(idToken, accessToken)      │
│  4. FirebaseAuth.signInWithCredential(credential)   ← 직접! │
│  5. apiUserMy()                 → PostgreSQL 동기화          │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│  카카오 로그인 (signInWithKakao)                              │
│  ──────────────────────────────────────────                   │
│  1. isKakaoTalkInstalled()      → 카카오톡 설치 확인          │
│  2. loginWithKakaoTalk/Account  → OAuthToken                 │
│  3. api('kakao_firebase_token') → 서버에서 Custom Token 발급  │
│     파라미터: {'kakao_access_token': accessToken}             │
│  4. FirebaseAuth.signInWithCustomToken(customToken) ← 간접! │
│  5. apiUserMy()                 → PostgreSQL 동기화          │
└──────────────────────────────────────────────────────────────┘
```

---

## 10. Firebase Custom Token 서버 연동 (PHP)

### 10.1 API 엔드포인트: `kakao_firebase_token`

**파일:** `/Users/thruthesky/apps/center/lib/api/api.allowed_functions.php` (기존 구현)

```php
<?php
/**
 * 카카오 access_token → Firebase Custom Token 발급 (Flutter 앱용)
 *
 * 요청 파라미터:
 *   - kakao_access_token: 카카오 access_token (필수) ← ⚠️ 이 이름 정확히 사용
 *
 * 응답:
 *   - custom_token: Firebase Custom Token (문자열)
 *   - kakao_user_id: 카카오 사용자 ID (문자열)
 *   - firebase_uid: Firebase UID (문자열, 'kakao:{id}' 형식)
 */

$kakaoAccessToken = $input['kakao_access_token'] ?? null;

if (empty($kakaoAccessToken)) {
    response_error('kakao/access-token-required', '카카오 access_token이 필요합니다.');
}

// 1) 카카오 access_token으로 사용자 정보 조회
$ch = curl_init('https://kapi.kakao.com/v2/user/me');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER     => [
        'Authorization: Bearer ' . $kakaoAccessToken,
        'Content-Type: application/x-www-form-urlencoded;charset=utf-8',
    ],
    CURLOPT_TIMEOUT        => 10,
]);
$meRes = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($meRes === false || $httpCode !== 200) {
    response_error('kakao-token-invalid', '카카오 access_token 검증에 실패했습니다.');
}

$me = json_decode($meRes, true);
$kakaoUserId = (string) $me['id'];

// 2) Firebase Custom Token 발급 (UID: 'kakao:{카카오사용자ID}')
$firebaseAuth = firebase_auth_admin();
$firebaseUid = 'kakao:' . $kakaoUserId;
$customToken = $firebaseAuth->createCustomToken($firebaseUid);
$customTokenString = $customToken->toString();

// 3) 응답
response([
    'custom_token' => $customTokenString,
    'kakao_user_id' => $kakaoUserId,
    'firebase_uid' => $firebaseUid,
]);
```

### 10.2 Firebase UID 규칙

| 소셜 로그인 | Firebase UID 형식 | 예시 |
|-----------|-------------------|------|
| Google | Google에서 자동 할당 | `abc123def456...` |
| Apple | Apple에서 자동 할당 | `000123.abc456...` |
| **카카오** | **`kakao:{카카오사용자ID}`** | `kakao:454835416` |

> **참고:** Firebase Auth 콘솔에서 카카오 Custom Token 사용자의 Identifier가 비어 있는 것은 **정상**입니다.

### 10.3 API 호출 흐름

```
Flutter 앱                     PHP 서버                     카카오 API
─────────                     ─────────                    ──────────
  │                              │                            │
  │  POST /api.php               │                            │
  │  func=kakao_firebase_token   │                            │
  │  kakao_access_token=xxx      │                            │
  │──────────────────────────────>│                            │
  │                              │  GET /v2/user/me            │
  │                              │  Authorization: Bearer xxx  │
  │                              │────────────────────────────>│
  │                              │                            │
  │                              │  { "id": 454835416 }       │
  │                              │<────────────────────────────│
  │                              │                            │
  │                              │  createCustomToken(         │
  │                              │    'kakao:454835416'        │
  │                              │  )                          │
  │                              │                            │
  │  { custom_token: "eyJ...",   │                            │
  │    kakao_user_id: "454...",  │                            │
  │    firebase_uid: "kakao:..." }                            │
  │<──────────────────────────────│                            │
```

---

## 11. 로그인 UI 구현

### 11.1 카카오 로그인 버튼 — 카카오 공식 디자인 가이드

**파일:** `lib/user/widgets/user_login_form.dart`

카카오 공식 디자인 가이드 준수:
- **배경색**: `#FEE500` (카카오 공식 노란색)
- **텍스트 색**: `#191919` (85% opacity)
- **모서리 반경**: 12px (카카오 공식 가이드)
- **아이콘**: 카카오 말풍선 로고 (`_KakaoIconPainter`)

```dart
// 카카오 로그인 버튼 (공식 카카오 디자인 가이드)
// 배경색: #FEE500, 텍스트: #191919 (85% opacity), 모서리: 12px
SizedBox(
  width: double.infinity,
  height: 44,
  child: _isLoading
      ? Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEE500),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF191919),
              ),
            ),
          ),
        )
      : Material(
          color: const Color(0xFFFEE500),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _handleKakaoLogin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 카카오 말풍선 아이콘
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomPaint(
                    painter: _KakaoIconPainter(),
                  ),
                ),
                const SizedBox(width: 8),
                // 로그인 텍스트
                Text(
                  tr.signInWithKakao,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xD9191919), // #191919 at 85% opacity
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
          ),
        ),
),
```

### 11.2 카카오 아이콘 (CustomPainter)

```dart
/// 카카오톡 말풍선 아이콘을 그리는 CustomPainter
/// 색상: #191919 (검정에 가까운)
class _KakaoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF191919)
      ..style = PaintingStyle.fill;

    // 카카오 말풍선 아이콘 경로 (viewBox 0 0 18 18 기준을 size에 맞게 스케일)
    final scaleX = size.width / 18;
    final scaleY = size.height / 18;

    final path = Path();
    path.moveTo(9 * scaleX, 1 * scaleY);
    path.cubicTo(4.58 * scaleX, 1 * scaleY, 1 * scaleX, 3.79 * scaleY, 1 * scaleX, 7.23 * scaleY);
    path.cubicTo(1 * scaleX, 9.41 * scaleY, 2.44 * scaleX, 11.33 * scaleY, 4.62 * scaleX, 12.42 * scaleY);
    path.lineTo(3.7 * scaleX, 15.8 * scaleY);
    path.cubicTo(3.62 * scaleX, 16.1 * scaleY, 3.96 * scaleX, 16.34 * scaleY, 4.22 * scaleX, 16.16 * scaleY);
    path.lineTo(8.24 * scaleX, 13.49 * scaleY);
    path.cubicTo(8.49 * scaleX, 13.51 * scaleY, 8.74 * scaleX, 13.52 * scaleY, 9 * scaleX, 13.52 * scaleY);
    path.cubicTo(13.42 * scaleX, 13.52 * scaleY, 17 * scaleX, 10.73 * scaleY, 17 * scaleX, 7.23 * scaleY);
    path.cubicTo(17 * scaleX, 3.79 * scaleY, 13.42 * scaleX, 1 * scaleY, 9 * scaleX, 1 * scaleY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 11.3 로그인 처리 함수

```dart
/// 카카오 로그인 처리
Future<void> _handleKakaoLogin() async {
  setState(() => _isLoading = true);
  try {
    await UserService.instance.signInWithKakao();
    if (mounted) {
      widget.onLoginSuccess?.call(context);
    }
  } catch (e) {
    if (mounted) {
      handleError(context, e);
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

### 11.4 번역 키

| 파일 | 키 | 값 |
|------|-----|-----|
| `app_en.arb` | `signInWithKakao` | `"Sign in with Kakao"` |
| `app_ko.arb` | `signInWithKakao` | `"카카오로 로그인"` |
| `app_ja.arb` | `signInWithKakao` | `"カカオでログイン"` |
| `app_zh.arb` | `signInWithKakao` | `"使用Kakao登录"` |

---

## 12. 에러 처리

### 12.1 카카오 SDK 에러 종류

카카오 SDK에서 발생하는 주요 예외 유형:

| 예외 타입 | 원인 | 처리 방법 |
|-----------|------|-----------|
| `PlatformException(CANCELED)` | 사용자가 로그인 취소 | 정상 동작, 에러 메시지 불필요 |
| `KakaoException` (isInvalidTokenError) | 토큰 만료/무효 | 재로그인 유도 |
| `KakaoException` (기타) | 카카오 API 에러 | 에러 메시지 표시 |

### 12.2 카카오톡 앱 로그인 실패 시 폴백 패턴

카카오 공식 문서에서 권장하는 패턴:

```dart
if (await kakao.isKakaoTalkInstalled()) {
  try {
    // 1차 시도: 카카오톡 앱으로 로그인
    kakaoToken = await kakao.UserApi.instance.loginWithKakaoTalk();
  } catch (e) {
    // 사용자 취소 시 (PlatformException code='CANCELED')
    // → 폴백하지 않고 종료할 수도 있음
    // 기타 에러 시 → 카카오 계정(웹) 로그인으로 폴백
    kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
  }
} else {
  // 카카오톡 미설치 → 카카오 계정(웹) 로그인만 가능
  kakaoToken = await kakao.UserApi.instance.loginWithKakaoAccount();
}
```

### 12.3 서버 에러 (PHP)

| 에러 코드 | 원인 | 해결 |
|----------|------|------|
| `kakao/access-token-required` | `kakao_access_token` 파라미터 누락 | 파라미터 이름 확인 |
| `kakao-token-invalid` | 카카오 access_token 만료/무효 | 재로그인 필요 |
| `kakao-user-id-missing` | 카카오 사용자 ID 확인 불가 | 카카오 계정 상태 확인 |
| `custom-token-failed` | Firebase Custom Token 발급 실패 | 서비스 계정 키 확인 |

### 12.4 Firebase Auth 에러

```dart
try {
  await FirebaseAuth.instance.signInWithCustomToken(customToken);
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'invalid-custom-token':
      // Custom Token 형식이 잘못됨 → 서버 확인
      break;
    case 'custom-token-mismatch':
      // Custom Token이 다른 Firebase 프로젝트용 → 서비스 계정 확인
      break;
  }
}
```

---

## 13. 로그아웃 / 연결끊기 (탈퇴)

### 13.1 로그아웃

카카오 로그인 시 Firebase Auth에 로그인되므로, 기존 `logout()` 메서드로 처리됩니다.

```dart
// UserService.logout() - 기존 코드 그대로 사용
void logout() {
  FirebaseAuth.instance.signOut();
}
```

> **참고:** 카카오 SDK의 `UserApi.instance.logout()`은 호출하지 않아도 됩니다.
> Firebase Auth에서 로그아웃하면 앱의 인증 상태가 해제됩니다.
> 카카오 SDK의 logout()은 카카오 서버의 토큰을 만료시키는 것으로, 호출 성공/실패와 무관하게 SDK 내부 토큰은 삭제됩니다.

### 13.2 연결끊기 (회원 탈퇴)

회원 탈퇴 시 카카오 연결끊기는 **선택사항**입니다:

```dart
// 회원 탈퇴 시 (선택: 카카오 연결끊기)
Future<void> deleteAccount() async {
  // 1. 센터 API로 계정 삭제
  await api('delete_user_account');

  // 2. 카카오 연결끊기 (선택)
  // 연결끊기(unlink)는 앱과 카카오 계정 간의 연결을 해제
  // → 다음 로그인 시 동의 화면이 다시 표시됨
  try {
    await kakao.UserApi.instance.unlink();
  } catch (e) {
    // 카카오 연결끊기 실패해도 계속 진행
  }

  // 3. Firebase 로그아웃
  await FirebaseAuth.instance.signOut();
}
```

> **logout() vs unlink() 차이:**
> - `logout()`: 카카오 토큰만 만료 (앱 연결 유지, 다음 로그인 시 동의 화면 안 뜸)
> - `unlink()`: 앱과 카카오 계정 연결 해제 (다음 로그인 시 동의 화면 다시 표시)

---

## 14. 카카오 SDK 주요 API 레퍼런스

### 14.1 로그인 관련

```dart
// 카카오톡 앱 설치 확인
// Android: <queries>에 com.kakao.talk 선언 필수 (API 30+)
// iOS: LSApplicationQueriesSchemes에 kakaokompassauth 선언 필수
bool isInstalled = await kakao.isKakaoTalkInstalled();

// 카카오톡 앱으로 로그인 (앱이 설치된 경우만 사용)
// → 카카오톡 앱이 열리고 동의 화면 표시
kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoTalk();

// 카카오 계정 (웹페이지)으로 로그인
// → 웹 브라우저에서 아이디/비밀번호 입력
kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoAccount();
```

### 14.2 OAuthToken 객체

```dart
class OAuthToken {
  String accessToken;               // 카카오 접근 토큰 (API 호출용)
  String? refreshToken;             // 갱신 토큰 (자동 갱신용)
  DateTime accessTokenExpiresAt;    // 접근 토큰 만료 시간
  DateTime? refreshTokenExpiresAt;  // 갱신 토큰 만료 시간
  String? idToken;                  // OpenID Connect 사용 시 ID 토큰
  List<String>? scopes;             // 허용된 동의 범위 목록
}
```

> **센터 프로젝트에서는 `accessToken`만 사용합니다.** 이 토큰을 서버에 전송하여 사용자 검증 후 Firebase Custom Token을 발급받습니다.

### 14.3 토큰 관리 (카카오 SDK 내부)

```dart
// 저장된 토큰 존재 여부 확인
bool hasToken = await kakao.AuthApi.instance.hasToken();

// 토큰 정보 확인 (유효성)
kakao.AccessTokenInfo tokenInfo = await kakao.UserApi.instance.accessTokenInfo();
print('토큰 유효: ${tokenInfo.expiresIn}초 남음');
print('서비스 사용자 ID: ${tokenInfo.id}');
```

> **참고:** 센터 프로젝트에서는 카카오 토큰 자체의 유효성을 관리하지 않습니다.
> 매 로그인 시 새로운 토큰을 발급받아 서버에 전송하므로 토큰 만료 걱정 불필요.

### 14.4 사용자 정보 조회

```dart
// 사용자 정보 조회 (참고용 - 센터 프로젝트에서는 서버에서 처리)
kakao.User user = await kakao.UserApi.instance.me();
print('카카오 사용자 ID: ${user.id}');
print('닉네임: ${user.kakaoAccount?.profile?.nickname}');
print('이메일: ${user.kakaoAccount?.email}');
print('프로필 이미지: ${user.kakaoAccount?.profile?.thumbnailImageUrl}');
```

> **센터 프로젝트에서는 Flutter에서 사용자 정보를 직접 조회하지 않습니다.**
> access_token을 서버에 전송하고, 서버에서 카카오 사용자 ID를 확인합니다.

### 14.5 추가 동의 요청

사용자의 추가 정보(이메일, 전화번호 등)가 필요한 경우:

```dart
// 추가 동의 필요 여부 확인
kakao.User user = await kakao.UserApi.instance.me();
List<String> scopes = [];
if (user.kakaoAccount?.emailNeedsAgreement == true) {
  scopes.add('account_email');
}
if (user.kakaoAccount?.phoneNumberNeedsAgreement == true) {
  scopes.add('phone_number');
}

// 추가 동의 요청
if (scopes.isNotEmpty) {
  kakao.OAuthToken token = await kakao.UserApi.instance.loginWithNewScopes(scopes);
  print('허용된 범위: ${token.scopes}');
}
```

### 14.6 사용자 정보 저장 (커스텀 프로퍼티)

```dart
// 카카오 서버에 커스텀 데이터 저장 (참고용)
Map<String, String> properties = {
  'nickname': '새닉네임',
};
await kakao.UserApi.instance.updateProfile(properties);
```

### 14.7 로그아웃 / 연결끊기

```dart
// 로그아웃 (카카오 토큰 만료, 결과와 무관하게 SDK 내부 토큰 삭제)
await kakao.UserApi.instance.logout();

// 연결끊기 (앱 연결 해제 + 토큰 삭제, 다음 로그인 시 동의 화면 재표시)
await kakao.UserApi.instance.unlink();
```

---

## 15. 실전 트러블슈팅

### 15.1 카카오톡 앱이 열리지 않음 (Android)

**원인 1:** `<queries>` 태그에 `com.kakao.talk` 패키지 선언 누락 (Android 11+)

```xml
<!-- AndroidManifest.xml의 <queries> 안에 추가 -->
<package android:name="com.kakao.talk" />
```

**원인 2:** `AuthCodeCustomTabsActivity` 누락 또는 scheme 오류

```xml
<!-- scheme이 kakao{네이티브앱키} 형식인지 확인 -->
<data android:scheme="kakao74e192bb5d6b531e64ae1ac8a9135838" android:host="oauth" />
```

**원인 3:** 카카오 디벨로퍼스 콘솔에 키 해시 미등록

```dart
// 현재 앱의 키 해시 출력하여 확인
var keyHash = await KakaoSdk.origin;
debugPrint('현재 키 해시: $keyHash');
```

### 15.2 카카오톡 앱이 열리지 않음 (iOS)

**원인 1:** `LSApplicationQueriesSchemes`에 `kakaokompassauth` 누락

**원인 2:** `CFBundleURLTypes`에 카카오 URL Scheme 누락

**원인 3:** Info.plist에서 키가 중복 선언됨 (마지막 것만 적용)

> **⚠️ iOS 시뮬레이터에서는 카카오톡 앱 설치 불가** → `isKakaoTalkInstalled()`가 항상 `false` → `loginWithKakaoAccount()`로 자동 폴백 (정상 동작)

### 15.3 "CANCELED" 에러

**원인:** 사용자가 카카오톡 로그인을 취소함
**처리:** 정상적인 사용자 행동이므로 에러 메시지 불필요

### 15.4 서버 에러: `kakao/access-token-required`

**원인:** Flutter에서 서버로 전송하는 파라미터 이름이 틀림
**확인:** `{'kakao_access_token': kakaoToken.accessToken}` (⚠️ `kakao_token`이 아님!)

### 15.5 Custom Token 발급 실패

**원인:** Firebase 서비스 계정 키 문제

**확인:**
- `etc/config/withcenter-firebase-adminsdk.json` 파일 존재 확인
- 서비스 계정에 `Firebase Auth` 권한 확인
- JSON 파일의 `private_key` 필드 검증

### 15.6 signInWithCustomToken 실패

| 에러 | 원인 | 해결 |
|------|------|------|
| `invalid-custom-token` | Custom Token 형식 오류 | PHP 서버의 Firebase Admin SDK 버전 확인 |
| `custom-token-mismatch` | Firebase 프로젝트 불일치 | 서비스 계정이 올바른 프로젝트 것인지 확인 |

### 15.7 키 해시 불일치 (Android)

**증상:** 카카오 로그인 시 "이 앱에서 카카오 로그인을 사용할 수 없습니다" 에러
**원인:** 카카오 콘솔에 등록된 키 해시와 실제 앱의 키 해시가 다름

```dart
// 앱 실행 중 현재 키 해시 출력
var keyHash = await KakaoSdk.origin;
debugPrint('현재 키 해시: $keyHash');
```

- 디버그 빌드와 릴리스 빌드의 키 해시는 **다릅니다**
- Google Play Console에서 배포 시 App Signing Key 해시도 등록 필요

### 15.8 `isKakaoTalkInstalled()` 항상 false (Android)

**증상:** 카카오톡이 설치되어 있는데도 `false` 반환
**원인:** Android 11+(API 30) 패키지 가시성 정책으로 인해 `<queries>`에 패키지 선언 필요

```xml
<!-- AndroidManifest.xml -->
<queries>
    <package android:name="com.kakao.talk" />
</queries>
```

이 설정 후 앱을 **완전히 삭제 후 재설치** (hot restart 불충분, 매니페스트 변경은 재설치 필요)

---

## 16. 관련 파일 목록

### 16.1 Flutter 앱 (center_apps) — 구현 완료

| 파일 | 용도 | 상태 |
|------|------|------|
| `pubspec.yaml` | `kakao_flutter_sdk_user` 패키지 | ✅ 구현 완료 |
| `lib/user/services/user.service.dart` | `signInWithKakao()` 메서드 | ✅ 구현 완료 |
| `lib/user/services/kakaotalk.service.dart` | `KakaotalkService.init()` | ✅ 구현 완료 |
| `lib/user/widgets/user_login_form.dart` | 카카오 로그인 버튼 UI | ✅ 구현 완료 |
| `lib/center.dart` | kakaotalk.service.dart export | ✅ 구현 완료 |
| `lib/l10n/app_*.arb` | signInWithKakao 번역 (en/ko/ja/zh) | ✅ 구현 완료 |

### 16.2 각 가맹사 앱 — Singapore 앱 구현 완료

| 파일 | 용도 | 상태 |
|------|------|------|
| `apps/singapore/lib/main.dart` | `KakaotalkService.init()` 호출 | ✅ 구현 완료 |
| `apps/singapore/lib/singapore.config.dart` | `kakaoNativeAppKey` 저장 | ✅ 구현 완료 |
| `apps/singapore/android/.../AndroidManifest.xml` | AuthCodeCustomTabsActivity + queries | ✅ 구현 완료 |
| `apps/singapore/ios/Runner/Info.plist` | URL Scheme + LSApplicationQueriesSchemes | ✅ 구현 완료 |

### 16.3 PHP 서버 (센터 프로젝트)

| 파일 | 용도 | 상태 |
|------|------|------|
| `lib/api/api.allowed_functions.php` | `kakao_firebase_token()` 함수 | ✅ 구현 완료 |
| `lib/firebase/firebase.functions.php` | `firebase_auth_admin()` → Custom Token 발급 | ✅ 기존 구현 |
| `etc/config/withcenter-firebase-adminsdk.json` | Firebase Admin SDK 서비스 계정 키 | ✅ 기존 설정 |

### 16.4 기존 공유 파일 (수정 불필요)

| 파일 | 핵심 기능 |
|------|----------|
| `lib/functions/api.functions.dart` | `api()` 함수, `apiUserMy()` |
| `lib/user/models/user_model.dart` | 사용자 데이터 모델 |
| `lib/user/states/user_state.dart` | 전역 사용자 상태 (Firebase authStateChanges 감지) |
| `lib/user/screens/login.screen.dart` | 로그인 화면 |

### 16.5 관련 문서

| 문서 | 설명 |
|------|------|
| [web-kakoatalk-social-login.md](../web/web-kakoatalk-social-login.md) | 웹 버전 카카오 로그인 (PHP redirect 방식) |
| [카카오 공식 Flutter Getting Started](https://developers.kakao.com/docs/latest/en/flutter/getting-started) | SDK 설치, 플랫폼 설정, 초기화 |
| [카카오 공식 Flutter Kakao Login](https://developers.kakao.com/docs/latest/en/kakaologin/flutter) | 로그인/로그아웃 API, 토큰 관리, 사용자 정보 |
