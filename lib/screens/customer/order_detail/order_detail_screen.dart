import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_notifier.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(
        title: const Text('작업 상세'),
      ),
      body: CourtBackground(
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    OrderDetailState state,
  ) {
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref
            .read(
                orderDetailNotifierProvider(orderId).notifier)
            .loadOrder(orderId),
      );
    }

    final order = state.order;
    if (order == null) {
      return const LoadingIndicator();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LargeStatusBadge(status: order.status),
          const SizedBox(height: 24),
          _TimelineSection(
            createdAt: order.createdAt,
            inProgressAt: order.inProgressAt,
            completedAt: order.completedAt,
            currentStatus: order.status,
          ),
          if (order.memo != null &&
              order.memo!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _MemoSection(memo: order.memo!),
          ],
          if (state.shop != null) ...[
            const SizedBox(height: 24),
            _ShopInfoSection(shop: state.shop!),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// 상태 뱃지 (Large) — 스펙 섹션 3.2.
class _LargeStatusBadge extends StatelessWidget {
  const _LargeStatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, icon) = switch (status) {
      OrderStatus.received => (
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
        Icons.inventory_2,
      ),
      OrderStatus.inProgress => (
        AppTheme.inProgressBackground,
        const Color(0xFF1E40AF),
        Icons.build_circle,
      ),
      OrderStatus.completed => (
        AppTheme.completedBackground,
        AppTheme.completedText,
        Icons.check_circle,
      ),
    };

    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0x1Affffff),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF93C5FD),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: fgColor),
          const SizedBox(width: 12),
          Text(
            status.label,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
          ),
        ],
      ),
    );
  }
}

/// 진행 상태 타임라인 — 스펙 섹션 3.3.
class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.createdAt,
    this.inProgressAt,
    this.completedAt,
    required this.currentStatus,
  });

  final DateTime createdAt;
  final DateTime? inProgressAt;
  final DateTime? completedAt;
  final OrderStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '진행 상태',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TimelineNode(
                  label: '접수됨',
                  time: Formatters.dateTime(createdAt),
                  isActive: true,
                  color: const Color(0xFFF59E0B),
                  isLast: false,
                  nextActive: inProgressAt != null,
                ),
                _TimelineNode(
                  label: '작업중',
                  time: inProgressAt != null
                      ? Formatters.dateTime(inProgressAt!)
                      : '—',
                  isActive: inProgressAt != null,
                  color: AppTheme.inProgressForeground,
                  isLast: false,
                  nextActive: completedAt != null,
                ),
                _TimelineNode(
                  label: '완료',
                  time: completedAt != null
                      ? Formatters.dateTime(completedAt!)
                      : '—',
                  isActive: completedAt != null,
                  color: AppTheme.completedForeground,
                  isLast: true,
                  nextActive: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.label,
    required this.time,
    required this.isActive,
    required this.color,
    required this.isLast,
    required this.nextActive,
  });

  final String label;
  final String time;
  final bool isActive;
  final Color color;
  final bool isLast;
  final bool nextActive;

  static const _inactiveColor = Color(0xFFCBD5E1);

  @override
  Widget build(BuildContext context) {
    final nodeColor = isActive ? color : _inactiveColor;

    return Column(
      children: [
        Row(
          children: [
            Icon(
              isActive
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 24,
              color: nodeColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isActive
                          ? AppTheme.textPrimary
                          : _inactiveColor,
                    ),
              ),
            ),
            Text(
              time,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
            ),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 2,
                height: 32,
                color: nextActive ? color : _inactiveColor,
              ),
            ),
          ),
      ],
    );
  }
}

/// 작업 메모 — 스펙 섹션 3.4.
class _MemoSection extends StatelessWidget {
  const _MemoSection({required this.memo});

  final String memo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '작업 메모',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(
            memo,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}

/// 샵 정보 — 스펙 섹션 3.5.
class _ShopInfoSection extends StatelessWidget {
  const _ShopInfoSection({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '샵 정보',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push(
                    '/customer/shop/${shop.id}',
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        size: 20,
                        color: AppTheme.accent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shop.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent,
                              ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppTheme.textTertiary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        shop.address,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _launchPhone(shop.phone),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.call,
                        size: 20,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.phone(shop.phone),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _launchPhone(shop.phone),
                        icon: const Icon(Icons.call,
                            size: 20),
                        label: const Text('전화하기'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchMap(
                          shop.latitude,
                          shop.longitude,
                          shop.name,
                        ),
                        icon: const Icon(Icons.directions,
                            size: 20),
                        label: const Text('길찾기'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phone) async {
    final raw = Formatters.phoneRaw(phone);
    final uri = Uri.parse('tel:$raw');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMap(
    double lat,
    double lng,
    String name,
  ) async {
    final naver = Uri.parse(
      'nmap://route/public?dlat=$lat&dlng=$lng&dname=$name',
    );
    if (await canLaunchUrl(naver)) {
      await launchUrl(naver);
    } else {
      final web = Uri.parse(
        'https://map.naver.com/v5/directions/-/-/-/transit'
        '?c=$lng,$lat,15,0,0,0,dh',
      );
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }
}
