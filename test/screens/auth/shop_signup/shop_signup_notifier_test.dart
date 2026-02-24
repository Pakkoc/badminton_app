import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_notifier.dart';
import 'package:badminton_app/screens/auth/shop_signup/shop_signup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockShopRepository extends Mock implements ShopRepository {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockAuthUser extends Mock implements AuthUser {}

class _FakeShop extends Fake implements Shop {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeShop());
  });

  late _MockShopRepository mockShopRepo;
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late _MockAuthUser mockAuthUser;
  late ProviderContainer container;

  setUp(() {
    mockShopRepo = _MockShopRepository();
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockAuthUser = _MockAuthUser();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockAuthUser);
    when(() => mockAuthUser.id).thenReturn('test-owner-id');

    container = ProviderContainer(
      overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShopSignupNotifier', () {
    test('초기 상태는 빈 ShopSignupState이다', () {
      // Arrange & Act
      final state = container.read(shopSignupNotifierProvider);

      // Assert
      expect(state, const ShopSignupState());
      expect(state.shopName, isEmpty);
      expect(state.address, isEmpty);
      expect(state.latitude, 0.0);
      expect(state.longitude, 0.0);
      expect(state.phone, isEmpty);
      expect(state.description, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('updateShopName은 샵 이름을 업데이트한다', () {
      // Arrange
      final notifier = container.read(
        shopSignupNotifierProvider.notifier,
      );

      // Act
      notifier.updateShopName('배드민턴 프로샵');

      // Assert
      final state = container.read(shopSignupNotifierProvider);
      expect(state.shopName, '배드민턴 프로샵');
    });

    test('updateAddress는 주소를 업데이트한다', () {
      // Arrange
      final notifier = container.read(
        shopSignupNotifierProvider.notifier,
      );

      // Act
      notifier.updateAddress('서울시 강남구 역삼동');

      // Assert
      final state = container.read(shopSignupNotifierProvider);
      expect(state.address, '서울시 강남구 역삼동');
    });

    test('updatePhone은 전화번호를 업데이트한다', () {
      // Arrange
      final notifier = container.read(
        shopSignupNotifierProvider.notifier,
      );

      // Act
      notifier.updatePhone('010-1234-5678');

      // Assert
      final state = container.read(shopSignupNotifierProvider);
      expect(state.phone, '010-1234-5678');
    });

    test('updateDescription은 소개글을 업데이트한다', () {
      // Arrange
      final notifier = container.read(
        shopSignupNotifierProvider.notifier,
      );

      // Act
      notifier.updateDescription('최고의 거트 서비스');

      // Assert
      final state = container.read(shopSignupNotifierProvider);
      expect(state.description, '최고의 거트 서비스');
    });

    test('setLocation은 위도와 경도를 업데이트한다', () {
      // Arrange
      final notifier = container.read(
        shopSignupNotifierProvider.notifier,
      );

      // Act
      notifier.setLocation(37.5665, 126.978);

      // Assert
      final state = container.read(shopSignupNotifierProvider);
      expect(state.latitude, 37.5665);
      expect(state.longitude, 126.978);
    });

    group('isValid', () {
      test('모든 필드가 유효하면 true를 반환한다', () {
        // Arrange
        final notifier = container.read(
          shopSignupNotifierProvider.notifier,
        );

        // Act
        notifier.updateShopName('배드민턴 프로샵');
        notifier.updateAddress('서울시 강남구');
        notifier.updatePhone('010-1234-5678');
        notifier.setLocation(37.5665, 126.978);

        // Assert
        expect(notifier.isValid, isTrue);
      });

      test('샵 이름이 없으면 false를 반환한다', () {
        // Arrange
        final notifier = container.read(
          shopSignupNotifierProvider.notifier,
        );

        // Act
        notifier.updateAddress('서울시 강남구');
        notifier.updatePhone('010-1234-5678');
        notifier.setLocation(37.5665, 126.978);

        // Assert
        expect(notifier.isValid, isFalse);
      });

      test('좌표가 0이면 false를 반환한다', () {
        // Arrange
        final notifier = container.read(
          shopSignupNotifierProvider.notifier,
        );

        // Act
        notifier.updateShopName('배드민턴 프로샵');
        notifier.updateAddress('서울시 강남구');
        notifier.updatePhone('010-1234-5678');

        // Assert
        expect(notifier.isValid, isFalse);
      });
    });

    group('submit', () {
      test('성공 시 /owner/dashboard를 반환한다', () async {
        // Arrange
        final notifier = container.read(
          shopSignupNotifierProvider.notifier,
        );
        notifier.updateShopName('배드민턴 프로샵');
        notifier.updateAddress('서울시 강남구');
        notifier.updatePhone('010-1234-5678');
        notifier.setLocation(37.5665, 126.978);

        when(() => mockShopRepo.create(any()))
            .thenAnswer((_) async => Shop(
                  id: 'shop-1',
                  ownerId: 'test-owner-id',
                  name: '배드민턴 프로샵',
                  address: '서울시 강남구',
                  latitude: 37.5665,
                  longitude: 126.978,
                  phone: '010-1234-5678',
                  createdAt: DateTime.now(),
                ));

        // Act
        final route = await notifier.submit();

        // Assert
        expect(route, '/owner/dashboard');
      });

      test('유효하지 않으면 null을 반환한다', () async {
        // Arrange
        final notifier = container.read(
          shopSignupNotifierProvider.notifier,
        );

        // Act
        final route = await notifier.submit();

        // Assert
        expect(route, isNull);
      });
    });
  });
}
