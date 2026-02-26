import 'package:badminton_app/models/order.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'owner_dashboard_state.freezed.dart';

@freezed
class OwnerDashboardState with _$OwnerDashboardState {
  const factory OwnerDashboardState({
    @Default(0) int receivedCount,
    @Default(0) int inProgressCount,
    @Default(0) int completedCount,
    @Default([]) List<GutOrder> recentOrders,
    @Default({}) Map<String, String> memberNames,
    @Default(true) bool isLoading,
    String? error,
    String? shopName,
    String? shopId,
  }) = _OwnerDashboardState;
}
