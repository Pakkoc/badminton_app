import 'dart:async';

import 'package:badminton_app/app/router.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock
    implements SupabaseClient {}

class _MockGoTrueClient extends Mock
    implements GoTrueClient {}

void main() {
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockAuth.onAuthStateChange).thenAnswer(
      (_) => const Stream<AuthState>.empty(),
    );
  });

  group('Router', () {
    test('routerProvider는 GoRouter를 제공한다', () {
      final container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      expect(router, isA<GoRouter>());
    });

    test('GoRouter의 configuration에 routes가 존재한다', () {
      final container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      expect(router.configuration.routes, isNotEmpty);
    });
  });
}
