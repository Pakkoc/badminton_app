import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_state.dart';
import 'package:badminton_app/services/address_search_service.dart';
import 'package:badminton_app/services/geocoding_service.dart';
import 'package:flutter/widgets.dart';
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
        notifyShop: user?.notifyShop ?? true,
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

  /// 주소 검색 바텀시트를 열고 결과를 state에 반영한다.
  Future<void> searchAddress(BuildContext context) async {
    const addressService = AddressSearchService();
    final address = await addressService.searchAddress(context);

    if (address == null || address.isEmpty) return;
    if (state.shop == null) return;

    state = state.copyWith(
      shop: state.shop!.copyWith(address: address),
    );

    final geocoding = ref.read(geocodingServiceProvider);
    final result = await geocoding.geocode(address);

    if (result != null && state.shop != null) {
      state = state.copyWith(
        shop: state.shop!.copyWith(
          latitude: result.latitude,
          longitude: result.longitude,
        ),
      );
    }
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

  /// 가게 알림 토글을 변경한다. 즉시 서버에 저장한다.
  Future<void> toggleNotifyShop(bool value) async {
    final prev = state.notifyShop;
    state = state.copyWith(notifyShop: value);
    try {
      final userId =
          ref.read(supabaseProvider).auth.currentUser?.id;
      if (userId == null) return;
      await ref
          .read(userRepositoryProvider)
          .updateNotifyShop(userId, value: value);
    } catch (_) {
      // 실패 시 롤백
      state = state.copyWith(notifyShop: prev);
    }
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
        'latitude': shop.latitude,
        'longitude': shop.longitude,
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
