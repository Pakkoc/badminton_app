import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopSettingsNotifierProvider =
    NotifierProvider<ShopSettingsNotifier, ShopSettingsState>(
  ShopSettingsNotifier.new,
);

class ShopSettingsNotifier extends Notifier<ShopSettingsState> {
  @override
  ShopSettingsState build() {
    Future.microtask(loadShop);
    return const ShopSettingsState(isLoading: true);
  }

  Future<void> loadShop() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '로그인이 필요합니다',
        );
        return;
      }

      final shopRepository = ref.read(shopRepositoryProvider);
      final shop = await shopRepository.getByOwner(user.id);
      state = ShopSettingsState(shop: shop);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '샵 정보를 불러올 수 없습니다',
      );
    }
  }

  void updateShopName(String name) {
    if (state.shop == null) return;
    state = state.copyWith(
      shop: state.shop!.copyWith(name: name),
    );
  }

  void updateAddress(String address) {
    if (state.shop == null) return;
    state = state.copyWith(
      shop: state.shop!.copyWith(address: address),
    );
  }

  void updatePhone(String phone) {
    if (state.shop == null) return;
    state = state.copyWith(
      shop: state.shop!.copyWith(phone: phone),
    );
  }

  void updateDescription(String description) {
    if (state.shop == null) return;
    state = state.copyWith(
      shop: state.shop!.copyWith(description: description),
    );
  }

  Future<bool> submit() async {
    if (state.shop == null) return false;

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
    );
    try {
      final shopRepository = ref.read(shopRepositoryProvider);
      final shop = state.shop!;
      final data = <String, dynamic>{
        'name': shop.name,
        'address': shop.address,
        'phone': shop.phone,
        'description': shop.description,
      };

      final updated =
          await shopRepository.update(shop.id, data);
      state = state.copyWith(
        shop: updated,
        isSubmitting: false,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.userMessage,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '샵 설정 저장에 실패했습니다',
      );
      return false;
    }
  }
}
