import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_notifier.dart';
import 'package:badminton_app/screens/owner/dashboard/owner_dashboard_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/order_timeline_row.dart';
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
    final state = ref.watch(ownerDashboardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '대시보드',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: AppTheme.textHint,
              size: 24,
            ),
            onPressed: () {
              StatefulNavigationShell.of(context).goBranch(2);
            },
          ),
        ],
      ),
      body: CourtBackground(
        child: _DashboardBody(
        state: state,
        onRetry: _loadDashboard,
        onStatusChange: (orderId, newStatus) {
          ref
              .read(ownerDashboardNotifierProvider.notifier)
              .changeOrderStatus(orderId, newStatus);
        },
        onViewAll: () {
          StatefulNavigationShell.of(context).goBranch(1);
        },
      ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            final shopId = ref
                .read(ownerDashboardNotifierProvider)
                .shopId;
            context.push(
              '/owner/dashboard/order-create'
              '?shopId=$shopId',
            );
          },
          backgroundColor: AppTheme.primaryCta,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.state,
    required this.onRetry,
    required this.onStatusChange,
    required this.onViewAll,
  });

  final OwnerDashboardState state;
  final VoidCallback onRetry;
  final void Function(String, OrderStatus) onStatusChange;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: onRetry,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: CustomScrollView(
        slivers: [
          // Stats Section: padding [16,28], gap 12
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsSectionHeader(),
                  const SizedBox(height: 12),
                  _StatusCountCards(
                    receivedCount: state.receivedCount,
                    inProgressCount: state.inProgressCount,
                    completedCount: state.completedCount,
                  ),
                ],
              ),
            ),
          ),
          // Recent Header: padding [24,28,8,28]
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
            sliver: SliverToBoxAdapter(
              child: _RecentHeader(onViewAll: onViewAll),
            ),
          ),
          // Order Cards: padding [0,28], gap 10
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (state.recentOrders.isEmpty)
                  const _EmptyOrdersView()
                else
                  ...state.recentOrders.indexed.map(
                    (entry) {
                      final (idx, order) = entry;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              idx < state.recentOrders.length - 1
                                  ? 10
                                  : 0,
                        ),
                        child: _OrderCard(
                          order: order,
                          memberName:
                              state.memberNames[order.memberId] ??
                                  '회원',
                          onStatusChange: (newStatus) {
                            onStatusChange(order.id, newStatus);
                          },
                        ),
                      );
                    },
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      '오늘의 작업 현황',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
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
            numberColor: AppTheme.receivedForeground,
            labelColor: AppTheme.receivedText,
            bgColor: AppTheme.receivedBackground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountCard(
            label: '작업중',
            count: inProgressCount,
            numberColor: AppTheme.inProgressForeground,
            labelColor: AppTheme.inProgressText,
            bgColor: AppTheme.inProgressBackground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountCard(
            label: '완료',
            count: completedCount,
            numberColor: AppTheme.completedForeground,
            labelColor: AppTheme.completedText,
            bgColor: AppTheme.completedBackground,
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
    required this.numberColor,
    required this.labelColor,
    required this.bgColor,
  });

  final String label;
  final int count;
  final Color numberColor;
  final Color labelColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: numberColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentHeader extends StatelessWidget {
  const _RecentHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '최근 작업',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            '전체보기',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          SizedBox(height: 12),
          Text(
            '아직 접수된 작업이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '\'+\' 버튼으로 새 작업을 접수하세요',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.memberName,
    required this.onStatusChange,
  });

  final GutOrder order;
  final String memberName;
  final void Function(OrderStatus) onStatusChange;

  Color get _accentColor => switch (order.status) {
        OrderStatus.received =>
          AppTheme.receivedForeground,
        OrderStatus.inProgress =>
          AppTheme.inProgressForeground,
        OrderStatus.completed =>
          AppTheme.completedForeground,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: _accentColor,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                memberName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              StatusBadge(
                status: order.status,
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          OrderTimelineRow(order: order),
          if (order.status != OrderStatus.completed) ...[
            const SizedBox(height: 8),
            _ActionButton(
              status: order.status,
              onPressed: () {
                final next = order.status == OrderStatus.received
                    ? OrderStatus.inProgress
                    : OrderStatus.completed;
                onStatusChange(next);
              },
            ),
          ],
        ],
      ),
    );
  }

}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.status,
    required this.onPressed,
  });

  final OrderStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (status) {
      OrderStatus.received => ('작업 시작', AppTheme.inProgressForeground),
      OrderStatus.inProgress => (
        '작업 완료',
        AppTheme.primaryCta,
      ),
      _ => ('', Colors.transparent),
    };

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
