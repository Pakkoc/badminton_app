import 'package:badminton_app/models/shop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_requests_state.freezed.dart';

@freezed
class ShopRequestsState with _$ShopRequestsState {
  const factory ShopRequestsState({
    @Default([]) List<Shop> requests,
    @Default(true) bool isLoading,
    String? error,
  }) = _ShopRequestsState;
}
