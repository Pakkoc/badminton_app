import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/notification_item.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_notifier.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_screen.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

void main() {
  group('NotificationsScreen', () {
    testWidgets('로딩 중일 때 로딩 인디케이터를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const NotificationsScreen(),
        overrides: [
          notificationsNotifierProvider.overrideWith(
            () => _FakeNotificationsNotifier(
              const NotificationsState(isLoading: true),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );
    });

    testWidgets('알림이 없을 때 빈 상태를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const NotificationsScreen(),
        overrides: [
          notificationsNotifierProvider.overrideWith(
            () => _FakeNotificationsNotifier(
              const NotificationsState(),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('알림이 없습니다'), findsOneWidget);
    });

    testWidgets('알림 목록을 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const NotificationsScreen(),
        overrides: [
          notificationsNotifierProvider.overrideWith(
            () => _FakeNotificationsNotifier(
              NotificationsState(
                notifications: [testNotification],
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('작업 상태 변경'), findsOneWidget);
      expect(
        find.text('거트 프로샵에서 작업이 시작되었습니다.'),
        findsOneWidget,
      );
    });

    testWidgets('AppBar에 "알림"과 "모두 읽음" 버튼이 표시된다',
        (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const NotificationsScreen(),
        overrides: [
          notificationsNotifierProvider.overrideWith(
            () => _FakeNotificationsNotifier(
              const NotificationsState(),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('알림'), findsOneWidget);
      expect(find.text('모두 읽음'), findsOneWidget);
    });

    testWidgets('읽지 않은 알림은 배경색이 다르다', (tester) async {
      // Arrange
      final unreadNotification = testNotification.copyWith(
        isRead: false,
      );
      final readNotification = NotificationItem(
        id: 'read-id',
        userId: testUser.id,
        type: NotificationType.notice,
        title: '읽은 알림',
        body: '이미 읽은 알림입니다.',
        isRead: true,
        createdAt: DateTime(2026, 1, 10),
      );

      await pumpTestApp(
        tester,
        child: const NotificationsScreen(),
        overrides: [
          notificationsNotifierProvider.overrideWith(
            () => _FakeNotificationsNotifier(
              NotificationsState(
                notifications: [
                  unreadNotification,
                  readNotification,
                ],
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('작업 상태 변경'), findsOneWidget);
      expect(find.text('읽은 알림'), findsOneWidget);
    });

    testWidgets('에러 상태일 때 에러 뷰를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const NotificationsScreen(),
        overrides: [
          notificationsNotifierProvider.overrideWith(
            () => _FakeNotificationsNotifier(
              const NotificationsState(
                error: '알림을 불러올 수 없습니다',
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.text('알림을 불러올 수 없습니다'),
        findsOneWidget,
      );
    });
  });
}

class _FakeNotificationsNotifier
    extends NotificationsNotifier {
  final NotificationsState _initialState;

  _FakeNotificationsNotifier(this._initialState);

  @override
  NotificationsState build() => _initialState;

  @override
  Future<void> loadNotifications() async {}

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAllAsRead() async {}
}
