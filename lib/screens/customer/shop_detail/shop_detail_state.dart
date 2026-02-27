import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_detail_state.freezed.dart';

@freezed
class ShopDetailState with _$ShopDetailState {
  const factory ShopDetailState({
    Shop? shop,
    @Default(false) bool isMember,
    @Default(false) bool isLoading,
    @Default(false) bool isRegistering,
    @Default([]) List<Post> noticePosts,
    @Default([]) List<Post> eventPosts,
    @Default([]) List<InventoryItem> inventoryItems,
    @Default(0) int receivedCount,
    @Default(0) int inProgressCount,
    String? error,
  }) = _ShopDetailState;
}
