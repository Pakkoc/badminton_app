import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/location_provider.dart';
import 'package:badminton_app/repositories/order_repository.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopSearchNotifierProvider =
    NotifierProvider<ShopSearchNotifier, ShopSearchState>(
  ShopSearchNotifier.new,
);

class ShopSearchNotifier extends Notifier<ShopSearchState> {
  @override
  ShopSearchState build() {
    Future.microtask(() => checkAndRequestPermission());
    return const ShopSearchState();
  }

  /// 위치 권한을 확인하고 필요시 요청한다.
  Future<void> checkAndRequestPermission() async {
    final locationService =
        ref.read(locationServiceProvider);

    final hasPermission =
        await locationService.checkPermission();
    if (hasPermission) {
      state = state.copyWith(
        hasLocationPermission: true,
      );
      await loadNearbyShops();
      return;
    }

    final granted =
        await locationService.requestPermission();
    state = state.copyWith(
      hasLocationPermission: granted,
    );
    if (granted) {
      await loadNearbyShops();
    }
  }

  /// 뷰 모드를 전환한다.
  void toggleViewMode(ShopSearchViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// 마커 선택/해제 (지도 뷰).
  void selectShop(Shop? shop) {
    state = state.copyWith(selectedShop: shop);
  }

  /// 지도 영역 내 주변 샵을 조회한다.
  Future<void> loadNearbyShops({
    double swLat = 33.0,
    double swLng = 124.0,
    double neLat = 39.0,
    double neLng = 132.0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shopRepo = ref.read(shopRepositoryProvider);
      final orderRepo = ref.read(orderRepositoryProvider);
      final shops = await shopRepo.searchByBounds(
        swLat: swLat,
        swLng: swLng,
        neLat: neLat,
        neLng: neLng,
      );

      // 각 샵의 주문 현황을 조회한다.
      final counts = <String, ShopOrderCounts>{};
      for (final shop in shops) {
        final orders = await orderRepo.getByShop(shop.id);
        final received = orders
            .where((o) => o.status == OrderStatus.received)
            .length;
        final inProgress = orders
            .where((o) => o.status == OrderStatus.inProgress)
            .length;
        counts[shop.id] = ShopOrderCounts(
          receivedCount: received,
          inProgressCount: inProgress,
        );
      }

      state = state.copyWith(
        shops: shops,
        orderCounts: counts,
        isLoading: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '주변 샵을 불러올 수 없습니다',
      );
    }
  }

  /// 위치 권한 상태를 업데이트한다.
  void setLocationPermission(bool granted) {
    state = state.copyWith(hasLocationPermission: granted);
  }
}
