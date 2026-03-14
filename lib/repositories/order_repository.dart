import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.read(supabaseProvider));
});

/// 주문(거트 작업) 데이터를 관리하는 리포지토리.
class OrderRepository {
  final SupabaseClient _client;

  static const _table = 'orders';

  OrderRepository(this._client);

  /// 주문을 생성한다.
  ///
  /// [order.id]가 빈 문자열이면 DB에서 자동 생성한다.
  Future<GutOrder> create(GutOrder order) async {
    try {
      final json = order.toJson();
      if (json['id'] == '') json.remove('id');
      final data = await _client
          .from(_table)
          .insert(json)
          .select()
          .single();
      return GutOrder.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 주문 상태를 업데이트한다.
  Future<GutOrder> updateStatus(String id, String status) async {
    try {
      final data = await _client
          .from(_table)
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();
      return GutOrder.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 주문을 삭제한다.
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장별 주문 목록을 조회한다.
  ///
  /// [statusFilter]가 주어지면 해당 상태의 주문만 반환한다.
  Future<List<GutOrder>> getByShop(
    String shopId, {
    String? statusFilter,
  }) async {
    try {
      var query = _client
          .from(_table)
          .select()
          .eq('shop_id', shopId);
      if (statusFilter != null) {
        query = query.eq('status', statusFilter);
      }
      final data = await query.order('created_at');
      return data.map(GutOrder.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 회원(사용자) ID로 주문 목록을 조회한다.
  Future<List<GutOrder>> getByMemberUser(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select('*, members!inner(user_id)')
          .eq('members.user_id', userId)
          .order('created_at');
      return data.map(GutOrder.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장의 활성(미완료) 주문 수를 반환한다.
  Future<int> countActiveByShop(String shopId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('shop_id', shopId)
          .neq('status', 'completed')
          .count(CountOption.exact);
      return data.count;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장별 주문 목록을 실시간 스트림으로 구독한다.
  Stream<List<Map<String, dynamic>>> streamByShop(String shopId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('shop_id', shopId)
        .order('created_at');
  }

  /// 특정 주문을 실시간 스트림으로 구독한다.
  Stream<Map<String, dynamic>> streamById(String orderId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((list) => list.first);
  }
}
