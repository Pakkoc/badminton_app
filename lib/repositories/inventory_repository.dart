import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(supabaseProvider));
});

/// 재고 리포지토리.
///
/// Supabase `inventory` 테이블에 대한 CRUD 작업을 수행한다.
class InventoryRepository {
  final SupabaseClient client;

  InventoryRepository(this.client);

  /// 재고 아이템을 생성한다.
  Future<InventoryItem> create(InventoryItem item) async {
    try {
      final data = await client
          .from('inventory')
          .insert(item.toJson())
          .select()
          .single();
      return InventoryItem.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 재고 아이템을 수정한다.
  Future<InventoryItem> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await client
          .from('inventory')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return InventoryItem.fromJson(result);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 재고 아이템을 삭제한다.
  Future<void> delete(String id) async {
    try {
      await client.from('inventory').delete().eq('id', id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장 ID로 재고 목록을 조회한다.
  Future<List<InventoryItem>> getByShop(String shopId) async {
    try {
      final data = await client
          .from('inventory')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      return data.map(InventoryItem.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
