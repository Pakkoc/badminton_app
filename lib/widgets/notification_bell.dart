import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/providers/unread_notification_count_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알림 벨 아이콘 + 읽지 않은 알림 수 뱃지.
///
/// 고객 홈과 사장님 대시보드에서 공통으로 사용한다.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count =
        ref.watch(unreadNotificationCountProvider);

    return IconButton(
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(fontSize: 10),
        ),
        child: const Icon(Icons.notifications_outlined),
      ),
      color: AppTheme.textPrimary,
      onPressed: onPressed,
      tooltip: '알림',
    );
  }
}
