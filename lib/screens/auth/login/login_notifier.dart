import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/screens/auth/login/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

final loginNotifierProvider =
    NotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState.idle();

  Future<void> signInWithKakao() async {
    await _signInWithOAuth('kakao', OAuthProvider.kakao);
  }

  Future<void> signInWithNaver() async {
    state = const LoginState.authenticating('naver');
    try {
      // 네이버는 Supabase OAuthProvider에 없으므로
      // flutter_naver_login을 통해 별도 처리한다.
      // TODO: NaverLoginService 연동
      state = const LoginState.idle();
    } on AppException catch (e) {
      state = LoginState.error(e.userMessage);
      await Future<void>.delayed(const Duration(seconds: 3));
      state = const LoginState.idle();
    } catch (e) {
      state = const LoginState.error('로그인에 실패했습니다');
      await Future<void>.delayed(const Duration(seconds: 3));
      state = const LoginState.idle();
    }
  }

  Future<void> signInWithGoogle() async {
    await _signInWithOAuth('google', OAuthProvider.google);
  }

  Future<void> _signInWithOAuth(
    String providerName,
    OAuthProvider provider,
  ) async {
    state = LoginState.authenticating(providerName);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithOAuth(provider);
      state = const LoginState.idle();
    } on AppException catch (e) {
      state = LoginState.error(e.userMessage);
      await Future<void>.delayed(const Duration(seconds: 3));
      state = const LoginState.idle();
    } catch (e) {
      state = const LoginState.error('로그인에 실패했습니다');
      await Future<void>.delayed(const Duration(seconds: 3));
      state = const LoginState.idle();
    }
  }
}
