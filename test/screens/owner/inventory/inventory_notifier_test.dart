import 'package:badminton_app/core/error/app_exception.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/repositories/inventory_repository.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_notifier.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';

class _MockInventoryRepository extends Mock
    implements InventoryRepository {}

class _FakeInventoryItem extends Fake
    implements InventoryItem {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeInventoryItem());
  });

  late _MockInventoryRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = _MockInventoryRepository();
    container = ProviderContainer(
      overrides: [
        inventoryRepositoryProvider
            .overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('InventoryNotifier', () {
    test('초기 상태는 빈 InventoryState이다', () {
      // Arrange & Act
      final state =
          container.read(inventoryNotifierProvider);

      // Assert
      expect(state, const InventoryState());
      expect(state.items, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    group('loadItems', () {
      test('shopId로 재고 목록을 조회한다', () async {
        // Arrange
        when(() => mockRepo.getByShop(any()))
            .thenAnswer((_) async => [testInventoryItem]);

        final notifier = container.read(
          inventoryNotifierProvider.notifier,
        );

        // Act
        await notifier.loadItems(testShop.id);

        // Assert
        final state =
            container.read(inventoryNotifierProvider);
        expect(state.items, [testInventoryItem]);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('조회 실패 시 에러를 설정한다', () async {
        // Arrange
        when(() => mockRepo.getByShop(any()))
            .thenThrow(AppException.server());

        final notifier = container.read(
          inventoryNotifierProvider.notifier,
        );

        // Act
        await notifier.loadItems(testShop.id);

        // Assert
        final state =
            container.read(inventoryNotifierProvider);
        expect(state.items, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNotNull);
      });
    });

    group('addItem', () {
      test('상품을 추가하고 true를 반환한다', () async {
        // Arrange
        when(() => mockRepo.create(any()))
            .thenAnswer((_) async => testInventoryItem);

        final notifier = container.read(
          inventoryNotifierProvider.notifier,
        );

        // Act
        final result = await notifier.addItem(
          shopId: testShop.id,
          name: 'BG65',
          category: '거트',
          quantity: 50,
        );

        // Assert
        expect(result, isTrue);
        final state =
            container.read(inventoryNotifierProvider);
        expect(state.items, [testInventoryItem]);
      });

      test('추가 실패 시 false를 반환한다', () async {
        // Arrange
        when(() => mockRepo.create(any()))
            .thenThrow(AppException.server());

        final notifier = container.read(
          inventoryNotifierProvider.notifier,
        );

        // Act
        final result = await notifier.addItem(
          shopId: testShop.id,
          name: 'BG65',
          category: '거트',
          quantity: 50,
        );

        // Assert
        expect(result, isFalse);
        final state =
            container.read(inventoryNotifierProvider);
        expect(state.error, isNotNull);
      });
    });

    group('updateItem', () {
      test('상품 수량을 수정하고 true를 반환한다', () async {
        // Arrange
        final updated =
            testInventoryItem.copyWith(quantity: 51);
        when(() => mockRepo.getByShop(any()))
            .thenAnswer((_) async => [testInventoryItem]);
        when(() => mockRepo.update(any(), any()))
            .thenAnswer((_) async => updated);

        final notifier = container.read(
          inventoryNotifierProvider.notifier,
        );
        await notifier.loadItems(testShop.id);

        // Act
        final result = await notifier.updateItem(
          testInventoryItem.id,
          {'quantity': 51},
        );

        // Assert
        expect(result, isTrue);
        final state =
            container.read(inventoryNotifierProvider);
        expect(state.items.first.quantity, 51);
      });

      test('수정 실패 시 false를 반환한다', () async {
        // Arrange
        when(() => mockRepo.update(any(), any()))
            .thenThrow(AppException.server());

        final notifier = container.read(
          inventoryNotifierProvider.notifier,
        );

        // Act
        final result = await notifier.updateItem(
          testInventoryItem.id,
          {'quantity': 51},
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('deleteItem', () {
      test('상품을 삭제하고 true를 반환한다', () async {
        // Arrange
        when(() => mockRepo.getByShop(any()))
            .thenAnswer((_) async => [testInventoryItem]);
        when(() => mockRepo.delete(any()))
            .thenAnswer((_) async {});

        final notifier = container.read(
          inventoryNotifierProvider.notifier,
        );
        await notifier.loadItems(testShop.id);

        // Act
        final result = await notifier.deleteItem(
          testInventoryItem.id,
        );

        // Assert
        expect(result, isTrue);
        final state =
            container.read(inventoryNotifierProvider);
        expect(state.items, isEmpty);
      });

      test('삭제 실패 시 false를 반환한다', () async {
        // Arrange
        when(() => mockRepo.delete(any()))
            .thenThrow(AppException.server());

        final notifier = container.read(
          inventoryNotifierProvider.notifier,
        );

        // Act
        final result = await notifier.deleteItem(
          testInventoryItem.id,
        );

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
