import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/utils/formatters.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_state.dart';
import 'package:badminton_app/services/address_search_service.dart';
import 'package:badminton_app/services/geocoding_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopSignupNotifierProvider =
    NotifierProvider<ShopSignupNotifier, ShopSignupState>(
  ShopSignupNotifier.new,
);

class ShopSignupNotifier extends Notifier<ShopSignupState> {
  @override
  ShopSignupState build() => const ShopSignupState();

  void updateShopName(String shopName) {
    state = state.copyWith(shopName: shopName);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateBusinessNumber(String value) {
    state = state.copyWith(businessNumber: value);
  }

  void setLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng);
  }

  /// 기존 rejected 샵 정보를 불러와 폼에 채운다.
  Future<void> loadExistingShop() async {
    final shop = await ref.read(myShopProvider.future);
    if (shop == null ||
        shop.status != ShopStatus.rejected) {
      return;
    }

    state = state.copyWith(
      shopName: shop.name,
      address: shop.address,
      latitude: shop.latitude,
      longitude: shop.longitude,
      phone: shop.phone,
      description: shop.description ?? '',
      businessNumber: shop.businessNumber != null
          ? Formatters.businessNumber(shop.businessNumber!)
          : '',
      isReapply: true,
      existingShopId: shop.id,
    );
  }

  /// 주소 검색 바텀시트를 열고 결과를 state에 반영한다.
  ///
  /// 주소 선택 후 Geocoding API로 좌표를 자동 변환한다.
  Future<void> searchAddress(BuildContext context) async {
    const addressService = AddressSearchService();
    final address =
        await addressService.searchAddress(context);

    if (address == null || address.isEmpty) return;

    state = state.copyWith(address: address);

    await _geocodeAddress(address);
  }

  /// 주소를 좌표로 변환하여 state에 반영한다.
  Future<void> _geocodeAddress(String address) async {
    final geocoding = ref.read(geocodingServiceProvider);
    final result = await geocoding.geocode(address);

    if (result != null) {
      state = state.copyWith(
        latitude: result.latitude,
        longitude: result.longitude,
      );
    }
  }

  bool get isValid =>
      Validators.shopName(state.shopName) == null &&
      state.address.isNotEmpty &&
      Validators.phone(state.phone) == null &&
      Validators.businessNumber(
            state.businessNumber,
          ) ==
          null;

  Future<String?> submit() async {
    if (!isValid) return null;

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
    );

    try {
      final userId =
          ref.read(supabaseProvider).auth.currentUser!.id;
      final rawBizNum = Formatters.businessNumberRaw(
        state.businessNumber,
      );
      final shop = Shop(
        id: state.existingShopId ?? '',
        ownerId: userId,
        name: state.shopName,
        address: state.address,
        latitude: state.latitude,
        longitude: state.longitude,
        phone: state.phone,
        description:
            state.description.isEmpty
                ? null
                : state.description,
        businessNumber: rawBizNum,
        createdAt: DateTime.now(),
      );

      if (state.isReapply && state.existingShopId != null) {
        await ref
            .read(shopRepositoryProvider)
            .update(state.existingShopId!, {
          'name': shop.name,
          'address': shop.address,
          'latitude': shop.latitude,
          'longitude': shop.longitude,
          'phone': shop.phone,
          'description': shop.description,
          'business_number': rawBizNum,
          'status': 'pending',
        });
      } else {
        await ref.read(shopRepositoryProvider).create(shop);
      }

      ref.invalidate(myShopProvider);
      ref.invalidate(shopStatusProvider);

      return 'submitted';
    } on AppException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.userMessage,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '알 수 없는 오류가 발생했습니다',
      );
      return null;
    }
  }
}
