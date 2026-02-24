import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/providers/auth_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_notifier.dart';
import 'package:badminton_app/screens/owner/shop_settings/shop_settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockShopRepository extends Mock
    implements ShopRepository {}

void main() {
  late _MockShopRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = _MockShopRepository();
    container = ProviderContainer(
      overrides: [
        shopRepositoryProvider
            .overrideWithValue(mockRepo),
        currentUserProvider.overrideWith(
          (ref) async => testOwner,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ShopSettingsNotifier', () {
    test('build 시 자동으로 샵 정보를 로드한다', () async {
      // Arrange
      when(() => mockRepo.getByOwner(any()))
          .thenAnswer((_) async => testShop);

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
        when(() => mockRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);

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
        when(() => mockRepo.getByOwner(any()))
            .thenThrow(AppException.server());

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
        final noUserContainer = ProviderContainer(
          overrides: [
            shopRepositoryProvider
                .overrideWithValue(mockRepo),
            currentUserProvider.overrideWith(
              (ref) async => null,
            ),
          ],
        );
        addTearDown(noUserContainer.dispose);

        final notifier = noUserContainer.read(
          shopSettingsNotifierProvider.notifier,
        );

        // Act
        await notifier.loadShop();

        // Assert
        final state = noUserContainer.read(
          shopSettingsNotifierProvider,
        );
        expect(state.errorMessage, '로그인이 필요합니다');
      });
    });

    group('update methods', () {
      test('updateShopName은 샵 이름을 업데이트한다', () async {
        // Arrange
        when(() => mockRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);

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
        when(() => mockRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);

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
        when(() => mockRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);

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

      test('updateDescription은 소개글을 업데이트한다', () async {
        // Arrange
        when(() => mockRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);

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
        when(() => mockRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);
        when(() => mockRepo.update(any(), any()))
            .thenAnswer((_) async => testShop);

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
        when(() => mockRepo.getByOwner(any()))
            .thenAnswer((_) async => testShop);

        final notifier = container.read(
          shopSettingsNotifierProvider.notifier,
        );
        await notifier.loadShop();
        // 빌드 시 스케줄된 microtask 완료 대기
        await Future<void>.delayed(Duration.zero);

        when(() => mockRepo.update(any(), any()))
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
