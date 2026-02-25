import 'dart:async';

import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SplashRoute {
  login,
  customerHome,
  ownerDashboard,
  profileSetup,
  shopRegister,
}

final splashRouteProvider =
    FutureProvider<SplashRoute>((ref) async {
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
  // 최소 1.5초 대기
  await Future<void>.delayed(const Duration(milliseconds: 1500));

  final client = ref.read(supabaseProvider);
  final session = client.auth.currentSession;

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

    final user = User.fromJson(data);

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
