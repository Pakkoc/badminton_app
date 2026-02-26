import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    as supa;

import '../../../helpers/fixtures.dart';

class _MockShopRepository extends Mock
    implements ShopRepository {}

class _MockUserRepository extends Mock
    implements UserRepository {}

class _MockSupabaseClient extends Mock
    implements supa.SupabaseClient {}

class _MockGoTrueClient extends Mock
    implements supa.GoTrueClient {}

void main() {
  late _MockShopRepository mockShopRepo;
  late _MockUserRepository mockUserRepo;
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late ProviderContainer container;

  setUp(() {
    mockShopRepo = _MockShopRepository();
    mockUserRepo = _MockUserRepository();
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(
      _fakeAuthUser(testOwner.id),
    );

    container = ProviderContainer(
      overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
        shopRepositoryProvider
            .overrideWithValue(mockShopRepo),
        userRepositoryProvider
            .overrideWithValue(mockUserRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShopSettingsNotifier', () {
    test('build 시 자동으로 샵 정보를 로드한다', () async {
      // Arrange
      when(() => mockShopRepo.getByOwner(any()))
          .thenAnswer((_) async => testShop);
      when(() => mockUserRepo.getById(any()))
          .thenAnswer((_) async => testOwner);

      // Act
      container.read(shopSettingsNotifierProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state =
          container.read(shopSettingsNotifierProvider);
      expect(state.shop, testShop);
      expect(state.isLoading, isFalse);
    });

    group('loadShop', () {
      test('사장님 ID로 샵 정보를 조회한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);
        when(() => mockUserRepo.getById(any()))
            .thenAnswer((_) async => testOwner);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );

        // Act
        await notifier.loadShop();

        // Assert
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.shop, testShop);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
      });

      test('조회 실패 시 에러를 설정한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenThrow(AppException.server());
        when(() => mockUserRepo.getById(any()))
            .thenAnswer((_) async => testOwner);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );

        // Act
        await notifier.loadShop();

        // Assert
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.errorMessage, isNotNull);
        expect(state.isLoading, isFalse);
      });

      test('로그인하지 않으면 에러를 설정한다', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );

        // Act
        await notifier.loadShop();

        // Assert
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.errorMessage, '로그인이 필요합니다');
      });
    });

    group('update methods', () {
      test('updateShopName은 샵 이름을 업데이트한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);
        when(() => mockUserRepo.getById(any()))
            .thenAnswer((_) async => testOwner);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );
        await notifier.loadShop();

        // Act
        notifier.updateShopName('새 샵 이름');

        // Assert
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.shop!.name, '새 샵 이름');
      });

      test('updateAddress는 주소를 업데이트한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);
        when(() => mockUserRepo.getById(any()))
            .thenAnswer((_) async => testOwner);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );
        await notifier.loadShop();

        // Act
        notifier.updateAddress('서울시 송파구');

        // Assert
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.shop!.address, '서울시 송파구');
      });

      test('updatePhone은 전화번호를 업데이트한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);
        when(() => mockUserRepo.getById(any()))
            .thenAnswer((_) async => testOwner);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );
        await notifier.loadShop();

        // Act
        notifier.updatePhone('0298765432');

        // Assert
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.shop!.phone, '0298765432');
      });

      test('updateDescription은 소개글을 업데이트한다',
          () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);
        when(() => mockUserRepo.getById(any()))
            .thenAnswer((_) async => testOwner);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );
        await notifier.loadShop();

        // Act
        notifier.updateDescription('새 소개글');

        // Assert
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.shop!.description, '새 소개글');
      });

      test('shop이 null이면 업데이트하지 않는다', () {
        // Arrange
        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );

        // Act
        notifier.updateShopName('새 샵 이름');

        // Assert
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.shop, isNull);
      });
    });

    group('submit', () {
      test('저장에 성공하면 true를 반환한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);
        when(() => mockUserRepo.getById(any()))
            .thenAnswer((_) async => testOwner);
        when(() => mockShopRepo.update(any(), any()))
            .thenAnswer((_) async => testShop);
        when(() => mockUserRepo.update(any(), any()))
            .thenAnswer((_) async => testOwner);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );
        await notifier.loadShop();

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, isTrue);
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.isSubmitting, isFalse);
      });

      test('shop이 null이면 false를 반환한다', () async {
        // Arrange
        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, isFalse);
      });

      test('저장 실패 시 false를 반환한다', () async {
        // Arrange
        when(() => mockShopRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);
        when(() => mockUserRepo.getById(any()))
            .thenAnswer((_) async => testOwner);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );
        await notifier.loadShop();
        await Future<void>.delayed(Duration.zero);

        when(() => mockShopRepo.update(any(), any()))
            .thenThrow(AppException.server());

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, isFalse);
        final state =
            container.read(shopSettingsNotifierProvider);
        expect(state.isSubmitting, isFalse);
        expect(state.errorMessage, isNotNull);
      });
    });
  });
}

/// GoTrueClient.currentUser가 반환할 가짜 AuthUser 생성.
supa.User _fakeAuthUser(String id) => supa.User(
      id: id,
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime(2026).toIso8601String(),
    );
