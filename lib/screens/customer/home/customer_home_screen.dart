import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/screens/customer/home/customer_home_notifier.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerHomeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('거트알림'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                context.push('/customer/notifications'),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
      bottomNavigationBar: _BottomNav(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              context.go('/customer/shop-search');
            case 2:
              context.go('/customer/mypage');
          }
        },
      ),
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
            .read(customerHomeNotifierProvider.notifier)
            .refresh(),
      );
    }

    if (state.activeOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref
            .read(customerHomeNotifierProvider.notifier)
            .refresh(),
        child: ListView(
          children: const [
            SizedBox(height: 120),
            EmptyState(
              icon: Icons.content_paste_off,
              message: '아직 진행 중인 작업이 없습니다',
            ),
          ],
        ),
      );
    }

    final receivedCount = state.activeOrders
        .where(
          (GutOrder o) => o.status == OrderStatus.received,
        )
        .length;
    final inProgressCount = state.activeOrders
        .where(
          (GutOrder o) => o.status == OrderStatus.inProgress,
        )
        .length;

    return RefreshIndicator(
      onRefresh: () => ref
          .read(customerHomeNotifierProvider.notifier)
          .refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(
            receivedCount: receivedCount,
            inProgressCount: inProgressCount,
          ),
          const SizedBox(height: 16),
          ...state.activeOrders.map<Widget>(
            (GutOrder order) => _OrderCard(
              order: order,
              onTap: () =>
                  context.push('/customer/order/${order.id}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.receivedCount,
    required this.inProgressCount,
  });

  final int receivedCount;
  final int inProgressCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$receivedCount',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '접수됨',
                    style:
                        Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 48,
              color: colorScheme.outlineVariant,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$inProgressCount',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '작업중',
                    style:
                        Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      Formatters.relativeTime(
                        order.createdAt,
                      ),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '샵검색',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
    );
  }
}
