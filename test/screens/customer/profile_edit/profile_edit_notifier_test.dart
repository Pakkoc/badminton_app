import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/storage_repository.dart';
import 'package:badminton_app/repositories/user_repository.dart';
import 'package:badminton_app/screens/customer/profile_edit/profile_edit_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockUserRepository extends Mock
    implements UserRepository {}

class _MockStorageRepository extends Mock
    implements StorageRepository {}

void main() {
  late _MockUserRepository mockUserRepo;
  late _MockStorageRepository mockStorageRepo;
  late ProviderContainer container;

  setUp(() {
    mockUserRepo = _MockUserRepository();
    mockStorageRepo = _MockStorageRepository();
    when(
      () => mockUserRepo.getById(testUser.id),
    ).thenAnswer((_) async => testUser);
    container = ProviderContainer(
      overrides: [
        userRepositoryProvider
            .overrideWithValue(mockUserRepo),
        storageRepositoryProvider
            .overrideWithValue(mockStorageRepo),
        currentAuthUserIdProvider.overrideWithValue(
          testUser.id,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileEditNotifier', () {
    test('build 시 프로필을 자동 로드한다', () async {
      // Arrange & Act
      container.read(profileEditNotifierProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Assert
      final state =
          container.read(profileEditNotifierProvider);
      expect(state.name, testUser.name);
      expect(state.phone, testUser.phone);
    });

    test('updateName은 이름을 업데이트한다', () async {
      // Arrange
      final notifier = container.read(
        profileEditNotifierProvider.notifier,
      );

      // Act
      notifier.updateName('새이름');

      // Assert
      final state =
          container.read(profileEditNotifierProvider);
      expect(state.name, '새이름');
    });

    test('updatePhone은 전화번호를 업데이트한다', () async {
      // Arrange
      final notifier = container.read(
        profileEditNotifierProvider.notifier,
      );

      // Act
      notifier.updatePhone('010-9999-8888');

      // Assert
      final state =
          container.read(profileEditNotifierProvider);
      expect(state.phone, '010-9999-8888');
    });

    group('submit', () {
      test('프로필 저장에 성공하면 true를 반환한다', () async {
        // Arrange
        when(() => mockUserRepo.update(any(), any()))
            .thenAnswer((_) async => testUser);

        final notifier = container.read(
          profileEditNotifierProvider.notifier,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, isTrue);
        final state =
            container.read(profileEditNotifierProvider);
        expect(state.isSubmitting, isFalse);
        expect(state.errorMessage, isNull);
      });

      test('프로필 저장에 실패하면 false를 반환한다', () async {
        // Arrange
        when(() => mockUserRepo.update(any(), any()))
            .thenThrow(AppException.server());

        final notifier = container.read(
          profileEditNotifierProvider.notifier,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, isFalse);
        final state =
            container.read(profileEditNotifierProvider);
        expect(state.isSubmitting, isFalse);
        expect(state.errorMessage, isNotNull);
      });

      test('로그인하지 않으면 false를 반환한다', () async {
        // Arrange
        final noUserContainer = ProviderContainer(
          overrides: [
            userRepositoryProvider
                .overrideWithValue(mockUserRepo),
            storageRepositoryProvider
                .overrideWithValue(mockStorageRepo),
            currentAuthUserIdProvider.overrideWithValue(
              null,
            ),
          ],
        );
        addTearDown(noUserContainer.dispose);

        final notifier = noUserContainer.read(
          profileEditNotifierProvider.notifier,
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // Act
        final result = await notifier.submit();

        // Assert
        expect(result, isFalse);
        final state = noUserContainer.read(
          profileEditNotifierProvider,
        );
        expect(state.errorMessage, '로그인이 필요합니다');
      });
    });
  });
}
