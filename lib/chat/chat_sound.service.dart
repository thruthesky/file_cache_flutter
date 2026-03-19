import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Chat Sound Service - 채팅 알림음 재생 서비스
///
/// Singleton pattern for playing chat notification sounds across the app.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 하나의 인스턴스만 사용합니다.
///
/// Features - 기능:
/// - Play send sound (send.mp3) - 메시지 전송음 재생
/// - Play receive sound (beep_message.mp3) - 새 메시지 도착 알림음 재생
/// - Track app foreground state - 앱 포그라운드 상태 확인
class ChatSoundService {
  /// Singleton instance - 싱글톤 인스턴스
  static ChatSoundService? _instance;

  /// Singleton instance getter - 싱글톤 인스턴스 접근자
  static ChatSoundService get instance {
    _instance ??= ChatSoundService._internal();
    return _instance!;
  }

  /// Private constructor - Private 생성자
  ChatSoundService._internal();

  /// Send sound player - 메시지 전송음 재생기
  final AudioPlayer _sendPlayer = AudioPlayer();

  /// Receive sound player - 메시지 수신음 재생기
  final AudioPlayer _receivePlayer = AudioPlayer();

  /// App foreground state tracker - 앱 포그라운드 상태 추적
  ///
  /// true: App is in foreground - 앱이 포그라운드에 있음
  /// false: App is in background/terminated - 앱이 백그라운드/종료 상태
  bool _isAppInForeground = true;

  /// Service initialization flag - 서비스 초기화 여부
  bool _initialized = false;

  /// Initialize service - 서비스 초기화
  ///
  /// Register AppLifecycleListener to track app state.
  /// AppLifecycleListener를 등록하여 앱 상태를 추적합니다.
  void initialize() {
    if (_initialized) return;

    // Register AppLifecycleListener - AppLifecycleListener 등록
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));

    _initialized = true;
  }

  /// Set app foreground state - 앱 포그라운드 상태 설정
  void _setAppInForeground(bool value) {
    _isAppInForeground = value;
  }

  /// Play send sound - 메시지 전송음 재생
  ///
  /// Call when user sends a message.
  /// 사용자가 메시지를 전송할 때 호출합니다.
  Future<void> playSendSound() async {
    try {
      await _sendPlayer.play(AssetSource('sound/send.mp3'));
    } catch (e) {
      // Silently ignore on failure - 소리 재생 실패 시 조용히 무시
      // Don't affect chat functionality - 채팅 기능에 영향을 주지 않도록 함
    }
  }

  /// Play receive sound - 새 메시지 도착 알림음 재생
  ///
  /// Only play when app is in foreground.
  /// 앱이 포그라운드 상태일 때만 재생합니다.
  ///
  /// In background/terminated state, Firebase Messaging's system notification sound plays.
  /// 백그라운드/종료 상태에서는 Firebase Messaging의 시스템 알림음이 재생됩니다.
  Future<void> playReceiveSound() async {
    // Check if service is initialized - 서비스 초기화 확인
    if (!_initialized) return;

    // Don't play if app is in background - 앱이 백그라운드에 있으면 재생하지 않음
    if (!_isAppInForeground) return;

    try {
      await _receivePlayer.play(AssetSource('sound/beep_message.mp3'));
    } catch (e) {
      // Silently ignore on failure - 소리 재생 실패 시 조용히 무시
    }
  }

  /// Dispose resources - 리소스 해제
  ///
  /// Call on app termination to release AudioPlayer resources.
  /// 앱 종료 시 호출하여 AudioPlayer 리소스를 해제합니다.
  void dispose() {
    _sendPlayer.dispose();
    _receivePlayer.dispose();
  }
}

/// AppLifecycle state observer - AppLifecycle 상태 감시 옵저버
///
/// Implement WidgetsBindingObserver to monitor app lifecycle state changes.
/// WidgetsBindingObserver를 구현하여 앱의 라이프사이클 상태 변화를 감시합니다.
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final ChatSoundService _service;

  _AppLifecycleObserver(this._service);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App moved to foreground - 앱이 포그라운드로 전환됨
        _service._setAppInForeground(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App moved to background - 앱이 백그라운드로 전환됨
        _service._setAppInForeground(false);
        break;
    }
  }
}
