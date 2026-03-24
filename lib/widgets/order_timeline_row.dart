import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/order.dart';

/// 주문 카드에 표시되는 접수/시작/완료 타임라인 Row.
///
/// 각 단계의 날짜+시간을 가로 한 줄로 보여주며,
/// 미도달 단계는 회색 `──`로 표시한다.
class OrderTimelineRow extends StatelessWidget {
  const OrderTimelineRow({super.key, required this.order});

  final GutOrder order;

  static const _active = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppTheme.onCardTertiary,
  );

  static const _inactive = TextStyle(
    fontSize: 11,
    color: AppTheme.onCardHint,
  );

  @override
  Widget build(BuildContext context) {
    final hasStart = order.inProgressAt != null;
    final hasComplete = order.completedAt != null;

    return Row(
      children: [
        Text('접수 ${_fmt(order.createdAt)}', style: _active),
        Text(' → ', style: hasStart ? _active : _inactive),
        Text(
          hasStart
              ? '시작 ${_fmt(order.inProgressAt!)}'
              : '시작 ──',
          style: hasStart ? _active : _inactive,
        ),
        Text(' → ', style: hasComplete ? _active : _inactive),
        Text(
          hasComplete
              ? '완료 ${_fmt(order.completedAt!)}'
              : '완료 ──',
          style: hasComplete ? _active : _inactive,
        ),
      ],
    );
  }

  String _fmt(DateTime dt) {
    final month = dt.month;
    final day = dt.day;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$month/$day $h:$m';
  }
}
