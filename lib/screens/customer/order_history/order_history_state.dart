import 'package:badminton_app/models/order.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_history_state.freezed.dart';

@freezed
class OrderHistoryState with _$OrderHistoryState {
  const factory OrderHistoryState({
    @Default([]) List<GutOrder> orders,
    @Default(false) bool isLoading,
    String? error,
  }) = _OrderHistoryState;
}
