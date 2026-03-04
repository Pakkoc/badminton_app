import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_request_detail_state.freezed.dart';

@freezed
class ShopRequestDetailState with _$ShopRequestDetailState {
  const factory ShopRequestDetailState({
    Shop? shop,
    User? owner,
    @Default(true) bool isLoading,
    @Default(false) bool isProcessing,
    String? error,
  }) = _ShopRequestDetailState;
}
