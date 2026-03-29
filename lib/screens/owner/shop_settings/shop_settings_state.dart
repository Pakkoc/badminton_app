import 'package:badminton_app/models/shop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_settings_state.freezed.dart';

@freezed
class ShopSettingsState with _$ShopSettingsState {
  const factory ShopSettingsState({
    Shop? shop,
    @Default('') String ownerName,
    @Default('') String ownerPhone,
    @Default(true) bool notifyShop,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    @Default(false) bool isEditing,
    /// 편집 취소 시 복원할 스냅샷
    Shop? originalShop,
    @Default('') String originalOwnerName,
    @Default('') String originalOwnerPhone,
    String? errorMessage,
  }) = _ShopSettingsState;
}
