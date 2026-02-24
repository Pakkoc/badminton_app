import 'package:badminton_app/models/shop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_settings_state.freezed.dart';

@freezed
class ShopSettingsState with _$ShopSettingsState {
  const factory ShopSettingsState({
    Shop? shop,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _ShopSettingsState;
}
