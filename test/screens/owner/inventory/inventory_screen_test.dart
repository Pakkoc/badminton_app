import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_notifier.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_screen.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

void main() {
  group('InventoryScreen', () {
    testWidgets('로딩 중일 때 로딩 인디케이터를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              const InventoryState(isLoading: true),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );
    });

    testWidgets('재고가 비어있을 때 빈 상태를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              const InventoryState(),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('등록된 상품이 없습니다'), findsOneWidget);
      expect(find.text('상품 추가'), findsWidgets);
    });

    testWidgets('재고 목록을 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              InventoryState(items: [testInventoryItem]),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('BG65'), findsOneWidget);
      expect(find.text('거트'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('AppBar 제목이 "재고 관리"이다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              const InventoryState(),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('재고 관리'), findsOneWidget);
    });

    testWidgets('FAB이 "상품 추가" 텍스트를 표시한다',
        (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              InventoryState(items: [testInventoryItem]),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.widgetWithText(
          FloatingActionButton,
          '상품 추가',
        ),
        findsOneWidget,
      );
    });

    testWidgets('에러 상태일 때 에러 뷰를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              const InventoryState(
                error: '재고 목록을 불러올 수 없습니다',
              ),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.text('재고 목록을 불러올 수 없습니다'),
        findsOneWidget,
      );
    });

    testWidgets('수량 증가/감소 버튼이 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              InventoryState(items: [testInventoryItem]),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.byIcon(Icons.add_circle_outline),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.remove_circle_outline),
        findsOneWidget,
      );
    });
  });
}

class _FakeInventoryNotifier extends InventoryNotifier {
  final InventoryState _initialState;

  _FakeInventoryNotifier(this._initialState);

  @override
  InventoryState build() => _initialState;

  @override
  Future<void> loadItems(String shopId) async {}

  @override
  Future<bool> addItem({
    required String shopId,
    required String name,
    String? category,
    required int quantity,
  }) async =>
      true;

  @override
  Future<bool> updateItem(
    String id,
    Map<String, dynamic> data,
  ) async =>
      true;

  @override
  Future<bool> deleteItem(String id) async => true;
}
