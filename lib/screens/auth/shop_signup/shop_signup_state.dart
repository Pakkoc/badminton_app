import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_signup_state.freezed.dart';

@freezed
class ShopSignupState with _$ShopSignupState {
  const factory ShopSignupState({
    @Default('') String shopName,
    @Default('') String address,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @Default('') String phone,
    @Default('') String description,
    @Default('') String businessNumber,
    @Default(false) bool isSubmitting,
    @Default(false) bool isReapply,
    String? existingShopId,
    String? errorMessage,
  }) = _ShopSignupState;
}
