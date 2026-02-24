import 'package:badminton_app/screens/customer/order_detail/order_detail_notifier.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_screen.dart';
import 'package:badminton_app/screens/customer/order_detail/order_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

class FakeOrderDetailNotifier extends OrderDetailNotifier {
  final OrderDetailState _initialState;

  FakeOrderDetailNotifier(this._initialState);

  @override
  OrderDetailState build(String arg) => _initialState;

  @override
  Future<void> loadOrder(String orderId) async {}
}

void main() {
  Widget createApp({
    required OrderDetailState state,
    String orderId = '880e8400-e29b-41d4-a716-446655440003',
  }) {
    return ProviderScope(
      overrides: [
        orderDetailNotifierProvider.overrideWith(
          () => FakeOrderDetailNotifier(state),
        ),
      ],
      child: MaterialApp(
        home: OrderDetailScreen(orderId: orderId),
      ),
    );
  }

  group('OrderDetailScreen', () {
    testWidgets(
      '로딩 중일 때 LoadingIndicator를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const OrderDetailState(isLoading: true),
          ),
        );

        // Assert
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AppBar에 작업 상세가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const OrderDetailState(isLoading: true),
          ),
        );

        // Assert
        expect(find.text('작업 상세'), findsOneWidget);
      },
    );

    testWidgets(
      '에러 시 ErrorView를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const OrderDetailState(
              error: '주문 정보를 불러올 수 없습니다',
            ),
          ),
        );

        // Assert
        expect(
          find.text('주문 정보를 불러올 수 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '주문과 샵 정보가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: OrderDetailState(
              order: testOrderReceived,
              shop: testShop,
            ),
          ),
        );

        // Assert
        expect(find.text(testShop.name), findsOneWidget);
        expect(find.text(testShop.address), findsOneWidget);
      },
    );

    testWidgets(
      '타임라인이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: OrderDetailState(
              order: testOrderInProgress,
              shop: testShop,
            ),
          ),
        );

        // Assert
        expect(find.text('타임라인'), findsOneWidget);
        expect(find.text('접수'), findsOneWidget);
        expect(find.text('작업 시작'), findsOneWidget);
        expect(find.text('완료'), findsOneWidget);
      },
    );

    testWidgets(
      '메모가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: OrderDetailState(
              order: testOrderReceived,
              shop: testShop,
            ),
          ),
        );

        // Assert
        expect(find.text('메모'), findsOneWidget);
        expect(find.text('2본 작업'), findsOneWidget);
      },
    );
  });
}
