import 'dart:async';
import 'dart:developer' as developer;

import 'package:app_links/app_links.dart';
import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/core/error/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  /// 브라우저에서 네이버 OAuth를 수행하고,
  /// Edge Function이 code→token 교환 후 딥링크로 세션 토큰을 전달한다.
  /// 앱이 딥링크를 수신하여 setSession으로 로그인을 완료한다.
  Future<void> signInWithNaver() async {
    final supabaseUrl =
        _client.rest.url.replaceAll('/rest/v1', '');
    final efUrl = '$supabaseUrl/functions/v1/naver-auth';
    final uri = Uri.parse(efUrl);
    developer.log(
      'Opening Naver OAuth: $uri',
      name: 'AuthRepository',
    );

    final completer = Completer<void>();
    final appLinks = AppLinks();

    // 딥링크 수신 리스너 (query param에서 토큰 추출)
    late StreamSubscription<Uri> linkSub;
    linkSub = appLinks.uriLinkStream.listen(
      (linkUri) async {
        developer.log(
          'Deep link received: $linkUri',
          name: 'AuthRepository',
        );

        if (linkUri.host != 'login-callback') return;

        final error =
            linkUri.queryParameters['error'];
        final refreshToken =
            linkUri.queryParameters['refresh_token'];

        linkSub.cancel();

        if (error != null) {
          if (!completer.isCompleted) {
            completer.completeError(
              AppException(
                code: 'naver_error',
                message: error,
                userMessage: '네이버 로그인에 실패했습니다',
              ),
            );
          }
          return;
        }

        if (refreshToken != null) {
          try {
            await _client.auth.setSession(refreshToken);
            if (!completer.isCompleted) {
              completer.complete();
            }
          } catch (e) {
            developer.log(
              'setSession failed: $e',
              name: 'AuthRepository',
            );
            if (!completer.isCompleted) {
              completer.completeError(
                AppException(
                  code: 'naver_session',
                  message: 'Failed to set session: $e',
                  userMessage: '세션 설정에 실패했습니다',
                ),
              );
            }
          }
        }
      },
    );

    // 브라우저 열기
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      linkSub.cancel();
      throw AppException(
        code: 'naver_browser',
        message: 'Failed to launch browser',
        userMessage: '브라우저를 열 수 없습니다',
      );
    }

    // 60초 타임아웃
    Timer(const Duration(seconds: 60), () {
      linkSub.cancel();
      if (!completer.isCompleted) {
        completer.completeError(
          AppException(
            code: 'naver_timeout',
            message: 'Naver login timed out',
            userMessage: '네이버 로그인 시간이 초과되었습니다',
          ),
        );
      }
    });

    return completer.future;
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
