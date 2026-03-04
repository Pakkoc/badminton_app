import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'shop.freezed.dart';
part 'shop.g.dart';

String _shopStatusToJson(ShopStatus status) =>
    status.toJson();

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
    @Default(ShopStatus.pending)
    @JsonKey(
      name: 'status',
      fromJson: ShopStatus.fromJson,
      toJson: _shopStatusToJson,
    )
    ShopStatus status,
    @JsonKey(name: 'business_number')
    String? businessNumber,
    @JsonKey(name: 'reject_reason')
    String? rejectReason,
    @JsonKey(name: 'reviewed_at') DateTime? reviewedAt,
    @JsonKey(name: 'created_at')
    required DateTime createdAt,
  }) = _Shop;

  factory Shop.fromJson(Map<String, dynamic> json) =>
      _$ShopFromJson(json);
}
