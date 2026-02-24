import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_notifier.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderHistoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('작업 내역')),
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
            .read(orderHistoryNotifierProvider.notifier)
            .loadHistory(),
      );
    }

    if (state.orders.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        message: '작업 내역이 없습니다',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final GutOrder order = state.orders[index];
        return _HistoryCard(
          order: order,
          onTap: () =>
              context.push('/customer/order/${order.id}'),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.order,
    required this.onTap,
  });

  final GutOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              StatusBadge(status: order.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (order.memo != null)
                      Text(
                        order.memo!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.dateTime(order.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
