import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late _MockNotificationRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = _MockNotificationRepository();
    container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider
            .overrideWithValue(mockRepo),
        currentUserProvider.overrideWith(
          (ref) async => testUser,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('NotificationsNotifier', () {
    test('build 시 자동으로 알림을 로드한다', () async {
      // Arrange
      when(() => mockRepo.getByUser(any()))
          .thenAnswer((_) async => [testNotification]);

      // Act
      container.read(notificationsNotifierProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state =
          container.read(notificationsNotifierProvider);
      expect(state.notifications, [testNotification]);
      expect(state.isLoading, isFalse);
    });

    group('loadNotifications', () {
      test('알림 목록을 조회한다', () async {
        // Arrange
        when(() => mockRepo.getByUser(any()))
            .thenAnswer((_) async => [testNotification]);

        final notifier = container.read(
          notificationsNotifierProvider.notifier,
        );

        // Act
        await notifier.loadNotifications();

        // Assert
        final state =
            container.read(notificationsNotifierProvider);
        expect(state.notifications, [testNotification]);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('로그인하지 않으면 에러를 설정한다', () async {
        // Arrange
        final noUserContainer = ProviderContainer(
          overrides: [
            notificationRepositoryProvider
                .overrideWithValue(mockRepo),
            currentUserProvider.overrideWith(
              (ref) async => null,
            ),
          ],
        );
        addTearDown(noUserContainer.dispose);

        final notifier = noUserContainer.read(
          notificationsNotifierProvider.notifier,
        );

        // Act
        await notifier.loadNotifications();

        // Assert
        final state = noUserContainer.read(
          notificationsNotifierProvider,
        );
        expect(state.error, '로그인이 필요합니다');
        expect(state.isLoading, isFalse);
      });

      test('조회 실패 시 에러를 설정한다', () async {
        // Arrange
        when(() => mockRepo.getByUser(any()))
            .thenThrow(AppException.server());

        final notifier = container.read(
          notificationsNotifierProvider.notifier,
        );

        // Act
        await notifier.loadNotifications();

        // Assert
        final state =
            container.read(notificationsNotifierProvider);
        expect(state.error, isNotNull);
        expect(state.isLoading, isFalse);
      });
    });

    group('markAsRead', () {
      test('알림을 읽음 처리한다', () async {
        // Arrange
        when(() => mockRepo.getByUser(any()))
            .thenAnswer((_) async => [testNotification]);
        when(() => mockRepo.markAsRead(any()))
            .thenAnswer((_) async {});

        final notifier = container.read(
          notificationsNotifierProvider.notifier,
        );
        await notifier.loadNotifications();

        // Act
        await notifier.markAsRead(testNotification.id);

        // Assert
        final state =
            container.read(notificationsNotifierProvider);
        expect(state.notifications.first.isRead, isTrue);
      });
    });

    group('markAllAsRead', () {
      test('모든 알림을 읽음 처리한다', () async {
        // Arrange
        when(() => mockRepo.getByUser(any()))
            .thenAnswer((_) async => [testNotification]);
        when(() => mockRepo.markAllAsRead(any()))
            .thenAnswer((_) async {});

        final notifier = container.read(
          notificationsNotifierProvider.notifier,
        );
        await notifier.loadNotifications();

        // Act
        await notifier.markAllAsRead();

        // Assert
        final state =
            container.read(notificationsNotifierProvider);
        expect(
          state.notifications.every((n) => n.isRead),
          isTrue,
        );
      });
    });
  });
}
