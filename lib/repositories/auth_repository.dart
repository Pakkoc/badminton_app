import 'package:badminton_app/core/error/error_handler.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
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

  /// 네이버 소셜 로그인을 수행한다.
  ///
  /// flutter_naver_login으로 네이버 토큰을 받은 뒤,
  /// Supabase signInWithIdToken으로 세션을 생성한다.
  Future<void> signInWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();
      if (result.status == NaverLoginStatus.error) {
        throw ErrorHandler.handle(
          Exception(result.errorMessage ?? '네이버 로그인 실패'),
        );
      }
      final token = await FlutterNaverLogin.getCurrentAccessToken();
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: token.accessToken,
      );
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
