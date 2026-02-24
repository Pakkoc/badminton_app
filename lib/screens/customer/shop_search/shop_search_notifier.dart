import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/customer/shop_search/shop_search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopSearchNotifierProvider =
    NotifierProvider<ShopSearchNotifier, ShopSearchState>(
  ShopSearchNotifier.new,
);

class ShopSearchNotifier extends Notifier<ShopSearchState> {
  @override
  ShopSearchState build() => const ShopSearchState();

  Future<void> searchShops(String query) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: query,
    );
    try {
      final shopRepository = ref.read(shopRepositoryProvider);
      final shops = await shopRepository.searchByName(query);
      state = state.copyWith(
        shops: shops,
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
        error: '샵 검색에 실패했습니다',
      );
    }
  }

  Future<void> loadNearbyShops() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shopRepository = ref.read(shopRepositoryProvider);
      final shops = await shopRepository.searchByBounds(
        swLat: 33.0,
        swLng: 124.0,
        neLat: 39.0,
        neLng: 132.0,
      );
      state = state.copyWith(
        shops: shops,
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
}
