import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_notifier.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderHistoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('작업 이력'),
      ),
      body: CourtBackground(
        child: _buildBody(context, ref, state),
      ),
      bottomNavigationBar: const CustomerBottomNav(
        currentIndex: 3,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    OrderHistoryState state,
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sports_tennis,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 완료된 작업이 없습니다',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.textTertiary),
            ),
            const SizedBox(height: 8),
            Text(
              '거트 작업이 완료되면 여기에 표시됩니다',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: () => ref
          .read(orderHistoryNotifierProvider.notifier)
          .loadHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 16,
        ),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          final shopName =
              state.shopNames[order.shopId] ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HistoryCard(
              order: order,
              shopName: shopName,
              onTap: () => context
                  .push('/customer/order/${order.id}'),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.order,
    required this.shopName,
    required this.onTap,
  });

  final GutOrder order;
  final String shopName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completedDate = order.completedAt ?? order.updatedAt;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceHigh,
            border: Border(
              left: BorderSide(
                color: AppTheme.activeTab,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${Formatters.date(completedDate)} 완료',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.completedBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(
                    color: AppTheme.completedText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
