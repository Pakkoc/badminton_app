import 'dart:typed_data';

import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/providers/supabase_provider.dart';
import 'package:badminton_app/repositories/shop_repository.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_notifier.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_screen.dart';
import 'package:badminton_app/screens/owner/inventory/inventory_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

class _MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late _MockSupabaseClient mockSupabase;
  late _MockGoTrueClient mockAuth;
  late _MockShopRepository mockShopRepo;

  setUp(() {
    mockSupabase = _MockSupabaseClient();
    mockAuth = _MockGoTrueClient();
    mockShopRepo = _MockShopRepository();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  group('InventoryScreen', () {
    testWidgets('로딩 중일 때 로딩 인디케이터를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
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
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
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
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              InventoryState(items: [testInventoryItem]),
            ),
          ),
        ],
      );

      // Assert
      expect(find.text('BG65'), findsOneWidget);
      expect(find.text('기타'), findsOneWidget);
      expect(find.text('50개'), findsOneWidget);
    });

    testWidgets('AppBar 제목이 "재고 관리"이다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
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

    testWidgets('FAB이 표시된다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              InventoryState(items: [testInventoryItem]),
            ),
          ),
        ],
      );

      // Assert
      expect(
        find.byType(FloatingActionButton),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('에러 상태일 때 에러 뷰를 표시한다', (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
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

    testWidgets('재고 그리드 카드에 이미지 영역이 표시된다',
        (tester) async {
      // Arrange & Act
      await pumpTestApp(
        tester,
        child: const InventoryScreen(),
        overrides: [
          supabaseProvider.overrideWithValue(mockSupabase),
          shopRepositoryProvider.overrideWithValue(mockShopRepo),
          inventoryNotifierProvider.overrideWith(
            () => _FakeInventoryNotifier(
              InventoryState(items: [testInventoryItem]),
            ),
          ),
        ],
      );

      // Assert — 그리드 카드에 아이콘 표시
      expect(
        find.byIcon(Icons.inventory_2),
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
    required InventoryCategory category,
    required int quantity,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async =>
      true;

  @override
  Future<bool> updateItem(
    String id,
    Map<String, dynamic> data, {
    Uint8List? imageBytes,
    String? imageExtension,
  }) async =>
      true;

  @override
  Future<bool> deleteItem(String id) async => true;
}
