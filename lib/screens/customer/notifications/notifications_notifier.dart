import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/providers/unread_notification_count_provider.dart';
import 'package:badminton_app/repositories/notification_repository.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsNotifierProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    Future.microtask(loadNotifications);
    return const NotificationsState(isLoading: true);
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await getCurrentUser(ref);
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: '로그인이 필요합니다',
        );
        return;
      }

      final repository =
          ref.read(notificationRepositoryProvider);
      final notifications =
          await repository.getByUser(user.id);
      state = NotificationsState(notifications: notifications);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '알림을 불러올 수 없습니다',
      );
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final repository =
          ref.read(notificationRepositoryProvider);
      await repository.markAsRead(id);
      state = state.copyWith(
        notifications: state.notifications
            .map(
              (n) => n.id == id
                  ? n.copyWith(isRead: true)
                  : n,
            )
            .toList(),
      );
      ref
          .read(unreadNotificationCountProvider.notifier)
          .refresh();
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = await getCurrentUser(ref);
      if (user == null) return;

      final repository =
          ref.read(notificationRepositoryProvider);
      await repository.markAllAsRead(user.id);
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList(),
      );
      ref
          .read(unreadNotificationCountProvider.notifier)
          .refresh();
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
    }
  }
}
