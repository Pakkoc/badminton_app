import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/order.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_manage_state.freezed.dart';

@freezed
class OrderManageState with _$OrderManageState {
  const factory OrderManageState({
    @Default([]) List<GutOrder> orders,
    OrderStatus? selectedFilter,
    @Default(true) bool isLoading,
    String? error,
  }) = _OrderManageState;

  const OrderManageState._();

  List<GutOrder> get filteredOrders {
    if (selectedFilter == null) return orders;
    return orders
        .where((o) => o.status == selectedFilter)
        .toList();
  }
}
