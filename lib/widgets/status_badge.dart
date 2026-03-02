import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:flutter/material.dart';

enum StatusBadgeSize { small, large }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusBadgeSize.small,
  });

  final OrderStatus status;
  final StatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _statusColors;
    final isLarge = size == StatusBadgeSize.large;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isLarge ? 8 : 6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: isLarge ? 14 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) get _statusColors => switch (status) {
        OrderStatus.received => (
          const Color(0xFFFEF3C7),
          const Color(0xFFF59E0B),
        ),
        OrderStatus.inProgress => (
          AppTheme.inProgressBackground,
          AppTheme.inProgressForeground,
        ),
        OrderStatus.completed => (
          AppTheme.completedBackground,
          AppTheme.completedForeground,
        ),
      };
}
