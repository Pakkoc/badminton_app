import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState
    extends ConsumerState<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  void _loadDashboard() {
    final userId =
        ref.read(supabaseProvider).auth.currentUser?.id;
    if (userId != null) {
      ref
          .read(ownerDashboardNotifierProvider.notifier)
          .loadDashboard(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(ownerDashboardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              final shell = StatefulNavigationShell.of(context);
              shell.goBranch(2);
            },
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final shopId = ref
              .read(ownerDashboardNotifierProvider)
              .shopId;
          context.push(
            '/owner/dashboard/order-create'
            '?shopId=$shopId',
          );
        },
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(OwnerDashboardState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: _loadDashboard,
      );
    }

    if (state.recentOrders.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        message: '오늘 접수된 작업이 없습니다',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadDashboard(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '오늘의 작업 현황',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
          ),
          const SizedBox(height: 12),
          _StatusCountCards(
            receivedCount: state.receivedCount,
            inProgressCount: state.inProgressCount,
            completedCount: state.completedCount,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 작업',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
              TextButton(
                onPressed: () {
                  StatefulNavigationShell.of(context)
                      .goBranch(1);
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      const Color(0xFF16A34A),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '전체보기',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...state.recentOrders.map(
            (order) => _OrderCard(
              order: order,
              onStatusChange: (newStatus) {
                ref
                    .read(ownerDashboardNotifierProvider
                        .notifier)
                    .changeOrderStatus(
                      order.id,
                      newStatus,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCountCards extends StatelessWidget {
  const _StatusCountCards({
    required this.receivedCount,
    required this.inProgressCount,
    required this.completedCount,
  });

  final int receivedCount;
  final int inProgressCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CountCard(
            label: '접수됨',
            count: receivedCount,
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFEF3C7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountCard(
            label: '작업중',
            count: inProgressCount,
            color: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFDBEAFE),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountCard(
            label: '완료',
            count: completedCount,
            color: const Color(0xFF22C55E),
            bgColor: const Color(0xFFDCFCE7),
          ),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$count',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
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
    required this.onStatusChange,
  });

  final GutOrder order;
  final void Function(OrderStatus) onStatusChange;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(order.memo ?? '메모 없음'),
        subtitle: Text(
          '회원 ID: ${order.memberId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: StatusBadge(status: order.status),
      ),
    );
  }
}
