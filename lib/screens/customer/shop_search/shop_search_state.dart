import 'package:badminton_app/models/shop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_search_state.freezed.dart';

/// 뷰 모드: 지도 또는 리스트.
enum ShopSearchViewMode { map, list }

/// 샵별 작업 현황.
class ShopOrderCounts {
  final int receivedCount;
  final int inProgressCount;

  const ShopOrderCounts({
    this.receivedCount = 0,
    this.inProgressCount = 0,
  });
}

@freezed
class ShopSearchState with _$ShopSearchState {
  const factory ShopSearchState({
    @Default([]) List<Shop> shops,
    @Default(false) bool isLoading,
    String? error,
    @Default(ShopSearchViewMode.map)
    ShopSearchViewMode viewMode,
    Shop? selectedShop,
    @Default({})
    Map<String, ShopOrderCounts> orderCounts,
    @Default(true) bool hasLocationPermission,
  }) = _ShopSearchState;
}
