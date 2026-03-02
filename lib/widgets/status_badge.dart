import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:flutter/material.dart';

enum StatusBadgeSize { small, large }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusBadgeSize.small,
    this.showDot = false,
  });

  final OrderStatus status;
  final StatusBadgeSize size;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, txtColor) = _statusColors;
    final isLarge = size == StatusBadgeSize.large;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : showDot ? 12 : 10,
        vertical: isLarge ? 6 : showDot ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: fgColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.label,
            style: TextStyle(
              color: txtColor,
              fontSize: isLarge ? 14 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) get _statusColors => switch (status) {
        OrderStatus.received => (
          AppTheme.receivedBackground,
          AppTheme.receivedForeground,
          AppTheme.receivedText,
        ),
        OrderStatus.inProgress => (
          AppTheme.inProgressBackground,
          AppTheme.inProgressForeground,
          AppTheme.inProgressText,
        ),
        OrderStatus.completed => (
          AppTheme.completedBackground,
          AppTheme.completedForeground,
          AppTheme.completedText,
        ),
      };
}
