import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/admin/shop_request_detail/shop_request_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopRequestDetailNotifierProvider =
    StateNotifierProvider<ShopRequestDetailNotifier,
        ShopRequestDetailState>(
  (ref) => ShopRequestDetailNotifier(
    shopRepository: ref.watch(shopRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  ),
);

class ShopRequestDetailNotifier
    extends StateNotifier<ShopRequestDetailState> {
  final ShopRepository _shopRepository;
  final UserRepository _userRepository;

  ShopRequestDetailNotifier({
    required ShopRepository shopRepository,
    required UserRepository userRepository,
  })  : _shopRepository = shopRepository,
        _userRepository = userRepository,
        super(const ShopRequestDetailState());

  Future<void> loadDetail(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shop = await _shopRepository.getById(shopId);
      if (shop == null) {
        state = state.copyWith(
          isLoading: false,
          error: '샵 정보를 찾을 수 없습니다',
        );
        return;
      }

      final owner =
          await _userRepository.getById(shop.ownerId);

      state = state.copyWith(
        isLoading: false,
        shop: shop,
        owner: owner,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    }
  }

  Future<bool> approve() async {
    final shop = state.shop;
    if (shop == null) return false;

    state = state.copyWith(isProcessing: true);
    try {
      await _shopRepository.approve(shop.id);
      state = state.copyWith(isProcessing: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.userMessage,
      );
      return false;
    }
  }

  Future<bool> reject(String reason) async {
    final shop = state.shop;
    if (shop == null) return false;

    state = state.copyWith(isProcessing: true);
    try {
      await _shopRepository.reject(shop.id, reason);
      state = state.copyWith(isProcessing: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.userMessage,
      );
      return false;
    }
  }
}
