import 'dart:convert';

import 'package:badminton_app/core/error/error_handler.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// 인증을 관리하는 리포지토리.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// OAuth 콜백 딥링크 URL.
  static const _redirectUrl =
      'com.gurtalim.app://login-callback';

  /// OAuth 소셜 로그인을 수행한다.
  ///
  /// 카카오, 구글, 애플 로그인을 지원한다.
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      return await _client.auth.signInWithOAuth(
        provider,
        redirectTo: _redirectUrl,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// 네이버 소셜 로그인을 수행한다.
  ///
  /// flutter_naver_login으로 네이버 Access Token을 받은 뒤,
  /// Edge Function(naver-auth)으로 Supabase 사용자를 생성/조회하고
  /// OTP verifyOTP로 세션을 생성한다.
  Future<void> signInWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();
      if (result.status == NaverLoginStatus.error) {
        throw ErrorHandler.handle(
          Exception(result.errorMessage ?? '네이버 로그인 실패'),
        );
      }
      final token = await FlutterNaverLogin.getCurrentAccessToken();

      // Edge Function 호출
      final supabaseUrl = _client.rest.url.replaceAll('/rest/v1', '');
      final anonKey = _client.rest.headers['apikey'] ?? '';
      final res = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/naver-auth'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': anonKey,
        },
        body: jsonEncode({'access_token': token.accessToken}),
      );

      if (res.statusCode != 200) {
        throw Exception('네이버 EF 실패(${res.statusCode}): ${res.body}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw Exception('네이버 세션 토큰 없음: ${res.body}');
      }

      // refresh_token으로 세션 설정
      await _client.auth.setSession(refreshToken);
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
