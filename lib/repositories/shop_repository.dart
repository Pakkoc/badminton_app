import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.watch(supabaseProvider));
});

/// 매장 데이터를 관리하는 리포지토리.
class ShopRepository {
  final SupabaseClient _client;

  static const _table = 'shops';

  ShopRepository(this._client);

  /// ID로 매장을 조회한다.
  Future<Shop?> getById(String id) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장을 생성한다.
  Future<Shop> create(Shop shop) async {
    try {
      final json = shop.toJson()..remove('id');
      final data = await _client
          .from(_table)
          .insert(json)
          .select()
          .single();
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장 정보를 부분 업데이트한다.
  Future<Shop> update(String id, Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(_table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return Shop.fromJson(result);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 사장님 ID로 매장을 조회한다.
  Future<Shop?> getByOwner(String ownerId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('owner_id', ownerId)
          .maybeSingle();
      if (data == null) return null;
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장 이름으로 검색한다.
  Future<List<Shop>> searchByName(String query) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .ilike('name', '%$query%')
          .order('name');
      return data.map(Shop.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 지도 영역(bounds) 내의 매장 목록을 조회한다.
  Future<List<Shop>> searchByBounds({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
  }) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .gte('latitude', swLat)
          .lte('latitude', neLat)
          .gte('longitude', swLng)
          .lte('longitude', neLng);
      return data.map(Shop.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 승인 대기 중인 샵 목록을 조회한다.
  Future<List<Shop>> getPendingShops() async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('status', 'pending')
          .order('created_at');
      return data.map(Shop.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 샵 등록을 승인한다.
  Future<Shop> approve(String id) async {
    try {
      final data = await _client
          .from(_table)
          .update({
            'status': 'approved',
            'reject_reason': null,
            'reviewed_at':
                DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 샵 등록을 거절한다.
  Future<Shop> reject(String id, String reason) async {
    try {
      final data = await _client
          .from(_table)
          .update({
            'status': 'rejected',
            'reject_reason': reason,
            'reviewed_at':
                DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();
      return Shop.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
