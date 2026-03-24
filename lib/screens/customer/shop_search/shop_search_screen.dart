import 'package:badminton_app/app/theme.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/location_provider.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_notifier.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:badminton_app/widgets/court_background.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
import 'package:badminton_app/widgets/error_view.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 테스트 환경에서 NaverMap 렌더링을 건너뛰기 위한 플래그.
@visibleForTesting
// ignore: library_private_types_in_public_api
bool shopSearchUsePlaceholder = false;

class ShopSearchScreen extends ConsumerStatefulWidget {
  const ShopSearchScreen({super.key});

  @override
  ConsumerState<ShopSearchScreen> createState() =>
      _ShopSearchScreenState();
}

class _ShopSearchScreenState
    extends ConsumerState<ShopSearchScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref
          .read(shopSearchNotifierProvider.notifier)
          .checkAndRequestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopSearchNotifierProvider);
    final isMap =
        state.viewMode == ShopSearchViewMode.map;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '주변 샵',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
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
      ),
      // 위치 권한 미허용 시 안내 화면, 그 외에는 지도+리스트.
      body: CourtBackground(
        child: !state.hasLocationPermission
          ? const _LocationPermissionView()
          : Stack(
              children: [
                // NaverMap은 항상 렌더링하여 리빌드를 방지.
                const _MapView(),
                // 리스트 모드일 때 지도 위에 오버레이.
                if (!isMap)
                  _buildListBody(context, state),
              ],
            ),
      ),
      bottomNavigationBar: const CustomerBottomNav(
        currentIndex: 1,
      ),
    );
  }

  Widget _buildListBody(
    BuildContext context,
    ShopSearchState state,
  ) {
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
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const _EmptyView(),
      );
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _ShopListView(
        shops: state.shops,
        orderCounts: state.orderCounts,
      ),
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
        borderRadius: BorderRadius.circular(14),
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
              ? AppTheme.accent
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(
                color: isActive
                    ? Colors.white
                    : AppTheme.onCardSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

/// 위치 권한 미허용 상태 — 스펙 3.8.
class _LocationPermissionView extends ConsumerWidget {
  const _LocationPermissionView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onPressed: () => ref
                  .read(shopSearchNotifierProvider.notifier)
                  .checkAndRequestPermission(),
              child: const Text('권한 허용하기'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              final locationService =
                  ref.read(locationServiceProvider);
              await locationService.openSettings();
            },
            child: const Text('설정으로 이동'),
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
            color: AppTheme.border,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
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
      elevation: 0,
      color: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppTheme.cardBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
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
                            color: AppTheme.onCardPrimary,
                          ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: AppTheme.onCardTertiary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.onCardTertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      shop.address,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppTheme.onCardSecondary,
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
                        color: AppTheme.border,
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
///
/// const 생성자로 리빌드를 방지하고, 내부에서 직접
/// shopSearchNotifierProvider를 watch한다.
class _MapView extends ConsumerStatefulWidget {
  const _MapView();

  @override
  ConsumerState<_MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<_MapView> {
  NaverMapController? _mapController;
  List<Shop> _prevShops = const [];


  /// 한국 기본 위치 (서울).
  static const _defaultPosition = NLatLng(37.5665, 126.9780);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopSearchNotifierProvider);

    // 샵 목록이 변경되면 마커를 갱신한다.
    if (state.shops != _prevShops) {
      _prevShops = state.shops;
      // build 후 마커 갱신 (build 중 controller 호출 방지).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMarkers(state.shops);
      });
    }

    return Stack(
      children: [
        if (kIsWeb || shopSearchUsePlaceholder)
          Container(
            color: AppTheme.surfaceVariant,
            child: const Center(child: Text('지도 영역')),
          )
        else
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: _defaultPosition,
                zoom: 12,
              ),
              locationButtonEnable: true,
            ),
            onMapReady: _onMapReady,
            onCameraIdle: _onCameraIdle,
          ),
        // 하단 시트 (마커 선택 시)
        if (state.selectedShop != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomSheetCard(
              shop: state.selectedShop!,
              counts:
                  state.orderCounts[state.selectedShop!.id] ??
                      const ShopOrderCounts(),
            ),
          ),
      ],
    );
  }

  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    _updateMarkers(ref.read(shopSearchNotifierProvider).shops);
  }

  /// 카메라 이동 완료 시 영역 내 샵을 다시 로드한다.
  Future<void> _onCameraIdle() async {
    final controller = _mapController;
    if (controller == null) return;
    final bounds = await controller.getContentBounds();
    ref.read(shopSearchNotifierProvider.notifier).loadNearbyShops(
          swLat: bounds.southWest.latitude,
          swLng: bounds.southWest.longitude,
          neLat: bounds.northEast.latitude,
          neLng: bounds.northEast.longitude,
        );
  }

  void _updateMarkers(List<Shop> shops) {
    final controller = _mapController;
    if (controller == null) return;
    controller.clearOverlays();
    for (final shop in shops) {
      if (shop.latitude == null || shop.longitude == null) {
        continue;
      }
      final marker = NMarker(
        id: shop.id,
        position: NLatLng(shop.latitude!, shop.longitude!),
      );
      marker.setOnTapListener((_) {
        ref
            .read(shopSearchNotifierProvider.notifier)
            .selectShop(shop);
      });
      controller.addOverlay(marker);
    }
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
      decoration: BoxDecoration(
        color: AppTheme.dialogSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        border: Border.all(
          color: AppTheme.border,
          width: 0.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 16,
            offset: Offset(0, -4),
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
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
