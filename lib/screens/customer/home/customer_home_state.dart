import 'package:badminton_app/models/order.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_home_state.freezed.dart';

@freezed
class CustomerHomeState with _$CustomerHomeState {
  const factory CustomerHomeState({
    @Default([]) List<GutOrder> activeOrders,
    @Default(false) bool isLoading,
    String? error,
  }) = _CustomerHomeState;
}
