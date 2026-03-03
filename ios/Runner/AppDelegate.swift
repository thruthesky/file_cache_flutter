import Flutter
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1. Firebase를 native에서 먼저 초기화
    //    Flutter의 Firebase.initializeApp()은 이미 초기화된 경우 재초기화하지 않음
    FirebaseApp.configure()
    print("[PhilGo] FirebaseApp.configure() 완료")

    // 2. Firebase Auth의 checkNotificationForwarding() 체크를 사전 통과시킴
    //    Firebase Auth SDK는 verifyPhoneNumber 호출 시 내부적으로 fake "prober" notification을
    //    application.delegate에 보내고, canHandleNotification()이 호출되는지 확인함
    //    Scene-based lifecycle(Flutter 3.41+)에서 이 메커니즘이 정상 동작하지 않을 수 있으므로,
    //    앱 시작 시 직접 prober notification을 Auth에 전달하여 forwarding check를 통과시킴
    let fakeProber: [AnyHashable: Any] = [
      "com.google.firebase.auth": ["warning": "This fake notification should be forwarded to Firebase Auth."]
    ]
    let handled = Auth.auth().canHandleNotification(fakeProber)
    print("[PhilGo] notification forwarding 사전 등록: \(handled)")

    // 4. APNs 등록 요청
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("[PhilGo] APNs 토큰 등록 성공")
    Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("[PhilGo] APNs 토큰 등록 실패: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    print("[PhilGo] didReceiveRemoteNotification 호출됨")
    if Auth.auth().canHandleNotification(userInfo) {
      print("[PhilGo] Auth.canHandleNotification = true")
      completionHandler(.noData)
      return
    }
    Messaging.messaging().appDidReceiveMessage(userInfo)
    super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
  }
}
