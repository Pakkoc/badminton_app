import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/notification_item.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_notifier.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_state.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(
                    notificationsNotifierProvider.notifier,
                  )
                  .markAllAsRead();
            },
            child: const Text('모두 읽음'),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    NotificationsState state,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.notifications.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () {
          ref
              .read(notificationsNotifierProvider.notifier)
              .loadNotifications();
        },
      );
    }

    if (state.notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        message: '알림이 없습니다',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(notificationsNotifierProvider.notifier)
            .loadNotifications();
      },
      child: ListView.builder(
        itemCount: state.notifications.length,
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () {
              ref
                  .read(
                    notificationsNotifierProvider.notifier,
                  )
                  .markAsRead(notification.id);
              if (notification.orderId != null) {
                context.push(
                  '/customer/order/${notification.orderId}',
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationItem notification;
  final VoidCallback onTap;

  IconData _iconForType(NotificationType type) =>
      switch (type) {
        NotificationType.statusChange =>
          Icons.sync,
        NotificationType.completion =>
          Icons.check_circle_outline,
        NotificationType.notice =>
          Icons.campaign_outlined,
        NotificationType.receipt =>
          Icons.receipt_long_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final bgColor = notification.isRead
        ? null
        : const Color(0xFFEFF6FF);

    return Container(
      color: bgColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context)
              .colorScheme
              .primaryContainer,
          child: Icon(
            _iconForType(notification.type),
            color: Theme.of(context)
                .colorScheme
                .onPrimaryContainer,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead
                ? FontWeight.normal
                : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.body),
        trailing: Text(
          Formatters.relativeTime(notification.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: onTap,
      ),
    );
  }
}
