import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// FCM 푸시 알림 서비스.
///
/// 알림 권한 요청, 토큰 관리, 메시지 핸들러 설정을 담당한다.
class FcmService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'gut_alarm_channel',
    '거트알림',
    description: '거트 작업 상태 알림',
    importance: Importance.high,
  );

  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  /// FCM을 초기화한다.
  ///
  /// 알림 권한을 요청하고 토큰을 가져온다.
  Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();
    await getToken();
    setupMessageHandlers();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(settings);

    // Android 알림 채널 생성
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
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
    FirebaseMessaging.onMessage
        .listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp
        .listen(_handleBackgroundMessage);
  }

  Future<NotificationSettings> _requestPermission() async {
    return _messaging.requestPermission();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // 알림 탭 → 앱 열기 (추후 딥링크 처리 가능)
  }
}
