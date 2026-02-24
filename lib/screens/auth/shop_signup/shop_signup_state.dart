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
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _ShopSignupState;
}
