import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

/// FCM 푸시 알림 서비스.
///
/// 알림 권한 요청, 토큰 관리, 메시지 핸들러 설정을 담당한다.
class FcmService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// GoRouter 참조 — 알림 탭 시 딥링크 네비게이션에 사용.
  static GoRouter? _router;

  static const _androidChannel = AndroidNotificationChannel(
    'order_status',
    '주문 상태 알림',
    description: '거트 작업 상태 변경 알림',
    importance: Importance.high,
  );

  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  /// GoRouter를 설정한다 — 앱 시작 후 호출해야 한다.
  static void setRouter(GoRouter router) {
    _router = router;
  }

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
    const settings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

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
        .listen(_handleMessageOpenedApp);
    _handleInitialMessage();
  }

  Future<NotificationSettings> _requestPermission() async {
    return _messaging.requestPermission();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // data를 payload로 전달 — 탭 시 딥링크에 사용
    final payload = jsonEncode(message.data);

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
      payload: payload,
    );
  }

  /// 포그라운드 로컬 알림 탭 핸들러.
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateToOrder(data);
    } on FormatException {
      debugPrint('FCM: invalid notification payload');
    }
  }

  /// 백그라운드에서 알림 탭 → 앱 열기.
  void _handleMessageOpenedApp(RemoteMessage message) {
    _navigateToOrder(message.data);
  }

  /// 앱이 종료된 상태에서 알림 탭 → 앱 열기.
  Future<void> _handleInitialMessage() async {
    final message =
        await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      // 라우터 준비를 위해 잠시 대기
      await Future<void>.delayed(const Duration(seconds: 1));
      _navigateToOrder(message.data);
    }
  }

  /// FCM data에서 order_id를 추출하여 주문 상세로 이동.
  void _navigateToOrder(Map<String, dynamic> data) {
    final orderId = data['order_id'] as String?;
    if (orderId == null || _router == null) return;

    _router!.push('/customer/order/$orderId');
  }
}
