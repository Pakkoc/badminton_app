import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/admin/shop_requests/shop_requests_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopRequestsNotifierProvider = StateNotifierProvider<
    ShopRequestsNotifier, ShopRequestsState>(
  (ref) => ShopRequestsNotifier(
    shopRepository: ref.watch(shopRepositoryProvider),
  ),
);

class ShopRequestsNotifier
    extends StateNotifier<ShopRequestsState> {
  final ShopRepository _shopRepository;

  ShopRequestsNotifier({
    required ShopRepository shopRepository,
  })  : _shopRepository = shopRepository,
        super(const ShopRequestsState());

  Future<void> loadRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final requests =
          await _shopRepository.getPendingShops();
      state = state.copyWith(
        isLoading: false,
        requests: requests,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    }
  }
}
