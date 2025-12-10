# Firebase 초기화

## 개요

필고 앱은 Firebase를 사용하여 인증, 데이터베이스, 메시징 등의 기능을 구현합니다.

## 초기화 위치

`lib/main.dart`에서 앱 시작 시 Firebase를 초기화합니다.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(...);
}
```

## 사용 중인 Firebase 패키지

| 패키지 | 버전 | 용도 |
|--------|------|------|
| firebase_core | ^3.15.1 | Firebase 코어 |
| firebase_auth | ^5.6.1 | 전화번호 인증 |
| firebase_database | ^11.3.10 | Realtime Database |
| firebase_messaging | ^15.2.8 | 푸시 알림 |
| firebase_remote_config | ^5.5.0 | 원격 설정 |

## Firebase 설정 파일

- `lib/firebase_options.dart` - Firebase 프로젝트 설정
- `android/app/google-services.json` - Android 설정
- `ios/Runner/GoogleService-Info.plist` - iOS 설정

## 푸시 알림 초기화

`lib/functions/init.functions.dart`의 `initMessagingService()`에서 처리:

```dart
await MessagingService.instance.initialize(
  domain: 'philgo_v6_app',
  onForegroundMessage: (message) { ... },
  onMessageOpenedFromBackground: (message) { ... },
  onMessageOpenedFromTerminated: (message) { ... },
);
```

## Android 알림 채널

```dart
void initNotificationChannel() async {
  const MethodChannel channel = MethodChannel('com.withcenter.philgo/push_notification');
  Map<String, String> channelMap = {
    "id": "main_notification",
    "name": "Main Notifications",
    "sound": "custom_sound",
  };
  await channel.invokeMethod('createNotificationChannel', channelMap);
}
```
