import 'package:badminton_app/core/utils/formatters.dart';
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
        await tester.pumpWidget(
          createApp(
            state: const OrderDetailState(isLoading: true),
          ),
        );
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AppBar에 "작업 상세"가 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const OrderDetailState(isLoading: true),
          ),
        );
        expect(find.text('작업 상세'), findsOneWidget);
      },
    );

    testWidgets(
      '에러 시 ErrorView를 표시한다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: const OrderDetailState(
              error: '주문 정보를 불러올 수 없습니다',
            ),
          ),
        );
        expect(
          find.text('주문 정보를 불러올 수 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '큰 상태 뱃지에 상태 텍스트가 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: OrderDetailState(
              order: testOrderReceived,
              shop: testShop,
            ),
          ),
        );
        // Large badge + timeline 모두에 "접수됨" 표시
        expect(find.text('접수됨'), findsNWidgets(2));
      },
    );

    testWidgets(
      '"진행 상태" 타임라인이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: OrderDetailState(
              order: testOrderInProgress,
              shop: testShop,
            ),
          ),
        );
        expect(find.text('진행 상태'), findsOneWidget);
        expect(find.text('접수됨'), findsOneWidget);
        expect(find.text('작업중'), findsNWidgets(2));
        expect(find.text('완료'), findsOneWidget);
      },
    );

    testWidgets(
      '"작업 메모" 섹션이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: OrderDetailState(
              order: testOrderReceived,
              shop: testShop,
            ),
          ),
        );
        expect(find.text('작업 메모'), findsOneWidget);
        expect(find.text('2본 작업'), findsOneWidget);
      },
    );

    testWidgets(
      '"샵 정보" 섹션에 이름, 주소, 전화, 버튼이 표시된다',
      (tester) async {
        await tester.pumpWidget(
          createApp(
            state: OrderDetailState(
              order: testOrderReceived,
              shop: testShop,
            ),
          ),
        );
        expect(find.text('샵 정보'), findsOneWidget);
        expect(find.text(testShop.name), findsOneWidget);
        expect(find.text(testShop.address), findsOneWidget);
        expect(
          find.text(Formatters.phone(testShop.phone)),
          findsOneWidget,
        );
        expect(find.text('전화하기'), findsOneWidget);
        expect(find.text('길찾기'), findsOneWidget);
      },
    );
  });
}
