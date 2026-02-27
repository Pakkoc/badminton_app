import 'package:badminton_app/screens/customer/order_history/order_history_notifier.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_screen.dart';
import 'package:badminton_app/screens/customer/order_history/order_history_state.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
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
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(isLoading: true),
          ),
        );
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AppBar에 "작업 이력"이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(isLoading: true),
          ),
        );
        expect(find.text('작업 이력'), findsOneWidget);
      },
    );

    testWidgets(
      '에러 시 ErrorView를 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(
              error: '작업 이력을 불러올 수 없습니다',
            ),
          ),
        );
        expect(
          find.text('작업 이력을 불러올 수 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '빈 이력일 때 빈 상태 메시지를 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(),
          ),
        );
        expect(
          find.text('아직 완료된 작업이 없습니다'),
          findsOneWidget,
        );
        expect(
          find.text('거트 작업이 완료되면 여기에 표시됩니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '완료된 주문 카드에 샵 이름과 완료일이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: OrderHistoryState(
              orders: [testOrderCompleted],
              shopNames: {
                testOrderCompleted.shopId: '거트 프로샵',
              },
            ),
          ),
        );
        expect(find.text('거트 프로샵'), findsOneWidget);
        expect(find.text('완료'), findsOneWidget);
      },
    );

    testWidgets(
      '하단 네비게이션 4탭이 표시된다 (이력 탭 활성)',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const OrderHistoryState(),
          ),
        );
        expect(
          find.byType(CustomerBottomNav),
          findsOneWidget,
        );
        expect(find.text('이력'), findsOneWidget);
      },
    );
  });
}
