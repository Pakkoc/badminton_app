import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(supabaseProvider));
});

/// 사용자 데이터를 관리하는 리포지토리.
class UserRepository {
  final SupabaseClient _client;

  static const _table = 'users';

  UserRepository(this._client);

  /// ID로 사용자를 조회한다.
  Future<User?> getById(String id) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return User.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 사용자를 생성한다.
  Future<User> create(User user) async {
    try {
      final data = await _client
          .from(_table)
          .insert(user.toJson())
          .select()
          .single();
      return User.fromJson(data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 사용자 정보를 부분 업데이트한다.
  Future<User> update(String id, Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from(_table)
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return User.fromJson(result);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 샵 알림 설정을 업데이트한다.
  Future<User> updateNotifyShop(String id, {required bool value}) async {
    return update(id, {'notify_shop': value});
  }

  /// 커뮤니티 알림 설정을 업데이트한다.
  Future<User> updateNotifyCommunity(
    String id, {
    required bool value,
  }) async {
    return update(id, {'notify_community': value});
  }

  /// 전화번호로 매칭되는 회원에 user_id를 업데이트한다.
  Future<void> matchMembersByPhone(
    String phone,
    String userId,
  ) async {
    try {
      await _client
          .from('members')
          .update({'user_id': userId})
          .eq('phone', phone)
          .isFilter('user_id', null);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
