import 'package:badminton_app/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    required String name,
    @JsonKey(
      fromJson: InventoryCategory.fromJson,
      toJson: _inventoryCategoryToJson,
    )
    @Default(InventoryCategory.other)
    InventoryCategory category,
    @Default(0) int quantity,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}

String _inventoryCategoryToJson(InventoryCategory category) =>
    category.toJson();
