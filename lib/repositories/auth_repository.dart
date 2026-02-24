import 'package:badminton_app/core/error/error_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 인증을 관리하는 리포지토리.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// OAuth 소셜 로그인을 수행한다.
  ///
  /// 카카오, 네이버, 구글, 애플 로그인을 지원한다.
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      return await _client.auth.signInWithOAuth(provider);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 로그아웃을 수행한다.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 현재 인증된 사용자를 반환한다.
  User? get currentUser => _client.auth.currentUser;

  /// 현재 세션을 반환한다.
  Session? get currentSession => _client.auth.currentSession;

  /// 인증 상태 변경 스트림을 반환한다.
  Stream<AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;
}
