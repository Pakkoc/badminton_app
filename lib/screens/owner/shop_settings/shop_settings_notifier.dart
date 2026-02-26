import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
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
      final userId =
          ref.read(supabaseProvider).auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '로그인이 필요합니다',
        );
        return;
      }

      final shopRepository = ref.read(shopRepositoryProvider);
      final userRepository = ref.read(userRepositoryProvider);

      final shop = await shopRepository.getByOwner(userId);
      final user = await userRepository.getById(userId);

      state = ShopSettingsState(
        shop: shop,
        ownerName: user?.name ?? '',
        ownerPhone: user?.phone ?? '',
      );
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

  void updateOwnerName(String name) {
    state = state.copyWith(ownerName: name);
  }

  void updateOwnerPhone(String phone) {
    state = state.copyWith(ownerPhone: phone);
  }

  Future<bool> submit() async {
    if (state.shop == null) return false;

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
    );
    try {
      final userId =
          ref.read(supabaseProvider).auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: '로그인이 필요합니다',
        );
        return false;
      }

      final shopRepository = ref.read(shopRepositoryProvider);
      final userRepository = ref.read(userRepositoryProvider);
      final shop = state.shop!;

      final shopData = <String, dynamic>{
        'name': shop.name,
        'address': shop.address,
        'phone': shop.phone,
        'description': shop.description,
      };
      final userData = <String, dynamic>{
        'name': state.ownerName,
        'phone': state.ownerPhone,
      };

      final Shop updatedShop =
          await shopRepository.update(shop.id, shopData);
      final User updatedUser =
          await userRepository.update(userId, userData);

      state = state.copyWith(
        shop: updatedShop,
        ownerName: updatedUser.name,
        ownerPhone: updatedUser.phone,
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
