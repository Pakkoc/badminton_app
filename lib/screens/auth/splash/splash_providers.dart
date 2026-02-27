import 'dart:async';

import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart' as app;
import 'package:badminton_app/providers/fcm_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SplashRoute {
  login,
  customerHome,
  ownerDashboard,
  profileSetup,
  shopRegister,
}

/// autoDispose로 변경하여 스플래시 화면 재진입 시 항상 재실행.
final splashRouteProvider =
    FutureProvider.autoDispose<SplashRoute>((ref) async {
  try {
    final result = await Future.any<SplashRoute>([
      _resolveRoute(ref),
      Future<SplashRoute>.delayed(
        const Duration(seconds: 5),
        () => SplashRoute.login,
      ),
    ]);
    return result;
  } catch (_) {
    return SplashRoute.login;
  }
});

Future<SplashRoute> _resolveRoute(Ref ref) async {
  // 최소 1.5초 대기 (스플래시 애니메이션)
  await Future<void>.delayed(const Duration(milliseconds: 1500));

  final client = ref.read(supabaseProvider);
  var session = client.auth.currentSession;

  // 웹 OAuth 콜백 후 세션이 아직 설정되지 않았을 수 있음.
  // onAuthStateChange에서 signedIn 이벤트를 최대 3초 대기.
  if (session == null) {
    try {
      final authState = await client.auth.onAuthStateChange
          .where(
            (state) =>
                state.event == AuthChangeEvent.signedIn ||
                state.event == AuthChangeEvent.tokenRefreshed ||
                state.event ==
                    AuthChangeEvent.initialSession,
          )
          .first
          .timeout(const Duration(seconds: 3));
      session = authState.session;
    } on TimeoutException {
      // 타임아웃 → 세션 없음
    }
  }

  if (session == null) {
    return SplashRoute.login;
  }

  // users 테이블에서 직접 조회
  try {
    final userId = session.user.id;
    final data = await client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      return SplashRoute.profileSetup;
    }

    final user = app.User.fromJson(data);

    // FCM 토큰 저장 (비동기, 실패해도 라우팅 진행)
    unawaited(
      ref
          .read(fcmServiceProvider)
          .saveTokenToDb(userId, client)
          .catchError((_) {}),
    );

    if (user.role == UserRole.shopOwner) {
      // 사장님인데 샵이 없으면 샵 등록으로
      final shop = await client
          .from('shops')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();
      if (shop == null) {
        return SplashRoute.shopRegister;
      }
      return SplashRoute.ownerDashboard;
    }

    return SplashRoute.customerHome;
  } catch (_) {
    return SplashRoute.profileSetup;
  }
}
