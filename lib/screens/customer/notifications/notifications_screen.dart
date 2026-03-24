import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/notification_item.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_notifier.dart';
import 'package:badminton_app/screens/customer/notifications/notifications_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
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
      body: CourtBackground(
        child: _buildBody(context, ref, state),
      ),
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
              } else if (notification.postId != null &&
                  (notification.type ==
                          NotificationType.commentOnPost ||
                      notification.type ==
                          NotificationType.replyOnComment)) {
                context.push(
                  '/community/${notification.postId}',
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
        NotificationType.statusChange => Icons.sync,
        NotificationType.completion =>
          Icons.check_circle_outline,
        NotificationType.notice => Icons.campaign_outlined,
        NotificationType.receipt =>
          Icons.receipt_long_outlined,
        NotificationType.shopApproval => Icons.check_circle,
        NotificationType.shopRejection =>
          Icons.cancel_outlined,
        NotificationType.communityReport =>
          Icons.flag_outlined,
        NotificationType.commentOnPost =>
          Icons.chat_bubble_outline,
        NotificationType.replyOnComment =>
          Icons.reply_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final bgColor = notification.isRead
        ? Colors.transparent
        : AppTheme.cardBackground;

    final tile = InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: const Border(
            bottom: BorderSide(
              color: AppTheme.cardBorder,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.cardBackground,
              child: Icon(
                _iconForType(notification.type),
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: notification.isRead
                          ? AppTheme.textPrimary
                          : AppTheme.onCardPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: notification.isRead
                              ? null
                              : AppTheme.onCardSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Formatters.relativeTime(
                notification.createdAt,
              ),
              style:
                  Theme.of(context).textTheme.bodySmall
                      ?.copyWith(
                        color: notification.isRead
                            ? null
                            : AppTheme.onCardTertiary,
                      ),
            ),
          ],
        ),
      ),
    );

    if (!notification.isRead) {
      return Semantics(
        label: '읽지 않은 알림: ${notification.title}',
        child: tile,
      );
    }
    return tile;
  }
}
