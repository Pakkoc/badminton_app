import 'package:badminton_app/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
class GutOrder with _$GutOrder {
  const factory GutOrder({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(
      fromJson: OrderStatus.fromJson,
      toJson: _orderStatusToJson,
    )
    required OrderStatus status,
    String? memo,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'in_progress_at') DateTime? inProgressAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _GutOrder;

  factory GutOrder.fromJson(Map<String, dynamic> json) =>
      _$GutOrderFromJson(json);
}

String _orderStatusToJson(OrderStatus status) => status.toJson();
