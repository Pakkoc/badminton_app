import 'dart:typed_data';

import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/inventory_repository.dart';
import 'package:badminton_app/repositories/storage_repository.dart';
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
      final repository =
          ref.read(inventoryRepositoryProvider);
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

  Future<String?> _uploadImage(
    Uint8List bytes,
    String extension,
  ) async {
    final storage = ref.read(storageRepositoryProvider);
    final userId =
        ref.read(supabaseProvider).auth.currentUser!.id;
    final ts = DateTime.now().microsecondsSinceEpoch;
    final path = '$userId/$ts.$extension';
    return storage.uploadImage(
      'inventory-images',
      bytes,
      path,
    );
  }

  Future<bool> addItem({
    required String shopId,
    required String name,
    required InventoryCategory category,
    required int quantity,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    try {
      String? imageUrl;
      if (imageBytes != null && imageExtension != null) {
        imageUrl = await _uploadImage(
          imageBytes,
          imageExtension,
        );
      }
      final repository =
          ref.read(inventoryRepositoryProvider);
      final item = InventoryItem(
        id: '',
        shopId: shopId,
        name: name,
        category: category,
        quantity: quantity,
        imageUrl: imageUrl,
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
    Map<String, dynamic> data, {
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    try {
      if (imageBytes != null && imageExtension != null) {
        final url = await _uploadImage(
          imageBytes,
          imageExtension,
        );
        data['image_url'] = url;
      }
      final repository =
          ref.read(inventoryRepositoryProvider);
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
      final repository =
          ref.read(inventoryRepositoryProvider);
      await repository.delete(id);
      state = state.copyWith(
        items: state.items
            .where((item) => item.id != id)
            .toList(),
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
