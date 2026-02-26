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
    // shopId가 없으면 currentOwnerShopProvider에서 가져옴
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
    // shopId가 없는 경우 shop 로딩을 감시
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
                  .read(
                      orderManageNotifierProvider.notifier)
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
        return _OrderManageCard(
          order: order,
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
            label: '전체 ($totalCount)',
            isSelected: selectedFilter == null,
            onTap: () => onFilterChanged(null),
          ),
          const SizedBox(width: 8),
          ...OrderStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label:
                    '${status.label} ${countByStatus[status] ?? 0}',
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
              ? const Color(0xFF16A34A)
              : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF16A34A)
                : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

class _OrderManageCard extends StatelessWidget {
  const _OrderManageCard({
    required this.order,
    required this.onStatusChange,
    this.onDelete,
  });

  final GutOrder order;
  final void Function(OrderStatus) onStatusChange;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final Widget card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '회원 ID: ${order.memberId}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            if (order.memo != null) ...[
              const SizedBox(height: 8),
              Text(
                order.memo!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            _StatusChangeButtons(
              currentStatus: order.status,
              onStatusChange: onStatusChange,
            ),
          ],
        ),
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: Key(order.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          color: Colors.red,
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
}

class _StatusChangeButtons extends StatelessWidget {
  const _StatusChangeButtons({
    required this.currentStatus,
    required this.onStatusChange,
  });

  final OrderStatus currentStatus;
  final void Function(OrderStatus) onStatusChange;

  @override
  Widget build(BuildContext context) {
    return switch (currentStatus) {
      OrderStatus.received => TextButton(
          onPressed: () =>
              onStatusChange(OrderStatus.inProgress),
          child: const Text('작업 시작'),
        ),
      OrderStatus.inProgress => TextButton(
          onPressed: () =>
              onStatusChange(OrderStatus.completed),
          child: const Text('작업 완료'),
        ),
      OrderStatus.completed => const SizedBox.shrink(),
    };
  }
}
