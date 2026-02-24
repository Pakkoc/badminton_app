import 'package:badminton_app/models/inventory_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_state.freezed.dart';

@freezed
class InventoryState with _$InventoryState {
  const factory InventoryState({
    @Default([]) List<InventoryItem> items,
    @Default(false) bool isLoading,
    String? error,
  }) = _InventoryState;
}
