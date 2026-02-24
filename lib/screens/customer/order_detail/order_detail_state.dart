import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_detail_state.freezed.dart';

@freezed
class OrderDetailState with _$OrderDetailState {
  const factory OrderDetailState({
    GutOrder? order,
    Shop? shop,
    @Default(false) bool isLoading,
    String? error,
  }) = _OrderDetailState;
}
