import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/screens/customer/home/customer_home_notifier.dart';
import 'package:badminton_app/screens/customer/home/customer_home_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/notification_bell.dart';
import 'package:badminton_app/widgets/order_timeline_row.dart';
import 'package:badminton_app/widgets/skeleton_shimmer.dart';
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
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 8),
            const Text('거트알림'),
          ],
        ),
        actions: [
          NotificationBell(
            onPressed: () =>
                context.push('/customer/notifications'),
          ),
        ],
      ),
      body: CourtBackground(
        child: _buildBody(context, ref, state),
      ),
      bottomNavigationBar: const CustomerBottomNav(
        currentIndex: 0,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    CustomerHomeState state,
  ) {
    if (state.isLoading) {
      return const _ShimmerLoading();
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
      return _EmptyBody(
        onRefresh: () => ref
            .read(customerHomeNotifierProvider.notifier)
            .refresh(),
      );
    }

    return _OrderListBody(
      state: state,
      onRefresh: () => ref
          .read(customerHomeNotifierProvider.notifier)
          .refresh(),
    );
  }
}

/// 빈 상태 — 스펙 섹션 3.6.
class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: onRefresh,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_tennis,
                    size: 120,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '아직 진행 중인 작업이 없습니다',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '주변 샵을 검색해 거트를 맡겨보세요',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textTertiary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push('/customer/shop-search'),
                      child: const Text('주변 샵 검색하기'),
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

/// 주문 목록 본문 — 요약 카드 + 내 작업 섹션.
class _OrderListBody extends StatelessWidget {
  const _OrderListBody({
    required this.state,
    required this.onRefresh,
  });

  final CustomerHomeState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final receivedCount = state.activeOrders
        .where((o) => o.status == OrderStatus.received)
        .length;
    final inProgressCount = state.activeOrders
        .where((o) => o.status == OrderStatus.inProgress)
        .length;
    final showSummary = receivedCount + inProgressCount > 0;

    return RefreshIndicator(
      color: AppTheme.accent,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        itemCount: state.activeOrders.length +
            (showSummary ? 2 : 1), // summary + title + cards
        itemBuilder: (context, index) {
          var offset = 0;

          // 요약 카드
          if (showSummary && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _SummaryCard(
                receivedCount: receivedCount,
                inProgressCount: inProgressCount,
              ),
            );
          }
          if (showSummary) offset = 1;

          // "내 작업" 섹션 타이틀
          if (index == offset) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '내 작업',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
            );
          }

          // 작업 카드
          final orderIndex = index - offset - 1;
          final order = state.activeOrders[orderIndex];
          final shopName =
              state.shopNames[order.shopId] ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OrderCard(
              order: order,
              shopName: shopName,
              onTap: () =>
                  context.push('/customer/order/${order.id}'),
            ),
          );
        },
      ),
    );
  }
}

/// 진행 중 요약 카드 — Pencil Summary Wrapper.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.receivedCount,
    required this.inProgressCount,
  });

  final int receivedCount;
  final int inProgressCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.receivedForeground,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '접수 $receivedCount건',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onCardPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.inProgressForeground,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '작업중 $inProgressCount건',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onCardPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 작업 카드 — 스펙 섹션 3.3.
///
/// 세로 레이아웃: 상태뱃지 → 샵이름 → 접수시간 → 메모(선택).
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.shopName,
    required this.onTap,
  });

  final GutOrder order;
  final String shopName;
  final VoidCallback onTap;

  Color get _accentColor => switch (order.status) {
        OrderStatus.received => AppTheme.receivedForeground,
        OrderStatus.inProgress =>
          AppTheme.inProgressForeground,
        OrderStatus.completed =>
          AppTheme.completedForeground,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: _accentColor,
            width: 3,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                status: order.status,
                showDot: true,
              ),
              const SizedBox(height: 8),
              Text(
                shopName,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.onCardSecondary),
              ),
              const SizedBox(height: 8),
              OrderTimelineRow(order: order),
              if (order.memo != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.notes,
                      size: 16,
                      color: AppTheme.onCardTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.memo!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppTheme.onCardTertiary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (order.status == OrderStatus.completed) ...[
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.directions,
                    size: 24,
                    color: AppTheme.accent,
                    semanticLabel: '길찾기',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 로딩 시 shimmer 카드 3개를 보여주는 위젯.
class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppTheme.cardBorder,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    SkeletonShimmer(
                      width: 60,
                      height: 24,
                      borderRadius: 12,
                    ),
                    SizedBox(height: 8),
                    SkeletonShimmer(
                      width: 120,
                      height: 16,
                    ),
                    SizedBox(height: 8),
                    SkeletonShimmer(
                      width: 80,
                      height: 14,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 읽지 않은 알림 수를 뱃지로 표시하는 알림 아이콘.
