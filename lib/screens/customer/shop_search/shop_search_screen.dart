import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_notifier.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShopSearchScreen extends ConsumerWidget {
  const ShopSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopSearchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '주변 샵',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _ViewModeToggle(
              viewMode: state.viewMode,
              onChanged: (mode) => ref
                  .read(shopSearchNotifierProvider.notifier)
                  .toggleViewMode(mode),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: AppTheme.border,
          ),
        ),
      ),
      body: _buildBody(context, ref, state),
      bottomNavigationBar: const CustomerBottomNav(
        currentIndex: 1,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ShopSearchState state,
  ) {
    if (!state.hasLocationPermission) {
      return const _LocationPermissionView();
    }

    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref
            .read(shopSearchNotifierProvider.notifier)
            .loadNearbyShops(),
      );
    }

    if (state.shops.isEmpty) {
      return const _EmptyView();
    }

    if (state.viewMode == ShopSearchViewMode.list) {
      return _ShopListView(
        shops: state.shops,
        orderCounts: state.orderCounts,
      );
    }

    // 지도 뷰: NaverMap + 하단 시트
    return _MapView(
      shops: state.shops,
      orderCounts: state.orderCounts,
      selectedShop: state.selectedShop,
    );
  }
}

/// 뷰 전환 토글 — 스펙 3.1.
class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.viewMode,
    required this.onChanged,
  });

  final ShopSearchViewMode viewMode;
  final ValueChanged<ShopSearchViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleSegment(
            label: '지도',
            isActive: viewMode == ShopSearchViewMode.map,
            onTap: () =>
                onChanged(ShopSearchViewMode.map),
          ),
          _ToggleSegment(
            label: '리스트',
            isActive: viewMode == ShopSearchViewMode.list,
            onTap: () =>
                onChanged(ShopSearchViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.courtGreen
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(
                color: isActive
                    ? Colors.white
                    : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

/// 위치 권한 미허용 상태 — 스펙 3.8.
class _LocationPermissionView extends StatelessWidget {
  const _LocationPermissionView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_off,
            size: 48,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            '위치 권한이 필요합니다',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '주변 샵을 찾으려면 위치 권한을 허용해 주세요',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textTertiary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () {
                // 시스템 설정으로 이동
              },
              child: const Text('설정으로 이동'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 빈 상태 — 스펙 3.6.
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront,
            size: 120,
            color: Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 24),
          Text(
            '주변에 등록된 샵이 없습니다',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 지역을 탐색해 보세요',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}

/// 리스트 뷰 — 스펙 리스트 뷰 레이아웃.
class _ShopListView extends StatelessWidget {
  const _ShopListView({
    required this.shops,
    required this.orderCounts,
  });

  final List<Shop> shops;
  final Map<String, ShopOrderCounts> orderCounts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shops.length,
      itemBuilder: (context, index) {
        final shop = shops[index];
        final counts = orderCounts[shop.id] ??
            const ShopOrderCounts();
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < shops.length - 1 ? 12 : 0,
          ),
          child: _ShopCard(
            shop: shop,
            counts: counts,
            onTap: () => context
                .push('/customer/shop/${shop.id}'),
          ),
        );
      },
    );
  }
}

/// 샵 카드 — 스펙 3.4.
class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.shop,
    required this.counts,
    required this.onTap,
  });

  final Shop shop;
  final ShopOrderCounts counts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shop.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  _OrderCountBadge(
                    label:
                        '접수 ${counts.receivedCount}건',
                    color: AppTheme.receivedForeground,
                    backgroundColor:
                        AppTheme.receivedBackground,
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '·',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  _OrderCountBadge(
                    label:
                        '작업중 ${counts.inProgressCount}건',
                    color: AppTheme.inProgressForeground,
                    backgroundColor:
                        AppTheme.inProgressBackground,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 작업 현황 뱃지 — 스펙 3.4.
class _OrderCountBadge extends StatelessWidget {
  const _OrderCountBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

/// 지도 뷰 — 스펙 3.2.
/// NaverMap은 네이티브 위젯이므로 위젯 테스트에서 직접
/// 렌더링할 수 없다. 지도 통합은 별도 통합 테스트에서 검증.
class _MapView extends StatelessWidget {
  const _MapView({
    required this.shops,
    required this.orderCounts,
    this.selectedShop,
  });

  final List<Shop> shops;
  final Map<String, ShopOrderCounts> orderCounts;
  final Shop? selectedShop;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // NaverMap 영역 (플레이스홀더)
        Container(
          color: AppTheme.surfaceVariant,
          child: const Center(
            child: Text('지도 영역'),
          ),
        ),
        // 현재 위치 FAB
        Positioned(
          right: 16,
          bottom: selectedShop != null ? 180 : 16,
          child: FloatingActionButton.small(
            heroTag: 'myLocation',
            onPressed: () {
              // 현재 위치로 이동
            },
            backgroundColor: Colors.white,
            elevation: 4,
            child: const Icon(
              Icons.my_location,
              color: AppTheme.courtGreen,
              size: 24,
            ),
          ),
        ),
        // 하단 시트 (마커 선택 시)
        if (selectedShop != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomSheetCard(
              shop: selectedShop!,
              counts: orderCounts[selectedShop!.id] ??
                  const ShopOrderCounts(),
            ),
          ),
      ],
    );
  }
}

/// 하단 시트 카드 — 스펙 3.3.
class _BottomSheetCard extends StatelessWidget {
  const _BottomSheetCard({
    required this.shop,
    required this.counts,
  });

  final Shop shop;
  final ShopOrderCounts counts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _ShopCard(
              shop: shop,
              counts: counts,
              onTap: () => context
                  .push('/customer/shop/${shop.id}'),
            ),
          ),
        ],
      ),
    );
  }
}
