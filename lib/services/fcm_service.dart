import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// FCM 푸시 알림 서비스.
///
/// 알림 권한 요청, 토큰 관리, 메시지 핸들러 설정을 담당한다.
class FcmService {
  final FirebaseMessaging _messaging;

  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  /// FCM을 초기화한다.
  ///
  /// 알림 권한을 요청하고 토큰을 가져온다.
  Future<void> initialize() async {
    await _requestPermission();
    await getToken();
    setupMessageHandlers();
  }

  /// 현재 FCM 토큰을 반환한다.
  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  /// FCM 토큰을 users 테이블에 저장한다.
  Future<void> saveTokenToDb(
    String userId,
    SupabaseClient supabase,
  ) async {
    final token = await getToken();
    if (token == null) return;

    await supabase
        .from('users')
        .update({'fcm_token': token}).eq('id', userId);
  }

  /// 토큰 갱신 스트림을 반환한다.
  Stream<String> get onTokenRefresh =>
      _messaging.onTokenRefresh;

  /// 포그라운드 메시지 수신 스트림을 반환한다.
  Stream<RemoteMessage> get onMessage =>
      FirebaseMessaging.onMessage;

  /// 포그라운드/백그라운드 메시지 핸들러를 설정한다.
  void setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp
        .listen(_handleBackgroundMessage);
  }

  Future<NotificationSettings> _requestPermission() async {
    return _messaging.requestPermission();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // 포그라운드 메시지 처리 로직
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // 백그라운드 메시지 탭 처리 로직
  }
}
