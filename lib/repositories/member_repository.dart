import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/utils/escape_like.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.read(supabaseProvider));
});

/// 회원 데이터를 관리하는 리포지토리.
class MemberRepository {
  final SupabaseClient _client;

  static const _table = 'members';

  MemberRepository(this._client);

  /// 매장 ID와 사용자 ID로 회원을 조회한다.
  Future<Member?> getByShopAndUser(
    String shopId,
    String userId,
  ) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('shop_id', shopId)
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return null;
      return Member.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장 ID와 전화번호로 회원을 조회한다.
  Future<Member?> getByShopAndPhone(
    String shopId,
    String phone,
  ) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('shop_id', shopId)
          .eq('phone', phone)
          .maybeSingle();
      if (data == null) return null;
      return Member.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장 내 회원을 이름 또는 전화번호로 검색한다.
  Future<List<Member>> search(
    String shopId,
    String query,
  ) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('shop_id', shopId)
          .or('name.ilike.%${escapeLike(query)}%,phone.ilike.%${escapeLike(query)}%');
      return data.map(Member.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 매장 ID로 전체 회원을 조회한다.
  Future<List<Member>> getByShop(String shopId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('shop_id', shopId);
      return data.map(Member.fromJson).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 회원을 생성한다.
  ///
  /// [member.id]가 빈 문자열이면 DB에서 자동 생성한다.
  Future<Member> create(Member member) async {
    try {
      final json = member.toJson();
      if (json['id'] == '') json.remove('id');
      final data = await _client
          .from(_table)
          .insert(json)
          .select()
          .single();
      return Member.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 회원 정보를 부분 업데이트한다.
  Future<Member> update(String id, Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(_table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return Member.fromJson(result);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
