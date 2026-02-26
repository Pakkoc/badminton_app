import 'package:badminton_app/screens/owner/order_create/order_create_notifier.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_screen.dart';
import 'package:badminton_app/screens/owner/order_create/order_create_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('OrderCreateScreen', () {
    testWidgets('AppBar에 작업 접수를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderCreateNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OrderCreateState(),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderCreateScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert
      expect(find.text('작업 접수'), findsOneWidget);
    });

    testWidgets('회원 검색 필드를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderCreateNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OrderCreateState(),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderCreateScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert
      expect(find.text('회원 검색'), findsOneWidget);
      expect(
        find.text('이름 또는 전화번호'),
        findsOneWidget,
      );
    });

    testWidgets('선택된 회원을 카드로 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderCreateNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                OrderCreateState(
                  selectedMember: testMember,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderCreateScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert
      expect(
        find.text('홍길동 (01012345678)'),
        findsOneWidget,
      );
    });

    testWidgets('회원 미선택 시 접수 버튼이 비활성화된다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderCreateNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OrderCreateState(),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderCreateScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert: "작업 접수하기" 텍스트를 포함한 ElevatedButton을 찾아 비활성화 확인
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작업 접수하기'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('회원 선택 시 접수 버튼이 활성화된다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderCreateNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                OrderCreateState(
                  selectedMember: testMember,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderCreateScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert: "작업 접수하기" 텍스트를 포함한 ElevatedButton을 찾아 활성화 확인
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '작업 접수하기'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('검색 결과가 있으면 리스트를 표시한다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderCreateNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                OrderCreateState(
                  searchResults: [testMember],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderCreateScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert
      expect(find.text('홍길동'), findsOneWidget);
      expect(find.text('01012345678'), findsOneWidget);
    });
  });
}

class _FakeNotifier extends StateNotifier<OrderCreateState>
    implements OrderCreateNotifier {
  _FakeNotifier(super.state);

  @override
  Future<void> searchMembers(
    String shopId,
    String query,
  ) async {}

  @override
  void selectMember(dynamic member) {}

  @override
  void updateMemo(String memo) {}

  @override
  Future<void> submit(String shopId) async {}

  @override
  void reset() {}
}
