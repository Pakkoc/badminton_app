import 'package:badminton_app/providers/app_mode_provider.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/fixtures.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockAuthUser extends Mock implements AuthUser {}

class _MockShopRepository extends Mock implements ShopRepository {}

void main() {
  group('activeModeProvider', () {
    test('초기값은 AppMode.customer이다', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act & Assert
      expect(container.read(activeModeProvider), AppMode.customer);
    });

    test('모드를 owner로 전환할 수 있다', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      container.read(activeModeProvider.notifier).state =
          AppMode.owner;

      // Assert
      expect(container.read(activeModeProvider), AppMode.owner);
    });
  });

  group('hasShopProvider', () {
    late _MockSupabaseClient mockSupabase;
    late _MockGoTrueClient mockAuth;
    late _MockAuthUser mockAuthUser;
    late _MockShopRepository mockShopRepo;

    setUp(() {
      mockSupabase = _MockSupabaseClient();
      mockAuth = _MockGoTrueClient();
      mockAuthUser = _MockAuthUser();
      mockShopRepo = _MockShopRepository();

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(mockAuthUser);
      when(() => mockAuthUser.id).thenReturn('user-1');
    });

    test('샵이 있으면 true를 반환한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenAnswer((_) async => testShop);

      final container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result =
          await container.read(hasShopProvider.future);

      // Assert
      expect(result, isTrue);
    });

    test('샵이 없으면 false를 반환한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner('user-1'))
          .thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result =
          await container.read(hasShopProvider.future);

      // Assert
      expect(result, isFalse);
    });

    test('로그인하지 않으면 false를 반환한다', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      final container = ProviderContainer(
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result =
          await container.read(hasShopProvider.future);

      // Assert
      expect(result, isFalse);
    });
  });
}
