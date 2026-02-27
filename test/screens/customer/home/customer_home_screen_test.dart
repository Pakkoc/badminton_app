import 'package:badminton_app/screens/customer/home/customer_home_notifier.dart';
import 'package:badminton_app/screens/customer/home/customer_home_screen.dart';
import 'package:badminton_app/screens/customer/home/customer_home_state.dart';
import 'package:badminton_app/widgets/customer_bottom_nav.dart';
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
      '빈 상태 — 일러스트, 메시지, CTA 버튼 표시',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const CustomerHomeState(),
          ),
        );

        // Assert
        expect(
          find.byIcon(Icons.sports_tennis),
          findsOneWidget,
        );
        expect(
          find.text('아직 진행 중인 작업이 없습니다'),
          findsOneWidget,
        );
        expect(
          find.text('주변 샵을 검색해 거트를 맡겨보세요'),
          findsOneWidget,
        );
        expect(
          find.text('주변 샵 검색하기'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AppBar에 거트알림 타이틀이 녹색으로 표시된다',
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
      '활성 주문이 있으면 요약 카드를 "접수 N건 / 작업중 N건" 형식으로 표시',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: CustomerHomeState(
              activeOrders: [
                testOrderReceived,
                testOrderInProgress,
              ],
              shopNames: {
                testOrderReceived.shopId: '거트 프로샵',
              },
            ),
          ),
        );

        // Assert
        expect(find.text('접수 1건'), findsOneWidget);
        expect(find.text('작업중 1건'), findsOneWidget);
      },
    );

    testWidgets(
      '"내 작업" 섹션 타이틀이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: CustomerHomeState(
              activeOrders: [testOrderReceived],
              shopNames: {
                testOrderReceived.shopId: '거트 프로샵',
              },
            ),
          ),
        );

        // Assert
        expect(find.text('내 작업'), findsOneWidget);
      },
    );

    testWidgets(
      '작업 카드에 샵 이름이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: CustomerHomeState(
              activeOrders: [testOrderReceived],
              shopNames: {
                testOrderReceived.shopId: '거트 프로샵',
              },
            ),
          ),
        );

        // Assert
        expect(find.text('거트 프로샵'), findsOneWidget);
      },
    );

    testWidgets(
      '작업 카드에 접수 시간이 "접수 HH:mm" 형식으로 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: CustomerHomeState(
              activeOrders: [testOrderReceived],
              shopNames: {
                testOrderReceived.shopId: '거트 프로샵',
              },
            ),
          ),
        );

        // Assert
        expect(find.text('접수 10:00'), findsOneWidget);
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
              shopNames: {
                testOrderReceived.shopId: '거트 프로샵',
              },
            ),
          ),
        );

        // Assert
        expect(find.text('2본 작업'), findsOneWidget);
      },
    );

    testWidgets(
      '하단 네비게이션 4탭이 표시된다',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createApp(
            state: const CustomerHomeState(),
          ),
        );

        // Assert
        expect(
          find.byType(CustomerBottomNav),
          findsOneWidget,
        );
        expect(find.text('홈'), findsOneWidget);
        expect(find.text('샵검색'), findsOneWidget);
        expect(find.text('이력'), findsOneWidget);
        expect(find.text('MY'), findsOneWidget);
      },
    );
  });
}
