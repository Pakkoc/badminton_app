import 'package:badminton_app/screens/customer/order_history/order_history_notifier.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_screen.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

class FakeOrderHistoryNotifier extends OrderHistoryNotifier {
  final OrderHistoryState _initialState;

  FakeOrderHistoryNotifier(this._initialState);

  @override
  OrderHistoryState build() => _initialState;

  @override
  Future<void> loadHistory() async {}
}

void main() {
  Widget createApp({
    required OrderHistoryState state,
  }) {
    return ProviderScope(
      overrides: [
        orderHistoryNotifierProvider.overrideWith(
          () => FakeOrderHistoryNotifier(state),
        ),
      ],
      child: const MaterialApp(
        home: OrderHistoryScreen(),
      ),
    );
  }

  group('OrderHistoryScreen', () {
    testWidgets(
      '로딩 중일 때 LoadingIndicator를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(isLoading: true),
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
      'AppBar에 작업 내역이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(isLoading: true),
          ),
        );

        // Assert
        expect(find.text('작업 내역'), findsOneWidget);
      },
    );

    testWidgets(
      '에러 시 ErrorView를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(
              error: '작업 내역을 불러올 수 없습니다',
            ),
          ),
        );

        // Assert
        expect(
          find.text('작업 내역을 불러올 수 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '빈 내역일 때 EmptyState를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(),
          ),
        );

        // Assert
        expect(
          find.text('작업 내역이 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '주문 내역 카드가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: OrderHistoryState(
              orders: [
                testOrderReceived,
                testOrderCompleted,
              ],
            ),
          ),
        );

        // Assert
        expect(find.text('2본 작업'), findsNWidgets(2));
      },
    );
  });
}
