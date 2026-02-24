import 'package:badminton_app/screens/customer/home/customer_home_notifier.dart';
import 'package:badminton_app/screens/customer/home/customer_home_screen.dart';
import 'package:badminton_app/screens/customer/home/customer_home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

class FakeCustomerHomeNotifier extends CustomerHomeNotifier {
  final CustomerHomeState _initialState;

  FakeCustomerHomeNotifier(this._initialState);

  @override
  CustomerHomeState build() => _initialState;

  @override
  Future<void> loadOrders() async {}

  @override
  Future<void> refresh() async {}
}

void main() {
  Widget createApp({
    required CustomerHomeState state,
  }) {
    return ProviderScope(
      overrides: [
        customerHomeNotifierProvider.overrideWith(
          () => FakeCustomerHomeNotifier(state),
        ),
      ],
      child: const MaterialApp(
        home: CustomerHomeScreen(),
      ),
    );
  }

  group('CustomerHomeScreen', () {
    testWidgets(
      '로딩 중일 때 LoadingIndicator를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const CustomerHomeState(isLoading: true),
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
      '에러 시 ErrorView를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const CustomerHomeState(
              error: '테스트 에러',
            ),
          ),
        );

        // Assert
        expect(find.text('테스트 에러'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
      },
    );

    testWidgets(
      '빈 주문 목록일 때 EmptyState를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const CustomerHomeState(),
          ),
        );

        // Assert
        expect(
          find.text('아직 진행 중인 작업이 없습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AppBar에 거트알림 타이틀이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const CustomerHomeState(),
          ),
        );

        // Assert
        expect(find.text('거트알림'), findsOneWidget);
      },
    );

    testWidgets(
      '알림 아이콘이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const CustomerHomeState(),
          ),
        );

        // Assert
        expect(
          find.byIcon(Icons.notifications_outlined),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '활성 주문이 있으면 요약 카드와 주문 카드를 표시한다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: CustomerHomeState(
              activeOrders: [
                testOrderReceived,
                testOrderInProgress,
              ],
            ),
          ),
        );

        // Assert
        // 요약 카드의 접수됨 + StatusBadge의 접수됨
        expect(find.text('접수됨'), findsWidgets);
        expect(find.text('작업중'), findsWidgets);
        // 요약 카드에 각각 1건씩
        expect(find.text('1'), findsNWidgets(2));
      },
    );

    testWidgets(
      '주문 카드에 메모가 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: CustomerHomeState(
              activeOrders: [testOrderReceived],
            ),
          ),
        );

        // Assert
        expect(find.text('2본 작업'), findsOneWidget);
      },
    );

    testWidgets(
      '하단 네비게이션이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const CustomerHomeState(),
          ),
        );

        // Assert
        expect(find.text('홈'), findsOneWidget);
        expect(find.text('샵검색'), findsOneWidget);
        expect(find.text('마이페이지'), findsOneWidget);
      },
    );
  });
}
