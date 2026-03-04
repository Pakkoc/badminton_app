import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/repositories/inventory_repository.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryNotifierProvider =
    NotifierProvider<InventoryNotifier, InventoryState>(
  InventoryNotifier.new,
);

class InventoryNotifier extends Notifier<InventoryState> {
  @override
  InventoryState build() => const InventoryState();

  Future<void> loadItems(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(inventoryRepositoryProvider);
      final items = await repository.getByShop(shopId);
      state = InventoryState(items: items);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '재고 목록을 불러올 수 없습니다',
      );
    }
  }

  Future<bool> addItem({
    required String shopId,
    required String name,
    required InventoryCategory category,
    required int quantity,
  }) async {
    try {
      final repository = ref.read(inventoryRepositoryProvider);
      final item = InventoryItem(
        id: '',
        shopId: shopId,
        name: name,
        category: category,
        quantity: quantity,
        createdAt: DateTime.now(),
      );
      final created = await repository.create(item);
      state = state.copyWith(
        items: [created, ...state.items],
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: '상품을 추가할 수 없습니다',
      );
      return false;
    }
  }

  Future<bool> updateItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final repository = ref.read(inventoryRepositoryProvider);
      final updated = await repository.update(id, data);
      state = state.copyWith(
        items: state.items
            .map((item) => item.id == id ? updated : item)
            .toList(),
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: '상품을 수정할 수 없습니다',
      );
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      final repository = ref.read(inventoryRepositoryProvider);
      await repository.delete(id);
      state = state.copyWith(
        items:
            state.items.where((item) => item.id != id).toList(),
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(error: e.userMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: '상품을 삭제할 수 없습니다',
      );
      return false;
    }
  }
}
