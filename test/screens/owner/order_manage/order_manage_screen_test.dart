import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_notifier.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_screen.dart';
import 'package:badminton_app/screens/owner/order_manage/order_manage_state.dart';
import 'package:badminton_app/widgets/empty_state.dart';
import 'package:badminton_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('OrderManageScreen', () {
    testWidgets('AppBar에 작업 관리를 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderManageNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OrderManageState(isLoading: false),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderManageScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert
      expect(find.text('작업 관리'), findsOneWidget);
    });

    testWidgets('로딩 중일 때 LoadingIndicator를 표시한다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderManageNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OrderManageState(isLoading: true),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderManageScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('작업이 없으면 EmptyState를 표시한다', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderManageNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OrderManageState(
                  isLoading: false,
                  orders: [],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderManageScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('작업이 없습니다'), findsOneWidget);
    });

    testWidgets('상태 필터 탭을 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderManageNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                const OrderManageState(isLoading: false),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderManageScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert: 필터 탭에 카운트가 포함된 텍스트 형식
      expect(find.text('전체 0'), findsOneWidget);
      expect(find.text('접수 0'), findsOneWidget);
      expect(find.text('작업중 0'), findsOneWidget);
      expect(find.text('완료 0'), findsOneWidget);
    });

    testWidgets('작업 목록을 표시한다', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderManageNotifierProvider.overrideWith(
              (_) => _FakeNotifier(
                OrderManageState(
                  isLoading: false,
                  orders: [
                    testOrderReceived,
                    testOrderInProgress,
                  ],
                  memberNames: {
                    testOrderReceived.memberId: '홍길동',
                  },
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: OrderManageScreen(shopId: testShop.id),
          ),
        ),
      );

      // Assert — 회원 이름과 액션 버튼 표시
      expect(
        find.text('홍길동'),
        findsNWidgets(2),
      );
      expect(find.text('작업 시작'), findsOneWidget);
      expect(find.text('작업 완료'), findsOneWidget);
    });
  });
}

class _FakeNotifier extends StateNotifier<OrderManageState>
    implements OrderManageNotifier {
  _FakeNotifier(super.state);

  @override
  Future<void> loadOrders(String shopId) async {}

  @override
  void filterByStatus(OrderStatus? status) {}

  @override
  Future<void> changeStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {}

  @override
  Future<void> deleteOrder(String orderId) async {}
}
