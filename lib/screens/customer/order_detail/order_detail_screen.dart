import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_notifier.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(orderDetailNotifierProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('작업 상세')),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref
            .read(orderDetailNotifierProvider(orderId).notifier)
            .loadOrder(orderId),
      );
    }

    final order = state.order;
    if (order == null) {
      return const LoadingIndicator();
    }

    final shop = state.shop;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: StatusBadge(
              status: order.status,
              size: StatusBadgeSize.large,
            ),
          ),
          const SizedBox(height: 24),
          if (shop != null) ...[
            Text(
              shop.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              shop.address,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 24),
          ],
          _TimelineSection(
            createdAt: order.createdAt,
            inProgressAt: order.inProgressAt,
            completedAt: order.completedAt,
          ),
          if (order.memo != null && order.memo!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '메모',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.memo!,
                style:
                    Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.createdAt,
    this.inProgressAt,
    this.completedAt,
  });

  final DateTime createdAt;
  final DateTime? inProgressAt;
  final DateTime? completedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '타임라인',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _TimelineItem(
          label: '접수',
          time: Formatters.dateTime(createdAt),
          isActive: true,
        ),
        _TimelineItem(
          label: '작업 시작',
          time: inProgressAt != null
              ? Formatters.dateTime(inProgressAt!)
              : '-',
          isActive: inProgressAt != null,
        ),
        _TimelineItem(
          label: '완료',
          time: completedAt != null
              ? Formatters.dateTime(completedAt!)
              : '-',
          isActive: completedAt != null,
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.label,
    required this.time,
    required this.isActive,
    this.isLast = false,
  });

  final String label;
  final String time;
  final bool isActive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.3);
    final color = isActive ? activeColor : inactiveColor;

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                  ),
                  Text(
                    time,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
