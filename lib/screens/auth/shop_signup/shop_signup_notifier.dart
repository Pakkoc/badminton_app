import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/utils/validators.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_state.dart';
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

  void setLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng);
  }

  bool get isValid =>
      Validators.shopName(state.shopName) == null &&
      state.address.isNotEmpty &&
      Validators.phone(state.phone) == null &&
      state.latitude != 0.0 &&
      state.longitude != 0.0;

  Future<String?> submit() async {
    if (!isValid) return null;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final userId =
          ref.read(supabaseProvider).auth.currentUser!.id;
      final shop = Shop(
        id: '',
        ownerId: userId,
        name: state.shopName,
        address: state.address,
        latitude: state.latitude,
        longitude: state.longitude,
        phone: state.phone,
        description:
            state.description.isEmpty ? null : state.description,
        createdAt: DateTime.now(),
      );

      await ref.read(shopRepositoryProvider).create(shop);

      return '/owner/dashboard';
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
