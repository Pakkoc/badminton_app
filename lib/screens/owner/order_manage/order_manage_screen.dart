import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/providers/owner_shop_provider.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_notifier.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_state.dart';
import 'package:badminton_app/widgets/confirm_dialog.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:badminton_app/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderManageScreen extends ConsumerStatefulWidget {
  const OrderManageScreen({
    super.key,
    this.shopId,
  });

  final String? shopId;

  @override
  ConsumerState<OrderManageScreen> createState() =>
      _OrderManageScreenState();
}

class _OrderManageScreenState
    extends ConsumerState<OrderManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    final shopId = widget.shopId;
    if (shopId != null && shopId.isNotEmpty) {
      ref
          .read(orderManageNotifierProvider.notifier)
          .loadOrders(shopId);
      return;
    }
    final shopAsync = ref.read(currentOwnerShopProvider);
    shopAsync.whenData((shop) {
      if (shop != null) {
        ref
            .read(orderManageNotifierProvider.notifier)
            .loadOrders(shop.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shopId == null || widget.shopId!.isEmpty) {
      ref.listen(currentOwnerShopProvider, (prev, next) {
        next.whenData((shop) {
          if (shop != null) {
            ref
                .read(orderManageNotifierProvider.notifier)
                .loadOrders(shop.id);
          }
        });
      });
    }

    final state = ref.watch(orderManageNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('작업 관리')),
      body: Column(
        children: [
          _StatusFilterTabs(
            selectedFilter: state.selectedFilter,
            totalCount: state.orders.length,
            countByStatus: {
              for (final s in OrderStatus.values)
                s: state.orders
                    .where((o) => o.status == s)
                    .length,
            },
            onFilterChanged: (status) {
              ref
                  .read(orderManageNotifierProvider.notifier)
                  .filterByStatus(status);
            },
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(OrderManageState state) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: _loadOrders,
      );
    }

    final orders = state.filteredOrders;

    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        message: '작업이 없습니다',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final memberName =
            state.memberNames[order.memberId] ?? '회원';
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < orders.length - 1 ? 10 : 0,
          ),
          child: _OrderManageCard(
            order: order,
            memberName: memberName,
            onStatusChange: (newStatus) {
              ref
                  .read(orderManageNotifierProvider.notifier)
                  .changeStatus(order.id, newStatus);
            },
            onDelete: order.status == OrderStatus.received
                ? () {
                    showConfirmDialog(
                      context: context,
                      title: '작업 삭제',
                      content: '이 작업을 삭제하시겠습니까?',
                      onConfirm: () {
                        ref
                            .read(
                                orderManageNotifierProvider
                                    .notifier)
                            .deleteOrder(order.id);
                      },
                    );
                  }
                : null,
          ),
        );
      },
    );
  }
}

class _StatusFilterTabs extends StatelessWidget {
  const _StatusFilterTabs({
    required this.selectedFilter,
    required this.totalCount,
    required this.countByStatus,
    required this.onFilterChanged,
  });

  final OrderStatus? selectedFilter;
  final int totalCount;
  final Map<OrderStatus, int> countByStatus;
  final void Function(OrderStatus?) onFilterChanged;

  /// 접수됨 → 접수 (탭 라벨 축약)
  String _tabLabel(OrderStatus status) => switch (status) {
        OrderStatus.received => '접수',
        OrderStatus.inProgress => '작업중',
        OrderStatus.completed => '완료',
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          _FilterChip(
            label: '전체 $totalCount',
            isSelected: selectedFilter == null,
            onTap: () => onFilterChanged(null),
          ),
          const SizedBox(width: 8),
          ...OrderStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label:
                    '${_tabLabel(status)} '
                    '${countByStatus[status] ?? 0}',
                isSelected: selectedFilter == status,
                onTap: () => onFilterChanged(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _OrderManageCard extends StatelessWidget {
  const _OrderManageCard({
    required this.order,
    required this.memberName,
    required this.onStatusChange,
    this.onDelete,
  });

  final GutOrder order;
  final String memberName;
  final void Function(OrderStatus) onStatusChange;
  final VoidCallback? onDelete;

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
    final Widget card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: _accentColor,
            width: 4,
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
          Text(
            _formatTimeLabel(order.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
            ),
          ),
          if (order.status != OrderStatus.completed) ...[
            const SizedBox(height: 8),
            _ActionButton(
              status: order.status,
              onPressed: () {
                final next =
                    order.status == OrderStatus.received
                        ? OrderStatus.inProgress
                        : OrderStatus.completed;
                onStatusChange(next);
              },
            ),
          ],
        ],
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: Key(order.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        onDismissed: (_) => onDelete!(),
        child: card,
      );
    }

    return card;
  }

  String _formatTimeLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday =
        today.subtract(const Duration(days: 1));
    final dtDate = DateTime(dt.year, dt.month, dt.day);

    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');

    if (dtDate == today) {
      return '오늘 $h:$m 접수';
    } else if (dtDate == yesterday) {
      return '어제 $h:$m 접수';
    } else {
      return '${dt.month}/${dt.day} $h:$m 접수';
    }
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
      OrderStatus.received => (
        '작업 시작',
        AppTheme.inProgressForeground,
      ),
      OrderStatus.inProgress => (
        '작업 완료',
        AppTheme.primary,
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
