import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop.freezed.dart';
part 'shop.g.dart';

@freezed
class Shop with _$Shop {
  const factory Shop({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String phone,
    String? description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Shop;

  factory Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);
}
