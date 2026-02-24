import 'package:badminton_app/models/shop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_search_state.freezed.dart';

@freezed
class ShopSearchState with _$ShopSearchState {
  const factory ShopSearchState({
    @Default([]) List<Shop> shops,
    @Default(false) bool isLoading,
    String? error,
    @Default('') String searchQuery,
  }) = _ShopSearchState;
}
