import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/user.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_notifier.dart';
import 'package:badminton_app/screens/auth/profile_setup/profile_setup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class _MockUserRepository extends Mock implements UserRepository {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockAuthUser extends Mock implements AuthUser {}

class _FakeUser extends Fake implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUser());
  });

  late _MockUserRepository mockUserRepo;
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late _MockAuthUser mockAuthUser;
  late ProviderContainer container;

  setUp(() {
    mockUserRepo = _MockUserRepository();
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockAuthUser = _MockAuthUser();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockAuthUser);
    when(() => mockAuthUser.id).thenReturn('test-user-id');

    container = ProviderContainer(
      overrides: [
        supabaseProvider.overrideWithValue(mockSupabase),
        userRepositoryProvider.overrideWithValue(mockUserRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileSetupNotifier', () {
    test('초기 상태는 빈 ProfileSetupState이다', () {
      // Arrange & Act
      final state = container.read(profileSetupNotifierProvider);

      // Assert
      expect(state, const ProfileSetupState());
      expect(state.name, isEmpty);
      expect(state.phone, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('updateName은 이름을 업데이트한다', () {
      // Arrange
      final notifier = container.read(
        profileSetupNotifierProvider.notifier,
      );

      // Act
      notifier.updateName('홍길동');

      // Assert
      final state = container.read(profileSetupNotifierProvider);
      expect(state.name, '홍길동');
    });

    test('updatePhone은 전화번호를 업데이트한다', () {
      // Arrange
      final notifier = container.read(
        profileSetupNotifierProvider.notifier,
      );

      // Act
      notifier.updatePhone('010-1234-5678');

      // Assert
      final state = container.read(profileSetupNotifierProvider);
      expect(state.phone, '010-1234-5678');
    });

    group('isValid', () {
      test('이름과 전화번호가 유효하면 true를 반환한다', () {
        // Arrange
        final notifier = container.read(
          profileSetupNotifierProvider.notifier,
        );

        // Act
        notifier.updateName('홍길동');
        notifier.updatePhone('010-1234-5678');

        // Assert
        expect(notifier.isValid, isTrue);
      });

      test('이름이 유효하지 않으면 false를 반환한다', () {
        // Arrange
        final notifier = container.read(
          profileSetupNotifierProvider.notifier,
        );

        // Act
        notifier.updateName('홍');
        notifier.updatePhone('010-1234-5678');

        // Assert
        expect(notifier.isValid, isFalse);
      });

      test('전화번호가 유효하지 않으면 false를 반환한다', () {
        // Arrange
        final notifier = container.read(
          profileSetupNotifierProvider.notifier,
        );

        // Act
        notifier.updateName('홍길동');
        notifier.updatePhone('123');

        // Assert
        expect(notifier.isValid, isFalse);
      });
    });

    group('submit', () {
      test('항상 /customer/home을 반환한다', () async {
        // Arrange
        final notifier = container.read(
          profileSetupNotifierProvider.notifier,
        );
        notifier.updateName('홍길동');
        notifier.updatePhone('010-1234-5678');

        when(() => mockUserRepo.create(any()))
            .thenAnswer((_) async => User(
                  id: 'test-user-id',
                  role: UserRole.customer,
                  name: '홍길동',
                  phone: '010-1234-5678',
                  createdAt: DateTime.now(),
                ));
        when(
          () => mockUserRepo.matchMembersByPhone(
            any(),
            any(),
          ),
        ).thenAnswer((_) async {});

        // Act
        final route = await notifier.submit();

        // Assert
        expect(route, '/customer/home');
      });

      test('유효하지 않으면 null을 반환한다', () async {
        // Arrange
        final notifier = container.read(
          profileSetupNotifierProvider.notifier,
        );

        // Act
        final route = await notifier.submit();

        // Assert
        expect(route, isNull);
      });
    });
  });
}
