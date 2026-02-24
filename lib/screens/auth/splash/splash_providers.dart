import 'dart:async';

import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SplashRoute {
  login,
  customerHome,
  ownerDashboard,
  profileSetup,
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

  final isNewUser = ref.read(isNewUserProvider);
  if (isNewUser) {
    return SplashRoute.profileSetup;
  }

  final role = ref.read(userRoleProvider);
  return switch (role) {
    UserRole.customer => SplashRoute.customerHome,
    UserRole.shopOwner => SplashRoute.ownerDashboard,
    null => SplashRoute.login,
  };
}
